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
str <- paste("../Skript-Daten/MorpheusMassData.txt")
morpheusMassData <- read.table(str, sep="\t", header= TRUE)
morpheusMassData <- morpheusMassData[order(morpheusMassData$Volume), ]

#build matrix for heatmap
rnames <- c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0)
cnames <- c(-25, -20, -15, -10, -5, 0, 5, 10, 15, 20, 25)
mat = matrix(, nrow=length(rnames), ncol=length(cnames))

for (j in 1:length(cnames))
	for(i in 1:length(rnames)) {
		tempX = (i - 1) / 5
		tempY = j * 5 - 30
		tempData <- subset(morpheusMassData, morpheusMassData$ICC==tempY & morpheusMassData$Volume == tempX)
		if (tempData != Inf)
			mat[i, j] = tempData[[1]]
		else 
			mat[i, j] = 0
	}
rownames(mat) <- rnames 
colnames(mat) <- cnames

# creates a own color palette from red to green
my_palette <- colorRampPalette(c("brown", "green", "yellow", "red"))(n = 309)

# (optional) defines the color breaks manually for a "skewed" color transition
col_breaks = c(seq(0,1,length=10),		# for brown
	seq(2,100,length=100),  			# for green
	seq(101,300,length=100),           # for yellow
	seq(301,700,length=100))           # for red							
	
# creates a 5 x 5 inch image
png("../Plots/heatmapMorpheus.png",    # create PNG for the heat map        
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
		xlab="Lambda_V",
		ylab="Inter-Cell Communication"
		)            # turn off column clustering

	dev.off()               # close the PNG device