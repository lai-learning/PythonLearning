letter = '''Dear {salutation} {name},

Thank you for your letter. We are sorry that out {product} {verbed} in your
{room}. Please note that it should never be used in a {room}, especially
near any {animals}.

Send us your receipt and {amount} for shipping and handing. We will send
you another {product} that, in our tests, is {percent}% less likely to
have {verbed}.

Thank you for your support.
Sincerely,
{spokesman}
{job_title}'''

response = {
    'salutation' : 'ancle',
    'name' : 'Lee',
    'product' : 'keyboard',
    'verbed' : 'imploded',
    'room' : 'office',
    'animals' : 'dogs',
    'amount' : '1.38',
    'percent' : '5',
    'spokesman' : 'TI Inc',
    'job_title' : 'officer'
}

print(letter.format(**response))

