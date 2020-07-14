"""
Quick script to sync Things 3 upcoming tasks (i.e. those with a due date) with ultralist.

Requires things.sh:
https://github.com/AlexanderWillner/things.sh

Ultralist:
brew install ultralist
https://ultralist.io/docs/basics/concepts/

"""
import subprocess
import re

# Ultralist only understands specific dates
date_dict = {
    "01": "jan",
    "02": "feb",
    "03": "mar",
    "04": "apr",
    "05": "may",
    "06": "jun",
    "07": "jul",
    "08": "aug",
    "09": "sep",
    "10": "oct",
    "11": "nov",
    "12": "dec",
}
# Get things agenda
out = subprocess.run(
    "things.sh upcoming | rg 'Recurring' -v | cut -d '|' -f1 -f2 -f3",
    shell=True,
    stdout=subprocess.PIPE,
    text=True,
    universal_newlines=True,
)
out = out.stdout.split("\n")

# Get existing tasks in ultralist
existing_tasks = subprocess.run(
    "ultralist list",
    shell=True,
    stdout=subprocess.PIPE,
    text=True,
    universal_newlines=True,
)
existing_tasks = existing_tasks.stdout.split("\n")
task_list = []
for task in existing_tasks:
    if task and len(task) > 3:
        text = re.split(r'\s{2,}', task)[-1].strip()
        task_list.append(text)

# Add things 3 tasks that don't already exist in ultralist
success = 0
ignored = 0
for item in out:
    # Handle empty strings
    if item:
        data = item.split("|")
        date = data[0]
        month = date.split("-")[1]
        month = date_dict[month]
        day = date.split("-")[2]
        project = data[1]  # not currently using this
        text = data[2].strip()
        if text not in task_list:
            result = subprocess.run(
                f"ultralist add {text} due {month} {day}",
                shell=True,
                stdout=subprocess.PIPE,
                text=True,
                universal_newlines=True,
            )
            if "Todo" not in result.stdout and "added" not in result.stdout:
                print(f"{result.stdout}")
                raise ValueError("Adding Things 3 todos to ultralist failed!")
            else:
                success += 1
        else:
            ignored += 1

print(f"Successfully added {success} tasks and ignored {ignored}!")

