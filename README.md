Get MGRAST Data
===============

Download metagenome samples from MG-RAST using the API. Convert and combine these into a single abundance table.

Requirements
------------
* BIOM Format (http://biom-format.org/)
* Curl
* Perl

To get help for each script use the -h option
---------------------------------------------

./download_and_convert.pl -h

./create_table.pl -h

Testing (obtain KO tables)
--------------------------

./download_and_convert.pl test_samples.txt

./create_table.pl downloads/function/KO/*.tab >test_table.txt
