namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Transport contract.</summary>
public static partial class MathBlockTransport
{
    /// <summary>Computes the <c>transport.assignment-cost@1</c> mathematical operation.</summary>
    public static double AssignmentCost(MathBlockMatrix cost, IReadOnlyList<double> assignment)
    {
        ArgumentNullException.ThrowIfNull(assignment);
        ArgumentNullException.ThrowIfNull(cost);
        var result = 0d;
        for (var row = 0; row < cost.Rows; row++)
            result += cost[row, (int)assignment[row]];
        return result;
    }
}
