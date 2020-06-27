import article_utils
import utils
from firebase_admin import firestore
import my_firebase as firebase
import pprint
import itertools


def has_book_tag(scraped_articles_collection):
    return scraped_articles_collection.where(u'tags', 'array_contains_any', [u'book'])


def order_by_title(scraped_articles_collection):
    return scraped_articles_collection.order_by(u'chineseTitle', direction=firestore.Query.ASCENDING)


def docRefId_to_article(docs, existing_articles):
    return {docRef.id: article for (docRef, article) in zip(docs, existing_articles)}


def title_extractor(article):
    return article.chinese_title

def ch_extractor(article):
    return article.chapter_num


# sort_fn_list should be in the order of priority, this method will reverse the order when actually sorting
def sort(refId_to_article, sort_key_extractor_list):
    article_list = [(refId, article) for refId, article in refId_to_article.items()]
    for sort_key_extractor in sort_key_extractor_list[::-1]:
        article_list.sort(key=lambda article_tuple: sort_key_extractor(article_tuple[1]))
    return {article_tuple[0]: article_tuple[1] for article_tuple in article_list}



if __name__ == "__main__":
    # articles = article_utils.load_from_json()
    # if True:
    #     article_utils.print_articles_min(articles)
    db = firebase.get_db()
    (docs, existing_articles, scraped_articles_collection) = firebase.get_existing_articles(db, [has_book_tag])
    articles_queried = docRefId_to_article(docs, existing_articles)
    articles_queried = sort(articles_queried, [ch_extractor])

    pp = pprint.PrettyPrinter(indent=2)
    count = 1
    for docRef, article in articles_queried.items():
        print(f'({count}/{len(articles_queried)}) {article.chinese_title}')
        article_utils.print_article_min(article)
        # print(f'  *  docRef: {docRef}')
        # print(f'  *  chapter_num: {pp.pformat(article.chapter_num)}')
        # print(f'  *  favorite: {pp.pformat(article.favorite)}')
        # print(f'  *  tags: {pp.pformat(article.tags)}')
        print('')
        count = count + 1

    confirm = utils.get_yes_no(f'Are you sure you want to delete {len(articles_queried)} articles? ')
    if confirm:
        count = 0
        for docRef, article in itertools.islice(articles_queried.items(), 0, None):
            print(f'Deleting ({count}/{len(articles_queried)}) {article.chinese_title} ...')
            print(f'  *  docRef: {docRef}')
            print(f'  *  chapter_num: {pp.pformat(article.chapter_num)}')
            print(f'  *  favorite: {pp.pformat(article.favorite)}')
            print(f'  *  tags: {pp.pformat(article.tags)}')
            print('')
            count = count + 1
            db.collection(u'scraped_articles').document(docRef).delete()
    #
    #

