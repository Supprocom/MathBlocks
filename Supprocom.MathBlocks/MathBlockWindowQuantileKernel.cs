namespace Supprocom.MathBlocks;

// The kernel of window.vector.median (probability 0.5, as vector.median) and window.vector.quantile (input 1).
internal sealed class MathBlockWindowQuantileKernel(bool median) : MathBlockWindowKernel
{
    internal override void Run(
        object? prepared,
        IReadOnlyList<MathBlockValue> inputs,
        int count,
        int width,
        double fill,
        double[]? values,
        bool[]? valid) =>
        MathBlockWindowSelection.RunQuantile(
            inputs[0].AsVector().Span, count, width, median ? 0.5d : inputs[1].AsScalar(), fill, values, valid);
}
