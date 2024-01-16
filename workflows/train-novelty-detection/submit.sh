#!/bin/bash -e
#SBATCH -p pbatch
#SBATCH -J n2f-training
#SBATCH -N 5
#SBATCH -n 280
#SBATCH -t 8:00:00
#SBATCH -A mlgcrm
#SBATCH --output=%x-%j.out
source /usr/workspace/climdat/python_venv/miniconda3/envs/fv3net-dev/bin/activate
train_config=train_gamma_1_79_nu_0.0001.yaml
training_data=training_data.yaml
trained_model_name=$(date +'%Y-%m-%d')-ocsvm-Tq-$(openssl rand -hex 6)
trained_model_output=`pwd`/trained_model_output/$trained_model_name
python -m fv3fit.train $train_config $training_data $trained_model_output --no-wandb
mv $SLURM_JOB_NAME-$SLURM_JOB_ID.out $trained_model_output