scream-run-script
=================
The run scripts in this directory are adapted from [run_eamxx_template.sh](https://github.com/E3SM-Project/scream-docs/blob/master/run_scripts/run_eamxx_template.sh).

During a typical nudge-to-fine workflow, we start from a high-resolution simulation and output the state in a coarsened state, then use the coarsened data to nudge a low-resolution simulation. For example, we start from a ne120 simulation (`run_ne120pg2_2yr.sh`) and output the state in ne30 resolution, then we run a ne30 simulation (`run_ne30pg2_2yr.sh`) and nudge it with the coarsened ne120->ne30 state. In particular, during the low-resolution simulation, we need to specify the path to the coarsened state file from the high-resolution simulation (`sc_export::prescribed_from_file::files` and `nudging::nudging_filename`).

Once the nudged run is completed, we can use the output to train a ML model to predict the nudging tendencies. The ML model is then used online to run a low-resolution simulation and predict the nudging tendencies. A ML corrected run example is provided in `run_ne30pg2_ML_correction.sh`. Typically, we need to restart the ML corrected run from a previously nudged restart state. For example, we run the nudged simulation for 2-years, use the first year of data for training and the second year of data for testing. In this case, we need to point the ML corrected run folder to use the nudged restart state for the `rpointer.*` files. To avoid restart casename issues, it is recommended to keep the `CASE_SCRIPTS_DIR` and `CASE_RUN_DIR` path as the sample run scripts. The folder structure should look like this:
```
${CASE_NAME}/tests/{PE_LAYOUT}_1x1_ndays_nudged
${CASE_NAME}/tests/{PE_LAYOUT}_1x1_ndays_mlcorrected
${CASE_NAME}/tests/{PE_LAYOUT}_1x1_ndays_baseline
```

Then we add `rpointer.*` files in the `${CASE_NAME}/tests/{PE_LAYOUT}_1x1_ndays_mlcorrected/run` folder to point to the nudged restart state in `${CASE_NAME}/tests/{PE_LAYOUT}_1x1_ndays_nudged`. Additionally, we change CONTINUE_RUN to TRUE in `${CASE_NAME}/tests/{PE_LAYOUT}_1x1_ndays_mlcorrected/case_scripts`: `./xmlchange CONTINUE_RUN=TRUE`. The same procedure should be applied to the baseline run.

Because of the way the folders are set up, we occasionally run into e3sm build errors. Most of the time this can be resolved by cleaning the build first then rebuilding it.
In `${CASE_NAME}/tests/{PE_LAYOUT}_1x1_ndays_mlcorrected/case_scripts` or `${CASE_NAME}/tests/{PE_LAYOUT}_1x1_ndays_baseline/case_scripts`:
```
./case.build --clean-all
./case.build
```