#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

[TranspileToCUDA]
internal static unsafe class ProbabilityModule
{
    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_explicit_subset_size() => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_incomplete_beta_maximum_iterations() => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_limit_incomplete_beta_tolerance() => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_incomplete_beta_policy() => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_nonconvergence_record_probability(int opcode) => throw new NotSupportedException();

    // The accessors of the binomial table, which the device prelude defines: the library's prelude reads and writes the module-global table,
    // the generator's default prelude has a load that returns 0 and a store that does nothing.
    [CudaExternal]
    private static float mathblocks_binomial_table_load(int index) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_binomial_table_store(int index, float value) => throw new NotSupportedException();

    [CudaExternal]
    public struct MathBlockSlot
    {
        public float scalar_value;
        public ulong data_pointer;
        public ulong scratch_pointer;
        public CudaInt32 boolean_value;
        public CudaInt32 valid;
        public int rows;
        public int columns;
        public int count;
        public int capacity;
    }

    [CudaExternal]
    public struct MathBlockComplexValue
    {
        public float real;
        public float imaginary;
    }

    [CudaExternal(IsPure = true)]
    private static float mathblocks_compensated_product_sum([CudaReadOnly] float* first, [CudaReadOnly] float* second, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_compensated_sum([CudaReadOnly] float* values, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static MathBlockComplexValue mathblocks_complex_add(MathBlockComplexValue left, MathBlockComplexValue right) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static MathBlockComplexValue mathblocks_complex_conjugate(MathBlockComplexValue value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static MathBlockComplexValue mathblocks_complex_divide(MathBlockComplexValue left, MathBlockComplexValue right) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static bool mathblocks_complex_finite(MathBlockComplexValue value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static MathBlockComplexValue mathblocks_complex_from_polar(float magnitude, float phase) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_complex_magnitude(MathBlockComplexValue value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static MathBlockComplexValue mathblocks_complex_make(float real, float imaginary) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static MathBlockComplexValue mathblocks_complex_multiply(MathBlockComplexValue left, MathBlockComplexValue right) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_complex_phase(MathBlockComplexValue value) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_complex_shape(MathBlockSlot* output, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static MathBlockComplexValue mathblocks_complex_square_root(MathBlockComplexValue value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static MathBlockComplexValue mathblocks_complex_subtract(MathBlockComplexValue left, MathBlockComplexValue right) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_cube_root(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_error_function(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_exponential(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_log_one_plus(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_maximum(float first, float second) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_natural_logarithm(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_power(float value, float exponent) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_set_vector_shape(MathBlockSlot* output, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_sine(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_square_root(float value) => throw new NotSupportedException();
    [CudaDevice]
    private static bool mathblocks_probability_integer(float value, int* result)
    {
        if (value < -2147483648.0f || value > 2147483647.0f || value != MathF.Truncate(value))
            return false;
        *result = (int)value;
        return true;
    }

    // The binomial coefficient n choose k as the running product of the loop below, with n in 64 bits so that a sum
    // of two int32 values does not wrap. After the symmetry step n is at least 2k, so from k = 600 on the coefficient
    // exceeds 1e359 and the loop ends at +Infinity; that value is returned without running it. A smaller k that overflows
    // part way stops at the first +Infinity as well.
    [CudaDevice]
    private static float mathblocks_probability_binomial(long n, int k)
    {
        if (k < 0 || k > n)
            return 0.0f;
        if (k > n - k)
            k = (int)(n - k);
        if (k >= 600)
            return BitConverter.Int32BitsToSingle(0x7f800000);
        float result = 1.0f;
        for (int index = 1; index <= k; index++)
        {
            result = result * (float)(n - k + index) / index;
            // Every factor and divisor from here on is at least 1, so +Infinity stays +Infinity.
            if (float.IsInfinity(result))
                break;
        }

        if (float.IsInfinity(result))
            return mathblocks_probability_binomial_ordered(n, k);
        return result;
    }

    // Recomputes C(n, k) for 0 <= k <= n - k when the product loop above overflowed: each step multiplies by the already divided factor
    // (n - k + index) / index, so the running value after step i is about C(n - k + i, i), never above the final value; the result is +infinity
    // only when C(n, k) itself exceeds the largest double.
    [CudaDevice]
    private static float mathblocks_probability_binomial_ordered(long n, int k)
    {
        float result = 1.0f;
        for (int index = 1; index <= k; index++)
            result = result * ((float)(n - k + index) / index);
        return result;
    }

    // The binomial coefficient through a table of the symmetric half of C(n, k), 0 <= k <= n <= 1023. The entry of (n, k) is at the offset of
    // row n, floor(n / 2) * floor((n - 1) / 2) + n (the entries of the rows below it, floor(m / 2) + 1 for row m), plus min(k, n - k). A
    // zero entry is unfilled, since a coefficient in this range is at least 1 or +infinity. The first evaluation of a pair stores the
    // helper's own result, so a later load returns the same bits; the stores are aligned 64-bit writes, so two threads that fill one entry
    // write the same bits, and a thread that reads a zero evaluates the helper itself. A pair outside the range goes straight to the helper.
    [CudaDevice]
    private static float mathblocks_probability_binomial_memo(long n, int k)
    {
        if (k < 0 || k > n || n > 1023)
            return mathblocks_probability_binomial(n, k);
        int row = (int)n;
        int half = k > row - k ? row - k : k;
        int index = (row / 2) * ((row - 1) / 2) + row + half;
        float entry = mathblocks_binomial_table_load(index);
        if (entry != 0.0f)
            return entry;
        entry = mathblocks_probability_binomial(n, k);
        mathblocks_binomial_table_store(index, entry);
        return entry;
    }

    [CudaDevice]
    private static bool mathblocks_probability_distribution([CudaReadOnly] float* values, int count)
    {
        if (count <= 0)
            return false;
        for (int index = 0; index < count; index++)
            if (values[index] < 0.0f) return false;
        return MathF.Abs(mathblocks_compensated_sum(values, count) - 1.0f) <= 1e-5f;
    }

    [CudaDevice]
    private static float mathblocks_probability_entropy([CudaReadOnly] float* values, int count)
    {
        float entropy = 0.0f;
        for (int index = 0; index < count; index++)
            if (values[index] > 0.0f)
                entropy -= values[index] * mathblocks_natural_logarithm(values[index]);
        return entropy;
    }

    [CudaDevice]
    private static float mathblocks_probability_kl(
        [CudaReadOnly] float* probabilities,
        [CudaReadOnly] float* reference,
        int count)
    {
        float result = 0.0f;
        for (int index = 0; index < count; index++)
            if (probabilities[index] > 0.0f)
                result += probabilities[index] *
                    mathblocks_natural_logarithm(probabilities[index] / reference[index]);
        return result;
    }

    [CudaDevice]
    private static float mathblocks_probability_log_gamma_core(float value)
    {
        ReadOnlySpan<float> coefficients = stackalloc float[8]
        {
            676.5203681218851f,
            -1259.1392167224028f,
            771.32342877765313f,
            -176.61502916214059f,
            12.507343278686905f,
            -0.13857109526572012f,
            9.9843695780195716e-6f,
            1.5056327351493116e-7f
        };
        value -= 1.0f;
        float sum = 0.99999999999980993f;
        for (int index = 0; index < 8; index++)
            sum += coefficients[index] / (value + index + 1.0f);
        // CoreCLR computes value + lanczosCoefficients.Length - 0.5: (value + 8) - 0.5, two roundings.
        float shifted = value + 8.0f;
        float t = shifted - 0.5f;
        return 0.5f * mathblocks_natural_logarithm(
                   2.0f * 3.141592653589793238462643383279502884f) +
               (value + 0.5f) * mathblocks_natural_logarithm(t) - t +
               mathblocks_natural_logarithm(sum);
    }

    [CudaDevice]
    private static float mathblocks_probability_log_gamma(float value)
    {
        // The poles: a whole number at or below zero has no value.
        if (value <= 0.0f && value == MathF.Floor(value))
            return BitConverter.Int32BitsToSingle(0x7fc00000);
        if (value < 0.5f)
        {
            return mathblocks_natural_logarithm(3.141592653589793238462643383279502884f) -
                mathblocks_natural_logarithm(
                    mathblocks_sine(3.141592653589793238462643383279502884f * value)) -
                mathblocks_probability_log_gamma_core(1.0f - value);
        }
        return mathblocks_probability_log_gamma_core(value);
    }

    [CudaDevice]
    private static float mathblocks_probability_beta_fraction(float x, float left, float right, bool* converged)
    {
        int maximum_iterations = mathblocks_limit_incomplete_beta_maximum_iterations();
        float tolerance = mathblocks_limit_incomplete_beta_tolerance();
        const float minimum = 1e-30f;
        *converged = false;
        float qab = left + right;
        float qap = left + 1.0f;
        float qam = left - 1.0f;
        float c = 1.0f;
        float d = 1.0f - qab * x / qap;
        if (MathF.Abs(d) < minimum) d = minimum;
        d = 1.0f / d;
        float result = d;
        for (int iteration = 1; iteration <= maximum_iterations; iteration++)
        {
            float doubled = 2.0f * iteration;
            float coefficient = iteration * (right - iteration) * x /
                ((qam + doubled) * (left + doubled));
            d = 1.0f + coefficient * d;
            if (MathF.Abs(d) < minimum) d = minimum;
            c = 1.0f + coefficient / c;
            if (MathF.Abs(c) < minimum) c = minimum;
            d = 1.0f / d;
            result *= d * c;
            coefficient = -(left + iteration) * (qab + iteration) * x /
                ((left + doubled) * (qap + doubled));
            d = 1.0f + coefficient * d;
            if (MathF.Abs(d) < minimum) d = minimum;
            c = 1.0f + coefficient / c;
            if (MathF.Abs(c) < minimum) c = minimum;
            d = 1.0f / d;
            float delta = d * c;
            result *= delta;
            if (MathF.Abs(delta - 1.0f) <= tolerance)
            {
                *converged = true;
                break;
            }
        }
        return result;
    }

    [CudaDevice]
    private static float mathblocks_probability_incomplete_beta(
        float x,
        float left,
        float right,
        bool* converged)
    {
        *converged = true;
        if (x == 0.0f) return 0.0f;
        if (x == 1.0f) return 1.0f;
        float front = mathblocks_exponential(
            mathblocks_probability_log_gamma(left + right) -
            mathblocks_probability_log_gamma(left) -
            mathblocks_probability_log_gamma(right) +
            left * mathblocks_natural_logarithm(x) +
            right * mathblocks_log_one_plus(-x));
        return x < (left + 1.0f) / (left + right + 2.0f)
            ? front * mathblocks_probability_beta_fraction(x, left, right, converged) / left
            : 1.0f - front * mathblocks_probability_beta_fraction(1.0f - x, right, left, converged) / right;
    }

    [CudaDevice]
    private static MathBlockComplexValue mathblocks_probability_complex_cube_root(
        MathBlockComplexValue value)
    {
        if (value.real == 0.0f && value.imaginary == 0.0f)
            return mathblocks_complex_make(0.0f, 0.0f);
        return mathblocks_complex_from_polar(
            mathblocks_cube_root(mathblocks_complex_magnitude(value)),
            mathblocks_complex_phase(value) / 3.0f);
    }

    // Renyi (renyi) or Tsallis entropy of a distribution. Returns false for a nonpositive order; the caller checks
    // that the value is finite.
    [CudaDevice]
    private static bool mathblocks_probability_ordered_entropy_value(
        [CudaReadOnly] float* values,
        int count,
        float order,
        bool renyi,
        float* value)
    {
        if (order <= 0.0f)
            return false;
        if (order == 1.0f)
        {
            *value = mathblocks_probability_entropy(values, count);
        }
        else
        {
            float sum = 0.0f;
            for (int index = 0; index < count; index++)
                sum += mathblocks_power(values[index], order);
            *value = renyi
                ? mathblocks_natural_logarithm(sum) / (1.0f - order)
                : (1.0f - sum) / (order - 1.0f);
        }
        return true;
    }

    // The scalar-valued opcodes on scalar arguments: ballot count (0), binomial coefficient (1), factorial (2),
    // normal CDF (23), Poisson CDF and PMF (25, 26), beta (28), log-gamma (29) and the regularized incomplete beta
    // (30). Writes the result to value and returns whether it is valid: in the source's domain and finite. The
    // probability dispatcher and the elementwise forms both evaluate their rows here.
    [CudaDevice]
    private static bool mathblocks_probability_scalar_value(int opcode, float a, float b, float c, float* value, bool* converged)
    {
        *value = 0.0f;
        *converged = true;
        if (opcode == 0 || opcode == 1 || opcode == 2)
        {
            int first_integer = 0;
            int second_integer = 0;
            if (!mathblocks_probability_integer(a, &first_integer) || first_integer < 0 ||
                (opcode != 2 && !mathblocks_probability_integer(b, &second_integer)) ||
                (opcode == 2 && first_integer > 170) ||
                (opcode == 0 && (first_integer <= second_integer || second_integer < 0)))
            {
                return false;
            }
            if (opcode == 0)
            {
                long total = (long)first_integer + second_integer;
                *value = (float)(first_integer - second_integer) /
                    (float)total *
                    mathblocks_probability_binomial_memo(total, second_integer);
            }
            else if (opcode == 1)
            {
                *value = mathblocks_probability_binomial_memo(first_integer, second_integer);
            }
            else
            {
                float factorial = 1.0f;
                for (int index = 2; index <= first_integer; index++) factorial *= index;
                *value = factorial;
            }
            return float.IsFinite(*value);
        }

        if (opcode == 23)
        {
            *value = 0.5f * (1.0f + mathblocks_error_function(a / mathblocks_square_root(2.0f)));
            return float.IsFinite(*value);
        }

        if (opcode == 25 || opcode == 26)
        {
            int count = 0;
            float rate = a;
            if (!mathblocks_probability_integer(b, &count) || count < 0 || rate < 0.0f)
                return false;
            float sum = 0.0f;
            if (opcode == 25 && rate == 0.0f)
            {
                // Index 0 contributes 1.0 and every later term is +0.0, so the sum is exactly 1.0.
                sum = 1.0f;
            }
            else if (opcode == 25)
            {
                // The sum of terms 0..count in index order. A term whose exponent is below -104 is exactly +0.0
                // (the exponential returns 0.0 below -103.98), and adding +0.0 leaves the sum unchanged, so those
                // terms are skipped: the exponent rises with the index up to the rate and falls after it.
                float log_rate = mathblocks_natural_logarithm(rate);
                int peak = rate < count ? (int)rate : count;
                int first = 0;
                bool reached = -rate + peak * log_rate - mathblocks_probability_log_gamma(peak + 1.0f) >= -104.0f;
                if (reached)
                {
                    int high = peak;
                    while (first < high)
                    {
                        int middle = first + (high - first) / 2;
                        if (-rate + middle * log_rate - mathblocks_probability_log_gamma(middle + 1.0f) >= -104.0f)
                            high = middle;
                        else
                            first = middle + 1;
                    }
                    for (int index = first; index <= count; index++)
                    {
                        float exponent = -rate + index * log_rate - mathblocks_probability_log_gamma(index + 1.0f);
                        if (index > rate && exponent < -104.0f)
                            break;
                        // Past the peak the terms only fall, so once one leaves the sum unchanged every later one does too.
                        float next_sum = sum + mathblocks_exponential(exponent);
                        if (index > rate && next_sum == sum)
                            break;
                        sum = next_sum;
                    }
                }
            }
            else
            {
                for (int index = count; index <= count; index++)
                {
                    float probability = rate == 0.0f
                        ? (index == 0 ? 1.0f : 0.0f)
                        : mathblocks_exponential(
                            -rate + index * mathblocks_natural_logarithm(rate) -
                            mathblocks_probability_log_gamma(index + 1.0f));
                    sum += probability;
                }
            }
            *value = sum;
            return float.IsFinite(sum);
        }

        if (opcode == 28)
        {
            *value = mathblocks_exponential(
                mathblocks_probability_log_gamma(a) +
                mathblocks_probability_log_gamma(b) -
                mathblocks_probability_log_gamma(a + b));
        }
        else if (opcode == 29)
        {
            *value = mathblocks_probability_log_gamma(a);
        }
        else if (opcode == 30)
        {
            if (a < 0.0f || a > 1.0f || b <= 0.0f || c <= 0.0f)
                return false;
            *value = mathblocks_probability_incomplete_beta(a, b, c, converged);
            // The Invalid policy makes a non-converged row invalid; the caller counts the row from converged.
            if (!*converged && mathblocks_limit_incomplete_beta_policy() == 1)
                return false;
        }
        else
        {
            return false;
        }
        return float.IsFinite(*value);
    }

    [CudaDevice(Name = "mathblocks_probability_dispatch")]
    private static void mathblocks_probability(
        int opcode,
        MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        int thread = (int)Cuda.ThreadIdx.X;
        MathBlockSlot* first = Cuda.ReadOnly(input_count > 0 ? inputs[0] : null);
        MathBlockSlot* second = Cuda.ReadOnly(input_count > 1 ? inputs[1] : null);
        MathBlockSlot* third = Cuda.ReadOnly(input_count > 2 ? inputs[2] : null);
        MathBlockSlot* fourth = Cuda.ReadOnly(input_count > 3 ? inputs[3] : null);
        if (thread == 0)
        {
            output->scalar_value = 0.0f;
            output->boolean_value = 0;
            output->rows = 0;
            output->columns = 0;
            output->count = 0;
            output->valid = 1;
            for (int index = 0; index < input_count; index++)
                if (inputs[index] == null || !inputs[index]->valid) output->valid = 0;
        }
        Cuda.SyncThreads();
        if (!output->valid)
            return;

        float* a = Cuda.ReadOnly(first == null ? null : (float*)first->data_pointer);
        float* b = Cuda.ReadOnly(second == null ? null : (float*)second->data_pointer);
        float* result = (float*)output->data_pointer;
        float* scratch = (float*)output->scratch_pointer;

        if (opcode == 3)
        {
            // The domain test reads only the input, so every thread takes the same exit before the barrier below.
            if (first->count > mathblocks_limit_explicit_subset_size())
            {
                if (thread == 0)
                    output->valid = 0;
                return;
            }
            if (thread == 0)
                mathblocks_set_vector_shape(output, (1 << first->count) - 1);
            Cuda.SyncThreads();
            for (int mask = thread + 1; output->valid && mask <= output->count; mask += Cuda.BlockDim.X)
            {
                float sum = 0.0f;
                for (int index = 0; index < first->count; index++)
                    if ((mask & (1 << index)) != 0) sum += a[index];
                result[mask - 1] = sum;
                if (!float.IsFinite(sum)) Cuda.AtomicExchange(ref output->valid, 0);
            }
            return;
        }

        if (opcode == 19)
        {
            int count = first->count <= 1 ? 1 : first->count - 1;
            if (thread == 0) mathblocks_set_vector_shape(output, count);
            Cuda.SyncThreads();
            if (first->count <= 1)
            {
                if (thread == 0) result[0] = 0.0f;
            }
            else
            {
                for (int index = thread + 1; index < first->count; index += Cuda.BlockDim.X)
                {
                    result[index - 1] = index * a[index];
                    if (!float.IsFinite(result[index - 1])) Cuda.AtomicExchange(ref output->valid, 0);
                }
            }
            return;
        }

        if (opcode == 24 || opcode == 27)
        {
            if (thread == 0)
            {
                if (first->count <= 0)
                {
                    output->valid = 0;
                    return;
                }
                for (int index = 0; index < first->count; index++)
                    if (a[index] < 0.0f) output->valid = 0;
                mathblocks_set_vector_shape(output, first->count);
                if (opcode == 24)
                {
                    float total = mathblocks_compensated_sum(a, first->count);
                    for (int index = 0; output->valid && index < first->count; index++)
                        result[index] = a[index] * (1.0f / total);
                }
                else
                {
                    float maximum = a[0];
                    for (int index = 1; index < first->count; index++)
                        maximum = mathblocks_maximum(maximum, a[index]);
                    for (int index = 0; index < first->count; index++)
                        result[index] = mathblocks_exponential(a[index] - maximum);
                    float total = mathblocks_compensated_sum(result, first->count);
                    float scale = 1.0f / total;
                    for (int index = 0; index < first->count; index++)
                        result[index] *= scale;
                }
                for (int index = 0; index < first->count; index++)
                    if (!float.IsFinite(result[index])) output->valid = 0;
            }
            return;
        }

        if (thread != 0)
            return;

        if (opcode == 0 || opcode == 1 || opcode == 2 || opcode == 23 || opcode == 25 || opcode == 26 ||
            opcode == 28 || opcode == 29 || opcode == 30)
        {
            float value = 0.0f;
            bool converged = true;
            bool valid = mathblocks_probability_scalar_value(
                opcode,
                first == null ? 0.0f : first->scalar_value,
                second == null ? 0.0f : second->scalar_value,
                third == null ? 0.0f : third->scalar_value,
                &value,
                &converged);
            if (!converged) mathblocks_nonconvergence_record_probability(opcode);
            output->scalar_value = value;
            if (!valid) output->valid = 0;
            return;
        }

        if (opcode >= 4 && opcode <= 16)
        {
            bool first_distribution = opcode == 12
                ? mathblocks_probability_distribution(a, first->count)
                : mathblocks_probability_distribution(a, first->count);
            bool pair = opcode == 4 || opcode == 7 || opcode == 9 || opcode == 10 ||
                opcode == 11 || opcode == 15;
            if (!first_distribution || (pair &&
                (first->count != second->count || !mathblocks_probability_distribution(b, second->count))))
            {
                output->valid = 0;
                return;
            }
            float value = 0.0f;
            if (opcode == 4)
            {
                for (int index = 0; index < first->count; index++)
                    value += mathblocks_square_root(a[index] * b[index]);
            }
            else if (opcode == 5)
            {
                value = mathblocks_probability_entropy(a, first->count) /
                    mathblocks_natural_logarithm(2.0f);
            }
            else if (opcode == 6)
            {
                int first_count = 0;
                int second_count = 0;
                int condition_count = 0;
                if (!mathblocks_probability_integer(second->scalar_value, &first_count) || first_count <= 0 ||
                    !mathblocks_probability_integer(third->scalar_value, &second_count) || second_count <= 0 ||
                    !mathblocks_probability_integer(fourth->scalar_value, &condition_count) || condition_count <= 0 ||
                    (long)first_count * second_count * condition_count != first->count || scratch == null)
                {
                    output->valid = 0;
                    return;
                }
                int first_condition_count = first_count * condition_count;
                int second_condition_count = second_count * condition_count;
                float* first_condition = scratch;
                float* second_condition = first_condition + first_condition_count;
                float* condition = second_condition + second_condition_count;
                for (int index = 0; index < first_condition_count + second_condition_count + condition_count; index++)
                    scratch[index] = 0.0f;
                for (int first_index = 0; first_index < first_count; first_index++)
                    for (int second_index = 0; second_index < second_count; second_index++)
                        for (int state = 0; state < condition_count; state++)
                        {
                            float probability = a[(first_index * second_count + second_index) *
                                condition_count + state];
                            first_condition[first_index * condition_count + state] += probability;
                            second_condition[second_index * condition_count + state] += probability;
                            condition[state] += probability;
                        }
                for (int first_index = 0; first_index < first_count; first_index++)
                    for (int second_index = 0; second_index < second_count; second_index++)
                        for (int state = 0; state < condition_count; state++)
                        {
                            float probability = a[(first_index * second_count + second_index) *
                                condition_count + state];
                            if (probability == 0.0f) continue;
                            value += probability * mathblocks_natural_logarithm(
                                probability * condition[state] /
                                (first_condition[first_index * condition_count + state] *
                                 second_condition[second_index * condition_count + state]));
                        }
            }
            else if (opcode == 7)
            {
                for (int index = 0; index < first->count; index++)
                {
                    if (a[index] > 0.0f && b[index] == 0.0f)
                    {
                        output->valid = 0;
                        return;
                    }
                    if (a[index] > 0.0f)
                        value -= a[index] * mathblocks_natural_logarithm(b[index]);
                }
            }
            else if (opcode == 8)
            {
                value = 1.0f - mathblocks_compensated_product_sum(a, a, first->count);
            }
            else if (opcode == 9)
            {
                for (int index = 0; index < first->count; index++)
                {
                    float difference = mathblocks_square_root(a[index]) - mathblocks_square_root(b[index]);
                    value += difference * difference;
                }
                value = mathblocks_square_root(value / 2.0f);
            }
            else if (opcode == 10)
            {
                if (scratch == null)
                {
                    output->valid = 0;
                    return;
                }
                for (int index = 0; index < first->count; index++)
                    scratch[index] = (a[index] + b[index]) / 2.0f;
                value = 0.5f * (mathblocks_probability_kl(a, scratch, first->count) +
                               mathblocks_probability_kl(b, scratch, first->count));
            }
            else if (opcode == 11)
            {
                for (int index = 0; index < first->count; index++)
                    if (a[index] > 0.0f && b[index] == 0.0f)
                    {
                        output->valid = 0;
                        return;
                    }
                value = mathblocks_probability_kl(a, b, first->count);
            }
            else if (opcode == 12)
            {
                int rows = first->rows;
                int columns = first->columns;
                if (scratch == null)
                {
                    output->valid = 0;
                    return;
                }
                float* row_totals = scratch;
                float* column_totals = scratch + rows;
                for (int index = 0; index < rows + columns; index++) scratch[index] = 0.0f;
                for (int row = 0; row < rows; row++)
                    for (int column = 0; column < columns; column++)
                    {
                        float probability = a[row * columns + column];
                        row_totals[row] += probability;
                        column_totals[column] += probability;
                    }
                for (int row = 0; row < rows; row++)
                    for (int column = 0; column < columns; column++)
                    {
                        float probability = a[row * columns + column];
                        if (probability > 0.0f)
                            value += probability * mathblocks_natural_logarithm(
                                probability / (row_totals[row] * column_totals[column]));
                    }
            }
            else if (opcode == 13 || opcode == 16)
            {
                if (!mathblocks_probability_ordered_entropy_value(
                        a,
                        first->count,
                        second->scalar_value,
                        opcode == 13,
                        &value))
                {
                    output->valid = 0;
                    return;
                }
            }
            else if (opcode == 14)
            {
                value = mathblocks_probability_entropy(a, first->count);
            }
            else if (opcode == 15)
            {
                for (int index = 0; index < first->count; index++)
                    value += MathF.Abs(a[index] - b[index]);
                value /= 2.0f;
            }
            output->scalar_value = value;
            if (!float.IsFinite(value)) output->valid = 0;
            return;
        }

        if (opcode == 17)
        {
            float parameter = second->scalar_value;
            if (first->count <= 0 || parameter < 0.0f || parameter > 1.0f)
            {
                output->valid = 0;
                return;
            }
            int degree = first->count - 1;
            float value = 0.0f;
            for (int index = 0; index <= degree; index++)
                value += a[index] * mathblocks_probability_binomial(degree, index) *
                    mathblocks_power(parameter, (float)index) *
                    mathblocks_power(1.0f - parameter, (float)(degree - index));
            output->scalar_value = value;
            if (!float.IsFinite(value)) output->valid = 0;
            return;
        }

        if (opcode == 18)
        {
            if (first->count != 4)
            {
                output->valid = 0;
                return;
            }
            MathBlockComplexValue* roots = (MathBlockComplexValue*)output->data_pointer;
            mathblocks_complex_shape(output, 3);
            float constant = a[0];
            float linear = a[1];
            float quadratic = a[2];
            float leading = a[3];
            if (leading == 0.0f)
            {
                output->valid = 0;
                return;
            }
            float normalized_a = quadratic / leading;
            float normalized_b = linear / leading;
            float normalized_c = constant / leading;
            float p = normalized_b - normalized_a * normalized_a / 3.0f;
            float q = 2.0f * normalized_a * normalized_a * normalized_a / 27.0f -
                normalized_a * normalized_b / 3.0f + normalized_c;
            MathBlockComplexValue square_root = mathblocks_complex_square_root(
                mathblocks_complex_make(q * q / 4.0f + p * p * p / 27.0f, 0.0f));
            MathBlockComplexValue u = mathblocks_probability_complex_cube_root(
                mathblocks_complex_add(mathblocks_complex_make(-q / 2.0f, 0.0f), square_root));
            MathBlockComplexValue v = u.real == 0.0f && u.imaginary == 0.0f
                ? mathblocks_probability_complex_cube_root(
                    mathblocks_complex_subtract(mathblocks_complex_make(-q / 2.0f, 0.0f), square_root))
                : mathblocks_complex_divide(
                    mathblocks_complex_make(-p, 0.0f),
                    mathblocks_complex_multiply(mathblocks_complex_make(3.0f, 0.0f), u));
            MathBlockComplexValue omega = mathblocks_complex_make(
                -0.5f,
                mathblocks_square_root(3.0f) / 2.0f);
            roots[0] = mathblocks_complex_subtract(
                mathblocks_complex_add(u, v),
                mathblocks_complex_make(normalized_a / 3.0f, 0.0f));
            roots[1] = mathblocks_complex_subtract(
                mathblocks_complex_add(
                    mathblocks_complex_multiply(omega, u),
                    mathblocks_complex_multiply(mathblocks_complex_conjugate(omega), v)),
                mathblocks_complex_make(normalized_a / 3.0f, 0.0f));
            roots[2] = mathblocks_complex_subtract(
                mathblocks_complex_add(
                    mathblocks_complex_multiply(mathblocks_complex_conjugate(omega), u),
                    mathblocks_complex_multiply(omega, v)),
                mathblocks_complex_make(normalized_a / 3.0f, 0.0f));
            for (int index = 0; index < 3; index++)
                if (!mathblocks_complex_finite(roots[index])) output->valid = 0;
            return;
        }

        if (opcode == 20)
        {
            int order = 0;
            if (!mathblocks_probability_integer(second->scalar_value, &order) ||
                order < 0 || order > first->count || scratch == null)
            {
                output->valid = 0;
                return;
            }
            for (int index = 0; index <= order; index++) scratch[index] = 0.0f;
            scratch[0] = 1.0f;
            for (int value_index = 0; value_index < first->count; value_index++)
            {
                int maximum = order < value_index + 1 ? order : value_index + 1;
                for (int degree = maximum; degree >= 1; degree--)
                    scratch[degree] += a[value_index] * scratch[degree - 1];
            }
            output->scalar_value = scratch[order];
            if (!float.IsFinite(output->scalar_value)) output->valid = 0;
            return;
        }

        if (opcode == 21)
        {
            float value = 0.0f;
            for (int index = first->count - 1; index >= 0; index--)
                value = value * second->scalar_value + a[index];
            output->scalar_value = value;
            if (!float.IsFinite(value)) output->valid = 0;
            return;
        }

        if (opcode == 22)
        {
            if (first->count <= 0)
            {
                output->valid = 0;
                return;
            }
            float maximum = a[0];
            for (int index = 1; index < first->count; index++)
                maximum = mathblocks_maximum(maximum, a[index]);
            float sum = 0.0f;
            for (int index = 0; index < first->count; index++)
                sum += mathblocks_exponential(a[index] - maximum);
            output->scalar_value = maximum + mathblocks_natural_logarithm(sum);
            if (!float.IsFinite(output->scalar_value)) output->valid = 0;
            return;
        }

        output->valid = 0;
    }
}
