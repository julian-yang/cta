import article_utils
import scrape_liberty_times
import webbrowser
import textwrap
import pprint
from selenium import webdriver

use_cached = True

current = 1
total = 0


def verify_article(article, driver):
    global current
    print('\n\n\n\n\n')
    article_utils.print_article_min(article)
    print('\n')
    print(f'({current}/{total}) {article.chinese_title}')
    current = current + 1
    print(f'Wrapped article text:')
    for paragraph in article.chinese_body.split('\n'):
        pprint.pprint(textwrap.wrap(paragraph, 40))
        print()

    print(f'Opening url: {article.url}')
    driver.get(article.url)
    selection = ''
    while selection not in ['y', 'n']:
        selection = input('\nPlease y/n if good: ')
    return selection == 'y'


if __name__ == "__main__":
    if not use_cached:
        articles = scrape_liberty_times.scrapeLibertyTimes()
        article_utils.dump_to_json(articles)

    articles = article_utils.load_from_json()
    total = len(articles)

    driver = webdriver.Chrome()
    bad_articles = [article for article in articles if not verify_article(article, driver)]
    article_utils.dump_to_json(bad_articles, 'bad_articles.json')





