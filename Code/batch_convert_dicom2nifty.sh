#!/bin/bash

# Define the DICOM input directory and the BIDS output directory
dicom_root_dir="/mnt/c/users/kramerlab/documents/EO_sct_data/ /data"
bids_root_dir="/mnt/c/users/kramerlab/documents/EO_sct_data/BIDS/data"

# Echo the directories for confirmation
echo "DICOM root directory: $dicom_root_dir"
echo "BIDS root directory: $bids_root_dir"

# Create BIDS root directory if it doesn't exist
echo "Checking if BIDS root directory exists..."
mkdir -p "$bids_root_dir"
echo "BIDS root directory is set up at: $bids_root_dir"

# Define the substring to filter files (e.g., "_AX_T2_")
SUBSTRING="_AX_T2_"

# Loop through all subject folders in the DICOM directory
for subject_folder in "$dicom_root_dir"/*; do
    if [ -d "$subject_folder" ]; then
        # Extract subject ID from the folder name (this depends on how the folders are named)
        subject_id=$(basename "$subject_folder")
        bids_subject_dir="$bids_root_dir/$subject_id"

        # Print the current subject ID and paths being processed
        echo "----------------------------------------"
        echo "Processing subject: $subject_id"
        echo "DICOM folder: $subject_folder"
        echo "BIDS subject directory: $bids_subject_dir"

        # Create the subject directory in the BIDS output directory
        echo "Creating BIDS directories for subject $subject_id..."
        mkdir -p "$bids_subject_dir/anat"
        echo "Created anat directory: $bids_subject_dir/anat"

        # Run dcm2niix for the subject, outputting the files to the correct BIDS folder
        echo "Converting DICOM files for subject $subject_id using dcm2niix..."
        dcm2niix -b y -z y -f "${subject_id}_%p_%s" -o "$bids_subject_dir/anat" "$subject_folder"

        # Check the result of dcm2niix
        if [ $? -eq 0 ]; then
            echo "DICOM conversion successful for subject $subject_id."
        else
            echo "Error occurred during DICOM conversion for subject $subject_id." >&2
        fi

        # Navigate to the subject's output directory
        cd "$bids_subject_dir/anat" || exit
    
        # Filter and delete files that do not match the substring
        #find . -type f ! -name "*${SUBSTRING}*" -exec rm {} +
        # Rename the output files to follow the convention: "sXX_t2w.nii.gz"
        #modality="T2w"  # Assuming T2-weighted (adjust based on modality)
        #new_filename="${subject_id}_${modality}.nii.gz"

        ## Rename any NIfTI files matching the substring to the new convention
        #for nifti_file in *.nii.gz; do
        #    if [[ "$nifti_file" == *"${SUBSTRING}"* ]]; then
        #        echo "Renaming $nifti_file to $new_filename..."
        #        mv "$nifti_file" "$new_filename"
        #    fi
        #done

        ## Rename the corresponding JSON files to follow the convention
        #for json_file in *.json; do
        #    if [[ "$json_file" == *"${SUBSTRING}"* ]]; then
        #        echo "Renaming $json_file to $new_json_filename..."
        #        mv "$json_file" "$new_json_filename"
        #    fi
        #done

        # Rename all files except those with the .nii.gz extension
        #for file in *; do
        #    if [[ "$file" != *.nii.gz ]]; then
        #        # Extract the file extension (e.g., .json)
        #        extension="${file##*.}"
        #        base_filename="${subject_id}_T2w.${extension}"

                # Rename the file
        #        echo "Renaming $file to $base_filename..."
        #        mv "$file" "$base_filename"
        #    else
        #        echo "Skipping $file (NIfTI file)"
        #    fi
        #done


    
        echo "Finished processing subject: $subject_id"
        echo "----------------------------------------"
    else
        echo "$subject_folder is not a directory, skipping..."
    fi
done

echo "All conversions completed."
