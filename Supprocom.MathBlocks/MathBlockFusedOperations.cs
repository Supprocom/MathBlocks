namespace Supprocom.MathBlocks;

// The pointwise operations a fused expression evaluates per row. Each CoreCLR row function is the per-element
// function the operation's own evaluator maps over its vector, and each CUDA expression is the per-element code of
// the operation's case in its family dispatcher, with the same device functions and rounding intrinsics.
internal static class MathBlockFusedOperations
{
    private const MathBlockFusedKind Number = MathBlockFusedKind.Number;
    private const MathBlockFusedKind Scalar = MathBlockFusedKind.Scalar;
    private const MathBlockFusedKind Flag = MathBlockFusedKind.Flag;
    private const MathBlockFusedKind Complex = MathBlockFusedKind.Complex;

    private static readonly MathBlockFusedOperation[] operations =
    [
        new("vector.absolute@1", MathBlockFusedOpcode.VectorAbsolute, Number, Number),
        new("vector.add-scalar@1", MathBlockFusedOpcode.VectorAddScalar, Number, Number, Scalar),
        new("vector.add@1", MathBlockFusedOpcode.VectorAdd, Number, Number, Number),
        new("vector.subtract@1", MathBlockFusedOpcode.VectorSubtract, Number, Number, Number),
        new("vector.multiply@1", MathBlockFusedOpcode.VectorMultiply, Number, Number, Number),
        new("vector.divide@1", MathBlockFusedOpcode.VectorDivide, Number, Number, Number),
        new("vector.scale@1", MathBlockFusedOpcode.VectorScale, Number, Number, Scalar),
        new("vector.sign@1", MathBlockFusedOpcode.VectorSign, Number, Number),
        new("vector.positive-part@1", MathBlockFusedOpcode.VectorPositivePart, Number, Number),
        new("vector.square@1", MathBlockFusedOpcode.VectorSquare, Number, Number),
        new("vector.square-root@1", MathBlockFusedOpcode.VectorSquareRoot, Number, Number),
        new("vector.exponential@1", MathBlockFusedOpcode.VectorExponential, Number, Number),
        new("vector.natural-logarithm@1", MathBlockFusedOpcode.VectorNaturalLogarithm, Number, Number),
        new("vector.power@1", MathBlockFusedOpcode.VectorPower, Number, Number, Scalar),
        new("vector.equal@1", MathBlockFusedOpcode.VectorEqual, Flag, Number, Number),
        new("vector.less-than@1", MathBlockFusedOpcode.VectorLessThan, Flag, Number, Number),
        new("vector.greater-than@1", MathBlockFusedOpcode.VectorGreaterThan, Flag, Number, Number),
        new("vector.select@1", MathBlockFusedOpcode.VectorSelect, Number, Flag, Number, Number),
        new("boolean-vector.and@1", MathBlockFusedOpcode.BooleanVectorAnd, Flag, Flag, Flag),
        new("boolean-vector.or@1", MathBlockFusedOpcode.BooleanVectorOr, Flag, Flag, Flag),
        new("boolean-vector.xor@1", MathBlockFusedOpcode.BooleanVectorXor, Flag, Flag, Flag),
        new("boolean-vector.not@1", MathBlockFusedOpcode.BooleanVectorNot, Flag, Flag),
        new("complex-vector.create@1", MathBlockFusedOpcode.ComplexVectorCreate, Complex, Number, Number),
        new("complex-vector.real@1", MathBlockFusedOpcode.ComplexVectorReal, Number, Complex),
        new("complex-vector.imaginary@1", MathBlockFusedOpcode.ComplexVectorImaginary, Number, Complex),
        new("complex-vector.magnitude@1", MathBlockFusedOpcode.ComplexVectorMagnitude, Number, Complex)
    ];

    private static readonly Dictionary<string, MathBlockFusedOperation> byIdentity = CreateIndex();

    // Pointwise operations whose output row count differs from their input row count, so row t of the output is
    // not a function of row t of the inputs.
    private static readonly Dictionary<string, string> excluded = new(StringComparer.Ordinal)
    {
        ["vector.append@1"] = "its output has one more row than its input",
        ["polynomial.derivative@1"] = "its output has one row fewer than its input"
    };

    public static IReadOnlyList<MathBlockFusedOperation> All => operations;

    public static Dictionary<string, string> Excluded => excluded;

    public static bool TryResolve(string identity, out MathBlockFusedOperation operation) =>
        byIdentity.TryGetValue(identity, out operation!);

    public static double EvaluateNumber(MathBlockFusedOpcode opcode, double first, double second) => opcode switch
    {
        // Each case is the function the operation's CoreCLR evaluator applies to every element.
        MathBlockFusedOpcode.VectorAbsolute => Math.Abs(first),
        MathBlockFusedOpcode.VectorAddScalar => first + second,
        MathBlockFusedOpcode.VectorAdd => MathBlockScalar.Add(first, second),
        MathBlockFusedOpcode.VectorSubtract => MathBlockScalar.Subtract(first, second),
        MathBlockFusedOpcode.VectorMultiply => MathBlockScalar.Multiply(first, second),
        MathBlockFusedOpcode.VectorDivide => MathBlockScalar.Divide(first, second),
        MathBlockFusedOpcode.VectorScale => first * second,
        MathBlockFusedOpcode.VectorSign => Math.Sign(first),
        MathBlockFusedOpcode.VectorPositivePart => Math.Max(first, 0d),
        MathBlockFusedOpcode.VectorSquare => first * first,
        MathBlockFusedOpcode.VectorSquareRoot => Math.Sqrt(first),
        MathBlockFusedOpcode.VectorExponential => MathBlockScalar.Exponential(first),
        MathBlockFusedOpcode.VectorNaturalLogarithm => MathBlockScalar.NaturalLogarithm(first),
        MathBlockFusedOpcode.VectorPower => MathBlockScalar.Power(first, second),
        _ => throw new InvalidOperationException($"Fused opcode '{opcode}' does not produce a number.")
    };

    public static bool EvaluateFlag(MathBlockFusedOpcode opcode, double first, double second) => opcode switch
    {
        MathBlockFusedOpcode.VectorEqual => first == second,
        MathBlockFusedOpcode.VectorLessThan => first < second,
        MathBlockFusedOpcode.VectorGreaterThan => first > second,
        _ => throw new InvalidOperationException($"Fused opcode '{opcode}' does not compare numbers.")
    };

    public static bool EvaluateLogic(MathBlockFusedOpcode opcode, bool first, bool second) => opcode switch
    {
        MathBlockFusedOpcode.BooleanVectorAnd => first && second,
        MathBlockFusedOpcode.BooleanVectorOr => first || second,
        MathBlockFusedOpcode.BooleanVectorXor => first ^ second,
        MathBlockFusedOpcode.BooleanVectorNot => !first,
        _ => throw new InvalidOperationException($"Fused opcode '{opcode}' is not a Boolean operation.")
    };

    public static double EvaluateProjection(MathBlockFusedOpcode opcode, Complex value) => opcode switch
    {
        MathBlockFusedOpcode.ComplexVectorReal => value.Real,
        MathBlockFusedOpcode.ComplexVectorImaginary => value.Imaginary,
        MathBlockFusedOpcode.ComplexVectorMagnitude => MathBlockComplex.Magnitude(value),
        _ => throw new InvalidOperationException($"Fused opcode '{opcode}' is not a complex projection.")
    };

    // The CUDA expression for one row. Arguments are register names; the expressions mirror the per-element code
    // of the operation's dispatcher case (Vector cases 0-57, Complex cases 14-17).
    public static string CudaExpression(MathBlockFusedOpcode opcode, string[] arguments) => opcode switch
    {
        MathBlockFusedOpcode.VectorAbsolute => $"fabs({arguments[0]})",
        MathBlockFusedOpcode.VectorAddScalar => $"__dadd_rn({arguments[0]}, {arguments[1]})",
        MathBlockFusedOpcode.VectorAdd => $"__dadd_rn({arguments[0]}, {arguments[1]})",
        MathBlockFusedOpcode.VectorSubtract => $"__dsub_rn({arguments[0]}, {arguments[1]})",
        MathBlockFusedOpcode.VectorMultiply => $"__dmul_rn({arguments[0]}, {arguments[1]})",
        MathBlockFusedOpcode.VectorDivide => $"__ddiv_rn({arguments[0]}, {arguments[1]})",
        MathBlockFusedOpcode.VectorScale => $"__dmul_rn({arguments[0]}, {arguments[1]})",
        MathBlockFusedOpcode.VectorSign => $"{arguments[0]} > 0.0 ? 1.0 : {arguments[0]} < 0.0 ? -1.0 : 0.0",
        MathBlockFusedOpcode.VectorPositivePart => $"mathblocks_maximum({arguments[0]}, 0.0)",
        MathBlockFusedOpcode.VectorSquare => $"__dmul_rn({arguments[0]}, {arguments[0]})",
        MathBlockFusedOpcode.VectorSquareRoot => $"mathblocks_square_root({arguments[0]})",
        MathBlockFusedOpcode.VectorExponential => $"mathblocks_exponential({arguments[0]})",
        MathBlockFusedOpcode.VectorNaturalLogarithm => $"mathblocks_natural_logarithm({arguments[0]})",
        MathBlockFusedOpcode.VectorPower => $"mathblocks_power({arguments[0]}, {arguments[1]})",
        MathBlockFusedOpcode.VectorEqual => $"{arguments[0]} == {arguments[1]}",
        MathBlockFusedOpcode.VectorLessThan => $"{arguments[0]} < {arguments[1]}",
        MathBlockFusedOpcode.VectorGreaterThan => $"{arguments[0]} > {arguments[1]}",
        MathBlockFusedOpcode.VectorSelect => $"{arguments[0]} ? {arguments[1]} : {arguments[2]}",
        MathBlockFusedOpcode.BooleanVectorAnd => $"{arguments[0]} && {arguments[1]}",
        MathBlockFusedOpcode.BooleanVectorOr => $"{arguments[0]} || {arguments[1]}",
        MathBlockFusedOpcode.BooleanVectorXor => $"{arguments[0]} != {arguments[1]}",
        MathBlockFusedOpcode.BooleanVectorNot => $"!{arguments[0]}",
        MathBlockFusedOpcode.ComplexVectorCreate => $"mathblocks_complex_make({arguments[0]}, {arguments[1]})",
        MathBlockFusedOpcode.ComplexVectorReal => $"{arguments[0]}.real",
        MathBlockFusedOpcode.ComplexVectorImaginary => $"{arguments[0]}.imaginary",
        MathBlockFusedOpcode.ComplexVectorMagnitude => $"mathblocks_complex_magnitude({arguments[0]})",
        _ => throw new InvalidOperationException($"Fused opcode '{opcode}' has no CUDA expression.")
    };

    private static Dictionary<string, MathBlockFusedOperation> CreateIndex()
    {
        var index = new Dictionary<string, MathBlockFusedOperation>(operations.Length, StringComparer.Ordinal);
        foreach (var operation in operations)
            index.Add(operation.Identity, operation);
        return index;
    }
}
