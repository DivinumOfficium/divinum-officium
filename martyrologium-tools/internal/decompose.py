"""Builds the Latin pool files from the flat Latin martyrologies.

  Martyrologium/MM-DD.txt         [Titulus] then one section per elogium,
                                  in reading order
  Martyrologium1960/MM-DD.txt     only what 1960 changes:
      [Key]              empty  deleted
      [Key]              value  reworded, stays put
      [Key post Other]   value  placed after Other
      [Key ante Other]   empty  moved before Other, keeps its value

1570 values are derived by deaccenting the base ones, so only real 1570
rewordings get stored.
"""

import collections
import difflib
import sys
from pathlib import Path

from martyrlib import (
    HORAS, VERSIONS, KEY_NAME_RE, PoolDay, all_days, do_read_lines,
    parse_flat_day, is_structural, make_key, elogia_path,
    deaccent, merge_order, latin_day,
)

UNIFY = Path(__file__).resolve().parent.parent / "unify.txt"
_dmemo = {}


def read_decisions():
    """unify.txt: which differently-worded entries are the same elogium.

        <day> <version> <key> <same-as>   merge <key> into <same-as>
       -<day> <version> <key>             confirmed a separate elogium

    An entry that is not word-for-word the same once accents are folded
    keeps its own key unless a line here says otherwise,
    and decompose reports it until someone decides."""
    out = {}
    if UNIFY.exists():
        for line in UNIFY.read_text(encoding="utf-8").splitlines():
            line = line.split("#")[0].strip()
            if not line:
                continue
            no = line.startswith("-")
            parts = line.lstrip("-").split()
            if no and len(parts) == 3:
                out[(parts[0], _suffix(parts[1]), parts[2])] = False
            elif not no and len(parts) == 4:
                out[(parts[0], _suffix(parts[1]), parts[2])] = parts[3]
    return out


def _suffix(name):
    return "" if name == "base" else name


def _d(text):
    if text not in _dmemo:
        _dmemo[text] = deaccent(text)
    return _dmemo[text]


def escape(line):
    return "=" + line if (line.strip() == "" or line.startswith(("[", "="))) else line


def main():
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    reports = Path(__file__).resolve().parent.parent / "reports"
    reports.mkdir(exist_ok=True)

    # load flats
    versions, anomalies = {}, []
    for suffix, dirname in VERSIONS:
        per = {}
        for day in all_days():
            heading, tail, anom = parse_flat_day(
                do_read_lines(HORAS / "Latin" / dirname / "source" / f"{day}.txt"))
            anomalies += [f"{dirname}/{day}.txt: {a}" for a in anom]
            per[day] = (heading, tail)
        versions[suffix] = per

    # key assignment pass
    home = {}                                   # exact text -> (day, key)
    daykeys = collections.defaultdict(dict)     # day -> key -> base text
    values = collections.defaultdict(dict)      # (day, key) -> suffix -> text
    deacc = collections.defaultdict(dict)       # day -> deaccented text -> key
    badkeys, exact, review = [], [], []
    decisions = read_decisions()

    def remember(day, key, text):
        deacc[day].setdefault(_d(text), key)

    def take(day, key, suffix, text):
        """Record text as this version's wording of key, if the slot is free."""
        slot = values[(day, key)]
        if suffix in slot and slot[suffix] != text:
            return False
        slot[suffix] = text
        remember(day, key, text)
        return True

    def prospective_key(day, text):
        """The key this text would get, without creating it. Deterministic,
        so unify.txt can name it."""
        key = make_key(text)
        if not KEY_NAME_RE.match(key):
            key = "Elogium"
        base, n = key, 1
        while key in daykeys[day]:
            n += 1
            key = f"{base}-{n}"
        return key

    def new_key(day, text, suffix):
        key = prospective_key(day, text)
        if not KEY_NAME_RE.match(make_key(text)):
            badkeys.append((day, key, text[:60]))
        daykeys[day][key] = text if suffix == "" else None
        if suffix == "":
            home[text] = (day, key)
        else:
            values[(day, key)][suffix] = text
        remember(day, key, text)
        return key

    def assign(day, text, suffix):
        if text in home:
            hd, hk = home[text]
            ref = hk if hd == day else f"{hd}:{hk}"
            # a reference resolves to the other day's value, and for 1570
            # that is its base text deaccented. where this day wants a
            # different spelling, 29 February is left accented while
            # 23 February is not, the reference cannot deliver it, so
            # keep the wording here
            if suffix == "1570" and _d(daykeys[hd][hk]) != text:
                return new_key(day, text, suffix)
            return ref

        if suffix:
            key = deacc[day].get(_d(text))
            if key is not None:
                base_text = daykeys[day].get(key)
                if (suffix == "1570" and base_text is not None
                        and _d(base_text) == text):
                    exact.append((day, key, suffix))
                    return key
                if take(day, key, suffix, text):
                    exact.append((day, key, suffix))
                    return key

            want = prospective_key(day, text)
            verdict = decisions.get((day, suffix, want))

            if verdict and take(day, verdict, suffix, text):
                return verdict
            if verdict is None:
                review.append((day, suffix, want, text))
        return new_key(day, text, suffix)

    seqs = {} # (suffix, day) -> (has_sep, [key, ...])
    for suffix, _dirname in VERSIONS: # base first: it owns the keys
        for day in all_days():
            _heading, tail = versions[suffix][day]
            has_sep, keys, nlit = False, [], 0
            for i, line in enumerate(tail):
                if is_structural(line):
                    if i == 0 and line.strip() == "_":
                        has_sep = True
                        continue
                    nlit += 1
                    lk = f"Linea-{nlit}"
                    if lk not in daykeys[day]:
                        daykeys[day][lk] = escape(line) if suffix == "" else None
                    if suffix:
                        values[(day, lk)].setdefault(suffix, escape(line))
                    keys.append(lk)
                    continue
                keys.append(assign(day, line, suffix))
            seqs[(suffix, day)] = (has_sep, keys)

    # emit base files
    for day in all_days():
        pool = PoolDay(day)
        pool.set("Titulus", versions[""][day][0])
        has_sep, keys = seqs[("", day)]
        if not has_sep:
            pool.set("Separatio", "")
        for key in keys:
            # a MM-DD:Key section is a reference: its value always resolves
            # from that day's file, so it is stored empty
            pool.set(key, "" if ":" in key else daykeys[day][key])
        pool.write(elogia_path("Latin", day))

    # emit version files
    stats = collections.Counter()
    for suffix, _dirname in VERSIONS[1:]:
        outdir = elogia_path("Latin", "01-01", suffix).parent
        if outdir.exists():
            for old in outdir.glob("[0-9][0-9]-[0-9][0-9].txt"):
                old.unlink()

        for day in all_days():
            base_sep, base_keys = seqs[("", day)]
            v_sep, v_keys = seqs[(suffix, day)]
            entries = [] # (raw section name, value)

            heading = versions[suffix][day][0]
            rendered_heading = (deaccent(versions[""][day][0])
                                if suffix == "1570" else versions[""][day][0])
            if heading != rendered_heading:
                entries.append(("Titulus", heading))
                stats[f"{suffix}-titulus"] += 1
            if v_sep != base_sep:
                entries.append(("Separatio", "_" if v_sep else ""))
                stats[f"{suffix}-separatio"] += 1

            # deletions and value overrides (position-neutral)
            for key in base_keys:
                if key not in v_keys:
                    entries.append((key, ""))
                    stats[f"{suffix}-deleted"] += 1
            for key in v_keys:
                if key in base_keys and suffix in values.get((day, key), {}):
                    entries.append((key, values[(day, key)][suffix]))
                    stats[f"{suffix}-override"] += 1

            # placements: whatever the base order cannot produce on its own
            # (additions, and the rare genuine reorderings) is anchored.
            # Out-of-place keys are found as the complement of the longest
            # common subsequence, so each round fixes real outliers only.
            for _round in range(8):
                merged = merge_order(
                    base_keys,
                    [(*_parse(name), val) for name, val in entries])
                if merged == v_keys:
                    break
                keep = set()
                for a, b, size in difflib.SequenceMatcher(
                        None, merged, v_keys, autojunk=False
                ).get_matching_blocks():
                    keep.update(v_keys[b:b + size])
                outliers = [k for k in v_keys if k not in keep]
                if not outliers:
                    break
                outset = set(outliers)
                for key in outliers:
                    i = v_keys.index(key)
                    # anchor to a key that is NOT itself being re-anchored,
                    # otherwise the two anchors can reference each other
                    prev = next((k for k in reversed(v_keys[:i])
                                 if k not in outset), None)
                    nxt = next((k for k in v_keys[i + 1:]
                                if k not in outset), None)
                    if prev is not None:
                        name = f"{key} post {prev}"
                    elif nxt is not None:
                        name = f"{key} ante {nxt}"
                    elif i > 0:
                        name = f"{key} post {v_keys[i - 1]}"
                    elif len(v_keys) > 1:
                        name = f"{key} ante {v_keys[1]}"
                    else:
                        name = key
                    val = values.get((day, key), {}).get(suffix, "")
                    entries = [(n, v) for n, v in entries
                               if _parse(n)[0] != key]
                    entries.append((name, val))
                    stats[f"{suffix}-placed"] += 1

            if not entries:
                continue
            pool = PoolDay(day)
            for name, val in entries:
                pool.set(name, val)
            pool.write(elogia_path("Latin", day, suffix))

    # report
    n_base = sum(len([k for k, t in v.items() if t is not None])
                 for v in daykeys.values())
    lines = [
        f"base pool files             : 366",
        f"base elogia                 : {n_base}",
        f"same wording, accents aside : {len(exact)}",
        f"unified by unify.txt        : {sum(1 for v in decisions.values() if v)}",
        f"awaiting a decision         : {len(review)}",
        f"anomalies                   : {len(anomalies)}",
        f"unrepresentable keys        : {len(badkeys)}",
        "",
        "version deltas:",
    ] + [f"  {k:22} {v}" for k, v in sorted(stats.items())]
    summary = "\n".join(lines)
    print(summary)
    (reports / "decompose-report.txt").write_text(
        summary + "\n\n== anomalies ==\n" + "\n".join(anomalies or ["(none)"])
        + "\n\n== unrepresentable keys ==\n"
        + "\n".join(f"{d} {k!r} {t}" for d, k, t in badkeys) + "\n",
        encoding="utf-8")
    print("detail: reports/decompose-report.txt")

    if review:
        out = ["# Entries a version words differently from anything already",
               "# keyed for that day. Each is its own key until decided.",
               "# Copy the line into unify.txt, filling in the entry it",
               "# belongs to, or prefix '-' if it really is separate:",
               "#",
               "#     <day> <version> <key> <same-as>",
               "#    -<day> <version> <key>",
               ""]
        for day, suffix, key, text in sorted(review):
            out += [f"# {day} {suffix or 'base'} [{key}]",
                    f"#   {text}",
                    f"#   the day already has:"]
            for k in seqs[("", day)][1]:
                other = daykeys[day].get(k)
                if other and k != key:
                    out += [f"#     {k}", f"#       {other}"]
            out += [f"-{day} {suffix or 'base'} {key}", ""]
        (reports / "unify-pending.txt").write_text(
            "\n".join(out), encoding="utf-8", newline="\n")
        print(f"{len(review)} to decide: reports/unify-pending.txt")
    print()
    return check()


def check():
    """Rebuild every Latin day from the pool alone and compare with source/."""
    total = ok = 0
    bad = []
    for suffix, dirname in VERSIONS:
        v_ok = 0
        for day in all_days():
            total += 1
            want = do_read_lines(HORAS / "Latin" / dirname / "source" / f"{day}.txt")
            titulus, sep, entries = latin_day(day, suffix)
            if titulus is None:
                bad.append(f"{dirname}/{day}: no [Titulus]")
                continue
            got = titulus.split("\n")
            if sep is not None:
                got.append(sep)
            for key, value in entries:
                if value is None:
                    bad.append(f"{dirname}/{day}: no value for [{key}]")
                    break
                got += [l[1:] if l.startswith("=") else l
                        for l in value.split("\n")]
            else:
                if got == want:
                    ok += 1
                    v_ok += 1
                else:
                    bad.append(f"{dirname}/{day}: differs")
        print(f"  {dirname:20} {v_ok}/366 rebuild identically")
    print(f"  TOTAL {ok}/{total}")
    for line in bad[:10]:
        print("    " + line)
    return 1 if bad else 0


def _parse(raw):
    from martyrlib import parse_section_name
    return parse_section_name(raw)


if __name__ == "__main__":
    sys.exit(main())
