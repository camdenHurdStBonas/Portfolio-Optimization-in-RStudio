# Portfolio Optimization in Rstudio

## Overview

This project provides a Portfolio Object in RStudio designed for portfolio optimization and statistics using historical stock data from Yahoo! Finance. The Portfolio Object allows users to analyze and optimize portfolios based on input stock data.

## Portfolio Object

### Input:

- `...`: CSV files of stock data from Yahoo! Finance.
- `names.list`: List of names for each stock.
- `RF`: Risk-free rate (default set to zero) used for Sharpe ratio calculations.
- `num.ports`: The number of portfolios for the efficient frontier.

### Output:

- Default: Returns the object environment.
- `get.Cov()`: Returns the covariance matrix of all stocks.
- `get.Cor()`: Returns the correlation matrix of all stocks.
- `get.Stats()`: Returns average, geometric average, standard deviation, and Sharpe ratio of all stocks.
- `get.MVP()`: Returns weights and statistics of the Minimum Variance Portfolio.
- `get.MVEP()`: Returns weights and statistics of the Mean-Variance Efficient Portfolio.
- `plot.EF()`: Plots the efficient frontier.
- `plot.MVP()`: Bar chart of the Minimum Variance Portfolio.
- `plot.MVEP()`: Bar chart of the Mean-Variance Efficient Portfolio.

## Getting Started

### Prerequisites

Make sure you have the following R packages installed:

- `timetk`: [timetk package](https://cran.r-project.org/package=timetk)
- `plotly`: [plotly package](https://cran.r-project.org/package=plotly)
- `tibble`: [tibble package](https://cran.r-project.org/package=tibble)

### Setup

1. Download or clone the project from GitHub.
2. Set the working directory in `portfolioMain.R` to the location of the project.

```R
# Set the variable "path" to the name of the Working Directory
path <- "/path/to/Portfolio-Optimization-in-Rstudio"
setwd(path)
```

3. Run portfolioMain.R.

```R
#import portfolioObject.R
source('portfolioObject.R')
```

