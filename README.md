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

Testing (generates the files KO_function.biom and KO_function.tab)
--------------------------

./download_and_convert.pl test_samples.txt
