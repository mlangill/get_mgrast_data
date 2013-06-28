#!/usr/bin/perl


use warnings;
use strict;
use File::Basename;
use Getopt::Long;
use Pod::Usage;

#Set up options
my %opt=();
GetOptions (\%opt,'replace_spaces','transpose','no_metadata','help','man') or pod2usage(2);
pod2usage(1) if exists $opt{'help'};
pod2usage(-verbose=>2) if exists $opt{'man'};
pod2usage($0.': You must specify at least one file.') if @ARGV==0;

my @files=@ARGV;

my @sample_names;
my %table;
foreach my $file (@files){
    my ($sample_name,$dir,$suffix)= fileparse($file, qr/\.[^.]*/);
    push(@sample_names,$sample_name);

    open(my $IN,'<',$file) || die "Can't read $file : $!";
    #throwaway headers
    <$IN>;
    <$IN>;
    while(<$IN>){
	chomp;
	my($obs_id,$abundance,$e,$p,$l,$ontology)=split(/\t/,$_);
	if($opt{'replace_spaces'}){
	    $obs_id =~ s/ /_/g;
	}
	$table{$obs_id}{$sample_name}=$abundance;
	unless(exists($table{$obs_id}{'metadata'})){
	    $table{$obs_id}{'metadata'}=$ontology;
	}
    }
}

####now print out the data structure as a table

if($opt{'transpose'}){
    #print header
    print join("\t",'ids',keys %table),"\n";
    foreach my $sample (@sample_names){
	my @counts;
	foreach my $obs_id (keys %table){
	    if(exists($table{$obs_id}{$sample})){
		push(@counts,$table{$obs_id}{$sample});
	    }else{
		push(@counts,0);
	    }
	}
	print join("\t",$sample,@counts),"\n";
    }
}else{

    #print header
    if($opt{'no_metadata'}){
	print join("\t",'ids',@sample_names),"\n";
    }else{
	print join("\t",'ids',@sample_names,'metadata'),"\n";	
    }
    foreach my $obs_id (keys %table){
	my @counts;
	foreach my $sample (@sample_names){
	    if(exists($table{$obs_id}{$sample})){
		push(@counts,$table{$obs_id}{$sample});
	    }else{
		push(@counts,0);
	    }
	}
	if($opt{'no_metadata'}){
	    print join("\t",$obs_id,@counts),"\n";
	}else{
	    print join("\t",$obs_id,@counts,$table{$obs_id}{'metadata'}),"\n";
	}
    }
}

__END__

=head1 Name

create_table.pl - combines abundances of taxa or functions for samples in multiple files into a single file

=head1 USAGE

create_table.pl [--replace_spaces --transpose --no_metadata --help --man] <files>

E.g.:

create_table.pl downloads/functions/KO/*.tab

=head1 OPTIONS

=over 4

=item B<-t, --transpose>

Output table as each row as a sample and each column as a taxa or function

=item B<-r, --replace_spaces>

Replace spaces in taxa or function ids as underscores. (Note: ontology metadata will likely contain spaces anyway)

=item B<-n, --no_metadata>

Don't output the metadata associated with the taxa or function ids

=item B<-h, --help>

Displays the usage message.

=item B<-m, --man>

Displays the entire help documentation.

=back

=head1 DESCRIPTION

B<create_table.pl>

=head1 AUTHOR

Morgan Langille, E<lt>morgan.g.i.langille@gmail.com<gt>

=head1 DATE

27-Jun-2013

=cut

