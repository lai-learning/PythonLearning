#################################################
### synopsys design compiler file generation  ###
### script created by hjl 2016.02.08          ###
#################################################

#!/usr/bin/perl -w
use 5.010;

print "Please input project name of dc:\n";
$pro_name = <STDIN>;
chomp $pro_name;
mkdir "$pro_name", 0755 or die "cannot make directory: $!";

### create folder ###
chdir "$pro_name";
mkdir "log", 0755 or die "cannot make directory: $!";
mkdir "rtl", 0755 or die "cannot make directory: $!";
mkdir "cons", 0755 or die "cannot make directory: $!";
mkdir "mapped", 0755 or die "cannot make directory: $!";
mkdir "unmapped", 0755 or die "cannot make directory: $!";
mkdir "netlist", 0755 or die "cannot make directory: $!";

### getgrent run file ###
open FH, ">run";
print FH "dc_shell -f run.tcl | tee ./log/run.log \n";
close FH;

$date = `date +%Y/%m/%d`;
chomp $date;
### generate setup file ###
open FH1, ">.synopsys_dc.setup";
select FH1;
say "#####################################################";
say "###     global setting: synnopsys_dc.setup       ####";
say "###       created by hjl $date               ####";
say "#####################################################";
say "\nset search_path [list /home/lai123/libs\\";
say "\t\t\t\t\t./netlist\\";
say "\t\t\t\t\t./rtl\\";
say "\t\t\t\t\t./cons\\";
say "\t\t\t\t\t./log\\";
say "\t\t\t\t\t./\t\t]";
say "set target_library [list slow_1v08c125.db dw_foundation.sldb]";
say "set link_library [list * slow_1v08c125.db dw_foundation.sldb]";
say "set symbol_library [list smic13g.sdb]";
say "\nset sh_continue_on_error true";
say "set  bus_naming_style {%s[%d]}";
say "set verilog_show_unconnected_pins true";
say "\n### created by hjl $date ###";
say "history keep 500";
say "\n";
close FH1;

select STDOUT;
say "Please input name of top module which synthesize:";
$top_module = <STDIN>;
chomp $top_module;

### generate constraints.con file ###
say "Please input clk name of top module which synthesize:";
$clk = <STDIN>;
chomp $clk;
say "Please input clock period of top module (ns):";
$period = <STDIN>;
chomp $period;
$period = $period * 0.8;
$half_period = $period/2.0;
$input_delay = $period * 0.6;
say "Please input reset name of top module which synthesize:";
$reset = <STDIN>;
chomp $reset;

open FH2, "> ./cons/constaints.con";
select FH2;
say "reset_design";
say "set current_design $top_module\n";
say "######## set operation condition ##############";
say "#set_wire_load_model -name large ";
say "set_wire_load_mode enclosed";
say "set_operating_conditions slow\n";
say "### drive and load constraints ###";
say "### set input drive ###";
say "set_driving_cell -lib_cell INVX3 -pin Y [all_inputs]";
say "set_drive 0 [list $clk $reset]";
say "set_load [expr {[load_of DFFRX2/D]*3}] [all_outputs]\n";
say "######### optimization constrains #############";
say "### area constraints ###";
say "set_max_area 0\n";
say "### speed constaints ###";
say "### timing constraints ###";
say "create_clock -period $period -waveform [list 0.0 $half_period] [get_ports $clk]\n";
say "set_dont_touch_network [list $clk $reset]";
say "set_false_path -through $reset";
say "set_ideal_network [list $clk $reset]\n";
say "### set input delay ###";
say "set_input_delay -max $input_delay -clock $clk [get_ports all_inputs]\n";
say "### set output delay ###";
say "set_output_delay -max $input_delay -clock $clk [get_ports all_outputs]\n";
say "### set clock source delay ###";
say "set_clock_latency -source -max 0.3 [get_clocks $clk]";
say "### set clock network delay ###";
say "set_clock_latency -max 0.12 [get_clocks  $clk]";
say "set_clock_transition 0.08 [get_clocks $clk]";
say "set_clock_uncertainty -setup 0.08 [get_clocks $clk]\n";
say "################ set DRC ####################";
say "set_max_transition 1.8 \$design";
say "set_max_fanout 10 \$design";
close FH2;

### generate run.tcl file ###
open FH3, ">run.tcl";
select FH3;
say "#############################################";
say "###            run script                 ###";
say "###       created by hjl $date        ###";
say "#############################################";
say "set  design  $top_module";
say "read_verilog  [list \$design.v ]";
say "current_design \$design";
say "\nredirect -tee -file log/precompile.rpt {link}";
say "redirect -append -tee -file log/precompile.rpt {check_design}";
say "### save presynthesis data in ddc ###";
say "write -format ddc -hier -output unmapped/\$design.ddc";
say "### add constraints on design ###";
say "redirect -tee -file log/precompile.rpt {source -echo -ver constraint.con}";
say "### report after source constraints ###";
say "redirect -append -tee -file log/precompile.rpt {report_port -verbose}";
say "redirect -append -tee -file log/precompile.rpt {report_clock}";
say "redirect -append -tee -file log/precompile.rpt {report_clock -skew}";
say "redirect -append -tee -file log/precompile.rpt {check_timing}";
say "\n####################################################";
say "### compile design, use DC Ultra  use boundary   ###";
say "### optimization and map_effort high             ###";
say "####################################################";
say "compile_ultra -timing -no_autoungroup ";
say "redirect -tee -file log/violators.rpt {report_constraint -all_violators}";
say "redirect -tee -append -file log/violators.rpt {report_constraint -all_violators}";
say "check_design";
say "report_compile_options";
say "set_svf -append default.svf";
say "report_design";
say "report_cell";
say "report_area";
say "report_power";
say "report_timing -max_paths 10000 ";
say "#reporting quality of results";
say "report_qor  ";
say "#######################################";
say "### write out design data in memory ###";
say "#######################################";
say "### convert tri to wire -eliminate assign ###";
say "set  verilogout_no_tri true";
say "### eliminate special characters in the netlist and constraint file ###";
say "change_names -rule verilog -hier";
say "### write out post-synthesis data ###";
say "write -f ddc -hier -out mapped/\$design.ddc";
say "write -f verilog -hierarchy -output netlist/\$design.v";
say "### write out the constraints-only sdc file ###";
say "write_sdc mapped/\$design.sdc";
say "### write out sdf file ### ";
say "write_sdf -version 2.1 mapped/\$design.sdf";
say "\nexit\n";
close FH3;

