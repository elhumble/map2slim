'''
Generate gene association file using GO annotation text file and GOID to term aspect index file
Usage is python 3_go2gaf.py data/inFile data/go.p > data/outFile.gaf
Output is .gaf file for use in GOSlim mapping
Author Damian Kao (http://blog.nextgenetics.net/?e=5), modified by Emily Humble
'''


import sys, pickle

#input the gene annotation file (inFile) and pickled go.p GOID/terms index file (goFile)
#inFile is your custom annotations
#goFile is the unpickled GO IDs to GO categories index you generated from 2_parse_go_obo.py
inFile = open(sys.argv[1],'r')
goFile = pickle.load(open(sys.argv[2],'rb'))


#parse the GOID/terms index and store it in the dictionary, goHash
goHash = {}

for line in goFile:
    #skip lines that start with '!' character as they are comment headers
    if line[0] != "!":
        data = line.strip().split('\t')
       # skip obsolete terms
        if data[-1] != 'obs':
            for info in data:
                if info[0:3] == "GO:":
                    #create dictionary of term aspects
                    goHash[data[0]] = data[-1]

#Here are some columns that the GAF format wants. 
#Since Ontologizer doesn't care about this, we can just make it up
DB = 'yourOrganism'
DBRef = 'PMID:0000000'
DBEvi = 'ISO'
DBObjectType = 'gene'
DBTaxon = 'taxon:79327'
DBDate = '23022011'
DBAssignedBy = 'PFAM'

#potential obselete goids that you have in your annotation
potentialObs = []

#if you specified to not print out obsolete goids, then print out the .gaf
if len(sys.argv) == 3:
    print '!gaf-version: 2.0'

#Loop through the GO annotation file and generate assocation lines.
for line in inFile:
    data = line.strip().split('\t')

    #if gene has go annotations
    if len(data) > 1:
        #gid is the gene id, goIDs is an array of assocated GO ids
        gid = data[0]
        goIDs = data[1].split(',')

        #second column of the .gaf file that Ontologizer doesn't care about
        DBID = "db." + gid

        #third column is the name of the gene which Ontologizer does use
        DBObjSym = gid
    
        #for each GO ID in the line, print out an association line
        for goID in goIDs:
            if goHash.has_key(goID):
                DBAspect = goHash[goID]
                DBObjName = 'myOrganism' + DBID

                outArray = [DB,DBID,DBObjSym,'0',goID,DBRef,DBEvi,'0',DBAspect,'0','0',DBObjectType,DBTaxon,DBDate,DBAssignedBy]
                
                #only print out the .gaf file if you didn't specify to print out obsolete goids.
                if len(sys.argv) == 3:
                    print '\t'.join(outArray)
            else:
                potentialObs.append(goID)

#if there is a 4th argument, print out the potential obsolete list
if len(sys.argv) == 4:
    print '\n'.join(set(potentialObs))
