import easygui
import os
import lib.article_pb2 as article_pb2
import ntpath



def customInsert(db):
    cwd = os.path.dirname(os.path.realpath(__file__))
    os.system('''/usr/bin/osascript -e 'tell app "Finder" to set frontmost of process "Python" to true' ''')
    path = easygui.fileopenbox("Please select article file (txt", "Article Picker", filetypes=["*.txt"], default=cwd)

    print(path)
    chinese_body = []
    with open(path, encoding="utf-8-sig") as txtfile:  # encoding="utf-8-sig"
        # should be entire file
        chinese_body = txtfile.readlines()

    file_name = ntpath.basename(path)

    msg = "Please add article details"
    title = "Add new article"
    fieldNames = ["chineseTitle", "chineseBody", "tags", "url"]
    fieldValues = [file_name, '\n'.join(chinese_body), '', '']

    os.system('''/usr/bin/osascript -e 'tell app "Finder" to set frontmost of process "Python" to true' ''')
    fieldValues = easygui.multenterbox(msg, title, fieldNames, fieldValues)

    # make sure that none of the fields was left blank
    while 1:
        if fieldValues == None: break
        errmsg = ""
        for i in range(len(fieldNames)):
            if fieldValues[i].strip() == "":
                errmsg = errmsg + ('"%s" is a required field.\n\n' % fieldNames[i])
        if errmsg == "": break  # no problems found
        fieldValues = easygui.multenterbox(errmsg, title, fieldNames, fieldValues)
    print("Reply was: ", fieldValues)

    article = article_pb2.Article()
    article.chinese_title = fieldValues[0]
    article.chinese_body = fieldValues[1]
    article.tags.extend(fieldValues[2].split(' '))
    article.url = fieldValues[3]
    return [article]


if __name__ == "__main__":
    customInsert()
