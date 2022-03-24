class Markdown_Parser {
    static var content = "This is a multiline input
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
> ***This is the fourth item in a blockquote and it's both***.
> This is the fifth item in a blockquote and it's part plain, **part bold**, and *part italic*.

- This is a single item unordered list.

- This is the first item in an unordered list.
- This is the second item in an unordered list.
- **This is the third item in an unordered list and it's bold**.
- This is the fourth item in an unordered list and part of it is plain, **part bold**, *part italic*, and ***part both***.
- This is the fifth item in an unordered list and links to my [GitHub page](https://www.github.com/Mariosyian), go check it out.

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
This version was written for Haxe.

usage: haxe --run Markdown_Parser.hx <path/to/file> [--help] [--raw <markdown string>] [--stdout] [--demo]

<path/to/file>: The file that contains markdown code. Ignored if the `--raw` flag is used. Must be the first argument.

--help      Display this help message and exit.
--raw       Provide a raw string of markdown content to be parsed into HTML.
--stdout    Print the resulting HTML code to standard out instead of a file.
--demo      Uses a predefined raw string (implies the `--raw` flag) that uses all features of the markdown parser.

Example usage:
- Raw string
haxe --run Markdown_Parser.hx --raw '# An h1 header with *bold text*.' --stdout
- File
haxe --run Markdown_Parser.hx ./markdown.md

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
        var arguments: Array<String> = Sys.args();
        var flags: Map<String, Bool> = [
            // FIX -- Why doesn't arguments.contains() work??
            "help" => contains(arguments, "--help"),
            "raw" => contains(arguments, "--raw"),
            "stdout" => contains(arguments, "--stdout"),
            "demo" => contains(arguments, "--demo"),
        ];
    
        if (flags["help"]) {
            showHelpMessage();
        }

        if (flags["raw"]) {
            try {
                content = arguments[arguments.indexOf("--raw") + 1];
            } catch(e:Any) {
                Sys.println("No markdown string was provided.");
                Sys.exit(1);
            }
        } else if (!flags["demo"]) {
            try {
                // This assumes the user abides to the usage instructions.
                content = arguments[0];
            } catch(e:Any) {
                content = "";
            }
        }

        new MarkdownParser(
            content,
            flags["demo"] || flags["raw"],
            flags["stdout"]
        );
    }
}
