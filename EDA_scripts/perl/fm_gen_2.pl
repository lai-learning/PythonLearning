#################################################
### synopsys formality file generation script ###
###      created by hjl 2014.10.08            ###
#################################################

#!/usr/bin/perl -w
### make run.tcl file ###
print "Please input project name of formality:\n";
$pro_name = <STDIN>;
chomp $pro_name;
print "Please input top module name of formality:\n";
$top_name = <STDIN>;
chomp $top_name;
$date = `date +%Y/%m/%d`;
chdir "$pro_name";
chomp $date;
open FH1,">run.tcl";
print FH1 "############################################\n";
print FH1 "###     synopsys formality run script    ###\n";
print FH1 "###      created by hjl $date       ###\n";
print FH1 "############################################\n";
print FH1 "set design $top_name\n";
$dwroot =  "/opt/EDA_Tools/synopsys/D-2010.03-SP5-2";
print FH1 "\nset hdlin_dwroot $dwroot\n";

print FH1 "\n### step 0 : guidance ###\n";
print FH1 "set_svf ./default.svf\n";
print FH1 "report_guidance -to guidance_svf\n";

print FH1 "\n### step 1 : read refence ###\n";
chdir "./rtl";
@referen_list = glob "*.v";
chdir "..";
foreach (@referen_list)
{
    print FH1 "read_verilog -r ./rtl/$_\n";
}
print FH1 "set_top $top_name\n";

print FH1 "\n### step 2 : read implementation ###\n";
chdir "./lib";
@db_list = glob "*.db";
chdir "..";
foreach (@db_list)
{
    print FH1 "read_db -technology_library ./lib/$_\n";
}
chdir "./netlist";
@implem_list = glob "*.v";
chdir "..";
foreach (@implem_list)
{
    print FH1 "read_verilog -i ./netlist/$_\n";
}
print FH1 "set_top $top_name\n";

print FH1 "\n### step 3 : setup ###\n";
print FH1 "\n### step 4 : match ###\nmatch\n";
print FH1 "\n### step 5 : verify ###\nverify\n";
print FH1 "\n### step 6 : debug  ###\n";
print FH1 "report_svf_operation -status rejected\n";
print FH1 "report_failing_points\n";
print FH1 "\n### save session file ###\n\n";
print FH1 "exit\n";
close FH1;
