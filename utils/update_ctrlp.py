import subprocess

commands = ["CtrlPClearAllCaches", "CtrlP /Users/silver", "qall"]
echoes = "; ".join(["echo"] + ["echo :" + cmd for cmd in commands])
subprocess.call("(%s) | /usr/bin/vim" % echoes, shell=True)
