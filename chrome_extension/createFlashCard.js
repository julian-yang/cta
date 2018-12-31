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
      </div>
    `;

    $( function() {
      chrome.storage.sync.get(['selectionInfo'], function(result) {
        console.log('Value of selectionInfo is ' + JSON.stringify(result));
        $("#cta-dialog .sentence").append(result.selectionInfo.selectionText);
      })

      $("#cta-dialog").dialog();
    });
  }
});