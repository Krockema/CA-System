using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CA
{
    public static class Globals
    {
        public static double MovementProbability = 0.10;
        public static double DivisionProbability = 0.50;
        public static double GrowthProbability = 1.00;

        public static double GrowthPercentage = 0.5;
        public static double MinCellSize = 1;
        public static double NodeCapacity = 15;

        public static Random Random = new Random();
    }
}
