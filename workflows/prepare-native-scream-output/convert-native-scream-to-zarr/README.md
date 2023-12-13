convert-native-scream-to-zarr
=============================
This workflow converts the native scream output to zarr format into three folders:
- nudging_tendencies.zarr
- physics_tendencies.zarr
- state_after_timestep.zarr

To run the workflow on quartz or ruby:
```
sbatch submit.sh
```