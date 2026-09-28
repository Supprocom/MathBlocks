namespace Supprocom.MathBlocks;

public static partial class MathBlockTransport
{
    /// <summary>Computes the <c>transport.coupling-cost@1</c> mathematical operation.</summary>
    public static double CouplingCost(MathBlockMatrix coupling, MathBlockMatrix cost)
    {
        ArgumentNullException.ThrowIfNull(cost);
        ArgumentNullException.ThrowIfNull(coupling);
        var sum = 0d;
        for (var row = 0; row < coupling.Rows; row++)
            for (var column = 0; column < coupling.Columns; column++)
                sum += coupling[row, column] * cost[row, column];
        return sum;
    }
}
