#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

[TranspileToCUDA]
internal static unsafe class StatisticsModule
{
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
    private static float mathblocks_compensated_product_sum([CudaReadOnly] float* first, [CudaReadOnly] float* second, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_compensated_sum([CudaReadOnly] float* values, int count) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_nonnegative_integer(float value, int* result) => throw new NotSupportedException();

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
    private static float mathblocks_quiet_nan() => throw new NotSupportedException();
    [CudaDevice]
    private static float mathblocks_statistics_mean([CudaReadOnly] float* values, int count)
    {
        return mathblocks_compensated_sum(values, count) / count;
    }

    [CudaDevice]
    private static float mathblocks_statistics_population_variance(
        [CudaReadOnly] float* values,
        int count)
    {
        float mean = mathblocks_statistics_mean(values, count);
        float sum = 0.0f;
        for (int index = 0; index < count; index++)
        {
            float difference = values[index] - mean;
            sum += difference * difference;
        }
        return sum / count;
    }

    [CudaDevice]
    private static float mathblocks_statistics_population_covariance(
        [CudaReadOnly] float* left,
        [CudaReadOnly] float* right,
        int count)
    {
        float left_mean = mathblocks_statistics_mean(left, count);
        float right_mean = mathblocks_statistics_mean(right, count);
        float sum = 0.0f;
        for (int index = 0; index < count; index++)
            sum += (left[index] - left_mean) * (right[index] - right_mean);
        return sum / count;
    }

    // covariance / variance, or NaN (invalid) when the variance overflowed: dividing by an infinity would give a finite zero.
    [CudaDevice]
    private static float mathblocks_statistics_quotient_by_variance(float covariance, float variance)
    {
        if (!float.IsFinite(variance))
            return mathblocks_quiet_nan();
        return covariance / variance;
    }

    // covariance / (sd(left) * sd(right)), or NaN (invalid) when a variance or the product of the two standard deviations overflowed.
    [CudaDevice]
    private static float mathblocks_statistics_correlation_value(float covariance, float left_variance, float right_variance)
    {
        if (!float.IsFinite(left_variance) || !float.IsFinite(right_variance))
            return mathblocks_quiet_nan();
        float denominator = mathblocks_square_root(left_variance) * mathblocks_square_root(right_variance);
        if (!float.IsFinite(denominator))
            return mathblocks_quiet_nan();
        return covariance / denominator;
    }

    // The distance correlation from the three moments, or NaN (invalid) when a moment or the product of the two variances overflowed.
    [CudaDevice]
    private static float mathblocks_statistics_distance_correlation_value(
        float covariance_square,
        float left_variance_square,
        float right_variance_square)
    {
        float denominator = mathblocks_square_root(left_variance_square * right_variance_square);
        if (!float.IsFinite(covariance_square) || !float.IsFinite(left_variance_square) ||
            !float.IsFinite(right_variance_square) || !float.IsFinite(denominator))
            return mathblocks_quiet_nan();
        return mathblocks_square_root(covariance_square / denominator);
    }

    [CudaDevice]
    private static float mathblocks_statistics_pearson(
        [CudaReadOnly] float* left,
        [CudaReadOnly] float* right,
        int count)
    {
        return mathblocks_statistics_correlation_value(
            mathblocks_statistics_population_covariance(left, right, count),
            mathblocks_statistics_population_variance(left, count),
            mathblocks_statistics_population_variance(right, count));
    }

    [CudaExternal]
    private static float* mathblocks_stable_merge_sort(float* values, float* buffer, int count, bool descending) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_stable_sort_into([CudaReadOnly] float* values, int count, float* result, float* buffer, bool descending) => throw new NotSupportedException();

    // The same with the buffer in the count doubles after result: result needs 2 * count doubles.
    [CudaDevice]
    private static void mathblocks_statistics_sort_copy(
        [CudaReadOnly] float* values,
        int count,
        float* result,
        bool descending)
    {
        mathblocks_stable_sort_into(values, count, result, result + count, descending);
    }

    [CudaDevice]
    private static float mathblocks_statistics_sorted_quantile(
        [CudaReadOnly] float* sorted,
        int count,
        float probability)
    {
        if (count == 1)
            return sorted[0];
        float position = probability * (count - 1);
        int lower = (int)MathF.Floor(position);
        int upper = (int)MathF.Ceiling(position);
        float weight = position - lower;
        return sorted[lower] * (1.0f - weight) + sorted[upper] * weight;
    }

    [CudaDevice]
    private static float mathblocks_statistics_median(float* values, int count)
    {
        float* sorted = mathblocks_stable_merge_sort(values, values + count, count, false);
        return mathblocks_statistics_sorted_quantile(sorted, count, 0.5f);
    }

    // The average rank of values[index]: the values below it plus half of the equal ones (itself included) plus a half.
    // Both counts are exact integers; a NaN value counts nothing, so its rank is 0.5.
    [CudaDevice]
    private static float mathblocks_statistics_rank_at(
        [CudaReadOnly] float* values,
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
        return lower + (equal + 1.0f) / 2.0f;
    }

    [CudaDevice]
    private static void mathblocks_statistics_rank(
        [CudaReadOnly] float* values,
        int count,
        float* result)
    {
        for (int index = 0; index < count; index++)
            result[index] = mathblocks_statistics_rank_at(values, count, index);
    }

    [CudaDevice]
    private static void mathblocks_statistics_center_distance(
        [CudaReadOnly] float* values,
        int count,
        float* result,
        float* row_means)
    {
        float total_mean = 0.0f;
        for (int row = 0; row < count; row++)
        {
            row_means[row] = 0.0f;
            for (int column = 0; column < count; column++)
            {
                float distance = MathF.Abs(values[row] - values[column]);
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
        [CudaReadOnly] float* values,
        int count,
        float order_value,
        bool central,
        float* value)
    {
        int order = 0;
        if (count <= 0 ||
            !mathblocks_nonnegative_integer(order_value, &order))
            return false;
        float mean = central ? mathblocks_statistics_mean(values, count) : 0.0f;
        float sum = 0.0f;
        for (int index = 0; index < count; index++)
            sum += mathblocks_power(values[index] - mean, (float)order);
        *value = sum / count;
        return float.IsFinite(*value);
    }

    [CudaDevice]
    private static bool mathblocks_statistics_kendall_value(
        [CudaReadOnly] float* left_values,
        [CudaReadOnly] float* right_values,
        int count,
        float* value)
    {
        long concordant = 0;
        long discordant = 0;
        long left_ties = 0;
        long right_ties = 0;
        for (int left = 0; left < count; left++)
        {
            for (int right = left + 1; right < count; right++)
            {
                float left_difference = left_values[left] - left_values[right];
                float right_difference = right_values[left] - right_values[right];
                int left_sign = left_difference > 0.0f ? 1 : left_difference < 0.0f ? -1 : 0;
                int right_sign = right_difference > 0.0f ? 1 : right_difference < 0.0f ? -1 : 0;
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
        *value = (float)(concordant - discordant) /
            mathblocks_square_root(
                (float)(concordant + discordant + left_ties) *
                (concordant + discordant + right_ties));
        return float.IsFinite(*value);
    }

    [CudaDevice]
    private static bool mathblocks_statistics_shape_moment_value(
        [CudaReadOnly] float* values,
        int count,
        bool kurtosis,
        float* value)
    {
        if (count <= 0)
            return false;
        float mean = mathblocks_statistics_mean(values, count);
        float second_moment = 0.0f;
        float higher_moment = 0.0f;
        for (int index = 0; index < count; index++)
        {
            float difference = values[index] - mean;
            float square = difference * difference;
            second_moment += square;
            higher_moment += kurtosis ? square * square : square * difference;
        }
        second_moment /= count;
        higher_moment /= count;
        *value = kurtosis
            ? higher_moment / (second_moment * second_moment) - 3.0f
            : higher_moment / mathblocks_power(second_moment, 1.5f);
        return float.IsFinite(*value);
    }

    [CudaDevice]
    private static bool mathblocks_statistics_weighted_value(
        [CudaReadOnly] float* values,
        [CudaReadOnly] float* weights,
        int count,
        bool variance,
        float* value)
    {
        if (count <= 0)
            return false;
        float weight_sum = mathblocks_compensated_sum(weights, count);
        float mean = mathblocks_compensated_product_sum(values, weights, count) / weight_sum;
        if (!variance)
        {
            *value = mean;
        }
        else
        {
            float numerator = 0.0f;
            for (int index = 0; index < count; index++)
            {
                float difference = values[index] - mean;
                numerator += weights[index] * difference * difference;
            }
            *value = numerator / weight_sum;
        }
        return float.IsFinite(*value);
    }

    // Writes the pair averages (values[left] + values[right]) / 2 for left <= right in row order and returns
    // their count.
    [CudaDevice]
    private static int mathblocks_statistics_pair_averages(
        [CudaReadOnly] float* values,
        int count,
        float* averages)
    {
        int average_count = 0;
        for (int left = 0; left < count; left++)
            for (int right = left; right < count; right++)
                averages[average_count++] = (values[left] + values[right]) / 2.0f;
        return average_count;
    }

    // Writes the pair slopes of the Theil-Sen estimator for left < right with distinct x in row order and
    // returns their count, or -1 when a difference, rise or slope overflows.
    [CudaDevice]
    private static int mathblocks_statistics_pair_slopes(
        [CudaReadOnly] float* x,
        [CudaReadOnly] float* y,
        int count,
        float* slopes)
    {
        int slope_count = 0;
        for (int left = 0; left < count; left++)
        {
            for (int right = left + 1; right < count; right++)
            {
                float difference = x[right] - x[left];
                // An overflowing difference, rise or slope would divide by an infinity or put an infinity in the median: -1.
                if (!float.IsFinite(difference))
                    return -1;
                if (difference != 0.0f)
                {
                    float rise = y[right] - y[left];
                    float slope = rise / difference;
                    if (!float.IsFinite(rise) || !float.IsFinite(slope))
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
            output->scalar_value = 0.0f;
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

        float* a = Cuda.ReadOnly(first == null ? null : (float*)first->data_pointer);
        float* b = Cuda.ReadOnly(second == null ? null : (float*)second->data_pointer);
        float* result = (float*)output->data_pointer;
        float* scratch = (float*)output->scratch_pointer;

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

        // Distance correlation: the block builds both distance matrices by rows, then centres them. Every sum keeps the
        // order of the one thread: a row sum runs over its row's columns, each of the two matrix totals and each of
        // the three moments is one serial sum over the matrix in index order by a single thread. The totals and the
        // moments are handed between threads through output->scalar_value and the scratch, between barriers.
        // The condition is the one of the case below.
        bool distance_parallel = opcode == 3 && first->count > 0 && first->count == second->count && scratch != null;
        if (distance_parallel)
        {
            int distance_count = first->count;
            int distance_cells = distance_count * distance_count;
            float* left_distances = scratch;
            float* right_distances = scratch + distance_cells;
            float* row_means = right_distances + distance_cells;
            int second_owner = 1 % Cuda.BlockDim.X;
            int third_owner = 2 % Cuda.BlockDim.X;
            for (int row = thread; row < distance_count; row += Cuda.BlockDim.X)
            {
                row_means[row] = 0.0f;
                for (int column = 0; column < distance_count; column++)
                {
                    float distance = MathF.Abs(a[row] - a[column]);
                    left_distances[row * distance_count + column] = distance;
                    row_means[row] += distance;
                    right_distances[row * distance_count + column] = MathF.Abs(b[row] - b[column]);
                }
                row_means[row] /= distance_count;
            }
            Cuda.SyncThreads();
            float left_total = 0.0f;
            float right_total = 0.0f;
            if (thread == 0)
            {
                for (int index = 0; index < distance_cells; index++)
                    left_total += left_distances[index];
                left_total /= distance_count * distance_count;
                output->scalar_value = left_total;
            }
            if (thread == second_owner)
            {
                for (int index = 0; index < distance_cells; index++)
                    right_total += right_distances[index];
                right_total /= distance_count * distance_count;
            }
            Cuda.SyncThreads();
            float left_mean = output->scalar_value;
            for (int row = thread; row < distance_count; row += Cuda.BlockDim.X)
                for (int column = 0; column < distance_count; column++)
                    left_distances[row * distance_count + column] -=
                        row_means[row] + row_means[column] - left_mean;
            Cuda.SyncThreads();
            if (thread == second_owner)
                output->scalar_value = right_total;
            for (int row = thread; row < distance_count; row += Cuda.BlockDim.X)
            {
                row_means[row] = 0.0f;
                for (int column = 0; column < distance_count; column++)
                    row_means[row] += right_distances[row * distance_count + column];
                row_means[row] /= distance_count;
            }
            Cuda.SyncThreads();
            float right_mean = output->scalar_value;
            for (int row = thread; row < distance_count; row += Cuda.BlockDim.X)
                for (int column = 0; column < distance_count; column++)
                    right_distances[row * distance_count + column] -=
                        row_means[row] + row_means[column] - right_mean;
            Cuda.SyncThreads();
            float covariance_moment = 0.0f;
            float left_moment = 0.0f;
            float right_moment = 0.0f;
            if (thread == 0)
                for (int index = 0; index < distance_cells; index++)
                    covariance_moment += left_distances[index] * right_distances[index];
            if (thread == second_owner)
                for (int index = 0; index < distance_cells; index++)
                    left_moment += left_distances[index] * left_distances[index];
            if (thread == third_owner)
                for (int index = 0; index < distance_cells; index++)
                    right_moment += right_distances[index] * right_distances[index];
            Cuda.SyncThreads();
            if (thread == 0)
                scratch[0] = covariance_moment;
            if (thread == second_owner)
                scratch[1] = left_moment;
            if (thread == third_owner)
                scratch[2] = right_moment;
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
                        scratch[column] = 0.0f;
                        for (int row = 0; row < rows; row++)
                            scratch[column] += a[row * columns + column] / rows;
                    }
                    for (int left = 0; left < columns; left++)
                    {
                        for (int right = left; right < columns; right++)
                        {
                            float sum = 0.0f;
                            for (int row = 0; row < rows; row++)
                            {
                                sum += (a[row * columns + left] - scratch[left]) *
                                       (a[row * columns + right] - scratch[right]);
                            }
                            float covariance = sum / rows;
                            result[left * columns + right] = covariance;
                            result[right * columns + left] = covariance;
                            if (!float.IsFinite(covariance)) output->valid = 0;
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
                    float covariance_square = scratch[0];
                    float left_variance_square = scratch[1];
                    float right_variance_square = scratch[2];
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
                        result[index] = 0.0f;
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
                        result[lower] += 1.0f;
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
                        mathblocks_statistics_sorted_quantile(scratch, first->count, 0.75f) -
                        mathblocks_statistics_sorted_quantile(scratch, first->count, 0.25f);
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
                    float covariance = mathblocks_statistics_population_covariance(a, b, first->count);
                    if (opcode == 12 || opcode == 20)
                    {
                        output->scalar_value = opcode == 12
                            ? covariance
                            : covariance * first->count / (first->count - 1.0f);
                    }
                    else if (opcode == 9)
                    {
                        output->scalar_value = mathblocks_statistics_quotient_by_variance(
                            covariance, mathblocks_statistics_population_variance(a, first->count));
                    }
                    else if (opcode == 7)
                    {
                        float slope = mathblocks_statistics_quotient_by_variance(
                            covariance, mathblocks_statistics_population_variance(a, first->count));
                        output->scalar_value = mathblocks_statistics_mean(b, first->count) -
                            slope * mathblocks_statistics_mean(a, first->count);
                    }
                    else
                    {
                        float correlation = mathblocks_statistics_correlation_value(
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
                    float* sorted = scratch;
                    float* deviations = scratch + first->count;
                    mathblocks_statistics_sort_copy(a, first->count, sorted, false);
                    float median = mathblocks_statistics_sorted_quantile(sorted, first->count, 0.5f);
                    for (int index = 0; index < first->count; index++)
                        deviations[index] = MathF.Abs(a[index] - median);
                    mathblocks_statistics_sort_copy(deviations, first->count, sorted, false);
                    output->scalar_value = mathblocks_statistics_sorted_quantile(sorted, first->count, 0.5f);
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
                    float variance = mathblocks_statistics_population_variance(a, first->count);
                    if (opcode == 21 || opcode == 22)
                        variance = variance * first->count / (first->count - 1.0f);
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
                    float* left_ranks = scratch;
                    float* right_ranks = scratch + first->count;
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
            if (output->valid && opcode != 2 && opcode != 4 && !float.IsFinite(output->scalar_value))
                output->valid = 0;
        }
    }
}
