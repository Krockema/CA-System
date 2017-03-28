#Daten einlesen
csDataList <- list()
printMass <- data.frame("time"=numeric(), "divide"=numeric(), "flip"=numeric())
for (divide in seq(5, 15, 1)) {
	for (flip in seq(0, 10, 1)) {
		str <- paste("../GS-Daten/gs_heatmap/gs_divide_", divide,"_flip_", flip, ".txt", sep="")
		csDataList[[(divide - 5) * 11 + flip + 1]] <- read.table(str, sep=";", header= TRUE)
	}
}

#Datensätze untersuchen
printDataCSList <- list()
for (setnr in seq(1, 121, 1)) {
	#Ausgabetabelle erzeugen
	printDataCS <- data.frame("time"=numeric(), "cell.id"=numeric(), "size"=numeric(), "surface"=numeric(), "x"=numeric(), "y"=numeric())
	#Loop über die Zeit
	for (timeSet in seq(0,max(csDataList[[setnr]]$time),25000)) {
		#Subset erzeugen
		temp <- subset(csDataList[[setnr]], csDataList[[setnr]]$time==timeSet)

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
		printDataCS <- rbind.data.frame(printDataCS, data.frame("Time"=timeSet, "xCenter"=xCenter, "yCenter"=yCenter, "MaximalerRadius"=maxRadius, "DurchschnittRadius"=meanRadius, "EightyProzentRadius"=eightyRadius, "AnzahlZellenSystem" = numberOfCells, "Abdeckung" = numberOfCells/(50*50)))
	}
	printDataCSList[[setnr]] <- printDataCS
}

#Daten schreiben
for(i in seq(0, 120, 1)) {
	#printData in Datei überführen
	str <- paste("../GS-Daten/rScriptData/gs_divide_", i %/% 11 + 5,"_flip_", i %% 11, ".txt", sep="")
	i = i + 1
	write.table(printDataCSList[[i]], file = str, sep="\t")
}

#Ausgabetabelle erzeugen und berechnen
for (i in seq(1, 121, 1)){
	temp <- subset(printDataCSList[[i]], printDataCSList[[i]]$Abdeckung>0.799)
	i = i - 1
	minTime <- min(temp$Time)
	printMass <- rbind.data.frame(printMass, data.frame("time" = minTime / 2500, "divide" = i %/% 11 + 5, "flip" = i %% 11))
}

#write infos into file
str <- paste("../Skript-Daten/GSMassData.txt")
write.table(printMass, file=str, sep="\t")