#!/Users/esh/miniconda3/bin/python
"""
Scaffold a project directory quickly and put it under version control with reasonable defaults.
"""

import os
from subprocess import check_output, STDOUT
import argparse


def sys_call(str):
    return check_output(str, shell=True, stderr=STDOUT)


parser = argparse.ArgumentParser(
    description="script to auto-generate project structure."
)
parser.add_argument(
    "--base_dir", help="Where to initialize project. Defaults to cwd.", required=False
)
parser.add_argument("--name", help="Project name.", required=True)
args = parser.parse_args()
if not args.base_dir:
    base_dir = os.getcwd()
else:
    base_dir = args.base_dir
if not args.name:
    parser.error("Need a project name!")
else:
    project_name = args.name

abs_project_path = os.path.join(base_dir, project_name)

# Make dir structure
print("Setting up project...")
call_string = (
    f"mkdir -p {abs_project_path}/analysis {abs_project_path}/data {abs_project_path}/papers "
    f"{abs_project_path}/presentations {abs_project_path}/code {abs_project_path}/figures "
    f"{abs_project_path}/paradigms {abs_project_path}/.vscode;"
)
sys_call(call_string)

# Create a README file
readme = open(os.path.join(abs_project_path, "README.md"), "w")
readme.write(
    f"""
# {project_name}


---
## Python environment setup
The environment.yml file in this repo can be used to bootstrap a conda environment for
reproducibility:\n
`conda env create -p ./env -f environment.yml`\n

To update the environment file after installing/removing packages: `conda env export --no-builds -f environment.yml`\n\n

To update the environment itself after editing the `environment.yml` file: `conda env update --file environment.yml --prune`\n
             """
)
readme.close()

# Create a gitignore file
ignore_file = open(os.path.join(abs_project_path, ".gitignore"), "w")
ignore_file.write("*.DS_Store\n")
ignore_file.write("*.ipynb_checkpoints\n")
ignore_file.write("*.pyc\n")
ignore_file.write("#Don't commit actual conda env\n")
ignore_file.write("env\n")
ignore_file.write("#Don't commit data, figs, or presentations by default\n")
ignore_file.write("*.csv\n")
ignore_file.write("*.txt\n")
ignore_file.write("*.png\n")
ignore_file.write("*.jpg\n")
ignore_file.write("*.jpeg\n")
ignore_file.write("*.ppt*\n")
ignore_file.write("*.key\n")
ignore_file.close()

# Vscode settings file
vscode_file = open(os.path.join(abs_project_path, ".vscode", "settings.json"), "w")
vscode_file.write("{\n")
vscode_file.write(
    '\t"python.defaultInterpreterPath": "${workspaceFolder}/env/bin/python",\n'
)
vscode_file.write('\t"python.terminal.activateEnvironment": true,\n')
vscode_file.write('\t"editor.formatOnSave": true,\n')
vscode_file.write('\t"python.analysis.extraPaths": ["${workspaceFolder}/code"]\n')
vscode_file.write("}")
vscode_file.close()

# CD to project dir
os.chdir(abs_project_path)
# Create gitkeep files to commit empty dir structure
call_string = r"find * -type d -not -path '*/\.*' -exec touch {}/.gitkeep \;"
sys_call(call_string)
# Initialize repo
sys_call("git init")
# Add stuff
git_add_call_string = "git add .gitignore README.md .vscode analysis code data figures papers paradigms presentations"

# Conda environment
setup_py = input("Setup python environment? (y): ") or "y"
if setup_py == "y":
    py_version = input("Python version? (3.8): ") or "3.8"
    setup_precommit = input("Setup environment check pre-commit hook? (y): ") or "y"
    print("Setting up environment...")
    call_string = f"conda create -y -p ./env python={py_version} pip ipykernel"
    sys_call(call_string)
    call_string = f"conda run -p ./env pip install --upgrade pycodestyle black flake8"
    sys_call(call_string)
    call_string = f"conda run -p ./env conda env export --no-builds -f environment.yml"
    sys_call(call_string)

    git_add_call_string += " environment.yml"

# Perform initial commit
sys_call(git_add_call_string)
call_string = "git commit -m 'Initial project commit.'"
sys_call(call_string)

if setup_precommit:
    print("Setting up pre-commit hook ...")
    sys_call(
        "cp /Users/Esh/Documents/cmd_programs/check_env.sh ./.git/hooks/pre-commit"
    )

# Messages
print(f"New project folder and repo created in:\n\n {abs_project_path}")
if setup_py:
    print(
        """\nNew python environment created in ./env with environment.yml packages\n\nYou can activate this environment in a terminal using: conda activate ./env\n"""
    )
