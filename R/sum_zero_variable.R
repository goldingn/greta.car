#' sum-to-zero variable
#'
#' Create an greta array with sum-to-zero constraint
#'
#' @param dim the dimensions of the greta array to be returned, either a scalar
#'   or a vector of positive integers. See details.
#'
#' @details The sum-to-zero constraint operates on the final dimension, which
#'   must have more than 1 element. Passing in a scalar value for `dim`
#'   therefore results in a row-vector.
#'
#' @note It will not be possible to provide initial values for this variable
#'   greta array, due to the transformation required for the sum to zero
#'   constraint. That could be made possible in the future, either with a hacky
#'   solution, or a more elegant solution if this function were to be
#'   incorporated into the main greta package.
#'
#' @return an operation greta array, transformed from a variable greta array,
#'   with each element real-valued and subject to the constraint that all those
#'   elements sum to zero along the last dimension.
#'
#' @noRd
#'
#' @examples
#'
#' # a row-vector summing to 0
#' a <- sum_zero_variable(5)
#'
#' # equivalent to:
#' b <- sum_zero_variable(c(1, 5))
#'
#' # 3 length-5 row vectors, each summing to 0
#' c <- sum_zero_variable(3, 5)
#'
#' # 4 length-5 vectors, each summing to 0, in a 2x2 configuration
#' x <- sum_zero_variable(2, 2, 3)
#' 
sum_zero_variable <- function(dim) {
  
  # for scalar dims, return a row vector
  if (length(dim) == 1) {
    dim <- c(1, dim)
  }
  
  dim <- check_dims(target_dim = dim)
  
  # dimension of the free state version
  n_dim <- length(dim)
  last_dim <- dim[n_dim]
  if (!last_dim > 1) {
    msg <- cli::format_error(
      "the final dimension of a sum_zero variable must have more than one \\
      element",
      "The final dimension has: {.val {length(last_dim)} elements}"
    )
    stop(
      msg,
      call. = FALSE
    )
  }
  
  raw_dim <- dim
  raw_dim[n_dim] <- last_dim - 1
  free_dim <- prod(raw_dim)
  
  # create variable node
  node <- vble(
    truncation = c(-Inf, Inf),
    dim = dim,
    free_dim = free_dim
  )
  
  # set the constraint, to enable transformation
  node$constraint <- "sum_zero"
  
  # return as a greta array
  as.greta_array(node)
}