import article_utils
import scrape_liberty_times
import webbrowser
import textwrap
import pprint
from selenium import webdriver
import my_firebase as firebase
import collections
import itertools


def get_yes_no(text):
    selection = ''
    while selection not in ['y', 'n']:
        selection = input(f'{text}')
    return selection == 'y'


def ask_if_obvious(candidates):
    obvious = []
    cur = 0
    total = len(candidates)
    for item in candidates:
        cur = cur + 1
        if get_yes_no(f'\n ({cur}/{total}) Please y/n if you know "{item}": '):
            obvious.append(item)
    return obvious


def compute_top_words(db_connection):
    (docs, articles, scraped_articles_collection) = firebase.get_existing_articles(db_connection)
    histogram = {}
    for article in articles:
        for word in article.segmentation:
            sofar = histogram.setdefault(word, {'count': 0, 'articles': {}})
            sofar['count'] = sofar['count'] + 1
            if article.url not in sofar['articles'].keys():
                sofar['articles'][article.url] = article
    known_words = firebase.get_known_words(db_connection)
    sorted_histogram = collections.OrderedDict(
        [(k, v) for k, v in sorted(histogram.items(), key=lambda item: item[1]['count'], reverse=True)])
    word_to_count = collections.OrderedDict(
        [(item[0], {'count': item[1]['count'], 'num_articles': len(item[1]['articles'])}) for item in
         sorted_histogram.items()])
    return known_words, sorted_histogram, word_to_count

if __name__ == "__main__":
    db = firebase.get_db()
    known_words, sorted_histogram, word_to_count = compute_top_words(db)
    top20 = list(itertools.islice(word_to_count.items(), 0, 20))
    print('Top 20')
    pprint.pprint(top20)
    filtered = collections.OrderedDict([item for item in word_to_count.items() if item[0] not in known_words])

    start = 0
    if not get_yes_no('Update obvious words? (y/n): '):
        print('goodbye!')
        exit(0)

    while start < len(filtered.items()):
        top20_filtered = list(itertools.islice(filtered.items(), start, min(start + 20, len(filtered.items()))))
        print('Top 20 filtered')
        pprint.pprint(top20_filtered)

        candidates = [item[0] for item in top20_filtered]
        obvious = ask_if_obvious(candidates)
        print('Inserting these words into obvious:')
        pprint.pprint(obvious)
        firebase.insert_obvious_words(db, obvious)
        start = start + 20
        if not get_yes_no('Continue? (y/n): '):
            break

    print('Done')
    known_words, sorted_histogram, word_to_count = compute_top_words(db)
    print('Top 20 unknown:')
    filtered = collections.OrderedDict([item for item in word_to_count.items() if item[0] not in known_words])
    top20_filtered = list(itertools.islice(filtered.items(), 0, 20))
    pprint.pprint(top20_filtered)
