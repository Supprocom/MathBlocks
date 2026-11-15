namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>One of the six per-row device functions with a scalar operation behind it, and what the proof compares it with.</summary>
/// <param name="Name">The name in <c>mathblocks_row_&lt;name&gt;</c>.</param>
/// <param name="ScalarIdentifier">The CoreCLR scalar operation that the function mirrors.</param>
/// <param name="Source">The index of the operation in the elementwise source list; its dispatch opcode is twice the index, and one more for the validity sibling.</param>
/// <param name="Arity">The number of double arguments.</param>
/// <param name="Baseline">The inline device expression of the same arithmetic, over <c>a[row]</c> and <c>b[row]</c>.</param>
internal sealed record RowFunctionOp(string Name, string ScalarIdentifier, int Source, int Arity, string Baseline)
{
    /// <summary>The six functions: absolute 41, add 42, subtract 43, multiply 44, divide 45 and square root 48.</summary>
    internal static readonly RowFunctionOp[] All =
    [
        new("absolute", "scalar.absolute", 41, 1, "fabs(a[row])"),
        new("add", "scalar.add", 42, 2, "a[row] + b[row]"),
        new("subtract", "scalar.subtract", 43, 2, "a[row] - b[row]"),
        new("multiply", "scalar.multiply", 44, 2, "a[row] * b[row]"),
        new("divide", "scalar.divide", 45, 2, "a[row] / b[row]"),
        new("square_root", "scalar.square-root", 48, 1, "sqrt(a[row])")
    ];

    /// <summary>Gets the add function, whose rule the row sum applies at every step.</summary>
    internal static RowFunctionOp Add => All[1];
}
