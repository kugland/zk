import unittest
import sys
import tty
import os
import pty
from textwrap import dedent
from typing import Optional, Mapping
import unittest.util

import unittest.test


def read_until_end(fd: int) -> bytes:
    """
    Read from a file descriptor until the end and return the output.
    """

    output = b""
    while True:
        try:
            buf = os.read(fd, 1000)
            if not buf:
                break
            output += buf
        except OSError:
            break
    return output


def run(
    input: str,
    *,
    preamble: Optional[str] = None,
    sidechannel: bool = True,
    term: str = "xterm-256color",
    env: Optional[Mapping[str, str]] = None,
) -> str:
    """
    Run zsh in a pty with the given input and return the output.
    """

    input = dedent(input).strip() + "\n"

    if sidechannel:
        read, write = os.pipe()
        os.set_inheritable(write, True)

    pid, master_fd = pty.fork()
    if pid == 0:  # Child process
        # Chdir to main project directory
        os.chdir(os.path.join(os.path.dirname(__file__), ".."))

        # Set environment variables
        os.environ["PS1"] = "%% "
        os.environ["TERM"] = term
        if env:
            for key, value in env.items():
                os.environ[key] = value

        if sidechannel:
            os.close(read)

        os.execlp("zsh", "zsh", "-i", "--no-globalrcs", "--no-rcs")
    else:  # Parent process
        tty.setraw(master_fd)  # Disable echo

        if preamble:
            os.write(master_fd, preamble.encode())
            os.write(master_fd, b"\n")

        if sidechannel:
            os.close(write)
            os.write(master_fd, b"{\n")

        os.write(master_fd, input.encode())

        if sidechannel:
            os.write(master_fd, f"}} >&{write}\n".encode())
            os.write(master_fd, f"exec {write}>&-\n".encode())

        os.write(master_fd, b"exit\n")
        os.waitpid(pid, 0)

        term = read_until_end(master_fd)
        os.close(master_fd)

        if sidechannel:
            output = read_until_end(read)
            os.close(read)
        else:
            output = term

        return output.decode()
