namespace Supprocom.MathBlocks;

// A window form's row algorithm when it doesn't evaluate the source on each window. Prepare does the work that
// depends only on the series inputs, so a batch over many widths does it once; Run fills the rows for one width.
// Run receives inputs the form has already checked: every input valid, equal series lengths, 1 <= width <= count.
internal abstract class MathBlockWindowKernel
{
    internal virtual object? Prepare(IReadOnlyList<MathBlockValue> inputs) => null;

    // Row t < width - 1 gets fill and false. Row t >= width - 1 gets its value and true when the row is computed,
    // otherwise fill and false. Either array may be null.
    internal abstract void Run(
        object? prepared,
        IReadOnlyList<MathBlockValue> inputs,
        int count,
        int width,
        double fill,
        double[]? values,
        bool[]? valid);
}
