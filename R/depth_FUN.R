center.cloud<-function(df, center=c(0,0,0)){
  df[,1:3]<-cbind(df[,1]-center[1],
                  df[,2]-center[2],
                  df[,3]-center[3])
  return(df)
}

read.ptx<-function(file, do.row.col=FALSE){
  require(data.table)
  res_col <- as.numeric(read.csv(file, sep = "", skip = 0,nrows = 2, header = FALSE)[1,])
  res_row <- as.numeric(read.csv(file, sep = "", skip = 0,nrows = 2, header = FALSE)[2,])
  df<-fread(file, select = c(1:4), skip = 10,header = FALSE)
  colnames(df)<-c("x","y","z","int")
  
  if (do.row.col==TRUE){
    df<-list(res_col,res_row, df) 
  }
  return(data.table(df))
}

cart.To.sphere<-function(df){
  require(data.table)
  colnames(df)[1:3]<-c("x","y","z")
  r <- sqrt(df$x^2 + df$y^2 +df$z^2)
  inc <- ((acos(df$z/r)))*(180/pi)
  az <- atan2(df$y,df$x)*(180/pi)
  return(cbind(r,inc,az))
}

depth.bin<-function(df, zen_bin, zen_range, az_bin){
  require(data.table)
  zen_ls<-seq(zen_range[1],zen_range[2], by = zen_bin)
  df.az.ls<-lapply(zen_ls, function(x){
    range<-list(x,x+zen_bin)
    df.bin<-df[inc %between% range,]
    df.bin$d<-sqrt(df.bin$x^2+df.bin$y^2)
    df.bin$az_bin<-floor(df.bin$az/az_bin)*az_bin
    df.bin$zen_bin<-x
    return(df.bin)
  }
  )
  return(df.az.ls)
}

depth.pctl<-function(depth.list, percentiles){
  depth.list.pct<-lapply(depth.list, function(x) {
    depth.pct<-aggregate(d~az_bin+zen_bin, data=x, function(x) quantile(x, percentiles))
    depth.pct<-data.frame(az_bin=depth.pct$az_bin,
                          zen_bin=depth.pct$zen_bin,
                          depth.pct$d)
    colnames(depth.pct)[c(1:length(percentiles))+2]<-paste0('p_',percentiles*100)
    return(depth.pct)
  })
  return(do.call(rbind,depth.list.pct))
}

depth.metrics<-function(depth.list.pct){
  depth_mean<-aggregate(.~zen_bin, FUN="mean", data=depth.list.pct)
  depth_sd<-aggregate(.~zen_bin, FUN="sd", data=depth.list.pct)
  colnames(depth_sd)[1:length(percentiles)+2]<-paste0(colnames(depth_sd)[1:length(percentiles)+2],
                                                      "_sd")
  depth_metrics<-cbind(depth_mean[,-2], depth_sd[,-c(1:2)])
  colnames(depth_metrics)[1:length(percentiles)+2]<-paste0(colnames(depth_sd)[1:length(percentiles)+2])
  return(depth_metrics)
}

depth.fun<-function(df, zen_bin, zen_range, az_bin, percentiles){
  print(paste("Converting to spherical coordinates....", "25%"))
  df<-cbind(df,cart.To.sphere(df))
  print(paste("Splitting into zenith bins....","50%"))
  depth.list<-depth.bin(df, zen_bin, zen_range, az_bin)
  print(paste("Calculating depth percentiles....","75%"))
  depth.list.pct<-depth.pctl(depth.list, percentiles)
  print(paste("Calculating depth metrics....","99%"))
  depth<-depth.metrics(depth.list.pct)
  print("Done")
  return(depth)
}


