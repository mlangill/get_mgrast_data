#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;
use File::Spec::Functions qw(catfile);
use File::Path qw(make_path);

#Set up options
my %opt=();
GetOptions (\%opt,'output=s','source=s','type=s','auth_key=s','force','help','man') or pod2usage(2);
pod2usage(1) if exists $opt{'help'};
pod2usage(-verbose=>2) if exists $opt{'man'};
pod2usage($0.': You must specify at least MGRAST sample id') if @ARGV==0;
#pod2usage($0.': You must specify an output file with -o ') unless $opt{'output'};

#set defaults
unless(exists $opt{'type'}){
    $opt{'type'}='function';
}
unless(exists $opt{'source'}){
    $opt{'source'}='KO';
}
my $file;
if(exists $opt{'output'}){
    $file=$opt{'output'};
}else{
    $file=$opt{'source'}.'_'.$opt{'type'};
}

my $base_cmd='curl -X GET ';
if($opt{'auth_key'}){
    $base_cmd .= "-H \"auth: $opt{'auth_key'}\" "
}

my @samples;
while(<>){
    chomp;
    push @samples, $_;
}
my $sample_str=join('&id=mgm',@samples);

my $biom_file=$file.'.biom';
    
if((!-e $biom_file) || $opt{'force'}){
    my $curl_cmd= $base_cmd . "\"http://api.metagenomics.anl.gov/matrix/$opt{'type'}\?id=mgm$sample_str\&source=$opt{'source'}\" > $biom_file";
    print $curl_cmd,"\n";
    system($curl_cmd);
}else{
    print "Skipping (use -f to override) the download of $biom_file.\n";
}

my $cmd = 'convert_biom.py ';
my $new_file=$file.'.tab';
    
$cmd .= "-b -i $biom_file -o $new_file";
    
my $metadata_name='ontology';
if($opt{'type'} eq 'organism'){
    $metadata_name='taxonomy';
}
$cmd.=" --header_key $metadata_name";
    
if((!-e $new_file) || $opt{'force'}){
    print $cmd,"\n";
    system($cmd);
}else{
    print "Skipping (use -f to override) the conversion to $new_file.\n";
}




__END__

=head1 Name

download_and_convert.pl - combines abundances of taxa or functions for samples in multiple files into a single file

=head1 USAGE

download_and_convert.pl [--source [KO,...] --type [function,organism,feature] --no_metadata --auth_key <string> --help --man] <files>

E.g.:

download_and_convert.pl list_of_samples.txt

=head1 OPTIONS

=over 4

=item B<-s, --source>

Source of annotations: default: KO

For type 'function': KO, NOG, COG, Subsystems (Note: all of these work fine)

For type 'organism' or 'feature': M5NR, SwissProt, GenBank, IMG, SEED, TrEMBL, RefSeq, PATRIC, KEGG, M5RNA, RDP, Greengenes, LSU, SSU

Working: Greengenes, RefSeq, KEGG, RDP, GenBank (maybe)

Not Working: M5NR, SwissProt, IMG, SEED, TrEMBL, PATRIC, M5RNA, LSU, SSU

(See MGRAST API documentation: http://metagenomics.anl.gov/Html/api.html#matrix)

=item B<-t, --type>

Type of annotation ('function', 'organism', or 'feature'); default: function

=item B<-o, --output>

File name to be used for outputting biom and tab files. Default is to use the source and type combined (e.g. 'KO_function')

=item B<-a, --auth_key>

Your MGRAST auth id, used for obtaining non-public samples.

=item B<-f, --force>

Force redownloading and reconverting all samples. (Default is to skip if files already exist).

=item B<-h, --help>

Displays the usage message.

=item B<-m, --man>

Displays the entire help documentation.

=back

=head1 DESCRIPTION

B<download_and_convert.pl> - Downloads each sample in BIOM format and converts to a nicer tab delimited format. Requires that BIOM be installed. Should work for either taxonomy or function. However, MG-RAST is currently not formatting their BIOM files correctly so some options will not work. 

=head1 AUTHOR

Morgan Langille, E<lt>morgan.g.i.langille@gmail.com<gt>

=head1 DATE

27-Jun-2013

=cut

