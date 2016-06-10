## Water  management optimisation
Laureline Josset - 2016

The present code allows to find the optimized water operations (extractions, deliveries and releases) to minimize the cost while ensuring that demand is met.

The R script "main.R" is the core of the code where the three tasks are performed : loading the dataset, generating the matrix for the optimisation (with or without optimisation of groundwater) and solving the problem (using lpSolve - under a LGPLicense, or Gurobi, which require the obtention of a license). 

For documentation about the concept behind the code, please visit https://github.com/LaurelineJ/WaterManagementOptimisation/documentation_optimisation.md. Also, a simple illustration of the code can be found at https://github.com/LaurelineJ/WaterManagementOptimisation/example.ipynb

The code is currently under development. Please contact the authors for any question regarding use and distribution of the code. 