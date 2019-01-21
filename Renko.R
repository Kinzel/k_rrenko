krenko = function(Ativo, size, thresholdtrendsize = 1, thresholdreversionsize=2)
{
  ## JAN/2019
  ## Guilherme Kinzel
  
  ## This code was only possible by RomanAbashin. Data.table manipulation and ggplot
  ## package used: rrenko package, https://github.com/RomanAbashin/rrenko
  
  ## 'Ativo' need to be a xts, with one of columns named 'close'. Or, it will be used the last column (as a OHLC)
  
  require(data.table)
  require(xts)
  
  if(thresholdtrendsize<0 | thresholdreversionsize<0)
  {
    stop("thresholdtrendsize and thresholdreversionsize should be >0")
  }
  
  if(!is.xts(Ativo)){
    stop("X should be a xts")
  }
  
  whereclose <- which(tolower(names(Ativo))=="close")
  
  if(length(whereclose)>0){
    price <- Ativo[,whereclose]
  }else{
    warning("Column 'Close' was not found. Using the last column")
    price <- Ativo[,ncol(Ativo)]
  }
  
  data <- data.table(date=index(Ativo),close=as.numeric(price))
  names(data) <- c("date","close")
  
  data$corridor_bottom <- size * floor(data$close/size)
  data$corridor_top <- data$corridor_bottom + size
  
  # whichandhead <- function(a,b){
  #   return(head(which(a==b)))
  # }
  # data <- data[unlist(lapply(unique(Eu), whichandhead, rleid(data$corridor_bottom))),]
  
  data <- data[, head(.SD, 1), by = .(corridor_bottom, rleid(corridor_bottom))]
  
  data$direction <- rep(NA, length.out = dim(data)[1])
  data$base <- rep(NA, length.out = dim(data)[1])
  
  data$direction[1] <- "up"
  data$base[1] <- data$corridor_bottom[1]-size
  j <- 1
  
  ## Threshold
  Delta <- size*thresholdtrendsize
  DeltaReversion <- size*thresholdreversionsize
  
  for (i in 2:nrow(data)) {
    fDif <- data$corridor_bottom[j] - data$corridor_bottom[i]
    
    ## avoid floating point error
    if(round(abs(fDif),abs(log10(Delta)))<Delta)next
    
    if(fDif<0){
      bHappened <- T
      ## UP -> UP
      ## DOWN -> UP
      if(data$direction[j]=="down"
         & abs(fDif) < DeltaReversion & j>1){
        ##Reversion
        bHappened <- F
      }
      
      if(bHappened)
      {
        data$direction[i] <- "up"
        data$base[i] <- data$base[j]+size
        j <- i
      }
    }else if(fDif>0){
      ##DOWN -> DOWN
      ##UP -> DOWN
      bHappened <- T
      if(data$direction[j]=="up"
         & abs(fDif) < DeltaReversion & j>1){
        ##Reversion
        bHappened <- F
      }
      if(bHappened)
      {
        data$direction[i] <- "down"
        data$base[i] <- data$base[j]-size
        j <- i
      }
    }
  }
  
  data <- data[!is.na(direction)]
  data <- tail(data,-1)
  
  return(data)
}

krenko_plot= function(Ativo, size, thresholdtrendsize = 1, thresholdreversionsize=2, withDates=T, spacebetweenpriceaxis=1)
{
  ## Guilherme Kinzel
  ## This code was only possible by RomanAbashin, rrenko package, https://github.com/RomanAbashin/rrenko
  ## JAN/2019
  
  ## 'Ativo' need to be a xts, with one of columns named 'close'. Or, it will be used the last column (as a OHLC)
  
  require(ggplot2)
  
  data <- krenko(Ativo, size,thresholdtrendsize,thresholdreversionsize)
  
  data$rleid[1] <- 1
  data$step <- seq(1, length.out=dim(data)[1])
  data2 <- data
  data2$base <- size
  data <- rbind(data, data2)
  
  limites <- data[data$base!=size]$base
  
  limitesMin <- min(limites)-size*spacebetweenpriceaxis
  limitesMax <- max(limites)+size*spacebetweenpriceaxis
  
  
  g <- ggplot(data) + geom_col(aes(interaction(data$step), 
                                   base, fill = paste(direction, base != size), 
                                   color = paste(direction, base != size))) + 
    scale_fill_manual(values = c("#000000", "transparent","#FFFFFF", "transparent")) + 
    scale_color_manual(values = c("#000000","transparent", "#000000", "transparent")) +
    coord_cartesian(ylim=c(limitesMin,limitesMax))
  
  if(withDates){
    g <- g + theme(axis.text.x = element_text(angle = 90, hjust = 1), 
                   axis.title.x = element_blank(),
                   axis.title.y = element_blank(), legend.position = "none") + 
      scale_x_discrete(labels = c(data$date))
  }else{
    g <- g + theme(axis.text.x = element_blank(), 
                   axis.title.x = element_blank(),
                   axis.title.y = element_blank(), legend.position = "none") + 
      scale_x_discrete(labels = c(data$date))
  }
  return(g)
}
