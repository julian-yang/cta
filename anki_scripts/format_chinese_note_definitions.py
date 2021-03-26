import tempfile
from jinja2 import Template
import subprocess
import csv
import sys
import re
import os
import argparse
import string
import consts
import pprint
import nltk
import time

parser = argparse.ArgumentParser(
    description="""Reads a CSV file and uses gTTS to download mp3 file of Chinese words.
   Column named 'word' for the chinese word, Column named 'audio' for the audio file name.""")
parser.add_argument('-c', '--csvfile', dest='filename')

header = ['Front', 'Color', 'Pinyin', 'Bopomofo', 'Ruby', 'Ruby (Bopomofo)', 'English', 'Examples', 'Classifier',
          'Simplified', 'Traditional', 'Also Written', 'Frequency', 'Silhouette']

PINYIN_VOWELS = 'ɑ̄āĀáɑ́ǎɑ̌ÁǍàɑ̀ÀēĒéÉěĚèÈīĪíÍǐǏìÌōŌóÓǒǑòÒūŪúÚǔǓùÙǖǕǘǗǚǙǜǛ'
contains_pinyin_regex = f'{"|".join(list(PINYIN_VOWELS))}'
chinese_punc_regex = rf'！？｡。＂＃＄％＆＇（）＊＋，－／：；＜＝＞＠［＼］＾＿｀｛｜｝～｟｠｢｣､、〃》「」『』【】〔〕〖〗〘〙〚〛〜〝〞〟〰〾〿–—‘’‛“”„‟…‧﹏.,'


chinese_punc_regex_with_class = rf'[！？｡。＂＃＄％＆＇（）＊＋，－／：；＜＝＞＠［＼］＾＿｀｛｜｝～｟｠｢｣､、〃》「」『』【】〔〕〖〗〘〙〚〛〜〝〞〟〰〾〿–—‘’‛“”„‟…‧﹏.,]'
'，､、？！｡'
special_punc = '。'
contains_han_zi_regex = rf'[\u4e00-\u9fff]+'
is_han_zi_regex = rf'[\u4e00-\u9fff]'

TRANSCRIPT_REGEX_TEMPLATE = (
    "(({initials})({finals})[{tones}]?|([']?{standalones})[{tones}]?)"
)

HEADER = '\033[95m'
OKBLUE = '\033[94m'
OKGREEN = '\033[92m'
WARNING = '\033[93m'
FAIL = '\033[91m'
ENDC = '\033[0m'
BOLD = '\033[1m'
UNDERLINE = '\033[4m'

true_word = rf"(\s*[{string.ascii_lowercase + string.ascii_uppercase}\d;\(\)\.\-\"\/’'\?]+\s*)+"

banned_words = {'遷'}

def move_leftover(leftover, match_end):
    if len(leftover) == match_end:
        return ''
    else:
        return leftover[match_end:]


def should_parse_row(english):
    return re.search(contains_han_zi_regex, english)

nltk.download('words')
dictionary = set(nltk.corpus.words.words())
whitelist_pinyin = {'ne'}
english_word_supplement = {'disengaging'}
maybe_english = {'co'}
sentinel_divider = '-----------DIVIDER-----------------'
example_divider = '----------EXAMPLE----------------'

table_template = Template('''<table style="border-collapse: collapse; width: 100%;" border="1">
<tbody>
{% for example in examples -%}
<tr>
<td style="width: 33.3333%;">{{example.chinese}}</td>
<td style="width: 33.3333%;">{{example.english}}</td>
<td style="width: 33.3333%;">{{example.pinyin}}</td>
</tr>
{% endfor -%}
</tbody>
</table>
''')

tempfile_template = Template('''({{cur_number}}/{{total}}) {{cur_word}} -- Original:
{{original_english}}


{{sentinel_divider}}
{% for extracted_definition in extracted_definitions -%}
{{extracted_definition}}
{% endfor %}

{% for example in examples -%}
{{example_divider}}

{{example.chinese}}

{{example.pinyin}}

{{example.english}}

{% endfor %}
{{example_divider}}
''')
row_template = string.Template('<td style="width: 33.3333%;">$text</td>')
def transformToHtmlTable(examples):
    print(f'Examples: {len(examples)}')
    return table_template.render(examples=examples, test='this is a test')




def parse_row(english):
    result = {}
    leftover = english
    definition, leftover = find_english_definition_phrase(leftover)
    result['definition'] = [definition]
    print(f'definition:\n\t{definition}')

    examples = []
    # parse out first example:
    snapshot_leftover = leftover
    while leftover:
        print('Leftover: ' + leftover)
        chinese_example = ''

        while re.match(is_han_zi_regex, leftover[0]) or re.match(chinese_punc_regex_with_class, leftover[0]) or re.match(r'\s', leftover[0]):
            chinese_example += leftover[0]
            leftover = leftover[1:]


        print(chinese_example)
        # find pinyin phrase
        leftover, pinyin_extraction = extract_pinyin(leftover)

        print(pinyin_extraction)

        leftover, english_translation_extraction = extract_phrase(leftover, true_word)
        examples.append(
            {'chinese': chinese_example, 'pinyin': pinyin_extraction, 'english': english_translation_extraction})

        print(english_translation_extraction)
        if snapshot_leftover == leftover:
            response = input('Seems like we might be stuck.. break?')
            if response == 'y':
               return None
        else:
            snapshot_leftover = leftover



    # print(f'extraction:\n')
    # pprint.pprint(examples)
    print(f'leftover: {leftover}')
    # while leftover:

    #pprint.pprint(result)
    result['examples'] = examples
    return result

def extract_phrase(leftover, phrase_regex):
    phrase_extraction = ''
    phrase_match = re.match(phrase_regex, leftover, flags=re.IGNORECASE)
    while phrase_match:
        phrase_extraction += phrase_match.group(0)
        leftover = move_leftover(leftover, phrase_match.end())
        space_match = re.match(f'[\s|\.,,]+', leftover)
        if space_match:
            phrase_extraction += space_match.group(0)
            leftover = move_leftover(leftover, space_match.end())
        phrase_match = re.match(phrase_regex, leftover)
    return leftover, phrase_extraction


def extract_pinyin(leftover):
    pinyin_extraction = ''
    pinyin_match = re.match(consts.PINYIN_REGEX, leftover, flags=re.IGNORECASE)

    while pinyin_match is not None:
        pinyin_match_result = pinyin_match.group(0)
        # english_match = re.match(english_regex, leftover)
        # english_match_result = english_match.group(0).rstrip()
        # if (pinyin_match_result in dictionary and pinyin_match_result not in whitelist_pinyin) or pinyin_match_result in maybe_english:
        #     # try to extract the whole word first, since pinyin extraction only extracts the first bit.
        #     print(f'{pinyin_extraction}{WARNING}{english_match_result}{ENDC}{leftover[len(english_match_result):]}')
        #     response = input(
        #         f'Is "{english_match_result}" an English word (y/n)?  english_match: "{english_match_result}" pinyin match: "{pinyin_match.group(0)}",  leftover: {leftover}\n')
        #     if response == 'y':
        #         english_word_supplement.add(english_match_result)
        #         print('skipping, and breaking out of pinyin extraction...')
        #         break
            # if english_match:
            #     english_match_result = english_match.group(0).rstrip()
            #     print(f'English match result: {english_match_result}  |   cur_pinyin_extraction: {pinyin_extraction}')
            #     if english_match_result in dictionary or english_match_result in english_word_supplement:
            #         print(f'......"{english_match_result}" matched result in dictionary or word supplement.  Skipping....  english_match: "{english_match_result}", pinyin_match: "{pinyin_match.group(0)}",  leftover: {leftover}')
            #         break
            #     else:
            #         response = input(f'Possible english word (y/n)?  english_match: "{english_match_result}" pinyin match: "{pinyin_match.group(0)}",  leftover: {leftover}\n')
            #         if response == 'y':
            #             english_word_supplement.add(english_match_result)
            #             print('skipping, and breaking out of pinyin extraction...')
            #             break

        pinyin_extraction += pinyin_match.group(0)
        leftover = move_leftover(leftover, pinyin_match.end())
        space_match = re.match(rf'[\s|\.,{chinese_punc_regex}]+', leftover)
        if space_match:
            pinyin_extraction += space_match.group(0)
            leftover = move_leftover(leftover, space_match.end())
        pinyin_match = re.match(consts.PINYIN_REGEX, leftover)
    return leftover, pinyin_extraction


def find_english_definition_phrase(leftover):
    definition = ''
    unclosed_left_paren = 0
    # parse out definition:
    while leftover and not re.match(is_han_zi_regex, leftover[0]) or unclosed_left_paren > 0:
        definition += (leftover[0])
        if leftover[0] == '(':
            unclosed_left_paren += 1
        elif leftover[0] == ')':
            unclosed_left_paren -= 1
        leftover = move_leftover(leftover, 1)
    return definition, leftover

# input: array of lines from the tmp file
def parse_output(output):
    # skip until we find sentinel
    seen_sentinel = False
    finished_definition = False
    definition_lines = []
    examples = []
    current_example = []
    for line in output:
        if line.rstrip() == '':
            continue
        if not seen_sentinel:
            seen_sentinel = line.rstrip() == sentinel_divider
            continue
        # continue until running into Example sentinel
        if not finished_definition:
            if line.rstrip() == example_divider:
                finished_definition = True
                continue
            else:
                definition_lines.append(line.rstrip())
        # we are looking for examples then.
        else:
            if line.rstrip() == example_divider:
                if len(current_example) != 3:
                    print('Found abnormal examples:')
                    pprint.pprint(current_example)
                    input('Press any button to continue.')
                examples.append({'chinese': current_example[0], 'pinyin': current_example[1], 'english': current_example[2]})
                current_example = []
            else:
                current_example.append(line.rstrip())
    return definition_lines, examples


def write_to_output(converted_rows, start_num):
    with open(f'test_output_{start_num}.csv', 'w', encoding="utf-8-sig", newline='') as output_file:
        for row in converted_rows:
            output_file.write('\t'.join(row))
            output_file.write('\n')
        # outputWriter = csv.writer(output_file, dialect='cta', escapechar='\\')
        # for row in converted_rows:
        #     outputWriter.writerow(row)

        # print('\tSaving "{}" now...'.format(audioFilePath))


if __name__ == "__main__":
    # args = parser.parse_args()
    # print('Versioning:\n{}'.format(sys.version))
    # print('Reading from {}'.format(args.filename))
    dir_path = os.path.dirname(os.path.realpath('Chinese.txt'))

    csv.register_dialect('cta', delimiter='\t', quoting=csv.QUOTE_NONE, lineterminator='\n')
    converted_rows = []
    try:
        with open('Chinese.txt', encoding="utf-8-sig") as csvfile:  # encoding="utf-8-sig"
            csvreader = csv.DictReader(csvfile, dialect='cta', fieldnames=header)
            print('Found the following column names: {}'.format(csvreader.fieldnames))
            count = 0
            parsing_required_rows = []
            for row in csvreader:
                original_english = row['English']
                should_parse = should_parse_row(original_english)
                if not should_parse:
                    continue
                else:
                    parsing_required_rows.append(row)

            print(f'Found {len(parsing_required_rows)} rows that need parsing!')
            count = 129
            for row in parsing_required_rows[count:]:
                # print(f'Should parse: {should_parse is not None}\n\t{original_english}')
                if row['Front'] in banned_words:
                    continue
                try:
                    original_english = row['English']
                    parsed = parse_row(original_english)
                    if parsed is None:
                        print(rf'Bad formatting? Front: {row["Front"]} Original english: ' + original_english)
                        continue
                    # with tempfile.NamedTemporaryFile(suffix='parsetemp') as temp:
                    extracted_definitions = '\n'.join(parsed['definition'])
                    with open('tmp.txt', encoding="utf-8-sig", mode='w') as tmp:  # encoding="utf-8-sig"
                        tempfile_template_vars = {
                            'cur_number': count,
                            'total': len(parsing_required_rows),
                            'cur_word': row["Front"],
                            'original_english': original_english,
                            'sentinel_divider': sentinel_divider,
                            'extracted_definitions': parsed['definition'],
                            'example_divider': example_divider,
                            'examples': parsed['examples']
                        }
                        tempfile_contents = tempfile_template.render(tempfile_template_vars)
                        tmp.write(tempfile_contents)
                    # open the editor.
                    handler = subprocess.Popen(['mvim', tmp.name])
                    time.sleep(2)
                    while os.path.exists(f'.{tmp.name}.swp'):
                        time.sleep(1)
                    temp_file = open(tmp.name, 'r').readlines()
                    finished_english_definition, examples = parse_output(temp_file)
                    finished_english_definition = '<br>'.join(finished_english_definition)
                    finished_examples = transformToHtmlTable(examples)
                    print(finished_examples)
                    finished_examples = finished_examples.replace('\n', '')
                    converted_rows.append([row['Front'], finished_english_definition, finished_examples, row['Front']])
                    if len(converted_rows) == 10:
                        print(f'Writing to output! count={count}')
                        write_to_output(converted_rows, count)
                        converted_rows = []
                    count += 1



                    print('done looking at edited version!')
                    # reformat the edited text.
                except Exception as bleghh:
                    print(bleghh)
                print('\n------------------ \n')

                # count = count + 1
                # if count >= 1:
                #     break
            # end for
        write_to_output(converted_rows, count)
    except Exception as e:
        print (e)
        print("Unexpected error:", sys.exc_info()[0])
    #time.sleep(10)
