using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CA
{
    public static class Globals
    {
        /// <summary>
        /// Hier werden die generierten Daten abgespeichert
        /// </summary>
        public static string FilePathFieldOfViewState = "C:\\Users\\Maggo\\Documents\\HTW\\FuE-Projekt\\Data";
        public static string FilePathStatistics = "C:\\Users\\Maggo\\Documents\\HTW\\FuE-Projekt\\Statistics";
        public static string FilePathColonySize = "C:\\Users\\Maggo\\Documents\\HTW\\FuE-Projekt\\ColonySize";

        /// <summary>
        /// Eine einzelne Zelle wird im Vakuum beobachtet
        /// </summary>
        public static bool SingleCellAnalysis = false;
        /// <summary>
        /// Eine Zelle wird in der Kolonie beobachtet
        /// </summary>
        public static bool SingleCellWatchMode = false;
        public static bool UseDivisionFunction = true;
        public static Cell CelltoWatch = null;

        public static int MCSCount = 4800; //= 20 Tage

        public static double MovementProbability = 0.1; //Unbekannt
        public static double DivisionProbability = 0.013; //Unbekannt
        public static double GrowthProbability = 1.00; //Unbekannt

        public static double GrowthPercentage = 0.0038; //Unbekannt
        public static double MinCellSize = 170; //In Micrometer^2
        public static double NodeCapacity = 800; //In Micrometer^2
        public static double StartCellSize = 35; //In Micrometer^2
        public static int StartCellCount = 90;
        public static int GridSize = 400;
        
        //0.01;0.003

        public static int FieldOfViewWidth = 450;
        public static int FieldofViewHeight = 336;
        /// <summary>
        /// Anteil den eine Zelle kleiner wird nachdem sie sich teilt
        /// </summary>
        public static double DivisionSizeReduction = 0.5;

        /// <summary>
        /// Applikationsweiter Zufallszahlengenerator
        /// </summary>
        public static Random Random = new Random();
    }
}
