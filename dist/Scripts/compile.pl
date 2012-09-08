#!/usr/bin/perl

sub error
{
	print	"\n=========================\n\n"
		.	"ERROR: $_[0]\n";
	getc(STDIN);
	exit(0);
}

$skyrimPath			= $ENV{'SkyrimPath'} or error("\$SkyrimPath env var not set");
$scriptPath			= $skyrimPath . "\\Data\\Scripts\\Source";
$compilerPath		= $skyrimPath . "\\Papyrus Compiler\\PapyrusCompiler.exe";
$compilerFlagPath	= $scriptPath . "\\TESV_Papyrus_Flags.flg";

# Clean old files
@files = <*.pex>;
foreach $file (@files) {
    unlink($file);
}

# Compile files in Source/
@argList = (
	"$compilerPath",
	"Source",
	"-i=Source; $scriptPath",
	"-o=.",
	"-f=$compilerFlagPath",
	"-op",
	"-all"
);
	
system(@argList) == 0 or error("Compile failed.");