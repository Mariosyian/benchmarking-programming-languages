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
    ],
)
def test_parse_args(flags):
    with patch.object(sys, "argv", flags):
        for flag in flags:
            assert flag in sys.argv


# def test_help_message_is_displayed(capsys):
#     message = """
# Shaved down version of the Common Mark markdown parser created as part of COMP30040.
# This version was written for Python3.

# usage: python markdown_parser.py <path/to/file> [--help] [--raw <markdown string>]
#                                                 [--prettify] [--stdout] [--demo]

# <path/to/file>: The file that contains markdown code. Ignored if the `--raw` flag is
#                 used. Must be the first argument.

# --help: Display this help message and exit.
# --raw: Provide a raw string of markdown content to be parsed into HTML.
# --prettify: Prettify the output using BeautifulSoup4.
# --stdout: Print the resulting HTML code to standard out instead of a file.
# --demo: Uses a predefined raw string (implies the `--raw` flag) that uses all features
#         of the markdown parser.

# Example usage:
# - Raw string
# python markdown_parser.py --raw "# An h1 header with *bold text*." --stdout
# - File
# python markdown_parser.py ./markdown.md --prettify

# Exit Codes:
# 0 - OK
# 1 - Erroneous input

# Author: Marios Yiannakou, GitHub: @Mariosyian"""

#     with patch.object(sys, "argv", "--help"):
#         with patch.object(md, "__name__", "__main__"):
#             assert "--help" in sys.argv
#             runpy.run_module(
#                 "markdown_parser",
#             )
#             assert capsys.readouterr().out == message


def test_that_program_exits_with_code_1_when_no_content_and_no_string(capsys):
    message = "No file was provided.\n"
    with pytest.raises(SystemExit) as exit_code:
        md.MarkdownParser("", False)

    assert exit_code.value.code == 1
    captured = capsys.readouterr()
    assert captured.out == message


def test_that_program_exits_with_code_1_when_no_content_but_string(capsys):
    message = "No markdown string was provided.\n"
    with pytest.raises(SystemExit) as exit_code:
        md.MarkdownParser("", True)

    assert exit_code.value.code == 1
    captured = capsys.readouterr()
    assert captured.out == message


def test_that_program_exits_with_code_1_when_content_but_no_string(capsys):
    message = "The file provided was not found.\n"
    with pytest.raises(SystemExit) as exit_code:
        md.MarkdownParser("Hello there!", False)

    assert exit_code.value.code == 1
    captured = capsys.readouterr()
    assert captured.out == message


@pytest.mark.parametrize(
    "markdown_html",
    [
        [
            "**this is bold**",
            f"<b>this is bold</b>",
        ],
        [
            "*this is italic*",
            f"<i>this is italic</i>",
        ],
        [
            "***this is both***",
            f"<b><i>this is both</i></b>",
        ],
        [
            "#### This should be an h4 header",
            f"<h4> This should be an h4 header</h4>\n",
        ],
        [
            "_This should be underlined_",
            f'<p style="text-decoration: underline;">This should be underlined</p>',
        ],
        [
            "This should be normal text",
            f"<p>\nThis should be normal text\n</p>",
        ],
        [
            "[Foo-Bar](foo.bar)",
            f'<a href="foo.bar">Foo-Bar</a>',
        ],
        [
            "> This is a blockquote\n> This is the same blockquote",
            f"<blockquote>\n<p> This is a blockquote</p>\n<p> This is the same blockquote</p>\n\n</blockquote>",
        ],
        [
            "- This is the first item in an unordered list.\n- This is the second item in an unordered list.",
            f"<ul>\n<li> This is the first item in an unordered list.</li>\n<li> This is the second item in an unordered list.</li>\n\n</ul>",
        ],
        [
            "+ This is the first item in an ordered list.\n+ This is the second item in an ordered list.",
            f"<ol>\n<li> This is the first item in an ordered list.</li>\n<li> This is the second item in an ordered list.</li>\n\n</ol>",
        ],
        [
            "![woohoo](image)",
            f'<img src="image" alt="woohoo"/>',
        ],
        [
            "with more random text\nbut this spans across two lines",
            f"<p>\nwith more random text\nbut this spans across two lines\n</p>",
        ],
        [
            "more random text but with **bold** and *italic* in the middle",
            f"<p>\nmore random text but with <b>bold</b> and <i>italic</i> in the middle\n</p>",
        ],
        [
            """
                **this is bold**
                *this is italic*
                ***this is both***

                #### This should be an h4 header

                _This should be underlined_

                This should be normal

                [Foo-Bar](foo.bar)

                > This is a blockquote

                - This is a single item unordered list.

                + This is a single item ordered list.

                ![woohoo](image)
            """,
            '<b>this is bold</b><i>this is italic</i><b><i>this is both</i></b><h4> This should be an h4 header</h4>\n<p style="text-decoration: underline;">This should be underlined</p><p>\nThis should be normal\n</p>\n<a href="foo.bar">Foo-Bar</a><blockquote>\n<p> This is a blockquote</p>\n\n</blockquote>\n<ul>\n<li> This is a single item unordered list.</li>\n\n</ul>\n<ol>\n<li> This is a single item ordered list.</li>\n\n</ol>\n<img src="image" alt="woohoo"/>',
        ],
    ],
)
def test_that_the_parser_produces_the_correct_html_and_prints_to_stdout(
    markdown_html, capsys
):
    markdown, parsed_html = markdown_html
    html = f'<!DOCTYPE html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="author" content="Marios Yiannakou">\n<meta name="description" content="This is a markdown parser to HTML created for my COMP30040 module at the University of Manchester.">\n</head>\n<body>\n{parsed_html}\n</body>\n</html>'
    md.MarkdownParser(markdown, True, False, True)
    assert capsys.readouterr().out.strip() == html.strip()


def test_that_the_parser_produces_the_correct_html_and_prints_to_stdout_with_prettify(
    capsys,
):
    markdown = "**this is bold**"
    parsed_html = f"  <b>\n   this is bold\n  </b>"
    html = f'<!DOCTYPE html>\n<html lang="en">\n <head>\n  <meta charset="utf-8"/>\n  <meta content="Marios Yiannakou" name="author"/>\n  <meta content="This is a markdown parser to HTML created for my COMP30040 module at the University of Manchester." name="description"/>\n </head>\n <body>\n{parsed_html}\n </body>\n</html>'
    md.MarkdownParser(markdown, True, True, True)
    assert capsys.readouterr().out.strip() == html.strip()


@pytest.mark.parametrize(
    "markdown_html",
    [
        [
            "**this is not bold*",
            f"<p>\n**this is not bold*\n</p>",
        ],
        [
            "*this is not italic",
            f"<p>\n*this is not italic\n</p>",
        ],
        [
            "***this is not both",
            f"<p>\n***this is not both\n</p>",
        ],
        [
            "****this should be invalid****",
            f"<p>\n****this should be invalid****\n</p>",
        ],
        [
            "_This should not be underlined",
            f"<p>\n_This should not be underlined\n</p>",
        ],
        [
            "__This should not be underlined__",
            f"<p>\n__This should not be underlined__\n</p>",
        ],
        [
            "_This should not be underlined*",
            f"<p>\n_This should not be underlined*\n</p>",
        ],
        [
            "[Foo-Bar(foo.bar)",
            f"<p>\n[Foo-Bar(foo.bar)\n</p>",
        ],
        [
            "![woohoo]image)",
            f"<p>\n![woohoo]image)\n</p>",
        ],
    ],
)
def test_that_the_parser_catches_invalid_markdown(markdown_html, capsys):
    markdown, parsed_html = markdown_html
    html = f'<!DOCTYPE html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="author" content="Marios Yiannakou">\n<meta name="description" content="This is a markdown parser to HTML created for my COMP30040 module at the University of Manchester.">\n</head>\n<body>\n{parsed_html}\n</body>\n</html>'
    md.MarkdownParser(markdown, True, False, True)
    assert capsys.readouterr().out.strip() == html.strip()


def test_that_the_parser_treats_unknown_special_characters_as_invalid_markdown(capsys):
    markdown = "£"
    parsed_html = f"<p>\n£\n</p>"
    html = f'<!DOCTYPE html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="author" content="Marios Yiannakou">\n<meta name="description" content="This is a markdown parser to HTML created for my COMP30040 module at the University of Manchester.">\n</head>\n<body>\n{parsed_html}\n</body>\n</html>'
    md.MarkdownParser(markdown, True, False, True)
    assert capsys.readouterr().out.strip() == html.strip()
