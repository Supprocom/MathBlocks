using System.Globalization;
using System.Text;

namespace Supprocom.MathBlocks.Cuda;

// Writes the CUDA source of a fused expression: a per-row __device__ function and a grid-stride kernel around it.
// Registers are named after program nodes: n<i> holds a number or scalar, b<i> a Boolean (0 or 1), c<i> a complex
// value, and r<i> the row validity of a node that a vector input reaches.
internal static class MathBlockFusedCudaSource
{
    public static string Create(MathBlockFusedExpression expression)
    {
        var program = expression.Program;
        var nodes = program.Nodes;
        var builder = new StringBuilder();
        AppendHeader(builder, expression);

        builder.Append("__device__ void ").Append(expression.CudaFunctionName).Append("(\n")
            .Append("    const void* const* inputs,\n")
            .Append("    const double* scalars,\n")
            .Append("    const int* const* validity,\n")
            .Append("    long long row,\n")
            .Append("    double* outputs,\n")
            .Append("    int* output_validity,\n")
            .Append("    unsigned long long* invalid_mask)\n")
            .Append("{\n")
            .Append("    unsigned long long invalid = 0ULL;\n");

        var scalarOrdinal = 0;
        foreach (var node in expression.ScalarNodes)
        {
            builder.Append("    const double n").Append(Number(node)).Append(" = ");
            if (nodes[node].Kind == MathBlockProgramBuilder.NodeKind.Input)
                builder.Append("scalars[").Append(Number(scalarOrdinal++)).Append("];\n");
            else
                builder.Append(FormatDouble(nodes[node].Value.AsScalar())).Append(";\n");
        }

        for (var ordinal = 0; ordinal < expression.VectorInputNodes.Length; ordinal++)
        {
            var node = expression.VectorInputNodes[ordinal];
            var index = Number(ordinal);
            if (expression.Kinds[node] == MathBlockFusedKind.Number)
                builder.Append("    const double n").Append(Number(node))
                    .Append(" = ((const double*)inputs[").Append(index).Append("])[row];\n");
            else
                builder.Append("    const int b").Append(Number(node))
                    .Append(" = ((const int*)inputs[").Append(index).Append("])[row] != 0;\n");
            builder.Append("    const int r").Append(Number(node))
                .Append(" = validity == 0 || validity[").Append(index).Append("] == 0 || validity[")
                .Append(index).Append("][row] != 0;\n");
        }

        foreach (var step in expression.Steps)
            AppendStep(builder, expression, step);

        for (var index = 0; index < expression.OutputNodes.Length; index++)
        {
            var node = expression.OutputNodes[index];
            builder.Append("    outputs[").Append(Number(index)).Append("] = ")
                .Append(expression.Kinds[node] == MathBlockFusedKind.Number
                    ? "n" + Number(node)
                    : "b" + Number(node) + " ? 1.0 : 0.0")
                .Append(";\n");
            builder.Append("    output_validity[").Append(Number(index)).Append("] = ")
                .Append(RowValidity(expression, node)).Append(";\n");
        }

        builder.Append("    if (invalid != 0ULL)\n")
            .Append("        atomicOr(invalid_mask, invalid);\n")
            .Append("}\n\n");

        AppendKernel(builder, expression);
        return builder.ToString();
    }

    private static void AppendHeader(StringBuilder builder, MathBlockFusedExpression expression)
    {
        var program = expression.Program;
        var nodes = program.Nodes;
        builder.Append("// MathBlocks fused expression ").Append(expression.Fingerprint).Append(".\n")
            .Append("// Program fingerprint ").Append(program.Fingerprint).Append(".\n")
            .Append("// MathBlocks CUDA source fingerprint ").Append(MathBlockCudaDeviceModule.SourceFingerprint)
            .Append(".\n")
            .Append("// Compile after the MathBlocks CUDA source (MathBlockCudaDeviceModule.Source).\n")
            .Append("// inputs[i]: const double* (Vector) or const int* of 0 and 1 (BooleanVector), one per vector\n")
            .Append("// input; pass a readable buffer for an invalid input. validity[i]: const int* of 0 and 1, or\n")
            .Append("// null when input i is valid in every row; validity itself may be null.\n");
        for (var ordinal = 0; ordinal < expression.VectorInputNodes.Length; ordinal++)
        {
            var node = expression.VectorInputNodes[ordinal];
            builder.Append("//   inputs[").Append(Number(ordinal)).Append("] '").Append(nodes[node].Name)
                .Append("' ").Append(nodes[node].Type.Kind.ToString()).Append('\n');
        }
        builder.Append("// scalars[i]: one per scalar input.\n");
        for (var ordinal = 0; ordinal < expression.ScalarInputNames.Count; ordinal++)
            builder.Append("//   scalars[").Append(Number(ordinal)).Append("] '")
                .Append(expression.ScalarInputNames[ordinal]).Append("'\n");
        builder.Append("// outputs[k] (1.0 or 0.0 for a BooleanVector output) and output_validity[k], per row:\n");
        for (var index = 0; index < expression.OutputNodes.Length; index++)
        {
            var node = expression.OutputNodes[index];
            builder.Append("//   outputs[").Append(Number(index)).Append("] '").Append(expression.OutputNames[index])
                .Append("' ").Append(nodes[node].Type.Kind.ToString()).Append('\n');
        }
        builder.Append("// invalid_mask: bit k is set when operation node k produces a nonfinite row:\n");
        for (var bit = 0; bit < expression.Steps.Length; bit++)
        {
            var step = expression.Steps[bit];
            builder.Append("//   bit ").Append(Number(bit)).Append(" node ").Append(Number(step.Node)).Append(' ')
                .Append(step.Operation.Identity).Append('\n');
        }
    }

    private static void AppendStep(StringBuilder builder, MathBlockFusedExpression expression, MathBlockFusedExpression.Step step)
    {
        var node = Number(step.Node);
        var arguments = new string[step.Arguments.Length];
        for (var index = 0; index < arguments.Length; index++)
            arguments[index] = Register(expression, step.Arguments[index]);
        var expressionText = MathBlockFusedOperations.CudaExpression(step.Operation.Opcode, arguments);
        var bit = "0x" + (1ul << expression.MaskBit(step.Node)).ToString("x", CultureInfo.InvariantCulture) + "ULL";
        builder.Append("    // node ").Append(node).Append(' ').Append(step.Operation.Identity).Append('\n');
        switch (step.Operation.Result)
        {
            case MathBlockFusedKind.Number:
                builder.Append("    const double n").Append(node).Append(" = ").Append(expressionText).Append(";\n")
                    .Append("    if (!isfinite(n").Append(node).Append(")) invalid |= ").Append(bit).Append(";\n");
                break;
            case MathBlockFusedKind.Flag:
                builder.Append("    const int b").Append(node).Append(" = ").Append(expressionText).Append(";\n");
                break;
            default:
                builder.Append("    const MathBlockComplexValue c").Append(node).Append(" = ").Append(expressionText)
                    .Append(";\n")
                    .Append("    if (!isfinite(c").Append(node).Append(".real) || !isfinite(c").Append(node)
                    .Append(".imaginary)) invalid |= ").Append(bit).Append(";\n");
                break;
        }
        if (expression.ContributingInputs(step.Node) != 0)
        {
            builder.Append("    const int r").Append(node).Append(" = ");
            var first = true;
            foreach (var argument in step.Arguments)
            {
                if (expression.ContributingInputs(argument) == 0)
                    continue;
                if (!first)
                    builder.Append(" & ");
                builder.Append('r').Append(Number(argument));
                first = false;
            }
            builder.Append(";\n");
        }
    }

    private static void AppendKernel(StringBuilder builder, MathBlockFusedExpression expression)
    {
        var outputCount = Number(expression.OutputNodes.Length);
        builder.Append("extern \"C\" __global__ void ").Append(expression.CudaKernelName).Append("(\n")
            .Append("    const void* const* inputs,\n")
            .Append("    const double* scalars,\n")
            .Append("    const int* const* validity,\n")
            .Append("    long long rows,\n")
            .Append("    void* const* outputs,\n")
            .Append("    int* const* output_validity,\n")
            .Append("    unsigned long long* invalid_mask)\n")
            .Append("{\n")
            .Append("    for (long long row = (long long)blockIdx.x * blockDim.x + threadIdx.x; row < rows;\n")
            .Append("         row += (long long)gridDim.x * blockDim.x)\n")
            .Append("    {\n")
            .Append("        double values[").Append(outputCount).Append("];\n")
            .Append("        int row_validity[").Append(outputCount).Append("];\n")
            .Append("        ").Append(expression.CudaFunctionName)
            .Append("(inputs, scalars, validity, row, values, row_validity, invalid_mask);\n");
        for (var index = 0; index < expression.OutputNodes.Length; index++)
        {
            var output = Number(index);
            builder.Append(expression.Kinds[expression.OutputNodes[index]] == MathBlockFusedKind.Number
                    ? "        ((double*)outputs[" + output + "])[row] = values[" + output + "];\n"
                    : "        ((int*)outputs[" + output + "])[row] = values[" + output + "] != 0.0;\n")
                .Append("        output_validity[").Append(output).Append("][row] = row_validity[")
                .Append(output).Append("];\n");
        }
        builder.Append("    }\n")
            .Append("}\n");
    }

    private static string Register(MathBlockFusedExpression expression, int node) =>
        expression.Kinds[node] switch
        {
            MathBlockFusedKind.Number or MathBlockFusedKind.Scalar => "n" + Number(node),
            MathBlockFusedKind.Flag => "b" + Number(node),
            _ => "c" + Number(node)
        };

    // A node reached by no vector input has no row validity register and is valid in every row.
    private static string RowValidity(MathBlockFusedExpression expression, int node) =>
        expression.ContributingInputs(node) != 0 ? "r" + Number(node) : "1";

    private static string FormatDouble(double value) =>
        "__longlong_as_double((long long)0x" +
        Math.ToBits(value).ToString("x16", CultureInfo.InvariantCulture) + "ULL)";

    private static string Number(int value) => value.ToString(CultureInfo.InvariantCulture);
}
