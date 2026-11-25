<h1 align="center">fsl anat</h1>

<p align="center">
  fsl_anat (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/fsl_anat) provides a general pipeline for processing anatomical images (e.g. mp2rage scans).
</p>

<p align="center">
  <a href="https://github.com/brainlife/abcd-spec"><img src="https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg" alt="ABCD Spec v1.1"></a>
  <a href="https://doi.org/10.25663/brainlife.app.512"><img src="https://img.shields.io/badge/Brainlife-brainlife.app.512-blue.svg" alt="Run on brainlife.io"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-see_LICENSE-lightgrey.svg" alt="License"></a>
</p>

## At a glance

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **fsl_anat (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/fsl_anat) provides a general pipeline for processing anatomical images (e.g. mp2rage scans).**

| | |
|---|---|
| **Inputs** | `neuro/anat/mp2rage` |
| **Outputs** | `neuro/anat/mp2rage` ×2 · `neuro/transform/nifti` · `raw` |
| **Container** | `brainlife/fsl:5.0.11` |
| **Resources** | 1 CPUs · 4.5 h walltime |
| **Run it** | [doi.org/10.25663/brainlife.app.512](https://doi.org/10.25663/brainlife.app.512) |

#### Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `mp2rage` | `neuro/anat/mp2rage` | yes |  |

#### Outputs

| Output | Datatype | Description |
|---|---|---|
| `acpc` | `neuro/anat/mp2rage` | ACPC aligned data |
| `standard` | `neuro/anat/mp2rage` | mp2rage nonlinearly warped to standard space |
| `standard_nonlin_warp` | `neuro/transform/nifti` | Nonlinear warp generated from mp2rage to standard via fnirt |
| `raw` | `raw` | Output directory for all the data derivatives generated |

<details>
<summary><b>Parameters</b> (3)</summary>

| Parameter | Type | Default | Description |
|---|---|---|---|
| `reorient` | boolean | `false` | Reorient the image to FSL's standard (reorient2std). Leave as false if already done |
| `crop` | boolean | `false` | Crop the non-brain material using FSL's robustfov. Leave as false if already done |
| `template` | enum | `MNI152_1mm` | The template to which to align the T1 Options: `MNI152_1mm`, `nihpd_asym_04.5-08.5`, `nihpd_asym_04.5-18.5`, `nihpd_asym_07.0-11.0`, `nihpd_asym_07.5-13.5`, `nihpd_asym_10.0-14.0`, `nihpd_asym_13.0-18.5`, `MNI152_0.7mm`, `MNI152_0.8mm`, `MNI152_2mm`. |

</details>

<!-- brainlife-app:end -->

## Versions on brainlife.io

This repository hosts several Apps, each built from its own branch.

| App | Branch | Run it | Status |
|---|---|---|---|
| FSL Anat (mp2rage) | [`mp2rage-v1.0`](https://github.com/brainlife/app-fsl-anat/tree/mp2rage-v1.0) | [doi:10.25663/brainlife.app.512](https://doi.org/10.25663/brainlife.app.512) | current |
| FSL Anat (T2) | [`v1.1`](https://github.com/brainlife/app-fsl-anat/tree/v1.1) | [doi:10.25663/brainlife.app.350](https://doi.org/10.25663/brainlife.app.350) | available |
| FSL Anat (T1) | [`v1.1`](https://github.com/brainlife/app-fsl-anat/tree/v1.1) | [doi:10.25663/brainlife.app.273](https://doi.org/10.25663/brainlife.app.273) | available |

## Running the App

### On brainlife.io

Open the App at [doi.org/10.25663/brainlife.app.512](https://doi.org/10.25663/brainlife.app.512), choose `neuro/anat/mp2rage` from your project, set the parameters and press **Execute**. The results are saved to your project as `neuro/anat/mp2rage`, `neuro/anat/mp2rage`, `neuro/transform/nifti`, `raw`.

### Locally

You need [Singularity/Apptainer](https://apptainer.org/) (the App runs in `brainlife/fsl:5.0.11`), [`jq`](https://jqlang.github.io/jq/).

1. Clone this repository and check out the App's branch (`git checkout mp2rage-v1.0`).
2. Create `config.json` with the paths to your inputs and the parameters:

   ```json
   {
       "mag_inv1": "/path/to/mp2rage/mag_inv1",
       "phase_inv1": "/path/to/mp2rage/phase_inv1",
       "mag_inv2": "/path/to/mp2rage/mag_inv2",
       "phase_inv2": "/path/to/mp2rage/phase_inv2",
       "unit1": "/path/to/mp2rage/unit1",
       "mag_inv1_json": "/path/to/mp2rage/mag_inv1_json",
       "phase_inv1_json": "/path/to/mp2rage/phase_inv1_json",
       "mag_inv2_json": "/path/to/mp2rage/mag_inv2_json",
       "phase_inv2_json": "/path/to/mp2rage/phase_inv2_json",
       "unit1_json": "/path/to/mp2rage/unit1_json",
       "reorient": false,
       "crop": false,
       "template": "MNI152_1mm"
   }
   ```

3. Run `./main`.

## Citing

If you use this App, please cite it, the software it builds on and brainlife.io:

- FSL Anat (mp2rage). brainlife.io App. [doi:10.25663/brainlife.app.512](https://doi.org/10.25663/brainlife.app.512)
- Jenkinson et al. FSL. *NeuroImage* 62:782-790 (2012). [doi:10.1016/j.neuroimage.2011.09.015](https://doi.org/10.1016/j.neuroimage.2011.09.015)
- Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. *Scientific Data* 6:69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)

## Authors

brainlife.io team

## Funding

[![Wellcome-226486/Z/22/Z](https://img.shields.io/badge/Wellcome-226486%2FZ%2F22%2FZ-purple.svg)](https://wellcome.org/)
[![NIH-NINDS-U24NS140384](https://img.shields.io/badge/NIH_NINDS-U24NS140384-green.svg)](https://reporter.nih.gov/project-details/11261037)
[![NIH-NINDS-UM1NS132207](https://img.shields.io/badge/NIH_NINDS-UM1NS132207-green.svg)](https://reporter.nih.gov/project-details/11411328)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://reporter.nih.gov/project-details/10262925)
[![NIH-NIBIB-R01EB030896](https://img.shields.io/badge/NIH_NIBIB-R01EB030896-green.svg)](https://reporter.nih.gov/project-details/10428625)
[![NIH-NIMH-R01MH126699](https://img.shields.io/badge/NIH_NIMH-R01MH126699-green.svg)](https://reporter.nih.gov/project-details/10460628)
[![NIH-NIDCD-R01DC020088](https://img.shields.io/badge/NIH_NIDCD-R01DC020088-green.svg)](https://reporter.nih.gov/project-details/11140284)
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-2203524](https://img.shields.io/badge/NSF_BCS-2203524-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2203524)
[![NSF-IIS-1636893](https://img.shields.io/badge/NSF_IIS-1636893-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-OAC-2148729](https://img.shields.io/badge/NSF_OAC-2148729-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148729)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NSF-IIS-2148700](https://img.shields.io/badge/NSF_IIS-2148700-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148700)
[![NSF-OAC-1916518](https://img.shields.io/badge/NSF_OAC-1916518-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1916518)

<sub>brainlife.io is publicly funded, and acknowledging that support helps keep it running. This App was developed with support from Wellcome, the U.S. National Institutes of Health (including the BRAIN Initiative BRAIN CONNECTS program: The Axonal Projectome EXchange, U24NS140384, and the Center for Mesoscale Connectomics, UM1NS132207) and the U.S. National Science Foundation.</sub>

## License

See [LICENSE](LICENSE).
