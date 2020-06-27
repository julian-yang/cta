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


def scrape_chapter(book_title, url, converter):
    response = get_http_session().get(url)
    # response = requests.get(url)
    if not response.status_code == 200:
        return None
    soup = BeautifulSoup(response.content, 'html.parser')
    article = article_pb2.Article()
    article.url = url
    article.chinese_title = soup.find('td', class_='cntitle').text.replace(':', '：').rstrip()
    content_tag = soup.find('td', class_='content')
    paragraphs = [converter.convert(p_tag.text) for p_tag in content_tag.select('p')]
    article.chinese_body = '\n'.join(paragraphs)
    article.tags.extend(['dushu', 'book', book_title])
    article_utils.print_article(article)
    return article


def scrape_book_page(base_page_url, converter):
    response = requests.get(base_page_url)
    if not response.status_code == 200:
        return None
    soup = BeautifulSoup(response.content, 'html.parser')
    article_urls = []
    dushu_urlbase = 'http://www.dushu369.com'
    # for article in soup.find_all('a', class_='title-link')[::5]:
    book_title = converter.convert(soup.find('td', class_='cntitle').text)
    for article in soup.find_all('a', class_='a0'):
        article_url = article['href']
        article_urls.append(f'{dushu_urlbase}{article_url}')
        # if article_url.startswith(traditional_prefix):
        # article_urls.append(f'{liberty_urlbase}{article_url}')
    return book_title, article_urls

# returns a list of dict
def scrapeDuShu(db):
    book_url = input(f'Enter url to scrape: ')
    utils.get_yes_no(f'Confirm url (y/n): {book_url}\n')

    dushu_urlbase = 'http://www.dushu369.com'
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
        article = scrape_chapter(book_title, link, converter)
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
