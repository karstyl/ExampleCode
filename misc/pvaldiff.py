#!/usr/bin/env python2
# import csv
# import gzip
import sys
import numpy as np
import scipy.stats
import math
from scipy.stats import poisson

# use: python pvaldiff.py infile > outfile

# this will generate a pvalue comparing two different values
# the pvalue will test the liklihood that they are from the same poisson distribution


# Ideas originated in
# https://cdn.elifesciences.org/articles/32920/elife-32920-v2.pdf
# https://elifesciences.org/articles/32920
# Originally published in
# Association Mapping From Sequencing Reads Using K-mers bioRxiv (23 May 2017), 141267, 
# doi:10.1101/141267

# likelihood ratio test for nested models is from (Wilks, 1938)
# Wilks SS (1938) The large-sample distribution of the likelihood 
# ratio for testing composite hypotheses. The Annals of Mathematical 
# Statistics 9:60–62. https://doi.org/10.1214/aoms/1177732360




#############
#
# If you are using to use this, some values are hard coded!!!!!!
#
# You need to edit grp1total, grp2total, and the top values for the commonvalues
# Don't forget that the top commonvalues are also in the script as a logical test
#
#############




infile=sys.argv[1]

# command to use for realtime copy/paste testing and developments
# qsub -q secondary -I -l walltime=02:00:00,nodes=1:ppn=1
#  module load python/2

#1 is aggr, 2 is tame, the file is set up in that order
grp1tot=44754063321 # pheno1 total kmers counts
grp2tot=98639705357 # pheno3 (star) total kmers counts
N1=grp1tot
N2=grp2tot
norm=(float(N2))/(float(N1))

# poisson.pmf computations can take a long time and many of the same ones will need to be done repeatadly
# speed up script by pre-computing for the most common values
# this will speed up calcuations if there are multiple calls for most of the numbers in each subdictionary. 
# the number used in the dictionary computation should be near the top of the numbers that are repeated muliple times


commonvalues = {}
depth=range(1000)
compare=range(1000)
for i in depth:
    commonvalues[i] = {}
    for j in compare:
        commonvalues[i][j] = poisson.pmf(i,j)




with open(infile, 'r') as countfile:
    line = countfile.readline()
    while line:
        values= line.split()
        # group1 is first column, group2 is second (index0&1)
        K1=int(values[0])
        K2=int(values[1])
        # normalize K1 to have the same scale as K2
        K1norm=int(K1*norm)
        K2norm=K2
        # caluclate the average depth for the null hypothosis (K1norm=Knormavg and K2norm=Knormavg)
        Knormavg=int((K1norm+K2norm)/2)
        #
        if K1norm < 1000 and K2norm < 1000 and Knormavg < 1000:
            #look up in dict
            th=(commonvalues[K1norm][Knormavg]*commonvalues[K2norm][Knormavg])
            th1=commonvalues[K1norm][K1norm]
            th2=commonvalues[K2norm][K2norm]
        else:
            #calculate
            th=((poisson.pmf(K1norm,Knormavg)*poisson.pmf(K2norm,Knormavg)))
            th1=poisson.pmf(K1norm,K1norm)
            th2=poisson.pmf(K2norm,K2norm)
        # calculate the ratio of prob(Alt Hyp)/prob(Null Hyp)
        # this is explicitly testing if both are from the same/average distribution
        # or if they are from different distribuions. 
        # This is to find the max liklihood
        lam=th1*th2/th
        # 2*ln(lam) is chi2 distributed
        transvalue = 2*np.log(lam)
        pvalue = 1- scipy.stats.chi2.cdf(transvalue, 1)
        if K1norm > K2norm:
            higher = "set1"
        elif  K1norm < K2norm:
            higher = "set2"
        else:
            higher = "set0"
        outline = '\t'.join(map(str, [lam, transvalue, pvalue, higher]))
        print outline
        line = countfile.readline()

countfile.close()







