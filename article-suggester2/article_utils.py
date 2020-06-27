import google.protobuf.text_format as text_format
import google.protobuf.json_format as json_format
import lib.article_pb2 as article_pb2
import json

def print_article(article):
    print(text_format.MessageToString(article, as_utf8=True))

def print_article_min(article):
    print_field('word_count', article.stats.word_count)
    print_field('average_word_difficulty', article.stats.average_word_difficulty)
    # print_field('unknown_word_count', unknown_word_count(article))
    print_field('known_ratio', article.stats.known_ratio)
    print_field('unique_known_ratio', article.stats.unique_known_ratio)
    print_field('mean_square_difficulty', article.stats.mean_square_difficulty)
    print_field('url', article.url)
    print_field('tags', article.tags)


def print_field(field, value):
    print(f' * {field}: {value}')


def print_articles_min(articles):
    count = 0
    for article in articles:
        print(f'({count}) {article.chinese_title}:')
        print_article_min(article)
        print('')
        count += 1


# def unknown_word_count(article):
#     return len(article.unique_words) - article.stats.known_word_count


def parse_firebase_article(doc):
    dict = doc.to_dict()
    add_date = dict.pop('addDate', None)
    publish_date = dict.pop('publishDate', None)
    try:
        json_str = json.dumps(dict, default=str)
        article = json_format.Parse(json_str, article_pb2.Article())
        if add_date is not None:
            article.add_date.FromJsonString(add_date.rfc3339())
        if publish_date is not None:
            article.publish_date.FromJsonString(publish_date.rfc3339())
        return article
    except json_format.ParseError as e:
        print(f'Failed to parse into Article proto: doc={dict}')
        return None


def parse_firebase_articles(docs):
    return [article for article in (parse_firebase_article(doc) for doc in docs) if article is not None]


def add_article_to_firebase(collection, article):
    article.add_date.GetCurrentTime()
    article_dict = json_format.MessageToDict(article, preserving_proto_field_name=False)
    article_dict['addDate'] = article.add_date.ToDatetime()
    article_dict['publishDate'] = article.publish_date.ToDatetime()
    result = collection.add(article_dict)
    return result


def add_vocabularies_to_firebase(collection, vocabularies):
    vocabularies_dict = json_format.MessageToDict(vocabularies, preserving_proto_field_name=False)
    result = collection.add(vocabularies_dict)
    return result


cached_name = 'cached_articles.json'


def dump_to_json(articles, filename=cached_name):
    articles_proto = article_pb2.Articles()
    articles_proto.articles.extend(articles)
    with open(filename, 'w', encoding="utf-8") as fout:
        fout.write(text_format.MessageToString(articles_proto, as_utf8=True))


def load_from_json(filename=cached_name):
    with open(filename, 'r', encoding="utf-8") as fin:
        data = fin.read()
        articles = text_format.Parse(data, article_pb2.Articles())
        return list(articles.articles)
