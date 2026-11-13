namespace Supprocom.MathBlocks;

// Carries the domain options of one CoreCLR execution into the evaluators that read them, and counts the evaluations that
// ended at an iteration budget without converging. The shared default context applies the default options and counts nothing,
// so Evaluate(inputs) keeps its cost and its results.
internal sealed class MathBlockDomainContext
{
    internal static readonly MathBlockDomainContext Default = new(MathBlockDomainOptions.Default, counting: false);

    private readonly bool counting;
    private long nonConverged;

    internal MathBlockDomainContext(MathBlockDomainOptions options, bool counting = true)
    {
        Options = options;
        this.counting = counting;
    }

    internal MathBlockDomainOptions Options { get; }

    internal long NonConverged => Interlocked.Read(ref nonConverged);

    internal void RecordNonConvergence()
    {
        if (counting)
            Interlocked.Increment(ref nonConverged);
    }
}
