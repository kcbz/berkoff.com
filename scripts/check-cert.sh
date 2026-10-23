#!/usr/bin/env bash
# Checks whether GitHub has issued a certificate covering www.berkoff.com yet.
# Run: ./scripts/check-cert.sh
set -uo pipefail

echo "DNS"
printf "  apex          %s\n" "$(dig +short A berkoff.com | tr '\n' ' ')"
printf "  www           %s\n" "$(dig +short www.berkoff.com | head -1)"
printf "  MX (email)    %s\n" "$(dig +short MX berkoff.com | wc -l | tr -d ' ') records — must stay 4"

echo
echo "Certificate"
state=$(gh api repos/kcbz/berkoff.com/pages -q '.https_certificate.state' 2>/dev/null)
doms=$(gh api repos/kcbz/berkoff.com/pages -q '.https_certificate.domains|join(", ")' 2>/dev/null)
enf=$(gh api repos/kcbz/berkoff.com/pages -q '.https_enforced' 2>/dev/null)
printf "  state         %s\n" "${state:-unknown}"
printf "  covers        %s\n" "${doms:-unknown}"
printf "  enforce https %s\n" "${enf:-unknown}"

echo
echo "Live"
printf "  https://berkoff.com       %s\n" "$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 https://berkoff.com)"
printf "  https://www.berkoff.com   %s\n" "$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 https://www.berkoff.com 2>/dev/null || echo 'CERT ERROR')"

echo
if [[ "$doms" == *"www.berkoff.com"* && "$enf" == "true" ]]; then
  echo "ALL GOOD — certificate covers apex + www, and Enforce HTTPS is on."
elif [[ "$doms" == *"www.berkoff.com"* ]]; then
  echo "Certificate covers www, but Enforce HTTPS is OFF. Turn it back on:"
  echo "  gh api -X PUT repos/kcbz/berkoff.com/pages -F cname=berkoff.com -F https_enforced=true"
else
  echo "Not yet. www is still missing from the certificate."
  echo "If this is still true 24h after the wildcard was deleted, force it:"
  echo "  gh api -X PUT repos/kcbz/berkoff.com/pages -F cname=''      # removes domain"
  echo "  sleep 90"
  echo "  gh api -X PUT repos/kcbz/berkoff.com/pages -F cname=berkoff.com"
  echo "  (berkoff.com 404s for a few minutes during this)"
fi
