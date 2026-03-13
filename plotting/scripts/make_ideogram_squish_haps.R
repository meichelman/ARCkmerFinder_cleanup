# differs from make_ideogram4_rectangles.R in that it labels
# the top 1% locations


options(echo=TRUE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

szOutput <- args[1]
szInputBedFile <- args[2]
szTitle <- args[3]
szTopOnePerCentWindows <- args[4]
szTopOnePerCentWindowsOtherHaplotype <- args[5]
# this is the putative introgressed regions
szInputRegionsForRectangles <- args[6]
szAssemblyBedFile <- args[7]
szFileOfContigsToDisplayOnLeft  <- args[8]
szFileOfContigsToDisplayOnRight <- args[9]



l_chroms_part1 = scan( szFileOfContigsToDisplayOnLeft, what = "character" )
l_chroms_part1
l_chroms_part2 = scan( szFileOfContigsToDisplayOnRight,what = "character" )
l_chroms_part2

szFileOfContigsToDisplayOnLeft

l_chroms_part1 = scan( szFileOfContigsToDisplayOnLeft, what = "character" )

szFileOfContigsToDisplayOnRight

l_chroms_part2 = scan( szFileOfContigsToDisplayOnRight, what = "character" )



library(ggplot2)
library(gridExtra)
library(ggpubr)
library(karyoploteR)
library(plyranges)
library(tidyr)
library(dplyr)
library(stringr)
library(ggplotify)
library(cowplot)


if(!require('ggthemes')) {
  install.packages( "ggthemes", repos='https://ftp.osuosl.org/pub/cran/' )  
  library('ggthemes')
}



options(digits=20)
options( echo = TRUE )

custom.genome <- toGRanges(read.delim( szAssemblyBedFile, header=F, sep=''))

data <- read.delim( szInputBedFile, header = F,sep='')
# no longer showing putative introgressed regions
#regions <- read.delim( szInputRegionsForRectangles, header = F, sep = '' )
topOnePerCentWindows <- read.delim( szTopOnePerCentWindows, header = F, sep = '' )
topOnePerCentWindowsOtherHaplotype <- read.delim( szTopOnePerCentWindowsOtherHaplotype, header = F, sep = '' )

plot.params <- getDefaultPlotParams(plot.type=1)



nMax = ceiling(max(data$V4)/1e3)*1e3


r1 = 0.8
r0 = 0.0

#rTopOnePerCentWindows = 0.6
rTopOnePerCentWindowsTop = 0.8
rTopOnePerCentWindowsBottom = 0.7
rTopOnePerCentWindowsTopOtherHaplotype = 0.7
rTopOnePerCentWindowsBottomOtherHaplotype = 0.6

p1 <- as.ggplot(expression(kp <- plotKaryotype(genome = custom.genome, plot.type = 1, chromosomes=l_chroms_part1, plot.params = plot.params) %>% kpAddBaseNumbers(tick.dist = 20e6, add.units = "Mbp", cex=0.5 ),
   kpAddMainTitle(kp, main= szTitle ),  
   kpPoints( kp, chr = as.character( data$V1 ), x = data$V2, 
            y = data$V4, pch=".", col=data$V5, cex=5, ymax = nMax, r0 = r0, r1 = r1),


   kpRect( kp, 
           chr = as.character( topOnePerCentWindows$V1 ), 
           x0 = topOnePerCentWindows$V2,
           x1 = topOnePerCentWindows$V3,
           y0 = rTopOnePerCentWindowsBottom,
           y1 = rTopOnePerCentWindowsTop,
           col = "darkolivegreen",
           border = "darkolivegreen",
           r0 = r0,
           r1 = r1 ),


   kpRect( kp, 
           chr = as.character( topOnePerCentWindowsOtherHaplotype$V1 ), 
           x0 = topOnePerCentWindowsOtherHaplotype$V2,
           x1 = topOnePerCentWindowsOtherHaplotype$V3,
           y0 = rTopOnePerCentWindowsBottomOtherHaplotype,
           y1 = rTopOnePerCentWindowsTopOtherHaplotype,
           col = "coral3",
           border = "coral3",
           r0 = r0,
           r1 = r1 ),


#   kpPoints( kp, chr = as.character( topOnePerCentWindows$V1 ), x =
#   topOnePerCentWindows$V2, y = rTopOnePerCentWindows, pch = 24, col =
#   "darkolivegreen", bg = "darkolivegreen", cex = 0.5 ),


# no longer showing putative introgressed regions (12/5/2024)
#   kpRect( kp, chr = as.character( regions$V1 ), x0 = regions$V2, x1 =
#                           regions$V3, y0 = 0.8, y1 = 1.0, col = "black", r0 = r0, r1 = r1 ),
	kpAxis(kp, ymin = 0, ymax = nMax, r0=r0, r1= r1, numticks = 3, col="#666666", cex=1.0)  
))

p2 <- as.ggplot(expression(kp <- plotKaryotype(genome = custom.genome, plot.type = 1, chromosomes=l_chroms_part2, plot.params = plot.params) %>% kpAddBaseNumbers(tick.dist = 20e6, add.units = "Mbp", cex=0.5 ),

   kpPoints( kp, chr = as.character( data$V1 ), x = data$V2, y = data$V4, 
             pch=".", col=data$V5, cex=5, ymax = nMax, r0 = r0, r1 = r1),

   kpRect( kp, 
           chr = as.character( topOnePerCentWindows$V1 ), 
           x0 = topOnePerCentWindows$V2,
           x1 = topOnePerCentWindows$V3,
           y0 = rTopOnePerCentWindowsBottom,
           y1 = rTopOnePerCentWindowsTop,
           col = "darkolivegreen",
           border = "darkolivegreen",
           r0 = r0,
           r1 = r1 ),


   kpRect( kp, 
           chr = as.character( topOnePerCentWindowsOtherHaplotype$V1 ), 
           x0 = topOnePerCentWindowsOtherHaplotype$V2,
           x1 = topOnePerCentWindowsOtherHaplotype$V3,
           y0 = rTopOnePerCentWindowsBottomOtherHaplotype,
           y1 = rTopOnePerCentWindowsTopOtherHaplotype,
           col = "coral3",
           border = "coral3",
           r0 = r0,
           r1 = r1 ),


#   kpPoints( kp, chr = as.character( topOnePerCentWindows$V1 ), x = topOnePerCentWindows$V2, y = rTopOnePerCentWindows, pch = 24, col = "darkolivegreen", bg = "darkolivegreen", cex = 0.5 ),



# no longer showing putative introgressed regions (12/5/2024)
#   kpRect( kp, chr = as.character( regions$V1 ), x0 = regions$V2, x1 =
#                           regions$V3, y0 = 0.8, y1 = 1.0, col = "black", r0 = r0, r1 = r1 ),
   kpAxis(kp, ymin = 0, ymax = nMax, r0=r0, r1=r1, numticks = 3, col="#666666", cex=1.0)
))

p1 <- p1 + theme_base()
p2 <- p2 + theme_base()

save_plot( szOutput,  plot_grid(p1, p2, ncol=2,  rel_widths = c(1,1)), base_width = 15, base_height = 9)

