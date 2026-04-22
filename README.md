# BMEG 591T final project:
## 1. Project Title & Team Members
Title: Automatic segmentation of acute spinal cord injury on T2-weighted magnetic resonance images
Team Members: Oscar Ortiz and Saad Ali

## 2.  Abstract:
Acute spinal cord injury (SCI) is a severe neurological condition where early assessment of tissue damage is critical for guiding clinical intervention. On T2-weighted MRI, acute injury often presents as hyperintense regions corresponding to edema. However, manual segmentation of these regions is time-consuming and subject to variability, while existing automated tools are not optimized for acute injury cases.
In this project, we develop a deep learning-based segmentation model using nnU-Net to automatically identify spinal cord hyperintensities in acute SCI. We evaluate its performance against the Spinal Cord Toolbox (SCT), a widely used baseline for spinal cord segmentation. The dataset consists of 31 patients with acute SCI, with expert-annotated ground truth masks.
Our results show that nnU-Net significantly outperforms SCT across key metrics, achieving a Dice score of 0.7317 compared to 0.4863 for SCT, along with substantial improvements in recall and boundary accuracy. While both models demonstrate similar precision, SCT tends to under-segment lesion extent.
These findings demonstrate that models specifically trained for acute SCI can substantially improve segmentation accuracy. This approach has the potential to support faster and more reliable clinical decision-making in acute care settings.

## Methods & Implementation:
### Dataset:
The dataset consists of 31 patients 25 male, 6 female, mean age:39 ± 15.4 years) with acute spinal cord injury, each with T2-weighted MRI scans and expert-annotated ground truth masks for hyperintense regions. Images were acquired approximately 1.1 ± 0.66 days post-injury. All images are 1.5 Tesla cervical spine T2-weighted MRIs. Hyperintensities were manually segmented on axial slices by a trained annotator, serving as ground truth.

### Model implementations:
Preprocessing steps followed the nnUNet pipeline. Here we will outline the calls on the command line to run the training and referencing of both the nnUNet and SCT models.
### nnU-Net:
1. Install nnU-Net and set up the environment. Make sure we also have python installed. 
```bash
pip install nnunet
```
2. Prepare the dataset in the required format (e.g., NIfTI files with corresponding labels).
Here first we convert the original DICOM files as well as the labels to NIFTI format using the script in the Code folder called: batch_convert_dicom2nifty.bash.
Then we will organize the dataset according to the nnU-Net structure, with separate folders for training and testing data, and ensure that the labels are correctly formatted, namely a raw, a preprocessed and a results folder (see under nnUNet folder). Within the raw data folder, we will have a subfolder called imagesTr for training images, a subfolder called labelsTr for training labels, and a subfolder called imagesTs for test images. The labels are in the same format as the images, with the same naming convention (e.g., image_001.nii.gz and label_001.nii.gz).

3. Set up environment variables for nnU-Net:
```bash
export nnUNet_raw_data_base="/path/to/nnUNet_raw_data"
export nnUNet_preprocessed="/path/to/nnUNet_preprocessed"
export RESULTS_FOLDER="/path/to/nnUNet_results"
```

4. Preprocessing and planning:
```bash
nnUNetv2_plan_and_preprocess -d SCIEMG --verify_dataset_integrity
```
This command extracts the dataset fingerprint, normalizes intesities and configures patch size and architecture of mode.

5. Training the model: We run 5-fold cross validation based on the plans generated int the previous step. For this we run the sciemg_train_bash.sh script in the Code folder. 

6. Inference on test set: We run this command on a folder containing the test images that have not been seen yet by the model to generate prediction masks. 
```bash
nnUNetv2_predict -i /path/to/test/images -o /path/to/output/predictions -t SCIEMG -m 3d_fullres
```
It uses all 5 folds to generate predictions and averages them for the final output.

7. Post-processing: We can apply any necessary post-processing steps to the predicted mask as per the nnU-Net pipeline. This includes removing small isolated regions, filling holes, or applying morphological operations to refine the segmentation.
```bash
nnUNetv2_apply_postprocessing -i /path/to/predictions -o /path/to/postprocessed/predictions -t SCIEMG -m 3d_fullres
```
### Spinal Cord Toolbox (SCT) (https://spinalcordtoolbox.com/stable/):
1. Install SCT and set up the environment. Make sure we also have python installed.
```bash
pip install spinalcordtoolbox
```
There is a detailed tutorial here: (https://spinalcordtoolbox.com/stable/user_section/tutorials/lesion-analysis/lesion-segmentation-sci.html) but for brevity here are the important commands.

2. Main command:

```bash
sct_deepseg lesion_sci_t2 -i t2.nii.gz -qc qc
```

##### What this does
- `lesion_sci_t2` selects the SCI lesion model
- `-i t2.nii.gz` provides the input T2w image
- `-qc qc` writes slice-by-slice quality-control output into a folder called `qc`

#### Expected outputs
```text
t2_sc_seg.nii.gz
t2_lesion_seg.nii.gz
t2_lesion_seg.json
```

### Evaluation Metrics:
We evaluated the performance of both models using the following metrics:
- Dice Similarity Coefficient (DSC): Measures the overlap between the predicted segmentation and the ground truth, with values ranging from 0 (no overlap) to 1 (perfect overlap).
- Jaccard Index: Similar to DSC, it measures the intersection over union of the predicted and ground truth masks.
- Precision: The ratio of true positives to the sum of true positives and false positives, indicating the accuracy of positive predictions.
- Recall: The ratio of true positives to the sum of true positives and false negatives, indicating the ability of the model to identify all relevant instances.
- F1-Score: The harmonic mean of precision and recall, providing a single metric that balances both.
- Hausdorff Distance: Measures the maximum distance between the predicted and ground truth boundaries, indicating the spatial accuracy of the segmentation.
- Hausdorff Distance 95th Percentile: Similar to the Hausdorff Distance but considers the 95th percentile of distances, providing a more robust measure of boundary accuracy by excluding outliers.

To assess factors that affected model performance, we also analyzed the relationship between image brightness and accuracy. We calculated the mean intensity of the T2-weighted images and examined its correlation with the Dice scores for both models. This analysis helps to understand whether variations in image brightness influenced the segmentation performance, as hyperintense regions in T2-weighted MRI are critical for identifying acute spinal cord injury. We used scatter plots and correlation coefficients to visualize and quantify this relationship, providing insights into potential factors that may impact model accuracy.
The implementation of this analysis can be found in the Code folder under the script called: evaluating_performance.ipynb.


