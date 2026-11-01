using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Whether a CUDA test may run. A test needs a device; without one it fails at its first line with <c>A CUDA device is required.</c>, which hides
/// every defect that comes before the first device call (an operation identity that does not exist, a wrong input type, a plan that throws).
/// With the environment variable <c>MATHBLOCKS_TEST_PRETEND_DEVICE=1</c> (set only by the pre-launch gate of the device run script, with the device
/// hidden) the tests go on to their first device call and fail there with a device error: any other failure is a test or library defect that the
/// device run would have hit after taking the lock.
/// </summary>
internal static class CudaTestDevice
{
    internal const string PretendVariable = "MATHBLOCKS_TEST_PRETEND_DEVICE";

    /// <summary>Gets whether the test may go on to the device.</summary>
    internal static bool Available =>
        MathBlocksCUDAWorker.IsAvailable || string.Equals(Environment.GetEnvironmentVariable(PretendVariable), "1", StringComparison.Ordinal);
}
