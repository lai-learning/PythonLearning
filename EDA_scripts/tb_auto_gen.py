import sys
import re

module_name_ori = sys.argv[1]
module_name = re.sub(r'.v', '', module_name_ori)

fout = open('tb_'+module_name_ori,'wt') 
fout.write('`timescale 1ns/1ps\n')
fout.write('module ' + module_name + ';' + '\n')

# get all input and output ports
fin = open(module_name_ori,'rt')
in_ports_no_comma_list = []
out_ports_no_comma_list = []
for line in fin:
    # match input in1,in2, or input [3:0] in1,in2,
    m = re.match(r'^\s*input\s*(?P<WIDTH>(\[\d*:\d\])*)\s*(?P<NAME>(\w+\,\s*)+)',line) 
    if m:
        in_ports = m.group('NAME')
        port_width = m.group('WIDTH')
        in_ports_no_comma_tmp = re.split(',',in_ports)
        in_ports_no_comma_list += in_ports_no_comma_tmp[0:-1]

    # match output in1,in2, or input [3:0] in1,in2, pr output out3
    m1 = re.match(r'^\s*output\s*(?P<WIDTH>(\[\d*:\d\])*)\s*(?P<NAME>(\w+\,\s*)+\w+)',line) 
    if m1:
        out_ports = m1.group('NAME')
        port_width = m1.group('WIDTH')
        out_ports_no_comma_tmp = re.split(',', out_ports)
        out_ports_no_comma_list += out_ports_no_comma_tmp

for ports in in_ports_no_comma_list:
    if port_width:
        fout.write('reg ' + port_width + ' ' + ports + ';\n')
    else:
        fout.write('reg' + port_width + ' ' + ports + ';\n')

for ports in out_ports_no_comma_list:
    if port_width:
        fout.write('wire ' + port_width + ' ' + ports + ';\n')
    else:
        fout.write('wire' + port_width + ' ' + ports + ';\n')

# instance module
fout.write('\n//instance\n')
fout.write(module_name + ' ' + module_name + '_i(\n')
for ports in in_ports_no_comma_list:
    fout.write('\t.' + ports + '(' + ports + '),\n')
for ports in out_ports_no_comma_list[0:-1]:
    fout.write('\t.' + ports + '(' + ports + '),\n')
#fout.write('\t.' + out_ports_no_comma_list[-1] + '(' + out_ports_no_comma_list[-1] + ')\n')
fout.write(');\n\n')

for ports in out_ports_no_comma_list:
    fout.write(ports)

# get clock ports
clk_ports = {} # dict store all clk ports
for ports in in_ports_no_comma_list:
    m2 = re.match(r'\w*rst\w*', ports)
    m3 = re.match(r'\w*clk\w*', ports)
    if m2:
        rst_port = m2.group()
    if m3:
        clk_ports[m3.group()] = ''

num_str = '01234'
num = 0
for ports in clk_ports.keys():
    fout.write('localparam CLK_PERIOD_' + num_str[num] + ' = 10;\n')
    fout.write('always #(CLK_PERIOD_' + num_str[num] + '/2.0) ' + ports + '= ~'+ ports + '\n')
    fout.write('\n')
    num += 1

fout.write('initial begin\n')
for ports in in_ports_no_comma_list:
    fout.write('\t' + ports + ' = 0;\n')
fout.write('\t//removal reset after 50 ns\n')
fout.write('\t' +  rst_port + ' = 1;\n')
for clk in clk_ports.keys():
    fout.write('\t@(posedge ' + clk + ');\n')
fout.write('\t//add stimu here\n\n\n\n')
fout.write('end\n\n')

fout.write('initial begin\n')
fout.write('\t$fsdbDumpfile(\"' + module_name + '.fsdb\");\n')
fout.write('\t$fsdbDumpvars(0,tb_' + module_name + ');\n')
fout.write('\t$fsdbDumpMDA();\n')
fout.write('end\n\n')
fout.write('endmodule\n\n')


