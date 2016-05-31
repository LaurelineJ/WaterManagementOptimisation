#################################################################################################################
######## Matrix generator in R - Laureline & Ipsita 2016
######## laureline.josset@gmail.com
######## GUROBI version
#################################################################################################################

### OBJECTIVE
Obj <-matrix(data=0,ncol=1,nrow=(R+n_s)*M*Time+(1+n_s)*R*Time)
Obj[1:(R*M*Time),] <-array(cijts[1:R,,,],dim=c(R*M*Time,1))
#Obj[1:(R*M*Time),] <-array(apply(cijts[1:R,,,],1:3,sum)/n_s,dim=c(R*M*Time,1))
Obj[(R*M*Time)+(1:(M*Time*n_s)),] <-array(ws[,,]*cijts[R+1,,,],dim=c(M*Time*n_s,1))

### CONSTRAINTS
#-- DEMANDS
rhs_d <- array(Djts,dim=c(M*Time*n_s,1))
s_d <- array(">=",dim=c(M*Time*n_s,1))
A_d <- array(0,dim=c(M*Time*n_s,(R+n_s)*M*Time+(1+n_s)*R*Time))
for(i in 1:R){for(j in 1:M){for(t in 1:Time){for(s in 1:n_s){
  A_d[posMTS(j,t,s),posRMT(i,j,t)]=Mij[i,j]  
  A_d[posMTS(j,t,s),R*M*Time+posMTS(j,t,s)]=1
}}}}

#-- STREAMS
# MIN
rhs_pmin <- array(PCminit,dim=c(R*Time,1))
s_pmin <- array(">",dim=c(R*Time,1))
A_pmin <- array(0,dim=c(R*Time,(R+n_s)*M*Time+(1+n_s)*R*Time))
for(l in 1:(R*Time)){
  A_pmin[l,l+(R+n_s)*M*Time]<-1
}

# MAX
rhs_pmax <- array(PCmaxit,dim=c(R*Time,1))
s_pmax <- array("<",dim=c(R*Time,1))
A_pmax <- array(0,dim=c(R*Time,(R+n_s)*M*Time+(1+n_s)*R*Time))
for(l in 1:(R*Time)){
  A_pmax[l,l+(n_s+R)*M*Time]<-1
}


#-- RESERVOIR
# MIN
rhs_smin <- array(SCminit,dim=c(R*Time*n_s,1))
s_smin <- array(">",dim=c(R*Time*n_s,1))
A_smin <- array(0,dim=c(R*Time*n_s,(R+n_s)*M*Time+(1+n_s)*R*Time))
for(l in 1:(R*Time*n_s)){
  A_smin[l,l+R*Time+(R+n_s)*M*Time]<-1
}

# MAX
rhs_smax <- array(SCmaxit,dim=c(R*Time*n_s,1))
s_smax <- array("<",dim=c(R*Time*n_s,1))
A_smax <- array(0,dim=c(R*Time*n_s,(R+n_s)*M*Time+(1+n_s)*R*Time))
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
 A_s1 <- array(0,dim=c(R*n_s,(R+n_s)*M*Time+(1+n_s)*R*Time))
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
  A_sS[posRTS(i,t,s),posRTS(i_,t_,s)]<-(posRT(i,t)==posRT(i_,t_)) - (1-eits[i,t_,s])*((i==i_)*(t_+1==t))#posRT(i,t)==posRT(i_,t_-1))
  }}}}}


A_s <- array(0,dim=c(R*Time*n_s,(R+n_s)*M*Time+(1+n_s)*R*Time))
A_s[,1:(R*M*Time)] = A_sQ
A_s[,R*M*Time+(1:(n_s*M*Time))] = A_sQsup
A_s[,(R+n_s)*M*Time+(1:(R*Time))] = A_sP
A_s[,(R+n_s)*M*Time+R*Time+(1:(R*Time*n_s))] = A_sS

#################################################################################################################
### INPUT FOR GUROBI
rhs   <- rbind(rhs_d,rhs_pmin,rhs_pmax,rhs_smin,rhs_smax,rhs_s1,rhs_s)
sense <- rbind(  s_d,  s_pmin,  s_pmax,  s_smin,  s_smax,  s_s1,  s_s)
A     <- rbind(  A_d,  A_pmin,  A_pmax,  A_smin,  A_smax,  A_s1,  A_s)
