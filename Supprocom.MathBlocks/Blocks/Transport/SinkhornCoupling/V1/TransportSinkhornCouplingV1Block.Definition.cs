namespace Supprocom.MathBlocks;
internal static partial class TransportMathBlocks
{
    internal static class TransportSinkhornCouplingV1Block
    {
        internal const string Identity = "transport.sinkhorn-coupling@1";
        internal static MathBlockOperation Create() => CreateSinkhorn();
        private static MathBlockOperation CreateSinkhorn()
        {
            var cost = MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0d, 1d, 1d, 0d]));
            return MathBlockOperationFactory.Create("transport.sinkhorn-coupling", 5, SinkhornType, inputs =>
            {
                var regularization = inputs[3].AsScalar();
                var iterations = inputs[4].AsScalar();
                return IsDistribution(inputs[1].AsVector()) && IsDistribution(inputs[2].AsVector()) && regularization > 0d && iterations >= 1d && iterations <= 10_000d && iterations == Math.Truncate(iterations) ? MathBlockValue.Matrix(MathBlockTransport.SinkhornCoupling(inputs[0].AsMatrix(), inputs[1].AsVector(), inputs[2].AsVector(), regularization, (int)iterations)) : MathBlockValue.Invalid(MathBlockType.Matrix(rows: inputs[0].Type.Rows, columns: inputs[0].Type.Columns), "The inputs are outside the operation domain.");
            }, [cost, fair, fair, MathBlockValue.Scalar(1d), MathBlockValue.Scalar(20d)], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0.36552928931500245d, 0.13447071068499755d, 0.13447071068499755d, 0.36552928931500245d])), 1e-8, 2);
        }
    }
}
