"""
Quick script to sync Things 3 tasks with ultralist.
Pulls in all tasks from two areas: Primary and Secondary.
If the task has a deadline (not a when!) in Things 3, it will be added.

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


def things_pull():
    """Pull all tasks in Primary or Secondary from Things 3"""

    all_items = subprocess.run(
        "things.sh all | grep 'Primary\|Secondary' | grep -v 'Recurring'",
        shell=True,
        stdout=subprocess.PIPE,
        text=True,
        universal_newlines=True,
    )
    all_items = all_items.stdout.split("\n")

    upcoming = subprocess.run(
        "things.sh upcoming | rg 'Recurring' -v | cut -d '|' -f1 -f2 -f3",
        shell=True,
        stdout=subprocess.PIPE,
        text=True,
        universal_newlines=True,
    )
    upcoming = upcoming.stdout.split("\n")

    # Because the things.sh all command excludes per item due dates and the upcoming command
    # ignores items without due dates, we're merging them together here
    pruned_items = []
    for item in upcoming + all_items:
        item_dict = {}
        if item:
            data = item.split("|")
            if len(data) == 3:
                date = data[0]
                month = date.split("-")[1]
                item_dict["month"] = date_dict[month]
                item_dict["day"] = date.split("-")[2]
                item_dict["project"] = data[1]
                item_dict["text"] = data[2].strip()
            else:
                item_dict["project"] = data[0]
                item_dict["text"] = data[1].strip()

            if pruned_items:
                existing_items_text = list(map(lambda d: d["text"], pruned_items))
                if item_dict["text"] not in existing_items_text:
                    pruned_items.append(item_dict)
            else:
                pruned_items.append(item_dict)
    return pruned_items


def ul_pull():
    """Pull all tasts from ultralist"""

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
            text = re.split(r"\s{2,}", task)[-1].strip()
            if '+Primary' in text:
                text = text.split('+Primary')[-1].strip()
            elif '+Secondary' in text:
                text = text.split('+Secondary')[-1].strip()
            task_list.append(text)
    return task_list


def make_cmd(item):
    """Format a dictionary reflecting a single Things 3 item to a command for ultralist"""

    return f"ultralist add {'+' + item.get('project') if item.get('project') else ''} \"{item['text']}\" {'due ' + item.get('month') + ' ' + item.get('day') if item.get('month') else ''}"


# Add things 3 tasks that don't already exist in ultralist
success = 0
ignored = 0
things_items = things_pull()
task_list = ul_pull()
for item in things_items:
    if item["text"] not in task_list:
        cmd = make_cmd(item).strip()
        result = subprocess.run(
            cmd,
            shell=True,
            stdout=subprocess.PIPE,
            text=True,
            universal_newlines=True,
        )
        if "Todo" not in result.stdout and "added" not in result.stdout:
            print(f"{result.stdout}")
            breakpoint()
            raise ValueError("Adding Things 3 todos to ultralist failed!")
        else:
            success += 1
    else:
        ignored += 1

print(f"Successfully added {success} tasks and ignored {ignored}!")

