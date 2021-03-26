from flask import Flask, request, send_file
from gtts import gTTS
import io
import ssl

app = Flask(__name__)

@app.route("/")
def index():
  return """ 
    <h1>Simple gTTS server for Anki chinese translation.</h1>
    <p>You can make a sample request like: <br/>
      <a href="localhost:5000/gtts?phrase=臺灣&filename=taiwan.mp3&lang=zh-tw">
        localhost:5000/gtts?phrase=臺灣&filename=taiwan.mp3&lang=zh-tw
      </a>
    </p>
    <p>The default for filename is '<b>gtts.mp3</b>';</p>
    <p>The default for lang is '<b>zh-tw</b>'</p>
  """

@app.route("/ping")
def hello():
  return "Hello World!"

@app.route("/gtts")
def fetchAudio():
  phrase = request.args.get('phrase', default='')
  if not phrase:
    return 'Missing "phrase" query parameter. Ex: localhost:5000?phrase=臺灣&filename=taiwan.mp3'

  filename = request.args.get('filename', default='gtts.mp3')
  if not filename.endswith('.mp3'):
    filename += '.mp3'

  language = request.args.get('lang', default='zh-tw')

  tts = gTTS(phrase, lang=language)
  temp = io.BytesIO()
  tts.write_to_fp(temp)
  temp.seek(0)
  return send_file(temp, attachment_filename=filename, as_attachment=True)

if __name__ == "__main__":
  app.run()