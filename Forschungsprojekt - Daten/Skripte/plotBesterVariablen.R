#beste Variablen plotten
morpheusData <- read.table("../Skript-Daten/Morpheus/morpheusRoundsSimilarity.txt", sep="\t", header=TRUE)
caData <- read.table("../Skript-Daten/CA/caRoundsSimilarity.txt", sep="\t", header=TRUE)
gsData <- read.table("../Skript-Daten/GS/gsRoundsSimilarity.txt", sep="\t", header=TRUE)

pdf("../Plots/morpheusVariatiesCAGS.pdf")
plot(morpheusData$Time, morpheusData$AbdeckungDurchschnitt, type = "p", main="Anstieg Abdeckungsrate unterschiedlicher Zellsysteme und -parameter", lty=3, lwd=1, cex=0.5, ylab="Abdeckungsrate in Prozent", xlab="Zeit in MCS", col="green")
lines(caData$Time/2500, caData$AbdeckungDurchschnitt, type="p", lty=3, col="red", lwd=1, cex=0.5)   
lines(gsData$Time/2500, gsData$AbdeckungDurchschnitt, type="p", lty=3, col="black", lwd=1, cex=0.5) 
legend("bottomright", legend=c("Morpheus Durchschnitt", "CA Durchschnitt", "GS Durchschnitt"), col=c("green", "red", "black"), lty = c(3, 3, 3), title="Variationen")
dev.off()