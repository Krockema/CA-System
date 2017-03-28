#Daten einlesen
morpheusDataList <- list()
printMass <- data.frame("Time"=numeric(), "ICC"=numeric(), "Volume"=numeric())
for (k in seq(-25, 25, 5)) {
	print(k)
	for (i in seq(0.0, 2.0, 0.2)) {
		if (i == 0 || i == 1 || i == 2)
			str <- paste("/Users/McBob/Morpheus-Mass_Data/Inter-Cell-Communication ", k, "/Volume ", i, ".0 ICC ", k, "/logger.txt", sep="")
		else 
			str <- paste("/Users/McBob/Morpheus-Mass_Data/Inter-Cell-Communication ", k, "/Volume ", i, " ICC ", k,"/logger.txt", sep="")
		morpheusDataList[[i * 5 + 1]] <- read.table(str, sep="\t", header= TRUE)
	}
	#Loop
	printDataMorpheusList <- list()
	for (j in seq(1, 11)) {
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
		
		#printData in Datei überführen
		if (j == 1 || j == 6 || j == 11)
			str <- paste("/Users/McBob/Morpheus-Mass_Data/Inter-Cell-Communication ", k, "/Volume ", (j - 1) / 5, ".0 ICC ", k, "/rScriptData.txt", sep="")
		else
			str <- paste("/Users/McBob/Morpheus-Mass_Data/Inter-Cell-Communication ", k, "/Volume ", (j - 1) / 5, " ICC ", k ,"/rScriptData.txt", sep="")
		write.table(printDataMorpheusList[[j]], file = str, sep="\t")
		rm(printDataMorpheus)
	}

	#now get for each file the time when 80% Abdeckung is reached
	for (j in seq(1, 11)){
		temp <- subset(printDataMorpheusList[[j]], printDataMorpheusList[[j]]$Abdeckung>0.799)
		minTime <- min(temp$Time)
		printMass <- rbind.data.frame(printMass, data.frame("Time" = minTime, "ICC" = k, "Volume" = (j - 1) / 5))
	}
}
#write infos into file
str <- paste("../Skript-Daten/MorpheusMassData.txt")
write.table(printMass, file=str, sep="\t")