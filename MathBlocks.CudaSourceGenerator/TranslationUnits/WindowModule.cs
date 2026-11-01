#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

// Trailing-window forms. Opcode 2 * source + sibling, with source the index in the window source list (0 .. 52)
// or a window-accurate source (53 .. 58). Every thread checks the inputs itself and then evaluates its rows: the
// window kernel passes the grid-wide thread index and count, the device dispatch path the thread index in the
// block. Most sources take the rows end = thread, thread + threads, ..., and row end >= width - 1 calls the
// source's per-thread function on rows end - width + 1 .. end of each series. The median, the quantile and the
// window-accurate sources give each thread one block of consecutive rows and slide their state through it.
// Warm-up rows and rows whose result is invalid hold the fill (form) or false (sibling).
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
            case 53:
            case 54:
                return 285;
            case 55:
            case 56:
            case 57:
            case 58:
                return 570;
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

    // The window-accurate.* sources (53 sum, 54 mean, 55 population variance, 56 sample variance, 57 population
    // standard deviation, 58 sample standard deviation) mirror MathBlockExactAccumulator and MathBlockWindowAccurate
    // step for step. An accumulator is 285 longs of the thread's scratch: the chunks 0 .. 140 (chunk i counts units
    // of 2^(-2208 + 32 i)), the read scratch 141 .. 281, then lowest, highest and the count of additions since the
    // last in-place carry. The sum is exact, so its value, and every read, does not depend on the order or history
    // of the additions; a thread can start from any earlier row.
    [CudaDevice]
    private static double mathblocks_window_power_of_two(int exponent)
    {
        return BitConverter.Int64BitsToDouble((long)(exponent + 1023) << 52);
    }

    [CudaDevice]
    private static void mathblocks_window_exact_clear(long* accumulator)
    {
        for (int index = 0; index < 282; index++)
            accumulator[index] = 0L;
        accumulator[282] = 141L;
        accumulator[283] = -1L;
        accumulator[284] = 0L;
    }

    // Adds value * 2^shift to the chunks of target in pieces below 2^33 and returns the lowest chunk index touched.
    [CudaDevice]
    private static int mathblocks_window_exact_add_to(long* target, double value, int shift, bool subtract)
    {
        long bits = BitConverter.DoubleToInt64Bits(value);
        bool negative = (bits < 0L) != subtract;
        int biased = (int)((bits >> 52) & 2047L);
        long significand = bits & 4503599627370495L;
        int exponent;
        if (biased == 0)
        {
            exponent = -1074;
        }
        else
        {
            significand |= 1L << 52;
            exponent = biased - 1075;
        }
        int position = exponent + shift + 2208;
        int index = position >> 5;
        int offset = position & 31;
        long low_part = (significand & 4294967295L) << offset;
        long high_part = (significand >> 32) << offset;
        long first = low_part & 4294967295L;
        long second = (low_part >> 32) + (high_part & 4294967295L);
        long third = high_part >> 32;
        if (negative)
        {
            target[index] -= first;
            target[index + 1] -= second;
            target[index + 2] -= third;
        }
        else
        {
            target[index] += first;
            target[index + 1] += second;
            target[index + 2] += third;
        }
        return index;
    }

    // Carries chunks first .. last into [0, 2^32) and adds the final carry to chunk last + 1, which then holds the
    // sign of the value.
    [CudaDevice]
    private static long mathblocks_window_exact_carry(long* target, int first, int last)
    {
        long carry = 0L;
        for (int index = first; index <= last; index++)
        {
            long current = target[index] + carry;
            carry = current >> 32;
            target[index] = current & 4294967295L;
        }
        target[last + 1] += carry;
        return target[last + 1];
    }

    [CudaDevice]
    private static void mathblocks_window_exact_negate(long* target, int first, int last)
    {
        for (int index = first; index <= last; index++)
            target[index] = -target[index];
    }

    [CudaDevice]
    private static void mathblocks_window_exact_add(long* accumulator, double value, int shift, bool subtract)
    {
        if (value == 0.0)
            return;
        int index = mathblocks_window_exact_add_to(accumulator, value, shift, subtract);
        if (index < accumulator[282])
            accumulator[282] = index;
        if (index + 2 > accumulator[283])
            accumulator[283] = index + 2;
        accumulator[284] += 1L;
        if (accumulator[284] == 134217728L)
        {
            mathblocks_window_exact_carry(accumulator, (int)accumulator[282], (int)accumulator[283]);
            accumulator[283] += 1L;
            accumulator[284] = 0L;
        }
    }

    [CudaDevice]
    private static void mathblocks_window_split(double a, double* high, double* low)
    {
        double c = 134217729.0 * a;
        *high = c - (c - a);
        *low = a - *high;
    }

    // Dekker's product without FMA: p = fl(a b) and p + e = a b exactly, barring overflow and underflow.
    [CudaDevice]
    private static void mathblocks_window_two_product(double a, double b, double* p, double* e)
    {
        *p = a * b;
        double ah = 0.0;
        double al = 0.0;
        double bh = 0.0;
        double bl = 0.0;
        mathblocks_window_split(a, &ah, &al);
        mathblocks_window_split(b, &bh, &bl);
        *e = ((ah * bh - *p) + ah * bl + al * bh) + al * bl;
    }

    // Adds (or subtracts) value^2 exactly as the product pair of value scaled by 2^600 or 2^-600 outside
    // 2^-400 .. 2^400, added back at that scale.
    [CudaDevice]
    private static void mathblocks_window_exact_add_square(long* accumulator, double value, bool subtract)
    {
        if (value == 0.0)
            return;
        double magnitude = Math.Abs(value);
        double scaled = value;
        int shift = 0;
        if (magnitude < mathblocks_window_power_of_two(-400))
        {
            scaled = value * mathblocks_window_power_of_two(600);
            shift = -1200;
        }
        else if (magnitude > mathblocks_window_power_of_two(400))
        {
            scaled = value * mathblocks_window_power_of_two(-600);
            shift = 1200;
        }
        double product = 0.0;
        double error = 0.0;
        mathblocks_window_two_product(scaled, scaled, &product, &error);
        mathblocks_window_exact_add(accumulator, product, shift, subtract);
        mathblocks_window_exact_add(accumulator, error, shift, subtract);
    }

    // Copies the chunks into the read scratch in canonical form with the magnitude of the value and returns top:
    // chunks lowest .. top are in [0, 2^32).
    [CudaDevice]
    private static int mathblocks_window_exact_load(long* accumulator, bool* negative)
    {
        long* scratch = accumulator + 141;
        int lowest = (int)accumulator[282];
        int highest = (int)accumulator[283];
        for (int index = lowest; index <= highest; index++)
            scratch[index] = accumulator[index];
        for (int index = highest + 1; index <= highest + 4; index++)
            scratch[index] = 0L;
        *negative = mathblocks_window_exact_carry(scratch, lowest, highest) < 0L;
        if (*negative)
        {
            mathblocks_window_exact_negate(scratch, lowest, highest + 1);
            mathblocks_window_exact_carry(scratch, lowest, highest + 1);
        }
        return highest + 1;
    }

    // count (1 .. 53) bits of the canonical value starting at the bit with weight 2^position.
    [CudaDevice]
    private static long mathblocks_window_exact_bits([CudaReadOnly] long* value, int position, int count)
    {
        int relative = position + 2208;
        int index = relative >> 5;
        int offset = relative & 31;
        ulong word = (ulong)value[index] | ((ulong)value[index + 1] << 32);
        ulong result = word >> offset;
        if (offset != 0)
            result |= (ulong)value[index + 2] << (64 - offset);
        return (long)(result & ((1UL << count) - 1UL));
    }

    // Whether any bit with weight below 2^position is set.
    [CudaDevice]
    private static bool mathblocks_window_exact_any_below([CudaReadOnly] long* value, int lowest, int position)
    {
        int relative = position + 2208;
        int index = relative >> 5;
        int offset = relative & 31;
        if ((value[index] & ((1L << offset) - 1L)) != 0L)
            return true;
        for (int chunk = lowest; chunk < index; chunk++)
            if (value[chunk] != 0L)
                return true;
        return false;
    }

    // Rounds a nonnegative canonical value (zero above top) to the nearest double, ties to even, with sticky an
    // extra nonzero part below every chunk bit. The result's bits are built directly.
    [CudaDevice]
    private static double mathblocks_window_exact_round([CudaReadOnly] long* value, int lowest, int top, bool sticky)
    {
        int chunk = top;
        while (chunk >= lowest && value[chunk] == 0L)
            chunk--;
        if (chunk < lowest)
            return 0.0;
        int bit = 31;
        while (((value[chunk] >> bit) & 1L) == 0L)
            bit--;
        int most = -2208 + 32 * chunk + bit;
        int least = most - 52 < -1074 ? -1074 : most - 52;
        int count = most - least + 1;
        long significand = count > 0 ? mathblocks_window_exact_bits(value, least, count) : 0L;
        bool round = mathblocks_window_exact_bits(value, least - 1, 1) != 0L;
        bool below = sticky || mathblocks_window_exact_any_below(value, lowest, least - 1);
        if (round && (below || (significand & 1L) != 0L))
            significand++;
        if (significand == 1L << 53)
        {
            significand = 1L << 52;
            least++;
        }
        if (significand >= 1L << 52)
        {
            int biased = least + 1075;
            if (biased >= 2047)
                return BitConverter.Int64BitsToDouble(9218868437227405312L);
            return BitConverter.Int64BitsToDouble(((long)biased << 52) | (significand - (1L << 52)));
        }
        return BitConverter.Int64BitsToDouble(significand);
    }

    // high = RN(S) and low = RN(S - high); an overflow gives an infinite high and a zero low. zero tells whether
    // the exact value is 0, which a high of 0 alone doesn't (S may round to 0).
    [CudaDevice]
    private static void mathblocks_window_exact_read_pair(long* accumulator, double* high, double* low, bool* zero)
    {
        *high = 0.0;
        *low = 0.0;
        *zero = true;
        if (accumulator[283] < 0L)
            return;
        long* scratch = accumulator + 141;
        int lowest = (int)accumulator[282];
        bool negative = false;
        int top = mathblocks_window_exact_load(accumulator, &negative);
        for (int index = lowest; index <= top; index++)
            if (scratch[index] != 0L)
                *zero = false;
        *high = mathblocks_window_exact_round(scratch, lowest, top, false);
        if (!double.IsFinite(*high))
        {
            *high = negative ? -*high : *high;
            return;
        }
        mathblocks_window_exact_add_to(scratch, *high, 0, true);
        bool rest_negative = mathblocks_window_exact_carry(scratch, lowest, top) < 0L;
        if (rest_negative)
        {
            mathblocks_window_exact_negate(scratch, lowest, top + 1);
            mathblocks_window_exact_carry(scratch, lowest, top + 1);
        }
        *low = mathblocks_window_exact_round(scratch, lowest, top + 1, false);
        if (rest_negative)
            *low = -*low;
        if (negative)
        {
            *high = -*high;
            *low = -*low;
        }
    }

    // RN(S / divisor) for an integer divisor >= 1 by long division over the canonical chunks, down to four chunks
    // below the leading one, with a nonzero remainder as the sticky bit; the chunks below lowest that it writes are
    // cleared again.
    [CudaDevice]
    private static double mathblocks_window_exact_read_quotient(long* accumulator, int divisor)
    {
        if (accumulator[283] < 0L)
            return 0.0;
        long* scratch = accumulator + 141;
        int lowest = (int)accumulator[282];
        bool negative = false;
        int top = mathblocks_window_exact_load(accumulator, &negative);
        int leading = top;
        while (leading > lowest && scratch[leading] == 0L)
            leading--;
        int start = leading - 4 < lowest ? leading - 4 : lowest;
        if (start < 0)
            start = 0;
        long remainder = 0L;
        for (int index = top + 1; index >= start; index--)
        {
            long current = (remainder << 32) | scratch[index];
            scratch[index] = current / divisor;
            remainder = current % divisor;
        }
        double result = mathblocks_window_exact_round(scratch, start, top + 1, remainder != 0L);
        for (int index = start; index < lowest; index++)
            scratch[index] = 0L;
        return negative ? -result : result;
    }

    [CudaDevice]
    private static void mathblocks_window_two_sum(double a, double b, double* s, double* e)
    {
        *s = a + b;
        double b_virtual = *s - a;
        double a_virtual = *s - b_virtual;
        *e = (a - a_virtual) + (b - b_virtual);
    }

    [CudaDevice]
    private static void mathblocks_window_fast_two_sum(double a, double b, double* s, double* e)
    {
        *s = a + b;
        *e = b - (*s - a);
    }

    // (h + l)^2: h^2 exactly plus the rounded cross term 2 h l.
    [CudaDevice]
    private static void mathblocks_window_square(double h, double l, double* sh, double* sl)
    {
        double p = 0.0;
        double e = 0.0;
        mathblocks_window_two_product(h, h, &p, &e);
        double low = e + (h + h) * l;
        mathblocks_window_fast_two_sum(p, low, sh, sl);
    }

    // (h + l) / width: the quotient's high part, then the exact remainder h - q width plus l, over width.
    [CudaDevice]
    private static void mathblocks_window_divide_by_integer(double h, double l, int width, double* qh, double* ql)
    {
        double divisor = width;
        double high = h / divisor;
        double p = 0.0;
        double e = 0.0;
        mathblocks_window_two_product(high, divisor, &p, &e);
        double low = ((h - p) - e + l) / divisor;
        mathblocks_window_fast_two_sum(high, low, qh, ql);
    }

    // (ah + al) - (bh + bl) by the accurate double-double addition, rounded once to double.
    [CudaDevice]
    private static double mathblocks_window_subtract_rounded(double ah, double al, double bh, double bl)
    {
        double sh = 0.0;
        double sl = 0.0;
        double th = 0.0;
        double tl = 0.0;
        mathblocks_window_two_sum(ah, -bh, &sh, &sl);
        mathblocks_window_two_sum(al, -bl, &th, &tl);
        double c = sl + th;
        double vh = 0.0;
        double vl = 0.0;
        mathblocks_window_fast_two_sum(sh, c, &vh, &vl);
        double w = tl + vl;
        double zh = 0.0;
        double zl = 0.0;
        mathblocks_window_fast_two_sum(vh, w, &zh, &zl);
        return zh;
    }

    // Whether value is 0 or within [2^-968, largest]; false for an infinity or NaN.
    [CudaDevice]
    private static bool mathblocks_window_in_range(double value, double largest)
    {
        return value == 0.0 ||
            (Math.Abs(value) >= mathblocks_window_power_of_two(-968) && Math.Abs(value) <= largest);
    }

    // The rows first_row .. last_row - 1 of a window-accurate source. The thread first adds the up to width - 1 rows
    // before first_row, then adds x[row] and subtracts x[row - width] per row as the sequential CoreCLR pass does;
    // the change count covers the pairs of adjacent rows inside the window in the same way.
    [CudaDevice]
    private static void mathblocks_window_accurate_rows(
        int source,
        [CudaReadOnly] double* x,
        int width,
        int first_row,
        int last_row,
        double fill,
        bool sibling,
        double* result,
        CudaInt32* boolean_result,
        long* scratch)
    {
        bool variance = source >= 55;
        bool sample = source == 56 || source == 58;
        bool deviation = source >= 57;
        long* first = scratch;
        long* second = scratch + 285;
        mathblocks_window_exact_clear(first);
        if (variance)
            mathblocks_window_exact_clear(second);
        double divisor = sample ? width - 1.0 : width;
        int begin = first_row - width + 1 < 0 ? 0 : first_row - width + 1;
        int changes = 0;
        for (int row = begin; row < last_row; row++)
        {
            mathblocks_window_exact_add(first, x[row], 0, false);
            if (variance)
            {
                mathblocks_window_exact_add_square(second, x[row], false);
                if (row > begin && x[row] != x[row - 1])
                    changes++;
            }
            if (row - width >= begin)
            {
                mathblocks_window_exact_add(first, x[row - width], 0, true);
                if (variance)
                {
                    mathblocks_window_exact_add_square(second, x[row - width], true);
                    if (x[row - width + 1] != x[row - width])
                        changes--;
                }
            }
            if (row < first_row)
                continue;
            bool computed = false;
            double value = 0.0;
            if (row >= width - 1)
            {
                if (!variance)
                {
                    double low = 0.0;
                    bool zero = true;
                    if (source == 54)
                        value = mathblocks_window_exact_read_quotient(first, width);
                    else
                        mathblocks_window_exact_read_pair(first, &value, &low, &zero);
                    computed = double.IsFinite(value);
                }
                else
                {
                    double moment = 0.0;
                    bool in_range = true;
                    if (changes != 0)
                    {
                        double s1h = 0.0;
                        double s1l = 0.0;
                        double s2h = 0.0;
                        double s2l = 0.0;
                        double qh = 0.0;
                        double ql = 0.0;
                        double rh = 0.0;
                        double rl = 0.0;
                        bool s1_zero = true;
                        bool s2_zero = true;
                        mathblocks_window_exact_read_pair(first, &s1h, &s1l, &s1_zero);
                        mathblocks_window_exact_read_pair(second, &s2h, &s2l, &s2_zero);
                        mathblocks_window_square(s1h, s1l, &qh, &ql);
                        mathblocks_window_divide_by_integer(qh, ql, width, &rh, &rl);
                        moment = mathblocks_window_subtract_rounded(s2h, s2l, rh, rl);
                        double largest = BitConverter.Int64BitsToDouble(9218868437227405311L);
                        if (!mathblocks_window_in_range(s2h, largest) ||
                            !mathblocks_window_in_range(qh, largest) ||
                            !mathblocks_window_in_range(rh, mathblocks_window_power_of_two(996)) ||
                            (s2h == 0.0 && !s2_zero) || (qh == 0.0 && s1h != 0.0) ||
                            (moment > 0.0 && moment < mathblocks_window_power_of_two(-968)))
                            in_range = false;
                        else if (moment <= 0.0)
                            moment = 0.0;
                    }
                    value = moment / divisor;
                    if (deviation)
                        value = mathblocks_square_root(value);
                    computed = in_range && double.IsFinite(value);
                }
            }
            if (sibling)
                boolean_result[row] = computed;
            else
                result[row] = computed ? value : fill;
        }
    }

    // The rows first_row .. last_row - 1 of window.vector.median (source 47) and window.vector.quantile (48) from a
    // sorted copy of the window that slides with the rows. The source's stable insertion sort orders the window by
    // (value, index) with -0 equal to +0; a new row has the largest index, so it goes after every value that does
    // not compare greater, and the leaving row has the smallest, so it is the first value that does not compare
    // lower than it. The sorted copy therefore equals the source's sorted window on every row, and the quantile is
    // the source's expression on it.
    [CudaDevice]
    private static void mathblocks_window_sorted_rows(
        [CudaReadOnly] double* x,
        int width,
        double probability,
        int first_row,
        int last_row,
        double fill,
        bool sibling,
        double* result,
        CudaInt32* boolean_result,
        double* sorted)
    {
        bool probability_valid = !(probability < 0.0 || probability > 1.0);
        int begin = first_row - width + 1 < 0 ? 0 : first_row - width + 1;
        int size = 0;
        for (int row = begin; row < last_row; row++)
        {
            if (row - width >= begin)
            {
                double leaving = x[row - width];
                int low = 0;
                int high = size;
                while (low < high)
                {
                    int middle = (low + high) / 2;
                    if (sorted[middle] < leaving)
                        low = middle + 1;
                    else
                        high = middle;
                }
                for (int index = low; index < size - 1; index++)
                    sorted[index] = sorted[index + 1];
                size--;
            }
            double entering = x[row];
            int position = size;
            while (position > 0 && sorted[position - 1] > entering)
            {
                sorted[position] = sorted[position - 1];
                position--;
            }
            sorted[position] = entering;
            size++;
            if (row < first_row)
                continue;
            bool computed = false;
            double value = 0.0;
            if (row >= width - 1 && probability_valid)
            {
                value = mathblocks_statistics_sorted_quantile(sorted, width, probability);
                computed = double.IsFinite(value);
            }
            if (sibling)
                boolean_result[row] = computed;
            else
                result[row] = computed ? value : fill;
        }
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
        bool valid = opcode >= 0 && source < 59 && input_count == arity + (sibling ? 1 : 2);
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
        if (source == 47 || source == 48 || source >= 53)
        {
            // These sources slide a state over consecutive rows, so each thread owns one block of rows.
            long rows_per_thread = ((long)count + threads - 1) / threads;
            long first_row = thread * rows_per_thread;
            if (first_row >= count)
                return;
            long last_row = count - first_row < rows_per_thread ? count : first_row + rows_per_thread;
            if (source >= 53)
            {
                mathblocks_window_accurate_rows(
                    source,
                    a,
                    width,
                    (int)first_row,
                    (int)last_row,
                    fill,
                    sibling,
                    result,
                    boolean_result,
                    (long*)scratch);
            }
            else
            {
                mathblocks_window_sorted_rows(
                    a,
                    width,
                    source == 47 ? 0.5 : first_parameter->scalar_value,
                    (int)first_row,
                    (int)last_row,
                    fill,
                    sibling,
                    result,
                    boolean_result,
                    scratch);
            }
            return;
        }
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
