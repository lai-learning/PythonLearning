import xlrd
import time

excel_name = 'alipay_record_7_9.xls'
data = xlrd.open_workbook(excel_name)
table = data.sheet_by_index(0) # get sheet
max_row = table.nrows # get row number
max_col = table.ncols # get col number
start_flag = '交易来源地'
start_valid = 0
type1 = '其他（包括阿里巴巴和外部商家）'
type2 = '淘宝'
type3 = '支付宝网站'

trade_time1 = []
trade_time2 = []
trade_time3 = []
countpart1 = []
countpart2 = []
countpart3 = []
trade_name1 = []
trade_name2 = []
trade_name3 = []
amount1 = []
amount2 = []
amount3 = []
status1 = []
status2 = []
status3 = []
type1_amount = 0;
type2_amount = 0;
type3_amount = 0;

# chinese character encode to same type, then compare
start_row = 0
for i in range(0,max_row):
    # get valid data
    if table.cell(i,5).value.strip().encode('unicode-escape') == start_flag.encode('unicode-escape'):
        start_valid = 1
    elif table.cell(i,5) == ' ':
        start_valid = 0
    # get type amount
    if start_valid:
        if table.cell(i,5).value.strip().encode('unicode-escape') == type1.encode('unicode-escape'):
            temp = xlrd.xldate_as_tuple(table.cell(i,3).value,0) #read as date
            temp1 = ('%d/%d/%d' % (temp[0],temp[1],temp[2]))
            trade_time1.append(temp1)
            countpart1.append(table.cell(i,5+2).value.strip())
            trade_name1.append(table.cell(i,5+3).value.strip())
            amount1.append(table.cell(i,5+4).value)
            status1.append(table.cell(i,5+10).value.strip())
            type1_amount += table.cell(i,5+4).value
        elif table.cell(i,5).value.strip().encode('unicode-escape') == type2.encode('unicode-escape'):
            temp2 = xlrd.xldate_as_tuple(table.cell(i,3).value,0) #read as date
            temp3 = ('%d/%d/%d' % (temp[0],temp[1],temp[2]))
            trade_time2.append(temp3)
            countpart2.append(table.cell(i,5+2).value)
            trade_name2.append(table.cell(i,5+3).value)
            amount2.append(table.cell(i,5+4).value)
            status2.append(table.cell(i,5+10).value)
            type2_amount += table.cell(i,5+4).value
        elif table.cell(i,5).value.strip().encode('unicode-escape') == type3.encode('unicode-escape'):
            temp4 = xlrd.xldate_as_tuple(table.cell(i,3).value,0) #read as date
            temp5 = ('%d/%d/%d' % (temp[0],temp[1],temp[2]))
            trade_time3.append(temp5)
            countpart3.append(table.cell(i,5+2).value)
            trade_name3.append(table.cell(i,5+3).value)
            amount3.append(table.cell(i,5+4).value)
            status3.append(table.cell(i,5+10).value)
            type3_amount += table.cell(i,5+4).value

with open('results.txt','wt') as outfile:
    # write first type
    outfile.write('%-18s %-12s %-5s %-40s\n' % ('time', 'amount','status', 'countpart')) 
    for i in range(0,len(trade_time1)):
        outfile.write('%-18s %-12f %-5s %-40s\n' % (trade_time1[i], amount1[i], status1[i], countpart1[i])) 
    outfile.write('%-28s %-12f \n' % ('type1_amout', type1_amount )) 
    outfile.write('\n\n\n')

    # write second type
    outfile.write('***************shop online****************\n')
    outfile.write('%-18s %-12s %-9s %-40s\n' % ('time', 'amount','status', 'countpart')) 
    for i in range(0,len(trade_time2)):
        outfile.write('%-18s %-12f %-7s %-40s\n' % (trade_time2[i], amount2[i], status2[i], countpart2[i])) 
    outfile.write('%-18s %-12f \n' % ('type2_amout', type2_amount )) 
    outfile.write('\n\n\n')

    # write third type
    outfile.write('************transfer online***************\n')
    outfile.write('%-18s %-12s %-9s %-40s\n' % ('time', 'amount','status', 'countpart')) 
    for i in range(0,len(trade_time2)):
        outfile.write('%-18s %-12f %-7s %-40s\n' % (trade_time3[i], amount3[i], status3[i], countpart3[i])) 
    outfile.write('%-18s %-12f \n' % ('type3_amout', type3_amount )) 
    outfile.write('\n\n\n')

    #write total expense
    outfile.write('%-18s %12f' % ('total expense',type1_amount+type2_amount+type3_amount)) 



