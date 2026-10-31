namespace Supprocom.MathBlocks;

// The kernel of window.vector.minimum, maximum, arg-minimum and arg-maximum.
internal sealed class MathBlockWindowExtremeKernel(bool maximum, bool position) : MathBlockWindowKernel
{
    internal override void Run(
        object? prepared,
        IReadOnlyList<MathBlockValue> inputs,
        int count,
        int width,
        double fill,
        double[]? values,
        bool[]? valid) =>
        MathBlockWindowSelection.RunExtreme(
            inputs[0].AsVector().Span, count, width, fill, maximum, position, values, valid);
}
