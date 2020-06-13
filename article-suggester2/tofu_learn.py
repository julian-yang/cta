from selenium import webdriver
from bs4 import BeautifulSoup
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import json
import csv
import io
import scrape_articles
import pprint
import requests
from texttable import Texttable

def login_tofu_learn():
    driver = webdriver.Chrome()
    driver.get('https://www.tofulearn.com/login')
    current_url = driver.current_url
    email = driver.find_element_by_css_selector("input[type='email']")
    email.clear()
    email.send_keys("xsouthpawed@gmail.com")
    password = driver.find_element_by_css_selector("input[type='password']")
    password.clear()
    password.send_keys("combustion3")
    driver.find_element_by_css_selector("paper-button#btnLogin").click()
    WebDriverWait(driver, 15).until(EC.url_changes(current_url))
    return driver


def retrieve_json(driver, url):
    driver.get(url)
    raw_json = driver.find_element_by_tag_name('pre')
    # skip first 3 characters (the 'json' starts with 'SRS')
    return json.loads(raw_json.text[3:])


def retrieve_deck(driver, deck_id):
    deck_url = f'https://www.tofulearn.com/api/getDeck/{deck_id}'
    deck_json = retrieve_json(driver, deck_url)
    deck_title = deck_json['template']['name']
    num_sets = deck_json['template']['summary']['levels']
    words = set()
    for num in range(0, num_sets):
        set_json = retrieve_json(driver, f'{deck_url}/{num}')
        for card in set_json['templates']:
            words.add(card['word'])
    print(f'{deck_title}: {len(words)}')
    return [deck_title, deck_id, num_sets, words]
    # print(f'{deck_title}\t\t\t{deck_id}\t\t{num_sets}')

# returns a set of all words known
def retrieve_decks():
    driver = login_tofu_learn()
    decks_json = retrieve_json(driver, 'https://www.tofulearn.com/api/getDecks')
    deck_table = Texttable()
    deck_table.add_row(['title', 'id', 'num_sets'])
    all_words = set()
    for deck in decks_json['decks']:
        id = deck['id']
        info = retrieve_deck(driver, id)
        row = info[:-1]
        all_words |= info[-1]
        deck_table.add_row(row)
    print(deck_table.draw())
    print(f'total words: {len(all_words)}')
    return all_words


if __name__ == "__main__":
    retrieve_decks()
    # pprint.pprint(cookies, width=1)
