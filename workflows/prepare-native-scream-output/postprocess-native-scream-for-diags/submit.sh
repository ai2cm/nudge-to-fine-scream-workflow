#!/bin/bash -e
#SBATCH -p pdebug
#SBATCH -J write-to-diags-zarr
#SBATCH -N 1
#SBATCH -n 36
#SBATCH -t 01:00:00
#SBATCH -A mlgcrm
source /usr/workspace/climdat/python_venv/miniconda3/envs/fv3net-dev/bin/activate
scream_output_files="/usr/workspace/climdat/eamxx-ml/nudge-to-fine-sample-data/example-ML-corrected-run/output.scream.AVERAGE.nhours_x3.2011-01-*.nc"
output_zarr_path=`pwd`/post-processed-for-diags
time_chunk_size=12
python /usr/workspace/climdat/eamxx-ml/fv3net/projects/scream/scream_post/translate_prognostic_output.py "$scream_output_files" $output_zarr_path $time_chunk_size all