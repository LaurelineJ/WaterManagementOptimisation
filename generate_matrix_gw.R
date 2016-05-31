#################################################################################################################
######## Matrix generator in R - Laureline 2016
######## laureline.josset@gmail.com
######## GUROBI version
#################################################################################################################
dim_tot <- (R+n_s)*M*Time + (1+n_s)*R*Time + G*M*Time + G*Time*n_s

### OBJECTIVE
Obj <-matrix(data=0,ncol=1,nrow=dim_tot)
Obj[1:(R*M*Time),] <-array(cijts[1:R,,,],dim=c(R*M*Time,1))
#Obj[1:(R*M*Time),] <-array(apply(cijts[1:R,,,],1:3,sum)/n_s,dim=c(R*M*Time,1))
Obj[(R*M*Time)+(1:(M*Time*n_s)),] <-array(ws[,,]*cijts[R+1,,,],dim=c(M*Time*n_s,1))
Obj[(R+n_s)*M*Time + (1+n_s)*R*Time + (1:(G*M*Time))] <- array(cgjt,dim=c(G*M*Time,1))

### CONSTRAINTS
#-- DEMANDS
rhs_d <- array(Djts,dim=c(M*Time*n_s,1))
s_d <- array(">=",dim=c(M*Time*n_s,1))
A_d <- array(0,dim=c(M*Time*n_s,dim_tot))
for(i in 1:R){for(j in 1:M){for(t in 1:Time){for(s in 1:n_s){
  A_d[posMTS(j,t,s),posRMT(i,j,t)]=Mij[i,j]  
  A_d[posMTS(j,t,s),R*M*Time+posMTS(j,t,s)]=1
}}}}
# add water from gw to complete the demand
startG <-(R+n_s)*M*Time + (1+n_s)*R*Time 
for(g in 1:G){for(j in 1:M){for(t in 1:Time){for(s in 1:n_s){
  A_d[posMTS(j,t,s),startG + posGMT(g,j,t)]= Mgj[g,j]            # =1 if aquifer is linked to municipality at a given time step and for all scenarios
}}}}


#-- STREAMS
# MIN
rhs_pmin <- array(PCminit,dim=c(R*Time,1))
s_pmin <- array(">",dim=c(R*Time,1))
A_pmin <- array(0,dim=c(R*Time,dim_tot))
for(l in 1:(R*Time)){
  A_pmin[l,l+(R+n_s)*M*Time]<-1
}

# MAX
rhs_pmax <- array(PCmaxit,dim=c(R*Time,1))
s_pmax <- array("<",dim=c(R*Time,1))
A_pmax <- array(0,dim=c(R*Time,dim_tot))
for(l in 1:(R*Time)){
  A_pmax[l,l+(n_s+R)*M*Time]<-1
}


#-- RESERVOIR
# MIN
rhs_smin <- array(SCminit,dim=c(R*Time*n_s,1))
s_smin <- array(">",dim=c(R*Time*n_s,1))
A_smin <- array(0,dim=c(R*Time*n_s,dim_tot))
for(l in 1:(R*Time*n_s)){
  A_smin[l,l+R*Time+(R+n_s)*M*Time]<-1
}

# MAX
rhs_smax <- array(SCmaxit,dim=c(R*Time*n_s,1))
s_smax <- array("<",dim=c(R*Time*n_s,1))
A_smax <- array(0,dim=c(R*Time*n_s,dim_tot))
for(l in 1:(R*Time*n_s)){
  A_smax[l,l+R*Time+(R+n_s)*M*Time]<-1
}

# t=1
rhs_s1 <- array((Si0s*(1-eits[,1,]) + Iits[,1,]),dim=c(R*n_s,1))
s_s1  <- array("=",dim=c(R*n_s,1))
A_s1Q <- array(0,dim=c(R*n_s,R*M*Time))
A_s1Qsup <- array(0,dim=c(R*n_s,n_s*M*Time))
A_s1P <- array(0,dim=c(R*n_s,R*Time))
A_s1S <- array(0,dim=c(R*n_s,R*Time*n_s))

for(i in 1:R){for(j in 1:M){for(s in 1:n_s){
  A_s1Q[posRS(i,s),posRMT(i,j,1)]<-Mij[i,j]
}}}
for(i in 1:R){for(i_ in 1:R){for(s in 1:n_s){
  A_s1P[posRS(i,s),posRT(i_,1)]<- (i==i_)-Mii[i,i_]
}}}
for(i in 1:R){for(s in 1:n_s){
  A_s1S[posRS(i,s),posRTS(i,1,s)]<-1
}}
 A_s1 <- array(0,dim=c(R*n_s,dim_tot))
 A_s1[,1:(R*M*Time)] = A_s1Q
 A_s1[,R*M*Time+(1:(n_s*M*Time))] = A_s1Qsup
 A_s1[,(R+n_s)*M*Time+(1:(R*Time))] = A_s1P
 A_s1[,(R+n_s)*M*Time+R*Time+(1:(R*Time*n_s))] = A_s1S

# t in 2:Time
rhs_s <- array(Iits,dim=c(R*Time*n_s,1))
for(i in 1:R){for(s in 1:n_s){
rhs_s[posRTS(i,1,s)] <- 0}}
s_s  <- array("=",dim=c(R*Time*n_s,1))
A_sQ <- array(0,dim=c(R*Time*n_s,R*M*Time))
A_sQsup <- array(0,dim=c(R*Time*n_s,n_s*M*Time))
A_sP <- array(0,dim=c(R*Time*n_s,R*Time))
A_sS <- array(0,dim=c(R*Time*n_s,R*Time*n_s))
for(i in 1:R){for(j in 1:M){for(t in 2:Time){for(s in 1:n_s){
  A_sQ[posRTS(i,t,s),posRMT(i,j,t)]<-Mij[i,j]
}}}}
for(i in 1:R){for(i_ in 1:R){for(t in 2:Time){for(s in 1:n_s){
  A_sP[posRTS(i,t,s),posRT(i_,t)]<- (i==i_)-Mii[i,i_]
}}}}
for(i in 1:R){for(i_ in 1:R){for(t in 2:Time){for(t_ in 1:Time){for(s in 1:n_s){
  A_sS[posRTS(i,t,s),posRTS(i_,t_,s)]<-(posRT(i,t)==posRT(i_,t_)) - (1-eits[i,t_,s])*((i==i_)*(t_+1==t)) #posRT(i,t)==posRT(i_,t_-1))
}}}}}

##########################################################################################################################
A_s <- array(0,dim=c(R*Time*n_s,dim_tot))
A_s[,1:(R*M*Time)] = A_sQ
A_s[,R*M*Time+(1:(n_s*M*Time))] = A_sQsup
A_s[,(R+n_s)*M*Time+(1:(R*Time))] = A_sP
A_s[,(R+n_s)*M*Time+R*Time+(1:(R*Time*n_s))] = A_sS
A_s[1:(R*n_s),] <- A_s1
rhs_s[1:(R*n_s)]<-rhs_s1
s_s[1:(R*n_s)]<-s_s1

##########################################################################################################################
#-- HYDRAULIC HEAD h_gts
# MIN
rhs_hmin <- array(h_min,dim=c(G*Time*n_s,1))
s_hmin <- array(">",dim=c(G*Time*n_s,1))
A_hmin <- array(0,dim=c(G*Time*n_s,dim_tot))
start <- (R+n_s)*M*Time + (1+n_s)*R*Time + G*M*Time
for(l in 1:(G*Time*n_s)){
  A_hmin[l,l+start]<-1
}

# MAX
rhs_hmax <- array(h_max,dim=c(G*Time*n_s,1))
s_hmax <- array("<",dim=c(G*Time*n_s,1))
A_hmax <- array(0,dim=c(G*Time*n_s,dim_tot))
start <- (R+n_s)*M*Time + (1+n_s)*R*Time + G*M*Time
for(l in 1:(G*Time*n_s)){
  A_hmax[l,l+start]<-1
}

# STATE EQUATION : 
# t=1 h_g1s + Mgj*Qgw_gjt/(area*ss*thick) - L_gts/(area*ss)= hg0s + Igts/(area*ss*thick)
rhs_h1 <- array(0,dim=c(G*n_s,1))

for(g in 1:G){for(s in 1:n_s){for(g_ in 1:G){
  rhs_h1[posGS(g,s)]<-rhs_h1[posGS(g,s)] + Mgg[g,g_]*Kgg[g,g_]*(hg0s[g_,s]-hg0s[g,s])/(area[g]*ss[g]*thick[g])
}}}
rhs_h1 <- rhs_h1+array(hg0s + Igts[,1,]/array(area*ss*thick,dim=c(G,n_s)),dim=c(G*n_s,1))

s_h1  <- array("=",dim=c(G*n_s,1))
A_h1Qgw <- array(0,dim=c(G*n_s,G*M*Time))
A_h1h <- array(0,dim=c(G*n_s,n_s*G*Time))

for(g in 1:G){for(j in 1:M){for(s in 1:n_s){
  A_h1Qgw[posGS(g,s),posGMT(g,j,1)]<-Mgj[g,j]/(area[g]*ss[g]*thick[g])
}}}

for(g in 1:G){for(s in 1:n_s){
  A_h1h[posGS(g,s),posGTS(g,1,s)]<-1
}}

A_h1 <- array(0,dim=c(G*n_s,dim_tot))
start <- (R+n_s)*M*Time + (1+n_s)*R*Time
A_h1[,start+(1:(G*M*Time))]<-A_h1Qgw
start <- (R+n_s)*M*Time + (1+n_s)*R*Time + G*M*Time
A_h1[,start+(1:(G*n_s*Time))]<-A_h1h

# t in 2:Time h_gts - h_g(t-1)s + Mgj*Qgw_gjt/(area*ss*thick) - L_gts/(area*ss)= Igts/(area*ss*thick)
rhs_h <- array(Igts/array(area*ss*thick,dim=c(G,Time,n_s)),dim=c(G*Time*n_s,1))
s_h  <- array("=",dim=c(G*Time*n_s,1))
A_hQgw <- array(0,dim=c(G*Time*n_s,G*M*Time))
A_hh <- array(0,dim=c(G*Time*n_s,n_s*G*Time))

for(t in 2:Time){for(g in 1:G){for(j in 1:M){for(s in 1:n_s){
  A_hQgw[posGTS(g,t,s),posGMT(g,j,t)]<-Mgj[g,j]/(area[g]*ss[g]*thick[g])
}}}}

for(g in 1:G){for(t in 2:Time){for(t_ in 1:Time){for(s in 1:n_s){
  A_hh[posGTS(g,t,s),posGTS(g,t_,s)]<-(t==t_) - (t_+1==t)
}}}}

for(t in 2:Time){for(g_ in 1:G){for(g in 1:G){for(s in 1:n_s){
  A_hh[posGTS(g,t,s),posGTS(g_,t-1,s)]<- A_hh[posGTS(g,t,s),posGTS(g_,t-1,s)]+(g==g_)*sum(Mgg[g,]*Kgg[g,]) - Mgg[g,g_]*Kgg[g,g_]
}}}}

A_h <- array(0,dim=c(G*Time*n_s,dim_tot))
start <- (R+n_s)*M*Time + (1+n_s)*R*Time
A_h[,start+(1:(G*M*Time))]<-A_hQgw
start <- (R+n_s)*M*Time + (1+n_s)*R*Time + G*M*Time
A_h[,start+(1:(G*n_s*Time))]<-A_hh

A_h[1:(G*n_s),] <- A_h1
rhs_h[1:(G*n_s)]<-rhs_h1
s_h[1:(G*n_s)]<-s_h1

#################################################################################################################
#################################################################################################################
### INPUT FOR GUROBI
rhs   <- rbind(rhs_d,rhs_pmin,rhs_pmax,rhs_smin,rhs_smax,rhs_s,rhs_hmin,rhs_hmax,rhs_h)
sense <- rbind(  s_d,  s_pmin,  s_pmax,  s_smin,  s_smax,  s_s,  s_hmin,  s_hmax,  s_h)
A     <- rbind(  A_d,  A_pmin,  A_pmax,  A_smin,  A_smax,  A_s,  A_hmin,  A_hmax,  A_h)


