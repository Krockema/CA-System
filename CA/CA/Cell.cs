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
            Size = ParentNode.Capacity;
            Statistics.CellCount++;
        }

        public void Divide()
        {
            Statistics.AttemptedDivisions++;
            if (Size / 2 >= Globals.MinCellSize)
            {
                var r = Globals.Random.NextDouble();
                if (r <= Globals.DivisionProbability)
                {
                    Size = Size / 2;
                    var child = new Cell(ParentNode);
                    child.Size = Size;
                    ParentNode.Cells.Add(child);
                    Statistics.CompletedDivisions++;
                }
            }
        }

        public void Grow()
        {
            Statistics.AttemptedGrowths++;
            if (ParentNode.Capacity > 0)
            {
                var r = Globals.Random.NextDouble();
                if (r <= Globals.GrowthProbability)
                {
                    var gain = Size * Globals.GrowthPercentage;
                    if (ParentNode.Capacity >= gain)
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
                int ra = Globals.Random.Next(neighbours.Count); //TODO: Nur aus freien Nachbarn ziehen?
                var randomNeighbour = neighbours[ra];

                if (randomNeighbour.Capacity >= Size)
                {
                    ParentNode.Cells.Remove(this);
                    randomNeighbour.Cells.Add(this);
                    ParentNode = randomNeighbour;
                    Statistics.CompletedMoves++;
                }
            }
        }
    }
}
