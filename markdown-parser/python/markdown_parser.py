from os import path
import re


class MarkdownParser:
    """
    Represents a markdown parser that abides to the CommonMark spec, but modified to
    fit what, I bleieve, is a version of the parser achievable by a beginner level
    programmer in a language of their chosing.

    @author Marios Yiannakou
    """
    # Used to keep track of multiline blocks e.g. paragraph
    previous_line = None
    # Stack to keep track of the HTML elements opened.
    html_elements = None
    # The string to contain all the parsed HTML.
    raw_html = None

    def __init__(self, content: str = None, string: bool = False):
        """
        Parse a markdown document or string into its HTML equivalent.

        :param content: The path of the file, or a string, to be parsed. Works in
            conjunction with the `string` boolean flag.
        :param string: Boolean flag to specify whether a user has passed a filename
            or a string.
        """
        if not content:
            raise ValueError("No file or content have been provided.")
        if not string:
            if not path.exists(content):
                raise FileNotFoundError("The file provided was not found.")

        self.html_elements = ["html", "body"]
        self.raw_html = f"<html>\n<head>\n<meta charset=\"utf-8\">\n<meta name=\"author\" content=\"Marios Yiannakou\">\n</head>\n<body>\n"
        self._read_file(content, string)

    def _read_file(self, filename: str, string: bool) -> None:
        """
        Open the given file in read mode and parse each line.

        :param content: The path of the file, or a string, to be parsed. Works in
            conjunction with the `string` boolean flag.
        :param string: Boolean flag to specify whether a user has passed a string to be
            parsed, or a filename.
        """
        if not string:
            with open(filename, "r") as file:
                for line in file.readlines():
                    self.parse_content(line)
        else:
            self.parse_content(filename)

        print(self.raw_html)
        # try:
        #     with open("parsed.html", "w") as file:
        #         file.write(parsed_content)
        # except Exception as e:
        #     print(f"Exception occured while writing to file\n{e}")

    def parse_content(self, content: str) -> None:
        """
        Reads and parses the provided content into HTML.

        :param content: A string to be parsed with markdown rules.
        :returns: The parsed content as HTML.
        """
        # Split the line into tokens
        # TODO: regex *[a-zA-Z0-9]*\n, remove only last \n  
        for line in content.split("\n"):
            line = line.strip()
            if line == "":
                self.previous_line = line
                continue

            special_characters = re.match(r"[^a-zA-Z0-9 '\"]*", line)
            if not special_characters:
                if not self.previous_line or self.previous_line == "":
                    self.raw_html += f"<p>"
                    self.html_elements.append("p")
                self.raw_html += f"\n{line}"
            else:
                self.parse_special_characters(line, special_characters)
            
            self.previous_line = line

            if self.previous_line == "":
                self.raw_html += f"\n</{self.html_elements.pop()}>"

        while self.html_elements:
            self.raw_html += f"\n</{self.html_elements.pop()}>"

    def parse_special_characters(self, line: str, matched_regex: re.Match) -> None:
        """
        Parse the given line with special characters into HTML.

        :param line: The line to be parsed.
        :param matched_regex: The regex that was matched.
        """
        special_characters = matched_regex.group()
        length = len(special_characters)
        if length == 0:
            return

        if special_characters[0] == "#":
            tag = "h6" if length >= 6 else f"h{length}"
            self.raw_html += f"<{tag}>{line[length:].strip()}</{tag}>"


parser = MarkdownParser(
    """This is a multiline input
to be parsed in the markdown parser

# This line should be an h1 header
**this line should be bold**""",
    True,
)
