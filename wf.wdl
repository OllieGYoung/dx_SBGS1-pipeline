version 1.0

# snake_case for filenames, camelCase for tasknames

import "tasks/concat_fastqs.wdl" as concatFastqsTask
import "tasks/trimming.wdl" as trimmingTask
import "tasks/fastqc.wdl" as fastqcTask
import "tasks/multiqc.wdl" as multiqcTask
import "tasks/aligning.wdl" as alignmentTask
import "tasks/variant_calling.wdl" as variantCallingTask
import "tasks/annotating.wdl" as annotatingTask

workflow main {

############# INPUTS #####################

    input {
        File fastqs_tar
        File adapter_file
        File ref_genome_tar
        File ref_genome_fa
        File vep_cache

        ### DOCKERS
        String fastqcDocker
        String trimmingDocker
        String multiqcDocker 
        String samDocker
        String bamDocker
        String octopusDocker
        String annotatingDocker
    }

############ TASKS ######################

# pull fastqs from input dir -> array[file] in cromwell
    call concatFastqsTask.concat_fastqs {
        input:
            fastqs_tar = fastqs_tar
    }

# trimming the reads using Trimmomatic 
    call trimmingTask.trim_fastqs_task {
        input:
            fastq_files = concat_fastqs.fastq_array,
            adapter_file = adapter_file,
            Docker = trimmingDocker
    }


# FastQC
    scatter (f in trim_fastqs_task.paired_trimmed_files) {
        call fastqcTask.fastqc {
            input:
                 fastq_file = f,
                 Docker = fastqcDocker
        }
    }

# MultiQC
    call multiqcTask.multiqc {
        input:
            fastqc_outputs = flatten(fastqc.fastqc_output),
            Docker = multiqcDocker
    }

# Alignment

    # concatenate indexed ref genome files 
    call alignmentTask.concat_refs {
        input:
        ref_genome = ref_genome_tar
    }

    # convert to SAM 
    call alignmentTask.generate_sam {
        input:
            ref_indexed = concat_refs.ref_indexed,
            fastq_files = trim_fastqs_task.paired_trimmed_files,
            ref_genome_fa = ref_genome_fa,
            Docker = samDocker
    }

    # SAM to BAM
    scatter (f in generate_sam.sam_files) {
        call alignmentTask.generate_bam {
            input:
                sam_file = f,
                Docker = bamDocker
        }
    }

# Variant calling (octopus)
    scatter (pair in generate_bam.bam_bai_pair) {
        call variantCallingTask.octopus_caller {
            input:
                ref_indexed = concat_refs.ref_indexed,
                ref_genome_fa = ref_genome_fa,
                bam_file = pair.left,
                bai_file = pair.right,
                Docker = octopusDocker
        }
    }

Array[File] vcf_array = select_all(octopus_caller.vcf_file)

# Annotating
    scatter (vcf in vcf_array) {
    call annotatingTask.VEP_annotation {
            input:
                vcf = vcf,
                vep_cache = vep_cache,
                Docker = annotatingDocker
        }
    }

############ OUTPUTS ######################

    output {
        File multiqc_report = multiqc.multiqc_report
        #File multiqc_data = multiqc.multiqc_data
        Array[File] vcf_files = octopus_caller.vcf_file
        Array[File] annotated_vcfs = VEP_annotation.annotated_vcf
    }
}
