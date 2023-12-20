prognostic-run-diags
====================
This workflow is used to produce diagnostics from a prognostic run and generate a report.

To run the workflow on quartz or ruby:
```
sbatch diags_save_and_report.sh
```

- `input_data` should be a prognostic run directory including post-processed data (see `prepare-native-scream-output/postprocess-native-scream-for-diags`), containing `data_2d.zarr` and `data_3d.zarr`
- `diag_output` is where the diagnostics will be saved, should always be `$input_data/_diagnostics/diags.nc`
- `verification_data` is typically the coarsened fine data from the high-resolution run

When making the report, we create `rundirs.json` with labels for the runs. For example:
```
[
    {
      "url": "/path/to/sample/ML_run/",
      "name": "sample_ML_run"
    },
    {
      "url": "/path/to/different/sample/ML_run/",
      "name": "sample_different_ML_run"
    },    
]
```