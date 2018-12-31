chrome.runtime.onMessage.addListener(request => {
  if (request.type === 'flashCardCreator') {
    // document.body.innerHTML +=`<dialog style="height:40%"> <iframe id="flashCardCreator"style="height:100%"></iframe>
    //         <div style="position:absolute; top:0px; left:5px;">  
    //             <button>x</button>
    //         </div>
    //         </dialog>`;
    // const dialog = document.querySelector("dialog");
    // dialog.showModal();
    // const iframe = document.getElementById("flashCardCreator");
    // iframe.srcdoc = "<p>Hello world!</p> <script src=\"" + chrome.extension.getURL("loadAngularDart.js") +  "\"></script>";
    // // iframe.src = chrome.extension.getURL("index.html");
    // iframe.frameBorder = 0;
    // dialog.querySelector("button").addEventListener("click", () => {
    //     dialog.close();
    // });
    document.body.innerHTML += `
      <div id="cta-dialog" title="Create new Anki flashcard">
        <p> Basic dialog here </p>
        <p class="sentence"></p>
        <input class="submit ui-button ui-widget ui-corner-all" type="submit" value="Create">
      </div>
    `;

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
    });
  }
});

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