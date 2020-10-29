#!/Users/Esh/anaconda3/bin/python
from subprocess import check_output
import argparse
from pathlib import Path
import pandas as pd
from pandas_profiling import ProfileReport

parser = argparse.ArgumentParser(
    "Generate an overview report of a csv file using pandas_profiling.\nWill create an html file in the current directory with the same name as the input csv file."
)
parser.add_argument("input_file", type=str, help="csv file to generate a report for")
args = parser.parse_args()


def make_report(path, out_name):
    df = pd.read_csv(str(f))
    profile = ProfileReport(df, title=name)
    profile.to_file(f"{out_name}")
    print(f"Report saved to {out_name}")


f = Path(args.input_file)
name = f.name.split(".")[0]
out = f"{name}.html"
if Path(out).exists():
    valid_resp = False
    while not valid_resp:
        resp = input(f"{out} already exists. Overwrite? (y) or (n) ")
        if resp == "y":
            valid_resp = True
            make_report(f, out)
        elif resp == "n":
            valid_resp = True
            print("Opening existing report")
        else:
            print("Please input y or n only!")
else:
    make_report(f, out)
check_output(f"open {out}", shell=True)
