namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// One call of PatternResearcher's device route (main 37b0702c, MathBlocks 0.7.0-local.4): the identity, the route, the parameter, and the MathBlocks operations the route dispatches in
/// order. The whole route dispatches the identity's own contract with the contract's family and opcode (the layered formula CUDA module's Dispatch and the layered general plan). The
/// lifted route (vector.scale and vector.subtract only) dispatches the elementwise twin of the scalar operation with the fill appended, then its validity sibling without the fill
/// (the generic scalar dispatch CUDA module's DispatchLifted). A window form dispatches the form with the width and the fill, and its validity sibling with the width.
/// </summary>
/// <param name="Identity">The identity PatternResearcher names.</param>
/// <param name="Route">The route name: whole or lifted.</param>
/// <param name="Parameter">The parameter label: the scale factor, the window width, or a dash.</param>
/// <param name="Width">The window width, or one.</param>
/// <param name="Constant">The scale factor, or zero.</param>
/// <param name="Contracts">The device contract identities dispatched in order; the last is the validity sibling.</param>
/// <param name="TimedSteps">How many of the contracts one timed launch dispatches.</param>
internal sealed record VectorBlockCall(string Identity, string Route, string Parameter, float Width, float Constant, string[] Contracts, int TimedSteps)
{
    /// <summary>Gets the key shared by the classes of one identity, route and parameter.</summary>
    internal string Name => $"{Identity} {Route}";

    /// <summary>Gets whether the identity is the window form.</summary>
    internal bool IsWindow => string.Equals(Identity, VectorBlockCalls.Standardize, StringComparison.Ordinal);

    /// <summary>Gets whether the route is the lifted one.</summary>
    internal bool IsLifted => string.Equals(Route, VectorBlockCalls.Lifted, StringComparison.Ordinal);
}
