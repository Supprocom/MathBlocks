#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

[TranspileToCUDA]
internal static unsafe class VectorModule
{
    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_generated_vector_length() => throw new NotSupportedException();

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
    private static float mathblocks_exponential(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_natural_logarithm(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_power(float value, float exponent) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_square_root(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_quiet_nan() => throw new NotSupportedException();

    // IEEE 754-2019 minimum and maximum, as MathBlockPrimitives.Min and Max: a NaN operand gives NaN, and -0 is less than +0.
    [CudaDevice]
    private static float mathblocks_minimum(float first, float second)
    {
        if (float.IsNaN(first) || float.IsNaN(second))
            return mathblocks_quiet_nan();
        if (first < second)
            return first;
        if (second < first)
            return second;
        if (first == 0.0f)
            return Cuda.SignBit(first) ? first : second;
        return first;
    }

    [CudaDevice]
    private static float mathblocks_maximum(float first, float second)
    {
        if (float.IsNaN(first) || float.IsNaN(second))
            return mathblocks_quiet_nan();
        if (first > second)
            return first;
        if (second > first)
            return second;
        if (first == 0.0f)
            return Cuda.SignBit(first) ? second : first;
        return first;
    }

    [CudaDevice]
    private static bool mathblocks_nonnegative_integer(float value, int* result)
    {
        if (value < 0.0f || value > 2147483647.0f || value != MathF.Truncate(value))
            return false;
        *result = (int)value;
        return true;
    }

    [CudaDevice]
    private static float mathblocks_compensated_sum([CudaReadOnly] float* values, int count)
    {
        float sum = 0.0f;
        float correction = 0.0f;
        for (int index = 0; index < count; index++)
        {
            float value = values[index];
            float next = sum + value;
            correction += MathF.Abs(sum) >= MathF.Abs(value)
                ? sum - next + value
                : value - next + sum;
            sum = next;
        }
        return sum + correction;
    }

    [CudaDevice]
    private static float mathblocks_compensated_product_sum(
        [CudaReadOnly] float* first,
        [CudaReadOnly] float* second,
        int count)
    {
        float sum = 0.0f;
        float correction = 0.0f;
        for (int index = 0; index < count; index++)
        {
            float value = first[index] * second[index];
            float next = sum + value;
            correction += MathF.Abs(sum) >= MathF.Abs(value)
                ? sum - next + value
                : value - next + sum;
            sum = next;
        }
        return sum + correction;
    }

    [CudaDevice]
    private static float mathblocks_compensated_absolute_sum([CudaReadOnly] float* values, int count)
    {
        float sum = 0.0f;
        float correction = 0.0f;
        for (int index = 0; index < count; index++)
        {
            float value = MathF.Abs(values[index]);
            float next = sum + value;
            correction += MathF.Abs(sum) >= MathF.Abs(value)
                ? sum - next + value
                : value - next + sum;
            sum = next;
        }
        return sum + correction;
    }

    [CudaDevice]
    private static void mathblocks_set_vector_shape(MathBlockSlot* output, int count)
    {
        output->rows = count;
        output->columns = 0;
        output->count = count;
        if (count < 0 || count > output->capacity)
        {
            output->valid = 0;
            return;
        }
    }

    // Stable bottom-up merge sort of count values, alternating between values and buffer (count doubles each). Returns
    // the array that holds the sorted values. Equal values, -0.0 and +0.0 among them, keep their input order, so the
    // result is the array the source's stable sort (SortedCopy) produces; descending takes the larger value first
    // and keeps the input order of equal ones. This is the one sort helper of the device source; it sits in the
    // second translation unit so that every later unit can declare it external.
    [CudaDevice]
    private static float* mathblocks_stable_merge_sort(float* values, float* buffer, int count, bool descending)
    {
        float* source = values;
        float* target = buffer;
        for (int width = 1; width < count; width += width)
        {
            for (int start = 0; start < count; start += width + width)
            {
                int middle = start + width < count ? start + width : count;
                int end = middle + width < count ? middle + width : count;
                int left = start;
                int right = middle;
                int position = start;
                while (left < middle && right < end)
                {
                    bool take_right = descending ? source[right] > source[left] : source[right] < source[left];
                    target[position++] = take_right ? source[right++] : source[left++];
                }
                while (left < middle)
                    target[position++] = source[left++];
                while (right < end)
                    target[position++] = source[right++];
            }
            float* sorted = target;
            target = source;
            source = sorted;
        }
        return source;
    }

    // Copies count values into result and sorts them there with the merge sort, using buffer (count doubles) as the
    // other array.
    [CudaDevice]
    private static void mathblocks_stable_sort_into(
        [CudaReadOnly] float* values,
        int count,
        float* result,
        float* buffer,
        bool descending)
    {
        for (int index = 0; index < count; index++)
            result[index] = values[index];
        float* sorted = mathblocks_stable_merge_sort(result, buffer, count, descending);
        if (sorted != result)
            for (int index = 0; index < count; index++)
                result[index] = sorted[index];
    }

    // Stable insertion sort of count values into sorted.
    [CudaDevice]
    private static void mathblocks_sort_copy_values(
        [CudaReadOnly] float* source,
        int count,
        float* sorted)
    {
        for (int index = 0; index < count; index++)
        {
            float value = source[index];
            int position = index;
            while (position > 0 && sorted[position - 1] > value)
            {
                sorted[position] = sorted[position - 1];
                position--;
            }
            sorted[position] = value;
        }
    }

    // The indices 0 .. count - 1 in the stable ascending order of keys (equal keys keep the index order), the order of
    // SortedIndices; buffer holds count ints. The sorted order ends in order.
    [CudaDevice]
    private static void mathblocks_stable_index_order([CudaReadOnly] float* keys, int count, int* order, int* buffer)
    {
        for (int index = 0; index < count; index++)
            order[index] = index;
        int* source = order;
        int* target = buffer;
        for (int width = 1; width < count; width += width)
        {
            for (int start = 0; start < count; start += width + width)
            {
                int middle = start + width < count ? start + width : count;
                int end = middle + width < count ? middle + width : count;
                int left = start;
                int right = middle;
                int position = start;
                while (left < middle && right < end)
                {
                    bool take_right = keys[source[right]] < keys[source[left]];
                    target[position++] = take_right ? source[right++] : source[left++];
                }
                while (left < middle)
                    target[position++] = source[left++];
                while (right < end)
                    target[position++] = source[right++];
            }
            int* sorted = target;
            target = source;
            source = sorted;
        }
        if (source != order)
            for (int index = 0; index < count; index++)
                order[index] = source[index];
    }

    // vector.sort: the stable merge sort of the source's SortedCopy. The sorted values end in the output's data (or in
    // the scratch when the output has no data pointer); the scratch holds 2 * count doubles, the other array of the merge.
    [CudaDevice]
    private static void mathblocks_copy_and_sort(
        [CudaReadOnly] MathBlockSlot* input,
        MathBlockSlot* output)
    {
        float* scratch = (float*)output->scratch_pointer;
        float* source = Cuda.ReadOnly((float*)input->data_pointer);
        if (output->data_pointer != 0)
            mathblocks_stable_sort_into(source, input->count, (float*)output->data_pointer, scratch, false);
        else
            mathblocks_stable_sort_into(source, input->count, scratch, scratch + input->count, false);
    }

    // Sorts count values into sorted and interpolates the quantile at probability.
    [CudaDevice]
    private static float mathblocks_quantile_values(
        [CudaReadOnly] float* values,
        int count,
        float* sorted,
        float probability)
    {
        mathblocks_sort_copy_values(values, count, sorted);
        if (count == 1)
            return sorted[0];
        float position = probability * (count - 1);
        int lower = (int)MathF.Floor(position);
        int upper = (int)MathF.Ceiling(position);
        float weight = position - lower;
        return sorted[lower] * (1.0f - weight) + sorted[upper] * weight;
    }

    // vector.median and vector.quantile: the quantile of the stable merge sort of the input, held in the scratch
    // (2 * count doubles).
    [CudaDevice]
    private static float mathblocks_quantile(
        [CudaReadOnly] MathBlockSlot* input,
        MathBlockSlot* output,
        float probability)
    {
        float* sorted = (float*)output->scratch_pointer;
        float* source = Cuda.ReadOnly((float*)input->data_pointer);
        int count = input->count;
        mathblocks_stable_sort_into(source, count, sorted, sorted + count, false);
        if (count == 1)
            return sorted[0];
        float position = probability * (count - 1);
        int lower = (int)MathF.Floor(position);
        int upper = (int)MathF.Ceiling(position);
        float weight = position - lower;
        return sorted[lower] * (1.0f - weight) + sorted[upper] * weight;
    }

    [CudaDevice]
    private static bool mathblocks_vector_geometric_mean_value(
        [CudaReadOnly] float* values,
        int count,
        float* logarithms,
        float* value)
    {
        if (count <= 0)
            return false;
        bool finite = true;
        for (int index = 0; index < count; index++)
        {
            logarithms[index] = mathblocks_natural_logarithm(values[index]);
            if (!float.IsFinite(logarithms[index]))
                finite = false;
        }
        if (!finite)
            return false;
        *value = mathblocks_exponential(mathblocks_compensated_sum(logarithms, count) / count);
        return float.IsFinite(*value);
    }

    // The first position of the largest (maximum) or smallest value.
    [CudaDevice]
    private static bool mathblocks_vector_arg_extreme_value(
        [CudaReadOnly] float* values,
        int count,
        bool maximum,
        float* value)
    {
        if (count <= 0)
            return false;
        int selected = 0;
        for (int index = 1; index < count; index++)
            if (maximum ? values[index] > values[selected] : values[index] < values[selected]) selected = index;
        *value = (float)selected;
        return true;
    }

    // The average rank of values[position]: smaller values, plus the mean position among equal values.
    [CudaDevice]
    private static float mathblocks_vector_rank_at(
        [CudaReadOnly] float* values,
        int count,
        int position)
    {
        int less = 0;
        int equal = 0;
        for (int other = 0; other < count; other++)
        {
            if (values[other] < values[position]) less++;
            else if (values[other] == values[position]) equal++;
        }
        return less + (equal + 1.0f) / 2.0f;
    }

    [CudaDevice]
    private static void mathblocks_vector_standardize_moments(
        [CudaReadOnly] float* values,
        int count,
        float* mean,
        float* deviation)
    {
        float average = mathblocks_compensated_sum(values, count) / count;
        float variance = 0.0f;
        for (int index = 0; index < count; index++)
        {
            float difference = values[index] - average;
            variance += difference * difference;
        }
        variance /= count;
        *mean = average;
        // A variance that overflowed would divide every difference by an infinity and give zeros; NaN (invalid) instead.
        *deviation = float.IsFinite(variance) ? mathblocks_square_root(variance) : mathblocks_quiet_nan();
    }

    [CudaDevice(Name = "mathblocks_vector_dispatch")]
    private static void mathblocks_vector(
        int opcode,
        MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        int thread = (int)Cuda.ThreadIdx.X;
        MathBlockSlot* first = Cuda.ReadOnly(input_count > 0 ? inputs[0] : null);
        MathBlockSlot* second = Cuda.ReadOnly(input_count > 1 ? inputs[1] : null);
        MathBlockSlot* third = Cuda.ReadOnly(input_count > 2 ? inputs[2] : null);

        if (thread == 0)
        {
            output->scalar_value = 0.0f;
            output->boolean_value = 0;
            output->rows = 0;
            output->columns = 0;
            output->count = 0;
            output->valid = first == null || first->valid;
            if (second != null)
                output->valid = output->valid && second->valid;
            if (third != null)
                output->valid = output->valid && third->valid;
        }
        Cuda.SyncThreads();
        if (!output->valid)
            return;

        float* a = Cuda.ReadOnly(first == null ? null : (float*)first->data_pointer);
        float* b = Cuda.ReadOnly(second == null ? null : (float*)second->data_pointer);
        float* c = Cuda.ReadOnly(third == null ? null : (float*)third->data_pointer);
        CudaInt32* boolean_a = Cuda.ReadOnly(first == null ? null : (CudaInt32*)first->data_pointer);
        CudaInt32* boolean_b = Cuda.ReadOnly(second == null ? null : (CudaInt32*)second->data_pointer);
        float* result = (float*)(output->data_pointer != 0
            ? output->data_pointer
            : output->scratch_pointer);
        CudaInt32* boolean_result = (CudaInt32*)output->data_pointer;

        switch (opcode)
        {
            case 0:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                    result[index] = MathF.Abs(a[index]);
                break;
            case 1:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                {
                    result[index] = a[index] + second->scalar_value;
                    if (!float.IsFinite(result[index])) Cuda.AtomicExchange(ref output->valid, 0);
                }
                break;
            case 2:
            case 9:
            case 26:
            case 47:
                if (thread == 0)
                {
                    mathblocks_set_vector_shape(output, first->count);
                    if (first->count != second->count) output->valid = 0;
                }
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                {
                    float value = opcode == 2 ? a[index] + b[index]
                        : opcode == 9 ? a[index] / b[index]
                        : opcode == 26 ? a[index] * b[index]
                        : a[index] - b[index];
                    result[index] = value;
                    if (!float.IsFinite(value)) Cuda.AtomicExchange(ref output->valid, 0);
                }
                break;
            case 3:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count + 1);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                    result[index] = a[index];
                if (thread == 0 && output->valid) result[first->count] = second->scalar_value;
                break;
            case 4:
            case 5:
                if (thread == 0 &&
                    !mathblocks_vector_arg_extreme_value(a, first->count, opcode == 4, &output->scalar_value))
                    output->valid = 0;
                break;
            case 6:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count + second->count);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                    result[index] = a[index];
                for (int index = thread; output->valid && index < second->count; index += Cuda.BlockDim.X)
                    result[first->count + index] = b[index];
                break;
            case 7:
                if (thread == 0)
                {
                    mathblocks_set_vector_shape(output, first->count);
                    float product = 1.0f;
                    for (int index = 0; output->valid && index < first->count; index++)
                    {
                        product *= a[index];
                        result[index] = product;
                        if (!float.IsFinite(product)) output->valid = 0;
                    }
                }
                break;
            case 8:
                if (thread == 0)
                {
                    mathblocks_set_vector_shape(output, first->count);
                    float sum = 0.0f;
                    for (int index = 0; output->valid && index < first->count; index++)
                    {
                        sum += a[index];
                        result[index] = sum;
                        if (!float.IsFinite(sum)) output->valid = 0;
                    }
                }
                break;
            case 10:
                if (thread == 0)
                {
                    if (first->count != second->count) output->valid = 0;
                    else
                    {
                        output->scalar_value = mathblocks_compensated_product_sum(a, b, first->count);
                        if (!float.IsFinite(output->scalar_value)) output->valid = 0;
                    }
                }
                break;
            case 11:
            case 15:
            case 20:
                if (thread == 0)
                {
                    mathblocks_set_vector_shape(output, first->count);
                    if (first->count != second->count) output->valid = 0;
                }
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                    boolean_result[index] = opcode == 11 ? a[index] == b[index]
                        : opcode == 15 ? a[index] > b[index]
                        : a[index] < b[index];
                break;
            case 12:
            case 27:
            case 44:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                {
                    float value = opcode == 12 ? mathblocks_exponential(a[index])
                        : opcode == 27 ? mathblocks_natural_logarithm(a[index])
                        : mathblocks_square_root(a[index]);
                    result[index] = value;
                    if (!float.IsFinite(value)) Cuda.AtomicExchange(ref output->valid, 0);
                }
                break;
            case 13:
                if (thread == 0) mathblocks_set_vector_shape(output, second->count);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < second->count; index += Cuda.BlockDim.X)
                {
                    int source_index = 0;
                    if (!mathblocks_nonnegative_integer(b[index], &source_index) || source_index >= first->count)
                        Cuda.AtomicExchange(ref output->valid, 0);
                    else
                        result[index] = a[source_index];
                }
                break;
            case 14:
                if (thread == 0 &&
                    (output->scratch_pointer == 0 ||
                     !mathblocks_vector_geometric_mean_value(a, first->count, result, &output->scalar_value)))
                    output->valid = 0;
                break;
            case 16:
                if (thread == 0)
                {
                    int index = 0;
                    if (!mathblocks_nonnegative_integer(second->scalar_value, &index) || index >= first->count)
                        output->valid = 0;
                    else
                        output->scalar_value = a[index];
                }
                break;
            case 17:
            case 18:
                if (thread == 0)
                {
                    float norm = opcode == 17
                        ? mathblocks_compensated_absolute_sum(a, first->count)
                        : mathblocks_square_root(mathblocks_compensated_product_sum(a, a, first->count));
                    output->scalar_value = norm;
                    if (!float.IsFinite(norm)) output->valid = 0;
                }
                break;
            case 19:
                if (thread == 0) output->scalar_value = (float)first->count;
                break;
            case 21:
                if (thread == 0)
                {
                    int count = 0;
                    if (!mathblocks_nonnegative_integer(third->scalar_value, &count) || count <= 0 || count > mathblocks_limit_generated_vector_length())
                        output->valid = 0;
                    else
                        mathblocks_set_vector_shape(output, count);
                }
                Cuda.SyncThreads();
                if (output->valid)
                {
                    float start = first->scalar_value;
                    float end = second->scalar_value;
                    float step = output->count == 1 ? 0.0f : (end - start) / (output->count - 1);
                    for (int index = thread; index < output->count; index += Cuda.BlockDim.X)
                    {
                        result[index] = index == output->count - 1 ? end : start + step * index;
                        if (!float.IsFinite(result[index])) Cuda.AtomicExchange(ref output->valid, 0);
                    }
                }
                break;
            case 22:
            case 25:
                if (thread == 0)
                {
                    if (first->count <= 0)
                    {
                        output->valid = 0;
                        break;
                    }
                    float selected = a[0];
                    for (int index = 1; index < first->count; index++)
                        selected = opcode == 22
                            ? mathblocks_maximum(selected, a[index])
                            : mathblocks_minimum(selected, a[index]);
                    output->scalar_value = selected;
                }
                break;
            case 23:
            case 48:
                if (thread == 0)
                {
                    float sum = mathblocks_compensated_sum(a, first->count);
                    output->scalar_value = opcode == 23 ? sum / first->count : sum;
                    if (!float.IsFinite(output->scalar_value)) output->valid = 0;
                }
                break;
            case 24:
            case 35:
                if (thread == 0)
                {
                    float probability = opcode == 24 ? 0.5f : second->scalar_value;
                    if (first->count <= 0 || output->scratch_pointer == 0 ||
                        probability < 0.0f || probability > 1.0f)
                        output->valid = 0;
                    else
                    {
                        output->scalar_value = mathblocks_quantile(first, output, probability);
                        if (!float.IsFinite(output->scalar_value)) output->valid = 0;
                    }
                }
                break;
            case 28:
            case 29:
                if (thread == 0)
                {
                    mathblocks_set_vector_shape(output, first->count);
                    output->scalar_value = opcode == 28
                        ? mathblocks_compensated_absolute_sum(a, first->count)
                        : mathblocks_square_root(mathblocks_compensated_product_sum(a, a, first->count));
                    if (!float.IsFinite(output->scalar_value) || output->scalar_value == 0.0f) output->valid = 0;
                }
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                {
                    result[index] = a[index] * (1.0f / output->scalar_value);
                    if (!float.IsFinite(result[index])) Cuda.AtomicExchange(ref output->valid, 0);
                }
                break;
            case 30:
                if (thread == 0)
                {
                    mathblocks_set_vector_shape(output, 2);
                    if (output->valid)
                    {
                        result[0] = first->scalar_value;
                        result[1] = second->scalar_value;
                    }
                }
                break;
            case 31:
            case 41:
            case 45:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                {
                    float value = opcode == 31 ? mathblocks_maximum(a[index], 0.0f)
                        : opcode == 41 ? (float)(Cuda.Int(a[index] > 0.0f) - Cuda.Int(a[index] < 0.0f))
                        : a[index] * a[index];
                    result[index] = value;
                    if (!float.IsFinite(value)) Cuda.AtomicExchange(ref output->valid, 0);
                }
                break;
            case 32:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                {
                    result[index] = mathblocks_power(a[index], second->scalar_value);
                    if (!float.IsFinite(result[index])) Cuda.AtomicExchange(ref output->valid, 0);
                }
                break;
            case 33:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count + 1);
                Cuda.SyncThreads();
                if (thread == 0 && output->valid) result[0] = second->scalar_value;
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                    result[index + 1] = a[index];
                break;
            case 34:
                if (thread == 0)
                {
                    float product = 1.0f;
                    for (int index = 0; index < first->count; index++) product *= a[index];
                    output->scalar_value = product;
                    if (!float.IsFinite(product)) output->valid = 0;
                }
                break;
            case 36:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                    result[index] = mathblocks_vector_rank_at(a, first->count, index);
                break;
            case 37:
                if (thread == 0)
                {
                    int count = 0;
                    if (!mathblocks_nonnegative_integer(second->scalar_value, &count) || count > mathblocks_limit_generated_vector_length())
                        output->valid = 0;
                    else
                        mathblocks_set_vector_shape(output, count);
                }
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < output->count; index += Cuda.BlockDim.X)
                    result[index] = first->scalar_value;
                break;
            case 38:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                    result[index] = a[first->count - index - 1];
                break;
            case 39:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                {
                    result[index] = a[index] * second->scalar_value;
                    if (!float.IsFinite(result[index])) Cuda.AtomicExchange(ref output->valid, 0);
                }
                break;
            case 40:
                if (thread == 0)
                {
                    mathblocks_set_vector_shape(output, first->count);
                    if (first->count != second->count || first->count != third->count) output->valid = 0;
                }
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                    result[index] = boolean_a[index] ? b[index] : c[index];
                break;
            case 42:
                if (thread == 0)
                {
                    int start = 0;
                    int length = 0;
                    if (!mathblocks_nonnegative_integer(second->scalar_value, &start) ||
                        !mathblocks_nonnegative_integer(third->scalar_value, &length) ||
                        start > first->count || length > first->count - start)
                        output->valid = 0;
                    else
                        mathblocks_set_vector_shape(output, length);
                }
                Cuda.SyncThreads();
                if (output->valid)
                {
                    int start = (int)second->scalar_value;
                    for (int index = thread; index < output->count; index += Cuda.BlockDim.X)
                        result[index] = a[start + index];
                }
                break;
            case 43:
                if (thread == 0)
                {
                    mathblocks_set_vector_shape(output, first->count);
                    if (output->valid) mathblocks_copy_and_sort(first, output);
                }
                break;
            case 46:
                if (thread == 0)
                {
                    mathblocks_set_vector_shape(output, first->count);
                    if (!output->valid || first->count <= 0)
                    {
                        output->valid = 0;
                        break;
                    }
                    float mean = 0.0f;
                    float deviation = 0.0f;
                    mathblocks_vector_standardize_moments(a, first->count, &mean, &deviation);
                    for (int index = 0; index < first->count; index++)
                    {
                        result[index] = (a[index] - mean) / deviation;
                        if (!float.IsFinite(result[index])) output->valid = 0;
                    }
                }
                break;
            case 49:
                if (thread == 0)
                {
                    int count = 0;
                    for (int index = 0; index < first->count; index++)
                    {
                        bool found = false;
                        for (int prior = 0; prior < count; prior++)
                            if (result[prior] == a[index]) { found = true; break; }
                        if (!found) result[count++] = a[index];
                    }
                    mathblocks_set_vector_shape(output, count);
                }
                break;
            case 50:
            case 52:
            case 55:
            {
                if (thread == 0)
                {
                    output->boolean_value = opcode == 50 ? 1 : 0;
                    output->scalar_value = 0.0f;
                }
                Cuda.SyncThreads();
                int local_count = 0;
                bool local_all = true;
                bool local_any = false;
                for (int index = thread; index < first->count; index += Cuda.BlockDim.X)
                {
                    bool value = boolean_a[index] != 0;
                    if (value) local_count++;
                    local_all = local_all && value;
                    local_any = local_any || value;
                }
                if (opcode == 55 && local_count != 0)
                    Cuda.AtomicAdd(ref output->boolean_value, local_count);
                else if (opcode == 50 && !local_all)
                    Cuda.AtomicExchange(ref output->boolean_value, 0);
                else if (opcode == 52 && local_any)
                    Cuda.AtomicExchange(ref output->boolean_value, 1);
                Cuda.SyncThreads();
                if (thread == 0 && opcode == 55)
                {
                    output->scalar_value = (float)output->boolean_value;
                    output->boolean_value = 0;
                }
                break;
            }
            case 51:
            case 54:
            case 57:
                if (thread == 0)
                {
                    mathblocks_set_vector_shape(output, first->count);
                    if (first->count != second->count) output->valid = 0;
                }
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                    boolean_result[index] = opcode == 51 ? boolean_a[index] && boolean_b[index]
                        : opcode == 54 ? boolean_a[index] || boolean_b[index]
                        : boolean_a[index] != boolean_b[index];
                break;
            case 53:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                    boolean_result[index] = !boolean_a[index];
                break;
            case 56:
                if (thread == 0)
                {
                    int count = 0;
                    for (int index = 0; index < first->count; index++)
                        if (boolean_a[index]) result[count++] = (float)index;
                    mathblocks_set_vector_shape(output, count);
                }
                break;
            default:
                if (thread == 0) output->valid = 0;
                break;
        }
    }
}
