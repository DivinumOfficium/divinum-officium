"""Import a translated martyrology.

The translator writes plain files, one per day, as the martyrology
has always been stored: heading line, '_', then one elogium per line. Name
them MM-DD.txt and point --src at the folder.

    python import_translation.py --lang Deutsch --from 1960 --src ~/deutsch

    --lang             folder under web/www/horas/
    --from             Latin version the translation follows: base, 1955R, 1960
    --src              folder of MM-DD.txt files, any subset of the year
    --replace          re-import days already there
    --enable-versions  also write the opt-in files under Martyrologium1960
                       etc. so those days follow that version's order.
                       Without it a day renders as written under every
                       version, which is what you usually want.

It keeps a copy of the files under source/, matches
each line against the Latin, learns the language's name list into
namelex/, then matches again now that it knows the names.

Lines that name the same saints as a Latin elogium get that Latin key, so
they line up with the other languages; the rest keep a key of their own.
The percentage is reported and never enforced.

To redo a language already in the tree, point --src at its own source/
folder and pass --replace.
"""

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "internal"))

import cognates
import learn_names
from martyrlib import all_days, do_read_lines, elogia_path, flat_path
from convertlib import convert_day

VERSIONS = {
    "base": "", "divino": "", "1910": "", "1954": "",
    "1955": "1955R", "1955r": "1955R",
    "1960": "1960", "rubrics1960": "1960", "newcal": "1960",
}


def read_days(src):
    """Every MM-DD.txt in src, as {day: lines}."""
    days, bad = {}, {}
    known = set(all_days())
    for path in sorted(src.glob("*.txt")):
        if path.stem not in known:
            continue
        try:
            days[path.stem] = do_read_lines(path)
        except UnicodeDecodeError as e:
            bad[path.stem] = f"not valid UTF-8 ({e.reason} at byte {e.start})"
    return days, bad


def convert_all(days, suffix, skipped):
    """Convert every day, returning {day: pool} and the match totals."""
    pools, agg = {}, {"aligned": 0, "extras": 0, "structural": 0}
    for day, lines in days.items():
        pool, stats, err = convert_day(day, lines, suffix)
        if err:
            skipped[day] = err
            continue
        pools[day] = pool
        for k in agg:
            agg[k] += stats[k]
    return pools, agg


def rate(agg):
    total = agg["aligned"] + agg["extras"]
    pct = f"{100 * agg['aligned'] / total:.1f}%" if total else "n/a"
    return f"{agg['aligned']}/{total} lines to Latin keys ({pct})"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--lang", required=True)
    ap.add_argument("--from", dest="version", required=True,
                    help="base | 1955R | 1960")
    ap.add_argument("--src", required=True)
    ap.add_argument("--replace", action="store_true")
    ap.add_argument("--enable-versions", metavar="LIST",
                    help="space/comma list drawn from: 1955R 1960")
    args = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

    suffix = VERSIONS.get(args.version.lower().replace(" ", ""))
    if suffix is None:
        sys.exit(f"unknown version {args.version!r}; use base, 1955R or 1960")

    enable = []
    if args.enable_versions:
        enable = [t for t in args.enable_versions.replace(",", " ").split()
                  if t != "base"]
        bad = [t for t in enable if t not in ("1955R", "1960")]
        if bad:
            sys.exit(f"unknown version(s) in --enable-versions: {bad}")

    src = Path(args.src)
    days, skipped = read_days(src)
    if not days:
        sys.exit(f"no MM-DD.txt files found in {src}")

    if not args.replace:
        already = [d for d in days if elogia_path(args.lang, d).exists()]
        for d in already:
            skipped[d] = "already imported (use --replace)"
            del days[d]
        if not days:
            sys.exit(f"all {len(already)} days already imported; "
                     "pass --replace to redo them")

    # which words this language capitalizes, so that ones that only look
    # like names because a sentence started there are not taken for names
    for lines in days.values():
        cognates.add_case_corpus(args.lang, lines)

    print(f"{args.lang}: {len(days)} days")

    cognates.set_lexicon(args.lang)
    _first_pools, first = convert_all(days, suffix, dict(skipped))
    print(f"  matched {rate(first)} on spelling rules")

    pairs = learn_names.learn(args.lang, suffix, days)
    print(f"  learned {pairs} name pairs -> namelex/{args.lang}.txt")

    cognates.set_lexicon(None)
    cognates.set_lexicon(args.lang)
    pools, agg = convert_all(days, suffix, skipped)
    print(f"  matched {rate(agg)} using them")

    for day, pool in pools.items():
        pool.write(elogia_path(args.lang, day))
        keep = flat_path(args.lang, day)
        keep.parent.mkdir(parents=True, exist_ok=True)
        keep.write_text("\n".join(days[day]) + "\n",
                        encoding="utf-8", newline="\n")
        for tok in enable:
            vpath = elogia_path(args.lang, day, tok)
            if not vpath.exists():
                vpath.parent.mkdir(parents=True, exist_ok=True)
                vpath.write_text("", encoding="utf-8", newline="\n")

    print(f"  wrote {len(pools)} days")
    if skipped:
        print(f"  skipped {len(skipped)}:")
        for day, why in sorted(skipped.items())[:10]:
            print(f"    {day}  {why}")
        if len(skipped) > 10:
            print(f"    ... and {len(skipped) - 10} more")


if __name__ == "__main__":
    main()
