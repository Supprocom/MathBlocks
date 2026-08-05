using System.Text;

namespace Supprocom.MathBlocks.Cuda;

internal static class MathBlockProgramPopulationSearchCudaKernel
{
    private static readonly Lazy<KernelState> state = new(Load, LazyThreadSafetyMode.ExecutionAndPublication);

    public static IntPtr BeginFunction => state.Value.BeginFunction;
    public static IntPtr SetupFunction => state.Value.SetupFunction;
    public static IntPtr PrepareFunction => state.Value.PrepareFunction;
    public static IntPtr EvaluateFunction => state.Value.EvaluateFunction;
    public static IntPtr CommitFunction => state.Value.CommitFunction;
    public static IntPtr FinalizeFunction => state.Value.FinalizeFunction;
    public static IntPtr PublishFunction => state.Value.PublishFunction;

    internal static string CreateSource(string residentKernelSource)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(residentKernelSource);
        var source = new StringBuilder(1_000_000);
        AppendCatalog(source, ScalarCudaBlockCatalog.KernelSource, ScalarCudaBlockCatalog.KernelEntryPoint);
        AppendCatalog(source, VectorCudaBlockCatalog.KernelSource, VectorCudaBlockCatalog.KernelEntryPoint);
        AppendCatalog(source, ComplexCudaBlockCatalog.KernelSource, ComplexCudaBlockCatalog.KernelEntryPoint);
        AppendCatalog(source, MatrixCudaBlockCatalog.KernelSource, MatrixCudaBlockCatalog.KernelEntryPoint);
        AppendCatalog(source, ProbabilityCudaBlockCatalog.KernelSource, ProbabilityCudaBlockCatalog.KernelEntryPoint);
        AppendCatalog(source, SequencePathCudaBlockCatalog.KernelSource, SequencePathCudaBlockCatalog.KernelEntryPoint);
        AppendCatalog(source, StatisticsCudaBlockCatalog.KernelSource, StatisticsCudaBlockCatalog.KernelEntryPoint);
        AppendCatalog(source, GeometryCudaBlockCatalog.KernelSource, GeometryCudaBlockCatalog.KernelEntryPoint);
        AppendCatalog(source, GraphCudaBlockCatalog.KernelSource, GraphCudaBlockCatalog.KernelEntryPoint);
        AppendCatalog(source, AdvancedCudaBlockCatalog.KernelSource, AdvancedCudaBlockCatalog.KernelEntryPoint);
        AppendCatalog(source, TransportCudaBlockCatalog.KernelSource, TransportCudaBlockCatalog.KernelEntryPoint);
        source.AppendLine(ResidentDispatchSource);
        source.AppendLine(residentKernelSource);
        return source.ToString();
    }

    private static void AppendCatalog(StringBuilder destination, string source, string entryPoint)
    {
        var declaration = $"extern \"C\" __global__ void {entryPoint}";
        var replacement = $"__device__ void {entryPoint}_resident";
        var transformed = source.Replace(declaration, replacement, StringComparison.Ordinal);
        if (ReferenceEquals(transformed, source) || transformed.Contains(declaration, StringComparison.Ordinal))
            throw new InvalidOperationException($"CUDA catalog entry '{entryPoint}' cannot become resident dispatch code.");
        destination.AppendLine(transformed);
    }

    private static KernelState Load()
    {
        var source = CreateSource(MathBlockProgramPopulationSearchResidentKernel.Source);
        var ptx = MathBlocksCudaNative.CompilePtx(source, "mathblocks_program_population_search.cu");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleLoadData(out var module, ptx),
            "cuModuleLoadData(mathblocks population search)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var beginFunction,
                module,
                "mathblocks_program_population_search_begin"),
            "cuModuleGetFunction(mathblocks_program_population_search_begin)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var setupFunction,
                module,
                "mathblocks_program_population_search_setup"),
            "cuModuleGetFunction(mathblocks_program_population_search_setup)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var prepareFunction,
                module,
                "mathblocks_program_population_search_prepare"),
            "cuModuleGetFunction(mathblocks_program_population_search_prepare)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var evaluateFunction,
                module,
                "mathblocks_program_population_search_evaluate"),
            "cuModuleGetFunction(mathblocks_program_population_search_evaluate)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var commitFunction,
                module,
                "mathblocks_program_population_search_commit"),
            "cuModuleGetFunction(mathblocks_program_population_search_commit)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var finalizeFunction,
                module,
                "mathblocks_program_population_search_finalize"),
            "cuModuleGetFunction(mathblocks_program_population_search_finalize)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var publishFunction,
                module,
                "mathblocks_program_population_search_publish"),
            "cuModuleGetFunction(mathblocks_program_population_search_publish)");
        return new KernelState(
            module,
            beginFunction,
            setupFunction,
            prepareFunction,
            evaluateFunction,
            commitFunction,
            finalizeFunction,
            publishFunction);
    }

    private sealed record KernelState(
        IntPtr Module,
        IntPtr BeginFunction,
        IntPtr SetupFunction,
        IntPtr PrepareFunction,
        IntPtr EvaluateFunction,
        IntPtr CommitFunction,
        IntPtr FinalizeFunction,
        IntPtr PublishFunction);

    private const string ResidentDispatchSource = """
        __device__ void mb_population_dispatch(
            int family,
            int opcode,
            const MathBlockSlot* const* inputs,
            int input_count,
            MathBlockSlot* output)
        {
            switch (family)
            {
                case 0: mathblocks_advanced_resident(opcode, inputs, input_count, output); break;
                case 1: mathblocks_complex_resident(opcode, inputs, input_count, output); break;
                case 2: mathblocks_geometry_resident(opcode, inputs, input_count, output); break;
                case 3: mathblocks_graph_resident(opcode, inputs, input_count, output); break;
                case 4: mathblocks_matrix_resident(opcode, inputs, input_count, output); break;
                case 5: mathblocks_probability_resident(opcode, inputs, input_count, output); break;
                case 6: mathblocks_scalar_resident(opcode, inputs, input_count, output); break;
                case 7: mathblocks_sequence_path_resident(opcode, inputs, input_count, output); break;
                case 8: mathblocks_statistics_resident(opcode, inputs, input_count, output); break;
                case 9: mathblocks_transport_resident(opcode, inputs, input_count, output); break;
                case 10: mathblocks_vector_resident(opcode, inputs, input_count, output); break;
                default:
                    if (threadIdx.x == 0) output->valid = 0;
                    __syncthreads();
                    break;
            }
        }
        """;
}

internal static class MathBlockProgramPopulationSearchResidentKernel
{
    internal const string Source = """
        typedef unsigned long long mbp_ull;

        struct MbpHash
        {
            mbp_ull first;
            mbp_ull second;
        };

        __device__ int mbp_read_int(const unsigned char* arena, int offset)
        {
            return *((const int*)(arena + offset));
        }

        __device__ mbp_ull mbp_read_ull(const unsigned char* arena, int offset)
        {
            return *((const mbp_ull*)(arena + offset));
        }

        __device__ void mbp_write_int(unsigned char* arena, int offset, int value)
        {
            atomicExch((int*)(arena + offset), value);
        }

        __device__ void mbp_write_ull(unsigned char* arena, int offset, mbp_ull value)
        {
            atomicExch((unsigned long long*)(arena + offset), value);
        }

        __device__ int mbp_align(int value)
        {
            return (value + 7) & ~7;
        }

        __device__ int mbp_header_offset(const unsigned char* arena, int index)
        {
            return mbp_read_int(arena, 128 + index * 4);
        }

        __device__ void mbp_copy(unsigned char* destination, const unsigned char* source, int count)
        {
            for (int index = (int)threadIdx.x; index < count; index += (int)blockDim.x)
                destination[index] = source[index];
            __syncthreads();
        }

        __device__ void mbp_clear(unsigned char* destination, int count)
        {
            for (int index = (int)threadIdx.x; index < count; index += (int)blockDim.x)
                destination[index] = 0;
            __syncthreads();
        }

        __device__ mbp_ull mbp_power(mbp_ull value, int exponent)
        {
            mbp_ull result = 1ull;
            for (int index = 0; index < exponent; index++)
            {
                if (result != 0ull && value > ~0ull / result)
                    return ~0ull;
                result *= value;
            }
            return result;
        }

        __device__ mbp_ull mbp_saturating_add(mbp_ull first, mbp_ull second)
        {
            return ~0ull - first < second ? ~0ull : first + second;
        }

        __device__ void mbp_hash_byte(MbpHash* hash, unsigned char value)
        {
            hash->first = (hash->first ^ (mbp_ull)value) * 1099511628211ull;
            hash->second = (hash->second ^ (mbp_ull)value) * 14029467366897019727ull;
        }

        __device__ void mbp_hash_word(MbpHash* hash, mbp_ull value)
        {
            for (int shift = 0; shift < 64; shift += 8)
                mbp_hash_byte(hash, (unsigned char)((value >> shift) & 0xffull));
        }

        __device__ MbpHash mbp_hash_start()
        {
            MbpHash result;
            result.first = 14695981039346656037ull;
            result.second = 7809847782465536322ull;
            return result;
        }

        __device__ bool mbp_hash_equal(MbpHash first, MbpHash second)
        {
            return first.first == second.first && first.second == second.second;
        }

        __device__ bool mbp_hash_less(MbpHash first, MbpHash second)
        {
            return first.first < second.first ||
                (first.first == second.first && first.second < second.second);
        }

        __device__ MbpHash mbp_read_hash(const unsigned char* arena, int offset, int index)
        {
            MbpHash result;
            result.first = mbp_read_ull(arena, offset + index * 16);
            result.second = mbp_read_ull(arena, offset + index * 16 + 8);
            return result;
        }

        __device__ void mbp_write_hash(unsigned char* arena, int offset, int index, MbpHash value)
        {
            mbp_write_ull(arena, offset + index * 16, value.first);
            mbp_write_ull(arena, offset + index * 16 + 8, value.second);
        }

        __device__ bool mbp_contains_hash(
            const unsigned char* arena,
            int offset,
            int count,
            MbpHash value)
        {
            for (int index = 0; index < count; index++)
                if (mbp_hash_equal(mbp_read_hash(arena, offset, index), value))
                    return true;
            return false;
        }

        __device__ bool mbp_wave_owns_structural(
            const unsigned char* arena,
            int wave_offset,
            int wave_count,
            int entry_size,
            MbpHash value)
        {
            for (int index = 0; index < wave_count; index++)
            {
                int entry = wave_offset + index * entry_size;
                int status = mbp_read_int(arena, entry);
                if (status != 1 && status != 5)
                    continue;
                MbpHash existing;
                existing.first = mbp_read_ull(arena, entry + 48);
                existing.second = mbp_read_ull(arena, entry + 56);
                if (mbp_hash_equal(existing, value))
                    return true;
            }
            return false;
        }

        __device__ bool mbp_types_compatible(
            const unsigned char* arena,
            int type_offset,
            int expected_type,
            int actual_type)
        {
            int expected = type_offset + expected_type * 48;
            int actual = type_offset + actual_type * 48;
            if (mbp_read_int(arena, expected) != mbp_read_int(arena, actual))
                return false;
            int expected_rows = mbp_read_int(arena, expected + 4);
            int actual_rows = mbp_read_int(arena, actual + 4);
            if (expected_rows != 0 && actual_rows != 0 && expected_rows != actual_rows)
                return false;
            int expected_columns = mbp_read_int(arena, expected + 8);
            int actual_columns = mbp_read_int(arena, actual + 8);
            if (expected_columns != 0 && actual_columns != 0 && expected_columns != actual_columns)
                return false;
            for (int offset = 12; offset < 44; offset += 4)
                if (mbp_read_int(arena, expected + offset) != mbp_read_int(arena, actual + offset))
                    return false;
            return true;
        }

        __device__ bool mbp_slot_matches_type(
            const unsigned char* arena,
            int type_offset,
            int type_id,
            const MathBlockSlot* slot)
        {
            int type = type_offset + type_id * 48;
            int kind = mbp_read_int(arena, type);
            int rows = mbp_read_int(arena, type + 4);
            int columns = mbp_read_int(arena, type + 8);
            if (!slot->valid || slot->count < 0 || slot->count > slot->capacity)
                return false;
            if (rows != 0 && slot->rows != rows)
                return false;
            if (columns != 0 && slot->columns != columns)
                return false;
            if ((kind == 4 || kind == 6 || kind == 8 || kind == 11) && slot->rows != slot->count)
                return false;
            if ((kind == 5 || kind == 7) &&
                (slot->rows < 0 || slot->columns < 0 || slot->rows * slot->columns != slot->count))
            {
                return false;
            }
            if (kind == 3 && slot->count != 1)
                return false;
            return true;
        }

        __device__ bool mbp_slot_is_finite(
            const unsigned char* arena,
            int type_offset,
            int type_id,
            const MathBlockSlot* slot)
        {
            int kind = mbp_read_int(arena, type_offset + type_id * 48);
            if (kind == 1)
                return isfinite(slot->scalar_value);
            if (kind == 2 || kind == 11)
                return true;
            const double* values = (const double*)slot->data_pointer;
            if (kind == 3 || kind == 6 || kind == 7 || kind == 8)
            {
                for (int index = 0; index < slot->count * 2; index++)
                    if (!isfinite(values[index]))
                        return false;
                return true;
            }
            if (kind == 4 || kind == 5)
            {
                for (int index = 0; index < slot->count; index++)
                    if (!isfinite(values[index]))
                        return false;
                return true;
            }
            if (kind == 9 || kind == 10)
            {
                for (int index = 0; index < slot->count; index++)
                    if (!isfinite(values[index * 2 + 1]))
                        return false;
                return true;
            }
            return false;
        }

        __device__ void mbp_initialize_slot(
            const unsigned char* arena,
            int type_offset,
            int type_id,
            MathBlockSlot* slot,
            mbp_ull data_pointer,
            mbp_ull scratch_pointer,
            int capacity)
        {
            int type = type_offset + type_id * 48;
            int kind = mbp_read_int(arena, type);
            int rows = mbp_read_int(arena, type + 4);
            int columns = mbp_read_int(arena, type + 8);
            slot->scalar_value = 0.0;
            slot->data_pointer = kind == 1 || kind == 2 ? 0ull : data_pointer;
            slot->scratch_pointer = scratch_pointer;
            slot->boolean_value = 0;
            slot->valid = 1;
            slot->rows = rows;
            slot->columns = columns;
            slot->capacity = kind == 1 || kind == 2 ? 0 : capacity;
            if (kind == 3)
                slot->count = 1;
            else if ((kind == 5 || kind == 7) && rows > 0 && columns > 0)
                slot->count = rows * columns;
            else if ((kind == 4 || kind == 6 || kind == 8 || kind == 11) && rows > 0)
                slot->count = rows;
            else
                slot->count = 0;
        }

        __device__ MbpHash mbp_structural_hash(
            const unsigned char* arena,
            int operation_offset,
            int operation_count,
            int maximum_arity,
            const int* selected_operations,
            const int* selected_operands)
        {
            MbpHash hash = mbp_hash_start();
            mbp_hash_word(&hash, (mbp_ull)operation_count);
            for (int node = 0; node < operation_count; node++)
            {
                int operation = operation_offset + selected_operations[node] * 48;
                mbp_hash_word(&hash, mbp_read_ull(arena, operation + 32));
                mbp_hash_word(&hash, mbp_read_ull(arena, operation + 40));
                int arity = mbp_read_int(arena, operation + 8);
                mbp_hash_word(&hash, (mbp_ull)arity);
                for (int input = 0; input < arity; input++)
                    mbp_hash_word(&hash, (mbp_ull)selected_operands[node * maximum_arity + input]);
            }
            return hash;
        }

        __device__ int mbp_validity_rows(int kind, const MathBlockSlot* output)
        {
            if (kind == 1 || kind == 2 || kind == 3)
                return 1;
            if (kind == 5 || kind == 7 || kind == 9)
                return output->rows;
            return output->count;
        }

        __device__ MbpHash mbp_semantic_hash(
            const unsigned char* arena,
            int type_offset,
            int type_id,
            const MathBlockSlot* output,
            const int* mask,
            int mask_count,
            int maximum_lookback)
        {
            MbpHash hash = mbp_hash_start();
            int type = type_offset + type_id * 48;
            int kind = mbp_read_int(arena, type);
            mbp_hash_word(&hash, (mbp_ull)(long long)kind);
            mbp_hash_word(&hash, (mbp_ull)(long long)output->rows);
            mbp_hash_word(&hash, (mbp_ull)(long long)output->columns);
            for (int offset = 12; offset < 44; offset += 4)
                mbp_hash_word(&hash, (mbp_ull)(long long)mbp_read_int(arena, type + offset));
            mbp_hash_word(&hash, (mbp_ull)(long long)maximum_lookback);
            int valid_rows = 0;
            for (int row = 0; row < mask_count; row++)
                if (mask[row] != 0)
                    valid_rows++;
            mbp_hash_word(&hash, (mbp_ull)valid_rows);
            if (kind == 1)
            {
                if (mask_count > 0 && mask[0] != 0)
                    mbp_hash_word(&hash, (mbp_ull)__double_as_longlong(output->scalar_value));
                return hash;
            }
            if (kind == 2)
            {
                if (mask_count > 0 && mask[0] != 0)
                    mbp_hash_word(&hash, output->boolean_value != 0 ? 1ull : 0ull);
                return hash;
            }
            if (kind == 3)
            {
                const mbp_ull* values = (const mbp_ull*)output->data_pointer;
                if (mask_count > 0 && mask[0] != 0)
                {
                    mbp_hash_word(&hash, values[0]);
                    mbp_hash_word(&hash, values[1]);
                }
                return hash;
            }
            if (kind == 4 || kind == 6 || kind == 8 || kind == 11)
            {
                for (int row = 0; row < output->count && row < mask_count; row++)
                {
                    if (mask[row] == 0)
                        continue;
                    mbp_hash_word(&hash, (mbp_ull)row);
                    if (kind == 11)
                        mbp_hash_word(&hash, ((const int*)output->data_pointer)[row] != 0 ? 1ull : 0ull);
                    else if (kind == 6 || kind == 8)
                    {
                        const mbp_ull* values = (const mbp_ull*)output->data_pointer;
                        mbp_hash_word(&hash, values[row * 2]);
                        mbp_hash_word(&hash, values[row * 2 + 1]);
                    }
                    else
                        mbp_hash_word(&hash, ((const mbp_ull*)output->data_pointer)[row]);
                }
                return hash;
            }
            if (kind == 5 || kind == 7)
            {
                const mbp_ull* values = (const mbp_ull*)output->data_pointer;
                int width = kind == 7 ? output->columns * 2 : output->columns;
                for (int row = 0; row < output->rows && row < mask_count; row++)
                {
                    if (mask[row] == 0)
                        continue;
                    mbp_hash_word(&hash, (mbp_ull)row);
                    for (int column = 0; column < width; column++)
                        mbp_hash_word(&hash, values[row * width + column]);
                }
                return hash;
            }
            const mbp_ull* values = (const mbp_ull*)output->data_pointer;
            if (valid_rows != 0)
            {
                for (int index = 0; index < output->count * 2; index++)
                    mbp_hash_word(&hash, values[index]);
            }
            return hash;
        }

        __device__ mbp_ull mbp_random_next(mbp_ull* first, mbp_ull* second)
        {
            mbp_ull x = *first;
            mbp_ull y = *second;
            *first = y;
            x ^= x << 23;
            *second = x ^ y ^ (x >> 17) ^ (y >> 26);
            return *second + y;
        }

        __device__ int mbp_band_for_operation_count(
            const unsigned char* arena,
            int band_offset,
            int band_count,
            int operation_count)
        {
            int result = -1;
            int maximum = -1;
            for (int index = 0; index < band_count; index++)
            {
                int band = band_offset + index * 24;
                if (mbp_read_int(arena, band) == operation_count &&
                    mbp_read_int(arena, band + 4) > maximum)
                {
                    maximum = mbp_read_int(arena, band + 4);
                    result = index;
                }
            }
            return result;
        }

        __device__ bool mbp_decode_enumeration(
            unsigned char* arena,
            mbp_ull proposal_cursor,
            int operation_count,
            int terminal_count,
            int band_count,
            int maximum_arity,
            int operation_offset,
            int band_offset,
            int* selected_operations,
            int* selected_operands,
            int* candidate_operation_count,
            int* band_maximum)
        {
            int band_index = -1;
            for (int index = 0; index < band_count; index++)
            {
                int band = band_offset + index * 24;
                mbp_ull start = mbp_read_ull(arena, band + 8);
                mbp_ull count = mbp_read_ull(arena, band + 16);
                if (proposal_cursor >= start && proposal_cursor - start < count)
                {
                    band_index = index;
                    break;
                }
            }
            if (band_index < 0)
                return false;
            int band = band_offset + band_index * 24;
            *candidate_operation_count = mbp_read_int(arena, band);
            *band_maximum = mbp_read_int(arena, band + 4);
            mbp_ull local = proposal_cursor - mbp_read_ull(arena, band + 8);
            for (int node = 0; node < *candidate_operation_count; node++)
            {
                mbp_ull available = (mbp_ull)(terminal_count + node);
                mbp_ull choices = 0ull;
                for (int operation_index = 0; operation_index < operation_count; operation_index++)
                {
                    int operation = operation_offset + operation_index * 48;
                    choices = mbp_saturating_add(
                        choices,
                        mbp_power(available, mbp_read_int(arena, operation + 8)));
                }
                if (choices == 0ull)
                    return false;
                mbp_ull choice = local % choices;
                local /= choices;
                int selected = -1;
                for (int operation_index = 0; operation_index < operation_count; operation_index++)
                {
                    int operation = operation_offset + operation_index * 48;
                    int arity = mbp_read_int(arena, operation + 8);
                    mbp_ull span = mbp_power(available, arity);
                    if (choice < span)
                    {
                        selected = operation_index;
                        atomicExch(&selected_operations[node], operation_index);
                        for (int input = 0; input < maximum_arity; input++)
                            atomicExch(&selected_operands[node * maximum_arity + input], -1);
                        for (int input = 0; input < arity; input++)
                        {
                            atomicExch(
                                &selected_operands[node * maximum_arity + input],
                                (int)(choice % available));
                            choice /= available;
                        }
                        break;
                    }
                    choice -= span;
                }
                if (selected < 0)
                    return false;
            }
            return true;
        }

        __device__ int mbp_entry_program_offset(int objective_count)
        {
            return mbp_align(80 + objective_count * 8);
        }

        __device__ void mbp_load_entry_program(
            const unsigned char* arena,
            int entry,
            int objective_count,
            int program_operation_size,
            int maximum_arity,
            int* selected_operations,
            int* selected_operands,
            int* operation_count)
        {
            *operation_count = mbp_read_int(arena, entry + 12);
            int program = entry + mbp_entry_program_offset(objective_count);
            for (int node = 0; node < *operation_count; node++)
            {
                int source = program + node * program_operation_size;
                atomicExch(&selected_operations[node], mbp_read_int(arena, source));
                int arity = mbp_read_int(arena, source + 4);
                for (int input = 0; input < maximum_arity; input++)
                    atomicExch(
                        &selected_operands[node * maximum_arity + input],
                        input < arity ? mbp_read_int(arena, source + 8 + input * 4) : -1);
            }
        }

        __device__ int mbp_parent_count(
            const unsigned char* arena,
            int pareto_offset,
            int pareto_capacity,
            int quality_offset,
            int quality_capacity,
            int entry_size)
        {
            int count = 0;
            for (int index = 0; index < pareto_capacity; index++)
                if (mbp_read_int(arena, pareto_offset + index * entry_size) == 1)
                    count++;
            for (int index = 0; index < quality_capacity; index++)
                if (mbp_read_int(arena, quality_offset + index * entry_size) == 1)
                    count++;
            return count;
        }

        __device__ int mbp_parent_entry(
            const unsigned char* arena,
            int parent_index,
            int pareto_offset,
            int pareto_capacity,
            int quality_offset,
            int quality_capacity,
            int entry_size)
        {
            for (int index = 0; index < pareto_capacity; index++)
            {
                int entry = pareto_offset + index * entry_size;
                if (mbp_read_int(arena, entry) != 1)
                    continue;
                if (parent_index-- == 0)
                    return entry;
            }
            for (int index = 0; index < quality_capacity; index++)
            {
                int entry = quality_offset + index * entry_size;
                if (mbp_read_int(arena, entry) != 1)
                    continue;
                if (parent_index-- == 0)
                    return entry;
            }
            return -1;
        }

        __device__ bool mbp_generate_mutation(
            unsigned char* arena,
            int operation_count,
            int terminal_count,
            int maximum_operation_count,
            int maximum_arity,
            int operation_offset,
            int objective_count,
            int program_operation_size,
            int pareto_offset,
            int pareto_capacity,
            int quality_offset,
            int quality_capacity,
            int entry_size,
            mbp_ull* random_first,
            mbp_ull* random_second,
            int* selected_operations,
            int* selected_operands,
            int* candidate_operation_count)
        {
            int parents = mbp_parent_count(
                arena,
                pareto_offset,
                pareto_capacity,
                quality_offset,
                quality_capacity,
                entry_size);
            if (parents == 0)
                return false;
            int parent = mbp_parent_entry(
                arena,
                (int)(mbp_random_next(random_first, random_second) % (mbp_ull)parents),
                pareto_offset,
                pareto_capacity,
                quality_offset,
                quality_capacity,
                entry_size);
            mbp_load_entry_program(
                arena,
                parent,
                objective_count,
                program_operation_size,
                maximum_arity,
                selected_operations,
                selected_operands,
                candidate_operation_count);
            if (*candidate_operation_count <= 0 || *candidate_operation_count > maximum_operation_count)
                return false;
            int node = (int)(mbp_random_next(random_first, random_second) % (mbp_ull)*candidate_operation_count);
            int available = terminal_count + node;
            if ((mbp_random_next(random_first, random_second) & 1ull) == 0ull)
            {
                int selected = (int)(mbp_random_next(random_first, random_second) % (mbp_ull)operation_count);
                atomicExch(&selected_operations[node], selected);
                int arity = mbp_read_int(arena, operation_offset + selected * 48 + 8);
                for (int input = 0; input < maximum_arity; input++)
                    atomicExch(
                        &selected_operands[node * maximum_arity + input],
                        input < arity
                            ? (int)(mbp_random_next(random_first, random_second) % (mbp_ull)available)
                            : -1);
            }
            else
            {
                int operation = operation_offset + selected_operations[node] * 48;
                int arity = mbp_read_int(arena, operation + 8);
                if (arity == 0)
                    return true;
                int input = (int)(mbp_random_next(random_first, random_second) % (mbp_ull)arity);
                atomicExch(
                    &selected_operands[node * maximum_arity + input],
                    (int)(mbp_random_next(random_first, random_second) % (mbp_ull)available));
            }
            return true;
        }

        __device__ bool mbp_generate_crossover(
            unsigned char* arena,
            int terminal_count,
            int maximum_operation_count,
            int maximum_arity,
            int operation_offset,
            int objective_count,
            int program_operation_size,
            int pareto_offset,
            int pareto_capacity,
            int quality_offset,
            int quality_capacity,
            int entry_size,
            mbp_ull* random_first,
            mbp_ull* random_second,
            int* selected_operations,
            int* selected_operands,
            int* candidate_operation_count)
        {
            int parents = mbp_parent_count(
                arena,
                pareto_offset,
                pareto_capacity,
                quality_offset,
                quality_capacity,
                entry_size);
            if (parents < 2)
                return false;
            int first_parent_index = (int)(mbp_random_next(random_first, random_second) % (mbp_ull)parents);
            int second_parent_index = (int)(mbp_random_next(random_first, random_second) % (mbp_ull)(parents - 1));
            if (second_parent_index >= first_parent_index)
                second_parent_index++;
            int first_parent = mbp_parent_entry(
                arena, first_parent_index, pareto_offset, pareto_capacity,
                quality_offset, quality_capacity, entry_size);
            int second_parent = mbp_parent_entry(
                arena, second_parent_index, pareto_offset, pareto_capacity,
                quality_offset, quality_capacity, entry_size);
            int first_count = mbp_read_int(arena, first_parent + 12);
            int second_count = mbp_read_int(arena, second_parent + 12);
            int count = first_count > second_count ? first_count : second_count;
            if (count <= 0 || count > maximum_operation_count)
                return false;
            int first_program = first_parent + mbp_entry_program_offset(objective_count);
            int second_program = second_parent + mbp_entry_program_offset(objective_count);
            for (int node = 0; node < count; node++)
            {
                int selected_parent;
                if (node >= first_count)
                    selected_parent = second_program;
                else if (node >= second_count)
                    selected_parent = first_program;
                else
                    selected_parent = (mbp_random_next(random_first, random_second) & 1ull) == 0ull
                        ? first_program
                        : second_program;
                int source = selected_parent + node * program_operation_size;
                int selected = mbp_read_int(arena, source);
                atomicExch(&selected_operations[node], selected);
                int arity = mbp_read_int(arena, operation_offset + selected * 48 + 8);
                int stored_arity = mbp_read_int(arena, source + 4);
                int available = terminal_count + node;
                for (int input = 0; input < maximum_arity; input++)
                {
                    if (input >= arity)
                    {
                        atomicExch(&selected_operands[node * maximum_arity + input], -1);
                        continue;
                    }
                    int operand = input < stored_arity ? mbp_read_int(arena, source + 8 + input * 4) : -1;
                    if (operand < 0 || operand >= available)
                        operand = (int)(mbp_random_next(random_first, random_second) % (mbp_ull)available);
                    atomicExch(&selected_operands[node * maximum_arity + input], operand);
                }
            }
            *candidate_operation_count = count;
            return true;
        }

        __device__ bool mbp_generate_immigrant(
            unsigned char* arena,
            int operation_count,
            int terminal_count,
            int band_count,
            int maximum_arity,
            int operation_offset,
            int band_offset,
            mbp_ull* random_first,
            mbp_ull* random_second,
            int* selected_operations,
            int* selected_operands,
            int* candidate_operation_count,
            int* band_maximum)
        {
            if (band_count <= 0)
                return false;
            int band_index = (int)(mbp_random_next(random_first, random_second) % (mbp_ull)band_count);
            int band = band_offset + band_index * 24;
            *candidate_operation_count = mbp_read_int(arena, band);
            *band_maximum = mbp_read_int(arena, band + 4);
            for (int node = 0; node < *candidate_operation_count; node++)
            {
                int selected = (int)(mbp_random_next(random_first, random_second) % (mbp_ull)operation_count);
                atomicExch(&selected_operations[node], selected);
                int arity = mbp_read_int(arena, operation_offset + selected * 48 + 8);
                int available = terminal_count + node;
                for (int input = 0; input < maximum_arity; input++)
                    atomicExch(
                        &selected_operands[node * maximum_arity + input],
                        input < arity
                            ? (int)(mbp_random_next(random_first, random_second) % (mbp_ull)available)
                            : -1);
            }
            return true;
        }

        __device__ bool mbp_type_program(
            const unsigned char* arena,
            int operation_offset,
            int operation_input_type_offset,
            int terminal_offset,
            int type_offset,
            int terminal_count,
            int operation_count,
            int maximum_arity,
            int output_type,
            const int* selected_operations,
            const int* selected_operands,
            int* selected_types,
            int* selected_lookbacks,
            int* maximum_lookback,
            mbp_ull* deterministic_cost)
        {
            for (int terminal = 0; terminal < terminal_count; terminal++)
            {
                int descriptor = terminal_offset + terminal * 32;
                atomicExch(&selected_types[terminal], mbp_read_int(arena, descriptor));
                atomicExch(&selected_lookbacks[terminal], mbp_read_int(arena, descriptor + 8));
            }
            *maximum_lookback = 0;
            *deterministic_cost = 0ull;
            for (int node = 0; node < operation_count; node++)
            {
                int selected = selected_operations[node];
                int operation = operation_offset + selected * 48;
                int arity = mbp_read_int(arena, operation + 8);
                int input_base = mbp_read_int(arena, operation + 16);
                int lookback = 0;
                for (int input = 0; input < arity; input++)
                {
                    int operand = selected_operands[node * maximum_arity + input];
                    if (operand < 0 || operand >= terminal_count + node)
                        return false;
                    int expected = mbp_read_int(arena, operation_input_type_offset + (input_base + input) * 4);
                    if (!mbp_types_compatible(arena, type_offset, expected, selected_types[operand]))
                        return false;
                    if (selected_lookbacks[operand] > lookback)
                        lookback = selected_lookbacks[operand];
                }
                int output_node = terminal_count + node;
                atomicExch(&selected_types[output_node], mbp_read_int(arena, operation + 12));
                atomicExch(&selected_lookbacks[output_node], lookback);
                *deterministic_cost += mbp_read_ull(arena, operation + 24);
            }
            int final_node = terminal_count + operation_count - 1;
            if (operation_count <= 0 ||
                !mbp_types_compatible(arena, type_offset, output_type, selected_types[final_node]))
            {
                return false;
            }
            *maximum_lookback = selected_lookbacks[final_node];
            return true;
        }

        __device__ int mbp_execute_program(
            unsigned char* arena,
            int operation_offset,
            int terminal_offset,
            int type_offset,
            int immutable_slot_offset,
            int candidate_slot_offset,
            int candidate_payload_offset,
            int scratch_offset,
            int input_pointer_offset,
            int payload_stride,
            int terminal_count,
            int operation_count,
            int maximum_operation_count,
            int maximum_arity,
            int band_maximum,
            const int* selected_operations,
            const int* selected_operands,
            const int* selected_types,
            int* cooperative_status)
        {
            MathBlockSlot* slots = (MathBlockSlot*)(arena + candidate_slot_offset);
            const MathBlockSlot** input_pointers = (const MathBlockSlot**)(arena + input_pointer_offset);
            if (threadIdx.x == 0)
            {
                *cooperative_status = 1;
                for (int terminal = 0; terminal < terminal_count; terminal++)
                {
                    int immutable_index = mbp_read_int(arena, terminal_offset + terminal * 32 + 4);
                    slots[terminal] = *((const MathBlockSlot*)(arena + immutable_slot_offset + immutable_index * 48));
                }
            }
            __syncthreads();
            for (int node = 0; node < operation_count; node++)
            {
                int selected = selected_operations[node];
                int operation = operation_offset + selected * 48;
                int arity = mbp_read_int(arena, operation + 8);
                int output_index = terminal_count + node;
                MathBlockSlot* output = &slots[output_index];
                if (threadIdx.x == 0)
                {
                    for (int input = 0; input < arity; input++)
                        input_pointers[input] = &slots[selected_operands[node * maximum_arity + input]];
                    mbp_initialize_slot(
                        arena,
                        type_offset,
                        selected_types[output_index],
                        output,
                        (mbp_ull)(arena + candidate_payload_offset + node * payload_stride),
                        (mbp_ull)(arena + scratch_offset),
                        band_maximum);
                }
                __syncthreads();
                mb_population_dispatch(
                    mbp_read_int(arena, operation),
                    mbp_read_int(arena, operation + 4),
                    input_pointers,
                    arity,
                    output);
                __syncthreads();
                if (threadIdx.x == 0)
                {
                    if (output->count < 0 ||
                        output->count > band_maximum ||
                        output->count > output->capacity)
                    {
                        *cooperative_status = -1;
                    }
                    else if (!output->valid)
                    {
                        *cooperative_status = 0;
                    }
                    else if (!mbp_slot_matches_type(
                            arena,
                            type_offset,
                            selected_types[output_index],
                            output) ||
                        !mbp_slot_is_finite(
                            arena,
                            type_offset,
                            selected_types[output_index],
                            output))
                    {
                        *cooperative_status = 0;
                    }
                }
                __syncthreads();
                if (*cooperative_status != 1)
                    return *cooperative_status;
            }
            return *cooperative_status;
        }

        __device__ bool mbp_create_mask(
            const unsigned char* arena,
            int type_offset,
            int output_type,
            const MathBlockSlot* output,
            int history_offset,
            int history_count,
            int maximum_lookback,
            MathBlockSlot* mask_slot,
            int* mask_values,
            int* cooperative_status)
        {
            if (threadIdx.x == 0)
            {
                int kind = mbp_read_int(arena, type_offset + output_type * 48);
                int row_count = mbp_validity_rows(kind, output);
                *cooperative_status = row_count >= 0 && row_count <= history_count ? 1 : 0;
                if (*cooperative_status != 0)
                {
                    mask_slot->scalar_value = 0.0;
                    mask_slot->data_pointer = (mbp_ull)mask_values;
                    mask_slot->scratch_pointer = 0ull;
                    mask_slot->boolean_value = 0;
                    mask_slot->valid = 1;
                    mask_slot->rows = row_count;
                    mask_slot->columns = 0;
                    mask_slot->count = row_count;
                    mask_slot->capacity = history_count;
                }
            }
            __syncthreads();
            if (*cooperative_status == 0)
                return false;
            for (int row = (int)threadIdx.x; row < mask_slot->count; row += (int)blockDim.x)
                mask_values[row] = mbp_read_int(arena, history_offset + row * 4) >= maximum_lookback ? 1 : 0;
            __syncthreads();
            return true;
        }

        __device__ bool mbp_execute_objectives(
            unsigned char* arena,
            int objective_node_offset,
            int objective_input_offset,
            int objective_source_offset,
            int type_offset,
            int immutable_slot_offset,
            int objective_slot_offset,
            int objective_payload_offset,
            int scratch_offset,
            int input_pointer_offset,
            int scratch_bytes,
            int objective_node_count,
            int objective_count,
            const MathBlockSlot* candidate_output,
            const MathBlockSlot* validity_mask,
            int operation_count,
            int maximum_lookback,
            mbp_ull deterministic_cost,
            int age,
            unsigned char* objective_destination,
            int* cooperative_status)
        {
            MathBlockSlot* slots = (MathBlockSlot*)(arena + objective_slot_offset);
            const MathBlockSlot** input_pointers = (const MathBlockSlot**)(arena + input_pointer_offset);
            if (threadIdx.x == 0)
                *cooperative_status = 1;
            __syncthreads();
            for (int node = 0; node < objective_node_count; node++)
            {
                int descriptor = objective_node_offset + node * 40;
                int kind = mbp_read_int(arena, descriptor);
                if (kind >= 0 && kind <= 2)
                {
                    if (threadIdx.x == 0)
                    {
                        if (kind == 0)
                            slots[node] = *candidate_output;
                        else if (kind == 1)
                            slots[node] = *validity_mask;
                        else
                        {
                            int immutable_index = mbp_read_int(arena, descriptor + 24);
                            slots[node] = *((const MathBlockSlot*)(
                                arena + immutable_slot_offset + immutable_index * 48));
                        }
                        int type_id = mbp_read_int(arena, descriptor + 4);
                        *cooperative_status = mbp_slot_matches_type(
                                arena,
                                type_offset,
                                type_id,
                                &slots[node]) &&
                            mbp_slot_is_finite(arena, type_offset, type_id, &slots[node]);
                    }
                    __syncthreads();
                    if (*cooperative_status == 0)
                        return false;
                    continue;
                }
                int required_scratch_bytes = mbp_read_int(arena, descriptor + 36);
                int arity = mbp_read_int(arena, descriptor + 16);
                int input_base = mbp_read_int(arena, descriptor + 20);
                if (threadIdx.x == 0)
                {
                    *cooperative_status = kind == 3 && required_scratch_bytes >= 0 &&
                        required_scratch_bytes <= scratch_bytes;
                    for (int input = 0; *cooperative_status != 0 && input < arity; input++)
                    {
                        int source = mbp_read_int(arena, objective_input_offset + (input_base + input) * 4);
                        if (source < 0 || source >= node)
                            *cooperative_status = 0;
                        else
                            input_pointers[input] = &slots[source];
                    }
                    if (*cooperative_status != 0)
                    {
                        mbp_initialize_slot(
                            arena,
                            type_offset,
                            mbp_read_int(arena, descriptor + 4),
                            &slots[node],
                            (mbp_ull)(arena + objective_payload_offset + mbp_read_int(arena, descriptor + 32)),
                            (mbp_ull)(arena + scratch_offset),
                            mbp_read_int(arena, descriptor + 28));
                    }
                }
                __syncthreads();
                if (*cooperative_status == 0)
                    return false;
                mb_population_dispatch(
                    mbp_read_int(arena, descriptor + 8),
                    mbp_read_int(arena, descriptor + 12),
                    input_pointers,
                    arity,
                    &slots[node]);
                __syncthreads();
                if (threadIdx.x == 0)
                {
                    int type_id = mbp_read_int(arena, descriptor + 4);
                    *cooperative_status = mbp_slot_matches_type(
                            arena,
                            type_offset,
                            type_id,
                            &slots[node]) &&
                        mbp_slot_is_finite(arena, type_offset, type_id, &slots[node]);
                }
                __syncthreads();
                if (*cooperative_status == 0)
                    return false;
            }
            if (threadIdx.x == 0)
            {
                for (int objective = 0; objective < objective_count; objective++)
                {
                    int descriptor = objective_source_offset + objective * 16;
                    int source_kind = mbp_read_int(arena, descriptor);
                    double value = 0.0;
                    if (source_kind == 0)
                    {
                        int source_node = mbp_read_int(arena, descriptor + 4);
                        if (source_node < 0 || source_node >= objective_node_count ||
                            !slots[source_node].valid)
                        {
                            *cooperative_status = 0;
                            break;
                        }
                        value = slots[source_node].scalar_value;
                    }
                    else if (source_kind == 1)
                        value = (double)operation_count;
                    else if (source_kind == 2)
                        value = (double)maximum_lookback;
                    else if (source_kind == 3)
                        value = (double)deterministic_cost;
                    else if (source_kind == 4)
                        value = (double)age;
                    else
                    {
                        *cooperative_status = 0;
                        break;
                    }
                    if (!isfinite(value))
                    {
                        *cooperative_status = 0;
                        break;
                    }
                    *((double*)(objective_destination + objective * 8)) = value;
                }
            }
            __syncthreads();
            return *cooperative_status != 0;
        }

        __device__ int mbp_quality_cell(
            const unsigned char* arena,
            int quality_dimension_offset,
            int quality_dimension_count,
            const unsigned char* objectives)
        {
            int cell = 0;
            for (int dimension = 0; dimension < quality_dimension_count; dimension++)
            {
                int descriptor = quality_dimension_offset + dimension * 32;
                int objective = mbp_read_int(arena, descriptor);
                int bins = mbp_read_int(arena, descriptor + 4);
                int multiplier = mbp_read_int(arena, descriptor + 8);
                double minimum = __longlong_as_double((long long)mbp_read_ull(arena, descriptor + 16));
                double maximum = __longlong_as_double((long long)mbp_read_ull(arena, descriptor + 24));
                double value = *((const double*)(objectives + objective * 8));
                if (!isfinite(value))
                    return -1;
                int bin;
                if (value <= minimum)
                    bin = 0;
                else if (value >= maximum)
                    bin = bins - 1;
                else
                    bin = (int)(((value - minimum) / (maximum - minimum)) * (double)bins);
                if (bin < 0)
                    bin = 0;
                if (bin >= bins)
                    bin = bins - 1;
                cell += bin * multiplier;
            }
            return cell;
        }

        __device__ bool mbp_dominates(
            const unsigned char* arena,
            int objective_source_offset,
            int objective_count,
            const unsigned char* first,
            const unsigned char* second)
        {
            bool strict = false;
            for (int objective = 0; objective < objective_count; objective++)
            {
                double left = *((const double*)(first + objective * 8));
                double right = *((const double*)(second + objective * 8));
                int direction = mbp_read_int(arena, objective_source_offset + objective * 16 + 8);
                if (direction == 0)
                {
                    if (left > right)
                        return false;
                    if (left < right)
                        strict = true;
                }
                else
                {
                    if (left < right)
                        return false;
                    if (left > right)
                        strict = true;
                }
            }
            return strict;
        }

        __device__ int mbp_compact_pareto(
            unsigned char* arena,
            int pareto_offset,
            int pareto_capacity,
            int entry_size)
        {
            int destination = 0;
            for (int index = 0; index < pareto_capacity; index++)
            {
                int entry = pareto_offset + index * entry_size;
                if (mbp_read_int(arena, entry) != 1)
                    continue;
                if (index != destination)
                {
                    mbp_copy(
                        arena + pareto_offset + destination * entry_size,
                        arena + entry,
                        entry_size);
                    mbp_clear(arena + entry, entry_size);
                }
                destination++;
            }
            return destination;
        }

        __device__ bool mbp_entry_matches_semantic_and_objectives(
            unsigned char* arena,
            int candidate,
            int entry,
            int objective_count)
        {
            if (mbp_read_int(arena, entry) != 1 ||
                mbp_read_ull(arena, entry + 64) != mbp_read_ull(arena, candidate + 64) ||
                mbp_read_ull(arena, entry + 72) != mbp_read_ull(arena, candidate + 72))
            {
                return false;
            }
            for (int objective = 0; objective < objective_count; objective++)
            {
                if (mbp_read_ull(arena, entry + 80 + objective * 8) !=
                    mbp_read_ull(arena, candidate + 80 + objective * 8))
                {
                    return false;
                }
            }
            return true;
        }

        __device__ bool mbp_has_equivalent_semantic_entry(
            unsigned char* arena,
            int candidate,
            int pareto_offset,
            int pareto_count,
            int quality_offset,
            int quality_capacity,
            int entry_size,
            int objective_count)
        {
            for (int index = 0; index < pareto_count; index++)
            {
                if (mbp_entry_matches_semantic_and_objectives(
                        arena,
                        candidate,
                        pareto_offset + index * entry_size,
                        objective_count))
                {
                    return true;
                }
            }
            for (int index = 0; index < quality_capacity; index++)
            {
                if (mbp_entry_matches_semantic_and_objectives(
                        arena,
                        candidate,
                        quality_offset + index * entry_size,
                        objective_count))
                {
                    return true;
                }
            }
            return false;
        }

        __device__ bool mbp_insert_pareto(
            unsigned char* arena,
            int candidate,
            int pareto_offset,
            int pareto_capacity,
            int entry_size,
            int objective_source_offset,
            int objective_count,
            int* pareto_count)
        {
            const unsigned char* candidate_objectives = arena + candidate + 80;
            for (int index = 0; index < *pareto_count; index++)
            {
                int entry = pareto_offset + index * entry_size;
                if (mbp_dominates(
                        arena,
                        objective_source_offset,
                        objective_count,
                        arena + entry + 80,
                        candidate_objectives))
                {
                    return false;
                }
            }
            for (int index = 0; index < *pareto_count; index++)
            {
                int entry = pareto_offset + index * entry_size;
                if (mbp_dominates(
                        arena,
                        objective_source_offset,
                        objective_count,
                        candidate_objectives,
                        arena + entry + 80))
                {
                    mbp_write_int(arena, entry, 0);
                }
            }
            *pareto_count = mbp_compact_pareto(arena, pareto_offset, pareto_capacity, entry_size);
            if (*pareto_count < pareto_capacity)
            {
                int destination = pareto_offset + *pareto_count * entry_size;
                mbp_copy(arena + destination, arena + candidate, entry_size);
                mbp_write_int(arena, destination, 1);
                mbp_write_int(arena, destination + 16, -1);
                (*pareto_count)++;
                return true;
            }
            MbpHash candidate_hash;
            candidate_hash.first = mbp_read_ull(arena, candidate + 48);
            candidate_hash.second = mbp_read_ull(arena, candidate + 56);
            int worst = 0;
            MbpHash worst_hash;
            worst_hash.first = mbp_read_ull(arena, pareto_offset + 48);
            worst_hash.second = mbp_read_ull(arena, pareto_offset + 56);
            for (int index = 1; index < pareto_capacity; index++)
            {
                MbpHash hash;
                hash.first = mbp_read_ull(arena, pareto_offset + index * entry_size + 48);
                hash.second = mbp_read_ull(arena, pareto_offset + index * entry_size + 56);
                if (mbp_hash_less(worst_hash, hash))
                {
                    worst = index;
                    worst_hash = hash;
                }
            }
            if (!mbp_hash_less(candidate_hash, worst_hash))
                return false;
            int destination = pareto_offset + worst * entry_size;
            mbp_copy(arena + destination, arena + candidate, entry_size);
            mbp_write_int(arena, destination, 1);
            mbp_write_int(arena, destination + 16, -1);
            return true;
        }

        __device__ bool mbp_insert_quality(
            unsigned char* arena,
            int candidate,
            int quality_offset,
            int quality_capacity,
            int entry_size,
            int quality_objective,
            int objective_source_offset,
            int cell)
        {
            if (cell < 0 || cell >= quality_capacity)
                return false;
            int destination = quality_offset + cell * entry_size;
            bool replace = mbp_read_int(arena, destination) != 1;
            if (!replace)
            {
                double candidate_value = *((double*)(arena + candidate + 80 + quality_objective * 8));
                double current_value = *((double*)(arena + destination + 80 + quality_objective * 8));
                int direction = mbp_read_int(arena, objective_source_offset + quality_objective * 16 + 8);
                replace = direction == 0 ? candidate_value < current_value : candidate_value > current_value;
                if (candidate_value == current_value)
                {
                    MbpHash candidate_hash;
                    candidate_hash.first = mbp_read_ull(arena, candidate + 48);
                    candidate_hash.second = mbp_read_ull(arena, candidate + 56);
                    MbpHash current_hash;
                    current_hash.first = mbp_read_ull(arena, destination + 48);
                    current_hash.second = mbp_read_ull(arena, destination + 56);
                    replace = mbp_hash_less(candidate_hash, current_hash);
                }
            }
            if (!replace)
                return false;
            mbp_copy(arena + destination, arena + candidate, entry_size);
            mbp_write_int(arena, destination, 1);
            mbp_write_int(arena, destination + 16, cell);
            return true;
        }

        __device__ void mbp_update_age_objectives(
            unsigned char* arena,
            int archive_offset,
            int archive_capacity,
            int entry_size,
            int objective_source_offset,
            int objective_count,
            int maximum_age)
        {
            if (threadIdx.x == 0)
            {
                for (int index = 0; index < archive_capacity; index++)
                {
                    int entry = archive_offset + index * entry_size;
                    if (mbp_read_int(arena, entry) != 1)
                        continue;
                    int age = mbp_read_int(arena, entry + 8) + 1;
                    if (age > maximum_age)
                    {
                        mbp_write_int(arena, entry, 0);
                        continue;
                    }
                    mbp_write_int(arena, entry + 8, age);
                    for (int objective = 0; objective < objective_count; objective++)
                    {
                        if (mbp_read_int(arena, objective_source_offset + objective * 16) == 4)
                            *((double*)(arena + entry + 80 + objective * 8)) = (double)age;
                    }
                }
            }
            __syncthreads();
        }

        __device__ void mbp_write_program(
            unsigned char* arena,
            int entry,
            int objective_count,
            int program_operation_size,
            int maximum_arity,
            int operation_offset,
            int operation_count,
            const int* selected_operations,
            const int* selected_operands)
        {
            int program = entry + mbp_entry_program_offset(objective_count);
            for (int node = 0; node < operation_count; node++)
            {
                int destination = program + node * program_operation_size;
                int selected = selected_operations[node];
                int arity = mbp_read_int(arena, operation_offset + selected * 48 + 8);
                mbp_write_int(arena, destination, selected);
                mbp_write_int(arena, destination + 4, arity);
                for (int input = 0; input < maximum_arity; input++)
                    mbp_write_int(
                        arena,
                        destination + 8 + input * 4,
                        input < arity ? selected_operands[node * maximum_arity + input] : -1);
            }
        }

        __device__ void mbp_prepare_entry(
            unsigned char* arena,
            int entry,
            int entry_size,
            int source,
            int operation_count,
            mbp_ull trial_cursor,
            mbp_ull proposal_cursor,
            MbpHash structural,
            int objective_count,
            int program_operation_size,
            int maximum_arity,
            int operation_offset,
            const int* selected_operations,
            const int* selected_operands)
        {
            mbp_clear(arena + entry, entry_size);
            mbp_write_int(arena, entry + 4, source);
            mbp_write_int(arena, entry + 8, 0);
            mbp_write_int(arena, entry + 12, operation_count);
            mbp_write_int(arena, entry + 16, -1);
            mbp_write_ull(arena, entry + 32, trial_cursor);
            mbp_write_ull(arena, entry + 40, proposal_cursor);
            mbp_write_ull(arena, entry + 48, structural.first);
            mbp_write_ull(arena, entry + 56, structural.second);
            mbp_write_program(
                arena,
                entry,
                objective_count,
                program_operation_size,
                maximum_arity,
                operation_offset,
                operation_count,
                selected_operations,
                selected_operands);
        }

        __device__ void mbp_fail(unsigned char* arena, int compact_offset, int status)
        {
            mbp_clear(arena + compact_offset, 144);
            mbp_write_int(arena, compact_offset, status);
        }

        extern "C" __global__ void mathblocks_program_population_search_begin(unsigned char* arena)
        {
            if (blockIdx.x != 0)
                return;
            if (mbp_read_int(arena, 0) != (int)0x4d425334 || mbp_read_int(arena, 4) != 11)
                return;

            int fingerprint_capacity = mbp_read_int(arena, 40);
            int pareto_capacity = mbp_read_int(arena, 56);
            int quality_capacity = mbp_read_int(arena, 60);
            int entry_size = mbp_read_int(arena, 112);
            int accepted_state_offset = mbp_header_offset(arena, 23);
            int accepted_structural_offset = mbp_header_offset(arena, 24);
            int accepted_semantic_offset = mbp_header_offset(arena, 25);
            int accepted_pareto_offset = mbp_header_offset(arena, 26);
            int accepted_quality_offset = mbp_header_offset(arena, 27);
            int working_state_offset = mbp_header_offset(arena, 28);
            int working_structural_offset = mbp_header_offset(arena, 29);
            int working_semantic_offset = mbp_header_offset(arena, 30);
            int working_pareto_offset = mbp_header_offset(arena, 31);
            int working_quality_offset = mbp_header_offset(arena, 32);
            int compact_offset = mbp_header_offset(arena, 34);

            mbp_copy(arena + working_state_offset, arena + accepted_state_offset, 144);
            mbp_copy(
                arena + working_structural_offset,
                arena + accepted_structural_offset,
                fingerprint_capacity * 16);
            mbp_copy(
                arena + working_semantic_offset,
                arena + accepted_semantic_offset,
                fingerprint_capacity * 16);
            mbp_copy(
                arena + working_pareto_offset,
                arena + accepted_pareto_offset,
                pareto_capacity * entry_size);
            mbp_copy(
                arena + working_quality_offset,
                arena + accepted_quality_offset,
                quality_capacity * entry_size);
            mbp_clear(arena + compact_offset, 144);
        }

        extern "C" __global__ void mathblocks_program_population_search_setup(unsigned char* arena)
        {
            if (blockIdx.x != 0)
                return;
            __shared__ int cooperative_status;
            if (mbp_read_int(arena, 0) != (int)0x4d425334 || mbp_read_int(arena, 4) != 11)
                return;

            int grammar_operation_count = mbp_read_int(arena, 8);
            int terminal_count = mbp_read_int(arena, 12);
            int band_count = mbp_read_int(arena, 20);
            int maximum_operation_count = mbp_read_int(arena, 24);
            int maximum_band_elements = mbp_read_int(arena, 28);
            int maximum_value_elements = mbp_read_int(arena, 32);
            int proposals_per_cycle = mbp_read_int(arena, 36);
            int cycle_work_limit = mbp_read_int(arena, 320);
            int proposal_wave_size = mbp_read_int(arena, 324);
            int proposal_wave_slot_offset = mbp_read_int(arena, 332);
            int proposal_wave_slot_bytes = mbp_read_int(arena, 336);
            int proposal_wave_snapshot_pareto_offset = mbp_read_int(arena, 340);
            int proposal_wave_snapshot_quality_offset = mbp_read_int(arena, 344);
            int fingerprint_capacity = mbp_read_int(arena, 40);
            int output_type = mbp_read_int(arena, 44);
            int objective_node_count = mbp_read_int(arena, 48);
            int objective_count = mbp_read_int(arena, 52);
            int pareto_capacity = mbp_read_int(arena, 56);
            int quality_capacity = mbp_read_int(arena, 60);
            int quality_dimension_count = mbp_read_int(arena, 64);
            int maximum_age = mbp_read_int(arena, 68);
            int include_rejected = mbp_read_int(arena, 72);
            int mutation_trials = mbp_read_int(arena, 76);
            int crossover_trials = mbp_read_int(arena, 80);
            int immigrant_trials = mbp_read_int(arena, 84);
            int evolution_pattern = mbp_read_int(arena, 88);
            int quality_objective = mbp_read_int(arena, 92);
            int maximum_arity = mbp_read_int(arena, 96);
            int scratch_bytes = mbp_read_int(arena, 100);
            int payload_stride = mbp_read_int(arena, 104);
            int program_operation_size = mbp_read_int(arena, 108);
            int entry_size = mbp_read_int(arena, 112);
            int history_count = mbp_read_int(arena, 120);
            int refresh_count = mbp_read_int(arena, 124);

            int operation_offset = mbp_header_offset(arena, 0);
            int operation_input_type_offset = mbp_header_offset(arena, 1);
            int terminal_offset = mbp_header_offset(arena, 2);
            int type_offset = mbp_header_offset(arena, 3);
            int band_offset = mbp_header_offset(arena, 4);
            int immutable_slot_offset = mbp_header_offset(arena, 5);
            int objective_node_offset = mbp_header_offset(arena, 7);
            int objective_input_offset = mbp_header_offset(arena, 8);
            int objective_source_offset = mbp_header_offset(arena, 9);
            int quality_dimension_offset = mbp_header_offset(arena, 10);
            int history_offset = mbp_header_offset(arena, 11);
            int candidate_slot_offset = mbp_header_offset(arena, 12);
            int objective_slot_offset = mbp_header_offset(arena, 13);
            int mask_slot_offset = mbp_header_offset(arena, 14);
            int candidate_payload_offset = mbp_header_offset(arena, 15);
            int objective_payload_offset = mbp_header_offset(arena, 16);
            int mask_payload_offset = mbp_header_offset(arena, 17);
            int scratch_offset = mbp_header_offset(arena, 18);
            int input_pointer_offset = mbp_header_offset(arena, 19);
            int selected_operation_offset = mbp_header_offset(arena, 20);
            int selected_operand_offset = mbp_header_offset(arena, 21);
            int selected_type_offset = mbp_header_offset(arena, 22);
            int accepted_state_offset = mbp_header_offset(arena, 23);
            int accepted_structural_offset = mbp_header_offset(arena, 24);
            int accepted_semantic_offset = mbp_header_offset(arena, 25);
            int accepted_pareto_offset = mbp_header_offset(arena, 26);
            int accepted_quality_offset = mbp_header_offset(arena, 27);
            int working_state_offset = mbp_header_offset(arena, 28);
            int working_structural_offset = mbp_header_offset(arena, 29);
            int working_semantic_offset = mbp_header_offset(arena, 30);
            int working_pareto_offset = mbp_header_offset(arena, 31);
            int working_quality_offset = mbp_header_offset(arena, 32);
            int refresh_offset = mbp_header_offset(arena, 33);
            int compact_offset = mbp_header_offset(arena, 34);
            int compact_size = mbp_header_offset(arena, 35);
            int compact_structural_offset = mbp_header_offset(arena, 36);
            int compact_semantic_offset = mbp_header_offset(arena, 37);
            int compact_pareto_offset = mbp_header_offset(arena, 38);
            int compact_quality_offset = mbp_header_offset(arena, 39);
            int compact_trial_offset = mbp_header_offset(arena, 40);
            mbp_ull total_proposals = mbp_read_ull(arena, 296);
            mbp_ull enumeration_limit = mbp_read_ull(arena, 304);
            mbp_ull maximum_trials = mbp_read_ull(arena, 312);

            if (grammar_operation_count <= 0 || terminal_count <= 0 || band_count <= 0 ||
                maximum_operation_count <= 0 || maximum_band_elements <= 0 ||
                maximum_value_elements <= 0 || proposals_per_cycle <= 0 ||
                cycle_work_limit <= 0 || proposal_wave_size <= 0 ||
                proposal_wave_slot_offset <= 0 ||
                proposal_wave_slot_bytes / proposal_wave_size < entry_size ||
                proposal_wave_snapshot_pareto_offset <= 0 ||
                proposal_wave_snapshot_quality_offset <= 0 ||
                fingerprint_capacity <= 0 ||
                objective_node_count <= 0 || objective_count <= 0 || pareto_capacity <= 0 ||
                quality_capacity <= 0 || maximum_arity < 0 || history_count <= 0 ||
                compact_size < 144 || enumeration_limit > total_proposals)
            {
                mbp_fail(arena, compact_offset, 4);
                return;
            }

            int structural_count = mbp_read_int(arena, accepted_state_offset);
            int semantic_count = mbp_read_int(arena, accepted_state_offset + 4);
            int pareto_count = mbp_read_int(arena, accepted_state_offset + 8);
            int quality_count = mbp_read_int(arena, accepted_state_offset + 12);
            mbp_ull enumeration_cursor = mbp_read_ull(arena, accepted_state_offset + 16);
            mbp_ull trial_cursor = mbp_read_ull(arena, accepted_state_offset + 24);
            mbp_ull cycle_count = mbp_read_ull(arena, accepted_state_offset + 32);
            mbp_ull random_first = mbp_read_ull(arena, accepted_state_offset + 40);
            mbp_ull random_second = mbp_read_ull(arena, accepted_state_offset + 48);
            mbp_ull structural_duplicates = mbp_read_ull(arena, accepted_state_offset + 56);
            mbp_ull semantic_duplicates = mbp_read_ull(arena, accepted_state_offset + 64);
            mbp_ull evaluated = mbp_read_ull(arena, accepted_state_offset + 72);
            mbp_ull accepted = mbp_read_ull(arena, accepted_state_offset + 80);
            mbp_ull envelope_generation = mbp_read_ull(arena, accepted_state_offset + 88);
            int refresh_cursor = mbp_read_int(arena, accepted_state_offset + 96);
            int accepted_refresh_count = mbp_read_int(arena, accepted_state_offset + 100);
            mbp_ull enumeration_trial_count = mbp_read_ull(arena, accepted_state_offset + 104);
            mbp_ull wave_cursor = mbp_read_ull(arena, accepted_state_offset + 112);
            if (structural_count < 0 || structural_count > fingerprint_capacity ||
                semantic_count < 0 || semantic_count > fingerprint_capacity ||
                pareto_count < 0 || pareto_count > pareto_capacity ||
                quality_count < 0 || quality_count > quality_capacity ||
                enumeration_cursor > total_proposals ||
                enumeration_trial_count > enumeration_limit ||
                enumeration_trial_count > enumeration_cursor ||
                wave_cursor > trial_cursor ||
                enumeration_trial_count > trial_cursor || trial_cursor > maximum_trials ||
                random_first == 0ull && random_second == 0ull ||
                refresh_cursor < 0 || refresh_cursor > refresh_count ||
                accepted_refresh_count != refresh_count)
            {
                mbp_fail(arena, compact_offset, 4);
                return;
            }

            mbp_clear(arena + compact_offset, compact_size);

            mbp_update_age_objectives(
                arena,
                working_pareto_offset,
                pareto_capacity,
                entry_size,
                objective_source_offset,
                objective_count,
                maximum_age);
            mbp_update_age_objectives(
                arena,
                working_quality_offset,
                quality_capacity,
                entry_size,
                objective_source_offset,
                objective_count,
                maximum_age);
            pareto_count = mbp_compact_pareto(
                arena, working_pareto_offset, pareto_capacity, entry_size);
            quality_count = 0;
            for (int cell = 0; cell < quality_capacity; cell++)
                if (mbp_read_int(arena, working_quality_offset + cell * entry_size) == 1)
                    quality_count++;

            int* selected_operations = (int*)(arena + selected_operation_offset);
            int* selected_operands = (int*)(arena + selected_operand_offset);
            int total_candidate_nodes = terminal_count + maximum_operation_count;
            int* selected_types = (int*)(arena + selected_type_offset);
            int* selected_lookbacks = selected_types + total_candidate_nodes;
            MathBlockSlot* candidate_slots = (MathBlockSlot*)(arena + candidate_slot_offset);
            MathBlockSlot* mask_slot = (MathBlockSlot*)(arena + mask_slot_offset);
            int* mask_values = (int*)(arena + mask_payload_offset);
            int new_structural_count = 0;
            int new_semantic_count = 0;
            int trial_result_count = 0;
            int processed = 0;
            int enumeration_scan_count = 0;

            while (processed < cycle_work_limit && refresh_cursor < refresh_count)
            {
                int refresh_entry = refresh_offset + refresh_cursor * entry_size;
                int candidate_operation_count = 0;
                mbp_load_entry_program(
                    arena,
                    refresh_entry,
                    objective_count,
                    program_operation_size,
                    maximum_arity,
                    selected_operations,
                    selected_operands,
                    &candidate_operation_count);
                int band_index = mbp_band_for_operation_count(
                    arena, band_offset, band_count, candidate_operation_count);
                if (band_index < 0)
                {
                    mbp_fail(arena, compact_offset, 4);
                    return;
                }
                int band_maximum = mbp_read_int(arena, band_offset + band_index * 24 + 4);
                int maximum_lookback = 0;
                mbp_ull deterministic_cost = 0ull;
                if (!mbp_type_program(
                        arena,
                        operation_offset,
                        operation_input_type_offset,
                        terminal_offset,
                        type_offset,
                        terminal_count,
                        candidate_operation_count,
                        maximum_arity,
                        output_type,
                        selected_operations,
                        selected_operands,
                        selected_types,
                        selected_lookbacks,
                        &maximum_lookback,
                        &deterministic_cost))
                {
                    mbp_fail(arena, compact_offset, 4);
                    return;
                }
                int outcome = mbp_execute_program(
                    arena,
                    operation_offset,
                    terminal_offset,
                    type_offset,
                    immutable_slot_offset,
                    candidate_slot_offset,
                    candidate_payload_offset,
                    scratch_offset,
                    input_pointer_offset,
                    payload_stride,
                    terminal_count,
                    candidate_operation_count,
                    maximum_operation_count,
                    maximum_arity,
                    band_maximum,
                    selected_operations,
                    selected_operands,
                    selected_types,
                    &cooperative_status);
                if (outcome != 1)
                {
                    mbp_fail(arena, compact_offset, outcome < 0 ? 3 : 4);
                    return;
                }
                int final_node = terminal_count + candidate_operation_count - 1;
                if (!mbp_create_mask(
                        arena,
                        type_offset,
                        selected_types[final_node],
                        &candidate_slots[final_node],
                        history_offset,
                        history_count,
                        maximum_lookback,
                        mask_slot,
                        mask_values,
                        &cooperative_status))
                {
                    mbp_fail(arena, compact_offset, 3);
                    return;
                }
                int candidate_entry = compact_trial_offset;
                MbpHash structural;
                structural.first = mbp_read_ull(arena, refresh_entry + 48);
                structural.second = mbp_read_ull(arena, refresh_entry + 56);
                if (!mbp_contains_hash(
                        arena,
                        working_structural_offset,
                        structural_count,
                        structural))
                {
                    if (structural_count >= fingerprint_capacity)
                    {
                        mbp_fail(arena, compact_offset, 1);
                        return;
                    }
                    mbp_write_hash(
                        arena,
                        working_structural_offset,
                        structural_count,
                        structural);
                    mbp_write_hash(
                        arena,
                        compact_structural_offset,
                        new_structural_count,
                        structural);
                    structural_count++;
                    new_structural_count++;
                }
                mbp_prepare_entry(
                    arena,
                    candidate_entry,
                    entry_size,
                    mbp_read_int(arena, refresh_entry + 4),
                    candidate_operation_count,
                    mbp_read_ull(arena, refresh_entry + 32),
                    mbp_read_ull(arena, refresh_entry + 40),
                    structural,
                    objective_count,
                    program_operation_size,
                    maximum_arity,
                    operation_offset,
                    selected_operations,
                    selected_operands);
                MbpHash semantic = mbp_semantic_hash(
                    arena,
                    type_offset,
                    selected_types[final_node],
                    &candidate_slots[final_node],
                    mask_values,
                    mask_slot->count,
                    maximum_lookback);
                mbp_write_ull(arena, candidate_entry + 64, semantic.first);
                mbp_write_ull(arena, candidate_entry + 72, semantic.second);
                if (!mbp_contains_hash(
                        arena,
                        working_semantic_offset,
                        semantic_count,
                        semantic))
                {
                    if (semantic_count >= fingerprint_capacity)
                    {
                        mbp_fail(arena, compact_offset, 2);
                        return;
                    }
                    mbp_write_hash(
                        arena,
                        working_semantic_offset,
                        semantic_count,
                        semantic);
                    mbp_write_hash(
                        arena,
                        compact_semantic_offset,
                        new_semantic_count,
                        semantic);
                    semantic_count++;
                    new_semantic_count++;
                }
                if (!mbp_execute_objectives(
                        arena,
                        objective_node_offset,
                        objective_input_offset,
                        objective_source_offset,
                        type_offset,
                        immutable_slot_offset,
                        objective_slot_offset,
                        objective_payload_offset,
                        scratch_offset,
                        input_pointer_offset,
                        scratch_bytes,
                        objective_node_count,
                        objective_count,
                        &candidate_slots[final_node],
                        mask_slot,
                        candidate_operation_count,
                        maximum_lookback,
                        deterministic_cost,
                        0,
                        arena + candidate_entry + 80,
                        &cooperative_status))
                {
                    mbp_fail(arena, compact_offset, 4);
                    return;
                }
                int cell = mbp_quality_cell(
                    arena,
                    quality_dimension_offset,
                    quality_dimension_count,
                    arena + candidate_entry + 80);
                bool pareto = mbp_insert_pareto(
                    arena,
                    candidate_entry,
                    working_pareto_offset,
                    pareto_capacity,
                    entry_size,
                    objective_source_offset,
                    objective_count,
                    &pareto_count);
                bool quality = mbp_insert_quality(
                    arena,
                    candidate_entry,
                    working_quality_offset,
                    quality_capacity,
                    entry_size,
                    quality_objective,
                    objective_source_offset,
                    cell);
                (void)pareto;
                (void)quality;
                refresh_cursor++;
                processed++;
            }

            quality_count = 0;
            for (int cell = 0; cell < quality_capacity; cell++)
                if (mbp_read_int(arena, working_quality_offset + cell * entry_size) == 1)
                    quality_count++;

            mbp_write_int(arena, working_state_offset, structural_count);
            mbp_write_int(arena, working_state_offset + 4, semantic_count);
            mbp_write_int(arena, working_state_offset + 8, pareto_count);
            mbp_write_int(arena, working_state_offset + 12, quality_count);
            mbp_write_ull(arena, working_state_offset + 16, enumeration_cursor);
            mbp_write_ull(arena, working_state_offset + 24, trial_cursor);
            mbp_write_ull(arena, working_state_offset + 32, cycle_count);
            mbp_write_ull(arena, working_state_offset + 40, random_first);
            mbp_write_ull(arena, working_state_offset + 48, random_second);
            mbp_write_ull(arena, working_state_offset + 56, structural_duplicates);
            mbp_write_ull(arena, working_state_offset + 64, semantic_duplicates);
            mbp_write_ull(arena, working_state_offset + 72, evaluated);
            mbp_write_ull(arena, working_state_offset + 80, accepted);
            mbp_write_ull(arena, working_state_offset + 88, envelope_generation);
            mbp_write_int(arena, working_state_offset + 96, refresh_cursor);
            mbp_write_int(arena, working_state_offset + 100, refresh_count);
            mbp_write_ull(arena, working_state_offset + 104, enumeration_trial_count);
            mbp_write_ull(arena, working_state_offset + 112, wave_cursor);

            int control_offset = mbp_read_int(arena, 348);
            if (control_offset <= 0)
            {
                mbp_fail(arena, compact_offset, 4);
                return;
            }
            mbp_clear(arena + control_offset, 32);
            mbp_write_int(arena, control_offset, processed);
            mbp_write_int(arena, control_offset + 4, 0);
            mbp_write_int(
                arena,
                control_offset + 8,
                refresh_cursor == refresh_count &&
                    processed < cycle_work_limit &&
                    trial_cursor < maximum_trials
                    ? 1
                    : 0);
            mbp_write_int(arena, control_offset + 12, 0);
            mbp_write_int(arena, compact_offset + 4, 0);
            mbp_write_int(arena, compact_offset + 8, new_structural_count);
            mbp_write_int(arena, compact_offset + 12, new_semantic_count);
        }


        extern "C" __global__ void mathblocks_program_population_search_prepare(unsigned char* arena)
        {
            if (blockIdx.x != 0)
                return;
            if (mbp_read_int(arena, 0) != (int)0x4d425334 || mbp_read_int(arena, 4) != 11)
                return;

            int compact_offset = mbp_header_offset(arena, 34);
            if (mbp_read_int(arena, compact_offset) != 0)
                return;

            int grammar_operation_count = mbp_read_int(arena, 8);
            int terminal_count = mbp_read_int(arena, 12);
            int band_count = mbp_read_int(arena, 20);
            int maximum_operation_count = mbp_read_int(arena, 24);
            int maximum_band_elements = mbp_read_int(arena, 28);
            int proposals_per_cycle = mbp_read_int(arena, 36);
            int fingerprint_capacity = mbp_read_int(arena, 40);
            int output_type = mbp_read_int(arena, 44);
            int objective_count = mbp_read_int(arena, 52);
            int pareto_capacity = mbp_read_int(arena, 56);
            int quality_capacity = mbp_read_int(arena, 60);
            int mutation_trials = mbp_read_int(arena, 76);
            int crossover_trials = mbp_read_int(arena, 80);
            int evolution_pattern = mbp_read_int(arena, 88);
            int maximum_arity = mbp_read_int(arena, 96);
            int program_operation_size = mbp_read_int(arena, 108);
            int entry_size = mbp_read_int(arena, 112);
            int cycle_work_limit = mbp_read_int(arena, 320);
            int proposal_wave_size = mbp_read_int(arena, 324);
            int proposal_wave_slot_offset = mbp_read_int(arena, 332);
            int proposal_wave_snapshot_pareto_offset = mbp_read_int(arena, 340);
            int proposal_wave_snapshot_quality_offset = mbp_read_int(arena, 344);
            int control_offset = mbp_read_int(arena, 348);
            int candidate_lane_count = mbp_read_int(arena, 352);
            mbp_ull catalog_cursor_start = mbp_read_ull(arena, 360);
            int catalog_offset = mbp_read_int(arena, 368);
            int catalog_count = mbp_read_int(arena, 372);

            int operation_offset = mbp_header_offset(arena, 0);
            int operation_input_type_offset = mbp_header_offset(arena, 1);
            int terminal_offset = mbp_header_offset(arena, 2);
            int type_offset = mbp_header_offset(arena, 3);
            int band_offset = mbp_header_offset(arena, 4);
            int objective_source_offset = mbp_header_offset(arena, 9);
            int selected_operation_offset = mbp_header_offset(arena, 20);
            int selected_operand_offset = mbp_header_offset(arena, 21);
            int selected_type_offset = mbp_header_offset(arena, 22);
            int working_state_offset = mbp_header_offset(arena, 28);
            int working_structural_offset = mbp_header_offset(arena, 29);
            int working_pareto_offset = mbp_header_offset(arena, 31);
            int working_quality_offset = mbp_header_offset(arena, 32);

            mbp_ull total_proposals = mbp_read_ull(arena, 296);
            mbp_ull enumeration_limit = mbp_read_ull(arena, 304);
            mbp_ull maximum_trials = mbp_read_ull(arena, 312);
            if (control_offset <= 0 || candidate_lane_count <= 0 || catalog_count < 0 ||
                (catalog_count > 0 &&
                    (catalog_offset <= 0 || total_proposals != (mbp_ull)catalog_count)) ||
                proposal_wave_size <= 0 || proposal_wave_size > cycle_work_limit)
            {
                mbp_fail(arena, compact_offset, 4);
                return;
            }

            int processed = mbp_read_int(arena, control_offset);
            int enumeration_scan_count = mbp_read_int(arena, control_offset + 4);
            bool continue_proposals = mbp_read_int(arena, control_offset + 8) != 0;
            mbp_ull enumeration_cursor = mbp_read_ull(arena, working_state_offset + 16);
            mbp_ull trial_cursor = mbp_read_ull(arena, working_state_offset + 24);
            mbp_ull random_first = mbp_read_ull(arena, working_state_offset + 40);
            mbp_ull random_second = mbp_read_ull(arena, working_state_offset + 48);
            mbp_ull enumeration_trial_count = mbp_read_ull(arena, working_state_offset + 104);
            int structural_count = mbp_read_int(arena, working_state_offset);

            if (!continue_proposals ||
                processed >= cycle_work_limit ||
                trial_cursor >= maximum_trials)
            {
                mbp_write_int(arena, control_offset + 12, 0);
                return;
            }

            mbp_copy(
                arena + proposal_wave_snapshot_pareto_offset,
                arena + working_pareto_offset,
                pareto_capacity * entry_size);
            mbp_copy(
                arena + proposal_wave_snapshot_quality_offset,
                arena + working_quality_offset,
                quality_capacity * entry_size);

            int* selected_operations = (int*)(arena + selected_operation_offset);
            int* selected_operands = (int*)(arena + selected_operand_offset);
            int total_candidate_nodes = terminal_count + maximum_operation_count;
            int* selected_types = (int*)(arena + selected_type_offset);
            int* selected_lookbacks = selected_types + total_candidate_nodes;
            int wave_result_count = 0;

            while (wave_result_count < proposal_wave_size &&
                processed < cycle_work_limit &&
                trial_cursor < maximum_trials)
            {
                int source = 0;
                mbp_ull proposal_cursor = ~0ull;
                int candidate_operation_count = 0;
                int band_maximum = maximum_band_elements;
                int maximum_lookback = 0;
                mbp_ull deterministic_cost = 0ull;
                bool generated = false;
                bool enumeration_typed = false;
                int catalog_entry = -1;
                if (catalog_count > 0 &&
                    enumeration_trial_count < enumeration_limit &&
                    enumeration_cursor < total_proposals &&
                    enumeration_scan_count < proposals_per_cycle)
                {
                    source = 0;
                    int catalog_index = (int)enumeration_cursor;
                    proposal_cursor = catalog_cursor_start + enumeration_cursor;
                    enumeration_cursor++;
                    enumeration_scan_count++;
                    catalog_entry = catalog_offset + catalog_index * entry_size;
                    mbp_load_entry_program(
                        arena,
                        catalog_entry,
                        objective_count,
                        program_operation_size,
                        maximum_arity,
                        selected_operations,
                        selected_operands,
                        &candidate_operation_count);
                    int band_index = mbp_band_for_operation_count(
                        arena,
                        band_offset,
                        band_count,
                        candidate_operation_count);
                    if (band_index < 0)
                    {
                        mbp_fail(arena, compact_offset, 4);
                        return;
                    }
                    band_maximum = mbp_read_int(arena, band_offset + band_index * 24 + 4);
                    enumeration_typed = mbp_type_program(
                        arena,
                        operation_offset,
                        operation_input_type_offset,
                        terminal_offset,
                        type_offset,
                        terminal_count,
                        candidate_operation_count,
                        maximum_arity,
                        output_type,
                        selected_operations,
                        selected_operands,
                        selected_types,
                        selected_lookbacks,
                        &maximum_lookback,
                        &deterministic_cost);
                    if (!enumeration_typed)
                    {
                        mbp_fail(arena, compact_offset, 4);
                        return;
                    }
                    generated = true;
                    enumeration_trial_count++;
                }
                else if (catalog_count == 0 &&
                    enumeration_trial_count < enumeration_limit &&
                    enumeration_cursor < total_proposals &&
                    enumeration_scan_count < proposals_per_cycle)
                {
                    source = 0;
                    while (enumeration_cursor < total_proposals &&
                        enumeration_scan_count < proposals_per_cycle)
                    {
                        proposal_cursor = enumeration_cursor++;
                        enumeration_scan_count++;
                        generated = mbp_decode_enumeration(
                            arena,
                            proposal_cursor,
                            grammar_operation_count,
                            terminal_count,
                            band_count,
                            maximum_arity,
                            operation_offset,
                            band_offset,
                            selected_operations,
                            selected_operands,
                            &candidate_operation_count,
                            &band_maximum);
                        if (!generated)
                        {
                            mbp_fail(arena, compact_offset, 4);
                            return;
                        }
                        enumeration_typed = mbp_type_program(
                            arena,
                            operation_offset,
                            operation_input_type_offset,
                            terminal_offset,
                            type_offset,
                            terminal_count,
                            candidate_operation_count,
                            maximum_arity,
                            output_type,
                            selected_operations,
                            selected_operands,
                            selected_types,
                            selected_lookbacks,
                            &maximum_lookback,
                            &deterministic_cost);
                        if (enumeration_typed)
                        {
                            enumeration_trial_count++;
                            break;
                        }
                        generated = false;
                    }
                }
                if (!generated &&
                    (enumeration_trial_count >= enumeration_limit ||
                        enumeration_cursor >= total_proposals) &&
                    evolution_pattern > 0)
                {
                    proposal_cursor = ~0ull;
                    int position = (int)(trial_cursor % (mbp_ull)evolution_pattern);
                    if (position < mutation_trials)
                    {
                        source = 1;
                        generated = mbp_generate_mutation(
                            arena,
                            grammar_operation_count,
                            terminal_count,
                            maximum_operation_count,
                            maximum_arity,
                            operation_offset,
                            objective_count,
                            program_operation_size,
                            proposal_wave_snapshot_pareto_offset,
                            pareto_capacity,
                            proposal_wave_snapshot_quality_offset,
                            quality_capacity,
                            entry_size,
                            &random_first,
                            &random_second,
                            selected_operations,
                            selected_operands,
                            &candidate_operation_count);
                    }
                    else if (position < mutation_trials + crossover_trials)
                    {
                        source = 2;
                        generated = mbp_generate_crossover(
                            arena,
                            terminal_count,
                            maximum_operation_count,
                            maximum_arity,
                            operation_offset,
                            objective_count,
                            program_operation_size,
                            proposal_wave_snapshot_pareto_offset,
                            pareto_capacity,
                            proposal_wave_snapshot_quality_offset,
                            quality_capacity,
                            entry_size,
                            &random_first,
                            &random_second,
                            selected_operations,
                            selected_operands,
                            &candidate_operation_count);
                    }
                    else
                    {
                        source = 3;
                        generated = mbp_generate_immigrant(
                            arena,
                            grammar_operation_count,
                            terminal_count,
                            band_count,
                            maximum_arity,
                            operation_offset,
                            band_offset,
                            &random_first,
                            &random_second,
                            selected_operations,
                            selected_operands,
                            &candidate_operation_count,
                            &band_maximum);
                    }
                    if (generated && source != 3)
                    {
                        int band_index = mbp_band_for_operation_count(
                            arena,
                            band_offset,
                            band_count,
                            candidate_operation_count);
                        if (band_index < 0)
                            generated = false;
                        else
                            band_maximum = mbp_read_int(arena, band_offset + band_index * 24 + 4);
                    }
                }
                if (!generated)
                {
                    continue_proposals = false;
                    break;
                }

                mbp_ull current_trial = trial_cursor++;
                processed++;
                int candidate_entry =
                    proposal_wave_slot_offset + wave_result_count * entry_size;
                MbpHash structural = mbp_structural_hash(
                    arena,
                    operation_offset,
                    candidate_operation_count,
                    maximum_arity,
                    selected_operations,
                    selected_operands);
                if (catalog_entry >= 0 &&
                    (mbp_read_ull(arena, catalog_entry + 48) != structural.first ||
                        mbp_read_ull(arena, catalog_entry + 56) != structural.second))
                {
                    mbp_fail(arena, compact_offset, 4);
                    return;
                }
                mbp_prepare_entry(
                    arena,
                    candidate_entry,
                    entry_size,
                    source,
                    candidate_operation_count,
                    current_trial,
                    proposal_cursor,
                    structural,
                    objective_count,
                    program_operation_size,
                    maximum_arity,
                    operation_offset,
                    selected_operations,
                    selected_operands);
                mbp_write_int(arena, candidate_entry + 20, band_maximum);

                int status = 1;
                bool typed = enumeration_typed || generated && mbp_type_program(
                    arena,
                    operation_offset,
                    operation_input_type_offset,
                    terminal_offset,
                    type_offset,
                    terminal_count,
                    candidate_operation_count,
                    maximum_arity,
                    output_type,
                    selected_operations,
                    selected_operands,
                    selected_types,
                    selected_lookbacks,
                    &maximum_lookback,
                    &deterministic_cost);
                if (!typed)
                {
                    status = 4;
                }
                else if (mbp_contains_hash(
                        arena,
                        working_structural_offset,
                        structural_count,
                        structural) ||
                    mbp_wave_owns_structural(
                        arena,
                        proposal_wave_slot_offset,
                        wave_result_count,
                        entry_size,
                        structural))
                {
                    status = 2;
                }
                mbp_write_int(arena, candidate_entry, status);
                mbp_write_int(arena, candidate_entry + 16, -1);
                mbp_write_int(arena, candidate_entry + 24, 0);
                __syncthreads();
                wave_result_count++;
            }

            mbp_write_int(arena, control_offset, processed);
            mbp_write_int(arena, control_offset + 4, enumeration_scan_count);
            mbp_write_int(arena, control_offset + 8, continue_proposals ? 1 : 0);
            mbp_write_int(arena, control_offset + 12, wave_result_count);
            mbp_write_ull(arena, working_state_offset + 16, enumeration_cursor);
            mbp_write_ull(arena, working_state_offset + 24, trial_cursor);
            mbp_write_ull(arena, working_state_offset + 40, random_first);
            mbp_write_ull(arena, working_state_offset + 48, random_second);
            mbp_write_ull(arena, working_state_offset + 104, enumeration_trial_count);
        }

        extern "C" __global__ void mathblocks_program_population_search_evaluate(
            unsigned char* arena,
            int slot_index,
            int lane_index)
        {
            if (blockIdx.x != 0)
                return;
            __shared__ int cooperative_status;
            if (mbp_read_int(arena, 0) != (int)0x4d425334 || mbp_read_int(arena, 4) != 11)
                return;

            int compact_offset = mbp_header_offset(arena, 34);
            if (mbp_read_int(arena, compact_offset) != 0)
                return;

            int control_offset = mbp_read_int(arena, 348);
            int wave_result_count = mbp_read_int(arena, control_offset + 12);
            int candidate_lane_count = mbp_read_int(arena, 352);
            int lane_stride_bytes = mbp_read_int(arena, 356);
            if (slot_index < 0 || slot_index >= wave_result_count ||
                lane_index < 0 || lane_index >= candidate_lane_count ||
                lane_stride_bytes <= 0)
            {
                return;
            }

            int terminal_count = mbp_read_int(arena, 12);
            int band_count = mbp_read_int(arena, 20);
            int maximum_operation_count = mbp_read_int(arena, 24);
            int output_type = mbp_read_int(arena, 44);
            int objective_node_count = mbp_read_int(arena, 48);
            int objective_count = mbp_read_int(arena, 52);
            int quality_dimension_count = mbp_read_int(arena, 64);
            int maximum_arity = mbp_read_int(arena, 96);
            int scratch_bytes = mbp_read_int(arena, 100);
            int payload_stride = mbp_read_int(arena, 104);
            int program_operation_size = mbp_read_int(arena, 108);
            int entry_size = mbp_read_int(arena, 112);
            int history_count = mbp_read_int(arena, 120);
            int proposal_wave_slot_offset = mbp_read_int(arena, 332);

            int operation_offset = mbp_header_offset(arena, 0);
            int operation_input_type_offset = mbp_header_offset(arena, 1);
            int terminal_offset = mbp_header_offset(arena, 2);
            int type_offset = mbp_header_offset(arena, 3);
            int band_offset = mbp_header_offset(arena, 4);
            int immutable_slot_offset = mbp_header_offset(arena, 5);
            int objective_node_offset = mbp_header_offset(arena, 7);
            int objective_input_offset = mbp_header_offset(arena, 8);
            int objective_source_offset = mbp_header_offset(arena, 9);
            int quality_dimension_offset = mbp_header_offset(arena, 10);
            int history_offset = mbp_header_offset(arena, 11);
            int lane_delta = lane_index * lane_stride_bytes;
            int candidate_slot_offset = mbp_header_offset(arena, 12) + lane_delta;
            int objective_slot_offset = mbp_header_offset(arena, 13) + lane_delta;
            int mask_slot_offset = mbp_header_offset(arena, 14) + lane_delta;
            int candidate_payload_offset = mbp_header_offset(arena, 15) + lane_delta;
            int objective_payload_offset = mbp_header_offset(arena, 16) + lane_delta;
            int mask_payload_offset = mbp_header_offset(arena, 17) + lane_delta;
            int scratch_offset = mbp_header_offset(arena, 18) + lane_delta;
            int input_pointer_offset = mbp_header_offset(arena, 19) + lane_delta;
            int selected_operation_offset = mbp_header_offset(arena, 20) + lane_delta;
            int selected_operand_offset = mbp_header_offset(arena, 21) + lane_delta;
            int selected_type_offset = mbp_header_offset(arena, 22) + lane_delta;
            int working_state_offset = mbp_header_offset(arena, 28);

            int candidate_entry = proposal_wave_slot_offset + slot_index * entry_size;
            if (mbp_read_int(arena, candidate_entry) != 1)
                return;

            int* selected_operations = (int*)(arena + selected_operation_offset);
            int* selected_operands = (int*)(arena + selected_operand_offset);
            int total_candidate_nodes = terminal_count + maximum_operation_count;
            int* selected_types = (int*)(arena + selected_type_offset);
            int* selected_lookbacks = selected_types + total_candidate_nodes;
            MathBlockSlot* candidate_slots = (MathBlockSlot*)(arena + candidate_slot_offset);
            MathBlockSlot* mask_slot = (MathBlockSlot*)(arena + mask_slot_offset);
            int* mask_values = (int*)(arena + mask_payload_offset);
            int candidate_operation_count = 0;
            mbp_load_entry_program(
                arena,
                candidate_entry,
                objective_count,
                program_operation_size,
                maximum_arity,
                selected_operations,
                selected_operands,
                &candidate_operation_count);
            __syncthreads();

            int band_index = mbp_band_for_operation_count(
                arena,
                band_offset,
                band_count,
                candidate_operation_count);
            int band_maximum = mbp_read_int(arena, candidate_entry + 20);
            int maximum_lookback = 0;
            mbp_ull deterministic_cost = 0ull;
            bool typed = band_index >= 0 && band_maximum > 0 && mbp_type_program(
                arena,
                operation_offset,
                operation_input_type_offset,
                terminal_offset,
                type_offset,
                terminal_count,
                candidate_operation_count,
                maximum_arity,
                output_type,
                selected_operations,
                selected_operands,
                selected_types,
                selected_lookbacks,
                &maximum_lookback,
                &deterministic_cost);
            if (!typed)
            {
                mbp_write_int(arena, candidate_entry, -4);
                return;
            }

            int outcome = mbp_execute_program(
                arena,
                operation_offset,
                terminal_offset,
                type_offset,
                immutable_slot_offset,
                candidate_slot_offset,
                candidate_payload_offset,
                scratch_offset,
                input_pointer_offset,
                payload_stride,
                terminal_count,
                candidate_operation_count,
                maximum_operation_count,
                maximum_arity,
                band_maximum,
                selected_operations,
                selected_operands,
                selected_types,
                &cooperative_status);
            if (outcome < 0)
            {
                mbp_write_int(arena, candidate_entry, -3);
                return;
            }
            if (outcome == 0)
            {
                mbp_write_int(arena, candidate_entry, 5);
                return;
            }

            int final_node = terminal_count + candidate_operation_count - 1;
            if (!mbp_create_mask(
                    arena,
                    type_offset,
                    selected_types[final_node],
                    &candidate_slots[final_node],
                    history_offset,
                    history_count,
                    maximum_lookback,
                    mask_slot,
                    mask_values,
                    &cooperative_status))
            {
                mbp_write_int(arena, candidate_entry, -3);
                return;
            }

            if (threadIdx.x == 0)
                atomicAdd((unsigned long long*)(arena + working_state_offset + 72), 1ull);
            __syncthreads();

            MbpHash semantic = mbp_semantic_hash(
                arena,
                type_offset,
                selected_types[final_node],
                &candidate_slots[final_node],
                mask_values,
                mask_slot->count,
                maximum_lookback);
            mbp_write_ull(arena, candidate_entry + 64, semantic.first);
            mbp_write_ull(arena, candidate_entry + 72, semantic.second);
            int flags = 8;
            int status = 5;
            int cell = -1;
            if (mbp_execute_objectives(
                    arena,
                    objective_node_offset,
                    objective_input_offset,
                    objective_source_offset,
                    type_offset,
                    immutable_slot_offset,
                    objective_slot_offset,
                    objective_payload_offset,
                    scratch_offset,
                    input_pointer_offset,
                    scratch_bytes,
                    objective_node_count,
                    objective_count,
                    &candidate_slots[final_node],
                    mask_slot,
                    candidate_operation_count,
                    maximum_lookback,
                    deterministic_cost,
                    0,
                    arena + candidate_entry + 80,
                    &cooperative_status))
            {
                flags |= 4;
                cell = mbp_quality_cell(
                    arena,
                    quality_dimension_offset,
                    quality_dimension_count,
                    arena + candidate_entry + 80);
                status = 1;
            }
            mbp_write_int(arena, candidate_entry, status);
            mbp_write_int(arena, candidate_entry + 16, cell);
            mbp_write_int(arena, candidate_entry + 24, flags);
        }

        extern "C" __global__ void mathblocks_program_population_search_commit(unsigned char* arena)
        {
            if (blockIdx.x != 0)
                return;
            if (mbp_read_int(arena, 0) != (int)0x4d425334 || mbp_read_int(arena, 4) != 11)
                return;

            int compact_offset = mbp_header_offset(arena, 34);
            if (mbp_read_int(arena, compact_offset) != 0)
                return;

            int control_offset = mbp_read_int(arena, 348);
            int wave_result_count = mbp_read_int(arena, control_offset + 12);
            if (wave_result_count <= 0)
                return;

            int fingerprint_capacity = mbp_read_int(arena, 40);
            int objective_count = mbp_read_int(arena, 52);
            int pareto_capacity = mbp_read_int(arena, 56);
            int quality_capacity = mbp_read_int(arena, 60);
            int quality_objective = mbp_read_int(arena, 92);
            int entry_size = mbp_read_int(arena, 112);
            int include_rejected = mbp_read_int(arena, 72);
            int proposal_wave_slot_offset = mbp_read_int(arena, 332);
            int candidate_lane_count = mbp_read_int(arena, 352);

            int objective_source_offset = mbp_header_offset(arena, 9);
            int working_state_offset = mbp_header_offset(arena, 28);
            int working_structural_offset = mbp_header_offset(arena, 29);
            int working_semantic_offset = mbp_header_offset(arena, 30);
            int working_pareto_offset = mbp_header_offset(arena, 31);
            int working_quality_offset = mbp_header_offset(arena, 32);
            int compact_structural_offset = mbp_header_offset(arena, 36);
            int compact_semantic_offset = mbp_header_offset(arena, 37);
            int compact_trial_offset = mbp_header_offset(arena, 40);

            int structural_count = mbp_read_int(arena, working_state_offset);
            int semantic_count = mbp_read_int(arena, working_state_offset + 4);
            int pareto_count = mbp_read_int(arena, working_state_offset + 8);
            mbp_ull structural_duplicates = mbp_read_ull(arena, working_state_offset + 56);
            mbp_ull semantic_duplicates = mbp_read_ull(arena, working_state_offset + 64);
            mbp_ull accepted = mbp_read_ull(arena, working_state_offset + 80);
            mbp_ull wave_cursor = mbp_read_ull(arena, working_state_offset + 112);
            int trial_result_count = mbp_read_int(arena, compact_offset + 4);
            int new_structural_count = mbp_read_int(arena, compact_offset + 8);
            int new_semantic_count = mbp_read_int(arena, compact_offset + 12);

            for (int ordinal = 0; ordinal < wave_result_count; ordinal++)
            {
                int candidate_entry = proposal_wave_slot_offset + ordinal * entry_size;
                int status = mbp_read_int(arena, candidate_entry);
                if (status < 0)
                {
                    mbp_fail(arena, compact_offset, -status);
                    return;
                }

                int cell = mbp_read_int(arena, candidate_entry + 16);
                int flags = mbp_read_int(arena, candidate_entry + 24);
                bool keep_result = include_rejected != 0;

                if (status == 2)
                {
                    structural_duplicates++;
                }
                else if (status != 4 && status != 6)
                {
                    MbpHash structural;
                    structural.first = mbp_read_ull(arena, candidate_entry + 48);
                    structural.second = mbp_read_ull(arena, candidate_entry + 56);
                    if (mbp_contains_hash(
                            arena,
                            working_structural_offset,
                            structural_count,
                            structural))
                    {
                        structural_duplicates++;
                        status = 2;
                        cell = -1;
                        flags = 0;
                    }
                    else
                    {
                        if (structural_count >= fingerprint_capacity)
                        {
                            mbp_fail(arena, compact_offset, 1);
                            return;
                        }
                        mbp_write_hash(
                            arena,
                            working_structural_offset,
                            structural_count,
                            structural);
                        mbp_write_hash(
                            arena,
                            compact_structural_offset,
                            new_structural_count,
                            structural);
                        structural_count++;
                        new_structural_count++;

                        if ((flags & 8) != 0)
                        {
                            MbpHash semantic;
                            semantic.first = mbp_read_ull(arena, candidate_entry + 64);
                            semantic.second = mbp_read_ull(arena, candidate_entry + 72);
                            bool semantic_duplicate = mbp_contains_hash(
                                arena,
                                working_semantic_offset,
                                semantic_count,
                                semantic);
                            if (semantic_duplicate)
                            {
                                semantic_duplicates++;
                            }
                            else
                            {
                                if (semantic_count >= fingerprint_capacity)
                                {
                                    mbp_fail(arena, compact_offset, 2);
                                    return;
                                }
                                mbp_write_hash(
                                    arena,
                                    working_semantic_offset,
                                    semantic_count,
                                    semantic);
                                mbp_write_hash(
                                    arena,
                                    compact_semantic_offset,
                                    new_semantic_count,
                                    semantic);
                                semantic_count++;
                                new_semantic_count++;
                            }

                            if ((flags & 4) != 0)
                            {
                                bool equivalent_semantic = semantic_duplicate &&
                                    mbp_has_equivalent_semantic_entry(
                                        arena,
                                        candidate_entry,
                                        working_pareto_offset,
                                        pareto_count,
                                        working_quality_offset,
                                        quality_capacity,
                                        entry_size,
                                        objective_count);
                                bool accepted_pareto = false;
                                bool accepted_quality = false;
                                if (!equivalent_semantic)
                                {
                                    accepted_pareto = mbp_insert_pareto(
                                        arena,
                                        candidate_entry,
                                        working_pareto_offset,
                                        pareto_capacity,
                                        entry_size,
                                        objective_source_offset,
                                        objective_count,
                                        &pareto_count);
                                    accepted_quality = mbp_insert_quality(
                                        arena,
                                        candidate_entry,
                                        working_quality_offset,
                                        quality_capacity,
                                        entry_size,
                                        quality_objective,
                                        objective_source_offset,
                                        cell);
                                }
                                if (accepted_pareto)
                                    flags |= 1;
                                if (accepted_quality)
                                    flags |= 2;
                                if (accepted_pareto || accepted_quality)
                                {
                                    status = 0;
                                    accepted++;
                                    keep_result = true;
                                }
                                else
                                {
                                    status = semantic_duplicate || equivalent_semantic ? 3 : 1;
                                }
                            }
                        }
                    }
                }

                mbp_write_int(arena, candidate_entry, status);
                mbp_write_int(arena, candidate_entry + 16, cell);
                mbp_write_int(arena, candidate_entry + 24, flags);
                if (keep_result)
                {
                    mbp_copy(
                        arena + compact_trial_offset + trial_result_count * entry_size,
                        arena + candidate_entry,
                        entry_size);
                    trial_result_count++;
                }
            }

            int candidate_chunk_count = 0;
            int maximum_concurrent_candidates = 0;
            for (int chunk = 0; chunk < wave_result_count; chunk += candidate_lane_count)
            {
                int concurrent = 0;
                int chunk_end = chunk + candidate_lane_count;
                if (chunk_end > wave_result_count)
                    chunk_end = wave_result_count;
                for (int ordinal = chunk; ordinal < chunk_end; ordinal++)
                {
                    int entry = proposal_wave_slot_offset + ordinal * entry_size;
                    if ((mbp_read_int(arena, entry + 24) & 8) != 0)
                        concurrent++;
                }
                if (concurrent > 0)
                    candidate_chunk_count++;
                if (concurrent > maximum_concurrent_candidates)
                    maximum_concurrent_candidates = concurrent;
            }
            int prior_candidate_chunk_count = mbp_read_int(arena, control_offset + 16);
            int prior_maximum_concurrent = mbp_read_int(arena, control_offset + 20);
            mbp_write_int(
                arena,
                control_offset + 16,
                prior_candidate_chunk_count + candidate_chunk_count);
            mbp_write_int(
                arena,
                control_offset + 20,
                prior_maximum_concurrent > maximum_concurrent_candidates
                    ? prior_maximum_concurrent
                    : maximum_concurrent_candidates);

            int quality_count = 0;
            for (int cell = 0; cell < quality_capacity; cell++)
                if (mbp_read_int(arena, working_quality_offset + cell * entry_size) == 1)
                    quality_count++;
            wave_cursor++;
            mbp_write_int(arena, working_state_offset, structural_count);
            mbp_write_int(arena, working_state_offset + 4, semantic_count);
            mbp_write_int(arena, working_state_offset + 8, pareto_count);
            mbp_write_int(arena, working_state_offset + 12, quality_count);
            mbp_write_ull(arena, working_state_offset + 56, structural_duplicates);
            mbp_write_ull(arena, working_state_offset + 64, semantic_duplicates);
            mbp_write_ull(arena, working_state_offset + 80, accepted);
            mbp_write_ull(arena, working_state_offset + 112, wave_cursor);
            mbp_write_int(arena, compact_offset + 4, trial_result_count);
            mbp_write_int(arena, compact_offset + 8, new_structural_count);
            mbp_write_int(arena, compact_offset + 12, new_semantic_count);
            mbp_write_int(arena, control_offset + 12, 0);
        }

        extern "C" __global__ void mathblocks_program_population_search_finalize(unsigned char* arena)
        {
            if (blockIdx.x != 0)
                return;
            if (mbp_read_int(arena, 0) != (int)0x4d425334 || mbp_read_int(arena, 4) != 11)
                return;

            int compact_offset = mbp_header_offset(arena, 34);
            if (mbp_read_int(arena, compact_offset) != 0)
                return;

            int pareto_capacity = mbp_read_int(arena, 56);
            int quality_capacity = mbp_read_int(arena, 60);
            int entry_size = mbp_read_int(arena, 112);
            int working_state_offset = mbp_header_offset(arena, 28);
            int working_pareto_offset = mbp_header_offset(arena, 31);
            int working_quality_offset = mbp_header_offset(arena, 32);
            int compact_pareto_offset = mbp_header_offset(arena, 38);
            int compact_quality_offset = mbp_header_offset(arena, 39);
            int control_offset = mbp_read_int(arena, 348);

            int structural_count = mbp_read_int(arena, working_state_offset);
            int semantic_count = mbp_read_int(arena, working_state_offset + 4);
            int pareto_count = mbp_read_int(arena, working_state_offset + 8);
            int quality_count = 0;
            for (int cell = 0; cell < quality_capacity; cell++)
                if (mbp_read_int(arena, working_quality_offset + cell * entry_size) == 1)
                    quality_count++;

            mbp_ull enumeration_cursor = mbp_read_ull(arena, working_state_offset + 16);
            mbp_ull trial_cursor = mbp_read_ull(arena, working_state_offset + 24);
            mbp_ull cycle_count = mbp_read_ull(arena, working_state_offset + 32) + 1ull;
            mbp_ull random_first = mbp_read_ull(arena, working_state_offset + 40);
            mbp_ull random_second = mbp_read_ull(arena, working_state_offset + 48);
            mbp_ull structural_duplicates = mbp_read_ull(arena, working_state_offset + 56);
            mbp_ull semantic_duplicates = mbp_read_ull(arena, working_state_offset + 64);
            mbp_ull evaluated = mbp_read_ull(arena, working_state_offset + 72);
            mbp_ull accepted = mbp_read_ull(arena, working_state_offset + 80);
            mbp_ull envelope_generation = mbp_read_ull(arena, working_state_offset + 88);
            int refresh_cursor = mbp_read_int(arena, working_state_offset + 96);
            int refresh_count = mbp_read_int(arena, working_state_offset + 100);
            mbp_ull enumeration_trial_count = mbp_read_ull(arena, working_state_offset + 104);
            mbp_ull wave_cursor = mbp_read_ull(arena, working_state_offset + 112);

            mbp_write_int(arena, working_state_offset + 12, quality_count);
            mbp_write_ull(arena, working_state_offset + 32, cycle_count);

            mbp_write_int(arena, compact_offset, 0);
            mbp_write_int(arena, compact_offset + 16, pareto_count);
            mbp_write_int(arena, compact_offset + 20, quality_count);
            mbp_write_ull(arena, compact_offset + 24, enumeration_cursor);
            mbp_write_ull(arena, compact_offset + 32, trial_cursor);
            mbp_write_ull(arena, compact_offset + 40, cycle_count);
            mbp_write_ull(arena, compact_offset + 48, random_first);
            mbp_write_ull(arena, compact_offset + 56, random_second);
            mbp_write_ull(arena, compact_offset + 64, structural_duplicates);
            mbp_write_ull(arena, compact_offset + 72, semantic_duplicates);
            mbp_write_ull(arena, compact_offset + 80, evaluated);
            mbp_write_ull(arena, compact_offset + 88, accepted);
            mbp_write_int(arena, compact_offset + 96, structural_count);
            mbp_write_int(arena, compact_offset + 100, semantic_count);
            mbp_write_ull(arena, compact_offset + 104, envelope_generation);
            mbp_write_int(arena, compact_offset + 112, refresh_cursor);
            mbp_write_int(arena, compact_offset + 116, refresh_count);
            mbp_write_ull(arena, compact_offset + 120, enumeration_trial_count);
            mbp_write_ull(arena, compact_offset + 128, wave_cursor);
            mbp_write_int(arena, compact_offset + 136, mbp_read_int(arena, control_offset + 16));
            mbp_write_int(arena, compact_offset + 140, mbp_read_int(arena, control_offset + 20));
            mbp_copy(
                arena + compact_pareto_offset,
                arena + working_pareto_offset,
                pareto_capacity * entry_size);
            mbp_copy(
                arena + compact_quality_offset,
                arena + working_quality_offset,
                quality_capacity * entry_size);
        }


        extern "C" __global__ void mathblocks_program_population_search_publish(unsigned char* arena)
        {
            if (blockIdx.x != 0)
                return;
            if (mbp_read_int(arena, 0) != (int)0x4d425334 || mbp_read_int(arena, 4) != 11)
                return;

            int compact_offset = mbp_header_offset(arena, 34);
            if (mbp_read_int(arena, compact_offset) != 0)
                return;

            int fingerprint_capacity = mbp_read_int(arena, 40);
            int pareto_capacity = mbp_read_int(arena, 56);
            int quality_capacity = mbp_read_int(arena, 60);
            int entry_size = mbp_read_int(arena, 112);
            int accepted_state_offset = mbp_header_offset(arena, 23);
            int accepted_structural_offset = mbp_header_offset(arena, 24);
            int accepted_semantic_offset = mbp_header_offset(arena, 25);
            int accepted_pareto_offset = mbp_header_offset(arena, 26);
            int accepted_quality_offset = mbp_header_offset(arena, 27);
            int working_state_offset = mbp_header_offset(arena, 28);
            int working_structural_offset = mbp_header_offset(arena, 29);
            int working_semantic_offset = mbp_header_offset(arena, 30);
            int working_pareto_offset = mbp_header_offset(arena, 31);
            int working_quality_offset = mbp_header_offset(arena, 32);

            mbp_copy(arena + accepted_state_offset, arena + working_state_offset, 144);
            mbp_copy(
                arena + accepted_structural_offset,
                arena + working_structural_offset,
                fingerprint_capacity * 16);
            mbp_copy(
                arena + accepted_semantic_offset,
                arena + working_semantic_offset,
                fingerprint_capacity * 16);
            mbp_copy(
                arena + accepted_pareto_offset,
                arena + working_pareto_offset,
                pareto_capacity * entry_size);
            mbp_copy(
                arena + accepted_quality_offset,
                arena + working_quality_offset,
                quality_capacity * entry_size);
        }
        """;
}
