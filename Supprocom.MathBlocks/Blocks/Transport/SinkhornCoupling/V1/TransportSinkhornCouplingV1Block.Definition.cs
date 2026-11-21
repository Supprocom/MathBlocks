namespace Supprocom.MathBlocks;

internal static partial class TransportMathBlocks
{
    internal static class TransportSinkhornCouplingV1Block
    {
        internal const string Identity = "transport.sinkhorn-coupling@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateSinkhorn();
        private static MathBlockOperation CreateSinkhorn()
        {
            var cost = MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0f, 1f, 1f, 0f]));
            return MathBlockOperationFactory.CreateDomain("transport.sinkhorn-coupling", 5, SinkhornType, (inputs, domain) =>
            {
                var regularization = inputs[3].AsScalar();
                var iterations = inputs[4].AsScalar();
                return IsDistribution(inputs[1].AsVector()) && IsDistribution(inputs[2].AsVector()) && regularization > 0f && iterations >= 1f && iterations <= domain.Options.MaximumIterationCount && iterations == Math.Truncate(iterations) ? MathBlockValue.Matrix(MathBlockTransport.SinkhornCoupling(inputs[0].AsMatrix(), inputs[1].AsVector(), inputs[2].AsVector(), regularization, (int)iterations)) : MathBlockValue.Invalid(MathBlockType.Matrix(rows: inputs[0].Type.Rows, columns: inputs[0].Type.Columns), "The inputs are outside the operation domain.");
            }, [cost, fair, fair, MathBlockValue.Scalar(1f), MathBlockValue.Scalar(20f)], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0.36552928931500245f, 0.13447071068499755f, 0.13447071068499755f, 0.36552928931500245f])), 1e-8f, 2);
        }
    }
}
