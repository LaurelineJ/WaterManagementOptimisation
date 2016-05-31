posRMT <- function(i,j,t){
  pos<-0
  if(i<=R){if(j<=M){if(t<=Time){
    pos=i+R*(j-1)+R*M*(t-1)
  }}}
  return(pos)
}
posGMT <- function(g,j,t){
  pos<-0
  if(g<=G){if(j<=M){if(t<=Time){
    pos=g+G*(j-1)+G*M*(t-1)
  }}}
  return(pos)
}
posMTS <- function(j,t,s){
  pos<-0
  if(j<=M){if(t<=Time){if(s<=n_s){
    pos=j+M*(t-1)+R*Time*(s-1)
  }}}
  return(pos)
}
posRTS <- function(i,t,s){
  pos<-0
  if(i<=R){if(t<=Time){if(s<=n_s){
    pos=i+R*(t-1)+R*Time*(s-1)
  }}}
  return(pos)
}
posGTS <- function(g,t,s){
  pos<-0
  if(g<=G){if(t<=Time){if(s<=n_s){
    pos=g+G*(t-1)+G*Time*(s-1)
  }}}
  return(pos)
}

posRT <- function(i,t){
  pos<-0
  if(i<=R){if(t<=Time){
    pos=i+R*(t-1)
  }}
  return(pos)
}
posRS <- function(i,s){
  pos<-0
  if(i<=R){if(s<=n_s){
    pos=i+R*(s-1)
  }}
  return(pos)
}
posGS <- function(g,s){
  pos<-0
  if(g<=G){if(s<=n_s){
    pos=g+G*(s-1)
  }}
  return(pos)
}
posMT <- function(j,t){
  pos<-0
  if(j<=M){if(t<=Time){
    pos=j+M*(t-1)
  }}
  return(pos)
}

posRM <- function(i,j){
  pos<-0
  if(i<=R){if(j<=M){
    pos=i+R*(j-1)
  }}
  return(pos)
}
