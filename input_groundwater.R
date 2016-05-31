#################################################################################################################
######## Matrix generator in R - Laureline 2016
#################################################################################################################
### GROUNDWATER MODEL
# DATA NECESSARY FOR THE MODEL
# aquifer connections
Mgg <- rbind(c(0,1,0,1,0),c(1,0,1,1,1),c(0,1,0,0,1),c(1,1,0,0,1),c(0,1,1,1,0))
# aquifer-municipality connections
Mgj <- diag(1,nrow=G,ncol=M)


# each county area in 1000m^2
area <- c(1.05e11,1.2e11,0.9e11,1.6e11,0.3e11)*1e-3
#elevation of the county surface with respect to datum in m
elevation <- c(330,300,305,325,285)
# depth of the exploited layer with respect to the county ground level in m
depth <- c(120, 100, 110, 150, 80)
# thickness of the confined exploited aquifer in m
thick <- c(405, 410, 420, 420, 410)
mat_thick <- (matrix(thick,M,M)+t(matrix(thick,M,M)))/2*Mgg
# distance between central points of each pair of counties in m
dist_matrix <- rbind(c(1e5,  2e4,  1e5,4e4,  1e5),
                     c(2e4,  1e5,2.5e4,3e4,  4e4),
                     c(1e5,2.5e4,  1e5,1e5,4.5e4),
                     c(4e4,  3e4,  1e5,1e5,  3e4),
                     c(1e5,  4e4,4.5e4,3e4,  1e5))
#length border between counties in m
length_matrix <- rbind(c(  0  , 4e4,     0, 1.5e4,     0),
                       c(  4e4,   0,   3e4,   3e4,   2e4),
                       c(  0  , 3e4,     0,     0, 1.5e4),
                       c(1.5e4, 3e4,     0,     0,   2e4),
                       c(  0  , 2e4, 1.5e4,   2e4,     0))



# hydraulic conductivity in 1000m/month
hyd_cond <- c(1.5e2, 2.1e2, 2.5e2,2e2, 1e2)*1e-4
mat_hyd_cond <- 2/(matrix(1/hyd_cond,M,M)+t(matrix(1/hyd_cond,M,M)))*Mgg
# specific storage of the confined exploited layer in m^-1
ss <- c(1e-7,5e-6,8e-6,9e-6,2e-7)
# leakage coefficient to describe lateral flow in 1000m^2/month                 
Kgg <- mat_hyd_cond*mat_thick*length_matrix/dist_matrix

# piezometric head initialisation values in m
h_zero <- array(max(elevation - depth) +40,dim=c(G,1))
hg0s <- array(data = h_zero,dim=c(G,n_s))
# minimum piezometric head in m (aquifer remains confined)
h_min <- array(max(elevation - depth),dim=c(G,1))
# maximum piezometric head in m (non-artesian wells)
h_max <- array(min(elevation),dim=c(G,1))

# cost of groundwater extraction in $/1000m^3
cgjt <- array((elevation-h_zero)*0.01,dim=c(G,M,Time))
