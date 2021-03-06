# TLS Depth Complexity

![tls](tls.png)

Algorithms described in "Vegetation structural complexity and biodiversity in the Great Smoky Mountains" (Walter et al. 2021; https://onlinelibrary.wiley.com/doi/10.1002/ecs2.3390) for generating a new complexity metric from single-scan terrestrial laser scanning (TLS) data. 

If you use this metric please cite our study:

Walter, J.A., Stovall, A.E.L., & Atkins, J.W. 2021. Vegetation structural complexity and biodiversity in the Great Smoky Mountains. Ecosphere 12:3. doi:10.1002/ecs2.3390

The following algorithm is based in the R programming language.

## Load the Functions

```{r,echo=FALSE}
source("R/depth_FUN.R")
```

## Options
Several parameters are available: 

```{r,echo=FALSE}
zen_bin<-5
zen_range<-c(0,55)
az_bin<-10
percentiles<-c(0.50,0.80,0.90)
```

`zen_bin` is the zenith angle bin size in degrees (default = 5)

`zen_range` is the zenith angle range in degrees (default = `c(0,55)`)

`az_bin` is the azimuth angle bin size in degrees (default = `10`)

`percentiles` are the depth percentiles desired (default = `c(0.50,0.80,0.90)`)
 
Now, the depth function should be properly configured and ready to run!

## RUN THE PIPELINE
Load packages, functions, and input parameters.
```{r,echo=FALSE}
source("R/depth_FUN.R")
```

Load in your TLS file in R. I wrote a function to read in PTX format files since I use these frequently, but really any single scan file with XYZ columns will work.
```{r,echo=FALSE}
files<-list.files("input", full.names = TRUE)
df<-read.ptx(files)
```

Run `depth.fun`. The output will be a dataframe of zenith angle bins and complexity metrics described in the publication.
```{r,echo=TRUE}
depth<-depth.fun(df, 
                 zen_bin=5, 
                 zen_range=c(0,55), 
                 az_bin=10, 
                 percentiles=c(0.5,0.80,0.90))
```

See `R/run_depth.R` for the example code described above and the plots shown below.


![depth](output/plot_radius_depth_metrics.png)

