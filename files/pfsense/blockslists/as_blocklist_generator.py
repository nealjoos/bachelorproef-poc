import requests
import sys

if len(sys.argv) != 2:
    print("Usage: python get_prefixes.py <ASN>")
    sys.exit(1)

asn = sys.argv[1]  # e.g., AS32934

# Ensure it starts with "AS"
if not asn.upper().startswith("AS"):
    asn = "AS" + asn

url = f"https://stat.ripe.net/data/announced-prefixes/data.json?resource={asn}"

print(f"Fetching prefixes for {asn}...")

response = requests.get(url)
data = response.json()

ipv4_prefixes = []
ipv6_prefixes = []

for prefix in data["data"]["prefixes"]:
    pfx = prefix["prefix"]
    if ":" in pfx:
        ipv6_prefixes.append(pfx)
    else:
        ipv4_prefixes.append(pfx)

# Output file names include the ASN
with open(f"{asn}_ipv4.txt", "w") as f:
    f.write("\n".join(ipv4_prefixes))

with open(f"{asn}_ipv6.txt", "w") as f:
    f.write("\n".join(ipv6_prefixes))

print(f"Saved {len(ipv4_prefixes)} IPv4 prefixes to {asn}_ipv4.txt")
print(f"Saved {len(ipv6_prefixes)} IPv6 prefixes to {asn}_ipv6.txt")
