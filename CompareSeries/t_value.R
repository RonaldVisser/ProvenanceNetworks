# determin t_value
t_value <- function(r, n) {
  t_value <- (r * sqrt(n - 1)) / sqrt(1 - r^2)
}
