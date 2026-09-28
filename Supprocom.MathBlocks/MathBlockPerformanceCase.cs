namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Performance Case contract.</summary>
public sealed class MathBlockPerformanceCase
{
    /// <summary>Defines one measured input case and latency target.</summary>
    public MathBlockPerformanceCase(
        IEnumerable<MathBlockValue> inputs,
        int iterations = 64,
        double maximumWarmLatencyMicroseconds = 1_000d)
    {
        ArgumentNullException.ThrowIfNull(inputs);
        Inputs = Array.AsReadOnly(MathBlockCollectionPrimitives.CopyEnumerable(inputs));
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(iterations);
        if (!Math.IsFinite(maximumWarmLatencyMicroseconds) ||
            maximumWarmLatencyMicroseconds <= 0d ||
            maximumWarmLatencyMicroseconds > 1_000d)
        {
            throw new ArgumentOutOfRangeException(nameof(maximumWarmLatencyMicroseconds));
        }
        Iterations = iterations;
        MaximumWarmLatencyMicroseconds = maximumWarmLatencyMicroseconds;
    }

    /// <summary>Gets the inputs value.</summary>
    public IReadOnlyList<MathBlockValue> Inputs { get; }
    /// <summary>Gets the iterations value.</summary>
    public int Iterations { get; }
    /// <summary>Gets the maximum warm latency microseconds value.</summary>
    public double MaximumWarmLatencyMicroseconds { get; }
}
