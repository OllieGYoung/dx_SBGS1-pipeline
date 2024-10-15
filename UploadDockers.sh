#!/bin/bash

# Save the Docker image to a file
docker save biocontainers/trimmomatic:v0.38dfsg-1-deb_cv1 > trimmomatic:v0.38dfsg-1-deb_cv1.tar
docker save staphb/fastqc:0.12.1 > fastqc_0.12.1.tar
docker save multiqc/multiqc:v1.25.1 > multiqc:v1.25.1.tar

# Upload the Docker image tar file to DNAnexus
dx upload trimmomatic:v0.38dfsg-1-deb_cv1.tar
dx upload fastqc_0.12.1.tar
dx upload multiqc:v1.25.1.tar
