'use strict';

// import {Cedict} from 'cedict';
// var ceDict = require():w
var traditionalCedict;

chrome.runtime.onMessage.addListener(request => {
  if (request.type === 'flashCardCreator') {
    if (!traditionalCedict) { 
      loadCedict();
    }

    document.body.innerHTML += `
      <div id="cta-dialog" title="Create new Anki flashcard">
        <div class="sentence-container">
          Sentence: <div class="sentence"></div>
        </div>
        <div class="word-container">
          Word: <input class="word" name="word" type="text">
        </div>
        <fieldset>
          <legend>Pinyin/Definition:</legend>
          <div class="suggestions-container">
            Suggestions: 
            <select name="suggestions">
            </select>
          </div>
          Pinyin: <input name="pinyin" type="text">
          Definition: <input name="definition" type="text">
        </fieldset>
        <input class="lookup ui-button ui-widget ui-corner-all" type="submit" value="Lookup">
        <input class="submit ui-button ui-widget ui-corner-all" type="submit" value="Create">
      </div>
    `;

    // setup JQuery stuff.
    $( function() {
      chrome.storage.sync.get(['selectionInfo'], function(result) {
        console.log('Value of selectionInfo is ' + JSON.stringify(result));
        $("#cta-dialog .sentence").append(result.selectionInfo.selectionText);
      });
      $("#cta-dialog input[name=submit]").button();

      let pinyinInput = $("#cta-dialog input[name='pinyin']")[0];
      let definitionInput = $("#cta-dialog input[name='definition']")[0];
      let sentinel = '$';
      // Setup LOOKUP
      $("#cta-dialog .ui-button.lookup").click(event=> {
        event.preventDefault();
        let word = $("#cta-dialog input[name='word']")[0].value;
        // figure out how to do await here, but for now just assume we've already loaded the dictionary
        let matches = traditionalCedict.getMatch(word);
        for (var i = 0; i < matches.length; i++) {
          let match = matches[i];
          let pinyin = match.pinyin;
          let definition = match.english.split('/').join('; ');
          let suggestion = `${pinyin}: ${definition}`;
          $("#cta-dialog select[name='suggestions']").append($('<option>', {
            value: `${pinyin}${sentinel}${definition}`,
            text: suggestion
          }));
          if (i ==0) {
            pinyinInput.value = pinyin;
            definitionInput.value = definition;
          }
        }
        // $("#cta-dialog .suggestions-container").css('visibility', 'visible');
        // for definitions, need to split '/' and replace with '; '

        // (".Deposit").css('visibility','visible');
      });

      // Setup apply suggestion
      $("#cta-dialog select[name='suggestions']").change(function() {

        $("#cta-dialog select[name='suggestions'] option:selected").each(function() {
          let selection = $(this)[0].value.split(sentinel);
          pinyinInput.value = selection[0];
          definitionInput.value = selection[1];
        });
      });

      // Setup CREATE
      $("#cta-dialog .ui-button.submit").click(event => {
        event.preventDefault();
        // callAnkiConnect('GET', null, 'text');
        var addNoteRequestData = buildAddNoteRequestData("新年快樂", "testSentence {{c1::testWord}}", "testPinyin", "testMeanings");
        callAnkiConnect('POST', JSON.stringify(addNoteRequestData), 'json');
      });

      $("#cta-dialog").dialog();
    });
  }
});

function loadCedict() {
  chrome.storage.sync.get(['cedictUrl'], function(result) {
    console.log('extract cedictUrl: ' + JSON.stringify(result));
    $.ajax({
      url: result.cedictUrl,
      type: 'GET',
      dataType: 'text',
      success: function(data) {
        traditionalCedict = loadTraditional(data);
        console.log(JSON.stringify(traditionalCedict.getMatch("判")));
      },
      error: function(request, error) {
        alert('Could not load Cedict!\nRequest: '+JSON.stringify(request)+'\nerror: ' + JSON.stringify(error));
      }
    });
  });
}

function buildAddNoteRequestData(word, sentence, pinyin, meanings) {
  let filename = `cta2_${pinyin}.mp3`
  let url = `http://localhost:5000/gtts?phrase=${word}&filename=${filename}&lang=zh-tw`
  return {
    action: "addNotes",
    version: 6,
    params: {
      notes: [
        {
          deckName: "test_deck",
          modelName: "CTA-vocab-2",
          fields: {
            word: word,
            sentence: sentence,
            pinyin: pinyin,
            meanings: meanings
          },
          tags: ["testNote"],
          audio: {
            url: url,
            filename: filename,
            // fields must not be empty otherwise AnkiConnect will skip processing the audio part.
            // All fields listed here will have "[sound:<filename>]" appended to it in the note.
            fields: ["audio"]
          }
        }
      ]
    }
  };
}

function callAnkiConnect(requestType, data, dataType) {
  console.log('data:\n' + data);
  $.ajax({
    url: 'http://localhost:8765',
    type: requestType,
    data: data,
    dataType: dataType,
    success: function(data) {
      alert('Data: '+JSON.stringify(data));
    },
    error: function(request, error) {
      
      alert('Request: '+JSON.stringify(request)+' error: ' + JSON.stringify(error));
    }
  });
}