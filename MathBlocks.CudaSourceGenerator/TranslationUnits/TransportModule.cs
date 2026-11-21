#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

[TranspileToCUDA]
internal static unsafe class TransportModule
{
    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_explicit_subset_size() => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_iteration_count() => throw new NotSupportedException();

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

    [CudaExternal(IsPure = true)]
    private static bool mathblocks_advanced_distribution([CudaReadOnly] float* values, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static int mathblocks_advanced_popcount(int value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_exponential(float value) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_nonnegative_integer(float value, int* result) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_positive_infinity() => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_power(float value, float exponent) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_sequence_positive_integer(float value, int* result) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_sequence_set_matrix_shape(MathBlockSlot* output, int rows, int columns) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_sequence_set_vector_shape(MathBlockSlot* output, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_square_root(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_maximum(float first, float second) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_minimum(float first, float second) => throw new NotSupportedException();
    [CudaExternal]
    private static void mathblocks_statistics_sort_copy([CudaReadOnly] float* values, int count, float* result, bool descending) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_stable_index_order([CudaReadOnly] float* keys, int count, int* order, int* buffer) => throw new NotSupportedException();

    [CudaDevice]
    private static float mathblocks_transport_mean_pairwise(
        [CudaReadOnly] float* left,
        int left_count,
        [CudaReadOnly] float* right,
        int right_count)
    {
        float sum = 0.0f;
        for (int left_index = 0; left_index < left_count; left_index++)
            for (int right_index = 0; right_index < right_count; right_index++)
                sum += MathF.Abs(left[left_index] - right[right_index]);
        return sum / (left_count * right_count);
    }

    [CudaDevice(Name = "mathblocks_transport_dispatch")]
    private static void mathblocks_transport(
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
        MathBlockSlot* fifth = Cuda.ReadOnly(input_count > 4 ? inputs[4] : null);
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
        float* c = Cuda.ReadOnly(third == null ? null : (float*)third->data_pointer);
        float* d = Cuda.ReadOnly(fourth == null ? null : (float*)fourth->data_pointer);
        float* result = (float*)output->data_pointer;
        float* scratch = (float*)output->scratch_pointer;

        if (thread == 0)
        {
            switch (opcode)
            {
                case 0:
                    if (first->rows != first->columns || second->count != first->rows)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    float total = 0.0f;
                    for (int row = 0; row < first->rows; row++)
                    {
                        int column = 0;
                        if (!mathblocks_nonnegative_integer(b[row], &column) || column >= first->columns)
                        {
                            output->valid = 0;
                            break;
                        }
                        total += a[row * first->columns + column];
                    }
                    output->scalar_value = total;
                    break;
                }
                case 1:
                    if (first->rows != second->rows || first->columns != second->columns)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    float total = 0.0f;
                    for (int row = 0; row < first->rows; row++)
                        for (int column = 0; column < first->columns; column++)
                            total += a[row * first->columns + column] *
                                     b[row * first->columns + column];
                    output->scalar_value = total;
                    break;
                }
                case 2:
                    if (first->count <= 0 || second->count <= 0)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    float cross = mathblocks_transport_mean_pairwise(
                        a, first->count, b, second->count);
                    float left_within = mathblocks_transport_mean_pairwise(
                        a, first->count, a, first->count);
                    float right_within = mathblocks_transport_mean_pairwise(
                        b, second->count, b, second->count);
                    float squared = 2.0f * cross - left_within - right_within;
                    // The owned maximum, as CoreCLR: a NaN (inf - inf from overflowing pairwise means) stays NaN and the result is invalid.
                    output->scalar_value = mathblocks_square_root(mathblocks_maximum(squared, 0.0f));
                    break;
                }
                case 3:
                    if (first->rows != first->columns || first->rows > mathblocks_limit_explicit_subset_size() || scratch == null)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    int size = first->rows;
                    int state_count = 1 << size;
                    mathblocks_sequence_set_vector_shape(output, size);
                    float* values = scratch;
                    int* previous_mask = (int*)(values + state_count);
                    int* chosen_column = previous_mask + state_count;
                    for (int index = 0; index < state_count; index++)
                    {
                        values[index] = mathblocks_positive_infinity();
                        previous_mask[index] = 0;
                        chosen_column[index] = 0;
                    }
                    values[0] = 0.0f;
                    for (int mask = 0; mask < state_count; mask++)
                    {
                        int row = mathblocks_advanced_popcount(mask);
                        if (row >= size || !float.IsFinite(values[mask]))
                            continue;
                        for (int column = 0; column < size; column++)
                        {
                            if ((mask & (1 << column)) != 0)
                                continue;
                            int next = mask | (1 << column);
                            float candidate = values[mask] + a[row * size + column];
                            if (candidate >= values[next])
                                continue;
                            values[next] = candidate;
                            previous_mask[next] = mask;
                            chosen_column[next] = column;
                        }
                    }
                    int current = state_count - 1;
                    for (int row = size - 1; row >= 0; row--)
                    {
                        result[row] = (float)chosen_column[current];
                        current = previous_mask[current];
                    }
                    break;
                }
                case 4:
                    mathblocks_sequence_set_matrix_shape(output, first->count, second->count);
                    if (!mathblocks_advanced_distribution(a, first->count) ||
                        !mathblocks_advanced_distribution(b, second->count))
                    {
                        output->valid = 0;
                        break;
                    }
                    for (int index = 0; index < output->count; index++)
                        result[index] = 0.0f;
                {
                    int left_index = 0;
                    int right_index = 0;
                    float left_remaining = a[0];
                    float right_remaining = b[0];
                    while (left_index < first->count && right_index < second->count)
                    {
                        float amount = left_remaining < right_remaining
                            ? left_remaining
                            : right_remaining;
                        result[left_index * second->count + right_index] += amount;
                        left_remaining -= amount;
                        right_remaining -= amount;
                        if (left_remaining == 0.0f && ++left_index < first->count)
                            left_remaining = a[left_index];
                        if (right_remaining == 0.0f && ++right_index < second->count)
                            right_remaining = b[right_index];
                    }
                    break;
                }
                case 5:
                    if (first->count != second->count ||
                        !mathblocks_advanced_distribution(a, first->count) ||
                        !mathblocks_advanced_distribution(b, second->count))
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    float cumulative = 0.0f;
                    float total = 0.0f;
                    for (int index = 0; index < first->count - 1; index++)
                    {
                        cumulative += a[index] - b[index];
                        total += MathF.Abs(cumulative);
                    }
                    output->scalar_value = total;
                    break;
                }
                case 6:
                    mathblocks_sequence_set_matrix_shape(output, first->rows, first->columns);
                    if (first->rows != second->count || first->columns != third->count ||
                        !mathblocks_advanced_distribution(b, second->count) ||
                        !mathblocks_advanced_distribution(c, third->count) ||
                        fourth->scalar_value <= 0.0f || scratch == null)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    int iterations = 0;
                    if (!mathblocks_sequence_positive_integer(fifth->scalar_value, &iterations) || iterations > mathblocks_limit_iteration_count())
                    {
                        output->valid = 0;
                        break;
                    }
                    float* kernel = scratch;
                    float* left_scale = kernel + first->count;
                    float* right_scale = left_scale + first->rows;
                    for (int row = 0; row < first->rows; row++)
                        for (int column = 0; column < first->columns; column++)
                            kernel[row * first->columns + column] =
                                mathblocks_exponential(-a[row * first->columns + column] /
                                                       fourth->scalar_value);
                    for (int row = 0; row < first->rows; row++)
                        left_scale[row] = 1.0f;
                    for (int column = 0; column < first->columns; column++)
                        right_scale[column] = 1.0f;
                    for (int iteration = 0; iteration < iterations; iteration++)
                    {
                        for (int row = 0; row < first->rows; row++)
                        {
                            float sum = 0.0f;
                            for (int column = 0; column < first->columns; column++)
                                sum += kernel[row * first->columns + column] * right_scale[column];
                            left_scale[row] = b[row] / sum;
                        }
                        for (int column = 0; column < first->columns; column++)
                        {
                            float sum = 0.0f;
                            for (int row = 0; row < first->rows; row++)
                                sum += kernel[row * first->columns + column] * left_scale[row];
                            right_scale[column] = c[column] / sum;
                        }
                    }
                    for (int row = 0; row < first->rows; row++)
                        for (int column = 0; column < first->columns; column++)
                            result[row * first->columns + column] =
                                left_scale[row] * kernel[row * first->columns + column] *
                                right_scale[column];
                    break;
                }
                case 7:
                    if (first->count <= 0 || first->count != second->count ||
                        third->scalar_value < 1.0f || scratch == null)
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    float* left_sorted = scratch;
                    float* right_sorted = scratch + first->count;
                    mathblocks_statistics_sort_copy(a, first->count, left_sorted, false);
                    mathblocks_statistics_sort_copy(b, second->count, right_sorted, false);
                    float sum = 0.0f;
                    for (int index = 0; index < first->count; index++)
                        sum += mathblocks_power(
                            MathF.Abs(left_sorted[index] - right_sorted[index]),
                            third->scalar_value);
                    output->scalar_value = mathblocks_power(
                        sum / first->count,
                        1.0f / third->scalar_value);
                    break;
                }
                case 8:
                    if (first->count <= 0 || first->count != second->count ||
                        third->count <= 0 || third->count != fourth->count || scratch == null ||
                        !mathblocks_advanced_distribution(b, second->count) ||
                        !mathblocks_advanced_distribution(d, fourth->count))
                    {
                        output->valid = 0;
                        break;
                    }
                {
                    int* left_order = (int*)scratch;
                    int* right_order = left_order + first->count;
                    int* left_buffer = right_order + third->count;
                    int* right_buffer = left_buffer + first->count;
                    mathblocks_stable_index_order(a, first->count, left_order, left_buffer);
                    mathblocks_stable_index_order(c, third->count, right_order, right_buffer);
                    int left_index = 0;
                    int right_index = 0;
                    float left_remaining = b[left_order[0]];
                    float right_remaining = d[right_order[0]];
                    float total = 0.0f;
                    while (left_index < first->count && right_index < third->count)
                    {
                        float amount = left_remaining < right_remaining
                            ? left_remaining
                            : right_remaining;
                        total += amount * MathF.Abs(
                            a[left_order[left_index]] - c[right_order[right_index]]);
                        left_remaining -= amount;
                        right_remaining -= amount;
                        if (left_remaining == 0.0f && ++left_index < first->count)
                            left_remaining = b[left_order[left_index]];
                        if (right_remaining == 0.0f && ++right_index < third->count)
                            right_remaining = d[right_order[right_index]];
                    }
                    output->scalar_value = total;
                    break;
                }
                case 9:
                case 10:
                    mathblocks_sequence_set_matrix_shape(output, first->rows, second->columns);
                    if (first->columns != second->rows)
                    {
                        output->valid = 0;
                        break;
                    }
                    for (int row = 0; row < first->rows; row++)
                        for (int column = 0; column < second->columns; column++)
                        {
                            float selected = opcode == 9
                                ? -mathblocks_positive_infinity()
                                : mathblocks_positive_infinity();
                            for (int inner = 0; inner < first->columns; inner++)
                            {
                                float candidate = a[row * first->columns + inner] +
                                    b[inner * second->columns + column];
                                // The owned maximum and minimum, as CoreCLR (the sign of a zero tie).
                                selected = opcode == 9
                                    ? mathblocks_maximum(selected, candidate)
                                    : mathblocks_minimum(selected, candidate);
                            }
                            result[row * second->columns + column] = selected;
                        }
                    break;
            }

            if (output->valid &&
                opcode != 3 && opcode != 4 && opcode != 6 && opcode != 9 && opcode != 10 &&
                !float.IsFinite(output->scalar_value))
            {
                output->valid = 0;
            }
            if (output->valid && (opcode == 3 || opcode == 4 || opcode == 6 || opcode == 9 || opcode == 10))
                for (int index = 0; index < output->count; index++)
                    if (!float.IsFinite(result[index])) output->valid = 0;
        }
    }
}
