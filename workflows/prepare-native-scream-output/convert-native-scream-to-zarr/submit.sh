#!/bin/bash -e
#SBATCH -p pbatch
#SBATCH -J write-to-zarr
#SBATCH -N 1
#SBATCH -n 36
#SBATCH -t 03:00:00
#SBATCH -A mlgcrm
source /usr/workspace/climdat/python_venv/miniconda3/envs/fv3net-dev/bin/activate
scream_output_files="/p/lustre1/wu62/EAMxx/20231208.F2010-SCREAMv1.ne30pg2_ne30pg2.ruby/tests/840x1_1x1_ndays_nudged/run/output.scream.AVERAGE.nhours_x3.2010-*.nc"
output_zarr_path=`pwd`/2010.zarr
catalog=/usr/WS1/climdat/eamxx-ml/fv3net/LC_catalog.yaml
python /usr/workspace/climdat/eamxx-ml/fv3net/projects/scream/scream_post/format_output.py "$scream_output_files" $output_zarr_path T_mid,qv,U,V physics,nudging 12 --catalog_path=$catalog --calc-physics-tend=True --rename-nudging-tend=True --rename-delp=True --convert-to-cftime=True --rename-water-vapor-path=True --rename-lev-to-z=True --split-horiz-winds-tend=True --add-rad-fluxes=True --add-phis=True
