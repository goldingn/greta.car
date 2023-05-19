# this R file is just here to produce a package-level helpfile for people to
# look at when they get started

#' @title Conditional Autoregressive Models in greta
#' @name greta.car
#'
#' @description Distributions and utility functions that extend greta by making
#'   it easy to define conditional autoregressive models.
#'
#' @docType package
#'
#' @importFrom tensorflow tf
#' @importFrom greta .internals
#' @importFrom R6 R6Class
#'
#' @examples
#'
#' # fit an ICAR model on a network to fake data
#' 
#' # define a network on a ring with a given number of nodes
#' n_nodes <- 5
#' edges <- cbind(1:n_nodes, c(2:n_nodes, 1))
#'
#' # make some fake Gaussian observations for each node
#' set.seed(2023-05-19)
#' true_phi <- rnorm(n_nodes)
#' true_phi <- true_phi - sum(true_phi) / n_nodes
#' # sum(true_phi)
#' true_intercept <- 2
#' true_sd <- 0.2
#' y <- rnorm(n = n_nodes,
#'            mean = true_intercept + true_phi,
#'            sd = true_sd)
#' 
#' # define an ICAR random effect on this network
#' phi <- icar(edges)
#' # phi has length n_nodes (extracted from 'edges')
#' 
#' # apply soft sum-to-zero, to avoid identifiability issues
#' nil <- zeros(1)
#' distribution(nil) <- normal(sum(phi), n_nodes * 0.001)
#' 
#' # define an observation model for the data
#' intercept <- normal(0, 1)
#' sd <- normal(0, 1, truncation = c(0, Inf))
#' distribution(y) <- normal(intercept + t(phi), sd)
#' 
#' \dontrun{
#' # fit the model and plot estimates
#' m <- model(phi)
#' draws <- mcmc(m)
#' 
#' # check convergence of chains
#' coda::gelman.diag(draws, autoburnin = FALSE, multivariate = FALSE)
#' plot(draws)
#' 
#' # plot concordance of phi estimates with 'true' values
#' estimate <- summary(draws)$statistics[, "Mean"]
#' ci <- summary(draws)$quantiles[, c("2.5%", "97.5%")]
#' truth <- c(true_phi)
#' plot(estimate ~ truth,
#'      ylim = range(ci))
#' arrows(x0 = truth,
#'        x1 = truth,
#'        y0 = ci[, 1],
#'        y1 = ci[, 2], length = 0)
#' abline(0, 1)
#' }
#' 
NULL
