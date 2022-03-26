# Markdown Parser

This is a shaved down version of the [Common Mark spec markdown parser](https://spec.commonmark.org/0.30/#introduction).

## Exclusions
This parser does **NOT** support:
- Comments or `<!-- * -->`
- Parent/Child relations. Indentations at the start of the line are stripped.
- Character escaping. If the character is caught by the regex found in the source code, it most likely will cause an error in the HTML output.
- Any HTML elements or Common Mark specs not seen here.


## Paragraph | `<p>`
A normal paragraph or `<p>` element is a string of alphanumeric characters, along with any special characters that are not reserved for Markdown parsing. The list contains (but not limited to) `abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 '"./\@$%&-=+;:<,?{}[]()|~` and as a regex `^[a-zA-Z0-9 '"./\@$%&-=+;:<>,?!{}[]()|~#]*$`. Depending on how they are used, some of these characters may be parsed as markdown

A new paragraph is created by adding an empty line.
```
# Markdown
This is a single line paragraph with some special characters '"./\@$%&-=+;:<,?(){}[]. As you can see, some of the characters which are caught by the Markdown parser appear as simple text due to the way they are used.

This is a new paragraph explaining why the above characters are not caught. A hyper link needs two square brackets [] and then two parenthesys () right after each other, otherwise, these are not parsed.
   -----
# HTML
<p>This is a single line paragraph with some special characters '"./\@$%&-=+;:<,?(){}[]. As you can see, some of the characters which are caught by the Markdown parser appear as simple text due to the way they are used.</p>
<p>This is a new paragraph explaining why the above characters are not caught. A hyper link needs two square brackets [] and then two parenthesys () right after each other, otherwise, these are not parsed.</p>
```
This is a single line paragraph with some special characters '"./\@$%&-=+;:<,?(){}[]. As you can see, some of the characters which are caught by the Markdown parser appear as simple text due to the way they are used.

This is a new paragraph explaining why the above characters are not caught. A hyper link needs two square brackets [] and then two parenthesys () right after each other, otherwise, these are not parsed.

---
## Styling | `<b>`, `<i>`, `<p style="text-decoration: underline;">`
Emphasis styling such as italic or `<i>`, bold or `<b>`, or both `<b><i>` are defined as `*`,  `**`, and `***` respectively and must wrap around the content they are targeting. In addition, underlining or `<p style="text-decoration: underline;">` is defined as `_` and must wrap around the content it is targeting.
```
# Markdown
*This line should be italic.*
**This line should be bold.**
***This line should be both bold and italic.***
_This line is underlined_
   -----
# HTML
<i>This line should be italic.</i>
<b>This line should be bold.</b>
<b><i>This line should be both bold and italic.</i></b>
<p style="text-decoration: underline;">This line is underlined</p>
```
*This line should be italic.*

**This line should be bold.**

***This line should be both bold and italic.***

The underline is not supported by most Markdown parsers, and the underscore `_` is usually used similary to the `*` for italic and bold.

---
## Headers | `<hX>`
A header or `[<h1>, <h2>, <h3>, <h4>, <h5>, <h6>]` element is defined as `# An h1 element`. A header can be styled as described in the #Styling section.
```
# Markdown
# This is an h1 header.
## This is an h2 header.
### This is an h3 header.
#### This is an h4 header.
##### This is an h5 header.
###### This is an h6 header.
####### Anything above 6 '#' characters is considerd an h6 header.
   -----
# HTML
<h1>This is an h1 header.</h1>
<h2>This is an h2 header.</h2>
<h3>This is an h3 header.</h3>
<h4>This is an h4 header.</h4>
<h5>This is an h5 header.</h5>
<h6>This is an h6 header.</h6>
<h6>Anything above 6 '#' characters is considerd an h6 header.</h6>
```
# This is an h1 header.
## This is an h2 header.
### This is an h3 header.
#### This is an h4 header.
##### This is an h5 header.
###### This is an h6 header.
####### Anything above 6 '#' characters is considerd an h6 header.

The "over 6 `#` characters" rule is not included in conventional markdown parsers.

---
## Lists | `<ul>` or `<ol>`
An unordered list or `<ul>` element is defined as `- List Item 1`, while an ordered list or `<ol>` element is defined as `+ List Item 1`. This only supports plain or stylised text, and hyperlinks. The `-` and `+` characters must be the first characters in the line.
```
# Markdown
- This is the first item in an unordered list.
- This is the second item in an unordered list.
- **This is the third item in an unordered list and it's bold**.
- This is the fourth item in an unordered list and links to my [GitHub page](https://www.github.com/Mariosyian).

+ This is the first item in an ordered list.
+ This is the second item in an ordered list.
+ **This is the third item in an ordered list and it's bold**.
+ This is the fourth item in an ordered list and links to my [GitHub page](https://www.github.com/Mariosyian).
   -----
# HTML
<ul>
<li>This is the first item in an unordered list.</li>
<li>This is the second item in an unordered list.</li>
<li><b>This is the third item in an unordered list and it's bold.</b></li>
<li>This is the fourth item in an unordered list and links to my <a href="https://www.github.com/Mariosyian">GitHub page</a>.</li>
</ul>

<ol>
<li>This is the first item in an unordered list.</li>
<li>This is the second item in an unordered list.</li>
<li><b>This is the third item in an unordered list and it's bold.</b></li>
<li>This is the fourth item in an unordered list and links to my <a href="https://www.github.com/Mariosyian">GitHub page</a>.</li>
</ol>
```
- This is the first item in an unordered list.
- This is the second item in an unordered list.
- **This is the third item in an unordered list and it's bold**.
- This is the fourth item in an unordered list and links to my [GitHub page](https://www.github.com/Mariosyian).

The plus sign is interpreted as an unordered list in most Markdown parsers.
---
## Anchor tags / Hyperlinks | `<a>`
A hyperlink or `<a>` element is defined as `[text to display](URL)`. A hyperlink may only contain plain text (i.e. does not parse styling patterns).
```
# Markdown
This line contains a hyperlink to my [GitHub page](https://www.github.com/Mariosyian).
   -----
# HTML
<p>This line contains a hyperlink to my <a href="https://www.github.com/Mariosyian">GitHub page</a></p>
```
This line contains a hyperlink to my [GitHub page](https://www.github.com/Mariosyian).

---
## Images | `<img>`
An image or `<img>` element is defined as `![alternate text](URL)`.
```
# Markdown
This line contains an image of a muffin ![It's muffin time!](https://static.wikia.nocookie.net/asdfmovie/images/1/1d/Muffin.png/revision/latest/scale-to-width-down/148?cb=20180617145555) with alternate text 'It's muffin time!'.
   -----
# HTML
<p>This line contains an image of a muffin <img src="https://static.wikia.nocookie.net/asdfmovie/images/1/1d/Muffin.png/revision/latest/scale-to-width-down/148?cb=20180617145555" alt="It's muffin time!"></p>
```
This line contains an image of a muffin ![It's muffin time!](https://static.wikia.nocookie.net/asdfmovie/images/1/1d/Muffin.png/revision/latest/scale-to-width-down/148?cb=20180617145555) with alternate text 'It's muffin time!'.

---
## BlockQuote | `<blockquote>`
A blockquote is defined by a `>` character followed by a single space, and is contained in a single line. Multiple blockquotes with no empty line in-between, are rendered as a single multiline blockquote. The `>` character must be the first character in the line.

Blockquote lines support plain and stylised text.
```
# Markdown
> This is a blockquote

> This is the first item in a multiline blockquote.
> **This is the second item in a blockquote and it's bold**.
> *This is the third item in a blockquote and it's italic*.
> ***This is the fourth item in a blockquote and it's both***.
> This is the fifth item in a blockquote and it's part plain, **part bold**, and *part italic*.
   -----
# HTML
<blockquote>
<p>This is a blockquote</p>
</blockquote>

<blockquote>
<p>This is the first item in a multiline blockquote.</p>
<p>This is the second item in a blockquote and it's bold.</p>
<p>This is the third item in a blockquote and it's italic.</p>
<p>This is the fourth item in a blockquote and it's both.</p>
<p>This is the fifth item in a blockquote and it's part plain, part bold, and part italic.</p>
</blockquote>
```
> This is a blockquote

> This is the first item in a multiline blockquote.
> **This is the second item in a blockquote and it's bold**.
> *This is the third item in a blockquote and it's italic*.
> ***This is the fourth item in a blockquote and it's both***.
> This is the fifth item in a blockquote and it's part plain, **part bold**, and *part italic*.
