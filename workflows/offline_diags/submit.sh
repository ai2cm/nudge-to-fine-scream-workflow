#!/bin/bash -e
#SBATCH -p pdebug
#SBATCH -J offline_compute
#SBATCH -N 1
#SBATCH -n 56
#SBATCH -t 01:00:00
#SBATCH -A mlgcrm
#SBATCH --output=%x-%j.out
trained_model=/usr/workspace/wu62/scream-docs/nudge-to-fine-scream-workflow/workflows/train-evaluate-scream-1yr/trained_model_output/2023-11-15-uv-tendencies/no-tapering
test_data_config=test_data_tq_2010_1yr.yaml
offline_output=offline_output_uv
source /usr/workspace/wu62/miniconda3/envs/fv3net/bin/activate
python -m fv3net.diagnostics.offline.compute $trained_model $test_data_config $offline_output --evaluation-grid=ne30

python -m fv3net.diagnostics.offline.views.create_report \
              $offline_output \
              $offline_output/report \
              --commit-sha "not-a-commit" \
              --training-config \
              $trained_model/train.yaml \
              --training-data-config \
              $trained_model/training_data.yaml \
              --no-wandb

mv $SLURM_JOB_NAME-$SLURM_JOB_ID.out $offline_output