import re
import os
import pprint
import time
import datetime

if __name__ == "__main__":
    output_csv_regex = rf'^test_output_(\d+)\.csv$'

    files_to_join = []

    min_start = int(input('Enter minimum start (inclusive): '))
    max_end = int(input('Enter max end (exclusive): '))
    with os.scandir('.') as entries:
        for entry in entries:
            match_result = re.match(output_csv_regex, entry.name)
            num = int(match_result.group(1)) if match_result else -9999
            if min_start <= num < max_end:
                print(f'Adding file: {entry.name}')
                files_to_join.append(entry.name)
            else:
                print(f'Skipping file: {entry.name}')


    print('Found these files: ')
    pprint.pprint(files_to_join)
    if input('Confirm (y/n)?') == 'y':
        st = datetime.datetime.fromtimestamp(time.time()).strftime('%Y_%m_%d__%H_%M_%S')
        total_lines = []
        for file_to_join in files_to_join:
            with open(file_to_join, 'r', encoding="utf-8-sig") as input_file: # to remove the #FEFF char
                total_lines.extend(input_file.readlines())

        with open(f'joined_output_{st}.csv', 'w', encoding="utf-8-sig") as output_file:  # encoding="utf-8-sig"

            output_file.writelines(total_lines)

        print(f'Done writing file: joined_output_{st}.csv!')

