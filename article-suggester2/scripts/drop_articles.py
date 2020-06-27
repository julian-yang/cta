import article_utils
import utils
import my_firebase as firebase
import pprint
import itertools

if __name__ == "__main__":
    # articles = article_utils.load_from_json()
    # if True:
    #     article_utils.print_articles_min(articles)
    db = firebase.get_db()
    (docs, existing_articles, scraped_articles_collection) = firebase.get_existing_articles(db)
    articles_to_drop = {docRef: article for (docRef, article) in zip(docs, existing_articles) if not article.favorite}
    pp = pprint.PrettyPrinter(indent=2)
    count = 1
    for docRef, article in articles_to_drop.items():
        print(f'({count}/{len(articles_to_drop)}) {article.chinese_title}')
        print(f'  *  docRef: {docRef.id}')
        print(f'  *  favorite: {pp.pformat(article.favorite)}')
        print(f'  *  tags: {pp.pformat(article.tags)}')
        print('')
        count = count + 1

    confirm = utils.get_yes_no(f'Are you sure you want to delete {len(articles_to_drop)} articles? ')
    if confirm:
        count = 0
        for docRef, article in itertools.islice(articles_to_drop.items(), 0, None):
            print(f'Deleting ({count}/{len(articles_to_drop)}) {article.chinese_title} ...')
            print(f'  *  docRef: {docRef.id}')
            print(f'  *  favorite: {pp.pformat(article.favorite)}')
            print(f'  *  tags: {pp.pformat(article.tags)}')
            print('')
            count = count + 1
            scraped_articles_collection.document(docRef.id).delete()



