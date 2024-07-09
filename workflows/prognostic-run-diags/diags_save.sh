#!/bin/bash -e
#SBATCH -p pbatch
#SBATCH -J prog-save-diags
#SBATCH -N 1
#SBATCH -n 36
#SBATCH -t 03:00:00
#SBATCH -A mlgcrm
#SBATCH --output=%x-%j.out

#!/bin/bash

conda activate /global/common/software/m4492/fv3net-shared-py39
# input_data=/pscratch/sd/a/andrep/for_diags/baseline
# input_data=/pscratch/sd/a/andrep/for_diags/nudged_sim_fixed_rad
# input_data=/pscratch/sd/a/andrep/for_diags/tquvRad_ml_corrected
input_data=/pscratch/sd/a/andrep/for_diags/tquvRad_novelty_ml_corrected_v2
diag_dir=$input_data/_diagnostics
diag_output=$diag_dir/diags.nc
verification_data=/pscratch/sd/a/andrep/for_diags/verification
prognostic_run_diags save $input_data $diag_output --verification-url=$verification_data \
  --gsrm=scream --catalog=/global/homes/a/andrep/repos/fv3net/LC_catalog.yaml \
  --scheduler-file=scheduler_file.json
prognostic_run_diags metrics $input_data/_diagnostics/diags.nc > $input_data/_diagnostics/metrics.json
