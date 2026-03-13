options(echo=TRUE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)


szFile = args[1]
szTitle = args[2]
szInputFile = args[3]


library(ggplot2)


png( szFile, width = 1000, height = 600  )


df <- read.table( szInputFile, comment.char = '' )


# Change density plot line colors by groups
p <- ggplot(df, aes(x=V4, fill=V5, y = after_stat(density))) +
  geom_histogram(position="dodge", bins = 100 )

p <- p + scale_x_log10()
p <- p + ggtitle( szTitle )


p <- p + xlab("# of kmers found in each 20kb region")
p <- p + ylab("# of 20kb regions with # of kmers on x axis")

p


dev.off()
