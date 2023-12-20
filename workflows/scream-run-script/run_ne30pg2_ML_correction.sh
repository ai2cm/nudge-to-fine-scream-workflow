#!/bin/bash -fe

# EAMxx template run script

main() {

# For debugging script, uncomment line below
#set -x

# --- Toggle flags for what to do ----
# Typical use cases:
# - New complete setup and run: everything true
# - Skip code checkout, do_fetch_code=false, everything else true
# - Skip code checkout, reuse existing executable: do_fetch_code=false, do_case_build=false, everything else true
do_fetch_code=false
do_create_newcase=true
do_case_setup=true
do_case_build=true
do_case_submit=true

# --- Configuration flags ----
# Machine
readonly MACHINE="ruby"  # "quartz"

# Code and compilation
readonly CASENAME_CHECKOUT="20231219"
readonly BRANCH="master"         # master, branch name, or github hash
readonly CHERRY=( )       
readonly COMPILER="intel"
readonly DEBUG_COMPILE=false

# Simulation
readonly COMPSET="F2010-SCREAMv1"
readonly RESOLUTION="ne30pg2_ne30pg2"
readonly CASE_NAME=${CASENAME_CHECKOUT}.${COMPSET}.${RESOLUTION}.${MACHINE}
# If this is part of a simulation campaign, ask your group lead about using a case_group label
readonly CASE_GROUP=""

readonly OUTPUT_YAML_FILES="/usr/gdata/climdat/eamxx-ml/output/scream_output.ne30_mlcorrected.yaml"
# History file frequency (if using default above)
readonly HIST_OPTION="nmonths"
readonly HIST_N="2"

# Run options
readonly MODEL_START_TYPE="initial"  # "initial", "continue", "branch", "hybrid"
readonly START_DATE="2010-01-01"               # "" for default, or explicit "0001-01-01"
readonly START_TIME="0" # start on hour 3

# Additional options for 'branch' and 'hybrid'
readonly GET_REFCASE=false
readonly RUN_REFDIR=""
readonly RUN_REFCASE=""
readonly RUN_REFDATE=""   # same as MODEL_START_DATE for 'branch', can be different for 'hybrid'

# Machine specific settings
if [[ "$MACHINE" == "ruby" || "$MACHINE" == "quartz" ]]; then
    # Load default Python - should include the following packages: pyyaml pylint psutil
    module load python/3.9.12
    # Paths
    readonly CODE_ROOT="/usr/workspace/${USER}/scream"
    # [EW]: I've had issues with writing restart files to lustre2
    # switching to /usr/workspace has been fine, unclear if it's necessary
    # readonly CASE_ROOT="/p/lustre2/${USER}/E3SM/EAMxx/${CASE_NAME}"
    readonly CASE_ROOT="/usr/workspace/${USER}/EAMxx/${CASE_NAME}"
    # Additional settings
    readonly PROJECT="mlgcrm"
    readonly QUEUE="pbatch"
fi

# Sub-directories
readonly CASE_BUILD_DIR=${CASE_ROOT}/build
readonly CASE_ARCHIVE_DIR=${CASE_ROOT}/archive

# Define type of run
#  short tests: specify PE layout and simulation length such as "16x1_1x4_ndays", "16x1_2x2_ndays", ...
#  or "production" for full simulation

readonly run="840x1_1x1_ndays_mlcorrected"
tmp=($(echo $run | tr "_" " "))
layout=${tmp[0]}
units=${tmp[2]}
resubmit=$(( ${tmp[1]%%x*} -1 ))
length=${tmp[1]##*x}

readonly CASE_SCRIPTS_DIR=${CASE_ROOT}/tests/${run}/case_scripts
readonly CASE_RUN_DIR=${CASE_ROOT}/tests/${run}/run
readonly PELAYOUT=${layout}
readonly WALLTIME="01:40:00"
readonly STOP_OPTION="ndays" #"nmonths"
readonly STOP_N="2"
readonly REST_OPTION="nmonths"
readonly REST_N="2"
readonly RESUBMIT="0"
readonly DO_SHORT_TERM_ARCHIVING=false

# Leave empty (unless you understand what it does)
readonly OLD_EXECUTABLE=""

# --- Now, do the work ---

# Make directories created by this script world-readable
umask 022

# Fetch code from Github
fetch_code

# Create case
create_newcase

# Setup
case_setup

# Build
case_build

# Configure runtime options
runtime_options

# Copy script into case_script directory for provenance
copy_script

# Submit
case_submit

# All done
echo $'\n----- All done -----\n'

}

# =======================
# Custom user_nl settings
# =======================

user_nl() {

    echo "+++ Configuring SCREAM for 128 vertical levels +++"
    ./xmlchange SCREAM_CMAKE_OPTIONS="SCREAM_NP 4 SCREAM_NUM_VERTICAL_LEV 128 SCREAM_NUM_TRACERS 10"

}

######################################################
### Most users won't need to change anything below ###
######################################################

#-----------------------------------------------------
fetch_code() {

    if [ "${do_fetch_code,,}" != "true" ]; then
        echo $'\n----- Skipping fetch_code -----\n'
        return
    fi

    echo $'\n----- Starting fetch_code -----\n'
    local path=${CODE_ROOT}
    local repo=scream

    echo "Cloning $repo repository branch $BRANCH under $path"
    if [ -d "${path}" ]; then
        echo "ERROR: Directory already exists. Not overwriting"
        exit 20
    fi
    mkdir -p ${path}
    pushd ${path}

    # This will put repository, with all code
    git clone git@github.com:E3SM-Project/${repo}.git .

    # Q: DO WE NEED THIS FOR EAMXX?
    # Setup git hooks
    rm -rf .git/hooks
    git clone git@github.com:E3SM-Project/E3SM-Hooks.git .git/hooks
    git config commit.template .git/hooks/commit.template

    # Check out desired branch
    git checkout ${BRANCH}

    # Custom addition
    if [ "${CHERRY}" != "" ]; then
        echo ----- WARNING: adding git cherry-pick -----
        for commit in "${CHERRY[@]}"
        do
            echo ${commit}
            git cherry-pick ${commit}
        done
        echo -------------------------------------------
    fi

    # Bring in all submodule components
    git submodule update --init --recursive

    popd
}

#-----------------------------------------------------
create_newcase() {

    if [ "${do_create_newcase,,}" != "true" ]; then
        echo $'\n----- Skipping create_newcase -----\n'
        return
    fi

    echo $'\n----- Starting create_newcase -----\n'

    # Base arguments
    args=" --case ${CASE_NAME} \
        --output-root ${CASE_ROOT} \
        --script-root ${CASE_SCRIPTS_DIR} \
        --handle-preexisting-dirs u \
        --compset ${COMPSET} \
        --res ${RESOLUTION} \
        --machine ${MACHINE} \
        --compiler ${COMPILER} \
        --walltime ${WALLTIME} \
        --pecount ${PELAYOUT}"

    # Oprional arguments
    if [ ! -z "${PROJECT}" ]; then
      args="${args} --project ${PROJECT}"
    fi
    if [ ! -z "${CASE_GROUP}" ]; then
      args="${args} --case-group ${CASE_GROUP}"
    fi
    if [ ! -z "${QUEUE}" ]; then
      args="${args} --queue ${QUEUE}"
    fi

    ${CODE_ROOT}/cime/scripts/create_newcase ${args}

    if [ $? != 0 ]; then
      echo $'\nNote: if create_newcase failed because sub-directory already exists:'
      echo $'  * delete old case_script sub-directory'
      echo $'  * or set do_newcase=false\n'
      exit 35
    fi

}

#-----------------------------------------------------
case_setup() {

    if [ "${do_case_setup,,}" != "true" ]; then
        echo $'\n----- Skipping case_setup -----\n'
        return
    fi

    echo $'\n----- Starting case_setup -----\n'
    pushd ${CASE_SCRIPTS_DIR}

    # Setup some CIME directories
    ./xmlchange EXEROOT=${CASE_BUILD_DIR}
    ./xmlchange RUNDIR=${CASE_RUN_DIR}

    # Short term archiving
    ./xmlchange DOUT_S=${DO_SHORT_TERM_ARCHIVING^^}
    ./xmlchange DOUT_S_ROOT=${CASE_ARCHIVE_DIR}
    ./xmlchange PIO_NETCDF_FORMAT="64bit_data"
    # Extracts input_data_dir in case it is needed for user edits to the namelist later
    local input_data_dir=`./xmlquery DIN_LOC_ROOT --value`

    # Custom user_nl
    user_nl

    # Finally, run CIME case.setup
    ./case.setup --reset

    popd
}

#-----------------------------------------------------
case_build() {

    pushd ${CASE_SCRIPTS_DIR}

    # do_case_build = false
    if [ "${do_case_build,,}" != "true" ]; then

        echo $'\n----- case_build -----\n'

        if [ "${OLD_EXECUTABLE}" == "" ]; then
            # Ues previously built executable, make sure it exists
            if [ -x ${CASE_BUILD_DIR}/e3sm.exe ]; then
                echo 'Skipping build because $do_case_build = '${do_case_build}
            else
                echo 'ERROR: $do_case_build = '${do_case_build}' but no executable exists for this case.'
                exit 297
            fi
        else
            # If absolute pathname exists and is executable, reuse pre-exiting executable
            if [ -x ${OLD_EXECUTABLE} ]; then
                echo 'Using $OLD_EXECUTABLE = '${OLD_EXECUTABLE}
                cp -fp ${OLD_EXECUTABLE} ${CASE_BUILD_DIR}/
            else
                echo 'ERROR: $OLD_EXECUTABLE = '$OLD_EXECUTABLE' does not exist or is not an executable file.'
                exit 297
            fi
        fi
        echo 'WARNING: Setting BUILD_COMPLETE = TRUE.  This is a little risky, but trusting the user.'
        ./xmlchange BUILD_COMPLETE=TRUE

    # do_case_build = true
    else

        echo $'\n----- Starting case_build -----\n'

        # Turn on debug compilation option if requested
        if [ "${DEBUG_COMPILE^^}" == "TRUE" ]; then
            ./xmlchange DEBUG=${DEBUG_COMPILE^^}
        fi

        # Run CIME case.build
        ./case.build

        # Some user_nl settings won't be updated to *_in files under the run directory
        # Call preview_namelists to make sure *_in and user_nl files are consistent.
        ./preview_namelists

    fi

    popd
}

#-----------------------------------------------------
runtime_options() {

    echo $'\n----- Starting runtime_options -----\n'
    pushd ${CASE_SCRIPTS_DIR}

    # Set simulation start date
    if [ ! -z "${START_DATE}" ]; then
        ./xmlchange RUN_STARTDATE=${START_DATE}
    fi
    if [ ! -z "${START_TIME}" ]; then
        ./xmlchange START_TOD=${START_TIME}
    fi    
    ./atmchange initial_conditions::Filename=/usr/gdata/climdat/eamxx-ml/init/screami_ne30np4128_remapped_from_ne120np4L128_20230215.nc
    ./atmchange vtheta_thresh=200
    # Segment length
    ./xmlchange STOP_OPTION=${STOP_OPTION,,},STOP_N=${STOP_N}

    # Restart frequency
    ./xmlchange REST_OPTION=${REST_OPTION,,},REST_N=${REST_N}
    ./atmchange Scorpio::model_restart::output_control::frequency_units=${REST_OPTION} \
                Scorpio::model_restart::output_control::Frequency=${REST_N}

    # Coupler history
    ./xmlchange HIST_OPTION=${HIST_OPTION,,},HIST_N=${HIST_N}

    # Coupler budgets (always on)
    ./xmlchange BUDGETS=TRUE
    ./xmlchange JOB_WALLCLOCK_TIME=${WALLTIME}
    ./xmlchange JOB_QUEUE=${QUEUE}

    cat <<EOF >> user_nl_elm
    finidat='/usr/gdata/climdat/eamxx-ml/init/lnd/t.se62-mar27.F2010-SCREAMv1.ne120pg2_ne120pg2.pm-gpu.n085t4xX.L128.vth200.elm.r.0004-07-01-00000-ne30pg2-regrid.nc'
    hist_nhtfrq = 0,-168
    hist_mfilt  = 1,1
    hist_fincl2 = 'SOILWATER_10CM'
EOF


    # Set resubmissions
    if (( RESUBMIT > 0 )); then
        ./xmlchange RESUBMIT=${RESUBMIT}
    fi

    # Run type
    # Start from default of user-specified initial conditions
    if [ "${MODEL_START_TYPE,,}" == "initial" ]; then
        ./xmlchange RUN_TYPE="startup"
        ./xmlchange CONTINUE_RUN="FALSE"

    # Continue existing run
    elif [ "${MODEL_START_TYPE,,}" == "continue" ]; then
        ./xmlchange CONTINUE_RUN="TRUE"

    elif [ "${MODEL_START_TYPE,,}" == "branch" ] || [ "${MODEL_START_TYPE,,}" == "hybrid" ]; then
        ./xmlchange RUN_TYPE=${MODEL_START_TYPE,,}
        ./xmlchange GET_REFCASE=${GET_REFCASE}
	./xmlchange RUN_REFDIR=${RUN_REFDIR}
        ./xmlchange RUN_REFCASE=${RUN_REFCASE}
        ./xmlchange RUN_REFDATE=${RUN_REFDATE}
        echo 'Warning: $MODEL_START_TYPE = '${MODEL_START_TYPE}
	echo '$RUN_REFDIR = '${RUN_REFDIR}
	echo '$RUN_REFCASE = '${RUN_REFCASE}
	echo '$RUN_REFDATE = '${START_DATE}

    else
        echo 'ERROR: $MODEL_START_TYPE = '${MODEL_START_TYPE}' is unrecognized. Exiting.'
        exit 380
    fi

    # Change output stream yaml files if requested
    if [ ! -z "${OUTPUT_YAML_FILES}" ]; then
        ./atmchange output_yaml_files="${OUTPUT_YAML_FILES}"
    fi
    # Change options for nudging
    ./atmchange physics::atm_procs_list="mac_aero_mic,rrtmgp,mlcorrection"
    ./case.setup
    ./atmchange mlcorrection::ML_model_path_tq=/usr/gdata/climdat/eamxx-ml/vcm-scream/sample-trained-ML-model/2023-12-13-tq-tendencies-5bba84c4e149/tapering
    ./atmchange mlcorrection::ML_model_path_uv=NONE
    ./atmchange mlcorrection::ML_model_path_sfc_fluxes=NONE
    ./atmchange mlcorrection::ML_output_fields=T_mid,qv,u,v
    ./atmchange mlcorrection::compute_tendencies=T_mid,qv,horiz_winds
    ./atmchange physics::compute_tendencies=T_mid,qv,horiz_winds
    popd
}

#-----------------------------------------------------
case_submit() {

    if [ "${do_case_submit,,}" != "true" ]; then
        echo $'\n----- Skipping case_submit -----\n'
        return
    fi

    echo $'\n----- Starting case_submit -----\n'
    pushd ${CASE_SCRIPTS_DIR}

    # Run CIME case.submit
    ./case.submit

    popd
}

#-----------------------------------------------------
copy_script() {

    echo $'\n----- Saving run script for provenance -----\n'

    local script_provenance_dir=${CASE_SCRIPTS_DIR}/run_script_provenance
    mkdir -p ${script_provenance_dir}
    local this_script_name=`basename $0`
    local script_provenance_name=${this_script_name}.`date +%Y%m%d-%H%M%S`
    cp -vp ${this_script_name} ${script_provenance_dir}/${script_provenance_name}

}

#-----------------------------------------------------
# Silent versions of popd and pushd
pushd() {
    command pushd "$@" > /dev/null
}
popd() {
    command popd "$@" > /dev/null
}

# Now, actually run the script
#-----------------------------------------------------
main
