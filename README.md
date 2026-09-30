# berkoff.com

Personal site for Bruce I. Berkoff. Single static page, no build step.

- `index.html` — the whole site (markup + CSS + the theme toggle)
- `assets/` — photos and extracted company/university logos
- `CNAME` — custom domain for GitHub Pages
- `NOTES.md` — design system, open content questions, asset provenance

## Local preview

Open `index.html` directly, or:

    python3 -m http.server 8000

## Deploy

Pushing to `main` publishes via GitHub Pages. No build, no CI.

`_source-assets/` holds the unused original images pulled from the old site
(~14MB of stock photography and the oversized logo JPEGs). It is gitignored —
kept locally for reference, deliberately not shipped.
