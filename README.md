## dx SBGS1 pipeline
This pipeline was written as a training component for the diagnostic sequencing module of the bioinformatics NHS STP. It runs on [WDL 1.0](https://github.com/openwdl/wdl/blob/main/versions/1.0/SPEC.md) on the [DNAnexus](https://platform.dnanexus.com/login) cloud computing platform. 

Our pipeline takes a directory of paired-end FASTQ files as inputs and outputs annotated VCF files as well as intermediates. 

### Usage
- Compiling the workflow with **dxCompiler**
```bash
java - jar /path/to/dxCompiler-<version>.jar compile <workflow.wdl> \
    - inputs <inputs.json> \
    - project <DNAnexus project ID> -folder /path/to/folder
```
- Running the workflow
```bash
dx run workflow-<workflow ID> \
    -f Samtools_dnanexus.dx.json \ 
    --destination /path/to/folder \
```

### Note on FASTQ file names
FASTQs were created using Bcl2Fastq and follow a specific naming convention. 
FASTQ file names must end in `_R1_001.fastq.gz` and `_R2_001.fastq.gz` for the pipeline to execute correctly. 

### Flowchart
