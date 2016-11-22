'''
Extract features by coordinate from GFF file:
1. INTERVAL: extract specific feature in interval of coordinates
2. MULTIPLE: get all features for one or more specific nucleotide positions
GFF should be sorted by coordinate and by generality of terms (e.g. gene>mRNA>CDS>exon)
GFF has 1-based coordinates!
''' 
import os, re, sys
import copy
import pickle
import natsort
from argparse import ArgumentParser
from argparse import ArgumentDefaultsHelpFormatter
from genofeat.gff.GFF import GFF
import bio.annotation.structuralannotation.feature as saf
def main():
    
    parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter, add_help=True)
    subparsers = parser.add_subparsers(help="Sub-command help")
    intervalP = subparsers.add_parser('interval', help='Get coordinates of features in interval')
    intervalP.add_argument("-a","--start", help="start location", default=1, dest="start", type=int, required=True)
    intervalP.add_argument("-c","--chrom", help="chromosome or seqname", default="1", dest="chrom", required=True)
    intervalP.add_argument("-g","--gff",help="GFF file", dest="gff", required=True)
    intervalP.add_argument("-f","--feature", dest="feature",default="gene", help="Feature type: gene, exon, intron, ...")
    intervalP.add_argument("-o", "--output", dest="output", help="output file")
    intervalP.add_argument("-s","--stop", help="stop", default=0, dest="stop", type=int, required=True)
    intervalP.add_argument("--strict", help="Strict coordinates", default=False, action="store_true", dest="strict")
    intervalP.set_defaults(func=interval)
    
    multipleP = subparsers.add_parser('multiple', help='summarize info for multiple groups')
    multipleP.add_argument("-f","--file", dest="position", help="File with position of interest (one per line).", required=True)
    multipleP.add_argument("-g","--gff",help="GFF file", dest="gff", required=True)
    multipleP.add_argument("-o", "--output", dest="output", help="output file")
    multipleP.add_argument("-0", "--zero", dest="zeroformat",action="store_true", help="Positions are 0- or 1-based, default=1")
    multipleP.add_argument("--addChr", action="store_true", help="If seqname/chromosome index starts with digit, add prefix 'Chr'")
    multipleP.add_argument("--nocache", action="store_true",help="Do not use pickled GFF file", dest="nocache")
    multipleP.add_argument("--delChr",action="store_true", help="Remove prefix 'Chr' from seqname")
    multipleP.add_argument("--gff-pid", default="Parent",help="Identifier for parental information",dest="gffpid")
    multipleP.add_argument("--onlysummary",action="store_true",help="Only summarize info",dest="onlysummary")
    multipleP.add_argument("--promotor-length",default=1000,help="upstream nr nucleotides to consider promotor", dest="promotor",type=int)
    multipleP.set_defaults(func=multiple)
    
    #extract command line arguments
    args = parser.parse_args()
    args.func(args)
    
def interval(args):
    '''
    Get feature coordinates in interval
    '''
    start = args.start
    stop = args.stop
    feature = args.feature
    
    #parse file
    gff = GFF(args.gff)
    
    #get chromosome
    featBySeqName = gff.getFeatBySeqName(args.chrom)
    
    #get features within coordinates
    features = featBySeqName.getFeatByCoordinate(feat=feature,start=start,end=stop, strict=args.strict)
    
    print("{0} feature(s) retrieved".format(len(features)))
    
    #if len(features)>0: print(features[0]) 
    
    if args.output:
        with open(args.output,'w') as fo:
            for f in features:
                fo.write("{0}\n".format(f))
                
def multiple(args):
    '''
    Read multiple positions and retrieve structural annotation
    File format: <position> <seqname> <strand>
    '''
    #open coordinates file
    print("Parsing nucleotide coordinates...")
    if args.zeroformat:
        print("\tCoordinates are set to be 0-based. GFF is 1-based. Hence, coordinates are incremented by 1.")
    coordinates=dict()
    nrC = 0
    with open(args.position,'r') as f:
        for line in f:
            line = line.rstrip('\n\r')
            if line=="" or line.startswith("#"): continue
            (pos,seqname,strand) = line.split('\t')
            pos=int(pos)
            nrC+=1
            if args.zeroformat:
                pos+=1
            if args.addChr and re.match('^\d+',seqname):
                seqname="Chr{0}".format(seqname)
            elif args.delChr and re.match('^Chr',seqname):
                seqname=seqname.replace("Chr", "")
                #remove leading zeros
                matcher = re.match('^0+([1-9])$',seqname)
                if matcher:
                    seqname = matcher.group(1)
            if not seqname in coordinates.keys():
                coordinates[seqname]=set()
            coordinates[seqname].add((pos,strand))
    print("{0} coordinates found.".format(nrC))
    print("...done")
    
    #parse file
    print("Parsing GFF file...")
    pickleF = "{0}.pck".format(args.gff)
    if os.path.exists(pickleF) and not args.nocache:
        gff = pickle.load(open(pickleF,'rb'))
    else:
        try:
            gff = GFF(args.gff)
            pickle.dump(gff, open(pickleF,'wb'))
        except Exception as e:
            print(e)
            sys.exit(1)
    print("...done")
    
    #loop positions and retrieve annotations
    print("Fetching annotations for positions and strand orientation...")
    features=dict()
    promotors = dict()
    downstreamSites = dict()
    nrProm = 0
    nrDS = 0
    #keep track of number of hits of each specific feature
    featureNameSet = dict()
    for fns in gff.getFeatureNameSet():
        featureNameSet[fns]=set()
    tableText = "Seqname\tCoordinate\tStrand\tProtein-coding gene\tNon-coding gene\tTranscript\tExon\tIntron\tCDS\t3pUTR\t5pUTR"
    if args.promotor != 0:
        tableText += "\tpromotor\tdownstream"
    
    #Get annotations
    # count specific type of annotations. In case of isoforms, double counting of certain elements such as exon/intron/cds is prevented
    for seqname in sorted(coordinates.keys()):
        if not seqname in features.keys():
            features[seqname] = dict()
            promotors[seqname] = dict()
            downstreamSites[seqname] = dict()
        for ps in sorted(coordinates[seqname]):
            c=ps[0]
            s=ps[1]
            features[seqname][ps] = list()
            #checklist
            isGenic=0
            isNonCoding=0
            isTranscript=0
            isExon = 0
            isIntron = 0
            isCDS = 0
            is3pUTR = 0
            is5pUTR = 0
            isPromotor = 0
            isDownstream = 0
            #check if coordinate falls within gene
            genes = gff.isGenic(seqname, c, s)
            for gene in genes:
                if gene.isCoding():
                    isGenic=1
                else:
                    isNonCoding=1
                featureNameSet[gene.getType()].add(gene)
                features[seqname][ps].append(gene)
                #get transcripts
                transcripts = gene.getTranscripts()
                assert transcripts, "No transcripts present for this gene. Check GFF parsing for this gene ({0})".format(gene)
                if len(transcripts) > 1:
                    print("Warning: coordinate {0} belonging to genic region {1} covered by multiple transcripts!".format(c,gene.getID()))
                for t in transcripts:
                    if c >= t.getStart() and c <= t.getStop():
                        featureNameSet[t.getType()].add(t)
                        features[seqname][ps].append(t)
                        isTranscript=1
                        for e in t.getExons():
                            if c>= e.getStart() and c<=e.getStop():
                                isExon = 1
                                #check if exon element with same coordinates is already present
                                featureNameSet[e.getType()].add(e)
                                features[seqname][ps].append(e)
                                break
                        for i in t.getIntrons():
                            if c>=i.getStart() and c<=i.getStop():
                                isIntron=1
                                #check if intron element with same coordinates is already present
                                featureNameSet[i.getType()].add(i)
                                features[seqname][ps].append(i)
                                break
                        for cds in t.getCDS():
                            if c>=cds.getStart() and c<=cds.getStop():
                                isCDS = 1
                                #check if cds element with same coordinates is already present
                                featureNameSet[cds.getType()].add(cds)
                                features[seqname][ps].append(cds)
                                break
                        utr3p = t.get3pUTR()
                        utr5p = t.get5pUTR()
                        for u3 in utr3p:
                            if c>= u3.getStart() and c<=u3.getStop():
                                is3pUTR = 1
                                #check if utr element with same coordinates is already present
                                found=False
                                featureNameSet[u3.getType()].add(u3)
                                features[seqname][ps].append(u3)
                                break
                        for u5 in utr5p:
                            if c>= u5.getStart() and c<=u5.getStop():
                                is5pUTR = 1
                                #check if utr element with same coordinates is already present
                                featureNameSet[u5.getType()].add(u5)
                                features[seqname][ps].append(u5)
                                break
                            
            if args.promotor != 0:
                #loop all genes and fetch promotor regions and downstream sites
                for g in gff.getGenes(seqname=seqname):
                    #check for promotor region or downstream genic
                    gg = g.getGeneStructure()[0]
                    prom = gg.getPromotor(upstream=args.promotor)
                    if prom:
                        if c >= prom[0] and c<= prom[1]:
                            isPromotor=1
                            if not c in promotors[seqname].keys():
                                promotors[seqname][(c,s)] = list()
                            promotors[seqname][(c,s)].append(gg)
                    else:
                        #check downstream for same length as promotor
                        gg = g.getGeneStructure()[0]
                        ds = gg.getDownstreamSite(downstream=args.promotor)
                        if c >= ds[0] and c <= ds[1]:
                            isDownstream = 1
                            if not c in downstreamSites[seqname].keys():
                                downstreamSites[seqname][(c,s)] = list()
                            downstreamSites[seqname][(c,s)].append(gg)
                if isPromotor:
                    nrProm += 1
                if isDownstream:
                    nrDS += 1
            
            if args.promotor != 0:
                #print tabular format
                tableText += "\n{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}\t{8}\t{9}\t{10}\t{11}\t{12}".format(seqname,c,s,isGenic,isNonCoding,isTranscript,isExon,isIntron,isCDS,is3pUTR,is5pUTR,isPromotor,isDownstream)
            else:
                #print tabular format
                tableText += "\n{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}\t{8}\t{9}\t{10}".format(seqname,c,s,isGenic,isNonCoding,isTranscript,isExon,isIntron,isCDS,is3pUTR,is5pUTR)
            
    print("...done")
                    
    #write output
    print("Writing output...")
    nrNoAnnot=0
    nrAnnot=0
    if os.path.exists(args.output):
        os.remove(args.output)
    with open(args.output,'w') as fo:
        fo.write("#Output generated based on:\n")
        fo.write("#\tPositions file: {0}\n".format(args.position))
        fo.write("#\tGFF: {0}\n".format(args.gff))
        if not args.onlysummary:
            fo.write("#\tOnly information for specific seqname, position and strand is reported.")
            for seqname in natsort.natsorted(features.keys()):
                for ps in sorted(features[seqname].keys()):
                    pos = ps[0]
                    strand = ps[1]
                    line=""
                    ga = getFeatureAssociation(features[seqname][ps])
                    if len(ga)>0:
                        line += "\n###"
                        for gidx in range(0,len(ga)):
                            ggidx=None
                            for ggidx in ga[gidx]:
                                line+="\n"
                            line += "{0}\t{1}\t{2}\t{3}".format(seqname,pos,strand,ggidx)
                        nrAnnot+=1
                    else:
                        #line += "{0}\t{1}\tNo annotation".format(seqname,pos)
                        nrNoAnnot+=1
                    fo.write(line)
            
            if args.promotor != 0:
                fo.write("\n\n###########\n# PROMOTOR #\n###########")
                fo.write("\n\n#Positions present in promotor region (set as TSS-{0}):".format(args.promotor))
                fo.write("\n#Take care: this region may embed one or more other genes!")
                fo.write("\n#Seqname\tPosition\tStrand\tPromotor of gene (type,strand)\t[if position belongs to genic region: gene ID (type, strand)]")
                nrPromSameGene=0
                nrPromOtherGeneSameStrand=0
                nrPromOtherGeneOtherStrand=0
                for seqname in natsort.natsorted(promotors.keys()):
                    for ps in sorted(promotors[seqname].keys()):
                        line = "\n{0}\t{1}\t{2}".format(seqname,ps[0],ps[1])
                        if len(promotors[seqname][ps])>0:
                            for gp in promotors[seqname][ps]:
                                line += "\t{0} (type: {1}, strand: {2})".format(gp.getID(), gp.getType(),gp.getStrand())
                                #check if position is genic
                                for f in features[seqname][ps]:
                                    if isinstance(f,saf.Gene):
                                        line += "\t{0} (type: {1}, strand: {2})".format(f.getID(), f.getType(),f.getStrand())
                                        if f == gp: 
                                            nrPromSameGene+=1
                                        elif gp.getStrand()==f.getStrand(): 
                                            nrPromOtherGeneSameStrand+=1
                                        else:
                                            nrPromOtherGeneOtherStrand+=1
                        fo.write(line)
        
        fo.write("\n\n###########\n# SUMMARY #\n###########")
        fo.write("\nNumber input coordinates:\t{0}".format(nrC))
        fo.write("\nAnnotation:\t{0}".format(nrAnnot))
        fo.write("\n#Number of hits for specific feature:")
        for fns,items in iter(sorted(featureNameSet.items())):
            fo.write("\n{0}\t{1}".format(fns,len(items)))
        fo.write("\nNo annotation\t{0}".format(nrNoAnnot))
        if args.promotor != 0:
            fo.write("\nTotal number positions in promotor regions (set as TSS-{0}): {1}".format(args.promotor,nrProm))
            fo.write("\nTotal number positions in promotor regions and in genic region of same gene (set as TSS-{0}): {1}".format(args.promotor,nrPromSameGene))
            fo.write("\nTotal number positions in promotor regions but in other gene on same strand (set as TSS-{0}): {1}".format(args.promotor,nrPromOtherGeneSameStrand))
            fo.write("\nTotal number positions in promotor regions but in other gene on other strand (set as TSS-{0}): {1}".format(args.promotor,nrPromOtherGeneOtherStrand))
            
            fo.write("\nTotal number positions in downstream regions (set as gene stop coordinate+{0}): {1}".format(args.promotor,nrDS))
    
    outputTable = "{0}.table".format(args.output)
    if os.path.exists(outputTable):
        os.remove(outputTable)
    with open(outputTable,'w') as fo:
        fo.write(tableText)
    print("...done")
         
def getFeatureAssociation(featureList):
    '''
    Get feature association/ordening for particular list of features
    '''
    fl = copy.deepcopy(featureList)
    baseFeat=list()
    #retrieve features through ID AND PID (i.e. base features)
    for f in fl:
        id = f.getID()
        pids = f.getPID()
        if pids:
            for pid in pids:
                for bf in baseFeat:
                    if pid == bf.getID():
                        baseFeat.remove(bf)
        baseFeat.append(f)
    #remove from featureList
    for b in baseFeat:
        fl.remove(b)
            
    #retrieve paths of base features based on PID
    #make recursive function
    fa = list()
    for bf in baseFeat:
        name = bf.getType()
        id = bf.getID()
        bpid = bf.getPID()
        format=name
        if id:
            format="{0} ({1})".format(id,format)
        if bpid:
            #for b in bpid:
            fa.append(_getParentalFeat(bpid,fl,[format]))
    
    return fa
    
def _getParentalFeat(bpid,featureList, oriText):
        text=list()
        found=False
        for f in featureList:
            name = f.getType()
            id = f.getID()
            if not id: continue
            pid = f.getPID()
            dbxref=f.getDBxRef()
            for bp in bpid:
                if id == bp:
                    for i,t in enumerate(oriText):
                        t = "{0} ({1}) > {2}".format(id,name,t)
                        if dbxref:
                            t = "{0} ; DBxREF={1}".format(t,dbxref)
                        if pid:
                            t = _getParentalFeat(pid,featureList,[t])
                        else:
                            t = [t]
                        text.extend(t)
                    #found
                    found=True
            if found:
                break
        return text
            
if __name__ == "__main__":
    main()
    print("Finished")
