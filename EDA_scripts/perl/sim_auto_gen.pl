#!/usr/bin/perl -w
use 5.010;

say "*"x60;
say "  function\:\t\t";
say "  generating something needed to simulate functionly,including
  \"makefile\" file and some folders\. you can run tb_gen\.pl to 
  generating \"testbench\" file\, you can also run sim_f_gen\.pl 
  to generating \"sim\.f\" file\. ";
say "*"x60;
print "Please input project name\n";

$pro_name = <STDIN>;
chomp $pro_name;
if (-d $pro_name){
    print "folder \"$pro_name\" already exists, please use other name\n";
    exit;
}
else{
    mkdir "$pro_name", 0755 or die "cannot make directory: $!";
}

### make dir ###
chdir "$pro_name";
mkdir "log", 0755 or die "cannot make directory: $!";
mkdir "source", 0755 or die "cannot make directory: $!";
mkdir "testbench", 0755 or die "cannot make directory: $!";

### make make file ###
open FH,">makefile";
select FH;
say "nc:";
say "\tncverilog +ncaccess+r +loadpli1=debpli:novas_pli_boot -f sim.f -l ./log/\$\<.log";
say "sim:";
say "\tvcs -P /opt1/verdi2014/share/PLI/VCS/LINUX64/novas.tab /opt1/verdi2014/share/PLI/VCS/LINUX64/pli.a +vcsd -full64 -debug_all +v2k +lint=PCWM -timescale=1ns/1ps -R -f sim.f -l ./log/\$\<.log";
say "dve:";
say "\t./simv -gui";
say "dw:";
say "\tvericom -f sim.f\tverdi -ssf $pro_name\.fsdb -top tb_$pro_name"."&";
say "\n\.PHONY:clean";
say "clean:";
say "\trm -rf csrc INCA* simv* *Log ./log/*.log *.vpd sess* *.key DVEfiles work.lib++ nLint* nlint*";
close FH;

## generating sim_f_gen.pl file
open FH1,">sim_f_gen.pl";
select FH1;
say "\#\!\/usr\/bin\/perl \-w";
say "use 5\.010\;";
say "\#\# add source file";
say "say \"\*\"x30\;";
say "say \"function\: generating sim\.f file\"\;";
say "say \"*\"x30\;";
say "open FP, \">sim.f\" or die \"can not open: $!\"\;";
say "select FP\;";
say "chdir \"./source\"\;";
say "my \@source_list = glob \"\*\.v\"\;";
say "chdir \"\.\.\"\;";
say "say \"\/\/====== source file ======\"\;";
say "foreach (\@source_list)";
say "{";
say "\tsay \"\.\/source\/\$\_\"\;";
say "}";
say "\#\# add testbench file\;";
say "say \"\\n\/\/====== testbench file ======\"\;";
say "chdir \"./testbench\"\;";
say "my \@tb_list = glob \"\*\.v\"\;";
say "chdir \"\.\.\"\;";
say "foreach (\@tb_list)";
say "{";
say "\tsay \".\/testbench\/\$\_\"\;";
say "}";
say "close FP\;";
close FH1;

