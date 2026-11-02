#let project_name = "Deductive Verifier for IMP with Exceptions"
#let course = "CSE 610 Fall 2026"
#let authors = (
  "Vincent Chan",
  "Hongbin Jin",
  "Zhengsong Zhang",
)

#set page(
  header: [
    #project_name #h(1fr) #course
  ],
  number-align: center,
  numbering: "1",
)

#set heading(numbering: "1.1")

#let CodeBloc(content) = block(
  fill: luma(240),
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
    v(0.6em)
    set text(size: 1.1em, weight: "regular")
    authors.join(", ")
    v(0.6em)
  }),
)

#maketitle()

= Project Overview
<Project-Overview>
In this project, we plan to build an automated deductive verifier for modular IMP programs supporting exceptions.
With this verifier, users are able to reason about both normal and exceptional program behaviors using an assertion language.
Based on Hoare logic, verification conditions are generated from behavioral specifications expressed in the assertion language and checked by the Z3 SMT solver.

= Background
<Background>
// Some references

While monadic styles of error handling gain increasing popularity (e.g., #link("https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html#recoverable-errors-with-result")[Rust's approach to deal with recoverable errors] and C++ 23's introduction of #link("https://en.cppreference.com/cpp/utility/expected")[std::expected], exception handling is still a useful feature.
In C++, there is almost no performance overhead on normal paths of a program that may raise exceptions #cite(<cpp-error-speed>).
Though it is claimed that exceptions are almost never faster than result handling for control flow purposes #cite(<cpp-eh-bench>), a close examination shows that the compiled code for the two styles of error handling are equivalent due to control-flow merging.
However, using exceptions, error paths are much slower partly because of unwinding call stacks.
If a program expects errors are common, using exceptions can insur a heavy performance penalty.
In summary, two approaches have their own suitable use cases as they may demonstrate different performance characteristics under different settings.

Deductive verification about exceptions has been well studied in general.
Given only one kind of exceptions, a program state is extended with a boolean variable indicating whether an error has been raised #cite(<hoare-logics-hol>).
Xavier Leroy #cite(<unified-early-exits>) presented a unified treament of different sorts of early exits with exceptions being one.
For Hoare triples, postconditions are augmented so that properties about normal and exceptional states are clearly separated.
Along with other updated rules, Hoare logic for expcetion constructs are formulated as
$
\{ P \} "raise" E \{ [op("exn")(E) |-> P] \}
$
$
frac(
  \{ P \} s_1 \{ Q + [op("exn")(E) |-> R] \}
  quad
  \{ R \} s_2 \{ Q \},
  \{ P \} "try" s_1 "catch" E arrow.r s_2 \{ Q \}
)
$
where $[Q + op("exn")(E) |-> P]$ denotes normal and exceptional postconditions $Q$ and $P$ respectively.
Marco Paganoni et al. #cite(<byteback-exception>) introduced a practical approach to verify the exceptional behavior of Java programs at the level of the virtual machine.
Exceptional behavor can be specified for a Java method using the `@Raise` annotation, which accepts with exception classes raised and predicates.
When invoking a method with exceptional specifications, the caller must either hanlde the exceptions directly using a `try-catch` block or specifiy them in more or less detail in the signature.
Even though deductive verification of IMP programs with exceptions could hardly be a good research problem, it serves a good educational purpose.

= Feature
<Feature>
// With motivating example

The extended IMP language has the following features:

1. Arithmetic expressions supporting only arbitrary-precision integers, and boolean expressions which can only be used in control flow.

2. Functions with zero or more parameters and one return values. High-order functions are not supported.

3. Supported commands include `skip`, assignment, sequence, conditional, while loop, `raise` and `try-catch` to throw and handle exceptions, `exception` for defining custom exceptions.

4. Tag-like exceptions which do not associate any data, e.g., `exception DivisionByZero;`.

The assertion logic supports:

5. Logical statements involving only variables, constants, and three logical connectives (`AND`, `OR`, and `NOT`).

6. For functions, `requires`, `ensures`, and `raises` are used for preconditions, normal and exceptional postconditions respectively.

7. To achieve total correctness, `variant` and `invariant` can be used specify loop variants and invariants.

8. Inside functions, users can introduce preconditions and postconditions via `assume` and `assert`.

The following is an example of IMP program with behavioral specifications:

<target_imp_code>
```imp
exception DivisionByZero;

fn slow_mul(a, b) returns prod
  requires a >= 0 && b >= 0
  ensures prod == a * b
{
  prod := 0;
  n := 0;
  while n < b
    variant b - n
    invariant prod == a * n && n <= b
  {
    prod := prod + a;
    n := n + 1;
  }
}

fn check_divisor(d)
  ensures d != 0
  raises(DivisionByZero) d == 0
{
  if d == 0 {
    raise DivisionByZero;
  }
}

fn div(n, d) returns q
  requires n >= 0 && d >= 0
  raises(DivisionByZero) d == 0
{
  check_divisor(d);
  q := n / d;
  assert q * d <= n;
}

fn main() returns ret
{
  try {
    div(10, 0);
  } catch DivisionByZero {
    ret := -1;
  }
  ret := 0;
}
```

= Design Plan
<Design-Plan>
// What will be defined

1. Formal syntax of extend IMP language and assertion logic.

2. Simple type checker for IMP and assertion, e.g., number of arguments is correct for function application.

3. Semantics of extend IMP language.

4. Hoare logic rules for all language constructs.

5. Generation and checking of verification conditions.

= Evaluation
<Evaluation>

1. Our tool should be able to identify syntactic and type errors while be silent about well-formed programs. To test, we give both correct and incorrect MP programs to our tool and check whether expected results are returned.

2. Deductive verification should be automated correctly. Given an IMP with correct specifications, the verifier should prove that all the properties hold. For an incorrectly specified program, the tool should be able to identify the statements which cannot be verified. In cases where Z3 cannot check verification conditions in a reasonable amount of time, the verifier should report users about the situation.

= Scope
<Scope>
// Minimum, expected, and stretch outcome

== Unsupported Features

As the project goal is not to build a comprehensive deductive verifier, it does not support the following features:

1. The language does not support arrays so there is no related verification.

2. Though recursive functions are supported, we decide to not verify their total correctness, that is, only partial correctness of functions are verified. We believe that the rules to verify the total correctness of while loops should also apply to recursive functions.

== Supported Features

Since the project is about verification of exceptional behavior, we should support at least exception raising and handling for an IMP code snippet, for example,

```imp
try {
  d := 1;
  raise DivisionByZero;
} catch DivisionByZero {
  d := 0;
}
assert d >= 0;
```

The tool aims at automated verification of IMP programs involving functions, while loops, and exceptions handling, like #link(<target_imp_code>)[the example code] in the section Feature.

== Maybe Supported Features

If time allows, we hope to implement

1. An IMP interpreter based on the defined semantics.

2. A front-end for static compilation, e.g., translating IMP to LLVM IRs.

= Implementation Roadmap
<Implementation-Roadmap>
// Timeline and Goal, what tool will use

Using Ocaml, We plan to implement the following core compoennts:

1. Lexer and parser implemented with `ocamllex` and `Menhir`, which is supposed to be done with AI assistance.

2. Type checker.

3. Generator and checker verification conditions based on Z3 SMT solver and its OCaml bindings.

4. (Optional) IMP interpreter.

5. An IMP compiler front-end based on LLVM and the related OCaml bindings.

Proposed timeline is as follows,

- Week November 2: lexer and parser.

- Week November 9: type checker and VC generator.

- Week November 16: VC generator.

- Week November 23: Integrated testing.

- Week November 30: Prepare for demo and the final report.

#bibliography("ref.bib", title: [References])
