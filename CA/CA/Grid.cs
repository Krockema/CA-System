using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CA
{
    public class Grid
    {
        public Node[,] Nodes { get; set; }

        public Grid(int n)
        {
            Nodes = new Node[n, n];
            for (int i = 0; i < n; i++)
            {
                for (int j = 0; j < n; j++)
                {
                    var node = new Node(i, j);
                    node.OnRequestNeighbours += new Func<List<Node>>(delegate
                    {
                        return GetNeighbours(node);
                    });
                    Nodes[i, j] = node;
                }
            }
        }

        List<Node> GetNeighbours(Node node)
        {
            var nodes = new List<Node>();
            var x = node.Position.Item1;
            var y = node.Position.Item2;

            if (x < Nodes.GetUpperBound(0))
            {
                nodes.Add(Nodes[x + 1, y]);
                if (y < Nodes.GetUpperBound(1))
                    nodes.Add(Nodes[x + 1, y + 1]);
                if (y > 0)
                    nodes.Add(Nodes[x + 1, y - 1]);
            }

            if (x > 0)
            {
                nodes.Add(Nodes[x - 1, y]);
                if (y < Nodes.GetUpperBound(1))
                    nodes.Add(Nodes[x - 1, y + 1]);
                if (y > 0)
                    nodes.Add(Nodes[x - 1, y - 1]);
            }

            if (y < Nodes.GetUpperBound(1))
            {
                nodes.Add(Nodes[x, y + 1]);
            }

            if (y > 0)
            {
                nodes.Add(Nodes[x, y - 1]);
            }

            return nodes;
        }
    }
}
