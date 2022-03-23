/**
 * Represents a markdown parser that abides to the CommonMark spec, but modified to
 * fit what, I bleieve, is a version of the parser achievable by a beginner level
 * programmer in a language of their chosing.
 *
 * @author Marios Yiannakou
 */
class Markdown_Parser {
    
    // Used to keep track of multiline blocks e.g. paragraph
    var previousLine: String = "";
    // Stack to keep track of the HTML elements opened.
    var htmlElements: Array<String> = [];
    // The string to contain all the parsed HTML.
    var rawHtml: String = "";
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
     *  conjunction with the `string` boolean flag.
     * @param string Boolean flag to specify whether a user has passed a string or a
     *  filename. Set to `true` to indicate a raw markdown string, and `false` to
     *  indicate a filename.
     * @param prettify Boolean flag to specify whether the HTML output should be
     *  formatted using BeautifulSoup.
     * @param stdout Boolean flag to specify whether the HTML output should be
     *  displayed to standard out instead of being written to a file.
     */    
    function new(content: String = "", string: Bool = false, prettify: Bool = false, stdout: Bool = false) {
        if (StringTools.trim(content) == "" && !string) {
            Sys.println("No file was provided.");
            Sys.exit(1);
        }

        if (!string && !sys.FileSystem.exists(content)) {
            Sys.println("The file provided was not found.");
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
            parseContent(sys.io.File.getContent(content));
        } else {
            parseContent(content);
        }
        rawHtml += '\n</body>\n</html>\n';

        var parsedContentFilename: String = "parsed.html";
        try {
            // FIX
            // if (prettify) {
            //     rawHtml = BeautifulSoup(rawHtml, "html.parser").prettify();
            // }

            if (stdout) {
                Sys.println(rawHtml);
            } else {
                sys.io.File.saveContent(parsedContentFilename, rawHtml);
            }
        } catch(e:Any) {
            Sys.println(
                'Exception [${e}] occured while writing to file ... printing to standard out'
            );
            Sys.println(rawHtml);
            // FIX: Delete the file if it exists
            // if (Sys.FileSystem.exists((parsedContentFilename)) {
            //     remove(parsedContentFilename);
            // }
        }
    }
    
    /**
     * Reads and parses the provided content into HTML.
     * 
     * @param content A string to be parsed with markdown rules.
     */
    function parseContent(content: String) {
        for (line in content.split("\n")) {
            line = StringTools.trim(line);
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

            if (previousLine == "" && htmlElements.length > 0) {
                rawHtml += '\n</{htmlElements.pop()}>\n';
            }
            if (unorderedListItem && line.charAt(0) != "-") {
                unorderedListItem = false;
            }
            if (orderedListItem && line.charAt(0) != "+") {
                orderedListItem = false;
            }
            if (blockquoteItem && line.charAt(0) != ">") {
                blockquoteItem = false;
            }

            var specialCharacters: Array<{match:String, span:{start:Int, end:Int}}> = getSpecialCharacters(line);
            if (specialCharacters == []) {
                if (previousLine == "") {
                    rawHtml += "<p>";
                    htmlElements.push("p");
                }
                rawHtml += '\n${line}';
            } else {
                parseSpecialCharacters(line, specialCharacters);
            }

            previousLine = line;
        }

        while (htmlElements.length > 0) {
            rawHtml += '\n</${htmlElements.pop()}>';
        }
    }

    /**
     * Parse the given line with special characters into HTML.
     *
     * @param line The line to be parsed.
     * @param matchedRegex The regex list that was matched.
     */
    function parseSpecialCharacters(line: String, matchedRegex: Array<{match:String, span:{start:Int, end:Int}}>) {
        if (matchedRegex.length == 0) {
            return;
        }

        var closingTag: String = "";
        var regex: {match:String, span:{start:Int, end:Int}} = matchedRegex[0];
        matchedRegex.remove(regex);
        // Keep track of the current regex start and end position, in case of an update
        var spanStart: Int = regex.span.start;
        var spanEnd: Int = regex.span.end;
        // Starting and ending (non-inclusive) index of special characters in `line`
        var specialChars: String = regex.match;
        var specialCharsLength: Int = specialChars.length;

        if (StringTools.trim(line.substring(0, spanStart)) != "") {
            rawHtml += '<p>\n${line.substring(0, spanStart)}';
            htmlElements.push("p");
        }

        if (
            specialChars.charAt(0) == "#"
            && line.charAt(0) == "#"
            && line.substring(specialCharsLength, specialCharsLength + 2) == " "
        ) {
            var tag: String = if (specialCharsLength >= 6) "<h6>" else '<h${specialCharsLength}>';
            rawHtml += tag;
            closingTag = (
                if (specialCharsLength >= 6) "</h6>\n"
                else '</h${specialCharsLength}>\n'
            );
        } else if (specialChars.charAt(0) == "*") {
            // Pop the matched regex again as patterns that require opening and closing
            // patterns produce two matching elements, and are displayed twice
            // e.g. Bold --> **text to make bold** (requires '**' at the start and ending)
            // If there is no matching regex at the end, treat as normal text and print it.
            if (matchedRegex.length > 0) {
                var popped: {match:String, span:{start:Int, end:Int}} = matchedRegex[0];
                matchedRegex.remove(popped);
                regex = validateRegex(regex, popped);
                if (regex == null) {
                    appendInvalidRegex(line);
                    return;
                }
            } else {
                appendInvalidRegex(line);
                return;
            }

            // Don't add a new line at the end as these could be inline.
            var content: String = StringTools.trim(line.substring(spanEnd, regex.span.start));
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
        } else if (specialChars.charAt(0) == "_") {
            if (specialCharsLength > 1 || matchedRegex.length == 0) {
                appendInvalidRegex(line);
                return;
            } else {
                var popped: {match:String, span:{start:Int, end:Int}} = matchedRegex[0];
                matchedRegex.remove(popped);
                regex = validateRegex(regex, popped);
                if (regex == null) {
                    appendInvalidRegex(line);
                    return;
                }
            }

            var content: String = StringTools.trim(line.substring(spanEnd, regex.span.start));
            rawHtml += '<p style="text-decoration: underline;">${content}</p>';
        } else if (specialChars.charAt(0) == "!") {
            regex = getSpecialCharacters(line, "![[^]]*]([^)]*)")[0];
            if (regex != null) {
                var link: Array<String> = regex.match.split("](");
                var src: String = link[0].substring(2, link[0].length);
                var altText: String = link[1].substring(0, link[1].length-1);
                rawHtml += '<img src="${src}" alt="${altText}"/>';

                // FIX -- Maybe make into while ( regex.length > 0 ) ???
                line = line.substring(regex.span.end, line.length);
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
        } else if (specialChars.charAt(0) == "[") {
            regex = getSpecialCharacters(line, "[[^]]*]([^)]*)")[0];
            if (regex != null) {
                var link: Array<String> = regex.match.split("](");
                var src: String = link[0].substring(1, link[0].length);
                var text: String = link[1].substring(0, link[1].length-1);
                rawHtml += '<a href="${src}">${text}</a>';

                // FIX -- Maybe make into while ( regex.length > 0 ) ???
                line = line.substring(regex.span.end, line.length);
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
        } else if (specialChars.charAt(0) == ">" && line.length > 1 && StringTools.trim(line.substring(1, line.length)) != "") {
            if (!blockquoteItem) {
                blockquoteItem = true;
                rawHtml += "<blockquote>\n";
                htmlElements.push("blockquote");
            }

            rawHtml += "<p>";
            closingTag = "</p>\n";
        } else if (specialChars.charAt(0) == "-" && line.length > 1 && StringTools.trim(line.substring(1, line.length)) != "") {
            if (!unorderedListItem) {
                unorderedListItem = true;
                rawHtml += "<ul>\n";
                htmlElements.push("ul");
            }

            rawHtml += "<li>";
            closingTag = "</li>\n";
        } else if (specialChars.charAt(0) == "+" && line.length > 1 && StringTools.trim(line.substring(1, line.length)) != "") {
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
            var nextRegexStart: Int = matchedRegex[0].span.start;
            // Use `regex.span.end` instead of `spanEnd` as `regex` could have been
            // updated in the case of an emphasis styling pattern. This does not update
            // `spanStart` or `spanEnd`.
            rawHtml += line.substring(regex.span.end, nextRegexStart);
            parseSpecialCharacters(
                line.substring(nextRegexStart, line.length),
                getSpecialCharacters(line.substring(nextRegexStart, line.length))
            );
            matchedRegex = [];
        } else if (regex != null) {
            rawHtml += line.substring(regex.span.end, line.length);
        } else {
            rawHtml += line;
        }

        rawHtml += '${closingTag}';
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
    function validateRegex(currentRegex: {match:String, span:{start:Int, end:Int}}, poppedRegex: {match:String, span:{start:Int, end:Int}}): {match:String, span:{start:Int, end:Int}} {
        if (currentRegex.match == poppedRegex.match) {
            return poppedRegex;
        }

        return null;
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
     * Uses a give regular expression (a predefined one otherwise) to capture any
     * special characters from the provided string and returns them as a list of
     * `String` elements.
     * 
     * @param string The string to extract the special characters from.
     * @param regex The regular expression to be run as a string.
     * @returns A list of `String` elements representing all the matched special
     *  characters found in `string`, and their starting and ending positions in
     *  the original string.
     */
    function getSpecialCharacters(string: String, regex: String = "[^a-zA-Z0-9 '\"./\\@$%&=;:<,?{}|~]*"): Array<{match:String, span:{start:Int, end:Int}}> {
        var pattern: EReg = new EReg(regex, "gi");
        var matches: Array<{match:String, span:{start:Int, end:Int}}> = [];
        while (pattern.match(string)) {
            var position: {pos: Int, len: Int} = pattern.matchedPos();
            if (matches.length > 0) {
                position = {
                    "pos": matches[matches.length - 1].span.end + position.pos,
                    "len": position.len,
                };
            }
            matches.push(
                {
                    "match": pattern.matched(0),
                    "span": {
                        "start": position.pos,
                        "end": position.pos + position.len,
                    },
                }
            );
            string = pattern.matchedRight();
        }
        return matches;
    }
}

class MarkdownParser {
    /****** MAIN FUNCTION *****/
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
    public static function showHelpMessage() {
        Sys.println("
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
        Sys.exit(0);
    }
    
    public static function contains(arr: Array<String>, e: String): Bool {
        return arr.indexOf(e) != -1;
    }

    public static function main() {
        trace("HI")
        var arguments: Array<String> = Sys.args();
        trace("HI")
        var flags: Map<String, Bool> = [
            // FIX -- Why doesn't arguments.contains() work??
            "help" => contains(arguments, "--help"),
            "raw" => contains(arguments, "--raw"),
            "prettify" => contains(arguments, "--prettify"),
            "stdout" => contains(arguments, "--stdout"),
            "demo" => contains(arguments, "--demo"),
        ];
    
        trace("HI")
        if (flags["help"]) {
            showHelpMessage();
        }
    
        trace("HI")
        var content: String = "";
        if (flags["raw"]) {
            try {
                content = arguments[arguments.indexOf("--raw") + 1];
            } catch(e:Any) {
                Sys.println("No markdown string was provided.");
                Sys.exit(1);
            }
        } else if (!flags["demo"]) {
            try {
                content = arguments[1];
            } catch(e:Any) {
                content = null;
            }
        }

        trace("HI")
        new Markdown_Parser(
            content,
            flags["demo"] || flags["raw"],
            flags["prettify"],
            flags["stdout"]
        );
    }
}
