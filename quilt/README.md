# ExampleCode Jennifer L. Johnson



This is a set of scripts designed to run the program QUILT on a specific set of data.
QUILT is here: https://github.com/rwdavies/QUILT

My data is structured as low depth sequencing from many individuals and high quality, high depth sequencing from their grandparents. 

The grandparent data was previously analyzed and is available to my lab as fully phased, genome wide genotypes. I prepared this data as the referenece for imputaiton in quilt.

The individual data is available to my lab as bam files aligned to the same genome as the vcf files from the grandparents.

The data is being run family by family, as the exact ancestors, and therefor the possible haplotypes, of each individual is known.

QUILT was implimented on the UIUC campus cluster, which uses slurm, and the family data was computed using a slurm array.
