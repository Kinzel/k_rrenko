krenko = function(Ativo, size, threshold = 1)
{
  ## JAN/2019
  ## Guilherme Kinzel
  
  ## This code was only possible by RomanAbashin. Data.table manipulation and ggplot
  ## package used: rrenko package, https://github.com/RomanAbashin/rrenko
  
  ## 'Ativo' need to be a xts, with one of columns named 'close'. Or, it will be used the last column (as a OHLC)
  
  require(data.table)
  require(xts)
  
  if (!is.xts(Ativo)) {
    stop("X should be a xts")
  }
  
  whereclose <- which(tolower(names(Ativo)) == "close")
  
  if (length(whereclose) > 0) {
    price <- Ativo[, whereclose]
  } else{
    warning("Column 'Close' was not found. Using the last column")
    price <- Ativo[, ncol(Ativo)]
  }
  
  data <- data.table(date = index(Ativo), close = as.numeric(price))
  names(data) <- c("date", "close")
  
  data$corridor_bottom <- size * floor(data$close / size)
  
  data <- data[, head(.SD, 1), by = .(corridor_bottom, rleid(corridor_bottom))]
  
  data$corridor_top <- rep(NA, length.out = dim(data)[1])
  data$direction <- rep(NA, length.out = dim(data)[1])
  data$base <- rep(NA, length.out = dim(data)[1])
  
  data$direction[1] <- "up"
  data$base[1] <- data$corridor_bottom[1]
  j <- 1
  
  if (dim(data)[1] <= 1) {
    stop("size too big")
  }

  for (i in 2:nrow(data)) {
    fDif <- (data$corridor_bottom[j] - data$corridor_bottom[i]) / size
    
    ## avoid floating point error
    if (round(abs(fDif), 1) <= threshold)next
    iJump = abs(fDif)-1
    
    if (fDif < 0) {
      data$direction[i] <- "up"
      data$corridor_bottom[i] <- data$corridor_bottom[i] - size
      data$corridor_top[i] <- data$corridor_bottom[i] + size
      j <- i
      
    } else if (fDif > 0) {
      data$direction[i] <- "down"
      data$corridor_bottom[i] <- data$corridor_bottom[i] + size
      data$corridor_top[i] <- data$corridor_bottom[i] + size
      j <- i
    }
  }

  data <- data[!is.na(direction)]
  data$base <- data$corridor_bottom
  data <- tail(data, -1)
}

krenko_plot= function(Ativo, size, threshold=1, withDates=T, spacebetweenpriceaxis=1, title=NULL)
{
  ## Guilherme Kinzel
  ## This code was only possible by RomanAbashin, rrenko package, https://github.com/RomanAbashin/rrenko
  ## JAN/2019
  
  ## 'Ativo' need to be a xts, with one of columns named 'close'. Or, it will be used the last column (as a OHLC)
  
  require(ggplot2)
  
  data <- krenko(Ativo, size,threshold)
  
  # data$base <- data$base + size ## plot propuses
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
    #+ geom_point(aes(data$step, data$close))
  
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
  
  if(!is.null(title))
  {
    g <- g + ggtitle(title)
  }
  return(g)
}
