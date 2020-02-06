#!/bin/bash

# input configs
input=`jq -r '.input' config.json`
reorient=`jq -r '.reorient' config.json`
crop=`jq -r '.reorient' config.json`
bias=`jq -r '.bias' config.json`
seg=`jq -r '.seg' config.json`
subcortseg=`jq -r '.subcortseg' config.json`
input_type=`jq -r '.input_type' config.json`
tempdir='tmp'
mnidir='mni'
acpcdir='acpc'
mni_nonlin_warp='mni_nonlin_warp'
biasdir='bias'
outdir='raw'

## making output directories
for DIRS in ${mnidir} ${biasdir} ${acpcdir} ${mni_nonlin_warp}
do
	mkdir ${DIRS}
done

## set if conditions
[[ ${input_type} == 'T1' ]] && output_type='t1' || output_type='t2'
[[ ${input_type} == 'T2' ]] && l4='--nononlinreg' || l4=''
[[ ${reorient} == false ]] && l1='--noreorient' || l1=''
[[ ${crop} == false ]] && l2='--nocrop' || l2=''
[[ ${bias} == false ]] && l3='--nobias'
[[ ${seg} == false ]] && l6='--noseg' || l6=''
[[ ${subcortseg} == false ]] && l7='--nosubcortseg' || l7=''

## run fsl_anat
echo "running fsl_anat"
if [ ! -f ./${tempdir}.anat/${input_type}_to_MNI_nonlin.nii.gz ]; then
	fsl_anat -i ${input} \
		${l1} \
		${l2} \
		${l3} \
		${l4} \
		${l6} \
		${l7} \
		-t ${input_type} \
		-o ${tempdir} \
		--nocleanup
fi

## acpc align T1
# creating a rigid transform from linear alignment to MNI
aff2rigid ./${tempdir}.anat/${input_type}_to_MNI_lin.mat acpcmatrix

# applying rigid transform to bias corrected image
applywarp --rel \
	--interp=spline \
	-i ./${tempdir}.anat/${input_type}_biascorr.nii.gz \
	-r ${FSLDIR}/data/standard/MNI152_${input_type}_1mm \
	--premat=acpcmatrix \
	-o ./${acpcdir}/${output_type}.nii.gz

## outputs
# moving warp fields from non-linear warp to warp directory
mv ./${tempdir}.anat/MNI_to_${input_type}_nonlin_field.nii.gz ./${mni_nonlin_warp}/inverse-warp.nii.gz
mv ./${tempdir}.anat/${input_type}_to_MNI_nonlin_field.nii.gz ./${mni_nonlin_warp}/warp.nii.gz

# bias corrected image. even if not bias is set to false, this is the output we want for non-acpc aligned T1
mv ./${tempdir}.anat/${input_type}_biascorr.nii.gz ./${biasdir}/${output_type}.nii.gz

# MNI (2mm) T1
mv ./${tempdir}.anat/${input_type}_to_MNI_nonlin.nii.gz ./${mnidir}/${output_type}.nii.gz

# other outputs
mv ${tempdir}.anat ${outdir}
mv acpcmatrix ${outdir}/

## final check and cleanup
[ ! -f ${acpcdir}/${output_type}.nii.gz ] && echo "failed" && exit 1 || exit 0
