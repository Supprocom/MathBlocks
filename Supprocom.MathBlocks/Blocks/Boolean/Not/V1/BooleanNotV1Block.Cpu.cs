namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class BooleanNotV1BlockCpu
    {
        internal static MathBlockOperation Create() => MathBlockOperationFactory.Create("boolean.not", 1, types => MathBlockTypeRules.Unary(types, MathBlockValueKind.Boolean), inputs => MathBlockValue.Boolean(!inputs[0].AsBoolean()), [MathBlockValue.Boolean(true)], MathBlockValue.Boolean(false), performanceIterations: 512);
    }
}
