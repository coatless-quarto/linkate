-- linkate tests. Run from the repo root: quarto pandoc lua path/to/qtest.lua
local t = require("qtest")

t.test("html: autolinks, inline and reference links are collected under Links, after the last block", function()
  local r = t.render("basic.qmd", "html")
  r:succeeded()
  t.count(r.text, "<h1>Links</h1>", 1)
  t.in_order(r.text, {
    "The last paragraph.",
    "<h1>Links</h1>",
    '<li><a href="https://autolink.example.com" class="uri">https://autolink.example.com</a></li>',
    '<li><a href="https://inline.example.com">inline link</a></li>',
    '<li><a href="https://reference.example.com">reference link</a></li>',
  })
end)

t.test("a link repeated with the same text is listed once; other text for the same URL is its own entry", function()
  local r = t.render("basic.qmd", "html")
  t.count(r.text, '<li><a href="https://inline.example.com">inline link</a></li>', 1)
  t.count(r.text, '<li><a href="https://inline.example.com">other text</a></li>', 1)
  -- The links in the text stay where they are: 3 in the body, 2 in the list
  t.count(r.text, 'href="https://inline.example.com"', 5)
end)

t.test("a document without links gets no Links section", function()
  local r = t.render("none.qmd", "html")
  r:succeeded()
  t.not_contains(r.text, ">Links</h")
end)

t.test("revealjs: more than 6 links make a scrollable Links slide with a hint", function()
  local r = t.render("slides-many.qmd", "revealjs")
  r:succeeded()
  t.in_order(r.text, {
    '<section class="slide level2 scrollable">', "<h2>Links</h2>",
    "<em>Scroll to see more links</em>", 'href="https://site7.example.com"',
  })
end)

t.test("revealjs: 6 links fit on a plain Links slide, without the hint", function()
  local r = t.render("slides-few.qmd", "revealjs")
  r:succeeded()
  t.in_order(r.text, { '<section class="slide level2">', "<h2>Links</h2>", 'href="https://site6.example.com"' })
  t.not_contains(r.text, "level2 scrollable")
  t.not_contains(r.text, "Scroll to see more links")
end)

t.test("typst: the Links section lists the links", function()
  local r = t.render("basic.qmd", "typst")
  r:succeeded()
  t.in_order(r.text, { "The last paragraph.", "Links", '#link("https://reference.example.com")[reference link]' })
end)

t.test("docx: the Links section lists the links", function()
  local r = t.render("basic.qmd", "docx")
  r:succeeded()
  t.in_order(r.text, { 'Str "paragraph."', 'Header 1 ( "links"', '"https://reference.example.com"' })
end)
