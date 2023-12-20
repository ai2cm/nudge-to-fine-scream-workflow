workflows
=========
This directory contains the workflows that are used during a typical nudge-to-fine scream process. The order of the workflows is as follows:
1. [scream-run-script](scream-run-script/README.md): run high-resolution and low-resolution simulations
    - run a [high-resolution simulation](scream-run-script/run_ne120pg2_2yr.sh) and output the state in a coarsened state
    - run a [low-resolution nudged simulation](scream-run-script/run_ne30pg2_2yr_nudged.sh) and nudging tendencies for ML training
    - (optional) run a [low-resolution baseline simulation](scream-run-script/run_ne30pg2_baseline.sh) for comparison later
2. [convert-native-scream-to-zarr](prepare-native-scream-output/convert-native-scream-to-zarr/README.md): convert nudging tendencies to the format needed for ML training
    - (optional) [preprocess-to-netcdf](prepare-native-scream-output/preprocess-to-netcdf/README.md): batch preprocess the nudging tendencies to speed up ML training
3. [train-evaluate-scream-1yr](train-evaluate-scream-1yr/README.md): train and evaluate the ML model
4. (optional) [offline-diags](offline-diags/README.md): create offline report for the ML model
5. [scream-run-script](scream-run-script/README.md): run low-resolution ML corrected simulation
    - run a [low-resolution ML-corrected simulation](scream-run-script/run_ne30pg2_ML_correction.sh) using the trained ML model from step 3
6. [postprocess-native-scream-for-diags](prepare-native-scream-output/postprocess-native-scream-for-diags/README.md): postprocess ML output for prognostic run diagnostics and reporting
7. [prognostic-run-diags](prognostic-run-diags/README.md): run prognostic diagnostics on the ML-corrected simulation and create a report