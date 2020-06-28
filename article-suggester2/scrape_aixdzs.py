from bs4 import BeautifulSoup
from bs4.element import Tag
from bs4.element import NavigableString
import requests
import pprint
import utils
import os
import time
import datetime
import re
import opencc
import article_utils
import dateparser
import lib.article_pb2 as article_pb2
import my_firebase as firebase
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

only_scrape_1 = False


def get_http_session():
    session = requests.Session()
    retry = Retry(connect=10, backoff_factor=0.5)
    adapter = HTTPAdapter(max_retries=retry)
    session.mount('http://', adapter)
    session.mount('https://', adapter)
    return session


def maybe_print(text):
    debug_print = True
    if debug_print:
        print(f'* {text}\n')


def scrape_chapter(book_title, url, converter, chapter_num):
    response = get_http_session().get(url)
    # response = requests.get(url)
    if not response.status_code == 200:
        return None
    soup = BeautifulSoup(response.content, 'html.parser')
    article = article_pb2.Article()
    article.url = url
    article.chinese_title = soup.find('h1', attrs={'itemprop': 'name'}).text.replace(':', '：').rstrip()
    paragraphs = [p_tag.text for p_tag in soup.select('div.content > p')]
    article.chinese_body = '\n'.join(paragraphs)
    article.chapter_num = chapter_num
    article.tags.extend(['aixdzs', 'book', book_title])
    article_utils.print_article(article)
    return article


def scrape_book_page(base_page_url, converter):
    response = requests.get(base_page_url)
    if not response.status_code == 200:
        return None
    soup = BeautifulSoup(response.content, 'html.parser')
    article_urls = []
    # for article in soup.find_all('a', class_='title-link')[::5]:
    book_title = soup.find('h1', attrs={'itemprop': 'name'}).text
    for article in soup.select('li.chapter > a'):
        article_url = article['href']
        article_urls.append(f'{base_page_url}{article_url}')
        # if article_url.startswith(traditional_prefix):
        # article_urls.append(f'{liberty_urlbase}{article_url}')
    return book_title, article_urls

# returns a list of dict
def scrapeAixdzs(db):
    book_url = input(f'Enter url to scrape: ')
    utils.get_yes_no(f'Confirm url (y/n): {book_url}\n')

    converter = opencc.OpenCC('s2twp.json')
    (book_title, chapter_urls) = scrape_book_page(book_url, converter)

    # (docs, existing_articles, scraped_articles_collection) = firebase.get_existing_articles(db)
    # existing_urls = set([article.url for article in existing_articles])
    # article_urls.difference_update(existing_urls)

    # print(f'Found {len(article_urls)} new articles, scraping...')
    articles = []
    # uncomment to just scrape the first article
    if only_scrape_1:
        article_urls = chapter_urls[0:1]

    failed_urls = []
    count = 1
    for link in chapter_urls:
        print(f'({count}/{len(chapter_urls)}) {link}')
        article = scrape_chapter(book_title, link, converter, count)
        if article is not None:
            articles.append(article)
            # time.sleep(2)
        else:
            failed_urls.append(link)
        count = count + 1


    if len(failed_urls) > 0:
        failed_urls_sorted = sorted(failed_urls)
        print(f'*****************************')
        print(f'Could not scrape for urls:')
        for url in failed_urls_sorted:
            print(f'* {url}')

    print(f'Scraped {len(articles)} articles!')
    return articles
