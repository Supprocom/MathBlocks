namespace Supprocom.MathBlocks;

internal sealed class MathBlockFusedOperation
{
    public MathBlockFusedOperation(
        string identity,
        MathBlockFusedOpcode opcode,
        MathBlockFusedKind result,
        params MathBlockFusedKind[] arguments)
    {
        Identity = identity;
        Opcode = opcode;
        Result = result;
        Arguments = arguments;
        ElementwiseSource = -1;
    }

    // An elementwise form or sibling. Each source argument is a Number or a broadcast Scalar, at least one a Number,
    // and a form's last argument is its Scalar fill, so the argument kinds are checked per node.
    public MathBlockFusedOperation(string identity, int elementwiseSource, bool sibling)
    {
        Identity = identity;
        Opcode = sibling ? MathBlockFusedOpcode.ElementwiseValidity : MathBlockFusedOpcode.ElementwiseForm;
        Result = sibling ? MathBlockFusedKind.Flag : MathBlockFusedKind.Number;
        Arguments = [];
        ElementwiseSource = elementwiseSource;
    }

    public string Identity { get; }
    public MathBlockFusedOpcode Opcode { get; }
    public MathBlockFusedKind Result { get; }
    public MathBlockFusedKind[] Arguments { get; }

    // The index in the elementwise source list (the CUDA source of mathblocks_elementwise_source_opcode), or -1.
    public int ElementwiseSource { get; }

    public bool IsElementwise => ElementwiseSource >= 0;
}
