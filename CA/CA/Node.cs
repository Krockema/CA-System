using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CA
{
    public class Node
    {
        public Tuple<int,int> Position { get; set; }
        public double Capacity { get; set; }
        public List<Cell> Cells { get; set; }

        public Node(int x, int y)
        {
            Position = new Tuple<int, int>(x, y);
            Capacity = Globals.NodeCapacity;
            Cells = new List<Cell>();
        }

        public List<Node> GetNeighbours()
        {
            return OnRequestNeighbours();
        }

        public Func<List<Node>> OnRequestNeighbours;
    }
}
