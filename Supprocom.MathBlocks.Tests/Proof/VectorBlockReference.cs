using System.Globalization;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>The CoreCLR side of the vector-block proof: every EvaluateCoreCLR overload PatternResearcher's route can reach, and the bit-for-bit comparison of two values.</summary>
internal static class VectorBlockReference
{
    /// <summary>The number of overloads <see cref="Overloads"/> evaluates.</summary>
    internal const int OverloadCount = 6;

    /// <summary>The name of each overload, in the order of <see cref="Overloads"/>.</summary>
    internal static readonly string[] OverloadNames =
    [
        "contract params", "contract list", "contract list+domain", "operation list", "operation list+domain", "contract span"
    ];

    /// <summary>
    /// Evaluates the operation through every overload of PatternResearcher's CoreCLR route: GenericMathBlocksExecution.Evaluate (the contract's list overload, and with the domain options when they
    /// are not the defaults, and the operation's list overload with and without the domain), GenericCandidateBlockEvaluator (the contract's span overload, with the validity span for an
    /// elementwise form), and the params overload of the same contract. A span result is rebuilt as a value so that all six compare the same way.
    /// </summary>
    internal static MathBlockValue[] Overloads(string identity, MathBlockValue[] inputs, int rows)
    {
        var contract = MathBlockCudaDeviceModule.GetOperation(identity);
        var operation = MathBlockCatalog.Standard.Get(identity[..^2]);
        IReadOnlyList<MathBlockValue> list = inputs;
        var domain = new MathBlockDomainOptions();
        return
        [
            contract.EvaluateCoreCLR(inputs),
            contract.EvaluateCoreCLR(list),
            contract.EvaluateCoreCLR(list, domain),
            operation.Evaluate(list),
            operation.Evaluate(list, domain),
            SpanResult(contract, identity, inputs, rows, domain)
        ];
    }

    /// <summary>Compares two values by kind, validity and the bits of every row; returns null when they agree, and the first difference otherwise.</summary>
    internal static string? Difference(MathBlockValue expected, MathBlockValue actual)
    {
        if (expected.Type.Kind != actual.Type.Kind || expected.IsValid != actual.IsValid)
            return $"expected {expected.Type.Kind} valid {expected.IsValid}, actual {actual.Type.Kind} valid {actual.IsValid}";
        if (!expected.IsValid)
            return null;
        if (expected.Type.Kind == MathBlockValueKind.BooleanVector)
        {
            var left = expected.AsBooleanVector().ToArray();
            var right = actual.AsBooleanVector().ToArray();
            return left.AsSpan().SequenceEqual(right) ? null : string.Create(CultureInfo.InvariantCulture, $"the row validity differs ({left.Length} and {right.Length} rows)");
        }

        var expectedRows = expected.AsVector().ToArray();
        var actualRows = actual.AsVector().ToArray();
        if (expectedRows.Length != actualRows.Length)
            return string.Create(CultureInfo.InvariantCulture, $"{expectedRows.Length} rows against {actualRows.Length}");
        for (var row = 0; row < expectedRows.Length; row++)
        {
            if (BitConverter.SingleToInt32Bits(expectedRows[row]) != BitConverter.SingleToInt32Bits(actualRows[row]))
                return string.Create(CultureInfo.InvariantCulture, $"row {row}: expected {expectedRows[row]:R}, actual {actualRows[row]:R}");
        }

        return null;
    }

    /// <summary>Describes the outcome of an evaluation that may throw: invalid, valid with its row count, or the exception type.</summary>
#pragma warning disable CA1031
    internal static string Outcome(Func<MathBlockValue> evaluate)
    {
        try
        {
            var value = evaluate();
            if (!value.IsValid)
                return "invalid";
            return value.Type.Kind == MathBlockValueKind.BooleanVector
                ? string.Create(CultureInfo.InvariantCulture, $"valid {value.AsBooleanVector().ToArray().Length} rows")
                : string.Create(CultureInfo.InvariantCulture, $"valid {value.AsVector().ToArray().Length} rows");
        }
        catch (Exception exception)
        {
            return string.Concat("throws ", exception.GetType().Name);
        }
    }
#pragma warning restore CA1031

    // The span overload writes rows into a caller-owned span; an elementwise form also fills the validity span, which is the validity sibling.
    private static MathBlockValue SpanResult(MathBlockCudaOperationContract contract, string identity, MathBlockValue[] inputs, int rows, MathBlockDomainOptions domain)
    {
        var output = new float[rows];
        if (identity.StartsWith("elementwise.", StringComparison.Ordinal))
        {
            var rowValid = new bool[rows];
            var formEvaluation = contract.EvaluateCoreCLR(inputs, output, rowValid, domain);
            return formEvaluation.IsValid ? MathBlockValue.Vector(output, MathBlockUnit.Dimensionless) : MathBlockValue.Invalid(MathBlockType.Vector(), "The span evaluation is invalid.");
        }

        var evaluation = contract.EvaluateCoreCLR(inputs, output, domain);
        if (!evaluation.IsValid)
            return MathBlockValue.Invalid(identity.Contains("valid", StringComparison.Ordinal) ? MathBlockType.BooleanVector() : MathBlockType.Vector(), "The span evaluation is invalid.");
        if (!identity.Contains("-valid.", StringComparison.Ordinal))
            return MathBlockValue.Vector(output, MathBlockUnit.Dimensionless);
        var flags = new bool[rows];
        for (var row = 0; row < rows; row++)
            flags[row] = output[row] != 0f;
        return MathBlockValue.BooleanVector(flags);
    }
}
