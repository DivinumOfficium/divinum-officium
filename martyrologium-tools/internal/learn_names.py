"""Learns the Latin<->vernacular name pairs no spelling rule can reach.

The rules in cognates.py handle names that differ predictably (Æthérii /
Etherius). They cannot handle Michaélis/Miguel or Gállia/Francia, and a
hand-written table of those is never finished.

They can be read off the corpus instead. Most of the year already aligns
on the rules alone, and in an aligned pair the leftover names on each
side are probably translations of each other. A pair that turns up on
several unrelated days is real; one that turns up once is noise.

So: align, count the leftovers, keep the pairs that are common and that
pick each other, write namelex/<Lang>.txt, align again. Three or four
rounds settle. The file is data meant to be read and corrected.

    python learn_names.py [--rounds N] [--lang X] [--report]
"""

import argparse
import collections
import os
import sys
from pathlib import Path

import cognates
from cognates import proper_nouns, _cognate, _stem, normalize
from convertlib import parse_flat_loose, align, day_latin_entries
from martyrlib import all_days, do_read_lines, flat_path

LEXDIR = Path(os.environ.get(
    "MARTYR_NAMELEX", Path(__file__).resolve().parent.parent / "namelex"))

MIN_COUNT = 2        # distinct entries the pair must co-occur in
MIN_DICE = 0.50      # 2*c(l,v) / (c(l)+c(v))
MIN_LEN = 4          # ignore very short tokens: too collision-prone


def _pairs_for(days, suffix):
    """How often each Latin name is left over beside each vernacular one."""
    pair = collections.Counter()
    lc = collections.Counter()
    vc = collections.Counter()
    rep = {}                       # stem -> most common surface form

    for day, lines in days.items():
        _h, _s, body, err = parse_flat_loose(lines)
        if err:
            continue
        entries = day_latin_entries(day, suffix)
        for j, i in align(entries, body).items():
            la = proper_nouns(entries[i][1])
            vb = proper_nouns(body[j])
            # names the rules could not pair up
            lrest = [x for x in la if not any(_cognate(x, y) for y in vb)]
            vrest = [y for y in vb if not any(_cognate(x, y) for x in la)]
            lrest = [x for x in lrest if len(x) >= MIN_LEN]
            vrest = [y for y in vrest if len(y) >= MIN_LEN]
            if not lrest or not vrest:
                continue
            for x in set(lrest):
                sx = _stem(normalize(x))
                lc[sx] += 1
                rep.setdefault(sx, x)
                for y in set(vrest):
                    sy = _stem(normalize(y))
                    pair[(sx, sy)] += 1
            for y in set(vrest):
                sy = _stem(normalize(y))
                vc[sy] += 1
                rep.setdefault(sy, y)
    return pair, lc, vc, rep


def _select(pair, lc, vc):
    """Keep the pairs that are common and that pick each other."""
    best_l, best_v = {}, {}
    for (l, v), c in pair.items():
        if l not in best_l or c > pair[(l, best_l[l])]:
            best_l[l] = v
        if v not in best_v or c > pair[(best_v[v], v)]:
            best_v[v] = l

    out = []
    for (l, v), c in pair.items():
        if c < MIN_COUNT:
            continue
        if best_l.get(l) != v or best_v.get(v) != l:
            continue                      # not mutually the best partner
        dice = 2.0 * c / (lc[l] + vc[v])
        if dice < MIN_DICE:
            continue
        out.append((l, v, c, round(dice, 3)))
    out.sort(key=lambda r: (-r[2], r[0]))
    return out


MARKER = "# ---- learned (rewritten by learn_names.py) ----"

DEFAULT_HEADER = """\
# Latin <-> {lang} name correspondences.
#
# Compared by STEM, one pair per line:  <latin-stem> <vernacular-stem>
#
# Everything ABOVE the marker is hand-maintained and preserved across
# regeneration; everything below it is rewritten from the corpus by
# learn_names.py.  Two kinds of hand entry:
#
#     stem stem      force this pair (a name the mining never saw)
#     -stem stem     veto it (mining found it, but it is wrong)
#
# Vetoes are what to reach for when a learned pair is a coincidence
# rather than a name -- month names lining up because both sides are
# dating a martyrdom, or a common word that happens to be capitalized.
"""


def read_manual(lang):
    """The hand-kept block above the marker."""
    path = LEXDIR / f"{lang}.txt"
    if not path.exists():
        return DEFAULT_HEADER.format(lang=lang)
    head = path.read_text(encoding="utf-8").split(MARKER)[0]
    return head if head.strip() else DEFAULT_HEADER.format(lang=lang)


def vetoes(lang):
    out = set()
    for line in read_manual(lang).split("\n"):
        line = line.split("#")[0].strip() if not line.strip().startswith("#") \
            else ""
        if line.startswith("-"):
            parts = line[1:].split()
            if len(parts) == 2:
                out.add(tuple(parts))
    return out


def write_lexicon(lang, rows, rep):
    LEXDIR.mkdir(exist_ok=True)
    lines = [read_manual(lang).rstrip("\n"), MARKER]
    for l, v, c, d in rows:
        lines.append(f"{l} {v}   # {c}, {d}  ({rep.get(l, l)}/{rep.get(v, v)})")
    (LEXDIR / f"{lang}.txt").write_text("\n".join(lines) + "\n",
                                        encoding="utf-8", newline="\n")


def learn(lang, suffix, days, rounds=4, report=False):
    """Write namelex/<lang>.txt from these day files, return the pair count."""
    # keep what earlier rounds found: once a pair is learned it stops being
    # a leftover, so the next round would not find it again
    acc, reps = {}, {}
    veto = vetoes(lang)
    write_lexicon(lang, [], {})          # keep the manual block, drop learned
    cognates.set_lexicon(None)
    cognates.set_lexicon(lang)

    for _rnd in range(rounds):
        pair, lc, vc, rep = _pairs_for(days, suffix)
        rows = [r for r in _select(pair, lc, vc)
                if (r[0], r[1]) not in veto and (r[1], r[0]) not in veto]
        reps.update(rep)
        new = [(l, v, c, d) for l, v, c, d in rows if (l, v) not in acc]
        for l, v, c, d in rows:
            acc.setdefault((l, v), (c, d))
        write_lexicon(lang, [(l, v, c, d) for (l, v), (c, d)
                             in sorted(acc.items(), key=lambda kv: -kv[1][0])],
                      reps)
        if report:
            for l, v, c, d in new:
                print(f"      + {reps.get(l, l):16} ~ {reps.get(v, v):16}"
                      f"  {c} entries, dice {d}")
        if not new:
            break
        # reload so the next round aligns with everything learned so far
        cognates.set_lexicon(None)
        cognates.set_lexicon(lang)
    cognates.set_lexicon(None)
    return len(acc)


def installed_days(lang):
    """The language's flat files as already installed under source/."""
    return {day: do_read_lines(flat_path(lang, day)) for day in all_days()
            if flat_path(lang, day).exists()}


def main():
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    ap = argparse.ArgumentParser()
    ap.add_argument("--lang", required=True)
    ap.add_argument("--from", dest="suffix", default="base",
                    help="Latin version to align against: base, 1955R, 1960")
    ap.add_argument("--rounds", type=int, default=4)
    ap.add_argument("--report", action="store_true")
    args = ap.parse_args()

    suffix = "" if args.suffix == "base" else args.suffix
    n = learn(args.lang, suffix, installed_days(args.lang),
              args.rounds, args.report)
    print(f"{args.lang}: {n} pairs -> namelex/{args.lang}.txt")


if __name__ == "__main__":
    main()
