namespace Supprocom.MathBlocks;

internal static class MathBlockDataValidation
{
    public static bool IsFinite(Complex value) =>
        Math.IsFinite(value.Real) && Math.IsFinite(value.Imaginary);
}
