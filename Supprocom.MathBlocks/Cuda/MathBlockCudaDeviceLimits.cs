using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

// The limits of the CUDA device that bound the launch options: CU_DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK and
// CU_DEVICE_ATTRIBUTE_MAX_GRID_DIM_X.
[StructLayout(LayoutKind.Sequential)]
internal readonly record struct MathBlockCudaDeviceLimits(int MaximumThreadsPerBlock, int MaximumGridX);
