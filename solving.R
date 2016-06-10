#### solving of the optimisation problem with Gurobi
if(solver=="gurobi"){
  print("solving done by Gurobi")
model            <- list()
model$A          <- A
model$obj        <- Obj
model$modelsense <- "min"
model$rhs        <- as.vector(rhs)
model$sense      <- as.vector(sense)

### SOLVING
library(gurobi)
result <- gurobi(model)
objval <- result$objval
xval   <- result$x
}else{
  print("solving done by lpSolve")
  library(lpSolve) 
  result <- lp(direction="min", objective.in = Obj, const.mat = A, const.dir = sense, const.rhs = rhs)
  objval <- result$objval
  xval   <- result$solution  
}

print(paste0("Total cost of water allocation solution is : ", round(objval,2),"$"))