mystery = '\U0001f4a9'
print(mystery)
pop_byte = mystery.encode('utf-8')
print(pop_byte)
pop_string = pop_byte.decode('utf-8')
print(pop_string)

str1 = 'roast beef'
str2 = 'ham'
str3 = 'head'
str4 = 'clam'
print('My kitty cat likes %s' % str1)
print('My kitty cat likes %s' % str2)
print('My kitty cat fell on his %s' % str3)
print("And now thinks he's a %s " % str4)