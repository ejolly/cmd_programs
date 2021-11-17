#!/bin/zsh

# Link a separate kernel to an existing jupyter instance
# Assumes your base conda config exists within your $HOME/.zshrc file
if [ $# -eq 0 ]; then
    printf "Make jupyter aware of a python kernel in another environment.\n\nUSAGE:\nconda_link 'envname'\n'envname' should match what you pass into the 'conda activate' command\n\nTo remove an installed kernel run:\njupyter kernelspec remove 'envname'.\n\nTo see a list of installed kernels run:\njupyter kernelspec list\n\nAssumes that conda configuration was setup in $HOME/.zshrc if you're using zsh as your shell or $HOME/.bashrc if you're using bash as your shell. This should be true if you installed conda via the Anaconda commandline installer.\n"
else
    source "$HOME/.zshrc"
    envexists=$(conda env list | grep "$1")
    if [[ "$envexists" ]]; then
        conda activate "$1"
        out=$(python -m ipykernel install --user --name "$1")
        if [[ $? != 0 ]]; then
            printf "Linking failed. You probably need to install ipykernel within the environment you want to link:\nconda activate $1\nconda install ipykernel\n"
        elif [[ "$out" ]]; then
            echo "$out"
        fi
        conda deactivate
    else
        printf "$1 environment not found. Are you sure it exists?\nVerify with conda env list.\n"
        exit 1
    fi
fi
