#!/bin/bash

# input configs
input=`jq -r '.input' config.json`
TEMPLATE=`jq -r '.template' config.json`
reorient=`jq -r '.reorient' config.json`
crop=`jq -r '.crop' config.json`
bias=`jq -r '.bias' config.json`
seg=`jq -r '.seg' config.json`
subcortseg=`jq -r '.subcortseg' config.json`
input_type=`jq -r '.input_type' config.json`
tempdir='tmp'
standard='standard'
acpcdir='acpc'
standard_nonlin_warp='standard_nonlin_warp'
standard_nonlin_warp_input='standard_nonlin_warp_input'
biasdir='bias'
outdir='raw'

## making output directories
for DIRS in ${standard} ${biasdir} ${acpcdir} ${standard_nonlin_warp} ${standard_nonlin_warp_input}
do
	mkdir ${DIRS}
done

## set if conditions
[[ ${input_type} == 'T1' ]] && output_type='t1' || output_type='t2'
[[ ${reorient} ==  true ]] && fslreorient2std -m ${output_type}_reorient.txt ${input} ./${output_type}_reorient && input=${output_type}_reorient
[[ ${crop} == true ]] && robustfov -m ${output_type}_crop.txt -i ${input} -r ${output_type}_crop && input=${output_type}_crop && convert_xfm -omat ${output_type}_inverse_crop.txt -inverse ${output_type}_crop.txt
[[ ${bias} == false ]] && l3='--nobias'
[[ ${seg} == false ]] && l6='--noseg' || l6=''
[[ ${subcortseg} == false ]] && l7='--nosubcortseg' || l7=''

## set template for alignment
case $TEMPLATE in
nihpd_asym*)
    space="NIHPD"
    [ $input_type == "T1" ] && template=templates/${TEMPLATE}_t1w.nii
    [ $input_type == "T2" ] && template=templates/${TEMPLATE}_t2w.nii
    template_mask=templates/${template}_mask.nii
    ;;
MNI152_1mm)
    space="MNI152_1mm"
    [ $input_type == "T1" ] && template=templates/MNI152_T1_1mm.nii.gz
    [ $input_type == "T2" ] && template=templates/MNI152_T2_1mm.nii.gz
    template_mask=templates/MNI152_T1_1mm_brain_mask.nii.gz
    ;;
MNI152_0.7mm)
    space="MNI152_0.7mm"
    [ $input_type == "T1" ] && template=templates/MNI152_T1_0.7mm.nii.gz
    [ $input_type == "T2" ] && template=templates/MNI152_T2_0.7mm.nii.gz
    template_mask=templates/MNI152_T1_0.7mm_brain_mask.nii.gz
    ;;
MNI152_0.8mm)
    space="MNI152_0.8mm"
    [ $input_type == "T1" ] && template=templates/MNI152_T1_0.8mm.nii.gz
    [ $input_type == "T2" ] && template=templates/MNI152_T2_0.8mm.nii.gz
    template_mask=templates/MNI152_T1_0.8mm_brain_mask.nii.gz
    ;;
MNI152_2mm)
    space="MNI152_2mm"
    [ $input_type == "T1" ] && template=templates/MNI152_T1_2mm.nii.gz
    [ $input_type == "T2" ] && template=templates/MNI152_T2_2mm.nii.gz
    template_mask=templates/MNI152_T1_2mm_brain_mask_dil.nii.gz
    ;;
esac

## make config file for fnirt
cp -v ./templates/fnirt_config.cnf ./
sed -i "/--ref=/s/$/${TEMPLATE}/" ./fnirt_config.cnf
sed -i "/--refmask=/s/$/${TEMPLATE}_mask_dil1/" ./fnirt_config.cnf

## run fsl_anat
echo "running fsl_anat"
[ -d ${tempdir}.anat ] || [ -f ${biasdir}/${output_type}.nii.gz ] && rm -rf ${tempdir}.anat acpc/${output_type}.nii.gz acpcmatrix standard/* standard_nonlin_warp/* *.mat
[ -f ${biasdir}/${output_type}.nii.gz ] && rm ${biasdir}/${output_type}.nii.gz ${input_type}_to*
[ ! -f ${tempdir}.anat/${input_type}_biascorr.nii.gz ] && fsl_anat -i ${input} \
	--noreorient \
	--nocrop \
	${l3} \
	--noreg \
	--nononlinreg \
	${l6} \
	${l7} \
	-t ${input_type} \
	-o ${tempdir} \
	--nocleanup

## align input to template of choice
# flirt
echo  "flirt linear alignment"
[ ! -f ${input_type}_to_standard_lin ] && flirt -interp spline \
	-dof 12 -in ./${tempdir}.anat/${input_type}_biascorr \
	-ref ${template} \
	-omat ${input_type}_to_standard_lin.mat \
	-out ${input_type}_to_standard_lin \
	-searchrx -30 30 -searchry -30 30 -searchrz -30 30

## acpc align input
echo  "acpc alignment"
# creating a rigid transform from linear alignment to MNI
[ ! -f acpcmatrix ] && python \
	./aff2rigid.py \
	./${input_type}_to_standard_lin.mat \
	acpcmatrix

# applying rigid transform to bias corrected image
[ ! -f ./${acpcdir}/${output_type}.nii.gz ] && applywarp --rel \
	--interp=spline \
	-i ./${tempdir}.anat/${input_type}_biascorr.nii.gz \
	-r ${template} \
	--premat=acpcmatrix \
	-o ./${acpcdir}/${output_type}.nii.gz

# dilate and fill holes in template brain mask
[ ! -f ${TEMPLATE}_mask_dil1 ] && fslmaths \
	${template_mask} \
	-fillh \
	-dilF ${TEMPLATE}_mask_dil1

# flirt again
echo "acpc to MNI linear flirt"
[ ! -f acpc_to_standard_lin.mat ] && flirt \
	-interp spline \
	-dof 12 \
	-in ./${acpcdir}/${output_type}.nii.gz \
	-ref ${template} \
	-omat acpc_to_standard_lin.mat \
	-out acpc_to_standard_lin

# fnirt
echo  "fnirt nonlinear alignment"
[ ! -f ${input_type}_to_standard_nonlin ] && fnirt \
	--in=./${acpcdir}/${output_type}.nii.gz \
	--ref=${template} \
	--fout=${input_type}_to_standard_nonlin_field \
	--jout=${input_type}_to_standard_nonlin_jac \
	--iout=${input_type}_to_standard_nonlin \
	--logout=${input_type}_to_standard_nonlin.txt \
	--cout=${input_type}_to_standard_nonlin_coeff \
	--config=./fnirt_config.cnf \
	--aff=acpc_to_standard_lin.mat \
	--refmask=${TEMPLATE}_mask_dil1.nii.gz

echo "apply fnirt warp"
[ ! -f ${standard}/${output_type}.nii.gz ] && applywarp \
	--rel \
	--interp=spline \
	-i ./${acpcdir}/${output_type}.nii.gz \
	-r ${template} \
	-w ${input_type}_to_standard_nonlin_field \
	-o ${standard}/${output_type}.nii.gz

echo  "compute inverse warp"
[ ! -f standard_to_${input_type}_nonlin_field ] && invwarp \
	-r ${template} \
	-w ${input_type}_to_standard_nonlin_coeff \
	-o standard_to_${input_type}_nonlin_field

## outputs
echo "cleanup"
# moving warp fields from non-linear warp to warp directory
[ ! -f ${standard_nonlin_warp}/inverse-warp.nii.gz ] && cp ./standard_to_${input_type}_nonlin_field.nii.gz ./${standard_nonlin_warp}/inverse-warp.nii.gz
[ ! -f ${standard_nonlin_warp_input}/inverse-warp.nii.gz ] && mv ./standard_to_${input_type}_nonlin_field.nii.gz ./${standard_nonlin_warp_input}/inverse-warp.nii.gz

[ ! -f ${standard_nonlin_warp}/warp.nii.gz ] && cp ./${input_type}_to_standard_nonlin_field.nii.gz ./${standard_nonlin_warp}/warp.nii.gz
[ ! -f ${standard_nonlin_warp_input}/warp.nii.gz ] && mv ./${input_type}_to_standard_nonlin_field.nii.gz ./${standard_nonlin_warp_input}/warp.nii.gz

# bias corrected image. even if not bias is set to false, this is the output we want for non-acpc aligned input
[ ! -f ${biasdir}/${output_type}.nii.gz ] && mv ./${tempdir}.anat/${input_type}_biascorr.nii.gz ./${biasdir}/${output_type}.nii.gz

# copy over the acpc_to_standard affine
[ ! -f ${standard_nonlin_warp}/affine.txt ] && cp acpcmatrix ./${standard_nonlin_warp}/affine.txt

# concatenate crop and/or reorient matrices if available
if [ -f ${output_type}_inverse_crop.txt ] && [ ! -f ${output_type}_reorient.txt ]; then
	convert_xfm -omat acpcmatrix_inverse_crop.txt -concat acpcmatrix ${output_type}_inverse_crop.txt
	affine=acpcmatrix_inverse_crop.txt
elif [ ! -f ${output_type}_inverse_crop.txt ] && [ -f ${output_type}_reorient.txt ]; then
	convert_xfm -omat acpcmatrix_reorient.txt -concat acpcmatrix ${output_type}_reorient.txt
	affine=acpcmatrix_reorient.txt
elif [ -f ${output_type}_inverse_crop.txt ] && [ -f ${output_type}_reorient.txt ]; then
	convert_xfm -omat ${output_type}_crop_reorient.txt -concat ${output_type}_inverse_crop.txt ${output_type}_reorient.txt
	convert_xfm -omat acpcmatrix_crop_reorient.txt -concat acpcmatrix ${output_type}_crop_reorient.txt
	affine=acpcmatrix_crop_reorient.txt
else
	affine=acpcmatrix
fi

# move final affine to input transform folder
mv ${affine} ${standard_nonlin_warp_input}/affine.txt

# other outputs
[ ! -d ${outdir} ] &&  mv ${tempdir}.anat ${outdir} && mv *.nii.gz ${outdir}/ && mv fnirt_config.cnf ${outdir}/ && mv *.txt ${outdir}/ && mv *.mat ${outdir}/

## final check and cleanup
[ ! -f ${acpcdir}/${output_type}.nii.gz ] && echo "failed" && exit 1 || exit 0
