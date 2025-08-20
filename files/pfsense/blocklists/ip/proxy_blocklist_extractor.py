import re
import requests

# URL of your file
url = "https://cdn.jsdelivr.net/gh/proxifly/free-proxy-list@main/proxies/all/data.txt"

# Download the file
response = requests.get(url)
response.raise_for_status()
data = response.text

# Regex to extract IPv4 addresses
ipv4_pattern = r"\b(?:\d{1,3}\.){3}\d{1,3}\b"

# Extract IPs
ips = re.findall(ipv4_pattern, data)

# Remove duplicates while keeping order
unique_ips = list(dict.fromkeys(ips))

# Print results
for ip in unique_ips:
    print(ip)

# Optionally, save to a file
with open("proxy_ipv4.txt", "w") as f:
    f.write("\n".join(unique_ips))
