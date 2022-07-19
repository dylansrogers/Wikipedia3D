import sqlite3
import unidecode

con = sqlite3.connect('titles.db')
cur = con.cursor()

cur.execute('CREATE TABLE titles (ID INTEGER NOT NULL, Title TEXT NOT NULL, SortTitle TEXT NOT NULL PRIMARY KEY, SectionID INTEGER, CaseID INTEGER, BookID INTEGER) WITHOUT ROWID')
listfile = open("list.txt", "r", encoding="utf8")

for line in listfile:
    itemlist = line.split('; ', 1)
    sorttitle = itemlist[1]

    #Remove Escape Sequence
    sorttitle = sorttitle.removesuffix('\n')

    #Remove Accents From Unicode Crap
    if len(sorttitle) > 1:
        sorttitle = sorttitle.replace('Ə','A')
        sorttitle = unidecode.unidecode(sorttitle)

    #Remove inital ...
    if sorttitle.find('...') == 0 or sorttitle.find('...') == 1:
        sorttitle = sorttitle.replace('...','',1)
    
    #Replace Other ... with a Space
    sorttitle = sorttitle.replace('...', ' ')

    #Contextually Replaces Dollar Sign so Rappers Are Happy
    if sorttitle.find("$") == 0:
        if sorttitle[1].isalpha():
            sorttitle = sorttitle.replace('$','S')
        elif sorttitle[1].isnumeric():
            sorttitle = sorttitle.replace('$','')
    else:
        #Replace All other Dollar Signs With S
        sorttitle = sorttitle.replace('$','S')

    #Replace Fancy Shmancy Chemistry Crap
    sorttitle = sorttitle.replace('(+)-','')
    sorttitle = sorttitle.replace('(-)-','')

    #Check for other Punctuation
    punctuation = ['"','!',"'",'(','*','+','-','.',')',',','&','@',':','`','?','=',';','/','\\','^','~']
        
    dontdestroy = False
    for symbol in punctuation:
        if sorttitle.find(symbol) == 0:
            if not sorttitle[len(symbol)].isalnum():
                dontdestroy = True

    if dontdestroy == False:
        for symbol in punctuation:
            sorttitle = sorttitle.replace(symbol,'')

    #Make All Letters Uppercase
    sorttitle = sorttitle.upper()

    #Remove Spaces
    sorttitle = sorttitle.replace(" ",'')

    #Insert into Database, Appends ! if name already exists
    def test(sorttitlerecursive):
        try:
            cur.execute("INSERT INTO titles VALUES (?,?,?,?,?,?)", (itemlist[0], itemlist[1].removesuffix('\n'), sorttitlerecursive, 'NULL', 'NULL', 'NULL'))
        except:
            test(sorttitlerecursive + '!')

    test(sorttitle)

con.commit()
listfile.close()

query = '''UPDATE titles
SET SectionID = 27
WHERE (substr(SortTitle,1,1) < '0')'''
cur.execute(query)

query = '''UPDATE titles
SET SectionID = 26
WHERE (substr(SortTitle,1,1) >= '0' AND substr(SortTitle,1,1) < '<')'''
cur.execute(query)

query = '''UPDATE titles
SET SectionID = 27
WHERE (substr(SortTitle,1,1) >= '<' AND substr(SortTitle,1,1) < 'A')'''
cur.execute(query)

query = '''UPDATE titles
SET SectionID =:section
WHERE (substr(SortTitle,1,1) >= :value1 AND substr(SortTitle,1,1) < :value2)'''
sections = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','\\']
for x in range(len(sections) - 1):
    cur.execute(query, {"value1": sections[x], "value2": sections[x+1], "section": x})

query = '''UPDATE titles
SET SectionID = 27
WHERE (substr(SortTitle,1,1) >= '\\')'''
cur.execute(query)
con.commit()

query = '''UPDATE titles
SET CaseID = (b.RowID / 3750)
FROM (SELECT (row_number() OVER (PARTITION BY SectionID ORDER BY SortTitle)) -1 AS RowID, ID FROM titles) AS b
WHERE titles.ID = b.ID
'''
cur.execute(query)
con.commit()

query = '''UPDATE titles
SET BookID = (b.RowID / 50)
FROM (SELECT (row_number() OVER (PARTITION BY [SectionID], [CaseID] ORDER BY SortTitle)) -1 AS RowID, ID FROM titles) AS b
WHERE titles.ID = b.ID
'''
cur.execute(query)
con.commit()

con.close()