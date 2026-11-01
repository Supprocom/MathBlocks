#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

[TranspileToCUDA]
internal static unsafe class VectorModule
{
    [CudaExternal]
    public struct MathBlockSlot
    {
        public double scalar_value;
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
    private static double mathblocks_exponential(double value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_natural_logarithm(double value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_power(double value, double exponent) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_square_root(double value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_quiet_nan() => throw new NotSupportedException();

    // IEEE 754-2019 minimum and maximum, as MathBlockPrimitives.Min and Max: a NaN operand gives NaN, and -0 is less than +0.
    [CudaDevice]
    private static double mathblocks_minimum(double first, double second)
    {
        if (double.IsNaN(first) || double.IsNaN(second))
            return mathblocks_quiet_nan();
        if (first < second)
            return first;
        if (second < first)
            return second;
        if (first == 0.0)
            return Cuda.SignBit(first) ? first : second;
        return first;
    }

    [CudaDevice]
    private static double mathblocks_maximum(double first, double second)
    {
        if (double.IsNaN(first) || double.IsNaN(second))
            return mathblocks_quiet_nan();
        if (first > second)
            return first;
        if (second > first)
            return second;
        if (first == 0.0)
            return Cuda.SignBit(first) ? second : first;
        return first;
    }

    [CudaDevice]
    private static bool mathblocks_nonnegative_integer(double value, int* result)
    {
        if (value < 0.0 || value > 2147483647.0 || value != Math.Truncate(value))
            return false;
        *result = (int)value;
        return true;
    }

    [CudaDevice]
    private static double mathblocks_compensated_sum([CudaReadOnly] double* values, int count)
    {
        double sum = 0.0;
        double correction = 0.0;
        for (int index = 0; index < count; index++)
        {
            double value = values[index];
            double next = sum + value;
            correction += Math.Abs(sum) >= Math.Abs(value)
                ? sum - next + value
                : value - next + sum;
            sum = next;
        }
        return sum + correction;
    }

    [CudaDevice]
    private static double mathblocks_compensated_product_sum(
        [CudaReadOnly] double* first,
        [CudaReadOnly] double* second,
        int count)
    {
        double sum = 0.0;
        double correction = 0.0;
        for (int index = 0; index < count; index++)
        {
            double value = first[index] * second[index];
            double next = sum + value;
            correction += Math.Abs(sum) >= Math.Abs(value)
                ? sum - next + value
                : value - next + sum;
            sum = next;
        }
        return sum + correction;
    }

    [CudaDevice]
    private static double mathblocks_compensated_absolute_sum([CudaReadOnly] double* values, int count)
    {
        double sum = 0.0;
        double correction = 0.0;
        for (int index = 0; index < count; index++)
        {
            double value = Math.Abs(values[index]);
            double next = sum + value;
            correction += Math.Abs(sum) >= Math.Abs(value)
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
    private static double* mathblocks_stable_merge_sort(double* values, double* buffer, int count, bool descending)
    {
        double* source = values;
        double* target = buffer;
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
            double* sorted = target;
            target = source;
            source = sorted;
        }
        return source;
    }

    // Copies count values into result and sorts them there with the merge sort, using buffer (count doubles) as the
    // other array.
    [CudaDevice]
    private static void mathblocks_stable_sort_into(
        [CudaReadOnly] double* values,
        int count,
        double* result,
        double* buffer,
        bool descending)
    {
        for (int index = 0; index < count; index++)
            result[index] = values[index];
        double* sorted = mathblocks_stable_merge_sort(result, buffer, count, descending);
        if (sorted != result)
            for (int index = 0; index < count; index++)
                result[index] = sorted[index];
    }

    // Stable insertion sort of count values into sorted.
    [CudaDevice]
    private static void mathblocks_sort_copy_values(
        [CudaReadOnly] double* source,
        int count,
        double* sorted)
    {
        for (int index = 0; index < count; index++)
        {
            double value = source[index];
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
    private static void mathblocks_stable_index_order([CudaReadOnly] double* keys, int count, int* order, int* buffer)
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
        double* scratch = (double*)output->scratch_pointer;
        double* source = Cuda.ReadOnly((double*)input->data_pointer);
        if (output->data_pointer != 0)
            mathblocks_stable_sort_into(source, input->count, (double*)output->data_pointer, scratch, false);
        else
            mathblocks_stable_sort_into(source, input->count, scratch, scratch + input->count, false);
    }

    // Sorts count values into sorted and interpolates the quantile at probability.
    [CudaDevice]
    private static double mathblocks_quantile_values(
        [CudaReadOnly] double* values,
        int count,
        double* sorted,
        double probability)
    {
        mathblocks_sort_copy_values(values, count, sorted);
        if (count == 1)
            return sorted[0];
        double position = probability * (count - 1);
        int lower = (int)Math.Floor(position);
        int upper = (int)Math.Ceiling(position);
        double weight = position - lower;
        return sorted[lower] * (1.0 - weight) + sorted[upper] * weight;
    }

    // vector.median and vector.quantile: the quantile of the stable merge sort of the input, held in the scratch
    // (2 * count doubles).
    [CudaDevice]
    private static double mathblocks_quantile(
        [CudaReadOnly] MathBlockSlot* input,
        MathBlockSlot* output,
        double probability)
    {
        double* sorted = (double*)output->scratch_pointer;
        double* source = Cuda.ReadOnly((double*)input->data_pointer);
        int count = input->count;
        mathblocks_stable_sort_into(source, count, sorted, sorted + count, false);
        if (count == 1)
            return sorted[0];
        double position = probability * (count - 1);
        int lower = (int)Math.Floor(position);
        int upper = (int)Math.Ceiling(position);
        double weight = position - lower;
        return sorted[lower] * (1.0 - weight) + sorted[upper] * weight;
    }

    [CudaDevice]
    private static bool mathblocks_vector_geometric_mean_value(
        [CudaReadOnly] double* values,
        int count,
        double* logarithms,
        double* value)
    {
        if (count <= 0)
            return false;
        bool finite = true;
        for (int index = 0; index < count; index++)
        {
            logarithms[index] = mathblocks_natural_logarithm(values[index]);
            if (!double.IsFinite(logarithms[index]))
                finite = false;
        }
        if (!finite)
            return false;
        *value = mathblocks_exponential(mathblocks_compensated_sum(logarithms, count) / count);
        return double.IsFinite(*value);
    }

    // The first position of the largest (maximum) or smallest value.
    [CudaDevice]
    private static bool mathblocks_vector_arg_extreme_value(
        [CudaReadOnly] double* values,
        int count,
        bool maximum,
        double* value)
    {
        if (count <= 0)
            return false;
        int selected = 0;
        for (int index = 1; index < count; index++)
            if (maximum ? values[index] > values[selected] : values[index] < values[selected]) selected = index;
        *value = (double)selected;
        return true;
    }

    // The average rank of values[position]: smaller values, plus the mean position among equal values.
    [CudaDevice]
    private static double mathblocks_vector_rank_at(
        [CudaReadOnly] double* values,
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
        return less + (equal + 1.0) / 2.0;
    }

    [CudaDevice]
    private static void mathblocks_vector_standardize_moments(
        [CudaReadOnly] double* values,
        int count,
        double* mean,
        double* deviation)
    {
        double average = mathblocks_compensated_sum(values, count) / count;
        double variance = 0.0;
        for (int index = 0; index < count; index++)
        {
            double difference = values[index] - average;
            variance += difference * difference;
        }
        variance /= count;
        *mean = average;
        // A variance that overflowed would divide every difference by an infinity and give zeros; NaN (invalid) instead.
        *deviation = double.IsFinite(variance) ? mathblocks_square_root(variance) : mathblocks_quiet_nan();
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
            output->scalar_value = 0.0;
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

        double* a = Cuda.ReadOnly(first == null ? null : (double*)first->data_pointer);
        double* b = Cuda.ReadOnly(second == null ? null : (double*)second->data_pointer);
        double* c = Cuda.ReadOnly(third == null ? null : (double*)third->data_pointer);
        CudaInt32* boolean_a = Cuda.ReadOnly(first == null ? null : (CudaInt32*)first->data_pointer);
        CudaInt32* boolean_b = Cuda.ReadOnly(second == null ? null : (CudaInt32*)second->data_pointer);
        double* result = (double*)(output->data_pointer != 0
            ? output->data_pointer
            : output->scratch_pointer);
        CudaInt32* boolean_result = (CudaInt32*)output->data_pointer;

        switch (opcode)
        {
            case 0:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                    result[index] = Math.Abs(a[index]);
                break;
            case 1:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                {
                    result[index] = a[index] + second->scalar_value;
                    if (!double.IsFinite(result[index])) Cuda.AtomicExchange(ref output->valid, 0);
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
                    double value = opcode == 2 ? a[index] + b[index]
                        : opcode == 9 ? a[index] / b[index]
                        : opcode == 26 ? a[index] * b[index]
                        : a[index] - b[index];
                    result[index] = value;
                    if (!double.IsFinite(value)) Cuda.AtomicExchange(ref output->valid, 0);
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
                    double product = 1.0;
                    for (int index = 0; output->valid && index < first->count; index++)
                    {
                        product *= a[index];
                        result[index] = product;
                        if (!double.IsFinite(product)) output->valid = 0;
                    }
                }
                break;
            case 8:
                if (thread == 0)
                {
                    mathblocks_set_vector_shape(output, first->count);
                    double sum = 0.0;
                    for (int index = 0; output->valid && index < first->count; index++)
                    {
                        sum += a[index];
                        result[index] = sum;
                        if (!double.IsFinite(sum)) output->valid = 0;
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
                        if (!double.IsFinite(output->scalar_value)) output->valid = 0;
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
                    double value = opcode == 12 ? mathblocks_exponential(a[index])
                        : opcode == 27 ? mathblocks_natural_logarithm(a[index])
                        : mathblocks_square_root(a[index]);
                    result[index] = value;
                    if (!double.IsFinite(value)) Cuda.AtomicExchange(ref output->valid, 0);
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
                    double norm = opcode == 17
                        ? mathblocks_compensated_absolute_sum(a, first->count)
                        : mathblocks_square_root(mathblocks_compensated_product_sum(a, a, first->count));
                    output->scalar_value = norm;
                    if (!double.IsFinite(norm)) output->valid = 0;
                }
                break;
            case 19:
                if (thread == 0) output->scalar_value = (double)first->count;
                break;
            case 21:
                if (thread == 0)
                {
                    int count = 0;
                    if (!mathblocks_nonnegative_integer(third->scalar_value, &count) || count <= 0 || count > 1000000)
                        output->valid = 0;
                    else
                        mathblocks_set_vector_shape(output, count);
                }
                Cuda.SyncThreads();
                if (output->valid)
                {
                    double start = first->scalar_value;
                    double end = second->scalar_value;
                    double step = output->count == 1 ? 0.0 : (end - start) / (output->count - 1);
                    for (int index = thread; index < output->count; index += Cuda.BlockDim.X)
                    {
                        result[index] = index == output->count - 1 ? end : start + step * index;
                        if (!double.IsFinite(result[index])) Cuda.AtomicExchange(ref output->valid, 0);
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
                    double selected = a[0];
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
                    double sum = mathblocks_compensated_sum(a, first->count);
                    output->scalar_value = opcode == 23 ? sum / first->count : sum;
                    if (!double.IsFinite(output->scalar_value)) output->valid = 0;
                }
                break;
            case 24:
            case 35:
                if (thread == 0)
                {
                    double probability = opcode == 24 ? 0.5 : second->scalar_value;
                    if (first->count <= 0 || output->scratch_pointer == 0 ||
                        probability < 0.0 || probability > 1.0)
                        output->valid = 0;
                    else
                    {
                        output->scalar_value = mathblocks_quantile(first, output, probability);
                        if (!double.IsFinite(output->scalar_value)) output->valid = 0;
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
                    if (!double.IsFinite(output->scalar_value) || output->scalar_value == 0.0) output->valid = 0;
                }
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                {
                    result[index] = a[index] * (1.0 / output->scalar_value);
                    if (!double.IsFinite(result[index])) Cuda.AtomicExchange(ref output->valid, 0);
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
                    double value = opcode == 31 ? mathblocks_maximum(a[index], 0.0)
                        : opcode == 41 ? (double)(Cuda.Int(a[index] > 0.0) - Cuda.Int(a[index] < 0.0))
                        : a[index] * a[index];
                    result[index] = value;
                    if (!double.IsFinite(value)) Cuda.AtomicExchange(ref output->valid, 0);
                }
                break;
            case 32:
                if (thread == 0) mathblocks_set_vector_shape(output, first->count);
                Cuda.SyncThreads();
                for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                {
                    result[index] = mathblocks_power(a[index], second->scalar_value);
                    if (!double.IsFinite(result[index])) Cuda.AtomicExchange(ref output->valid, 0);
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
                    double product = 1.0;
                    for (int index = 0; index < first->count; index++) product *= a[index];
                    output->scalar_value = product;
                    if (!double.IsFinite(product)) output->valid = 0;
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
                    if (!mathblocks_nonnegative_integer(second->scalar_value, &count) || count > 1000000)
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
                    if (!double.IsFinite(result[index])) Cuda.AtomicExchange(ref output->valid, 0);
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
                    double mean = 0.0;
                    double deviation = 0.0;
                    mathblocks_vector_standardize_moments(a, first->count, &mean, &deviation);
                    for (int index = 0; index < first->count; index++)
                    {
                        result[index] = (a[index] - mean) / deviation;
                        if (!double.IsFinite(result[index])) output->valid = 0;
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
                    output->scalar_value = 0.0;
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
                    output->scalar_value = (double)output->boolean_value;
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
                        if (boolean_a[index]) result[count++] = (double)index;
                    mathblocks_set_vector_shape(output, count);
                }
                break;
            default:
                if (thread == 0) output->valid = 0;
                break;
        }
    }
}
