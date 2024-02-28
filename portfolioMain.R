#   Set up

#Cleared the work space
rm(list=ls())

#sets the variable "path" to the name of Working Directory
path <- "/Users/desktop/Github/Portfolio Optimization in Rstudio"

#Set the Working Directory using the variable "path"
setwd(path)

# https://cran.r-project.org/package=timetk
library(timetk)

# https://cran.r-project.org/package=plotly
library(plotly)

# https://cran.r-project.org/package=tibble
library(tibble)

#import portfolioObject.R
source('portfolioObject.R')


#   Data

#AAPL data frame from https://finance.yahoo.com/quote/AAPL?p=AAPL&.tsrc=fin-srch
AAPL.df <- read.csv("AAPL.csv")

#MSFT data frame from https://finance.yahoo.com/quote/MSFT?p=MSFT&.tsrc=fin-srch
MSFT.df <- read.csv("MSFT.csv")

#GOOGL data frame from https://finance.yahoo.com/quote/GOOGL?p=GOOGL&.tsrc=fin-srch
GOOGL.df <- read.csv("GOOGL.csv")

#AMZN data frame from https://finance.yahoo.com/quote/AMZN?p=AMZN&.tsrc=fin-srch
AMZN.df <- read.csv("AMZN.csv")


#   Portfolio Object


# names of the stocks
names <- c("AAPL","MSFT","GOOGL","AMZN")

# instance of the portfolio object
port.obj <- portfolio(AAPL.df,MSFT.df,GOOGL.df,AMZN.df,names.list= names, RF= 0.0,num.ports = 6000)


# Functions


# portfolio statistics
port_stats <- port.obj$get.Stats()

# portfolio covariance
port_cov <- port.obj$get.Cov()

# portfolio correlation
port_cor <- port.obj$get.Cor()

# portfolio mvp
port_mvp <- port.obj$get.MVP()

# portfoilio mvep
port_mvep <- port.obj$get.MVEP()

# Effecient frontier plot
port.obj$plot.EF()

# MVP bar chart
port.obj$plot.MVP()

# MVEP bar chart
port.obj$plot.MVEP()
