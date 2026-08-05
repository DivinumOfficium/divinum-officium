"""Imports a made-up language and checks it renders correctly.

Proves the things that are easy to break and hard to notice: a day renders
exactly as the translator wrote it, a version overlay reorders it the way
that version does, and the fallback option fills gaps without moving anything.

Run:  python internal/selftest.py
"""

import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

TOOLS = Path(__file__).resolve().parent.parent
REPO = TOOLS.parent
REPO_HORAS = REPO / "web" / "www" / "horas"
SCRATCH = Path(os.environ.get("TMP", "/tmp")) / "martyr-e2e"
DATA = SCRATCH / "horas"

PASS = []
FAIL = []


def check(name, cond, detail=""):
    (PASS if cond else FAIL).append(name)
    print(("  ok   " if cond else "  FAIL ") + name
          + (f"  {detail}" if detail and not cond else ""))


def read_lines(path):
    text = Path(path).read_text(encoding="utf-8")
    lines = text.split("\n")
    while lines and lines[-1] == "":
        lines.pop()
    return lines


def stage():
    if SCRATCH.exists():
        shutil.rmtree(SCRATCH)
    (DATA / "Latin").mkdir(parents=True)
    for folder in ("Martyrologium", "Martyrologium1955R", "Martyrologium1960",
                   "Martyrologium1570"):
        src_dir = REPO_HORAS / "Latin" / folder
        if src_dir.is_dir():
            shutil.copytree(src_dir, DATA / "Latin" / folder)

    src = SCRATCH / "src"
    src.mkdir()
    rot = SCRATCH / "rot"
    rot.mkdir()

    # clean French day used verbatim
    day_clean = read_lines(REPO_HORAS / "Francais" / "Martyrologium" / "source" / "01-20.txt")
    (src / "01-20.txt").write_text("\n".join(day_clean) + "\n",
                                   encoding="utf-8", newline="\n")

    # crafted faithful base-order May 1 with a language-only extra
    fr = read_lines(REPO_HORAS / "Francais" / "Martyrologium" / "source" / "05-01.txt")
    heading, b = fr[0], fr[2:]
    asaph = b[7].partition(", et la sainte Vierge")[0] + "."
    walburga = ("En Angleterre, la sainte Vierge Walburge, dont la fête est "
                "célébrée le 14 mai.")
    pius = ("De même à Rome, saint Pie V, pape et confesseur, de l'Ordre "
            "des Prêcheurs.")
    crafted = [b[0], pius, b[1], b[2], b[3], b[4], b[5], b[6],
               asaph, walburga, b[9], b[8]]
    (src / "05-01.txt").write_text(
        "\n".join([heading, "_"] + crafted) + "\n",
        encoding="utf-8", newline="\n")

    # a genuinely rotated day, imported as-is (order preservation proof)
    rot_day = read_lines(REPO_HORAS / "Francais" / "Martyrologium" / "source" / "01-08.txt")
    (rot / "01-08.txt").write_text("\n".join(rot_day) + "\n",
                                   encoding="utf-8", newline="\n")
    # the same crafted May 1, imported WITHOUT any version file, to test the
    # option on a language that never opted in
    (rot / "05-01.txt").write_text(
        "\n".join([heading, "_"] + crafted) + "\n",
        encoding="utf-8", newline="\n")
    return heading, crafted, walburga, pius, rot_day


def run_import(args):
    env = dict(os.environ, DO_MARTYR_DATA=str(DATA),
               MARTYR_NAMELEX=str(SCRATCH / "namelex"),
               PYTHONIOENCODING="utf-8")
    p = subprocess.run(
        [sys.executable, str(TOOLS / "import_translation.py")] + args,
        capture_output=True, text=True, encoding="utf-8", env=env, cwd=TOOLS)
    return p.returncode, (p.stdout or "") + (p.stderr or "")


def render(lang, day, version, martyrfallback=0, spell_var=False,
           lang1="Latin"):
    # spell_var: install a marker version of the Latin per-version spelling
    # pass, to prove the Latin-fill path routes through it (webdia.pl only
    # applies it when the COLUMN language is Latin, so the fill must do it)
    sv = ('*main::spell_var = sub { my $t = shift; $t =~ s/^/\\x{2020}/; $t };'
          if spell_var else '')
    script = f'''
use utf8; use lib "web/cgi-bin";
use DivinumOfficium::FileIO qw(do_read);
binmode STDOUT, ":encoding(utf-8)";
our ($datafolder,$version,$langfb)=("{DATA.as_posix()}","{version}","English");
our ($martyrfallback, $lang1) = ({martyrfallback}, "{lang1}");
do "./web/cgi-bin/DivinumOfficium/SetupString.pl" or die $@;
do "./web/cgi-bin/horas/specials/specprima.pl" or die $@;
*main::checklatinfile = sub {{}} unless defined &main::checklatinfile;
{sv}
print join("\\x{{1}}", martyrologium_elogia("{lang}","{day}"));
'''
    p = subprocess.run(["perl", "-e", script], capture_output=True, cwd=REPO)
    out = p.stdout.decode("utf-8")
    if p.returncode != 0:
        raise RuntimeError(p.stderr.decode("utf-8", "replace"))
    return out.split("\x01") if out else []


def section_key(pool_path, needle):
    text = Path(pool_path).read_text(encoding="utf-8")
    m = re.search(r"\[([^\]]+)\]\n[^\n]*" + re.escape(needle), text)
    return m.group(1) if m else None


def main():
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    heading, crafted, walburga, pius, rot_day = stage()

    print("import: clean run with 1960 opt-in")
    rc, out = run_import(["--lang", "Testlang", "--from", "divino",
                          "--src", str(SCRATCH / "src"),
                          "--enable-versions", "1960"])
    check("import exits 0", rc == 0, out)
    check("2 days imported", "wrote 2 days" in out, out)

    print("render: base rubrics = translator's file, byte-identical")
    lines = render("Testlang", "05-01", "Divino Afflatu")
    check("base render identical", lines == [heading, "_"] + crafted,
          f"{len(lines)} lines")

    print("render: 1960 arrangement")
    lines = render("Testlang", "05-01", "Rubrics 1960")
    joined = "\n".join(lines)
    check("Joseph the Worker skipped (no translation, no Latin fill)",
          "Joseph" not in joined and "Opific" not in joined)
    check("Philip & James omitted (Latin-governed, moved in 1960)",
          "Philippe" not in joined)
    check("first entry is Pius V (1960 order)",
          len(lines) > 2 and lines[2] == pius, lines[2][:60] if len(lines) > 2 else "")
    check("extra kept, anchored after its neighbour (Asaph)",
          walburga in lines
          and lines.index(walburga) - 1 >= 0
          and "Asaph" in lines[lines.index(walburga) - 1])

    print("overlay: override + delete for 1960 only")
    pool_file = DATA / "Testlang" / "Martyrologium" / "05-01.txt"
    wal_key = section_key(pool_file, "Walburge")
    latin_file = DATA / "Latin" / "Martyrologium" / "05-01.txt"
    jer_key = section_key(latin_file, "Jerem")
    check("keys discoverable in emitted files", bool(wal_key and jer_key),
          f"wal={wal_key} jer={jer_key}")
    replacement = "En Égypte, remplacement de l'entrée de Jérémie pour 1960."
    overlay = DATA / "Testlang" / "Martyrologium1960" / "05-01.txt"
    overlay.write_text(
        f"[{jer_key}]\n{replacement}\n\n[{wal_key}]\n\n",
        encoding="utf-8", newline="\n")

    lines = render("Testlang", "05-01", "Rubrics 1960")
    joined = "\n".join(lines)
    check("override value shown under 1960", replacement in joined)
    check("deleted extra gone under 1960", walburga not in joined)
    base_again = render("Testlang", "05-01", "Divino Afflatu")
    check("base render untouched by overlay",
          base_again == [heading, "_"] + crafted)

    print("option: untranslated Martyrologium entries in Latin")
    lines = render("Testlang", "05-01", "Rubrics 1960", martyrfallback=1)
    joined = "\n".join(lines)
    check("untranslated Latin-only entry now shown in Latin",
          "Solémnitas sancti Joseph Opíficis" in joined)
    check("still omits what 1960 deletes (Philip & James)",
          "Philippe" not in joined and "Philíppi" not in joined)
    check("language's own translations still win over Latin",
          pius in joined and "Romæ natális sancti Pii Quinti" not in joined)
    check("version override still wins (tier 1 over tier 3)",
          replacement in joined)
    check("explicitly deleted key is NOT refilled from Latin",
          walburga not in joined)
    check("base rubrics unaffected by the option",
          render("Testlang", "05-01", "Divino Afflatu", martyrfallback=1)
          == [heading, "_"] + crafted)

    print("no overlay: every version renders the translator's file order")
    rc, out = run_import(["--lang", "Testrot", "--from", "base",
                          "--src", str(SCRATCH / "rot")])
    check("rotated day imports (alignment reported, not gated)", rc == 0, out)
    flat = rot_day
    for vname in ("Divino Afflatu", "Reduced 1955", "Rubrics 1960"):
        lines = render("Testrot", "01-08", vname)
        check(f"01-08 file-order identical under {vname}", lines == flat,
              f"{len(lines)} vs {len(flat)}")

    print("option without any version file: still follows the Latin version")
    check("no version file exists for this language",
          not (DATA / "Testrot" / "Martyrologium1960" / "05-01.txt").exists())
    off = render("Testrot", "05-01", "Rubrics 1960")
    check("option off: unchanged file order", off == [heading, "_"] + crafted)
    on = render("Testrot", "05-01", "Rubrics 1960", martyrfallback=1)
    joined = "\n".join(on)
    check("option on: Latin-only 1960 entry now appears",
          "Solémnitas sancti Joseph Opíficis" in joined)
    check("option on: 1960 arrangement applied (Philip & James dropped)",
          "Philippe" not in joined)
    check("option on: the language's own translations kept",
          pius in joined and walburga in joined)

    print("order is the language's own, with or without the option")
    for lang, day in (("Testrot", "05-01"), ("Testlang", "05-01")):
        a = render(lang, day, "Rubrics 1960")
        b = render(lang, day, "Rubrics 1960", martyrfallback=1)
        kept_a = [l for l in a if l in set(b)]
        kept_b = [l for l in b if l in set(a)]
        check(f"{lang}: option only inserts, never reorders",
              kept_a == kept_b and a != b,
              f"{len(a)} -> {len(b)} lines")
    print("fallback follows the LEFT COLUMN, not Latin unconditionally")
    # Testlang carries a French translation of Joseph the Worker that
    # Testrot lacks; with Testlang in the left column, Testrot must inherit
    # the French wording rather than the Latin.
    joseph_fr = "En Égypte, saint Joseph l'Artisan, époux de la Vierge Marie."
    jkey = section_key(DATA / "Latin" / "Martyrologium1960" / "05-01.txt",
                       "Joseph")
    (DATA / "Testlang" / "Martyrologium1960" / "05-01.txt").write_text(
        f"[{jer_key}]\n{replacement}\n\n[{wal_key}]\n\n[{jkey}]\n{joseph_fr}\n",
        encoding="utf-8", newline="\n")
    check("Latin key for Joseph the Worker found", bool(jkey), f"jkey={jkey}")

    lat = render("Testrot", "05-01", "Rubrics 1960", martyrfallback=1)
    left = render("Testrot", "05-01", "Rubrics 1960", martyrfallback=1,
                  lang1="Testlang")
    check("left column Latin: inherits the Latin wording",
          "Solémnitas sancti Joseph Opíficis" in "\n".join(lat))
    check("left column Testlang: inherits ITS wording instead",
          joseph_fr in left and "Solémnitas sancti Joseph Opíficis"
          not in "\n".join(left))
    # Latin is a source only when Latin is the column beside you.  With
    # Testlang on the left, an entry Testlang also lacks stays absent
    # rather than turning up in a language the reader did not ask for.
    check("left column Testlang: no Latin leaks into either column",
          not any("Solémnitas" in l or "Jeremíæ" in l for l in left))
    check("a column never inherits from itself",
          render("Testlang", "05-01", "Rubrics 1960", martyrfallback=1,
                 lang1="Testlang")
          == render("Testlang", "05-01", "Rubrics 1960", martyrfallback=0))
    check("switching the left column does not reorder",
          [l for l in lat if l in set(left)] == [l for l in left if l in set(lat)])

    print("filled Latin goes through the version's Latin spelling pass")
    sv = render("Testrot", "05-01", "Rubrics 1960", martyrfallback=1, spell_var=True)
    filled = [l for l in sv if "Joseph" in l or "Ioseph" in l]
    check("filled Latin passed through spell_var",
          bool(filled) and all(l.startswith("†") for l in filled),
          repr(filled[:1]))
    check("the language's own text did NOT",
          any(l == pius for l in sv) and not any(l.startswith("†")
                                                 and pius in l for l in sv))

    print("the Latin column inherits too, when it is not the left one")
    # Walburga is Testlang's own: the Latin has never had her. With
    # Testlang on the left, the Latin column has to show her, which means
    # filling a key that is in neither the Latin's day nor its version.
    # Base rubrics, since the 1960 overlay above deletes her.
    lat_alone = render("Latin", "05-01", "Divino Afflatu", martyrfallback=1)
    lat_inh = render("Latin", "05-01", "Divino Afflatu", martyrfallback=1,
                     lang1="Testlang")
    check("Latin on the left: renders itself, inherits nothing",
          walburga not in lat_alone
          and lat_alone == render("Latin", "05-01", "Divino Afflatu"))
    check("Latin on the right: shows the left column's own entry",
          walburga in lat_inh)
    check("and keeps its own order while doing it",
          [l for l in lat_alone if l in set(lat_inh)]
          == [l for l in lat_inh if l in set(lat_alone)])

    base_order = render("Testrot", "05-01", "Divino Afflatu")
    on_1960 = render("Testrot", "05-01", "Rubrics 1960", martyrfallback=1)
    shared = [l for l in base_order if l in set(on_1960)]
    check("Testrot: shared entries keep the translator's sequence",
          shared == [l for l in on_1960 if l in set(base_order)])

    print()
    print(f"{len(PASS)} passed, {len(FAIL)} failed  (scratch: {SCRATCH})")
    sys.exit(1 if FAIL else 0)


if __name__ == "__main__":
    main()
