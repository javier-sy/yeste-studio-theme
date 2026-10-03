#!/usr/bin/env python3
"""Compares two built pages for what a visitor gets, ignoring formatting.

    scripts/compare-html.py BEFORE.html AFTER.html

The markup is compared as a stream of tags (attributes sorted, class lists sorted) and text
(whitespace collapsed); the CSS of every <style> block is compared as a set of rules, so moving
rules between blocks or files does not count as a change. Prints the differences and exits 1
when there are any.
"""
import difflib, re, sys
from html.parser import HTMLParser


class Page(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.tokens, self.css, self._in_style, self._text = [], [], False, []

    def _flush(self):
        text = re.sub(r"\s+", " ", "".join(self._text)).strip()
        if text:
            self.tokens.append("TEXT " + text)
        self._text = []

    def handle_starttag(self, tag, attrs):
        if tag == "style":
            self._flush(); self._in_style = True; return
        self._flush()
        norm = []
        for name, value in sorted(attrs):
            if name == "class" and value:
                value = " ".join(sorted(value.split()))
            norm.append(f'{name}="{value}"' if value is not None else name)
        self.tokens.append(f"<{tag} {' '.join(norm)}>".replace(" >", ">"))

    def handle_startendtag(self, tag, attrs):
        # <br> and <br /> are the same element
        self.handle_starttag(tag, attrs)

    def handle_endtag(self, tag):
        if tag == "style":
            self._in_style = False; return
        self._flush()
        self.tokens.append(f"</{tag}>")

    def handle_data(self, data):
        if self._in_style:
            self.css.append(data)
        else:
            self._text.append(data)


def css_rules(css):
    """Top-level CSS blocks (rules and @media blocks), whitespace removed."""
    css = re.sub(r"/\*.*?\*/", "", css, flags=re.S)
    css = re.sub(r"\s+", " ", css)
    rules, depth, start = [], 0, 0
    for i, ch in enumerate(css):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                rules.append(re.sub(r"\s*([{}:;,>])\s*", r"\1", css[start:i + 1].strip()))
                start = i + 1
    return rules


def load(path):
    page = Page()
    page.feed(open(path, encoding="utf-8").read())
    page.close()
    return page.tokens, sorted(css_rules("".join(page.css)))


(before_html, before_css), (after_html, after_css) = load(sys.argv[1]), load(sys.argv[2])
changed = False
for label, a, b in (("markup", before_html, after_html), ("css", before_css, after_css)):
    diff = list(difflib.unified_diff(a, b, "before", "after", lineterm="", n=2))
    if diff:
        changed = True
        print(f"== {label}: differs")
        print("\n".join(diff))
    else:
        print(f"== {label}: same")
sys.exit(1 if changed else 0)
