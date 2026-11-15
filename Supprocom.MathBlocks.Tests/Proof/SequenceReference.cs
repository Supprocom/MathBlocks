namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>Times the main-era operation that each new sequence operation is compared with, on typical market values at the same size and width.</summary>
internal static class SequenceReference
{
    /// <summary>
    /// Returns the median time per row of the comparable main-era operation: lead and lag against vector.gather@1 with the shifted indices, sum-over-offsets and first-true-offset
    /// against sequence.rolling-sum@1 of the same width, maximum-over-offsets against sequence.rolling-maximum@1 and the prefix difference against vector.cumulative-sum@1.
    /// The results are cached by operation and parameter.
    /// </summary>
    internal static double Nanoseconds(string name, ProofParameter parameter, double[] typical, Dictionary<string, double> cache)
    {
        var key = string.Concat(name, "|", parameter.Label);
        if (cache.TryGetValue(key, out var known))
            return known;
        var series = MathBlockValue.Vector(typical);
        MathBlockOperation operation;
        MathBlockValue[] inputs;
        switch (name)
        {
            case "lead":
                operation = MathBlockCatalog.Standard.Get("vector.gather");
                inputs = [series, Indices(typical.Length, (int)parameter.First)];
                break;
            case SequenceOps.Lag:
                operation = MathBlockCatalog.Standard.Get("vector.gather");
                inputs = [series, Indices(typical.Length, -(int)parameter.First)];
                break;
            case "maximum-over-offsets":
                operation = MathBlockCatalog.Standard.Get("sequence.rolling-maximum");
                inputs = [series, MathBlockValue.Scalar(parameter.Width)];
                break;
            case "prefix-difference-over-offsets":
                operation = MathBlockCatalog.Standard.Get("vector.cumulative-sum");
                inputs = [series];
                break;
            default:
                operation = MathBlockCatalog.Standard.Get("sequence.rolling-sum");
                inputs = [series, MathBlockValue.Scalar(parameter.Width)];
                break;
        }

        var nanoseconds = ProofTiming.NanosecondsPerRow(
            () =>
            {
                _ = operation.Evaluate(inputs);
            },
            typical.Length);
        cache[key] = nanoseconds;
        return nanoseconds;
    }

    // The indices row + shift, held inside the series, as the gather of a shifted copy reads them.
    private static MathBlockValue Indices(int rows, int shift)
    {
        var indices = new double[rows];
        for (var row = 0; row < rows; row++)
            indices[row] = Math.Clamp(row + shift, 0, rows - 1);
        return MathBlockValue.Vector(indices);
    }
}
