namespace Supprocom.MathBlocks;

public static partial class MathBlockTransport
{
    public static double CouplingCost(MathBlockMatrix coupling, MathBlockMatrix cost)
    {
        var sum = 0d;
        for (var row = 0; row < coupling.Rows; row++)
            for (var column = 0; column < coupling.Columns; column++)
                sum += coupling[row, column] * cost[row, column];
        return sum;
    }
}
