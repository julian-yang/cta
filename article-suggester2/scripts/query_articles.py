import article_utils
import utils
from firebase_admin import firestore
import my_firebase as firebase
import pprint
import itertools


def where_tag(tag_name):
    return lambda scraped_articles_collection: scraped_articles_collection.where(u'tags', 'array_contains_any', [tag_name])

def has_book_tag(scraped_articles_collection):
    return scraped_articles_collection.where(u'tags', 'array_contains_any', [u'book'])

def has_kaguya_tag(scraped_articles_collection):
    return scraped_articles_collection.where(u'tags', 'array_contains_any', [u'kaguya'])


def order_by_title(scraped_articles_collection):
    return scraped_articles_collection.order_by(u'chineseTitle', direction=firestore.Query.ASCENDING)


def title_extractor(article):
    return article.chinese_title

def ch_extractor(article):
    return article.chapter_num


# sort_fn_list should be in the order of priority, this method will reverse the order when actually sorting
def sort(docs, sort_key_extractor_list):
    for sort_key_extractor in sort_key_extractor_list[::-1]:
        docs.sort(key=lambda doc: sort_key_extractor(article_utils.parse_firebase_article(doc)))
    return docs


def get_lion_witch_wardrobe(db):
    return firebase.get_existing_articles(db, [where_tag(r'納尼亞傳奇1：獅子、女巫和衣櫥')])

def get_kaguya(db):
    return firebase.get_existing_articles(db, [where_tag(r'kaguya')])


if __name__ == "__main__":
    # articles = article_utils.load_from_json()
    # if True:
    #     article_utils.print_articles_min(articles)
    db = firebase.get_db()
    docs = firebase.get_existing_articles(db, [has_kaguya_tag])
    sort(docs, [ch_extractor])

    pp = pprint.PrettyPrinter(indent=2)
    count = 1
    for doc in docs:
        article = article_utils.parse_firebase_article(doc)
        print(f'({count}/{len(docs)}) {article.chinese_title}')
        article_utils.print_article_min(article)
        # print(f'  *  docRef: {docRef}')
        # print(f'  *  chapter_num: {pp.pformat(article.chapter_num)}')
        # print(f'  *  favorite: {pp.pformat(article.favorite)}')
        # print(f'  *  tags: {pp.pformat(article.tags)}')
        print('')
        count = count + 1

    confirm = utils.get_yes_no(f'Are you sure you want to delete {len(docs)} articles? ')
    if confirm:
        count = 0
        for doc in docs:
            article = article_utils.parse_firebase_article(doc)
            print(f'Deleting ({count}/{len(docs)}) {article.chinese_title} ...')
            print(f'  *  docRef: {doc.id}')
            print(f'  *  chapter_num: {pp.pformat(article.chapter_num)}')
            print(f'  *  favorite: {pp.pformat(article.favorite)}')
            print(f'  *  tags: {pp.pformat(article.tags)}')
            print('')
            count = count + 1
            db.collection(u'scraped_articles').document(doc.id).delete()
    #
    #

