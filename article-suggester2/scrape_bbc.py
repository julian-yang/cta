from bs4 import BeautifulSoup
import requests
import os
import time
import datetime
import article_utils
import dateparser
import lib.article_pb2 as article_pb2
from zipfile import ZipFile
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

only_scrape_1 = True

# returns a article_pyb2.Article
def scrape_bbc_article(url):
    session = requests.Session()
    retry = Retry(connect=10, backoff_factor=0.5)
    adapter = HTTPAdapter(max_retries=retry)
    session.mount('http://', adapter)
    session.mount('https://', adapter)

    response = session.get(url)
    # response = requests.get(url)
    if not response.status_code == 200:
        return None
    soup = BeautifulSoup(response.content, 'html.parser')
    article = article_pb2.Article()
    article.url = url
    article.chinese_title = soup.find('h1', class_='story-body__h1').text.replace(':', '：')
    raw_author = soup.find('span', class_='byline__title')
    if raw_author is not None:
        article.author = raw_author.text

    raw_date = soup.find('div', class_='date')
    if raw_date is not None:
        article.publish_date.FromDatetime(dateparser.parse(raw_date.text))

    # pprint.pprint(article, width=1)
    raw_article_body = soup.find('div', class_='story-body__inner')
    if raw_article_body is None:
        return None
    article_body = []
    for child in raw_article_body.contents:
        if child.val == 'p' or child.val == 'h2':
            article_body.append(child.text)
            # print(child.text)
    # pprint.pprint(article_body, width=1)
    article.chinese_body = "\n".join(article_body)
    article.tags.extend(['news', 'bbc'])
    article_utils.print_article(article)
    return article


# returns a list of dict
def scrapeBBC(db):
    bbc_urlbase = 'https://www.bbc.com'
    traditional_prefix = '/zhongwen/trad'
    response = requests.get(f'{bbc_urlbase}{traditional_prefix}')
    if not response.status_code == 200:
        return None
    soup = BeautifulSoup(response.content, 'html.parser')
    article_urls = []
    # for article in soup.find_all('a', class_='title-link')[::5]:
    for article in soup.find_all('a', class_='jeUMCT'):
        article_url = article['href']
        if article_url.startswith(traditional_prefix):
            article_urls.append(f'{bbc_urlbase}{article_url}')

    articles = []
    # uncomment to just scrape the first article
    if only_scrape_1:
        article_urls = article_urls[0:1]
    for link in article_urls:
        print(link)
        article = scrape_bbc_article(link)
        if article is not None:
            articles.append(article)
    return articles
