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
    data <- xts(x=abs(cumsum(rnorm(200))), order.by=as.POSIXct(Sys.Date()+1:200), born=as.POSIXct("1899-05-08"))

### Code

    krenko_plot(data, 1.25,withDates = F)

![k_rrenko](/newkrenkoMAR2019.png)

### Creator comments

Work better with time-series. GAPs are created by 'size' choice. Increase 'size' to reduce the number of GAPS. To reduce 'size' I suggest to use your minimum time-series object (as 1M and 5M). Time-series with large time-frame (as 12 Hours, 1DAY, etc) and with big 'sizes' will result in a lot of GAPs. This is not a flaw in code, its how Renko works.

## Changelog

## 0.1.3 2019-03-17
* Bug fixes.

## 0.1.2 - 2019-02-11
* Bug fixes.

### 0.1.1 - 2019-01-22
* Working fine.

### 0.1.0 - 2018-12-18
* Experimental use only.
