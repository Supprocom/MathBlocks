namespace Supprocom.MathBlocks;

internal static class MathBlockDataValidation
{
    public static bool IsFinite(Complex value) =>
        Math.IsFinite(value.Real) && Math.IsFinite(value.Imaginary);

    // True when every element is finite: the same test as All(values, Math.IsFinite), without the interface
    // indexer and the delegate per element.
    public static bool AllFinite(ReadOnlySpan<double> values)
    {
        for (var index = 0; index < values.Length; index++)
            if (!Math.IsFinite(values[index]))
                return false;
        return true;
    }
}
