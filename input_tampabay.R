#################################################################################################################
######## Matrix generator in R - Laureline & Ipsita 2016
#################################################################################################################
### USER INPUTS
# dimensions of the optimization problem
R <- 5       # index i - reservoirs
M <- 5       # index j - municipality
G <- 5       # index g - groundwater
Time <- 36   # index t - timestep
n_s <- 1     # index s - number of scenarios

### CONNECTIONS
# matrix specifying which reservoir is linked to which municipality
Mij <- rbind(c(1,0,0,1,0),c(0,1,1,0,0),c(0,0,1,0,0),c(0,1,0,1,0),c(0,0,0,0,1),c(1,1,1,1,1))
# matrix specifying the water network. reservoir i gets the water released from reservoir i* if Mii* == 1
Mii <- rbind(c(0,0,0,0,0,0),
             c(1,0,0,0,0,0),
             c(0,0,0,0,0,0),
             c(0,0,0,0,0,0),
             c(0,1,0,1,0,0),
             c(0,0,0,0,0,0))

source("generate_pos_function.R")
if(G>0){source("input_groundwater.R")}
###########################################################################
### DEMAND: proportional to population, demand in 1000m3/month
population <- c(32000,145000,50000, 12000,80000)
matrix_demand <- 1e-3*((matrix(population*15,M,Time)+matrix(5e4,M,Time)*t(matrix(sin(seq(1,Time)/12*pi)^4,Time,M))))
Djts <- array(data=matrix_demand,dim=c(M,Time,n_s))
plot(Djts[1,,1],ylim=c(0,max(Djts)),col="white")
for(m in 1:M){for(s in 1:n_s){
  lines(Djts[m,,s],ylim=c(0,max(Djts)),lty=m)
}}
legend("bottomright",legend=c("M1","M2","M3","M4","M5"),lty=1:M)

# capacity of channels for release in 1000m^3/month
PCminit <- array(data=1000,dim=(c(R,Time))) 
PCmaxit <- array(data=1e5,dim=(c(R,Time)))

### RESERVOIRS
# min capacity required to function in 1000m3
SCminit <- array(data=10,dim=(c(R,Time)))
# max capacity of the reservoirs in 1000m3
SCmaxit <- array(data=c(1e5,1e5,5e5,9e4,4e5),dim=(c(R,Time))) # in 1000m^3
# initial stored volumes in reservoirs in 1000m3
Si0s <- array(data=1e4,dim=(c(R,n_s)))

### CLIMATE INPUTS
# recharge sw in 1000m3
Iits <- array(data=0,dim=c(R,Time,n_s))
Iits[1,,1]<- rnorm(Time,mean=3.6e4,sd=8e2)
Iits[2,,1]<- rnorm(Time,mean=4.4e4,sd=8e2)
Iits[3,,1]<- rnorm(Time,mean=6.5e4,sd=8e2)
Iits[4,,1]<- rnorm(Time,mean=1.1e4,sd=8e2)
Iits[5,,1]<- rnorm(Time,mean=4.3e4,sd=8e2) # in 1000m^3
# evaporation in %
eits <- array(data=0,dim=c(R,Time,n_s))

# recharge gw in 1000m3
Igts <- array(data=0,dim=c(G,Time,n_s))
#Igts[1,,1]<- rnorm(Time,mean=1.2e7,sd=5e5)
#Igts[2,,1]<- rnorm(Time,mean=0.4e7,sd=5e5)
#Igts[3,,1]<- rnorm(Time,mean=1.0e7,sd=5e5)
#Igts[4,,1]<- rnorm(Time,mean=0.6e7,sd=5e5)
#Igts[5,,1]<- rnorm(Time,mean=1.3e7,sd=5e5)


### FOR THE OBJECTIVE FUNCTION
# matrix cost defining how much it cost for each municipality to get its water from a given reservoir in $/1000m3
matrix_cost <- rbind(c(1,0,0,4,0),c(0,2,3,0,0),c(0,4,1,0,0),c(0,6,0,1,0),c(0,0,0,0,2),c(10,10,10,10,10)) # static in time and indep of weather for now
cijts <- array(data=matrix_cost,dim=c(R+1,M,Time,n_s))

# weight of each scenario
ws<-array(data=1/n_s,dim=c(M,Time,n_s))

