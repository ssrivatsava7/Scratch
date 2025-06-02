import pandas as pd
import requests
from bs4 import BeautifulSoup

# Read the CSV file (replace with your actual file path)
file_path = 'TheVera - Sheet1.csv'
df = pd.read_csv(file_path, encoding='utf-8')

# Function to check if content can be extracted from a given URL
def extract_article_content(url):
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()  # raise error for 4XX/5XX

        soup = BeautifulSoup(response.text, 'html.parser')

        # Try to find article tag first
        article_tag = soup.find('article')
        if article_tag and article_tag.get_text(strip=True):
            return True

        # Fallback to main tag
        main_tag = soup.find('main')
        if main_tag and main_tag.get_text(strip=True):
            return True

        # If neither has content, return False
        return False

    except Exception:
        # If request fails or other issues, mark as False
        return False

# Extract non-null URLs from the column containing links
urls = df['article link'].dropna().tolist()

# Initialize dictionary to store extraction results
url_extraction_status = {}

# Iterate over each URL and store the extraction status
for url in urls:
    status = extract_article_content(url)
    url_extraction_status[url] = status
    print(f"Processed: {url} -> {'Content Found' if status else 'No Content / Failed'}")

# Save the results to a CSV file for easy access
result_df = pd.DataFrame(list(url_extraction_status.items()), columns=['URL', 'Content Extracted'])
result_df.to_csv('extraction_results.csv', index=False)
print("Extraction results saved to 'extraction_results.csv'.")
