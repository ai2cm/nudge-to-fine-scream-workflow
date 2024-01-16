train-novelty-detection
=======================

This is the workflow for training a novelty detection model. The trained model is meant to be used as a [composite model](https://vulcanclimatemodeling.com/docs/fv3fit/composite-models.html) with a baseline model from `train-evaluate-scream-1yr`. 

See [Sanford et al., 2023](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2023MS003809) for more information on novelty detection.

To run the workflow on quartz or ruby:
```
sbatch submit.sh
```

### Additional Notes
To get familiarized with this workflow, a notebook is added under [explore](explore/) where you can explore and train a novelty detection model on a small subset of data. Once you're ready to run the full workflow, it will likely take some iteration to get the model to train successfully. It appears that only selective combinations of &gamma; and &nu; are able to train successfully in a timely manner. The example training configuration (&gamma;=0.012, &nu;=1e-4) was trained succesfully using 5 nodes on Ruby, and took about ~5.5 hours.

### Example Trained Model
```
/usr/gdata/climdat/eamxx-ml/vcm-scream/sample-trained-ML-model/2024-01-06-ocsvm-Tq-88971a1232d0
```

Model output variables include: `is_novelty`, `novelty_score`, `centered_score`.
To check where novelties are detected in the prognostic run, we could add `add_field<Computed>` in MLCorrection and have output stream outputs this 2D variable.