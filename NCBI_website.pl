#!/home/bif701_163a30/software/bin/perl

use strict;
use warnings;

use CGI;
use LWP::Simple;
use Mail::Sendmail;

my $cgi = new CGI;
my (@attributes, $tmpAttr, $baseURL, $genbankFile, $virus, $ncbiURL, $rawData);
my (@tmpArray, @genbankData, $start, $i, $result, $baseCount, $email);

@attributes = $cgi->param('attributes');
$virus = $cgi->param('viruses');
$email = $cgi->param('mailto');

$baseURL = "ftp://ftp.ncbi.nih.gov/genomes/Viruses/";

print "Content-type: text/html\n\n";

print <<"EOF";
<html xmlns='http://www.w3.org/1999/xhtml' lang='en' xml:lang='en'>
<head>
   <title>Generic HTML Form for BIF712 (153) Assignment #2</title>
   <script type="text/javascript">
      function checkUncheckAll(oCheckbox) {
         var el, i = 0, bWhich = oCheckbox.checked, oForm = oCheckbox.form;
         while (el = oForm[i++])
            if (el.type == 'checkbox')
               el.checked = bWhich;
      }
   </script>
   <style type='text/css'>
    .c0  { font-family: arial, monospace; font-size: 10pt }
    .c1  { font-family: arial, monospace; font-size: 16pt }

    </style>
</head>
<body onload="document.forms[0].reset( )">
<pre>
<span class="c1">   NCBI GenBank File Retrieval Form (NGFRF)

   Select Fields To Display...</span><span class='c0'>
   <form method='post' action='genbank.pl' target="_blank">
   <input type='checkbox' name='attributes' value='LOCUS'>LOCUS
   <input type='checkbox' name='attributes' value='DEFINITION'>DEFINITION
   <input type='checkbox' name='attributes' value='ACCESSION'>ACCESSION
   <input type='checkbox' name='attributes' value='VERSION'>VERSION
   <input type='checkbox' name='attributes' value='KEYWORDS'>KEYWORDS
   <input type='checkbox' name='attributes' value='SOURCE'>SOURCE
   <input type='checkbox' name='attributes' value='ORGANISM'>ORGANISM
   <input type='checkbox' name='attributes' value='REFERENCE'>REFERENCE
   <input type='checkbox' name='attributes' value='AUTHORS'>AUTHORS
   <input type='checkbox' name='attributes' value='TITLE'>TITLE
   <input type='checkbox' name='attributes' value='JOURNAL'>JOURNAL
   <input type='checkbox' name='attributes' value='MEDLINE'>MEDLINE
   <input type='checkbox' name='attributes' value='FEATURES'>FEATURES
   <input type='checkbox' name='attributes' value='BASECOUNT'>BASE COUNT
   <input type='checkbox' name='attributes' value='ORIGIN'>ORIGIN

   <input type='checkbox' name='CHECKALL' onclick="checkUncheckAll(this)" /><strong>CHECK / UNCHECK All</strong>
   </span>

   <select name='viruses'>
      <option value='Zaire_ebolavirus_uid14703/NC_002549.gbk'>Zaire ebola virus [accn] NC_002549
      <option value='Human_respiratory_syncytial_virus_uid15003/NC_001781.gbk'>Human respiratory syncytial virus [accn] NC_001781
      <option value='African_green_monkey_polyomavirus_uid15320/NC_004763.gbk'>African green monkey polyomavirus [accn] NC_004763
      <option value='Staphylococcus_aureus_phage_P68_uid14269/NC_004679.gbk'>Staphylococcus aureus phage [accn] NC_004679
      <option value='Yersinia_pestis_phage_phiA1122_uid14332/NC_004777.gbk'>Yesrsinia pestis phage [accn] NC_004777
   </select>

   To receive a copy of the retrieved information, please enter your E-mail address below.

   Email: <input name='mailto' type='text' size='30'><br />
   <input type='submit' value='Process'> <input type='reset'>

EOF

#print "Test Genbank solution\n";
#print "virus selected is: '$virus'\n";
$ncbiURL = $baseURL . $virus;
#print "full URL: $ncbiURL\n";


@tmpArray = split('/', $virus);  # capture the accession number from the string
$genbankFile = $tmpArray[1];     # the 2nd element of the array after the split '/'
#print "genbank file to write is: $genbankFile\n";

unless(-e $genbankFile) {
   $rawData = get($ncbiURL); # this function should download the genbank file
                             # and store it in the current working directory
   open(FD, "> $genbankFile") || die("Error opening file... $genbankFile $!\n");
   print FD $rawData;
   close(FD);
}

# slurp the genbank file into a scalar!
$/ = undef;
open(FD, "< $genbankFile") || die("Error opening file... $genbankFile $!\n");
$rawData = <FD>;
close(FD);

$result = "";
$start = 1;
$i = 1;

$tmpAttr = "BASECOUNT";

foreach $tmpAttr (@attributes) {
   if($tmpAttr =~ /LOCUS/) {
      $rawData =~ /(LOCUS.*)DEFINITION/s;
      print "$1";
      $result .= $1;  # storing the result in a scalar to allow
                      # for the data to be sent by mail
   }
   elsif($tmpAttr =~ /KEYWORDS/) {
      $rawData =~ /(KEYWORDS.*?)REFERENCE/s;
      print "$1";
      $result .= $1;
   }
   elsif($tmpAttr =~ /DEFINITION/) {
      $rawData =~ /(DEFINITION.*?)ACCESSION/s;
      print "$1";
      $result .= $1;
   }
   elsif($tmpAttr =~ /ACCESSION/) {
      $rawData =~ /(ACCESSION.*?)VERSION/s;
      print "$1";
      $result .= $1;
   }
   elsif($tmpAttr =~ /VERSION/) {
      $rawData =~ /(VERSION.*?)DBLINK/s;
      print "$1";
      $result .= $1;

   }
   elsif($tmpAttr =~ /SOURCE/) {
      $rawData =~ /(SOURCE.*?)ORGANISM/s;
      print "$1";
      $result .= $1;

   }
   elsif($tmpAttr =~ /ORGANISM/) {
      $rawData =~ /(ORGANISM.*?)REFERENCE/s;
      print "$1";
      $result .= $1;

   }
   elsif($tmpAttr =~ /REFERENCE/) {
      $rawData =~ /(KEYWORDS.*?)REFERENCE/s;
      print "$1";
      $result .= $1;

   }
     elsif($tmpAttr =~ /AUTHORS/) {
      $rawData =~ /(KEYWORDS.*?)REFERENCE/s;
      print "$1";
      $result .= $1;

   }
     elsif($tmpAttr =~ /TITLE/) {
      $rawData =~ /(KEYWORDS.*?)REFERENCE/s;
      print "$1";
      $result .= $1;

   }
     elsif($tmpAttr =~ /JOURNAL/) {
      $rawData =~ /(JOUNRAL.*?)COMMENT/s;
      print "$1";
      $result .= $1;

   }
   elsif($tmpAttr =~ /MEDLINE/) {
      $rawData =~ /(PUBMED.*?)REFERENCE/s;
      print "$1";
      $result .= $1;

   }
   elsif($tmpAttr =~ /FEATURES/) {
      $rawData =~ /(FEATURES.*?)ORIGIN/s;
      print "$1";
      $result .= $1;

   }

   elsif($tmpAttr =~ /ORIGIN/) {
      $rawData =~ /(ORIGIN.*)/s;
      print "$1";
      $result .= $1;

   }
   elsif($tmpAttr =~ /BASECOUNT/) {
      $rawData =~ /(ORIGIN.*)/s;
          $baseCount = count ($rawData);
          #$result .= $baseCount;
          print $baseCount;

   }
   elsif($tmpAttr =~ /CHECKALL/) {
          print $rawData;

   }
}



sub count {
        my $dna = shift(@_);
        my ($a, $c, $g, $t);

$dna=~ s/[^atcg]//g;

my $dnaLength = length ($dna);

for (my $i=0; $i<$dnaLength; $i++){
        if (substr($dna, $i, 1) eq "a"){
        $a++
        }
        elsif (substr($dna, $i, 1) eq "c"){
        $t++
        }
        elsif (substr($dna, $i, 1) eq "g"){
        $c++
        }
        elsif (substr($dna, $i, 1) eq "t"){
        $g++
        }

}

return "$a A $c C $g G $t T ";

}

my %mail = ( To      => $email,
             From    => 'my.seneca.id@myseneca.ca',
             Message => "$result"
           );

sendmail(%mail) or die $Mail::Sendmail::error;
my $emailValdation = check_email ("$email");
print $emailValdation;

sub check_email {
    my $email = shift @_;

        if ($email =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)/ || $email !~ /^.+\@(\[?)[a-zA-Z0-9\-\.]+\.([a-zA-Z]{2,3}|[0-9]{1,3})(\]?)$/) {

        return "error invalid email address\n";;
    }
    else{
        return "OK! Sent mail message...\n";
    }
}

print "</form>";
print "</pre></body></html>\n";

print "</pre></body></html>\n";
