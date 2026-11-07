#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

[TranspileToCUDA]
internal static unsafe class StatisticsModule
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
    private static double mathblocks_compensated_product_sum([CudaReadOnly] double* first, [CudaReadOnly] double* second, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_compensated_sum([CudaReadOnly] double* values, int count) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_nonnegative_integer(double value, int* result) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_power(double value, double exponent) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_sequence_positive_integer(double value, int* result) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_sequence_set_matrix_shape(MathBlockSlot* output, int rows, int columns) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_sequence_set_vector_shape(MathBlockSlot* output, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_square_root(double value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static double mathblocks_quiet_nan() => throw new NotSupportedException();
    [CudaDevice]
    private static double mathblocks_statistics_mean([CudaReadOnly] double* values, int count)
    {
        return mathblocks_compensated_sum(values, count) / count;
    }

    [CudaDevice]
    private static double mathblocks_statistics_population_variance(
        [CudaReadOnly] double* values,
        int count)
    {
        double mean = mathblocks_statistics_mean(values, count);
        double sum = 0.0;
        for (int index = 0; index < count; index++)
        {
            double difference = values[index] - mean;
            sum += difference * difference;
        }
        return sum / count;
    }

    [CudaDevice]
    private static double mathblocks_statistics_population_covariance(
        [CudaReadOnly] double* left,
        [CudaReadOnly] double* right,
        int count)
    {
        double left_mean = mathblocks_statistics_mean(left, count);
        double right_mean = mathblocks_statistics_mean(right, count);
        double sum = 0.0;
        for (int index = 0; index < count; index++)
            sum += (left[index] - left_mean) * (right[index] - right_mean);
        return sum / count;
    }

    // covariance / variance, or NaN (invalid) when the variance overflowed: dividing by an infinity would give a finite zero.
    [CudaDevice]
    private static double mathblocks_statistics_quotient_by_variance(double covariance, double variance)
    {
        if (!double.IsFinite(variance))
            return mathblocks_quiet_nan();
        return covariance / variance;
    }

    // covariance / (sd(left) * sd(right)), or NaN (invalid) when a variance or the product of the two standard deviations overflowed.
    [CudaDevice]
    private static double mathblocks_statistics_correlation_value(double covariance, double left_variance, double right_variance)
    {
        if (!double.IsFinite(left_variance) || !double.IsFinite(right_variance))
            return mathblocks_quiet_nan();
        double denominator = mathblocks_square_root(left_variance) * mathblocks_square_root(right_variance);
        if (!double.IsFinite(denominator))
            return mathblocks_quiet_nan();
        return covariance / denominator;
    }

    // The distance correlation from the three moments, or NaN (invalid) when a moment or the product of the two variances overflowed.
    [CudaDevice]
    private static double mathblocks_statistics_distance_correlation_value(
        double covariance_square,
        double left_variance_square,
        double right_variance_square)
    {
        double denominator = mathblocks_square_root(left_variance_square * right_variance_square);
        if (!double.IsFinite(covariance_square) || !double.IsFinite(left_variance_square) ||
            !double.IsFinite(right_variance_square) || !double.IsFinite(denominator))
            return mathblocks_quiet_nan();
        return mathblocks_square_root(covariance_square / denominator);
    }

    [CudaDevice]
    private static double mathblocks_statistics_pearson(
        [CudaReadOnly] double* left,
        [CudaReadOnly] double* right,
        int count)
    {
        return mathblocks_statistics_correlation_value(
            mathblocks_statistics_population_covariance(left, right, count),
            mathblocks_statistics_population_variance(left, count),
            mathblocks_statistics_population_variance(right, count));
    }

    [CudaExternal]
    private static double* mathblocks_stable_merge_sort(double* values, double* buffer, int count, bool descending) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_stable_sort_into([CudaReadOnly] double* values, int count, double* result, double* buffer, bool descending) => throw new NotSupportedException();

    // The same with the buffer in the count doubles after result: result needs 2 * count doubles.
    [CudaDevice]
    private static void mathblocks_statistics_sort_copy(
        [CudaReadOnly] double* values,
        int count,
        double* result,
        bool descending)
    {
        mathblocks_stable_sort_into(values, count, result, result + count, descending);
    }

    [CudaDevice]
    private static double mathblocks_statistics_sorted_quantile(
        [CudaReadOnly] double* sorted,
        int count,
        double probability)
    {
        if (count == 1)
            return sorted[0];
        double position = probability * (count - 1);
        int lower = (int)Math.Floor(position);
        int upper = (int)Math.Ceiling(position);
        double weight = position - lower;
        return sorted[lower] * (1.0 - weight) + sorted[upper] * weight;
    }

    [CudaDevice]
    private static double mathblocks_statistics_median(double* values, int count)
    {
        double* sorted = mathblocks_stable_merge_sort(values, values + count, count, false);
        return mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
    }

    // The average rank of values[index]: the values below it plus half of the equal ones (itself included) plus a half.
    // Both counts are exact integers; a NaN value counts nothing, so its rank is 0.5.
    [CudaDevice]
    private static double mathblocks_statistics_rank_at(
        [CudaReadOnly] double* values,
        int count,
        int index)
    {
        int lower = 0;
        int equal = 0;
        for (int candidate = 0; candidate < count; candidate++)
        {
            if (values[candidate] < values[index])
                lower++;
            else if (values[candidate] == values[index])
                equal++;
        }
        return lower + (equal + 1.0) / 2.0;
    }

    [CudaDevice]
    private static void mathblocks_statistics_rank(
        [CudaReadOnly] double* values,
        int count,
        double* result)
    {
        for (int index = 0; index < count; index++)
            result[index] = mathblocks_statistics_rank_at(values, count, index);
    }

    [CudaDevice]
    private static void mathblocks_statistics_center_distance(
        [CudaReadOnly] double* values,
        int count,
        double* result,
        double* row_means)
    {
        double total_mean = 0.0;
        for (int row = 0; row < count; row++)
        {
            row_means[row] = 0.0;
            for (int column = 0; column < count; column++)
            {
                double distance = Math.Abs(values[row] - values[column]);
                result[row * count + column] = distance;
                row_means[row] += distance;
                total_mean += distance;
            }
            row_means[row] /= count;
        }
        total_mean /= count * count;
        for (int row = 0; row < count; row++)
            for (int column = 0; column < count; column++)
                result[row * count + column] -=
                    row_means[row] + row_means[column] - total_mean;
    }

    [CudaDevice]
    private static bool mathblocks_statistics_moment_value(
        [CudaReadOnly] double* values,
        int count,
        double order_value,
        bool central,
        double* value)
    {
        int order = 0;
        if (count <= 0 ||
            !mathblocks_nonnegative_integer(order_value, &order))
            return false;
        double mean = central ? mathblocks_statistics_mean(values, count) : 0.0;
        double sum = 0.0;
        for (int index = 0; index < count; index++)
            sum += mathblocks_power(values[index] - mean, (double)order);
        *value = sum / count;
        return double.IsFinite(*value);
    }

    [CudaDevice]
    private static bool mathblocks_statistics_kendall_value(
        [CudaReadOnly] double* left_values,
        [CudaReadOnly] double* right_values,
        int count,
        double* value)
    {
        long concordant = 0;
        long discordant = 0;
        long left_ties = 0;
        long right_ties = 0;
        for (int left = 0; left < count; left++)
        {
            for (int right = left + 1; right < count; right++)
            {
                double left_difference = left_values[left] - left_values[right];
                double right_difference = right_values[left] - right_values[right];
                int left_sign = left_difference > 0.0 ? 1 : left_difference < 0.0 ? -1 : 0;
                int right_sign = right_difference > 0.0 ? 1 : right_difference < 0.0 ? -1 : 0;
                if (left_sign == 0 && right_sign == 0)
                    continue;
                if (left_sign == 0)
                    left_ties++;
                else if (right_sign == 0)
                    right_ties++;
                else if (left_sign == right_sign)
                    concordant++;
                else
                    discordant++;
            }
        }
        *value = (double)(concordant - discordant) /
            mathblocks_square_root(
                (double)(concordant + discordant + left_ties) *
                (concordant + discordant + right_ties));
        return double.IsFinite(*value);
    }

    [CudaDevice]
    private static bool mathblocks_statistics_shape_moment_value(
        [CudaReadOnly] double* values,
        int count,
        bool kurtosis,
        double* value)
    {
        if (count <= 0)
            return false;
        double mean = mathblocks_statistics_mean(values, count);
        double second_moment = 0.0;
        double higher_moment = 0.0;
        for (int index = 0; index < count; index++)
        {
            double difference = values[index] - mean;
            double square = difference * difference;
            second_moment += square;
            higher_moment += kurtosis ? square * square : square * difference;
        }
        second_moment /= count;
        higher_moment /= count;
        *value = kurtosis
            ? higher_moment / (second_moment * second_moment) - 3.0
            : higher_moment / mathblocks_power(second_moment, 1.5);
        return double.IsFinite(*value);
    }

    [CudaDevice]
    private static bool mathblocks_statistics_weighted_value(
        [CudaReadOnly] double* values,
        [CudaReadOnly] double* weights,
        int count,
        bool variance,
        double* value)
    {
        if (count <= 0)
            return false;
        double weight_sum = mathblocks_compensated_sum(weights, count);
        double mean = mathblocks_compensated_product_sum(values, weights, count) / weight_sum;
        if (!variance)
        {
            *value = mean;
        }
        else
        {
            double numerator = 0.0;
            for (int index = 0; index < count; index++)
            {
                double difference = values[index] - mean;
                numerator += weights[index] * difference * difference;
            }
            *value = numerator / weight_sum;
        }
        return double.IsFinite(*value);
    }

    // Writes the pair averages (values[left] + values[right]) / 2 for left <= right in row order and returns
    // their count.
    [CudaDevice]
    private static int mathblocks_statistics_pair_averages(
        [CudaReadOnly] double* values,
        int count,
        double* averages)
    {
        int average_count = 0;
        for (int left = 0; left < count; left++)
            for (int right = left; right < count; right++)
                averages[average_count++] = (values[left] + values[right]) / 2.0;
        return average_count;
    }

    // Writes the pair slopes of the Theil-Sen estimator for left < right with distinct x in row order and
    // returns their count, or -1 when a difference, rise or slope overflows.
    [CudaDevice]
    private static int mathblocks_statistics_pair_slopes(
        [CudaReadOnly] double* x,
        [CudaReadOnly] double* y,
        int count,
        double* slopes)
    {
        int slope_count = 0;
        for (int left = 0; left < count; left++)
        {
            for (int right = left + 1; right < count; right++)
            {
                double difference = x[right] - x[left];
                // An overflowing difference, rise or slope would divide by an infinity or put an infinity in the median: -1.
                if (!double.IsFinite(difference))
                    return -1;
                if (difference != 0.0)
                {
                    double rise = y[right] - y[left];
                    double slope = rise / difference;
                    if (!double.IsFinite(rise) || !double.IsFinite(slope))
                        return -1;
                    slopes[slope_count++] = slope;
                }
            }
        }
        return slope_count;
    }

    [CudaDevice(Name = "mathblocks_statistics_dispatch")]
    private static void mathblocks_statistics(
        int opcode,
        MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        int thread = (int)Cuda.ThreadIdx.X;
        MathBlockSlot* first = Cuda.ReadOnly(input_count > 0 ? inputs[0] : null);
        MathBlockSlot* second = Cuda.ReadOnly(input_count > 1 ? inputs[1] : null);
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
        }
        Cuda.SyncThreads();
        if (!output->valid)
            return;

        double* a = Cuda.ReadOnly(first == null ? null : (double*)first->data_pointer);
        double* b = Cuda.ReadOnly(second == null ? null : (double*)second->data_pointer);
        double* result = (double*)output->data_pointer;
        double* scratch = (double*)output->scratch_pointer;

        // Spearman: the threads of the block count the ranks by index; each rank is an exact integer count, so the
        // values are those of one thread counting them all. The condition is the one of the case below.
        if (opcode == 23 && first->count > 0 && first->count == second->count && scratch != null)
        {
            for (int index = thread; index < first->count; index += Cuda.BlockDim.X)
            {
                scratch[index] = mathblocks_statistics_rank_at(a, first->count, index);
                scratch[first->count + index] = mathblocks_statistics_rank_at(b, first->count, index);
            }
            Cuda.SyncThreads();
        }

        if (thread == 0)
        {
            switch (opcode)
            {
                case 0:
                {
                    int lag = 0;
                    if (!mathblocks_sequence_positive_integer(second->scalar_value, &lag) || lag >= first->count)
                    {
                        output->valid = 0;
                        break;
                    }
                    int count = first->count - lag;
                    output->scalar_value = mathblocks_statistics_pearson(a, a + lag, count);
                    break;
                }
                case 1:
                case 18:
                    if (!mathblocks_statistics_moment_value(
                            a,
                            first->count,
                            second->scalar_value,
                            opcode == 1,
                            &output->scalar_value))
                        output->valid = 0;
                    break;
                case 2:
                {
                    int rows = first->rows;
                    int columns = first->columns;
                    mathblocks_sequence_set_matrix_shape(output, columns, columns);
                    if (rows <= 0 || columns <= 0 || scratch == null)
                    {
                        output->valid = 0;
                        break;
                    }
                    for (int column = 0; column < columns; column++)
                    {
                        scratch[column] = 0.0;
                        for (int row = 0; row < rows; row++)
                            scratch[column] += a[row * columns + column] / rows;
                    }
                    for (int left = 0; left < columns; left++)
                    {
                        for (int right = left; right < columns; right++)
                        {
                            double sum = 0.0;
                            for (int row = 0; row < rows; row++)
                            {
                                sum += (a[row * columns + left] - scratch[left]) *
                                       (a[row * columns + right] - scratch[right]);
                            }
                            double covariance = sum / rows;
                            result[left * columns + right] = covariance;
                            result[right * columns + left] = covariance;
                            if (!double.IsFinite(covariance)) output->valid = 0;
                        }
                    }
                    break;
                }
                case 3:
                {
                    int count = first->count;
                    if (count <= 0 || count != second->count || scratch == null)
                    {
                        output->valid = 0;
                        break;
                    }
                    double* left_distances = scratch;
                    double* right_distances = scratch + count * count;
                    double* row_means = right_distances + count * count;
                    mathblocks_statistics_center_distance(a, count, left_distances, row_means);
                    mathblocks_statistics_center_distance(b, count, right_distances, row_means);
                    double covariance_square = 0.0;
                    double left_variance_square = 0.0;
                    double right_variance_square = 0.0;
                    for (int index = 0; index < count * count; index++)
                    {
                        covariance_square += left_distances[index] * right_distances[index];
                        left_variance_square += left_distances[index] * left_distances[index];
                        right_variance_square += right_distances[index] * right_distances[index];
                    }
                    covariance_square /= count * count;
                    left_variance_square /= count * count;
                    right_variance_square /= count * count;
                    output->scalar_value = mathblocks_statistics_distance_correlation_value(
                        covariance_square, left_variance_square, right_variance_square);
                    break;
                }
                case 4:
                {
                    mathblocks_sequence_set_vector_shape(output, second->count + 1);
                    for (int index = 1; index < second->count; index++)
                    {
                        if (b[index] <= b[index - 1])
                        {
                            output->valid = 0;
                            break;
                        }
                    }
                    for (int index = 0; output->valid && index < output->count; index++)
                        result[index] = 0.0;
                    for (int value_index = 0; output->valid && value_index < first->count; value_index++)
                    {
                        int lower = 0;
                        int upper = second->count;
                        while (lower < upper)
                        {
                            int middle = lower + (upper - lower) / 2;
                            if (a[value_index] <= b[middle])
                                upper = middle;
                            else
                                lower = middle + 1;
                        }
                        result[lower] += 1.0;
                    }
                    break;
                }
                case 5:
                {
                    if (first->count <= 0 || scratch == null)
                    {
                        output->valid = 0;
                        break;
                    }
                    mathblocks_statistics_sort_copy(a, first->count, scratch, false);
                    output->scalar_value =
                        mathblocks_statistics_sorted_quantile(scratch, first->count, 0.75) -
                        mathblocks_statistics_sorted_quantile(scratch, first->count, 0.25);
                    break;
                }
                case 6:
                    if (first->count != second->count ||
                        !mathblocks_statistics_kendall_value(a, b, first->count, &output->scalar_value))
                        output->valid = 0;
                    break;
                case 7:
                case 8:
                case 9:
                case 11:
                case 12:
                case 20:
                {
                    if (first->count <= 0 || first->count != second->count)
                    {
                        output->valid = 0;
                        break;
                    }
                    double covariance = mathblocks_statistics_population_covariance(a, b, first->count);
                    if (opcode == 12 || opcode == 20)
                    {
                        output->scalar_value = opcode == 12
                            ? covariance
                            : covariance * first->count / (first->count - 1.0);
                    }
                    else if (opcode == 9)
                    {
                        output->scalar_value = mathblocks_statistics_quotient_by_variance(
                            covariance, mathblocks_statistics_population_variance(a, first->count));
                    }
                    else if (opcode == 7)
                    {
                        double slope = mathblocks_statistics_quotient_by_variance(
                            covariance, mathblocks_statistics_population_variance(a, first->count));
                        output->scalar_value = mathblocks_statistics_mean(b, first->count) -
                            slope * mathblocks_statistics_mean(a, first->count);
                    }
                    else
                    {
                        double correlation = mathblocks_statistics_correlation_value(
                            covariance,
                            mathblocks_statistics_population_variance(a, first->count),
                            mathblocks_statistics_population_variance(b, first->count));
                        output->scalar_value = opcode == 8 ? correlation * correlation : correlation;
                    }
                    break;
                }
                case 10:
                {
                    if (first->count <= 0 || scratch == null)
                    {
                        output->valid = 0;
                        break;
                    }
                    double* sorted = scratch;
                    double* deviations = scratch + first->count;
                    mathblocks_statistics_sort_copy(a, first->count, sorted, false);
                    double median = mathblocks_statistics_sorted_quantile(sorted, first->count, 0.5);
                    for (int index = 0; index < first->count; index++)
                        deviations[index] = Math.Abs(a[index] - median);
                    mathblocks_statistics_sort_copy(deviations, first->count, sorted, false);
                    output->scalar_value = mathblocks_statistics_sorted_quantile(sorted, first->count, 0.5);
                    break;
                }
                case 13:
                case 14:
                    if (!mathblocks_statistics_shape_moment_value(
                            a,
                            first->count,
                            opcode == 13,
                            &output->scalar_value))
                        output->valid = 0;
                    break;
                case 15:
                case 16:
                case 21:
                case 22:
                {
                    if (first->count <= 0)
                    {
                        output->valid = 0;
                        break;
                    }
                    double variance = mathblocks_statistics_population_variance(a, first->count);
                    if (opcode == 21 || opcode == 22)
                        variance = variance * first->count / (first->count - 1.0);
                    output->scalar_value = opcode == 15 || opcode == 21
                        ? mathblocks_square_root(variance)
                        : variance;
                    break;
                }
                case 17:
                {
                    if (first->count <= 0 || scratch == null)
                    {
                        output->valid = 0;
                        break;
                    }
                    int count = mathblocks_statistics_pair_averages(a, first->count, scratch);
                    output->scalar_value = mathblocks_statistics_median(scratch, count);
                    break;
                }
                case 19:
                    output->scalar_value = mathblocks_square_root(
                        mathblocks_compensated_product_sum(a, a, first->count) / first->count);
                    break;
                case 23:
                {
                    if (first->count <= 0 || first->count != second->count || scratch == null)
                    {
                        output->valid = 0;
                        break;
                    }
                    // The ranks were counted by the whole block before this switch.
                    double* left_ranks = scratch;
                    double* right_ranks = scratch + first->count;
                    output->scalar_value = mathblocks_statistics_pearson(
                        left_ranks,
                        right_ranks,
                        first->count);
                    break;
                }
                case 24:
                {
                    if (first->count != second->count || scratch == null)
                    {
                        output->valid = 0;
                        break;
                    }
                    int count = mathblocks_statistics_pair_slopes(a, b, first->count, scratch);
                    if (count <= 0)
                        output->valid = 0;
                    else
                        output->scalar_value = mathblocks_statistics_median(scratch, count);
                    break;
                }
                case 25:
                case 26:
                    if (first->count != second->count ||
                        !mathblocks_statistics_weighted_value(
                            a,
                            b,
                            first->count,
                            opcode == 26,
                            &output->scalar_value))
                        output->valid = 0;
                    break;
            }
            if (output->valid && opcode != 2 && opcode != 4 && !double.IsFinite(output->scalar_value))
                output->valid = 0;
        }
    }
}
