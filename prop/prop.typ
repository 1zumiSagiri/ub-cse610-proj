#import "@preview/curryst:0.6.0": prooftree, rule, rule-set
#let project_name = "Deductive Verifier for IMP with Exceptions"
#let course = "CSE 610 Fall 2026"
#let authors = (
    "Vincent Chan",
    "Hongbin Jin",
    "Zhengsong Zhang",
)

#set page(
    margin: (x: 0.7in, y: 0.6in),
    header: text(size: 7pt)[#project_name #h(1fr) #course],
    header-ascent: 20%,
    number-align: center,
    numbering: "1",
)
#set text(size: 11pt)
#set par(justify: true, leading: 0.55em, spacing: 0.6em)
#set heading(numbering: "1")
#show heading: set text(size: 11pt)
#show heading: set block(above: 0.8em, below: 0.4em)

#show raw: set text(size: 8pt)
#show raw.where(block: true): it => block(
    fill: luma(240),
    inset: 0.5em,
    radius: 0.3em,
    width: 100%,
    it,
)

#let sc(x) = smallcaps(x)

#let R(name, concl, ..prems) = prooftree(rule(
    label: text(size: 0.85em, sc(name)),
    ..prems.pos(),
    concl,
))

#let rules(..items) = {
    let groups = ((),)
    for it in items.pos() {
        if it == "br" { groups.push(()) } else { groups.last().push(it) }
    }
    align(center, block(width: 100%, {
        set par(justify: false)
        for g in groups {
            block(rule-set(column-gutter: 2em, row-gutter: 1.6em, ..g))
        }
    }))
}

#show link: it => underline(text(fill: blue)[#it])
#show ref: it => text(fill: blue)[#it]

#align(center)[
    #text(size: 1.4em, weight: "bold")[#project_name] \
    #authors.join(", ")
]

= Project Overview
We plan to build an automated deductive verifier in OCaml for modular IMP programs with exceptions.
Users specify normal and exceptional behavior in an assertion language; verification conditions (VCs) are generated from Hoare-style rules and checked by Z3.

= Background
Although monadic error handling (Rust's `Result`, C++23 `std::expected`) is increasingly popular, exceptions remain useful.
In C++ they add almost no overhead on normal paths #cite(<cpp-error-speed>), but error paths are much slower because of stack unwinding #cite(<cpp-eh-bench>), so the two styles suit different settings.
Deductive verification of exceptions is well studied.
With one kind of exception, the state is extended with a boolean "error raised" flag #cite(<hoare-logics-hol>).
Leroy #cite(<unified-early-exits>) treats early exits uniformly by splitting postconditions into normal and exceptional parts, giving
#rules(
    R("Raise", ${P} "raise" E {[op("exn")(E) |-> P]}$),
    R(
        "Try-Catch",
        ${P} "try" s_1 "catch" E arrow.r s_2 {Q}$,
        ${P} s_1 {Q + [op("exn")(E) |-> R]}$,
        ${R} s_2 {Q}$,
    ),
)
ByteBack #cite(<byteback-exception>) verifies Java exceptional behavior with `@Raise` annotations, and callers must handle or declare the listed exceptions.
Verifying IMP with exceptions is hardly a research problem, but it serves a good educational purpose.

= Features
<Features>
*Language.* (1) Unbounded integer arithmetic; boolean expressions only in control flow. (2) Functions with zero or more parameters and one return value; no higher-order functions. (3) Commands: `skip`, assignment, sequence, `if`, `while`, `raise`, `try-catch`, and `exception` declarations. (4) Tag-like exceptions that carry no data, e.g., `exception NegativeNumber;`.
*Assertions.* (5) Formulas over variables, constants, and `AND`/`OR`/`NOT`. (6) `requires`, `ensures`, `raises` give pre-, normal post-, and exceptional postconditions. (7) `variant`/`invariant` on loops give total correctness. (8) `assume`/`assert` inside function bodies.

#grid(
    columns: (1fr, 1fr),
    gutter: 0.8em,
    ```imp
    exception NegativeNumber;
    fn slow_mul(a, b) returns prod
      requires a >= 0 && b >= 0
      ensures prod == a * b
    {
      prod := 0; n := 0;
      while n < b
        variant b - n
        invariant prod == a * n && n <= b
      { prod := prod + a; n := n + 1; }
    }
    fn check_divisor(d)
      ensures d != 0
      raises(NegativeNumber) d == 0
    { if d == 0 { raise NegativeNumber; } }
    ```,
    ```imp
    fn div(n, d) returns q
      requires n >= 0 && d >= 0
      raises(NegativeNumber) d == 0
    {
      check_divisor(d);
      q := n / d;
      assert q * d <= n;
    }
    fn main() returns ret
    {
      try { div(10, 0); ret := 0; }
      catch NegativeNumber { ret := -1; }
    }
    ```,
)

= Design Plan and Evaluation
We will define (1) formal syntax of the language and assertions, (2) a simple type checker (e.g., argument counts), (3) its semantics, (4) Hoare rules for all constructs, and (5) VC generation and checking.
*Evaluation:* (a) well-formed programs are accepted while syntactic and type errors are reported, tested with correct and incorrect programs; (b) correctly specified programs are proven, while for incorrect ones the unverifiable statements are identified; Z3 timeouts or `unknown` results are reported to the user.

= Scope
*Minimum:* exception raising and handling in snippets such as `try { d := 1; raise NegativeNumber; } catch NegativeNumber { d := 0; } assert d >= 0;`.
*Expected:* automated verification of programs with functions, loops, and exceptions, like the example in @Features.
*Stretch:* an IMP interpreter, then a compiler front-end.
*Non-goals:* exceptions carrying data or hierarchies; `finally`; arrays, heap, strings, machine integers; concurrency and I/O; quantifiers, user-defined predicates, ghost state, `old()`; loop-invariant or spec inference; a mechanized soundness proof; counterexample generation; solver or VC optimization; IDE support and error recovery; a performance comparison of exceptions versus result types.

= Implementation Roadmap
We use `ocamllex` and `Menhir` for lexing and parsing (with AI assistance), OCaml for the type checker and VC generator, and Z3 for VCs.
*Timeline:* Nov 2: lexer, parser. Nov 9: type checker. Nov 16: VC generator. Nov 23: integrated testing. Nov 30: demo and final report.

#pagebreak()
#bibliography("ref.bib", title: [References])
