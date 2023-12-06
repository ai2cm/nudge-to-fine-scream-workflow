nudge-to-fine-scream-workflow
=============================

This repository utilizes functionalities from [fv3net](https://github.com/ai2cm/fv3net), see fv3net's [documentation](https://vulcanclimatemodeling.com/docs/fv3net/) for more information.

## Livermore Computing
On LC quartz and ruby, a default shared `fv3net` environemnt is available. To activate it, run
```
module use --append /usr/gdata/climdat/install/quartz/modulefiles
module load fv3net-dev-venv/0.0.1
```

You can check that the environment is loaded by running
```
pip list | grep fv3fit
```
and seeing that the output is
```
fv3fit    0.1.0    /usr/WS1/climdat/eamxx-ml/fv3net/external/fv3fit
```

It is recommended to create your own conda environment so that any local changes you make to `fv3net` are reflected in your workflow. To create a `fv3net` conda environment, clone `fv3net`, and run
```
make create_environment
```