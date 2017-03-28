#Daten einlesen
CADataList <- list()
for (i in seq(1,5)) {
	str <- paste("../CA-Daten/CA_5p_", i, "r.txt", sep="")
	CADataList[[i]] <- read.table(str, sep=";", header= TRUE)
}

#Loop
printDataCAList <- list()
for (j in seq(1, 5)) {
	#Ausgabetabelle erzeugen
	printDataCA <- data.frame("Time"=integer(), "xCenter"=numeric(), "yCenter"=numeric(), "MaximalerRadius"=numeric(), "DurchschnittRadius"=numeric(), "EightyProzentRadius"=numeric(), "AnzahlZellenSystem" = numeric(), "Abdeckung" = numeric())	
	for (i in seq(25000,max(CADataList[[j]]$time),25000)) {
		#Subset erzeugen
		temp <- subset(CADataList[[j]], CADataList[[j]]$time==i)

		#Mittelpunkt bestimmen
		xCenter <- sum(temp$x)/nrow(temp)
		yCenter <- sum(temp$y)/nrow(temp)

		#Abstand berechnen
		tableDistance <- cbind(temp, "distanceToCenter"=sqrt((temp$x - xCenter)^2 + (temp$y - yCenter)^2))
		
		#max. Umkreis bestimmen
		maxRadius <- max(tableDistance$distanceToCenter)

		#mean Umkreis bestimmen
		meanRadius <- mean(tableDistance$distanceToCenter)

		#80% Umkreis bestimmen
		tableSorted <- tableDistance[order(tableDistance$distanceToCenter),]
		eightyRadius <- tableSorted$distanceToCenter[nrow(tableSorted)/10*8]
		
		#Anzahl Zellen im System
		numberOfCells <- nrow(temp)

		#Daten zur Tabelle hinzufügen
		printDataCA <- rbind.data.frame(printDataCA, data.frame("Time"=i, "xCenter"=xCenter, "yCenter"=yCenter, "MaximalerRadius"=maxRadius, "DurchschnittRadius"=meanRadius, "EightyProzentRadius"=eightyRadius, "AnzahlZellenSystem" = numberOfCells, "Abdeckung" = numberOfCells/(50*50)))
	}
	printDataCAList[[j]] <- printDataCA
	
	#Plots
	str <- paste("../Plots/CA/ca_cell_system_evaluation_round_", j, ".pdf", sep="")
	pdf(str)
	plot(printDataCAList[[j]]$Time,printDataCAList[[j]]$MaximalerRadius, type = "p", main="Veränderung des maximalen Radius über die Zeit", lty=3, xlab="Maximaler Radius in Gitterpunkten", ylab="Zeit in MCS", cex=0.2, lwd=1)
	
	plot(printDataCAList[[j]]$Time,printDataCAList[[j]]$DurchschnittRadius, type = "p", main="Veränderung des durchschnittlichen Radius über die Zeit", lty=3, xlab="Durchschnittliche Radius in Gitterpunkten", ylab="Zeit in MCS", cex=0.2, lwd=1)
	
	plot(printDataCAList[[j]]$Time,printDataCAList[[j]]$EightyProzentRadius, type = "p", main="Veränderung des 80-Prozent Radius über die Zeit", lty=3, xlab="80-Prozent Radius in Gitterpunkten", ylab="Zeit in MCS", lwd=1, cex=0.2)
	
	plot(printDataCAList[[j]]$Time, printDataCAList[[j]]$xCenter, type = "p", main="Veränderung des Mittelpunktes über die Zeit", lty=3, xlab="X-Achse", ylab="Y-Achse", col="red", lwd=1, cex=0.5)
	lines(printDataCAList[[j]]$Time,printDataCAList[[j]]$yCenter, type = "p", lty=3, col="orange", lwd=1, cex=0.5)
	legend("topright", legend=c("x", "y"), col=c("red", "orange"), lty = c(3, 3))
	dev.off()

	#printData in Datei überführen
	str <- paste("../Skript-Daten/CA/caDataGoalRound", j, ".txt", sep="")
	write.table(printDataCAList[[j]], file = str, sep="\t")
	rm(printDataCA)
}

#Gemeinsamkeiten suchen
CASimilarity <- data.frame("Time"=integer(), "AbdeckungDurchschnitt"=numeric(), "AbdeckungMax"=numeric(),"AbdeckungMin"=numeric(), "AbdeckungUnterschied"=numeric())
for (j in seq(25000,max(printDataCAList[[j]]$Time),25000)) {
	CASimilarityData <- data.frame("Time"=numeric(), "Abdeckung"=numeric())
	for (i in seq(1, 5)) {
		temp <- subset(printDataCAList[[i]], printDataCAList[[i]]$Time==j)
		CASimilarityData <- rbind.data.frame(CASimilarityData, data.frame("Time" = temp$Time, "Abdeckung" = temp$Abdeckung))
	}
	CASimilarity <- rbind.data.frame(CASimilarity, data.frame("Time" = max(CASimilarityData$Time), "AbdeckungDurchschnitt" = mean(CASimilarityData$Abdeckung), "AbdeckungMax" = max(CASimilarityData$Abdeckung), "AbdeckungMin" = min(CASimilarityData$Abdeckung), "AbdeckungUnterschied"=max(CASimilarityData$Abdeckung)-min(CASimilarityData$Abdeckung)))
}

#Plot mean/max/min
str <- paste("../Plots/CA/ca_cell_system_evaluation_similarities.pdf", sep="")
pdf(str)
plot(CASimilarity$Time/(50*50), CASimilarity$AbdeckungDurchschnitt, type="p", lty=3, lwd=1, cex=0.1, main="CA Abdeckungsrate im Durchschnitt mit Min-/Max-Werten", ylab="Abdeckung Durchschnitt mit Abweichungen in Gitterpunkten", xlab="Zeit in MCS", ylim=c(0,1))
arrows(CASimilarity$Time/(50*50), CASimilarity$AbdeckungMin, CASimilarity$Time/(50*50), CASimilarity$AbdeckungMax, length=0.05, angle=90, code=3)
dev.off()

#CASimilarity in Datei überführen
str <- paste("../Skript-Daten/CA/caRoundsSimilarity.txt", sep="")
write.table(CASimilarity, file = str, sep="\t")