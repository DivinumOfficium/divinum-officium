# Latin Lexicon

Word-by-word interlinear gloss data, used when the Interlinear setting is enabled.

## Files

`latin_lexicon.json`: the base lexicon, mapping lowercase Latin word forms to short English glosses. Covers inflected forms as they appear in the liturgical texts. Do not edit by hand.

`lexicon_overrides.json`: manual corrections that take precedence over the base lexicon. Edit this file when a translation is wrong or missing. Set a key to `""` to hide the gloss.

## Correcting a translation

Add or update the word in `lexicon_overrides.json` using the lowercase inflected form as it appears in the text:

```json
{
  "laudent": "let them praise",
  "cornu": "horn",
  "sǽculum": "world/age"
}
```

Use `/` to separate multiple meanings (`"health/salvation"`). Include accented forms if the text uses them (`sǽculum` alongside `saeculum`).

Note: some glosses may be incorrect or missing, particularly for less common inflected forms.

## Compiled lexicon

The server uses `latin_lexicon.storable` (a Storable binary, not in git) rather than parsing the JSON at runtime. Rebuild it from the repo root after any change to either JSON file:

```bash
perl lexicon-tools/build_lexicon_storable.pl
```

When using Docker, the storable is baked into the image at build time — changes to the JSON files require a full rebuild:

```bash
docker compose build && docker compose up -d
```
