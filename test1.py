import os
import csv
from datetime import datetime 

poew = '''we have seen thee
lying quietly at you ease,
thy fair form no flies dare seize'''
print(poew)
with open('out.txt', 'wt') as fout:
    fout.write(poew)

poem = ''
with open('out.txt', 'rt') as fin:
    for line in fin:
        poem += line
print(poem)

bbyte = bytes(range(16))
with open('out1.txt', 'wb') as fout:
    print(bbyte)

villains = [['Doctor','No'],['Rosa','Klebb'],['Mister','Big'],['Auric','Goldfinger'],['Ernst','Blofeld']]
with open('villains','wt') as fout:
    csvout = csv.writer(fout)
    csvout.writerows(villains)

with open('villains','rt') as fin:
    cin = csv.reader(fin)
    villains_r = [row for row in cin]
print(villains_r)

fmt = "%Y/%m/%d %H:%M:%S"
now = datetime.now()
now_change = now.strftime(fmt)
print(now_change)

