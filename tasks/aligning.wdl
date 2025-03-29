version 1.0

########### MAKE REF GENOME DIR ##############
task concat_refs {
    input {
        File ref_genome
    }
    command <<< 

    mkdir refs 
    tar -xvf ~{ref_genome} -C refs --no-same-owner

    >>>

    output {
        Array[File] ref_indexed = glob("refs/*")
    }
    
    runtime {
        dx_instance_type: "mem1_ssd1_v2_x36" # 70.3GB working mem - 837GB total storage - 36 cores
    }
}

############### MAKE SAMS ####################
task generate_sam {

    input {
        Array[File] ref_indexed
        Array[File] fastq_files
        File ref_genome_fa
        String Docker
    }

    command <<<

        mkdir aligned; mkdir GRCh38

        # move to same dir
        mv ~{sep=' ' ref_indexed} GRCh38

        # run bwa mem (requires indexed genome)
        ## note: only works for this fastq naming convention
        for R1 in ~{sep=" " fastq_files}; do

            CHECKREAD=$(basename $R1 | cut -d'_' -f5)
            if [ $CHECKREAD = "R1" ] ; then
                R2=${R1/_R1_001.fastq.gz/_R2_001.fastq.gz}    
                BASE=$(basename $R1 | cut -d'_' -f1-4)
 
                # Define output file name (sam file)
                OUTPUT_SAM=aligned/${BASE}.sam

                bwa-mem2 mem -R "@RG\tID:${BASE}\tSM:${BASE}\tPL:ILLUMINA" GRCh38/~{basename(ref_genome_fa)} $R1 $R2 > $OUTPUT_SAM 
            fi
        done
    >>>
    
    output {
        Array[File] sam_files = glob("aligned/*[!gz].sam")
    }

    runtime {
        docker: "~{Docker}"
        dx_instance_type: "mem1_ssd1_v2_x36" # 70.3GB working mem - 837GB total storage - 36 cores
    }
}

############### MAKE BAMS ####################
task generate_bam {

    input {
        File sam_file
        String Docker
    }

    command <<<

        mkdir bam_aligned

        BASE=$(basename ~{sam_file} .sam)
        OUTPUT_BAM=bam_aligned/${BASE}_sorted.bam       # AM_B2426953_S8_L001.sam -> AM_B2426953_S8_L001_sorted.bam
        samtools view -bS ~{sam_file} | samtools sort -o $OUTPUT_BAM # create sorted BAM
        samtools index $OUTPUT_BAM # create corresponding BAI (index file)

    >>>

    output {
        File bam_file = "bam_aligned/${basename(sam_file, '.sam')}_sorted.bam"
        File bai_file = "bam_aligned/${basename(sam_file, '.sam')}_sorted.bam.bai"
        Pair[File, File] bam_bai_pair = (bam_file, bai_file) # concat pairs
    }

    runtime {
        docker: "~{Docker}"
        dx_instance_type: "mem1_ssd1_v2_x36" # 70.3GB working mem - 837GB total storage - 36 cores
    }
}
