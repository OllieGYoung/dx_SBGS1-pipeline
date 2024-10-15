version 1.0

# snake_case for filenames, camelCase for tasknames

import "tasks/concat_fastqs.wdl" as concatFastqsTask
import "tasks/trimming.wdl" as trimmingTask
import "tasks/fastqc.wdl" as fastqcTask
import "tasks/multiqc.wdl" as multiqcTask

workflow main {

############# INPUTS #####################

    input {
        File fastqs_tar
        File adapter_file
        String fastqcDocker
        String trimmingDocker
        String multiqcDocker 
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

############ OUTPUTS ######################

    output {
        File multiqc_report = multiqc.multiqc_report
        #File multiqc_data = multiqc.multiqc_data
    }
}
