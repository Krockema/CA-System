using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CA
{
    public class Cell
    {
        public double Size { get; set; }
        public Node ParentNode { get; set; }

        public Cell(Node parentNode)
        {
            ParentNode = parentNode;
            Size = Globals.StartCellSize;
            ParentNode.Capacity -= Size;
            Statistics.CellCount++;
        }

        public Cell(Node parentNode, double size)
        {
            ParentNode = parentNode;
            Size = size;
            Statistics.CellCount++;
        }

        public Cell Divide()
        {
            Statistics.AttemptedDivisions++;
            if (!Globals.UseDivisionFunction && Size >= Globals.MinCellSize || Globals.UseDivisionFunction)
            {
                var r = Globals.Random.NextDouble();
                if (!Globals.UseDivisionFunction && r <= Globals.DivisionProbability || Globals.UseDivisionFunction && r <= DivisionFunction(Size))
                {
                    var oldSize = Size;
                    var newSize = Size * Globals.DivisionSizeReduction;
                    var sizeDiff = oldSize - newSize;
                    Size = newSize;
                    var child = new Cell(ParentNode, sizeDiff);
                    ParentNode.Cells.Add(child);
                    Statistics.CompletedDivisions++;
                    return child;
                }
            }

            return null;
        }

        public void Grow()
        {
            Statistics.AttemptedGrowths++;
            if (!Globals.SingleCellAnalysis && ParentNode.Capacity > 0 || Globals.SingleCellAnalysis)
            {
                var r = Globals.Random.NextDouble();
                if (r <= Globals.GrowthProbability)
                {
                    var gain = Size * Globals.GrowthPercentage;
                    if (!Globals.SingleCellAnalysis && ParentNode.Capacity >= gain || Globals.SingleCellAnalysis)
                    {
                        Size += gain;
                        ParentNode.Capacity -= gain;
                    }
                    else
                    {
                        Size += ParentNode.Capacity;
                        ParentNode.Capacity = 0;
                    }

                    Statistics.CompletedGrowths++;
                }
            }
        }

        public void Move()
        {
            Statistics.AttemptedMoves++;
            var r = Globals.Random.NextDouble();
            if (r <= Globals.MovementProbability)
            {
                var neighbours = ParentNode.GetNeighbours();
                var freeNeighbours = neighbours.Where(x => x.Capacity >= Size).ToList();
                if (freeNeighbours.Count > 0)
                {
                    int ra = Globals.Random.Next(freeNeighbours.Count); //TODO: Nur aus freien Nachbarn ziehen?
                    var randomNeighbour = freeNeighbours[ra];
                    ParentNode.Cells.Remove(this);
                    ParentNode.Capacity += this.Size;
                    randomNeighbour.Cells.Add(this);
                    ParentNode = randomNeighbour;
                    ParentNode.Capacity -= this.Size;
                    Statistics.CompletedMoves++;
                }
            }
        }

        private double DivisionFunction(double cellsize)
        {
            //return Math.Pow(cellsize, 4) / (Math.Pow(cellsize, 4) + Math.Pow(170, 4))/240;
            return Math.Pow(cellsize, 4) / (Math.Pow(cellsize, 4) + Math.Pow(170, 4)) / 240 * 2 ;
        }
    }
}
