"""Turns a flat day file into a pool file.

One section per line of the original, in the original order. A line that
names the same saints as a Latin elogium takes that Latin key; the rest
get a key made from their own text, never one the Latin already uses.
Values are the lines verbatim, with '=' in front of anything that would
otherwise look like section grammar.

Reading the sections back in order reproduces the flat file exactly, and
convert_day() checks that for every day it writes.
"""

from martyrlib import (
    PoolDay, do_read_lines, make_key, elogia_path, KEY_NAME_RE, latin_day,
    pool_entries, VERSIONS,
)
from cognates import entry_score, match_quality


def parse_flat_loose(lines):
    """Split a flat day into (heading_lines, separator_line, body, error).

    Loose: the separator is the first line in the file whose stripped form
    is '_' (searched in the first 6 lines); its exact spelling is kept.
    Files without a separator (headingless French days, English days whose
    body follows the heading directly) are stored entirely as body, the
    renderer emits a separator only when a heading exists."""
    if not lines:
        return None, None, None, "empty file"
    sep = next((i for i, l in enumerate(lines[:6]) if l.strip() == "_"), None)
    if sep is None or sep == 0:
        return [], None, lines, None
    heading = lines[:sep]
    if any(h.strip() == "" or h.startswith(("[", "=")) for h in heading):
        # heading lines the format cannot carry verbatim: store as body
        return [], None, lines, None
    return heading, lines[sep], lines[sep + 1:], None


def escape_value(line):
    # whitespace-only lines must be escaped or the section reader's
    # trailing-blank trim would swallow them
    if line.strip() == "" or line.startswith(("[", "=")):
        return "=" + line
    return line


def unescape_value(value):
    return value[1:] if value.startswith("=") else value


def day_latin_entries(day, suffix):
    """(key, text) for a Latin day, plus entries only other versions have."""
    _titulus, _sep, entries = latin_day(day, suffix)
    out = [(k, v) for k, v in entries if v is not None]
    have = {k for k, _v in out}

    for other, _dirname in VERSIONS:
        if other == suffix:
            continue
        pos = 0
        for k, v in latin_day(day, other)[2]:
            if v is None:
                continue
            if k in have:
                idx = next((i for i, (kk, _x) in enumerate(out) if kk == k), None)
                if idx is not None:
                    pos = idx + 1
            elif ":" not in k:
                # ':' is a reference to another day's entry, not an elogium
                # of this one; a translated line gets its own key instead
                out.insert(pos, (k, v))
                have.add(k)
                pos += 1
    return out


def reserved_keys(day):
    """Every Latin key of the day in any version; vernacular-own keys must
    not collide with these."""
    names = {"Titulus", "Separatio"}
    for suffix, _dirname in VERSIONS:
        path = elogia_path("Latin", day, suffix)
        if path.exists():
            names.update(k for k, _a, _v in pool_entries(PoolDay.read(path)))
    return names


def align(latin_entries, body):
    """Greedy unique content alignment: returns {body_index: latin_index}.

    Pairs are ranked by two-way name agreement (so a long notice sharing a
    city cannot outrank a short entry whose names match exactly), then by
    positional distance; a pair is accepted only when both sides are still
    free and at least one proper noun matched."""
    candidates = []
    for j, vline in enumerate(body):
        if not vline.strip():
            continue
        for i, (_key, ltext) in enumerate(latin_entries):
            m, _t = entry_score(ltext, vline)
            if m >= 1:
                candidates.append(
                    (-round(match_quality(ltext, vline), 3), abs(i - j), i, j))
    candidates.sort()
    used_i, used_j, assign = set(), set(), {}
    for _negm, _d, i, j in candidates:
        if i in used_i or j in used_j:
            continue
        used_i.add(i)
        used_j.add(j)
        assign[j] = i
    return assign


def convert_day(day, lines, suffix=""):
    """Convert flat-file lines into a PoolDay.  Returns (pool, stats, error).

    suffix selects which Latin version's arrangement to align against;
    None disables alignment entirely (texts that are not elogium-per-line
    translations, e.g. commentary; every line keeps a language-own key).
    stats: dict with aligned, extras, structural, nonstandard_separator."""
    heading_lines, sep_line, body, err = parse_flat_loose(lines)
    if err:
        return None, None, err

    latin_entries = day_latin_entries(day, suffix) if suffix is not None else []
    assign = align(latin_entries, body)
    reserved = reserved_keys(day)

    pool = PoolDay(day)
    if heading_lines:
        pool.set("Titulus", "\n".join(heading_lines))
        if sep_line != "_":
            pool.set("Separatio", sep_line)

    used = set(reserved)
    stats = {"aligned": 0, "extras": 0, "structural": 0,
             "nonstandard_separator": int(sep_line != "_")}

    for j, vline in enumerate(body):
        if j in assign:
            key = latin_entries[assign[j]][0]
            stats["aligned"] += 1
        else:
            if vline.strip() in ("", "_"):
                key = "Linea"
                stats["structural"] += 1
            else:
                key = make_key(vline)
                stats["extras"] += 1
            if not KEY_NAME_RE.match(key):
                key = "Elogium"
            base_key, n = key, 1
            while key in used or key in pool.sections:
                n += 1
                key = f"{base_key}-{n}"
        used.add(key)
        pool.set(key, escape_value(vline))

    # byte-identity self-check THROUGH THE WRITTEN FORMAT: reparse the
    # rendered file text so representation gaps (e.g. whitespace-only
    # lines clipped by the section reader) cannot hide
    reparsed = PoolDay.read_text(pool.render(), day)
    rebuilt = []
    if "Titulus" in reparsed.sections:
        rebuilt += reparsed.sections["Titulus"].split("\n")
        rebuilt.append(reparsed.sections.get("Separatio", "_"))
    for name in reparsed.order:
        if name in ("Titulus", "Separatio"):
            continue
        rebuilt.append(unescape_value(reparsed.sections[name]))
    if rebuilt != lines:
        return None, None, "reconstruction mismatch"
    return pool, stats, None
