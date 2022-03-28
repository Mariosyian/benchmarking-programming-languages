import utest.Assert;
import utest.Runner;
import utest.ui.Report;

class Markdown_Parser_Test {
	public static function main() {
		var runner = new Runner();

		runner.addCase(new TestCase());

		Report.create(runner);
		runner.run();
	}
}

class TestCase extends utest.Test {
    var parsedContentFilename: String = "parsed.html";

// //     public function testThatTheHelpMessageIsDisplayed() {
// //         var message: String = '
// // Shaved down version of the Common Mark markdown parser created as part of COMP30040.
// // This version was written for Python3.

// // usage: python markdown_parser.py <path/to/file> [--help] [--raw <markdown string>]
// //                                                 [--prettify] [--stdout] [--demo]

// // <path/to/file>: The file that contains markdown code. Ignored if the `--raw` flag is
// //                 used. Must be the first argument.

// // --help: Display this help message and exit.
// // --raw: Provide a raw string of markdown content to be parsed into HTML.
// // --prettify: Prettify the output using BeautifulSoup4.
// // --stdout: Print the resulting HTML code to standard out instead of a file.
// // --demo: Uses a predefined raw string (implies the `--raw` flag) that uses all features
// //         of the markdown parser.

// // Example usage:
// // - Raw string
// // python markdown_parser.py --raw "# An h1 header with *bold text*." --stdout
// // - File
// // python markdown_parser.py ./markdown.md --prettify

// // Exit Codes:
// // 0 - OK
// // 1 - Erroneous input

// // Author: Marios Yiannakou, GitHub: @Mariosyian';
    
// //         // FIX
// //         // with patch.object(sys, "argv", "--help") {
// //         //     with patch.object(md, "__name__", "__main__") {
// //         //         assert "--help" in sys.argv
// //         //         runpy.run_module(
// //         //             "markdown_parser",
// //         //         )
// //         //         assert capsys.readouterr().out == message
// //         //     }
// //         // }
// //         Assert.fail("Not implemented");
// //     }


    public function testThatTheProgramExitsDueToErrorWhenNoContentAndNoString() {
        try {
            new MarkdownParser("", false);
            // Shouldn't reach this line due to an error
            Assert.fail("Shouldn't reach this point");
        } catch (e: Any) {
            Assert.isTrue(true);
        }
    }

    public function testThatTheProgramExitsDueToErrorWhenTheFileDoesntExist() {
        try {
            new MarkdownParser("File name that doesn't exist", false);
            Assert.fail("Shouldn't reach this point");
        } catch(e: Any) {
            Assert.isTrue(true);
        }
    }


    public function testThatTheParserProducesTheCorrectHtmlAndPrintsToStdout() {
        var map: Array<Array<String>> = [
            [
                "**this is bold**",
                '<b>this is bold</b>',
            ],
            [
                "*this is italic*",
                '<i>this is italic</i>',
            ],
            [
                "***this is both***",
                '<b><i>this is both</i></b>',
            ],
            [
                "#### This should be an h4 header",
                '<h4> This should be an h4 header</h4>\n',
            ],
            [
                "_This should be underlined_",
                '<p style="text-decoration: underline;">This should be underlined</p>',
            ],
            [
                "This should be normal text",
                '<p>\nThis should be normal text\n</p>',
            ],
            [
                "[Foo-Bar](foo.bar)",
                '<a href="foo.bar">Foo-Bar</a>',
            ],
            [
                "> This is a blockquote\n> This is the same blockquote",
                '<blockquote>\n<p> This is a blockquote</p>\n<p> This is the same blockquote</p>\n\n</blockquote>',
            ],
            [
                "- This is the first item in an unordered list.\n- This is the second item in an unordered list.",
                '<ul>\n<li> This is the first item in an unordered list.</li>\n<li> This is the second item in an unordered list.</li>\n\n</ul>',
            ],
            [
                "+ This is the first item in an ordered list.\n+ This is the second item in an ordered list.",
                '<ol>\n<li> This is the first item in an ordered list.</li>\n<li> This is the second item in an ordered list.</li>\n\n</ol>',
            ],
            [
                "![woohoo](image)",
                '<img src="image" alt="woohoo"/>',
            ],
            [
                "with more random text\nbut this spans across two lines",
                '<p>\nwith more random text\nbut this spans across two lines\n</p>',
            ],
            [
                "more random text but with **bold** and *italic* in the middle",
                '<p>\nmore random text but with <b>bold</b> and <i>italic</i> in the middle\n</p>',
            ],
            [
                '
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
                ',
                '<b>this is bold</b><i>this is italic</i><b><i>this is both</i></b><h4> This should be an h4 header</h4>\n<p style="text-decoration: underline;">This should be underlined</p><p>\nThis should be normal</p>\n<a href="foo.bar">Foo-Bar</a><blockquote>\n<p> This is a blockquote</p>\n</blockquote>\n<ul>\n<li> This is a single item unordered list.</li>\n</ul>\n<ol>\n<li> This is a single item ordered list.</li>\n</ol>\n<img src="image" alt="woohoo"/>',
            ]
        ];
        for (test in map) {
            var markdown: String = test[0];
            var parsedHtml: String = test[1];
            var html: String = '<!DOCTYPE html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="author" content="Marios Yiannakou">\n<meta name="description" content="This is a markdown parser to HTML created for my COMP30040 module at the University of Manchester.">\n</head>\n<body>\n${parsedHtml}\n</body>\n</html>\n';
            new MarkdownParser(markdown, true, false);
            // TODO: Need a more concrete way. Reading stdout directly?
            // Write results to a file and read the file
            Assert.equals(html, sys.io.File.getContent(parsedContentFilename));
        }
    }

    public function testThatTheParserCatchesInvalidMarkdown() {
        var map: Array<Array<String>> = [
            [
                "**this is not bold*",
                "<p>\n**this is not bold*\n</p>",
            ],
            [
                "*this is not italic",
                "<p>\n*this is not italic\n</p>",
            ],
            [
                "***this is not both",
                "<p>\n***this is not both\n</p>",
            ],
            [
                "****this should be invalid****",
                "<p>\n****this should be invalid****\n</p>",
            ],
            [
                "_This should not be underlined",
                "<p>\n_This should not be underlined\n</p>",
            ],
            [
                "__This should not be underlined__",
                "<p>\n__This should not be underlined__\n</p>",
            ],
            [
                "_This should not be underlined*",
                "<p>\n_This should not be underlined*\n</p>",
            ],
            [
                "[Foo-Bar(foo.bar)",
                "<p>\n[Foo-Bar(foo.bar)\n</p>",
            ],
            [
                "![woohoo]image)",
                "<p>\n![woohoo]image)\n</p>",
            ]
        ];
        for (test in map) {
            var markdown: String = test[0];
            var parsedHtml: String = test[1];
            var html: String = '<!DOCTYPE html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="author" content="Marios Yiannakou">\n<meta name="description" content="This is a markdown parser to HTML created for my COMP30040 module at the University of Manchester.">\n</head>\n<body>\n${parsedHtml}\n</body>\n</html>\n';
            new MarkdownParser(markdown, true, false);
            // TODO: Need a more concrete way. Reading stdout directly?
            // Write results to a file and read the file
            Assert.equals(html, sys.io.File.getContent(parsedContentFilename));
        }
    }


    public function testThatTheParserTreatsUnknownSpecialCharactersAsInvalidMarkdown() {
        var markdown: String = "£";
        var parsedHtml: String = "<p>\n£\n</p>";
        var html: String = '<!DOCTYPE html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="author" content="Marios Yiannakou">\n<meta name="description" content="This is a markdown parser to HTML created for my COMP30040 module at the University of Manchester.">\n</head>\n<body>\n${parsedHtml}\n</body>\n</html>\n';
        new MarkdownParser(markdown, true, false);
        // TODO: Need a more concrete way. Reading stdout directly?
        // Write results to a file and read the file
        Assert.equals(html, sys.io.File.getContent(parsedContentFilename));
    }
}
