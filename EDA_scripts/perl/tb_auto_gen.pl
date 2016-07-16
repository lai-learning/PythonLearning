#!/usr/bin/perl -w 
use 5.010;
  
say "*"x30;
say "function: generating testbench file automaticly";
say "*"x30;

my @all_in_var; # store all input variable
my @all_out_var; # store all input variable
my @all_var;  # store all variable in the module

#===============================#
# get argument from command line
#===============================#
my $in = $ARGV[0];
if(! defined $in){
  die "usage:$0 filename";
}

# output file name
my $out = $in;
$out =~ s/^(w+)?/tb_/g;

# get module name
my $module_name = $in;
$module_name =~ s/\.v//g;

# open file
if (!open $in_fh,'<',$in){
  die "can't open '$in': $!";
}

if (!open $out_fh, '>',$out){
  die "can't write '$out': $!";
}

select $out_fh;
say "`timescale 1ns/1ps\n";
say "module tb_$module_name;";
select $in_fh;

#=====================================
# find input and output in the module
#=====================================
while (<$in_fh>){
  select $out_fh;
  chomp;
  # patten input or output
  if(/\b(in|out)put\b/){
    #say  $_;
    my $tmp = $';
    # input 
    if("$&" eq "input"){
      $tmp =~ s/\,$//g; 
      # patten multi variable at one line or just one
      if($tmp =~ m/(((\w+\s?\,\s?)+)?\w+\b$)/){
        my $string = $&;
        my @mult_var = split /,/, $string;
        # remove all space
        foreach $var_tmp (@mult_var){
          $var_tmp =~ s/(\s?\b|\b\s?)//g;
          push @all_in_var, $var_tmp;
        }
      }
      say "reg$tmp;";    # eg: reg [3:0] a;
    }
    # output 
    if("$&" eq "output"){
      $tmp =~ s/\,$//g;   # remove the last comma
      # remove reg if the output in the module is reg type
      $tmp =~ s/\breg\s?\b//g; 
      # patten multi variable at one line or just one
      if($tmp =~ m/(((\w+\s?\,\s?)+)?\w+\b$)/){
        my $string1 = $&;
        my @mult_var1 = split /,/, $string1;
        # remove all space
        foreach $var_tmp1 (@mult_var1){
          $var_tmp1 =~ s/(\s?\b|\b\s?)//g;
          push @all_out_var, $var_tmp1;
        }
      }
      say "wire$tmp;";   #eg: wire [3:0] b;
    }
  }
}

select $out_fh;

#===================================#
# instance module in the testbench
#===================================#
push @all_var,@all_in_var;
push @all_var,@all_out_var;
say "\n// instance";
print "$module_name $module_name";
print "_inst(\n";
$var_num = @all_var - 1;
foreach (0..$var_num){
  if ($_ == $var_num){
    say "\t\.$all_var[$_]($all_var[$_])";
  }
  else{
    say "\t\.$all_var[$_]($all_var[$_]),";
  }
}
say ");";

#====================================#
# find all reset and all clk
#====================================#
foreach (@all_in_var){
  if(/(clk|clock)/){
    push @clk,$_;
  }
  if(/(rst|reset)/){
    push @rst,$_;
  }
}

say "\n\/\/generate all clk";
$clk_num = @clk-1;
foreach (0..$clk_num){
  say "localparam CYCLE_TIME_$_ = 10;";
  say "always #(CYCLE_TIME_$_/2.0)  $clk[$_] = ~$clk[$_];\n";
}

#==============================#
#add inital block in tb
#==============================#
say "\ninitial begin";
foreach (@all_in_var){
  say "\t$_ = 0;";
}
say "\t\/\/removal reset after 50 ns";
say "\t\#50;";
foreach (@rst){
  say "\t$_ = 1;";
}
say "\t\/\/add stimu here";
say "\n\n\n\n\n";
say "\t\#1000 \$finish;";
say "end";

#================================#
#add dump function in tb
#================================#
say "\ninitial begin";
say "\t\$fsdbDumpfile(\"$module_name.fsdb\");";
say "\t\$fsdbDumpvars(0,tb_$module_name);";
say "\t\$fsdbDumpMDA();";
say "end";

say "\nendmodule\n"

