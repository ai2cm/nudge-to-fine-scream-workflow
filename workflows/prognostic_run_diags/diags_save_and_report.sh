#!/bin/bash -e
#SBATCH -p pbatch
#SBATCH -J prog-save-diags
#SBATCH -N 1
#SBATCH -n 56
#SBATCH -t 03:00:00
#SBATCH -A mlgcrm
#SBATCH --output=%x-%j.out
input_data=/p/lustre1/wu62/EAMxx/20231016.F2010-SCREAMv1.ne30pg2_ne30pg2.quartz/tests/720x1_1x1_ndays_mlcorrected/run/tapering_clip20/2011_100ts/
diag_output=diags_test.nc
verification_data=/p/lustre1/wu62/EAMxx/20230826.F2010-SCREAMv1.ne120pg2_ne120pg2.ruby/tests/5712x1_1x1_ndays/run/2011
prognostic_run_diags save $input_data $diag_output --verification-url=$verification_data --gsrm=scream
prognostic_run_diags report-from-json --urls-are-rundirs --gsrm=scream rundirs.json temp_report