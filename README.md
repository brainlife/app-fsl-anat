[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-brainlife.app.273-blue.svg)](https://doi.org/10.25663/brainlife.app.273)

# FSL Anat (T1) 

This app will preprocess an anatomical (T1w) image using FSL's fsl_anat functionality. Within this, it will: crop and reorient and debias the anatomical T1w image, segment cortical and subcortical structures, and linearally and non-linearally the image to a variety of templates, including the MNI template.  This app takes as input an anatomical T1w image and instructions regarding which steps to perform and the template image to use. This app will output many images, including the linearally aligned 'acpc_aligned image', the non-linearally registered 'standard' image, the debiased image used before alignment, the warps derived from the alignment, and all the derivatives generated. 

### Authors 

- Brad Caron (bacaron@iu.edu) 

### Contributors 

- Soichi Hayashi (hayashis@iu.edu) 

### Funding 

[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-ACI-1916518](https://img.shields.io/badge/NSF_ACI-1916518-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1916518)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://grantome.com/grant/NIH/R01-EB029272-01)

### Citations 

Please cite the following articles when publishing papers that used data, code or other resources created by the brainlife.io community. 

1. https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/fsl_anat 

## Running the App 

### On Brainlife.io 

You can submit this App online at [https://doi.org/10.25663/brainlife.app.273](https://doi.org/10.25663/brainlife.app.273) via the 'Execute' tab. 

### Running Locally (on your machine) 

1. git clone this repo 

2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files. 

```json 
{
   "t1":    "testdata/anat/t1.nii.gz",
   "reorient":    true,
   "crop":    true,
   "bias":    true,
   "seg":    true,
   "subcortseg":    true,
   "input_type":    "T1",
   "template":    "MNI152_1mm"
} 
``` 

### Sample Datasets 

You can download sample datasets from Brainlife using [Brainlife CLI](https://github.com/brain-life/cli). 

```
npm install -g brainlife 
bl login 
mkdir input 
bl dataset download 
``` 

3. Launch the App by executing 'main' 

```bash 
./main 
``` 

## Output 

The main output of this App is many images, including the linearally aligned 'acpc_aligned image', the non-linearally registered 'standard' image, the debiased image used before alignment, the warps derived from the alignment, and all the derivatives generated 

#### Product.json 

The secondary output of this app is `product.json`. This file allows web interfaces, DB and API calls on the results of the processing. 

### Dependencies 

This App requires the following libraries when run locally. 

- FSL: 
- python2: 
- jsonlab: 
- numpy: 
- singularity: 
