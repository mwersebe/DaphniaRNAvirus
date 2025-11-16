## Snakemake workflow for RNA virus discovery by de novo assembly after host read removal

configfile: 'samples.yaml'

rule all: 
	input:
		scaffolds = expand("{sample}_unmapped_asm/scaffolds.fasta", sample = config['samples'])

rule spades_rna_viral:
	input:
		unmapped1 = "Data/{sample}_unmapped_1.fastg.gz",
		unmapped2 = "Data/{sample}_unmapped_2.fastg.gz"
	output:
		scaffolds = "{sample}_unmapped_asm/scaffolds.fasta"
	threads: 16
	singularity: "docker://staphb/spades:latest"
	shell:
		"""
		spades.py \
		-o {sample}_unmapped_asm \
		--metaviral \
		-1 {input.unmapped1} \
		-2 {input.unmapped2} \
		--threads {threads}
		"""
