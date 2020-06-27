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
import os
import json

print_existing_firebase_articles = False

# Note you can only call this once per script run!
def get_db():
    cwd = os.path.dirname(os.path.realpath(__file__))
    service_account_filename = 'chinesetextloader-firebase-adminsdk-sf42v-b8321b1f1e.json'
    service_account_filepath = os.path.join(cwd, service_account_filename) #'c:\_downloads\chinesetextloader-firebase-adminsdk-sf42v-d86a52ce3a.json'
    cred = credentials.Certificate(service_account_filepath)
    firebase_admin.initialize_app(cred)
    return firestore.client()


def insert_hsk_words(db_connection, hsk_words):
    insert_words_to_vocabularies(db_connection, hsk_words, u'hsk', rewrite=True)


def insert_words_to_vocabularies(db_connection, word_list, vocabularies_name, rewrite=False):
    known_words_collection = db_connection.collection(u'known_words')
    converted_word_list = [convertToWordProto(word) for word in word_list]
    new_vocabularies = vocab_pb2.Vocabularies()
    new_vocabularies.known_words.extend(converted_word_list)
    target_document = known_words_collection.document(vocabularies_name)
    if rewrite:
        new_vocabularies_dict = json_format.MessageToDict(new_vocabularies, preserving_proto_field_name=False)
        target_document.set(new_vocabularies_dict)
    else:
        existing_vocabularies = parse_vocabularies(target_document.get())
        merged = merge_vocabularies(existing_vocabularies, new_vocabularies)
        merged_vocabularies_dict = json_format.MessageToDict(merged, preserving_proto_field_name=False)
        target_document.set(merged_vocabularies_dict)

def map_headword_to_word(vocabularies):
    return {word.head_word:word for word in vocabularies.known_words}

def merge_vocabularies(a, b):
    a_dict = map_headword_to_word(a)
    b_dict = map_headword_to_word(b)
    merged_dict = {}
    merged_dict.update(a_dict)
    merged_dict.update(b_dict)
    merged = vocab_pb2.Vocabularies()
    merged.known_words.extend(merged_dict.values())
    return merged

def convertToWordProto(word):
    proto = vocab_pb2.Word()
    proto.head_word = word
    return proto


def insert_scraped_articles(db_connection, articles):
    docs, existing_articles, scraped_articles_collection = get_existing_articles(db_connection)
    existing_urls = [article.url for article in existing_articles]
    new_articles = [article for article in articles if article.url not in existing_urls]
    added_articles = []
    for article in new_articles:
        result = article_utils.add_article_to_firebase(scraped_articles_collection, article)
        added_articles.append(result)
    pp = pprint.PrettyPrinter(indent=2)

    if print_existing_firebase_articles:
        print('\n**********\nExisting docs:\n**********')
        for doc in docs:
            print(articleStringWithoutSegmentation(pp, doc))

    print('\n**********\nadded docs:\n**********')
    added_articles = [(added_article[0], scraped_articles_collection.document(added_article[1].id).get()) for added_article in added_articles]
    for added_article in added_articles:
        timestamp = added_article[0]
        doc = added_article[1]
        print(articleStringWithoutSegmentation(pp, doc))


def get_existing_articles(db_connection, where_clauses=[], orderby_clauses=[]):
    scraped_articles_collection = db_connection.collection(u'scraped_articles')
    for where_clause in where_clauses:
        scraped_articles_collection = where_clause(scraped_articles_collection)

    for orderby_clause in orderby_clauses:
        scraped_articles_collection = orderby_clause(scraped_articles_collection)

    print('streaming existing articles...')
    docs = list(scraped_articles_collection.stream())
    print('parsing existing articles...')
    existing_articles = article_utils.parse_firebase_articles(docs)
    return docs, existing_articles, scraped_articles_collection


def parse_vocabularies(vocabularies_ref):
    if vocabularies_ref.exists:
        json_str = json.dumps(vocabularies_ref.to_dict(), default=str)
        return json_format.Parse(json_str, vocab_pb2.Vocabularies())
    else:
        return vocab_pb2.Vocabularies()


def get_known_words(db_connection):
    word_documents = [u'latest', u'hsk', u'obvious']
    known_words_collection = db_connection.collection(u'known_words')
    known_words = set()
    for word_document in word_documents:
        doc_ref = known_words_collection.document(word_document).get()
        doc_words = [word.head_word for word in parse_vocabularies(doc_ref).known_words]
        known_words.update(doc_words)
    return known_words


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


def insert_obvious_words(db_connection, words):
    insert_words_to_vocabularies(db_connection, words, 'obvious')


if __name__ == "__main__":
    articles = article_utils.load_from_json()
    if True:
        article_utils.print_articles_min(articles)
    # calculate_avg_length()
    db = get_db()
    insert_scraped_articles(db, articles)

