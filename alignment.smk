## Snakemake workflow for RNA virus discovery by Alignment filtering to host genome

configfile: 'samples.yaml'

rule all: 
	input:
		unmapped1 = expand("Data/{sample}_unmapped_1.fastg.gz", sample = config['samples']),
		unmapped2 = expand("Data/{sample}_unmapped_1.fastg.gz", sample = config['samples'])

rule fastp:
	input:
		read1 = "Data/{sample}_1.fastq.gz",
		read2 = "Data/{sample}_2.fastq.gz"
	output:
		trimmed1 = "Data/{sample}_trimmed_1.fastq.gz",
		trimmed2  = "Data/{sample}_trimmed_2.fastq.gz",
		html = "Data/{sample}.html",
		json = "Data/{sample}.json"
	threads: 8
	singularity: "docker://staphb/fastp:latest"
	shell:
		"""
			fastp \
			--in1 {input.read1} \
			--out1 {output.trimmed2} \
			--in2 {input.read2} \
			--out2 {output.trimmed2} \
			-w {threads} \
			--html {output.html} \
			--json {output.json} \
			--detect_adapter_for_pe
		"""

rule bbmap:
	input:
		trimmed1 = rules.fastp.output.trimmed1,
		trimmed2 = rules.fastp.output.trimmed2
	output:
		unmapped1 = "Data/{sample}_unmapped_1.fastg.gz",
		unmapped2 = "Data/{sample}_unmapped_2.fastg.gz"
	threads: 8
	singularity: "docker://staphb/bbtools:latest"
	params: 
		reference = "References/References.fna.gz"
	shell:
		"""
			bbmap.sh \
			ref={params.reference} \
			in={input.trimmed1} \
			in2={input.trimmed2} \
			outu1={output.unmapped1} \
			outu2={output.unmapped2} \
			t={threads}
		"""
	
