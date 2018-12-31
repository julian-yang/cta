// chrome.runtime.onInstalled.addListener(function() {
    chrome.storage.sync.get(['selectionInfo'], function(result) {
        console.log('Value of selectionInfo is ' + result);
    })
// })
