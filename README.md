# go_annotation

Processing steps to map gene ontologies onto a GOslim

First, download go.obo from http://geneontology.org/ontology/go.obo and save as data/go.obo
Save a

1. Run `1_pickle.obo/py` to pickle file into go.p
Usage is python 1_pickle.obo.py
2. Run `2_parse_go_obo.py` to properly index go.p file
Usage is python 2_parse_go_out.py 
3. Run `3_go2gaf.py` to generate gene association file
Usage is python 3_go2gaf.py data/inFile data/go.p > data/outFile.gaf
inFile is GO annotation text file (Contig Name followed by tab sep GO terms)
4. Run owltools map2slim using a GOslim

`annotateSNPs.R` does some analysis with output slim file