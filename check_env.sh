#!/bin/bash

# Quick bash script that adds some package.json like behavior to managing anaconda environment files. The intended use case is from within a project dir with a conda environment *ALREADY ACTIVATED*.

# Simply run ./check_env.sh or add it as a git pre-commit hook.
# It will check for the existence of the following two files and diff them if they exist or create and git add them if they don't. From then on you can version control these files. Simply rerun this script anytime you conda install/uninstall/update anything to keep track of your environment changes.
# You can recreate your current environment using: conda env create -f env.yml
ENV_FILE='environment.yml'
REV_FILE='environment-revisions.txt'

# Ensure the user doesn't accidentally run this from a shell in which is the base environment is active
CURRENT_ENV=$(echo "$CONDA_DEFAULT_ENV")
if [ "$CURRENT_ENV" == "base" ]; then
    echo "The base conda environment appears to be active. Use conda activate YOUR_ENV prior to running this script"
    exit 1
fi

# If both the environment revisions file already exist then diff them
if [ -f "$ENV_FILE" ] && [ -f "$REV_FILE" ]; then
    echo "Checking conda environment for changes since last commit..."

    # Get current environment revision list
    CONDA_YAML=$(conda env export)
    CONDA_REV=$(conda list --revisions)

    # Get diff with existing files
    DIFF=$(echo "$CONDA_YAML" | git diff --no-index -- "$ENV_FILE" -)
    RDIFF=$(echo "$CONDA_REV" | git diff --no-index -- "$REV_FILE" -)

    if [ "$DIFF" != "" ]; then
        echo "Changes found...updating $ENV_FILE"
        echo "$CONDA_YAML" >"$ENV_FILE"
        echo "$CONDA_REV" >"$REV_FILE"
    else
        echo "No changes found"
    fi
else
    # Create the environment and revisions file for the first time
    if [ ! -f "$ENV_FILE" ]; then
        echo 'no env file found creating...'
        conda env export -f "$ENV_FILE"
        git add "$ENV_FILE"
    fi

    if [ ! -f "$REV_FILE" ]; then
        echo 'no revisions file found creating...'
        conda list --revisions >"$REV_FILE"
        git add "$REV_FILE"
    fi
fi

exit 0
