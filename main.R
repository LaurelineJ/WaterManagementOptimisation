#################################################################################################################
######## Matrix generator in R - Laureline & Ipsita 2016
######## laureline.josset@gmail.com
#################################################################################################################
### LOAD INPUTS
source("input_fivecounties.R")

#################################################################################################################
### GENERATE MATRICES FOR OPTIMISATION
source("generate_matrix_gw.R")

#################################################################################################################
### OPTIMIZATION
model            <- list()
model$A          <- A
model$obj        <- Obj
model$modelsense <- "min"
model$rhs        <- as.vector(rhs)
model$sense      <- as.vector(sense)

### SOLVING
library(gurobi)
result <- gurobi(model)

#################################################################################################################
### RESULTS
objval <- result$objval
xval   <- result$x
source("plot_results.R")

