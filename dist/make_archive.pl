#!/usr/bin/perl

use File::Basename;
use File::Copy;
use File::Path;

sub error
{
	print	"\n=========================\n\n"
		.	"ERROR: $_[0]\n";
	getc(STDIN);
	exit(1);
}

sub copyFile
{
	mkpath(dirname($_[1]));
	if (copy($_[0], $_[1])) {
		print "Copy $_[0] to $_[1]\n";
	} else {
		print "SKIP $_[0]\n";
	}
}

$skyrimPath		= $ENV{'SkyrimPath'} or error("\$SkyrimPath env var not set.");
$archivePath	= $skyrimPath . "\\Archive.exe";

$swfBuildPath	= "..\\build";
$archiveOutPath	= "_generated";

$fileGroupInterfacePath = "filegroup_interface.txt";
$fileGroupMiscPath = "filegroup_misc.txt";
$fileGroupScriptsPath = "filegroup_scripts.txt";

$filegroupPathOut = "filegroup_all.txt";

@filegroupPathsIn = (
	$fileGroupInterfacePath,
	$fileGroupScriptsPath,
	$fileGroupMiscPath
);

# No wait?
$noWait = defined($ARGV[0]);

# Fetch latest .swf's from build/
print "=== Updating .SWF files...\n\n";
open(IN, $fileGroupInterfacePath) or error("Cannot open $fileGroupInterfacePath: $!");

while (my $file = <IN>) {
	chomp($file);
	$file =~ s/^Interface\\//;
	copyFile("$swfBuildPath\\$file", "Data\\Interface\\$file");
}
close(IN);
print "Done.\n\n";

# Merge filegroup lists
print ("=== Merging filegroup lists...\n\n");
open(OUT, ">$filegroupPathOut") or error("Cannot open $filegroupPathOut: $!");

foreach $f (@filegroupPathsIn) {
    open(IN, $f) or error("Cannot open $f: $!");
    while (my $line = <IN>) {
    	chomp($line);
    	print OUT "$line\n";
    }
	close(IN);
}
close(OUT);
print "Done.\n\n";

# Create archive
print "=== Creating archive...\n\n";
system($archivePath, "bsascript.txt") == 0 or exit(1);
print "Done.\n\n";

# Install archive
print "=== Installing archive...\n\n";

copyFile($_, "$skyrimPath\\Data\\" . basename($_)) foreach (<_generated/*>);

print "Done.\n\n";

getc(STDIN) unless $noWait;
exit(0);