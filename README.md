# berkoff.com

Personal site for Bruce I. Berkoff. Single static page, no build step.

- `index.html` — the whole site (markup + CSS + the theme toggle)
- `assets/` — photos and extracted company/university logos
- `CNAME.pending` — the custom domain, held back until DNS cuts over (see below)
- `NOTES.md` — design system, open content questions, asset provenance

## Local preview

Open `index.html` directly, or:

    python3 -m http.server 8000

## Deploy

Pushing to `main` publishes via GitHub Pages. No build, no CI.

### Custom domain cutover

The site is intentionally NOT claiming `berkoff.com` yet. A `CNAME` file makes Pages
redirect the `github.io` URL to the custom domain, which would break staging while DNS
still points at the old AWS host.

When DNS is ready (see `dns-snapshot-berkoff.com.txt`):

    mv CNAME.pending CNAME && git add -f CNAME && git commit -m "Claim berkoff.com" && git push

Then in repo Settings -> Pages, set the custom domain and enable "Enforce HTTPS" once the
certificate provisions.

`_source-assets/` holds the unused original images pulled from the old site
(~14MB of stock photography and the oversized logo JPEGs). It is gitignored —
kept locally for reference, deliberately not shipped.
