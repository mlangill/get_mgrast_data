#!/usr/bin/env python
from __future__ import division

__author__ = "Morgan Langille"
__credits__ = ["Morgan Langille"]
__license__ = "GPL"
__version__ = "0.1"
__maintainer__ = "Morgan Langille"
__email__ = "morgan.g.i.langille@gmail.com"
__status__ = "Development"


from cogent.util.option_parsing import parse_command_line_parameters, make_option
from biom.parse import parse_biom_table
from os.path import join,splitext
import gzip

script_info = {}
script_info['brief_description'] = "Convert a BIOM table to a compatible STAMP profile table."
script_info['script_description'] = "Metadata will be parsed and used as hiearachal data for STAMP."

script_info['script_usage'] = [\
("Minimum Requirments","A BIOM file. ","%prog table1.biom > table1.spf")]

script_info['output_description']= "Output is written to STDOUT"

script_info['optional_options'] = [\
    make_option('-m','--metadata',default='taxonomy',type="string",help='Name of metadata. [default: %default]')]


script_info['disallow_positional_arguments'] = False

script_info['version'] = __version__
       

def main():
    option_parser, opts, args =\
                   parse_command_line_parameters(**script_info)

    min_args = 1
    if len(args) < min_args:
       option_parser.error('A BIOM file must be provided.')

    file_name = args[0]

    #allow file to be optionally gzipped (must use extension '.gz')
    ext=splitext(file_name)[1]
    if (ext == '.gz'):
        table = parse_biom_table(gzip.open(file_name,'rb'))
    else:
        table = parse_biom_table(open(file_name,'U'))

    metadata_name=opts.metadata

    #figure out the longest list within the given metadata
    max_len_metadata = max(len(p[metadata_name]) for p in table.ObservationMetadata)

    #make the header line
    header=[]
    #make simple labels for each level in the metadata (e.g. 'Level_1', 'Level_2', etc.)
    for i in range(max_len_metadata):
        header.append('Level_'+ str(i+1))
    
    #add the sample ids to the header line
    header.extend(table.SampleIds)
    
    print "\t".join(header)

    #now process each observation (row in the table)
    for obs_vals,obs_id,obs_metadata in table.iterObservations():
        row=obs_metadata[metadata_name]
        
        #Add blanks if the metadata doesn't fill each level
        if len(row) < max_len_metadata:
            for i in range(max_len_metadata - len(row)):
                row.append('')

        #Add count data to the row
        row.extend(map(str,obs_vals))
        print "\t".join(row)
        
    

if __name__ == "__main__":
    main()

