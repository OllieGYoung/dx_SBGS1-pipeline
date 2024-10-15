version 1.0

task multiqc {
    input {
        Array[File] fastqc_outputs
        String Docker 
    }

    command <<<
        mkdir dir_multiqc
        multiqc ~{sep= ' ' fastqc_outputs} -o dir_multiqc
    >>>

    output {
        File multiqc_report = "dir_multiqc/multiqc_report.html"
        #File multiqc_data = "dir_multiqc/multiqc_data"
    }

    runtime {
        docker: "~{Docker}"
        dx_instance_type: "mem1_ssd1_v2_x36"
    }
}
