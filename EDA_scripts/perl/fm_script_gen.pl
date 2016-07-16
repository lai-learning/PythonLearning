#################################################
### synopsys formality file generation script ###
###      created by hjl 2014.12.26            ###
#################################################

#!/usr/bin/perl -w
### make run.tcl file ###
$date = `date +%Y/%m/%d`;
chomp $date;

################## nc_fm ################
chdir "/home/abc/serdes_hjl/Project/synthesis/syn/scripts/nc_mode";
@nc_list = glob "*.tcl";
print "PWD:/home/abc/serdes_hjl/Project/synthesis/syn/scripts/nc_mode\n";
chdir "/home/abc/serdes_hjl/Project/FC_AE_fm/scripts/nc_mode";
print "PWD:/home/abc/serdes_hjl/Project/FC_AE_fm/scripts/nc_mode\n";
foreach (@nc_list)
{
    if($_ =~ /(\w+)/)
    {
        print "$&\n";
        &common($&);
    }
}
chdir "/home/abc/serdes_hjl/Project/FC_AE_fm/run_tcl";
print "PWD:/home/abc/serdes_hjl/Project/FC_AE_fm/run_tcl\n";
open  FH2, ">nc_fm.tcl";
print FH2 "############################################\n";
print FH2 "###     synopsys formality run script    ###\n";
print FH2 "###                nc_mode               ###\n";
print FH2 "###      created by hjl $date       ###\n";
print FH2 "############################################\n";
foreach (@nc_list)
{
    if($_ =~ /(\w+)/)
    {
        print "$&\n";
        print FH2 "#--------------------------------------------------\n";
        print FH2 "# module:  $&\n";
        print FH2 "fm_shell -f ./scripts/nc_mode/$&.tcl | tee ./log/nc_mode/$&.log\n";
    }
}
close FH2;

#################### nt_fm ###########################
chdir "/home/abc/serdes_hjl/Project/synthesis/syn/scripts/nt_mode";
print "PWD:/home/abc/serdes_hjl/Project/synthesis/syn/scripts/nt_mode\n";
@nt_list = glob "*.tcl";
chdir "/home/abc/serdes_hjl/Project/FC_AE_fm/scripts/nt_mode";
print "PWD:/home/abc/serdes_hjl/Project/FC_AE_fm/scripts/nt_mode\n";
foreach (@nt_list)
{
    if($_ =~ /(\w+)/)
    {
        #my $name = $&;
        print "$&\n";
        &common($&);
    }
}

chdir "/home/abc/serdes_hjl/Project/FC_AE_fm/run_tcl";
print "PWD:/home/abc/serdes_hjl/Project/FC_AE_fm/run_tcl\n";
open  FH2, ">nt_fm.tcl";
print FH2 "############################################\n";
print FH2 "###     synopsys formality run script    ###\n";
print FH2 "###                nt_mode               ###\n";
print FH2 "###      created by hjl $date       ###\n";
print FH2 "############################################\n";
foreach (@nt_list)
{
    if($_ =~ /(\w+)/)
    {
        print "$&\n";
        print FH2 "#--------------------------------------------------\n";
        print FH2 "# module:  $&\n";
        print FH2 "fm_shell -f ./scripts/nt_mode/$&.tcl | tee ./log/nc_mode/$&.log\n";
    }
}
close FH2;

#############################################################
chdir "/home/abc/serdes_hjl/Project/synthesis/syn/scripts";
print "PWD:/home/abc/serdes_hjl/Project/synthesis/syn/scripts\n";
@tcl_list = glob "*.tcl";
chdir "/home/abc/serdes_hjl/Project/FC_AE_fm/scripts";
print "PWD:/home/abc/serdes_hjl/Project/FC_AE_fm/scripts\n";
foreach (@tcl_list)
{
    if($_ =~ /(\w+)/)
    {
        #my $name = $&;
        print "$&\n";
        &common($&);
    }
}


sub common{
    $date = `date +%Y/%m/%d`;
    chomp $date;
    my $top_name = $_[0];
    open FH1, ">$top_name.tcl";
    print FH1 "############################################\n";
    print FH1 "###     synopsys formality run script    ###\n";
    print FH1 "###      created by hjl $date       ###\n";
    print FH1 "############################################\n";
    print FH1 "set active_design $top_name\n";
    #$dwroot =  "/export/home/soft2/synopsys/software/DC_2006/libraries/syn";
    $dwroot =  "/opt/EDA_Tools/synopsys/D-2010.03-SP5-2";
    print FH1 "\nset hdlin_dwroot $dwroot\n";
    
    print FH1 "\n### step 0 : guidance ###\n";
    print FH1 "set_svf ./svf/\$active_design.svf\n";
    print FH1 "report_guidance -to ./guidance/\$active_design.svf\n";
    
    print FH1 "\n### step 1 : read reference ###\n";
    print FH1 "read_verilog -r ./rtl/\$active_design.v\n";
    print FH1 "set_top \$active_design\n";
    
    print FH1 "\n### step 2 : read implementation ###\n";
    print FH1 "read_db -technology_library ./lib/DICE_DELAY_DFF_RN_MUX_slow.db\n";
    print FH1 "read_db -technology_library ./lib/simc013_rhbd_slow_v1.db\n";
    print FH1 "read_db -technology_library ./lib/SERT_DELAY_DFFSR_slow.db\n";
    print FH1 "read_db -technology_library ./lib/DICE_DELAY_DFF_RN_slow.db\n";
    print FH1 "read_db -technology_library ./lib/DICE_DELAY_DFF_slow_v1.db\n";
    print FH1 "read_verilog -i ./netlist/\$active_design.v\n";
    print FH1 "set_top \$active_design\n";
    
    print FH1 "\n### step 3 : setup ###\n";
    print FH1 "## if use DFT compiler or BSD compiler or Power compiler,\n";
    print FH1 "## setup here, or let it alone\n";
    print FH1 "\n### step 4 : match ###\nmatch\n";
    print FH1 "report_unmatched\n";
    print FH1 "report_unmatched -status unread\n";
    print FH1 "\n### step 5 : verify ###\nverify\n";
    print FH1 "\n### step 6 : debug  ###\n";
    print FH1 "## start gui here to debug if failed\n";
    print FH1 "\nreport_svf_operation -status rejected\n";
    print FH1 "report_failing_points\n";
    print FH1 "\nexit\n";
    close FH1;
}


