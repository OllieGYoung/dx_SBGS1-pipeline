version 1.0

task concat_fastqs {
    
    input {
        File fastqs_tar
    }

    command <<<
        mkdir temp_fastq_dir # temporary dir that is in cromwell sub_dir
        tar -xvf ~{fastqs_tar} -C temp_fastq_dir
    >>>

    output {
        Array[File] fastq_array = glob("temp_fastq_dir/*")
    }

    runtime {
        dx_instance_type: "mem1_ssd1_v2_x36"
    }
}
