import sys, pickle

'''
Pickle go.obo file for use in parse_go_obo.py
Usage is python 1_pickle.obo.py
'''
### 

### Define functions
def read_file(input_file):
    with open(input_file) as f_in:
        txt = (line.rstrip() for line in f_in)
        txt = list(line for line in txt if line)
    return txt

go_obo_file = "data/go.obo" # go.obo in working dir

obo_txt = read_file(go_obo_file)
pickle.dump(obo_txt, open("data/go.p", "wb"))

