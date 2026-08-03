namespace Supprocom.MathBlocks;

public static partial class MathBlockTransport
{
    public static double AssignmentCost(MathBlockMatrix cost, IReadOnlyList<double> assignment)
    {
        var result = 0d;
        for (var row = 0; row < cost.Rows; row++)
            result += cost[row, (int)assignment[row]];
        return result;
    }
}
