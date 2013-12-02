Get MG-RAST Data
===============

A suite of scripts that allow easy retrieval of information from the MG-RAST API. 

Requirements
------------

* BIOM Format (http://biom-format.org/)
* Curl
* Perl

Scripts
-------

* download_mgrast_abundance_tables.pl -- Downloads 'feature' by sample abundance tables, where 'feature' can be from several taxonomic or functional databases.  
* download_mgrast_sequences.pl -- Downloads sequences associated with each sample.
* biom_to_stamp.py -- A multipurpose file to convert BIOM files (with various types of metadata) into a STAMP formatted file. 

To get help for each script use the -h option
---------------------------------------------

* ./download_mgrast_abundance_tables.pl -h
* ./download_mgrast_sequences.pl -h 
* ./biom_to_stamp.py -h

Examples/Testing
----------------

* Downloads and creates both a BIOM table (KO_function.biom) and tab-delimited table (KO_function.tab)

  	 ./download_mgrast_abundance_tables.pl test_samples.txt

* Create a STAMP format file
  	 
	 ./biom_to_stamp.py -m ontology KO_function.biom > KO_function.spf

* Download sequences associated with a list of samples

  	   ./download_mgrast_sequences.pl test_stamples.txt