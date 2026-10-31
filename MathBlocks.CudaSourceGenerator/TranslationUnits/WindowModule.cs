#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

// Trailing-window forms. Opcode 2 * source + sibling, with source the index in the window source list. Every
// thread checks the inputs itself and then evaluates the rows end = thread, thread + threads, ...: the window
// kernel passes the grid-wide thread index and count, the device dispatch path the thread index in the block.
// Row end >= width - 1 calls the source's per-thread function on rows end - width + 1 .. end of each series;
// warm-up rows and rows whose source result is invalid hold the fill (form) or false (sibling).
[TranspileToCUDA]
internal static unsafe class WindowModule
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
    private static double mathblocks_compensated_absolute_sum([CudaReadOnly] double* values, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_compensated_product_sum([CudaReadOnly] double* first, [CudaReadOnly] double* second, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_compensated_sum([CudaReadOnly] double* values, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_maximum(double first, double second) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_minimum(double first, double second) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_natural_logarithm(double value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_square_root(double value) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_sequence_positive_integer(double value, int* result) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_statistics_mean([CudaReadOnly] double* values, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_statistics_population_variance([CudaReadOnly] double* values, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_statistics_population_covariance([CudaReadOnly] double* left, [CudaReadOnly] double* right, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_statistics_pearson([CudaReadOnly] double* left, [CudaReadOnly] double* right, int count) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_statistics_sort_copy([CudaReadOnly] double* values, int count, double* result) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_statistics_sorted_quantile([CudaReadOnly] double* sorted, int count, double probability) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_statistics_rank([CudaReadOnly] double* values, int count, double* result) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_statistics_moment_value([CudaReadOnly] double* values, int count, double order_value, bool central, double* value) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_statistics_kendall_value([CudaReadOnly] double* left_values, [CudaReadOnly] double* right_values, int count, double* value) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_statistics_shape_moment_value([CudaReadOnly] double* values, int count, bool kurtosis, double* value) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_statistics_weighted_value([CudaReadOnly] double* values, [CudaReadOnly] double* weights, int count, bool variance, double* value) => throw new NotSupportedException();

    [CudaExternal]
    private static int mathblocks_statistics_pair_averages([CudaReadOnly] double* values, int count, double* averages) => throw new NotSupportedException();

    [CudaExternal]
    private static int mathblocks_statistics_pair_slopes([CudaReadOnly] double* x, [CudaReadOnly] double* y, int count, double* slopes) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_sequence_first_passage_value([CudaReadOnly] double* values, int count, double threshold, bool at_or_above) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_sequence_longest_run_value([CudaReadOnly] CudaInt32* values, int count) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_sequence_decline_value([CudaReadOnly] double* values, int count, bool relative, double* value) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_sequence_variation_value([CudaReadOnly] double* values, int count, double order, bool absolute, double* value) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_sequence_recurrence_value([CudaReadOnly] double* values, int count, double threshold, double* value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_sequence_sign_change_value([CudaReadOnly] double* values, int count, bool differenced) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static bool mathblocks_probability_distribution([CudaReadOnly] double* values, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_probability_entropy([CudaReadOnly] double* values, int count) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_probability_ordered_entropy_value([CudaReadOnly] double* values, int count, double order, bool renyi, double* value) => throw new NotSupportedException();

    [CudaExternal]
    private static double mathblocks_quantile_values([CudaReadOnly] double* values, int count, double* sorted, double probability) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_vector_geometric_mean_value([CudaReadOnly] double* values, int count, double* logarithms, double* value) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_vector_arg_extreme_value([CudaReadOnly] double* values, int count, bool maximum, double* value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_vector_rank_at([CudaReadOnly] double* values, int count, int position) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_vector_standardize_moments([CudaReadOnly] double* values, int count, double* mean, double* deviation) => throw new NotSupportedException();

    // Source inputs: the series first, then the scalar parameters.
    [CudaDevice]
    private static int mathblocks_window_source_arity(int source)
    {
        switch (source)
        {
            case 34:
                return 3;
            case 0:
            case 1:
            case 2:
            case 4:
            case 5:
            case 6:
            case 7:
            case 9:
            case 10:
            case 16:
            case 18:
            case 21:
            case 22:
            case 23:
            case 24:
            case 28:
            case 30:
            case 36:
            case 37:
            case 48:
                return 2;
            default:
                return 1;
        }
    }

    [CudaDevice]
    private static int mathblocks_window_series_count(int source)
    {
        switch (source)
        {
            case 2:
            case 4:
            case 5:
            case 6:
            case 7:
            case 9:
            case 10:
            case 18:
            case 21:
            case 22:
            case 23:
            case 24:
                return 2;
            default:
                return 1;
        }
    }

    // Scratch doubles one thread needs for one window of the given width. The host plan sizes each thread's
    // slice with the same table.
    [CudaDevice]
    private static long mathblocks_window_scratch_count(int source, int width)
    {
        long count = width;
        switch (source)
        {
            case 3:
            case 44:
            case 47:
            case 48:
                return count;
            case 2:
            case 8:
            case 21:
                return count * 2;
            case 22:
                return count * (count - 1);
            case 15:
                return count * (count + 1);
            default:
                return 0;
        }
    }

    // Stable bottom-up merge sort of count values, alternating between values and buffer. Returns the array that
    // holds the sorted values. Equal values, -0.0 and +0.0 among them, keep their input order, so the result is
    // the array the source's stable sort produces.
    [CudaDevice]
    private static double* mathblocks_window_merge_sort(double* values, double* buffer, int count)
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
                    target[position++] = source[right] < source[left] ? source[right++] : source[left++];
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

    // Row means of the count x count distance matrix |values[row] - values[column]| and its total mean, summed in
    // the row-major order of mathblocks_statistics_center_distance.
    [CudaDevice]
    private static double mathblocks_window_distance_row_means(
        [CudaReadOnly] double* values,
        int count,
        double* row_means)
    {
        double total_mean = 0.0;
        for (int row = 0; row < count; row++)
        {
            row_means[row] = 0.0;
            for (int column = 0; column < count; column++)
            {
                double distance = Math.Abs(values[row] - values[column]);
                row_means[row] += distance;
                total_mean += distance;
            }
            row_means[row] /= count;
        }
        total_mean /= count * count;
        return total_mean;
    }

    // Distance correlation with 2 * count doubles of scratch. Each centred entry
    // |x[row] - x[column]| - (rowMean[row] + rowMean[column] - totalMean) is recomputed from the same operands
    // with the same operations as the source's centred matrix, and the three sums run in its row-major order.
    [CudaDevice]
    private static bool mathblocks_window_distance_correlation(
        [CudaReadOnly] double* left_values,
        [CudaReadOnly] double* right_values,
        int count,
        double* row_means,
        double* value)
    {
        if (count <= 0)
            return false;
        double* left_means = row_means;
        double* right_means = row_means + count;
        double left_total = mathblocks_window_distance_row_means(left_values, count, left_means);
        double right_total = mathblocks_window_distance_row_means(right_values, count, right_means);
        double covariance_square = 0.0;
        double left_variance_square = 0.0;
        double right_variance_square = 0.0;
        for (int row = 0; row < count; row++)
        {
            for (int column = 0; column < count; column++)
            {
                double left = Math.Abs(left_values[row] - left_values[column]) -
                    (left_means[row] + left_means[column] - left_total);
                double right = Math.Abs(right_values[row] - right_values[column]) -
                    (right_means[row] + right_means[column] - right_total);
                covariance_square += left * right;
                left_variance_square += left * left;
                right_variance_square += right * right;
            }
        }
        covariance_square /= count * count;
        left_variance_square /= count * count;
        right_variance_square /= count * count;
        *value = mathblocks_square_root(
            covariance_square /
            mathblocks_square_root(left_variance_square * right_variance_square));
        return double.IsFinite(*value);
    }

    // The source's median of the first count scratch values, sorted with the merge sort into the buffer after them.
    [CudaDevice]
    private static double mathblocks_window_scratch_median(double* scratch, int count)
    {
        double* sorted = mathblocks_window_merge_sort(scratch, scratch + count, count);
        return mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
    }

    // vector.standardize on the window, taken at its last position. The window is invalid when any standardized
    // value is not finite, as for the source.
    [CudaDevice]
    private static bool mathblocks_window_standardize_last(
        [CudaReadOnly] double* values,
        int count,
        double* value)
    {
        if (count <= 0)
            return false;
        double mean = 0.0;
        double deviation = 0.0;
        mathblocks_vector_standardize_moments(values, count, &mean, &deviation);
        for (int index = 0; index < count; index++)
            if (!double.IsFinite((values[index] - mean) / deviation))
                return false;
        *value = (values[count - 1] - mean) / deviation;
        return true;
    }

    // Evaluates the source on one window of count rows: a and b are the series windows (b is null for a single
    // series), flags is the Boolean series window of path.longest-true-run, and the parameters are the source's
    // scalar inputs. The validity rules are those of the source's dispatcher case. Returns whether the result is
    // valid; value holds the result.
    [CudaDevice]
    private static bool mathblocks_window_value(
        int source,
        [CudaReadOnly] double* a,
        [CudaReadOnly] double* b,
        [CudaReadOnly] CudaInt32* flags,
        int count,
        [CudaReadOnly] MathBlockSlot* first_parameter,
        [CudaReadOnly] MathBlockSlot* second_parameter,
        double* scratch,
        double* value)
    {
        switch (source)
        {
            case 0:
            {
                int lag = 0;
                if (!mathblocks_sequence_positive_integer(first_parameter->scalar_value, &lag) || lag >= count)
                    return false;
                *value = mathblocks_statistics_pearson(a, a + lag, count - lag);
                break;
            }
            case 1:
            case 16:
                return mathblocks_statistics_moment_value(a, count, first_parameter->scalar_value, source == 1, value);
            case 2:
                return mathblocks_window_distance_correlation(a, b, count, scratch, value);
            case 3:
                if (count <= 0 || scratch == null)
                    return false;
                mathblocks_statistics_sort_copy(a, count, scratch);
                *value =
                    mathblocks_statistics_sorted_quantile(scratch, count, 0.75) -
                    mathblocks_statistics_sorted_quantile(scratch, count, 0.25);
                break;
            case 4:
                return mathblocks_statistics_kendall_value(a, b, count, value);
            case 5:
            case 6:
            case 7:
            case 9:
            case 10:
            case 18:
            {
                if (count <= 0)
                    return false;
                double covariance = mathblocks_statistics_population_covariance(a, b, count);
                if (source == 10 || source == 18)
                {
                    *value = source == 10
                        ? covariance
                        : covariance * count / (count - 1.0);
                }
                else if (source == 7)
                {
                    *value = covariance /
                        mathblocks_statistics_population_variance(a, count);
                }
                else if (source == 5)
                {
                    double slope = covariance /
                        mathblocks_statistics_population_variance(a, count);
                    *value = mathblocks_statistics_mean(b, count) -
                        slope * mathblocks_statistics_mean(a, count);
                }
                else
                {
                    double correlation = covariance /
                        (mathblocks_square_root(mathblocks_statistics_population_variance(a, count)) *
                         mathblocks_square_root(mathblocks_statistics_population_variance(b, count)));
                    *value = source == 6 ? correlation * correlation : correlation;
                }
                break;
            }
            case 8:
            {
                if (count <= 0 || scratch == null)
                    return false;
                double* sorted = scratch;
                double* deviations = scratch + count;
                mathblocks_statistics_sort_copy(a, count, sorted);
                double median = mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
                for (int index = 0; index < count; index++)
                    deviations[index] = Math.Abs(a[index] - median);
                mathblocks_statistics_sort_copy(deviations, count, sorted);
                *value = mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
                break;
            }
            case 11:
            case 12:
                return mathblocks_statistics_shape_moment_value(a, count, source == 11, value);
            case 13:
            case 14:
            case 19:
            case 20:
            {
                if (count <= 0)
                    return false;
                double variance = mathblocks_statistics_population_variance(a, count);
                if (source == 19 || source == 20)
                    variance = variance * count / (count - 1.0);
                *value = source == 13 || source == 19
                    ? mathblocks_square_root(variance)
                    : variance;
                break;
            }
            case 15:
            {
                if (count <= 0 || scratch == null)
                    return false;
                int average_count = mathblocks_statistics_pair_averages(a, count, scratch);
                *value = mathblocks_window_scratch_median(scratch, average_count);
                break;
            }
            case 17:
                *value = mathblocks_square_root(
                    mathblocks_compensated_product_sum(a, a, count) / count);
                break;
            case 21:
            {
                if (count <= 0 || scratch == null)
                    return false;
                double* left_ranks = scratch;
                double* right_ranks = scratch + count;
                mathblocks_statistics_rank(a, count, left_ranks);
                mathblocks_statistics_rank(b, count, right_ranks);
                *value = mathblocks_statistics_pearson(left_ranks, right_ranks, count);
                break;
            }
            case 22:
            {
                int slope_count = mathblocks_statistics_pair_slopes(a, b, count, scratch);
                if (slope_count == 0)
                    return false;
                *value = mathblocks_window_scratch_median(scratch, slope_count);
                break;
            }
            case 23:
            case 24:
                return mathblocks_statistics_weighted_value(a, b, count, source == 24, value);
            case 25:
                *value = mathblocks_sequence_longest_run_value(flags, count);
                return true;
            case 26:
            case 27:
                return mathblocks_sequence_decline_value(a, count, source == 27, value);
            case 28:
                return mathblocks_sequence_variation_value(a, count, first_parameter->scalar_value, false, value);
            case 29:
                return mathblocks_sequence_variation_value(a, count, 2.0, false, value);
            case 30:
                return mathblocks_sequence_recurrence_value(a, count, first_parameter->scalar_value, value);
            case 31:
                return mathblocks_sequence_variation_value(a, count, 1.0, true, value);
            case 32:
            case 33:
                *value = mathblocks_sequence_sign_change_value(a, count, source == 32);
                return true;
            case 34:
                *value = mathblocks_sequence_first_passage_value(
                    a,
                    count,
                    first_parameter->scalar_value,
                    second_parameter->boolean_value != 0);
                return true;
            case 35:
            case 36:
            case 37:
            case 38:
            case 39:
                if (!mathblocks_probability_distribution(a, count))
                    return false;
                if (source == 35)
                {
                    *value = mathblocks_probability_entropy(a, count);
                }
                else if (source == 39)
                {
                    *value = mathblocks_probability_entropy(a, count) /
                        mathblocks_natural_logarithm(2.0);
                }
                else if (source == 38)
                {
                    *value = 1.0 - mathblocks_compensated_product_sum(a, a, count);
                }
                else if (!mathblocks_probability_ordered_entropy_value(
                             a,
                             count,
                             first_parameter->scalar_value,
                             source == 36,
                             value))
                {
                    return false;
                }
                break;
            case 40:
            case 41:
            {
                double sum = mathblocks_compensated_sum(a, count);
                *value = source == 41 ? sum / count : sum;
                break;
            }
            case 42:
            case 43:
            {
                if (count <= 0)
                    return false;
                double selected = a[0];
                for (int index = 1; index < count; index++)
                    selected = source == 43
                        ? mathblocks_maximum(selected, a[index])
                        : mathblocks_minimum(selected, a[index]);
                *value = selected;
                return true;
            }
            case 44:
                return mathblocks_vector_geometric_mean_value(a, count, scratch, value);
            case 45:
                *value = mathblocks_compensated_absolute_sum(a, count);
                break;
            case 46:
                *value = mathblocks_square_root(mathblocks_compensated_product_sum(a, a, count));
                break;
            case 47:
            case 48:
            {
                double probability = source == 47 ? 0.5 : first_parameter->scalar_value;
                if (count <= 0 || scratch == null || probability < 0.0 || probability > 1.0)
                    return false;
                *value = mathblocks_quantile_values(a, count, scratch, probability);
                break;
            }
            case 49:
            case 50:
                return mathblocks_vector_arg_extreme_value(a, count, source == 49, value);
            case 51:
                *value = mathblocks_vector_rank_at(a, count, count - 1);
                return true;
            case 52:
                return mathblocks_window_standardize_last(a, count, value);
            default:
                return false;
        }
        return double.IsFinite(*value);
    }

    // Thread 0 writes the output header; the other threads only write rows.
    [CudaDevice]
    private static void mathblocks_window_publish(MathBlockSlot* output, bool valid, int count, int thread)
    {
        if (thread != 0)
            return;
        output->scalar_value = 0.0;
        output->boolean_value = 0;
        output->columns = 0;
        output->rows = valid ? count : 0;
        output->count = valid ? count : 0;
        output->valid = valid;
    }

    // thread is this thread's index among the threads that evaluate rows; scratch_capacity is the planned
    // scratch doubles per thread, and a negative capacity (the device dispatch path) takes the run-time
    // requirement of the width.
    [CudaDevice]
    private static void mathblocks_window_run(
        int opcode,
        MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output,
        int thread,
        int threads,
        int scratch_capacity)
    {
        int source = opcode / 2;
        bool sibling = opcode % 2 != 0;
        int arity = mathblocks_window_source_arity(source);
        int series = mathblocks_window_series_count(source);
        bool valid = opcode >= 0 && source < 53 && input_count == arity + (sibling ? 1 : 2);
        for (int index = 0; valid && index < input_count; index++)
            if (inputs[index] == null || !inputs[index]->valid)
                valid = false;
        if (!valid)
        {
            mathblocks_window_publish(output, false, 0, thread);
            return;
        }

        MathBlockSlot* first = Cuda.ReadOnly(input_count > 0 ? inputs[0] : null);
        MathBlockSlot* second = Cuda.ReadOnly(series > 1 ? inputs[1] : null);
        MathBlockSlot* first_parameter = Cuda.ReadOnly(arity > series ? inputs[series] : null);
        MathBlockSlot* second_parameter = Cuda.ReadOnly(arity > series + 1 ? inputs[series + 1] : null);
        MathBlockSlot* width_input = Cuda.ReadOnly(inputs[arity]);
        MathBlockSlot* fill_input = Cuda.ReadOnly(sibling ? null : inputs[arity + 1]);
        int count = first->count;
        int width = 0;
        if (second != null && second->count != count)
            valid = false;
        if (!mathblocks_sequence_positive_integer(width_input->scalar_value, &width) || width > count)
            valid = false;
        if (count > output->capacity)
            valid = false;
        long required = valid ? mathblocks_window_scratch_count(source, width) : 0;
        long capacity = scratch_capacity < 0 ? required : scratch_capacity;
        if (required > capacity || (required > 0 && output->scratch_pointer == 0))
            valid = false;
        mathblocks_window_publish(output, valid, count, thread);
        if (!valid)
            return;

        double fill = sibling ? 0.0 : fill_input->scalar_value;
        double* a = Cuda.ReadOnly((double*)first->data_pointer);
        CudaInt32* flags = Cuda.ReadOnly((CudaInt32*)first->data_pointer);
        double* b = Cuda.ReadOnly(second == null ? null : (double*)second->data_pointer);
        double* result = (double*)output->data_pointer;
        CudaInt32* boolean_result = (CudaInt32*)output->data_pointer;
        double* scratch = (double*)output->scratch_pointer + thread * (int)capacity;
        for (int end = thread; end < count; end += threads)
        {
            bool row_valid = false;
            double value = 0.0;
            if (end >= width - 1)
            {
                // b is only read for paired sources, whose second series is never null.
                int start = end - width + 1;
                row_valid = mathblocks_window_value(
                    source,
                    a + start,
                    b + start,
                    flags + start,
                    width,
                    first_parameter,
                    second_parameter,
                    scratch,
                    &value);
            }
            if (sibling)
                boolean_result[end] = row_valid;
            else
                result[end] = row_valid ? value : fill;
        }
    }

    [CudaDevice(Name = "mathblocks_window_dispatch")]
    private static void mathblocks_window(
        int opcode,
        MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        mathblocks_window_run(
            opcode,
            inputs,
            input_count,
            output,
            (int)Cuda.ThreadIdx.X,
            (int)Cuda.BlockDim.X,
            -1);
    }
}
