namespace Supprocom.MathBlocks;

public static class MathBlockCatalog
{
    private static readonly Lazy<MathBlockRegistry> standard = new(CreateStandard);

    public static MathBlockRegistry Standard => standard.Value;

    private static MathBlockRegistry CreateStandard()
        => new(MathBlockFeatureIndex.CreateOperations());
}

internal static class MathBlockOperationFactory
{
    public static MathBlockOperation Create(
        string identifier,
        int arity,
        MathBlockTypeResolver typeResolver,
        MathBlockEvaluator evaluator,
        IReadOnlyList<MathBlockValue> sampleInputs,
        MathBlockValue sampleOutput,
        double tolerance = 1e-10,
        int performanceIterations = 64) =>
        new(
            identifier,
            1,
            arity,
            typeResolver,
            evaluator,
            [new MathBlockRegressionCase("reference", sampleInputs, sampleOutput, tolerance)],
            new MathBlockPerformanceCase(sampleInputs, performanceIterations));

    public static MathBlockOperation ScalarUnary(
        string identifier,
        Func<double, double> function,
        double sample,
        double expected,
        MathBlockTypeResolver? resolver = null,
        double tolerance = 1e-10) =>
        Create(
            identifier,
            1,
            resolver ?? (types => MathBlockTypeRules.Unary(types, MathBlockValueKind.Scalar)),
            inputs =>
            {
                var outputType = (resolver ?? (types => MathBlockTypeRules.Unary(types, MathBlockValueKind.Scalar)))(
                    MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
                return MathBlockValue.Scalar(function(inputs[0].AsScalar()), outputType.Unit);
            },
            [MathBlockValue.Scalar(sample)],
            MathBlockValue.Scalar(expected),
            tolerance,
            512);

    public static MathBlockOperation ScalarBinary(
        string identifier,
        Func<double, double, double> function,
        double left,
        double right,
        double expected,
        MathBlockTypeResolver resolver,
        double tolerance = 1e-10) =>
        Create(
            identifier,
            2,
            resolver,
            inputs =>
            {
                var outputType = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
                return MathBlockValue.Scalar(function(inputs[0].AsScalar(), inputs[1].AsScalar()), outputType.Unit);
            },
            [MathBlockValue.Scalar(left), MathBlockValue.Scalar(right)],
            MathBlockValue.Scalar(expected),
            tolerance,
            512);

    public static MathBlockOperation ScalarComparison(
        string identifier,
        Func<double, double, bool> function,
        double left,
        double right,
        bool expected) =>
        Create(
            identifier,
            2,
            MathBlockTypeRules.Comparison,
            inputs => MathBlockValue.Boolean(function(inputs[0].AsScalar(), inputs[1].AsScalar())),
            [MathBlockValue.Scalar(left), MathBlockValue.Scalar(right)],
            MathBlockValue.Boolean(expected),
            performanceIterations: 512);
}
