#!/usr/bin/perl
#$
#$=head1 NAME
#$
#$ratfor90 -ratfor for fortran90
#$
#$=head1 SYNOPSIS
#$
#$ratfor90  <infile >outfile -sep -SOURCE=source
#$
#$=head1 INPUT PARAMETERS
#$
#$=over 4
#$
#$=item sep - flag 
#$
#$      [-sep]  perform saw functionality,includes from and to 
#$      (history,aux,either,par)
#$
#$=item -DSOURCE - flag 
#$
#$       [-DSOURCE=sourcefile] source file, enables 
#$       automatic writing of self-doc routine 
#$
#$=back
#$
#$
#$=head1 DESCRIPTION
#$
#$ Convert ratfor code to strict fortran90. Also allows sep conventions
#$ and loptran conventions.
#$
#$=head1 CATEGORY
#$
#$B<tools>
#$
#$
#$=cut
#
# Author: Robert G. Clapp
# Stanford Exploration Project 
# Stanford University 




system("touch ratfor_problem;rm ratfor_problem");#REMOVE OLD RATFOR_PROBLEM file
#RED

&parse_args;        #read and interpret user arguments
&read_in_code;      #read in  code

#RED Just remove any % in column 1.  This was intended for ratfor(77) to 
#    just pass the line as is - may have to do this here but will first 
#    attempt simple remove at beginning
for($i1=0;$i1<@lines;$i1++) {
	if(index($lines[$i1],"%",0) == 0 ) {
#		print STDERR "Before: $lines[$i1]\n";
		$line=substr($lines[$i1],1,length($lines[$i1])-1);
		$lines[$i1]=$line;
	}
}
&quote_comment_parse;  #replace all the quotes and comments
&initial_parse;     #take care of C equivilants and line continuations
&parse_semi_colons; #hit return after semi-colons for
if($SEP==1){ #if  we are using sep saw/sat conventions
	if($clop>0){ &run_lop;}
	&convert_sep2; #saw  conventions
	#loptran       #and loptran conventions here
}
	

&pre_process_program; #CHANGE SPACING, SIMPLE SUBSITIONS, ETC
&check_line_breaks;  #TRIES TO MERGE LINES THAT BELONG TOGETHER
&fix_if_else; #hit return after some else statements, etc
&extend_syntax; #ALLOWS +=, -=
&insert_brackets;#ADD BRACKETS BASED ON C-LIKE DEFINITION OF LINE

&change_spacing; #INDENT PROGRAM
&replace_brackets; #REPLACE BRACKETS WITH CORRESPONDING THEN,END STATEMETNS
&check_implicit2; #ADD IN IMPLICIT NONES IN THE RIGHT PLACES
&post_program_parse; #FINISH UP REPLACE COMMENTS,ETC
print STDOUT "$program \n";

#UPDATED TO THIS POINT

   

########################################################################
########################################################################
########################################################################
#############################SUBROUTINES################################
########################################################################
########################################################################
########################################################################



##############################################################
####################     parse_args      #####################
##############################################################

sub parse_args{

$selfdoc='
ratfor90  [-sep] [-DSOURCE=file.r] <infile >outfile
	-sep = perform saw functionality,includes from and to (history,aux,either,par)
	-SOURCE= source file, enables automatic writing of self-doc routine
'; 

if( $#ARGV > 2 ) { print $selfdoc,"\n"; exit; }

$i1=0; $SEP=0; $F_SOURCE=0;$lop_type="real"; $beg_lop=""; $lop_fun="_lop"; $GENLABEL=33000;
  while($i1 <= $#ARGV){
    if($ARGV[$i1] eq "-sep"){ $SEP=1;
      $i1= $i1 +1;}
		elsif($ARGV[$i1] eq "-SOURCE"){
      &check_next; $F_SOURCE=1; $SOURCE=$ARGV[$i1+1]; $i1=$i1+2;    
    }
		elsif($ARGV[$i1] =~ /^-DSOURCE=(.+)$/){ $SOURCE=$1;
			$i1=$i1+1;
		}
		elsif($ARGV[$i1] eq "-dcomplex"){
      $lop_type="double complex";$i1= $i1 +1; $beg_lop="dc"; $lop_fun="_dclop";
		}
		elsif($ARGV[$i1] eq "-complex"){
      $lop_type="complex";$i1= $i1 +1; $beg_lop="c";$lop_fun="_clop";
		}
		else{ print STDERR "Invalid argument $ARGV[$i1] \n \n $selfdoc\n"; exit -1 ;}
  }
}
			
##############################################################
####################     check_next      #####################
##############################################################


sub check_next{
  #check to see if the next argument is valid when dealing with two
  #component optionsal

  if($i1+1 == $ARGV[$i1]){
    #in this case there is no second argument we know something is messed up
    print $selfdoc,"\n";
    exit;
  }
  if($ARGV[$i1+1]=~/^-(\S+)$/){
    #in this case the next argument is another - so we know something is wrong
    print $selfdoc,"\n";
    exit;
  }
}

##############################################################
####################    read_in_code     #####################
##############################################################

sub read_in_code{
	#RECURSIVE SUBROUTINE TO READ IN CODE
	if($#_ == -1){
		while (<STDIN>){
			#  2. Attempt removing ^ (begins with) =~ /^\
			#     Result - no change
			# if($_=~ /^\s*include\s*"(\S+)"/oi){

			if($_=~ /^\s*include\s*/oi){
				$depth=0;
				&read_in_code($1);
			}
			else{
				$lines[$il]=$_;
				$il++;
			}
		}
	}
	else{
		$name="AA".$depth;
		$iline=$_;
		$iline=~tr/A-Z/a-z/;
		$apos=index($iline,'include',0);
		$iline1=substr($iline,$apos+7);
		$apos=index($iline1,'#',0);
		if($apos > 0){
			$iline=substr($iline1,0,$apos);
			$iline1=$iline;
		}
		$apos=index($iline1,'!',0);
		if($apos > 0){
			$iline=substr($iline1,0,$apos);
			$iline1=$iline;
		}
		$aquote='"';
		$apos=index($iline1,$aquote,0);
		if($apos > 0){
			substr($iline1,$apos,1)=" ";
			$aapos=index($iline1,'"',0);
			if($aapos > 0){
				substr($iline1,$aapos,1)=' ';
			}
		}
		# open($name,$_[0])
		open($name,$iline1) or
		  print STDERR "Open Failure for $iline1\n Error: $! \n";
		$lines[$il]="!##### Beginning $iline1\n"; $il++;
		while(<$name>){
			if($_=~ /^\s*include\s*/oi){  
				$depth=$depth+1;&read_in_code($1);$depth=$depth-1;$name="AA".$depth;}
			else{ $lines[$il]=$_; $il++;}
		}
		$lines[$il]="!##### End $iline1\n"; $il++;	
		close($name);

	}
}

##############################################################
####################  quote_comment_parse  ###################
##############################################################

sub quote_comment_parse{

$qnum=0; $r77=0;
$cnum=0; $clop=0;
#@lines=split("\n",$program);
$solver=0; $i1=0;

# RED
# The following array contain special values that will be subbed with XsAt<num>
# The actual value will be reinserted in the subroutine reinsert.
# For each special string, specnum should be incremented by 1 
$specnum=0;
$specvalue[$specnum]='!m!m';

while($i1 < @lines){ #loop over the lines

# RED
# Scan the line for any of the special char sequences defined above.
# A given sequence may occur more than once in a line

	for($is=0;$is<=$specnum;$is++){
		$si=index($lines[$i1],$specvalue[$is],0);
		while($si != -1) {
			$ls=length($specvalue[$is]);
			$ll=length($lines[$i1]);
			$hold=substr($lines[$i1],0,$si);
			$hold1=substr($lines[$i1],$si+$ls,$ll-$si-$ls);
			$lines[$i1]=$hold."XsAt".$specnum.$hold1;
			$si=index($lines[$i1],$specvalue[$is],0)
                }
	}
#
# RED  Before processing here, sub special NOT situations
#      Need sub syntax for zero or more blanks
	$lines[$i1]=~ s/\(!/\(.not. /gm;
	$lines[$i1]=~ s/\( !/\(.not. /gm;
	$lines[$i1]=~ s/&&!/&& .not. /gm;
	$lines[$i1]=~ s/&& !/&& .not. /gm;
	$lines[$i1]=~ s/\|\|!/\|\| .not. /gm;
	$lines[$i1]=~ s/\|\| !/\|\| .not. /gm;
	$lines[$i1]=~ s/\|!/\| .not. /gm;
	$lines[$i1]=~ s/\| !/\| .not. /gm;

# RED  If line begins with a label then insert "    continue\n"
#      except for lines containing "format" statement
	
	$line=$lines[$i1];
	$ach=substr($line,0,1); 
        if($ach == "1" || $ach == "2" || $ach == "3" || $ach == "4" || $ach == "5" ||
   	   $ach == "6" || $ach == "7" || $ach == "4" || $ach == "8" || $ach == "9"){
		$line=~ s/\t/ /;
		$apos=index($line," ",0);
		if($apos > -1){
			if(index($line,"format",$apos) == -1) {
				substr($lines[$i1],$apos,0)="     continue\n";
			}
                }
	}


#
	$num=$i1;
	$line=$lines[$i1]; $break=0; 
	
	while($break==0){ #if we haven't finished parsing this line
	
		if($line =~ /"|'|!|\#/oi){
			#in this case we have a possible quote or comment
			$break_it=0;
			$single=index($line,"'",0);
			$double=index($line,'"',0);
			$point=index($line,'!',0);
			$point2=index($line,'!=',0);
			$pound=index($line,'#',0);

			while($point==$point2 && $point != -1){
				$t=$point+1;
				$point=index($line,'!',$t);
				$point2=index($line,'!=',$t);
			}

                        #Figure out the first comment character
                        if($point > -1){
                                if($pound > -1){
                                        if($point > $pound){ $comment="\#"; $cpos=$pound;}
                                        else{ $comment="!"; $cpos=$point;}
                                }
                                else{  $comment="!"; $cpos=$point;}
                        }
                        elsif($pound > -1){  $comment="\#"; $cpos=$pound;}
                        else {$cpos=9999; $comment="!";}
			
		#Figure out the first quote character
		if($single == -1 && $double==-1){ $qpos=9999; $quote="";}
		else{
			if($single == -1) { $qpos=$double; $quote='"';}
			elsif($double==-1){ $qpos=$single; $quote="'";}
			elsif($double < $single ) { $qpos=$double; $quote='"';}
			else{ $qpos=$single; $quote="'";}
		}
		
		
		#FIGURE OUT WHAT COMES FIRST
		if($cpos<$qpos){ #the line is just a comment 
			#life is simple the rest of the line is a comment store in the register
		
			$hold=substr($line,$cpos+1,length($line)-$cpos);
			$comments[$cnum]=substr($line,$cpos+1,length($line)-$cpos);
			if($hold =~ /^\s*%/ ) { 
				if($hold=~ /^%</){ $solver=1;}
				$lop[$clop]=$hold;
				substr($line,$cpos,length($line)-$cpos+1)="@%@".$clop."@%@\n";
				$clop++; $break=1;
			}
			else{
				$comments[$cnum]=$hold;
				substr($line,$cpos,length($line)-$cpos+1)="@<@".$cnum."@>@\n";
				$break=1;  $cnum++; 
			}
		}
 		elsif($qpos!=9999){ #we have a quote
			$pos=index($line,$quote,$qpos+1);
			while($pos==-1){
				$i1++;
		 		if($i1 == @lines){ #we have come to the end of the program without "
				 $lines[$num]="ERROR BEFORE ERROR\n 
           $line \n","ERROR AFTER ERROR \n";
           print STDERR "QUOTE MATCHING PROBLEM \n";
         &crash_it;
				}
		 		$line.=$lines[$i1];
				$line=~s/\s*\n\s*//gm; $line.="\n";
				$lines[$i1]="";
				$pos=index($line,$quote,$qpos+1); 
			}
			#we have found the end of the quote, yeah!

			$quotes[$qnum]=substr($line,$qpos,$pos-$qpos+1);

			substr($line,$qpos,$pos-$qpos+1)="XyAt$qnum";
			$qnum++;
		}
		else{ $break=1;}
	}
	else{ #we didn't find any quotes or comments
		$break=1;
	}
}
	$lines[$num]=$line;
	$i1++;
}
$program=join("",@lines);
}

##############################################################
####################      reinsert       #####################
##############################################################

sub reinsert{
	#reinserts comments and quotes
#RED
#  Added reinsert of any special character sequences that needed to pass as is
#  to avoid possible issues with ratfor90 processing.  See beginning of
#  quote_commente_parse for assign character sequences, etc.

	for($i1=0; $i1 < @lines; $i1++){
		if($lines[$i1]=~ /@<@(\d+)@>@/){ $fill=$1;
			$exp="@<@".$fill."@>@";
			$lines[$i1]=~s/$exp/!$comments[$fill]/gm;
		}
		if($lines[$i1]=~ /@%@(\d+)@%@/){ $fill=$1;
			$exp="@%@".$fill."@%@";
			$lines[$i1]=~s/$exp//gm;
		}
		if($lines[$i1]=~ /XyAt/){ $logic=1;
			while($logic==1){
                                if($lines[$i1]=~ /XyAt(\d+)/){ $fill=$1;
					# RED removed g in /gm to keep from more
					#     than one sub at a time.  Example 
					#     problem: XyAt1 and XyAt10 had
					#     XyAt1 subbed.
                                        $lines[$i1]=~s/XyAt$fill/$quotes[$fill]/m;
                                }
                                else{$logic=0;}
			}
		}
#RED Special char sequences
		if($lines[$i1]=~ /XsAt/){ $logic=1;
			while($logic==1){
				if($lines[$i1]=~ /XsAt(\d+)/){ $fill=$1;
					$lines[$i1]=~s/XsAt$fill/$specvalue[$fill]/m;
				}
				else{$logic=0;}
			}
			
		}
	}
}
	

##############################################################
####################      crash_it       #####################
##############################################################

sub crash_it{
	&reinsert;
	$program=join("\n",@lines);	
	$program=~s/\n\s*\n+/\n/gm;
	print STDERR "wrote file as far as I got to ratfor_problem\n";
	open(TEMP,">ratfor_problem");
	print TEMP $program;
	close (TEMP);
	system("sleep 3");
	print STDOUT " $program \n";;
	exit(3);
}

##############################################################
####################   initial_parse     #####################
##############################################################

sub initial_parse{
	#DEALS WITH LINE CONTINUATION, C equivs, COMMENTS

	#replace c equivilants
	$program=~s/==/.eq./gm;
	$program=~s/!=/.ne./gm;
	$program=~s/==/.eq./gm;
#RED    Added sub for <= >=
	$program=~s/<=/.le./gm;
	$program=~s/>=/.ge./gm;
	$program=~s/\|\|/.or./gm;
	
	# Added change of single | to or
	$program=~s/\|/.or./gm;
	$program=~s/&&/.and./gm;
	# Added change of single & to and
	$program=~s/&/.and./gm;

	#explicit line continuations
	$program=~s/&\s*\n//gm;
	$program=~s/_\s*\n//gm;
		
	#end of lines with  +,-,,,*,/  add the next line to it
	$program=~ s/[&_]\s*\n\s*//gm;
	$program=~ s/\*\s*\n\s*/\*/gm;
	$program=~ s/-\s*\n\s*/-/gm;
	$program=~ s/\+\s*\n\s*/\+/gm;
	$program=~ s/,\s*\n\s*/,/gm;

	@lines=split("\n",$program);
}

##############################################################
####################  parse_semi_colons  #####################
##############################################################

sub parse_semi_colons{
	#hit return after ; except in the case of for loops
	$i1=0; while($i1 < @lines){
#		if($lines[$i1] =~/[\s*|^]for\s*\(/oi) { 
		if($lines[$i1] =~/^for\s*\(/oi || $lines[$i1] =~ /\s+for\s*\(/) { 
			$line=$lines[$i1]; $hold=$i1;
			$pos=0; $logic=0;
			while($logic==0){
				$first=index($line,"for",$pos); 
				if($first != -1){
					$bracket=index($line,"(",$first)+1;
					&find_paren;
					$pos=$close;
				}
				else {
					@string=split("",$line);
					for($i=$pos; $i<@string; $i++){
							if($string[$i] eq ";"){ $string[$i]="\n";}
					}
					$logic=1;
				}
			}
			$lines[$i1]=$line;
		}
		else{ $lines[$i1]=~ s/;/\n/gm;}
		$i1++;
	}
	$program=join("\n",@lines);
}
							

##############################################################
####################     find_paren      #####################
##############################################################

sub find_paren{
	#find the ) to match a ( specified by 
	$level=1;
	while($level >0){
			$open=index($line,"(",$bracket);
			$close=index($line,")",$bracket);
			if($open==-1) {$open=9999;}
			if($close==-1) {$close=9999;}
			if($open==9999 && $close == 9999){
				$i1++;
				if($i1==@lines){
				 	$lines[$hold]="ERROR BEFORE ERROR\n 
           $lines[$hold] ERROR AFTER ERROR \n";
					print STDERR "CAN'T FIND CLOSE OPEN FOR (\n";
					&crash_it;
				}
				$line.=$lines[$i1];
				$line=~s/\s*\n\s*//gm; $line.="\n";
			}
			elsif($open < $close) { $level++; $bracket=$open+1;}
			else{ $level--; $bracket=$close+1;}
	}
	for($i=$hold; $i <= $i1 ; $i++){ $lines[$i]="";}
}


##############################################################
####################      run_lop        #####################
##############################################################

sub run_lop{
	#converts SEP program writing convention styles to strict ratfor
	if($program =~ /\n\s*module\s+/oi){ &run_module_lop;}
	elsif($program =~ /^\s*module\s+/oi){ &run_module_lop;}
	elsif ($solver==0){ 
		if($program =~ /^\s*program/){}
		elsif($program =~ /\n\s*program/){}
		else{&ratfor_77;}
	}
	if($solver==1){ &run_solver_lop;}

}

##############################################################
####################   run_solver_lop    #####################
##############################################################

sub run_solver_lop{
@lines=split("\n",$program); $i1=0; $begin=0;
while($i1 < @lines){
		if($lines[$i1]=~/^\s*@%@(\d+)@%@/){ $num=$1;
			if($lop[$num] =~ /^%<(.+)$/){ 
				$expression=$1;  $logic=0;
				$expression=~ s/!=/\/=/gm;
				$expression=~ s/#.+//gm;
				$expression=~ s/!.+//gm; $ia=$i1+1;
				while($ia < @lines && $logic==0){
					if($lines[$ia]=~/^\s*$/){$ia++;}
					elsif($lines[$ia] =~ /^\s*@%@(\d+)@%@/){ $num=$1;
						if($lop[$num] =~ /^%<(.+)$/){
							$expression.=": $1";   $logic=0;
        			$expression=~ s/!=/\/=/gm;
        			$expression=~ s/#.+//gm;
        			$expression=~ s/!.+//gm;    
						}
						$ia++;
					}
					else{$ia--;$logic=1;}
				}
				&parse_expression; $i1=$ia;
			}
		}
		$i1++;
	}
$program=join("\n",@lines);
}
					



##############################################################
####################   parse_expression  #####################
##############################################################

sub parse_expression{
@solver_args=("oper","solv", "data", "x", "niter",
 "prec", "nprec", "eps", "reg","nreg",
 "x0","nmem","nfreq","err","res","xp","nloper","xmov",
  "rmov","wght","verb","known","wt");


$nreq=10;
$wt="";
my $decs = join("|^\\s*",@solver_args);

@required=("data","x","niter","oper");
for($i=0; $i < @solver_args; $i++){ $solve{$solver_args[$i]}="";}

$argument_list=$expression;
&split_argument_list2;
if($list[0] =~ /\s*(0)\s*=\s*(\S.+)$/){ $left=$1; $right=$2;}
elsif($list[0] =~ /\s*(\w+)\s*=\s*(\S.+)$/){ $left=$1; $right=$2;}
else{ 
	print STDERR "trouble parsing your solver statement. The first \n",
"part must be your operator statement eq d = A m \n $line[0] \n";
	$lines[$i1]="ERROR BEFORE ERROR \n".$list[0]."\n ERROR AFTER ERROR \n";
	&crash_it;
}
if($left=~/^0$/){
	if($right =~ /(.*)\((.+)\)/){ $wt=$1; $middle=$2;}
	else {$middle=$right; $wt="";}
	if($middle=~/^\s*(\w+)\s*-\s*(.+)\s*$/){ $solve{"data"}=$1; $oper=$2;}
	elsif($middle=~/^\s*(\w+)\s*\+(.+)\s*$/){ $solve{"data"}=-$1; $oper=$2;}
}
else{ $solve{"data"}=$left; $oper=$right;}
@funs=split(/\s+/,$oper);
if($#funs==1){  $solve{"oper"}=$funs[0]; $solve{"x"}=$funs[1];}
elsif($#funs==2){ 
 $solve{"oper"}=$funs[0]; $solver{"prec"}=$funs[1];$solve{"x"}=$funs[2];}
else{
	print STDERR "trouble parsing your solver statement. The first ",
	"part must be your operator statement eq d = A m or d = A  P m \n $oper \n";
	$lines[$i1]="ERROR BEFORE ERROR \n".$list[$0]."ERROR AFTER ERROR \n";
	&crash_it;
}


for($i=1; $i < $nlist; $i++){
	if($list[$i]=~/^\s*($decs)\s*=\s*(.+)\s*$/){$p1=$1; $p2=$2; $p1=~s/\s+//gm; $p2=~s/\s+//gm; $solve{$p1}=$p2; }
	elsif($list[$i]=~/^\s*0\s*=(.+)$/){ $reg=$1;
		if($reg=~/^\s*(\w+)\s*(\w+)\s*(\w+)\s*$/){ $eps=$1; $reg=$2; $mod=$3;}
		elsif($reg=~/^\s*(\w+)\s*(\w+)\s*$/){ $eps=""; $reg=$2; $mod=$3;}
		else{
			print STDERR "Unrecognized regularization equation.",
			"must be of the form 0 = eps reg mod or 0 = reg mod \n";
			$lines[$i1]="ERROR BEFORE ERROR \n".$list[$i]."ERROR AFTER ERROR \n";
			&crash_it;
		}
		if($mod ne $solve{"x"}){ 
			print STDERR "Unrecognized regularization equation.",
			"must be of the form 0 = eps reg mod or 0 = reg mod \n";
			$lines[$i1]="ERROR BEFORE ERROR \n".$list[$i]."ERROR AFTER ERROR \n";
			&crash_it;
		}
		else{ $solve{"eps"}=$eps; $solve{"reg"}=$reg;}
	}
	else{
		print STDERR "Unrecognizable solver statement.\n $list[$i] \n";
		$lines[$i1]="ERROR BEFORE ERROR \n".$list[$i]."\n ERROR AFTER ERROR \n";
		&crash_it;
	}
}
for($i=0;$i<@required;$i++){
	if($solve{$required[$i]} =~ /^\s*$/){
		print STDERR "You must supply  $required[$i] \n";
		$lines[$i1]="ERROR BEFORE ERROR \n".$expression."ERROR AFTER ERROR \n";
		&crash_it;
	}
}
if($solve{"reg"} =~/\S+/){  $solver="solver_reg";
	if($solve{"nreg"} eq ""){ $solve{"nreg"}= "size(".$solve{"x"}.")";}
}
elsif($solve{"prec"} =~/\S+/){  $solver="solver_prec";
	if($solve{"nprec"} eq ""){ $solve{"nprec"}= "size(".$solve{"x"}.")";}
}
else{$solver="solver";}

if($solver ne "solver" && $solve{"eps"} eq ""){
	print STDERR "You must supply  eps \n",
	$lines[$i1]="ERROR BEFORE ERROR \n".$expression."ERROR AFTER ERROR \n";
	&crash_it;
}

if($wt ne ""){
	if($solve{"nmem"} ne ""){ $solve{"wght"}=$wt;}
	else { $solve{"wt"}=$wt;}
}

if($solve{"solv"} eq ""){ $solve{"solv"}="cgstep";}
$lines[$i1]="call $solver (".$solve{"oper"}.",".$solve{"solv"};
if($solver eq "solver_reg"){ $lines[$i1].=", $solve{'reg'}, $solve{'nreg'}";}
if($solver eq "solver_preq"){$lines[$i1].=", $solve{'prec'},$solve{'nprec'}";}
$lines[$i1].=",$solve{'x'}, $solve{'data'}, $solve{'niter'}";
if($solver ne "solver"){ $lines[$i1].=",$solve{'eps'}";}
for($i=$nreq; $i <  @solver_args; $i++){
	if($solve{$solver_args[$i]} ne ""){ 
		$lines[$i1].=",$solver_args[$i] =".$solve{$solver_args[$i]};
	}
}
$lines[$i1].=")";
}



##############################################################
####################   run_module_lop    #####################
##############################################################

sub run_module_lop{
	$nallocate=0;
	@lines=split("\n",$program);
	my @declarations=("real", "integer", "complex", "logical", "type\\s*\\(\\s*\\S+\\s*\\)");
	my $decs = join("|^\\s*",@declarations);
	$ndec=0; 

	#program to convert Sergey's loptran standarards to ratfor
	$in_mod=-1; $dec_begin=0;  $mod_level=0; $in_lop==0;
	for($i1=0; $i1 < @lines; $i1++){
		$_=$lines[$i1];
		if($lines[$i1]=~/{/){ $mod_level+=tr/{//;}
		if($lines[$i1] =~/}/){$mod_level-=tr/}//;}
		if($lines[$i1]=~/^\s*module\s+([^\s\!]+)/){ 
			$module=$1; $in_mod=$i1; $lines[$i1].="\n use $beg_lop"."adj_mod\n";
			$hit_sub=0; $nmod_args=0; $begin=""; $close=0;
		}
		if($lines[$i1]=~/^\s*subroutine\s*\(/){ &funish_lop_unit;}
		if($lines[$i1]=~/^\s*function\s*\(/){&funish_lop_unit;}
		if($lines[$i1]=~/^(.+)function\s*\(/){
			if($1 =~ /^$decs/){ &funish_lop_unit;}
		}
		if($lines[$i1]=~/^\s*@%@(\d+)@%@/){ $num=$1;
			if($lop[$num] =~ /^%\s*$lop_fun/){ &funish_lop_unit; &do_lop;}
			elsif($lop[$num] =~/%\s*_init/){ &funish_lop_unit; &do_init;}
			elsif($lop[$num] =~/%\s*_close/){ &funish_lop_unit; &do_close;}
		}
		if($in_mod != -1 && $hit_sub==0){
			if($lines[$i1] =~ /^\s*$decs\s*[\s\S]+$/){
			if($lines[$i1] =~ /^(.*\S)\s*@<@/){$lines[$i1]=$1;}
			if($lines[$i1] =~ /^\s*($decs)\s*([\s\S]+)$/){$type=$1; $rest=$2;}
				$dlines[$ndec]=$i1; $ndec++;
				if($rest =~ /^\s*,(.+)::\s*(\S.*)$/){ 
					$args=$1; $argument_list=$2;
				}
				elsif( $rest =~ /^\s*::\s*(.+)$/){ $argument_list=$1; $args="";}
				else{ $argument_list=$rest; $args="";}	
				$argument_list=~s/\s+$//gm;
				&split_argument_list;


				if($args=~ /allocatable/){	
					if($args =~/dimension\s*\((.+)\)/){ $dims=$1; 
						@string=split("",$dims); $ct=0;$exp=":";
						for($j=0; $j < @string; $j++){
							if($string[$j] eq "(") { $ct++;}
							elsif($string[$j] eq ")") { $ct--;}
							elsif($ct==0 && $string[$j] eq ","){ $exp.=",:";}
						}
						$dim=$dims;
						$dim=~ s/\*/\\\*/gm; $dim=~ s/\+/\\\+/gm;
						$dim=~ s/\(/\\\(/gm; $dim=~ s/\)/\\\)/gm;
						$args=~ s/$dim/$exp/gm;
						$got=1;
				}
				else{ $got=0;}
				}

				for($i=0; $i < $nlist; $i++){
				if($args=~ /allocatable/){
					if($got==0){
						if($list[$i] =~/\((.+)\)/){ $dims=$1; 
							@string=split("",$dims); $ct=0;$exp=":";
							for($j=0; $j < @string; $j++){
								if($string[$j] eq "(") { $ct++;}
								elsif($string[$j] eq ")") { $ct--;}
								elsif($ct==0 && $string[$j] eq ","){ $exp.=",:";}
							}
							$dim=$dims;
							$dim=~ s/\*/\\\*/gm; $dim=~ s/\+/\\\+/gm;
							$dim=~ s/\(/\\\(/gm; $dim=~ s/\)/\\\)/gm;
							$pre=$list[$i]; $list[$i]=~ s/$dim/$exp/gm;
						}
						else{ 
							print STDERR "Trouble parsing module allocatable statement\n";
							$lines[$i1]="ERROR BEFORE ERROR ERROR\n".$lines[$i1]."
             ERROR AFTER ERROR  \n";
							&crash_it;	
						}
					}
					else { $pre=$list[$i];}
					$begin.="if (.not. allocated($list[$i])) allocate($pre ( $dims)) \n";
					$allocate[$nallocate]=$list[$i];$nallocate++;
					}
					if($list[$i] =~ /(\S+)(\S\(.+\))/){
						$list[$i1]=$1;
						$options{$list[$i]}="$args , dimension".$2;
					}
					else { $options{$list[$i]}=$args;}
					$line_num{$list[$i]}=$i1;
					$argum{$list[$i]}=$type;
					$mod_args[$nmod_args]=$list[$i];$nmod_args++;
					$found{$list[$i]}=0;
				}
				$lines[$i1]="";
			}
		}
		if($mod_level==0 && $in_mod !=-1){ &finish_mod;}
	}
	$program=join("\n",@lines);
}

##############################################################
####################      funish_lop_unit    #################
##############################################################

sub funish_lop_unit{
	#just put a close bracket
	if($in_lop==1){ $lines[$i1-1].="}\n";$in_lop=0;}
	if($in_init==1){ $lines[$i1-1].="\n}\n"; $in_init=0;}
	if($in_close==1){ $lines[$i1-1].="\n}\n"; $in_close=0;}
	if($hit_sub==0){ 
		$hit_sub=1; $lines[$i1]="contains \n $lines[$i1]";}

}

##############################################################
####################      do_close           #################
##############################################################

sub do_close{
	#just put a close bracket
	$close=1;
	$lines[$i1].="\n subroutine  $module"."_close(){ \n";
	$in_close=1;
	if($nallocate>0){
		$lines[$i1].="deallocate( $allocate[0] "; 
		for($a=1;$a<$nallocate;$a++){ $lines[$i1].=",$allocate[$a]";}
		$lines[$i1].=")\n";
	}
}

##############################################################
####################        do_lop       #####################
##############################################################

sub do_lop{
	if($lop[$num]=~/^\s*%\s*($lop_fun\S*)\s*\(\s*(.+)\)\s*$/){
		$name=$module.$1;$argument_list=$2;	
		$mod=0; $ct=0;$model="";$data="";
		&split_argument_list;
		$model=$list[0];$data=$list[1];
		if($model=~/(\S+)\s*(\(.+\))/){$model=$1; $model_dim=$2;}
		else {$model_dim="(:)";}
		if($data=~/(\S+)\s*(\(.+\))/){$data=$1; $data_dim=$2;}
		else {$data_dim="(:)";}
	
		if($nlist !=2){
			print STDERR "ERROR ERROR trouble parsing lop statement1\n";
			$lines[$i1]="ERROR ERROR BEFORE ERROR ERROR\n".$lines[$i1]."ERROR ERROR AFTER ERROR ERROR\n";
			&crash_it;
		}
		$lines[$i1].="\n function $name ( adj, add, $model, $data) result(stat){ \n";
		$lines[$i1].="integer            :: stat \n";
		$lines[$i1].="logical,intent(in) :: adj,add \n";
		$lines[$i1].="$lop_type,dimension(:)  :: $model,$data \n";
		$lines[$i1].="call $beg_lop"."adjnull (adj,add,$model,$data )\n";
		$lines[$i1].="call $name"."2"."(adj,$model,$data )\n";
		$lines[$i1].="stat=0 \n}\n";
		$lines[$i1].="subroutine $name"."2"."(adj,$model,$data){\n";
		$lines[$i1].="logical,intent(in) :: adj \n";
		$lines[$i1].="$lop_type, dimension $model_dim  :: $model \n";
		$lines[$i1].="$lop_type, dimension $data_dim  :: $data \n";
	}
	else{
		print STDERR "ERROR ERROR trouble parsing lop statement2 --$lop[$num] -- \n";
		$lines[$i1]="ERROR ERROR BEFORE ERROR ERROR\n".$lines[$i1]."ERROR ERROR AFTER ERROR ERROR\n";
		&crash_it;
	}
	$in_lop=1;
}

##############################################################
####################        do_init      #####################
##############################################################

sub do_init{
	#create the init file

	my @declarations=("real", "integer", "complex", "logical", "type\\s*\\(\\s*\\S+\\s*\\)","@<@","optional");
	my $decs = join("|^\\s*",@declarations);

	$ihold=$i1+1; $logic=0;
	while($logic==0){	
		if($lines[$ihold] =~ /^\s*$decs/){$ihold++;}
		elsif($lines[$ihold] =~ /^\s*interface/){  $ihold++;
#			print STDERR "this is it $lines[$ihold-1] \n";
			if($lines[$ihold-1] =~/{/){ $ct=1; 
				while($ct>0){
					if($lines[$ihold]=~/{/){ $ct++;}
					elsif($lines[$ihold]=~/}/){ $ct--;}
					$ihold++;
				}
			}
			else{ $l2=0;
				while($l2==0){
				if($lines[$ihold] =~ /^\s*end\s+interface/){$l2=1; $ihold++;}
				else{$ihold++;}
			}
		}}
		else{$logic=1;}
	}
	$ihold--;



	$d=""; $extra="";
	if($lop[$num]=~/^\s*%\s*(_init\S*)\s*\(\s*(.+)\s*\)\s*$/){
		$name=$module.$1;$argument_list=$2;	
		for($i=0;$i<$nlist;$i++){$list[$i]="";}
		&split_argument_list;
		for($i=0;$i<$nlist;$i++){
		if($list[$i]=~ /\s*(\S+)\s*/){$list[$i]=$1;}
		if($argum{$list[$i]}){
			if( $options{$list[$i]} =~ /^\s*$/){
				$d.="$argum{$list[$i]}    $options{$list[$i]}:: $list[$i]"."_in \n";
			}
			else{
				$d.="$argum{$list[$i]} ,  $options{$list[$i]}:: $list[$i]"."_in \n";
			}
			$found{$list[$i]}=1; 
			if($options{$list[$i]}=~/pointer/){
					$extra.="$list[$i] => $list[$i]"."_in \n";
			}
			else{
					$extra.="$list[$i] = $list[$i]"."_in \n";
			}
			$list[$i].="_in";
		}
	}
	if($nlist>0){
		$list_it="$list[0]";for($i=1; $i< $nlist; $i++){ $list_it.=",$list[$i]";}
	}else{ $list_it="";}
	$lines[$i1].="\n subroutine $name ( $list_it ) {\n $d \n ";
	$i1=$ihold; $lines[$i1].="\n $extra \n $begin \n";

}
else{
		print STDERR "ERROR ERROR trouble parsing init statement \n $lop[$num] \n";
	$lines[$i1]="ERROR ERROR BEFORE ERROR ERROR\n".$lines[$i1]."ERROR ERROR AFTER ERROR ERROR\n";
	&crash_it;
}
$in_init=1;
			
}

##############################################################
####################      finish_mod     #####################
##############################################################

sub finish_mod{

	&funish_lop_unit;
	for($i=0; $i < $nmod_args; $i++){
		$ln=$line_num{$mod_args[$i]};
		if($options{$mod_args[$i]}=~/^\s*$/){
		$lines[$ln] .="$argum{$mod_args[$i]}, private :: $mod_args[$i] \n";
		}
		else{
			if($options{$mod_args[$i]} =~ /private/){
		$lines[$ln] .="$argum{$mod_args[$i]},  $options{$mod_args[$i]} :: $mod_args[$i] \n";
		}else{
		$lines[$ln] .="$argum{$mod_args[$i]} ,private, $options{$mod_args[$i]} :: $mod_args[$i] \n";}
		}
	}
	if($close==0){
		$lines[$i1-1].="\n subroutine $module"."_close(){\n";
		if($nallocate>0){
	    $lines[$i1-1].="deallocate( $allocate[0] ";
 	   	for($a=1;$a<$nallocate;$a++){ $lines[$i1-1].=",$allocate[$a]";}
 	   	$lines[$i1-1].=")\n";
  	}
		$lines[$i1-1].="}\n";
		$close=1;
	}
#	&crash_it;
}

##############################################################
####################      ratfor_77      #####################
##############################################################

sub ratfor_77{
	#program to convert ratfor77 and saw conventions to ratfor90
	@lines=split("\n",$program);
	
	$subl=0; $ia=0;
	while($subl!=1 && $ia<@lines ){
		if($subl==0){
			if($lines[$ia] =~ /^@<@(\d+)@>@/oi || $lines[$ia] =~ /^@%@(\d+)@%@/oi){ $com=$1;
				if($lop[$com] =~ /^%/){
					$lines[$ia]=$lines[$ia]."\nprogram zyxabc";
					$subl=-1;	 $pline=$ia;
				}
			   }
		}
		elsif($lines[$ia] =~ /^\s*allocate\s*:/oi){ &decipher_allocate;}
		elsif($lines[$ia] =~ /^\s*subroutine\s+(\S+)\s*(\(.+)$/oi){
				$sub_n=$1; $args=$2;
				$i0=$ia+1; while($subl!=1 && $i0 < @lines){
					print STDERR "In ratfor77 while\n";
					if($lines[$i0]=~ /^\s*real/oi || $lines[$i0] =~/^\s*use/oi ||
						$lines[$i0]=~ /^\s*integer/oi || $lines[$i0] =~/^\s*complex/oi ||
						$lines[$i0]=~/^\s*double\s+precission/oi|| $lines[$i0] =~/^\s*type\s*\(/oi ||
						$lines[$i0]=~/^\s*implicit\s+/oi || $lines[$i0] =~/^\s*character/oi ||
						$lines[$i0]=~ /^\s*logical/oi){ 
						$lines[$ia]=
						"call ".$sub_n." ".$args."\n end program zyxabc \n".$lines[$ia];
						$subl=1;
					}
					else{ $args=$args."\n".$lines[$i0]; $i0++;}
				}
			}
		$ia++;
		}
	$program=join("\n",@lines);	
}
				
	
					
##############################################################
####################  decipher_allocate  #####################
##############################################################

sub decipher_allocate{
	if($lines[$ia] =~ /^\s*allocate\s*:\s*(\S+)\s+(.+)$/oi){
		$type=$1; $line=$2; $linei=$line;
		$logit=0;
		while ($logit==0){
			if ($line =~ /^\s*([a-zA-Z1-9]+)\s*\(\s*([^\)]+)\s*\)\s*,\s*(\S.+)$/oi){
				$var=$1; $dims=$2; $line=$3; $log2=0;
				$output="$type".", allocatable, dimension (";
				$dimo=$dims;
				while($log2!=1){
					if($dimo =~ /^([^,]+),(.+)/oi){
						$dimo=$2;
						if($log2==0){ $log2=-1; $output=$output.":";}
						else{ $output=$output.",:";}
					}
					elsif($dimo=~/^(\S+)$/oi){ 
						if($log2==0){ $output=$output.":) :: ".$var; } 
						else{
	$output=$output.",:) :: ".$var;}
						$log2=1;
					}
					else{ $log2=1; $output=$output.")  :: ".$var;
					}
				}
			$lines[$pline]=$lines[$pline]."\n".$output;  
			}
			elsif ($line =~ /^\s*(\S+)\s*\(\s*(\S+)\s*\)\s*$/oi){
				$var=$1; $dims=$2; $line=$3; $log2=0;
				$output=$type.", allocatable, dimension (";
				$dimo=$dims;
				while($log2!=1){
					if($dimo =~ /^([^,]+),(.+)/oi){
						$dimo=$2;
						if($log2==0){ $log2=-1; $output=$output.":";}
						else{ $output=$output.",:";}
					}
					elsif($dimo=~/^(\S+)$/oi){ 
						if($log2==0){ $output=$output.":) :: ".$var; } 
						else{$output=$output.",:) :: ".$var;}
						$log2=1;
					}
					else{  $output=$output.")  :: ".$var;
					}
				}
			}
			else{ 
				$logit=1; $lines[$ia]="allocate (".$linei.")";}
		}
	$lines[$pline]=$lines[$pline]."\n".$output;  
	}
	   else{
		print STDERR "TROUBLE INTERPRETING ALLOCATE \n";
		$lines[$ia]="ERROR BEFORE ERROR\n".$lines[$ia]."\nEEROR AFTER ERROR";	
		&crash_it;
	}

}

##############################################################
####################    convert_sep2     #####################
##############################################################

sub convert_sep2{
	#this looks for breaks (end of declares, end of programs, etc)
  # and for getch, hetch, etc

	@prog_breaks=("program","subroutine","recursive\\s+subroutine",
          "function","\\S+\\s+function", "type\(\\s*\\S+\\s*\)\\s*function");

	@declarations=("logical","real","type","@<@","@%@","integer","use","implicit","complex","character","function","interface","}","\$");
	@sep_vars=("fetch","getch","hetch","putch","auxpar","auxputch");

	$in_fun{"from param"}="getch"; $putch_string{"from param"}="#";
	$in_fun{"from par"}="getch";   $putch_string{"from par"}=" " ;
	$in_fun{"from either"}="fetch";
	$in_fun{"from history"}="hetch";
	$in_fun{"from aux"}="auxpar";$putch_string{"from aux"}="_";
	$in_fun{"to history"}="putch";
	$in_fun{"to aux"}="auxputch";
 	$types{"real"}="f";
	$types{"integer"}="d";
	$types{"character"}="s";
	$types{"logical"}="l";

 	@lines=split("\n",$program);
  my $breaks = join("|^\\s*",@prog_breaks);
  my $decs = join("|^\\s*",@declarations);



	$in_unit=0; $c_init=0; $write_initpar=1; $head=0; $write_doc=1;
	for($i1=0;$i1<@lines;$i1++){
		if($lines[$i1] =~/^\s*($breaks)/oi){ #INITIALIZE NEW PROGRAM
			if($in_unit==1){&finish_unit;}
			$current_unit=$1;
			for($ia=0;$ia<@sep_vars;$ia++){	
				$need{$sep_vars[$ia]}=0; $in_dec{$sep_vars[$ia]}=0;
			}
			$in_unit=1; $head=1; next;	
		}
		if($head==1){
			if($lines[$i1] =~/^\s*($decs)/oi){ #ARE WE STILL IN THE HEADER
				if($1 =~ /integer/){
					for($ia=0;$ia<@sep_vars;$ia++){
						if($lines[$i1] =~/\s*$sep_vars[$ia]/){$in_dec{$sep_vars[$ia]}=1;}
					}
				}
			}
			else{ $end_of_header=$i1-1; $head=0;}
		}

		if($head==0){
			$add=0;
			if($lines[$i1]  =~ /^\s*(from\s+\S+)\s*:([\s\S]+)$/oi){
				$type_c=$1; $argument_list=$2; 
				&from_to_convert;
			}
		  elsif($lines[$i1]=~ /^\s*(to\s+\S+)\s*:([\s\S]+)$/oi){
        $type_c=$1; $argument_list=$2; &from_to_convert;
       }
			elsif($lines[$i1]=~/call\s+initpar/oi) {$write_initpar =0;}
      elsif($lines[$i1] =~ /^\s*call\s+doc/oi) {$write_doc =0;}
			elsif($lines[$i1] =~ /^\s*call\s+putch(\([\s\S]+\))\s*$/oi){
      	$add=1;$fname="putch";$fn=3;$arguments=$1;$extra="";$need{"putch"}=1;}
    	elsif($lines[$i1] =~ /^\s*call\s+putch(\([\s\S]+\))\s*@<@[\s\S]+$/){
     	 	$add=1;$fname="putch";$fn=3;$arguments=$1;$extra=$2; ;$need{"putch"}=1;}
   	 	elsif($lines[$i1] =~ /^\s*call\s+putch(\([\s\S]+\))\s*$/oi){
   	   	$add=1;$fname="auxputch";$fn=5;$arguments=$1;$extra="";$need{"putch"}=1;}
   	 	elsif($lines[$i1] =~ /^\s*call\s+putch(\([\s\S]+\))\s*@<@[\s\S]+$/){
   	   	$add=1;$fname="auxputch";$fn=5;$arguments=$1;$extra=$2;;$need{"putch"}=1;}
   	 	if($add==1){
   	   	$lines[$i1]="ab2c32y{\n if(0 .ne. $fname $arguments)
   	   	call erexit('trouble writing to file ')\n}\n";
				$in_prog{$fname}=1;
			}
    }
	}
	&finish_unit;
	$program=join("\n",@lines);
}


##############################################################
####################    finish_unit      #####################
##############################################################

sub finish_unit{
	#FINISH A UNIT ADD putch,getch,selfdoc,initpar

	#FIRST TAKE CARE OF HETCH GETCH ETC
	$logic=0;
	for($ia=0; $ia < @sep_vars; $ia++){
		if($need{$sep_vars[$ia]} ==1 && $in_dec{$sep_vars[$ia]}==0){
			if($logic==0){ 
				$logic=1; $lines[$end_of_header].="\ninteger $sep_vars[$ia]";
			}
			else{ $lines[$end_of_header].=",$sep_vars[$ia]"; }
		}
	}
	if($current_unit eq "program"){
		if($write_initpar==1){ $lines[$end_of_header].="\ncall initpar()";}
		if($write_doc==1){$lines[$end_of_header].="\ncall doc('$SOURCE')";}
	}
}


		
##############################################################
####################   from_to_convert   #####################
##############################################################

sub from_to_convert{
	#convert sep conventions

$type_c=~s/\s+/ /gm;
if($type_c =~ /^\s*from/){ $from=1; $error="0>="; $aa="reading"; $need{"putch"}=1;}
else {$from =0; $error="0.ne."; $aa="writing";}
$line="ab2c32y{\n";

$function=$in_fun{$type_c};
$need{$function}=1;


#handle auxilary file case
if($type_c eq "from aux" || $type_c eq "to aux"){
	if($argument_list =~ /^\s*(\S*)\s+(\S[\s\S]*)$/){
		$file=$1; $argument_list=$2;
		$extra=",'$file'";
	}
	else{
    print STDERR "ERROR:couldn't find auxilary file name ) \n";
    $lines[$i1] = "ERROR BEFORE ERROR\n".$lines[$i1]."\nERROR AFTER\n";
    &crash_it;
	}
}
else{ $extra=""; $file="";}

#find out the type of data
	if($argument_list =~ /^\s*(\S+)\s+(\S[\s\S]*)$/){
		$type=$1; $argument_list=$2;
		if($type =~ /integer/ || $type =~ /real/ || $type =~/logical/ ||
      $type =~ /character/){}
		else{ 
    	print STDERR "ERROR:unacceptable type of data  \n";
    	$lines[$i1] = "ERROR BEFORE ERROR\n".$lines[$i1]."\nERROR AFTER\n";
			&crash_it;
		}
		$type=$types{$type};
	}
	else{
    print STDERR "ERROR:couldn't find type of data ) \n";
    $lines[$il] = "ERROR BEFORE ERROR\n".$lines[$il]."\nERROR AFTER\n";
		&crash_it;
	}

&split_argument_list;

for($i=0; $i < $nlist; $i++){
	&split_argument;
	$line.="if($error ".$in_fun{$type_c}."('$arg_f','$type',$arg $extra)){\n";
	if($default ne ""){ $line.="$arg = $default \n}\n";}
	else{
		$line.="call erexit(XyAt$qnum)}\n";
		$quotes[$qnum]="'Trouble $aa  $arg_f $type_c $file '";  $qnum++;
	}
	if($putch_string{$type_c}){
		$line.="if(0.ne.putch('Read  $type_c: $file$putch_string{$type_c}$arg_f ','$type',$arg)){\n";
		$line.="call erexit(XyAt$qnum)}\n";
		$quotes[$qnum]="'Trouble writing $arg to history'"; $qnum++;
		if($type_c eq "from par"){
			$quotes[$qnum]="'$arg_f: from par is obsolete, please replace with from param'";
			print STDERR "$quotes[$qnum]\n";
			$line.="write(0,*) XyAt$qnum\n"; $qnum++;
		}
	}
}

$lines[$i1]="$line }\n";
}
	

	
##############################################################
#################### split_argument_list2 ####################
##############################################################

sub split_argument_list2{
	#splits the argument list into parts

	@string=split(//,$argument_list);
	$nlist=0;
	$level=0;$list[0]="";
	for($i=0; $i < @string ; $i++){
		if($string[$i] eq "(") { $level++;}
		elsif($string[$i] eq ")"){$level--;}

		if($string[$i] eq ":" && $level==0){ 
			$nlist++;$list[$nlist]="";
			if($i < @string -1){
				while($string[$i+1] eq " "){ $i++;}
			}
		}
		else{ $list[$nlist].=$string[$i];}
	}
	$nlist++;
}

##############################################################
#################### split_argument_list #####################
##############################################################

sub split_argument_list{
	#splits the argument list into parts

	@string=split(//,$argument_list);
	$nlist=0;
	$level=0;$list[0]="";
	for($i=0; $i < @string ; $i++){
		if($string[$i] eq "(") { $level++;}
		elsif($string[$i] eq ")"){$level--;}

		if($string[$i] eq "," && $level==0){ 
			$nlist++;$list[$nlist]="";
			if($i < @string -1){
				while($string[$i+1] eq " "){ $i++;}
			}
		}
		else{ $list[$nlist].=$string[$i];}
	}
	$nlist++;
}

	
##############################################################
####################    split_argument   #####################
##############################################################

sub split_argument{
	#splits sep argument into var var_f and default

	@string=split(//,$list[$i]);
	$sec=0; $part[0]=""; $part[1]=""; $part[2]=""; $level=0;
	for($j=0; $j < @string ; $j++){
		if($string[$j] eq "(") { $level++;}
		elsif($string[$j] eq ")"){$level--;}
		if($level==0 && $string[$j] eq ":"){ $sec=1;}
		elsif($level==0 && $string[$j] eq "="){ $sec=2;}
		elsif($level==0 && $string[$j]=~/\s/){}
		else{$part[$sec].=$string[$j];}
	}
	if($part[0] eq ""){
		$lines[$i1]="ERROR ERROR ERROR \n $lines[$i1] ERROR ERROR ERROR \n";
		print STDERR "Trouble parsing $line_c statement \n";
		&crash_it;
	}
	$arg_f=$part[0];
	if($part[1] eq ""){ $arg=$arg_f;}
	else { $arg=$part[1];}
	
	$default=$part[2];
			
}

##############################################################
#################### pre_process_program #####################
##############################################################

sub pre_process_program{

	#standardize the spacing a little bit	

	$program =~ s/elsewhere/else where\n/gm;	
 	$program =~ s/else/else /gm;	;
 	$program =~ s/else\s+if/else if/gm;	
	$program =~ s/else\(/else\(/gm;	
	$program =~ s/if\s*\(/if \(/gm;	
	$program =~ s/{/ \n{\n /gm; #}
	$program =~ s/}/\n}\n /gm;
	$program =~ s/\)[\n|\t|\s]*{/\){/gm;	#}}

	#DELTED SOME POTENTIALLY IMPORTANT STUFF

	#make some more general substitions
#RED Added subs for next 1 and break 1
	$program =~ s/next 1/cycle/gm;
	$program =~ s/[ |\t]next[ |\t]/ cycle /gm;
	$program =~ s/[ |\t]next\n/ cycle\n/gm;
	$program =~ s/break 1/exit/gm;
        $program =~ s/[ |\t]break[ |\t]/ exit /gm;
        $program =~ s/[ |\t]break\n/ exit\n/gm;

#RED 
	$program =~ s/for\(;;\)/do /gm;

	$program =~ s/do\s+while/while/gm;  
	$program =~ s/while/do while /gm;  

	#this makes sep77, ratfor77 code work
	$program =~ s/temporary\s+real/real/gm;  
	$program =~ s/\n\s*temporary integer/\ninteger/gm;  
	$program =~ s/\n\s*temporary complex/\ncomplex/gm;  
	$program =~ s/repeat/do /gm; 
	@lines=split("\n",$program);
}

##############################################################
####################  check_line_breaks  #####################
##############################################################

#checks to see if a line is a recgonizable type, if not assumes its
#part of the previous line

# fixxes things like
# x=a+
#     bZ* 23
# to x=a+bZ* 23

sub check_line_breaks{
	#recognized begining of lines
	# RED
	# Added dimension, include, pause and equivalence and something else to recognized list
	# "include" should no longer need to be in there since read of code now 
	# brings in all included files.
	#
	@recognized=( 
	"do\\s+" , "if\\s+" ,"else\\s+" , "write\\s*\\(" ,"print" 
, "{" 
		,"}" 
,"[a-zA-Z][\\s\\S]*[^//]=" 
,"[a-zA-Z]\s*=" 
#,"[a-zA-Z][\\s\\S]*\\s*\\\\+\\\\+" 
,"[a-zA-Z][\\s\\S]*\\s*--" ,"real\\s*"
		, "integer\\s*" ,"allocate\\s*\\(" ,"@<@" , "@%@","deallocate" ,"character\s*\\(" 
		,"where" ,"do\$", "call\\s+" ,"type\\s*\\(" ,"subroutine\\s+" ,"logical\\s*"
		,"integer\\s+" ,"complex\\s*" ,"real\\s+" ,"implicit\\s+" ,"program\\s+" 
		,"common\\s*" ,"equivalence\\s+" ,"include\\s+","dimension\\s+",
		,"use\\s+" ,"module\\s+" ,"contains" ,"end\\s+interface" ,"nullify"
  	,"logical\\s+" ,"exit","pause\\s+" 
     ,"\^[\\s]*\$" 
,"end\\s*\$" ,"interface" ,"type,","type\\s+","private","public","optional","ON"

	  ,"format" ,"private\\s+" ,"for\\s*\\(" ,"public\\s+" ,"next" ,"end\\S+" 
		,"return\\s*\$" ,"double\\s+precision" ,"select" ,"case" ,"end" ,"stop"
		,"recursive\\s+subroutine" ,"function" ,"character" ,"data\\s+\\S+"
		,"recursive\\s+function", "ab2c32y","cycle","return\\s*\\(",
		,"read\\s*\\(","continue","go\\s+to","rewind","goto","save","close\\s*\\("
	);

	#
	# return was not being recognized in above list.
	# Added additional return with no $ to above list to correct return
	# statement being appended to a preceeding line containing a comment
	#  
	$num_begining=@recognized;

	my $regex = join("|^\\s*", @recognized);
	$i1=0;
	for($i1=0;$i1<@lines;$i1++){
		$lines[$i1] =~ s/\n//gm;
		if($lines[$i1] =~/^\s*(\S[\s\S]*)@<@/oi){
			if($1 =~ /^@/oi){
				$line=$1;
			} 
			else{$line=$lines[$i1];}
		}
		else{$line=$lines[$i1];}
 		$logic=0; $new_line=0; $it=0;
		#look for a recognizeed type
		if($line =~ /^\s*$regex/oi){ 
			$logic=1;
		}
		if($logic==0 && ($line=~/^\s*[0-9]+\s(.+)$/oi 
           || $line=~/^\s*[a-zA-Z]\S*:(.+)/oi)){
			$line=$1;
			if($line =~ /^\s*$regex/oi){ $logic=1;}
			#this allows line numbers, I wish to discontinue this crap
		}

		#If it recognized type it return

		if($logic==1 && $i1 >0){ 
				$lines[$i1-1].="\n";
		}
		else{
				# RED
				# Am taking out the space until such time
				# as I see it may be used elsewhere.
#				$lines[$i1-1]=~ s/\s*$/ /gm;
				$lines[$i1-1]=~s/\s*$//gm;
				$lines[$i1]=~ s/^\s+//gm; 
		}
	}
	$lines[$num_lines-1]=$lines[$num_lines-1]."\n";
	$program=join("",@lines);	
	@lines=split("\n",$program);

}


##############################################################
####################     fix_if_else     #####################
##############################################################

sub fix_if_else{
	# split lines, specifically if,elses,else ifs, and do whiles

	@recognized=("else\\s+if\\s+" ,"do\\s+while\\s+" ,"where\\s*","if\\s+",
  "for\\s*"); 
	my $regex1 = join("\\(|^\\s*", @recognized);

	for($i1=0; $i1<@lines;$i1++){
                if($lines[$i1]=~/else/){
                        if($lines[$i1]=~/else\s+if/oi||
        $lines[$i1]=~/else\s+where/oi || $lines[$i1]=~/write[\s\S]*else/oi){}
                        else{ $lines[$i1] =~s/else/else\n/gm; }
                }
		#this allows repeat until statements
		elsif($lines[$i1]=~/^\s*}\s*until\s*(\([\s\S]+)$/oi){
			$lines[$i1]="if".$1."\nexit\n}";
		}

		if($lines[$i1] =~/^\s*$regex1\(/oi){ 
			$line=$lines[$i1]; $hold=$i1;
			$bracket=index($lines[$i1],"(",0)+1;
			&find_paren;

			substr($line,$bracket-1,1)=")\n"; $lines[$i1]=$line;
		}
	}
	$program=join("\n",@lines);	
	$program=~s/\n\s*{/{/gm;  #}}
	@lines=split("\n",$program);	
}
##############################################################
####################    extend_syntax    #####################
##############################################################

sub extend_syntax{
	for($i1=0; $i1<@lines;$i1++){
		if($lines[$i1] =~ /^(.+)(@<@.+)$/){ $end=$2; $line=$1;}
		else {$line=$lines[$i1]; $end="";}
		if($line =~/[\+-]=/oi){ #DOES THE LINE HAVE A +=
			if($line =~/;/){@parts=split(";",$line); $np=@parts;}#DOES THE LINE HAVE A ;
			else {$parts[0]=$line; $np=1;}
			for($ip=0; $ip < $np; $ip++){ #LOOP THROUGH THE PARTS OF THE LINE
				if($parts[$ip] =~ /(.+)\+=(.+)/oi){ $parts[$ip]=$1."=".$1."+".$2;}
				if($parts[$ip] =~ /(.+)-=(.+)/oi){ $parts[$ip]=$1."=".$1."-".$2;}
			}
			if($np>1){$line=join(";",@parts);} else{ $line=$parts[0];}
			$lines[$i1]=$line.$end;
		}
		$log=0;
		if($lines[$i1] =~/^\s*use\s*(.+)$/){
			 $lines[$i1]=~s/\+/\n use /gm;
			}
			
	}
}
##############################################################
####################   insert_brackets   #####################
##############################################################


#this is the most complicated part, and probably inefficiently and
#incorrectly written, and wrong.  Attempts to add brackets in
#the right place. Tried to comment it sufficiently, because if
#I or anybody else has to fix it they are in for a real task

sub  insert_brackets{
$program=join("\n",@lines);
$program=~s/\n[\s*\n]+/\n/gm;
$program=~s/\n{/{/gm;
@lines=split("\n",$program);

	#varibles
	# num_in_stack = number of brackets deep a current line is at
	# @stack_type  = type of expresion 
	# @stack_bracket = 1, bracket already exists, 0 not
	# logic   = 1-statement is of recognized type, -1 last statement was of
	#            recognized type, 0 not recognized type
	# old_status = previous lines logic

	#recognized complex expressions
	$express[0] ="if\\s+"; $type_it[0] ="if";
	$express[1] ="if\\s*\\("; $type_it[1] ="if";
	$express[2] ="else"; $type_it[2]="else";
	$express[3] ="ab2c32y"; $type_it[3]="erase";
	$express[4] ="do\\s+"; $type_it[4]="do";
	$express[5] ="for\\s*\\("; $type_it[5]="for";
	$express[6] ="where\\s*\\("; $type_it[6]="if"; 
	$express[7] ="select\\s*case\\s*\\("; $type_it[7]="if"; 
	$num_express=@express;
	@real_status=("if","if","else","erase","do","for","where","select");
	my $regex1 = join("|^\\s*", @express);

	$num_lines=@lines; $old_nc=0;
	for($ia=0;$ia<$num_lines;$ia++){
 		$logic=0;
		$i1=0;  #HERE
		if($lines[$ia]=~/^@<@/oi || $lines[$ia]=~/^@%@/oi){ }
		else{
		#this allows naming bafk: or 123
		if($lines[$ia]=~/^\s*[0-9]+\s([\s\S]+)$/oi
		      || $lines[$ia] =~/^[a-zA-z]\S*:([\s\S]+)$/oi) {$line=$1;} 
		else{ $line=$lines[$ia];}
#			print stderr "line check $ia $line $num_in_stack \n";
			#if we find one of the expressions we know that we need to have a bracket
			if($line=~/^([\s\S]+)@<@/){$line=$1;} 
			if($line=~ /^\s*$regex1/oi){
				while($i1 < $num_express && $logic==0){
     					if($line =~/^([\s|\t]*)$express[$i1]/i){
						$logic=1; $type=$type_it[$i1];$real_type=$real_status[$i1];
						#if we have a bracket record it
       						if( $line =~ /{/){  #} 
							$bracket=1;
							$logic=-1;
							if($type =~ /if/oi) {$last_bracket_status=0;}
						}
						#if not add a bracket
       						else{
							$bracket=0; $logic=1; $lines[$ia]=$lines[$ia]."{\n"; #} 
							if($type =~ /if/oi) {$last_bracket_status=1;}
       						}
     					}
					$i1++;
   				}
			}



			#if we find an end or return we need to dump all our brackets
			#this should work, because I am not going to allow any automatic
			#calculation of end of line with modules or types

			# if($line =~/^\s*end[\s|\n]+/oi || $line =~ /^\s*return[\s|\n]+/oi){
 			if($line =~/^\s*end[\s|\n]+/oi ){
  			   	for($i1=0; $i1 < $num_in_stack; $i1++){ 
					if($stack_bracket[$i1]==0){  #{
						$lines[$ia]="}\n".$lines[$ia];;
				}
			}
			$old_status=0;
     			$num_in_stack=0;
 		}


		#if the line is not of recognized type
 		elsif ($logic==0){
			if($line =~ /}/oi){
				#we just found a } so drop everything back to the last bracket
        #regardless of anything else
				# do {
        #  do
        #   if
        #    b=23
        #   }

				
#				print stderr $lines[$ia],"before",$ia," ",$num_in_stack," ",$stack_row[$num_in_stack],"\n";

				#dump all the closers before last bracket

				while($num_in_stack >0  &&$stack_bracket[$num_in_stack-1]==0){
					$lines[$ia] =$lines[$ia]."\n}";
					$num_in_stack--;
				}
				$num_in_stack--;

#				while($stack_row[$num_in_stack]==1&&$stack_bracket[$num_in_stack-1]==0){
#					$lines[$ia] =$lines[$ia]."\n}";
#					$num_in_stack--;
#				}
				$old_status=0;
#				print stderr $lines[$ia],"<<",$ia," ",$num_in_stack," ",$stack_row[$num_in_stack],"\n";
				if($num_in_stack>0){
					if ($stack_row[$num_in_stack]==1 || $lines[$old_nc]=~/}/){
					$old_status=2; }}
				

			}
			#in order to support brackets not defined by ratfor77
			elsif($line=~/{$/oi){ 
				$stack_row[$num_in_stack]=0; $stack_bracket[$num_in_stack]=1;
				$stack_type[$num_in_stack]="buga"; $stack_line[$num_in_stack]=ia;
				$num_in_stack++;
			}
        
   		elsif($old_status >=1){
				#in case last line was a bracket we need to drop all of the row
				if($lines[$old_nc] =~ /^\W*$/oi){ 
					while($stack_row[$num_in_stack] ==1 && $stack_bracket[$num_in_stack-1] ==0 &&  $num_in_stack >0){
      			$num_in_stack--; $lines[$ia]="}\n".$lines[$ia];
					}
					$old_status=0;
				}
				else{
						
					# if the last line was we can drop at least one bracket 
					#  do i1=1,3
					#    b=23
					#{
					#  add  } unless do i1=1,3{  #}
					
			 		if($stack_bracket[$num_in_stack-1]==0 ){
 		     		$num_in_stack--; $old_status=-1; 
 	    			$lines[$ia]=$lines[$ia]."}\n";
					}
					# 
					elsif($lines[$ia+1] =~ /}/oi){ $old_status=-1; $ia++; $num_in_stack--;}
					else { $old_status=0; }
 	  		}
			}
	  	elsif($old_status==-1) {

				#if we hit the second line in a row with no recognized type
				#we can dump all brackets until we reach where someone actually
				#specified an open bracket
				
				while($num_in_stack >= 1 && $stack_row[$num_in_stack] ==1 && $stack_bracket[$num_in_stack-1]==0){
					$lines[$ia]="}\n".$lines[$ia];
					$num_in_stack--;
				}
				$old_status=0;
			}
		}




		#if the status =1 (logic) , we have a recognized type
		else{
#		print stderr $i1," ",$lines[$ia]," logic1tat=-1\n";
			# if we found a consecutive rcognied type line
			# if (i1=3;...
			#   do i1=1,3

 	 		if($old_status>=1){
#			print stderr $i1," ",$lines[$ia]," in old stat 1stat=-1\n";
				#this if should only be hit when we have
        # do
        #   if{
        #     b=23
	      #   }
				#else
					#we have two cases
          # b=23            #case 1
          # else
          #
          # b=23
          # }                #case 2
          #else 
				if($type eq "else"){   #case 2
					if($lines[$old_nc]=~/}/oi){
						#special case for else where
						if($line =~/^\s*else\s+where/oi){
							if($lines[$stack_line[$num_in_stack]] =~ /^\s*where/oi) {
								$stack_bracket[$num_in_stack]=1;$num_in_stack++;	}
							if($lines[$stack_line[$num_in_stack-1]] =~ /where\s*\(/oi){$logic=1;}
							else{$logic=0;}
							while($num_in_stack >0 && $logic==0){
								if($lines[$stack_line[$num_in_stack-1]]=~/where\s*\(/oi){$logic=1;}
								$num_in_stack--;	
								if($stack_bracket[$num_in_stack]==0)
									{$lines[$ia]="}\n".$lines[$ia];}
							}
						}
						else{
					    if($lines[$stack_line[$num_in_stack]]=~/if\s*\(/oi || 
								$lines[$stack_line[$num_in_stack]] =~ /else if\s*\(/oi) {
								$stack_bracket[$num_in_stack]=1;$num_in_stack++;	}
						  if($lines[$stack_line[$num_in_stack-1]]=~/if\s*\(/oi || 
							  $lines[$stack_line[$num_in_stack-1]]=~ /else if\s*\(/oi){$logic=1;}
							else{$logic=0;}
							while($num_in_stack >0 && $logic==0){
								if($lines[$stack_line[$num_in_stack-1]]=~/if\s*\(/oi || 
								 $lines[$stack_line[$num_in_stack-1]]=~/else if\s*\(/oi){$logic=1;}
								 $num_in_stack--;	
								 if($stack_bracket[$num_in_stack]==0)
									{$lines[$ia]="}\n".$lines[$ia];}
							}
						}
						if($stack_bracket[$num_in_stack-1]==0){
							$lines[$ia]="}\n".$lines[$ia];}
						$stack_type[$num_in_stack-1]="else";
						$stack_line[$num_in_stack-1]=$ia;
						$stack_bracket[$num_in_stack-1]=$bracket;
					}
				}
				else{
					#this is a test for
					#do i = 1, nop
  				# if(i == 1) {
					#		}
					#if(conj == 0)
					#we need to dump brackets in this case
					if($old_status==2){
	  				while($num_in_stack >= 1 && $stack_row[$num_in_stack] ==1 && 
							$stack_bracket[$num_in_stack-1]==0){
 	        		$lines[$ia]="}\n".$lines[$ia];
 	        		$num_in_stack--;
 		       	}
					}
#					print stderr $old_status,">>",$lines[$ia],"<<in else \n";
					$stack_bracket[$num_in_stack]=$bracket;
					$stack_row[$num_in_stack]=1;
					$stack_type[$num_in_stack]=$real_type;
					$stack_line[$num_in_stack]=$ia;
					$num_in_stack++;
					$old_status=1;
				}
			}
		  

			# if we don't have consectuve recognized types
 	 		else{
				#if we have found an else it is a special case
    		if($line =~/^[\s|\t]*else/oi){
					#if the previous statement was an if or else if
          # we don't have to do much 
			    #if ()
          # line=er
          #else()
					$log2=0;
						#dumnp all brackets back to specficed bracket or last if or else
						# if statement
						#handle
            # if ()
            #   do
            #     do
            # else
						#first check to see if we have the speial case of else
					if($line=~/\s*else\s+where/oi){
						if($stack_type[$num_in_stack] ne "where"){
      				while($stack_type[$num_in_stack-1] ne "where" &&$num_in_stack>0){
								if($stack_bracket[$num_in_stack-1]==0){ 
       		 				$lines[$ia]="}\n".$lines[$ia]; }	
       		 			$num_in_stack--;
 	     				} $log2=1;
						}
					}
					else{
  					if($stack_type[$num_in_stack] ne "if" 
						  && $stack_type[$num_in_stack] ne "else"){$log2=1;
      			  while(($stack_type[$num_in_stack-1] ne "if" 
                && $stack_type[$num_in_stack-1] ne "else") && $num_in_stack>0){
							  if($stack_bracket[$num_in_stack-1]==0){ 
       		 			  $lines[$ia]="}\n".$lines[$ia]; }	
       		 			$num_in_stack--; }
						}
					}	
					#if we reached the end wtihout finding any if or else, we have
					# an error
					if($log2==1){
						if($num_in_stack==0 && $last_bracket_status ==1){
						  print STDERR "ERROR: \n I found an else statement and ";
						  print STDERR "couldn't find the matching if or else if statement\n";
						  $lines[$ia] = "ERROR BEFORE ERROR\n".$lines[$ia]."\nERROR AFTER\n";
						  &crash_it;
					  }
					  # otherwise we need to drop a bracket, why???
					  #logic is that we just finished an if so we need to add bracket
            # if
            #   do
            #     bv=23
            # else
					  else{
       			  $num_in_stack--; 
						  if($stack_bracket[$num_in_stack]==0){ 
							  $lines[$ia]="}\n".$lines[$ia];}
						}
					}
					#we are inside an else so record it, duh.
					$stack_bracket[$num_in_stack]=$bracket;
					$stack_type[$num_in_stack]=$real_type;
					$stack_line[$num_in_stack]=$ia;
      		$num_in_stack++;
    		}
				# if we are one away from a known statemt we can drop all the brackets
				# back to a known bracket or all of them
    		elsif($old_status==-1){
					while($num_in_stack > 0 && $stack_row[$num_in_stack]==1 && $stack_bracket[$num_in_stack-1]==0){ 
 	   				$lines[$ia]="}\n".$lines[$ia];
						$num_in_stack--;
					}
					$stack_bracket[$num_in_stack]=$bracket;
					$stack_type[$num_in_stack]=$real_type;
					$stack_line[$num_in_stack]=$ia;
					if($num_in_stack ==0 || $stack_bracket[$num_in_stack-1]==0){
						$stack_row[$num_in_stack]=0;
					}
					$num_in_stack++;
    		}

				#otherwise just add the bracket to the stack, phew!
        # B22=22
        # B32=22
        #  do 
				else{
					if($num_in_stack == -1) {
						print STDERR $line," STACK ERROR\n";&crash_it;}
					$stack_bracket[$num_in_stack]=$bracket;
					$stack_type[$num_in_stack]=$real_type;
					$stack_line[$num_in_stack]=$ia;
						$stack_row[$num_in_stack]=0;
									#$stack_row[$num_in_stack]=0;
									$num_in_stack++;
								}
							}

							#fix old_staus
							$old_status=1;
						}
						$old_nc=$ia;
					}
	}
	$program=join("\n",@lines); 
	$program =~ s/}\s*\n/\n}\n/gm;
	@lines=split("\n",$program);
}

############################################################## 
####################    change_spacing   #####################
##############################################################

sub change_spacing{
  #this subroutine indents according to bracket depth

	$depth=0; $num_lines=@lines; $i0=0; $gets=0;
	for($i1=0;$i1<$num_lines;$i1++){
                $ach=substr($lines[$i1],0,1);
		if(index($lines[$i1],"program",0) > -1 ||
		   index($lines[$i1],"subroutine",0) > -1 ||
		   index($lines[$i1],"&",0) > -1) {
			$prloop=1;
			$ach=substr($lines[$i1],0,1);
			if($ach <=> " "){
				$prloop=0;
			}
			while($prloop == 0){
				$aline=substr($lines[$i1],1,length($lines[$i1])-1);
				$lines[$i1]=$aline;
				$ach=substr($lines[$i1],0,1);
				if($ach ^= " "){
					$prloop=1;
				}
			}
		}
	        if($ach == "1" || $ach == "2" || $ach == "3" || $ach == "4" || $ach == "5" ||
		   $ach == "6" || $ach == "7" || $ach == "4" || $ach == "8" || $ach == "9"){
			$apos=index($lines[$i1]," ",0);
			if($apos > -1){
				# RED Nothing fancy, slam some blanks after label to ensure
				#     the statement starts at least in column 7
				substr($lines[$i1],$apos,0)="     ";
			}
	        }
		elsif($lines[$i1] =~ /^\s*@<@/ || $lines[$i1] =~ /^\s*@%@/ ){}else{
			if($lines[$i1] =~ /{/){
				$indent[$i0]=$depth; $i0++;
				for($it=0; $it<$depth+6;$it++){ $lines[$i1] = " ".$lines[$i1]; }
				$depth++;
			}
			elsif($lines[$i1] =~ /}/){
				$depth--;
				for($it=0; $it<$depth+6;$it++){ $lines[$i1] = " ".$lines[$i1]; }
			}
			else{
				for($it=0; $it<$depth+6;$it++){ $lines[$i1] = " ".$lines[$i1]; }
			}
		}
	}
}
##############################################################
####################   replace_brackets  #####################
##############################################################

sub replace_brackets{
 #replace brackets with correct end, then, etc

for($il=0; $il<@lines;$il++){
	if($lines[$il] =~ /{\s*$/oi){
		 &find_type_line;
	}
	elsif($lines[$il] =~ /}\s*$/oi){
		&close_bracket2;
	}
}
	
$program=join("\n",@lines);	
}

##############################################################
####################    close_bracket2   #####################
##############################################################

sub close_bracket2{
	#FINDS CLOSING BRACKET COULD BE SPED UP
	$i1=$num_brackets;
	$logic=0;
	while($i1 >= 0 && $logic==0){
		$i1--;
		if($bracket_close_pos[$i1] == -1){ 
			$bracket_close_pos[$i1]=$il;
			$logic=1;
		}
        }

	if($logic==0){
		print STDERR "ERROR:\n EXTRA RIGHT BRACKET???? \n";
		$lines[$il] = "ERROR BEFORE ERROR\n".$lines[$il]."\nERROR AFTER\n";
#		$program=join("",@string);	@lines=split("\n",$program);	
		&crash_it;
	}

	#add how to replace the bracket here
	#if bracket type equal if

	$lines[$bracket_open_pos[$i1]]=~ s/{$//;
	$temp_ch=$lines[$bracket_open_pos[$i1]];
	$indent="";$logic=0;
	while($logic ==0){
		if($temp_ch=~/^  ([\s\S]*)$/oi){$temp_ch=$1; $indent=$indent."  ";}
		else{$logic=1;}
	}
		
	$loop=$pos; 
	if($bracket_type[$i1] eq "if" || $bracket_type[$i1] eq "where"){
		$pos=$loop+1; $not_comment=1;
		if($bracket_type[$i1] eq "if"){
			$lines[$bracket_open_pos[$i1]]=$lines[$bracket_open_pos[$i1]]." then";
		}
		$end_if=1;
		$logic=0; $ia=$bracket_close_pos[$i1]+1;while($logic == 0 && $ia <= @lines){
			if($lines[$ia] =~/^\s*@<@/oi || $lines[$ia] =~/^\s*@%@/oi){ $ia++;}
			elsif($lines[$ia] =~ /^\s*else\s*{/oi || $lines[$ia]=~ /^\s*else\s+where{/oi ||  $lines[$ia] =~ /^\s*else\s+if\s*\(/oi){$end_if=0; $logic=1;} 
			else {$logic =1; }
		}
		if($end_if == 1) {
			if($bracket_type[$i1]eq "if"){
				$lines[$bracket_close_pos[$i1]]=$indent."end if".$marker[$i1];}
			else{	$lines[$bracket_close_pos[$i1]]="end where".$marker[$i1];}}
		else { $lines[$bracket_close_pos[$i1]]=$indent;}
	}
	elsif($bracket_type[$i1] eq "else") {
		$lines[$bracket_close_pos[$i1]] =$indent."end if ".$marker[$i1]; 
	}
	elsif($bracket_type[$i1] eq "do") {
		$lines[$bracket_close_pos[$i1]] = $indent."end do ".$marker[$i1];;
	}
	elsif($bracket_type[$i1] eq "program") {
		$lines[$bracket_close_pos[$i1]] = $indent."end program ";
	}
	elsif($bracket_type[$i1] eq "subroutine") {
		$lines[$bracket_close_pos[$i1]] = $indent."end subroutine ";
	}
	elsif($bracket_type[$i1] eq "type") {
		$lines[$bracket_close_pos[$i1]] = $indent."end type";
	}
	elsif($bracket_type[$i1] eq "module") {
		$lines[$bracket_close_pos[$i1]] = $indent."end module";
	}
	elsif($bracket_type[$i1] eq "select") {
		$lines[$bracket_close_pos[$i1]] = $indent."end select ";
	}
	elsif($bracket_type[$i1] eq "function") {
		$lines[$bracket_close_pos[$i1]] = $indent."end function ";
	}
	elsif($bracket_type[$i1] eq "interface") {
		$lines[$bracket_close_pos[$i1]] = $indent."end interface ";
	}
	elsif($bracket_type[$i1] eq "erase"){
		$lines[$bracket_open_pos[$i1]] = $indent." ";
		$lines[$bracket_close_pos[$i1]] = $indent." ";
	}
	elsif($bracket_type[$i1] eq "for"){
		if($lines[$bracket_open_pos[$i1]] =~/^\s*for\s*\(([\s\S]+)\)\s*$/oi){ #}
			$temp_ch=$1;}
		else{ 
			print STDERR "TROUBLE INTERPRETING FOR STATEMENT \n";
			$string[$bracket_match[$i1]]="ERROR BEFORE".$string[$bracket_match[$i1]];
			$string[$bracket_open_pos[$i1]]="ERROR AFTER".$string[$bracket_match[$i1]];
			$program=join("",@string); @lines=split("\n",$program);
			&crash_it;
		}
		@arguments=split(";",$temp_ch);
		$arguments[0]=~s/\s//gm; $arguments[1]=~s/\s//gm; $arguments[2]=~s/\s//gm;
		if($marker[$i1] ne ""){ $i0=$bracket_match[$i1]-1;  $ma=$marker[$i1].": ";
			while($string[$i0] ne "\n"){$i0--;}}
		else{$i0=$bracket_match[$i1]; $ma="";}
		# Changed the following to include 6 spaces for proper indent for hpux f90
		$lines[$bracket_open_pos[$i1]]="      ".$arguments[0]."\n      do\n".$indent."if(.not. (".$arguments[1].")) then\n".$indent."  exit\n".$indent."end if";
#RED
		$GENLABEL=$GENLABEL+1;
		$lines[$bracket_close_pos[$i1]]=$GENLABEL.$indent."  ".$arguments[2]."\n".$indent."end do";
#RED
#		print STDERR "\nCurrent Index i1=$i1\n";
#		for($ix=0;$ix<=$num_brackets;$ix++) {
#			print STDERR "\nindex            :$ix\n";
#			print STDERR "  type           :$bracket_type[$ix]\n";
#			print STDERR "  match          :$bracket_match[$ix]\n";
#			print STDERR "  open_pos       :$bracket_open_pos[$ix]\n";
#			print STDERR "  close_pos      :$bracket_close_pos[$ix]\n";
#		}

# Scan rest of brackets (i1 +1) for any do or for bracket pairs that fall within the current
# the current bracket pair
#			Note: current index is i1
#
		$num_rejects=0;
		for($ix=$i1+1;$ix<$num_brackets;$ix++) {
			if($bracket_open_pos[$ix]>$bracket_open_pos[$i1] && $bracket_close_pos[$ix]<$bracket_close_pos[$i1]) {
				if($bracket_type[$ix] eq "do" || $bracket_type[$ix] eq "for") {
					$reject_open_pos[$num_rejects]=$bracket_open_pos[$ix];
					$reject_close_pos[$num_rejects]=$bracket_close_pos[$ix];
					$num_rejects=$num_rejects+1;
				}	
			}
		}

#  Scan between for brackets for for "cycle"
#  Sub as needed only in non-rejected lines with goto genlabel number

		for($ix=$bracket_open_pos[$i1];$ix<=$bracket_close_pos[$i1];$ix++) {
			$reject_logic=0;
			for($iy=0;$iy<$num_rejects;$iy++) {
				if($ix >= $reject_open_pos[$iy] && $ix <= $reject_close_pos[$iy]) {
					$reject_logic=1;
				}
			}
			if($reject_logic == 0) {
				$lines[$ix]=~s/cycle/goto $GENLABEL/gm;
			}
		}

	}
	elsif($bracket_type[$i1] eq "elsewhere") {
		$lines[$bracket_close_pos[$i1]] = $indent."end where ".$marker[$i1];
	}
	$pos=$loop;

}	

##############################################################
####################   find_type_line    #####################
##############################################################
   
#finds what a bracket is enclosing (do,if,etc.)
sub find_type_line{
	$i1=length($lines[$il]); $logic=0; $brack_deep=0;

	if($lines[$il]=~/^\s*([a-zA-Z]\S+)\s*:\s*([\s\S]+)$/oi){
		$marker[$bracket_count]=$1;$line=$2;}
	elsif($lines[$il]=~/^\s*[0-9]+\s+([\s\S]+)$/oi){
		$marker[$bracket_count]="";$line=$1;}
	else{$line=$lines[$il];$marker[$bracket_count]="";}


	if($line =~/^\s*do\s/i){ $logic=1; $type_found="do"; }
	elsif($line =~/^\s*else\s+where/oi){ $logic=1; $type_found="elsewhere"; }
	elsif($line =~/^\s*else\s+if\W*\(/oi){ $logic=1; $type_found="if"; }
	elsif($line =~/^\s*else\W/oi){ $logic=1; $type_found="else"; }
	elsif($line =~/^\s*if\W*\(/oi){ $logic=1; $type_found="if"; }
	elsif($line =~/^\s*module\s/oi){ $logic=1; $type_found="module"; }
	elsif($line =~/^\s*interface\s/oi){ $logic=1; $type_found="interface"; }
	elsif($line =~/^[\s\S]*function\s+/oi){ $logic=1; $type_found="function"; }
	elsif($line =~/^\s*program\s/oi){ $logic=1; $type_found="program"; }
	elsif($line =~/^\s*subroutine\s/oi){ $logic=1; $type_found="subroutine"; }
	elsif($line =~/^\s*recursive\s+subroutine\s/oi){ $logic=1; $type_found="subroutine"; }
	elsif($line =~/^\s*type\s/oi){ $logic=1; $type_found="type"; }
	elsif($line =~/^\s*ab2c32y\s*/oi){ $logic=1; $type_found="erase"; }
	elsif($line =~/^\s*type,\s/oi){ $logic=1; $type_found="type"; }
	elsif($line =~/^\s*where\s*\(/oi){ $logic=1; $type_found="where"; }
	elsif($line =~/^\s*select\s+case\s*\(/oi){ $logic=1; $type_found="select"; }
	elsif($line =~/^\s*for\s*\(/oi){ $logic=1; $type_found="for"; }
	if($logic==1){
		$bracket_type[$bracket_count]=$type_found;
		$bracket_open_pos[$bracket_count]=$il;
		$bracket_close_pos[$bracket_count]=-1;
		$bracket_match[$bracket_count]=$i1;
		$bracket_count++; $num_brackets++; $logic=1;
	}
	else{
		print STDERR "the line $lines[$il] ends here \n";
		print STDERR "ERROR:\n Problem finding acceptable bracket statement \n";
		print STDERR "I was looking for do, module,subroutine, etc before a {\n";
		print STDERR "and couldn't find it (spelling?????) \n";
		$lines[$il] = "ERROR BEFORE ERROR\n".$lines[$il]."\nERROR AFTER\n";
		&crash_it;
	}
}

##############################################################
####################  check_implicit2    #####################
##############################################################
sub check_implicit2{
	#SUBROUTINE TO ADD IMPLICIT NONES IN THE RIGHT PLACE

  @prog_breaks=("program","subroutine","recursive\\s+subroutine","module",
          "function","\\S+\\s+function", "type\(\\s*\\S+\\s*\)\\s*function");

  @declarations=("logical","real","type","integer","implicit","complex","character","function","interface","\$","contains");

  @lines=split("\n",$program);
  my $progs = join("|^\\s*",@prog_breaks);
  my $decs = join("|^\\s*",@declarations);

  $in_unit=0; $c_init=0; $write_initpar=1; $head=0; $write_doc=1;
  for($i1=0;$i1<@lines;$i1++){
		if($in_unit==0){
    	if($lines[$i1] =~/^\s*$progs/oi){ $in_unit=1;
				for($ia=0;$ia<@prog_breaks;$ia++){ 
    			if($lines[$i1] =~/^\s*$prog_breaks[$ia]/i){ 
						$unit_type=$prog_breaks[$ia];
					}
				}
			}
		}
		elsif($in_unit==1){
   		if($lines[$i1] =~/^\s*($decs)/oi){ $line_num=$i1; $in_unit=2;}
		}
		else{	
			if($lines[$i1] =~/^\s*end\s+$unit_type/){
				if($in_unit==1){ $line_num=$i1;}
				if($lines[$line_num +1] =~/^(\s*)\S/){$blank=$1;}
				$lines[$line_num]=$blank."implicit none\n$lines[$line_num]";
				$in_unit=0;
			}
		}
	}
	$program=join("\n",@lines);

}
##############################################################
####################  post_program_parse #####################
##############################################################
sub post_program_parse{
	@lines=split("\n",$program);
	&reinsert;
	&split_line2;
	
	$program=join("\n",@lines);
	$program=~s/&\n\s*\n+/\n/gm;
#	@lines=split("\n",$program); &crash_it;
	$program=~s/&\s*\n\s*&\s*!/\n!/gm;
	$program=~s/&\s*\n\s*&\s*\n/\n/gm;
	$program=~s/\s*\n\s*\n/\n/gm;
	$program=~s/else\s+where/elsewhere/gm;
	$program=~s/!\s*\$CPP/#/gm;
}

##############################################################
####################      split_line2    #####################
##############################################################
sub split_line2{
	@breaks=(" ", ",", "(",")","+","-","*","/");
	for($i1=0; $i1< @lines; $i1++){
		$split_length=72;
		$pos=0;
		$split_pos=$split_length;
		$spcomment="";
		$finline="";
		$q1=index($lines[$i1],'!',$pos);

#RED Allow ! inside comment
		$qsingle=index($lines[$i1],"'",$pos);
		$qdouble=index($lines[$i1],'"',$pos);
		if($qsingle > -1 && $qsingle < $q1) {$q1 = -1};
		if($qdouble > -1 && $qdouble < $q1) {$q1 = -1};

		if($q1 > -1){
			#split out any comment
			$spline=substr($lines[$i1],0,$q1);
			$spcomment="\n$blank";
			substr($spcomment,length($spcomment),0)=substr($lines[$i1],$q1);
		}
		else {
			$spline=$lines[$i1];
		}
		$size_line=length($spline);
		while($size_line > $split_length){
			#we need to split this line
			# need to determine what this does!
			if($spline =~ /^(\s*)\S.*/){$blank=$1;}
			
		        substr($finline,length($finline),0)=substr($spline,0,$split_length); 	
			# RED 02/08/08 removed & prior to \n
			substr($finline,length($finline),0)="\n     &";
			$tline=substr($spline,$split_length);
			$spline=$tline;
			$size_line=length($spline);
			$split_length=66;
		}
		substr($finline,length($finline),0)=$spline;
		substr($finline,length($finline),0)=$spcomment;
		$lines[$i1]=$finline;
	}
	$program=join("\n",@lines);
}
