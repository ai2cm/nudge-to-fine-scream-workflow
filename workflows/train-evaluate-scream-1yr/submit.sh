#!/bin/bash -e
#SBATCH -p pdebug
#SBATCH -J n2f-training
#SBATCH -N 1
#SBATCH -n 36
#SBATCH -t 00:30:00
#SBATCH -A mlgcrm
#SBATCH --output=%x-%j.out
source /usr/workspace/wu62/miniconda3/envs/fv3net/bin/activate
train_config=training_config_test.yaml
training_data=training_data.yaml
trained_model_name=$(date +'%Y-%m-%d')-test-PR
trained_model_output=/usr/workspace/wu62/scream-docs/nudge-to-fine-scream-workflow/workflows/train-evaluate-scream-1yr/trained_model_output/$trained_model_name
python -m fv3fit.train $train_config $training_data $trained_model_output --no-wandb
mv $SLURM_JOB_NAME-$SLURM_JOB_ID.out $trained_model_output