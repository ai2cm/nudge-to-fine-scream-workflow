#!/bin/bash -e
#SBATCH -p pbatch
#SBATCH -J prog-save-diags
#SBATCH -N 1
#SBATCH -n 36
#SBATCH -t 03:00:00
#SBATCH -A mlgcrm
#SBATCH --output=%x-%j.out
source /usr/workspace/climdat/python_venv/miniconda3/envs/fv3net-dev/bin/activate
input_data=/usr/gdata/climdat/eamxx-ml/vcm-scream/sample-prog-save-diags/tapering_clip20/
diag_output=$input_data/_diagnostics/diags.nc
verification_data=/usr/gdata/climdat/eamxx-ml/vcm-scream/sample-prog-save-diags/verification
prognostic_run_diags save $input_data $diag_output --verification-url=$verification_data --gsrm=scream --catalog=/usr/WS1/climdat/eamxx-ml/fv3net/LC_catalog.yaml
prognostic_run_diags metrics $input_data/_diagnostics/diags.nc > $input_data/_diagnostics/metrics.json

rm -f rundirs.json
cat <<EOF > rundirs.json
[
    {
      "url": "$input_data",
      "name": "sample_ML_run"
    }
]
EOF

prognostic_run_diags report-from-json --urls-are-rundirs rundirs.json report
mv $SLURM_JOB_NAME-$SLURM_JOB_ID.out report