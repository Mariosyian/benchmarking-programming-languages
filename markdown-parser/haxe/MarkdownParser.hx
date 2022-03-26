/**
 * Represents a markdown parser that abides to the CommonMark spec, but modified to
 * fit what, I believe, is a version of the parser achievable by a beginner to
 * intermediate level programmer in a language of their chosing.
 *
 * @author Marios Yiannakou
 */
class MarkdownParser {
    
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
     * @param stdout Boolean flag to specify whether the HTML output should be
     *  displayed to standard out instead of being written to a file.
     */    
    public function new(content: String = "", string: Bool = false, stdout: Bool = false) {
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
        readFile(content, string, stdout);
    }

    /**
     * Parse each line of the given content or filename.
     * 
     * @param content The path of the file, or a string, to be parsed. Works in
     *      conjunction with the `string` boolean flag.
     * @param string Boolean flag to specify whether a user has passed a string to be
     *      parsed, or a filename.
     * @param stdout Boolean flag to specify whether the HTML output should be
     *      displayed to standard out instead of being written to a file.
     */
    public function readFile(
        content: String, string: Bool, stdout: Bool = false
    ) {
        if (!string) {
            parseContent(sys.io.File.getContent(content));
        } else {
            parseContent(content);
        }
        rawHtml += '\n</body>\n</html>\n';

        var parsedContentFilename: String = "parsed.html";
        try {
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
            if (sys.FileSystem.exists(parsedContentFilename)) {
                Sys.stderr().writeString('${parsedContentFilename} was unable to be removed. Please remove this manually.');
            }
        }
    }
    
    /**
     * Reads and parses the provided content into HTML.
     * 
     * @param content A string to be parsed with markdown rules.
     */
    public function parseContent(content: String) {
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
                rawHtml += '</${htmlElements.pop()}>\n';
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
            if (specialCharacters.length == 0) {
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
     public function parseSpecialCharacters(line: String, matchedRegex: Array<{match:String, span:{start:Int, end:Int}}>) {
        if (matchedRegex.length == 0) {
            return;
        }
        
        var closingTag: String = "";
        var regex: {match:String, span:{start:Int, end:Int}} = matchedRegex.splice(0,1)[0];
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
            && line.substring(specialCharsLength, specialCharsLength + 1) == " "
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
                var popped: {match:String, span:{start:Int, end:Int}} = matchedRegex.splice(0,1)[0];
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
                var popped: {match:String, span:{start:Int, end:Int}} = matchedRegex.splice(0,1)[0];
                regex = validateRegex(regex, popped);
                if (regex == null) {
                    appendInvalidRegex(line);
                    return;
                }
            }

            var content: String = StringTools.trim(line.substring(spanEnd, regex.span.start));
            rawHtml += '<p style="text-decoration: underline;">${content}</p>';
        } else if (specialChars.charAt(0) == "!" || specialChars.charAt(0) == "[") {
            // A hyperlink matches both an image and an anchor tag.
            // In the case of an image the '!' is skipped over (i.e. not written).
            regex = getSpecialCharacters(line, ~/\[[^\]]*\]\([^\)]*\)/gi)[0];
            if (regex != null) {
                var link: Array<String> = regex.match.split("](");
                var src: String = link[1].substring(0, link[1].length-1);
                var text: String = "";
                if (specialChars.charAt(0) == "!") {
                    text = link[0].substring(2, link[0].length);
                    rawHtml += '<img src="${src}" alt="${text}"/>';
                } else {
                    text = link[0].substring(1, link[0].length);
                    rawHtml += '<a href="${src}">${text}</a>';
                }

                // `matchedRegex` doesn't match the URL pattern, but special
                // characters. Even though `regex` matches ![]() / [](),
                // `matchedRegex` contains ['![', '](', ')'] which must be removed.
                // A dirty solution at the moment is to cut the line from the end of
                // the link until the end, and reparse it.
                line = line.substring(regex.span.end, line.length);
                matchedRegex = getSpecialCharacters(line);
                // This is required for the end of this function, to append any more
                // text.
                if (matchedRegex.length == 0) {
                    regex = null;
                }
            } else {
                appendInvalidRegex(line);
                return;
            }
        } else if (specialChars.charAt(0) == ">" && line.charAt(0) == ">" && line.length > 1 && StringTools.trim(line.substring(1, line.length)) != "") {
            if (!blockquoteItem) {
                blockquoteItem = true;
                rawHtml += "<blockquote>\n";
                htmlElements.push("blockquote");
            }

            rawHtml += "<p>";
            closingTag = "</p>\n";
        } else if (specialChars.charAt(0) == "-" && line.charAt(0) == "-" && line.length > 1 && StringTools.trim(line.substring(1, line.length)) != "") {
            if (!unorderedListItem) {
                unorderedListItem = true;
                rawHtml += "<ul>\n";
                htmlElements.push("ul");
            }

            rawHtml += "<li>";
            closingTag = "</li>\n";
        } else if (specialChars.charAt(0) == "+" && line.charAt(0) == "+" && line.length > 1 && StringTools.trim(line.substring(1, line.length)) != "") {
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
        // e.g. # An h1 header with **bold text** and then some.
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
    public function validateRegex(currentRegex: {match:String, span:{start:Int, end:Int}}, poppedRegex: {match:String, span:{start:Int, end:Int}}): {match:String, span:{start:Int, end:Int}} {
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
    public function appendInvalidRegex(line: String) {
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
    public function getSpecialCharacters(string: String, regex: EReg = null): Array<{match:String, span:{start:Int, end:Int}}> {
        // The reason this is setup like this, is because the regex pattern can not be
        // inserted directly into the function definition. 
        if (regex == null) {
            regex = ~/[^a-zA-Z0-9 '".\/\\@$%&=;:<,?{}|~]+/gi;
        }

        var matches: Array<{match:String, span:{start:Int, end:Int}}> = [];
        while (regex.match(string)) {
            var position: {pos: Int, len: Int} = regex.matchedPos();
            if (matches.length > 0) {
                position = {
                    "pos": matches[matches.length - 1].span.end + position.pos,
                    "len": position.len,
                };
            }
            matches.push(
                {
                    "match": regex.matched(0),
                    "span": {
                        "start": position.pos,
                        "end": position.pos + position.len,
                    },
                }
            );
            string = regex.matchedRight();
        }
        return matches;
    }
}

