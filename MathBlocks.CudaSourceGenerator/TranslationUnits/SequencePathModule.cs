#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

[TranspileToCUDA]
internal static unsafe class SequencePathModule
{
    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_state_count() => throw new NotSupportedException();

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

    [CudaExternal]
    private static bool mathblocks_nonnegative_integer(double value, int* result) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_positive_infinity() => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_power(double value, double exponent) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_square_root(double value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_maximum(double first, double second) => throw new NotSupportedException();

    public struct MathBlockSequencePathRun
    {
        public int start;
        public int length;
        public double value;
    }

    [CudaDevice]
    private static bool mathblocks_sequence_positive_integer(double value, int* result)
    {
        return mathblocks_nonnegative_integer(value, result) && *result > 0;
    }

    [CudaDevice]
    private static void mathblocks_sequence_set_vector_shape(MathBlockSlot* output, int count)
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

    [CudaDevice]
    private static void mathblocks_sequence_set_matrix_shape(
        MathBlockSlot* output,
        int rows,
        int columns)
    {
        long count = (long)rows * columns;
        output->rows = rows;
        output->columns = columns;
        output->count = count > 2147483647L ? -1 : (int)count;
        if (rows < 0 || columns < 0 || count > output->capacity)
        {
            output->valid = 0;
            return;
        }
    }

    [CudaDevice]
    private static ulong mathblocks_sequence_order_key(double value)
    {
        ulong bits = (ulong)BitConverter.DoubleToInt64Bits(value);
        if (value == 0.0)
            bits = 0UL;
        return (bits & 0x8000000000000000UL) != 0UL
            ? ~bits
            : bits ^ 0x8000000000000000UL;
    }

    [CudaDevice]
    private static bool mathblocks_sequence_is_power_of_two(int value)
    {
        return value > 0 && (value & (value - 1)) == 0;
    }

    [CudaDevice]
    private static void mathblocks_sequence_prepare_order_ranks(
        [CudaReadOnly] double* values,
        int count,
        byte* scratch,
        MathBlockSlot* output)
    {
        int thread = (int)Cuda.ThreadIdx.X;
        ulong* first_keys = (ulong*)scratch;
        ulong* second_keys = first_keys + count;
        int* first_indexes = (int*)(second_keys + count);
        int* second_indexes = first_indexes + count;
        int* ranks = second_indexes + count;
        int* lower_heap = ranks + count;
        int* upper_heap = lower_heap + output->boolean_value;
        int* positions = upper_heap + output->boolean_value;
        int* kinds = positions + count;
        // The radix passes run on a fixed partition of 128 virtual lanes (MathBlockCudaDeviceModule.VirtualLaneCount): a real thread
        // t takes the lanes t, t + block size, ... below 128, so the chunks, the counts and the scratch layout do not depend on
        // the block size, and a block larger than 128 leaves its extra threads idle in the lane phases.
        const int virtual_lanes = 128;
        int* zero_counts = kinds + count;
        int* zero_prefix = zero_counts + virtual_lanes;

        for (int index = thread; index < count; index += Cuda.BlockDim.X)
        {
            if (!double.IsFinite(values[index]))
                Cuda.AtomicExchange(ref output->valid, 0);
            first_keys[index] = mathblocks_sequence_order_key(values[index]);
            first_indexes[index] = index;
        }
        Cuda.SyncThreads();
        if (!output->valid)
            return;

        ulong* source_keys = first_keys;
        ulong* destination_keys = second_keys;
        int* source_indexes = first_indexes;
        int* destination_indexes = second_indexes;
        for (int bit = 0; bit < 64; bit++)
        {
            for (int lane = thread; lane < virtual_lanes; lane += (int)Cuda.BlockDim.X)
            {
                int begin = (int)(((long)count * lane) / virtual_lanes);
                int end = (int)(((long)count * (lane + 1)) / virtual_lanes);
                int zeros = 0;
                for (int index = begin; index < end; index++)
                    if (((source_keys[index] >> bit) & 1UL) == 0UL)
                        zeros++;
                zero_counts[lane] = zeros;
            }
            Cuda.SyncThreads();
            if (thread == 0)
            {
                int prefix = 0;
                for (int lane = 0; lane < virtual_lanes; lane++)
                {
                    zero_prefix[lane] = prefix;
                    prefix += zero_counts[lane];
                }
                output->columns = prefix;
            }
            Cuda.SyncThreads();
            for (int lane = thread; lane < virtual_lanes; lane += (int)Cuda.BlockDim.X)
            {
                int begin = (int)(((long)count * lane) / virtual_lanes);
                int end = (int)(((long)count * (lane + 1)) / virtual_lanes);
                int zero_destination = zero_prefix[lane];
                int one_destination = output->columns + begin - zero_destination;
                for (int index = begin; index < end; index++)
                {
                    ulong key = source_keys[index];
                    int destination = ((key >> bit) & 1UL) == 0UL
                        ? zero_destination++
                        : one_destination++;
                    destination_keys[destination] = key;
                    destination_indexes[destination] = source_indexes[index];
                }
            }
            Cuda.SyncThreads();
            ulong* key_swap = source_keys;
            source_keys = destination_keys;
            destination_keys = key_swap;
            int* index_swap = source_indexes;
            source_indexes = destination_indexes;
            destination_indexes = index_swap;
        }
        for (int index = thread; index < count; index += Cuda.BlockDim.X)
            ranks[source_indexes[index]] = index;
        Cuda.SyncThreads();
        if (thread == 0)
            output->columns = 0;
        Cuda.SyncThreads();
    }

    [CudaDevice]
    private static void mathblocks_sequence_heap_swap(
        int* heap,
        int left,
        int right,
        int* positions)
    {
        int value = heap[left];
        heap[left] = heap[right];
        heap[right] = value;
        positions[heap[left]] = left;
        positions[heap[right]] = right;
    }

    [CudaDevice]
    private static bool mathblocks_sequence_heap_precedes(
        int left,
        int right,
        [CudaReadOnly] int* ranks,
        bool maximum)
    {
        return maximum
            ? ranks[left] > ranks[right]
            : ranks[left] < ranks[right];
    }

    [CudaDevice]
    private static void mathblocks_sequence_heap_sift_up(
        int* heap,
        int position,
        int* positions,
        [CudaReadOnly] int* ranks,
        bool maximum)
    {
        while (position > 0)
        {
            int parent = (position - 1) >> 1;
            if (!mathblocks_sequence_heap_precedes(
                    heap[position],
                    heap[parent],
                    ranks,
                    maximum))
            {
                break;
            }
            mathblocks_sequence_heap_swap(heap, position, parent, positions);
            position = parent;
        }
    }

    [CudaDevice]
    private static void mathblocks_sequence_heap_sift_down(
        int* heap,
        int count,
        int position,
        int* positions,
        [CudaReadOnly] int* ranks,
        bool maximum)
    {
        while (true)
        {
            int left = position * 2 + 1;
            if (left >= count)
                return;
            int right = left + 1;
            int selected = right < count && mathblocks_sequence_heap_precedes(
                    heap[right],
                    heap[left],
                    ranks,
                    maximum)
                ? right
                : left;
            if (!mathblocks_sequence_heap_precedes(
                    heap[selected],
                    heap[position],
                    ranks,
                    maximum))
            {
                return;
            }
            mathblocks_sequence_heap_swap(heap, position, selected, positions);
            position = selected;
        }
    }

    [CudaDevice]
    private static void mathblocks_sequence_heap_insert(
        int* heap,
        int* count,
        int item,
        int kind,
        int* positions,
        int* kinds,
        [CudaReadOnly] int* ranks,
        bool maximum)
    {
        int position = (*count)++;
        heap[position] = item;
        positions[item] = position;
        kinds[item] = kind;
        mathblocks_sequence_heap_sift_up(
            heap,
            position,
            positions,
            ranks,
            maximum);
    }

    [CudaDevice]
    private static void mathblocks_sequence_heap_remove(
        int* heap,
        int* count,
        int item,
        int* positions,
        int* kinds,
        [CudaReadOnly] int* ranks,
        bool maximum)
    {
        int position = positions[item];
        int replacement = heap[--(*count)];
        kinds[item] = -1;
        positions[item] = -1;
        if (position >= *count)
            return;
        heap[position] = replacement;
        positions[replacement] = position;
        if (position > 0 && mathblocks_sequence_heap_precedes(
                heap[position],
                heap[(position - 1) >> 1],
                ranks,
                maximum))
        {
            mathblocks_sequence_heap_sift_up(
                heap,
                position,
                positions,
                ranks,
                maximum);
        }
        else
        {
            mathblocks_sequence_heap_sift_down(
                heap,
                *count,
                position,
                positions,
                ranks,
                maximum);
        }
    }

    [CudaDevice]
    private static void mathblocks_sequence_rebalance_heaps(
        int* lower_heap,
        int* lower_count,
        int* upper_heap,
        int* upper_count,
        int target_lower_count,
        int* positions,
        int* kinds,
        [CudaReadOnly] int* ranks)
    {
        while (*lower_count > target_lower_count)
        {
            int item = lower_heap[0];
            mathblocks_sequence_heap_remove(
                lower_heap,
                lower_count,
                item,
                positions,
                kinds,
                ranks,
                true);
            mathblocks_sequence_heap_insert(
                upper_heap,
                upper_count,
                item,
                1,
                positions,
                kinds,
                ranks,
                false);
        }
        while (*lower_count < target_lower_count)
        {
            int item = upper_heap[0];
            mathblocks_sequence_heap_remove(
                upper_heap,
                upper_count,
                item,
                positions,
                kinds,
                ranks,
                false);
            mathblocks_sequence_heap_insert(
                lower_heap,
                lower_count,
                item,
                0,
                positions,
                kinds,
                ranks,
                true);
        }
    }

    [CudaDevice]
    private static void mathblocks_sequence_rolling_extreme(
        [CudaReadOnly] double* values,
        int count,
        int width,
        double* result,
        int* deque,
        bool minimum)
    {
        int head = 0;
        int tail = 0;
        for (int index = 0; index < count; index++)
        {
            while (head < tail && deque[head] <= index - width)
                head++;
            while (head < tail && (minimum
                ? values[deque[tail - 1]] > values[index]
                : values[deque[tail - 1]] < values[index]))
            {
                tail--;
            }
            deque[tail++] = index;
            if (index >= width - 1)
                result[index - width + 1] = values[deque[head]];
        }
    }

    [CudaDevice]
    private static void mathblocks_sequence_rolling_sum(
        [CudaReadOnly] double* values,
        int count,
        int width,
        double* result)
    {
        double sum = 0.0;
        for (int index = 0; index < width; index++)
            sum += values[index];
        result[0] = sum;
        for (int index = width; index < count; index++)
        {
            sum += values[index] - values[index - width];
            result[index - width + 1] = sum;
        }
    }

    [CudaDevice]
    private static double mathblocks_sequence_first_passage_value(
        [CudaReadOnly] double* values,
        int count,
        double threshold,
        bool at_or_above)
    {
        int result_index = -1;
        for (int index = 0; index < count; index++)
        {
            if (at_or_above ? values[index] >= threshold : values[index] <= threshold)
            {
                result_index = index;
                break;
            }
        }
        return (double)result_index;
    }

    [CudaDevice]
    private static double mathblocks_sequence_longest_run_value(
        [CudaReadOnly] CudaInt32* values,
        int count)
    {
        int maximum = 0;
        int current = 0;
        for (int index = 0; index < count; index++)
        {
            current = values[index] ? current + 1 : 0;
            maximum = maximum > current ? maximum : current;
        }
        return (double)maximum;
    }

    [CudaDevice]
    private static bool mathblocks_sequence_decline_value(
        [CudaReadOnly] double* values,
        int count,
        bool relative,
        double* value)
    {
        if (count <= 0)
            return false;
        double maximum = values[0];
        double decline = 0.0;
        for (int index = 1; index < count; index++)
        {
            // The owned maximum, as CoreCLR: a NaN candidate (0 / 0 at a zero peak) makes the result NaN (invalid), and -0 is less than +0.
            maximum = mathblocks_maximum(maximum, values[index]);
            double candidate = !relative
                ? maximum - values[index]
                : (maximum - values[index]) / maximum;
            decline = mathblocks_maximum(decline, candidate);
        }
        *value = decline;
        return double.IsFinite(decline);
    }

    // Sums |x[i] - x[i - 1]| (absolute) or its power of the given order.
    [CudaDevice]
    private static bool mathblocks_sequence_variation_value(
        [CudaReadOnly] double* values,
        int count,
        double order,
        bool absolute,
        double* value)
    {
        if (count <= 0)
            return false;
        if (!(order > 0.0))
            return false;
        double total = 0.0;
        for (int index = 1; index < count; index++)
        {
            double change = Math.Abs(values[index] - values[index - 1]);
            total += absolute ? change : mathblocks_power(change, order);
        }
        *value = total;
        return double.IsFinite(total);
    }

    [CudaDevice]
    private static bool mathblocks_sequence_recurrence_value(
        [CudaReadOnly] double* values,
        int count,
        double threshold,
        double* value)
    {
        if (count <= 0 || threshold < 0.0)
            return false;
        long recurrent = 0;
        long total = (long)count * count;
        for (int left = 0; left < count; left++)
            for (int right = 0; right < count; right++)
                if (Math.Abs(values[left] - values[right]) <= threshold)
                    recurrent++;
        *value = (double)recurrent / total;
        return true;
    }

    // Counts sign changes of the values, or of their first differences, skipping zeros.
    [CudaDevice]
    private static double mathblocks_sequence_sign_change_value(
        [CudaReadOnly] double* values,
        int count,
        bool differenced)
    {
        int changes = 0;
        int previous = 0;
        int start = differenced ? 1 : 0;
        for (int index = start; index < count; index++)
        {
            double difference = differenced ? values[index] - values[index - 1] : values[index];
            int current = difference > 0.0 ? 1 : difference < 0.0 ? -1 : 0;
            if (current == 0)
                continue;
            if (previous != 0 && current != previous)
                changes++;
            previous = current;
        }
        return (double)changes;
    }

    // An integer offset that fits int32 without its extreme negative value, as MathBlockVectorMath.TryReadOffset accepts.
    [CudaDevice]
    private static bool mathblocks_sequence_offset(double value, int* result)
    {
        if (value != Math.Truncate(value) || value > 2147483647.0 || value < -2147483647.0)
            return false;
        *result = (int)value;
        return true;
    }

    // Row row + offset exists and is chained to row: a later row by the counts at that row, an earlier row by the counts at row.
    [CudaDevice]
    private static bool mathblocks_sequence_offset_reachable(
        [CudaReadOnly] double* counts,
        int count,
        int row,
        long offset)
    {
        long target = row + offset;
        if (target < 0 || target >= count)
            return false;
        if (offset < 0)
            return counts[row] >= (double)(-offset);
        return counts[(int)target] >= (double)offset;
    }

    // One row of sequence.first-true-offset (kind 0), sequence.sum-over-offsets (kind 1) or sequence.maximum-over-offsets (kind 2),
    // the loops of MathBlockVectorMath.FirstTrueOffsetRow, SumOverOffsetsRow and MaximumOverOffsetsRow. The maximum starts at the
    // first row of the span, which is what a start at negative infinity gives under Math.Max. Returns the validity of the row.
    [CudaDevice]
    private static bool mathblocks_sequence_offset_row(
        int kind,
        [CudaReadOnly] double* values,
        [CudaReadOnly] CudaInt32* values_valid,
        [CudaReadOnly] double* counts,
        int count,
        int row,
        int start,
        int end,
        double no_match,
        double* result)
    {
        *result = 0.0;
        if (kind == 0)
        {
            for (long offset = start; offset <= end; offset++)
            {
                if (!mathblocks_sequence_offset_reachable(counts, count, row, offset))
                    return false;
                int target = (int)(row + offset);
                if (!values_valid[target])
                    return false;
                if (values[target] != 0.0)
                {
                    *result = (double)offset;
                    return true;
                }
            }
            *result = no_match;
            return true;
        }
        long before = 0L;
        if (start < 0)
            before = -(long)start;
        long after = 0L;
        if (end > 0)
            after = (long)end;
        if ((long)row + start < 0 || counts[row] < (double)before)
            return false;
        long last = row + after;
        if (last >= count || counts[(int)last] < (double)after)
            return false;
        long first = (long)row + start;
        double accumulator = 0.0;
        for (long index = first; index <= (long)row + end; index++)
        {
            if (!values_valid[(int)index])
                return false;
            if (kind == 1)
            {
                accumulator += values[(int)index];
                if (!double.IsFinite(accumulator))
                    return false;
            }
            else if (index == first)
            {
                accumulator = values[(int)index];
            }
            else
            {
                accumulator = Math.Max(accumulator, values[(int)index]);
            }
        }
        *result = accumulator;
        return true;
    }

    // Opcodes 37 to 42: the value (odd) and validity (even) operations of first-true-offset, sum-over-offsets and
    // maximum-over-offsets. Inputs: the series, its validity (a Boolean vector), the counts, start and end, then for a value
    // operation the fill and, for first-true, the no-match offset before it. Every row is independent, so thread t takes the rows
    // t, t + block size, ...; an input that is not valid, a length that differs, a count that is not a non-negative integer, or an
    // offset that is not an integer or has start above end invalidates the whole call, as on CoreCLR.
    [CudaDevice]
    private static void mathblocks_sequence_offsets(
        int opcode,
        MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        int thread = (int)Cuda.ThreadIdx.X;
        MathBlockSlot* series = Cuda.ReadOnly(inputs[0]);
        MathBlockSlot* flags = Cuda.ReadOnly(inputs[1]);
        MathBlockSlot* counts_slot = Cuda.ReadOnly(inputs[2]);
        MathBlockSlot* start_slot = Cuda.ReadOnly(inputs[3]);
        MathBlockSlot* end_slot = Cuda.ReadOnly(inputs[4]);
        int kind = (opcode - 37) / 2;
        bool validity = (opcode & 1) == 0;
        int start = 0;
        int end = 0;
        bool offsets_valid = mathblocks_sequence_offset(start_slot->scalar_value, &start);
        if (offsets_valid)
            offsets_valid = mathblocks_sequence_offset(end_slot->scalar_value, &end);
        if (offsets_valid)
            offsets_valid = start <= end;
        if (thread == 0)
        {
            output->valid = series->valid && flags->valid && counts_slot->valid && start_slot->valid && end_slot->valid;
            for (int index = 5; index < input_count; index++)
            {
                MathBlockSlot* extra = Cuda.ReadOnly(inputs[index]);
                output->valid = output->valid && extra->valid;
            }
            mathblocks_sequence_set_vector_shape(output, series->count);
            if (flags->count != series->count || counts_slot->count != series->count || !offsets_valid)
                output->valid = 0;
        }
        Cuda.SyncThreads();
        double* values = Cuda.ReadOnly((double*)series->data_pointer);
        CudaInt32* values_valid = Cuda.ReadOnly((CudaInt32*)flags->data_pointer);
        double* counts = Cuda.ReadOnly((double*)counts_slot->data_pointer);
        for (int index = thread; output->valid && index < series->count; index += (int)Cuda.BlockDim.X)
        {
            if (!(counts[index] >= 0.0) || counts[index] != Math.Truncate(counts[index]))
                Cuda.AtomicExchange(ref output->valid, 0);
        }
        Cuda.SyncThreads();
        if (!output->valid)
            return;

        double no_match = 0.0;
        double fill = 0.0;
        if (!validity)
        {
            MathBlockSlot* fill_slot = Cuda.ReadOnly(inputs[input_count - 1]);
            fill = fill_slot->scalar_value;
            if (kind == 0)
            {
                MathBlockSlot* no_match_slot = Cuda.ReadOnly(inputs[5]);
                no_match = no_match_slot->scalar_value;
            }
        }
        double* result = (double*)output->data_pointer;
        CudaInt32* boolean_result = (CudaInt32*)output->data_pointer;
        for (int row = thread; row < series->count; row += (int)Cuda.BlockDim.X)
        {
            double value = 0.0;
            bool row_valid = mathblocks_sequence_offset_row(
                kind, values, values_valid, counts, series->count, row, start, end, no_match, &value);
            if (validity)
                boolean_result[row] = row_valid;
            else
                result[row] = row_valid ? value : fill;
        }
    }

    [CudaDevice(Name = "mathblocks_sequence_path_dispatch")]
    private static void mathblocks_sequence_path(
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
        CudaInt32* boolean_a = Cuda.ReadOnly(first == null ? null : (CudaInt32*)first->data_pointer);
        double* result = (double*)output->data_pointer;
        double* scratch = (double*)output->scratch_pointer;

        // Convolution: every output is an independent sum, formed by one thread over the left index in ascending order, which
        // is the order in which CoreCLR (and the serial loop below) adds to that output; thread t takes the outputs t, t + block
        // size, ... The domain test reads only inputs and no thread writes the output slot before the barrier; thread 0 sets the
        // shape and the validity in the switch below, after the barrier that makes the results visible to it.
        if (opcode == 0)
        {
            int convolution_count = first->count + second->count - 1;
            if (first->count > 0 && second->count > 0 && convolution_count <= output->capacity)
            {
                for (int output_index = thread; output_index < convolution_count; output_index += (int)Cuda.BlockDim.X)
                {
                    int low = output_index - (second->count - 1);
                    int left_start = low > 0 ? low : 0;
                    int left_end = output_index < first->count - 1 ? output_index : first->count - 1;
                    double sum = 0.0;
                    for (int left = left_start; left <= left_end; left++)
                        sum += a[left] * b[output_index - left];
                    result[output_index] = sum;
                }
            }
            Cuda.SyncThreads();
        }

        switch (opcode)
        {
            case 0:
                if (thread == 0)
                {
                    int count = first->count + second->count - 1;
                    mathblocks_sequence_set_vector_shape(output, count);
                    if (first->count <= 0 || second->count <= 0)
                        output->valid = 0;
                    // The block-parallel section above filled every output; a non-finite output is absorbing (an infinity or a NaN
                    // stays one under every later addition), so it is non-finite exactly when CoreCLR's running check fired. Only then
                    // is the serial loop below run again, which leaves the partially filled data exactly as it did.
                    bool finite = true;
                    for (int index = 0; output->valid && index < count; index++)
                        if (!double.IsFinite(result[index]))
                            finite = false;
                    if (finite)
                        break;
                    for (int index = 0; output->valid && index < count; index++)
                        result[index] = 0.0;
                    for (int left = 0; output->valid && left < first->count; left++)
                    {
                        for (int right = 0; right < second->count; right++)
                        {
                            result[left + right] += a[left] * b[right];
                            if (!double.IsFinite(result[left + right]))
                                output->valid = 0;
                        }
                    }
                }
                break;
            case 1:
            {
                int lag = 0;
                if (thread == 0)
                {
                    if (!mathblocks_sequence_positive_integer(second->scalar_value, &lag) || lag >= first->count)
                        output->valid = 0;
                    else
                        mathblocks_sequence_set_vector_shape(output, first->count - lag);
                    output->scalar_value = (double)lag;
                }
                Cuda.SyncThreads();
                lag = (int)output->scalar_value;
                for (int index = thread; output->valid && index < output->count; index += Cuda.BlockDim.X)
                {
                    result[index] = a[index + lag] - a[index];
                    if (!double.IsFinite(result[index])) Cuda.AtomicExchange(ref output->valid, 0);
                }
                break;
            }
            case 2:
                if (thread == 0)
                {
                    double alpha = second->scalar_value;
                    mathblocks_sequence_set_vector_shape(output, first->count);
                    if (first->count <= 0 || !(alpha > 0.0 && alpha <= 1.0))
                        output->valid = 0;
                    if (output->valid)
                    {
                        result[0] = a[0];
                        for (int index = 1; index < first->count; index++)
                        {
                            result[index] = alpha * a[index] + (1.0 - alpha) * result[index - 1];
                            if (!double.IsFinite(result[index]))
                                output->valid = 0;
                        }
                    }
                }
                break;
            case 3:
            case 6:
                if (thread == 0)
                {
                    int width = 0;
                    if (!mathblocks_sequence_positive_integer(second->scalar_value, &width) ||
                        width > first->count || scratch == null)
                    {
                        output->valid = 0;
                    }
                    else
                    {
                        mathblocks_sequence_set_vector_shape(output, first->count - width + 1);
                        int* deque = (int*)scratch;
                        int head = 0;
                        int tail = 0;
                        for (int index = 0; index < first->count; index++)
                        {
                            while (head < tail && deque[head] <= index - width)
                                head++;
                            while (head < tail && (opcode == 6
                                ? a[deque[tail - 1]] >= a[index]
                                : a[deque[tail - 1]] <= a[index]))
                            {
                                tail--;
                            }
                            deque[tail++] = index;
                            if (index >= width - 1)
                                result[index - width + 1] = a[deque[head]];
                        }
                    }
                }
                break;
            case 4:
            case 9:
                if (thread == 0)
                {
                    int width = 0;
                    if (!mathblocks_sequence_positive_integer(second->scalar_value, &width) || width > first->count)
                    {
                        output->valid = 0;
                    }
                    else
                    {
                        mathblocks_sequence_set_vector_shape(output, first->count - width + 1);
                        mathblocks_sequence_rolling_sum(a, first->count, width, result);
                        if (opcode == 4)
                        {
                            double scale = 1.0 / width;
                            for (int index = 0; index < output->count; index++)
                                result[index] *= scale;
                        }
                        for (int index = 0; index < output->count; index++)
                            if (!double.IsFinite(result[index])) output->valid = 0;
                    }
                }
                break;
            case 5:
            case 7:
            {
                int width = 0;
                double probability = 0.0;
                if (thread == 0)
                {
                    probability = opcode == 5 ? 0.5 : third->scalar_value;
                    if (!mathblocks_sequence_positive_integer(second->scalar_value, &width) ||
                        width > first->count || !(probability >= 0.0 && probability <= 1.0) ||
                        (width > 1 && scratch == null))
                    {
                        output->valid = 0;
                    }
                    else
                    {
                        mathblocks_sequence_set_vector_shape(output, first->count - width + 1);
                    }
                    output->scalar_value = probability;
                    output->boolean_value = width;
                }
                Cuda.SyncThreads();
                width = output->boolean_value;
                probability = output->scalar_value;
                // Thread 0 reuses both fields for the work counters below; every thread must have read them first.
                Cuda.SyncThreads();
                if (!output->valid)
                    break;
                if (width == 1)
                {
                    for (int index = thread; index < first->count; index += Cuda.BlockDim.X)
                        result[index] = a[index];
                    Cuda.SyncThreads();
                    if (thread == 0)
                    {
                        output->scalar_value = (double)first->count;
                        output->boolean_value = 0;
                    }
                    break;
                }
                if (probability == 0.0 || probability == 1.0)
                {
                    if (thread == 0)
                    {
                        mathblocks_sequence_rolling_extreme(
                            a,
                            first->count,
                            width,
                            result,
                            (int*)scratch,
                            probability == 0.0);
                        output->scalar_value = (double)(
                            (long)first->count * 3 + output->count);
                        output->boolean_value = 0;
                    }
                    Cuda.SyncThreads();
                    break;
                }

                byte* order_scratch = (byte*)scratch;
                mathblocks_sequence_prepare_order_ranks(
                    a,
                    first->count,
                    order_scratch,
                    output);
                if (!output->valid)
                    break;
                ulong* first_keys = (ulong*)order_scratch;
                ulong* second_keys = first_keys + first->count;
                int* first_indexes = (int*)(second_keys + first->count);
                int* second_indexes = first_indexes + first->count;
                int* ranks = second_indexes + first->count;
                int* lower_heap = ranks + first->count;
                int* upper_heap = lower_heap + width;
                int* positions = upper_heap + width;
                int* kinds = positions + first->count;
                double quantile_position = probability * (width - 1);
                int lower_index = (int)Math.Floor(quantile_position);
                int upper_index = (int)Math.Ceiling(quantile_position);
                double weight = quantile_position - lower_index;

                if (output->count == 1)
                {
                    if (thread == 0)
                    {
                        double lower_value = a[first_indexes[lower_index]];
                        double upper_value = a[first_indexes[upper_index]];
                        result[0] = lower_value * (1.0 - weight) + upper_value * weight;
                        output->valid = double.IsFinite(result[0]);
                        output->scalar_value = (double)((long)first->count * 64 + 2);
                        output->boolean_value = 64;
                    }
                    Cuda.SyncThreads();
                    break;
                }

                for (int index = thread; index < first->count; index += Cuda.BlockDim.X)
                {
                    positions[index] = -1;
                    kinds[index] = -1;
                }
                Cuda.SyncThreads();
                if (thread == 0)
                {
                    int lower_count = 0;
                    int upper_count = 0;
                    int target_lower_count = lower_index + 1;
                    for (int index = 0; index < width; index++)
                    {
                        if (lower_count == 0 && upper_count == 0)
                        {
                            mathblocks_sequence_heap_insert(
                                lower_heap,
                                &lower_count,
                                index,
                                0,
                                positions,
                                kinds,
                                ranks,
                                true);
                        }
                        else if (lower_count == 0)
                        {
                            mathblocks_sequence_heap_insert(
                                upper_heap,
                                &upper_count,
                                index,
                                1,
                                positions,
                                kinds,
                                ranks,
                                false);
                        }
                        else if (ranks[index] <= ranks[lower_heap[0]])
                        {
                            mathblocks_sequence_heap_insert(
                                lower_heap,
                                &lower_count,
                                index,
                                0,
                                positions,
                                kinds,
                                ranks,
                                true);
                        }
                        else
                        {
                            mathblocks_sequence_heap_insert(
                                upper_heap,
                                &upper_count,
                                index,
                                1,
                                positions,
                                kinds,
                                ranks,
                                false);
                        }
                        int active_target = target_lower_count < index + 1
                            ? target_lower_count
                            : index + 1;
                        mathblocks_sequence_rebalance_heaps(
                            lower_heap,
                            &lower_count,
                            upper_heap,
                            &upper_count,
                            active_target,
                            positions,
                            kinds,
                            ranks);
                    }
                    for (int start = 0; start < output->count; start++)
                    {
                        double lower_value = a[lower_heap[0]];
                        double upper_value = lower_index == upper_index
                            ? lower_value
                            : a[upper_heap[0]];
                        result[start] = lower_value * (1.0 - weight) + upper_value * weight;
                        if (!double.IsFinite(result[start]))
                        {
                            output->valid = 0;
                            break;
                        }
                        if (start + 1 == output->count)
                            break;
                        int outgoing = start;
                        int incoming = start + width;
                        if (kinds[outgoing] == 0)
                        {
                            mathblocks_sequence_heap_remove(
                                lower_heap,
                                &lower_count,
                                outgoing,
                                positions,
                                kinds,
                                ranks,
                                true);
                        }
                        else
                        {
                            mathblocks_sequence_heap_remove(
                                upper_heap,
                                &upper_count,
                                outgoing,
                                positions,
                                kinds,
                                ranks,
                                false);
                        }
                        if (lower_count == 0)
                        {
                            mathblocks_sequence_heap_insert(
                                upper_heap,
                                &upper_count,
                                incoming,
                                1,
                                positions,
                                kinds,
                                ranks,
                                false);
                        }
                        else if (ranks[incoming] <= ranks[lower_heap[0]])
                        {
                            mathblocks_sequence_heap_insert(
                                lower_heap,
                                &lower_count,
                                incoming,
                                0,
                                positions,
                                kinds,
                                ranks,
                                true);
                        }
                        else
                        {
                            mathblocks_sequence_heap_insert(
                                upper_heap,
                                &upper_count,
                                incoming,
                                1,
                                positions,
                                kinds,
                                ranks,
                                false);
                        }
                        mathblocks_sequence_rebalance_heaps(
                            lower_heap,
                            &lower_count,
                            upper_heap,
                            &upper_count,
                            target_lower_count,
                            positions,
                            kinds,
                            ranks);
                    }
                    int heap_height = 1;
                    for (int value = width; value > 1; value = (value + 1) >> 1)
                        heap_height++;
                    long heap_bound = ((long)width +
                        2l * (first->count - width)) * heap_height;
                    long selection_bound = (long)output->count * 2;
                    output->scalar_value = (double)(
                        (long)first->count * 64 + heap_bound + selection_bound);
                    output->boolean_value = 64;
                }
                Cuda.SyncThreads();
                break;
            }
            case 8:
            case 10:
                if (thread == 0)
                {
                    int width = 0;
                    if (!mathblocks_sequence_positive_integer(second->scalar_value, &width) || width > first->count)
                    {
                        output->valid = 0;
                    }
                    else
                    {
                        mathblocks_sequence_set_vector_shape(output, first->count - width + 1);
                        for (int start = 0; start < output->count; start++)
                        {
                            double mean = 0.0;
                            for (int index = 0; index < width; index++)
                                mean += a[start + index];
                            mean /= width;
                            double sum_squares = 0.0;
                            for (int index = 0; index < width; index++)
                            {
                                double difference = a[start + index] - mean;
                                sum_squares += difference * difference;
                            }
                            double deviation = mathblocks_square_root(sum_squares / width);
                            result[start] = opcode == 8 ? deviation : deviation * deviation;
                            if (!double.IsFinite(result[start]))
                                output->valid = 0;
                        }
                    }
                }
                break;
            case 11:
                if (thread == 0)
                {
                    mathblocks_sequence_set_vector_shape(output, first->count);
                    if (!mathblocks_sequence_is_power_of_two(first->count) || scratch == null)
                    {
                        output->valid = 0;
                    }
                    else
                    {
                        for (int index = 0; index < first->count; index++)
                            result[index] = a[index];
                        int length = first->count;
                        double scale = 1.0 / mathblocks_square_root(2.0);
                        while (length > 1)
                        {
                            int half = length / 2;
                            for (int index = 0; index < half; index++)
                            {
                                scratch[index] = (result[2 * index] + result[2 * index + 1]) * scale;
                                scratch[half + index] = (result[2 * index] - result[2 * index + 1]) * scale;
                            }
                            for (int index = 0; index < length; index++)
                                result[index] = scratch[index];
                            length = half;
                        }
                        for (int index = 0; index < first->count; index++)
                            if (!double.IsFinite(result[index])) output->valid = 0;
                    }
                }
                break;
            case 12:
                if (thread == 0)
                {
                    mathblocks_sequence_set_vector_shape(output, first->count);
                    if (!mathblocks_sequence_is_power_of_two(first->count))
                    {
                        output->valid = 0;
                    }
                    else
                    {
                        for (int index = 0; index < first->count; index++)
                            result[index] = a[index];
                        for (int width = 1; width < first->count; width *= 2)
                        {
                            for (int start = 0; start < first->count; start += 2 * width)
                            {
                                for (int offset = 0; offset < width; offset++)
                                {
                                    double left = result[start + offset];
                                    double right = result[start + width + offset];
                                    result[start + offset] = left + right;
                                    result[start + width + offset] = left - right;
                                }
                            }
                        }
                        double scale = 1.0 / mathblocks_square_root((double)first->count);
                        for (int index = 0; index < first->count; index++)
                        {
                            result[index] *= scale;
                            if (!double.IsFinite(result[index])) output->valid = 0;
                        }
                    }
                }
                break;
            case 13:
                if (thread == 0)
                {
                    mathblocks_sequence_set_vector_shape(output, first->count);
                    double sum = 0.0;
                    for (int index = 0; index < first->count; index++)
                    {
                        sum += a[index] - second->scalar_value;
                        result[index] = sum;
                        if (!double.IsFinite(sum))
                            output->valid = 0;
                    }
                }
                break;
            case 14:
                {
                    int rows_count = first->count;
                    int columns_count = second->count;
                    if (rows_count <= 0 || columns_count <= 0 || scratch == null)
                    {
                        Cuda.SyncThreads();
                        if (thread == 0)
                            output->valid = 0;
                        break;
                    }

                    double* diagonal_even = scratch;
                    double* diagonal_odd = scratch + (columns_count + 1);
                    for (int diagonal = 2; diagonal <= rows_count + columns_count; diagonal++)
                    {
                        double* older = (diagonal & 1) == 0 ? diagonal_even : diagonal_odd;
                        double* newer = (diagonal & 1) == 0 ? diagonal_odd : diagonal_even;
                        int low = diagonal - rows_count > 1 ? diagonal - rows_count : 1;
                        int high = columns_count < diagonal - 1 ? columns_count : diagonal - 1;
                        for (int top = high; top >= low; top -= Cuda.BlockDim.X)
                        {
                            int right = top - thread;
                            bool active = right >= low;
                            double value = 0.0;
                            if (active)
                            {
                                int left = diagonal - right;
                                double above = left == 1 ? mathblocks_positive_infinity() : newer[right];
                                double before = right == 1 ? mathblocks_positive_infinity() : newer[right - 1];
                                double corner = left == 1 || right == 1
                                    ? (left == 1 && right == 1 ? 0.0 : mathblocks_positive_infinity())
                                    : older[right - 1];
                                double minimum = above < before ? above : before;
                                minimum = minimum < corner ? minimum : corner;
                                value = Math.Abs(a[left - 1] - b[right - 1]) + minimum;
                            }
                            Cuda.SyncThreads();
                            if (active)
                                older[right] = value;
                            Cuda.SyncThreads();
                        }
                    }

                    if (thread == 0)
                    {
                        double* last = ((rows_count + columns_count) & 1) == 0 ? diagonal_even : diagonal_odd;
                        output->scalar_value = last[columns_count];
                        if (!double.IsFinite(output->scalar_value))
                            output->valid = 0;
                    }
                }
                break;
            case 15:
                if (thread == 0)
                {
                    output->scalar_value = mathblocks_sequence_first_passage_value(
                        a,
                        first->count,
                        second->scalar_value,
                        third->boolean_value != 0);
                }
                break;
            case 16:
                if (thread == 0)
                {
                    double lower = second->scalar_value;
                    double upper = third->scalar_value;
                    mathblocks_sequence_set_vector_shape(output, first->count);
                    if (!(lower < upper))
                    {
                        output->valid = 0;
                    }
                    else
                    {
                        double state = 0.0;
                        for (int index = 0; index < first->count; index++)
                        {
                            if (a[index] >= upper)
                                state = 1.0;
                            else if (a[index] <= lower)
                                state = -1.0;
                            result[index] = state;
                        }
                    }
                }
                break;
            case 17:
                if (thread == 0)
                {
                    int rows = first->count == 0 ? 0 : 2 * first->count - 1;
                    mathblocks_sequence_set_matrix_shape(output, rows, 2);
                    if (first->count <= 0)
                    {
                        output->valid = 0;
                    }
                    else
                    {
                        result[0] = a[0];
                        result[1] = a[0];
                        int row = 0;
                        for (int index = 1; index < first->count; index++)
                        {
                            row++;
                            result[row * 2] = a[index];
                            result[row * 2 + 1] = a[index - 1];
                            row++;
                            result[row * 2] = a[index];
                            result[row * 2 + 1] = a[index];
                        }
                    }
                }
                break;
            case 18:
                if (thread == 0)
                    output->scalar_value = mathblocks_sequence_longest_run_value(boolean_a, first->count);
                break;
            case 19:
            case 20:
                if (thread == 0 &&
                    !mathblocks_sequence_decline_value(a, first->count, opcode == 20, &output->scalar_value))
                    output->valid = 0;
                break;
            case 21:
            case 22:
            case 29:
                if (thread == 0 &&
                    !mathblocks_sequence_variation_value(
                        a,
                        first->count,
                        opcode == 22 ? 2.0 : second == null ? 1.0 : second->scalar_value,
                        opcode == 29,
                        &output->scalar_value))
                    output->valid = 0;
                break;
            case 23:
                if (thread == 0 &&
                    !mathblocks_sequence_recurrence_value(
                        a,
                        first->count,
                        second->scalar_value,
                        &output->scalar_value))
                    output->valid = 0;
                break;
            case 24:
                if (thread == 0)
                {
                    mathblocks_sequence_set_vector_shape(output, first->count);
                    if (first->count <= 0)
                    {
                        output->valid = 0;
                    }
                    else
                    {
                        double cumulative = 0.0;
                        double minimum = 0.0;
                        for (int index = 0; index < first->count; index++)
                        {
                            cumulative += a[index];
                            minimum = minimum < cumulative ? minimum : cumulative;
                            result[index] = cumulative - minimum;
                            if (!double.IsFinite(result[index]))
                                output->valid = 0;
                        }
                    }
                }
                break;
            case 25:
                if (thread == 0)
                {
                    MathBlockSequencePathRun* runs = (MathBlockSequencePathRun*)output->data_pointer;
                    if (first->count == 0)
                    {
                        output->count = 0;
                        output->rows = 0;
                    }
                    else
                    {
                        int start = 0;
                        int count = 0;
                        for (int index = 1; index <= first->count; index++)
                        {
                            if (index < first->count && a[index] == a[start])
                                continue;
                            if (count >= output->capacity)
                            {
                                output->count = output->capacity == 2147483647
                                    ? -1
                                    : output->capacity + 1;
                                output->rows = output->count;
                                output->valid = 0;
                                break;
                            }
                            runs[count].start = start;
                            runs[count].length = index - start;
                            runs[count].value = a[start];
                            count++;
                            start = index;
                        }
                        if (output->valid)
                        {
                            output->count = count;
                            output->rows = count;
                        }
                    }
                }
                break;
            case 26:
                if (thread == 0)
                {
                    mathblocks_sequence_set_vector_shape(output, first->columns);
                    if (first->rows <= 0)
                    {
                        output->valid = 0;
                    }
                    else
                    {
                        for (int column = 0; column < first->columns; column++)
                        {
                            result[column] = a[(first->rows - 1) * first->columns + column] - a[column];
                            if (!double.IsFinite(result[column])) output->valid = 0;
                        }
                    }
                }
                break;
            case 27:
                if (thread == 0)
                {
                    int dimension = first->columns;
                    int count = dimension * dimension * dimension;
                    mathblocks_sequence_set_vector_shape(output, count);
                    if (first->rows < 1 || scratch == null)
                    {
                        output->valid = 0;
                    }
                    else
                    {
                        double* level_one = scratch;
                        double* level_two = scratch + dimension;
                        double* increment = level_two + dimension * dimension;
                        for (int index = 0; index < dimension; index++)
                            level_one[index] = 0.0;
                        for (int index = 0; index < dimension * dimension; index++)
                            level_two[index] = 0.0;
                        for (int index = 0; index < count; index++)
                            result[index] = 0.0;
                        for (int row = 1; row < first->rows; row++)
                        {
                            for (int index = 0; index < dimension; index++)
                                increment[index] = a[row * dimension + index] - a[(row - 1) * dimension + index];
                            for (int left = 0; left < dimension; left++)
                            {
                                for (int middle = 0; middle < dimension; middle++)
                                {
                                    for (int right = 0; right < dimension; right++)
                                    {
                                        int target = (left * dimension + middle) * dimension + right;
                                        result[target] +=
                                            level_two[left * dimension + middle] * increment[right] +
                                            level_one[left] * increment[middle] * increment[right] / 2.0 +
                                            increment[left] * increment[middle] * increment[right] / 6.0;
                                    }
                                    level_two[left * dimension + middle] +=
                                        level_one[left] * increment[middle] +
                                        increment[left] * increment[middle] / 2.0;
                                }
                                level_one[left] += increment[left];
                            }
                        }
                        for (int index = 0; index < count; index++)
                            if (!double.IsFinite(result[index])) output->valid = 0;
                    }
                }
                break;
            case 28:
                if (thread == 0)
                {
                    int dimension = first->columns;
                    mathblocks_sequence_set_matrix_shape(output, dimension, dimension);
                    if (scratch == null)
                    {
                        output->valid = 0;
                    }
                    else
                    {
                        double* cumulative = scratch;
                        double* increment = scratch + dimension;
                        for (int index = 0; index < dimension; index++)
                            cumulative[index] = 0.0;
                        for (int index = 0; index < dimension * dimension; index++)
                            result[index] = 0.0;
                        for (int row = 1; row < first->rows; row++)
                        {
                            for (int column = 0; column < dimension; column++)
                                increment[column] = a[row * dimension + column] - a[(row - 1) * dimension + column];
                            for (int left = 0; left < dimension; left++)
                            {
                                for (int right = 0; right < dimension; right++)
                                {
                                    result[left * dimension + right] +=
                                        cumulative[left] * increment[right] +
                                        0.5 * increment[left] * increment[right];
                                }
                            }
                            for (int column = 0; column < dimension; column++)
                                cumulative[column] += increment[column];
                        }
                        for (int index = 0; index < dimension * dimension; index++)
                            if (!double.IsFinite(result[index])) output->valid = 0;
                    }
                }
                break;
            case 30:
            case 31:
                if (thread == 0)
                    output->scalar_value = mathblocks_sequence_sign_change_value(a, first->count, opcode == 30);
                break;
            case 32:
                if (thread == 0)
                {
                    int state_count = 0;
                    if (!mathblocks_sequence_positive_integer(second->scalar_value, &state_count) || state_count > mathblocks_limit_state_count())
                    {
                        output->valid = 0;
                    }
                    else
                    {
                        mathblocks_sequence_set_matrix_shape(output, state_count, state_count);
                        for (int index = 0; output->valid && index < output->count; index++)
                            result[index] = 0.0;
                        for (int index = 0; output->valid && index < first->count; index++)
                        {
                            int state = 0;
                            if (!mathblocks_nonnegative_integer(a[index], &state) || state >= state_count)
                                output->valid = 0;
                        }
                        for (int index = 1; output->valid && index < first->count; index++)
                            result[(int)a[index - 1] * state_count + (int)a[index]] += 1.0;
                    }
                }
                break;
            // sequence.lead (33), sequence.lead-valid (34), sequence.lag (35) and sequence.lag-valid (36). The inputs are the series,
            // its availability flags, the counts of contiguous steps before each row, the offset and, for the value forms, the fill.
            // The whole call is invalid when the lengths differ, the offset is not an integer of at least 1, or a count is not a
            // non-negative integer. Each row is then independent: it holds the shifted value (or true) when the shifted row exists,
            // the rows between are chained and the shifted row is available, and the fill (or false) otherwise. The offset is limited to
            // the row count, which leaves every row unavailable and keeps the index arithmetic in int, as on CoreCLR.
            case 33:
            case 34:
            case 35:
            case 36:
            {
                bool shift_forward = opcode < 35;
                bool shift_sibling = opcode % 2 == 0;
                MathBlockSlot* shift_offset_input = Cuda.ReadOnly(input_count > 3 ? inputs[3] : null);
                MathBlockSlot* shift_fill_input = Cuda.ReadOnly(input_count > 4 ? inputs[4] : null);
                CudaInt32* shift_flags = Cuda.ReadOnly((CudaInt32*)second->data_pointer);
                double* shift_counts = Cuda.ReadOnly((double*)third->data_pointer);
                CudaInt32* shift_boolean = (CudaInt32*)output->data_pointer;
                int shift_rows = first->count;
                if (thread == 0)
                {
                    mathblocks_sequence_set_vector_shape(output, shift_rows);
                    double shift_offset_value = shift_offset_input == null ? 0.0 : shift_offset_input->scalar_value;
                    if (input_count != (shift_sibling ? 4 : 5) || !shift_offset_input->valid || (!shift_sibling && !shift_fill_input->valid) ||
                        second->count != shift_rows || third->count != shift_rows ||
                        !(shift_offset_value >= 1.0) || shift_offset_value != Math.Truncate(shift_offset_value))
                        output->valid = 0;
                    output->scalar_value = shift_offset_value < (double)shift_rows ? shift_offset_value : (double)shift_rows;
                }
                Cuda.SyncThreads();
                for (int shift_index = thread; output->valid && shift_index < shift_rows; shift_index += Cuda.BlockDim.X)
                {
                    double shift_count_value = shift_counts[shift_index];
                    if (!(shift_count_value >= 0.0) || shift_count_value != Math.Truncate(shift_count_value) || !double.IsFinite(shift_count_value))
                        Cuda.AtomicExchange(ref output->valid, 0);
                }
                Cuda.SyncThreads();
                int shift_offset = (int)output->scalar_value;
                double shift_fill = 0.0;
                if (output->valid && !shift_sibling)
                    shift_fill = shift_fill_input->scalar_value;
                for (int shift_index = thread; output->valid && shift_index < shift_rows; shift_index += Cuda.BlockDim.X)
                {
                    bool shift_available = false;
                    int shift_source = 0;
                    if (shift_forward)
                    {
                        if (shift_index < shift_rows - shift_offset)
                        {
                            shift_source = shift_index + shift_offset;
                            shift_available = shift_counts[shift_source] >= (double)shift_offset && shift_flags[shift_source];
                        }
                    }
                    else if (shift_index >= shift_offset)
                    {
                        shift_source = shift_index - shift_offset;
                        shift_available = shift_counts[shift_index] >= (double)shift_offset && shift_flags[shift_source];
                    }
                    if (shift_sibling)
                        shift_boolean[shift_index] = shift_available;
                    else
                        result[shift_index] = shift_available ? a[shift_source] : shift_fill;
                }
                break;
            }
            case 37:
            case 38:
            case 39:
            case 40:
            case 41:
            case 42:
                mathblocks_sequence_offsets(opcode, inputs, input_count, output);
                break;
            // Prefix difference over offsets (43: the values, 44: the validity flags): one thread walks the series once. A segment
            // starts at row 0 and at every row whose count is 0. Inside a segment two running prefixes follow the row index,
            // P[row + start] and P[row + end + 1], each added left to right from the segment start (the sum of the rows before
            // it, an unavailable row adding nothing, which equals adding 0), so every prefix is the sequential sum that CoreCLR
            // forms; both positions only move forward as the row grows. The cost is one pass over the series on one thread, with
            // no scratch. A row is valid when both ends lie in its segment, no unavailable row lies between them and the
            // difference is finite; any other row holds the fill (43) or 0 (44).
            case 43:
            case 44:
            {
                MathBlockSlot* start_slot = Cuda.ReadOnly(input_count > 3 ? inputs[3] : null);
                MathBlockSlot* end_slot = Cuda.ReadOnly(input_count > 4 ? inputs[4] : null);
                MathBlockSlot* fill_slot = Cuda.ReadOnly(input_count > 5 ? inputs[5] : null);
                CudaInt32* available = Cuda.ReadOnly(second == null ? null : (CudaInt32*)second->data_pointer);
                double* counts = Cuda.ReadOnly(third == null ? null : (double*)third->data_pointer);
                CudaInt32* flags = (CudaInt32*)output->data_pointer;
                if (thread == 0)
                {
                    int count = first->count;
                    double start = start_slot->scalar_value;
                    double end = end_slot->scalar_value;
                    double fill = 0.0;
                    if (opcode == 43)
                        fill = fill_slot->scalar_value;
                    mathblocks_sequence_set_vector_shape(output, count);
                    if (!start_slot->valid || !end_slot->valid || (opcode == 43 && !fill_slot->valid) ||
                        second->count != count || third->count != count)
                    {
                        output->valid = 0;
                    }
                    if (!double.IsFinite(start) || !double.IsFinite(end) || start != Math.Floor(start) ||
                        end != Math.Floor(end) || start > end)
                    {
                        output->valid = 0;
                    }
                    for (int row = 0; output->valid && row < count; row++)
                        if (!double.IsFinite(counts[row]) || counts[row] < 0.0 || counts[row] != Math.Floor(counts[row]))
                            output->valid = 0;
                    int segment_start = 0;
                    while (output->valid && segment_start < count)
                    {
                        int segment_end = segment_start + 1;
                        while (segment_end < count && counts[segment_end] != 0.0)
                            segment_end++;
                        int low_position = segment_start;
                        double low_sum = 0.0;
                        int low_missing = 0;
                        int high_position = segment_start;
                        double high_sum = 0.0;
                        int high_missing = 0;
                        for (int row = segment_start; row < segment_end; row++)
                        {
                            double low = (double)row + start;
                            double high = (double)row + end;
                            bool row_valid = false;
                            double difference = 0.0;
                            if (low >= (double)segment_start && high < (double)segment_end)
                            {
                                int low_target = (int)low;
                                int high_target = (int)high + 1;
                                while (low_position < low_target)
                                {
                                    if (available[low_position] != 0)
                                        low_sum += a[low_position];
                                    else
                                        low_missing++;
                                    low_position++;
                                }
                                while (high_position < high_target)
                                {
                                    if (available[high_position] != 0)
                                        high_sum += a[high_position];
                                    else
                                        high_missing++;
                                    high_position++;
                                }
                                difference = high_sum - low_sum;
                                row_valid = low_missing == high_missing && double.IsFinite(difference);
                            }
                            if (opcode == 44)
                                flags[row] = row_valid ? 1 : 0;
                            else
                                result[row] = row_valid ? difference : fill;
                        }
                        segment_start = segment_end;
                    }
                }
                break;
            }
        }
    }
}
