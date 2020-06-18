from google.cloud import firestore
import firebase_admin
import google.protobuf.json_format as json_format
from firebase_admin import credentials
from firebase_admin import firestore
import lib.article_pb2 as article_pb2
import lib.vocab_pb2 as vocab_pb2
import datetime
import pprint
import article_utils


# Note you can only call this once per script run!
def get_db():
    service_account_filepath ='c:\_downloads\chinesetextloader-firebase-adminsdk-sf42v-d86a52ce3a.json'
    cred = credentials.Certificate(service_account_filepath)
    firebase_admin.initialize_app(cred)
    return firestore.client()


def insert_hsk_words(db_connection, hsk_words):
    known_words_collection = db_connection.collection(u'known_words')
    converted_hsk_words = [convertToWordProto(word) for word in hsk_words]
    hsk_vocabularies = vocab_pb2.Vocabularies()
    hsk_vocabularies.known_words.extend(converted_hsk_words)
    hsk_vocabularies_dict = json_format.MessageToDict(hsk_vocabularies, preserving_proto_field_name=True)
    known_words_collection.document(u'hsk').set(hsk_vocabularies_dict)


def convertToWordProto(word):
    proto = vocab_pb2.Word()
    proto.head_word = word
    return proto


def insert_scraped_articles(db_connection, articles):
    scraped_articles_collection = db_connection.collection(u'scraped_articles')
    print('streaming existing articles...')
    docs = list(scraped_articles_collection.stream())
    print('parsing existing articles...')
    existing_articles = article_utils.parse_firebase_articles(docs)
    existing_urls = [article.url for article in existing_articles]
    new_articles = [article for article in articles if article.url not in existing_urls]
    added_articles = []
    for article in new_articles:
        result = article_utils.add_article_to_firebase(scraped_articles_collection, article)
        added_articles.append(result)
    pp = pprint.PrettyPrinter(indent=2)

    print('\n**********\nExisting docs:\n**********')
    for doc in docs:
        print(articleStringWithoutSegmentation(pp, doc))

    print('\n**********\nadded docs:\n**********')
    added_articles = [(added_article[0], scraped_articles_collection.document(added_article[1].id).get()) for added_article in added_articles]
    for added_article in added_articles:
        timestamp = added_article[0]
        doc = added_article[1]
        print(articleStringWithoutSegmentation(pp, doc))


def articleStringWithoutSegmentation(pp, doc):
    stripDoc = doc.to_dict()
    stripDoc.pop('segmentation', None)
    return f'{doc.id} => {pp.pformat(stripDoc)}'


def calculate_avg_length():
    db = get_db()
    articles_collection = db.collection(u'articles')
    docs = list(articles_collection.stream())
    lengths = [len(doc.to_dict()['chineseBody']) for doc in docs]
    average = sum(lengths) / len(lengths)
    print(f'average={average}, lengths={lengths}')


if __name__ == "__main__":
    articles = article_utils.load_from_json()
    if True:
        article_utils.print_articles_min(articles)
    # calculate_avg_length()
    db = get_db()
    insert_scraped_articles(db, articles)

