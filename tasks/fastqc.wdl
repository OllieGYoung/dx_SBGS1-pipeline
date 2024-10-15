version 1.0

task fastqc {

    input {
        File fastq_file
        String Docker
    }

    command <<<

        mkdir dir_fastqc
        fastqc -o dir_fastqc --noextract ~{fastq_file}
        
    >>>

    output {
        Array[File] fastqc_output = glob("dir_fastqc/*.{zip,html}")
    }

    runtime {
        docker: "~{Docker}"
        dx_instance_type: "mem1_ssd1_v2_x36"
    }
}
