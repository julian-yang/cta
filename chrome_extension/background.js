// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

'use strict';

chrome.storage.sync.set({cedictUrl: chrome.extension.getURL('cedict/cedict_ts.u8')}, function() {
  console.log('set cedictUrl');
});

chrome.runtime.onInstalled.addListener(function() {
  chrome.storage.sync.set({color: '#3aa757'}, function() {
    console.log("The color is green.");
  });
});

function onClick(info, tab) {
  console.log("item " + info.menuItemId + " was clicked");
  console.log("info: " + JSON.stringify(info));
  console.log("tab: " + JSON.stringify(tab));
  chrome.storage.sync.set({selectionInfo: info}, function() {
    console.log("Set selection info");
  });
}

var parent = chrome.contextMenus.create({
  "id": "createChineseAnki",
  "title": "Create Chinese Anki flashcard using \"%s\"",
  "contexts": ["selection"],
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  console.log(info);
  if (info.menuItemId == "createChineseAnki") {
    onClick(info, tab);
  }
  chrome.tabs.query({active: true, currentWindow: true}, tabs => {
      chrome.tabs.sendMessage(tabs[0].id, {type: 'flashCardCreator'});
  });
});
