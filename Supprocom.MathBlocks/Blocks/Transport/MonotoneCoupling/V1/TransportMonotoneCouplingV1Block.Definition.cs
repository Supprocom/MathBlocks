namespace Supprocom.MathBlocks;
internal static partial class TransportMathBlocks
{
    internal static class TransportMonotoneCouplingV1Block
    {
        internal const string Identity = "transport.monotone-coupling@1";
        internal static MathBlockOperation Create() => CreateMonotoneCoupling();
        private static MathBlockOperation CreateMonotoneCoupling() => MathBlockOperationFactory.Create("transport.monotone-coupling", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            MathBlockTypeRules.RequireDimensionless(types[1]);
            return MathBlockType.Matrix(rows: types[0].Rows, columns: types[1].Rows);
        }, inputs => IsDistribution(inputs[0].AsVector()) && IsDistribution(inputs[1].AsVector()) ? MathBlockValue.Matrix(MathBlockTransport.MonotoneCoupling(inputs[0].AsVector(), inputs[1].AsVector())) : MathBlockValue.Invalid(MathBlockType.Matrix(), "An input is not a distribution."), [fair, fair], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0.5d, 0d, 0d, 0.5d])), performanceIterations: 8);
    }
}
