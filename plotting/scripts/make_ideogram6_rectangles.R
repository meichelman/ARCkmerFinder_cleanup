# differs from make_ideogram4_rectangles.R in that it labels
# the top N% locations


# options(echo=TRUE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

szOutput <- args[1]
szInputBedFile <- args[2]
szTitle <- args[3]
szTopNPerCentWindows <- args[4]

szAssemblyBedFile <- args[5]
szFileOfContigsToDisplayOnLeft  <- args[6]
szFileOfContigsToDisplayOnRight <- args[7]

# args[6]
# szFileOfContigsToDisplayOnLeft
l_chroms_part1 = scan( szFileOfContigsToDisplayOnLeft, what = "character" )
# l_chroms_part1
l_chroms_part2 = scan( szFileOfContigsToDisplayOnRight,what = "character" )
# l_chroms_part2

# szFileOfContigsToDisplayOnLeft

l_chroms_part1 = scan( szFileOfContigsToDisplayOnLeft, what = "character" )

# szFileOfContigsToDisplayOnRight

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
# options( echo = TRUE )

custom.genome <- toGRanges(read.delim( szAssemblyBedFile, header=F, sep=''))

data <- read.delim( szInputBedFile, header = F,sep='')
# no longer showing putative introgressed regions
#regions <- read.delim( szInputRegionsForRectangles, header = F, sep = '' )
topNPerCentWindows <- read.delim( szTopNPerCentWindows, header = F, sep = '' )


plot.params <- getDefaultPlotParams(plot.type=1)



nMax = ceiling(max(data$V4)/1e3)*1e3


r1 = 0.8
r0 = 0.0

#rTopNPerCentWindows = 0.6
rTopNPerCentWindowsTop = 0.8
rTopNPerCentWindowsBottom = 0.6

p1 <- as.ggplot(expression(kp <- plotKaryotype(genome = custom.genome, plot.type = 1, chromosomes=l_chroms_part1, plot.params = plot.params) %>% kpAddBaseNumbers(tick.dist = 20e6, add.units = "Mbp", cex=0.5 ),
   kpAddMainTitle(kp, main= szTitle ),  
   kpPoints( kp, chr = as.character( data$V1 ), x = data$V2, 
            y = data$V4, pch=".", cex=5, ymax = nMax, r0 = r0, r1 = r1),


   kpRect( kp, 
           chr = as.character( topNPerCentWindows$V1 ), 
           x0 = topNPerCentWindows$V2,
           x1 = topNPerCentWindows$V3,
           y0 = rTopNPerCentWindowsBottom,
           y1 = rTopNPerCentWindowsTop,
           border = "darkolivegreen",
           r0 = r0,
           r1 = r1 ),


#   kpPoints( kp, chr = as.character( topNPerCentWindows$V1 ), x =
#   topNPerCentWindows$V2, y = rtopNPerCentWindows, pch = 24, col =
#   "darkolivegreen", bg = "darkolivegreen", cex = 0.5 ),


# no longer showing putative introgressed regions (12/5/2024)
#   kpRect( kp, chr = as.character( regions$V1 ), x0 = regions$V2, x1 =
#                           regions$V3, y0 = 0.8, y1 = 1.0, col = "black", r0 = r0, r1 = r1 ),
	kpAxis(kp, ymin = 0, ymax = nMax, r0=r0, r1= r1, numticks = 3, col="#666666", cex=1.0)  
))

p2 <- as.ggplot(expression(kp <- plotKaryotype(genome = custom.genome, plot.type = 1, chromosomes=l_chroms_part2, plot.params = plot.params) %>% kpAddBaseNumbers(tick.dist = 20e6, add.units = "Mbp", cex=0.5 ),

   kpPoints( kp, chr = as.character( data$V1 ), x = data$V2, y = data$V4, 
             pch=".", cex=5, ymax = nMax, r0 = r0, r1 = r1),

   kpRect( kp, 
           chr = as.character( topNPerCentWindows$V1 ), 
           x0 = topNPerCentWindows$V2,
           x1 = topNPerCentWindows$V3,
           y0 = rTopNPerCentWindowsBottom,
           y1 = rTopNPerCentWindowsTop,
           border = "darkolivegreen",
           r0 = r0,
           r1 = r1 ),


#   kpPoints( kp, chr = as.character( topNPerCentWindows$V1 ), x = topNPerCentWindows$V2, y = rtopNPerCentWindows, pch = 24, col = "darkolivegreen", bg = "darkolivegreen", cex = 0.5 ),



# no longer showing putative introgressed regions (12/5/2024)
#   kpRect( kp, chr = as.character( regions$V1 ), x0 = regions$V2, x1 =
#                           regions$V3, y0 = 0.8, y1 = 1.0, col = "black", r0 = r0, r1 = r1 ),
   kpAxis(kp, ymin = 0, ymax = nMax, r0=r0, r1=r1, numticks = 3, col="#666666", cex=1.0)
))

p1 <- p1 + theme_base()
p2 <- p2 + theme_base()

save_plot( szOutput,  plot_grid(p1, p2, ncol=2,  rel_widths = c(1.75,1.75)), base_width = 15, base_height = 9)

