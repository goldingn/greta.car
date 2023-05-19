
<!-- README.md is generated from README.Rmd. Please edit that file -->

# greta.car

<!-- badges: start -->
<!-- once you've signed into travis and set it to wath your new repository, you can edit the following badges to point to your repo -->

[![Codecov test
coverage](https://codecov.io/gh/greta-dev/greta.car/branch/main/graph/badge.svg)](https://codecov.io/gh/greta-dev/greta.car?branch=main)
[![R-CMD-check](https://github.com/goldingn/greta.car/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/goldingn/greta.car/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

This is an experimental extension package to greta for implementing
conditional autoregressive models. The package infrastructure itself is
from the [greta.template](https://github.com/greta-dev/greta.template)
repo.

#### to do list

- [x] Pick a package name (preferably with ‘greta.’ at the beginning).
  Update the package name in:
  - [x] the ‘Package’ field in `DESCRIPTION`
  - [x] the `library()` and `test_check()` calls in `tests/testthat.R`
  - [x] in the `@name` documentation field in `R/package.R`
  - [x] at the top of `README.Rmd`
  - [x] the repo name (if it changed since you made it)
  - [x] the R project file; rename it from `greta.template.Rproj` to
    `greta.<something>.Rproj`
- [x] Come up with a helpful package title. Add it to:
  - [x] the ‘Title’ field in `DESCRIPTION`
  - [x] the `@title` documentation field in `R/package.R`
  - [x] at the top of your GitHub repo
- [x] Fill in the the author details in `DESCRIPTION`
- [x] Update the ‘URL’ and ‘BugReports’ fields in `DESCRIPTION` to point
  to your repo
- [x] Decide what sort of license you want to use for your package (you
  are completely free to change the CC0 license in the template). See
  [https://choosealicense.com]() or
  [r-pkgs.org](https://r-pkgs.org/description.html#license) for help
  choosing.
  - [x] create the license file and edit the ‘License’ field in
    `DESCRIPTION` (e.g. with [the `usethis`
    package](https://usethis.r-lib.org/reference/licenses.html))
- [x] Write short paragraph describing the package. Copy it to:
  - [x] the ‘Description’ field of `DESCRIPTION`
  - [x] the `@description` documentation field of `R/package.R`
- [x] add a github actions badge with `use_github_actions_badge()`
- [x] edit the [codecov](https://codecov.io) badge in `README.Rmd` to
  point to your package
- [ ] Write a simple example introducing the package and add it to
  `R/package.R`
- [ ] Update `README.Rmd` to sell to people with a sales pitch and maybe
  an example that creates a figure, to get people excited about your
  package.
- [ ] Start adding functions, documentation and examples to new R files
  in `R` folder
- [ ] Write some unit tests for these functions in the `tests/testthat`
  folder
- [ ] Delete the example function and test files `R/square.R` and
  `tests/testthat/test-square.R`
