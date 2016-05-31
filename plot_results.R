### PLOTTING
rQ    <- array(data=xval[1:(R*M*Time)],dim=c(R,M,Time))
rQsup <- array(data=xval[(R*M*Time)+1:(n_s*M*Time)],dim=c(M,Time,n_s))
rP    <- array(data=xval[(1:(R*Time))+(R+n_s)*M*Time],dim=c(R,Time))
rS    <- array(data=xval[(1:(R*Time*n_s))+(R+n_s)*M*Time+R*Time],dim=c(R,Time,n_s))

startG <-(R+n_s)*M*Time + (1+n_s)*R*Time 
rQgw  <- array(data=xval[(1:(G*M*Time))+startG],dim=c(G,M,Time))
rhead <- array(data=xval[(1:(G*Time*n_s)) + startG + G*M*Time],dim=c(G,Time,n_s))
rLat  <- array(data=xval[(1:(G*Time*n_s)) + startG + G*Time*(M+n_s)],dim=c(G,Time,n_s))

resstring<-c("res 1","res 2","res 3","res 4","res 5")

plot(rQ[1,1,],lty=1,type="l",ylim=c(0,max(c(max(rQsup),max(rQ)))),col="white")
for(m in 1:M){for(r in 1:R){
  lines(rQ[r,m,],lty=m,col=r,lwd=4)
}}
for(m in 1:M){for(s in 1:n_s){
  lines(rQsup[m,,s],lty=m,col="purple",lwd=2)
}}
legend("topright",legend=c(resstring,"super res"),col=c(1:5,"purple"),lty=1,lwd=2)


plot(rS[1,,1],lty=1,type="l",ylim=c(0,max(rS)),col="white")
for(s in 1:n_s){for(r in 1:R){
  lines(rS[r,,s],lty=s,col=r,lwd=2)
}}
legend("bottomright",legend=c("res 1","res 2","res 3","res 4","res 5"),col=1:R,lty=1)



#### verification of the newtwork:
par(mfrow=c(R,1))
par(mar=c(2,2,4,1))
for(reser in 1:R){
  plot(rS[reser,,1],ylim=c(-1e8,max(SCmaxit[reser,])),type="l",col="blue")
  for(m in 1:M){lines(rQ[reser,m,],col="red")}
  lines(rP[reser,],col="black")
  lines(Iits[reser,,1],col="green")
  abline(SCmaxit[reser,1],0,col="orange")
  abline(SCminit[reser,1],0,col="orange")
  S<-matrix(ncol=1,nrow=Time)
  t=1
  S[1]<-Si0s[reser,1] +
    Iits[reser,t,1]-
    sum(rQ[reser,,t])+
    t(Mii[reser,1:R])%*%t(t(rP[,t]))-
    rP[reser,t]-
    eits[reser,t,1]*Si0s[reser,1]
  
  for(t in 2:Time){
    S[t]<-S[t-1]+ 
      Iits[reser,t,1]-
      sum(rQ[reser,,t])+
      t(Mii[reser,1:R])%*%t(t(rP[,t]))-
      rP[reser,t]-
      eits[reser,t,1]*S[t-1]
  }
  points(S)
  title(paste("reservoir",reser))
}

for(m in seq(1:M)){
  plot(Djts[m,,s],ylim=c(0,max(Djts[m,,])))
  lines(Djts[m,,s])
  for(r in 1:R){lines(rQ[r,m,],col="blue")}
  for(g in 1:G){lines(rQgw[g,m,],col="orange")}
  title(paste("Municipality",m, "water source"))
  legend("bottomright",legend=c("demand","surface water","groundwater"),col=c("black","blue","orange"),lty=c(1,1,1))
}


for(g in seq(1:G)){
  plot(rhead[g,,s],ylim=c(min(h_min),max(h_max)))
  for(m in 1:M){lines(rQgw[g,m,]/(area[g]*ss[g]*thick[g]),col="orange")}
  lines(rLat[g,,s]/(area[g]*ss[g]*thick[g]),col="blue")
  abline(h_min[g],0,col="magenta")
  abline(h_max[g],0,col="magenta")
  title(paste("Aquifer",g, "piezohead"))
  legend("bottomright",legend=c("water table","lateral flows","withdrawals","recharge"),col=c("black","blue","orange","magenta"),lty=c(1,1,1))
}


for(g in seq(1:G)){
  plot(rhead[g,,s],ylim=c(-max(rQgw[g,m,]/(area[g]*ss[g]*thick[g])),max(rQgw[g,m,]/(area[g]*ss[g]*thick[g]))))
  for(m in 1:M){lines(rQgw[g,m,]/(area[g]*ss[g]*thick[g]),col="orange")}
  lines(rLat[g,,s]/(area[g]*ss[g]*thick[g]),col="blue")
  lines(Igts[g,,s]/(area[g]*ss[g]*thick[g]),col="magenta")
  title(paste("delta",g, "piezohead"))
  legend("bottomright",legend=c("water table","lateral flows","withdrawals","recharge"),col=c("black","blue","orange","magenta"),lty=c(1,1,1))
}



par(mfrow=c(1,1))
plot(rhead[1,,1],type="l",ylim=c(min(rhead),max(rhead)))
for(g in 2:G){
lines(rhead[g,,1],type="l")
}
