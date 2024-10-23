#!/bin/bash

###### just for fun

# Print statement 
big_text=$(cat <<'EOF'
  _____             _               _    _       _                 _     
 |  __ \           | |             | |  | |     | |               | |    
 | |  | | ___   ___| | _____ _ __  | |  | |_ __ | | ___   __ _  __| |___ 
 | |  | |/ _ \ / __| |/ / _ \ '__| | |  | | '_ \| |/ _ \ / _` |/ _` / __|
 | |__| | (_) | (__|   <  __/ |    | |__| | |_) | | (_) | (_| | (_| \__ \
 |_____/ \___/ \___|_|\_\___|_|     \____/| .__/|_|\___/ \__,_|\__,_|___/
                                          | |                            
                                          |_|                            
EOF
)

if command -v lolcat &> /dev/null; then
    echo "$big_text" | lolcat
else
    echo "$big_text"
fi

echo -e "\nChecking you have all the Docker tarballs you need to run the workflow...\n\n"

######## Define the required Docker images

# Declare associative array (key = name of docker image, value = name of tarball)
declare -A images=(
    ["biocontainers/bwa:v0.7.17_cv1"]="bwa_v0.7.17_cv1.tar"
    ["biocontainers/trimmomatic:v0.38dfsg-1-deb_cv1"]="trimmomatic_v0.38dfsg-1-deb_cv1.tar"
    ["staphb/fastqc:0.12.1"]="fastqc_0.12.1.tar"
    ["multiqc/multiqc:v1.25.1"]="multiqc_v1.25.1.tar"
    ["swglh/samtools:1.18"]="samtools_1.18.tar"
    ["swglh/bwamem2:v2.2.1"]="bwamem2_v2.2.1.tar"
    ["dancooke/octopus:invitae--eae1ab48_0"]="octopus_invitae_eae1ab48_0.tar"
)

# Function to check if Docker images are present
pull_images() {
    # Initialize number of missing images
    local missing=0
    # Loop through elements of the associative array
    for image in "${!images[@]}"; do 
        # If a docker image doesn't exist after trying to grep it from those stored locally:
        if ! docker images | grep -q "$image"; then
            echo "Docker image $image not found locally. Pulling it now..."
            if docker pull "$image"; then
                echo "$image successfully pulled."
            else
                echo "Error: Failed to pull $image. Exiting."
                exit 1
            fi
        # If image was found locally:
        else
            echo "Docker image $image is already available locally."
        fi
    done
}

# Run the above function
pull_images

# Prompt the user for the DNAnexus upload path
echo "Please enter the DNAnexus upload destination: "
read -r docker_upload_path

# Check if the user provided an upload path
if [[ -z "$docker_upload_path" ]]; then
    echo "Error: Upload path cannot be empty. Exiting."
    exit 1
fi

# Upload tarballs to DNAnexus
echo "Uploading tarballs to DNAnexus..."
for tarball in "${images[@]}"; do
    echo "Uploading $tarball to $docker_upload_path..."
    dx upload "$tarball" --path "$docker_upload_path"
done

echo "All Docker images uploaded. Check on ${docker_upload_path} before starting the pipeline."
