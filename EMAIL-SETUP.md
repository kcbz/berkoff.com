# Email forwarding + contact form for berkoff.com

> **This repo is public.** Do not commit the real forwarding destination here.
> It lives in the ImprovMX dashboard. Below it is written as `<DESTINATION>`.

Two separate systems that meet at one address:

    anyone@berkoff.com  --(ImprovMX forwarding)-->  <DESTINATION>
    website form        --(Web3Forms)-->  Bruce@Berkoff.com  --> same forward

Pointing the form at `Bruce@Berkoff.com` rather than at the destination directly means
the real address lives in exactly ONE place (the ImprovMX dashboard). If Bruce ever
changes it, update it there and nothing else needs touching — not the website, not
Web3Forms, not this repo.

Current state: inbound mail is handled by Network Solutions / Open-Xchange.
Confirmed with Bruce: **receive-and-forward only, no stored mail**, so there is no
mailbox to migrate.

---

## Order of operations

Do these in order. Do not change DNS until step 1 is done.

### 1. Create the ImprovMX account

Sign up free at improvmx.com, add domain `berkoff.com`.

Set up forwarding:

| Alias | Forwards to |
|---|---|
| `bruce@berkoff.com` | `<DESTINATION>` |
| `*@berkoff.com` (catch-all) | `<DESTINATION>` |

The catch-all covers "any other address ending in berkoff.com", which is what Bruce
described wanting. The free tier is 1 domain / 25 aliases; the catch-all counts as one.
Check their current daily limit on the pricing page — published figures have varied,
though volume for this site will be trivial either way.

### 2. Change DNS at Network Solutions

Only two record types change. **Nothing else in the zone is touched.**

DELETE these four:

    MX  10  mx001.netsol.xion.oxcs.net
    MX  10  mx002.netsol.xion.oxcs.net
    MX  10  mx003.netsol.xion.oxcs.net
    MX  10  mx004.netsol.xion.oxcs.net

ADD these two:

    MX  10  mx1.improvmx.com
    MX  20  mx2.improvmx.com

REPLACE the SPF TXT record:

    old:  v=spf1 include:spf.cloudus.oxcs.net ~all
    new:  v=spf1 include:spf.improvmx.com ~all

ADD a DMARC record (the domain has none today):

    TXT  _dmarc   v=DMARC1; p=none; rua=mailto:<DESTINATION>

`p=none` is monitor-only and changes nothing about delivery.

LEAVE ALONE — these are website records, not email:

    A      @      185.199.108.153 / .109.153 / .110.153 / .111.153
    CNAME  www    kcbz.github.io

The old `mail` / `smtp` / `imap` / `pop` / `autodiscover` CNAMEs can be deleted once
forwarding is confirmed working. They only pointed at Network Solutions' mail service.

### 3. Verify before trusting it

Wait for propagation (zone TTL is 7200s / 2h), then:

    dig +short MX berkoff.com        # expect mx1 and mx2 improvmx
    dig +short TXT berkoff.com       # expect the improvmx SPF

Send a test to `bruce@berkoff.com` AND to something random like
`testing123@berkoff.com`, from an outside account. Both should arrive.

**Check the Junk folder.** Outlook/Hotmail is the strictest major provider about
forwarded mail — first messages frequently land there. Mark as "not junk" to train it.
If forwarding there proves unreliable, a Gmail destination handles forwards better.

### 4. Wire up the contact form

Only after forwarding works.

1. Go to web3forms.com, enter `Bruce@Berkoff.com` as the destination. They email an
   access key. No account needed.
2. Paste it into `index.html`, replacing `YOUR_WEB3FORMS_ACCESS_KEY`.
3. In the Web3Forms dashboard, turn on:
   - **Domain restriction** -> `berkoff.com` (stops others POSTing with your key)
   - **hCaptcha** spam protection
4. Commit and push. Send a test through the live form.

The form already carries a honeypot field that catches most naive bots on its own.

Note: the access key is itself low-sensitivity (it only routes to an address it already
knows), which is why it is fine in the public page. The destination address is the part
that stays private.

---

## Security notes

- The real destination appears NOWHERE in the published site, and must not appear in
  this repo either. Web3Forms binds the destination to the access key on their server;
  the page only carries the key.
- The access key IS public — unavoidable for any form on a static host. It allows
  someone to send messages to the destination; it does not allow reading anything or
  discovering the destination. Domain restriction + hCaptcha are the mitigations.
- `Bruce@Berkoff.com` is a visible mailto on the page and always has been. It is a
  public business contact; that exposure is intentional.

## Rollback

Restore the four Network Solutions MX records and the original SPF line, both recorded
verbatim in `dns-snapshot-berkoff.com.txt`. Inbound mail returns to Open-Xchange.
Website records are untouched by any of this, so the site cannot break.
