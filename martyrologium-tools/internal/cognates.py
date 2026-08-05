"""Proper-noun matching between Latin elogia and their translations.

Martyrology entries are saturated with the names of people and places, and
those names survive translation recognisably — but rarely letter for
letter.  Latin writes Æthérii where English writes Etherius, Philíppi where
Italian writes Filippo, and Joánnis where French writes Jean.  So names are
compared by folding the spellings that vary systematically (ae/e, ph/f,
th/t, j/i, doubled letters, dropped h), stripping Latin case endings, and
consulting a small table for the names no rule reaches (Guilielmus /
William).

Two entries are scored by how well their name sets agree, two-way, so a
long notice that merely shares a city cannot outrank a short entry whose
names match exactly.  This drives both the import alignment and the
crossed-key checks.
"""

import re

from martyrlib import WORD_RE, deaccent, TITLE_STOPWORDS

# Capitalised words that are not names, across the languages we convert.
_STOP = {
    # Latin entry machinery
    "natalis", "item", "eodem", "ipso", "die", "apud", "via", "sanctorum",
    "ibidem", "likewise", "also", "meme", "dememe", "aussi", "igualmente",
    "commemoratio", "festum", "vigilia", "octava", "translatio", "inventio",
    "dedicatio", "solemnitas", "passio", "depositio", "conversio", "ordinis",
    "sancti", "sanctae", "beati", "beatae", "beatorum",
    # articles / prepositions capitalized at sentence start
    "the", "le", "la", "les", "en", "a", "at", "in", "upon", "de", "del",
    "della", "di", "da", "du", "des", "au", "aux", "el", "los", "las", "un",
    "une", "il", "lo", "w", "na", "v", "u", "z", "o", "y", "e", "et",
    # saint markers
    "saint", "sainte", "saints", "st", "ste", "san", "santa", "santo",
    "sant", "sw", "sv", "sw.", "santi",
    # titles, English
    "apostle", "apostles", "bishop", "archbishop", "pope", "king", "queen",
    "virgin", "virgins", "martyr", "martyrs", "abbot", "abbess", "priest",
    "deacon", "subdeacon", "confessor", "confessors", "prophet", "widow",
    "emperor", "empress", "monk", "monks", "brothers", "company", "order",
    "blessed", "holy", "feast", "solemnity", "vigil", "octave",
    "translation", "finding", "dedication", "commemoration", "church",
    "lord", "our", "lady", "god", "christ", "jesus", "mother",
    # titles, French
    "apotre", "apotres", "eveque", "archeveque", "pape", "roi", "reine",
    "vierge", "vierges", "martyre", "abbe", "abbesse", "pretre", "diacre",
    "sous", "confesseur", "confesseurs", "prophete", "veuve", "empereur",
    "imperatrice", "moine", "moines", "freres", "ordre", "bienheureux",
    "bienheureuse", "fete", "solennite", "vigile", "invention", "dedicace",
    "memoire", "sont", "nes", "eternelle", "vie", "eglise", "seigneur",
    "notre", "dame", "dieu", "mere",
    # titles, Spanish / Italian
    "apostol", "obispo", "papa", "rey", "reina", "virgen", "martir", "abad",
    "sacerdote", "confesor", "profeta", "viuda", "vescovo", "re", "regina",
    "vergine", "martire", "abate", "prete", "confessore", "iglesia",
    "chiesa",
}
_STOP |= TITLE_STOPWORDS

# Spellings that vary systematically between Latin and its vernaculars.
_FOLD = [
    ("ae", "e"), ("oe", "e"),      # Æthérii -> eteri, Cælestíni -> celestini
    ("ph", "f"), ("th", "t"), ("ch", "c"),
    ("y", "i"), ("j", "i"), ("k", "c"), ("w", "v"), ("v", "u"),
    ("z", "s"), ("x", "cs"), ("qu", "cu"), ("gu", "g"),
]

# Latin -ti- is -ci-/-zi- in the Romance languages (Patiéntis/Paciente).
# Only used when comparing two names: in normalize() it would merge t with
# c and split the stopword stems (beáti/beáto).
_ROMANCE = [("ti", "si"), ("ci", "si")]


def _romance(s):
    for a, b in _ROMANCE:
        s = s.replace(a, b)
    return s

# Latin case endings; the stem is what carries the name.
_ENDINGS = ("orum", "arum", "ibus", "ius", "ium", "iae", "ii", "is", "es",
            "us", "um", "ae", "as", "os", "em", "am", "im", "o", "a", "e",
            "i", "s")


def normalize(name):
    s = deaccent(name).lower()
    for a, b in _FOLD:
        s = s.replace(a, b)
    s = re.sub(r"(.)\1+", r"\1", s)     # collapse doubled letters
    return s.replace("h", "")


def _stem(s):
    for e in _ENDINGS:
        if len(s) - len(e) >= 3 and s.endswith(e):
            return s[: -len(e)]
    return s


# Titles occur in every case (Epíscopi, Epíscopo, Epíscopum): one listing
# covers the declensions once compared by stem.
_STOP_STEMS = {_stem(normalize(w)) for w in _STOP}

# Names whose vernacular forms no orthographic rule reaches.  Each row is
# one name; membership is what makes two spellings cognate.
_SAME_NAME = [
    "Joannes Ioannes Johannes John Jean Juan Giovanni Jan Janos",
    "Jacobus James Jacques Giacomo Jakub Santiago Diego Jakob",
    "Guilielmus Vilhelmus William Guillaume Guglielmo Guillermo Wilhelm Vilem",
    "Ludovicus Louis Luis Luigi Ludwik Lewis Ludvik",
    "Carolus Charles Carlo Karol Carlos Karel",
    "Aegidius Giles Gilles Egidio Idzi",
    "Hieronymus Jerome Girolamo Jeronimo Hieronim",
    "Stephanus Stephen Steven Etienne Esteban Stefano Szczepan Stepan",
    "Elisabeth Elizabeth Isabel Isabella Alzbeta",
    "Ioseph Joseph Jose Giuseppe Jozef",
    "Catharina Catherine Katherine Caterina Catalina Katerina",
    "Margarita Margaret Marguerite Margherita Malgorzata",
    "Wenceslaus Wenceslas Vaclav Waclaw",
    "Adalbertus Adalbert Vojtech Wojciech",
    "Hugo Hugh Hugues Ugo",
    "Agnes Ines Agnieszka",
    "Ioanna Joan Jeanne Juana Giovanna",
    "Helena Helen Helene Elena",
    "Eduardus Edward Edouard Edoardo",
    "Ludmilla Ludmila",
]

# Indexed by stem, since the text carries declined forms (Joánnis, not
# Joannes).  A stem can belong to more than one row (Joannes and Ioanna
# both stem to "ioan"), so rows are sets and a match is any overlap.
_NAME_GROUP = {}
for _i, _row in enumerate(_SAME_NAME):
    for _n in _row.split():
        _NAME_GROUP.setdefault(_stem(normalize(_n)), set()).add(_i)


# learned name pairs for one language, from namelex/<Lang>.txt.
# module state because the tools do one language at a time.
_LEXICON = frozenset()
_LEXICON_LANG = None


def set_lexicon(lang):
    """Load namelex/<lang>.txt as the active learned lexicon (None: none)."""
    global _LEXICON, _LEXICON_LANG
    if lang == _LEXICON_LANG:
        return
    pairs, veto = set(), set()
    if lang:
        import pathlib
        import os
        root = os.environ.get(
            "MARTYR_NAMELEX",
            pathlib.Path(__file__).resolve().parent.parent / "namelex")
        path = pathlib.Path(root) / f"{lang}.txt"
        if path.exists():
            for line in path.read_text(encoding="utf-8").split("\n"):
                line = line.split("#")[0].strip()
                if not line:
                    continue
                target, line = ((veto, line[1:]) if line.startswith("-")
                                else (pairs, line))
                parts = line.split()
                if len(parts) == 2:
                    target.add((parts[0], parts[1]))
                    target.add((parts[1], parts[0]))
    _LEXICON, _LEXICON_LANG = frozenset(pairs - veto), lang


# Entries often have commentary tacked on, and every sentence in it starts
# with a capital, so words like 'Tuvo' or 'Por' would count as names. A
# real name is basically never written lowercase, so count that instead of
# keeping a word list.
_CASE = {}
# count, not ratio: a word like 'murió' starts enough sentences to look
# capitalized half the time, while a name is never written lowercase
_COMMON_LOWER = 10


def _case_table(lang):
    """token -> (upper count, lower count) in this language's martyrology.

    Vernacular only. Latin has no commentary to trip over, and plenty of
    adjectives that are also names (clarus/Clara, felix, magnus, pius), so
    measuring it would drop St Clare from her own elogium."""
    if lang not in _CASE:
        from martyrlib import all_days, do_read_lines, flat_path
        table = {}
        for day in all_days():
            path = flat_path(lang, day)
            if not path.exists():
                continue
            try:
                lines = do_read_lines(path)
            except UnicodeDecodeError:
                continue
            add_case_corpus(lang, lines, table)
        _CASE.setdefault(lang, table)
    return _CASE[lang]


def add_case_corpus(lang, lines, table=None):
    """Add text to a language's case table, for files not yet installed."""
    table = _CASE.setdefault(lang, {}) if table is None else table
    for line in lines:
        for tok in WORD_RE.findall(line):
            if len(tok) < 3:
                continue
            low = deaccent(tok).lower()
            u, l = table.get(low, (0, 0))
            table[low] = (u + 1, l) if tok[0].isupper() else (u, l + 1)
    return table


def _is_common(lang, low):
    return _case_table(lang).get(low, (0, 0))[1] >= _COMMON_LOWER


def proper_nouns(text, lang=None):
    """The entry's distinct proper nouns, de-duplicated by stem so a place
    repeated in a long notice cannot outweigh a short exact match.

    With lang, also drops words that are only capitalized because a
    sentence started there."""
    names, seen = [], set()
    for tok in WORD_RE.findall(text):
        if len(tok) < 3 or not tok[0].isupper():
            continue
        low = deaccent(tok).lower()
        key = _stem(normalize(tok))
        if low in _STOP or key in _STOP_STEMS or key in seen:
            continue
        if lang and _is_common(lang, low):
            continue
        seen.add(key)
        names.append(low)
    return names


def _cognate(a, b):
    """True when two proper nouns are the same name across languages."""
    na, nb = normalize(a), normalize(b)
    if na == nb:
        return True

    ra, rb = _romance(na), _romance(nb)
    if ra == rb or (len(_stem(ra)) >= 3 and _stem(ra) == _stem(rb)):
        return True

    sa, sb = _stem(na), _stem(nb)
    if _LEXICON and (sa, sb) in _LEXICON:
        return True

    ga = _NAME_GROUP.get(sa)
    gb = _NAME_GROUP.get(sb)
    if ga and gb and ga & gb:
        return True

    n = 0
    for x, y in zip(na, nb):
        if x != y:
            break
        n += 1
    if n >= 4:
        return True
    if n >= 3 and min(len(na), len(nb)) <= 5:
        return True

    return len(sa) >= 3 and sa == sb    # Aetherii / Etherius -> eteri


def entry_score(latin_text, vern_text):
    """(matched, total) over the Latin entry's proper nouns."""
    la = proper_nouns(latin_text)
    vb = proper_nouns(vern_text, _LEXICON_LANG)
    return sum(1 for x in la if any(_cognate(x, y) for y in vb)), len(la)


def match_quality(latin_text, vern_text):
    """How well two entries name the same people and places, 0..1.

    Two-way, so a long notice sharing only a city cannot outrank an entry
    whose names match exactly."""
    la = proper_nouns(latin_text)
    vb = proper_nouns(vern_text, _LEXICON_LANG)
    if not la or not vb:
        return 0.0
    m = sum(1 for x in la if any(_cognate(x, y) for y in vb))
    return 2.0 * m / (len(la) + len(vb))


def entry_ok(latin_text, vern_text):
    matched, total = entry_score(latin_text, vern_text)
    return total == 0 or matched >= 1


def shift_hint(refs, body, get_latin_text):
    """For a flagged day, test whether a constant offset k aligns the
    vernacular entries with the Latin ones (vern[i] ~ latin[i+k])."""
    best = None
    for k in range(-3, 4):
        matched = total = 0
        for i, vtext in enumerate(body):
            j = i + k
            if 0 <= j < len(refs):
                total += 1
                if entry_ok(get_latin_text(refs[j]), vtext):
                    matched += 1
        if total >= 3 and (best is None or matched / total > best[1] / best[2]):
            best = (k, matched, total)
    if best and best[1] / best[2] >= 0.8:
        k, m, t = best
        return f"aligns at shift {k:+d} ({m}/{t})"
    return "no constant-shift alignment"
