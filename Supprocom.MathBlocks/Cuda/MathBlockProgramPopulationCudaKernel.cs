namespace Supprocom.MathBlocks.Cuda;

internal static class MathBlockProgramPopulationCudaKernel
{
    private static readonly Lazy<KernelState> state = new(Load, LazyThreadSafetyMode.ExecutionAndPublication);

    public static IntPtr Function => state.Value.Function;

    private static KernelState Load()
    {
        var ptx = MathBlocksCudaNative.CompilePtx(KernelSource, "mathblocks_program_population.cu");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleLoadData(out var module, ptx),
            "cuModuleLoadData(mathblocks population)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var function,
                module,
                "mathblocks_program_population"),
            "cuModuleGetFunction(mathblocks_program_population)");
        return new KernelState(module, function);
    }

    private sealed record KernelState(IntPtr Module, IntPtr Function);

    private const string KernelSource = """
        typedef unsigned long long mb_ull;

        struct MbHash
        {
            mb_ull first;
            mb_ull second;
        };

        __device__ int mb_read_int(unsigned char* arena, int offset)
        {
            return *((int*)(arena + offset));
        }

        __device__ mb_ull mb_read_ull(unsigned char* arena, int offset)
        {
            return *((mb_ull*)(arena + offset));
        }

        __device__ void mb_write_int(unsigned char* arena, int offset, int value)
        {
            *((int*)(arena + offset)) = value;
        }

        __device__ void mb_write_ull(unsigned char* arena, int offset, mb_ull value)
        {
            *((mb_ull*)(arena + offset)) = value;
        }

        __device__ int mb_align(int value)
        {
            return (value + 7) & ~7;
        }

        __device__ mb_ull mb_power(mb_ull value, int exponent)
        {
            mb_ull result = 1ull;
            for (int index = 0; index < exponent; index++)
                result *= value;
            return result;
        }

        __device__ void mb_hash_byte(MbHash* hash, unsigned char value)
        {
            hash->first = (hash->first ^ (mb_ull)value) * 1099511628211ull;
            hash->second = (hash->second ^ (mb_ull)value) * 14029467366897019727ull;
        }

        __device__ void mb_hash_word(MbHash* hash, mb_ull value)
        {
            for (int shift = 0; shift < 64; shift += 8)
                mb_hash_byte(hash, (unsigned char)((value >> shift) & 0xffull));
        }

        __device__ MbHash mb_hash_start()
        {
            MbHash result;
            result.first = 14695981039346656037ull;
            result.second = 7809847782465536322ull;
            return result;
        }

        __device__ bool mb_hash_equal(MbHash left, MbHash right)
        {
            return left.first == right.first && left.second == right.second;
        }

        __device__ MbHash mb_read_hash(unsigned char* arena, int offset, int index)
        {
            MbHash result;
            result.first = mb_read_ull(arena, offset + index * 16);
            result.second = mb_read_ull(arena, offset + index * 16 + 8);
            return result;
        }

        __device__ void mb_write_hash(unsigned char* arena, int offset, int index, MbHash value)
        {
            mb_write_ull(arena, offset + index * 16, value.first);
            mb_write_ull(arena, offset + index * 16 + 8, value.second);
        }

        __device__ bool mb_contains_hash(unsigned char* arena, int offset, int count, MbHash value)
        {
            for (int index = 0; index < count; index++)
                if (mb_hash_equal(mb_read_hash(arena, offset, index), value))
                    return true;
            return false;
        }

        __device__ bool mb_types_compatible(
            unsigned char* arena,
            int type_offset,
            int expected_type,
            int actual_type)
        {
            const int type_size = 48;
            int expected = type_offset + expected_type * type_size;
            int actual = type_offset + actual_type * type_size;
            if (mb_read_int(arena, expected) != mb_read_int(arena, actual))
                return false;
            int expected_rows = mb_read_int(arena, expected + 4);
            int actual_rows = mb_read_int(arena, actual + 4);
            if (expected_rows != 0 && expected_rows != actual_rows)
                return false;
            int expected_columns = mb_read_int(arena, expected + 8);
            int actual_columns = mb_read_int(arena, actual + 8);
            if (expected_columns != 0 && expected_columns != actual_columns)
                return false;
            for (int offset = 12; offset < 44; offset += 4)
                if (mb_read_int(arena, expected + offset) != mb_read_int(arena, actual + offset))
                    return false;
            return true;
        }

        __device__ MbHash mb_structural_hash(
            unsigned char* arena,
            int operation_offset,
            int operation_count,
            const int* selected_operations,
            const int* selected_operands)
        {
            MbHash hash = mb_hash_start();
            mb_hash_word(&hash, (mb_ull)operation_count);
            for (int node = 0; node < operation_count; node++)
            {
                int operation = operation_offset + selected_operations[node] * 64;
                mb_hash_word(&hash, mb_read_ull(arena, operation + 32));
                mb_hash_word(&hash, mb_read_ull(arena, operation + 40));
                int arity = mb_read_int(arena, operation + 4);
                mb_hash_word(&hash, (mb_ull)arity);
                for (int input = 0; input < arity; input++)
                    mb_hash_word(&hash, (mb_ull)selected_operands[node * 4 + input]);
            }
            return hash;
        }

        __device__ MbHash mb_semantic_hash(
            unsigned char* arena,
            int type_offset,
            int output_type,
            int output_count,
            const mb_ull* output_values)
        {
            MbHash hash = mb_hash_start();
            int type = type_offset + output_type * 48;
            int kind = mb_read_int(arena, type);
            int actual_rows = kind == 4 || kind == 11
                ? output_count
                : mb_read_int(arena, type + 4);
            mb_hash_word(&hash, (mb_ull)(long long)kind);
            mb_hash_word(&hash, (mb_ull)(long long)actual_rows);
            mb_hash_word(&hash, (mb_ull)(long long)mb_read_int(arena, type + 8));
            for (int offset = 12; offset < 44; offset += 4)
                mb_hash_word(&hash, (mb_ull)(long long)mb_read_int(arena, type + offset));
            for (int index = 0; index < output_count; index++)
                mb_hash_word(&hash, output_values[index]);
            return hash;
        }

        __device__ double mb_minimum(double first, double second)
        {
            if (first < second)
                return first;
            if (second < first)
                return second;
            if (first == 0.0)
                return signbit(first) ? first : second;
            return first;
        }

        __device__ double mb_maximum(double first, double second)
        {
            if (first > second)
                return first;
            if (second > first)
                return second;
            if (first == 0.0)
                return signbit(first) ? second : first;
            return first;
        }

        __device__ int mb_execute_operation(
            int opcode,
            int arity,
            const int* operands,
            int output_node,
            int* counts,
            mb_ull* values,
            int maximum_elements,
            int band_maximum)
        {
            int first_count = arity > 0 ? counts[operands[0]] : 0;
            int second_count = arity > 1 ? counts[operands[1]] : 0;
            mb_ull* output = values + output_node * maximum_elements;
            mb_ull* first_bits = arity > 0 ? values + operands[0] * maximum_elements : nullptr;
            mb_ull* second_bits = arity > 1 ? values + operands[1] * maximum_elements : nullptr;
            double* first = (double*)first_bits;
            double* second = (double*)second_bits;
            double* numeric_output = (double*)output;
            int output_count = 0;

            if (opcode >= 1 && opcode <= 14)
            {
                if ((opcode == 5 || opcode == 6) ? first_count != 1 : (first_count != 1 || second_count != 1))
                    return 0;
                output_count = 1;
                switch (opcode)
                {
                    case 1: numeric_output[0] = first[0] + second[0]; break;
                    case 2: numeric_output[0] = first[0] - second[0]; break;
                    case 3: numeric_output[0] = first[0] * second[0]; break;
                    case 4: numeric_output[0] = first[0] / second[0]; break;
                    case 5: numeric_output[0] = -first[0]; break;
                    case 6: numeric_output[0] = fabs(first[0]); break;
                    case 7: numeric_output[0] = mb_minimum(first[0], second[0]); break;
                    case 8: numeric_output[0] = mb_maximum(first[0], second[0]); break;
                    case 9: output[0] = first[0] == second[0] ? 1ull : 0ull; break;
                    case 10: output[0] = first[0] != second[0] ? 1ull : 0ull; break;
                    case 11: output[0] = first[0] > second[0] ? 1ull : 0ull; break;
                    case 12: output[0] = first[0] >= second[0] ? 1ull : 0ull; break;
                    case 13: output[0] = first[0] < second[0] ? 1ull : 0ull; break;
                    case 14: output[0] = first[0] <= second[0] ? 1ull : 0ull; break;
                }
                if (opcode <= 8 && !isfinite(numeric_output[0]))
                    return 0;
            }
            else if (opcode >= 20 && opcode <= 29)
            {
                if (opcode == 24)
                    output_count = first_count;
                else if (opcode == 25)
                {
                    if (second_count != 1)
                        return 0;
                    output_count = first_count;
                }
                else if (opcode == 26 || opcode == 27)
                    output_count = 1;
                else if (opcode == 29)
                    output_count = first_count + second_count;
                else
                {
                    if (first_count != second_count)
                        return 0;
                    output_count = first_count;
                }
                if (output_count <= 0 || output_count > band_maximum || output_count > maximum_elements)
                    return -1;
                if (opcode == 26 || opcode == 27)
                {
                    if (first_count <= 0)
                        return 0;
                    double sum = 0.0;
                    double correction = 0.0;
                    for (int index = 0; index < first_count; index++)
                    {
                        double value = first[index];
                        double next = sum + value;
                        correction += fabs(sum) >= fabs(value)
                            ? sum - next + value
                            : value - next + sum;
                        sum = next;
                    }
                    numeric_output[0] = sum + correction;
                    if (opcode == 27)
                        numeric_output[0] /= (double)first_count;
                    if (!isfinite(numeric_output[0]))
                        return 0;
                }
                else if (opcode == 29)
                {
                    for (int index = 0; index < first_count; index++)
                        numeric_output[index] = first[index];
                    for (int index = 0; index < second_count; index++)
                        numeric_output[first_count + index] = second[index];
                }
                else
                {
                    for (int index = 0; index < output_count; index++)
                    {
                        if (opcode == 20)
                            numeric_output[index] = first[index] + second[index];
                        else if (opcode == 21)
                            numeric_output[index] = first[index] - second[index];
                        else if (opcode == 22)
                            numeric_output[index] = first[index] * second[index];
                        else if (opcode == 23)
                            numeric_output[index] = first[index] / second[index];
                        else if (opcode == 24)
                            numeric_output[index] = fabs(first[index]);
                        else if (opcode == 25)
                            numeric_output[index] = first[index] + second[0];
                        else if (opcode == 28)
                            output[index] = first[index] == second[index] ? 1ull : 0ull;
                        if (opcode != 28 && !isfinite(numeric_output[index]))
                            return 0;
                    }
                }
            }
            else if (opcode >= 40 && opcode <= 43)
            {
                if ((opcode == 43 && first_count != 1) ||
                    (opcode != 43 && (first_count != 1 || second_count != 1)))
                    return 0;
                output_count = 1;
                if (opcode == 40)
                    output[0] = first_bits[0] != 0 && second_bits[0] != 0 ? 1ull : 0ull;
                else if (opcode == 41)
                    output[0] = first_bits[0] != 0 || second_bits[0] != 0 ? 1ull : 0ull;
                else if (opcode == 42)
                    output[0] = (first_bits[0] != 0) != (second_bits[0] != 0) ? 1ull : 0ull;
                else
                    output[0] = first_bits[0] == 0 ? 1ull : 0ull;
            }
            else if (opcode >= 50 && opcode <= 54)
            {
                if (opcode == 53 || opcode == 54)
                    output_count = opcode == 54 ? 1 : first_count;
                else
                {
                    if (first_count != second_count)
                        return 0;
                    output_count = first_count;
                }
                if (output_count <= 0 || output_count > band_maximum || output_count > maximum_elements)
                    return -1;
                if (opcode == 54)
                {
                    int count = 0;
                    for (int index = 0; index < first_count; index++)
                        if (first_bits[index] != 0)
                            count++;
                    numeric_output[0] = (double)count;
                }
                else
                {
                    for (int index = 0; index < output_count; index++)
                    {
                        if (opcode == 50)
                            output[index] = first_bits[index] != 0 && second_bits[index] != 0 ? 1ull : 0ull;
                        else if (opcode == 51)
                            output[index] = first_bits[index] != 0 || second_bits[index] != 0 ? 1ull : 0ull;
                        else if (opcode == 52)
                            output[index] = (first_bits[index] != 0) != (second_bits[index] != 0) ? 1ull : 0ull;
                        else
                            output[index] = first_bits[index] == 0 ? 1ull : 0ull;
                    }
                }
            }
            else
            {
                return 0;
            }

            counts[output_node] = output_count;
            return 1;
        }

        extern "C" __global__ void mathblocks_program_population(unsigned char* arena)
        {
            if (blockIdx.x != 0 || threadIdx.x != 0)
                return;

            if (mb_read_int(arena, 0) != (int)0x4d425050 || mb_read_int(arena, 4) != 1)
                return;
            int operation_count = mb_read_int(arena, 8);
            int terminal_count = mb_read_int(arena, 12);
            int band_count = mb_read_int(arena, 20);
            int maximum_operation_count = mb_read_int(arena, 24);
            int maximum_elements = mb_read_int(arena, 28);
            int proposals_per_cycle = mb_read_int(arena, 32);
            int fingerprint_capacity = mb_read_int(arena, 36);
            int output_type = mb_read_int(arena, 40);
            int state_offset = mb_read_int(arena, 44);
            int result_entry_size = mb_read_int(arena, 52);
            int operation_offset = mb_read_int(arena, 56);
            int terminal_offset = mb_read_int(arena, 60);
            int type_offset = mb_read_int(arena, 64);
            int band_offset = mb_read_int(arena, 68);
            int value_offset = mb_read_int(arena, 72);
            int workspace_type_offset = mb_read_int(arena, 76);
            int workspace_count_offset = mb_read_int(arena, 80);
            int workspace_value_offset = mb_read_int(arena, 84);
            int structural_offset = mb_read_int(arena, 88);
            int semantic_offset = mb_read_int(arena, 92);
            int result_offset = mb_read_int(arena, 96);
            mb_ull total_proposals = mb_read_ull(arena, 104);
            int* workspace_types = (int*)(arena + workspace_type_offset);
            int* workspace_counts = (int*)(arena + workspace_count_offset);
            mb_ull* workspace_values = (mb_ull*)(arena + workspace_value_offset);

            mb_write_int(arena, state_offset, 0);
            mb_write_int(arena, state_offset + 4, 0);
            int structural_count = mb_read_int(arena, state_offset + 8);
            int semantic_count = mb_read_int(arena, state_offset + 12);
            mb_ull cursor = mb_read_ull(arena, state_offset + 16);
            mb_ull structural_duplicates = mb_read_ull(arena, state_offset + 24);
            mb_ull semantic_duplicates = mb_read_ull(arena, state_offset + 32);
            mb_ull evaluated = mb_read_ull(arena, state_offset + 40);
            mb_ull cycle_trials = 0ull;
            int result_count = 0;

            if (operation_count <= 0 || terminal_count <= 0 || band_count <= 0 ||
                maximum_operation_count <= 0 || maximum_operation_count > 8 ||
                maximum_elements <= 0 || proposals_per_cycle <= 0 ||
                structural_count < 0 || semantic_count < 0 ||
                structural_count > fingerprint_capacity || semantic_count > fingerprint_capacity ||
                cursor > total_proposals)
            {
                mb_write_int(arena, state_offset, 4);
                return;
            }

            for (int proposal = 0; proposal < proposals_per_cycle && cursor < total_proposals; proposal++)
            {
                mb_ull proposal_cursor = cursor;
                cursor++;
                cycle_trials++;
                int band_index = -1;
                for (int index = 0; index < band_count; index++)
                {
                    int band = band_offset + index * 24;
                    mb_ull start = mb_read_ull(arena, band + 8);
                    mb_ull count = mb_read_ull(arena, band + 16);
                    if (proposal_cursor >= start && proposal_cursor - start < count)
                    {
                        band_index = index;
                        break;
                    }
                }
                if (band_index < 0)
                {
                    mb_write_int(arena, state_offset, 4);
                    mb_write_int(arena, state_offset + 4, 0);
                    return;
                }

                int band = band_offset + band_index * 24;
                int candidate_operation_count = mb_read_int(arena, band);
                int band_maximum = mb_read_int(arena, band + 4);
                mb_ull local = proposal_cursor - mb_read_ull(arena, band + 8);
                int selected_operations[8];
                int selected_operands[32];
                bool decoded = true;
                for (int node = 0; node < candidate_operation_count; node++)
                {
                    mb_ull available = (mb_ull)(terminal_count + node);
                    mb_ull choices = 0ull;
                    for (int operation_index = 0; operation_index < operation_count; operation_index++)
                    {
                        int operation = operation_offset + operation_index * 64;
                        choices += mb_power(available, mb_read_int(arena, operation + 4));
                    }
                    if (choices == 0ull)
                    {
                        decoded = false;
                        break;
                    }
                    mb_ull choice = local % choices;
                    local /= choices;
                    int selected = -1;
                    for (int operation_index = 0; operation_index < operation_count; operation_index++)
                    {
                        int operation = operation_offset + operation_index * 64;
                        int arity = mb_read_int(arena, operation + 4);
                        mb_ull span = mb_power(available, arity);
                        if (choice < span)
                        {
                            selected = operation_index;
                            selected_operations[node] = operation_index;
                            for (int input = 0; input < 4; input++)
                                selected_operands[node * 4 + input] = -1;
                            for (int input = 0; input < arity; input++)
                            {
                                selected_operands[node * 4 + input] = (int)(choice % available);
                                choice /= available;
                            }
                            break;
                        }
                        choice -= span;
                    }
                    if (selected < 0)
                    {
                        decoded = false;
                        break;
                    }
                }
                if (!decoded)
                    continue;

                for (int terminal = 0; terminal < terminal_count; terminal++)
                {
                    int descriptor = terminal_offset + terminal * 16;
                    int count = mb_read_int(arena, descriptor + 8);
                    int source_index = mb_read_int(arena, descriptor + 12);
                    workspace_types[terminal] = mb_read_int(arena, descriptor);
                    workspace_counts[terminal] = count;
                    for (int value = 0; value < count; value++)
                    {
                        workspace_values[terminal * maximum_elements + value] =
                            mb_read_ull(arena, value_offset + (source_index + value) * 8);
                    }
                }

                bool typed = true;
                for (int node = 0; node < candidate_operation_count; node++)
                {
                    int operation = operation_offset + selected_operations[node] * 64;
                    int arity = mb_read_int(arena, operation + 4);
                    for (int input = 0; input < arity; input++)
                    {
                        int expected = mb_read_int(arena, operation + 12 + input * 4);
                        int actual = workspace_types[selected_operands[node * 4 + input]];
                        if (!mb_types_compatible(arena, type_offset, expected, actual))
                        {
                            typed = false;
                            break;
                        }
                    }
                    if (!typed)
                        break;
                    workspace_types[terminal_count + node] = mb_read_int(arena, operation + 8);
                }
                int final_node = terminal_count + candidate_operation_count - 1;
                if (!typed || !mb_types_compatible(arena, type_offset, output_type, workspace_types[final_node]))
                    continue;

                bool executable_candidate = true;
                for (int node = 0; node < candidate_operation_count; node++)
                {
                    int operation = operation_offset + selected_operations[node] * 64;
                    int outcome = mb_execute_operation(
                        mb_read_int(arena, operation),
                        mb_read_int(arena, operation + 4),
                        selected_operands + node * 4,
                        terminal_count + node,
                        workspace_counts,
                        workspace_values,
                        maximum_elements,
                        band_maximum);
                    if (outcome < 0)
                    {
                        mb_write_int(arena, state_offset, 3);
                        mb_write_int(arena, state_offset + 4, 0);
                        return;
                    }
                    if (outcome == 0)
                    {
                        executable_candidate = false;
                        break;
                    }
                    int produced_node = terminal_count + node;
                    int produced_type = workspace_types[produced_node];
                    int produced_descriptor = type_offset + produced_type * 48;
                    int produced_kind = mb_read_int(arena, produced_descriptor);
                    int produced_rows = mb_read_int(arena, produced_descriptor + 4);
                    if ((produced_kind == 4 || produced_kind == 11) &&
                        produced_rows != 0 && produced_rows != workspace_counts[produced_node])
                    {
                        executable_candidate = false;
                        break;
                    }
                }
                if (!executable_candidate)
                    continue;

                int final_count = workspace_counts[final_node];
                int final_type = workspace_types[final_node];
                int final_descriptor = type_offset + final_type * 48;
                int final_kind = mb_read_int(arena, final_descriptor);
                int declared_rows = mb_read_int(arena, final_descriptor + 4);
                if ((final_kind == 4 || final_kind == 11) && declared_rows != 0 && declared_rows != final_count)
                    continue;
                MbHash structural = mb_structural_hash(
                    arena,
                    operation_offset,
                    candidate_operation_count,
                    selected_operations,
                    selected_operands);
                if (mb_contains_hash(arena, structural_offset, structural_count, structural))
                {
                    structural_duplicates++;
                    continue;
                }
                if (structural_count >= fingerprint_capacity)
                {
                    mb_write_int(arena, state_offset, 1);
                    mb_write_int(arena, state_offset + 4, 0);
                    return;
                }
                mb_write_hash(arena, structural_offset, structural_count, structural);
                structural_count++;
                evaluated++;

                mb_ull* final_values = workspace_values + final_node * maximum_elements;
                MbHash semantic = mb_semantic_hash(
                    arena,
                    type_offset,
                    final_type,
                    final_count,
                    final_values);
                if (mb_contains_hash(arena, semantic_offset, semantic_count, semantic))
                {
                    semantic_duplicates++;
                    continue;
                }
                if (semantic_count >= fingerprint_capacity)
                {
                    mb_write_int(arena, state_offset, 2);
                    mb_write_int(arena, state_offset + 4, 0);
                    return;
                }
                mb_write_hash(arena, semantic_offset, semantic_count, semantic);
                semantic_count++;

                int entry = result_offset + result_count * result_entry_size;
                mb_write_ull(arena, entry, proposal_cursor);
                mb_write_int(arena, entry + 8, candidate_operation_count);
                mb_write_int(arena, entry + 12, final_type);
                mb_write_int(arena, entry + 16, final_count);
                mb_write_ull(arena, entry + 24, structural.first);
                mb_write_ull(arena, entry + 32, structural.second);
                mb_write_ull(arena, entry + 40, semantic.first);
                mb_write_ull(arena, entry + 48, semantic.second);
                for (int node = 0; node < candidate_operation_count; node++)
                {
                    int operation_entry = entry + 56 + node * 20;
                    mb_write_int(arena, operation_entry, selected_operations[node]);
                    for (int input = 0; input < 4; input++)
                        mb_write_int(arena, operation_entry + 4 + input * 4, selected_operands[node * 4 + input]);
                }
                int output_entry = entry + mb_align(56 + maximum_operation_count * 20);
                for (int value = 0; value < final_count; value++)
                    mb_write_ull(arena, output_entry + value * 8, final_values[value]);
                result_count++;
            }

            mb_write_int(arena, state_offset, 0);
            mb_write_int(arena, state_offset + 4, result_count);
            mb_write_int(arena, state_offset + 8, structural_count);
            mb_write_int(arena, state_offset + 12, semantic_count);
            mb_write_ull(arena, state_offset + 16, cursor);
            mb_write_ull(arena, state_offset + 24, structural_duplicates);
            mb_write_ull(arena, state_offset + 32, semantic_duplicates);
            mb_write_ull(arena, state_offset + 40, evaluated);
            mb_write_ull(arena, state_offset + 48, cycle_trials);
        }
        """;
}
