#!/bin/bash
#SBATCH -p debug
#SBATCH -J save_val_netcdfs
#SBATCH -N 1
#SBATCH -C gpu
#SBATCH -t 00:30:00
#SBATCH -A m4492
#SBATCH --output=%x-%j.out

set -e
preprocess_output=/pscratch/sd/a/andrep/Corrective-ML/nudged_sim_with_fixed_radation_from_ne120/batch-validation-netcdfs-radiation-v2
preprocess_config=$(pwd)/validation.yaml
conda activate /global/common/software/m4492/fv3net-shared-py39
python -m loaders.batches.save $preprocess_config $preprocess_output --num-workers 12
cp $preprocess_config $preprocess_output