#################################################
### synopsys formality file generation script ###
###      created by hjl 2014.10.08            ###
#################################################

#!/usr/bin/perl -w
print "Please input project name of formality:\n";
$pro_name = <STDIN>;
chomp $pro_name;
mkdir "$pro_name", 0755 or die "cannot make directory: $!";

### make dir ###
chdir "$pro_name";
mkdir "log", 0755 or die "cannot make directory: $!";
mkdir "rtl", 0755 or die "cannot make directory: $!";
mkdir "lib", 0755 or die "cannot make directory: $!";
mkdir "netlist", 0755 or die "cannot make directory: $!";

### make run file ###
open FH, ">run";
print FH "fm_shell -f run.tcl | tee ./log/run.log \n";
close FH;

$date = `date +%Y/%m/%d`;
chomp $date;
### make run file ###
open FH1, ">.synopsys_fm.setup";
print FH1 "#####################################################\n";
print FH1 "### global setting just like synnopsys_dc.setup  ####\n";
print FH1 "#####################################################\n";
print FH1 "\nset search_path [list ./rtl\\\n";
print FH1 "\t\t\t\t\t./netlist\\\n";
print FH1 "\t\t\t\t\t./lib\\\n";
print FH1 "\t\t\t\t\t./log\\\n";
print FH1 "\t\t\t\t\t./\t\t]\n";
print FH1 "\nset sh_continue_on_error true\n";
print FH1 "set  bus_naming_style {%s[%d]}\n";
print FH1 "\n### created by hjl $date ###\n";
print FH1 "\n\n";
close FH1;


