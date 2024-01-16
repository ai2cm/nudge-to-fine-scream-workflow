import matplotlib.pyplot as plt
import vcm
from vcm.catalog import catalog 
import math 
import dask.diagnostics
import fv3viz
import time
import fsspec
import joblib
import xarray as xr
import os
import numpy as np
from vcm.cubedsphere import GridMetadataScream
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.svm import OneClassSVM

            
def get_ocsvm_model_path(gamma, nu, dataset_name, n, notes=None):
    if notes is None:
        return "gs://vcm-ml-scratch/claytons/2022-06-14/models/ocsvm_{}_{}_{}_{}.pkl".format(dataset_name, n, gamma, nu)
    else:
        return "gs://vcm-ml-scratch/claytons/2022-06-14/models/ocsvm_{}_{}_{}_{}_{}.pkl".format(dataset_name, n, gamma, nu, notes)

def save_ocsvm(clf, gamma, nu, dataset_name, n, notes=None):
    path = "ocsvm_{}_{}_{}_{}.pkl".format(dataset_name, n, gamma, nu)
    save_model(clf, path)
    return path
        
def save_model(clf, path):
    with fsspec.open(path, "wb") as f:
        joblib.dump(clf,  f)
    print("Successfully saved model to path {}".format(path))
        
def load_ocsvm(clf, gamma, nu, dataset_name, n, notes=None):
    return load_model(get_ocsvm_model_path(gamma, nu, dataset_name, n, notes)) 
        
def load_model(path):
    with fsspec.open(path, "rb") as f:
        return joblib.load(f)
    
def train_ocsvm(gamma, nu, dataset_name, training_data, save_model=True, timer=True):
    # training data must be an n x d matrix
    start = time.time()
    clf = make_pipeline(StandardScaler(), OneClassSVM(max_iter=10, kernel="rbf", gamma=gamma, nu=nu))
    clf.fit(training_data)
    if time:
        print("Time to train model: {}s".format(time.time() - start))
    if save_model:
        model_path = save_ocsvm(clf, gamma, nu, dataset_name, len(training_data))
        return clf, model_path
    else:
        return clf, None
    
def get_ocsvm_cutoff(clf, training_data, plots=True, timer=True):
    start = time.time()
    train_score = clf.score_samples(training_data)
    if timer:
        print("Time to evaluate model on training data: {}s".format(time.time() - start))

    if plots:
        plt.hist(train_score, bins=50)
        plt.title("Histogram of OCSVM scores for training data")
        plt.show()

    cutoff = min(train_score)
    return cutoff

def to_feature_matrix(features):
    return np.concatenate(features, axis=1)

def evaluate_novelty_detection_plots(score_ds, cutoff, dataset_name, full_fraction_range=False):
    novelty_ds = xr.where(score_ds <= cutoff, 1, 0)
        
    # score_ds.plot(bins=50, label="typical")
    # plt.axvline(x=cutoff, c="r")
    # plt.title("Histogram of OCSVM scores for {} data".format(dataset_name))
    # plt.show()

    novelty_ds.mean(("ncol")).plot(label="cutoff")
    plt.title("Fraction of novelties by time")
    plt.show()

    novelty_ds.mean(("ncol")).plot(label="cutoff")
    xr.where(score_ds <= 2 * cutoff, 1, 0).mean(("ncol")).plot(label="2*cutoff")
    xr.where(score_ds <= cutoff / 2, 1, 0).mean(("ncol")).plot(label="cutoff/2")
    plt.legend()
    plt.title("Fraction of novelties by time with other cutoffs")
    plt.show()

    grid = xr.open_zarr("/usr/workspace/climdat/eamxx-ml/vcm-scream/latLonArea/ne30/ne30.zarr/")
    if full_fraction_range:
        vcm.zonal_average_approximate(
            grid.lat,
            novelty_ds
        ).plot(x="time", vmax=1, vmin=0)
    else:
        vcm.zonal_average_approximate(
            grid.lat,
            novelty_ds
        ).plot(x="time")
    plt.title("Fraction of novelties by time and latitude")
    plt.show()
    grid_metadata = GridMetadataScream("ncol", "lon", "lat")
    if full_fraction_range:
        fv3viz.plot_cube(ds = novelty_ds.mean("time").to_dataset(name="novelty_frac").merge(grid), var_name="novelty_frac", vmax=1, vmin=0, grid_metadata=grid_metadata)
    else:
        fv3viz.plot_cube(ds = novelty_ds.mean("time").to_dataset(name="novelty_frac").merge(grid), var_name="novelty_frac", cmap_percentiles_lim=False, grid_metadata=grid_metadata)
    plt.title("Fraction of novelties over time")
    plt.show()

    print("Total fraction of novelties: {}".format(novelty_ds.mean().item()))
    

def evaluate_novelty_detection_multi_field(data_arrays, clf, cutoff, dataset_name, timer=True):
    start = time.time()
    dataset_features = to_feature_matrix(data_arrays)
    score = clf.score_samples(dataset_features)
    score_ds = xr.DataArray(np.asarray(score), coords=data_arrays[0].coords, dims=('sample')).unstack()

    if timer:
        print("Time elasped: {}s".format(time.time() - start))
    
    return score_ds

def train_and_eval_ocsvm(
    gamma,
    nu,
    training_dataset_name,
    training_data,
    testing_dataset_name,
    testing_data,
    save_model=True,
    timer=True,
    full_fraction_range=False):    
    clf, model_path = train_ocsvm(gamma, nu, training_dataset_name, training_data, save_model=save_model, timer=timer)
    cutoff = get_ocsvm_cutoff(clf, training_data, plots=True, timer=timer)
    prognostic_scores = evaluate_novelty_detection_multi_field([testing_data], clf, cutoff, testing_dataset_name, timer=timer)
    evaluate_novelty_detection_plots(prognostic_scores, cutoff, testing_dataset_name, full_fraction_range=full_fraction_range)
    trial_string = "{}_{}_{}_{}".format(training_dataset_name, len(training_data), gamma, nu)
    return clf, prognostic_scores, cutoff, trial_string, model_path

def eval_trained_ocsvm(
    clf,
    cutoff,
    testing_dataset_name,
    testing_data,
    timer=True):    
    prognostic_scores = evaluate_novelty_detection_multi_field([testing_data], clf, cutoff, testing_dataset_name, timer=timer)
    evaluate_novelty_detection_plots(prognostic_scores, cutoff, testing_dataset_name)
    return prognostic_scores

def stack(data_arr):
    return data_arr.stack(sample=["time", "tile", "x", "y"]).transpose("sample", ...)

def novelty_fraction_plot_latitudes(paths, score_datasets, cutoffs, min_max_out_of_range=None):
    latitudes = [-90, -60, -20, 20, 60, 90]
    common_coords = {"tile": range(6), "x": range(48), "y": range(48)}
    grid = atmospheric_data.get_grid()
    for i in range(len(latitudes) - 1):
        for path in paths:
            novelty_ds = xr.where(score_datasets[path] <= cutoffs[path], 1, 0)
            vcm.weighted_average(novelty_ds, grid.area.where((grid.lat >= latitudes[i]) & (grid.lat <= latitudes[i+1]))).plot(label=t)
        if min_max_out_of_range is not None:
            vcm.weighted_average(out_of_range.assign_coords(common_coords), grid.area.where((grid.lat >= latitudes[i]) & (grid.lat <= latitudes[i+1]))).plot(label="min-max")
        plt.legend()
        plt.title("Fraction of novelties between {} and {} latitude".format(latitudes[i], latitudes[i+1]))
        plt.show()
    
    