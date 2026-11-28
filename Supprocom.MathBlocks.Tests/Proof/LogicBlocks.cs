using System.Globalization;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The logic blocks of the proof and their inputs. Scalar and Boolean blocks take one value per dispatch, so their cost is per dispatch; the vector blocks take one value per row. The
/// blocks <c>boolean-vector.any@1</c> and <c>boolean-vector.all@1</c> are whole-vector reducers: no window form of either exists, so they are not usable as a trailing-window
/// feature in a search; the proof of their parity and cost is for the whole-vector route only.
/// </summary>
internal static class LogicBlocks
{
    /// <summary>The scalar comparisons, which take two scalars and give a Boolean. The greater-or-equal, less-or-equal and not-equal blocks exist in the catalog.</summary>
    internal static readonly string[] ScalarComparisons =
    [
        "scalar.greater-than@1", "scalar.less-than@1", "scalar.equal@1", "scalar.not-equal@1", "scalar.greater-or-equal@1", "scalar.less-or-equal@1"
    ];

    /// <summary>The scalar select: a Boolean and two scalars.</summary>
    internal const string ScalarSelect = "scalar.select@1";

    /// <summary>The Boolean blocks with two operands.</summary>
    internal static readonly string[] BooleanBinary = ["boolean.and@1", "boolean.or@1", "boolean.xor@1"];

    /// <summary>The Boolean negation.</summary>
    internal const string BooleanNot = "boolean.not@1";

    /// <summary>The whole-vector reducers over a Boolean vector (no window form exists).</summary>
    internal static readonly string[] WholeVectorReducers = ["boolean-vector.any@1", "boolean-vector.all@1"];

    /// <summary>The vector comparisons: two vectors, a Boolean vector.</summary>
    internal static readonly string[] VectorComparisons = ["vector.equal@1", "vector.less-than@1", "vector.greater-than@1"];

    /// <summary>The vector select: a Boolean vector and two vectors.</summary>
    internal const string VectorSelect = "vector.select@1";

    /// <summary>The Boolean-vector blocks with two operands.</summary>
    internal static readonly string[] BooleanVectorBinary = ["boolean-vector.and@1", "boolean-vector.or@1", "boolean-vector.xor@1"];

    /// <summary>The Boolean-vector negation.</summary>
    internal const string BooleanVectorNot = "boolean-vector.not@1";

    /// <summary>Every logic block of the proof.</summary>
    internal static string[] All { get; } =
    [
        .. ScalarComparisons, ScalarSelect, .. BooleanBinary, BooleanNot, .. WholeVectorReducers, .. VectorComparisons, VectorSelect, .. BooleanVectorBinary, BooleanVectorNot
    ];

    // Zeros of both signs, subnormals, the smallest normal, ties, the largest magnitudes, NaN and both infinities.
    private static readonly float[] ScalarGrid =
    [
        0f, -0f, 1f, -1f, 0.5f, 2f, float.Epsilon, -float.Epsilon, 5.28e-41f, 1.1754943e-38f, float.MaxValue, -float.MaxValue,
        float.NaN, float.PositiveInfinity, float.NegativeInfinity
    ];

    // The finite values of the vector grid: a vector never holds a value that is not finite.
    private static readonly float[] VectorGrid =
    [
        0f, -0f, 1f, -1f, 0.5f, -0.5f, 2f, float.Epsilon, -float.Epsilon, 5.28e-41f, 1.1754943e-38f, -1.1754943e-38f, 1.03e-37f, 3.16e37f, -3.16e37f,
        float.MaxValue, -float.MaxValue, 1.0000001f, 0.99999994f
    ];

    /// <summary>The row counts of the vector parity cases: one row, short series, a warp and a half, and a long series.</summary>
    internal static readonly int[] VectorRows = [1, 7, 33, 1000];

    /// <summary>Gets whether the identity is a block with scalar and Boolean operands only.</summary>
    internal static bool IsScalarKind(string identity) =>
        identity.StartsWith("scalar.", StringComparison.Ordinal) || identity.StartsWith("boolean.", StringComparison.Ordinal);

    /// <summary>
    /// Builds the dispatches of the parity proof for a block: one input list per dispatch. A scalar block gets every combination of the scalar grid, NaN and both infinities included
    /// (such a scalar is an invalid value), and every Boolean operand as true, false and invalid. A vector block gets the finite grid pairs as rows, and the same operands with a row
    /// that is not finite (an invalid vector) in one operand or in both.
    /// </summary>
    internal static List<MathBlockValue[]> ParityCases(string identity)
    {
        var cases = new List<MathBlockValue[]>();
        if (IsScalarKind(identity))
        {
            AddScalarCases(identity, cases);
            return cases;
        }

        for (var index = 0; index < VectorRows.Length; index++)
            AddVectorCases(identity, VectorRows[index], cases);
        if (identity.StartsWith("boolean-vector.", StringComparison.Ordinal) && Arity(identity) == 1)
            cases.Add([MathBlockValue.BooleanVector(Array.Empty<bool>())]);
        return cases;
    }

    /// <summary>
    /// Gives each dispatch a valid prototype for planning: the first dispatch whose operands are all valid and have the same types (a vector type holds its length). A dispatch that is
    /// already valid is its own prototype.
    /// </summary>
    internal static MathBlockValue[][] Prototypes(IReadOnlyList<MathBlockValue[]> cases)
    {
        var prototypes = new MathBlockValue[cases.Count][];
        for (var index = 0; index < cases.Count; index++)
        {
            var found = cases[index].All(operand => operand.IsValid) ? cases[index] : null;
            for (var other = 0; found is null && other < cases.Count; other++)
            {
                if (cases[other].All(operand => operand.IsValid) && cases[other].Length == cases[index].Length
                    && Enumerable.Range(0, cases[index].Length).All(operand => cases[other][operand].Type == cases[index][operand].Type))
                {
                    found = cases[other];
                }
            }

            prototypes[index] = found ?? throw new InvalidOperationException("A dispatch has no valid prototype of its types.");
        }

        return prototypes;
    }

    /// <summary>Gets the number of operands of a block.</summary>
    internal static int Arity(string identity) => MathBlockCatalog.Standard.Get(identity[..^2]).Arity;

    /// <summary>Builds the operands of a scalar or Boolean dispatch from one class row: the first and second value of the class at the row, and a Boolean from their order.</summary>
    internal static MathBlockValue[] ScalarInputs(string identity, float first, float second, float third)
    {
        if (identity.StartsWith("boolean.", StringComparison.Ordinal))
        {
            var left = MathBlockValue.Boolean(first > second);
            return Arity(identity) == 1 ? [left] : [left, MathBlockValue.Boolean(second > third)];
        }

        if (string.Equals(identity, ScalarSelect, StringComparison.Ordinal))
            return [MathBlockValue.Boolean(first > second), MathBlockValue.Scalar(first), MathBlockValue.Scalar(second)];
        return [MathBlockValue.Scalar(first), MathBlockValue.Scalar(second)];
    }

    /// <summary>Builds the operands of a vector dispatch from the cleaned operand rows of a class.</summary>
    internal static MathBlockValue[] VectorInputs(string identity, float[] first, float[] second)
    {
        var flags = new bool[first.Length];
        for (var row = 0; row < flags.Length; row++)
            flags[row] = first[row] > second[row];
        var other = new bool[first.Length];
        for (var row = 0; row < other.Length; row++)
            other[row] = second[row] > 0f;
        if (identity.StartsWith("boolean-vector.", StringComparison.Ordinal))
            return Arity(identity) == 1 ? [MathBlockValue.BooleanVector(flags)] : [MathBlockValue.BooleanVector(flags), MathBlockValue.BooleanVector(other)];
        if (string.Equals(identity, VectorSelect, StringComparison.Ordinal))
            return [MathBlockValue.BooleanVector(flags), MathBlockValue.Vector(first, MathBlockUnit.Dimensionless), MathBlockValue.Vector(second, MathBlockUnit.Dimensionless)];
        return [MathBlockValue.Vector(first, MathBlockUnit.Dimensionless), MathBlockValue.Vector(second, MathBlockUnit.Dimensionless)];
    }

    /// <summary>Compares two results by kind, validity and bits; returns null when they agree, and the first difference otherwise.</summary>
    internal static string? Difference(MathBlockValue expected, MathBlockValue actual)
    {
        if (expected.Type.Kind != actual.Type.Kind || expected.IsValid != actual.IsValid)
            return $"expected {expected.Type.Kind} valid {expected.IsValid}, actual {actual.Type.Kind} valid {actual.IsValid}";
        if (!expected.IsValid)
            return null;
        return expected.Type.Kind switch
        {
            MathBlockValueKind.Boolean => expected.AsBoolean() == actual.AsBoolean() ? null : $"expected {expected.AsBoolean()}, actual {actual.AsBoolean()}",
            MathBlockValueKind.Scalar => BitConverter.SingleToInt32Bits(expected.AsScalar()) == BitConverter.SingleToInt32Bits(actual.AsScalar())
                ? null
                : string.Create(CultureInfo.InvariantCulture, $"expected {expected.AsScalar():R}, actual {actual.AsScalar():R}"),
            _ => VectorBlockReference.Difference(expected, actual)
        };
    }

    /// <summary>Describes the operands of a dispatch for a failure message.</summary>
    internal static string Describe(MathBlockValue[] inputs)
    {
        var parts = new string[inputs.Length];
        for (var index = 0; index < parts.Length; index++)
        {
            var value = inputs[index];
            parts[index] = !value.IsValid
                ? "invalid"
                : value.Type.Kind switch
                {
                    MathBlockValueKind.Scalar => value.AsScalar().ToString("R", CultureInfo.InvariantCulture),
                    MathBlockValueKind.Boolean => value.AsBoolean().ToString(),
                    _ => value.Type.Kind.ToString()
                };
        }

        return string.Join(", ", parts);
    }

    private static void AddScalarCases(string identity, List<MathBlockValue[]> cases)
    {
        var arity = Arity(identity);
        if (identity.StartsWith("boolean.", StringComparison.Ordinal))
        {
            var states = new[] { MathBlockValue.Boolean(false), MathBlockValue.Boolean(true), MathBlockValue.Invalid(MathBlockType.Boolean, "The Boolean operand is missing.") };
            for (var left = 0; left < states.Length; left++)
            {
                if (arity == 1)
                {
                    cases.Add([states[left]]);
                    continue;
                }

                for (var right = 0; right < states.Length; right++)
                    cases.Add([states[left], states[right]]);
            }

            return;
        }

        var select = string.Equals(identity, ScalarSelect, StringComparison.Ordinal);
        var conditions = new[] { MathBlockValue.Boolean(false), MathBlockValue.Boolean(true), MathBlockValue.Invalid(MathBlockType.Boolean, "The condition is missing.") };
        for (var condition = 0; condition < (select ? conditions.Length : 1); condition++)
        {
            for (var left = 0; left < ScalarGrid.Length; left++)
            {
                for (var right = 0; right < ScalarGrid.Length; right++)
                {
                    cases.Add(select
                        ? [conditions[condition], MathBlockValue.Scalar(ScalarGrid[left]), MathBlockValue.Scalar(ScalarGrid[right])]
                        : [MathBlockValue.Scalar(ScalarGrid[left]), MathBlockValue.Scalar(ScalarGrid[right])]);
                }
            }
        }
    }

    private static void AddVectorCases(string identity, int rows, List<MathBlockValue[]> cases)
    {
        var count = VectorGrid.Length;
        var first = new float[rows];
        var second = new float[rows];
        for (var row = 0; row < rows; row++)
        {
            first[row] = VectorGrid[row / count % count];
            second[row] = VectorGrid[row % count];
        }

        var valid = VectorInputs(identity, first, second);
        cases.Add(valid);
        var rowsType = MathBlockType.Vector(MathBlockUnit.Dimensionless, rows);
        var booleanType = MathBlockType.BooleanVector(rows);
        // One operand at a time is invalid: the vector that held NaN or an infinity in a row, or the Boolean vector that is missing. The result is invalid on both routes.
        for (var operand = 0; operand < valid.Length; operand++)
        {
            var inputs = (MathBlockValue[])valid.Clone();
            inputs[operand] = MathBlockValue.Invalid(valid[operand].Type.Kind == MathBlockValueKind.BooleanVector ? booleanType : rowsType, "An operand row is not finite.");
            cases.Add(inputs);
        }

        if (valid.Length > 1)
        {
            var all = (MathBlockValue[])valid.Clone();
            for (var operand = 0; operand < all.Length; operand++)
                all[operand] = MathBlockValue.Invalid(valid[operand].Type.Kind == MathBlockValueKind.BooleanVector ? booleanType : rowsType, "Every operand is invalid.");
            cases.Add(all);
        }
    }
}
