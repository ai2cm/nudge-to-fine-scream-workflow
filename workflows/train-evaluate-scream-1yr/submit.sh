#!/bin/bash -e
#SBATCH -q shared
#SBATCH -J n2f-training
#SBATCH -N 1
#SBATCH -C gpu
#SBATCH -G 1
#SBATCH -t 8:00:00
#SBATCH -A m4492
#SBATCH --output=%x-%j.out

conda activate /global/common/software/m4492/fv3net-shared-py39
ml load cudatoolkit/11.7 cudnn

train_config=train-config.yaml
training_data=train-data.yaml
trained_model_name=$(date +'%Y-%m-%d')-rad-lw-only-$(openssl rand -hex 6)/no-tapering
trained_model_output=$SCRATCH/trained_model_output/$trained_model_name
validation_data=val-data.yaml
python -m fv3fit.train $train_config $training_data $trained_model_output --validation-data-config=$validation_data --no-wandb
mv $SLURM_JOB_NAME-$SLURM_JOB_ID.out $trained_model_output