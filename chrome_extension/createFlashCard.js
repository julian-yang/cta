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
        
        <p> Basic dialog here </p>
        <p class="sentence"></p>
        <input class="submit ui-button ui-widget ui-corner-all" type="submit" value="Create">
      </div>
    `;

    // setup JQuery stuff.
    $( function() {
      chrome.storage.sync.get(['selectionInfo'], function(result) {
        console.log('Value of selectionInfo is ' + JSON.stringify(result));
        $("#cta-dialog .sentence").append(result.selectionInfo.selectionText);
      });
      $("#cta-dialog input[type=submit]").button();
      $("#cta-dialog .ui-button.submit").click(event => {
        event.preventDefault();
        // callAnkiConnect('GET', null, 'text');
        var addNoteRequestData = buildAddNoteRequestData("testWord", "testSentence {{c1::testWord}}", "testPinyin", "testMeanings");
        callAnkiConnect('POST', JSON.stringify(addNoteRequestData), 'json');
      });

      $("#cta-dialog").dialog();

      // Test fetching from other domains.
      // $.ajax({
      //   url: 'https://www.github.com',
      //   type: 'GET',
      //   dataType: 'html',
      //   success: function(data) {
      //     console.log(data);
      //   },
      //   error: function(request, error) {
      //     alert('Could not load Cedict!\nRequest: '+JSON.stringify(request)+'\nerror: ' + JSON.stringify(error));
      //   }
      // });
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
        console.log(JSON.stringify(traditionalCedict.getMatch("臺灣")));
      },
      error: function(request, error) {
        alert('Could not load Cedict!\nRequest: '+JSON.stringify(request)+'\nerror: ' + JSON.stringify(error));
      }
    });
  });
}

function buildAddNoteRequestData(word, sentence, pinyin, meanings) {
  return {
    action: "addNotes",
    version: 6,
    params: {
      notes: [
        {
          deckName: "test_deck",
          modelName: "CTA-vocab-2",
          fields: {
            word: "testWord",
            sentence: "testSentence {{c1::testWord}}",
            pinyin: "testPinyin",
            meanings: "testMeanings"
          },
          tags: ["testNote"],
        }
      ]
    }
  };
}

function callAnkiConnect(requestType, data, dataType) {
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