# DaphniaRNAvirus
RNA virus discovery from metatranscriptomes of Daphnia pulex.

## Step Up: Download and install the necessary software. The workflow uses Singularity to manage reproducible environments. If you do not have Singularity installed, follow the directions [here](https://docs.sylabs.io/guides/4.0/admin-guide/installation.html#). 

```
cd Containers

## fastp read trimming:
singularity build fastp.sif docker://staphb/fastp:latest

## spades assembler:
singularity build spades.sif docker://staphb/spades:latest

## bbtools mapping RNA seq reads:
singularity build bbtools.sif docker://staphb/bbtools:latest

## Prokka Annotation:
singularity build prokka.sif docker://staphb/prokka:latest

## IQtree (v3) Phylogenetics:
singularity build iqtree3.sif docker://staphb/iqtree3:latest

cd ../
```
In addition to singularity you will need to install [mamba or conda](https://mamba.readthedocs.io/en/latest/installation/mamba-installation.html). I wrote the workflow using the workflow language Snakemake. It's best to install and manage snakemake via mamba or conda. 

`conda env create -n snakemake -f Auxfiles/snakemake_env.yaml`

## Workflow:
### Step 1: Download RNA-seq Data
I used SRA records from Hechler et al. in [Molecular Ecology](https://onlinelibrary.wiley.com/doi/10.1111/mec.17152).
```
cat Auxfiles/Daphnia_libraries.txt | awk -F "\t" '{print$3}' |while read line
do
echo ${line} |awk -F ";" '{print"ftp://"$1"\nftp://"$2}'
done > links.tmp
```
```
## This may take a while depending on the internet connection:

cat links.tmp |while read link 
do
wget ${link}
done 
```
## Step 2: Get the references for mapping

### Daphnia pulex KAP4 Genome and Mitogenome
```
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/021/134/715/GCF_021134715.1_ASM2113471v1/GCF_021134715.1_ASM2113471v1_genomic.fna.gz; mv GCF_021134715.1_ASM2113471v1_genomic.fna.gz References/Daphnia_pulex.fna.gz
```
### S. quadricauda
```
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/002/317/545/GCA_002317545.1_ASM231754v1/GCA_002317545.1_ASM231754v1_genomic.fna.gz; mv GCA_002317545.1_ASM231754v1_genomic.fna.gz References/Scenedesmus.fna.gz 
```
### R. subcapitata
```
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/003/203/535/GCA_003203535.1_Rsub_1.0/GCA_003203535.1_Rsub_1.0_genomic.fna.gz; mv GCA_003203535.1_Rsub_1.0_genomic.fna.gz 
References/Raphidocelis.fna.gz
```
### A. falcatus (unasssembled) 
```
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR128/048/SRR12880548/SRR12880548_*.fastq.gz; mv SRR12880548_*.fastq.gz References/.
```
## Step 3: Assemble the A. falcatus reads de novo. 

```
## Here we need to convert the raw fastqs into a reference for mapping. Short reads will create a fragmented but still useful assembly. First we need to remove adaptor contamination and trim low quality reads. Next, I used the spades isolate assembly module to assemble the genome de novo. 

cd References

## trim reads:

singularity exec -H $(pwd) ../Containers/fastp.sif fastp \
--in1  SRR12880548_1.fastq.gz \
--out1  SRR12880548_trimmed_1.fastq.gz \
--in2  SRR12880548_2.fastq.gz \
--out2  SRR12880548_trimmed_2.fastq.gz \
-w 10 \
--detect_adapter_for_pe \
--html SRR12880548_fastp.html

## assemble reference; this may take some time

singularity exec -H $(pwd) ../Containers/spades.sif spades.py \
-o SRR12880548_asm \
--isolate \
-1 SRR12880548_trimmed_1.fastq.gz \
-2 SRR12880548_trimmed_2.fastq.gz \
-t 16 ##adjust a required

## Rename and GZIP
mv SRR12880548_asm/scaffolds.fasta SRR12880548_asm.fna; gzip SRR12880548_asm.fna
```
## Step 4: Combine references into a single file for multimapping:

```
zcat *.fna.gz > References.fna; gzip References.fna

cd ../
```
## Step 5: Filtering host reads by mapping and de novo assembly of RNA-seq from unmapped reads: 

```
## activate snakemake mamba/conda env

pwd #(should be the working directory with the SRR fastqs with RNA seq data)

mamba activate snakemake

mkdir Data # Organize the directory 

mv *.fastq.gz Data/.

```

