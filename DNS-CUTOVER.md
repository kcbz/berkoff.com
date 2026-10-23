# Pointing berkoff.com at GitHub Pages

**Plan: DNS stays at Network Solutions.** Only the website records change. Every email
record is left exactly as it is, so his email cannot break.

Default Pages URL (redirects after custom domain setup): https://kcbz.github.io/berkoff.com/
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
Delete the existing `www` A record before adding the CNAME. A CNAME cannot coexist
with an A record at the same name. Do not change the email CNAME records.

### 3. Leave the wildcard for now

There is a `*` (wildcard) record pointing at `208.91.197.27`, a Network Solutions
parking page. It is not required for Pages; the explicit `www` CNAME overrides it.
Review whether other subdomains rely on it before deciding whether to remove it.

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

## GitHub setup and cutover order

1. In repo Settings -> Pages -> Build and deployment, select **GitHub Actions**.
2. When ready to publish, commit and push the prepared workflow to `main`. Confirm
   the deployment succeeds in Actions before cutting over DNS.
3. Set Settings -> Pages -> Custom domain to `berkoff.com` and save.
4. Apply the website DNS changes above at Network Solutions. A 15-minute TTL for
   the new records is suitable; existing cached records can take longer to expire.
5. Wait for GitHub's DNS check and TLS certificate, then enable **Enforce HTTPS**.

The Actions workflow publishes `_site/`. Custom domains for Actions deployments
are configured in Pages settings, not through a `CNAME` file. Do not rename or
commit the obsolete local `CNAME.pending` file. No DNS changes are automated.

---

## Verifying

    dig +short berkoff.com            # expect the four 185.199.x.x addresses
    dig +short www.berkoff.com        # expect kcbz.github.io
    dig +short MX berkoff.com         # expect the four netsol mx records, UNCHANGED
    curl -I https://berkoff.com       # expect HTTP 200 from GitHub.com

Send a test email to Bruce@Berkoff.com afterwards and confirm it arrives.

---

## Rollback

GitHub Pages is the permanent host. There is no going back to the old AWS
server (`54.67.97.108`) — it is not ours, it runs end-of-life PHP 8.0, and no
DNS references it any more. Do not treat it as a fallback.

Rolling back means reverting a bad deploy, not changing DNS:

    git revert <bad-commit> && git push

Pages rebuilds in under a minute. DNS never needs to be touched again.

## Optional hardening, once live

- **Domain verification.** GitHub account Settings -> Pages -> Add a domain gives a
  `_github-pages-challenge-kcbz` TXT record. Adding it stops anyone else from ever
  claiming berkoff.com on their own GitHub Pages account if the DNS were misconfigured.
- **DMARC.** The domain has SPF but no DMARC record at all. Add:
      TXT  _dmarc  "v=DMARC1; p=none; rua=mailto:Bruce@Berkoff.com"
  `p=none` only monitors and changes nothing about delivery.

---

# STATUS — RESOLVED 2026-10-23

Cutover complete and working.

    http://berkoff.com       301 -> https://berkoff.com/
    https://berkoff.com      200
    http://www.berkoff.com   301 -> https://berkoff.com/
    https://www.berkoff.com  301 -> https://berkoff.com/

TLS certificate covers `berkoff.com` + `www.berkoff.com`. Enforce HTTPS is ON.
MX records never touched; email unaffected throughout.

## What the www certificate problem actually was

`www.berkoff.com` threw ERR_CERT_COMMON_NAME_INVALID because GitHub's certificate
covered the apex only. Two things kept it stuck:

1. **Enforce HTTPS was on while the certificate was still pending.** It 301-redirected
   Let's Encrypt's HTTP validation request for the www hostname to the apex, so the www
   authorization could never succeed. The API also refuses to disable Enforce HTTPS while
   a certificate is pending — a genuine deadlock. Re-asserting the custom domain
   (`-F cname=berkoff.com` alone) cleared the flag without downtime.
2. **Deleting the `*` wildcard at Network Solutions restarted GitHub's provisioning
   clock**, which is why waiting 24h appeared not to help.

An earlier remove/re-add of the custom domain had been tried and failed, because Enforce
HTTPS was still on at the time. With it off, remove/re-add worked immediately: the
certificate request went from covering `berkoff.com` to covering both names, and issued
within about a minute.

## Routine check

    ./scripts/check-cert.sh

## If the certificate ever gets stuck again

    gh api -X PUT repos/kcbz/berkoff.com/pages -F cname=berkoff.com   # clears a stuck enforce flag
    gh api -X PUT repos/kcbz/berkoff.com/pages -F cname=''            # then remove
    sleep 90
    gh api -X PUT repos/kcbz/berkoff.com/pages -F cname=berkoff.com   # and re-add
    # once it covers both names:
    gh api -X PUT repos/kcbz/berkoff.com/pages -F cname=berkoff.com -F https_enforced=true
