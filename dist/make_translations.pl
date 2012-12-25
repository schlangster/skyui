#!/usr/bin/perl

sub error
{
	print	"\n=========================\n\n"
		.	"ERROR: $_[0]\n";
	getc(STDIN);
	exit(1);
}
#!/usr/bin/perl

my $translationsPath = ".\\Data\\Interface\\translations";
my $sourcePath = $translationsPath . "\\SkyUI_Translations.tsv";

print "=== Updating translation files...\n\n";
open SOURCE, "<:utf8", $sourcePath or error("Cannot open $sourcePath: $!");

# No wait?
$noWait = defined($ARGV[0]);

my @langs = split("\t", <SOURCE>);
shift @langs;

my @files;

foreach $lang (@langs) {
	chomp($lang);
	$lang = lc($lang);
	local *FILE;
	local $fileName = $translationsPath . "\\SkyUI_$lang.txt";
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
		print $file ($key . "\t" . $buf[$i] . "\n") if $buf[$i];
		$i++;
	}
}
close(SOURCE);

foreach $file (@files) {
	close $file;
}

print "Done.\n\n";

getc(STDIN) unless $noWait;
exit(0);