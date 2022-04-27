#!/bin/bash
#
#SBATCH --time=72:00:00                 # Job run time (hh:mm:ss)
#SBATCH --nodes=1                       # Number of nodes
#SBATCH --ntasks-per-node=8             # Number of task (cores/ppn) per node
#SBATCH --job-name=qu.fam               # Name of batch job
#SBATCH --partition=aces                # Partition (queue)           
#SBATCH --mem=200G
#SBATCH --output=quilt.%x.%j            # Name of batch job output file
#SBATCH --dependency=afterany:5033399


# Run after 1.runquiltbyfam.sh
# for more automation, set the this script to be dependant on this one, BUT:
# In practice, manual checking is not a bad thing if testing was not done




date

free -h





module load R/4.0.3_sandybridge
module load gcc/7.2.0 
module load libxml2/2.9.1
module load python/3

# load commonly needed/used paths 

export R_LIBS=~/R/x86_64-pc-linux-gnu-library/4.0
export PATH=$PATH:/home/jjohnso/project-aces/apps/bin/bin
export PATH=$PATH:/home/jjohnso/project-aces/apps/vcftools/vcftools-master/bin/
export PATH=$PATH:/home/jjohnso/project-aces/apps/samtools/bcftools-1.9/


ls -lhtr quilt_output_fam*_20gen/quilt.fam*.vcf.gz | awk '{print $9}' > vcvfbyfam.list

#combine files

bcftools merge \
--output quilt.byfam.vcf.gz \
--output-type z \
--file-list vcvfbyfam.list


# make index

bcftools index \
--tbi \
quilt.byfam.vcf.gz










