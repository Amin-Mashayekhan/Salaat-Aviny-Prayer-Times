"""Merge new UI strings into the two ARB files (Persian is the template).

Usage:  python -I tools/arb_merge.py <snippet.json>
Snippet format: { "key": ["persian", "english"] }  or
                { "key": {"fa": "...", "en": "...", "ph": ["name", "count"]} }
`ph` lists String placeholders used as {name} in both texts.
Existing keys are overwritten, so a snippet can also be used to fix a text.
"""
import json
import sys
from pathlib import Path

arb_dir = Path(__file__).resolve().parent.parent / "packages" / "owghat_lib" / "lib" / "l10n"


def load(name):
    path = arb_dir / name
    return json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}


def main(snippet_path):
    snippet = json.loads(Path(snippet_path).read_text(encoding="utf-8"))
    fa, en = load("app_fa.arb"), load("app_en.arb")
    fa.setdefault("@@locale", "fa")
    en.setdefault("@@locale", "en")
    for key, value in snippet.items():
        if isinstance(value, list):
            value = {"fa": value[0], "en": value[1], "ph": []}
        fa[key], en[key] = value["fa"], value["en"]
        if value.get("ph"):
            meta = {"placeholders": {p: {"type": "String"} for p in value["ph"]}}
            fa["@" + key] = meta
            en["@" + key] = meta
    for name, data in (("app_fa.arb", fa), ("app_en.arb", en)):
        ordered = {"@@locale": data["@@locale"]}
        for k in sorted(k for k in data if k != "@@locale" and not k.startswith("@")):
            ordered[k] = data[k]
            if "@" + k in data:
                ordered["@" + k] = data["@" + k]
        (arb_dir / name).write_text(json.dumps(ordered, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(len(snippet), "keys merged")


if __name__ == "__main__":
    main(sys.argv[1])
