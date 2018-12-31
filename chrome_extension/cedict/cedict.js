'use strict';
// Adapted from https://github.com/takumif/cedict-lookup
var Entry = (function () {
    function Entry(trad, simpl, pinyin, english) {
        this.traditional = trad;
        this.simplified = simpl;
        this.pinyin = pinyin;
        this.english = english;
    }
    return Entry;
}());

var CedictParser = (function () {
    function CedictParser() {
    }
    /**
     * Parses a CEDICT text file into a list of entries
     */
    CedictParser.parse = function (file) {
        chrome.extension.getURL(file);
        var text = fs_1.readFileSync(file, "utf-8");
        return CedictParser.parseCedictText(text);
    };
    CedictParser.parseCedictText = function (text) {
        var lines = text.split("\n");
        var entries = [];
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i];
            // ignore non-entry lines
            if (line.length === 0 || line[0] === "#") {
                continue;
            }
            entries.push(CedictParser.parseCedictLine(line));
        }
        return entries;
    };
    CedictParser.parseCedictLine = function (line) {
        // Entries have this format:
        // TRADITIONAL SIMPLIFIED [PINYIN] /ENGLISH 1/ENGLISH 2/
        var firstSpace = line.indexOf(" ");
        var secondSpace = line.indexOf(" ", firstSpace + 1);
        var leftBracket = line.indexOf("[");
        var rightBracket = line.indexOf("]");
        var firstSlash = line.indexOf("/");
        var lastNonSlashChar = line.length - 2;
        var traditional = line.substr(0, firstSpace);
        var simplified = line.substr(firstSpace + 1, secondSpace - firstSpace - 1);
        var pinyin = line.substr(leftBracket + 1, rightBracket - leftBracket - 1);
        var english = line.substr(firstSlash + 1, lastNonSlashChar - firstSlash - 1);
        return new Entry(traditional, simplified, pinyin, english);
    };
    return CedictParser;
}());

/**
 * An implementation of Cedict using the prefix tree data structure.
 * Each node (except for the root) contains a character, and contains a list of
 * entries formed by the characters in the path from the root to the node.
 * It uses the traditional attribute as the lookup key into the tree.
 */
var Cedict = (function () {
    function Cedict(cedictText, trad) {
        var entries = CedictParser.parseCedictText(cedictText);
        this.traditional = trad;
        this.root = new CedictNode("");
        this.populateTree(entries);
    }
    Cedict.prototype.getMatch = function (query) {
        var node = this.getNodeForWord(query);
        return node != null ? node.entries : [];
    };
    Cedict.prototype.getEntriesStartingWith = function (query) {
        var node = this.getNodeForWord(query);
        return node != null ? this.gatherEntriesUnderNode(node) : [];
    };
    /**
     * E.g. for a query of "我們是" this will return entries for 我 and 我們
     */
    Cedict.prototype.getPrefixEntries = function (query) {
        var node = this.root;
        var entries = [];
        for (var i = 0; i < query.length; i++) {
            var nextChar = query[i];
            if (node.suffixes[nextChar] === undefined) {
                break;
            }
            node = node.suffixes[nextChar];
            Array.prototype.push.apply(entries, node.entries);
        }
        return entries;
    };
    Cedict.prototype.populateTree = function (entries) {
        for (var i = 0; i < entries.length; i++) {
            this.insertEntry(entries[i]);
        }
    };
    Cedict.prototype.insertEntry = function (entry) {
        var node = this.root;
        var characters = this.traditional ? entry.traditional : entry.simplified;
        while (node.word != characters) {
            var nextChar = characters[node.word.length];
            if (node.suffixes[nextChar] === undefined) {
                // never seen this character sequence before, so make a node for it
                node.suffixes[nextChar] = new CedictNode(node.word + nextChar);
            }
            node = node.suffixes[nextChar];
        }
        node.entries.push(entry);
    };
    Cedict.prototype.gatherEntriesUnderNode = function (node) {
        if (node == null) {
            return [];
        }
        var entries = [];
        Array.prototype.push.apply(entries, node.entries);
        // get the entries from all the child nodes
        for (var suffix in node.suffixes) {
            Array.prototype.push.apply(entries, this.gatherEntriesUnderNode(node.suffixes[suffix]));
        }
        return entries;
    };
    /**
     * Returns null if the node is not found
     */
    Cedict.prototype.getNodeForWord = function (word) {
        var node = this.root;
        for (var i = 0; i < word.length; i++) {
            var nextChar = word[i];
            if (node.suffixes[nextChar] === undefined) {
                return null;
            }
            node = node.suffixes[nextChar];
        }
        return node;
    };
    return Cedict;
}());
var CedictNode = (function () {
    function CedictNode(w) {
        this.word = w;
        this.entries = [];
        this.suffixes = {};
    }
    return CedictNode;
}());
function loadTraditional(cedictText) {
    return new Cedict(cedictText, true);
}
// export {loadTraditional};
function loadSimplified(cedictText) {
    return new Cedict(cedictText, false);
}
