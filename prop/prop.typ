#let project_name = "Alive2"
#let course = "CSE 610 Fall 2026"

#set page(
  header: [
    #project_name #h(1fr) #course
  ],
  number-align: center,
  numbering: "1",
)

#set heading(numbering: "1")

#let CodeBloc(content) = block(
  fill: luma,
  inset: 1em,
  radius: 0.5em,
  width: 100%,
  content,
)

#show raw.where(block: true): CodeBloc
#show link: it => underline(text(fill: blue)[#it])
#show ref: it => text(fill: blue)[#it]

#let maketitle() = block(
  width: 100%,
  align(center, {
    text(size: 1.8em, weight: "bold")[#project_name]
  }),
)

#maketitle()

= Project Overview
<Project-Overview>
// 2-3 sentensces.

= Background
<Background>
// Some references

= Feature
<Feature>
// With motivating example

= Design Plan
<Design-Plan>
// What will be defined

= Evaluation
<Evaluation>
// How to test the project

= Scope
<Scope>
// Minimum, expected, and stretch outcome

= Implementation Roadmap
<Implementation-Roadmap>
// Timeline and Goal, what tool will use
