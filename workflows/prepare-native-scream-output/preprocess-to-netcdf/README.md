preprocess-to-netcdf
====================
This workflow is an optional step. During training, the workflow will batch the input zarr files. If you plan to retrain the model, you can use this workflow to preprocess the data into batched netcdf files. This will speed up the training process considerably.

Training/validation timestamps are a  selected using 60 train times drawn from 2 week block, from which first/last two timesteps are excluded
5 test times drawn from 1 week block following three week training block over the dataset.

See the notebook [here](https://github.com/ai2cm/scream-explore/blob/main/generate_train_val_timesteps.ipynb) for more details.

To run the workflow on Perlmutter:
```
sbatch save_train_netcdfs.sh
sbatch save_val_netcdfs.sh
```