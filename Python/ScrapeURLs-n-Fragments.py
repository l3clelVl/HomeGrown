############################################################################
#
# Usage = python scrape_links.py <url> <max_depth>
#
# This scrapes urls/fragments as well as e-mails and urls in text form
#
############################################################################
import sys
import re
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

    # Regular expression to match URLs in text
    url_pattern = re.compile(r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+')
    # Regular expression to match email addresses
    email_pattern = re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')

    # Find URLs in text content
    text = soup.get_text()
    for url in re.findall(url_pattern, text):
        urls.add(url)
    # Find email addresses in text content
    for email in re.findall(email_pattern, text):
        emails.add(email)
    
    # Find URLs in href attributes
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
emails = set()

# Start the recursive scraping
scrape_links(base_url, max_depth)

# Create filenames based on the 2nd argument
parsed_url = urlparse(base_url)
urls_filename = f"{parsed_url.netloc}_URLs_Fragments.txt"
emails_filename = f"{parsed_url.netloc}_Emails.txt"

# Sort the URLs alphabetically and write them to the file
if urls:
    with open(urls_filename, 'w') as file:
        sorted_urls = sorted(list(urls))
        for url in sorted_urls:
            file.write(url + '\n')
    print(f"URLs have been saved to {urls_filename}")

# Sort the emails alphabetically and write them to the file
if emails:
    with open(emails_filename, 'w') as file:
        sorted_emails = sorted(list(emails))
        for email in sorted_emails:
            file.write(email + '\n')
    print(f"Email addresses have been saved to {emails_filename}")

