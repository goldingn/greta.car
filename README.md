
<!-- README.md is generated from README.Rmd. Please edit that file -->

# greta.car

<!-- badges: start -->
<!-- once you've signed into travis and set it to wath your new repository, you can edit the following badges to point to your repo -->

[![Codecov test
coverage](https://codecov.io/gh/greta-dev/greta.car/branch/main/graph/badge.svg)](https://codecov.io/gh/greta-dev/greta.car?branch=main)
[![R-CMD-check](https://github.com/goldingn/greta.car/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/goldingn/greta.car/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

This is an experimental extension package to greta for implementing
conditional autoregressive models. Currently implemented is an
experimental `icar()` distribution for efficiently modelling intrisic
conditional autoregressive models, and an example analysis for it

Define an ICAR model on a network

``` r
# define a network on a ring with a given number of nodes
n_nodes <- 20
edges <- cbind(1:n_nodes, c(2:n_nodes, 1))
```

Simulate some true parameters and fake Gaussian observations at each

``` r
true_phi <- rnorm(n_nodes)
true_phi <- true_phi - sum(true_phi) / n_nodes
# sum(true_phi)
true_intercept <- 2
true_sd <- 0.2
y <- rnorm(n = n_nodes,
           mean = true_intercept + true_phi,
           sd = true_sd)
```

Visualise this data with igraph

``` r
library(igraph)
g <- graph_from_edgelist(edges, directed = FALSE)
scale <- y
scale <- scale - min(scale)
scale <- scale / max(scale)
V(g)$color <- grey(scale)
plot(g)
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

Define a greta model for this

``` r
library(greta.car)
#> Loading required package: greta
#> 
#> Attaching package: 'greta'
#> The following objects are masked from 'package:stats':
#> 
#>     binomial, cov2cor, poisson
#> The following objects are masked from 'package:base':
#> 
#>     %*%, apply, backsolve, beta, chol2inv, colMeans, colSums, diag,
#>     eigen, forwardsolve, gamma, identity, rowMeans, rowSums, sweep,
#>     tapply

# define an ICAR random effect on this network
phi <- icar(edges)
#> ℹ Initialising python and checking dependencies, this may take a moment.
#> ✔ Initialising python and checking dependencies ... done!               
# phi has length n_nodes (extracted from 'edges')

# apply soft sum-to-zero, to avoid identifiability issues
nil <- zeros(1)
distribution(nil) <- normal(sum(phi), n_nodes * 0.001)

# define an observation model for the data
intercept <- normal(0, 1)
sd <- normal(0, 1, truncation = c(0, Inf))
distribution(y) <- normal(intercept + t(phi), sd)
```

Fit the model by MCMC

``` r
m <- model(phi)
draws <- mcmc(m)
#> running 4 chains simultaneously on up to 8 CPU cores
#> 
#>     warmup                                           0/1000 | eta:  ?s              warmup ==                                       50/1000 | eta: 20s | 9% bad     warmup ====                                    100/1000 | eta: 11s | 4% bad     warmup ======                                  150/1000 | eta:  8s | 3% bad     warmup ========                                200/1000 | eta:  6s | 2% bad     warmup ==========                              250/1000 | eta:  5s | 2% bad     warmup ===========                             300/1000 | eta:  4s | 2% bad     warmup =============                           350/1000 | eta:  4s | 1% bad     warmup ===============                         400/1000 | eta:  3s | 1% bad     warmup =================                       450/1000 | eta:  3s | 1% bad     warmup ===================                     500/1000 | eta:  3s | <1% bad    warmup =====================                   550/1000 | eta:  2s | <1% bad    warmup =======================                 600/1000 | eta:  2s | <1% bad    warmup =========================               650/1000 | eta:  2s | <1% bad    warmup ===========================             700/1000 | eta:  1s | <1% bad    warmup ============================            750/1000 | eta:  1s | <1% bad    warmup ==============================          800/1000 | eta:  1s | <1% bad    warmup ================================        850/1000 | eta:  1s | <1% bad    warmup ==================================      900/1000 | eta:  0s | <1% bad    warmup ====================================    950/1000 | eta:  0s | <1% bad    warmup ====================================== 1000/1000 | eta:  0s | <1% bad
#>   sampling                                           0/1000 | eta:  ?s            sampling ==                                       50/1000 | eta:  2s            sampling ====                                    100/1000 | eta:  2s            sampling ======                                  150/1000 | eta:  2s            sampling ========                                200/1000 | eta:  2s            sampling ==========                              250/1000 | eta:  2s            sampling ===========                             300/1000 | eta:  2s            sampling =============                           350/1000 | eta:  1s            sampling ===============                         400/1000 | eta:  1s            sampling =================                       450/1000 | eta:  1s            sampling ===================                     500/1000 | eta:  1s            sampling =====================                   550/1000 | eta:  1s            sampling =======================                 600/1000 | eta:  1s            sampling =========================               650/1000 | eta:  1s            sampling ===========================             700/1000 | eta:  1s            sampling ============================            750/1000 | eta:  1s            sampling ==============================          800/1000 | eta:  0s            sampling ================================        850/1000 | eta:  0s            sampling ==================================      900/1000 | eta:  0s            sampling ====================================    950/1000 | eta:  0s            sampling ====================================== 1000/1000 | eta:  0s
```

Check convergence of chains (results hidden here)

``` r
coda::gelman.diag(draws, autoburnin = FALSE, multivariate = FALSE)
plot(draws)
```

Plot concordance of phi estimates with ‘true’ values

``` r
estimate <- summary(draws)$statistics[, "Mean"]
ci <- summary(draws)$quantiles[, c("2.5%", "97.5%")]
truth <- c(true_phi)
plot(estimate ~ truth,
     ylim = range(ci))
arrows(x0 = truth,
       x1 = truth,
       y0 = ci[, 1],
       y1 = ci[, 2], length = 0)
abline(0, 1, lty = 2)
```

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

Visualise the posterior means with iGraph (note the orders and locations
of nodes have changed from the above)

``` r
library(igraph)
g <- graph_from_edgelist(edges, directed = FALSE)
scale <- estimate
scale <- scale - min(scale)
scale <- scale / max(scale)
V(g)$color <- grey(scale)
plot(g)
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="100%" />

------------------------------------------------------------------------

The package infrastructure itself is from the
[greta.template](https://github.com/greta-dev/greta.template) repo, and
checklist for setting that up remains below.

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
- [x] Write a simple example introducing the package and add it to
  `R/package.R`
- [x] Update `README.Rmd` to sell to people with a sales pitch and maybe
  an example that creates a figure, to get people excited about your
  package.
- [x] Start adding functions, documentation and examples to new R files
  in `R` folder
- [ ] Write some unit tests for these functions in the `tests/testthat`
  folder
- [x] Delete the example function and test files `R/square.R` and
  `tests/testthat/test-square.R`
