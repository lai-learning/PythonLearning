####################################
### prime time script generation ###
###  created by hjl  2015.01.05  ###
####################################
#!/usr/bin/perl -w
############ get time ###########
$date = `date +%Y/%m/%d`;
chomp $date;
############# make DIR ############
mkdir "sdc" ,0755 or die "cannot make directory: $!";
mkdir "sdf" ,0755 or die "cannot make directory: $!";
mkdir "netlist" ,0755 or die "cannot make directory: $!";
mkdir "log" ,0755 or die "cannot make directory: $!";
mkdir "savesession" ,0755 or die "cannot make directory: $!";

########### create README file ###########
open FH, ">README";
print FH "!!!!this is a script to run STA after postCTS or postNanoRoute\n";
print FH "some tips:\n";
print FH "1\.copy \.spef file to sdf folder\n";
print FH "2\.copy \.sdc file to sdc folder, then comment clock latency(include\n";
print FH "  source latency and network latency) and clock uncertainty, because\n";
print FH "  clock information already had after clock tree synthesis(CTS)\n";
print FH "3\.copy gate netlist extracted from Encounter to netlist folder\n";
print FH "4\.if your \.spef and \.sdc and gate netlist is not the top design name,\n";
print FH "  please change the file name or modify the run.tcl\n";
print FH "5\.open terminal and input source run\n";
print FH "6\.please tell me if you find any problem\n\n";

############ create run file ############
open FH1, "> run";
print FH1 "###########################################\n";
print FH1 "###               run file              ###\n";
print FH1 "###     create by hjl $date        ###\n";
print FH1 "###########################################\n";
print FH1 "pt_shell -f run.tcl | tee -i ./log/run.log\n\n";
close FH1;

############# create .synopsys_pt.setup ############
$pwd = `pwd`;
chomp $pwd;
print "Please input your fast lib directory, then pree the Enter\n";
$fast_lib_dir = <STDIN>;
chomp $fast_lib_dir;
chdir "$fast_lib_dir";
@fast_lib_list=glob "*.db";
chdir "$pwd";
print "Please input your slow lib directory, then pree the Enter\n";
$slow_lib_dir = <STDIN>;
chomp $slow_lib_dir;
chdir "$slow_lib_dir";
@slow_lib_list=glob "*.db";
chdir "$pwd";
print "@slow_lib_list\n";
print "@fast_lib_list\n";
foreach $file_list (@slow_lib_list) 
{
    if($file_list =~ /(\w+)/)
    {
        push @slow_lib_list_no_db, $&;
    }
}
print "@slow_lib_list_no_db\n";
foreach $file_list1 (@fast_lib_list) 
{
    if($file_list1 =~ /(\w+)/)
    {
        push @fast_lib_list_no_db, $&;
    }
}
print "@fast_lib_list_no_db\n";

open FH3, ">.synopsys_pt.setup";
print FH3 "############################################\n";
print FH3 "###     synopsys Prime Time setup file   ###\n";
print FH3 "###      created by hjl $date       ###\n";
print FH3 "############################################\n";
print FH3 "set  search_path { \.  \.\/log  \.\/sdf  \.\/netlist \\\n";
print FH3 "                  \.savesession \.\/sdc \\\n";
print FH3 "                  $fast_lib_dir \\\n";
print FH3 "                  $slow_lib_dir \\\n";
print FH3 "                 }\n";
print FH3 "set link_path [list \* @fast_lib_list \\\n";
print FH3 "                  @slow_lib_list ]\n";
print FH3 "\nset  bus_naming_style {%s[%d]}\n";
print FH3 "#set  verilogout_show_unconnected_pins tru\n";
print FH3 "\nhistory keep 200\n";
print FH3 "alias h history\n";
print FH3 "\n";
close FH3;

############ create run.tcl file ############
print "Please input the top design name, then press the Enter\n";
$top_name = <STDIN>;
chomp $top_name;
open FH2, "> run.tcl";
print FH2 "############################################\n";
print FH2 "###     synopsys Prime Time run script   ###\n";
print FH2 "###      created by hjl $date       ###\n";
print FH2 "############################################\n";
print FH2 "\nset design $top_name\n";
print FH2 "\n### varieble setting ###\n";
print FH2 "set sh_source_emits_line_number W\n";
print FH2 "set sh_continue_on_error true\n";
print FH2 "# identify where timing updates occur\n";
print FH2 "set timing_update_status_level high\n";
print FH2 "# to prevent PT create black boxes\n";
print FH2 "set link_create_black_boxes false \n";
print FH2 "# reports for unconstrained path\n";
print FH2 "set timing_report_unconstrained_paths true\n";
print FH2 "\n### read netlist ###\n";
print FH2 "read_verilog  netlist/\$design.v\n";
print FH2 "current_design \$design\n";
print FH2 "\nredirect -tee -file log/EW.log {link_design -keep_sub_designs}\n";
print FH2 "\n### read spef ###\n";
print FH2 "read_parasitics ./sdf/\$design.spef\n";
print FH2 "redirect -tee -file log/EW.log {report_annotated_parasitics}\n";
print FH2 "set_operating_conditions -analysis_type on_chip_variation \\\n";
print FH2 "              -max_library {@slow_lib_list_no_db} \\\n";
print FH2 "              -min_library {@fast_lib_list_no_db} \\\n";
print FH2 "\nsource -echo -verbose ./sdc/\$design.sdc\n";
print FH2 "set_propagated_clock [all_clocks]\n";
print FH2 "# show detailed information abaut potential problems\n";
print FH2 "redirect -tee -append ./log/EW.log {check_timing -verbose}\n";
print FH2 "# show all port information\n";
print FH2 "redirect -tee -append ./log/EW.log {report_port -verbose}\n";
print FH2 "redirect -tee -append ./log/EW.log {report_clock}\n";
print FH2 "\nredirect -tee ./log/sta.log {report_analysis_coverage -status_details {untested violated}}\n";
print FH2 "redirect -tee -append ./log/sta.log {report_constraint -all_violators}\n";
print FH2 "redirect -tee -append ./log/sta.log {report_analysis_coverage -status violated -check \"setup hold\" -sort_by check_type}
\n";
print FH2 "\nredirect -tee ./log/sta_setup.log {puts \"\n";
print FH2 "############################################################\n";
print FH2 "##                          setup                         ##\n";
print FH2 "############################################################\"}\n";
print FH2 "redirect -tee -append ./log/sta_setup.log {puts \"------------------------------in2reg------reg2reg-------------------------\"}\n";
print FH2 "redirect -tee -append ./log/sta_setup.log {report_timing -nworst 100 -to [all_registers -data_pins] -slack_less 0.1 \\\n";
print FH2 "             -input_pins -nets -delay_type max}\n";
print FH2 "redirect -tee -append ./log/sta_setup.log {puts \"------------------------------reg2out-----in2out--------------------------\"}\n";
print FH2 "redirect -tee -append ./log/sta_setup.log {report_timing -nworst 100 -to [all_outputs] -slack_less 0.1 -nets -delay_type max}
\n";
print FH2 "\n\n";
print FH2 "redirect -tee ./log/sta_hold.log {puts \"\n";
print FH2 "############################################################\n";
print FH2 "##                          hold                          ##\n";
print FH2 "############################################################\"}\n";
print FH2 "redirect -tee -append ./log/sta_hold.log {puts \"------------------------------in2reg------reg2reg------------------------\"}\n";
print FH2 "redirect -tee -append ./log/sta_hold.log {report_timing -nworst 100 -to [all_registers -data_pins] -slack_less 0.1 \\\n";
print FH2 "             -input_pins -nets -delay_type min}\n";
print FH2 "redirect -tee -append ./log/sta_hold.log {puts \"------------------------------reg2out-----in2out--------------------------\"}\n";
print FH2 "redirect -tee -append ./log/sta_hold.log {report_timing -nworst 100 -to [all_outputs] -slack_less 0.1 -nets -delay_type min}\n";
print FH2 "\n";
print FH2 "### list all message ###\n";
print FH2 "redirect -tee ./log/qor.log {print_message_info}\n";
print FH2 "\n";
print FH2 "### save the session ###\n";
print FH2 "save_session -replace savesession\n";
print FH2 "\n";
print FH2 "quit\n";
print FH2 "\n";
print FH2 "\n";
print FH2 "\n";
close FH2;


