preprocess-to-netcdf
====================
This workflow is an optional step. During training, the workflow will batch the input zarr files. If you plan to retrain the model, you can use this workflow to preprocess the data into batched netcdf files. This will speed up the training process considerably.

Training timestamps are randomly selected from the training set. 

To run the workflow on quartz or ruby:
```
sbatch submit.sh
```