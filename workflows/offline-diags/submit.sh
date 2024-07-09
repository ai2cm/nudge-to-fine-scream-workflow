#!/bin/bash -e
#SBATCH -p debug
#SBATCH -J offline_diags
#SBATCH -N 1
#SBATCH -C gpu
#SBATCH -t 00:30:00
#SBATCH -A m4492
#SBATCH --output=%x-%j.out

VERSION=v1
# trained_model=/global/cfs/cdirs/m4492/corrective_ml/trained_models/2024-04-25-Tq-210cf0f46045/no-tapering
# offline_output=`pwd`/$(date +'%Y-%m-%d')-offline-output-sample-${VERSION}/tq_offline_diags

# trained_model=/global/cfs/cdirs/m4492/corrective_ml/trained_models/2024-04-24-uv-test-892b5c2ef080/no-tapering
# offline_output=`pwd`/$(date +'%Y-%m-%d')-offline-output-sample-${VERSION}/uv_offline_diags

trained_model=/pscratch/sd/a/andrep/Corrective-ML/models/trained_model_output/2024-07-03-rad-lw-only-0d41a5a38577/no-tapering
offline_output=`pwd`/$(date +'%Y-%m-%d')-offline-output-sample-${VERSION}/rad_offline_diags

test_data_config=/pscratch/sd/a/andrep/for_diags/test_data.yaml
mkdir -p $offline_output
conda activate /global/common/software/m4492/fv3net-shared-py39

python -m fv3net.diagnostics.offline.compute $trained_model $test_data_config $offline_output --evaluation-grid=ne30 \
    --catalog_path=/global/common/software/m4492/LC_catalog.yaml --n-jobs=8

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