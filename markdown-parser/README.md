# Markdown Parser

This is a shaved down version of the [Common Mark spec markdown parser](https://spec.commonmark.org/0.30/#introduction).

## Paragraph | `<p>`
A normal paragraph or `<p>` element is a string of alphanumeric characters, along with any special characters that are not reserved for Markdown parsing. The list contains (but not limited to) `abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 '"./\@$%&-=+;:<,?{}[]()|~` and as a regex `$[a-zA-Z0-9 '"./\@$%&-=+;:<>,?{}[]()|~]^`. Depending on how they are used, some of these characters may be parsed as markdown

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
*This line should is italic.*
**This line should is bold.**
***This line should is both bold and italic.***
_This line is underlined_
   -----
# HTML
<i>This line should is italic.</i>
<b>This line should is bold.</b>
<b><i>This line should is both bold and italic.</i></b>
<p style="text-decoration: underline;">This line is underlined</p>
```
*This line should is italic.*

**This line should is bold.**

***This line should is both bold and italic.***

The underline is not supported by most Markdown parsers, and the underscore `_` is usually used similary to the `*` for italic and bold.

---
## (Unordered) Lists | `<ol>`
Currently, this markdown parser only supports unordered lists, or the `<ol>` element.  It's defined as `- List Item 1`. This only supports plain or stylised text, and hyperlinks.
```
# Markdown
- This is the first item in an unordered list.
- This is the second item in an unordered list.
- **This is the third item in an unordered list and it's bold**.
- This is the fourth item in an unordered list and links to my [GitHub page](https://www.github.com/Mariosyian).
   -----
# HTML
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

---
## Anchor tags / Hyperlinks | `<a>`
A hyperlink or `<a>` element is defined as `[text to display](URL)`. A hyperlink can be styled as described in the #Styling section.
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
A blockquote is defined by a `>` character followed by a single space, and is contained in a single line.
```
# Markdown
> This is a blockquote
   -----
# HTML
<blockquote>
<p>This is a blockquote</p>
</blockquote>
```
> This is a blockquote

---
## Code spans | `<pre><code>`
A code span or `<pre><code>` element is defined as ` ``` ` and spans multiple lines until another ` ``` ` pattern is met. Everything inside a code block is interpreted as plain text.
```
# Markdown
\```
# This should have been an <h1> but is plain text because it's inside a code block.
** This line should have been bold but is plain text because it's inside a code block.**
This line should have had a hyperlink to my [GitHub page](https://www.github.com/Mariosyian) but is plain text because it's inside a code block.
\```
   -----
# HTML
<pre><code>
<p>
# This should have been an <h1> but is plain text because it's inside a code block.
** This line should have been bold but is plain text because it's inside a code block.**
This line should have had a hyperlink to my [GitHub page](https://www.github.com/Mariosyian) but is plain text because it's inside a code block.
</p>
</code></pre>
```
```
# This should have been an <h1> but is plain text because it's inside a code block.
** This line should have been bold but is plain text because it's inside a code block.**
This line should have had a hyperlink to my [GitHub page](https://www.github.com/Mariosyian) but is plain text because it's inside a code block.
```
