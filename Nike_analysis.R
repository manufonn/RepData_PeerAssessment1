

```{r}
#install.packages("tidyverse")
```


```{r }
library(tidyverse)
library(lubridate)
library(lattice)
#getwd()
```


# Code for reading in the dataset and/or processing the data
```{r }



fileURL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"

download.file(fileURL, destfile = "nikedata.zip")

unzip("nikedata.zip")

nike <- read.csv("activity.csv")
```


# Histogram of the total number of steps taken each day

```{r }

par(mfrow = c(1,1))

nike[["date"]] <- as_date(nike[["date"]], ymd())

daynike <- nike %>% group_by(date) %>% summarise(Totsteps = sum(steps, na.rm = TRUE))

hist(daynike$Totsteps,col = "red", xlab = "Total Steps", main = "Histogram")
```



# Mean and median number of steps taken each day

```{r }

mean(daynike$Totsteps, na.rm = TRUE)

median(daynike$Totsteps, na.rm = TRUE)

```


# Time series plot of the average number of steps taken

````{r }

meanSTEPS <- nike %>% group_by(date) %>% summarise(avg = mean(steps, na.rm = TRUE))

qplot(data = meanSTEPS, x = date, y = avg, geom = "path", ylab = "Average Steps", xlab = " ")
```


# The 5-minute interval that, on average, contains the maximum number of steps

```{r }


intnike <- nike %>% group_by(interval) %>% summarise(avg = mean(steps, na.rm = TRUE))
# view(intnike)


# max(intnike$avg, na.rm = TRUE) Here we find the max value first, then use to filter row that matches.
# 206.1698
maxinterval <- intnike %>% filter(avg == max(intnike$avg, na.rm = TRUE))

view(maxinterval)
```

# Calculate and report the total number of missing values in the dataset(NAs)


```{r}

sum(is.na(nike))
```

# Code to describe and show a strategy for imputing missing data

Devise a strategy for filling in all of the missing values in the dataset. The strategy does not need to be sophisticated. For example, you could use the mean/median for that day, or the mean for that 5-minute interval, etc.
Create a new dataset that is equal to the original dataset but with the missing data filled in (cleannike).
Make a histogram of the total number of steps taken each day and calculate and report the mean and median total number of steps taken per day. Do these values differ from the estimates from the first part of the assignment? What is the impact of imputing missing data on the estimates of the total daily number of steps?
        
        
        ```{r}  
Intvmean <- nike %>% group_by(interval) %>% summarise(meanSTEPS = mean(steps, na.rm = TRUE)) # group by interval and get the mean number of steps for each interval.


cleannike <- nike %>% group_by(date, interval)



cleannike$steps[is.na(cleannike$steps)] <- Intvmean$meanSTEPS 
# For any rows in cleannike that contain NA replace these with the mean number of steps for each interval.
```


# Histogram of the total number of steps taken each day after missing values are imputed

```{r}

nikenew <- cleannike %>% group_by(date) %>% summarise(Totalstp = sum(steps))

hist(nikenew$Totalstp, col = "blue", xlab = "Total Steps", main = "Histogram")
```

# Calculate and report the mean and median total number of steps taken per day.

```{r} 

mean(nikenew$Totalstp)


median(nikenew$Totalstp)
```


# Panel plot comparing the average number of steps taken per 5-minute interval across weekdays and weekends

```{r}
nikeweeks <- cleannike %>% ungroup() %>% mutate(weekdays = weekdays(as_date(cleannike[["date"]])))


nikewk_type <- nikeweeks %>% mutate(weektype = ifelse(nikeweeks$weekdays %in% c("Saturday", "Sunday"), "WkEnd", "WDay"))

table(nikewk_type$weektype)
```



# PLOT

```{R}

cobo <- nikewk_type %>% group_by(interval, weektype) %>% summarise(menot = mean(steps))

xyplot(menot ~ interval | weektype, data=cobo, type="l", layout=c(1,2))
```


### E - N - D