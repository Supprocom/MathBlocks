#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

[TranspileToCUDA]
internal static unsafe class DeviceDispatchModule
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
    private static void mathblocks_advanced_dispatch(int opcode, MathBlockSlot** inputs, int input_count, MathBlockSlot* output) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_complex_dispatch(int opcode, MathBlockSlot** inputs, int input_count, MathBlockSlot* output) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_geometry_dispatch(int opcode, MathBlockSlot** inputs, int input_count, MathBlockSlot* output) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_graph_dispatch(int opcode, MathBlockSlot** inputs, int input_count, MathBlockSlot* output) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_matrix_dispatch(int opcode, MathBlockSlot** inputs, int input_count, MathBlockSlot* output) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_probability_dispatch(int opcode, MathBlockSlot** inputs, int input_count, MathBlockSlot* output) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_scalar_dispatch(int opcode, MathBlockSlot** inputs, int input_count, MathBlockSlot* output) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_sequence_path_dispatch(int opcode, MathBlockSlot** inputs, int input_count, MathBlockSlot* output) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_statistics_dispatch(int opcode, MathBlockSlot** inputs, int input_count, MathBlockSlot* output) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_transport_dispatch(int opcode, MathBlockSlot** inputs, int input_count, MathBlockSlot* output) => throw new NotSupportedException();

    [CudaExternal]
    private static void mathblocks_vector_dispatch(int opcode, MathBlockSlot** inputs, int input_count, MathBlockSlot* output) => throw new NotSupportedException();

    [CudaDevice]
    private static MathBlockSlot** mathblocks_dispatch_inputs(
        [CudaReadOnly] MathBlockSlot** inputs)
    {
        // CSharp2CUDA 0.3.1 lowers conditional input reads through mutable pointer
        // temporaries. Only the dispatcher casts the pointer array; operation
        // implementations still wrap each input slot with Cuda.ReadOnly.
        return (MathBlockSlot**)(ulong)inputs;
    }

    [CudaDevice]
    private static void mathblocks_operation_dispatch(
        int family,
        int opcode,
        [CudaReadOnly] MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        MathBlockSlot** dispatchInputs = mathblocks_dispatch_inputs(inputs);
        switch (family)
        {
            case 0: mathblocks_advanced_dispatch(opcode, dispatchInputs, input_count, output); break;
            case 1: mathblocks_complex_dispatch(opcode, dispatchInputs, input_count, output); break;
            case 2: mathblocks_geometry_dispatch(opcode, dispatchInputs, input_count, output); break;
            case 3: mathblocks_graph_dispatch(opcode, dispatchInputs, input_count, output); break;
            case 4: mathblocks_matrix_dispatch(opcode, dispatchInputs, input_count, output); break;
            case 5: mathblocks_probability_dispatch(opcode, dispatchInputs, input_count, output); break;
            case 6: mathblocks_scalar_dispatch(opcode, dispatchInputs, input_count, output); break;
            case 7: mathblocks_sequence_path_dispatch(opcode, dispatchInputs, input_count, output); break;
            case 8: mathblocks_statistics_dispatch(opcode, dispatchInputs, input_count, output); break;
            case 9: mathblocks_transport_dispatch(opcode, dispatchInputs, input_count, output); break;
            case 10: mathblocks_vector_dispatch(opcode, dispatchInputs, input_count, output); break;
            default:
                if (Cuda.ThreadIdx.X == 0)
                {
                    output->valid = 0;
                    output->count = 0;
                }
                break;
        }
        Cuda.SyncThreads();
    }

    [CudaGlobal]
    private static void mathblocks_scalar(
        int opcode,
        [CudaReadOnly] MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        mathblocks_scalar_dispatch(opcode, mathblocks_dispatch_inputs(inputs), input_count, output);
    }

    [CudaGlobal]
    private static void mathblocks_vector(
        int opcode,
        [CudaReadOnly] MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        mathblocks_vector_dispatch(opcode, mathblocks_dispatch_inputs(inputs), input_count, output);
    }

    [CudaGlobal]
    private static void mathblocks_complex(
        int opcode,
        [CudaReadOnly] MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        mathblocks_complex_dispatch(opcode, mathblocks_dispatch_inputs(inputs), input_count, output);
    }

    [CudaGlobal]
    private static void mathblocks_matrix(
        int opcode,
        [CudaReadOnly] MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        mathblocks_matrix_dispatch(opcode, mathblocks_dispatch_inputs(inputs), input_count, output);
    }

    [CudaGlobal]
    private static void mathblocks_probability(
        int opcode,
        [CudaReadOnly] MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        mathblocks_probability_dispatch(opcode, mathblocks_dispatch_inputs(inputs), input_count, output);
    }

    [CudaGlobal]
    private static void mathblocks_sequence_path(
        int opcode,
        [CudaReadOnly] MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        mathblocks_sequence_path_dispatch(opcode, mathblocks_dispatch_inputs(inputs), input_count, output);
    }

    [CudaGlobal]
    private static void mathblocks_statistics(
        int opcode,
        [CudaReadOnly] MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        mathblocks_statistics_dispatch(opcode, mathblocks_dispatch_inputs(inputs), input_count, output);
    }

    [CudaGlobal]
    private static void mathblocks_geometry(
        int opcode,
        [CudaReadOnly] MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        mathblocks_geometry_dispatch(opcode, mathblocks_dispatch_inputs(inputs), input_count, output);
    }

    [CudaGlobal]
    private static void mathblocks_graph(
        int opcode,
        [CudaReadOnly] MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        mathblocks_graph_dispatch(opcode, mathblocks_dispatch_inputs(inputs), input_count, output);
    }

    [CudaGlobal]
    private static void mathblocks_advanced(
        int opcode,
        [CudaReadOnly] MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        mathblocks_advanced_dispatch(opcode, mathblocks_dispatch_inputs(inputs), input_count, output);
    }

    [CudaGlobal]
    private static void mathblocks_transport(
        int opcode,
        [CudaReadOnly] MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        mathblocks_transport_dispatch(opcode, mathblocks_dispatch_inputs(inputs), input_count, output);
    }
}
