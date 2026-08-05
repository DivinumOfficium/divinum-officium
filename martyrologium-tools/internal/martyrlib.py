"""Shared library for the martyrology elogia-pool toolchain.

One file per day per language, the whole day in reading order:

    web/www/horas/<Lang>/Martyrologium/MM-DD.txt          the day
    web/www/horas/<Lang>/Martyrologium1960/MM-DD.txt      1960's changes
    web/www/horas/<Lang>/Martyrologium/source/MM-DD.txt   the old flat file

    [Titulus]     the date line, may be several lines
    [Separatio]   only when the separator is not a plain '_'
    [<Key>]       one per elogium, in the order they are read

[MM-DD:Key] refers to an entry kept in another day's file. Key names must
fit setupstring's grammar; the ones generated here use only [A-Za-z0-9 -].
"""

import os
import re
import unicodedata
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent
# DO_MARTYR_DATA points the tools at another data root, used by the tests
HORAS = (Path(os.environ["DO_MARTYR_DATA"])
         if "DO_MARTYR_DATA" in os.environ
         else REPO / "web" / "www" / "horas")

# suffix -> folder name. Order matters: base first, since it owns the keys,
# and 1570 last, since its values are derived from the base ones.
VERSIONS = [
    ("", "Martyrologium"),
    ("1955R", "Martyrologium1955R"),
    ("1960", "Martyrologium1960"),
    ("1570", "Martyrologium1570"),
]

DAY_RE = re.compile(r"^(\d\d)-(\d\d)$")
SECTION_RE = re.compile(r"^\s*\[([^\]]+)\]")
# subset of setupstring's section-name grammar (SetupString.pl:324)
KEY_NAME_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9 -]*$")
CROSSDAY_RE = re.compile(r"^(\d\d-\d\d):(.+)$")


def all_days():
    for m, dmax in ((1, 31), (2, 29), (3, 31), (4, 30), (5, 31), (6, 30),
                    (7, 31), (8, 31), (9, 30), (10, 31), (11, 30), (12, 31)):
        for d in range(1, dmax + 1):
            yield f"{m:02d}-{d:02d}"


def do_read_lines(path):
    """Read a data file exactly the way DO's do_read() sees it: UTF-8, BOM
    stripped, split on \\r?\\n, trailing empty lines dropped (Perl split
    semantics)."""
    raw = Path(path).read_bytes()
    text = raw.decode("utf-8")
    if text.startswith("﻿"):
        text = text[1:]
    lines = re.split(r"\r?\n", text)
    while lines and lines[-1] == "":
        lines.pop()
    return lines


def parse_flat_day(lines):
    """Split a flat day file into (heading, tail, anomalies).

    `tail` is every line after the heading, verbatim, including the '_'
    separator and any blank lines. Callers escape those with '='."""
    anomalies = []
    if not lines:
        return None, [], ["empty file"]
    heading = lines[0]
    tail = lines[1:]
    if not tail or tail[0].strip() != "_":
        anomalies.append("no '_' separator on line 2")
    for i, e in enumerate(tail):
        if e.startswith("["):
            anomalies.append(f"line {i + 2} starts with '['")
        if e.startswith("@"):
            anomalies.append(f"line {i + 2} starts with '@'")
        if e.startswith("="):
            anomalies.append(f"line {i + 2} starts with '='")
    return heading, tail, anomalies


def is_structural(line):
    """Lines that are structure, not elogium text: blank or bare '_'."""
    s = line.strip()
    return s == "" or s == "_"


def parse_vernacular_day(lines):
    """Strictly parse a flat vernacular day file into (heading, body, error).

    heading is the newline-joined block before the '_' separator (may be
    several lines: morrow announcements); body is one elogium per line.
    error is None only when the file can be reproduced byte-identically from
    a pool, which is the seeding/import safety requirement."""
    if not lines:
        return None, None, "empty file"
    sep = next((i for i, l in enumerate(lines[:6]) if l.strip() == "_"), None)
    if sep is None or sep == 0:
        return None, None, "no '_' separator"
    if lines[sep] != "_":
        return None, None, (f"separator is {lines[sep]!r}, not '_' "
                            "(whitespace cleanup needed in flat file)")
    heading_lines = lines[:sep]
    body = lines[sep + 1:]
    if not body:
        return None, None, "no entries after separator"
    if any(is_structural(l) for l in heading_lines + body):
        return None, None, "structural line inside heading/body"
    if any(l.startswith(("[", "@", "=")) for l in heading_lines + body):
        return None, None, "line collides with section grammar"
    return "\n".join(heading_lines), body, None


def deaccent(s):
    # decompose FIRST: an accented ligature is one codepoint (ǽ is U+01FD),
    # so expanding ligatures first misses it and leaves a bare æ behind
    s = unicodedata.normalize("NFKD", s)
    s = "".join(c for c in s if not unicodedata.combining(c))
    return (s.replace("æ", "ae").replace("Æ", "Ae")
             .replace("œ", "oe").replace("Œ", "Oe"))


WORD_RE = re.compile(r"[^\W\d_]+", re.UNICODE)

HONORIFIC_RE = re.compile(
    r"\b(?:san?ct[ioaæe]\w*|beat[ioaæe]\w*|sanctórum|beatórum)\s",
    re.IGNORECASE,
)

# Common titles/descriptors that follow an honorific but are not names.
TITLE_STOPWORDS = {
    "martyrum", "martyris", "martyrium", "virginis", "virginum", "viduae",
    "confessoris", "confessorum", "episcopi", "episcoporum", "papae",
    "presbyteri", "diaconi", "subdiaconi", "abbatis", "abbatissae",
    "monachi", "monachorum", "militis", "militum", "regis", "reginae",
    "prophetae", "apostoli", "apostolorum", "evangelistae", "sacerdotis",
    "sacerdotum", "pontificis", "doctoris", "imperatoris", "imperatricis",
    "levitae", "senis", "pueri", "puerorum", "fratrum", "sororis",
    "matris", "patris", "anachoretae", "eremitae", "sanctimonialis",
    "dei", "domini", "nostri", "jesu", "christi", "mariae",
}

LINKWORDS = {"et", "ac", "atque", "cum", "de", "in", "item"}


def _cap_names_after(tokens, start, limit=2, window=8):
    names = []
    for tok in tokens[start:start + window]:
        low = deaccent(tok).lower()
        if tok[0].isupper():
            if low in TITLE_STOPWORDS:
                continue
            names.append(tok)
            if len(names) >= limit:
                break
        elif low in LINKWORDS:
            continue
        else:
            break
    return names


def make_key(text):
    """Derive a human-recognisable ASCII key from a Latin elogium."""
    tokens = WORD_RE.findall(text)
    m = HONORIFIC_RE.search(text)
    names = []
    if m:
        # index of first token at/after the honorific match end
        prefix_tokens = WORD_RE.findall(text[: m.end()])
        names = _cap_names_after(tokens, len(prefix_tokens))
    if not names:
        # fall back to the first capitalized tokens (typically the place name)
        caps = [t for t in tokens[:10] if t[0].isupper()
                and deaccent(t).lower() not in TITLE_STOPWORDS]
        names = caps[:2]
    if not names:
        names = ["Elogium"]
    slug = "-".join(re.sub(r"[^A-Za-z0-9]", "", deaccent(n)) for n in names)
    slug = re.sub(r"-+", "-", slug).strip("-")
    return slug or "Elogium"


def token_multiset(text):
    return sorted(deaccent(t).lower() for t in WORD_RE.findall(text))


def variant_suffix(new_text, old_text):
    """If new_text differs from old_text only by the word 'item', name the
    variant '<key> item'; otherwise '<key> alt'."""
    a, b = token_multiset(new_text), token_multiset(old_text)
    diff = []
    i = j = 0
    while i < len(a) or j < len(b):
        if i < len(a) and j < len(b) and a[i] == b[j]:
            i += 1
            j += 1
        elif j >= len(b) or (i < len(a) and a[i] < b[j]):
            diff.append(a[i])
            i += 1
        else:
            diff.append(b[j])
            j += 1
    if set(diff) == {"item"}:
        return "item"
    return "alt"


def similarity(a, b):
    # autojunk drops common characters in long strings, which makes the
    # ratio depend on which argument comes first
    import difflib
    return difflib.SequenceMatcher(None, a, b, autojunk=False).ratio()


class PoolDay:
    """One day's pool file (master or translation)."""

    def __init__(self, day):
        self.day = day
        self.sections = {}      # name -> text (single- or multi-line, no trailing NL)
        self.order = []         # section names in file order

    def set(self, name, text):
        if name not in self.sections:
            self.order.append(name)
        self.sections[name] = text

    def get(self, name, default=None):
        return self.sections.get(name, default)

    def render(self):
        out = []
        for name in self.order:
            out.append(f"[{name}]")
            out.append(self.sections[name])
            out.append("")
        return "\n".join(out).rstrip("\n") + "\n"

    def write(self, path):
        path = Path(path)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(self.render(), encoding="utf-8", newline="\n")

    @classmethod
    def read_text(cls, text, day=None):
        lines = re.split(r"\r?\n", text)
        while lines and lines[-1] == "":
            lines.pop()
        return cls._from_lines(lines, day)

    @classmethod
    def read(cls, path, day=None):
        return cls._from_lines(do_read_lines(path), day or Path(path).stem)

    @classmethod
    def _from_lines(cls, lines, day=None):
        pool = cls(day)
        name = None
        buf = []

        def flush():
            if name is not None:
                b = buf[:]
                while b and b[-1].strip() == "":
                    b.pop()
                pool.set(name, "\n".join(b))

        for line in lines:
            m = SECTION_RE.match(line) if line.startswith("[") else None
            if m:
                flush()
                name = m.group(1)
                buf = []
            elif name is not None:
                buf.append(line)
        flush()
        return pool


ANCHOR_RE = re.compile(r"^(\S+)\s+(ante|post)\s+(\S+)$")
STRUCTURAL_SECTIONS = ("Titulus", "Separatio")


def parse_section_name(raw):
    """'Key' -> (key, None); 'Key post Other' -> (key, ('post', 'Other'))."""
    m = ANCHOR_RE.match(raw.strip())
    if m:
        return m.group(1), (m.group(2), m.group(3))
    return raw.strip(), None


def pool_entries(pool):
    """Ordered [(key, anchor, value)] for a pool file, structural sections
    (Titulus/Separatio) excluded."""
    out = []
    for raw in pool.order:
        key, anchor = parse_section_name(raw)
        if key in STRUCTURAL_SECTIONS:
            continue
        out.append((key, anchor, pool.sections[raw]))
    return out


def merge_order(base_keys, overlay_entries):
    """Apply a version overlay to a base key order.

    In the overlay: a key with an empty value and no anchor is DELETED; a
    key with an anchor is placed there (added if new, moved if it was in
    base) and keeps the base value when its own is empty; any other key is
    a value override that keeps its base position.  Returns the merged key
    order."""
    deleted, anchored, moved = set(), [], set()
    for key, anchor, value in overlay_entries:
        if anchor is not None:
            anchored.append((key, anchor))
            moved.add(key)
        elif value == "":
            deleted.add(key)

    keys = [k for k in base_keys if k not in deleted and k not in moved]

    # place anchored keys as their targets become available, so an anchor
    # may reference another anchored key regardless of file order
    pending = list(anchored)
    while pending:
        rest = []
        for key, (rel, target) in pending:
            if target in keys:
                i = keys.index(target)
                keys.insert(i if rel == "ante" else i + 1, key)
            else:
                rest.append((key, (rel, target)))
        if len(rest) == len(pending):
            keys += [k for k, _a in rest]
            break
        pending = rest

    inbase, have = set(base_keys), set(keys)
    for key, anchor, value in overlay_entries:
        if anchor is None and value != "" and key not in inbase and key not in have:
            keys.append(key)
            have.add(key)
    return keys


def elogia_path(lang, day, suffix=""):
    """Path of a pool day file — these live in the Martyrologium folders
    themselves; suffix '1955R'/'1960'/'1570' addresses the language's
    version-delta folder."""
    return HORAS / lang / f"Martyrologium{suffix}" / f"{day}.txt"


def flat_path(lang, day, suffix=""):
    """Path of an original flat day file, kept under <folder>/source/."""
    return HORAS / lang / f"Martyrologium{suffix}" / "source" / f"{day}.txt"


def latin_day(day, suffix=""):
    """Effective (titulus, separator_or_None, [(key, value)]) for a Latin
    version-day, resolving the base file through the version overlay."""
    base = PoolDay.read(elogia_path("Latin", day))
    bkeys = [k for k, _a, _v in pool_entries(base)]
    bvals = {k: v for k, _a, v in pool_entries(base)}

    over = None
    opath = elogia_path("Latin", day, suffix)
    if suffix and opath.exists():
        over = PoolDay.read(opath)
    oents = pool_entries(over) if over else []
    ovals = {k: v for k, _a, v in oents if v != ""}

    keys = merge_order(bkeys, oents)

    titulus = None
    if over is not None:
        titulus = next((over.sections[r] for r in over.order
                        if parse_section_name(r)[0] == "Titulus"), None)
    if titulus is None:
        titulus = base.get("Titulus")
        if titulus is not None and suffix == "1570":
            titulus = deaccent(titulus)

    sep = base.get("Separatio", "_")
    if over is not None:
        for r in over.order:
            if parse_section_name(r)[0] == "Separatio":
                sep = over.sections[r] or None

    out = []
    for key in keys:
        if CROSSDAY_RE.match(key): # elogium homed on another day
            d2, k2 = key.split(":", 1)
            other = PoolDay.read(elogia_path("Latin", d2))
            v = other.get(k2)
            opath2 = elogia_path("Latin", d2, suffix)
            if suffix and opath2.exists():
                o2 = {k: val for k, _a, val in pool_entries(PoolDay.read(opath2))
                      if val != ""}
                if k2 in o2:
                    out.append((key, o2[k2]))
                    continue
            if v is not None and suffix == "1570":
                v = deaccent(v)
            out.append((key, v))
            continue
        if key in ovals:
            out.append((key, ovals[key]))
            continue
        v = bvals.get(key)
        if v is not None and suffix == "1570":
            v = deaccent(v)
        out.append((key, v))
    return titulus, sep, out


def ordo_refs(pool, ordo_name):
    """Split an Ordo section into a list of refs.

    Each ref is a tuple:
      ("lit", text)  -- literal structural line ('=_' -> '_', '=' -> '')
      (day, key)     -- elogium from another day's pool file
      (None, key)    -- elogium from this day's pool file
    """
    text = pool.get(ordo_name)
    if text is None:
        return None
    refs = []
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        if line.startswith("="):
            refs.append(("lit", line[1:]))
            continue
        m = CROSSDAY_RE.match(line)
        if m:
            refs.append((m.group(1), m.group(2)))
        else:
            refs.append((None, line))
    return refs
