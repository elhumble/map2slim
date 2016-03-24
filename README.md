# go_annotation

Processing steps to map gene ontologies onto a GOslim

First, download go.obo from http://geneontology.org/ontology/go.obo and save as `data/go.obo`  
Save the annotation file you want to slim down (contig name followed by tab sep GO terms) in `data/`  
Save the GOslim you want in `goslim` directory

1. Run `1_pickle.obo/py` to pickle go.obo into go.p  
Usage is python 1_pickle.obo.py
2. Run `2_parse_go_obo.py` to properly index go.p file  
Usage is python 2_parse_go_out.py
3. Run `3_go2gaf.py` to generate gene association file  
Usage is python 3_go2gaf.py data/inFile data/go.p > data/outFile.gaf  
inFile is full GO annotation file
4. Run `4_map2slim.sh` to get slim terms using owltools  
Usage is 4_map2slim.sh

* `annotateSNPs.R` does some analysis with output slim file