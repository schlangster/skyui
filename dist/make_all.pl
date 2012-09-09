#!/usr/bin/perl

system("make_scripts.pl", "1") == 0 or die;
system("make_archive.pl", "1") == 0 or die;