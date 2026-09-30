# Pointing berkoff.com at GitHub Pages

**Plan: DNS stays at Network Solutions.** Only the website records change. Every email
record is left exactly as it is, so his email cannot break.

Live staging: https://kcbz.github.io/berkoff.com/
Repo: https://github.com/kcbz/berkoff.com

---

## What changes in the Network Solutions DNS manager

Log in at networksolutions.com -> My Domains -> berkoff.com -> Manage -> Advanced DNS.

### 1. Replace the A record for the bare domain

| | Current | Change to |
|---|---|---|
| A `@` (or blank/`berkoff.com`) | `54.67.97.108` | **four** records: `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153` |

Delete the old `54.67.97.108` entry. GitHub needs all four for redundancy.

### 2. Add a CNAME for www

| Host | Type | Points to |
|---|---|---|
| `www` | CNAME | `kcbz.github.io` |

Note the trailing dot if the form requires one: `kcbz.github.io.`
There is no real `www` record today — it is being answered by the wildcard below,
which is why www.berkoff.com currently shows an error page.

### 3. Optional but recommended — remove the wildcard

There is a `*` (wildcard) record pointing at `208.91.197.27`, a Network Solutions
parking page. It makes every typo'd subdomain return a confusing error screen.
Deleting it is safe. An explicit `www` CNAME overrides it either way.

---

## DO NOT TOUCH

Leave every one of these exactly as they are. They are his live email.

    MX    @              mx001.netsol.xion.oxcs.net
    MX    @              mx002.netsol.xion.oxcs.net
    MX    @              mx003.netsol.xion.oxcs.net
    MX    @              mx004.netsol.xion.oxcs.net
    TXT   @              v=spf1 include:spf.cloudus.oxcs.net ~all
    CNAME mail           mail.berkoff.com.netsolmail.net
    CNAME smtp           smtp.berkoff.com.netsolmail.net
    CNAME imap           imap.berkoff.com.netsolmail.net
    CNAME pop            pop.berkoff.com.netsolmail.net
    CNAME autodiscover   autodiscover.hostingplatform.com

If the Network Solutions interface ever offers to "reset to defaults" or
"switch to our hosting", decline. That wipes custom records.

---

## Then, on this side

Once the A records resolve to GitHub (check with `dig +short berkoff.com`):

    mv CNAME.pending CNAME
    git add -f CNAME
    git commit -m "Claim berkoff.com"
    git push

Then repo Settings -> Pages -> Custom domain -> `berkoff.com` -> Save.
Wait for the TLS certificate (usually minutes, up to 24h), then tick
**Enforce HTTPS**.

---

## Verifying

    dig +short berkoff.com            # expect the four 185.199.x.x addresses
    dig +short www.berkoff.com        # expect kcbz.github.io
    dig +short MX berkoff.com         # expect the four netsol mx records, UNCHANGED
    curl -I https://berkoff.com       # expect HTTP 200 from GitHub.com

Send a test email to Bruce@Berkoff.com afterwards and confirm it arrives.

---

## Rollback

Put the single A record back to `54.67.97.108` and delete the `www` CNAME.
The old AWS server should be left running for about a week after cutover so
this is possible. Propagation is typically under an hour (the zone's TTL is
7200s / 2 hours).

## Optional hardening, once live

- **Domain verification.** GitHub account Settings -> Pages -> Add a domain gives a
  `_github-pages-challenge-kcbz` TXT record. Adding it stops anyone else from ever
  claiming berkoff.com on their own GitHub Pages account if the DNS were misconfigured.
- **DMARC.** The domain has SPF but no DMARC record at all. Add:
      TXT  _dmarc  "v=DMARC1; p=none; rua=mailto:Bruce@Berkoff.com"
  `p=none` only monitors and changes nothing about delivery.
