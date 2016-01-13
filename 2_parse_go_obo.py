#!/usr/bin/python

'''
Parse GO term from http://purl.obolibrary.org/obo/go.obo to generate proper index file for use in making a gaf file
Usage is python 2_parse_go_out.py 
Output is go.p pickled GOIDs index file
Author Byoungnam Min on Jul 2, 2015
'''

### Import modules
import sys, re, os, cPickle


### Parameters
go_obo_file = 'go.obo'
go_pickle = 'go.p'


### Define functions
def read_file(input_file):
    with open(input_file) as f_in:
        txt = (line.rstrip() for line in f_in)
        txt = list(line for line in txt if line)
    return txt


### Read obo file
obo_txt = read_file(go_obo_file)


### Parse it :) Slow is as good as Fast
go_id = ''
D_go = {}
for line in obo_txt:
    if line.startswith('id:'):
        go_id = line.split(' ')[1]
    elif line.startswith('name:'):
        go_name = line.replace('name: ', '')
    elif line.startswith('namespace:'):
        go_namespace = line.replace('namespace: ', '')
        D_go[go_id] = (go_name, go_namespace)
    elif line.startswith('alt_id:'):
        go_alt_id = line.replace('alt_id: ', '')
        D_go[go_alt_id] = (go_name, go_namespace)
        
cPickle.dump(D_go, open(go_pickle, 'wb'))
