local cta = require 'cta'
-- local dir = cta.askUserForDirectory()
-- print (dir)
-- local cmd = string.format('C:\\Python27\\Scripts\\gtts-cli.exe -l zh-tw 利息 --output "%s\\li_xi.mp3"', dir)
-- print (cmd)
-- print(os.execute(cmd))


function os.capture(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return s
end
  -- local output = os.execute('python C:\\Users\\yang_\\Documents\\gtts_execute.py -c C:\\Users\\yang_\\Documents\\test.csv')
-- local output = os.capture('/usr/local/bingtts-cli ', raw)
local output = os.capture('/usr/local/bin/python3 /Users/julianyang/Projects/cta/gtts_execute.py -c ~/Projects/cta/我的住院日記一/test_input_unknown_cta_anki.csv', true)
--local output = os.capture('/usr/local/bin/python3 /Users/julianyang/Projects/cta/test.py')
-- local output = os.execute('python C:\\Users\\yang_\\Documents\\gtts_execute.py -c C:\\Users\\yang_\\Documents\\test.csv')
-- print (os.execute('python C:\\Users\\yang_\\Documents\\gtts_execute.python'))
-- local output = os.capture([["C:\Python27\Scripts\gtts-cli.exe"]], false)
print (output)
-- print(os.execute([["C:\\Python27\\Scripts\\gtts-cli.exe 2>&1 C:\\Users\\yang_\\test.txt"]]))
-- C:\Python27\Scripts\gtts-cli.exe -l zh-tw 利息 --output "C:\Users\yang_\Documents\我的住院日記一\li_xi.mp3"

-- C:\Program Files\7-Zip

-- C:\Python27\Scripts
