#!/bin/bash

# input configs
input=`jq -r '.input' config.json`
TEMPLATE=`jq -r '.template' config.json`
reorient=`jq -r '.reorient' config.json`
crop=`jq -r '.reorient' config.json`
bias=`jq -r '.bias' config.json`
seg=`jq -r '.seg' config.json`
subcortseg=`jq -r '.subcortseg' config.json`
input_type=`jq -r '.input_type' config.json`
tempdir='tmp'
standard='standard'
acpcdir='acpc'
standard_nonlin_warp='standard_nonlin_warp'
biasdir='bias'
outdir='raw'

## making output directories
for DIRS in ${standard} ${biasdir} ${acpcdir} ${standard_nonlin_warp}
do
	mkdir ${DIRS}
done

## set if conditions
[[ ${input_type} == 'T1' ]] && output_type='t1' || output_type='t2'
[[ ${reorient} == false ]] && l1='--noreorient' || l1=''
[[ ${crop} == false ]] && l2='--nocrop' || l2=''
[[ ${bias} == false ]] && l3='--nobias'
[[ ${seg} == false ]] && l6='--noseg' || l6=''
[[ ${subcortseg} == false ]] && l7='--nosubcortseg' || l7=''

## set template for alignment
case $TEMPLATE in
nihpd_asym*)
    space="NIHPD"
    [ $input_type == "T1" ] && template=templates/${template}_t1w.nii
    [ $input_type == "T2" ] && template=templates/${template}_t2w.nii
    template_mask=templates/${template}_mask.nii
    ;;
*)
    space="MNI152NLin6Asym"
    [ $input_type == "T1" ] && template=templates/MNI152_T1_1mm.nii.gz
    [ $input_type == "T2" ] && template=templates/MNI152_T2_1mm.nii.gz
    template_mask=templates/MNI152_1mm_brain_mask.nii.gz
    ;;
esac

## make config file for fnirt
cp -v ./templates/fnirt_config.cnf ./
sed -i "/--ref=/s/$/${TEMPLATE}/" ./fnirt_config.cnf
sed -i "/--refmask=/s/$/${TEMPLATE}_mask_dil1/" ./fnirt_config.cnf

## run fsl_anat
echo "running fsl_anat"
[ ! -f ${tempdir}.anat/${input_type}_biascorr.nii.gz ] && fsl_anat -i ${input} \
	${l1} \
	${l2} \
	${l3} \
	--noreg \
	--nononlinreg \
	${l6} \
	${l7} \
	-t ${input_type} \
	-o ${tempdir} \
	--nocleanup

## align T1 to template of choice
# flirt
echo  "flirt linear alignment"
[ ! -f ${input_type}_to_standard_lin ] && flirt -interp spline \
	-dof 12 -in ./${tempdir}.anat/${input_type}_biascorr \
	-ref ${template} \
	-dof 12 \
	-omat ${input_type}_to_standard_lin.mat \
	-out ${input_type}_to_standard_lin

# dilate and fill holes in template brain mask
[ ! -f ${TEMPLATE}_mask_dil1 ] && fslmaths ${template_mask} -fillh -dilF ${TEMPLATE}_mask_dil1

# fnirt
echo  "fnirt nonlinear alignment"
[ ! -f ${input_type}_to_standard_nonlin ] && fnirt --in=./${tempdir}.anat/${input_type}_biascorr \
	--ref=${template} \
	--fout=${input_type}_to_standard_nonlin_field \
	--jout=${input_type}_to_standard_nonlin_jac \
	--iout=${input_type}_to_standard_nonlin \
	--logout=${input_type}_to_standard_nonlin.txt \
	--cout=${input_type}_to_standard_nonlin_coeff \
	--config=./fnirt_config.cnf \
	--aff=${input_type}_to_standard_lin.mat \
	--refmask=${TEMPLATE}_mask_dil1.nii.gz

echo  "compute inverse warp"
[ ! -f standard_to_${input_type}_nonlin_field ] && invwarp --ref=./${tempdir}.anat/${input_type}_biascorr -w ${input_type}_to_standard_nonlin_coeff -o standard_to_${input_type}_nonlin_field

## these are functions used to generate brainmask of T1, but not sure if necessary. leaving here for now
#/opt/fsl-5.0.11/bin/applywarp --interp=nn --in=${template}_brain_mask.nii.gz --ref=./${tempdir}.anat/${input_type}_biascorr -w standard_to_${input_type}_nonlin_field -o ${input_type}_biascorr_brain_mask
#/opt/fsl-5.0.11/bin/fslmaths T1_biascorr_brain_mask -fillh T1_biascorr_brain_mask
#/opt/fsl-5.0.11/bin/fslmaths T1_biascorr -mas T1_biascorr_brain_mask T1_biascorr_brain

## acpc align T1
echo  "acpc alignment"
# creating a rigid transform from linear alignment to MNI
[ ! -f acpcmatrix ] && aff2rigid ./${input_type}_to_standard_lin.mat acpcmatrix

# applying rigid transform to bias corrected image
[ ! -f ./${acpcdir}/${output_type}.nii.gz ] && applywarp --rel \
	--interp=spline \
	-i ./${tempdir}.anat/${input_type}_biascorr.nii.gz \
	-r ${template} \
	--premat=acpcmatrix \
	-o ./${acpcdir}/${output_type}.nii.gz

## outputs
echo "cleanup"
# moving warp fields from non-linear warp to warp directory
[ ! -f ${standard_nonlin_warp}/inverse-warp.nii.gz ] && mv ./standard_to_${input_type}_nonlin_field.nii.gz ./${standard_nonlin_warp}/inverse-warp.nii.gz

[ ! -f ${standard_nonlin_warp}/warp.nii.gz ] && mv ./${input_type}_to_standard_nonlin_field.nii.gz ./${standard_nonlin_warp}/warp.nii.gz

# bias corrected image. even if not bias is set to false, this is the output we want for non-acpc aligned T1
[ ! -f ${biasdir}/${output_type}.nii.gz ] && mv ./${tempdir}.anat/${input_type}_biascorr.nii.gz ./${biasdir}/${output_type}.nii.gz

# standard T1
[ ! -f ${standard}/${output_type}.nii.gz ] && mv ${input_type}_to_standard_nonlin.nii.gz ./${standard}/${output_type}.nii.gz

# other outputs
[ ! -d ${outdir} ] &&  mv ${tempdir}.anat ${outdir} && mv acpcmatrix ${outdir}/ && mv *.nii.gz ${outdir}/ && mv fnirt_config.cnf ${outdir}/ && mv *.txt ${outdir}/ && mv *.mat ${outdir}/

## final check and cleanup
[ ! -f ${acpcdir}/${output_type}.nii.gz ] && echo "failed" && exit 1 || exit 0
