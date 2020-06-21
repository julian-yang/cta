from bs4 import BeautifulSoup
import requests
import os
import time
import datetime
import scrape_bbc
import scrape_liberty_times
import article_utils
import dateparser
import lib.article_pb2 as article_pb2
from zipfile import ZipFile
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

def hello():
    print('hello world')

def manifest_articles(articles):
    st = datetime.datetime.fromtimestamp(time.time()).strftime('%Y_%m_%d__%H_%M_%S')
    cwd = os.path.dirname(os.path.realpath(__file__))
    directory = os.path.join(cwd, st) #rf'{cwd}\{st}'
    print(directory)
    if not os.path.exists(directory):
        os.makedirs(directory)

    zip_filename = rf'{directory}.zip'
    article_mapping = {}
    with ZipFile(zip_filename, 'w') as zip:
        for article in articles:
            filename = rf'{article.chinese_title}.txt'
            full_filename = os.path.join(directory, filename)# rf'{directory}\{filename}'
            print(full_filename)
            file = open(full_filename, "w", encoding="utf-8")
            # for line in article.chinese_body:
            #     file.write(line)
            file.write(article.chinese_title)
            file.write('\n\n')
            file.write(article.chinese_body)
            file.close()
            zip.write(full_filename, arcname=filename)
            article_mapping[filename] = article
    return (zip_filename, article_mapping)



if __name__ == "__main__":
    # articles = scrape_bbc.scrapeBBC()
    articles = scrape_liberty_times.scrapeLibertyTimes()
    zipfile = manifest_articles(articles)

    # pprint.pprint(scrapeBBC().pop())
