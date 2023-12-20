#!/bin/bash -e
#SBATCH -p pdebug
#SBATCH -J offline_compute
#SBATCH -N 2
#SBATCH -n 72
#SBATCH -t 01:00:00
#SBATCH -A mlgcrm
#SBATCH --output=%x-%j.out
trained_model=/usr/gdata/climdat/eamxx-ml/vcm-scream/sample-trained-ML-model/2023-12-13-tq-tendencies-5bba84c4e149/no-tapering
test_data_config=test_data.yaml
offline_output=`pwd`/$(date +'%Y-%m-%d')-offline-output-sample
source /usr/workspace/climdat/python_venv/miniconda3/envs/fv3net-dev/bin/activate
python -m fv3net.diagnostics.offline.compute $trained_model $test_data_config $offline_output --evaluation-grid=ne30 --catalog_path=/usr/WS1/climdat/eamxx-ml/fv3net/LC_catalog.yaml

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