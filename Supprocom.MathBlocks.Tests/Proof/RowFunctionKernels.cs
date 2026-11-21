using System.Globalization;
using System.Text;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The consumer-owned kernels of the L2 proof, assembled per row function from one template. The parity kernel runs the row function and the elementwise row function for the
/// same source in both opcode encodings. The timing kernel runs the row function and the baseline kernel runs the same arithmetic inline; both write the value and a validity
/// flag per row with a grid-stride loop, so they move the same bytes.
/// </summary>
internal static class RowFunctionKernels
{
    /// <summary>The number of values that each row of the row-sum kernels adds.</summary>
    internal const int SumCount = 8;

    /// <summary>Gets the source of every kernel, to be compiled after the device module.</summary>
    internal static string Source()
    {
        var text = new StringBuilder();
        for (var index = 0; index < RowFunctionOp.All.Length; index++)
        {
            var function = RowFunctionOp.All[index];
            var arguments = function.Arity == 1 ? "a[row], fill, &value" : "a[row], b[row], fill, &value";
            AppendParity(text, function.Name, arguments);
            AppendTiming(text, function.Name, arguments, function.Baseline);
        }

        AppendSum(text);
        return text.ToString();
    }

    // NVRTC ignores source line endings; the kernel text is not a fingerprinted fixture.
#pragma warning disable MA0136
    // The parity kernel passes the source index at run time; the row function is the one the kernel is named after.
    private static void AppendParity(StringBuilder text, string name, string arguments)
    {
        text.Append(CultureInfo.InvariantCulture, $$"""
            extern "C" __global__ void proof_parity_{{name}}(
                int rows, float fill, int source, const float* a, const float* b,
                float* row_values, int* row_valid, float* narrow_values, int* narrow_valid, float* wide_values, int* wide_valid)
            {
                for (int row = blockIdx.x * blockDim.x + threadIdx.x; row < rows; row += gridDim.x * blockDim.x)
                {
                    float value = 0.0;
                    float ignored = 0.0;
                    bool ok = mathblocks_row_{{name}}({{arguments}});
                    row_values[row] = value;
                    row_valid[row] = ok ? 1 : 0;
                    float narrow = 0.0;
                    (void)mathblocks_elementwise_row(2 * source, a[row], b[row], 0.0, fill, &narrow);
                    narrow_values[row] = narrow;
                    narrow_valid[row] = mathblocks_elementwise_row(2 * source + 1, a[row], b[row], 0.0, fill, &ignored) ? 1 : 0;
                    float wide = 0.0;
                    (void)mathblocks_elementwise_row(1024 + 2 * source, a[row], b[row], 0.0, fill, &wide);
                    wide_values[row] = wide;
                    wide_valid[row] = mathblocks_elementwise_row(1024 + 2 * source + 1, a[row], b[row], 0.0, fill, &ignored) ? 1 : 0;
                }
            }

            """);
    }

    // The row kernel calls the function; the baseline kernel computes the plain arithmetic and flags a finite result.
    private static void AppendTiming(StringBuilder text, string name, string arguments, string baseline)
    {
        text.Append(CultureInfo.InvariantCulture, $$"""
            extern "C" __global__ void proof_row_{{name}}(int rows, float fill, const float* a, const float* b, float* values, int* valid)
            {
                for (int row = blockIdx.x * blockDim.x + threadIdx.x; row < rows; row += gridDim.x * blockDim.x)
                {
                    float value = 0.0;
                    bool ok = mathblocks_row_{{name}}({{arguments}});
                    values[row] = value;
                    valid[row] = ok ? 1 : 0;
                }
            }

            extern "C" __global__ void proof_base_{{name}}(int rows, float fill, const float* a, const float* b, float* values, int* valid)
            {
                for (int row = blockIdx.x * blockDim.x + threadIdx.x; row < rows; row += gridDim.x * blockDim.x)
                {
                    float value = {{baseline}};
                    values[row] = value;
                    valid[row] = isfinite(value) ? 1 : 0;
                }
            }

            """);
    }

    // The row sum adds SumCount consecutive values per row; the parity run uses the count that its caller passes, and the timing run uses SumCount.
    private static void AppendSum(StringBuilder text)
    {
        text.Append(CultureInfo.InvariantCulture, $$"""
            extern "C" __global__ void proof_row_sum(int rows, int count, float fill, const float* v, float* values, int* valid)
            {
                for (int row = blockIdx.x * blockDim.x + threadIdx.x; row < rows; row += gridDim.x * blockDim.x)
                {
                    float value = 0.0;
                    bool ok = mathblocks_row_sum(v + (long long)row * count, count, fill, &value);
                    values[row] = value;
                    valid[row] = ok ? 1 : 0;
                }
            }

            extern "C" __global__ void proof_base_sum(int rows, int count, float fill, const float* v, float* values, int* valid)
            {
                for (int row = blockIdx.x * blockDim.x + threadIdx.x; row < rows; row += gridDim.x * blockDim.x)
                {
                    float sum = 0.0;
                    for (int index = 0; index < count; ++index)
                        sum += v[(long long)row * count + index];
                    values[row] = sum;
                    valid[row] = isfinite(sum) ? 1 : 0;
                }
            }

            """);
    }
#pragma warning restore MA0136
}
