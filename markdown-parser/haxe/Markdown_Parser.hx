/**
 * Represents a markdown parser that abides to the CommonMark spec, but modified to
 * fit what, I bleieve, is a version of the parser achievable by a beginner level
 * programmer in a language of their chosing.
 *
 * @author Marios Yiannakou
 */
class MarkdownParser {
    
    // Used to keep track of multiline blocks e.g. paragraph
    var previousLine: String = null;
    // Stack to keep track of the HTML elements opened.
    var htmlElements = null;
    // The string to contain all the parsed HTML.
    var rawHtml: String = null;
    // Boolean flag to denote if this is the start of a blockquote.
    var blockquoteItem: Bool = false;
    // Boolean flag to denote if this is the start of an unordered list.
    var unorderedListItem: Bool = false;
    // Boolean flag to denote if this is the start of an ordered list.
    var orderedListItem: Bool = false;

    /**
     * Parse a markdown document or string into its HTML equivalent.
     * 
     * @param content The path of the file, or a string, to be parsed. Works in
     *      conjunction with the `string` boolean flag.
     * @param string Boolean flag to specify whether a user has passed a filename
     *      or a string.
     * @param prettify Boolean flag to specify whether the HTML output should be
     *      formatted using BeautifulSoup.
     * @param stdout Boolean flag to specify whether the HTML output should be
     *      displayed to standard out instead of being written to a file.
     */    
    function new(
        content: String = null,
        string: Bool = false,
        prettify: Bool = false,
        stdout: Bool = false,
    ) {
        if (content == null || content.strip() == "") && string == null {
            trace("No file was provided.");
            Sys.exit(1);
        }
        else if (content == null || content.strip() == "") && string != null {
            trace("No markdown string was provided.");
            Sys.exit(1);
        }

        if string == null && sys.io.File.exists(content) {
            trace("The file provided was not found.");
            Sys.exit(1);
        }

        blockquoteItem = false;
        unorderedListItem = false;
        orderedListItem = false;
        htmlElements = [];
        rawHtml = '<!DOCTYPE html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="author" content="Marios Yiannakou">\n<meta name="description" content="This is a markdown parser to HTML created for my COMP30040 module at the University of Manchester.">\n</head>\n<body>\n';
        readFile(content, string, prettify, stdout);
    }

    /**
     * Parse each line of the given content or filename.
     * 
     * @param content The path of the file, or a string, to be parsed. Works in
     *      conjunction with the `string` boolean flag.
     * @param string Boolean flag to specify whether a user has passed a string to be
     *      parsed, or a filename.
     * @param prettify Boolean flag to specify whether the HTML output should be
     *      formatted using BeautifulSoup.
     * @param stdout Boolean flag to specify whether the HTML output should be
     *      displayed to standard out instead of being written to a file.
     */
    function readFile(
        content: String, string: Bool, prettify: Bool = false, stdout: Bool = false
    ) {
        if (!string) {
            var htmlCode: String = sys.io.File.getContent(content);
            for (line in htmlCode.split("\n")) {
                parseContent(line);
            }
        } else {
            parseContent(content);
        }
        rawHtml += '\n</body>\n</html>\n';

        parsed_content_filename = "parsed.html";
        try {
            // FIX
            // if (prettify) {
            //     rawHtml = BeautifulSoup(rawHtml, "html.parser").prettify();
            // }

            if (stdout) {
                trace(rawHtml);
            } else {
                sys.io.File.saveContent(parsedContentFilename, rawHtml);
            }
        } catch(e) {
            trace(
                'Exception ${str(e)} occured while writing to file ... printing to standard out'
            );
            trace(rawHtml);
            // FIX: Delete the file if it exists
            // if (sys.io.File.exists((parsed_content_filename)) {
            //     remove(parsed_content_filename);
            // }
        }
    }
    
    /**
     * Reads and parses the provided content into HTML.
     * 
     * @param content A string to be parsed with markdown rules.
     * @returns The parsed content as HTML.
     */
    function parseContent(content: String) {
        for (line in content.split("\n")) {
            line = line.strip();
            if (line == "") {
                if (unorderedListItem) {
                    unorderedListItem = false;
                }
                if (orderedListItem) {
                    orderedListItem = false;
                }
                if (blockquoteItem) {
                    blockquoteItem = false;
                }
                previousLine = "";
                continue;
            }

            if (previousLine == "" && htmlElements) {
                rawHtml += '\n</{htmlElements.pop()}>\n';
            }
            if (unorderedListItem && line[0] != "-") {
                unorderedListItem = false;
            }
            if (orderedListItem && line[0] != "+") {
                orderedListItem = false;
            }
            if (blockquoteItem && line[0] != ">") {
                blockquoteItem = false;
            }

            specialCharacters = getSpecialCharacters(line);
            if (specialCharacters == null) {
                if (previousLine == null || previousLine == "") {
                    rawHtml += "<p>";
                    htmlElements.push("p");
                }
                rawHtml += '\n${line}';
            } else {
                parseSpecialCharacters(line, specialCharacters);
            }

            previousLine = line;
        }

        while (htmlElements.length) {
            rawHtml += '\n</${htmlElements.pop()}>';
        }
    }

    /**
     * Parse the given line with special characters into HTML.
     *
     * @param line The line to be parsed.
     * @param matchedRegex The regex that was matched.
     */
    function parseSpecialCharacters(line: String, matchedRegex: Array<String>) {
        if (matchedRegex.length == 0) {
            return;
        }

        // Turn the string `line` into an array
        line = line.split("");

        var closingTag = null;
        var regex = matchedRegex.pop(0);
        // Starting and ending (non-inclusive) index of special characters in `line`
        spanStart, spanEnd = regex.span();
        var specialChars = regex.string.slice(spanStart, spanEnd);
        var specialCharsLength = specialChars.length;

        if (line.slice(0, spanStart).strip() != "") {
            rawHtml += '<p>\n${line.slice(0, spanStart)}';
            htmlElements.push("p");
        }

        if (
            specialChars[0] == "#"
            && line[0] == "#"
            && line.slice(specialCharsLength, specialCharsLength + 2) == " "
        ) {
            var tag = if (specialCharsLength >= 6) "<h6>" else '<h${specialCharsLength}>';
            rawHtml += tag;
            var closingTag = (
                if (specialCharsLength >= 6) "</h6>\n"
                else '</h${specialCharsLength}>\n'
            );
        } else if (specialChars[0] == "*") {
            // Pop the matched regex again as patterns that require opening and closing
            // patterns produce two matching elements, and are displayed twice
            // e.g. Bold --> **text to make bold** (requires '**' at the start and ending)
            // If there is no matching regex at the end, treat as normal text and print it.
            if (matchedRegex.length > 0) {
                regex = validateRegex(regex, matchedRegex.pop(0));
                if (regex == null) {
                    appendInvalidRegex(line);
                    return;
                }
            } else {
                appendInvalidRegex(line);
                return;
            }

            // Don't add a new line at the end as these could be inline.
            var content = line.slice(spanEnd, regex.span()[0]).strip();
            if (specialCharsLength == 1) {
                rawHtml += '<i>${content}</i>';
            } else if (specialCharsLength == 2) {
                rawHtml += '<b>${content}</b>';
            } else if (specialCharsLength == 3) {
                rawHtml += '<b><i>${content}</i></b>';
            } else {
                appendInvalidRegex(line);
                return;
            }
        } else if (specialChars[0] == "_") {
            if (specialCharsLength > 1 || matchedRegex.length == 0) {
                appendInvalidRegex(line);
                return;
            } else {
                regex = validateRegex(regex, matchedRegex.pop(0));
                if (regex == null) {
                    appendInvalidRegex(line);
                    return;
                }
            }

            var content = line.slice(spanEnd, regex.span()[0]).strip();
            rawHtml += '<p style="text-decoration: underline;">${content}</p>';
        } else if (specialChars[0] == "!") {
            regex = [
                for (match in re.finditer(r"\!\[.*?\]\(.*?\)", line)) if match.group()
            ];
            if (regex.length > 0) {
                altText, src = regex[0].group().split("](");
                altText = altText.slice(2, altText.length);
                src = src.slice(0, src.length - 1);
                rawHtml += '<img src="${src}" alt="${altText}"/>';

                line = line.slice(regex[0].span()[1], line.length);
                // Since URLs have some of the special characters that the markdown
                // parser understands, it's required that after parsing the URL, the
                // link is removed from the line and the `matchedRegex` list is
                // redefined here.
                matchedRegex = getSpecialCharacters(line);
                regex = null;
            } else {
                appendInvalidRegex(line);
                return;
            }
        } else if (specialChars[0] == "[") {
            var regex = [
                // FIX
                match for match in re.finditer(r"\[.*?\]\(.*?\)", line) if match.group()
            ];
            if (regex != null) {
                text, src = regex[0].group().split("](");
                text = text.slice(1, text.length);
                src = src.slice(0, src.length - 2);
                rawHtml += '<a href="${src}">${text}</a>';

                line = line.slice(regex[0].span()[1], line.length);
                // Since URLs have some of the special characters that the markdown
                // parser understands, it's required that after parsing the URL, the
                // link is removed from the line and the `matchedRegex` list is
                // redefined here.
                matchedRegex = getSpecialCharacters(line);
                regex = null;
            } else {
                appendInvalidRegex(line);
                return;
            }
        } else if (specialChars[0] == ">" && line.length > 1 && line.slice(1, line.length).strip() != "") {
            if (!blockquoteItem) {
                blockquoteItem = true;
                rawHtml += "<blockquote>\n";
                htmlElements.push("blockquote");
            }

            rawHtml += "<p>";
            closingTag = "</p>\n";
        } else if (specialChars[0] == "-" && line.length > 1 && line.slice(1, line.length).strip() != "") {
            if (!unorderedListItem) {
                unorderedListItem = true;
                rawHtml += "<ul>\n";
                htmlElements.push("ul");
            }

            rawHtml += "<li>";
            closingTag = "</li>\n";
        } else if (specialChars[0] == "+" && line.length > 1 && line.slice(1, line.length).strip() != "") {
            if (!orderedListItem) {
                orderedListItem = true;
                rawHtml += "<ol>\n";
                htmlElements.push("ol");
            }

            rawHtml += "<li>";
            closingTag = "</li>\n";
        } else {
            appendInvalidRegex(line);
            return;
        }

        // Send the substring that contains more markdown content to be parsed again
        // e.g. # An h1 header with **bold text**
        if (matchedRegex.length > 0) {
            // FIX
            next_regex_start, _ = matchedRegex[0].span();
            // Use `regex.span()[1]` instead of `spanEnd` as `regex` could have been
            // updated in the case of an emphasis styling pattern. This does not update
            // `spanStart` or `spanEnd`.
            rawHtml += line.slice(regex.span()[1], next_regex_start);
            parseSpecialCharacters(
                line.slice(next_regex_start, line.length),
                getSpecialCharacters(line.slice(next_regex_start, line.length)),
            );
            matchedRegex = [];
        } else if (regex != null) {
            rawHtml += line.slice(regex.span()[1], line.length);
        } else {
            rawHtml += line;
        }

        // Some regexes might finish before the actual line does thus,
        // `closingTag` might be `null`
        // e.g. # This line is an h1 header with ***bold and italic text*** and more normal text
        //      </i></b> closes before the end of the line so `closingTag` is `null`.
        if (closingTag) {
            rawHtml += '${closingTag}';
        }
    }

    /**
     * Validates that the popped regex matches the current regex to ensure that both
     * special characters are of the same type.
     * e.g. **this is bold**   is valid
     *      **this is bold*    is invalid
     *
     * @param currentRegex The regex to be matched against.
     * @param poppedRegex The regex currently under evaluation.
     * @returns The `poppedRegex` if it's a match, `null` otherwise.
     */
    function validateRegex(currentRegex: Array<String>, poppedRegex: Array<String>) {
        if (Std.string(currentRegex.group()) == Std.string(poppedRegex.group())) {
            return poppedRegex;
        }
    }

    /**
     * Appends an invalid regex as a plain text line.
     * e.g. **This line is bold
     *      This line is italic*
     *
     * will result in
     *
     * <p>
     * **This line is bold
     * This line is italic*
     * </p>
     *
     * @param line The line to append to the parsed content.
     */
    function appendInvalidRegex(line: String) {
        // Only append the <p> element if the latest one is not already a <p> element.
        if (
            htmlElements.length == 0
            || htmlElements[htmlElements.length - 1] != "p"
        ) {
            rawHtml += '<p>\n${line}';
            htmlElements.push("p");
        } else {
            rawHtml += '\n${line}';
        }
    }

    /**
     * Uses a predefined regular expression to capture any special characters from the
     * provided string and returns them as a list of `String` elements.
     * 
     * @param string The string to extract the special characters from.
     * @returns A list of `String` elements representing all the matched special
     *      charaters found in `string`.
     */
    function getSpecialCharacters(string: String) {
        // FIX
        pattern = r"[^a-zA-Z0-9 '\"./\\@$%&=;:<,?{}|~]*";
        return [for (match in re.finditer(pattern, string)) if match.group()];
    }


var content = "This is a multiline input
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

> This is a blockquote

> This is the first item in a multiline blockquote.
> **This is the second item in a blockquote and it's bold**.
> *This is the third item in a blockquote and it's italic*.
> ***This is the third item in a blockquote and it's both***.
> This is the third item in a blockquote and it's part plain, **part bold**, and *part italic*.

- This is a single item unordered list.

- This is the first item in an unordered list.
- This is the second item in an unordered list.
- **This is the third item in an unordered list and it's bold**.
- This is the fourth item in an unordered list and part of it is plain, **part bold**, *part italic*, and ***part both***.
- This is the fifth item in an unordered list and links to my [GitHub page](https://www.github.com/Mariosyian).

+ This is a single item ordered list.

+ This is the first item in an ordered list.
+ This is the second item in an ordered list.
+ **This is the third item in an ordered list and it's bold**.
+ This is the fourth item in an ordered list and part of it is plain, **part bold**, *part italic*, and ***part both***.
+ This is the fifth item in an ordered list and links to my [GitHub page](https://www.github.com/Mariosyian).

This line should have an **image** of a muffin ![muffin time](https://static.wikia.nocookie.net/asdfmovie/images/1/1d/Muffin.png/revision/latest/scale-to-width-down/148?cb=20180617145555) with alternate text 'muffin time'.";


/**
 * Display a help message and exit the program.
 */
function show_help_message() {
    trace(
        "
Shaved down version of the Common Mark markdown parser created as part of COMP30040.
This version was written for Python3.

usage: python markdown_parser.py <path/to/file> [--help] [--raw <markdown string>]
                                                [--prettify] [--stdout] [--demo]

<path/to/file>: The file that contains markdown code. Ignored if the `--raw` flag is
                used. Must be the first argument.

--help: Display this help message and exit.
--raw: Provide a raw string of markdown content to be parsed into HTML.
--prettify: Prettify the output using BeautifulSoup4.
--stdout: Print the resulting HTML code to standard out instead of a file.
--demo: Uses a predefined raw string (implies the `--raw` flag) that uses all features
        of the markdown parser.

Example usage:
- Raw string
python markdown_parser.py --raw '# An h1 header with *bold text*.' --stdout
- File
python markdown_parser.py ./markdown.md --prettify

Exit Codes:
0 - OK
1 - Erroneous input

Author: Marios Yiannakou, GitHub: @Mariosyian"
    );
    sys.exit(0);
}


function main() {
    var arguments = sys.args();
    var flags: Map<String, Bool> = [
        "help" => arguments.has("--help"),
        "raw" => arguments.has("--raw"),
        "prettify" => arguments.has("--prettify"),
        "stdout" => arguments.has("--stdout"),
        "demo" => arguments.has("--demo"),
    ];

    if (flags["help"]) {
        show_help_message();
    }

    if (flags["raw"]) {
        try {
            content = arguemnts[arguemnts.index("--raw") + 1];
        } catch(e) {
            trace("No markdown string was provided.");
            sys.exit(1);
        }
    } else if (!flags["demo"]) {
        try {
            content = arguments[1];
        } catch(e) {
            content = null;
        }
    }

    new MarkdownParser(
        content,
        flags["demo"] || flags["raw"],
        flags["prettify"],
        flags["stdout"],
    );
}
