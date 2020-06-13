from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import json
import csv
import io
import os
import article_utils
import scrape_articles
from operator import attrgetter
from article import Article
import my_firebase as firebase
import pprint

def parse_articles(zip_file, article_mapping):
    driver = webdriver.Chrome()
    driver.get('http://www.chinesereadability.net/CRIE/?LANG=ENG')

    # Sign in
    username = driver.find_element_by_id('Login1_UserName')
    username.clear()
    username.send_keys('julian')
    password = driver.find_element_by_id('Login1_Password')
    password.clear()
    password.send_keys('p4ssw0rd')
    driver.find_element_by_id('LoginButtonL2').click()

    # Setup feature select.
    # Words
    words = driver.find_element_by_id('A102')
    if not words.is_selected():
        words.click()

    # Average of vocabulary levels
    avg_vocab_level = driver.find_element_by_id('A203')
    if not avg_vocab_level.is_selected():
        avg_vocab_level.click()

    next_btn = driver.find_element_by_css_selector("input.english_text[name='nextBtn1']")
    next_btn.click()

    driver.find_element_by_link_text('Batch Process').click()
    upload_file = driver.find_element_by_css_selector('div.plupload.html5 input')
    # TODO(julian): replace this with some zip file directory.
    # after this command, file should automatically upload, just need to accept the popup to start the computation.
    upload_file.send_keys(zip_file)
    WebDriverWait(driver, 60).until(EC.alert_is_present())
    driver.switch_to.alert.accept()

    WebDriverWait(driver, 300).until(EC.text_to_be_present_in_element((By.CLASS_NAME, 'loading-progress-14'), '100%'))

    raw_data_rows = driver.find_elements_by_css_selector('div#HiddenStorage div')
    results = []

    for rawDataRow in raw_data_rows:
        data_row = json.loads(rawDataRow.get_attribute('innerText'))
        # no idea why we need to access data_row here for this to work..
        # test = data_row.items()
        # article = Article()
        filename = data_row['檔名']
        article = article_mapping[filename]
        article.word_count = int(data_row['詞數'])
        article.average_word_difficulty = float(data_row['華語詞彙難度平均'])
        # article.avgWordDifficulty = data_row['詞彙難度平均']
        article.unique_words.extend(set(data_row['詞數(顯示文字)'].split(',')))
        results.append(article)
    # driver.close()
    return results


def load_known_words():
    known_words = []
    script_dir = os.path.dirname(__file__)
    for level in range(1, 5):
        hsk_filename = rf'hsk{level}.csv'
        hskfile = os.path.join(script_dir, hsk_filename)
        # hskfile = rf'C:\Users\yang_\PycharmProjects\articlesuggester\hsk{level}.csv'
        print(hskfile)
        with io.open(hskfile, mode='r', encoding='utf-8') as csvfile:
            for hskword in csv.reader(csvfile):
                known_words.append(hskword[0])

    pleco_filename = os.path.join(script_dir, 'pleco.txt')
    with io.open(pleco_filename, mode='r', encoding='utf-8') as pleco_file:
        lines = pleco_file.readlines()
        for line in lines:
            split = line.split('\t', 1)
            word = split[0]
            known_words.append(word)

    return known_words


def add_known_ratio(known_words, articles):
    known_words = set(known_words)
    for article in articles:
        article_unique_words = set(article.unique_words)
        article_known_words = article_unique_words.intersection(known_words)
        article.stats.known_ratio = len(article_known_words) / len(article_unique_words)
        article.stats.known_word_count = len(article_known_words)

def merge_article_data(scraped, parsed_articles):
    mappings = {}
    for scraped_article in scraped:
        mappings[scraped_article['filename']] = {'scraped': scraped_article}
    for parsed_article in parsed_articles:
        entry = mappings[parsed_article.filename]
        entry['parsed'] = parsed_article
    merged = []
    for filename, mapping in mappings.items():
        article = mapping['scraped'].copy()
        parsed = mapping['parsed']
        article['wordCount'] = parsed.wordCount
        article['avgWordDifficulty'] = parsed.avgWordDifficulty
        article['uniqueWords'] = parsed.uniqueWords
        merged.append(article)
    return merged





if __name__ == "__main__":
    scraped_articles = scrape_articles.scrapeBBC()
    (zip_file, article_mapping) = scrape_articles.manifest_articles(scraped_articles)
    known_words = load_known_words()
    articles = parse_articles(zip_file, article_mapping)
    add_known_ratio(known_words, articles)
    # sort by secondary key first, then primary key.
    articles.sort(key=lambda article: article.average_word_difficulty)
    articles.sort(key=article_utils.unknown_word_count)
    count = 0
    article_utils.print_articles_min(articles)

    article_utils.dump_to_json(articles)

    firebase.insert_scraped_articles(articles)
    # selection = input('Please select which article to use: ')
    # print(f'you selected: {selection}')
