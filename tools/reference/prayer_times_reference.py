"""Reference implementation of the prayer-time algorithm specified in
docs/04-DOMAIN-SPEC.md, plus the generator of the golden test vectors.

This file is the executable form of the spec. The Dart implementation in
`packages/prayer_core` must be a faithful port of `compute()` below and must
reproduce `seed/golden/prayer_times_golden.json` to within +/- 1 second.

It is a PURE function of (date, latitude, longitude, elevation, utc offset,
method parameters). It knows nothing about time zones, DST, the system clock
or settings - on purpose (see "Time model" in the domain spec).

Usage:
    python -I prayer_times_reference.py generate <output.json>   # write golden vectors
    python -I prayer_times_reference.py show 2026-03-21 35.6892 51.3890 210 tehran
"""
from __future__ import annotations

import json
import math
import sys
from dataclasses import dataclass, asdict
from datetime import date, timedelta

# --------------------------------------------------------------------------- methods


@dataclass(frozen=True)
class Method:
    fajr_angle: float                    # sun depression (degrees) at Fajr
    isha_angle: float | None             # sun depression at Isha, or None when isha_minutes is used
    isha_minutes: float | None = None    # Isha = Maghrib + minutes (Umm al-Qura)
    maghrib_angle: float | None = None   # sun depression at Maghrib, None = Maghrib is sunset
    midnight: str = "standard"           # "standard": sunset->sunrise, "jafari": sunset->next Fajr


METHODS: dict[str, Method] = {
    "tehran": Method(17.7, 14.0, maghrib_angle=4.5, midnight="jafari"),   # Institute of Geophysics, Univ. of Tehran
    "jafari": Method(16.0, 14.0, maghrib_angle=4.0, midnight="jafari"),   # Leva Institute, Qom
    "mwl": Method(18.0, 17.0),                                            # Muslim World League
    "isna": Method(15.0, 15.0),                                           # Islamic Society of North America
    "egypt": Method(19.5, 17.5),                                          # Egyptian General Authority of Survey
    "makkah": Method(18.5, None, isha_minutes=90.0),                      # Umm al-Qura University, Makkah
    "karachi": Method(18.0, 18.0),                                        # Univ. of Islamic Sciences, Karachi
}

ASR_SHADOW_FACTOR = {"standard": 1.0, "hanafi": 2.0}
HIGH_LATITUDE_RULES = ("none", "night_middle", "one_seventh", "angle_based")
REFINE_PASSES = 3  # fixed number of refinement passes (deterministic, converges to < 0.1 s)

# --------------------------------------------------------------------------- math helpers


def _sin(d: float) -> float: return math.sin(math.radians(d))
def _cos(d: float) -> float: return math.cos(math.radians(d))
def _tan(d: float) -> float: return math.tan(math.radians(d))
def _asin(x: float) -> float: return math.degrees(math.asin(x))
def _acos(x: float) -> float: return math.degrees(math.acos(x))
def _atan2(y: float, x: float) -> float: return math.degrees(math.atan2(y, x))
def _acot(x: float) -> float: return math.degrees(math.atan(1.0 / x))


def _fix(value: float, modulus: float) -> float:
    """Reduce into [0, modulus)."""
    value = value - modulus * math.floor(value / modulus)
    return value + modulus if value < 0 else value


def julian_day(year: int, month: int, day: int) -> float:
    """Julian Day at 00:00 UT of a Gregorian calendar date."""
    if month <= 2:
        year -= 1
        month += 12
    a = math.floor(year / 100)
    b = 2 - a + math.floor(a / 4)
    return math.floor(365.25 * (year + 4716)) + math.floor(30.6001 * (month + 1)) + day + b - 1524.5


def sun_position(jd: float) -> tuple[float, float]:
    """(declination in degrees, equation of time in hours) - USNO low-precision
    formulas, accurate to about 1 arc-minute between 1950 and 2050."""
    d = jd - 2451545.0
    g = _fix(357.529 + 0.98560028 * d, 360.0)
    q = _fix(280.459 + 0.98564736 * d, 360.0)
    lam = _fix(q + 1.915 * _sin(g) + 0.020 * _sin(2 * g), 360.0)
    e = 23.439 - 0.00000036 * d
    ra = _fix(_atan2(_cos(e) * _sin(lam), _cos(lam)) / 15.0, 24.0)
    decl = _asin(_sin(e) * _sin(lam))
    eqt = q / 15.0 - ra
    return decl, eqt


# --------------------------------------------------------------------------- core


def _compute_day(d: date, lat: float, lon: float, elevation_m: float, method: Method,
                 asr: str, high_latitude: str) -> dict[str, float | None]:
    """Times of one calendar day in hours of *UT + longitude/15* ("local mean
    time" frame), not yet shifted to a civil offset. None = does not occur."""
    jd = julian_day(d.year, d.month, d.day) - lon / (15.0 * 24.0)

    def mid_day(t: float) -> float:
        _, eqt = sun_position(jd + t)
        return _fix(12.0 - eqt, 24.0)

    def angle_time(angle: float, t: float, before_noon: bool) -> float | None:
        """Time at which the sun is `angle` degrees BELOW the horizon."""
        decl, _ = sun_position(jd + t)
        noon = mid_day(t)
        x = (-_sin(angle) - _sin(decl) * _sin(lat)) / (_cos(decl) * _cos(lat))
        if x < -1.0 or x > 1.0:
            return None
        h = _acos(x) / 15.0
        return noon - h if before_noon else noon + h

    def asr_time(factor: float, t: float) -> float | None:
        decl, _ = sun_position(jd + t)
        angle = -_acot(factor + _tan(abs(lat - decl)))
        return angle_time(angle, t, before_noon=False)

    horizon = 0.833 + 0.0347 * math.sqrt(max(elevation_m, 0.0))  # refraction + semi-diameter + dip
    # initial guesses, as fractions of a day
    t = {"fajr": 5 / 24, "sunrise": 6 / 24, "dhuhr": 12 / 24, "asr": 13 / 24,
         "sunset": 18 / 24, "maghrib": 18 / 24, "isha": 18 / 24}
    out: dict[str, float | None] = {}
    for _ in range(REFINE_PASSES):
        out = {
            "fajr": angle_time(method.fajr_angle, t["fajr"], True),
            "sunrise": angle_time(horizon, t["sunrise"], True),
            "dhuhr": mid_day(t["dhuhr"]),
            "asr": asr_time(ASR_SHADOW_FACTOR[asr], t["asr"]),
            "sunset": angle_time(horizon, t["sunset"], False),
            "maghrib": angle_time(method.maghrib_angle, t["maghrib"], False)
            if method.maghrib_angle is not None else None,
            "isha": angle_time(method.isha_angle, t["isha"], False)
            if method.isha_angle is not None else None,
        }
        for key, value in out.items():
            if value is not None:
                t[key] = value / 24.0

    # ---- high-latitude adjustment (needs sunrise and sunset to exist)
    if high_latitude != "none" and out["sunrise"] is not None and out["sunset"] is not None:
        night = _fix(out["sunrise"] - out["sunset"], 24.0)

        def portion(angle: float) -> float:
            if high_latitude == "angle_based":
                return angle / 60.0 * night
            if high_latitude == "one_seventh":
                return night / 7.0
            return night / 2.0

        def adjust(value: float | None, base: float, angle: float, before: bool) -> float:
            limit = portion(angle)
            diff = None if value is None else (_fix(base - value, 24.0) if before else _fix(value - base, 24.0))
            if diff is None or diff > limit:
                return base - limit if before else base + limit
            return value

        out["fajr"] = adjust(out["fajr"], out["sunrise"], method.fajr_angle, True)
        if method.isha_angle is not None:
            out["isha"] = adjust(out["isha"], out["sunset"], method.isha_angle, False)
        if method.maghrib_angle is not None:
            out["maghrib"] = adjust(out["maghrib"], out["sunset"], method.maghrib_angle, False)

    if method.maghrib_angle is None:
        out["maghrib"] = out["sunset"]
    if method.isha_angle is None:
        out["isha"] = None if out["maghrib"] is None else out["maghrib"] + (method.isha_minutes or 0) / 60.0
    return out


def compute(d: date, lat: float, lon: float, elevation_m: float, utc_offset_hours: float,
            method_id: str, asr: str = "standard", high_latitude: str = "night_middle",
            imsak_minutes: float = 10.0) -> dict[str, float | None]:
    """Prayer times of civil date `d` as hours after local midnight of `d`, in the
    civil time `UT + utc_offset_hours`. `midnight` may exceed 24 (it then falls
    after 00:00 of the next civil day). None = the event does not occur that day."""
    method = METHODS[method_id]
    today = _compute_day(d, lat, lon, elevation_m, method, asr, high_latitude)
    shift = utc_offset_hours - lon / 15.0
    out: dict[str, float | None] = {k: (None if v is None else v + shift) for k, v in today.items()}
    out["imsak"] = None if out["fajr"] is None else out["fajr"] - imsak_minutes / 60.0

    # Islamic midnight: midpoint of the night that starts at today's sunset.
    out["midnight"] = None
    if out["sunset"] is not None:
        tomorrow = _compute_day(d + timedelta(days=1), lat, lon, elevation_m, method, asr, high_latitude)
        end = tomorrow["fajr"] if method.midnight == "jafari" else tomorrow["sunrise"]
        if end is not None:
            out["midnight"] = out["sunset"] + (end + shift + 24.0 - out["sunset"]) / 2.0
    return out


ORDER = ("imsak", "fajr", "sunrise", "dhuhr", "asr", "sunset", "maghrib", "isha", "midnight")


def qibla_bearing(lat: float, lon: float) -> float:
    """Initial great-circle bearing to the Kaaba, degrees clockwise from true north."""
    k_lat, k_lon = 21.422487, 39.826206
    y = _sin(k_lon - lon)
    x = _cos(lat) * _tan(k_lat) - _sin(lat) * _cos(k_lon - lon)
    return _fix(_atan2(y, x), 360.0)


# --------------------------------------------------------------------------- formatting


def to_seconds(hours: float | None) -> int | None:
    """Seconds after local midnight, rounded half-up to the nearest second."""
    return None if hours is None else int(math.floor(hours * 3600.0 + 0.5))


def display_minute(hours: float | None) -> str | None:
    """Displayed clock time: rounded half-up to the nearest minute, wrapped to 24 h."""
    if hours is None:
        return None
    minutes = int(math.floor(hours * 60.0 + 0.5)) % 1440
    return f"{minutes // 60:02d}:{minutes % 60:02d}"


# --------------------------------------------------------------------------- golden vectors

PLACES = [
    # id, name, lat, lon, elevation, [(method, asr)], offset rule
    ("tehran", "Tehran", 35.6892, 51.3890, 0.0, [("tehran", "standard"), ("jafari", "standard")], "iran"),
    ("mashhad", "Mashhad", 36.2970, 59.6062, 0.0, [("tehran", "standard")], "iran"),
    ("tabriz", "Tabriz", 38.0800, 46.2919, 0.0, [("tehran", "standard")], "iran"),
    ("shiraz", "Shiraz", 29.5918, 52.5837, 0.0, [("tehran", "standard")], "iran"),
    ("qom", "Qom", 34.6401, 50.8764, 0.0, [("tehran", "standard"), ("jafari", "standard")], "iran"),
    ("bandar_abbas", "Bandar Abbas", 27.1832, 56.2666, 0.0, [("tehran", "standard")], "iran"),
    ("zahedan", "Zahedan", 29.4963, 60.8629, 1352.0, [("tehran", "standard")], "iran"),
    ("london", "London", 51.5074, -0.1278, 0.0, [("mwl", "standard"), ("isna", "hanafi")], "uk"),
    ("makkah", "Makkah", 21.3891, 39.8579, 0.0, [("makkah", "standard")], "fixed:3"),
    ("jakarta", "Jakarta", -6.2088, 106.8456, 0.0, [("egypt", "standard")], "fixed:7"),
    ("tromso", "Tromso", 69.6492, 18.9553, 0.0, [("mwl", "standard")], "fixed:1"),
]
DATES = ["2024-02-29", "2025-03-20", "2025-03-21", "2025-03-22", "2025-09-21", "2025-09-22", "2025-09-23",
         "2026-01-01", "2026-03-20", "2026-03-21", "2026-03-22", "2026-04-15", "2026-06-21",
         "2026-09-21", "2026-09-22", "2026-09-23", "2026-11-11", "2026-12-21", "2027-03-21", "2030-07-01"]


def _offset(rule: str, d: date) -> float:
    if rule == "iran":
        return 3.5          # Iran: UTC+03:30 on EVERY date. No DST. Ever. (domain spec, section "Time model")
    if rule == "uk":         # explicit input of the vectors; the core never decides this itself
        return 1.0 if date(d.year, 4, 1) <= d <= date(d.year, 10, 20) else 0.0
    return float(rule.split(":")[1])


def generate(path: str) -> None:
    vectors = []
    for pid, name, lat, lon, elev, combos, rule in PLACES:
        for method, asr in combos:
            for hl in (("night_middle", "none") if pid == "tromso" else ("night_middle",)):
                for iso in DATES:
                    d = date.fromisoformat(iso)
                    off = _offset(rule, d)
                    times = compute(d, lat, lon, elev, off, method, asr, hl)
                    vectors.append({
                        "place": pid, "date": iso, "latitude": lat, "longitude": lon, "elevation_m": elev,
                        "utc_offset_minutes": int(off * 60), "method": method, "asr": asr,
                        "high_latitude": hl, "imsak_minutes": 10,
                        "seconds": {k: to_seconds(times[k]) for k in ORDER},
                        "display": {k: display_minute(times[k]) for k in ORDER},
                    })
    doc = {
        "description": "Golden vectors generated by tools/reference/prayer_times_reference.py. "
                       "`seconds` = seconds after local midnight of `date` (may exceed 86400 for midnight); "
                       "null = event does not occur. Dart port must match `seconds` within +/-1 and `display` exactly.",
        "methods": {k: asdict(v) for k, v in METHODS.items()},
        "qibla": [{"place": p[0], "latitude": p[2], "longitude": p[3], "bearing_deg": round(qibla_bearing(p[2], p[3]), 3)}
                  for p in PLACES if p[0] != "makkah"],
        "vectors": vectors,
    }
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write('{\n"description": ' + json.dumps(doc["description"]) + ',\n"methods": ' + json.dumps(doc["methods"])
                 + ',\n"qibla": ' + json.dumps(doc["qibla"]) + ',\n"vectors": [\n'
                 + ",\n".join(json.dumps(v) for v in vectors) + "\n]\n}\n")
    print(f"{len(vectors)} vectors -> {path}")


if __name__ == "__main__":
    if len(sys.argv) >= 3 and sys.argv[1] == "generate":
        generate(sys.argv[2])
    elif len(sys.argv) >= 7 and sys.argv[1] == "show":
        day = date.fromisoformat(sys.argv[2])
        result = compute(day, float(sys.argv[3]), float(sys.argv[4]), 0.0, float(sys.argv[5]) / 60.0, sys.argv[6])
        for key in ORDER:
            print(f"{key:9s} {display_minute(result[key])}")
    else:
        sys.exit(__doc__)
