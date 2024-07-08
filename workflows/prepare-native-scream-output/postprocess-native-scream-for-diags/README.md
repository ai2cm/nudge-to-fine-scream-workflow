postprocess-native-scream-for-diags
===================================

This workflow postprocesses scream native output to work with prognostic run diagnostics and reporting tools.

To run the workflow on Perlmutter:
```
sbatch submit.sh
```

It uses `projects/scream/scream_post/translate_prognostic_output.py` from the `fv3net` repository to translate the output to a format that can be used by the `fv3net` prognostic diagnostics and reporting tools. The output should contain `data_2d.zarr` and `data_3d.zarr`. 

```
usage: translate_prognostic_output.py [-h] [--subset] [--num_workers NUM_WORKERS] [--threads_per_worker THREADS_PER_WORKER] input_data output_path chunk_size variable_category

positional arguments:
  input_data            Input netcdf file(s) in string, wildcards allowed.
  output_path           Local or remote path where output will be written.
  chunk_size            Chunk size for the time dimension of output zarrs.
  variable_category     Either 2d, 3d, or all.

optional arguments:
  -h, --help            show this help message and exit
  --subset              Whether to subset to a smaller set of timesteps
  --num_workers NUM_WORKERS
                        Number of workers for the dask distributed client.
  --threads_per_worker THREADS_PER_WORKER
                        Number of threads per worker for the dask distributed client.
```
