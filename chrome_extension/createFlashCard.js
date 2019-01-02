'use strict';

var traditionalCedict;

chrome.runtime.onMessage.addListener(request => {
  if (request.type === 'flashCardCreator') {
    if (!traditionalCedict) { 
      loadCedict();
    }

    document.body.innerHTML += `
      <div id="cta-dialog" title="Create new Anki flashcard">
        <div class="inputs">
          <div class="sentence-container">
            Sentence: <input class="sentence" name="sentence" type="text"></input>
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
            <div>Pinyin: <input name="pinyin" type="text"></div>
            <div>Definition: <input name="definition" type="text"></div>
          </fieldset>
          <input class="lookup ui-button ui-widget ui-corner-all" type="submit" value="Lookup">
          <input class="create ui-button ui-widget ui-corner-all" type="submit" value="Create">
        </div>
          <div class="confirmation" style="display:none">
            <pre class="preview"></pre>
            <input class="back ui-button ui-widget ui-corner-all" type="submit" value="Back">
            <input class="confirm ui-button ui-widget ui-corner-all" type="submit" value="Confirm">
          </div>
        </div> 
      </div>
    `;

    // setup JQuery stuff.
    $( function() {
      let sentence = $("#cta-dialog input[name='sentence']")[0];       
      let wordInput = $("#cta-dialog input[name='word']")[0];
      let pinyinInput = $("#cta-dialog input[name='pinyin']")[0];
      let definitionInput = $("#cta-dialog input[name='definition']")[0];
      let preview = $("#cta-dialog .preview");
      let inputsContainer = $("#cta-dialog .inputs");
      let confirmationContainer = $("#cta-dialog .confirmation");

      chrome.storage.sync.get(['selectionInfo'], function(result) {
        console.log('Value of selectionInfo is ' + JSON.stringify(result));
        sentence.value = result.selectionInfo.selectionText;
      });
      $("#cta-dialog input[name=submit]").button();


      // '$' is probably not the best sentinel value, but it doesn't exist in Cedict. ¯\_(ツ)_/¯
      let sentinel = '$';

      // Setup LOOKUP
      $("#cta-dialog .ui-button.lookup").click(event=> {
        event.preventDefault();
        let suggestionsContainer = $("#cta-dialog select[name='suggestions']");
        suggestionsContainer.empty();
        // TODO(juliany): figure out how to do await here, but for now just assume we've already loaded the dictionary
        let matches = traditionalCedict.getMatch(wordInput.value);
        for (var i = 0; i < matches.length; i++) {
          let match = matches[i];
          let pinyin = addtones(match.pinyin);
          let definition = match.english.split('/').join('; ');
          suggestionsContainer.append($('<option>', {
            value: `${pinyin}${sentinel}${definition}`,
            // TODO(juliany): Figure out how to format this better.
            text: `${pinyin}: ${definition}`
          }));
          if (i ==0) {
            pinyinInput.value = pinyin;
            definitionInput.value = definition;
          }
        }
      });

      // Setup apply suggestion
      $("#cta-dialog select[name='suggestions']").change(function() {
        $("#cta-dialog select[name='suggestions'] option:selected").each(function() {
          let selection = $(this)[0].value.split(sentinel);
          pinyinInput.value = selection[0];
          definitionInput.value = selection[1];
        });
      });

      // Setup BACK
      $("#cta-dialog .ui-button.back").click(event => {
        event.preventDefault();
        inputsContainer.show();
        confirmationContainer.hide();
      });

      // Setup CREATE
      $("#cta-dialog .ui-button.create").click(event => {
        event.preventDefault();
        let addNoteRequestData = buildAddNoteRequestData(
          wordInput.value, 
          buildClozeSentence(wordInput.value, sentence.value), 
          addtones(pinyinInput.value), 
          definitionInput.value);
        preview.text(JSON.stringify(addNoteRequestData, null, 2));
        inputsContainer.hide();
        confirmationContainer.show();
      });

      // Setup Confirm
      $("#cta-dialog .ui-button.confirm").click(event => {
        event.preventDefault();
        let addNoteRequestData = preview.text();
        callAnkiConnect('POST', addNoteRequestData, 'json');
      });

      $("#cta-dialog").dialog();
    });
  }
});

function buildClozeSentence(word, sentence) {
  if (!sentence.includes(word)) {
    alert(`Sentence '${sentence}' does not contain '${word}'!`);
  }
  return sentence.replace(new RegExp(word, 'g'), `{{c1::${word}}}`);
}

function loadCedict() {
  chrome.storage.sync.get(['cedictUrl'], function(result) {
    console.log('extract cedictUrl: ' + JSON.stringify(result, null, 2));
    $.ajax({
      url: result.cedictUrl,
      type: 'GET',
      dataType: 'text',
      success: function(data) {
        traditionalCedict = loadTraditional(data);
        console.log(JSON.stringify(traditionalCedict.getMatch("判"), null, 2));
      },
      error: function(request, error) {
        alert('Could not load Cedict!\nRequest: '+JSON.stringify(request, null, 2)+'\nerror: ' + JSON.stringify(error, null, 2));
      }
    });
  });
}

function buildAddNoteRequestData(word, sentence, pinyin, meanings) {
  let filename = `cta2_${pinyin.replace(new RegExp(' ', 'g'), '_')}.mp3`
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
      alert('Data: '+JSON.stringify(data, null, 2));
    },
    error: function(request, error) {
      alert('Request: '+JSON.stringify(request, null, 2)+' error: ' + JSON.stringify(error, null, 2));
    }
  });
}