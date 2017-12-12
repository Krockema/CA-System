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
        public Node[,] FieldOfView { get; set; }
        public int FieldofViewNodeCountWidth { get; private set; }
        public int FieldOfViewNodeCountHeight { get; private set; }

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

            InitialiseFieldOfView();
        }

        public void InitialiseFieldOfView()
        {
            FieldofViewNodeCountWidth = (int)(Globals.FieldOfViewWidth / Math.Sqrt(Globals.NodeCapacity));
            FieldOfViewNodeCountHeight = (int)(Globals.FieldofViewHeight / Math.Sqrt(Globals.NodeCapacity));
            int leftWidth = Globals.GridSize - FieldofViewNodeCountWidth;
            int leftHeight = Globals.GridSize - FieldOfViewNodeCountHeight;
            int k = 0;

            FieldOfView = new Node[FieldofViewNodeCountWidth, FieldOfViewNodeCountHeight];

            for (int i = leftWidth/2; i < FieldofViewNodeCountWidth+ leftWidth / 2; i++)
            {
                int l = 0;
                for (int j = leftHeight/2; j < FieldOfViewNodeCountHeight+ leftHeight / 2; j++)
                {
                    FieldOfView[k, l] = Nodes[i, j];
                    l++;
                }

                k++;
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
