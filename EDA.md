R Notebook
================

This is an [R Markdown](http://rmarkdown.rstudio.com) Notebook. When you
execute code within the notebook, the results appear beneath the code.

Try executing this chunk by clicking the *Run* button within the chunk
or by placing your cursor inside it and pressing
*Ctrl+Shift+Enter*.

``` r
if (!require("pacman")) install.packages("pacman")
```

    ## Loading required package: pacman

``` r
pacman::p_load(data.table, dplyr,lubridate,ggplot2,stringr)
```

``` r
df <- fread('data/bikes_preprocessed_with_LOR_and_districts_and_duration_and_distance_and_speed.csv')

df <- df%>% filter(!providerId==2)

df$timestamp <- ymd_hms(df$timestamp)
df$end_timestamp <- ymd_hms(df$end_timestamp)

df$week <- lubridate::week(df$timestamp)
df$day <- lubridate::date(df$timestamp)
df$week_provider <- str_c(df$week,df$providerId)
```

# plot distribution per provider per week

``` r
groupy.week.provider <- df %>% group_by(providerId,week) %>% summarise(trips=n())

g <- ggplot(groupy.week.provider, aes(week,trips,color=as.factor(providerId)))
g + geom_line()
```

![](EDA_files/figure-gfm/unnamed-chunk-3-1.png)<!-- --> \#\# plot trips
per provider per
day

``` r
groupy.date.provider <- df %>% group_by(providerId,day) %>% summarise(trips=n())

g <- ggplot(groupy.date.provider, aes(day,trips,color=as.factor(providerId)))
g + geom_line()
```

![](EDA_files/figure-gfm/unnamed-chunk-4-1.png)<!-- --> \#\# plot median
speed per day per
provider

``` r
groupy.date.provider.speed <- df %>% filter(speed>1 & mode=='trip') %>%group_by(providerId,day) %>% summarise(median_speed=median(speed))

g <- ggplot(groupy.date.provider.speed, aes(day,median_speed,color=as.factor(providerId)))
g + geom_line()
```

![](EDA_files/figure-gfm/unnamed-chunk-5-1.png)<!-- --> \#\# plot median
duration per day per
provider

``` r
groupy.date.provider.duration <- df %>% filter(speed>1 & mode=='trip'& duration_minutes<50) %>%group_by(providerId,day) %>% summarise(median_duration=median(duration_minutes))

g <- ggplot(groupy.date.provider.duration, aes(day,median_duration,color=as.factor(providerId)))
g + geom_line()
```

![](EDA_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

``` r
ggplot(df %>% filter(mode=='trip' & speed >1 & speed<30 & duration_minutes<60),aes(distance_direct/1000, fill=as.factor(providerId)))+ geom_histogram(bins = 300,alpha=.5)+ facet_wrap(.~week)
```

![](EDA_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

## Sankey

``` r
groupy <- df %>% filter(mode=='trip') %>% group_by(from_spatial_na,to_spatial_na) %>% summarise(total=n())
groupy$from_spatial_na<-paste0('start_',groupy$from_spatial_na)
groupy$to_spatial_na<-paste0('end_',groupy$to_spatial_na)

groupy <- groupy %>% ungroup() %>% select(source=from_spatial_na,target=to_spatial_na,value=total)%>% as.data.frame(.) 

groupy <- groupy  %>% filter(!source==target) %>% filter(value>2000)

df.source <- groupy$source %>% as.data.frame()
df.target <- groupy$target %>% as.data.frame()

df.indexes <- rbind(df.source,df.target) %>% unique()
colnames(df.indexes)<- c('spatial_na')

df.indexes <- df.indexes %>% mutate(id = row_number()) 
df.indexes$id <- df.indexes$id -1


groupy <- merge(groupy,df.indexes,by.x='source',by.y='spatial_na')
groupy <- merge(groupy,df.indexes,by.x='target',by.y='spatial_na')

groupy <- groupy %>% select(source=id.x,target=id.y,value=value)# %>% filter(target>0)



nodes <-df.indexes %>% select(spatial_na)
colnames(nodes) <- c('name')
nodes$name <- as.character(nodes$name)
nodes <- as.data.frame(nodes)


 

# Now we have 2 data frames: a 'links' data frame with 3 columns (from, to, value), and a 'nodes' data frame that gives the name of each node.



 
# Thus we can plot it
# p <- sankeyNetwork(Links = groupy, Nodes = nodes, Source = "source",
#               Target = "target", Value = "value", NodeID = "name",
#               units = "TWh", fontSize = 12, nodeWidth = 10)

#saveNetwork(p,'sankey.html',selfcontained = TRUE)
```
