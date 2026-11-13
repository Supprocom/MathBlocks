namespace Supprocom.MathBlocks.Tests;

/// <summary>Generates the input types that the signature tests and the CUDA device test resolve: the contract cases of an operation, then a seeded grid of kinds, shapes and units.</summary>
internal static class MathBlockTypeSignatureGrid
{
    private static readonly MathBlockUnit[] Units = CreateUnits();
    private static readonly int[] Rows = [0, 0, 1, 2, 3, 5, int.MaxValue, int.MaxValue - 1, -1];
    private static readonly int[] Columns = [0, 0, 1, 2, 7];

    /// <summary>Gets the number of generated cases per operation, after the contract cases.</summary>
    internal const int GeneratedCases = 4_000;

    /// <summary>Gets the units of the grid: dimensionless, base dimensions, powers, fractions, and exponents that overflow int32 when squared, inverted or multiplied.</summary>
    internal static IReadOnlyList<MathBlockUnit> UnitPool => Units;

    /// <summary>Enumerates the input type lists of one operation.</summary>
    internal static IEnumerable<MathBlockType[]> Cases(MathBlockOperation operation)
    {
        var arity = operation.Arity;
        yield return CopyTypes(operation.PerformanceCase.Inputs);
        foreach (var regression in operation.RegressionCases)
            yield return CopyTypes(regression.Inputs);

        var baseline = CopyTypes(operation.PerformanceCase.Inputs);
        var random = new Random(StableSeed(operation.Identity));
        for (var index = 0; index < GeneratedCases; index++)
        {
            var types = new MathBlockType[arity];
            var shared = Units[random.Next(Units.Length)];
            var sameUnits = random.Next(2) == 0;
            for (var position = 0; position < arity; position++)
            {
                var kind = random.Next(10) < 7 ? baseline[position].Kind : (MathBlockValueKind)random.Next(1, 12);
                if (random.Next(40) == 0)
                    kind = (MathBlockValueKind)random.Next(0, 40);
                var unit = sameUnits && random.Next(5) != 0 ? shared : Units[random.Next(Units.Length)];
                if (random.Next(3) == 0)
                    unit = MathBlockUnit.Dimensionless;
                if (kind is MathBlockValueKind.Boolean or MathBlockValueKind.BooleanVector && random.Next(4) != 0)
                    unit = MathBlockUnit.Dimensionless;
                types[position] = new MathBlockType(kind, unit, Rows[random.Next(Rows.Length)], Columns[random.Next(Columns.Length)]);
            }
            yield return types;
        }
    }

    private static MathBlockType[] CopyTypes(IReadOnlyList<MathBlockValue> values)
    {
        var types = new MathBlockType[values.Count];
        for (var index = 0; index < types.Length; index++)
            types[index] = values[index].Type;
        return types;
    }

    // A stable hash, so the grid does not depend on string.GetHashCode.
    private static int StableSeed(string text)
    {
        var hash = 17;
        foreach (var character in text)
            hash = unchecked(hash * 31 + character);
        return hash;
    }

    private static MathBlockUnit[] CreateUnits()
    {
        static MathBlockUnit Basis(int dimension, int numerator = 1, int denominator = 1)
        {
            var exponent = new MathRational(numerator, denominator);
            var zero = MathRational.Zero;
            return dimension switch
            {
                0 => new MathBlockUnit(exponent, zero, zero, zero),
                1 => new MathBlockUnit(zero, exponent, zero, zero),
                2 => new MathBlockUnit(zero, zero, exponent, zero),
                _ => new MathBlockUnit(zero, zero, zero, exponent)
            };
        }

        return
        [
            MathBlockUnit.Dimensionless,
            Basis(0),
            Basis(1),
            Basis(0, 2),
            Basis(0, 1, 2),
            Basis(0).Multiply(Basis(1)),
            Basis(0, -1),
            Basis(2, 3),
            Basis(3, 1, 3),
            Basis(0).Multiply(Basis(1, -1)).Multiply(Basis(2, 2, 3)),
            new MathBlockUnit(new MathRational(1_073_741_824), MathRational.Zero, MathRational.Zero, MathRational.Zero),
            new MathBlockUnit(new MathRational(1, int.MaxValue), MathRational.Zero, MathRational.Zero, MathRational.Zero),
            new MathBlockUnit(new MathRational(-int.MaxValue), new MathRational(7), MathRational.Zero, MathRational.Zero),
            new MathBlockUnit(new MathRational(int.MinValue), MathRational.Zero, MathRational.Zero, MathRational.Zero)
        ];
    }
}
