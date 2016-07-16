#! /usr/bin/perl -w
#
#
@line=<>;
open FP,">new.v";
$buf_cnt=0;
foreach $line (@line)
{
    if($line=~/\s\sassign\s(.*)\s=\s(.*);/)
    {
        $buf_cnt=$buf_cnt+1;
        print FP "//$line";
        print FP "BUFX12 Ubuf$buf_cnt (.Y($1),.A($2));\n";
    }
    else
    {
        print FP "$line";
        
    }
}
