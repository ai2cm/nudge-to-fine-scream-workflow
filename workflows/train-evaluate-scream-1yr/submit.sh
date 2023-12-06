#!/bin/bash -e
#SBATCH -p pdebug
#SBATCH -J n2f-training
#SBATCH -N 1
#SBATCH -n 56
#SBATCH -t 01:00:00
#SBATCH -A mlgcrm
#SBATCH --output=%x-%j.out
source /usr/workspace/climdat/python_venv/miniconda3/envs/fv3net-dev/bin/activate
train_config=training_config_test.yaml
training_data=training_data.yaml
trained_model_name=$(date +'%Y-%m-%d')-tq-test-$(openssl rand -hex 6)/no-tapering
trained_model_output=`pwd`/trained_model_output/$trained_model_name
validation_data=val-data.yaml
python -m fv3fit.train $train_config $training_data $trained_model_output --validation-data-config=$validation_data --no-wandb
mv $SLURM_JOB_NAME-$SLURM_JOB_ID.out $trained_model_output