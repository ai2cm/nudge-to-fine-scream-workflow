#!/bin/bash -e

conda activate /global/common/software/m4492/fv3net-shared-py39
prognostic_run_diags report-from-json rundirs.json report

gcs_out="gs://vcm-ml-public/scream-reports/online/2024-07-08-tquvRad-novelty-detection"

gsutil -m cp -r report/* $gcs_out
