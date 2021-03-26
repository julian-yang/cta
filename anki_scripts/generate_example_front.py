import re
import csv
import pprint
from bs4 import BeautifulSoup

contains_han_zi_regex = rf'[\u4e00-\u9fff]+'

header = ['Front', 'Color', 'Pinyin', 'Bopomofo', 'Ruby', 'Ruby (Bopomofo)', 'English', 'Examples', 'Examples-front', 'Classifier',
          'Simplified', 'Traditional', 'Also Written', 'Frequency', 'Silhouette', 'Sound', 'Hanzi']
if __name__ == "__main__":
    new_lines = []

    csv.register_dialect('cta', delimiter='\t', quoting=csv.QUOTE_MINIMAL, lineterminator='\n')
    output_rows = []
    with open('backup_output/chinese_generate_example_front_input.txt', encoding="utf-8-sig") as csvfile:
        lines = csvfile.readlines()
        for line in lines:
            if not line.rstrip():
                continue
            cells = line.split('\t')[:-1] #drop the last cell which is just \n
            raw_row = {key: val for key, val in zip(header, cells)}
            # we really just care about Front, Pinyin, Examples, Silhouette to generate what we want.
            row = {key: val for key, val in raw_row.items() if key in ['Front', 'Pinyin', 'Examples', 'Silhouette']}
            if not row['Examples'].rstrip():
                continue

            # We also need to strip out html from pinyin to get raw html.
            raw_pinyin = row['Pinyin']
            soup = BeautifulSoup(raw_pinyin[1:-1], "html.parser")  # omit first and last char, which are quotes.
            new_pinyin = soup.text.rstrip()  # we can just use the raw text directly.
            row['Pinyin'] = new_pinyin
            modified_silhouette = ' ' + row['Silhouette'] + ' '
            print('Original row:\n' + pprint.pformat(row['Examples']))
            print('')
            example_front = row['Examples'].replace(row['Front'].rstrip(), modified_silhouette)
            # print(f'Replace hanzi "{row["Front"]}"row: ' + pprint.pformat(example_front))
            # print('')
            example_front_2 = example_front.replace(new_pinyin.rstrip(), row['Silhouette'])
            # example_front_2 = re.compile(new_pinyin).sub(row['Silhouette'], example_front)
            print(f'Replace hanzi "{row["Front"]}" and pinyin "{row["Pinyin"]}" row:\n' + pprint.pformat(example_front_2))
            row['Examples-front'] = example_front_2
            row['Hanzi'] = row['Front']
            print('\n------\n')
            output_rows.append(row)

    with open('backup_output/generated_front_examples.csv', 'w', encoding="utf-8-sig") as csvfile_modified:
        print(f'Writing {len(output_rows)} rows...')
        for row in output_rows:
            line = '\t'.join([val for key, val in row.items() if key in ['Front', 'Examples', 'Examples-front', 'Hanzi']])
            csvfile_modified.write(f'{line}\n')
        print('Done!')

        # with open('backup_output/test_output_20_modified.csv', 'w', encoding="utf-8-sig") as csvfile_modified:
        #     for line in new_lines:
        #         csvfile_modified.write(f'{line}\n')

