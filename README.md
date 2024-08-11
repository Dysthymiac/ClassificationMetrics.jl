# ClassificationMetrics


*Classification metrics calculation and reporting for Julia.*

| **Documentation**                                                               | **Build Status**                                                                                |
|:-------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------:|
| [![][docs-stable-img]][docs-stable-url] [![][docs-dev-img]][docs-dev-url] | [![][status-img]][status-url] [![][aqua-img]][aqua-url] [![][jet-img]][jet-url] |


## Installation

The package can be installed with the Julia package manager. Currently, the package is not in the general registry.
From the Julia REPL, type `]` to enter the Pkg REPL mode and run:

```
pkg> add https://github.com/Dysthymiac/ClassificationMetrics.jl
```

Or, equivalently, via the `Pkg` API:

```julia
julia> import Pkg; Pkg.add("https://github.com/Dysthymiac/ClassificationMetrics.jl")
```

## Documentation

- [**STABLE**][docs-stable-url] &mdash; **documentation of the most recently tagged version.**
- [**DEVEL**][docs-dev-url] &mdash; *documentation of the in-development version.*

## Project Status

The package is tested against, and being developed for, Julia `1.7` and above on Linux and Windows.

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://Dysthymiac.github.io/ClassificationMetrics.jl/dev

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://Dysthymiac.github.io/ClassificationMetrics.jl/stable/

[status-img]: https://github.com/Dysthymiac/ClassificationMetrics.jl/actions/workflows/CI.yml/badge.svg?branch=main
[status-url]: https://github.com/Dysthymiac/ClassificationMetrics.jl/actions/workflows/CI.yml?query=branch%3Amain
[aqua-img]: https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg
[aqua-url]: https://github.com/JuliaTesting/Aqua.jl
[jet-img]: https://img.shields.io/badge/%F0%9F%9B%A9%EF%B8%8F_tested_with-JET.jl-233f9a
[jet-url]: https://github.com/aviatesk/JET.jl