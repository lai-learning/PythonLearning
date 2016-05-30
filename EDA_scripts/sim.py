import os
from datetime import datetime 

# get system time
fmt = "%Y/%m/%d %H:%M:%S"
sys_time = datetime.now()
sys_time_format = sys_time.strftime(fmt)

prj_name = input("please input project name:")
verdi_dir = input("please input Verdi directory:(/opt/Verdi) ")
sim_ts = input("please input simulate timescale:(1ns/1ps) ")
top_module = input("please input top module name ")
tb_top_module = input("please input testbench of top module:(tb_top_module_name) ")

# makefile contents, change it if neccessary
makefile_str = '''\
nc:
	ncverilog +ncaccess+r +nctimescale+1ns/1ps +loadpli1=libpli -f sim.f -R -l ./log/$@$<.log
sim:
	vcs -P {verdi_root}/share/PLI/VCS/LINUX64/novas.tab {verdi_root}/share/PLI/VCS/LINUX64/pli.a -full64 +v2k -debug_all +lint=PCWM -f sim.f -R -timescale={timescale} -l ./log/$@.log
dve:
	./simv -gui
dw:
	vericom -f sim.f 
	verdi -ssf {module_name}.fsdb -top {tb_name}& 
clean:
	rm -rf csrc simv* *Log ./log/*.log *.vpd sess* *.key *.tcl DVEfiles work.lib++ nLint* nlint* INCA_libs \
'''

#sim_f contents
sim_f_str = '''\
// change it if neccessary

//====== source file  =======//
./source/{module_name}.v

//====== testbench file =======//
./testbench/{tb_name}.v

'''

mkfile_dict = {
        'verdi_root': verdi_dir,
        'timescale': sim_ts,
        'module_name': top_module,
        'tb_name':tb_top_module
        }

sim_f_dict = {
        'module_name': top_module,
        'tb_name':tb_top_module
        }

# whether folder exists 
if not os.path.exists(prj_name):
    os.mkdir(prj_name)
else:
    print("folder \"%s\" exists, please remove it" % prj_name) 

# create folder
os.chdir(prj_name)
os.mkdir('source')
os.mkdir('testbench')

# create makefile file
with open('makefile','wt') as fout:
    fout.write('#' * 40 + '\n')
    fout.write('#' * 5 + ' ' * 5 + sys_time_format + ' ' * 6 + '#' * 5 + '\n')
    fout.write('#' * 5 + ' ' * 5 + 'created by hjl' + ' ' * 11 + '#' * 5 + '\n')
    fout.write('#' * 40 + '\n')
    fout.write(makefile_str.format(**mkfile_dict))

# create sim.f file
with open('sim.f','wt') as fout:
    fout.write('//' + '#' * 36 + '//' + '\n')
    fout.write('//' + '#' * 3 + ' ' * 5 + sys_time_format + ' ' * 6 + '#' * 3 + '//' + '\n')
    fout.write('//' + '#' * 3 + ' ' * 5 + 'created by hjl' + ' ' * 11 + '#' * 3 + '//' + '\n')
    fout.write('//' + '#' * 36 + '//' + '\n')
    fout.write(sim_f_str.format(**sim_f_dict))

