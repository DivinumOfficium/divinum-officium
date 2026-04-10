import os
import pathlib
import re


CITATION_REGEX = r"^\s*(?:!)\s?(?P<citation>(?P<book>(?:\d\s)?\w+)\s?(?P<chapter>\d+)(?::|,\s)(?P<verses>\d+-?\d*,?\d*))\s*$"


def fix_encoding(path: pathlib.Path):
    try:
        with path.open() as f:
            content = f.read()
    except UnicodeDecodeError:
        with path.open(encoding="windows-1252") as f:
            content = f.read()
        with path.open("w", encoding="utf-8") as f:
            f.write(content)


def fix_bible_references(path: pathlib.Path):
    if not path.suffix == ".txt":
        return
    with path.open() as f:
        content = f.read()
    fixed_whitespace = re.sub(
        CITATION_REGEX, r"!\g<book> \g<chapter>:\g<verses>", content, flags=re.MULTILINE
    )
    fixed = fixed_whitespace
    if fixed == content:
        return
    with path.open("w") as f:
        f.write(fixed)


def main():
    a = []
    for root, dirs, files in os.walk(pathlib.Path(".")):
        if ".git" in root:
            continue
        for f in files:
            p = pathlib.Path(root, f)
            if p.suffix in (
                ".gif",
                ".ico",
                ".jpg",
                ".pdf",
                ".png",
                ".ttf",
            ):
                continue
            fix_encoding(p)
            fix_bible_references(p)


if __name__ == "__main__":
    main()
