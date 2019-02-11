# k_rrenko

## About
k_rrenko is an in-development R package to build Ranko plots and tables.

## Installation

    Just copy and paste the code.
    
    https://github.com/Kinzel/k_rrenko/blob/master/Renko.R

## Variables

    krenko_plot(Ativo, size, threshold, withDates)

* **Ativo** = a xts with close price
* **size** = the size of the renko bricks (no default)
* **threshold** = threshold size of trend brick (default = 1)

## Example

### Preparation

    library(xts)
    library(data.table)
    library(ggplot2)

### Data

    set.seed(10)
    data <- xts(x=abs(cumsum(rnorm(250))), order.by=as.POSIXct(Sys.Date()+1:250), born=as.POSIXct("1899-05-08"))

### Code

    krenko_plot(data, 1,withDates = F)

![k_rrenko](/22012019renko2.png)

## Creator Comments

Gaps in xts will create abnormal bricks in the plot. The first brick of the above plot is a example - there is a jump. Plot work perfectly in smooth continuous time-series. The table (krenko) is not affected.

## Changelog

## 0.1.2 - 2019-02-11
* Bug fixes.

### 0.1.1 - 2019-01-22
* Working fine.

### 0.1.0 - 2018-12-18
* Experimental use only.
