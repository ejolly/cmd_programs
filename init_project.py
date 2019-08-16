#!/usr/bin/env python
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
call_string = (
    "mkdir -p "
    + abs_project_path
    + "/{analysis,data,papers,presentations,code,figures,paradigms};"
)
sys_call(call_string)

# Create a README file
call_string = "echo '# " + project_name + "' > " + abs_project_path + "/README.md"
sys_call(call_string)

# Create a gitignore file
ignore_file = open(os.path.join(abs_project_path, ".gitignore"), "w")
ignore_file.write("*.DS_Store\n")
ignore_file.write("*.ipynb_checkpoints\n")
ignore_file.write("*.pyc\n")
ignore_file.write("#Don't commit data, figs, or presentations by default\n")
ignore_file.write("*.csv\n")
ignore_file.write("*.txt\n")
ignore_file.write("*.png\n")
ignore_file.write("*.jpg\n")
ignore_file.write("*.jpeg\n")
ignore_file.write("*.ppt*\n")
ignore_file.write("*.key\n")
ignore_file.close()

# Git
os.chdir(abs_project_path)
# Create gitkeep files to commit empty dir structure
call_string = "find * -type d -not -path '*/\.*' -exec touch {}/.gitkeep \;"
sys_call(call_string)
# Initialize, add all dirs and commit
call_string = "git init && git add * && git add .gitignore"
sys_call(call_string)
call_string = "git commit -m 'Initial project commit.'"
sys_call(call_string)
