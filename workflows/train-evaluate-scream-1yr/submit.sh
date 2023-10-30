#!/bin/bash -e
#SBATCH -p pdebug
#SBATCH -J n2f-training
#SBATCH -N 5
#SBATCH -n 180
#SBATCH -t 01:00:00
#SBATCH -A mlgcrm
#SBATCH --output=%x-%j.out
source /usr/workspace/wu62/miniconda3/envs/fv3net/bin/activate
train_config=training_config_dQu_dQv.yaml
training_data=training_data.yaml
trained_model_output=/usr/workspace/wu62/scream-docs/nudge-to-fine-scream-workflow/workflows/train-evaluate-scream-1yr/uv_tendencies
python -m fv3fit.train $train_config $training_data $trained_model_output --no-wandb --Livermore-Computing