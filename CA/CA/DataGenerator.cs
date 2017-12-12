using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CA
{
    public class DataGenerator
    {
        public int GridSize { get; set; }
        public Grid Grid { get; set; }
        public int MonteCarloSteps { get; set; }
        public List<Cell> CellList { get; set; }

        private enum CellActions
        {
            Movement,
            Division,
            Growth
        }

        public DataGenerator(int gridSize, int mcs)
        {
            GridSize = gridSize;
            MonteCarloSteps = mcs;
            CellList = new List<Cell>();
        }

        public void InitializeGrid()
        {
            Grid = new Grid(GridSize);
        }

        /// <summary>
        /// Creates a startSize x startSize colony in the center of the grid
        /// </summary>
        /// <param name="startSize"></param>
        public bool InitializeColonyInCenter(int startSize)
        {
            var startAndEnd = GetColonyStartAndEnd(startSize);
            var start = startAndEnd.Item1;
            var end = startAndEnd.Item2;

            if (start < 0 || end > GridSize)
            {
                return false;
            }

            for (int i = start; i < end; i++)
            {
                for (int j = start; j < end; j++)
                {
                    var node = Grid.Nodes[i, j];
                    var cell = new Cell(node);
                    node.Cells.Add(cell);
                    node.Capacity -= Globals.StartCellSize;
                    CellList.Add(cell);
                }
            }

            return true;
        }

        public bool InititalizeColonyInFieldOfView()
        {
            int count = 0;

            while (count < Globals.StartCellCount)
            {
                var node = GetRandomNodeInFieldOfView();
                if (node.Capacity > Globals.StartCellSize)
                {
                    var cell = new Cell(node);
                    node.Cells.Add(cell);
                    node.Capacity -= Globals.StartCellSize;
                    CellList.Add(cell);
                    count++;
                }
            }

            return true;
        }

        public void Simulate()
        {
            for (int i = 0; i < MonteCarloSteps; i++)
            {
                var cellCountAtBeginningOfStep = CellList.Count;

                for (int j = 0; j < cellCountAtBeginningOfStep * 3; j++)
                {
                    var cell = GetRandomCell();
                    var action = DetermineCellAction();
                    switch (action)
                    {
                        case CellActions.Movement:
                            cell.Move();

                            break;
                        case CellActions.Division:
                            var possibleNewCell = cell.Divide();
                            if (possibleNewCell != null)
                            {
                                CellList.Add(possibleNewCell);
                            }
                            break;
                        case CellActions.Growth:
                            cell.Grow();
                            break;
                        default:
                            break;
                    }
                }

                UpdateStatistics();
                SaveSimulationState(i);
            }
        }

        private void UpdateStatistics()
        {
            Statistics.Cellsizes = new List<double>();
            foreach (var node in Grid.FieldOfView)
            {
                foreach (var cell in node.Cells)
                {
                    Statistics.Cellsizes.Add(cell.Size);
                }
            }
        }

        public void SaveSimulationState(int i)
        {
            //SaveFieldOfViewState(i);
            SaveStatistics();
        }

        public void InitializeStatisticsFile()
        {
            var path = Globals.FilePathStatistics + "\\Statistics.csv";
            var config = Globals.MCSCount + "," + Globals.MovementProbability + "," + Globals.DivisionProbability + "," + Globals.GrowthProbability + "," + Globals.GrowthPercentage;
            config = string.Concat(config, Environment.NewLine);
            File.AppendAllText(path, config);
        }

        private void SaveStatistics()
        {
            var path = Globals.FilePathStatistics + "\\Statistics.csv";
            var enumerator = Statistics.Cellsizes
                            .Select((s, i) => (i + 1) % Statistics.Cellsizes.Count == 0 ? string.Concat(s, Environment.NewLine) : string.Concat(s, ","));

            
            var item = String.Join("", enumerator.ToArray<string>());
            File.AppendAllText(path, item);
        }

        public void ClearDirectory(string path)
        {
            DirectoryInfo di = new DirectoryInfo(path);
            FileInfo[] files = di.GetFiles("*.csv");

            foreach (var file in files)
            {
                file.Delete();
            }
        }

        public void SaveFieldOfViewState(int step)
        {
            string path = Globals.FilePathFieldOfViewState + "\\" + step + ".csv";

            var enumerator = GetCellCountMap().Cast<int>()
                            .Select((s, i) => (i + 1) % GridSize == 0 ? string.Concat(s, Environment.NewLine) : string.Concat(s, ","));

            var item = String.Join("", enumerator.ToArray<string>());
            File.AppendAllText(path, item);
        }

        public void PrintSimulationState()
        {
            for (int i = 0; i < GridSize; i++)
            {
                for (int j = 0; j < GridSize; j++)
                {
                    Console.Write(Grid.Nodes[i, j].Cells.Count + " ");
                }

                Console.WriteLine();
            }
        }

        private int[,] GetCellCountMap()
        {
            int[,] result = new int[GridSize, GridSize];
            for (int i = 0; i < GridSize; i++)
            {
                for (int j = 0; j < GridSize; j++)
                {
                    result[i, j] = Grid.Nodes[i, j].Cells.Count;
                }
            }

            return result;
        }

        private int[,] GetFieldOfViewCellCountMap()
        {
            int[,] result = new int[Grid.FieldofViewNodeCountWidth, Grid.FieldOfViewNodeCountHeight];
            for (int i = 0; i < Grid.FieldofViewNodeCountWidth; i++)
            {
                for (int j = 0; j < Grid.FieldOfViewNodeCountHeight; j++)
                {
                    result[i, j] = Grid.FieldOfView[i, j].Cells.Count;
                }
            }

            return result;
        }

        private Cell GetRandomCell()
        {
            int r = Globals.Random.Next(CellList.Count);
            return CellList[r];
        }

        private Node GetRandomNodeInFieldOfView()
        {
            int i = Globals.Random.Next(Grid.FieldofViewNodeCountWidth);
            int j = Globals.Random.Next(Grid.FieldOfViewNodeCountHeight);
            return Grid.FieldOfView[i, j];
        }

        private CellActions DetermineCellAction()
        {
            Array values = Enum.GetValues(typeof(CellActions));
            return (CellActions)values.GetValue(Globals.Random.Next(values.Length));
        }

        private Tuple<int, int> GetColonyStartAndEnd(int startSize)
        {
            int center = GridSize / 2;
            bool oddStartSize = false;

            if (startSize % 2 != 0)
                oddStartSize = true;

            int radius = oddStartSize ? (startSize + 1) / 2 : startSize / 2;
            int start = center - radius;
            int end = oddStartSize ? center + radius - 1 : center + radius;

            return new Tuple<int, int>(start, end);
        }

    }
}
