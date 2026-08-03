
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    public static double Magnitude(Complex value)
    {
        var real = Math.Abs(value.Real);
        var imaginary = Math.Abs(value.Imaginary);
        if (real < imaginary)
            (real, imaginary) = (imaginary, real);
        if (real == 0d)
            return 0d;
        var ratio = imaginary / real;
        return real * Math.Sqrt(1d + ratio * ratio);
    }
}

internal static partial class ComplexMathBlocks
{

    private static MathBlockOperation CreateUnary(
        string identifier,
        Func<Complex, Complex> function,
        Complex sample,
        Complex expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return MathBlockValue.Complex(function(inputs[0].AsComplex()), type.Unit);
        },
        [MathBlockValue.Complex(sample)], MathBlockValue.Complex(expected), 1e-9, 256);

    private static MathBlockOperation CreateBinary(
        string identifier,
        Func<Complex, Complex, Complex> function,
        Complex left,
        Complex right,
        Complex expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 2, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return MathBlockValue.Complex(function(inputs[0].AsComplex(), inputs[1].AsComplex()), type.Unit);
        },
        [MathBlockValue.Complex(left), MathBlockValue.Complex(right)], MathBlockValue.Complex(expected), 1e-9, 256);

    private static MathBlockType ResolveCreate(IReadOnlyList<MathBlockType> types)
    {
        var scalar = MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Scalar);
        return MathBlockType.Complex(scalar.Unit);
    }

    private static MathBlockType SameComplex(IReadOnlyList<MathBlockType> types) =>
        MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Complex);

    private static MathBlockType SameComplexUnary(IReadOnlyList<MathBlockType> types) =>
        MathBlockTypeRules.Unary(types, MathBlockValueKind.Complex);

    private static MathBlockType ComplexProduct(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Complex);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Complex);
        return MathBlockType.Complex(types[0].Unit.Multiply(types[1].Unit));
    }

    private static MathBlockType ComplexQuotient(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Complex);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Complex);
        return MathBlockType.Complex(types[0].Unit.Divide(types[1].Unit));
    }

    private static MathBlockType ComplexMagnitudeType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Complex);
        return MathBlockType.Scalar(types[0].Unit);
    }

    private static MathBlockType ComplexPhaseType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Complex);
        return MathBlockType.Scalar();
    }

    private static MathBlockType DimensionlessComplexUnary(IReadOnlyList<MathBlockType> types) =>
        MathBlockTypeRules.DimensionlessUnary(types, MathBlockValueKind.Complex);

    private static MathBlockType DimensionlessComplexBinary(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Complex);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Complex);
        MathBlockTypeRules.RequireDimensionless(types[0]);
        MathBlockTypeRules.RequireDimensionless(types[1]);
        return MathBlockType.Complex();
    }

    private static MathBlockType ComplexSquareRoot(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Complex);
        return MathBlockType.Complex(types[0].Unit.Pow(new MathRational(1, 2)));
    }

    private static MathBlockType ResolvePolar(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(types[1]);
        return MathBlockType.Complex(types[0].Unit);
    }
}
