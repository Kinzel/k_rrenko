# k_rrenko

## About
k_rrenko is an in-development R package to build Ranko plots and tables.

## Installation

    Just copy and paste the code.

## Variables

    krenko(Ativo, size, thresholdtrendsize, thresholdreversionsize)

* **Ativo** = a xts with close price
* **size** = the size of the renko bricks (no default)
* **thresholdtrendsize** = threshold size of trend brick (default = 1)
* **thresholdreversionsize** = threshold size of reversion brick (default = 2)

    krenko_plot(Ativo, size, thresholdtrendsize, thresholdreversionsize)

* **Ativo** = a xts with close price
* **size** = the size of the renko bricks (no default)
* **thresholdtrendsize** = threshold size of trend brick (default = 1)
* **thresholdreversionsize** = threshold size of reversion brick (default = 2)
* **withDates** = show the dates of xts (default = TRUE)

## Examples

### Data

    set.seed(10)
    data <- xts(x=abs(cumsum(rnorm(250))), order.by=as.POSIXct(Sys.Date()+1:250), born=as.POSIXct("1899-05-08"))

### Code

    krenko_plot(data, 1,withDates = F)

![rrenko modern](/images/IMAGEM.png)


## Changelog

### 0.1.1 - 2019-01-22
* There are some bugs, but working fine.

### 0.1.0 - 2019-12-13
* Experimental use only.
