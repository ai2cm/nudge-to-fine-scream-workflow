train-evaluate-scream-1yr
==========================

This is the workflow for training and evaluating a ML model for scream data.

Example training configuration, training data, and validation data yaml are provided. Make sure to update `submit.sh` if you would to use different yaml files, update trained model output path, or any slurm options.

To run the workflow on quartz or ruby:
```
sbatch submit.sh
```

Once training completes, we can use the trained model to report offline diagnostics as documented in `offline_diags`. We can also use the trained model for an online prognostic run, which typically requires the following CIME commands:

```
./atmchange physics::atm_procs_list="mac_aero_mic,rrtmgp,mlcorrection"
./case.setup
./atmchange mlcorrection::ML_model_path_tq="path/to/trained/model"
```