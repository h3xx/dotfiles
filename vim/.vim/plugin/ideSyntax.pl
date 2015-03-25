#!/usr/bin/perl 
##  @file     ideSyntax.pl
#   @brief    Transform a tags file genereated by ctags ide format into a Syntax vim file
#   @details  Usage:
#              @verbatim  ideSyntax.pl [-h|--help] projectname @endverbatim
#   @note     All the properties and options are case insensitive.
#   @author   Daniel Gomez-Prado
#   @version  2.0
#   @date     09/09/2008 03:14:27 PM PDT
#             12/18/2012 08:12:49 PM EST
               
use strict;
use warnings;

# use Shell qw(cat);
use File::Basename;
use Cwd qw(abs_path);
use Tie::File;

# hold the name of the current script file
my $what = $0;
my $root_dir = qx(pwd);	
if($root_dir=~m{^/cygdrive/([A-Za-z])/(.*)}){
	$root_dir = "$1:/$2";
}
if($root_dir=~m{(.*)\n}){
	$root_dir = "$1";
}

# Pre defined color names as shown in 
# http://www.yellowpipe.com/yis/tools/hex-to-rgb/color-converter.php
# website last accessed on Tuesday 18, Dec 2012.
my $aliceblue="#f0f8ff";
my $antiquewhite="#faebd7";
my $aqua="#00ffff";
my $aquamarine="#7fffd4";
my $azure="#f0ffff";
my $beige="#f5f5dc";
my $bisque="#ffe4c4";
my $black="#000000";
my $blanchedalmond="#ffebcd";
my $blue="#0000ff";
my $blueviolet="#8a2be2";
my $brown="#a52a2a";
my $burlywood="#deb887";
my $cadetblue="#5f9ea0";
my $chartreuse="#7fff00";
my $chocolate="#d2691e";
my $coral="#ff7f50";
my $cornflowerblue="#6495ed";
my $cornsilk="#fff8dc";
my $crimson="#dc143c";
my $cyan="#00ffff";
my $darkblue="#00008b";
my $darkcyan="#008b8b";
my $darkgoldenrod="#b8860b";
my $darkgray="#a9a9a9";
my $darkgreen="#006400";
my $darkgrey="#a9a9a9";
my $darkkhaki="#bdb76b";
my $darkmagenta="#8b008b";
my $darkolivegreen="#556b2f";
my $darkorange="#ff8c00";
my $darkorchid="#9932cc";
my $darkred="#8b0000";
my $darksalmon="#e9967a";
my $darkseagreen="#8fbc8f";
my $darkslateblue="#483d8b";
my $darkslategray="#2f4f4f";
my $darkslategrey="#2f4f4f";
my $darkturquoise="#00ced1";
my $darkviolet="#9400d3";
my $deeppink="#ff1493";
my $deepskyblue="#00bfff";
my $dimgray="#696969";
my $dimgrey="#696969";
my $dodgerblue="#1e90ff";
my $firebrick="#b22222";
my $floralwhite="#fffaf0";
my $forestgreen="#228b22";
my $fuchsia="#ff00ff";
my $gainsboro="#dcdcdc";
my $ghostwhite="#f8f8ff";
my $gold="#ffd700";
my $goldenrod="#daa520";
my $gray="#808080";
my $green="#008000";
my $greenyellow="#adff2f";
my $grey="#808080";
my $honeydew="#f0fff0";
my $hotpink="#ff69b4";
my $indianred="#cd5c5c";
my $indigo="#4b0082";
my $ivory="#fffff0";
my $khaki="#f0e68c";
my $lavender="#e6e6fa";
my $lavenderblush="#fff0f5";
my $lawngreen="#7cfc00";
my $lemonchiffon="#fffacd";
my $lightblue="#add8e6";
my $lightcoral="#f08080";
my $lightcyan="#e0ffff";
my $lightgoldenrodyellow="#fafad2";
my $lightgray="#d3d3d3";
my $lightgreen="#90ee90";
my $lightgrey="#d3d3d3";
my $lightpink="#ffb6c1";
my $lightsalmon="#ffa07a";
my $lightseagreen="#20b2aa";
my $lightskyblue="#87cefa";
my $lightslategray="#778899";
my $lightslategrey="#778899";
my $lightsteelblue="#b0c4de";
my $lightyellow="#ffffe0";
my $lime="#00ff00";
my $limegreen="#32cd32";
my $linen="#faf0e6";
my $magenta="#ff00ff";
my $maroon="#800000";
my $mediumaquamarine="#66cdaa";
my $mediumblue="#0000cd";
my $mediumorchid="#ba55d3";
my $mediumpurple="#9370db";
my $mediumseagreen="#3cb371";
my $mediumslateblue="#7b68ee";
my $mediumspringgreen="#00fa9a";
my $mediumturquoise="#48d1cc";
my $mediumvioletred="#c71585";
my $midnightblue="#191970";
my $mintcream="#f5fffa";
my $mistyrose="#ffe4e1";
my $moccasin="#ffe4b5";
my $navajowhite="#ffdead";
my $navy="#000080";
my $oldlace="#fdf5e6";
my $olive="#808000";
my $olivedrab="#6b8e23";
my $orange="#ffa500";
my $orangered="#ff4500";
my $orchid="#da70d6";
my $palegoldenrod="#eee8aa";
my $palegreen="#98fb98";
my $paleturquoise="#afeeee";
my $palevioletred="#db7093";
my $papayawhip="#ffefd5";
my $peachpuff="#ffdab9";
my $peru="#cd853f";
my $pink="#ffc0cb";
my $plum="#dda0dd";
my $powderblue="#b0e0e6";
my $purple="#800080";
my $red="#ff0000";
my $rosybrown="#bc8f8f";
my $royalblue="#4169e1";
my $saddlebrown="#8b4513";
my $salmon="#fa8072";
my $sandybrown="#f4a460";
my $seagreen="#2e8b57";
my $seashell="#fff5ee";
my $sienna="#a0522d";
my $silver="#c0c0c0";
my $skyblue="#87ceeb";
my $slateblue="#6a5acd";
my $slategray="#708090";
my $slategrey="#708090";
my $snow="#fffafa";
my $springgreen="#00ff7f";
my $steelblue="#4682b4";
my $tan="#d2b48c";
my $teal="#008080";
my $thistle="#d8bfd8";
my $tomato="#ff6347";
my $turquoise="#40e0d0";
my $violet="#ee82ee";
my $wheat="#f5deb3";
my $white="#ffffff";
my $whitesmoke="#f5f5f5";
my $yellow="#ffff00";
my $yellowgreen="#9acd32";

# choose the colors for your GUI from the values above 
# or provide the hexadecimal number directly.
my $colorTypeNamePublic = $turquoise;
my $colorTypeNameProtected = $mediumturquoise;
my $colorTypeNamePrivate = $darkturquoise;
my $colorFunctionPublic = $tomato;
my $colorFunctionProtected = $coral;
my $colorFunctionPrivate = $chocolate;
my $colorMemberPublic = $palegreen;
my $colorMemberProtected = $mediumaquamarine;
my $colorMemberPrivate = $mediumseagreen;
my $colorVariablePublic = $tan;
my $colorVariableProtected = $sandybrown;
my $colorVariablePrivate = $peru;


my $HELP = <<EOF
  Usage: 
	  $what
  Description:
	  $what transforms the IDE generated tags file for project-name into a vim syntax file
EOF
;

my $ide = "";
my $tagfile = "";
my $syntaxfile = "";

# Start executing the script or show the help
if( @ARGV == 1 ){
	my $opt = $ARGV[0];
	if ($opt=~m/^--help$/ || $opt=~m/^-h$/) {
		print $HELP;
		exit 1;
	} else {
		$ide = $opt;
		$tagfile = "$opt.ide.tags";
		$syntaxfile = "$opt.ide.syntax"
	}
} else {
	print $HELP;
	exit 1;
}

main();

sub get_priority {
	my $item;
	($item) = @_;
	if ($item=~m{class}){
		return 2;
	} elsif ($item=~m{member}){
		return 1;
	} else {
		return 0;
	}
}

sub check_priority {
	my $old;
	my $new;
	($old,$new) = @_;
	# CASE 1
	#   class has priority over prototypes/functions and members (etc)
	#   this resolves constructor/destructor re-coloring a class type
	# CASE 2
	#   member has priority over prototypes and functions (etc)
	#   this resolves multi-line constructor raw initialization 
	if ( get_priority($old) < get_priority($new) ) {
		#UPDATE necessary
		return 1;
	} else {
		return 0;
	}
}

sub main  {
	open INPUT, "< $tagfile" or die "Error: run ctags first\n";
	open OUTPUT, "> $syntaxfile" or die "ERROR: Can't open $syntaxfile for insertion, please check permissions\n";	
	my %syntax_table;
	while (<INPUT>) {
		my $current_item = $_;
		if( ($current_item=~m{^!.*}) || ($current_item=~m{^~.*}) || ($current_item=~m{^operator.*}) ) {
			# ignore tag comments, c++ destructors, operators
		} else {
			my $keyword = "";
			my $kind = "";
			my $access = "none";
			if( $current_item=~m{^([^\t]*)\t.*} ) {
				$keyword = $1;
			}
			if( $current_item=~m{.*\taccess:([^\t\n]*)\t.*$} ) {
				$access = $1;
			} elsif( $current_item=~m{.*\taccess:([^\t\n]*)$} ) { 
				$access = $1;
			}
			if( $current_item=~m{.*\tkind:([^\t\n]*)\t.*} ) {
				$kind = $1;
			} elsif( $current_item=~m{.*\tkind:([^\t\n]*)$} ) {
				$kind = $1;
			}
			if( !exists($syntax_table{$keyword}) || (exists($syntax_table{$keyword}) && check_priority($syntax_table{$keyword}{"kind"},$kind)) ) {
				$syntax_table{$keyword} = { 'kind' => $kind, 'access' => $access };
			}
		}
	}
	close INPUT;

	print OUTPUT "\" IDE syntax file for project $ide\n";
	print OUTPUT "\" Language   : C++ special highlighting for classes and methods\n";
	print OUTPUT "\" Author     : Daniel F. Gomez-Prado\n";
	print OUTPUT "\" Last Change: 2009 Oct 3\n";
	print OUTPUT "\n";
	print OUTPUT "if exists(\"b:current_syntax\")\n";
	print OUTPUT "\truntime! syntax/cpp.vim\n";
	print OUTPUT "\tunlet b:current_syntax\n";
	print OUTPUT "endif\n";
	print OUTPUT "\n";
	#my $count = 0;
	my @syntax_table_sorted = sort keys %syntax_table;
	my %group_table;
	foreach my $key (@syntax_table_sorted) {		
		my $group = "IDE_$ide"."_$syntax_table{$key}{'kind'}";
		if ( !($syntax_table{$key}{'access'} eq "none") ) {
			$group = "$group"."_$syntax_table{$key}{'access'}";
		}
		if( exists($group_table{$group}) ) { 
			$group_table{$group} = $group_table{$group}." ".$key;
		} else {
			$group_table{$group} = $key;
		}
		#print "$key | $syntax_table{$key}{'kind'} | $syntax_table{$key}{'access'}\n"; 
		#print "$group -> $key\n";
		#$count++;
	}
	my @group_table_sorted = sort keys %group_table;
	foreach my $atgroup (@group_table_sorted) {		
		print OUTPUT "syntax keyword $atgroup\t\t$group_table{$atgroup}\n";
		print OUTPUT "syntax cluster IDE_Cluster_$ide add=$atgroup\n"
		#print "$atgroup -> $group_table{$atgroup}\n";
	}
	my $boldterm = "cterm=bold term=bold gui=bold";

	print OUTPUT "\n";
	print OUTPUT "highlight default IDE_$ide"."None NONE\n";
	print OUTPUT "highlight default IDE_$ide"."TypeName $boldterm ctermfg=6 guifg=$colorTypeNamePublic\n";
	print OUTPUT "highlight default IDE_$ide"."TypeNamePublic $boldterm ctermfg=6 guifg=$colorTypeNamePublic\n";
	print OUTPUT "highlight default IDE_$ide"."TypeNameProtected $boldterm ctermfg=6 guifg=$colorTypeNameProtected\n";
	print OUTPUT "highlight default IDE_$ide"."TypeNamePrivate $boldterm ctermfg=6 guifg=$colorTypeNamePrivate\n";
	print OUTPUT "highlight default IDE_$ide"."Function $boldterm ctermfg=3 guifg=$colorFunctionPublic\n";
	print OUTPUT "highlight default IDE_$ide"."FunctionPublic $boldterm ctermfg=3 guifg=$colorFunctionPublic\n";
	print OUTPUT "highlight default IDE_$ide"."FunctionProtected $boldterm ctermfg=3 guifg=$colorFunctionProtected\n";
	print OUTPUT "highlight default IDE_$ide"."FunctionPrivate $boldterm ctermfg=3 guifg=$colorFunctionPrivate\n";
	print OUTPUT "highlight default IDE_$ide"."Member $boldterm guifg=$colorMemberPublic\n"; 
	print OUTPUT "highlight default IDE_$ide"."MemberPublic $boldterm guifg=$colorMemberPublic\n";
	print OUTPUT "highlight default IDE_$ide"."MemberProtected $boldterm guifg=$colorMemberProtected\n";
	print OUTPUT "highlight default IDE_$ide"."MemberPrivate $boldterm guifg=$colorMemberPrivate\n";
	print OUTPUT "highlight default IDE_$ide"."Variable guifg=$colorVariablePublic\n";
	print OUTPUT "highlight default IDE_$ide"."VariablePublic guifg=$colorVariablePublic\n";
	print OUTPUT "highlight default IDE_$ide"."VariableProtected guifg=$colorVariableProtected\n";
	print OUTPUT "highlight default IDE_$ide"."VariablePrivate guifg=$colorVariablePrivate\n";
	print OUTPUT "highlight default link IDE_$ide"."Constant PreProc\n";
	#print OUTPUT "highlight default IDE_$ide"."Constant cterm=bold term=bold gui=bold guifg=Magenta\n";
	print OUTPUT "\n";
	foreach my $atgroup (@group_table_sorted) {		
		print OUTPUT "highlight def link $atgroup \t IDE_$ide";
		my $item = "";
		my $type = "";
		if ($atgroup=~m{IDE_(.*)_(.*)_(.*)}) {
			$item = $2;
			$type = $3;
		} elsif ($atgroup=~m{IDE_(.*)_(.*)}) {
			$item = $2;
		}
		if (($item eq "class") || ($item eq "typedef") || ($item eq "enum") || ($item eq "struct") || ($item eq "namespace")) {
			print OUTPUT "Typename";
		} elsif (($item eq "prototype") || ($item eq "function")) {
			print OUTPUT "Function";
		} elsif ($item eq "variable") {
			print OUTPUT "Variable";
		} elsif ($item eq "member") {
			print OUTPUT "Member";
		} elsif (($item eq "macro") || ($item eq "enumerator")) {
			print OUTPUT "Constant";
		} else {
			print OUTPUT "None";
		}
		if ($type eq "private") {
			print OUTPUT "Private";
		} elsif ($type eq "protected") {
			print OUTPUT "Protected";
		} elsif ($type eq "public") {
			print OUTPUT "Public";
		}
		print OUTPUT "\n";
	}
	print OUTPUT "\n";
	print OUTPUT "let b:current_syntax = \"IDE_$ide\"\n";
	close OUTPUT;
	#print "There are $count elements\n"
}

