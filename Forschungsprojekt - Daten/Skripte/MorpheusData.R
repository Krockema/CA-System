#Daten einlesen
morpheusDataList <- list()
for (i in seq(1,10)) {
	str <- paste("../Morpheus-Daten/Standard-Daten/Round ", i, "/logger.txt", sep="")
	morpheusDataList[[i]] <- read.table(str, sep="\t", header= TRUE)
}
#Loop
printDataMorpheusList <- list()
for (j in seq(1, 10)) {
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
	str <- paste("../Plots/Morpheus/morpheus_cell_system_evaluation_round_", j, ".pdf", sep="")
	pdf(str)
	plot(printDataMorpheusList[[j]]$Time,printDataMorpheusList[[j]]$MaximalerRadius, type = "p", main="Veränderung des maximalen Radius über die Zeit", lty=3, xlab="Maximaler Radius in Gitterpunkten", ylab="Zeit in MCS", cex=0.2, lwd=1)
	
	plot(printDataMorpheusList[[j]]$Time,printDataMorpheusList[[j]]$DurchschnittRadius, type = "p", main="Veränderung des durchschnittlichen Radius über die Zeit", lty=3, xlab="Durchschnittliche Radius in Gitterpunkten", ylab="Zeit in MCS", cex=0.2, lwd=1)
	
	plot(printDataMorpheusList[[j]]$Time,printDataMorpheusList[[j]]$EightyProzentRadius, type = "p", main="Veränderung des 80-Prozent Radius über die Zeit", lty=3, xlab="80-Prozent Radius in Gitterpunkten", ylab="Zeit in MCS", lwd=1, cex=0.2)
	
	plot(printDataMorpheusList[[j]]$Time,printDataMorpheusList[[j]]$DurchschnittAnzahlZellen, type = "p", main="Veränderung der durchschnittlichen Anzahl an Zellen über die Zeit", lty=3, xlab="Durchschnittliche Anzahl an Zellen pro Verbund", ylab="Zeit in MCS", lwd=1, cex=0.2)
	
	plot(printDataMorpheusList[[j]]$Time, printDataMorpheusList[[j]]$xCenter, type = "p", main="Veränderung des Mittelpunktes über die Zeit", lty=3, xlab="X-Achse", ylab="Y-Achse", ylim=c(110,115), col="red", lwd=1, cex=0.5)
	lines(printDataMorpheusList[[j]]$Time,printDataMorpheusList[[j]]$yCenter, type = "p", lty=3, col="orange", lwd=1, cex=0.5)
	legend("topright", legend=c("x", "y"), col=c("red", "orange"), lty = c(3, 3))
	dev.off()

	#printData in Datei überführen
	str <- paste("../Skript-Daten/Morpheus/morpheusDataGoalRound", j, ".txt", sep="")
	write.table(printDataMorpheusList[[j]], file = str, sep="\t")
	rm(printDataMorpheus)
}

#Gemeinsamkeiten suchen
morpheusSimilarity <- data.frame("Time"=numeric(), "AbdeckungDurchschnitt"=numeric(), "AbdeckungMax"=numeric(),"AbdeckungMin"=numeric(), "AbdeckungUnterschied"=numeric())
for (j in seq(0,max(printDataMorpheusList[[j]]$Time),10)) {
	morpheusSimilarityData <- data.frame("Time"=numeric(), "Abdeckung"=numeric())
	for (i in seq(1, 10)) {
		temp <- subset(printDataMorpheusList[[i]], printDataMorpheusList[[i]]$Time==j)
		morpheusSimilarityData <- rbind.data.frame(morpheusSimilarityData, data.frame("Time" = temp$Time, "Abdeckung" = temp$Abdeckung))
	}
	morpheusSimilarity <- rbind.data.frame(morpheusSimilarity, data.frame("Time" = max(morpheusSimilarityData$Time), "AbdeckungDurchschnitt" = mean(morpheusSimilarityData$Abdeckung), "AbdeckungMax" = max(morpheusSimilarityData$Abdeckung), "AbdeckungMin" = min(morpheusSimilarityData$Abdeckung), "AbdeckungUnterschied"=max(morpheusSimilarityData$Abdeckung)-min(morpheusSimilarityData$Abdeckung)))
}

#Plot mean/max/min
str <- paste("../Plots/Morpheus/morpheus_cell_system_evaluation_similarities.pdf", sep="")
pdf(str)
plot(morpheusSimilarity$Time, morpheusSimilarity$AbdeckungDurchschnitt, type="p", lty=3, lwd=1, cex=0.1, main="Morpheus Abdeckungsrate im Durchschnitt mit Min-/Max-Werten", ylab="Abdeckung Durchschnitt mit Abweichungen in Gitterpunkten", xlab="Zeit in MCS")
arrows(morpheusSimilarity$Time, morpheusSimilarity$AbdeckungMin, morpheusSimilarity$Time, morpheusSimilarity$AbdeckungMax, length=0.05, angle=90, code=3)
dev.off()

#morpheusSimilarity in Datei überführen
str <- paste("../Skript-Daten/Morpheus/morpheusRoundsSimilarity.txt", sep="")
write.table(morpheusSimilarity, file = str, sep="\t")