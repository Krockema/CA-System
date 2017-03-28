##Parameter LambdaV
#Daten einlesen
morpheusDataList <- list()
for (i in c(0, 0.5, 1.5, 2)) {
	str <- paste("../Morpheus-Daten/Veränderung der Variablen/LambdaV ", i, "/logger.txt", sep="")
	if (i == 0)
		morpheusDataList[[1]] <- read.table(str, sep="\t", header= TRUE)
	if (i == 0.5)
		morpheusDataList[[2]] <- read.table(str, sep="\t", header= TRUE)
	if (i == 1.5)
		morpheusDataList[[3]] <- read.table(str, sep="\t", header= TRUE)
	if (i == 2)
		morpheusDataList[[4]] <- read.table(str, sep="\t", header= TRUE)
}

#Einzelne Datensätze auswerten
printDataMorpheusList <- list()
for (j in seq(1, 4)) {
	#Ausgabetabelle erzeugen
	printDataMorpheus <- data.frame("Time"=numeric(), "xCenter"=numeric(), "yCenter"=numeric(), "MaximalerRadius"=numeric(), "DurchschnittRadius"=numeric(), "EightyProzentRadius"=numeric(), "DurchschnittAnzahlZellen"=numeric(), "AnzahlZellenSystem" = numeric(), "Abdeckung" = numeric())
	for (i in seq(0,max(morpheusDataList[[j]]$time),10)) {
		#Subset erzeugen
		temp <- subset(morpheusDataList[[j]], morpheusDataList[[j]]$time==i)

		#Mittelpunkt bestimmen
		xCenter <- sum(temp$cell.center.x)/nrow(temp)
		yCenter <- sum(temp$cell.center.y)/nrow(temp)

		#Abstand berechnen
		tableDistance <- cbind(temp, "distanceToCenter"=sqrt((temp$cell.center.x - xCenter)^2 + (temp$cell.center.y - yCenter)^2))

		#max. Umkreis bestimmen
		maxRadius <- max(tableDistance$distanceToCenter)

		#mean Umkreis bestimmen
		meanRadius <- mean(tableDistance$distanceToCenter)

		#80% Umkreis bestimmen
		tableSorted <- tableDistance[order(tableDistance$distanceToCenter),]
		eightyRadius <- tableSorted$distanceToCenter[nrow(tableSorted)/10*8]

		#Durchschnitt Zellen
		meanCells <- mean(tableSorted$cell.surface)
		
		#Anzahl Zellen im System
		numberOfCells <- nrow(temp)

		#Daten zur Tabelle hinzufügen
		printDataMorpheus <- rbind.data.frame(printDataMorpheus, data.frame("Time"=i, "xCenter"=xCenter, "yCenter"=yCenter, "MaximalerRadius"=maxRadius, "DurchschnittRadius"=meanRadius, "EightyProzentRadius"=eightyRadius, "DurchschnittAnzahlZellen"=meanCells, "AnzahlZellenSystem" = numberOfCells, "Abdeckung" = numberOfCells/(224*224)))
	}
	printDataMorpheusList[[j]] <- printDataMorpheus
	
	#Plots
	str <- paste("../Plots/Variables/LambdaV/morpheus_cell_system_evaluation_round_", j, ".pdf", sep="")
	pdf(str)
	plot(printDataMorpheusList[[j]]$Time,printDataMorpheusList[[j]]$MaximalerRadius, type = "p", main="Veränderung des maximalen Radius über die Zeit", lty=3, lwd=1, cex=0.2, xlab="Maximaler Radius in Gitterpunkten", ylab="Zeit in MCS")
	
	plot(printDataMorpheusList[[j]]$Time,printDataMorpheusList[[j]]$DurchschnittRadius, type = "p", main="Veränderung des durchschnittlichen Radius über die Zeit", lty=3, lwd=1, cex=0.2, xlab="Durchschnittlicher Radius in Gitterpunkten", ylab="Zeit in MCS")
	
	plot(printDataMorpheusList[[j]]$Time,printDataMorpheusList[[j]]$EightyProzentRadius, type = "p", main="Veränderung des 80-Prozent Radius über die Zeit", lty=3, lwd=1, cex=0.2, xlab="80-Prozent Radius in Gitterpunkten", ylab="Zeit in MCS")
	
	plot(printDataMorpheusList[[j]]$Time,printDataMorpheusList[[j]]$DurchschnittAnzahlZellen, type = "p", main="Veränderung der durchschnittlichen Anzahl an Zellen über die Zeit", lty=3, lwd=1, cex=0.2, xlab="Durchschnittliche Anzahl an Zellen im Verbund", ylab="Zeit in MCS")
	
	plot(printDataMorpheusList[[j]]$Time,printDataMorpheusList[[j]]$xCenter, type = "p", main="Veränderung des Mittelpunktes über die Zeit", lty=3, lwd=1, ylim=c(110,115), col="red", cex=0.5, xlab="x", ylab="y")
	lines(printDataMorpheusList[[j]]$Time,printDataMorpheusList[[j]]$yCenter, type = "p", lty=3, lwd=1, col="orange", cex=0.5)
	legend("topright", legend=c("x", "y"), col=c("red", "orange"), lty = c(3, 3))

	dev.off()

	#printData in Datei überführen
	str <- paste("../Skript-Daten/Variables/LambdaV/morpheusDataLambdaV ", j, ".txt", sep="")
	write.table(printDataMorpheusList[[j]], file = str, sep="\t")
	rm(printDataMorpheus)
}

#Daten gemeinsam darstellen
str <- paste("../Plots/Variables/LambdaV/morpheus_cell_system_evaluation.pdf", sep="")
pdf(str)
plot(printDataMorpheusList[[1]]$Time, printDataMorpheusList[[1]]$MaximalerRadius, type = "p", main="Veränderung des maximalen Radius über die Zeit", lty=3, lwd=1, cex=0.5, xlab="Maximaler Radius in Gitterpunkten", ylab="Zeit in MCS")
for (j in seq(2,4))
	lines(printDataMorpheusList[[j]]$Time, printDataMorpheusList[[j]]$MaximalerRadius, type="p", lty=3, col=j, lwd=1, cex=0.5) 
legend("bottomright", legend=c("0", "0.5", "1.5", "2"), col=c(1, 2, 3, 4), lty = c(3, 3, 3, 3), title="Werte für Lambda_V")
		
plot(printDataMorpheusList[[1]]$Time,printDataMorpheusList[[1]]$DurchschnittRadius, type = "p", main="Veränderung des durchschnittlichen Radius über die Zeit", lty=3, lwd=1, cex=0.5, xlab="Durchschnittlicher Radius in Gitterpunkten", ylab="Zeit in MCS")
for (j in seq(2,4))
	lines(printDataMorpheusList[[j]]$Time, printDataMorpheusList[[j]]$DurchschnittRadius, type="p", lty=3, col=j, lwd=1, cex=0.5) 
legend("bottomright", legend=c("0", "0.5", "1.5", "2"), col=c(1, 2, 3, 4), lty = c(3, 3, 3, 3), title="Werte für Lambda_V")
		
plot(printDataMorpheusList[[1]]$Time,printDataMorpheusList[[1]]$EightyProzentRadius, type = "p", main="Veränderung des 80-Prozent Radius über die Zeit", lty=3, lwd=1, cex=0.5, xlab="80-Prozent Radius in Gitterpunkten", ylab="Zeit in MCS")
for (j in seq(2,4))
	lines(printDataMorpheusList[[j]]$Time, printDataMorpheusList[[j]]$EightyProzentRadius, type="p", lty=3, col=j, lwd=1, cex=0.5) 
legend("bottomright", legend=c("0", "0.5", "1.5", "2"), col=c(1, 2, 3, 4), lty = c(3, 3, 3, 3), title="Werte für Lambda_V")
		
plot(printDataMorpheusList[[1]]$Time,printDataMorpheusList[[1]]$DurchschnittAnzahlZellen, type = "p", main="Veränderung der durchschnittlichen Anzahl an Zellen über die Zeit", lty=3, lwd=1, cex=0.5, xlab="Durchschnittliche Anzahl an Zellen", ylab="Zeit in MCS")
for (j in seq(2,4))
	lines(printDataMorpheusList[[j]]$Time, printDataMorpheusList[[j]]$DurchschnittlicheAnzahlZellen, type="p", lty=3, col=j, lwd=1, cex=0.5) 
legend("topright", legend=c("0", "0.5", "1.5", "2"), col=c(1, 2, 3, 4), lty = c(3, 3, 3, 3), title="Werte für Lambda_V")

abdeckungsPlot <- list()
for(i in seq(1, 4)) {
	temp <- subset(printDataMorpheusList[[i]], printDataMorpheusList[[i]]$Abdeckung>0.799)
	minTemp <- min(temp$Time)
	abdeckungsPlot <- rbind.data.frame(abdeckungsPlot, data.frame("Time" = minTemp))
}
plot(abdeckungsPlot$Time, c(0, 0.5, 1.5, 2), lty=3, lwd=1, cex=0.5, ylab="Lambda_V", xlab="MCS bis 80% Abdeckung")
dev.off()

#printData in Datei überführen
str <- paste("../Skript-Daten/Variables/LambdaV/morpheusDataGoal.txt", sep="")
write.table(printDataMorpheusList[[j]], file = str, sep="\t")