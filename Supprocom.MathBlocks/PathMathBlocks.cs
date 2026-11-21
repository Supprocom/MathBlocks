
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{

    /// <summary>Sums powered absolute increments along a sampled path.</summary>
    public static float PowerVariation(IReadOnlyList<float> values, float order)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = 0f;
        for (var index = 1; index < values.Count; index++)
            result += Math.Pow(Math.Abs(values[index] - values[index - 1]), order);
        return result;
    }
}

internal static partial class PathMathBlocks
{
    private static readonly MathBlockValue path = MathBlockValue.Vector([1f, 3f, 2f, 5f]);

    private static MathBlockOperation CreatePathScalar(
        string identifier,
        Func<IReadOnlyList<float>, float> function,
        MathBlockValue sample,
        float expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return inputs[0].AsVector().Count > 0
                ? MathBlockValue.Scalar(function(inputs[0].AsVector()), type.Unit)
                : MathBlockValue.Invalid(type, "The path is empty.");
        },
        [sample], MathBlockValue.Scalar(expected), 1e-9f, 16);

    private static MathBlockOperation CreatePathVector(
        string identifier,
        Func<IReadOnlyList<float>, float[]> function,
        MathBlockValue sample,
        float[] expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return inputs[0].AsVector().Count > 0
                ? MathBlockValue.Vector(function(inputs[0].AsVector()), type.Unit, true)
                : MathBlockValue.Invalid(type, "The path is empty.");
        },
        [sample], MathBlockValue.Vector(expected), 1e-9f, 16);

    private static MathBlockOperation CreateComplexProjection(
        string identifier,
        Func<Complex, float> function,
        float[] expected) => MathBlockOperationFactory.Create(
        identifier, 1,
        types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.ComplexVector);
            return MathBlockType.Vector(types[0].Unit, types[0].Rows);
        },
        inputs => MathBlockValue.Vector(
            MathBlockCollectionPrimitives.Map(inputs[0].AsComplexVector(), function),
            inputs[0].Type.Unit,
            true),
        [MathBlockValue.ComplexVector([new(1f, 2f), new(3f, 4f)])], MathBlockValue.Vector(expected),
        1e-9f, 16);

    private static MathBlockType SameUnitScalar(IReadOnlyList<MathBlockType> types) =>
        MathBlockTypeRules.VectorReduction(types);

    private static MathBlockType DimensionlessPathScalar(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        return MathBlockType.Scalar();
    }

    private static MathBlockType SameUnitVector(IReadOnlyList<MathBlockType> types) =>
        MathBlockTypeRules.Unary(types, MathBlockValueKind.Vector);

    private static MathBlockType QuadraticVariationType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(2)));
    }
}
