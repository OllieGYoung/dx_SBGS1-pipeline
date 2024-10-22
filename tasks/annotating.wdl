version 1.0

task VEP_annotation {
    input {
        File vcf
        File vep_cache
        String Docker

        ### spliceAI
        File spliceaiSnv       
        File spliceaiSnvTbi
        File spliceaiIndel
        File spliceaiIndelTbi
        
    }

    command <<<

    # temp dirs for output, cache, plugins
    mkdir annotation/cache_out; mkdir annotation/plugins
    
    # extract vep cache
    tar -xf ~{vep_cache} -C annotation/cache_out

    # Move spliceAI files into plugin directory
    cp ~{spliceaiSnv} annotation/plugins/
    cp ~{spliceaiSnvTbi} annotation/plugins/
    cp ~{spliceaiIndel} annotation/plugins/
    cp ~{spliceaiIndelTbi} annotation/plugins/

    # define basename for annotated VCFs
    BASE_VCF=$(basename ~{vcf} _sorted.vcf)_annotated.vcf 

    #### run vep #####
    vep -i ~{vcf} \
        -o annotation/$BASE_VCF \
        --dir_cache annotation/cache_out \
        --cache --offline \
        --pick \
        --plugin SpliceAI,snv=annotation/plugins/$(basename ~{spliceaiSnv}),indel=annotation/plugins/$(basename ~{spliceaiIndel})
    
    >>>

    output {
        File annotated_vcf = "annotation/~{basename(vcf, '_sorted.vcf')}_annotated.vcf" 
    }

    runtime {
        docker: "~{Docker}"
        dx_instance_type: "mem1_ssd1_v2_x36"
        }

}