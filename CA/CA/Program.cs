using System;
using System.Globalization;
using System.Threading;

namespace CA
{
    class Program
    {
        static void Main(string[] args)
        {
            Thread.CurrentThread.CurrentCulture = CultureInfo.GetCultureInfo("en-US");
            var generator = new DataGenerator(Globals.GridSize,Globals.MCSCount);
            generator.ClearDirectory(Globals.FilePathFieldOfViewState);
            generator.ClearDirectory(Globals.FilePathStatistics);
            generator.InitializeStatisticsFile();
            generator.InitializeGrid();
            generator.InititalizeColonyInFieldOfView();
            //generator.InitializeColonyInCenter(20);
            //generator.PrintSimulationState();
            //generator.SaveSimulationState();
            generator.Simulate();
            Console.WriteLine();
            //generator.PrintSimulationState();

            Console.WriteLine("Versuchte Bewegungen: " + Statistics.AttemptedMoves);
            Console.WriteLine("Durchgeführte Bewegungen: " + Statistics.CompletedMoves);
            Console.WriteLine("Versuchte Teilungen: " + Statistics.AttemptedDivisions);
            Console.WriteLine("Durchgeführte Teilungen: " + Statistics.CompletedDivisions);
            Console.WriteLine("Versuchte Wachstume: " + Statistics.AttemptedGrowths);
            Console.WriteLine("Durchgeführte Wachstume: " + Statistics.CompletedGrowths);

            Console.Read();
        }
    }
}
