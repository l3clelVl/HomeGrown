import sys
import requests
from bs4 import BeautifulSoup
from datetime import datetime

def spider_website(url):
    try:
        response = requests.get(url)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            links = set()
            for link in soup.find_all('a'):
                href = link.get('href')
                if href and href.startswith('http'):
                    links.add(href)
            return links
        else:
            print(f"Error: {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")

def save_links_to_file(links, domain):
    timestamp = datetime.now().strftime("%Y%m%d%a%H%M")
    filename = f"{domain}_{timestamp}.txt"
    sorted_links = sorted(links)  # Sort the links alphabetically
    with open(filename, 'w') as file:
        for link in sorted_links:
            file.write(link + '\n')
    print(f"Links saved to {filename}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <url>")
        sys.exit(1)
    
    domain = sys.argv[1]

    protocol_list = ['http', 'https']

    # Prompt for selecting protocol
    print("Select the protocol:")
    for idx, protocol in enumerate(protocol_list, start=1):
        print(f"{idx}. {protocol}")

    protocol_choice = input("Enter the protocol number: ")
    try:
        protocol_choice = int(protocol_choice)
        if 1 <= protocol_choice <= len(protocol_list):
            protocol = protocol_list[protocol_choice - 1]
        else:
            print("Invalid protocol number. Exiting...")
            sys.exit(1)
    except ValueError:
        print("Invalid input. Exiting...")
        sys.exit(1)

    url = f"{protocol}://{domain}"
    links = spider_website(url)
    
    if links:
        save_links_to_file(links, domain)
