version 1.0

task VEP_annotation {
    input {
        File vcf
        File vep_cache
        String Docker
        
    }

    command <<<

    # temp dirs for output, cache, plugins
    mkdir annotation
    mkdir annotation/cache_out
    mkdir annotation/plugins
    
    # extract vep cache
    tar --no-same-owner -xvf ~{vep_cache} -C annotation/cache_out

    # define basename for annotated VCFs
    BASE_VCF=$(basename ~{vcf} _sorted.vcf)_annotated.vcf 

    #### run vep #####
    vep -i ~{vcf} \
        -o annotation/$BASE_VCF \
        --dir_cache annotation/cache_out \
        --cache --offline \
        --pick 
    
    >>>

    output {
        File annotated_vcf = "annotation/~{basename(vcf, '_sorted.vcf')}_annotated.vcf" 
    }

    runtime {
        docker: "~{Docker}"
        dx_instance_type: "mem1_ssd1_v2_x36"
        }

}