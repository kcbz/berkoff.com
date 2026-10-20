# berkoff.com

Personal site for Bruce I. Berkoff. Plain HTML, CSS and JavaScript; no framework,
package manager, dependencies or compilation step.

- `index.html` — the whole site, including CSS and the theme toggle
- `assets/` — photos and company/university logos
- `.github/workflows/deploy.yml` — GitHub Pages build and deployment
- `NOTES.md` — design notes and outstanding content questions

## Local production build and preview

From the repository root, assemble the same static output used by Actions:

```sh
mkdir -p _site
cp index.html _site/
cp -R assets _site/assets
python3 -m http.server 8000 --directory _site
```

Start with an empty `_site/` directory when rebuilding to avoid stale assets.
Open http://localhost:8000/. Output is `_site/` (gitignored). Only `index.html`
and `assets/` are published; repository notes, DNS snapshots and unused source
images are excluded. No environment variables or secrets enter the output.

## Deploy

Repository: https://github.com/kcbz/berkoff.com. Default branch: `main`.
The workflow builds and deploys on pushes to `main`, and supports **Actions →
Deploy website to GitHub Pages → Run workflow** on `main`.

Before pushing the workflow, open **Settings → Pages → Build and deployment**
and select **GitHub Actions** as the source. After pushing, check the Actions run.

For the custom domain, set **Settings → Pages → Custom domain** to `berkoff.com`
and save. Configure the Network Solutions records described in `DNS-CUTOVER.md`,
then enable **Enforce HTTPS** when available. The `www` CNAME target is
`kcbz.github.io`, without a protocol or repository name.

The production site is served at `https://berkoff.com/`. Existing relative asset
URLs and in-page anchor navigation work at the domain root without a framework
base-path setting or a routing fallback. GitHub redirects `www.berkoff.com` to
the apex domain when both DNS records are configured.

Actions deployments require the custom domain to be configured in Pages settings;
a `CNAME` file is not required and does not configure it. The local, ignored
`CNAME.pending` file is obsolete and need not be renamed or committed.

Known pre-existing content issue: the Download CV button references
`assets/Berkoff_CV.pdf`, which has not been supplied. Add that file to fix the link.
See `NOTES.md` for other editorial follow-ups.

`_source-assets/` contains unused original images kept locally for reference and
is gitignored.
