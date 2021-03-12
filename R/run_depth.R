source("R/depth_FUN.R")

### Input parameters ####
#filepath
files<-list.files("input", full.names = TRUE)
#zenith angle bin size in degrees(default = 5)
zen_bin<-5
#zenith angle range in degrees (default = c(0,55))
zen_range<-c(0,55)
#azimuth angle bin size in degrees (default = 10)
az_bin<-10
#depth percentiles desired (default = c(0.50,0.80,0.90))
percentiles<-c(0.50,0.80,0.90)

#### Apply functions individually####
df<-read.ptx(files)
df<-cbind(df,cart.To.sphere(df))
depth.list<-depth.bin(df, zen_bin, zen_range, az_bin)
depth.list.pct<-depth.pctl(depth.list, percentiles)
depth<-depth.metrics(depth.list.pct)

#### Apply single depth metric function ####

#read ptx file format
df<-read.ptx(files)

#run depth metric calculation
depth<-depth.fun(df, 
                 zen_bin=5, 
                 zen_range=, az_bin, percentiles)


#### Make some plots with ggplot ####
library(ggplot2)
library(viridis)
library(cowplot)
plot_grid(
  ggplot(data = depth.list.pct, aes(x = factor(az_bin), y = p_90, 
                                    group = reorder(zen_bin, rev(zen_bin)),
                                    color=reorder(zen_bin, rev(zen_bin)), 
                                    fill=reorder(zen_bin, rev(zen_bin)))) + 
    ylim(0, NA) +
    geom_polygon(alpha = 0.5) + 
    scale_fill_viridis_d()+
    scale_color_viridis_d()+
    # facet_wrap(~zen_bin)+
    coord_polar(start = - pi) + 
    theme(text = element_text(size = 8.75, colour = "black")) + theme_bw() +
    ylab( expression(90*'th percentile of distance (m)')) + xlab( expression(Azimuth ~ (degrees))) +
    theme(axis.title.x = element_text(vjust=-0.5)) +
    theme(axis.title.y = element_text(vjust=1.5)) +
    theme(plot.title = element_text(vjust=2.5)) +
    theme(legend.position= "none"),
  plot_grid(
    ggplot(data = depth, aes(x = zen_bin, y = p_90_sd, fill=zen_bin)) + 
      geom_bar(stat = "identity")+
      scale_fill_viridis()+
      # scale_color_viridis()+
      theme(text = element_text(size = 8.75, colour = "black")) + theme_bw() +
      ylab( expression(sigma~'Depth (m)')) + xlab( expression(Zenith ~ Angle ~ (degrees))) +
      theme(axis.title.x = element_text(vjust=-0.5)) +
      theme(axis.title.y = element_text(vjust=1.5)) +
      theme(plot.title = element_text(vjust=2.5)) +
      theme(legend.position= "none"),
    
    ggplot(data = depth, aes(x = zen_bin, y = p_90_sd/p_90*100, fill=zen_bin)) + 
      geom_bar(stat = "identity")+
      scale_fill_viridis()+
      # scale_color_viridis()+
      theme(text = element_text(size = 8.75, colour = "black")) + theme_bw() +
      ylab( expression(sigma~'Depth (%)')) + xlab( expression(Zenith ~ Angle ~ (degrees))) +
      theme(axis.title.x = element_text(vjust=-0.5)) +
      theme(axis.title.y = element_text(vjust=1.5)) +
      theme(plot.title = element_text(vjust=2.5)) +
      theme(legend.position= "none"),
    labels=c("B","C"), nrow=1),
  labels=c("A",NA), nrow=2, rel_heights = c(0.6,0.4))
ggsave("output/plot_radius_depth_metrics.pdf", width = 3.75, height = 3.75*1.5, units = "in")

