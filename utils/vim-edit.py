#!/usr/bin/env python
import sys
import os
from neovim import attach


def main():
    # What file to edit
    curdir = os.getcwd()
    if len(sys.argv) > 1:
        filename = sys.argv[1]
    else:
        filename = ""
    fullpath = os.path.join(curdir, filename)

    # Edit in new vim or parent vim?
    address = os.environ.get("NVIM_LISTEN_ADDRESS", None)
    if address is None:
        os.system("/bin/bash -c 'vim \"{0}\"'".format(fullpath))
    else:
        nvim = attach('socket', path=os.environ["NVIM_LISTEN_ADDRESS"])
        nvim.input("<ESC><ESC>:e {0}<CR>".format(fullpath))

if __name__ == '__main__':
    main()
