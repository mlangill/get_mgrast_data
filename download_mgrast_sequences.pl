#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;
use File::Spec::Functions qw(catfile);
use File::Path qw(make_path);

#Set up options
my %opt=();
GetOptions (\%opt,'keep_only=s','source=s','type=s','auth_key=s','evalue=s','force_downloading','force_filtering','help','man') or pod2usage(2);
pod2usage(1) if exists $opt{'help'};
pod2usage(-verbose=>2) if exists $opt{'man'};
pod2usage($0.': You must specify at least MGRAST sample id') if @ARGV==0;

#set defaults
unless(exists $opt{'type'}){
    $opt{'type'}='function';
}
unless(exists $opt{'source'}){
    $opt{'source'}='KO';
}

my $base_cmd='curl -X GET ';
if($opt{'auth_key'}){
    $base_cmd .= "-H \"auth: $opt{'auth_key'}\" "
}

my @samples;
while(<>){
    chomp;
    my $sample_str=$_;

    my $file=join("_",$sample_str,$opt{'source'},$opt{'type'},'sequences');
    my $download_file=$file.'.raw_mgrast';
    
    if((!-e $download_file) || $opt{'force_downloading'}){
	my $curl_cmd= $base_cmd . "\"http://api.metagenomics.anl.gov/annotation/sequence/mgm$sample_str\?type=$opt{'type'}\&source=$opt{'source'}\" > $download_file";
	print $curl_cmd,"\n";
	system($curl_cmd);
    }else{
	print "Skipping the download of $download_file. (use --force_downloading to override)\n";
    }

    my $new_file=$file.'.fna';
    if((!-e $new_file) || $opt{'force_filtering'}){

	open(my $IN,'<',$download_file)|| die("Can't read $download_file: $!");
	open(my $OUT,'>',$new_file)|| die("Can't write to $new_file: $!");
	my $blah=<$IN>;
	while(<$IN>){
	    chomp;
	    my($seq_id,$m5nr_id,$function,$seq)=split(/\t/,$_);
	    next unless $seq;
	    if($opt{'keep_only'} && ! ($function=~/$opt{'keep_only'}/)){
		next;
	    }
	    print $OUT ">$seq_id $m5nr_id $function\n";
	    print $OUT $seq,"\n";
	}
    }else{
	print "Skipping the conversion to $new_file. (use --force_filtering to override)\n";
    }
}



__END__

=head1 Name

download_mgrast_sequences.pl - combines abundances of taxa or functions for samples in multiple files into a single file

=head1 USAGE

download_mgrast_sequences.pl [--source [KO,...] --type [function,organism,feature] --no_metadata --auth_key <string> --help --man] <files>

E.g.:

download_sequences.pl list_of_samples.txt

=head1 OPTIONS

=over 4

=item B<-s, --source>

Source of annotations: default: KO

For type 'function': KO, NOG, COG, Subsystems (Note: all of these work fine)

For type 'organism' or 'feature': M5NR, SwissProt, GenBank, IMG, SEED, TrEMBL, RefSeq, PATRIC, KEGG, M5RNA, RDP, Greengenes, LSU, SSU

=item B<-t, --type>

Type of annotation ('function', 'organism', or 'feature'); default: function

=item B<-k, --keep_only>

Keep only sequences that have their function/organism matching the given string.

=item B<-a, --auth_key>

Your MGRAST auth id, used for obtaining non-public samples.

=item B<--force_download>

Force redownloading of sequences (Default is to skip if files already exist).

=item B<--force_filtering>

Force reconverting and filtering of sequences. (Default is to skip conversion and filterint if files already exist).

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

