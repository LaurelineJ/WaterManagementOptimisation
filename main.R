#################################################################################################################
######## Matrix generator in R - Laureline & Ipsita 2016
######## laureline.josset@gmail.com
#################################################################################################################
### LOAD INPUTS
source("input_fivecounties.R")

#################################################################################################################
### GENERATE MATRICES FOR OPTIMISATION
GW = TRUE # specify wether yes or not there is groundwater
if(GW){
  source("generate_matrix_gw.R")
}else{
  source("generate_matrix.R")
}
#################################################################################################################
### OPTIMIZATION : solver = "lpsolve" or "gurobi"
#solver = "gurobi"
solver = "lpsolve"
source("solving.R")

#################################################################################################################
### RESULTS Illustrations
source("plot_results.R")

