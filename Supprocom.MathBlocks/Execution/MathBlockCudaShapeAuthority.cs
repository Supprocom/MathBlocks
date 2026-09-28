using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

[StructLayout(LayoutKind.Sequential)]
internal readonly record struct MathBlockCudaShapeAuthority(int Rows, int Columns);
