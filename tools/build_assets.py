"""Builds the app's bundled data from seed/locations.

Keeps only verified Iranian cities and the fields the app needs.
Run from the repo root:  python -I tools/build_assets.py
"""
import json
from pathlib import Path

root = Path(__file__).resolve().parent.parent
seed = root / "seed" / "locations"
out = root / "packages" / "owghat_lib" / "assets" / "data"
out.mkdir(parents=True, exist_ok=True)

provinces = json.loads((seed / "provinces.json").read_text(encoding="utf-8"))
cities = json.loads((seed / "cities_iran.json").read_text(encoding="utf-8"))
province_ids = {p["id"] for p in provinces}
# A city without a known province cannot be shown in the province browser; skip it.
verified = [c for c in cities if c["verified"] and c["province_id"] in province_ids]
city_ids = {c["id"] for c in verified}
for p in provinces:
    assert p["center_city_id"] in city_ids, f"province {p['id']} centre not verified"
for c in verified:
    assert c["province_id"] in province_ids, f"city {c['id']} without province"

compact_provinces = [
    {"id": p["id"], "fa": p["name_fa"], "en": p["name_en"], "center": p["center_city_id"]}
    for p in provinces
]
compact_cities = [
    {
        "id": c["id"], "p": c["province_id"], "fa": c["name_fa"], "en": c["name_en"],
        "lat": c["latitude"], "lon": c["longitude"], "t": c["type"][0],
    }
    for c in verified
]
(out / "provinces.json").write_text(json.dumps(compact_provinces, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
(out / "cities.json").write_text(json.dumps(compact_cities, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
print(len(compact_provinces), "provinces,", len(compact_cities), "cities")
