import csv

file_name = './alipay_record_7_9.csv'
with open(file_name,'rt') as infile:
    reader = csv.reader(infile)
    for row in reader:
        row_list = list(row)
        row_list = row_list.strip()
        #for cel in row_list:
        #    print(cel.strip())
        #print(row_list.strip())
        if len(row) > 9:
            #print(row[2],row[7],row[9],row[15])
            #if row[15].decode(gbk) == u'已支出':
                print("***********")
        else:
            print(row)

