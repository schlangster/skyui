#!/usr/bin/perl

$noWait = defined($ARGV[0]);

system("make_scripts.pl", "1") == 0 or die;
system("make_archive.pl", "1") == 0 or die;

getc(STDIN) unless $noWait;
exit(0);