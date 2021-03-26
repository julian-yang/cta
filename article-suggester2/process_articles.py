from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import json
import io
import os
import article_utils
from scrapers import scrape_articles
import my_firebase as firebase
import utils


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

    mean_square_vocab_level_checkbox = driver.find_element_by_id('A204')
    if not mean_square_vocab_level_checkbox.is_selected():
        mean_square_vocab_level_checkbox.click()

    segmentation_checkbox = driver.find_element_by_id('Z22')
    if not segmentation_checkbox.is_selected():
        segmentation_checkbox.click()

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
        # article.stats.word_count = int(data_row['詞數'])
        article.stats.average_word_difficulty = float(data_row['華語詞彙難度平均'])
        # article.avgWordDifficulty = data_row['詞彙難度平均']
        # article.unique_words.extend(set(data_row['詞數(顯示文字)'].split(',')))
        unique_words = set(data_row['詞數(顯示文字)'].split(','))
        article.stats.mean_square_difficulty = float(data_row['華語詞彙難度均方和'])
        raw_segmentation = data_row['本文斷詞後結果(顯示文字)']
        segmentation = raw_segmentation.split(' ')
        article.stats.word_count = len(segmentation)
        article.segmentation.extend(segmentation)
        segmentation_unique = set(segmentation)

        results.append(article)
    # driver.close()
    return results


def load_hsk_words():
    known_words = []
    script_dir = os.path.dirname(__file__)
    for level in range(1, 6):
        hsk_filename = rf'hsk{level}.txt'
        hskfile = os.path.join(script_dir, hsk_filename)
        # hskfile = rf'C:\Users\yang_\PycharmProjects\articlesuggester\hsk{level}.csv'
        print(hskfile)
        with io.open(hskfile, mode='r', encoding='utf-8') as csvfile:
            for hskline in csvfile.readlines():
                hskword = hskline.split('\t')[1] # first one is simplified
                known_words.append(hskword)
    return list(set(known_words))


def load_known_words():
    known_words = load_hsk_words()
    script_dir = os.path.dirname(__file__)
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
        article_known_words = [word for word in article.segmentation if word in known_words] # article_unique_words.intersection(known_words)
        article.stats.known_ratio = len(article_known_words) / len(article.segmentation)
        article.stats.unique_known_ratio = len(set(article_known_words)) / len(set(article.segmentation))
        article.stats.known_word_count = len(article_known_words)


use_cache = False
if __name__ == "__main__":
    db = firebase.get_db()
    scraped_articles = article_utils.load_from_json() if use_cache else scrape_articles.scrapeArticles(db)
    (zip_file, article_mapping) = scrape_articles.manifest_articles(scraped_articles)

    known_words = firebase.get_known_words(db)
    articles = parse_articles(zip_file, article_mapping)
    if (len(article_mapping.keys()) != len(scraped_articles)):
        print(f'The parsed articles do not match input! input: {len(scraped_articles)} output: {len(articles)}')
    add_known_ratio(known_words, articles)
    # sort by secondary key first, then primary key.
    articles.sort(key=lambda article: article.stats.average_word_difficulty)
    # articles.sort(key=article_utils.unknown_word_count)
    count = 0
    article_utils.print_articles_min(articles)

    article_utils.dump_to_json(articles, filename='processed_cached_articles.json')
    if utils.get_yes_no('Insert into firebase? '):
        firebase.insert_scraped_articles(db, articles)

    print('Done!')

    # firebase.insert_hsk_words(db, load_hsk_words())
    # selection = input('Please select which article to use: ')
    # print(f'you selected: {selection}')
