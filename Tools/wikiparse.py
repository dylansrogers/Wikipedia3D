# get the list of all wikipedia pages (articles) -- English
from simplemediawiki import MediaWiki
import os

if os.path.isfile("wikiListOfArticles_nonredirects.txt"):

    #If File Already Exists, Append to the End
    with open("wikiListOfArticles_nonredirects.txt", "rb") as file:
        file.seek(-2, os.SEEK_END)
        while file.read(1) != b'\n':
            file.seek(-2, os.SEEK_CUR) 
        lastline = file.readline().decode()
    
    with open("wikiListOfArticles_nonredirects.txt", "r", encoding='utf-8') as input:
        with open("temp.txt", "w", encoding='utf-8') as output:
            # iterate all lines from file
            for line in input:
                # if text matches then don't write it
                if line != lastline.replace('\r',''):
                    output.write(line)
            

    # replace file with original name
    os.replace('temp.txt', 'wikiListOfArticles_nonredirects.txt')

    lastline = lastline.split('; ')
    lastline = lastline[1].removesuffix('\n')
    lastline = lastline.removesuffix('\r')

    listOfPagesFile = open("wikiListOfArticles_nonredirects.txt", "a", encoding="utf-8")

    wiki = MediaWiki('https://en.wikipedia.org/w/api.php')

    requestObj = {}
    requestObj['action'] = 'query'
    requestObj['list'] = 'allpages'
    requestObj['apfrom'] = lastline
    requestObj['aplimit'] = 'max'
    requestObj['apnamespace'] = '0'
    requestObj['apfilterredir'] = 'nonredirects'

    pagelist = wiki.call(requestObj)
    pagesInQuery = pagelist['query']['allpages']

    for eachPage in pagesInQuery:
        pageId = eachPage['pageid']
        title = eachPage['title']
        writestr = str(pageId) + "; " + str(title) + "\n"
        listOfPagesFile.write(writestr)

    numQueries = 1

    while True:

        try:
            requestObj['apcontinue'] = pagelist["continue"]["apcontinue"]
            pagelist = wiki.call(requestObj)

            pagesInQuery = pagelist['query']['allpages']

            for eachPage in pagesInQuery:
                pageId = eachPage['pageid']
                title = eachPage['title']
                writestr = (str(pageId) + "; " + title + "\n")
                listOfPagesFile.write(writestr)

            numQueries += 1

            if numQueries % 100 == 0:
                print("Done with queries -- ", numQueries)
                print(numQueries)
        except:
            listOfPagesFile.close()
            break

else:

    #If File Doesn't Exist, Start From Scratch
    listOfPagesFile = open("wikiListOfArticles_nonredirects.txt", "w", encoding="utf-8")


    wiki = MediaWiki('https://en.wikipedia.org/w/api.php')

    requestObj = {}
    requestObj['action'] = 'query'
    requestObj['list'] = 'allpages'
    requestObj['aplimit'] = 'max'
    requestObj['apnamespace'] = '0'
    requestObj['apfilterredir'] = 'nonredirects'

    pagelist = wiki.call(requestObj)
    pagesInQuery = pagelist['query']['allpages']

    for eachPage in pagesInQuery:
        pageId = eachPage['pageid']
        title = eachPage['title']
        writestr = str(pageId) + "; " + str(title) + "\n"
        listOfPagesFile.write(writestr)

    numQueries = 1

    while True:

        try:
            requestObj['apcontinue'] = pagelist["continue"]["apcontinue"]
            pagelist = wiki.call(requestObj)

            pagesInQuery = pagelist['query']['allpages']

            for eachPage in pagesInQuery:
                pageId = eachPage['pageid']
                title = eachPage['title']
                writestr = (str(pageId) + "; " + title + "\n")
                listOfPagesFile.write(writestr)

            numQueries += 1

            if numQueries % 100 == 0:
                print("Done with queries -- ", numQueries)
                print(numQueries)
        except:
            listOfPagesFile.close()
            break