version 1.0

task octopus_caller {
    input {
        File bam_file
        File bai_file
        File ref_genome_fa 
        Array[File] ref_indexed
        String Docker
    }

    command <<<

    mkdir vc_output; mkdir GRCh38
    mv ~{sep=' ' ref_indexed} GRCh38
    
    BASE=$(basename ~{bam_file} .bam).vcf
    
    octopus \
    --reference GRCh38/~{basename(ref_genome_fa)} \
    --reads ~{bam_file} \
    --output vc_output/$BASE

    >>>

    output {
        File vcf_file = "vc_output/~{basename(bam_file, '.bam')}.vcf"
    }

    runtime {
        docker: "~{Docker}"
        dx_instance_type: "mem1_ssd1_v2_x36" # 70.3GB working mem - 837GB total storage - 36 cores
    }
}
