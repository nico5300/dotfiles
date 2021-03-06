#!/usr/bin/env python3

"""
jj's pythonrc
Copyright (c) 2012-2020 Jonas Jelten <jj@sft.mx>
Licensed GPLv3 or later.
"""


# these imports are available in interactive python shells
import asyncio
import base64
import datetime
import importlib
import inspect
import io
import json
import math
import os
import pathlib
import re
import shlex
import shutil
import subprocess
import sys
import time
import traceback

from pathlib import Path
from pprint import pprint, pformat
from subprocess import call, run

try:
    # alternative for dir() to view members
    from see import see
except ImportError:
    pass

if 'bpython' not in sys.modules:
    # fancy prompt. bpython doesn't like nor need this
    # the \x01 and \x02 tell readline to ignore the chars
    sys.ps1 = '\x01\x1b[36m\x02>>>\x01\x1b[m\x02 '
    sys.ps2 = '\x01\x1b[36m\x02...\x01\x1b[m\x02 '


PAGER_INVOCATION = os.environ.get("PAGER", "less -S -i -R -M --shift 5")
HISTSIZE = 50000

USE_PYGMENTS = True
HAS_PYGMENTS = False

# convenience variables
loop = asyncio.get_event_loop()
loop.set_debug(True)


# cython on the fly compilation
try:
    import pyximport
    pyximport.install(
        build_in_temp=False,
        reload_support=True,
        inplace=True,
        language_level=sys.version_info.major
    )
except ImportError:
    pass


if USE_PYGMENTS:
    try:
        import pygments
        from pygments.formatters import TerminalFormatter
        import pygments.lexers
        HAS_PYGMENTS = True
    except ImportError:
        pass


def pager(txt):
    if not isinstance(txt, bytes):
        txt = txt.encode()
    subprocess.run(shlex.split(PAGER_INVOCATION) + ['-'], input=txt)


def pager_file(filename):
    subprocess.run(shlex.split(PAGER_INVOCATION) + [filename])


def dis(obj):
    """disassemble given stuff"""

    import dis as pydis

    output = io.StringIO()
    pydis.dis(obj, file=output)
    pager(output.getvalue())
    output.close()


if USE_PYGMENTS and HAS_PYGMENTS:
    def highlight(source):
        if not USE_PYGMENTS or not HAS_PYGMENTS:
            return source

        lexer = pygments.lexers.get_lexer_by_name('python')
        formatter = TerminalFormatter(bg='dark')
        return pygments.highlight(source, lexer, formatter)
else:
    def highlight(txt):
        return txt


def src(obj):
    """Read the source of an object in the interpreter."""
    source = highlight(inspect.getsource(obj))
    pager(source)


def loc(obj):
    """Get the definition location of give object."""
    srcfile = inspect.getsourcefile(obj)
    _, srcline = inspect.getsourcelines(obj)
    return "%s:%d" % (srcfile, srcline)


def cd(name):
    """Change the current directory to the given one."""
    os.chdir(name)


def pwd():
    """Return the current directory."""
    return os.getcwd()


def cat(name, binary=False, lines=False):
    """Read the given file and return its contents."""
    mode = "rb" if binary else "r"
    with open(name, mode) as fd:
        if lines:
            return fd.readlines()
        return fd.read()


def catln(name, binary=False):
    """Read the lines of the given file and return them."""
    return cat(name, binary, lines=True)


def ls(*args, recurse=False, merge=False):
    """
    List the current directory, or if given, all the files/directories.
    recurse: list contents recursively
    merge: don't return a dict entry for each listed, instead combine all results to one set
    """

    to_scan = list()

    if not args:
        to_scan.append(".")
    else:
        to_scan.extend(args)

    result = dict()

    if recurse:
        for inode in to_scan:
            result[inode] = os.walk(inode)
    else:
        for inode in to_scan:
            result[inode] = os.listdir(inode)

    if merge:
        if recurse:
            raise Exception("merge only available for non-recursive listings")

        result_set = set()
        for vals in result.values():
            result_set.update(vals)

        return result_set

    if len(to_scan) == 1:
        return result[to_scan[0]]

    return result


def sh(*args,check=True, **kwargs):
    """
    Execute the given commands and
    return True if the command exited with 0.
    """
    return run(args, check=check, **kwargs).returncode == 0


def _completion():
    """
    set up readline and history.
    supports parallel sessions and appends only the new history part
    to the history file.
    """
    import atexit
    import readline

    readline_statements = (
        r'"\e[A": history-search-backward',
        r'"\e[B": history-search-forward',
        r'"\e[C": forward-char',
        r'"\e[D": backward-char',
        r'"\eOd": backward-word',
        r'"\eOc": forward-word',
        r'"\e[3^": kill-word',
        r'"\C-h": backward-kill-word',
        'tab: complete',
    )

    for rlcmd in readline_statements:
        readline.parse_and_bind(rlcmd)

    history_file = (Path(os.path.expanduser('~')) /
                    (".python%d_history" % sys.version_info.major))

    if history_file.exists():
        readline.read_history_file(str(history_file))
        h_len = readline.get_current_history_length()
    else:
        h_len = 0
        with history_file.open("w") as fd:
            pass

    def save(prev_h_len, histfile):
        new_h_len = readline.get_current_history_length()
        readline.set_history_length(HISTSIZE)
        readline.append_history_file(new_h_len - prev_h_len, histfile)

    atexit.register(save, h_len, str(history_file))

    return history_file


def cororun(coro):
    """
    run the given coroutine and block until it's done
    """
    loop = asyncio.get_event_loop()
    loop.set_debug(True)
    try:
        return loop.run_until_complete(coro)
    except KeyboardInterrupt:
        print("cancelled coro run")


def looprun():
    """
    run the main eventloop forever.
    """
    loop = asyncio.get_event_loop()
    loop.set_debug(True)
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        print("cancelled loop run")


# bpython has its own completion stuff
if 'bpython' not in sys.modules:
    try:
        HISTFILE = _completion()
        del _completion
    except Exception as exc:
        sys.stderr.write("failed history and completion init: %s\n" % exc)
        import traceback
        traceback.print_exc()
        HISTFILE = None


def _fancy_displayhook(item):
    if item is None:
        return

    global _
    _ = item

    if isinstance(item, int) and not isinstance(item, bool) and item > 0:
        if item >= 2**32:
            display_text = "{0}, 0x{0:x}".format(item)
        else:
            display_text = "{0}, 0x{0:x}, 0b{0:b}".format(item)
    else:
        term_width, term_height = shutil.get_terminal_size(fallback=(80, 24))
        display_text = pformat(item, width=term_width)

    output = highlight(display_text)
    if output.endswith("\n"):
        print(output, end="")
    else:
        print(output)


# install the hook
sys.displayhook = _fancy_displayhook
del _fancy_displayhook 
