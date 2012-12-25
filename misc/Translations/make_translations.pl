#!/usr/bin/perl

sub error
{
	print	"\n=========================\n\n"
		.	"ERROR: $_[0]\n";
	getc(STDIN);
	exit(1);
}

my $sourcePath = "SkyUI_Translations.txt";

open SOURCE, "<:utf8", $sourcePath or error("Cannot open $sourcePath: $!");

my @langs = split("\t", <SOURCE>);
shift @langs;

my @files;

foreach $lang (@langs) {
	chomp($lang);
	$lang = lc($lang);
	local *FILE;
	local $fileName = "SkyUI_$lang.txt";
	open(FILE, ">:raw:encoding(UCS2-LE):crlf:utf8", "$fileName");
	print FILE ("\x{FEFF}"); # print BOM
	push(@files,*FILE);
}

while (my $line = <SOURCE>) {
	chomp($line);
	local @buf = split("\t", $line);
	local $key = shift @buf;
	
	next unless $key and $key =~ /^\$/;

	local $i=0;

	foreach $file (@files) {
		local $str = $buf[$i] ? $buf[$i] : $buf[0]; # fall back to english if no translate present
		print $file ($key . "\t" . $str . "\n") unless $str eq "\$";
		$i++;
	}
}
close(SOURCE);

foreach $file (@files) {
	close $file;
}

print "Done.\n\n";

getc(STDIN);
exit(0);