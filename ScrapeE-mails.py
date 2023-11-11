import requests
from bs4 import BeautifulSoup
import re
import argparse

def scrape_emails(url):
    # Fetch the webpage
    response = requests.get(url)
    
    # Check for successful request
    if response.status_code != 200:
        print(f"Failed to get content from {url}")
        return []

    # Parse HTML content
    soup = BeautifulSoup(response.text, 'html.parser')
    
    # Find emails using regex
    email_pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
    emails = re.findall(email_pattern, soup.get_text())
    
    return emails

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Scrape emails from a given website.')
    parser.add_argument('url', help='The URL of the website to scrape')
    
    args = parser.parse_args()
    
    found_emails = scrape_emails(args.url)
    
    if found_emails:
        print("Found the following email addresses:")
        for email in found_emails:
            print(email)
    else:
        print("No email addresses found.")
