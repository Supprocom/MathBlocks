namespace Supprocom.MathBlocks;

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
        int performanceIterations = 64,
        MathBlockCausalityInfo? causality = null) =>
        new(
            identifier,
            1,
            arity,
            typeResolver,
            evaluator,
            [new MathBlockRegressionCase("reference", sampleInputs, sampleOutput, tolerance)],
            new MathBlockPerformanceCase(sampleInputs, performanceIterations),
            causality ?? MathBlockCausalityIndex.Resolve($"{identifier}@1"));

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

    // An invalid result carries the type the operation declares for these inputs, so the declared-type check in
    // MathBlockOperation.Evaluate accepts it. A bare kind such as MathBlockType.Vector() has no length, and is
    // rejected whenever the declared type knows the length.
    public static MathBlockValue Invalid(
        MathBlockTypeResolver resolver,
        IReadOnlyList<MathBlockValue> inputs,
        string reason) =>
        MathBlockValue.Invalid(resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type)), reason);

    // A point-set graph whose edge weights overflowed is an invalid result of the declared type, not a graph that
    // fails validation. Input 0 is the point set: it gives the vertex count and the unit.
    public static MathBlockValue Graph(
        IReadOnlyList<MathBlockGraphEdge> edges,
        MathBlockTypeResolver resolver,
        IReadOnlyList<MathBlockValue> inputs)
    {
        for (var index = 0; index < edges.Count; index++)
            if (!Math.IsFinite(edges[index].Weight))
                return Invalid(resolver, inputs, "An edge weight is not finite.");
        return MathBlockValue.Graph(new MathBlockGraph(inputs[0].AsPointSet().Count, edges), inputs[0].Type.Unit);
    }
}
