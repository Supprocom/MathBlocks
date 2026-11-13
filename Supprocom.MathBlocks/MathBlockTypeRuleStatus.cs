namespace Supprocom.MathBlocks;

// The result codes of the shared resolver, in the order the translation unit defines them.
internal enum MathBlockTypeRuleStatus
{
    Ok = 0,
    Arity = 1,
    Kind = 2,
    Dimensionless = 3,
    Unit = 4,
    Shape = 5,
    Overflow = 6,
    Rule = 7
}
