############################################################################
#
# Usage = python scrape_links.py <url> <max_depth>
#
############################################################################

import sys
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse

def scrape_links(base_url, max_depth, current_depth=0):
    if current_depth > max_depth:
        return
    
    try:
        response = requests.get(base_url)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching the page: {e}")
        return
    
    soup = BeautifulSoup(response.text, 'html.parser')
    
    for link in soup.find_all('a'):
        href = link.get('href')
        if href:
            full_url = urljoin(base_url, href)
            if full_url not in urls:
                urls.add(full_url)
                # Recurse into the found URL
                scrape_links(full_url, max_depth, current_depth + 1)

if len(sys.argv) < 3:
    print("Usage: python scrape_links.py <url> <max_depth>")
    sys.exit(1)

base_url = sys.argv[1]
max_depth = int(sys.argv[2])

# Add "http://" to the URL if it's not present
if not base_url.startswith("http://") and not base_url.startswith("https://"):
    base_url = "http://" + base_url

urls = set()

# Start the recursive scraping
scrape_links(base_url, max_depth)

# Create a filename based on the 2nd argument
parsed_url = urlparse(base_url)
filename = f"{parsed_url.netloc}_URLs_Fragments.txt"

# Sort the URLs alphabetically and write them to the file
if urls:
    with open(filename, 'w') as file:
        sorted_urls = sorted(list(urls))
        for url in sorted_urls:
            file.write(url + '\n')
    print(f"URLs have been saved to {filename}")
else:
    print("No URLs found.")
