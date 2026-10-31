namespace Supprocom.MathBlocks;

// Holds a kernel's prepared state across the widths of one batch call. The state is created by the first width that
// reaches the kernel and reused by the others, which see the same series inputs.
internal sealed class MathBlockWindowPreparation
{
    internal bool Ready { get; private set; }

    internal object? State { get; private set; }

    internal object? Get(MathBlockWindowKernel kernel, IReadOnlyList<MathBlockValue> inputs)
    {
        if (!Ready)
        {
            State = kernel.Prepare(inputs);
            Ready = true;
        }
        return State;
    }
}
