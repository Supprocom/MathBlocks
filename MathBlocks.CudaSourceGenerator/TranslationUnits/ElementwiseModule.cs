#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

// Elementwise forms of the 41 scalar sources. Opcode 2 * source + sibling + 128 * mask, with source the index in
// the elementwise source list and bit k of mask set when argument k is a vector (the other arguments are
// broadcast scalars). Every thread checks the inputs itself and then evaluates the rows thread, thread + threads,
// ...: the elementwise kernel passes the grid-wide thread index and count, the device dispatch path the thread
// index in the block. Row i calls the source's per-row function, the one its scalar operation uses, on row i of
// every vector argument and the scalar arguments; rows whose source result is invalid hold the fill (form) or
// false (sibling).
[TranspileToCUDA]
internal static unsafe class ElementwiseModule
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

    [CudaExternal]
    private static bool mathblocks_scalar_value(int opcode, double a, double b, double c, double* value) => throw new NotSupportedException();

    [CudaExternal]
    private static bool mathblocks_probability_scalar_value(int opcode, double a, double b, double c, double* value) => throw new NotSupportedException();

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
                return 2;
            case 12:
            case 40:
                return 3;
            default:
                return 1;
        }
    }

    [CudaDevice]
    private static bool mathblocks_elementwise_row_value(int source_opcode, double a, double b, double c, double* value)
    {
        return source_opcode >= 64
            ? mathblocks_probability_scalar_value(source_opcode - 64, a, b, c, value)
            : mathblocks_scalar_value(source_opcode, a, b, c, value);
    }

    // Argument row: the vector's row, or the broadcast scalar; an absent argument reads 0.
    [CudaDevice]
    private static double mathblocks_elementwise_argument([CudaReadOnly] MathBlockSlot* slot, bool vector, int row)
    {
        if (slot == null)
            return 0.0;
        return vector ? ((double*)slot->data_pointer)[row] : slot->scalar_value;
    }

    [CudaDevice]
    private static void mathblocks_elementwise_publish(MathBlockSlot* output, bool valid, int count, int thread)
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
        int mask = opcode / 128;
        int form = opcode % 128;
        int source = form / 2;
        bool sibling = form % 2 != 0;
        int arity = mathblocks_elementwise_source_arity(source);
        bool valid = opcode >= 0 && source < 41 && mask > 0 && mask < (1 << arity) &&
            input_count == arity + (sibling ? 0 : 1);
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
        double fill = sibling ? 0.0 : inputs[arity]->scalar_value;
        int source_opcode = mathblocks_elementwise_source_opcode(source);
        double* result = (double*)output->data_pointer;
        CudaInt32* boolean_result = (CudaInt32*)output->data_pointer;
        for (int row = thread; row < count; row += threads)
        {
            double value = 0.0;
            bool row_valid = mathblocks_elementwise_row_value(
                source_opcode,
                mathblocks_elementwise_argument(first, first_vector, row),
                mathblocks_elementwise_argument(second, second_vector, row),
                mathblocks_elementwise_argument(third, third_vector, row),
                &value);
            if (sibling)
                boolean_result[row] = row_valid;
            else
                result[row] = row_valid ? value : fill;
        }
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
