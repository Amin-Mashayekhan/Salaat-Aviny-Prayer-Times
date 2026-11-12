"""Decode the location databases of the legacy "Aviny Prayer Times" (2013) app.

The legacy files (Countries_Enc.xml, Provinces_Enc.xml, Cities_Enc.xml) are not
really encrypted: each one is  Base64( UTF-8( XOR-129 of every UTF-16 code unit ) )
of a .NET DataSet XML document.

Usage:
    python -I decode_legacy_locations.py "<legacy install dir>" "<output dir>"

Output (UTF-8 JSON, stable ordering, one record per line for readable diffs):
    countries.json           all legacy countries (Persian + English names, legacy UTC offset)
    provinces.json           the 31 provinces of Iran
    cities_iran.json         Iranian cities (decimal coordinates, province, type)
    cities_world_legacy.json the few non-Iranian cities of the legacy DB (reference only)

Deliberately DROPPED from the output: the legacy `Daylight`, `Daylight_Begin` and
`Daylight_End` country columns. They are the root cause of the legacy one-hour bug
and must never be used by the new app.
"""
from __future__ import annotations

import base64
import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

XOR_KEY = 129
CITY_TYPE = {"C": "capital", "S": "province_center", "N": "normal"}
# Arabic code points that legacy data mixes with Persian ones.
NORMALIZE = str.maketrans({"ي": "ی", "ك": "ک", "ى": "ی", "‏": "", "‎": ""})

# Curated fixes for the provinces of Iran: (corrected Persian name, English name).
# The legacy DB has English names for only 2 provinces and misspells two Persian ones.
PROVINCES = {
    1: ("تهران", "Tehran"), 5: ("اردبیل", "Ardabil"), 6: ("آذربایجان غربی", "West Azerbaijan"),
    7: ("مرکزی", "Markazi"), 8: ("اصفهان", "Isfahan"), 9: ("خوزستان", "Khuzestan"),
    10: ("ایلام", "Ilam"), 11: ("بوشهر", "Bushehr"), 12: ("آذربایجان شرقی", "East Azerbaijan"),
    13: ("لرستان", "Lorestan"), 14: ("گیلان", "Gilan"), 15: ("زنجان", "Zanjan"),
    16: ("سیستان و بلوچستان", "Sistan and Baluchestan"), 17: ("سمنان", "Semnan"),
    18: ("کردستان", "Kurdistan"), 19: ("مازندران", "Mazandaran"), 20: ("فارس", "Fars"),
    21: ("قزوین", "Qazvin"), 22: ("قم", "Qom"), 23: ("کرمان", "Kerman"),
    24: ("کرمانشاه", "Kermanshah"), 25: ("گلستان", "Golestan"), 26: ("خراسان رضوی", "Razavi Khorasan"),
    27: ("همدان", "Hamadan"), 28: ("چهارمحال و بختیاری", "Chaharmahal and Bakhtiari"),
    29: ("کهگیلویه و بویراحمد", "Kohgiluyeh and Boyer-Ahmad"), 30: ("یزد", "Yazd"),
    31: ("هرمزگان", "Hormozgan"), 32: ("البرز", "Alborz"), 33: ("خراسان شمالی", "North Khorasan"),
    34: ("خراسان جنوبی", "South Khorasan"),
}
# Legacy rows with a missing province that can be assigned with certainty.
CITY_PROVINCE_FIX = {230: 1}  # Damavand -> Tehran province
TYPE_RANK = {"capital": 0, "province_center": 1, "normal": 2}


def has_persian(text: str) -> bool:
    return any("؀" <= ch <= "ۿ" for ch in text)


def decode(path: Path) -> ET.Element:
    raw = path.read_bytes()
    if raw.startswith(b"\xef\xbb\xbf"):
        raw = raw[3:]
    text = base64.b64decode(raw).decode("utf-8")
    return ET.fromstring("".join(chr(ord(ch) ^ XOR_KEY) for ch in text))


def rows(root: ET.Element) -> list[dict[str, str]]:
    return [{child.tag: (child.text or "").strip() for child in element} for element in root]


def clean(text: str) -> str:
    return " ".join(text.translate(NORMALIZE).split())


def dms(deg: str, minute: str, sec: str, hemisphere: str) -> float:
    value = float(deg or 0) + float(minute or 0) / 60 + float(sec or 0) / 3600
    if hemisphere.upper() in ("S", "W"):
        value = -value
    return round(value, 5)


def dump(path: Path, records: list[dict]) -> None:
    lines = ",\n".join("  " + json.dumps(r, ensure_ascii=False, sort_keys=False) for r in records)
    path.write_text("[\n" + lines + "\n]\n", encoding="utf-8")
    print(f"{path.name}: {len(records)} records")


def main(src: Path, out: Path) -> None:
    out.mkdir(parents=True, exist_ok=True)
    countries = rows(decode(src / "Countries_Enc.xml"))
    provinces = rows(decode(src / "Provinces_Enc.xml"))
    cities = rows(decode(src / "Cities_Enc.xml"))

    country_out = []
    for c in countries:
        code = int(c["Code"])
        name_en = clean(c.get("LName", ""))
        if code == 0 or not name_en:  # placeholder / junk rows
            continue
        country_out.append({
            "id": code,
            "name_fa": clean(c["Name"]),
            "name_en": name_en,
            "legacy_utc_offset_hours": float(c["Time_Zone"] or 0),
        })
    country_out.sort(key=lambda r: r["id"])
    valid_countries = {c["id"] for c in country_out}

    province_out = sorted(
        ({
            "id": int(p["Code"]),
            "country_id": int(p["Country_Code"]),
            "name_fa": PROVINCES[int(p["Code"])][0],
            "name_en": PROVINCES[int(p["Code"])][1],
            "center_city_id": int(p["Center_City_Code"]) if p.get("Center_City_Code") else None,
        } for p in provinces),
        key=lambda r: r["id"],
    )

    iran, world = [], []
    for c in cities:
        country_id = int(c["Country_Code"] or 0)
        if country_id not in valid_countries:
            continue
        record = {
            "id": int(c["Code"]),
            "country_id": country_id,
            "province_id": int(c["Province_Code"]) if c.get("Province_Code") not in (None, "", "0") else None,
            "name_fa": clean(c["Name"]),
            "name_en": clean(c.get("LName", "")),
            "latitude": dms(c["Latitude_D"], c["Latitude_M"], c["Latitude_S"], c["NorthSouth"]),
            "longitude": dms(c["Longitude_D"], c["Longitude_M"], c["Longitude_S"], c["EastWest"]),
            "elevation_m": float(c.get("Elevation") or 0),
            "type": CITY_TYPE.get(c.get("Type", "N"), "normal"),
            "verified": c.get("Approved") == "Y",
        }
        if record["latitude"] == 0 and record["longitude"] == 0:
            continue  # junk coordinates
        if country_id == 1:
            record["province_id"] = CITY_PROVINCE_FIX.get(record["id"], record["province_id"])
            # `verified` = approved in the legacy DB AND has a real Persian name.
            record["verified"] = record["verified"] and has_persian(record["name_fa"])
            record["time_zone"] = "Asia/Tehran"
            iran.append(record)
        else:
            world.append(record)

    # The legacy DB lists ~25 cities twice (once as province centre, once as a plain
    # city a few km away). Keep one row per (name, province): best type, then lowest id.
    iran.sort(key=lambda r: (TYPE_RANK[r["type"]], r["id"]))
    seen: set[tuple[str, int | None]] = set()
    deduped = []
    for record in iran:
        key = (record["name_fa"], record["province_id"])
        if key in seen:
            continue
        seen.add(key)
        deduped.append(record)
    iran = sorted(deduped, key=lambda r: r["id"])
    world.sort(key=lambda r: r["id"])

    dump(out / "countries.json", country_out)
    dump(out / "provinces.json", province_out)
    dump(out / "cities_iran.json", iran)
    dump(out / "cities_world_legacy.json", world)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(Path(sys.argv[1]), Path(sys.argv[2]))
