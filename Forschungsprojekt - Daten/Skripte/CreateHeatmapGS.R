#########################################################
### A) Installing and loading required packages
#########################################################

if (!require("gplots")) {
	install.packages("gplots", dependencies = TRUE)
	library(gplots)
	}
if (!require("RColorBrewer")) {
	install.packages("RColorBrewer", dependencies = TRUE)
	library(RColorBrewer)
	}
	
#Read the Data
str <- paste("../Skript-Daten/GSMassData.txt")
morpheusMassData <- read.table(str, sep="\t", header= TRUE)
morpheusMassData <- morpheusMassData[order(morpheusMassData$flip), ]

#build matrix for heatmap
rnames <- c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
cnames <- c(5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
mat = matrix(, nrow=length(rnames), ncol=length(cnames))

for (j in 1:length(cnames))
	for(i in 1:length(rnames)) {
		tempX = i - 1
		tempY = j + 4
		tempData <- subset(morpheusMassData, morpheusMassData$divide==tempY & morpheusMassData$flip == tempX)
		if (tempData != Inf)
			mat[i, j] = tempData[[1]]
		else 
			mat[i, j] = 0
	}
rownames(mat) <- rnames 
colnames(mat) <- cnames

# creates a own color palette from red to green
my_palette <- colorRampPalette(c("green", "yellow", "red"))(n = 299)

# (optional) defines the color breaks manually for a "skewed" color transition
col_breaks = c(seq(0,70,length=100),  	  # for green
	seq(71,120,length=100),           # for yellow
	seq(121,200,length=100))           # for red							
	
# creates a 5 x 5 inch image
png("../Plots/heatmapGS.png",    # create PNG for the heat map        
	width = 5*300,        # 5 x 300 pixels
	height = 5*300,
	res = 300,            # 300 pixels per inch
	pointsize = 8)        # smaller font size
	
heatmap.2(t(mat),
		cellnote = t(mat),  # same data set for cell labels
		main = "MCS bis 80% Abdeckung", # heat map title
		notecol="black",      # change font color of cell labels to black
		density.info="none",  # turns off density plot inside color legend
		trace="none",         # turns off trace lines inside the heat map
		margins =c(5,6),     # widens margins around plot
		col=my_palette,       # use on color palette defined earlier
		breaks=col_breaks,    # enable color transition at specified limits
		dendrogram="none", 	  # only draw a row dendrogram
		Colv="NA",
		Rowv="NA ",
		key.title = "MCS",
		xlab="flip",
		ylab="divide"
		)            # turn off column clustering

	dev.off()               # close the PNG device