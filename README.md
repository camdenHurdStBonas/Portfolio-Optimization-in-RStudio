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

### 1. Prerequisites

Make sure you have the following R packages installed:

- `timetk`: [timetk package](https://cran.r-project.org/package=timetk)
- `plotly`: [plotly package](https://cran.r-project.org/package=plotly)
- `tibble`: [tibble package](https://cran.r-project.org/package=tibble)

### 2. Setup

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

### 3. Data

Load historical stock data (example provided for AAPL, MSFT, GOOGL, AMZN).

```R
#AAPL data frame from https://finance.yahoo.com/quote/AAPL?p=AAPL&.tsrc=fin-srch
AAPL.df <- read.csv("AAPL.csv")
#MSFT data frame from https://finance.yahoo.com/quote/MSFT?p=MSFT&.tsrc=fin-srch
MSFT.df <- read.csv("MSFT.csv")
#GOOGL data frame from https://finance.yahoo.com/quote/GOOGL?p=GOOGL&.tsrc=fin-srch
GOOGL.df <- read.csv("GOOGL.csv")
#AMZN data frame from https://finance.yahoo.com/quote/AMZN?p=AMZN&.tsrc=fin-srch
AMZN.df <- read.csv("AMZN.csv")
```

### 4. Instance of the Portfolio Object

1. Create a list of names for each stock.

```R
# names of the stocks
names <- c("AAPL","MSFT","GOOGL","AMZN")
```

2. Create an instance of the portfolio.

```R
# instance of the portfolio object
port.obj <- portfolio(AAPL.df,MSFT.df,GOOGL.df,AMZN.df,names.list= names, RF= 0.0,num.ports = 6000)
```

### 5. Utilize various functions and plots

1. Stock statistics

```R
# portfolio statistics
port_stats <- port.obj$get.Stats()
> port_stats
      Average Geo Mean Standard Deviation Sharpe Ratio Count
AAPL     2.99     2.55               9.47       0.3160   231
MSFT     1.55     1.34               6.60       0.2348   231
GOOGL    1.99     1.63               8.69       0.2288   231
AMZN     2.42     1.89              10.55       0.2298   231
```

This will return the average, geometric average, standard deviation, and Sharpe ratio of all stocks in the portfolio.

2. Stock covariances

```R
# portfolio covariance
port_cor <- port.obj$get.Cov()
> port_cov 
             AAPL        MSFT       GOOGL        AMZN
AAPL  0.008977337 0.002779139 0.004105582 0.003843546
MSFT  0.002779139 0.004362489 0.002850251 0.003048506
GOOGL 0.004105582 0.002850251 0.007555437 0.003632038
AMZN  0.003843546 0.003048506 0.003632038 0.011128899
```

This will return the covariance matrix of all stocks in the portfolio.

3. Stock correlations

```R
# portfolio correlation
port_cor <- port.obj$get.Cor()

```

This will return the correlation matrix of all stocks in the portfolio.

4. Minimum variance portfolio

```R
# portfolio mvp
port_mvp <- port.obj$get.MVP()
```

This will return the weights and statistics of the Minimum Variance Portfolio.

5. Mean-variance efficient portfolio

```R
# portfoilio mvep
port_mvep <- port.obj$get.MVEP()
```

This will return the weights and statistics of the Mean-Variance Efficient Portfolio.

6. Efficient fronteir plot

```R
# Effecient frontier plot
port.obj$plot.EF()
```

This will generate a plot of the efficient frontier, showing the trade-off between expected return and portfolio risk.

7. Minimum variance portfolio bar chart

```R
# MVP bar chart
port.obj$plot.MVP()
```

This will generate a bar chart illustrating the weights of stocks in the Minimum Variance Portfolio and statistics of the portfolio.

8. Mean-variance efficient portfolio bar chart

```R
# MVEP bar chart
port.obj$plot.MVEP()
```

This will generate a bar chart illustrating the weights of stocks in the Mean-Variance Efficient Portfolio and statistics of the portfolio.

## Work Cited

“Chatgpt.” ChatGPT, https://openai.com/chatgpt.

Dancho, Matt. “A Tool Kit for Working with Time Series [R Package Timetk Version 2.9.0].” The Comprehensive R Archive Network, Comprehensive R Archive Network (CRAN), 31 Oct. 2023, https://cran.r-project.org/web/packages/timetk/index.html. 

DD. “Coding Finance -.” Portfolio Optimization in R, 31 May 2018, www.codingfinance.com/post/2018-05-31-portfolio-opt-in-r/. 

Müller, Kirill. “Simple Data Frames [R Package Tibble Version 3.2.1].” The Comprehensive R Archive Network, Comprehensive R Archive Network (CRAN), 20 Mar. 2023, https://cran.r-project.org/package=tibble. 

Sievert C (2020). Interactive Web-Based Data Visualization with R, plotly, and shiny. Chapman and Hall/CRC. ISBN 9781138331457, https://plotly-r.com.


## License
This project is licensed under the MIT License.
