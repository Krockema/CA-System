using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CA
{
    public static class Statistics
    {
        public static int AttemptedMoves;
        public static int CompletedMoves;
        public static int AttemptedDivisions;
        public static int CompletedDivisions;
        public static int AttemptedGrowths;
        public static int CompletedGrowths;
        public static int CellCount;

        public static void ResetStatistics()
        {
            AttemptedMoves = 0;
            CompletedMoves = 0;
            AttemptedDivisions = 0;
            CompletedDivisions = 0;
            AttemptedGrowths = 0;
            CompletedGrowths = 0;
            CellCount = 0;
        }
    }
}
