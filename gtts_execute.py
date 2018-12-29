from gtts import gTTS
import csv
import sys
import codecs
import os
import argparse 
import time

parser = argparse.ArgumentParser(
  description="""Reads a CSV file and uses gTTS to download mp3 file of Chinese words.
   Column named 'word' for the chinese word, Column named 'audio' for the audio file name.""")
parser.add_argument('-c', '--csvfile', dest='filename')

# sys.stdout = codecs.getwriter('utf8')(sys.stdout)
# raw_input()
args = parser.parse_args()
print('Versioning:\n{}'.format(sys.version))
print('Reading from {}'.format(args.filename))
dir_path = os.path.dirname(os.path.realpath(args.filename))

csv.register_dialect('cta', delimiter='\t', quoting=csv.QUOTE_NONE, lineterminator='\n')
try:
  with open(args.filename, encoding="utf-8-sig") as csvfile:  # encoding="utf-8-sig"
    csvreader = csv.DictReader(csvfile, dialect='cta')
    print ('Found the following column names: {}'.format(csvreader.fieldnames))
    for row in csvreader:
      print(row['word'], row['audio_name'])
      audioFilePath =  os.path.join(dir_path, row['audio_name'])
      tts = gTTS(row['word'], lang='zh-tw')
      print('\tSaving "{}" now...'.format(audioFilePath))
      tts.save(audioFilePath)
except Exception as e:
  print (e)
  print("Unexpected error:", sys.exc_info()[0])
  #time.sleep(10)
