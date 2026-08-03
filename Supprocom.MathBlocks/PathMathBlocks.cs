
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{

    public static double PowerVariation(IReadOnlyList<double> values, double order)
    {
        var result = 0d;
        for (var index = 1; index < values.Count; index++)
            result += Math.Pow(Math.Abs(values[index] - values[index - 1]), order);
        return result;
    }
}

internal static partial class PathMathBlocks
{
    private static readonly MathBlockValue path = MathBlockValue.Vector([1d, 3d, 2d, 5d]);

    private static MathBlockOperation CreatePathScalar(
        string identifier,
        Func<IReadOnlyList<double>, double> function,
        MathBlockValue sample,
        double expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return inputs[0].AsVector().Count > 0
                ? MathBlockValue.Scalar(function(inputs[0].AsVector()), type.Unit)
                : MathBlockValue.Invalid(type, "The path is empty.");
        },
        [sample], MathBlockValue.Scalar(expected), 1e-9, 16);

    private static MathBlockOperation CreatePathVector(
        string identifier,
        Func<IReadOnlyList<double>, double[]> function,
        MathBlockValue sample,
        double[] expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return inputs[0].AsVector().Count > 0
                ? MathBlockValue.Vector(function(inputs[0].AsVector()), type.Unit, true)
                : MathBlockValue.Invalid(type, "The path is empty.");
        },
        [sample], MathBlockValue.Vector(expected), 1e-9, 16);

    private static MathBlockOperation CreateComplexProjection(
        string identifier,
        Func<Complex, double> function,
        double[] expected) => MathBlockOperationFactory.Create(
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
        [MathBlockValue.ComplexVector([new(1d, 2d), new(3d, 4d)])], MathBlockValue.Vector(expected),
        1e-9, 16);

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
