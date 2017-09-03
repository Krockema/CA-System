using System;

namespace CA
{
    class Program
    {
        static void Main(string[] args)
        {
            var generator = new DataGenerator(6,4);
            generator.InitializeGrid();
            generator.InitializeColonyInCenter(3);
            generator.PrintSimulationState();
            //generator.SaveSimulationState();
            generator.Simulate();
            //generator.SaveSimulationState();
            Console.WriteLine();
            generator.PrintSimulationState();

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
