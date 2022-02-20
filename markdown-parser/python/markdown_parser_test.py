# Mock sys.argv -- https://stackoverflow.com/questions/18668947/how-do-i-set-sys-argv-so-i-can-unit-test-it
import sys
from unittest.mock import patch

import markdown_parser as md
import pytest


@pytest.mark.parametrize(
    "flags",
    [
        ["--help"],
        ["--raw"],
        ["--prettify"],
        ["--stdout"],
        ["--demo"],
        ["--help", "--raw", "--prettify", "--stdout", "--demo"],
    ],
)
def test_parse_args(flags):
    with patch.object(sys, "argv", flags):
        for flag in flags:
            assert flag in sys.argv
