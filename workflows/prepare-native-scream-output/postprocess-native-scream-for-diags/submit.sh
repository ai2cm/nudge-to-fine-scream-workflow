#!/bin/bash -e
#SBATCH -p debug
#SBATCH -J process-output-for-diags
#SBATCH -N 1
#SBATCH -C gpu
#SBATCH -t 00:30:00
#SBATCH -A m4492
#SBATCH --output=%x-%j.out

conda activate /global/common/software/m4492/fv3net-shared-py39

# ne30 nudged
# scream_output_files="/pscratch/sd/a/adonahue/Corrective-ML/20240304_NOT_remapped.F2010-SCREAMv1.ne30pg2_ne30pg2.pm-gpu/tests/20x1_1x1_ndays_nudged/run/output.scream.AVERAGE.nhours_x3.*.nc"
# scream_output_files="/pscratch/sd/a/adonahue/Corrective-ML/20240304_NOT_remapped.F2010-SCREAMv1.ne30pg2_ne30pg2.pm-gpu/tests/20x1_1x1_ndays_nudged/run/output.scream.AVERAGE.nhours_x3.201*-01-*.nc"
# output_zarr_path=$SCRATCH/processed_scream_output/nudged_sim_fixed_rad

# ne30 nudged fixed radiation
# scream_output_files="/pscratch/sd/a/andrep/Corrective-ML/nudged_sim_with_fixed_radation_from_ne120"
# output_zarr_path=$SCRATCH/processed_scream_output/nudged_sim_fixed_rad

# ne120 -> ne30
# 2d
# scream_output_files="/pscratch/sd/a/adonahue/Corrective-ML/20240326.F2010-SCREAMv1.ne120pg2_ne120pg2.pm-gpu/tests/88x1_1x1_nmonths/run/output.scream.remapped_output.2d.AVERAGE.nhours_x3.*.nc"
# category="2d"
# time_chunk_size=256
# output_zarr_path=$SCRATCH/processed_scream_output/verification

# 3d
# scream_output_files="/pscratch/sd/a/adonahue/Corrective-ML/20240222.F2010-SCREAMv1.ne120pg2_ne120pg2.pm-gpu/tests/88x1_1x1_nmonths/run/output.scream.novert.remapped_output.3d.AVERAGE.nhours_x3*.nc"
# category="3d"
# output_zarr_path=$SCRATCH/processed_scream_output/verification
# time_chunk_size=12
# category="3d"

# ne30 baseline
# scream_output_files="/pscratch/sd/a/adonahue/Corrective-ML/20240325_control.F2010-SCREAMv1.ne30pg2_ne30pg2.pm-gpu/tests/20x1_1x1_ndays_nudged/run/diagnostics.scream.hourly.AVERAGE.nhours_x3.*.nc"
# output_zarr_path=$SCRATCH/processed_scream_output/baseline

# ne30 ml_corrected tq
# scream_output_files="/pscratch/sd/a/adonahue/Corrective-ML/20240327.F2010-SCREAMv1.ne30pg2_ne30pg2.mlcorrected.from_ruby/output.scream.AVERAGE.nhours_x3.*nc"
# output_zarr_path=$SCRATCH/processed_scream_output/hr_ml_corrected3

# ne30 ml_corrected tquvRad
# scream_output_files="/pscratch/sd/a/andrep/from_ruby/output.scream.AVERAGE.nhours_x3.*nc"
# output_zarr_path=$SCRATCH/processed_scream_output/tquvRad_ml_corrected

# ne30 ml_corrected novelty_detection
scream_output_files="/pscratch/sd/a/andrep/Corrective-ML/gpu-ml-0617-1yr.F2010-SCREAMv1.ne30pg2_ne30pg2.pm-gpu/tests/20x1_1x1_ndays_mlcorrected/run/output.scream.AVERAGE.nhours_x3.*nc"
output_zarr_path=$SCRATCH/processed_scream_output/tquvRad_novelty_ml_corrected_v2

mkdir -p $output_zarr_path
fv3net_dir = $PSCRATCH/repos/fv3net

time_chunk_size=256
category="2d"
python $fv3net_dir/projects/scream/scream_post/translate_prognostic_output.py "$scream_output_files" $output_zarr_path $time_chunk_size $category

time_chunk_size=12
category="3d"
python $fv3net_dir/projects/scream/scream_post/translate_prognostic_output.py "$scream_output_files" $output_zarr_path $time_chunk_size $category
