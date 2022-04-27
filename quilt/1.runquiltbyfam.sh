#!/bin/bash
#
#SBATCH --time=72:00:00                  # Job run time (hh:mm:ss)
#SBATCH --nodes=1                        # Number of nodes
#SBATCH --ntasks-per-node=12             # Number of task (cores/ppn) per node
#SBATCH --job-name=qu.20                 # Name of batch job
#SBATCH --partition=aces                 # Partition (queue)           
#SBATCH --array=0-10%5
#SBATCH --mem=200G
#SBATCH --output=quilt.%x.%j.%A.%a       # Name of batch job output file
#


# This will run quilt for all families listed and create one vcf file per family
# This utilizes a slurm array, the gathering script is seperate
# for more automation, set the gathering script to be dependant on this one, BUT:
# In practice, manual checking is not a bad thing if testing was not done

date

free -h

fams=( 1 2 3 4 5 6 7 8 9 10  )


fam=${fams[$SLURM_ARRAY_TASK_ID]}





module load R/4.0.3_sandybridge
module load gcc/7.2.0 
module load libxml2/2.9.1
module load python/3

# load commonly needed/used paths 

export R_LIBS=~/R/x86_64-pc-linux-gnu-library/4.0
export PATH=$PATH:/home/jjohnso/project-aces/apps/bin/bin
export PATH=$PATH:/home/jjohnso/project-aces/apps/vcftools/vcftools-master/bin/
export PATH=$PATH:/home/jjohnso/project-aces/apps/samtools/bcftools-1.9/

# Run the rist time using stitch/quilt, keep in comments to record version and location originally used
# R CMD INSTALL ../../apps/STITCH/STITCH_1.6.6.tar.gz
# R CMD INSTALL ../../apps/QUILT/QUILT_1.0.3.tar.gz


# create a new directory for each family to avoid any issues with overwriting files between families

dirname="quilt_output_fam${fam}_20gen"

# set variable needed for input into program
nGenval=20


echo "run fam"
echo $fam
echo "at nGenval"
echo $nGenval

#make files notfam${fam}gp.txt AND fam${fam}.names


#### many files/locations are hard coded, check all if re-use of script is needed

grep Fam${fam}fam f2fams.txt | awk '{print $1}' > temp${fam}.f2names
grep -f temp${fam}.f2names bamlist.wtests.txt > fam${fam}bams.txt 
grep -f temp${fam}.f2names bamlistf2only.names > fam${fam}.names   
grep Fam${fam}fam gpinfo/gpfam.txt | awk '{print $1"\n"$2"\n"$3"\n"$4}' | sort | uniq > temp${fam}.gpnames
grep -v -f temp${fam}.gpnames   gpinfo/gplist.txt > notfam${fam}gp.txt



 for chr in {1..17}
 do
 	/home/jjohnso/project-aces/apps/QUILT/QUILT/QUILT.R \
 	--outputdir=${dirname} \
 	--chr=${chr} \
 	--tempdir=temp.${dirname} \
	--output_filename=quilt.chr${chr}.f${fam}.vcf \
 	--bamlist=fam${fam}bams.txt \
 	--sampleNames_file=fam${fam}.names \
 	--reference_haplotype_file=gpinfo/chr${chr}.impute.hap.gz  \
 	--reference_legend_file=gpinfo/chr${chr}.impute.legend.gz \
 	--genetic_map_file=gpinfo/chr${chr}.geneticmap.txt \
        --reference_sample_file=gpinfo/all.impute.hap.indv \
        --reference_exclude_samplelist_file=notfam${fam}gp.txt \
 	--nGen=${nGenval} \
 	--nCores=1 \
	--save_prepared_reference=TRUE
	# an error is being generated but data is still being written
    # remove the error file to keep from filling the drive
    rm core*
 done


# remove temp files that we are now done with

rm temp${fam}.f2names fam${fam}bams.txt fam${fam}.names
rm temp${fam}.gpnames notfam${fam}gp.txt
rm -r temp.${dirname}
rm core*

cd $dirname


echo "finished quilt"
#echo $dirname


# index all vcf files
for chr in {1..17}
do
tabix -p vcf quilt.chr${chr}.f${fam}.vcf.gz
done


 # make list of files
ls -lhtr quilt.chr*gz | awk '{print $9}' > vcflist

# combine vcf files

#
#
#  ADD LOGIC CHECK THAT THERE ARE 17 VCF FILES !!!!
#
#

bcftools concat \
--output quilt.fam${fam}.vcf.gz \
--force-samples \
--output-type z \
--file-list vcflist 

# uncomment if wanting to remove individual chromosome files automatically
# rm quilt.chr*









