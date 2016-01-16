import os
import sys
import random
from collections import Counter

HISTFILE = "{0}/.histfile".format(os.environ["HOME"])
ALPHABET = "abcdefghijklmnopqrstuvwxyz"

def count_history():
    """Return a counter containing counts of commands in history"""
    with open(HISTFILE, "rb") as histfile:
        lines_encoded = histfile.read().split(b"\n")

        counter = Counter()
        for line in lines_encoded[-1000:]:
            try:
                counter[line.decode("utf-8")] += 1
            except:
                pass
    return counter


def make_function(command):
    name = command[0] + random.choice(ALPHABET) + random.choice(ALPHABET)
    return """
function {function_name} {{
     {command}
}};
echo 'Defined shorthand: {function_name}'
""".format(function_name=name, command=command)


def main(command):
    history = count_history()
    if history[command] > 5 and len(command) > 20:
        print(make_function(command))
    else:
        print("true")


if __name__ == "__main__":
    main(sys.argv[1])
