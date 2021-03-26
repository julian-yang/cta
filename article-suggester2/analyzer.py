import article_utils
import pprint
import my_firebase as firebase
import collections
import itertools
import utils
from scripts.query_articles import get_lion_witch_wardrobe, get_kaguya


def ask_if_obvious(candidates):
    obvious = []
    cur = 0
    total = len(candidates)
    for item in candidates:
        cur = cur + 1
        if utils.get_yes_no(f'\n ({cur}/{total}) Please y/n if you know "{item}": '):
            obvious.append(item)
    return obvious


def compute_top_words(db_connection, articles):
    histogram = {}
    for article in articles:
        for word in article.segmentation[:4000]:
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
    # get_articles_method = firebase.get_existing_articles

    # get_articles_method = lambda db: article_utils.parse_firebase_articles(get_lion_witch_wardrobe(db))
    get_articles_method = lambda db: article_utils.parse_firebase_articles(get_kaguya(db))


    known_words, sorted_histogram, word_to_count = compute_top_words(db, get_articles_method(db))
    top20 = list(itertools.islice(word_to_count.items(), 0, 20))
    print('Top 20')
    pprint.pprint(top20)
    filtered = collections.OrderedDict([item for item in word_to_count.items() if item[0] not in known_words])

    start = 0
    if not utils.get_yes_no('Update obvious words? (y/n): '):
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
        if not utils.get_yes_no('Continue? (y/n): '):
            break

    print('Done')
    known_words, sorted_histogram, word_to_count = compute_top_words(db, get_articles_method(db))
    print('Top 20 unknown:')
    filtered = collections.OrderedDict([item for item in word_to_count.items() if item[0] not in known_words])
    top20_filtered = list(itertools.islice(filtered.items(), 0, 20))
    pprint.pprint(top20_filtered)
