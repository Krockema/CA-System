using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using CA;
using Accord.Statistics.Testing;
using System.Collections.Generic;

namespace UnitTestCA
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestGlobalRandomgenerator()
        {
            int between0and49 = 0;
            int between50and100 = 0;

            for (int i = 0; i < 10000; i++)
            {
                var r = Globals.Random.NextDouble();
                if (r < 0.5)
                {
                    between0and49++;
                }
                else
                {
                    between50and100++;
                }
            }

            Console.WriteLine(between0and49);
            Console.WriteLine(between50and100);

            double[] expected = { 5000, 5000 };
            double[] observed = { between0and49, between50and100 };

            int degreesOfFreedom = 1;
            var chi = new ChiSquareTest(expected, observed, degreesOfFreedom);
            bool significant = chi.Significant; // false

            Assert.AreEqual(significant, false);
        }

        [TestMethod]
        public void TestMovementOnly()
        {
            double observedMovementProbabilitySum = 0;
            int simulationCount = 10;
            Globals.MovementProbability = 0.10;
            Globals.DivisionProbability = 0;
            Globals.GrowthProbability = 0;

            for (int i = 0; i < simulationCount; i++)
            {
                Statistics.ResetStatistics();
                var generator = new DataGenerator(150, 150);
                generator.InitializeGrid();
                generator.InitializeColonyInCenter(10);
                generator.Simulate();

                observedMovementProbabilitySum += (double)Statistics.CompletedMoves / Statistics.AttemptedMoves;
            }

            var averageOberservedMovementProbability = observedMovementProbabilitySum / simulationCount;
            var differenceOfMovementProbability = Math.Abs(averageOberservedMovementProbability - Globals.MovementProbability);
            Console.WriteLine("Tatsächliche Bewegungsrate: " + averageOberservedMovementProbability + " Unterschied zur Vorgabe: " + differenceOfMovementProbability);

            Assert.IsTrue(differenceOfMovementProbability < 0.01);
        }

        [TestMethod]
        public void TestDivisionOnly()
        {
            int simulationCount = 10000;
            Globals.MovementProbability = 0.0;
            Globals.DivisionProbability = 0.5;
            Globals.GrowthProbability = 0;
            int attemptedDivisions = 0;
            int completedDivisions = 0;

            for (int i = 0; i < simulationCount; i++)
            {
                Statistics.ResetStatistics();
                var generator = new DataGenerator(10, 1);
                generator.InitializeGrid();
                generator.InitializeColonyInCenter(2);
                generator.Simulate();
                attemptedDivisions += Statistics.AttemptedDivisions;
                completedDivisions += Statistics.CompletedDivisions;
            }

            var oberservedDivisionProbability = (double)completedDivisions/attemptedDivisions;
            var differenceOfDivisionProbability = Math.Abs(oberservedDivisionProbability - Globals.DivisionProbability);
            Console.WriteLine("Tatsächliche Teilungsrate: " + oberservedDivisionProbability + " Unterschied zur Vorgabe: " + differenceOfDivisionProbability);

            Assert.IsTrue(differenceOfDivisionProbability < 0.01);
        }

        [TestMethod]
        public void TestGrowthOnly()
        {
            int simulationCount = 100;
            Globals.MovementProbability = 0.0;
            Globals.DivisionProbability = 0.0;
            Globals.GrowthProbability = 1.0;
            Globals.StartCellSize = Globals.NodeCapacity / 10;
            int attemptedGrowths = 0;
            int completedGrowths = 0;

            for (int i = 0; i < simulationCount; i++)
            {
                Statistics.ResetStatistics();
                var generator = new DataGenerator(10, 1);
                generator.InitializeGrid();
                generator.InitializeColonyInCenter(2);
                generator.Simulate();
                attemptedGrowths += Statistics.AttemptedGrowths;
                completedGrowths += Statistics.CompletedGrowths;
            }

            var oberservedGrowthProbability = (double)completedGrowths / attemptedGrowths;
            var differenceOfGrowthProbability = Math.Abs(oberservedGrowthProbability - Globals.GrowthProbability);
            Console.WriteLine("Tatsächliche Wachstumsrate: " + oberservedGrowthProbability + " Unterschied zur Vorgabe: " + differenceOfGrowthProbability);

            Assert.IsTrue(differenceOfGrowthProbability < 0.01);
        }

        [TestMethod]
        public void TestMovementAndDivision()
        {
            int simulationCount = 1000;
            Globals.MovementProbability = 0.1;
            Globals.DivisionProbability = 0.5;
            Globals.GrowthProbability = 0;
            int attemptedDivisions = 0;
            int completedDivisions = 0;
            int attemptedMovements = 0;
            int completedMovements = 0;

            for (int i = 0; i < simulationCount; i++)
            {
                Statistics.ResetStatistics();
                var generator = new DataGenerator(10, 10);
                generator.InitializeGrid();
                generator.InitializeColonyInCenter(2);
                generator.Simulate();
                attemptedDivisions += Statistics.AttemptedDivisions;
                completedDivisions += Statistics.CompletedDivisions;
                attemptedMovements += Statistics.AttemptedMoves;
                completedMovements += Statistics.CompletedMoves;

                //generator.PrintSimulationState();
            }
            
            var oberservedDivisionProbability = (double)completedDivisions / attemptedDivisions;
            var differenceOfDivisionProbability = Math.Abs(oberservedDivisionProbability - Globals.DivisionProbability);
            Console.WriteLine("Tatsächliche Teilungsrate: " + oberservedDivisionProbability + " Unterschied zur Vorgabe: " + differenceOfDivisionProbability);

            var oberservedMovementProbability = (double)completedMovements / attemptedMovements;
            var differenceOfMovementProbability = Math.Abs(oberservedMovementProbability - Globals.MovementProbability);
            Console.WriteLine("Tatsächliche Bewegungsrate: " + oberservedMovementProbability + " Unterschied zur Vorgabe: " + differenceOfMovementProbability);


            Assert.IsTrue(differenceOfDivisionProbability < 0.01 && differenceOfMovementProbability <0.01);
        }

    }
}
