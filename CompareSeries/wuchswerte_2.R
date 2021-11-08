# function to normalize according to Hollsteins transformation to Wuchswerte
# wuchswerte Hollstein(1980, 14-15) Y(i)=100 ln (b(i)/b(i-1))
# author: Ronald M. Visser
# variant that uses dplyr::lag() 
require(dplyr)
wuchswerte_2 <- function(x) {
  x2 <- lag(x,1)
  wuchswerte <- 100*log(x/x2)
  wuchswerte
}