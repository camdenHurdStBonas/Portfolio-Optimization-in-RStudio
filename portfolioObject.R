# Portfolio Optimization in rstudio
#   Use historical stock data from Yahoo! fiance to get the optimized portfolio and statistics
#
# Input: 
#   ...: csv files of stock data from yahoo! finance
#   names.list: list of names for each stock
#   RF: risk free rate by default set to zero used for Sharpe ratio of individual stocks and portfolios (not used for excess returns)
#   num.ports: the number of portfolios for the efficient frontier
# Output:
#   Default: returns the object environment
#   get.Cov: returns the covariance matrix of all the stocks
#   get.Cor: returns the correlation matrix of all the stocks
#   get.Stats: returns the average, geometric average, standard deviation, and Sharpe ratio of all the stocks 
#   get.MVP: returns the weights and statistic of the minimum variance portfolio
#   get.MVEP: returns the weights and statistic of the mean-variance efficient portfolio
#   plot.EF: plots the efficient frontier
#   plot.MVP: bar chart of the minimum variance portfolio
#   plot.MVEP: bar chart of the mean-variance efficient portfolio


# portfolio object
portfolio <- function(..., names.list=NULL, RF=0.0, num.ports = 5000) {
  
  # Create an environment to store local variables
  obj <- new.env()
  
  # Get the list of data frames passed to the function
  obj$data.frames <- list(...)
  
  # Check if all elements in obj$data.frames are data frames
  if (!all(sapply(obj$data.frames, is.data.frame))) {
    stop("All inputs must be data frames.")
  }
  
  # Check if all data frames have the 'Adj.Close' column
  if (!all(sapply(obj$data.frames, function(df) "Adj.Close" %in% names(df)))) {
    stop("All data frames must have an 'Adj.Close' column.")
  }
  
  # Check if names.list is provided and contains only strings
  if (!is.null(names.list)) {
    if (!all(sapply(names.list, is.character))) {
      stop("All elements in names.list must be strings.")
    }
  }
  
  # Check if RF is a decimal number greater than or equal to 0 and less than 1
  if (!is.numeric(RF) || RF < 0 || RF >= 1) {
    stop("RF must be a decimal number greater than or equal to 0 and less than 1.")
  }
  
  # Check if num.ports is a whole number greater than 0
  if (!is.numeric(num.ports) || num.ports <= 0 || num.ports != round(num.ports)) {
    stop("num.ports must be a whole number greater than 0.")
  }
  
  # a function that returns a list of rates of changes from previous to the next from a inputted data frame
  percentChangeList <- function(df){
    
    # stores the final output list
    final_rates <- list()
    
    # loop for every number in the data frame, but not the first index will be lost to calculate the changes
    for (i in 2:length(df)){
      
      # calculates the rate
      rate = log(df[i]/df[i-1]) - RF
      
      # add the new rate onto the existing rate
      final_rates <- c(final_rates, rate)
    }
    
    # returns the final list of rates
    return(as.numeric(final_rates))
    
  }
  
  # Find the minimum length among all columns
  obj$min_length <- min(sapply(obj$data.frames, nrow))-1
  
  obj$date <- as.Date(tail(obj$data.frames[[1]]$Date,obj$min_length))
  
  # Extract and manipulate the single column from each data frame
  obj$manipulated_columns <- lapply(obj$data.frames, function(df) {
    
    # gets the returns list for each stocks adj close
    manipulated_values <- percentChangeList(df$Adj.Close)
    
    # Trim or pad the values to make the column length equal to min_length
    length_diff <- obj$min_length - length(manipulated_values)
    if (length_diff > 0) {
      manipulated_values <- c(manipulated_values, rep(NA, length_diff))
    } else if (length_diff <= 0) {
      manipulated_values <- tail(manipulated_values, obj$min_length)
    }
    
    # return the manipulated values back to the coulmns
    return(manipulated_values)
    
  })
  
  
  # Combine the manipulated columns into a data frame
  obj$combined.data <- do.call(cbind, obj$manipulated_columns)
  
  # Set column names for combined.data
  colnames(obj$combined.data) <- names.list
  
  # Calculate the variance-covariance matrix
  obj$cov.matrix <- cov(obj$combined.data)
  rownames(obj$cov.matrix) <- colnames(obj$cov.matrix) <- names.list
  
  # Calculate the variance-covariance matrix
  obj$cor.matrix <- cor(obj$combined.data)
  rownames(obj$cor.matrix) <- colnames(obj$cor.matrix) <- names.list
  
  # Calculate the statistic matrix
  obj$stats.matrix <- matrix(NA, nrow = length(names.list), ncol = 5)
  rownames(obj$stats.matrix) <- names.list
  colnames(obj$stats.matrix) <- c("Average","Geo Mean","Standard Deviation","Sharpe Ratio", "Count")
  
  # Calculate the statistic matrix
  for (i in seq_along(names.list)) {
    col.data <- obj$combined.data[, names.list[i]]
    
    # Average
    obj$stats.matrix[i, 1] <- round(mean(col.data, na.rm = TRUE),4)*100
    
    # Geo Mean
    obj$stats.matrix[i, 2] <- round(exp(mean(log(1 + col.data), na.rm = TRUE)) - 1,4)*100
    
    # Standard Deviation
    obj$stats.matrix[i, 3] <- round(sd(col.data, na.rm = TRUE),4)*100
    
    # Sharpe Ratio
    obj$stats.matrix[i, 4] <- round((mean(col.data, na.rm = TRUE) - RF)/sd(col.data, na.rm = TRUE),4)
    
    # Count
    obj$stats.matrix[i, 5] <- sum(!is.na(col.data))
    
  }
  
  # matrix for all the possible weights
  obj$all.wts <- matrix(nrow = num.ports, ncol = length(names.list))
  
  # vector more all the possible returns
  obj$port.returns <- vector('numeric',length = num.ports)
  
  # vector more all the possible risks
  obj$port.risk <- vector('numeric',length = num.ports)
  
  # vector more all the possible sharpe ratios
  obj$port.sharpe <- vector('numeric',length = num.ports)
  
  # calculate all the possible weights, returns, risks, and sharpe ratio
  for (i in seq_along(obj$port.returns)) {
    
    # Weight calculation
    obj$wts <- runif(n=length(names.list))
    obj$wts <- obj$wts/sum(obj$wts)
    obj$all.wts[i,] <- obj$wts
    
    obj$port.weight.return <- rowSums(obj$combined.data*obj$wts)
    
    # Return calculation
    obj$port.returns[i] <- mean(obj$port.weight.return,na.rm = TRUE)
    
    # Risk calculation
    #obj$port.risk[i]  <- sqrt(t(obj$wts) %*% (obj$cov.matrix %*% obj$wts))
    obj$port.risk[i]  <- sd(obj$port.weight.return,na.rm = TRUE)
    
    # Sharpe Calculation
    obj$port.sharpe[i] <- (obj$port.returns[i]- RF) / obj$port.risk[i]
  }
  
  # tibble creation of all the possible portfolios and their weights, returns, risks, and sharpe
  obj$port.values <- tibble(Return= obj$port.returns, Risk = obj$port.risk, Sharpe= obj$port.sharpe)
  obj$all.wts <- tk_tbl(obj$all.wts)
  colnames(obj$all.wts) <- names.list
  obj$port.values <- round(tk_tbl(cbind(obj$all.wts,obj$port.values)),4)
  
  # findiong the MVP
  obj$min.var <- obj$port.values[which.min(obj$port.values$Risk),]
  
  # finding the MVEP
  obj$max.sr <- obj$port.values[which.max(obj$port.values$Sharpe),]
  
  # Getter function for covariance matrix
  obj$get.Cov <- function() {
    return(obj$cov.matrix)
  }
  
  # Getter function for correlation matrix
  obj$get.Cor <- function() {
    return(obj$cor.matrix)
  }
  
  # Getter function for average and count matrix
  obj$get.Stats <- function() {
    return(obj$stats.matrix)
  }
  
  # Getter function for mvp
  obj$get.MVP <- function() {
    return(obj$min.var)
  }
  
  # Getter function for mvep
  obj$get.MVEP <- function() {
    return(obj$max.sr)
  }
  
  # Plot the effecient frontier
  obj$plot.EF <- function() {
    
    # creation of the plot using the tible
    p <- obj$port.values %>%
      
      # X: Risk & Y: Return with the color of each point representing their sharpe ratio
      ggplot(aes(x = Risk, y = Return, color = Sharpe)) +
      
      # creates scatter plot
      geom_point() +
      
      # classic theme
      theme_classic() +
      
      # percent scale for y axis
      scale_y_continuous(labels = scales::percent) +
      
      # percent scale for x axis
      scale_x_continuous(labels = scales::percent) +
      
      # lables for each point
      labs(x = 'Risk', y = 'Returns', title = "Portfolio Optimization & Efficient Frontier") +
      
      # MVP point
      geom_point(aes(x = Risk, y = Return, label= "MVP", text= paste("Sharpe: ",obj$min.var$Sharpe)),
                 data = obj$min.var, color = 'red') +
      
      # MVEP point
      geom_point(aes(x = Risk, y = Return, label= "MVEP", text= paste("Sharpe: ",obj$max.sr$Sharpe)),
                 data = obj$max.sr, color = 'green')
    
    # Makes the plot
    ggplotly(p)
  }
  
  # Plot the MVP
  obj$plot.MVP <- function() {
    
    # Create a data frame for the plot
    plot_data <- data.frame(Asset = names.list, Weight = unlist(obj$min.var[names.list]))
    
    max.x <- sort(plot_data$Asset, decreasing = TRUE)[2]
    max.y <- max(plot_data$Weight)
    
    p <- ggplot(plot_data, aes(x = Asset, y = Weight, label= scales::percent(Weight))) +
      geom_bar(stat = "identity", fill = "skyblue") +
      labs(title = "Minimum Variance Portfolio Weights", x = "Asset", y = "Weight") +
      theme_classic() +
      
      # percent scale for y axis
      scale_y_continuous(labels = scales::percent) +
      
      geom_text(position = position_stack(vjust = 0.5), color = "black", size = 4) +
      
      theme(legend.position = "top", legend.justification = "right") +
      theme(legend.title = element_blank()) +
      geom_text(aes(x = max.x, y = max.y, label = paste("Return: ", scales::percent(unlist(obj$min.var["Return"]), accuracy = .01))),
                hjust = 0, vjust = 0, color = "black") +
      geom_text(aes(x = max.x, y = max.y-.05, label = paste("Risk: ", scales::percent(unlist(obj$min.var["Risk"]), accuracy = .01))),
                hjust = 0, vjust = 0, color = "black") +
      geom_text(aes(x = max.x, y = max.y-.1, label = paste("Sharpe: ", unlist(obj$min.var["Sharpe"]))),
                hjust = 0, vjust = 0, color = "black")
    
    # Makes the plot
    ggplotly(p)
    
  }
  
  # Plot the MVEP
  obj$plot.MVEP <- function() {
    
    # Create a data frame for the plot
    plot_data <- data.frame(Asset = names.list, Weight = unlist(obj$max.sr[names.list]))
    
    max.x <- sort(plot_data$Asset, decreasing = TRUE)[2]
    max.y <- max(plot_data$Weight)
    
    p <- ggplot(plot_data, aes(x = Asset, y = Weight, label= scales::percent(Weight))) +
      geom_bar(stat = "identity", fill = "skyblue") +
      labs(title = "Mean-Variance Effecient Portfolio Weights", x = "Asset", y = "Weight") +
      theme_classic() +
      
      # percent scale for y axis
      scale_y_continuous(labels = scales::percent) + 
      
      geom_text(position = position_stack(vjust = 0.5), color = "black", size = 4) +
      
      theme(legend.position = "top", legend.justification = "right") +
      theme(legend.title = element_blank()) +
      geom_text(aes(x = max.x, y = max.y, label = paste("Return: ", scales::percent(unlist(obj$max.sr["Return"]), accuracy = .01))),
                hjust = 0, vjust = 0, color = "black") +
      geom_text(aes(x = max.x, y = max.y-.05, label = paste("Risk: ", scales::percent(unlist(obj$max.sr["Risk"]), accuracy = .01))),
                hjust = 0, vjust = 0, color = "black") +
      geom_text(aes(x = max.x, y = max.y-.1, label = paste("Sharpe: ", unlist(obj$max.sr["Sharpe"]))),
                hjust = 0, vjust = 0, color = "black")
    
    # Makes the plot
    ggplotly(p)
    
  }
  
  obj$plot.returns <- function(weights,cpery=12) {
    
    obj$weighted.returns <- rowSums(obj$combined.data * weights)
    obj$weighted.value <- 100 * cumprod(obj$weighted.returns + 1)
    
    # Calculate average, standard deviation, and Sharpe ratio
    avg_return <- mean(obj$weighted.returns, na.rm = TRUE)
    std_dev <- sd(obj$weighted.returns, na.rm = TRUE)
    sharpe_ratio <- (avg_return - RF) / std_dev
    
    end_value <- obj$weighted.value[length(obj$weighted.value)]
    num_years <- length(obj$weighted.value) / cpery
    cagr <- (end_value / 100)^(1/num_years) - 1
    
    plot(obj$date,obj$weighted.returns*100,type="l", xlab = "Date", ylab = "Weighted Returns (%)", main = "Weighted Returns over Time",col='blue')
    
    grid(col='black')
    
    # Adding a dotted line at y = 0
    abline(h = 0, lty = 2)
    
    # Adding legend for names and weights
    legend("topleft", legend = paste(names.list, ": ", round(weights, 3)*100,"%"), col = "black", bty = "n")
    
    # Adding legend for returns with additional information
    legend("bottomleft", legend = c(paste("Average:", round(avg_return, 4)*100,"%"), 
                                  paste("Standard Deviation:", round(std_dev, 4)*100,"%"), 
                                  paste("Sharpe Ratio:", round(sharpe_ratio, 4))), bty = 'n')
   
    
    plot(obj$date,obj$weighted.value,type="l", xlab = "Date", ylab = "Value ($)", main = "Weighted Value over Time ($100 Invested)",col='blue')
    
    grid(col='black')
    
    legend("topleft", legend = c(paste(names.list, ": ", round(weights, 3)*100,"%"),
                                 paste("CAGR:", round(cagr * 100, 2), "%")),
           col = "black", bty = "n")
    
  }
  
  # Return the portfolio object
  return(obj)
}
