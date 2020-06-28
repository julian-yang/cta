import os
import time
import datetime

import scrape_aixdzs
import scrape_bbc
import scrape_liberty_times
import utils
import scrape_dushu
import article_utils
from zipfile import ZipFile
import my_firebase as firebase


def hello():
    print('hello world')


def manifest_articles(articles):
    st = datetime.datetime.fromtimestamp(time.time()).strftime('%Y_%m_%d__%H_%M_%S')
    cwd = os.path.dirname(os.path.realpath(__file__))
    directory = os.path.join(cwd, st)  # rf'{cwd}\{st}'
    print(directory)
    if not os.path.exists(directory):
        os.makedirs(directory)

    zip_filename = rf'{directory}.zip'
    article_mapping = {}
    with ZipFile(zip_filename, 'w') as zip:
        for article in articles:
            filename = rf'{sanitize_article_title(article.chinese_title)}.txt'
            if filename in article_mapping.keys():
                continue
            full_filename = os.path.join(directory, filename)  # rf'{directory}\{filename}'
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


def sanitize_article_title(title):
    return title.replace('/', '-').replace('\\', '-')
    # if os.path.sep == '/':
    #     return title.replace('/', '\\')
    # elif os.path.sep == '\\':
    #     return title.replace('\\', '/')
    # else:
    #     return title


scrape_types = {
    1: {
        'name': 'BBC',
        'scraper': scrape_bbc.scrapeBBC
    },
    2: {
        'name': 'Liberty Times',
        'scraper': scrape_liberty_times.scrapeLibertyTimes
    },
    3: {
        'name': 'DuShu',
        'scraper': scrape_dushu.scrapeDuShu
    },
    4: {
        'name': 'Aixdzs',
        'scraper': scrape_aixdzs.scrapeAixdzs
    }
}


def scrapeArticles(db):
    types_format = '\n'.join([f' * ({num}) {val["name"]}' for (num, val) in scrape_types.items()])
    scrape_type = int(input(f'Enter type to scrape:\n{types_format}\n'))
    utils.get_yes_no(f'Confirm type (y/n): ({scrape_type}) {scrape_types[scrape_type]["name"]}\n')
    articles = scrape_types[scrape_type]['scraper'](db)
    return articles



if __name__ == "__main__":
    articles = scrapeArticles(firebase.get_db())
    article_utils.dump_to_json(articles)
    (zip_file, article_mapping) = manifest_articles(articles)

    # pprint.pprint(scrapeBBC().pop())
