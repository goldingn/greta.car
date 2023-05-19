#' @importFrom R6 R6Class
icar_distribution <- R6Class(
  "icar_distribution",
  inherit = distribution_node,
  public = list(
    
    edges = NULL,
    
    initialize = function(edges) {

      # get the number of nodes from the edges matrix, with minimal checking
      dimension <- max(edges)
      dimension <- check_dimension(target = dimension)
      
      if (!inherits(edges, "matrix") || !is.numeric(edges) || ncol(edges) != 2) {
        msg <- cli::format_error(
          "{.arg edges} must be a two-column numeric R matrix"
        )
        stop(
          msg,
          call. = FALSE
        )
      }

      # record the edge info      
      self$edges <- edges

      dim <- c(1, dimension)
      super$initialize("icar", dim = dim, multivariate = TRUE)
      
      # set the unkown value
      self$value(unknowns(dims = dim))
      
    },
    
    # default (phi, ignores truncation)
    create_target = function(truncation) {
      
      # create variable greta array (with no constraints)
      greta_array <- variable(dim = self$dim)
      
      # return the node for the symmetric matrix
      target_node <- get_node(greta_array)
      target_node
      
    },
    
    tf_distrib = function(parameters, dag) {
      
      edges <- self$edges
    
      # the log probability is proportional to the inner product of the
      # differences in phi between adjacent nodes
        
      log_prob <- function(x) {

        # get edges as integers indexed from zero
        edges_from <- as.integer(edges[, 1] - 1L)
        edges_to <- as.integer(edges[, 2] - 1L)
        last_axis <- length(dim(x)) - 1L
        
        phi_from <- tf$gather(x, edges_from, axis = last_axis)
        phi_to <- tf$gather(x, edges_to, axis = last_axis)
        phi_diff <- phi_from - phi_to
        
        # get inner product (how is there not a dedicated TF function for this?)
        # inner <- tf$tensordot(phi_diff,
        #                       tf_transpose(phi_diff),
        #                       axes = 0:1)
        inner <- tf$matmul(phi_diff, tf_transpose(phi_diff))
        # inner <- tf$expand_dims(inner, last_axis)
        fl(-0.5) * inner
      }
      
      # note it is not possible to sample a priori from the ICAR model, since
      # the matrix cannot be inverted (the prior is improper). We could enable
      # sampling with some jitter on the matrix diagonal, but that's icky and
      # hard to convey to the user
      list(
        log_prob = log_prob,
        sample = NULL
      )
    }
  )
)

#' ICAR distribution
#'
#' A greta probability distribution corresponding to multivariate normal
#' distribution with intrinsic conditional autoregressive covariance structure.
#' The only input required is a two-column R matrix of node edges, from which
#' the dimension of the resulting random vector phi is calculated. The length of
#' phi will be equal to number of nodes represented in the edge matrix - the
#' maximum value in either column.
#'
#' @param edges A two-column R matrix of integers indexing the pairs of adjacent
#'   nodes in the network being modelled. The nodes are indexed from 1.
#'
#' @return An operation greta array with an ICAR distribution, giving the
#'   spatial random effect 'phi' at all nodes in the network. Note that this
#'   greta array does not have a sum to zero constraint, so a 'soft' sum-to-zero
#'   constraint will need to be applied, as in the example.
#'
#' @export
#'
#' @examples
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
icar <- function(edges) {
  distrib("icar", edges)
}