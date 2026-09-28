namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Statistics contract.</summary>
public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.autocorrelation@1</c> mathematical operation.</summary>
    public static double Autocorrelation(IReadOnlyList<double> values, int lag)
    {
        ArgumentNullException.ThrowIfNull(values);
        var left = MathBlockVectorMath.Slice(values, 0, values.Count - lag);
        var right = MathBlockVectorMath.Slice(values, lag, values.Count - lag);
        return PearsonCorrelation(left, right);
    }
}
