from os import path, remove
import re
from typing import Union


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
    # A list to indicate what type of list is at each level.
    # e.g. ['ul', 'ol', ...] indicates:
    # 1st level is an unordered list
    # 2nd level is an ordered list
    list_type = []

    def __init__(self, content: str = None, string: bool = False):
        """
        Parse a markdown document or string into its HTML equivalent.

        :param content: The path of the file, or a string, to be parsed. Works in
            conjunction with the `string` boolean flag.
        :param string: Boolean flag to specify whether a user has passed a filename
            or a string.
        :raises: A `ValueError` if no filename and no content has been provided to parse.
        :raises: A `FileNotFoundError` if the filename provided does not exist.
        """
        if not content:
            raise ValueError("No file or content have been provided.")
        if not string:
            if not path.exists(content):
                raise FileNotFoundError("The file provided was not found.")

        self.html_elements = []
        self.raw_html = f'<!DOCTYPE html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="author" content="Marios Yiannakou">\n<meta name="description" content="This is a markdown parser to HTML created for my COMP30040 module at the University of Manchester.">\n</head>\n<body>\n'
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

        self.raw_html += f"\n</body>\n</html>\n"

        print(self.raw_html)
        # parsed_content_filename = "parsed.html"
        # try:
        #     with open(parsed_content_filename, "w") as file:
        #         file.write(self.raw_html)
        # except Exception as e:
        #     print(f"Exception occured while writing to file ... printing to standard out")
        #     print(self.raw_html)
        #     if path.exists(parsed_content_filename):
        #          remove(parsed_content_filename)
        # TODO: Format with prettier?

    def parse_content(self, content: str) -> None:
        """
        Reads and parses the provided content into HTML.

        :param content: A string to be parsed with markdown rules.
        :returns: The parsed content as HTML.
        """
        # TODO: regex *[a-zA-Z0-9]*\n, remove only last \n
        #       Splitting on "\n" might have unwanted consequences
        for line in content.split("\n"):
            if line.strip() == "":
                self.previous_line = ""
                continue

            if self.previous_line == "" and self.html_elements:
                self.raw_html += f"\n</{self.html_elements.pop()}>\n"

            special_characters = self.get_special_characters(line)
            if not special_characters:
                if not self.previous_line or self.previous_line == "":
                    self.raw_html += f"<p>"
                    self.html_elements.append("p")
                self.raw_html += f"\n{line}"
            else:
                self.parse_special_characters(line, special_characters)

            self.previous_line = line

        while self.html_elements:
            self.raw_html += f"\n</{self.html_elements.pop()}>"

    def parse_special_characters(self, line: str, matched_regex: re.Match) -> None:
        """
        Parse the given line with special characters into HTML.

        :param line: The line to be parsed.
        :param matched_regex: The regex that was matched.
        """
        if len(matched_regex) == 0:
            return

        closing_tag = None
        regex = matched_regex.pop(0)
        # Starting and ending (non-inclusive) index of special characters in `line`
        span_start, span_end = regex.span()
        special_chars = regex.string[span_start:span_end]
        special_chars_length = len(special_chars)

        if (
            special_chars[0] == "#"
            and line.strip()[0] == "#"
            and line.strip()[special_chars_length:][0] == " "
        ):
            tag = "<h6>" if special_chars_length >= 6 else f"<h{special_chars_length}>"
            self.raw_html += tag
            closing_tag = (
                "</h6>\n"
                if special_chars_length >= 6
                else f"</h{special_chars_length}>\n"
            )

        elif special_chars[0] == "*":
            # Pop the matched regex again as patterns that require opening and closing
            # patterns produce two matching elements, and are displayed twice
            # e.g. Bold --> **text to make bold** (requires '**' at the start and ending)
            # If there is no matching regex at the end, treat as normal text and print it.
            if len(matched_regex):
                regex = self.validate_regex(regex, matched_regex.pop(0))
                if not regex:
                    self.append_invalid_regex(line)
                    return
            else:
                self.append_invalid_regex(line)
                return

            content_length = regex.span()[0] - span_start
            content = line[special_chars_length:content_length].strip()

            # Don't add a new line at the end as these could be inline.
            if special_chars_length == 1:
                self.raw_html += f"<i>{content}</i>"
            elif special_chars_length == 2:
                self.raw_html += f"<b>{content}</b>"
            elif special_chars_length == 3:
                self.raw_html += f"<b><i>{content}</i></b>"

        elif special_chars[0] == "_":
            if special_chars_length > 1 or len(matched_regex) == 0:
                self.append_invalid_regex(line)
                return
            else:
                regex = self.validate_regex(regex, matched_regex.pop(0))
                if not regex:
                    self.append_invalid_regex(line)
                    return

            content_length = regex.span()[0] - span_start
            content = line[special_chars_length:content_length].strip()

            self.raw_html += f'<p style="text-decoration: underline;">{content}</p>'

        elif special_chars[0] == "!":
            regex = [match for match in re.finditer(r"\!\[.*?\]\(.*?\)", line)]
            if regex:
                alt_text, src = regex[0].group().split("](")
                alt_text = alt_text[2:]
                src = src[:-1]
                self.raw_html += f'<img src="{src}" alt="{alt_text}"/>'
                self.html_elements.append("p")

                line = line[regex[0].span()[1] :]
                # Since URLs have some of the special characters that the markdown
                # parser understands, it's required that after parsing the URL, the
                # link is removed from the line and the `matched_regex` list is
                # redefined here.
                matched_regex = self.get_special_characters(line)
                regex = None
            else:
                self.append_invalid_regex(line)

        elif special_chars[0] == "[":
            regex = [match for match in re.finditer(r"\[.*?\]\(.*?\)", line)]
            if regex:
                text, src = regex[0].group().split("](")
                text = text[1:]
                src = src[:-1]
                self.raw_html += f'<p>\n{line[:span_start]}<a href="{src}">{text}</a>'
                self.html_elements.append("p")

                line = line[regex[0].span()[1] :]
                # Since URLs have some of the special characters that the markdown
                # parser understands, it's required that after parsing the URL, the
                # link is removed from the line and the `matched_regex` list is
                # redefined here.
                matched_regex = self.get_special_characters(line)
                regex = None
            else:
                self.append_invalid_regex(line)

        else:
            self.append_invalid_regex(line)

        # Send the substring that contains more markdown content to be parsed again
        # e.g. # An h1 header with **bold text**
        if len(matched_regex):
            next_regex_start, _ = matched_regex[0].span()
            self.raw_html += line[span_end:next_regex_start]
            self.parse_special_characters(line[next_regex_start:], matched_regex)
            matched_regex = []
        elif regex:
            self.raw_html += line[regex.span()[1] :]
        else:
            self.raw_html += line

        # Some regexes might finish before the actual line does thus,
        # `closing_tag` might be `None`
        # e.g. # This line is an h1 header with ***bold and italic text*** and more normal text
        #      </i></b> closes before the end of the line so `closing_tag` is `None`.
        if closing_tag:
            self.raw_html += closing_tag

    def validate_regex(
        self, current_regex: re.Match, popped_regex: re.Match
    ) -> Union[re.Match, None]:
        """
        Validates that the popped regex matches the current regex to ensure that both
        special characters are of the same type.

        e.g. **this is bold**   is valid
             **this is bold*    is invalid

        :param current_regex: The regex to be matched against.
        :param popped_regex: The regex currently under evaluation.
        :returns: The `popped_regex` if it's a match, `None` otherwise.
        """
        if str(current_regex.group()) == str(popped_regex.group()):
            return popped_regex

    def append_invalid_regex(self, line: str) -> None:
        """
        Appends an invalid regex as a plain text line.

        e.g. **This line is bold
             This line is italic*

        will result in

        <p>
        **This line is bold
        This line is italic*
        </p>

        :param line: The line to append to the parsed content.
        """
        # Only append the <p> element if the latest one is not already a <p> element.
        if (
            not self.html_elements
            or self.html_elements[len(self.html_elements) - 1] != "p"
        ):
            self.raw_html += f"<p>\n{line}"
            self.html_elements.append("p")
        else:
            self.raw_html += f"\n{line}"

    def get_special_characters(self, string: str):
        """
        Uses a predefined regular expression to capture any special characters from the
        provided string and returns them as a list of `re.Match` elements.

        :param string: The string to extract the special characters from.
        :returns: A list of `re.Match` elements representing all the matched special
            charaters found in `string`.
        """
        pattern = r"[^a-zA-Z0-9 '\"./:?]*"
        return [match for match in re.finditer(pattern, string) if match.group()]


parser = MarkdownParser(
    """This is a multiline input
to be parsed in the markdown parser

# *This line should be an h1 header with italic text*
#### This line should be an h4 header
####### This line should be an h6 header
**this line should be bold**
*this line should be italic*
# This line should be an h1 header with ***bold and italic text*** with more normal text outside
_This line should be underlined_

This should be a normal line with just **this text** as bold and *this* as italic.

And this is a completely random sentence that spans over multiple lines to check if the p element
understands that a single return between body text should not result in a new paragraph

**This line should not be bold and keep the stars
*This line should not be italic and keep the star

_This line should not be underlined and keep the underscore

__This line should not be underlined neither, and keep both the underscores__

This line should contain a hyperlink to [Google.com](https://www.google.com).

This line should have an **image** of a muffin ![muffin time](https://static.wikia.nocookie.net/asdfmovie/images/1/1d/Muffin.png/revision/latest/scale-to-width-down/148?cb=20180617145555) with alternate text 'muffin time'.""",
    True,
)
