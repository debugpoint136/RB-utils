# RB-utils


###### how to run all-in-one.sh
Log on to HTCF. 
`git clone git@github.com:debugpoint136/RB-utils.git`

cd into your folder where your fastq file is located and run below command - 

```
sh RB-utils/all-in-one.sh ENCFF000WRB.fastq.gz
```


This will create a folder - with following scripts :

- fastq-sam.sh
- sam-bam.sh
- iteres.sh
- methylQA-cpg-profile.sh
- methylQA-density.sh

`sbatch fastq-sam.sh` submits a job

This will internally call all other scripts.

Comment out the steps you don't want to invoked.

##### Working with BAM files

Check iteres.sh and make changes accordingly.