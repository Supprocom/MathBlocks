#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

// Elementwise forms of the scalar sources. Opcode 2 * source + sibling + 128 * mask for sources below 64 (1024 + 2 * source + sibling + 65536 * mask
// above), with source the index in the elementwise source list and bit k of mask set when argument k is a vector (the other arguments are
// broadcast scalars). A mask of 0 in the opcode is derived from the input slots (a slot with elements is a vector). Every thread checks the inputs itself and then evaluates the rows thread, thread + threads,
// ...: the elementwise kernel passes the grid-wide thread index and count, the device dispatch path the thread
// index in the block. Row i calls the source's per-row function, the one its scalar operation uses, on row i of
// every vector argument and the scalar arguments; rows with a non-finite argument or an invalid source result hold the fill (form) or
// false (sibling).
[TranspileToCUDA]
internal static unsafe class ElementwiseModule
{
    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_elementwise_source_count() => throw new NotSupportedException();

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

    [CudaExternal]
    private static bool mathblocks_scalar_value(int opcode, float a, float b, float c, float* value) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_probability_scalar_value(int opcode, float a, float b, float c, float* value, bool* converged) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_nonconvergence_record_elementwise(int opcode) => throw new NotSupportedException();

    // The source's opcode in its own family: the Scalar opcode, or 64 plus the Probability opcode.
    [CudaDevice]
    private static int mathblocks_elementwise_source_opcode(int source)
    {
        switch (source)
        {
            case 0: return 64;
            case 1: return 65;
            case 2: return 66;
            case 3: return 87;
            case 4: return 89;
            case 5: return 90;
            case 6: return 25;
            case 7: return 24;
            case 8: return 27;
            case 9: return 26;
            case 10: return 19;
            case 11: return 35;
            case 12: return 10;
            case 13: return 20;
            case 14: return 22;
            case 15: return 15;
            case 16: return 13;
            case 17: return 34;
            case 18: return 29;
            case 19: return 28;
            case 20: return 30;
            case 21: return 32;
            case 22: return 31;
            case 23: return 33;
            case 24: return 42;
            case 25: return 39;
            case 26: return 40;
            case 27: return 9;
            case 28: return 8;
            case 29: return 38;
            case 30: return 4;
            case 31: return 11;
            case 32: return 36;
            case 33: return 21;
            case 34: return 41;
            case 35: return 23;
            case 36: return 37;
            case 37: return 92;
            case 38: return 43;
            case 39: return 93;
            case 40: return 94;
            case 41: return 5;
            case 42: return 0;
            case 43: return 1;
            case 44: return 2;
            case 45: return 3;
            case 46: return 16;
            case 47: return 18;
            case 48: return 14;
            case 49: return 12;
            case 50: return 17;
            case 51: return 7;
            case 52: return 6;
            default: return -1;
        }
    }

    // The source's argument count.
    [CudaDevice]
    private static int mathblocks_elementwise_source_arity(int source)
    {
        switch (source)
        {
            case 0:
            case 1:
            case 4:
            case 5:
            case 8:
            case 27:
            case 28:
            case 29:
            case 37:
            case 42:
            case 43:
            case 44:
            case 45:
            case 46:
                return 2;
            case 12:
            case 40:
                return 3;
            default:
                return 1;
        }
    }

    [CudaDevice]
    private static bool mathblocks_elementwise_row_value(int source_opcode, float a, float b, float c, float* value, bool* converged)
    {
        *converged = true;
        return source_opcode >= 64
            ? mathblocks_probability_scalar_value(source_opcode - 64, a, b, c, value, converged)
            : mathblocks_scalar_value(source_opcode, a, b, c, value);
    }

    // Argument row: the vector's row, or the broadcast scalar; an absent argument reads 0.
    [CudaDevice]
    private static float mathblocks_elementwise_argument([CudaReadOnly] MathBlockSlot* slot, bool vector, int row)
    {
        if (slot == null)
            return 0.0f;
        return vector ? ((float*)slot->data_pointer)[row] : slot->scalar_value;
    }

    [CudaDevice]
    private static void mathblocks_elementwise_publish(MathBlockSlot* output, bool valid, int count, int thread)
    {
        if (thread != 0)
            return;
        output->scalar_value = 0.0f;
        output->boolean_value = 0;
        output->columns = 0;
        output->rows = valid ? count : 0;
        output->count = valid ? count : 0;
        output->valid = valid;
    }

    // Opcodes below 1024 are 2 * source + sibling + 128 * mask for sources below 64; larger sources are 1024 + (2 * source + sibling) + 65536 * mask
    // (MathBlockCudaElementwiseOpcode on the host). Returns the form, 2 * source + sibling, and gives the passed mask, the source and
    // whether the form is the sibling (validity) one.
    [CudaDevice]
    private static int mathblocks_elementwise_decode(int opcode, int* passed_mask, int* source, bool* sibling)
    {
        int mask = opcode / 128;
        int form = opcode % 128;
        if (opcode >= 1024)
        {
            int relative = opcode - 1024;
            mask = relative / 65536;
            form = relative % 65536;
        }
        *passed_mask = mask;
        *source = form / 2;
        *sibling = form % 2 != 0;
        return form;
    }

    // One row: the per-node values (form, the source's opcode in its family and arity) arrive from the caller, which reads the arguments. As
    // CoreCLR's row: a non-finite argument, a vector row or a broadcast scalar, makes the row invalid before the source is evaluated; the
    // source's own result is checked after. Writes the value, or the fill for an invalid row, and returns the row's validity.
    [CudaDevice]
    private static bool mathblocks_elementwise_row_core(
        int form,
        int source_opcode,
        int arity,
        float a,
        float b,
        float c,
        float fill,
        float* result)
    {
        float value = 0.0f;
        bool converged = true;
        bool row_valid = float.IsFinite(a) &&
            (arity < 2 || float.IsFinite(b)) &&
            (arity < 3 || float.IsFinite(c));
        if (row_valid)
            row_valid = mathblocks_elementwise_row_value(
                source_opcode,
                a,
                b,
                c,
                &value,
                &converged);
        if (!converged) mathblocks_nonconvergence_record_elementwise(form);
        *result = row_valid ? value : fill;
        return row_valid;
    }

    // thread is this thread's index among the threads that evaluate rows, and threads their count.
    [CudaDevice]
    private static void mathblocks_elementwise_run(
        int opcode,
        MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output,
        int thread,
        int threads)
    {
        int passed_mask = 0;
        int source = 0;
        bool sibling = false;
        int form = mathblocks_elementwise_decode(opcode, &passed_mask, &source, &sibling);
        int arity = mathblocks_elementwise_source_arity(source);
        // The argument kinds come from the input slots: a slot with elements (count > 0) is a vector, and a scalar has count 0 in the value
        // ABI. So the base opcode (mask bits 0) is enough; a consumer need not pass the mask. An empty vector has count 0 as a scalar does, so
        // a passed mask may still mark a slot with count 0 as a vector (the worker path does), and then the passed mask decides for that
        // slot. A slot with elements whose bit the passed mask leaves clear contradicts the inputs: the result is invalid.
        int derived_mask = 0;
        for (int index = 0; index < arity && index < input_count; index++)
            if (inputs[index] != null && inputs[index]->count > 0)
                derived_mask |= 1 << index;
        int mask = passed_mask == 0 ? derived_mask : passed_mask;
        bool valid = opcode >= 0 && source < mathblocks_limit_elementwise_source_count() && mask > 0 && mask < (1 << arity) &&
            (derived_mask & ~mask) == 0 && input_count == arity + (sibling ? 0 : 1);
        for (int index = 0; valid && index < input_count; index++)
            if (inputs[index] == null || !inputs[index]->valid)
                valid = false;
        int count = -1;
        for (int index = 0; valid && index < arity; index++)
        {
            if ((mask & (1 << index)) == 0)
                continue;
            if (count < 0)
                count = inputs[index]->count;
            else if (inputs[index]->count != count)
                valid = false;
        }
        if (valid && count > output->capacity)
            valid = false;
        mathblocks_elementwise_publish(output, valid, count, thread);
        if (!valid)
            return;

        MathBlockSlot* first = Cuda.ReadOnly(inputs[0]);
        MathBlockSlot* second = Cuda.ReadOnly(arity > 1 ? inputs[1] : null);
        MathBlockSlot* third = Cuda.ReadOnly(arity > 2 ? inputs[2] : null);
        bool first_vector = (mask & 1) != 0;
        bool second_vector = (mask & 2) != 0;
        bool third_vector = (mask & 4) != 0;
        float fill = sibling ? 0.0f : inputs[arity]->scalar_value;
        int source_opcode = mathblocks_elementwise_source_opcode(source);
        float* result = (float*)output->data_pointer;
        CudaInt32* boolean_result = (CudaInt32*)output->data_pointer;
        for (int row = thread; row < count; row += threads)
        {
            float value = 0.0f;
            float argument_a = mathblocks_elementwise_argument(first, first_vector, row);
            float argument_b = mathblocks_elementwise_argument(second, second_vector, row);
            float argument_c = mathblocks_elementwise_argument(third, third_vector, row);
            bool row_valid = mathblocks_elementwise_row_core(
                form,
                source_opcode,
                arity,
                argument_a,
                argument_b,
                argument_c,
                fill,
                &value);
            if (sibling)
                boolean_result[row] = row_valid;
            else
                result[row] = value;
        }
    }

    // The public single-row entry point of the module (MathBlockCudaDeviceModule.ElementwiseRowSignature): one row of an elementwise
    // source with the dispatch's semantics. The opcode is the one the dispatch takes, narrow or wide, values or validity form; its mask
    // bits are ignored, and a broadcast scalar is passed as a plain value. An opcode that is negative or names a source past the source
    // count gives the fill and false without evaluating. Arguments beyond the source's arity read 0, as the dispatch's absent slots do.
    // Both forms compute the same way: *result is the value, or the fill for an invalid row, and the return value is the row's validity.
    [CudaDevice(Name = "mathblocks_elementwise_row")]
    private static bool mathblocks_elementwise_row_entry(int opcode, float a, float b, float c, float fill, float* result)
    {
        int passed_mask = 0;
        int source = 0;
        bool sibling = false;
        int form = mathblocks_elementwise_decode(opcode, &passed_mask, &source, &sibling);
        if (opcode < 0 || source >= mathblocks_limit_elementwise_source_count())
        {
            *result = fill;
            return false;
        }
        int arity = mathblocks_elementwise_source_arity(source);
        float argument_b = arity > 1 ? b : 0.0f;
        float argument_c = arity > 2 ? c : 0.0f;
        return mathblocks_elementwise_row_core(form, mathblocks_elementwise_source_opcode(source), arity, a, argument_b, argument_c, fill, result);
    }

    [CudaDevice(Name = "mathblocks_elementwise_dispatch")]
    private static void mathblocks_elementwise(
        int opcode,
        MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        mathblocks_elementwise_run(
            opcode,
            inputs,
            input_count,
            output,
            (int)Cuda.ThreadIdx.X,
            (int)Cuda.BlockDim.X);
    }
}
