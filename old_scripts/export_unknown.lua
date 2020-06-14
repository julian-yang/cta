local cta = require 'cta'
local lfs = require 'lfs'
local function sentenceMostlyKnown( sentence, known, seen, threshold )
    if threshold == nil then
        threshold = 0.70
    end
    local total = 0
    local totalKnown = 0

    local unknown = {}
    for word in sentence:words() do
        if known:contains( word ) then
            totalKnown = totalKnown + 1
        else
            if seen[word] == nil then
                table.insert( unknown, word )
                seen[word] = true
            end
        end
        total = total + 1
    end

    local ratio = totalKnown / total
    return ratio >= threshold and ratio < 1, unknown
end

local function stripFileName(filename) 
    local index = string.find(filename, "/[^/]*$")
    local extension = string.find(filename, "%.[^%.]*$")
    -- lua substring is inclusive for start and end
    local strippedFileName = string.sub(filename, index + 1, extension - 1)
    return strippedFileName
end

local function stripFileExtension(filename)
    local extension = string.find(filename, "%.[^%.]*$")
    -- lua substring is inclusive for start and end
    local strippedFileExtension = string.sub(filename, 1, extension - 1)
    return strippedFileExtension
end

local function extractIndividualDefinitions(definitionStr)
    local definitions = {}
    for definition in definitionStr:gmatch('%d[^;]+') do
        table.insert(definitions, definition)
    end
    return definitions
end

local function extractMeanings(definitionList)
    local extractedDefinitions = {}
    for i, definition in ipairs(definitionList) do
        --   cta.write(string.format('\t%s\t%s', definition.pinyin, definition.english))
        local englishMeanings = extractIndividualDefinitions(definition.english)
        local concatEnglishMeanings = table.concat(englishMeanings, '<br>')
        table.insert(extractedDefinitions, string.format('<tr><td>%s</td><td>%s</td></tr>', definition.pinyin, concatEnglishMeanings))
    end
    local meanings = string.format('<table>%s</table>', table.concat(extractedDefinitions, ''))
    return meanings
end


function os.capture(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return s
end

local function findSentencesInDocument( filename, known, seen )
    local document = cta.Document( filename )
    local numLines = 0
    local maxDefinitions = 0
    local strippedFileName = stripFileName(filename)
    local rows = {}
    local definitionColumnNames = ''
    for line in document:lines() do
        for sentence in line:sentences() do
            local mostlyKnown, unknown = sentenceMostlyKnown( sentence, known, seen )
            if mostlyKnown and #unknown > 0 then
              for i, unknownWord in ipairs(unknown) do
                local definitions = cta.dictionary():definitions(unknownWord)
                local clozeSentence = sentence:clozeText( unknownWord, '{{c%n::%w}}' )
                local audioName = string.format('%s__%s.mp3', strippedFileName, definitions[1].pinyinNumbers)
                local audio = string.format('[sound:%s]', audioName)
                local meanings = extractMeanings(definitions)
                local row = string.format('%s\t%s\t%s\t%s\t%s', unknownWord, clozeSentence, audio, meanings, audioName)
                table.insert(rows, row)
                -- cta.write('\n')
              end
            end
        end
        numLines = numLines + 1
    end
    -- print (string.format('found %d lines, %d unknown words, max definitions: %d', numLines, #rows, maxDefinitions))
    -- print the title
    -- print(lfs.currentdir())
    print(string.format("Processed %d lines and extracted %d words", numLines, #rows))
    local csvfile = 'word\tsentence\taudio\tmeanings\taudio_name\n' .. table.concat(rows, '\n')
    local export_filename = string.format('%s_unknown_cta_anki.csv', stripFileExtension(filename))
    -- print (export_filename)
    -- local hardcode = '"C:\\Users\\yang_\\Documents\\我的住院日記一\\generated.csv"'
    local export_file, err = io.open(export_filename, 'w')
    if (export_file == nil) then
        print("Couldn't open file: " ..err)
    else
        export_file:write(csvfile)
        export_file:close()
        print('Finished writing file:\n\t' .. export_filename)
    end
    local pythonCmd = string.format('/usr/local/bin/python3 /Users/julianyang/Projects/cta/gtts_execute.py -c "%s"', export_filename)
    print(string.format('python script command:\n%s', pythonCmd))
    print('Python script output:\n---------------------')
    local output = os.capture(pythonCmd)
    print(output)
    print('End python script output')
end

-- local dictionary = cta.dictionary()
local known = cta.knownWords()
local seen = {}
local files = cta.askUserForFileToOpen()
if files ~= nil then
    -- cta.write(string.format('opening file: %s\n', files))
    -- for i, filename in  ipairs(files) do
        -- print('writing for file ', filename)
    findSentencesInDocument( files, known, seen )
    -- end
else
    print('No requested to be open found!')
end 

