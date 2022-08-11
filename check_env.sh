#!/bin/bash

# Quick bash script that adds some package.json like behavior to managing anaconda environment files. The intended use case is from within a project dir with a conda environment *ALREADY ACTIVATED*.

# Simply run ./check_env.sh or add it as a git pre-commit hook.
# It will check for the existence of the following two files and diff them if they exist or create and git add them if they don't. From then on you can version control these files. Simply rerun this script anytime you conda install/uninstall/update anything to keep track of your environment changes.
# You can recreate your current environment using: conda env create -f env.yml
ENV_FILE='environment.yml'

# Ensure the user doesn't accidentally run this from a shell in which is the base environment is active
CURRENT_ENV=$(echo "$CONDA_DEFAULT_ENV")
if [ "$CURRENT_ENV" != "base" ]; then
    echo "The conda env check pre-commit hook needs to be run from your base conda env. Deactivate any environments and try again"
    exit 1
fi

# If both the environment revisions file already exist then diff them
if [ -f "$ENV_FILE" ]; then
    echo "Checking environment.yml against conda environment for changes since last commit..."

    # Get current environment revision list
    CONDA_YAML=$(conda run -p ./env conda env export --no-builds)

    # Get diff with existing files
    DIFF=$(echo "$CONDA_YAML" | git diff --no-index -- "$ENV_FILE" -)

    if [ "$DIFF" != "" ]; then
        echo "Changes found...updating and staging $ENV_FILE"
        echo "$CONDA_YAML" >"$ENV_FILE"
        git add "$ENV_FILE"
        echo "Rerun your last git commit command to save changes"
        exit 1
    else
        echo "No changes found...proceeding with commit"
        exit 0
    fi
else
    # Create the environment and revisions file for the first time
    if [ ! -f "$ENV_FILE" ]; then
        echo 'no env file found creating...'
        conda env export --no-builds -f "$ENV_FILE"
        git add "$ENV_FILE"
        echo "Rerun your last git commit command to save changes"
        exit 1
    fi

fi

