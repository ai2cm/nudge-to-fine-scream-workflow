#!/bin/bash -e
#SBATCH -p pbatch
#SBATCH -J preprocess-to-netcdf
#SBATCH -N 1
#SBATCH -n 36
#SBATCH -t 03:00:00
#SBATCH -A mlgcrm
#SBATCH --output=%x-%j.out
preprocess_output=`pwd`/batch-netcdfs
preprocess_train_config=train.yaml
source /usr/workspace/climdat/python_venv/miniconda3/envs/fv3net-dev/bin/activate
python -m loaders.batches.save $preprocess_train_config $preprocess_output