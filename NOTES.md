# Redesign notes — berkoff.com

`index.html` is a single self-contained static page. Open it directly in a browser.
Assets are in `assets/`, pulled from the live site.

## Design system

**Type — two families, strict roles**
- `Newsreader` (serif) — display headings only. Never body copy.
- `IBM Plex Sans` — everything else, including the small uppercase "data" labels.

The old site loaded three families (Playfair Display, Nunito Sans, Inter) with no role
separation, which is why the page changed personality three times on the way down.

**Color** — all tokens on `:root`. Dark mode is defined twice on purpose: once under
`prefers-color-scheme: dark` (guarded with `:not([data-theme="light"])`) and once under
`[data-theme="dark"]`, so the manual toggle wins in both directions. One accent (teal),
used only on labels, rules, links and hover states.

## Open items

- [ ] **Dates for CBrite, Ascent Solar and Applied Materials** — cut off in the source site,
      currently `—`. Per his LightSense bio the sequence is:
      LG.Philips LCD -> Ascent Solar -> Applied Materials -> CBrite -> InFocus.
      The list is ordered on that assumption; dates would confirm it.
- [ ] **LG Display 1999–2006** — this date is from Crunchbase / MarketScreener, NOT from
      Bruce or his own site. Confirm before publishing, or delete the date.
- [ ] **Princeton degree wording** — confirm the actual degree and field.
- [ ] **NYSE photo caption** — the bell board reads JULY 26; confirm the year (2004?) and
      Bruce's exact title at the listing before this goes live.
- [ ] **CV PDF** — hero button points at `assets/Berkoff_CV.pdf`, which doesn't exist yet.
- [ ] **LinkedIn URL** — placeholder comment in the contact section.
- [ ] **Syntax-Brillian** — the old site spells it "Syntax-Brillain"; I used the company's
      actual spelling. Confirm which he wants.
- [ ] **enuclia / Philips roles** — both have logo cards in the old site's assets but no
      role listed anywhere I could find. `assets/logos/enuclia.png` and `philips.png` are
      extracted and ready if he wants those roles added.

## Asset problems on the current site

- Each company "logo" on the old site is a **3438×2168 JPEG of a flat gray rectangle**
  with a small logo box in one corner — ~550KB each, ~6.6MB to deliver twelve small marks.
  The logos in `assets/logos/` were extracted out of those JPEGs programmatically: find the
  dominant card colour, take the bounding box of everything that isn't it, then either trim
  the white box or key the grey out to white. Total is now ~740KB instead of 6.6MB.
- Three logos (Applied Materials, LightSense, Berkeley SkyDeck) contain **white ink**, so
  keying the grey to white would erase them. They keep their original dark plate inside the
  chip. If you can source proper SVGs for those three, they'll match the rest.
- The Nanosys logo in the source is the **mark only, no wordmark** — it reads as an abstract
  shape in the credential wall. Worth replacing or dropping from the wall.
- `BruceBerkoff.jpeg` is a **407×407** original that's been run through Topaz Gigapixel
  upscaling. It's capped at 260px here because it won't hold up larger. A new headshot is
  the single highest-value asset to commission.
- The four stock photos (`board_memberships`, `contact_us`, `deep_expertise`,
  `education_development`) are 1–2.5MB each and are not used. Generic boardroom /
  handshake / pointing-at-papers imagery undercuts a real résumé.

## Deliberate changes from the old site

- Contact form removed. A static page can't process one, and for a credibility site a
  prominent mailto + tel converts better than five required fields. Easy to add back with
  Formspree or similar if he wants it.
- Career cards became a weighted timeline, split into **Current** and **Prior** groups and
  ordered most-recent-first. LG Display, Applied Materials, Nanosys and the LCD TV
  Association still carry extra visual weight, so the strongest credentials read clearly
  even though chronology puts LG Display last.
- Metrics pulled out of the bio paragraph and into the hero.
