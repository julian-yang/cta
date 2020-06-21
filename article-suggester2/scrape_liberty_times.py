from bs4 import BeautifulSoup
from bs4.element import Tag
from bs4.element import NavigableString
import requests
import pprint
import os
import time
import datetime
import re
import article_utils
import dateparser
import lib.article_pb2 as article_pb2
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

only_scrape_1 = False

url_filter = [
    "https://news.ltn.com.tw/news/world/breakingnews/",
    "https://news.ltn.com.tw/news/life/breakingnews/",
    'https://news.ltn.com.tw/news/society/breakingnews/',
    'https://news.ltn.com.tw/news/politics/breakingnews/'
]

unsupported_general_url_prefix = [
    'https://news.ltn.com.tw/news/focus/',
    'https://talk.ltn.com.tw/article/paper/',
]


def get_http_session():
    session = requests.Session()
    retry = Retry(connect=10, backoff_factor=0.5)
    adapter = HTTPAdapter(max_retries=retry)
    session.mount('http://', adapter)
    session.mount('https://', adapter)
    return session


def is_caption_tag(element):
    if 'class' in element.attrs and 'ph_b' in element.attrs['class']:
        return True
    elif element.find('span', class_='ph_b'):
        return True
    else:
        return False


header_regex = re.compile('h\d')
def is_acceptable_text(element):
    element_type = type(element)
    is_tag_type = element_type == Tag
    if element_type == NavigableString:
        return True
    elif is_tag_type and (element.name in ['br', 'a', 'b', 'font'] or header_regex.match(element.name)):
        maybe_print(f'acceptable tag? {element}')
        return True
    elif element.text.strip() == '。':
        return True
    elif is_caption_tag(element):
        maybe_print(f'caption tag? {element}')
        return False
    elif is_tag_type and element.name == 'span' and not bool(element.attrs):
        maybe_print(f'vanilla span? {element}')
        return True
    elif is_tag_type and element.name in ['iframe']:
        maybe_print(f'explicit banned tag? {element}')
        return False
    else:
        maybe_print(f'some other tag? {element}')
        return False


def maybe_print(text):
    debug_print = True
    if debug_print:
        print(f'* {text}\n')


def is_article_text(p_tag, banned_tags):
    if not list(p_tag.children):
        return False # empty tag?
    elif '點我訂閱自由財經Youtube頻道' in p_tag.text:
        print(f'Youtube link?: {p_tag.text}')
        return False
    else:
        test = [child for child in p_tag.children if not is_acceptable_text(child)]
        if test:
            # print(f'Banned ptag: {p_tag}')
            banned_tags.append(p_tag)
            return False
        else:
            return True


def extract_article_text(p_tags):
    banned_tags = []
    article_texts = [pTag.text for pTag in p_tags if is_article_text(pTag, banned_tags)]
    print('Accepted text:')
    pprint.pprint(article_texts)
    print('Banned ptags:')
    pprint.pprint(banned_tags)
    return '\n'.join(article_texts)#, banned_tags


def has_unsupported_general_url_prefix(url):
    prefix_detection = [prefix for prefix in unsupported_general_url_prefix if url.startswith(prefix)]
    return len(prefix_detection) != 0


def scrape_liberty_article(input_url):
    response = get_http_session().get(input_url)
    # response = requests.get(url)
    if not response.status_code == 200:
        return None
    landing_url = response.url
    article = None
    if landing_url.startswith('https://news.ltn.com.tw/news/') and not has_unsupported_general_url_prefix(landing_url):
        article = scrape_general_liberty_article(landing_url)
    elif landing_url.startswith('https://ec.ltn.com.tw/article/'):
        article = scrape_ec_liberty_article(landing_url)
    elif landing_url.startswith('https://ent.ltn.com.tw/'):
        article = scrape_ent_liberty_article(landing_url)
    elif landing_url.startswith('https://sports.ltn.com.tw/news/'):
        article = scrape_sports_liberty_article(landing_url)
    return (article, landing_url)


# TODO: change these to take in BeautifulSoup
# returns a article_pyb2.Article
def scrape_general_liberty_article(url):
    response = get_http_session().get(url)
    # response = requests.get(url)
    if not response.status_code == 200:
        return None
    soup = BeautifulSoup(response.content, 'html.parser')
    article = article_pb2.Article()
    article.url = url
    article_div = soup.find('div', attrs={'itemprop': 'articleBody'})
    article.chinese_title = article_div.find('h1').text.replace(':', '：').rstrip()
    raw_date = article_div.find('span', class_='time')
    if raw_date is not None:
        article.publish_date.FromDatetime(dateparser.parse(raw_date.text))

    p_tags = [p_tag for p_tag in article_div.select('div[data-desc="內容頁"] > p') if 'class' not in p_tag.attrs]
    # p_tags = article_div.find_all('p', attrs={'class': None})
    article.chinese_body = extract_article_text(p_tags)
    article_utils.print_article(article)
    return article


# scrape economics article
def scrape_ec_liberty_article(url):
    response = get_http_session().get(url)
    if not response.status_code == 200:
        return None
    soup = BeautifulSoup(response.content, 'html.parser')
    article = article_pb2.Article()
    article.url = url
    article_div = soup.find('div', attrs={'data-desc': '內文'})
    article.chinese_title = article_div.find('h1').text.replace(':', '：').rstrip()
    raw_date = article_div.find('span', class_='time')
    if raw_date is not None:
        article.publish_date.FromDatetime(dateparser.parse(raw_date.text))

    p_tags = [p_tag for p_tag in soup.select('div.text > p') if 'class' not in p_tag.attrs]
    # p_tags = article_div.find('div', class_='text').find_all('p', attrs={'class': None})
    article.chinese_body = extract_article_text(p_tags)
    article_utils.print_article(article)
    return article


# scrape entertainment article
def scrape_ent_liberty_article(url):
    session = get_http_session()

    response = session.get(url)
    if not response.status_code == 200:
        return None
    soup = BeautifulSoup(response.content, 'html.parser')
    article = article_pb2.Article()
    article.url = url
    article_div = soup.find('div', attrs={'class': 'news_content'})
    article.chinese_title = article_div.find('h1').text.replace(':', '：').rstrip()
    raw_date = article_div.find('div', class_='date')
    if raw_date is not None:
        article.publish_date.FromDatetime(dateparser.parse(raw_date.text))

    p_tags = [p_tag for p_tag in soup.select('div.news_content > p') if 'class' not in p_tag.attrs]
    # p_tags = article_div.find_all('p', attrs={'class': None})
    article.chinese_body = extract_article_text(p_tags)
    article_utils.print_article(article)
    return article


# scrape sports article
def scrape_sports_liberty_article(url):
    session = get_http_session()

    response = session.get(url)
    if not response.status_code == 200:
        return None
    soup = BeautifulSoup(response.content, 'html.parser')
    article = article_pb2.Article()
    article.url = url
    article_div = soup.find('div', attrs={'class': 'news_content'})
    article.chinese_title = article_div.find('h1').text.replace(':', '：').rstrip()
    raw_date = article_div.find('div', class_='c_time')
    if raw_date is not None:
        article.publish_date.FromDatetime(dateparser.parse(raw_date.text))

    p_tags = [p_tag for p_tag in article_div.select('div[itemProp=articleBody] > p') if 'class' not in p_tag.attrs]
    # p_tags = article_div.find_all('p', attrs={'class': None})
    article.chinese_body = extract_article_text(p_tags)
    article_utils.print_article(article)
    return article


def scrape_base_page(base_page_url):
    response = requests.get(base_page_url)
    if not response.status_code == 200:
        return None
    soup = BeautifulSoup(response.content, 'html.parser')
    article_urls = []
    # for article in soup.find_all('a', class_='title-link')[::5]:
    for article in soup.find_all('a', class_='tit'):
        article_url = article['href']
        article_urls.append(article_url)
        # if article_url.startswith(traditional_prefix):
        # article_urls.append(f'{liberty_urlbase}{article_url}')
    return article_urls

# returns a list of dict
def scrapeLibertyTimes():
    liberty_urlbase = 'https://news.ltn.com.tw/'
    # traditional_prefix = '/zhongwen/trad'
    categories = ['list/breakingnews', 'list/breakingnews/popular']
    article_urls = set()
    for category in categories:
        article_urls.update(scrape_base_page(f'{liberty_urlbase}{category}'))

    articles = []
    # uncomment to just scrape the first article
    if only_scrape_1:
        article_urls = article_urls[0:1]

    failed_urls = []
    for link in article_urls:
        print(link)
        (article, landing_url) = scrape_liberty_article(link)
        if article is not None:
            articles.append(article)
        else:
            failed_urls.append(landing_url)

    if len(failed_urls) > 0:
        failed_urls_sorted = sorted(failed_urls)
        print(f'*****************************')
        print(f'Could not scrape for urls:')
        for url in failed_urls_sorted:
            print(f'* {url}')

    print(f'Scraped {len(articles)} articles!')
    return articles
