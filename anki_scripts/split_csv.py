import re

contains_han_zi_regex = rf'[\u4e00-\u9fff]+'
if __name__ == "__main__":
    new_lines = []
    with open('test_output_20.csv', encoding="utf-8-sig") as csvfile:  # encoding="utf-8-sig"
        # should be entire file
        input = csvfile.readlines()[0]
        leftover = input
        regex_search = r'([\u4e00-\u9fff]+)\t.*?</table>\t\1'
        match = re.search(r'([\u4e00-\u9fff]+)\t.*?</table>\t\1', leftover)

        new_lines = []
        while match:
            new_lines.append(match.group(0))
            if match.end() == len(leftover):
                leftover = ''
                break
            else:
                leftover = leftover[match.end():]
                match = re.search(r'([\u4e00-\u9fff]+)\t.*?</table>\t\1', leftover)

        with open('backup_output/test_output_20_modified.csv', 'w', encoding="utf-8-sig") as csvfile_modified:
            for line in new_lines:
                csvfile_modified.write(f'{line}\n')

