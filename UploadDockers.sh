#!/bin/bash

# Save the Docker image to a file
docker save biocontainers/trimmomatic:v0.38dfsg-1-deb_cv1 > trimmomatic:v0.38dfsg-1-deb_cv1.tar
docker save staphb/fastqc:0.12.1 > fastqc_0.12.1.tar
docker save multiqc/multiqc:v1.25.1 > multiqc:v1.25.1.tar
docker save swglh/samtools:1.18 > samtools:1.18.tar
docker save swglh/bwamem2:v2.2.1 > bwamem2:v2.2.1.tar
docker save dancooke/octopus:invitae--eae1ab48_0 > octopus:invitae--eae1ab48_0.tar

# Upload the Docker image tar file to DNAnexus
PATH_docker_base=$"Diagnostic Sequencing:/outputs/Exeter_WDL_pipeline/resources/DockerImages"

dx upload trimmomatic:v0.38dfsg-1-deb_cv1.tar --path $PATH_docker
dx upload fastqc_0.12.1.tar --path $PATH_docker
dx upload multiqc:v1.25.1.tar --path $PATH_docker
dx upload samtools:1.18.tar --path $PATH_docker
dx upload bwamem2:v2.2.1.tar --path $PATH_docker
dx upload octopus:invitae--eae1ab48_0.tar --path $PATH_docker

