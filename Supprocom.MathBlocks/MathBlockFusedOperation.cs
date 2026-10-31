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
    }

    public string Identity { get; }
    public MathBlockFusedOpcode Opcode { get; }
    public MathBlockFusedKind Result { get; }
    public MathBlockFusedKind[] Arguments { get; }
}
