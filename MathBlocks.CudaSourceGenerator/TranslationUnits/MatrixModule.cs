#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

[TranspileToCUDA]
internal static unsafe class MatrixModule
{
    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_matrix_exponential_taylor_terms() => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_matrix_size() => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_totally_nonnegative_size() => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_maximal_minor_columns() => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_explicit_subset_size() => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_iteration_count() => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_jacobi_policy() => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static long mathblocks_limit_jacobi_rotation_budget(int size) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_nonconvergence_record_matrix(int opcode) => throw new NotSupportedException();

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
    private static float mathblocks_arc_tangent_2(float left, float right) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_binary_logarithm(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_compensated_product_sum([CudaReadOnly] float* first, [CudaReadOnly] float* second, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_compensated_sum([CudaReadOnly] float* values, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_cosine(float value) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_nonnegative_integer(float value, int* result) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_power(float value, float exponent) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_set_vector_shape(MathBlockSlot* output, int count) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_sine(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_square_root(float value) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_maximum(float first, float second) => throw new NotSupportedException();

    [CudaDevice]
    private static void mathblocks_matrix_shape(MathBlockSlot* output, int rows, int columns)
    {
        long count = (long)rows * columns;
        output->rows = rows;
        output->columns = columns;
        output->count = count > 2147483647L ? -1 : (int)count;
        if (rows <= 0 || columns <= 0 || count > output->capacity)
            output->valid = 0;
    }

    [CudaDevice]
    private static bool mathblocks_matrix_compatible(
        [CudaReadOnly] MathBlockSlot* left,
        [CudaReadOnly] MathBlockSlot* right)
    {
        return left->rows == right->rows && left->columns == right->columns;
    }

    [CudaDevice]
    private static void mathblocks_matrix_copy([CudaReadOnly] float* source, float* destination, int count)
    {
        for (int index = 0; index < count; index++)
            destination[index] = source[index];
    }

    [CudaDevice]
    private static void mathblocks_matrix_swap_rows(
        float* values,
        int columns,
        int left,
        int right)
    {
        if (left == right)
            return;
        for (int column = 0; column < columns; column++)
        {
            float temporary = values[left * columns + column];
            values[left * columns + column] = values[right * columns + column];
            values[right * columns + column] = temporary;
        }
    }

    [CudaDevice]
    private static float mathblocks_matrix_determinant(
        [CudaReadOnly] float* source,
        int size,
        float* work)
    {
        mathblocks_matrix_copy(source, work, size * size);
        float determinant = 1.0f;
        for (int pivot = 0; pivot < size; pivot++)
        {
            int pivot_row = pivot;
            for (int row = pivot + 1; row < size; row++)
                if (MathF.Abs(work[row * size + pivot]) > MathF.Abs(work[pivot_row * size + pivot]))
                    pivot_row = row;
            if (work[pivot_row * size + pivot] == 0.0f)
                return 0.0f;
            if (pivot_row != pivot)
            {
                mathblocks_matrix_swap_rows(work, size, pivot, pivot_row);
                determinant = -determinant;
            }
            float diagonal = work[pivot * size + pivot];
            determinant *= diagonal;
            for (int row = pivot + 1; row < size; row++)
            {
                float scale = work[row * size + pivot] / diagonal;
                for (int column = pivot + 1; column < size; column++)
                    work[row * size + column] -= scale * work[pivot * size + column];
            }
        }
        return determinant;
    }

    [CudaDevice]
    private static bool mathblocks_matrix_try_solve(
        [CudaReadOnly] float* matrix,
        [CudaReadOnly] float* right,
        int size,
        float* augmented,
        float* solution)
    {
        int columns = size + 1;
        for (int row = 0; row < size; row++)
        {
            for (int column = 0; column < size; column++)
                augmented[row * columns + column] = matrix[row * size + column];
            augmented[row * columns + size] = right[row];
        }
        for (int pivot = 0; pivot < size; pivot++)
        {
            int pivot_row = pivot;
            for (int row = pivot + 1; row < size; row++)
                if (MathF.Abs(augmented[row * columns + pivot]) >
                    MathF.Abs(augmented[pivot_row * columns + pivot]))
                {
                    pivot_row = row;
                }
            if (augmented[pivot_row * columns + pivot] == 0.0f)
                return false;
            if (pivot_row != pivot)
                mathblocks_matrix_swap_rows(augmented, columns, pivot, pivot_row);
            float diagonal = augmented[pivot * columns + pivot];
            for (int column = pivot; column <= size; column++)
                augmented[pivot * columns + column] /= diagonal;
            for (int row = 0; row < size; row++)
            {
                if (row == pivot)
                    continue;
                float scale = augmented[row * columns + pivot];
                for (int column = pivot; column <= size; column++)
                    augmented[row * columns + column] -=
                        scale * augmented[pivot * columns + column];
            }
        }
        for (int row = 0; row < size; row++)
        {
            solution[row] = augmented[row * columns + size];
            if (!float.IsFinite(solution[row]))
                return false;
        }
        return true;
    }

    [CudaDevice]
    private static bool mathblocks_matrix_try_solve_basis(
        [CudaReadOnly] float* matrix,
        int size,
        int basis,
        float* augmented,
        float* solution)
    {
        int columns = size + 1;
        for (int row = 0; row < size; row++)
        {
            for (int column = 0; column < size; column++)
                augmented[row * columns + column] = matrix[row * size + column];
            augmented[row * columns + size] = row == basis ? 1.0f : 0.0f;
        }
        for (int pivot = 0; pivot < size; pivot++)
        {
            int pivot_row = pivot;
            for (int row = pivot + 1; row < size; row++)
                if (MathF.Abs(augmented[row * columns + pivot]) >
                    MathF.Abs(augmented[pivot_row * columns + pivot]))
                {
                    pivot_row = row;
                }
            if (augmented[pivot_row * columns + pivot] == 0.0f)
                return false;
            if (pivot_row != pivot)
                mathblocks_matrix_swap_rows(augmented, columns, pivot, pivot_row);
            float diagonal = augmented[pivot * columns + pivot];
            for (int column = pivot; column <= size; column++)
                augmented[pivot * columns + column] /= diagonal;
            for (int row = 0; row < size; row++)
            {
                if (row == pivot)
                    continue;
                float scale = augmented[row * columns + pivot];
                for (int column = pivot; column <= size; column++)
                    augmented[row * columns + column] -=
                        scale * augmented[pivot * columns + column];
            }
        }
        for (int row = 0; row < size; row++)
        {
            solution[row] = augmented[row * columns + size];
            if (!float.IsFinite(solution[row]))
                return false;
        }
        return true;
    }

    [CudaDevice]
    private static bool mathblocks_matrix_is_symmetric([CudaReadOnly] float* values, int rows, int columns)
    {
        if (rows != columns)
            return false;
        for (int row = 0; row < rows; row++)
            for (int column = row + 1; column < columns; column++)
                if (values[row * columns + column] != values[column * columns + row])
                    return false;
        return true;
    }

    [CudaDevice]
    private static bool mathblocks_matrix_is_positive_definite(
        [CudaReadOnly] float* values,
        int size,
        float* lower)
    {
        if (!mathblocks_matrix_is_symmetric(values, size, size))
            return false;
        for (int index = 0; index < size * size; index++)
            lower[index] = 0.0f;
        for (int row = 0; row < size; row++)
        {
            for (int column = 0; column <= row; column++)
            {
                float sum = values[row * size + column];
                for (int inner = 0; inner < column; inner++)
                    sum -= lower[row * size + inner] * lower[column * size + inner];
                if (row == column)
                {
                    if (sum <= 0.0f)
                        return false;
                    lower[row * size + column] = mathblocks_square_root(sum);
                }
                else
                {
                    lower[row * size + column] = sum / lower[column * size + column];
                }
            }
        }
        return true;
    }

    [CudaExternal]
    private static float* mathblocks_stable_merge_sort(float* values, float* buffer, int count, bool descending) => throw new NotSupportedException();

    [CudaDevice]
    private static bool mathblocks_matrix_symmetric_eigenvalues(
        [CudaReadOnly] float* source,
        int size,
        float* work,
        float* eigenvalues,
        float* buffer)
    {
        mathblocks_matrix_copy(source, work, size * size);
        long budget = mathblocks_limit_jacobi_rotation_budget(size);
        bool converged = false;
        // The scan that finds the pivot is also the convergence test: the sweep ends converged at the first scan with no
        // off-diagonal entry, and unconverged when the rotation budget is used up with one left.
        for (long iteration = 0; iteration <= budget; iteration++)
        {
            int pivot_row = 0;
            int pivot_column = 0;
            float largest = 0.0f;
            for (int row = 0; row < size; row++)
            {
                for (int column = row + 1; column < size; column++)
                {
                    float magnitude = MathF.Abs(work[row * size + column]);
                    if (magnitude <= largest)
                        continue;
                    largest = magnitude;
                    pivot_row = row;
                    pivot_column = column;
                }
            }
            if (largest == 0.0f)
            {
                converged = true;
                break;
            }
            if (iteration >= budget)
                break;
            float angle = 0.5f * mathblocks_arc_tangent_2(
                2.0f * work[pivot_row * size + pivot_column],
                work[pivot_column * size + pivot_column] -
                    work[pivot_row * size + pivot_row]);
            float cosine = mathblocks_cosine(angle);
            float sine = mathblocks_sine(angle);
            float aa = work[pivot_row * size + pivot_row];
            float bb = work[pivot_column * size + pivot_column];
            float ab = work[pivot_row * size + pivot_column];
            work[pivot_row * size + pivot_row] =
                cosine * cosine * aa - 2.0f * sine * cosine * ab + sine * sine * bb;
            work[pivot_column * size + pivot_column] =
                sine * sine * aa + 2.0f * sine * cosine * ab + cosine * cosine * bb;
            work[pivot_row * size + pivot_column] = 0.0f;
            work[pivot_column * size + pivot_row] = 0.0f;
            for (int other = 0; other < size; other++)
            {
                if (other == pivot_row || other == pivot_column)
                    continue;
                float first = work[other * size + pivot_row];
                float second = work[other * size + pivot_column];
                float first_value = cosine * first - sine * second;
                float second_value = sine * first + cosine * second;
                work[other * size + pivot_row] = first_value;
                work[pivot_row * size + other] = first_value;
                work[other * size + pivot_column] = second_value;
                work[pivot_column * size + other] = second_value;
            }
        }
        for (int index = 0; index < size; index++)
            eigenvalues[index] = work[index * size + index];
        // Ascending, as the source's StableMergeSort; buffer holds size doubles.
        float* sorted = mathblocks_stable_merge_sort(eigenvalues, buffer, size, false);
        if (sorted != eigenvalues)
            for (int index = 0; index < size; index++)
                eigenvalues[index] = sorted[index];
        return converged;
    }

    [CudaDevice]
    private static int mathblocks_matrix_rank([CudaReadOnly] float* source, int rows, int columns, float* work)
    {
        mathblocks_matrix_copy(source, work, rows * columns);
        int rank = 0;
        int pivot_column = 0;
        while (rank < rows && pivot_column < columns)
        {
            int pivot_row = rank;
            for (int row = rank + 1; row < rows; row++)
                if (MathF.Abs(work[row * columns + pivot_column]) >
                    MathF.Abs(work[pivot_row * columns + pivot_column]))
                {
                    pivot_row = row;
                }
            if (work[pivot_row * columns + pivot_column] == 0.0f)
            {
                pivot_column++;
                continue;
            }
            mathblocks_matrix_swap_rows(work, columns, rank, pivot_row);
            float pivot = work[rank * columns + pivot_column];
            for (int row = rank + 1; row < rows; row++)
            {
                float scale = work[row * columns + pivot_column] / pivot;
                for (int column = pivot_column; column < columns; column++)
                    work[row * columns + column] -= scale * work[rank * columns + column];
            }
            rank++;
            pivot_column++;
        }
        return rank;
    }

    [CudaDevice]
    private static void mathblocks_matrix_multiply_square(
        [CudaReadOnly] float* left,
        [CudaReadOnly] float* right,
        int size,
        float* destination)
    {
        for (int row = 0; row < size; row++)
        {
            for (int column = 0; column < size; column++)
            {
                float sum = 0.0f;
                for (int inner = 0; inner < size; inner++)
                    sum += left[row * size + inner] * right[inner * size + column];
                destination[row * size + column] = sum;
            }
        }
    }

    [CudaDevice]
    private static int mathblocks_pop_count(int value)
    {
        int count = 0;
        while (value != 0)
        {
            count += value & 1;
            value >>= 1;
        }
        return count;
    }

    [CudaDevice]
    private static void mathblocks_matrix_submatrix_from_masks(
        [CudaReadOnly] float* source,
        int source_columns,
        int row_mask,
        int column_mask,
        int order,
        float* destination)
    {
        int output_row = 0;
        for (int row = 0; row < 31; row++)
        {
            if ((row_mask & (1 << row)) == 0)
                continue;
            int output_column = 0;
            for (int column = 0; column < 31; column++)
            {
                if ((column_mask & (1 << column)) == 0)
                    continue;
                destination[output_row * order + output_column] =
                    source[row * source_columns + column];
                output_column++;
            }
            output_row++;
        }
    }

    [CudaDevice(Name = "mathblocks_matrix_dispatch")]
    private static void mathblocks_matrix(
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

        if (opcode == 0 || opcode == 10 || opcode == 22)
        {
            if (thread == 0)
            {
                mathblocks_matrix_shape(output, first->rows, first->columns);
                if (!mathblocks_matrix_compatible(first, second)) output->valid = 0;
            }
            Cuda.SyncThreads();
            for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
            {
                float value = opcode == 0 ? a[index] + b[index]
                    : opcode == 10 ? a[index] * b[index]
                    : a[index] - b[index];
                result[index] = value;
                if (!float.IsFinite(value)) Cuda.AtomicExchange(ref output->valid, 0);
            }
            return;
        }

        if (opcode == 1)
        {
            if (thread == 0)
            {
                mathblocks_matrix_shape(output, first->rows + 1, first->columns);
                if (second->count != first->columns) output->valid = 0;
            }
            Cuda.SyncThreads();
            for (int index = thread; output->valid && index < output->count; index += Cuda.BlockDim.X)
                result[index] = index < first->count ? a[index] : b[index - first->count];
            return;
        }

        if (opcode == 2 || opcode == 18)
        {
            int count = opcode == 2 ? first->columns : first->rows;
            if (thread == 0) mathblocks_set_vector_shape(output, count);
            Cuda.SyncThreads();
            for (int index = thread; output->valid && index < count; index += Cuda.BlockDim.X)
            {
                float sum = 0.0f;
                if (opcode == 2)
                {
                    for (int row = 0; row < first->rows; row++)
                        sum += a[row * first->columns + index];
                }
                else
                {
                    for (int column = 0; column < first->columns; column++)
                        sum += a[index * first->columns + column];
                }
                result[index] = sum;
                if (!float.IsFinite(sum)) Cuda.AtomicExchange(ref output->valid, 0);
            }
            return;
        }

        if (opcode == 3 || opcode == 19)
        {
            int selected = 0;
            bool valid_index = mathblocks_nonnegative_integer(second->scalar_value, &selected);
            int limit = opcode == 3 ? first->columns : first->rows;
            int count = opcode == 3 ? first->rows : first->columns;
            if (thread == 0)
            {
                mathblocks_set_vector_shape(output, count);
                if (!valid_index || selected >= limit) output->valid = 0;
            }
            Cuda.SyncThreads();
            for (int index = thread; output->valid && index < count; index += Cuda.BlockDim.X)
                result[index] = opcode == 3
                    ? a[index * first->columns + selected]
                    : a[selected * first->columns + index];
            return;
        }

        if (opcode == 4)
        {
            if (thread == 0)
            {
                mathblocks_matrix_shape(output, first->rows, first->columns);
                if (!mathblocks_matrix_compatible(first, second) || first->rows != first->columns)
                    output->valid = 0;
            }
            Cuda.SyncThreads();
            for (int flat = thread; output->valid && flat < output->count; flat += Cuda.BlockDim.X)
            {
                int row = flat / first->columns;
                int column = flat - row * first->columns;
                float left_product = 0.0f;
                float right_product = 0.0f;
                for (int inner = 0; inner < first->columns; inner++)
                {
                    left_product += a[row * first->columns + inner] *
                        b[inner * second->columns + column];
                    right_product += b[row * second->columns + inner] *
                        a[inner * first->columns + column];
                }
                result[flat] = left_product - right_product;
                if (!float.IsFinite(result[flat])) Cuda.AtomicExchange(ref output->valid, 0);
            }
            return;
        }

        if (opcode == 5)
        {
            int size = first->count;
            if (thread == 0)
            {
                mathblocks_matrix_shape(output, size, size);
                if (size <= 0) output->valid = 0;
            }
            Cuda.SyncThreads();
            for (int flat = thread; output->valid && flat < size * size; flat += Cuda.BlockDim.X)
            {
                int row = flat / size;
                int column = flat - row * size;
                result[flat] = row == column ? a[row] : 0.0f;
            }
            return;
        }

        if (opcode == 6)
        {
            int count = first->rows < first->columns ? first->rows : first->columns;
            if (thread == 0) mathblocks_set_vector_shape(output, count);
            Cuda.SyncThreads();
            for (int index = thread; output->valid && index < count; index += Cuda.BlockDim.X)
                result[index] = a[index * first->columns + index];
            return;
        }

        if (opcode == 7)
        {
            if (thread == 0) mathblocks_set_vector_shape(output, first->count);
            Cuda.SyncThreads();
            for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                result[index] = a[index];
            return;
        }

        if (opcode == 8)
        {
            if (thread == 0)
            {
                output->scalar_value = mathblocks_square_root(
                    mathblocks_compensated_product_sum(a, a, first->count));
                if (!float.IsFinite(output->scalar_value)) output->valid = 0;
            }
            return;
        }

        if (opcode == 9)
        {
            int size = first->columns;
            if (thread == 0) mathblocks_matrix_shape(output, size, size);
            Cuda.SyncThreads();
            for (int flat = thread; output->valid && flat < size * size; flat += Cuda.BlockDim.X)
            {
                int row = flat / size;
                int column = flat - row * size;
                float sum = 0.0f;
                for (int inner = 0; inner < first->rows; inner++)
                    sum += a[inner * first->columns + row] * a[inner * first->columns + column];
                result[flat] = sum;
                if (!float.IsFinite(sum)) Cuda.AtomicExchange(ref output->valid, 0);
            }
            return;
        }

        if (opcode == 11 || opcode == 23)
        {
            if (thread == 0)
            {
                mathblocks_matrix_shape(output, first->count, second->count);
                if (first->count <= 0 || second->count <= 0 ||
                    (opcode == 11 ? a[first->count - 1] != b[0] : a[0] != b[0]))
                {
                    output->valid = 0;
                }
            }
            Cuda.SyncThreads();
            for (int flat = thread; output->valid && flat < output->count; flat += Cuda.BlockDim.X)
            {
                int row = flat / second->count;
                int column = flat - row * second->count;
                if (opcode == 23)
                {
                    result[flat] = column >= row ? b[column - row] : a[row - column];
                }
                else
                {
                    int index = row + column;
                    result[flat] = index < first->count ? a[index] : b[index - first->count + 1];
                }
            }
            return;
        }

        if (opcode == 12)
        {
            int size = 0;
            bool valid_size = mathblocks_nonnegative_integer(first->scalar_value, &size);
            if (thread == 0)
            {
                mathblocks_matrix_shape(output, size, size);
                if (!valid_size || size <= 0 || size > mathblocks_limit_matrix_size()) output->valid = 0;
            }
            Cuda.SyncThreads();
            for (int flat = thread; output->valid && flat < size * size; flat += Cuda.BlockDim.X)
            {
                int row = flat / size;
                int column = flat - row * size;
                result[flat] = row == column ? 1.0f : 0.0f;
            }
            return;
        }

        if (opcode == 13)
        {
            int rows = first->rows * second->rows;
            int columns = first->columns * second->columns;
            if (thread == 0) mathblocks_matrix_shape(output, rows, columns);
            Cuda.SyncThreads();
            for (int flat = thread; output->valid && flat < rows * columns; flat += Cuda.BlockDim.X)
            {
                int row = flat / columns;
                int column = flat - row * columns;
                int left_row = row / second->rows;
                int right_row = row - left_row * second->rows;
                int left_column = column / second->columns;
                int right_column = column - left_column * second->columns;
                result[flat] = a[left_row * first->columns + left_column] *
                    b[right_row * second->columns + right_column];
                if (!float.IsFinite(result[flat])) Cuda.AtomicExchange(ref output->valid, 0);
            }
            return;
        }

        if (opcode == 14)
        {
            if (thread == 0)
            {
                mathblocks_set_vector_shape(output, first->rows);
                if (first->columns != second->count) output->valid = 0;
            }
            Cuda.SyncThreads();
            for (int row = thread; output->valid && row < first->rows; row += Cuda.BlockDim.X)
            {
                float sum = 0.0f;
                for (int column = 0; column < first->columns; column++)
                    sum += a[row * first->columns + column] * b[column];
                result[row] = sum;
                if (!float.IsFinite(sum)) Cuda.AtomicExchange(ref output->valid, 0);
            }
            return;
        }

        if (opcode == 15)
        {
            if (thread == 0)
            {
                mathblocks_matrix_shape(output, first->rows, second->columns);
                if (first->columns != second->rows) output->valid = 0;
            }
            Cuda.SyncThreads();
            for (int flat = thread; output->valid && flat < output->count; flat += Cuda.BlockDim.X)
            {
                int row = flat / second->columns;
                int column = flat - row * second->columns;
                float sum = 0.0f;
                for (int inner = 0; inner < first->columns; inner++)
                    sum += a[row * first->columns + inner] * b[inner * second->columns + column];
                result[flat] = sum;
                if (!float.IsFinite(sum)) Cuda.AtomicExchange(ref output->valid, 0);
            }
            return;
        }

        if (opcode == 16)
        {
            if (thread == 0) mathblocks_matrix_shape(output, first->count, second->count);
            Cuda.SyncThreads();
            for (int flat = thread; output->valid && flat < output->count; flat += Cuda.BlockDim.X)
            {
                int row = flat / second->count;
                int column = flat - row * second->count;
                result[flat] = a[row] * b[column];
                if (!float.IsFinite(result[flat])) Cuda.AtomicExchange(ref output->valid, 0);
            }
            return;
        }

        if (opcode == 17)
        {
            int rows = 0;
            int columns = 0;
            bool valid_rows = mathblocks_nonnegative_integer(second->scalar_value, &rows);
            bool valid_columns = mathblocks_nonnegative_integer(third->scalar_value, &columns);
            if (thread == 0)
            {
                mathblocks_matrix_shape(output, rows, columns);
                if (!valid_rows || !valid_columns || rows <= 0 || columns <= 0 ||
                    (long)rows * columns != first->count)
                {
                    output->valid = 0;
                }
            }
            Cuda.SyncThreads();
            for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
                result[index] = a[index];
            return;
        }

        if (opcode == 20)
        {
            if (thread == 0) mathblocks_matrix_shape(output, first->rows, first->columns);
            Cuda.SyncThreads();
            for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
            {
                result[index] = a[index] * second->scalar_value;
                if (!float.IsFinite(result[index])) Cuda.AtomicExchange(ref output->valid, 0);
            }
            return;
        }

        if (opcode == 21)
        {
            if (thread == 0)
            {
                mathblocks_matrix_shape(output, 2, first->count);
                if (first->count != second->count) output->valid = 0;
            }
            Cuda.SyncThreads();
            for (int index = thread; output->valid && index < first->count; index += Cuda.BlockDim.X)
            {
                result[index] = a[index];
                result[first->count + index] = b[index];
            }
            return;
        }

        if (opcode == 24)
        {
            if (thread == 0)
            {
                if (first->rows != first->columns)
                {
                    output->valid = 0;
                    return;
                }
                float trace = 0.0f;
                for (int index = 0; index < first->rows; index++)
                    trace += a[index * first->columns + index];
                output->scalar_value = trace;
                if (!float.IsFinite(trace)) output->valid = 0;
            }
            return;
        }

        if (opcode == 25)
        {
            if (thread == 0) mathblocks_matrix_shape(output, first->columns, first->rows);
            Cuda.SyncThreads();
            for (int flat = thread; output->valid && flat < output->count; flat += Cuda.BlockDim.X)
            {
                int row = flat / first->rows;
                int column = flat - row * first->rows;
                result[flat] = a[column * first->columns + row];
            }
            return;
        }

        if (thread != 0)
            return;

        if (opcode == 26)
        {
            if (first->rows != first->columns || scratch == null)
            {
                output->valid = 0;
                return;
            }
            output->scalar_value = mathblocks_matrix_determinant(a, first->rows, scratch);
            if (!float.IsFinite(output->scalar_value)) output->valid = 0;
            return;
        }

        if (opcode == 27)
        {
            int size = first->rows;
            int count = first->count;
            if (size != first->columns || scratch == null)
            {
                output->valid = 0;
                return;
            }
            mathblocks_matrix_shape(output, size, size);
            float norm = 0.0f;
            for (int row = 0; row < size; row++)
            {
                float row_sum = 0.0f;
                for (int column = 0; column < size; column++)
                    row_sum += MathF.Abs(a[row * size + column]);
                if (row_sum > norm) norm = row_sum;
            }
            // An overflowing norm would ask for int.MaxValue squarings; the result is not finite.
            if (!float.IsFinite(norm))
            {
                output->valid = 0;
                return;
            }
            // exp(A) overflows when trace(A) / n > ln(DBL_MAX) + ln(n) / 2 (Hadamard: det(exp A) = exp(trace A) and |det M| <= (sqrt(n) * max|m_ij|)^n), a
            // result the scaling and squaring below can lose to zeros without a non-finite value.
            float trace = 0.0f;
            for (int index = 0; index < size; index++)
                trace += a[index * size + index];
            if (trace / size > 88.72283905206835f + 0.5f * (mathblocks_binary_logarithm((float)size) * 0.693147180559945309417f))
            {
                output->valid = 0;
                return;
            }
            int scaling = norm > 1.0f ? (int)MathF.Ceiling(mathblocks_binary_logarithm(norm)) : 0;
            if (scaling < 0) scaling = 0;
            float scale = mathblocks_power(2.0f, (float)-scaling);
            float* scaled = scratch;
            float* term = scratch + count;
            float* temporary = scratch + count * 2;
            for (int index = 0; index < count; index++)
            {
                scaled[index] = a[index] * scale;
                result[index] = 0.0f;
                term[index] = 0.0f;
            }
            for (int index = 0; index < size; index++)
            {
                result[index * size + index] = 1.0f;
                term[index * size + index] = 1.0f;
            }
            for (int order = 1; order <= mathblocks_limit_matrix_exponential_taylor_terms(); order++)
            {
                mathblocks_matrix_multiply_square(term, scaled, size, temporary);
                float order_scale = 1.0f / order;
                for (int index = 0; index < count; index++)
                {
                    term[index] = temporary[index] * order_scale;
                    result[index] += term[index];
                }
            }
            for (int iteration = 0; iteration < scaling; iteration++)
            {
                mathblocks_matrix_multiply_square(result, result, size, temporary);
                mathblocks_matrix_copy(temporary, result, count);
            }
            for (int index = 0; index < count; index++)
                if (!float.IsFinite(result[index])) output->valid = 0;
            return;
        }

        if (opcode == 28)
        {
            int exponent = 0;
            if (first->rows != first->columns ||
                !mathblocks_nonnegative_integer(second->scalar_value, &exponent) ||
                scratch == null)
            {
                output->valid = 0;
                return;
            }
            int size = first->rows;
            int count = first->count;
            mathblocks_matrix_shape(output, size, size);
            float* power = scratch;
            float* temporary = scratch + count;
            mathblocks_matrix_copy(a, power, count);
            for (int index = 0; index < count; index++)
                result[index] = 0.0f;
            for (int index = 0; index < size; index++)
                result[index * size + index] = 1.0f;
            while (exponent > 0)
            {
                if ((exponent & 1) != 0)
                {
                    mathblocks_matrix_multiply_square(result, power, size, temporary);
                    mathblocks_matrix_copy(temporary, result, count);
                }
                exponent >>= 1;
                if (exponent > 0)
                {
                    mathblocks_matrix_multiply_square(power, power, size, temporary);
                    mathblocks_matrix_copy(temporary, power, count);
                }
            }
            for (int index = 0; index < count; index++)
                if (!float.IsFinite(result[index])) output->valid = 0;
            return;
        }

        if (opcode == 29)
        {
            int size = first->rows;
            if (size != first->columns || scratch == null)
            {
                output->valid = 0;
                return;
            }
            mathblocks_matrix_shape(output, size, size);
            float* augmented = scratch;
            float* solution = scratch + size * (size + 1);
            for (int column = 0; column < size; column++)
            {
                if (!mathblocks_matrix_try_solve_basis(a, size, column, augmented, solution))
                {
                    output->valid = 0;
                    return;
                }
                for (int row = 0; row < size; row++)
                    result[row * size + column] = solution[row];
            }
            return;
        }

        if (opcode == 30)
        {
            output->boolean_value = first->rows == first->columns && scratch != null &&
                mathblocks_matrix_is_positive_definite(a, first->rows, scratch);
            return;
        }

        if (opcode == 31)
        {
            output->boolean_value = mathblocks_matrix_is_symmetric(a, first->rows, first->columns);
            return;
        }

        if (opcode == 32)
        {
            if (first->rows > mathblocks_limit_totally_nonnegative_size() || first->columns > mathblocks_limit_totally_nonnegative_size() || scratch == null)
            {
                output->valid = 0;
                return;
            }
            float* submatrix = scratch;
            float* work = scratch + first->count;
            output->boolean_value = 1;
            for (int order = 1; output->boolean_value && order <=
                (first->rows < first->columns ? first->rows : first->columns); order++)
            {
                int row_limit = 1 << first->rows;
                int column_limit = 1 << first->columns;
                for (int row_mask = 1; output->boolean_value && row_mask < row_limit; row_mask++)
                {
                    if (mathblocks_pop_count(row_mask) != order)
                        continue;
                    for (int column_mask = 1; column_mask < column_limit; column_mask++)
                    {
                        if (mathblocks_pop_count(column_mask) != order)
                            continue;
                        mathblocks_matrix_submatrix_from_masks(
                            a,
                            first->columns,
                            row_mask,
                            column_mask,
                            order,
                            submatrix);
                        if (mathblocks_matrix_determinant(submatrix, order, work) < 0.0f)
                        {
                            output->boolean_value = 0;
                            break;
                        }
                    }
                }
            }
            return;
        }

        if (opcode == 33 || opcode == 40 || opcode == 43)
        {
            int size = first->rows;
            if (size != first->columns || scratch == null)
            {
                output->valid = 0;
                return;
            }
            float* eigenvalues = opcode == 43 ? result : scratch + first->count;
            if (opcode == 43 && !mathblocks_matrix_is_symmetric(a, size, size))
            {
                output->valid = 0;
                return;
            }
            if (opcode == 43) mathblocks_set_vector_shape(output, size);
            bool converged = mathblocks_matrix_symmetric_eigenvalues(a, size, scratch, eigenvalues, scratch + first->count + (opcode == 43 ? 0 : size));
            if (!converged)
            {
                mathblocks_nonconvergence_record_matrix(opcode);
                if (mathblocks_limit_jacobi_policy() == 1)
                {
                    output->valid = 0;
                    return;
                }
            }
            if (opcode == 33) output->scalar_value = eigenvalues[size - 1];
            else if (opcode == 40) output->scalar_value = eigenvalues[0];
            for (int index = 0; index < size; index++)
                if (!float.IsFinite(eigenvalues[index])) output->valid = 0;
            return;
        }

        if (opcode == 34)
        {
            if (first->rows > first->columns || first->columns > mathblocks_limit_maximal_minor_columns() || scratch == null)
            {
                output->valid = 0;
                return;
            }
            float* submatrix = scratch;
            float* work = scratch + first->count;
            int row_mask = (1 << first->rows) - 1;
            int limit = 1 << first->columns;
            int output_index = 0;
            for (int column_mask = 1; column_mask < limit; column_mask++)
            {
                if (mathblocks_pop_count(column_mask) != first->rows)
                    continue;
                mathblocks_matrix_submatrix_from_masks(
                    a,
                    first->columns,
                    row_mask,
                    column_mask,
                    first->rows,
                    submatrix);
                result[output_index++] = mathblocks_matrix_determinant(
                    submatrix,
                    first->rows,
                    work);
            }
            mathblocks_set_vector_shape(output, output_index);
            for (int index = 0; index < output_index; index++)
                if (!float.IsFinite(result[index])) output->valid = 0;
            return;
        }

        if (opcode == 35 || opcode == 36)
        {
            int iterations = 0;
            int size = first->rows;
            if (size != first->columns ||
                !mathblocks_nonnegative_integer(second->scalar_value, &iterations) ||
                iterations <= 0 || iterations > mathblocks_limit_iteration_count() || scratch == null)
            {
                output->valid = 0;
                return;
            }
            for (int index = 0; index < first->count; index++)
                if (a[index] < 0.0f) output->valid = 0;
            if (!output->valid)
                return;
            float* vector = opcode == 36 ? result : scratch;
            float* next = opcode == 36 ? scratch : scratch + size;
            float* products = opcode == 36 ? scratch + size : scratch + size * 2;
            for (int index = 0; index < size; index++)
                vector[index] = 1.0f / size;
            for (int iteration = 0; iteration < iterations; iteration++)
            {
                for (int row = 0; row < size; row++)
                {
                    float sum = 0.0f;
                    for (int column = 0; column < size; column++)
                        sum += a[row * size + column] * vector[column];
                    next[row] = sum + vector[row];
                }
                float norm = mathblocks_compensated_sum(next, size);
                for (int index = 0; index < size; index++)
                    vector[index] = next[index] / norm;
            }
            if (opcode == 36)
            {
                mathblocks_set_vector_shape(output, size);
                for (int index = 0; index < size; index++)
                    if (!float.IsFinite(result[index])) output->valid = 0;
                return;
            }
            for (int row = 0; row < size; row++)
            {
                float sum = 0.0f;
                for (int column = 0; column < size; column++)
                    sum += a[row * size + column] * vector[column];
                next[row] = sum;
            }
            for (int index = 0; index < size; index++)
                products[index] = vector[index] * next[index];
            float numerator = mathblocks_compensated_sum(products, size);
            for (int index = 0; index < size; index++)
                products[index] = vector[index] * vector[index];
            float denominator = mathblocks_compensated_sum(products, size);
            output->scalar_value = numerator / denominator;
            if (!float.IsFinite(output->scalar_value)) output->valid = 0;
            return;
        }

        if (opcode == 37)
        {
            int size = first->rows;
            if (size != first->columns || size > mathblocks_limit_explicit_subset_size() || scratch == null)
            {
                output->valid = 0;
                return;
            }
            int limit = 1 << size;
            mathblocks_set_vector_shape(output, limit - 1);
            float* submatrix = scratch;
            float* work = scratch + first->count;
            for (int mask = 1; mask < limit; mask++)
            {
                int order = mathblocks_pop_count(mask);
                mathblocks_matrix_submatrix_from_masks(
                    a,
                    size,
                    mask,
                    mask,
                    order,
                    submatrix);
                result[mask - 1] = mathblocks_matrix_determinant(submatrix, order, work);
                if (!float.IsFinite(result[mask - 1])) output->valid = 0;
            }
            return;
        }

        if (opcode == 38)
        {
            if (scratch == null)
            {
                output->valid = 0;
                return;
            }
            output->scalar_value = (float)mathblocks_matrix_rank(
                a,
                first->rows,
                first->columns,
                scratch);
            return;
        }

        if (opcode == 39)
        {
            int retained = 0;
            int size = first->rows;
            if (size != first->columns ||
                !mathblocks_nonnegative_integer(second->scalar_value, &retained) ||
                retained <= 0 || retained >= size || scratch == null)
            {
                output->valid = 0;
                return;
            }
            int eliminated = size - retained;
            float* leading = scratch;
            float* upper = leading + retained * retained;
            float* lower = upper + retained * eliminated;
            float* trailing = lower + eliminated * retained;
            float* inverse = trailing + eliminated * eliminated;
            float* augmented = inverse + eliminated * eliminated;
            float* solution = augmented + eliminated * (eliminated + 1);
            float* upper_inverse = solution + eliminated;
            float* product = upper_inverse + retained * eliminated;
            for (int row = 0; row < size; row++)
            {
                for (int column = 0; column < size; column++)
                {
                    float value = a[row * size + column];
                    if (row < retained && column < retained)
                        leading[row * retained + column] = value;
                    else if (row < retained)
                        upper[row * eliminated + column - retained] = value;
                    else if (column < retained)
                        lower[(row - retained) * retained + column] = value;
                    else
                        trailing[(row - retained) * eliminated + column - retained] = value;
                }
            }
            for (int column = 0; column < eliminated; column++)
            {
                if (!mathblocks_matrix_try_solve_basis(
                    trailing,
                    eliminated,
                    column,
                    augmented,
                    solution))
                {
                    output->valid = 0;
                    return;
                }
                for (int row = 0; row < eliminated; row++)
                    inverse[row * eliminated + column] = solution[row];
            }
            for (int row = 0; row < retained; row++)
            {
                for (int column = 0; column < eliminated; column++)
                {
                    float sum = 0.0f;
                    for (int inner = 0; inner < eliminated; inner++)
                        sum += upper[row * eliminated + inner] *
                            inverse[inner * eliminated + column];
                    upper_inverse[row * eliminated + column] = sum;
                }
            }
            for (int row = 0; row < retained; row++)
            {
                for (int column = 0; column < retained; column++)
                {
                    float sum = 0.0f;
                    for (int inner = 0; inner < eliminated; inner++)
                        sum += upper_inverse[row * eliminated + inner] *
                            lower[inner * retained + column];
                    product[row * retained + column] = sum;
                }
            }
            mathblocks_matrix_shape(output, retained, retained);
            for (int index = 0; index < retained * retained; index++)
            {
                result[index] = leading[index] - product[index];
                if (!float.IsFinite(result[index])) output->valid = 0;
            }
            return;
        }

        if (opcode == 41)
        {
            int size = first->rows;
            if (size != first->columns || second->count != size || scratch == null)
            {
                output->valid = 0;
                return;
            }
            mathblocks_set_vector_shape(output, size);
            if (!mathblocks_matrix_try_solve(a, b, size, scratch, result))
                output->valid = 0;
            return;
        }

        if (opcode == 42)
        {
            int iterations = 0;
            if (!mathblocks_nonnegative_integer(second->scalar_value, &iterations) ||
                iterations <= 0 || iterations > mathblocks_limit_iteration_count() || scratch == null)
            {
                output->valid = 0;
                return;
            }
            int size = first->columns;
            float* gram = scratch;
            float* work = gram + size * size;
            float* eigenvalues = work + size * size;
            for (int row = 0; row < size; row++)
            {
                for (int column = 0; column < size; column++)
                {
                    float sum = 0.0f;
                    for (int inner = 0; inner < first->rows; inner++)
                        sum += a[inner * first->columns + row] *
                            a[inner * first->columns + column];
                    // A square that overflowed gives an invalid result before the eigenvalue step, as on CoreCLR.
                    if (!float.IsFinite(sum))
                    {
                        output->valid = 0;
                        return;
                    }
                    gram[row * size + column] = sum;
                }
            }
            bool converged = mathblocks_matrix_symmetric_eigenvalues(gram, size, work, eigenvalues, eigenvalues + size);
            if (!converged)
            {
                mathblocks_nonconvergence_record_matrix(opcode);
                if (mathblocks_limit_jacobi_policy() == 1)
                {
                    output->valid = 0;
                    return;
                }
            }
            float largest = eigenvalues[size - 1];
            // The owned maximum, as CoreCLR's MathF.Max(0, largest): NaN propagates and a negative zero becomes +0.
            largest = mathblocks_maximum(0.0f, largest);
            output->scalar_value = mathblocks_square_root(largest);
            if (!float.IsFinite(output->scalar_value)) output->valid = 0;
        }
    }
}
