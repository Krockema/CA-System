#Daten einlesen
GSDataList <- list()
for (i in seq(1,5)) {
	str <- paste("../GS-Daten/GS_5p_", i, "r.txt", sep="")
	GSDataList[[i]] <- read.table(str, sep=";", header= TRUE)
}

#Loop
printDataGSList <- list()
for (j in seq(1, 5)) {
	#Ausgabetabelle erzeugen
	printDataGS <- data.frame("Time"=integer(), "xCenter"=numeric(), "yCenter"=numeric(), "MaximalerRadius"=numeric(), "DurchschnittRadius"=numeric(), "EightyProzentRadius"=numeric(), "AnzahlZellenSystem" = numeric(), "Abdeckung" = numeric())	
	for (i in seq(0,max(GSDataList[[j]]$time),25000)) {
		#Subset erzeugen
		temp <- subset(GSDataList[[j]], GSDataList[[j]]$time==i)
		#print(temp)
		#Mittelpunkt bestimmen
		xCenter <- sum(temp$cell.x)/nrow(temp)
		yCenter <- sum(temp$cell.y)/nrow(temp)

		#Abstand berechnen
		tableDistance <- cbind(temp, "distanceToCenter"=sqrt((temp$cell.x - xCenter)^2 + (temp$cell.y - yCenter)^2))
		
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
		printDataGS <- rbind.data.frame(printDataGS, data.frame("Time"=i, "xCenter"=xCenter, "yCenter"=yCenter, "MaximalerRadius"=maxRadius, "DurchschnittRadius"=meanRadius, "EightyProzentRadius"=eightyRadius, "AnzahlZellenSystem" = numberOfCells, "Abdeckung" = numberOfCells/(50*50)))
	}
	printDataGSList[[j]] <- printDataGS
	
	#Plots
	str <- paste("../Plots/GS/gs_cell_system_evaluation_round_", j, ".pdf", sep="")
	pdf(str)
	plot(printDataGSList[[j]]$Time,printDataGSList[[j]]$MaximalerRadius, type = "p", main="Veränderung des maximalen Radius über die Zeit", lty=3, xlab="Maximaler Radius in Gitterpunkten", ylab="Zeit in MCS", cex=0.2, lwd=1)
	
	plot(printDataGSList[[j]]$Time,printDataGSList[[j]]$DurchschnittRadius, type = "p", main="Veränderung des durchschnittlichen Radius über die Zeit", lty=3, xlab="Durchschnittliche Radius in Gitterpunkten", ylab="Zeit in MCS", cex=0.2, lwd=1)
	
	plot(printDataGSList[[j]]$Time,printDataGSList[[j]]$EightyProzentRadius, type = "p", main="Veränderung des 80-Prozent Radius über die Zeit", lty=3, xlab="80-Prozent Radius in Gitterpunkten", ylab="Zeit in MCS", lwd=1, cex=0.2)
	
	plot(printDataGSList[[j]]$Time, printDataGSList[[j]]$xCenter, type = "p", main="Veränderung des Mittelpunktes über die Zeit", lty=3, xlab="X-Achse", ylab="Y-Achse", col="red", lwd=1, cex=0.5)
	lines(printDataGSList[[j]]$Time,printDataGSList[[j]]$yCenter, type = "p", lty=3, col="orange", lwd=1, cex=0.5)
	legend("topright", legend=c("x", "y"), col=c("red", "orange"), lty = c(3, 3))
	dev.off()

	#printData in Datei überführen
	str <- paste("../Skript-Daten/GS/gsDataGoalRound", j, ".txt", sep="")
	write.table(printDataGSList[[j]], file = str, sep="\t")
	rm(printDataGS)
}

#Gemeinsamkeiten suchen
GSSimilarity <- data.frame("Time"=integer(), "AbdeckungDurchschnitt"=numeric(), "AbdeckungMax"=numeric(),"AbdeckungMin"=numeric(), "AbdeckungUnterschied"=numeric())
for (j in seq(0,max(printDataGSList[[j]]$Time),25000)) {
	GSSimilarityData <- data.frame("Time"=numeric(), "Abdeckung"=numeric())
	for (i in seq(1, 5)) {
		temp <- subset(printDataGSList[[i]], printDataGSList[[i]]$Time==j)
		GSSimilarityData <- rbind.data.frame(GSSimilarityData, data.frame("Time" = temp$Time, "Abdeckung" = temp$Abdeckung))
	}
	GSSimilarity <- rbind.data.frame(GSSimilarity, data.frame("Time" = max(GSSimilarityData$Time), "AbdeckungDurchschnitt" = mean(GSSimilarityData$Abdeckung), "AbdeckungMax" = max(GSSimilarityData$Abdeckung), "AbdeckungMin" = min(GSSimilarityData$Abdeckung), "AbdeckungUnterschied"=max(GSSimilarityData$Abdeckung)-min(GSSimilarityData$Abdeckung)))
}

#Plot mean/max/min
str <- paste("../Plots/GS/gs_cell_system_evaluation_similarities.pdf", sep="")
pdf(str)
plot(GSSimilarity$Time/(50*50), GSSimilarity$AbdeckungDurchschnitt, type="p", lty=3, lwd=1, cex=0.1, main="GS Abdeckungsrate im Durchschnitt mit Min-/Max-Werten", ylab="Abdeckung Durchschnitt mit Abweichungen in Gitterpunkten", xlab="Zeit in MCS", ylim=c(0,1))
arrows(GSSimilarity$Time/(50*50), GSSimilarity$AbdeckungMin, GSSimilarity$Time/(50*50), GSSimilarity$AbdeckungMax, length=0.05, angle=90, code=3)
dev.off()

#GSSimilarity in Datei überführen
str <- paste("../Skript-Daten/GS/gsRoundsSimilarity.txt", sep="")
write.table(GSSimilarity, file = str, sep="\t")