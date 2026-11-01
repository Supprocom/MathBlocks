#ifndef CSHARP2CUDA_INTEGER_SEMANTICS_0_1
#define CSHARP2CUDA_INTEGER_SEMANTICS_0_1
static_assert(sizeof(unsigned short) == 2, "C# char requires 16 bits");
static_assert(sizeof(int) == 4, "CSharp2CUDA requires a 32-bit CUDA int.");
static_assert(sizeof(long long) == 8, "CSharp2CUDA requires a 64-bit CUDA long long.");

static __device__ __forceinline__ int csharp2cuda_index_from_end(
    int length,
    int value)
{
    if (value < 0) __trap();
    return length - value;
}

static __device__ __forceinline__ int csharp2cuda_i32_from_bits(unsigned int bits)
{
    return bits <= 0x7fffffffu ? (int)bits : -1 - (int)(~bits);
}

static __device__ __forceinline__ signed char csharp2cuda_i8_from_bits(
    unsigned int bits)
{
    unsigned int value = bits & 0xffu;
    return value <= 0x7fu
        ? (signed char)value
        : (signed char)(-1 - (int)((~value) & 0xffu));
}

static __device__ __forceinline__ short csharp2cuda_i16_from_bits(
    unsigned int bits)
{
    unsigned int value = bits & 0xffffu;
    return value <= 0x7fffu
        ? (short)value
        : (short)(-1 - (int)((~value) & 0xffffu));
}

static __device__ __forceinline__ long long csharp2cuda_i64_from_bits(unsigned long long bits)
{
    return bits <= 0x7fffffffffffffffull ? (long long)bits : -1LL - (long long)(~bits);
}

static __device__ __forceinline__ int csharp2cuda_f64_to_i32(double value)
{
    if (isnan(value)) return 0;
    if (value >= 2147483648.0) return 2147483647;
    if (value <= -2147483648.0) return (-2147483647 - 1);
    return (int)value;
}

static __device__ __forceinline__ unsigned int csharp2cuda_f64_to_u32(double value)
{
    if (isnan(value) || value <= 0.0) return 0u;
    if (value >= 4294967296.0) return 0xffffffffu;
    return (unsigned int)value;
}

static __device__ __forceinline__ long long csharp2cuda_f64_to_i64(double value)
{
    if (isnan(value)) return 0LL;
    if (value >= 9223372036854775808.0) return 9223372036854775807LL;
    if (value <= -9223372036854775808.0) return (-9223372036854775807LL - 1LL);
    return (long long)value;
}

static __device__ __forceinline__ unsigned long long csharp2cuda_f64_to_u64(
    double value)
{
    if (isnan(value) || value <= 0.0) return 0ull;
    if (value >= 18446744073709551616.0) return 0xffffffffffffffffull;
    return (unsigned long long)value;
}

static __device__ __forceinline__ signed char csharp2cuda_f64_to_i8(double value)
{
    return csharp2cuda_i8_from_bits((unsigned int)csharp2cuda_f64_to_i32(value));
}

static __device__ __forceinline__ unsigned char csharp2cuda_f64_to_u8(double value)
{
    return (unsigned char)csharp2cuda_f64_to_i32(value);
}

static __device__ __forceinline__ short csharp2cuda_f64_to_i16(double value)
{
    return csharp2cuda_i16_from_bits((unsigned int)csharp2cuda_f64_to_i32(value));
}

static __device__ __forceinline__ unsigned short csharp2cuda_f64_to_u16(double value)
{
    return (unsigned short)csharp2cuda_f64_to_i32(value);
}

template <typename T>
static __device__ __forceinline__ T* csharp2cuda_pointer_add(T* pointer, int offset)
{
    unsigned long long address = (unsigned long long)pointer;
    unsigned long long displacement =
        (unsigned long long)(long long)offset * (unsigned long long)sizeof(T);
    return (T*)(address + displacement);
}

template <typename T>
static __device__ __forceinline__ T* csharp2cuda_pointer_add_reverse(int offset, T* pointer)
{
    return csharp2cuda_pointer_add(pointer, offset);
}

static __device__ __forceinline__ double csharp2cuda_f64_maximum(double left, double right)
{
    if (left != right)
    {
        if (!isnan(left))
            return right < left ? left : right;
        return left;
    }
    return signbit(right) ? left : right;
}

static __device__ __forceinline__ double csharp2cuda_f64_minimum(double left, double right)
{
    if (left != right)
    {
        if (!isnan(left))
            return left < right ? left : right;
        return left;
    }
    return signbit(left) ? left : right;
}

static __device__ __forceinline__ float csharp2cuda_f32_maximum(float left, float right)
{
    if (left != right)
    {
        if (!isnan(left))
            return right < left ? left : right;
        return left;
    }
    return signbit(right) ? left : right;
}

static __device__ __forceinline__ float csharp2cuda_f32_minimum(float left, float right)
{
    if (left != right)
    {
        if (!isnan(left))
            return left < right ? left : right;
        return left;
    }
    return signbit(left) ? left : right;
}

static __device__ __forceinline__ double csharp2cuda_f64_clamp(
    double value,
    double minimum,
    double maximum)
{
    if (minimum > maximum)
    {
        __trap();
        return 0.0;
    }
    return value < minimum ? minimum : value > maximum ? maximum : value;
}

static __device__ __forceinline__ float csharp2cuda_f32_clamp(
    float value,
    float minimum,
    float maximum)
{
    if (minimum > maximum)
    {
        __trap();
        return 0.0f;
    }
    return value < minimum ? minimum : value > maximum ? maximum : value;
}

static __device__ __forceinline__ int csharp2cuda_f64_sign(double value)
{
    if (isnan(value))
    {
        __trap();
        return 0;
    }
    return value > 0.0 ? 1 : value < 0.0 ? -1 : 0;
}

static __device__ __forceinline__ int csharp2cuda_f32_sign(float value)
{
    if (isnan(value))
    {
        __trap();
        return 0;
    }
    return value > 0.0f ? 1 : value < 0.0f ? -1 : 0;
}

static __device__ __forceinline__ signed char csharp2cuda_integral_abs(
    signed char value)
{
    if (value == (signed char)-128)
    {
        __trap();
        return 0;
    }
    return value < 0 ? (signed char)(-(int)value) : value;
}

static __device__ __forceinline__ short csharp2cuda_integral_abs(short value)
{
    if (value == (short)-32768)
    {
        __trap();
        return 0;
    }
    return value < 0 ? (short)(-(int)value) : value;
}

static __device__ __forceinline__ int csharp2cuda_integral_abs(int value)
{
    if (value == (-2147483647 - 1))
    {
        __trap();
        return 0;
    }
    return value < 0 ? -value : value;
}

static __device__ __forceinline__ long long csharp2cuda_integral_abs(
    long long value)
{
    if (value == (-9223372036854775807LL - 1LL))
    {
        __trap();
        return 0LL;
    }
    return value < 0LL ? -value : value;
}

template <typename T>
static __device__ __forceinline__ int csharp2cuda_integral_sign(T value)
{
    return value > (T)0 ? 1 : value < (T)0 ? -1 : 0;
}

template <typename T>
static __device__ __forceinline__ T csharp2cuda_integral_minimum(T left, T right)
{
    return left < right ? left : right;
}

template <typename T>
static __device__ __forceinline__ T csharp2cuda_integral_maximum(T left, T right)
{
    return left > right ? left : right;
}

template <typename T>
static __device__ __forceinline__ T csharp2cuda_integral_clamp(
    T value,
    T minimum,
    T maximum)
{
    if (minimum > maximum)
    {
        __trap();
        return (T)0;
    }
    return value < minimum ? minimum : value > maximum ? maximum : value;
}

template <typename T>
static __device__ __forceinline__ bool csharp2cuda_is_pow2(T value)
{
    return value > (T)0 && (value & (value - (T)1)) == (T)0;
}

static __device__ __forceinline__ unsigned int
csharp2cuda_u32_round_up_to_power_of_two(unsigned int value)
{
    value--;
    value |= value >> 1;
    value |= value >> 2;
    value |= value >> 4;
    value |= value >> 8;
    value |= value >> 16;
    return value + 1u;
}

static __device__ __forceinline__ unsigned long long
csharp2cuda_u64_round_up_to_power_of_two(unsigned long long value)
{
    value--;
    value |= value >> 1;
    value |= value >> 2;
    value |= value >> 4;
    value |= value >> 8;
    value |= value >> 16;
    value |= value >> 32;
    return value + 1ull;
}

static __device__ __forceinline__ int csharp2cuda_u32_trailing_zero_count(
    unsigned int value)
{
    return value == 0u ? 32 : __ffs(value) - 1;
}

static __device__ __forceinline__ int csharp2cuda_u64_trailing_zero_count(
    unsigned long long value)
{
    return value == 0ull ? 64 : __ffsll(value) - 1;
}

static __device__ __forceinline__ unsigned int csharp2cuda_u32_rotate_left(
    unsigned int value,
    int count)
{
    unsigned int shift = (unsigned int)count & 31u;
    return shift == 0u ? value : (value << shift) | (value >> (32u - shift));
}

static __device__ __forceinline__ unsigned long long csharp2cuda_u64_rotate_left(
    unsigned long long value,
    int count)
{
    unsigned int shift = (unsigned int)count & 63u;
    return shift == 0u ? value : (value << shift) | (value >> (64u - shift));
}

static __device__ __forceinline__ unsigned int csharp2cuda_u32_rotate_right(
    unsigned int value,
    int count)
{
    unsigned int shift = (unsigned int)count & 31u;
    return shift == 0u ? value : (value >> shift) | (value << (32u - shift));
}

static __device__ __forceinline__ unsigned long long csharp2cuda_u64_rotate_right(
    unsigned long long value,
    int count)
{
    unsigned int shift = (unsigned int)count & 63u;
    return shift == 0u ? value : (value >> shift) | (value << (64u - shift));
}

static __device__ __forceinline__ int csharp2cuda_u32_log2(unsigned int value)
{
    return value == 0u ? 0 : 31 - __clz(value);
}

static __device__ __forceinline__ int csharp2cuda_u64_log2(unsigned long long value)
{
    return value == 0ull ? 0 : 63 - __clzll(value);
}

static __device__ __forceinline__ int csharp2cuda_i32_add(int left, int right)
{
    return csharp2cuda_i32_from_bits((unsigned int)left + (unsigned int)right);
}

static __device__ __forceinline__ int csharp2cuda_i32_sub(int left, int right)
{
    return csharp2cuda_i32_from_bits((unsigned int)left - (unsigned int)right);
}

static __device__ __forceinline__ int csharp2cuda_i32_mul(int left, int right)
{
    return csharp2cuda_i32_from_bits((unsigned int)left * (unsigned int)right);
}

static __device__ __forceinline__ int csharp2cuda_i32_div(int left, int right)
{
    if (right == 0 || (left == (-2147483647 - 1) && right == -1))
    {
        __trap();
        return 0;
    }
    return left / right;
}

static __device__ __forceinline__ int csharp2cuda_i32_rem(int left, int right)
{
    if (right == 0)
    {
        __trap();
        return 0;
    }
    if (left == (-2147483647 - 1) && right == -1)
        return 0;
    return left % right;
}

static __device__ __forceinline__ int csharp2cuda_i32_and(int left, int right)
{
    return csharp2cuda_i32_from_bits((unsigned int)left & (unsigned int)right);
}

static __device__ __forceinline__ int csharp2cuda_i32_or(int left, int right)
{
    return csharp2cuda_i32_from_bits((unsigned int)left | (unsigned int)right);
}

static __device__ __forceinline__ int csharp2cuda_i32_xor(int left, int right)
{
    return csharp2cuda_i32_from_bits((unsigned int)left ^ (unsigned int)right);
}

static __device__ __forceinline__ int csharp2cuda_i32_not(int value)
{
    return csharp2cuda_i32_from_bits(~(unsigned int)value);
}

static __device__ __forceinline__ int csharp2cuda_i32_neg(int value)
{
    return csharp2cuda_i32_from_bits(0u - (unsigned int)value);
}

static __device__ __forceinline__ int csharp2cuda_i32_shl(int value, int count)
{
    unsigned int shift = (unsigned int)count & 31u;
    return csharp2cuda_i32_from_bits((unsigned int)value << shift);
}

static __device__ __forceinline__ int csharp2cuda_i32_shr(int value, int count)
{
    unsigned int shift = (unsigned int)count & 31u;
    if (shift == 0u)
        return value;
    unsigned int bits = (unsigned int)value >> shift;
    if (value < 0)
        bits |= ~0u << (32u - shift);
    return csharp2cuda_i32_from_bits(bits);
}

static __device__ __forceinline__ int csharp2cuda_i32_ushr(int value, int count)
{
    unsigned int shift = (unsigned int)count & 31u;
    return csharp2cuda_i32_from_bits((unsigned int)value >> shift);
}

static __device__ __forceinline__ unsigned int csharp2cuda_u32_div(unsigned int left, unsigned int right)
{
    if (right == 0u)
    {
        __trap();
        return 0u;
    }
    return left / right;
}

static __device__ __forceinline__ unsigned int csharp2cuda_u32_rem(unsigned int left, unsigned int right)
{
    if (right == 0u)
    {
        __trap();
        return 0u;
    }
    return left % right;
}

static __device__ __forceinline__ unsigned int csharp2cuda_u32_shl(unsigned int value, int count)
{
    return value << ((unsigned int)count & 31u);
}

static __device__ __forceinline__ unsigned int csharp2cuda_u32_shr(unsigned int value, int count)
{
    return value >> ((unsigned int)count & 31u);
}

static __device__ __forceinline__ long long csharp2cuda_i64_add(long long left, long long right)
{
    return csharp2cuda_i64_from_bits((unsigned long long)left + (unsigned long long)right);
}

static __device__ __forceinline__ long long csharp2cuda_i64_sub(long long left, long long right)
{
    return csharp2cuda_i64_from_bits((unsigned long long)left - (unsigned long long)right);
}

static __device__ __forceinline__ long long csharp2cuda_i64_mul(long long left, long long right)
{
    return csharp2cuda_i64_from_bits((unsigned long long)left * (unsigned long long)right);
}

static __device__ __forceinline__ long long csharp2cuda_i64_div(long long left, long long right)
{
    if (right == 0LL ||
        (left == (-9223372036854775807LL - 1LL) && right == -1LL))
    {
        __trap();
        return 0LL;
    }
    return left / right;
}

static __device__ __forceinline__ long long csharp2cuda_i64_rem(long long left, long long right)
{
    if (right == 0LL)
    {
        __trap();
        return 0LL;
    }
    if (left == (-9223372036854775807LL - 1LL) && right == -1LL)
        return 0LL;
    return left % right;
}

static __device__ __forceinline__ long long csharp2cuda_i64_and(long long left, long long right)
{
    return csharp2cuda_i64_from_bits((unsigned long long)left & (unsigned long long)right);
}

static __device__ __forceinline__ long long csharp2cuda_i64_or(long long left, long long right)
{
    return csharp2cuda_i64_from_bits((unsigned long long)left | (unsigned long long)right);
}

static __device__ __forceinline__ long long csharp2cuda_i64_xor(long long left, long long right)
{
    return csharp2cuda_i64_from_bits((unsigned long long)left ^ (unsigned long long)right);
}

static __device__ __forceinline__ long long csharp2cuda_i64_not(long long value)
{
    return csharp2cuda_i64_from_bits(~(unsigned long long)value);
}

static __device__ __forceinline__ long long csharp2cuda_i64_neg(long long value)
{
    return csharp2cuda_i64_from_bits(0ull - (unsigned long long)value);
}

static __device__ __forceinline__ long long csharp2cuda_i64_shl(long long value, int count)
{
    unsigned int shift = (unsigned int)count & 63u;
    return csharp2cuda_i64_from_bits((unsigned long long)value << shift);
}

static __device__ __forceinline__ long long csharp2cuda_i64_shr(long long value, int count)
{
    unsigned int shift = (unsigned int)count & 63u;
    if (shift == 0u)
        return value;
    unsigned long long bits = (unsigned long long)value >> shift;
    if (value < 0LL)
        bits |= ~0ull << (64u - shift);
    return csharp2cuda_i64_from_bits(bits);
}

static __device__ __forceinline__ long long csharp2cuda_i64_ushr(
    long long value,
    int count)
{
    unsigned int shift = (unsigned int)count & 63u;
    return csharp2cuda_i64_from_bits((unsigned long long)value >> shift);
}

static __device__ __forceinline__ unsigned long long csharp2cuda_u64_div(unsigned long long left, unsigned long long right)
{
    if (right == 0ull)
    {
        __trap();
        return 0ull;
    }
    return left / right;
}

static __device__ __forceinline__ unsigned long long csharp2cuda_u64_rem(unsigned long long left, unsigned long long right)
{
    if (right == 0ull)
    {
        __trap();
        return 0ull;
    }
    return left % right;
}

static __device__ __forceinline__ unsigned long long csharp2cuda_u64_shl(unsigned long long value, int count)
{
    return value << ((unsigned int)count & 63u);
}

static __device__ __forceinline__ unsigned long long csharp2cuda_u64_shr(unsigned long long value, int count)
{
    return value >> ((unsigned int)count & 63u);
}

static __device__ __forceinline__ int csharp2cuda_i32_add_assign(int& target, int value) { return target = csharp2cuda_i32_add(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_sub_assign(int& target, int value) { return target = csharp2cuda_i32_sub(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_mul_assign(int& target, int value) { return target = csharp2cuda_i32_mul(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_div_assign(int& target, int value) { return target = csharp2cuda_i32_div(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_rem_assign(int& target, int value) { return target = csharp2cuda_i32_rem(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_and_assign(int& target, int value) { return target = csharp2cuda_i32_and(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_or_assign(int& target, int value) { return target = csharp2cuda_i32_or(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_xor_assign(int& target, int value) { return target = csharp2cuda_i32_xor(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_shl_assign(int& target, int value) { return target = csharp2cuda_i32_shl(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_shr_assign(int& target, int value) { return target = csharp2cuda_i32_shr(target, value); }

static __device__ __forceinline__ long long csharp2cuda_i64_add_assign(long long& target, long long value) { return target = csharp2cuda_i64_add(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_sub_assign(long long& target, long long value) { return target = csharp2cuda_i64_sub(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_mul_assign(long long& target, long long value) { return target = csharp2cuda_i64_mul(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_div_assign(long long& target, long long value) { return target = csharp2cuda_i64_div(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_rem_assign(long long& target, long long value) { return target = csharp2cuda_i64_rem(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_and_assign(long long& target, long long value) { return target = csharp2cuda_i64_and(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_or_assign(long long& target, long long value) { return target = csharp2cuda_i64_or(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_xor_assign(long long& target, long long value) { return target = csharp2cuda_i64_xor(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_shl_assign(long long& target, int value) { return target = csharp2cuda_i64_shl(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_shr_assign(long long& target, int value) { return target = csharp2cuda_i64_shr(target, value); }

static __device__ __forceinline__ unsigned int csharp2cuda_u32_div_assign(unsigned int& target, unsigned int value) { return target = csharp2cuda_u32_div(target, value); }
static __device__ __forceinline__ unsigned int csharp2cuda_u32_rem_assign(unsigned int& target, unsigned int value) { return target = csharp2cuda_u32_rem(target, value); }
static __device__ __forceinline__ unsigned int csharp2cuda_u32_shl_assign(unsigned int& target, int value) { return target = csharp2cuda_u32_shl(target, value); }
static __device__ __forceinline__ unsigned int csharp2cuda_u32_shr_assign(unsigned int& target, int value) { return target = csharp2cuda_u32_shr(target, value); }

static __device__ __forceinline__ unsigned long long csharp2cuda_u64_div_assign(unsigned long long& target, unsigned long long value) { return target = csharp2cuda_u64_div(target, value); }
static __device__ __forceinline__ unsigned long long csharp2cuda_u64_rem_assign(unsigned long long& target, unsigned long long value) { return target = csharp2cuda_u64_rem(target, value); }
static __device__ __forceinline__ unsigned long long csharp2cuda_u64_shl_assign(unsigned long long& target, int value) { return target = csharp2cuda_u64_shl(target, value); }
static __device__ __forceinline__ unsigned long long csharp2cuda_u64_shr_assign(unsigned long long& target, int value) { return target = csharp2cuda_u64_shr(target, value); }

static __device__ __forceinline__ int csharp2cuda_i32_pre_increment(int& target) { return target = csharp2cuda_i32_add(target, 1); }
static __device__ __forceinline__ int csharp2cuda_i32_post_increment(int& target) { int result = target; target = csharp2cuda_i32_add(target, 1); return result; }
static __device__ __forceinline__ int csharp2cuda_i32_pre_decrement(int& target) { return target = csharp2cuda_i32_sub(target, 1); }
static __device__ __forceinline__ int csharp2cuda_i32_post_decrement(int& target) { int result = target; target = csharp2cuda_i32_sub(target, 1); return result; }
static __device__ __forceinline__ long long csharp2cuda_i64_pre_increment(long long& target) { return target = csharp2cuda_i64_add(target, 1LL); }
static __device__ __forceinline__ long long csharp2cuda_i64_post_increment(long long& target) { long long result = target; target = csharp2cuda_i64_add(target, 1LL); return result; }
static __device__ __forceinline__ long long csharp2cuda_i64_pre_decrement(long long& target) { return target = csharp2cuda_i64_sub(target, 1LL); }
static __device__ __forceinline__ long long csharp2cuda_i64_post_decrement(long long& target) { long long result = target; target = csharp2cuda_i64_sub(target, 1LL); return result; }
static __device__ __forceinline__ signed char csharp2cuda_i8_pre_increment(signed char& target) { return target = csharp2cuda_i8_from_bits((unsigned int)(int)target + 1u); }
static __device__ __forceinline__ signed char csharp2cuda_i8_post_increment(signed char& target) { signed char result = target; target = csharp2cuda_i8_from_bits((unsigned int)(int)target + 1u); return result; }
static __device__ __forceinline__ signed char csharp2cuda_i8_pre_decrement(signed char& target) { return target = csharp2cuda_i8_from_bits((unsigned int)(int)target - 1u); }
static __device__ __forceinline__ signed char csharp2cuda_i8_post_decrement(signed char& target) { signed char result = target; target = csharp2cuda_i8_from_bits((unsigned int)(int)target - 1u); return result; }
static __device__ __forceinline__ short csharp2cuda_i16_pre_increment(short& target) { return target = csharp2cuda_i16_from_bits((unsigned int)(int)target + 1u); }
static __device__ __forceinline__ short csharp2cuda_i16_post_increment(short& target) { short result = target; target = csharp2cuda_i16_from_bits((unsigned int)(int)target + 1u); return result; }
static __device__ __forceinline__ short csharp2cuda_i16_pre_decrement(short& target) { return target = csharp2cuda_i16_from_bits((unsigned int)(int)target - 1u); }
static __device__ __forceinline__ short csharp2cuda_i16_post_decrement(short& target) { short result = target; target = csharp2cuda_i16_from_bits((unsigned int)(int)target - 1u); return result; }
#endif

#line 115 "AdvancedModule.cs"
__device__ void mathblocks_advanced_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 79 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_distribution(const double* values, int count);

#line 70 "AdvancedModule.cs"
__device__ double mathblocks_advanced_factorial(int value);

#line 46 "AdvancedModule.cs"
__device__ int mathblocks_advanced_log_two(int value);

#line 58 "AdvancedModule.cs"
__device__ int mathblocks_advanced_popcount(int value);

#line 40 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_power_of_two(int value);

#line 85 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_transition(
    const double* values,
    int rows,
    int columns);

#line 115 "AdvancedModule.cs"
__device__ void mathblocks_advanced_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 121 "AdvancedModule.cs"
{
#line 122 "AdvancedModule.cs"
    int thread = threadIdx.x;
#line 123 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 123 "AdvancedModule.cs"
    if (((input_count) > (0)))
    {
#line 123 "AdvancedModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 123 "AdvancedModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 123 "AdvancedModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 124 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 124 "AdvancedModule.cs"
    if (((input_count) > (1)))
    {
#line 124 "AdvancedModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 124 "AdvancedModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 124 "AdvancedModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 125 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 125 "AdvancedModule.cs"
    if (((input_count) > (2)))
    {
#line 125 "AdvancedModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 125 "AdvancedModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 125 "AdvancedModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 126 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_3;
#line 126 "AdvancedModule.cs"
    if (((input_count) > (3)))
    {
#line 126 "AdvancedModule.cs"
        csharp2cuda_temp_3 = (inputs)[3];
    }
    else
    {
#line 126 "AdvancedModule.cs"
        csharp2cuda_temp_3 = ((MathBlockSlot*)(nullptr));
    }
#line 126 "AdvancedModule.cs"
    const MathBlockSlot* fourth = csharp2cuda_temp_3;
#line 127 "AdvancedModule.cs"
    if (((thread) == (0)))
#line 128 "AdvancedModule.cs"
    {
#line 129 "AdvancedModule.cs"
#line 129 "AdvancedModule.cs"
        double* csharp2cuda_temp_4 = &((output)->scalar_value);
        (*(csharp2cuda_temp_4) = 0.0);
#line 130 "AdvancedModule.cs"
#line 130 "AdvancedModule.cs"
        int* csharp2cuda_temp_5 = &((output)->boolean_value);
        (*(csharp2cuda_temp_5) = 0);
#line 131 "AdvancedModule.cs"
#line 131 "AdvancedModule.cs"
        int* csharp2cuda_temp_6 = &((output)->rows);
        (*(csharp2cuda_temp_6) = 0);
#line 132 "AdvancedModule.cs"
#line 132 "AdvancedModule.cs"
        int* csharp2cuda_temp_7 = &((output)->columns);
        (*(csharp2cuda_temp_7) = 0);
#line 133 "AdvancedModule.cs"
#line 133 "AdvancedModule.cs"
        int* csharp2cuda_temp_8 = &((output)->count);
        (*(csharp2cuda_temp_8) = 0);
#line 134 "AdvancedModule.cs"
#line 134 "AdvancedModule.cs"
        int* csharp2cuda_temp_9 = &((output)->valid);
        (*(csharp2cuda_temp_9) = 1);
#line 135 "AdvancedModule.cs"
        {
#line 135 "AdvancedModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 136 "AdvancedModule.cs"
#line 136 "AdvancedModule.cs"
                MathBlockSlot* csharp2cuda_temp_11 = (inputs)[index];
#line 136 "AdvancedModule.cs"
                bool csharp2cuda_temp_12;
#line 136 "AdvancedModule.cs"
                if (!(((((void*)(csharp2cuda_temp_11))) == (((void*)(nullptr))))))
                {
#line 136 "AdvancedModule.cs"
                    MathBlockSlot* csharp2cuda_temp_13 = (inputs)[index];
#line 136 "AdvancedModule.cs"
                    bool csharp2cuda_temp_14 = (csharp2cuda_temp_13)->valid;
#line 136 "AdvancedModule.cs"
                    csharp2cuda_temp_12 = (!(csharp2cuda_temp_14));
                }
                else
                {
#line 136 "AdvancedModule.cs"
                    csharp2cuda_temp_12 = true;
                }
                if (csharp2cuda_temp_12)
                {
#line 136 "AdvancedModule.cs"
#line 136 "AdvancedModule.cs"
                    int* csharp2cuda_temp_15 = &((output)->valid);
                    (*(csharp2cuda_temp_15) = 0);
                }
#line 135 "AdvancedModule.cs"
                int* csharp2cuda_temp_10 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_10));
            }
        }
    }
#line 138 "AdvancedModule.cs"
    __syncthreads();
#line 139 "AdvancedModule.cs"
#line 139 "AdvancedModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 140 "AdvancedModule.cs"
        return;
    }
#line 142 "AdvancedModule.cs"
    double* csharp2cuda_temp_17;
#line 142 "AdvancedModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 142 "AdvancedModule.cs"
        csharp2cuda_temp_17 = ((double*)(nullptr));
    }
    else
    {
#line 142 "AdvancedModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 142 "AdvancedModule.cs"
        csharp2cuda_temp_17 = ((double*)(csharp2cuda_temp_18));
    }
#line 142 "AdvancedModule.cs"
    const double* a = csharp2cuda_temp_17;
#line 143 "AdvancedModule.cs"
    double* csharp2cuda_temp_19;
#line 143 "AdvancedModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 143 "AdvancedModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 143 "AdvancedModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 143 "AdvancedModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 143 "AdvancedModule.cs"
    const double* b = csharp2cuda_temp_19;
#line 144 "AdvancedModule.cs"
    double* csharp2cuda_temp_21;
#line 144 "AdvancedModule.cs"
    if (((((void*)(third))) == (((void*)(nullptr)))))
    {
#line 144 "AdvancedModule.cs"
        csharp2cuda_temp_21 = ((double*)(nullptr));
    }
    else
    {
#line 144 "AdvancedModule.cs"
        unsigned long long csharp2cuda_temp_22 = (third)->data_pointer;
#line 144 "AdvancedModule.cs"
        csharp2cuda_temp_21 = ((double*)(csharp2cuda_temp_22));
    }
#line 144 "AdvancedModule.cs"
    const double* c = csharp2cuda_temp_21;
#line 145 "AdvancedModule.cs"
    unsigned long long csharp2cuda_temp_23 = (output)->data_pointer;
#line 145 "AdvancedModule.cs"
    double* result = ((double*)(csharp2cuda_temp_23));
#line 146 "AdvancedModule.cs"
    unsigned long long csharp2cuda_temp_24 = (output)->scratch_pointer;
#line 146 "AdvancedModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_24));
#line 148 "AdvancedModule.cs"
    if (((thread) == (0)))
#line 149 "AdvancedModule.cs"
    {
#line 150 "AdvancedModule.cs"
        switch (opcode)
        {
#line 152 "AdvancedModule.cs"
            case 0:
#line 153 "AdvancedModule.cs"
#line 153 "AdvancedModule.cs"
                int csharp2cuda_temp_25 = (first)->count;
#line 153 "AdvancedModule.cs"
                bool csharp2cuda_temp_26;
#line 153 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_25) <= (0))))
                {
#line 153 "AdvancedModule.cs"
                    int csharp2cuda_temp_27 = (first)->count;
#line 153 "AdvancedModule.cs"
                    csharp2cuda_temp_26 = ((csharp2cuda_temp_27) >= (31));
                }
                else
                {
#line 153 "AdvancedModule.cs"
                    csharp2cuda_temp_26 = true;
                }
#line 153 "AdvancedModule.cs"
                bool csharp2cuda_temp_28;
#line 153 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_26))
                {
#line 154 "AdvancedModule.cs"
                    int csharp2cuda_temp_29 = (second)->count;
#line 154 "AdvancedModule.cs"
                    int csharp2cuda_temp_30 = (first)->count;
#line 153 "AdvancedModule.cs"
                    csharp2cuda_temp_28 = ((csharp2cuda_temp_29) != (csharp2cuda_i32_shl(1, csharp2cuda_temp_30)));
                }
                else
                {
#line 153 "AdvancedModule.cs"
                    csharp2cuda_temp_28 = true;
                }
#line 153 "AdvancedModule.cs"
                bool csharp2cuda_temp_31;
#line 153 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_28))
                {
#line 153 "AdvancedModule.cs"
                    csharp2cuda_temp_31 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 153 "AdvancedModule.cs"
                    csharp2cuda_temp_31 = true;
                }
                if (csharp2cuda_temp_31)
#line 155 "AdvancedModule.cs"
                {
#line 156 "AdvancedModule.cs"
#line 156 "AdvancedModule.cs"
                    int* csharp2cuda_temp_32 = &((output)->valid);
                    (*(csharp2cuda_temp_32) = 0);
#line 157 "AdvancedModule.cs"
                    break;
                }
#line 159 "AdvancedModule.cs"
                {
#line 159 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 159 "AdvancedModule.cs"
                        int csharp2cuda_temp_34 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_34))))
                            break;
#line 160 "AdvancedModule.cs"
                        {
#line 161 "AdvancedModule.cs"
#line 161 "AdvancedModule.cs"
                            double csharp2cuda_temp_35 = (a)[index];
                            if (((csharp2cuda_temp_35) < (0.0)))
#line 162 "AdvancedModule.cs"
                            {
#line 163 "AdvancedModule.cs"
#line 163 "AdvancedModule.cs"
                                int* csharp2cuda_temp_36 = &((output)->valid);
                                (*(csharp2cuda_temp_36) = 0);
#line 164 "AdvancedModule.cs"
                                break;
                            }
#line 166 "AdvancedModule.cs"
                            int position = index;
#line 167 "AdvancedModule.cs"
                            while (true)
                            {
#line 167 "AdvancedModule.cs"
                                bool csharp2cuda_temp_37;
#line 167 "AdvancedModule.cs"
                                if (((position) > (0)))
                                {
#line 167 "AdvancedModule.cs"
                                    double csharp2cuda_temp_38 = (scratch)[csharp2cuda_i32_sub(position, 1)];
#line 167 "AdvancedModule.cs"
                                    double csharp2cuda_temp_39 = (a)[csharp2cuda_f64_to_i32(csharp2cuda_temp_38)];
#line 167 "AdvancedModule.cs"
                                    double csharp2cuda_temp_40 = (a)[index];
#line 167 "AdvancedModule.cs"
                                    csharp2cuda_temp_37 = ((csharp2cuda_temp_39) > (csharp2cuda_temp_40));
                                }
                                else
                                {
#line 167 "AdvancedModule.cs"
                                    csharp2cuda_temp_37 = false;
                                }
                                if (!(csharp2cuda_temp_37))
                                    break;
#line 168 "AdvancedModule.cs"
                                {
#line 169 "AdvancedModule.cs"
#line 169 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_41 = &((scratch)[position]);
#line 169 "AdvancedModule.cs"
                                    double csharp2cuda_temp_42 = (scratch)[csharp2cuda_i32_sub(position, 1)];
                                    (*(csharp2cuda_temp_41) = csharp2cuda_temp_42);
#line 170 "AdvancedModule.cs"
#line 170 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_43 = &(position);
                                    csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_43));
                                }
                            }
#line 172 "AdvancedModule.cs"
#line 172 "AdvancedModule.cs"
                            double* csharp2cuda_temp_44 = &((scratch)[position]);
                            (*(csharp2cuda_temp_44) = ((double)(index)));
                        }
#line 159 "AdvancedModule.cs"
                        int* csharp2cuda_temp_33 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_33));
                    }
                }
#line 174 "AdvancedModule.cs"
                if ((output)->valid)
#line 175 "AdvancedModule.cs"
                {
#line 176 "AdvancedModule.cs"
                    double total = 0.0;
#line 177 "AdvancedModule.cs"
                    double previous = 0.0;
#line 178 "AdvancedModule.cs"
                    {
#line 178 "AdvancedModule.cs"
                        int position = 0;
                        while (true)
                        {
#line 178 "AdvancedModule.cs"
                            int csharp2cuda_temp_46 = (first)->count;
                            if (!(((position) < (csharp2cuda_temp_46))))
                                break;
#line 179 "AdvancedModule.cs"
                            {
#line 180 "AdvancedModule.cs"
                                int coalition = 0;
#line 181 "AdvancedModule.cs"
                                {
#line 181 "AdvancedModule.cs"
                                    int index = position;
                                    while (true)
                                    {
#line 181 "AdvancedModule.cs"
                                        int csharp2cuda_temp_48 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_48))))
                                            break;
#line 182 "AdvancedModule.cs"
#line 182 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_49 = &(coalition);
#line 182 "AdvancedModule.cs"
                                        int csharp2cuda_temp_50 = *(csharp2cuda_temp_49);
#line 182 "AdvancedModule.cs"
                                        double csharp2cuda_temp_51 = (scratch)[index];
                                        (*(csharp2cuda_temp_49) = csharp2cuda_i32_or(csharp2cuda_temp_50, csharp2cuda_i32_shl(1, csharp2cuda_f64_to_i32(csharp2cuda_temp_51))));
#line 181 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_47 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_47));
                                    }
                                }
#line 183 "AdvancedModule.cs"
                                double csharp2cuda_temp_52 = (scratch)[position];
#line 183 "AdvancedModule.cs"
                                int ordered = csharp2cuda_f64_to_i32(csharp2cuda_temp_52);
#line 184 "AdvancedModule.cs"
#line 184 "AdvancedModule.cs"
                                double* csharp2cuda_temp_53 = &(total);
#line 184 "AdvancedModule.cs"
                                double csharp2cuda_temp_54 = *(csharp2cuda_temp_53);
#line 184 "AdvancedModule.cs"
                                double csharp2cuda_temp_55 = (a)[ordered];
#line 184 "AdvancedModule.cs"
                                double csharp2cuda_temp_56 = (b)[coalition];
                                (*(csharp2cuda_temp_53) = __dadd_rn(csharp2cuda_temp_54, __dmul_rn(__dsub_rn(csharp2cuda_temp_55, previous), csharp2cuda_temp_56)));
#line 185 "AdvancedModule.cs"
#line 185 "AdvancedModule.cs"
                                double* csharp2cuda_temp_57 = &(previous);
#line 185 "AdvancedModule.cs"
                                double csharp2cuda_temp_58 = (a)[ordered];
                                (*(csharp2cuda_temp_57) = csharp2cuda_temp_58);
                            }
#line 178 "AdvancedModule.cs"
                            int* csharp2cuda_temp_45 = &(position);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_45));
                        }
                    }
#line 187 "AdvancedModule.cs"
#line 187 "AdvancedModule.cs"
                    double* csharp2cuda_temp_59 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_59) = total);
                }
#line 189 "AdvancedModule.cs"
                break;
#line 190 "AdvancedModule.cs"
            case 1:
#line 191 "AdvancedModule.cs"
#line 191 "AdvancedModule.cs"
                int csharp2cuda_temp_60 = (first)->count;
#line 191 "AdvancedModule.cs"
                bool csharp2cuda_temp_61;
#line 191 "AdvancedModule.cs"
                if (!((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_60)))))
                {
#line 191 "AdvancedModule.cs"
                    int csharp2cuda_temp_62 = (first)->count;
#line 191 "AdvancedModule.cs"
                    csharp2cuda_temp_61 = ((csharp2cuda_temp_62) > (csharp2cuda_i32_shl(1, 12)));
                }
                else
                {
#line 191 "AdvancedModule.cs"
                    csharp2cuda_temp_61 = true;
                }
                if (csharp2cuda_temp_61)
#line 192 "AdvancedModule.cs"
                {
#line 193 "AdvancedModule.cs"
#line 193 "AdvancedModule.cs"
                    int* csharp2cuda_temp_63 = &((output)->valid);
                    (*(csharp2cuda_temp_63) = 0);
#line 194 "AdvancedModule.cs"
                    break;
                }
#line 196 "AdvancedModule.cs"
#line 196 "AdvancedModule.cs"
                int* csharp2cuda_temp_64 = &((output)->boolean_value);
                (*(csharp2cuda_temp_64) = 1);
#line 197 "AdvancedModule.cs"
                {
#line 197 "AdvancedModule.cs"
                    int left = 0;
                    while (true)
                    {
#line 197 "AdvancedModule.cs"
                        int csharp2cuda_temp_66 = (first)->count;
#line 197 "AdvancedModule.cs"
                        bool csharp2cuda_temp_67;
#line 197 "AdvancedModule.cs"
                        if (((left) < (csharp2cuda_temp_66)))
                        {
#line 197 "AdvancedModule.cs"
                            csharp2cuda_temp_67 = (output)->boolean_value;
                        }
                        else
                        {
#line 197 "AdvancedModule.cs"
                            csharp2cuda_temp_67 = false;
                        }
                        if (!(csharp2cuda_temp_67))
                            break;
#line 198 "AdvancedModule.cs"
                        {
#line 198 "AdvancedModule.cs"
                            int right = 0;
                            while (true)
                            {
#line 198 "AdvancedModule.cs"
                                int csharp2cuda_temp_69 = (first)->count;
                                if (!(((right) < (csharp2cuda_temp_69))))
                                    break;
#line 199 "AdvancedModule.cs"
#line 199 "AdvancedModule.cs"
                                double csharp2cuda_temp_70 = (a)[left];
#line 199 "AdvancedModule.cs"
                                double csharp2cuda_temp_71 = (a)[right];
#line 199 "AdvancedModule.cs"
                                double csharp2cuda_temp_72 = (a)[csharp2cuda_i32_or(left, right)];
#line 199 "AdvancedModule.cs"
                                double csharp2cuda_temp_73 = (a)[csharp2cuda_i32_and(left, right)];
                                if (((__dadd_rn(csharp2cuda_temp_70, csharp2cuda_temp_71)) < (__dadd_rn(csharp2cuda_temp_72, csharp2cuda_temp_73))))
#line 200 "AdvancedModule.cs"
                                {
#line 201 "AdvancedModule.cs"
#line 201 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_74 = &((output)->boolean_value);
                                    (*(csharp2cuda_temp_74) = 0);
#line 202 "AdvancedModule.cs"
                                    break;
                                }
#line 198 "AdvancedModule.cs"
                                int* csharp2cuda_temp_68 = &(right);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_68));
                            }
                        }
#line 197 "AdvancedModule.cs"
                        int* csharp2cuda_temp_65 = &(left);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_65));
                    }
                }
#line 204 "AdvancedModule.cs"
                break;
#line 205 "AdvancedModule.cs"
            case 2:
#line 206 "AdvancedModule.cs"
#line 206 "AdvancedModule.cs"
                int csharp2cuda_temp_75 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_75);
#line 207 "AdvancedModule.cs"
#line 207 "AdvancedModule.cs"
                int csharp2cuda_temp_76 = (first)->count;
                if ((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_76))))
#line 208 "AdvancedModule.cs"
                {
#line 209 "AdvancedModule.cs"
#line 209 "AdvancedModule.cs"
                    int* csharp2cuda_temp_77 = &((output)->valid);
                    (*(csharp2cuda_temp_77) = 0);
#line 210 "AdvancedModule.cs"
                    break;
                }
#line 212 "AdvancedModule.cs"
                {
#line 212 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 212 "AdvancedModule.cs"
                        int csharp2cuda_temp_79 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_79))))
                            break;
#line 213 "AdvancedModule.cs"
#line 213 "AdvancedModule.cs"
                        double* csharp2cuda_temp_80 = &((result)[index]);
#line 213 "AdvancedModule.cs"
                        double csharp2cuda_temp_81 = (a)[index];
                        (*(csharp2cuda_temp_80) = csharp2cuda_temp_81);
#line 212 "AdvancedModule.cs"
                        int* csharp2cuda_temp_78 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_78));
                    }
                }
#line 214 "AdvancedModule.cs"
                {
#line 214 "AdvancedModule.cs"
                    int bit = 0;
                    while (true)
                    {
#line 214 "AdvancedModule.cs"
                        int csharp2cuda_temp_83 = (first)->count;
                        if (!(((bit) < (mathblocks_advanced_log_two(csharp2cuda_temp_83)))))
                            break;
#line 215 "AdvancedModule.cs"
                        {
#line 215 "AdvancedModule.cs"
                            int mask = 0;
                            while (true)
                            {
#line 215 "AdvancedModule.cs"
                                int csharp2cuda_temp_85 = (first)->count;
                                if (!(((mask) < (csharp2cuda_temp_85))))
                                    break;
#line 216 "AdvancedModule.cs"
                                if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, bit))) != (0)))
                                {
#line 217 "AdvancedModule.cs"
#line 217 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_86 = &((result)[mask]);
#line 217 "AdvancedModule.cs"
                                    double csharp2cuda_temp_87 = *(csharp2cuda_temp_86);
#line 217 "AdvancedModule.cs"
                                    double csharp2cuda_temp_88 = (result)[csharp2cuda_i32_xor(mask, csharp2cuda_i32_shl(1, bit))];
                                    (*(csharp2cuda_temp_86) = __dsub_rn(csharp2cuda_temp_87, csharp2cuda_temp_88));
                                }
#line 215 "AdvancedModule.cs"
                                int* csharp2cuda_temp_84 = &(mask);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_84));
                            }
                        }
#line 214 "AdvancedModule.cs"
                        int* csharp2cuda_temp_82 = &(bit);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_82));
                    }
                }
#line 218 "AdvancedModule.cs"
                break;
#line 219 "AdvancedModule.cs"
            case 3:
#line 220 "AdvancedModule.cs"
#line 220 "AdvancedModule.cs"
                int csharp2cuda_temp_89 = (first)->count;
#line 220 "AdvancedModule.cs"
                bool csharp2cuda_temp_90;
#line 220 "AdvancedModule.cs"
                if (!((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_89)))))
                {
#line 220 "AdvancedModule.cs"
                    int csharp2cuda_temp_91 = (first)->count;
#line 220 "AdvancedModule.cs"
                    csharp2cuda_temp_90 = ((csharp2cuda_temp_91) > (csharp2cuda_i32_shl(1, 20)));
                }
                else
                {
#line 220 "AdvancedModule.cs"
                    csharp2cuda_temp_90 = true;
                }
                if (csharp2cuda_temp_90)
#line 221 "AdvancedModule.cs"
                {
#line 222 "AdvancedModule.cs"
#line 222 "AdvancedModule.cs"
                    int* csharp2cuda_temp_92 = &((output)->valid);
                    (*(csharp2cuda_temp_92) = 0);
#line 223 "AdvancedModule.cs"
                    break;
                }
#line 225 "AdvancedModule.cs"
                {
#line 226 "AdvancedModule.cs"
                    int csharp2cuda_temp_93 = (first)->count;
#line 226 "AdvancedModule.cs"
                    int player_count = mathblocks_advanced_log_two(csharp2cuda_temp_93);
#line 227 "AdvancedModule.cs"
                    mathblocks_sequence_set_vector_shape(output, player_count);
#line 228 "AdvancedModule.cs"
                    double denominator = mathblocks_advanced_factorial(player_count);
#line 229 "AdvancedModule.cs"
                    {
#line 229 "AdvancedModule.cs"
                        int player = 0;
                        while (true)
                        {
                            if (!(((player) < (player_count))))
                                break;
#line 230 "AdvancedModule.cs"
                            {
#line 231 "AdvancedModule.cs"
#line 231 "AdvancedModule.cs"
                                double* csharp2cuda_temp_95 = &((result)[player]);
                                (*(csharp2cuda_temp_95) = 0.0);
#line 232 "AdvancedModule.cs"
                                {
#line 232 "AdvancedModule.cs"
                                    int coalition = 0;
                                    while (true)
                                    {
#line 232 "AdvancedModule.cs"
                                        int csharp2cuda_temp_97 = (first)->count;
                                        if (!(((coalition) < (csharp2cuda_temp_97))))
                                            break;
#line 233 "AdvancedModule.cs"
                                        {
#line 234 "AdvancedModule.cs"
                                            if (((csharp2cuda_i32_and(coalition, csharp2cuda_i32_shl(1, player))) != (0)))
                                            {
#line 235 "AdvancedModule.cs"
                                                goto csharp2cuda_for_continue_9;
                                            }
#line 236 "AdvancedModule.cs"
                                            int size = mathblocks_advanced_popcount(coalition);
#line 237 "AdvancedModule.cs"
                                            double weight = __ddiv_rn(__dmul_rn(mathblocks_advanced_factorial(size), mathblocks_advanced_factorial(csharp2cuda_i32_sub(csharp2cuda_i32_sub(player_count, size), 1))), denominator);
#line 240 "AdvancedModule.cs"
#line 240 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_98 = &((result)[player]);
#line 240 "AdvancedModule.cs"
                                            double csharp2cuda_temp_99 = *(csharp2cuda_temp_98);
#line 241 "AdvancedModule.cs"
                                            double csharp2cuda_temp_100 = (a)[csharp2cuda_i32_or(coalition, csharp2cuda_i32_shl(1, player))];
#line 241 "AdvancedModule.cs"
                                            double csharp2cuda_temp_101 = (a)[coalition];
                                            (*(csharp2cuda_temp_98) = __dadd_rn(csharp2cuda_temp_99, __dmul_rn(weight, __dsub_rn(csharp2cuda_temp_100, csharp2cuda_temp_101))));
                                        }
                                        csharp2cuda_for_continue_9:
#line 232 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_96 = &(coalition);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_96));
                                    }
                                }
                            }
#line 229 "AdvancedModule.cs"
                            int* csharp2cuda_temp_94 = &(player);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_94));
                        }
                    }
#line 244 "AdvancedModule.cs"
                    break;
                }
#line 246 "AdvancedModule.cs"
            case 4:
            case 5:
#line 248 "AdvancedModule.cs"
#line 248 "AdvancedModule.cs"
                int csharp2cuda_temp_102 = (third)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_102);
#line 249 "AdvancedModule.cs"
#line 249 "AdvancedModule.cs"
                int csharp2cuda_temp_103 = (first)->count;
#line 249 "AdvancedModule.cs"
                bool csharp2cuda_temp_104;
#line 249 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_103) <= (0))))
                {
#line 249 "AdvancedModule.cs"
                    int csharp2cuda_temp_105 = (first)->count;
#line 249 "AdvancedModule.cs"
                    int csharp2cuda_temp_106 = (second)->count;
#line 249 "AdvancedModule.cs"
                    csharp2cuda_temp_104 = ((csharp2cuda_temp_105) != (csharp2cuda_temp_106));
                }
                else
                {
#line 249 "AdvancedModule.cs"
                    csharp2cuda_temp_104 = true;
                }
#line 249 "AdvancedModule.cs"
                bool csharp2cuda_temp_107;
#line 249 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_104))
                {
#line 249 "AdvancedModule.cs"
                    double csharp2cuda_temp_108 = (fourth)->scalar_value;
#line 249 "AdvancedModule.cs"
                    csharp2cuda_temp_107 = ((csharp2cuda_temp_108) < (0.0));
                }
                else
                {
#line 249 "AdvancedModule.cs"
                    csharp2cuda_temp_107 = true;
                }
                if (csharp2cuda_temp_107)
#line 250 "AdvancedModule.cs"
                {
#line 251 "AdvancedModule.cs"
#line 251 "AdvancedModule.cs"
                    int* csharp2cuda_temp_109 = &((output)->valid);
                    (*(csharp2cuda_temp_109) = 0);
#line 252 "AdvancedModule.cs"
                    break;
                }
#line 254 "AdvancedModule.cs"
                {
#line 254 "AdvancedModule.cs"
                    int query = 0;
                    while (true)
                    {
#line 254 "AdvancedModule.cs"
                        int csharp2cuda_temp_111 = (third)->count;
                        if (!(((query) < (csharp2cuda_temp_111))))
                            break;
#line 255 "AdvancedModule.cs"
                        {
#line 256 "AdvancedModule.cs"
                            double csharp2cuda_temp_112;
#line 256 "AdvancedModule.cs"
                            if (((opcode) == (4)))
                            {
#line 256 "AdvancedModule.cs"
                                csharp2cuda_temp_112 = mathblocks_positive_infinity();
                            }
                            else
                            {
#line 256 "AdvancedModule.cs"
                                csharp2cuda_temp_112 = (-(mathblocks_positive_infinity()));
                            }
#line 256 "AdvancedModule.cs"
                            double selected = csharp2cuda_temp_112;
#line 259 "AdvancedModule.cs"
                            {
#line 259 "AdvancedModule.cs"
                                int index = 0;
                                while (true)
                                {
#line 259 "AdvancedModule.cs"
                                    int csharp2cuda_temp_114 = (first)->count;
                                    if (!(((index) < (csharp2cuda_temp_114))))
                                        break;
#line 260 "AdvancedModule.cs"
                                    {
#line 261 "AdvancedModule.cs"
                                        double csharp2cuda_temp_115;
#line 261 "AdvancedModule.cs"
                                        if (((opcode) == (4)))
                                        {
#line 262 "AdvancedModule.cs"
                                            double csharp2cuda_temp_116 = (b)[index];
#line 262 "AdvancedModule.cs"
                                            double csharp2cuda_temp_117 = (fourth)->scalar_value;
#line 262 "AdvancedModule.cs"
                                            double csharp2cuda_temp_118 = (c)[query];
#line 262 "AdvancedModule.cs"
                                            double csharp2cuda_temp_119 = (a)[index];
#line 261 "AdvancedModule.cs"
                                            csharp2cuda_temp_115 = __dadd_rn(csharp2cuda_temp_116, __dmul_rn(csharp2cuda_temp_117, fabs(__dsub_rn(csharp2cuda_temp_118, csharp2cuda_temp_119))));
                                        }
                                        else
                                        {
#line 263 "AdvancedModule.cs"
                                            double csharp2cuda_temp_120 = (b)[index];
#line 263 "AdvancedModule.cs"
                                            double csharp2cuda_temp_121 = (fourth)->scalar_value;
#line 263 "AdvancedModule.cs"
                                            double csharp2cuda_temp_122 = (c)[query];
#line 263 "AdvancedModule.cs"
                                            double csharp2cuda_temp_123 = (a)[index];
#line 261 "AdvancedModule.cs"
                                            csharp2cuda_temp_115 = __dsub_rn(csharp2cuda_temp_120, __dmul_rn(csharp2cuda_temp_121, fabs(__dsub_rn(csharp2cuda_temp_122, csharp2cuda_temp_123))));
                                        }
#line 261 "AdvancedModule.cs"
                                        double candidate = csharp2cuda_temp_115;
#line 264 "AdvancedModule.cs"
#line 264 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_124 = &(selected);
#line 264 "AdvancedModule.cs"
                                        double csharp2cuda_temp_125;
#line 264 "AdvancedModule.cs"
                                        if (((opcode) == (4)))
                                        {
#line 265 "AdvancedModule.cs"
                                            double csharp2cuda_temp_126;
#line 265 "AdvancedModule.cs"
                                            if (((selected) < (candidate)))
                                            {
#line 265 "AdvancedModule.cs"
                                                csharp2cuda_temp_126 = selected;
                                            }
                                            else
                                            {
#line 265 "AdvancedModule.cs"
                                                csharp2cuda_temp_126 = candidate;
                                            }
#line 264 "AdvancedModule.cs"
                                            csharp2cuda_temp_125 = csharp2cuda_temp_126;
                                        }
                                        else
                                        {
#line 266 "AdvancedModule.cs"
                                            double csharp2cuda_temp_127;
#line 266 "AdvancedModule.cs"
                                            if (((selected) > (candidate)))
                                            {
#line 266 "AdvancedModule.cs"
                                                csharp2cuda_temp_127 = selected;
                                            }
                                            else
                                            {
#line 266 "AdvancedModule.cs"
                                                csharp2cuda_temp_127 = candidate;
                                            }
#line 264 "AdvancedModule.cs"
                                            csharp2cuda_temp_125 = csharp2cuda_temp_127;
                                        }
                                        (*(csharp2cuda_temp_124) = csharp2cuda_temp_125);
                                    }
#line 259 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_113 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_113));
                                }
                            }
#line 268 "AdvancedModule.cs"
#line 268 "AdvancedModule.cs"
                            double* csharp2cuda_temp_128 = &((result)[query]);
                            (*(csharp2cuda_temp_128) = selected);
                        }
#line 254 "AdvancedModule.cs"
                        int* csharp2cuda_temp_110 = &(query);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_110));
                    }
                }
#line 270 "AdvancedModule.cs"
                break;
#line 271 "AdvancedModule.cs"
            case 6:
#line 272 "AdvancedModule.cs"
#line 272 "AdvancedModule.cs"
                int csharp2cuda_temp_129 = (first)->count;
                if (((csharp2cuda_temp_129) <= (0)))
#line 273 "AdvancedModule.cs"
                {
#line 274 "AdvancedModule.cs"
#line 274 "AdvancedModule.cs"
                    int* csharp2cuda_temp_130 = &((output)->valid);
                    (*(csharp2cuda_temp_130) = 0);
#line 275 "AdvancedModule.cs"
                    break;
                }
#line 277 "AdvancedModule.cs"
                {
#line 278 "AdvancedModule.cs"
                    double sum = 0.0;
#line 279 "AdvancedModule.cs"
                    {
#line 279 "AdvancedModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 279 "AdvancedModule.cs"
                            int csharp2cuda_temp_132 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_132))))
                                break;
#line 280 "AdvancedModule.cs"
                            {
#line 280 "AdvancedModule.cs"
                                int right = 0;
                                while (true)
                                {
#line 280 "AdvancedModule.cs"
                                    int csharp2cuda_temp_134 = (first)->count;
                                    if (!(((right) < (csharp2cuda_temp_134))))
                                        break;
#line 281 "AdvancedModule.cs"
#line 281 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_135 = &(sum);
#line 281 "AdvancedModule.cs"
                                    double csharp2cuda_temp_136 = *(csharp2cuda_temp_135);
#line 281 "AdvancedModule.cs"
                                    double csharp2cuda_temp_137 = (a)[left];
#line 281 "AdvancedModule.cs"
                                    double csharp2cuda_temp_138 = (a)[right];
                                    (*(csharp2cuda_temp_135) = __dadd_rn(csharp2cuda_temp_136, fabs(__dsub_rn(csharp2cuda_temp_137, csharp2cuda_temp_138))));
#line 280 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_133 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_133));
                                }
                            }
#line 279 "AdvancedModule.cs"
                            int* csharp2cuda_temp_131 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_131));
                        }
                    }
#line 282 "AdvancedModule.cs"
#line 282 "AdvancedModule.cs"
                    double* csharp2cuda_temp_139 = &((output)->scalar_value);
#line 283 "AdvancedModule.cs"
                    int csharp2cuda_temp_140 = (first)->count;
#line 283 "AdvancedModule.cs"
                    int csharp2cuda_temp_141 = (first)->count;
#line 282 "AdvancedModule.cs"
                    double csharp2cuda_temp_142 = __ddiv_rn(sum, __dmul_rn(__dmul_rn(2.0, ((double)(csharp2cuda_temp_140))), mathblocks_compensated_sum(a, csharp2cuda_temp_141)));
                    (*(csharp2cuda_temp_139) = csharp2cuda_temp_142);
#line 284 "AdvancedModule.cs"
                    break;
                }
#line 286 "AdvancedModule.cs"
            case 7:
#line 287 "AdvancedModule.cs"
#line 287 "AdvancedModule.cs"
                int csharp2cuda_temp_143 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_143, 1));
#line 288 "AdvancedModule.cs"
#line 288 "AdvancedModule.cs"
                int csharp2cuda_temp_144 = (first)->count;
#line 288 "AdvancedModule.cs"
                bool csharp2cuda_temp_145;
#line 288 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_144) <= (0))))
                {
#line 288 "AdvancedModule.cs"
                    csharp2cuda_temp_145 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 288 "AdvancedModule.cs"
                    csharp2cuda_temp_145 = true;
                }
                if (csharp2cuda_temp_145)
#line 289 "AdvancedModule.cs"
                {
#line 290 "AdvancedModule.cs"
#line 290 "AdvancedModule.cs"
                    int* csharp2cuda_temp_146 = &((output)->valid);
                    (*(csharp2cuda_temp_146) = 0);
#line 291 "AdvancedModule.cs"
                    break;
                }
#line 293 "AdvancedModule.cs"
#line 293 "AdvancedModule.cs"
                double* csharp2cuda_temp_147 = &((result)[0]);
                (*(csharp2cuda_temp_147) = 0.0);
#line 294 "AdvancedModule.cs"
                {
#line 294 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 294 "AdvancedModule.cs"
                        int csharp2cuda_temp_149 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_149))))
                            break;
#line 295 "AdvancedModule.cs"
#line 295 "AdvancedModule.cs"
                        double* csharp2cuda_temp_150 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 295 "AdvancedModule.cs"
                        double csharp2cuda_temp_151 = (a)[index];
                        (*(csharp2cuda_temp_150) = csharp2cuda_temp_151);
#line 294 "AdvancedModule.cs"
                        int* csharp2cuda_temp_148 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_148));
                    }
                }
#line 296 "AdvancedModule.cs"
                {
#line 297 "AdvancedModule.cs"
                    int csharp2cuda_temp_152 = (first)->count;
#line 297 "AdvancedModule.cs"
                    double* sorted = mathblocks_stable_merge_sort(csharp2cuda_pointer_add(result, 1), scratch, csharp2cuda_temp_152, false);
#line 298 "AdvancedModule.cs"
                    if (((((void*)(sorted))) != (((void*)(csharp2cuda_pointer_add(result, 1))))))
                    {
#line 299 "AdvancedModule.cs"
                        {
#line 299 "AdvancedModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 299 "AdvancedModule.cs"
                                int csharp2cuda_temp_154 = (first)->count;
                                if (!(((index) < (csharp2cuda_temp_154))))
                                    break;
#line 300 "AdvancedModule.cs"
#line 300 "AdvancedModule.cs"
                                double* csharp2cuda_temp_155 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 300 "AdvancedModule.cs"
                                double csharp2cuda_temp_156 = (sorted)[index];
                                (*(csharp2cuda_temp_155) = csharp2cuda_temp_156);
#line 299 "AdvancedModule.cs"
                                int* csharp2cuda_temp_153 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_153));
                            }
                        }
                    }
                }
#line 302 "AdvancedModule.cs"
                {
#line 303 "AdvancedModule.cs"
                    int csharp2cuda_temp_157 = (first)->count;
#line 303 "AdvancedModule.cs"
                    double total = mathblocks_compensated_sum(csharp2cuda_pointer_add(result, 1), csharp2cuda_temp_157);
#line 304 "AdvancedModule.cs"
                    {
#line 304 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 304 "AdvancedModule.cs"
                            int csharp2cuda_temp_159 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_159))))
                                break;
#line 305 "AdvancedModule.cs"
#line 305 "AdvancedModule.cs"
                            double* csharp2cuda_temp_160 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 305 "AdvancedModule.cs"
                            double csharp2cuda_temp_161 = (result)[index];
#line 305 "AdvancedModule.cs"
                            double csharp2cuda_temp_162 = (result)[csharp2cuda_i32_add(index, 1)];
#line 305 "AdvancedModule.cs"
                            double csharp2cuda_temp_163 = __ddiv_rn(csharp2cuda_temp_162, total);
                            (*(csharp2cuda_temp_160) = __dadd_rn(csharp2cuda_temp_161, csharp2cuda_temp_163));
#line 304 "AdvancedModule.cs"
                            int* csharp2cuda_temp_158 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_158));
                        }
                    }
#line 306 "AdvancedModule.cs"
                    break;
                }
#line 308 "AdvancedModule.cs"
            case 8:
#line 309 "AdvancedModule.cs"
#line 309 "AdvancedModule.cs"
                int csharp2cuda_temp_164 = (first)->rows;
#line 309 "AdvancedModule.cs"
                int csharp2cuda_temp_165 = (first)->columns;
#line 309 "AdvancedModule.cs"
                bool csharp2cuda_temp_166;
#line 309 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_164) != (csharp2cuda_temp_165))))
                {
#line 309 "AdvancedModule.cs"
                    int csharp2cuda_temp_167 = (first)->rows;
#line 309 "AdvancedModule.cs"
                    int csharp2cuda_temp_168 = (second)->count;
#line 309 "AdvancedModule.cs"
                    csharp2cuda_temp_166 = ((csharp2cuda_temp_167) != (csharp2cuda_temp_168));
                }
                else
                {
#line 309 "AdvancedModule.cs"
                    csharp2cuda_temp_166 = true;
                }
#line 309 "AdvancedModule.cs"
                bool csharp2cuda_temp_169;
#line 309 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_166))
                {
#line 310 "AdvancedModule.cs"
                    int csharp2cuda_temp_170 = (first)->rows;
#line 310 "AdvancedModule.cs"
                    int csharp2cuda_temp_171 = (first)->columns;
#line 310 "AdvancedModule.cs"
                    bool csharp2cuda_temp_172 = mathblocks_advanced_transition(a, csharp2cuda_temp_170, csharp2cuda_temp_171);
#line 309 "AdvancedModule.cs"
                    csharp2cuda_temp_169 = (!(csharp2cuda_temp_172));
                }
                else
                {
#line 309 "AdvancedModule.cs"
                    csharp2cuda_temp_169 = true;
                }
#line 309 "AdvancedModule.cs"
                bool csharp2cuda_temp_173;
#line 309 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_169))
                {
#line 311 "AdvancedModule.cs"
                    int csharp2cuda_temp_174 = (second)->count;
#line 311 "AdvancedModule.cs"
                    bool csharp2cuda_temp_175 = mathblocks_advanced_distribution(b, csharp2cuda_temp_174);
#line 309 "AdvancedModule.cs"
                    csharp2cuda_temp_173 = (!(csharp2cuda_temp_175));
                }
                else
                {
#line 309 "AdvancedModule.cs"
                    csharp2cuda_temp_173 = true;
                }
                if (csharp2cuda_temp_173)
#line 312 "AdvancedModule.cs"
                {
#line 313 "AdvancedModule.cs"
#line 313 "AdvancedModule.cs"
                    int* csharp2cuda_temp_176 = &((output)->valid);
                    (*(csharp2cuda_temp_176) = 0);
#line 314 "AdvancedModule.cs"
                    break;
                }
#line 316 "AdvancedModule.cs"
                {
#line 317 "AdvancedModule.cs"
                    double total = 0.0;
#line 318 "AdvancedModule.cs"
                    {
#line 318 "AdvancedModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 318 "AdvancedModule.cs"
                            int csharp2cuda_temp_178 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_178))))
                                break;
#line 319 "AdvancedModule.cs"
                            {
#line 319 "AdvancedModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 319 "AdvancedModule.cs"
                                    int csharp2cuda_temp_180 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_180))))
                                        break;
#line 320 "AdvancedModule.cs"
                                    {
#line 321 "AdvancedModule.cs"
                                        double csharp2cuda_temp_181 = (b)[row];
#line 321 "AdvancedModule.cs"
                                        int csharp2cuda_temp_182 = (first)->columns;
#line 321 "AdvancedModule.cs"
                                        double csharp2cuda_temp_183 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_182), column)];
#line 321 "AdvancedModule.cs"
                                        double forward = __dmul_rn(csharp2cuda_temp_181, csharp2cuda_temp_183);
#line 322 "AdvancedModule.cs"
                                        double csharp2cuda_temp_184 = (b)[column];
#line 322 "AdvancedModule.cs"
                                        int csharp2cuda_temp_185 = (first)->columns;
#line 322 "AdvancedModule.cs"
                                        double csharp2cuda_temp_186 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(column, csharp2cuda_temp_185), row)];
#line 322 "AdvancedModule.cs"
                                        double reverse = __dmul_rn(csharp2cuda_temp_184, csharp2cuda_temp_186);
#line 323 "AdvancedModule.cs"
#line 323 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_187;
#line 323 "AdvancedModule.cs"
                                        if (((forward) > (0.0)))
                                        {
#line 323 "AdvancedModule.cs"
                                            csharp2cuda_temp_187 = ((reverse) == (0.0));
                                        }
                                        else
                                        {
#line 323 "AdvancedModule.cs"
                                            csharp2cuda_temp_187 = false;
                                        }
                                        if (csharp2cuda_temp_187)
#line 324 "AdvancedModule.cs"
                                        {
#line 325 "AdvancedModule.cs"
#line 325 "AdvancedModule.cs"
                                            int* csharp2cuda_temp_188 = &((output)->valid);
                                            (*(csharp2cuda_temp_188) = 0);
#line 326 "AdvancedModule.cs"
                                            break;
                                        }
#line 328 "AdvancedModule.cs"
#line 328 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_189;
#line 328 "AdvancedModule.cs"
                                        if (((forward) > (0.0)))
                                        {
#line 328 "AdvancedModule.cs"
                                            csharp2cuda_temp_189 = ((reverse) > (0.0));
                                        }
                                        else
                                        {
#line 328 "AdvancedModule.cs"
                                            csharp2cuda_temp_189 = false;
                                        }
                                        if (csharp2cuda_temp_189)
                                        {
#line 329 "AdvancedModule.cs"
#line 329 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_190 = &(total);
#line 329 "AdvancedModule.cs"
                                            double csharp2cuda_temp_191 = *(csharp2cuda_temp_190);
#line 329 "AdvancedModule.cs"
                                            double csharp2cuda_temp_192 = __ddiv_rn(forward, reverse);
                                            (*(csharp2cuda_temp_190) = __dadd_rn(csharp2cuda_temp_191, __dmul_rn(forward, mathblocks_natural_logarithm(csharp2cuda_temp_192))));
                                        }
                                    }
#line 319 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_179 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_179));
                                }
                            }
#line 318 "AdvancedModule.cs"
                            int* csharp2cuda_temp_177 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_177));
                        }
                    }
#line 331 "AdvancedModule.cs"
#line 331 "AdvancedModule.cs"
                    double* csharp2cuda_temp_193 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_193) = total);
#line 332 "AdvancedModule.cs"
                    break;
                }
#line 334 "AdvancedModule.cs"
            case 9:
#line 335 "AdvancedModule.cs"
#line 335 "AdvancedModule.cs"
                int csharp2cuda_temp_194 = (first)->rows;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_194);
#line 336 "AdvancedModule.cs"
#line 336 "AdvancedModule.cs"
                int csharp2cuda_temp_195 = (first)->rows;
#line 336 "AdvancedModule.cs"
                int csharp2cuda_temp_196 = (first)->columns;
#line 336 "AdvancedModule.cs"
                bool csharp2cuda_temp_197 = mathblocks_advanced_transition(a, csharp2cuda_temp_195, csharp2cuda_temp_196);
#line 336 "AdvancedModule.cs"
                bool csharp2cuda_temp_198;
#line 336 "AdvancedModule.cs"
                if (!((!(csharp2cuda_temp_197))))
                {
#line 336 "AdvancedModule.cs"
                    csharp2cuda_temp_198 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 336 "AdvancedModule.cs"
                    csharp2cuda_temp_198 = true;
                }
                if (csharp2cuda_temp_198)
#line 337 "AdvancedModule.cs"
                {
#line 338 "AdvancedModule.cs"
#line 338 "AdvancedModule.cs"
                    int* csharp2cuda_temp_199 = &((output)->valid);
                    (*(csharp2cuda_temp_199) = 0);
#line 339 "AdvancedModule.cs"
                    break;
                }
#line 341 "AdvancedModule.cs"
                {
#line 342 "AdvancedModule.cs"
                    int iterations = 0;
#line 343 "AdvancedModule.cs"
#line 343 "AdvancedModule.cs"
                    double csharp2cuda_temp_200 = (second)->scalar_value;
#line 343 "AdvancedModule.cs"
                    int* csharp2cuda_temp_201 = &(iterations);
#line 343 "AdvancedModule.cs"
                    bool csharp2cuda_temp_202 = mathblocks_sequence_positive_integer(csharp2cuda_temp_200, csharp2cuda_temp_201);
#line 343 "AdvancedModule.cs"
                    bool csharp2cuda_temp_203;
#line 343 "AdvancedModule.cs"
                    if (!((!(csharp2cuda_temp_202))))
                    {
#line 343 "AdvancedModule.cs"
                        csharp2cuda_temp_203 = ((iterations) > (10000));
                    }
                    else
                    {
#line 343 "AdvancedModule.cs"
                        csharp2cuda_temp_203 = true;
                    }
                    if (csharp2cuda_temp_203)
#line 344 "AdvancedModule.cs"
                    {
#line 345 "AdvancedModule.cs"
#line 345 "AdvancedModule.cs"
                        int* csharp2cuda_temp_204 = &((output)->valid);
                        (*(csharp2cuda_temp_204) = 0);
#line 346 "AdvancedModule.cs"
                        break;
                    }
#line 348 "AdvancedModule.cs"
                    {
#line 348 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 348 "AdvancedModule.cs"
                            int csharp2cuda_temp_206 = (first)->rows;
                            if (!(((index) < (csharp2cuda_temp_206))))
                                break;
#line 349 "AdvancedModule.cs"
#line 349 "AdvancedModule.cs"
                            double* csharp2cuda_temp_207 = &((result)[index]);
#line 349 "AdvancedModule.cs"
                            int csharp2cuda_temp_208 = (first)->rows;
#line 349 "AdvancedModule.cs"
                            double csharp2cuda_temp_209 = __ddiv_rn(1.0, ((double)(csharp2cuda_temp_208)));
                            (*(csharp2cuda_temp_207) = csharp2cuda_temp_209);
#line 348 "AdvancedModule.cs"
                            int* csharp2cuda_temp_205 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_205));
                        }
                    }
#line 350 "AdvancedModule.cs"
                    {
#line 350 "AdvancedModule.cs"
                        int iteration = 0;
                        while (true)
                        {
                            if (!(((iteration) < (iterations))))
                                break;
#line 351 "AdvancedModule.cs"
                            {
#line 352 "AdvancedModule.cs"
                                {
#line 352 "AdvancedModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 352 "AdvancedModule.cs"
                                        int csharp2cuda_temp_212 = (first)->rows;
                                        if (!(((index) < (csharp2cuda_temp_212))))
                                            break;
#line 353 "AdvancedModule.cs"
#line 353 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_213 = &((scratch)[index]);
                                        (*(csharp2cuda_temp_213) = 0.0);
#line 352 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_211 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_211));
                                    }
                                }
#line 354 "AdvancedModule.cs"
                                {
#line 354 "AdvancedModule.cs"
                                    int row = 0;
                                    while (true)
                                    {
#line 354 "AdvancedModule.cs"
                                        int csharp2cuda_temp_215 = (first)->rows;
                                        if (!(((row) < (csharp2cuda_temp_215))))
                                            break;
#line 355 "AdvancedModule.cs"
                                        {
#line 355 "AdvancedModule.cs"
                                            int column = 0;
                                            while (true)
                                            {
#line 355 "AdvancedModule.cs"
                                                int csharp2cuda_temp_217 = (first)->columns;
                                                if (!(((column) < (csharp2cuda_temp_217))))
                                                    break;
#line 356 "AdvancedModule.cs"
#line 356 "AdvancedModule.cs"
                                                double* csharp2cuda_temp_218 = &((scratch)[column]);
#line 356 "AdvancedModule.cs"
                                                double csharp2cuda_temp_219 = *(csharp2cuda_temp_218);
#line 356 "AdvancedModule.cs"
                                                double csharp2cuda_temp_220 = (result)[row];
#line 356 "AdvancedModule.cs"
                                                int csharp2cuda_temp_221 = (first)->columns;
#line 356 "AdvancedModule.cs"
                                                double csharp2cuda_temp_222 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_221), column)];
                                                (*(csharp2cuda_temp_218) = __dadd_rn(csharp2cuda_temp_219, __dmul_rn(csharp2cuda_temp_220, csharp2cuda_temp_222)));
#line 355 "AdvancedModule.cs"
                                                int* csharp2cuda_temp_216 = &(column);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_216));
                                            }
                                        }
#line 354 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_214 = &(row);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_214));
                                    }
                                }
#line 357 "AdvancedModule.cs"
                                {
#line 357 "AdvancedModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 357 "AdvancedModule.cs"
                                        int csharp2cuda_temp_224 = (first)->rows;
                                        if (!(((index) < (csharp2cuda_temp_224))))
                                            break;
#line 358 "AdvancedModule.cs"
#line 358 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_225 = &((result)[index]);
#line 358 "AdvancedModule.cs"
                                        double csharp2cuda_temp_226 = (scratch)[index];
                                        (*(csharp2cuda_temp_225) = csharp2cuda_temp_226);
#line 357 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_223 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_223));
                                    }
                                }
                            }
#line 350 "AdvancedModule.cs"
                            int* csharp2cuda_temp_210 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_210));
                        }
                    }
#line 360 "AdvancedModule.cs"
                    break;
                }
#line 362 "AdvancedModule.cs"
            case 10:
#line 363 "AdvancedModule.cs"
#line 363 "AdvancedModule.cs"
                int csharp2cuda_temp_227 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_227);
#line 364 "AdvancedModule.cs"
#line 364 "AdvancedModule.cs"
                int csharp2cuda_temp_228 = (first)->count;
#line 364 "AdvancedModule.cs"
                bool csharp2cuda_temp_229;
#line 364 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_228) <= (0))))
                {
#line 364 "AdvancedModule.cs"
                    csharp2cuda_temp_229 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 364 "AdvancedModule.cs"
                    csharp2cuda_temp_229 = true;
                }
                if (csharp2cuda_temp_229)
#line 365 "AdvancedModule.cs"
                {
#line 366 "AdvancedModule.cs"
#line 366 "AdvancedModule.cs"
                    int* csharp2cuda_temp_230 = &((output)->valid);
                    (*(csharp2cuda_temp_230) = 0);
#line 367 "AdvancedModule.cs"
                    break;
                }
#line 369 "AdvancedModule.cs"
                {
#line 370 "AdvancedModule.cs"
                    double* means = scratch;
#line 371 "AdvancedModule.cs"
                    int csharp2cuda_temp_231 = (first)->count;
#line 371 "AdvancedModule.cs"
                    int* weights = ((int*)(csharp2cuda_pointer_add(means, csharp2cuda_temp_231)));
#line 372 "AdvancedModule.cs"
                    int csharp2cuda_temp_232 = (first)->count;
#line 372 "AdvancedModule.cs"
                    int* starts = csharp2cuda_pointer_add(weights, csharp2cuda_temp_232);
#line 373 "AdvancedModule.cs"
                    int block_count = 0;
#line 374 "AdvancedModule.cs"
                    {
#line 374 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 374 "AdvancedModule.cs"
                            int csharp2cuda_temp_234 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_234))))
                                break;
#line 375 "AdvancedModule.cs"
                            {
#line 376 "AdvancedModule.cs"
#line 376 "AdvancedModule.cs"
                                double* csharp2cuda_temp_235 = &((means)[block_count]);
#line 376 "AdvancedModule.cs"
                                double csharp2cuda_temp_236 = (a)[index];
                                (*(csharp2cuda_temp_235) = csharp2cuda_temp_236);
#line 377 "AdvancedModule.cs"
#line 377 "AdvancedModule.cs"
                                int* csharp2cuda_temp_237 = &((weights)[block_count]);
                                (*(csharp2cuda_temp_237) = 1);
#line 378 "AdvancedModule.cs"
#line 378 "AdvancedModule.cs"
                                int* csharp2cuda_temp_238 = &((starts)[block_count]);
                                (*(csharp2cuda_temp_238) = index);
#line 379 "AdvancedModule.cs"
#line 379 "AdvancedModule.cs"
                                int* csharp2cuda_temp_239 = &(block_count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_239));
#line 380 "AdvancedModule.cs"
                                while (true)
                                {
#line 380 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_240;
#line 380 "AdvancedModule.cs"
                                    if (((block_count) >= (2)))
                                    {
#line 380 "AdvancedModule.cs"
                                        double csharp2cuda_temp_241 = (means)[csharp2cuda_i32_sub(block_count, 2)];
#line 380 "AdvancedModule.cs"
                                        double csharp2cuda_temp_242 = (means)[csharp2cuda_i32_sub(block_count, 1)];
#line 380 "AdvancedModule.cs"
                                        csharp2cuda_temp_240 = ((csharp2cuda_temp_241) > (csharp2cuda_temp_242));
                                    }
                                    else
                                    {
#line 380 "AdvancedModule.cs"
                                        csharp2cuda_temp_240 = false;
                                    }
                                    if (!(csharp2cuda_temp_240))
                                        break;
#line 381 "AdvancedModule.cs"
                                    {
#line 382 "AdvancedModule.cs"
                                        int csharp2cuda_temp_243 = (weights)[csharp2cuda_i32_sub(block_count, 2)];
#line 382 "AdvancedModule.cs"
                                        int csharp2cuda_temp_244 = (weights)[csharp2cuda_i32_sub(block_count, 1)];
#line 382 "AdvancedModule.cs"
                                        int combined_weight = csharp2cuda_i32_add(csharp2cuda_temp_243, csharp2cuda_temp_244);
#line 383 "AdvancedModule.cs"
#line 383 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_245 = &((means)[csharp2cuda_i32_sub(block_count, 2)]);
#line 384 "AdvancedModule.cs"
                                        double csharp2cuda_temp_246 = (means)[csharp2cuda_i32_sub(block_count, 2)];
#line 384 "AdvancedModule.cs"
                                        int csharp2cuda_temp_247 = (weights)[csharp2cuda_i32_sub(block_count, 2)];
#line 385 "AdvancedModule.cs"
                                        double csharp2cuda_temp_248 = (means)[csharp2cuda_i32_sub(block_count, 1)];
#line 385 "AdvancedModule.cs"
                                        int csharp2cuda_temp_249 = (weights)[csharp2cuda_i32_sub(block_count, 1)];
#line 384 "AdvancedModule.cs"
                                        double csharp2cuda_temp_250 = __ddiv_rn(__dadd_rn(__dmul_rn(csharp2cuda_temp_246, ((double)(csharp2cuda_temp_247))), __dmul_rn(csharp2cuda_temp_248, ((double)(csharp2cuda_temp_249)))), ((double)(combined_weight)));
                                        (*(csharp2cuda_temp_245) = csharp2cuda_temp_250);
#line 387 "AdvancedModule.cs"
#line 387 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_251 = &((weights)[csharp2cuda_i32_sub(block_count, 2)]);
                                        (*(csharp2cuda_temp_251) = combined_weight);
#line 388 "AdvancedModule.cs"
#line 388 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_252 = &(block_count);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_252));
                                    }
                                }
                            }
#line 374 "AdvancedModule.cs"
                            int* csharp2cuda_temp_233 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_233));
                        }
                    }
#line 391 "AdvancedModule.cs"
                    {
#line 391 "AdvancedModule.cs"
                        int block = 0;
                        while (true)
                        {
                            if (!(((block) < (block_count))))
                                break;
#line 392 "AdvancedModule.cs"
                            {
#line 393 "AdvancedModule.cs"
                                int csharp2cuda_temp_254;
#line 393 "AdvancedModule.cs"
                                if (((csharp2cuda_i32_add(block, 1)) < (block_count)))
                                {
#line 393 "AdvancedModule.cs"
                                    csharp2cuda_temp_254 = (starts)[csharp2cuda_i32_add(block, 1)];
                                }
                                else
                                {
#line 393 "AdvancedModule.cs"
                                    csharp2cuda_temp_254 = (first)->count;
                                }
#line 393 "AdvancedModule.cs"
                                int end = csharp2cuda_temp_254;
#line 394 "AdvancedModule.cs"
                                {
#line 394 "AdvancedModule.cs"
                                    int index = (starts)[block];
                                    while (true)
                                    {
                                        if (!(((index) < (end))))
                                            break;
#line 395 "AdvancedModule.cs"
#line 395 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_256 = &((result)[index]);
#line 395 "AdvancedModule.cs"
                                        double csharp2cuda_temp_257 = (means)[block];
                                        (*(csharp2cuda_temp_256) = csharp2cuda_temp_257);
#line 394 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_255 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_255));
                                    }
                                }
                            }
#line 391 "AdvancedModule.cs"
                            int* csharp2cuda_temp_253 = &(block);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_253));
                        }
                    }
#line 397 "AdvancedModule.cs"
                    break;
                }
#line 399 "AdvancedModule.cs"
            case 11:
#line 400 "AdvancedModule.cs"
#line 400 "AdvancedModule.cs"
                int csharp2cuda_temp_258 = (first)->count;
#line 400 "AdvancedModule.cs"
                int csharp2cuda_temp_259 = (second)->count;
#line 400 "AdvancedModule.cs"
                bool csharp2cuda_temp_260;
#line 400 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_258) != (csharp2cuda_temp_259))))
                {
#line 400 "AdvancedModule.cs"
                    csharp2cuda_temp_260 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 400 "AdvancedModule.cs"
                    csharp2cuda_temp_260 = true;
                }
                if (csharp2cuda_temp_260)
#line 401 "AdvancedModule.cs"
                {
#line 402 "AdvancedModule.cs"
#line 402 "AdvancedModule.cs"
                    int* csharp2cuda_temp_261 = &((output)->valid);
                    (*(csharp2cuda_temp_261) = 0);
#line 403 "AdvancedModule.cs"
                    break;
                }
#line 405 "AdvancedModule.cs"
                {
#line 406 "AdvancedModule.cs"
                    double* left_sorted = scratch;
#line 407 "AdvancedModule.cs"
                    int csharp2cuda_temp_262 = (first)->count;
#line 407 "AdvancedModule.cs"
                    double* right_sorted = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_262);
#line 408 "AdvancedModule.cs"
#line 408 "AdvancedModule.cs"
                    int csharp2cuda_temp_263 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_263, left_sorted, true);
#line 409 "AdvancedModule.cs"
#line 409 "AdvancedModule.cs"
                    int csharp2cuda_temp_264 = (first)->count;
                    mathblocks_statistics_sort_copy(b, csharp2cuda_temp_264, right_sorted, true);
#line 410 "AdvancedModule.cs"
                    double left_sum = 0.0;
#line 411 "AdvancedModule.cs"
                    double right_sum = 0.0;
#line 412 "AdvancedModule.cs"
                    bool majorizes = true;
#line 413 "AdvancedModule.cs"
                    {
#line 413 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 413 "AdvancedModule.cs"
                            int csharp2cuda_temp_266 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_266))))
                                break;
#line 414 "AdvancedModule.cs"
                            {
#line 415 "AdvancedModule.cs"
#line 415 "AdvancedModule.cs"
                                double* csharp2cuda_temp_267 = &(left_sum);
#line 415 "AdvancedModule.cs"
                                double csharp2cuda_temp_268 = *(csharp2cuda_temp_267);
#line 415 "AdvancedModule.cs"
                                double csharp2cuda_temp_269 = (left_sorted)[index];
                                (*(csharp2cuda_temp_267) = __dadd_rn(csharp2cuda_temp_268, csharp2cuda_temp_269));
#line 416 "AdvancedModule.cs"
#line 416 "AdvancedModule.cs"
                                double* csharp2cuda_temp_270 = &(right_sum);
#line 416 "AdvancedModule.cs"
                                double csharp2cuda_temp_271 = *(csharp2cuda_temp_270);
#line 416 "AdvancedModule.cs"
                                double csharp2cuda_temp_272 = (right_sorted)[index];
                                (*(csharp2cuda_temp_270) = __dadd_rn(csharp2cuda_temp_271, csharp2cuda_temp_272));
#line 417 "AdvancedModule.cs"
#line 417 "AdvancedModule.cs"
                                int csharp2cuda_temp_273 = (first)->count;
#line 417 "AdvancedModule.cs"
                                bool csharp2cuda_temp_274;
#line 417 "AdvancedModule.cs"
                                if (((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_273, 1))))
                                {
#line 417 "AdvancedModule.cs"
                                    csharp2cuda_temp_274 = ((left_sum) < (right_sum));
                                }
                                else
                                {
#line 417 "AdvancedModule.cs"
                                    csharp2cuda_temp_274 = false;
                                }
                                if (csharp2cuda_temp_274)
                                {
#line 418 "AdvancedModule.cs"
#line 418 "AdvancedModule.cs"
                                    bool* csharp2cuda_temp_275 = &(majorizes);
                                    (*(csharp2cuda_temp_275) = false);
                                }
                            }
#line 413 "AdvancedModule.cs"
                            int* csharp2cuda_temp_265 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_265));
                        }
                    }
#line 420 "AdvancedModule.cs"
#line 420 "AdvancedModule.cs"
                    int* csharp2cuda_temp_276 = &((output)->boolean_value);
#line 420 "AdvancedModule.cs"
                    bool csharp2cuda_temp_277;
#line 420 "AdvancedModule.cs"
                    if (majorizes)
                    {
#line 420 "AdvancedModule.cs"
                        csharp2cuda_temp_277 = ((left_sum) == (right_sum));
                    }
                    else
                    {
#line 420 "AdvancedModule.cs"
                        csharp2cuda_temp_277 = false;
                    }
#line 420 "AdvancedModule.cs"
                    int csharp2cuda_temp_278;
#line 420 "AdvancedModule.cs"
                    if (csharp2cuda_temp_277)
                    {
#line 420 "AdvancedModule.cs"
                        csharp2cuda_temp_278 = 1;
                    }
                    else
                    {
#line 420 "AdvancedModule.cs"
                        csharp2cuda_temp_278 = 0;
                    }
                    (*(csharp2cuda_temp_276) = csharp2cuda_temp_278);
#line 421 "AdvancedModule.cs"
                    break;
                }
#line 423 "AdvancedModule.cs"
            case 12:
#line 424 "AdvancedModule.cs"
#line 424 "AdvancedModule.cs"
                int csharp2cuda_temp_279 = (first)->count;
#line 424 "AdvancedModule.cs"
                bool csharp2cuda_temp_280;
#line 424 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_279) <= (0))))
                {
#line 424 "AdvancedModule.cs"
                    int csharp2cuda_temp_281 = (first)->count;
#line 424 "AdvancedModule.cs"
                    int csharp2cuda_temp_282 = (second)->count;
#line 424 "AdvancedModule.cs"
                    csharp2cuda_temp_280 = ((csharp2cuda_temp_281) != (csharp2cuda_temp_282));
                }
                else
                {
#line 424 "AdvancedModule.cs"
                    csharp2cuda_temp_280 = true;
                }
                if (csharp2cuda_temp_280)
#line 425 "AdvancedModule.cs"
                {
#line 426 "AdvancedModule.cs"
#line 426 "AdvancedModule.cs"
                    int* csharp2cuda_temp_283 = &((output)->valid);
                    (*(csharp2cuda_temp_283) = 0);
#line 427 "AdvancedModule.cs"
                    break;
                }
#line 429 "AdvancedModule.cs"
                {
#line 430 "AdvancedModule.cs"
                    double minimum = mathblocks_positive_infinity();
#line 431 "AdvancedModule.cs"
                    double maximum = (-(mathblocks_positive_infinity()));
#line 432 "AdvancedModule.cs"
                    {
#line 432 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 432 "AdvancedModule.cs"
                            int csharp2cuda_temp_285 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_285))))
                                break;
#line 433 "AdvancedModule.cs"
                            {
#line 434 "AdvancedModule.cs"
#line 434 "AdvancedModule.cs"
                                double csharp2cuda_temp_286 = (a)[index];
#line 434 "AdvancedModule.cs"
                                bool csharp2cuda_temp_287;
#line 434 "AdvancedModule.cs"
                                if (!(((csharp2cuda_temp_286) <= (0.0))))
                                {
#line 434 "AdvancedModule.cs"
                                    double csharp2cuda_temp_288 = (b)[index];
#line 434 "AdvancedModule.cs"
                                    csharp2cuda_temp_287 = ((csharp2cuda_temp_288) <= (0.0));
                                }
                                else
                                {
#line 434 "AdvancedModule.cs"
                                    csharp2cuda_temp_287 = true;
                                }
                                if (csharp2cuda_temp_287)
#line 435 "AdvancedModule.cs"
                                {
#line 436 "AdvancedModule.cs"
#line 436 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_289 = &((output)->valid);
                                    (*(csharp2cuda_temp_289) = 0);
#line 437 "AdvancedModule.cs"
                                    break;
                                }
#line 439 "AdvancedModule.cs"
                                double csharp2cuda_temp_290 = (a)[index];
#line 439 "AdvancedModule.cs"
                                double csharp2cuda_temp_291 = (b)[index];
#line 439 "AdvancedModule.cs"
                                double ratio = __ddiv_rn(csharp2cuda_temp_290, csharp2cuda_temp_291);
#line 440 "AdvancedModule.cs"
#line 440 "AdvancedModule.cs"
                                double* csharp2cuda_temp_292 = &(minimum);
#line 440 "AdvancedModule.cs"
                                double csharp2cuda_temp_293;
#line 440 "AdvancedModule.cs"
                                if (((minimum) < (ratio)))
                                {
#line 440 "AdvancedModule.cs"
                                    csharp2cuda_temp_293 = minimum;
                                }
                                else
                                {
#line 440 "AdvancedModule.cs"
                                    csharp2cuda_temp_293 = ratio;
                                }
                                (*(csharp2cuda_temp_292) = csharp2cuda_temp_293);
#line 441 "AdvancedModule.cs"
#line 441 "AdvancedModule.cs"
                                double* csharp2cuda_temp_294 = &(maximum);
#line 441 "AdvancedModule.cs"
                                double csharp2cuda_temp_295;
#line 441 "AdvancedModule.cs"
                                if (((maximum) > (ratio)))
                                {
#line 441 "AdvancedModule.cs"
                                    csharp2cuda_temp_295 = maximum;
                                }
                                else
                                {
#line 441 "AdvancedModule.cs"
                                    csharp2cuda_temp_295 = ratio;
                                }
                                (*(csharp2cuda_temp_294) = csharp2cuda_temp_295);
                            }
#line 432 "AdvancedModule.cs"
                            int* csharp2cuda_temp_284 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_284));
                        }
                    }
#line 443 "AdvancedModule.cs"
#line 443 "AdvancedModule.cs"
                    double* csharp2cuda_temp_296 = &((output)->scalar_value);
#line 443 "AdvancedModule.cs"
                    double csharp2cuda_temp_297 = __ddiv_rn(maximum, minimum);
                    (*(csharp2cuda_temp_296) = mathblocks_natural_logarithm(csharp2cuda_temp_297));
#line 444 "AdvancedModule.cs"
                    break;
                }
#line 446 "AdvancedModule.cs"
            case 13:
            case 16:
#line 448 "AdvancedModule.cs"
#line 448 "AdvancedModule.cs"
                int csharp2cuda_temp_298 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_298);
#line 449 "AdvancedModule.cs"
#line 449 "AdvancedModule.cs"
                int csharp2cuda_temp_299 = (first)->count;
#line 449 "AdvancedModule.cs"
                bool csharp2cuda_temp_300;
#line 449 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_299) <= (0))))
                {
#line 449 "AdvancedModule.cs"
                    csharp2cuda_temp_300 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 449 "AdvancedModule.cs"
                    csharp2cuda_temp_300 = true;
                }
                if (csharp2cuda_temp_300)
#line 450 "AdvancedModule.cs"
                {
#line 451 "AdvancedModule.cs"
#line 451 "AdvancedModule.cs"
                    int* csharp2cuda_temp_301 = &((output)->valid);
                    (*(csharp2cuda_temp_301) = 0);
#line 452 "AdvancedModule.cs"
                    break;
                }
#line 454 "AdvancedModule.cs"
                {
#line 455 "AdvancedModule.cs"
                    int* hull = ((int*)(scratch));
#line 456 "AdvancedModule.cs"
                    int hull_count = 0;
#line 457 "AdvancedModule.cs"
                    bool concave = ((opcode) == (16));
#line 458 "AdvancedModule.cs"
                    {
#line 458 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 458 "AdvancedModule.cs"
                            int csharp2cuda_temp_303 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_303))))
                                break;
#line 459 "AdvancedModule.cs"
                            {
#line 460 "AdvancedModule.cs"
#line 460 "AdvancedModule.cs"
                                int* csharp2cuda_temp_304 = &(hull_count);
#line 460 "AdvancedModule.cs"
                                int csharp2cuda_temp_305 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_304));
#line 460 "AdvancedModule.cs"
                                int* csharp2cuda_temp_306 = &((hull)[csharp2cuda_temp_305]);
                                (*(csharp2cuda_temp_306) = index);
#line 461 "AdvancedModule.cs"
                                while (true)
                                {
                                    if (!(((hull_count) >= (3))))
                                        break;
#line 462 "AdvancedModule.cs"
                                    {
#line 463 "AdvancedModule.cs"
                                        int one = (hull)[csharp2cuda_i32_sub(hull_count, 3)];
#line 464 "AdvancedModule.cs"
                                        int middle = (hull)[csharp2cuda_i32_sub(hull_count, 2)];
#line 465 "AdvancedModule.cs"
                                        int last = (hull)[csharp2cuda_i32_sub(hull_count, 1)];
#line 466 "AdvancedModule.cs"
                                        double csharp2cuda_temp_307 = (a)[middle];
#line 466 "AdvancedModule.cs"
                                        double csharp2cuda_temp_308 = (a)[one];
#line 466 "AdvancedModule.cs"
                                        double first_slope = __ddiv_rn(__dsub_rn(csharp2cuda_temp_307, csharp2cuda_temp_308), ((double)(csharp2cuda_i32_sub(middle, one))));
#line 467 "AdvancedModule.cs"
                                        double csharp2cuda_temp_309 = (a)[last];
#line 467 "AdvancedModule.cs"
                                        double csharp2cuda_temp_310 = (a)[middle];
#line 467 "AdvancedModule.cs"
                                        double second_slope = __ddiv_rn(__dsub_rn(csharp2cuda_temp_309, csharp2cuda_temp_310), ((double)(csharp2cuda_i32_sub(last, middle))));
#line 468 "AdvancedModule.cs"
#line 468 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_311;
#line 468 "AdvancedModule.cs"
                                        if (concave)
                                        {
#line 468 "AdvancedModule.cs"
                                            csharp2cuda_temp_311 = ((first_slope) >= (second_slope));
                                        }
                                        else
                                        {
#line 468 "AdvancedModule.cs"
                                            csharp2cuda_temp_311 = ((first_slope) <= (second_slope));
                                        }
                                        if (csharp2cuda_temp_311)
                                        {
#line 469 "AdvancedModule.cs"
                                            break;
                                        }
#line 470 "AdvancedModule.cs"
#line 470 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_312 = &((hull)[csharp2cuda_i32_sub(hull_count, 2)]);
#line 470 "AdvancedModule.cs"
                                        int csharp2cuda_temp_313 = (hull)[csharp2cuda_i32_sub(hull_count, 1)];
                                        (*(csharp2cuda_temp_312) = csharp2cuda_temp_313);
#line 471 "AdvancedModule.cs"
#line 471 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_314 = &(hull_count);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_314));
                                    }
                                }
                            }
#line 458 "AdvancedModule.cs"
                            int* csharp2cuda_temp_302 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_302));
                        }
                    }
#line 474 "AdvancedModule.cs"
                    {
#line 474 "AdvancedModule.cs"
                        int segment = 1;
                        while (true)
                        {
                            if (!(((segment) < (hull_count))))
                                break;
#line 475 "AdvancedModule.cs"
                            {
#line 476 "AdvancedModule.cs"
                                int start = (hull)[csharp2cuda_i32_sub(segment, 1)];
#line 477 "AdvancedModule.cs"
                                int end = (hull)[segment];
#line 478 "AdvancedModule.cs"
                                {
#line 478 "AdvancedModule.cs"
                                    int index = start;
                                    while (true)
                                    {
                                        if (!(((index) <= (end))))
                                            break;
#line 479 "AdvancedModule.cs"
                                        {
#line 480 "AdvancedModule.cs"
                                            double weight = __ddiv_rn(((double)(csharp2cuda_i32_sub(index, start))), ((double)(csharp2cuda_i32_sub(end, start))));
#line 481 "AdvancedModule.cs"
#line 481 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_317 = &((result)[index]);
#line 481 "AdvancedModule.cs"
                                            double csharp2cuda_temp_318 = (a)[start];
#line 481 "AdvancedModule.cs"
                                            double csharp2cuda_temp_319 = (a)[end];
                                            (*(csharp2cuda_temp_317) = __dadd_rn(__dmul_rn(csharp2cuda_temp_318, __dsub_rn(1.0, weight)), __dmul_rn(csharp2cuda_temp_319, weight)));
                                        }
#line 478 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_316 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_316));
                                    }
                                }
                            }
#line 474 "AdvancedModule.cs"
                            int* csharp2cuda_temp_315 = &(segment);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_315));
                        }
                    }
#line 484 "AdvancedModule.cs"
                    break;
                }
#line 486 "AdvancedModule.cs"
            case 14:
#line 487 "AdvancedModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 488 "AdvancedModule.cs"
                {
#line 489 "AdvancedModule.cs"
#line 489 "AdvancedModule.cs"
                    int* csharp2cuda_temp_320 = &((output)->valid);
                    (*(csharp2cuda_temp_320) = 0);
#line 490 "AdvancedModule.cs"
                    break;
                }
#line 492 "AdvancedModule.cs"
                {
#line 492 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 492 "AdvancedModule.cs"
                        int csharp2cuda_temp_322 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_322))))
                            break;
#line 493 "AdvancedModule.cs"
#line 493 "AdvancedModule.cs"
                        double* csharp2cuda_temp_323 = &((scratch)[index]);
#line 493 "AdvancedModule.cs"
                        double csharp2cuda_temp_324 = (a)[index];
                        (*(csharp2cuda_temp_323) = csharp2cuda_temp_324);
#line 492 "AdvancedModule.cs"
                        int* csharp2cuda_temp_321 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_321));
                    }
                }
#line 494 "AdvancedModule.cs"
#line 494 "AdvancedModule.cs"
                int* csharp2cuda_temp_325 = &((output)->boolean_value);
                (*(csharp2cuda_temp_325) = 1);
#line 495 "AdvancedModule.cs"
                {
#line 495 "AdvancedModule.cs"
                    int order = 0;
#line 495 "AdvancedModule.cs"
                    int length = (first)->count;
                    while (true)
                    {
#line 496 "AdvancedModule.cs"
                        int csharp2cuda_temp_328 = (first)->count;
#line 496 "AdvancedModule.cs"
                        bool csharp2cuda_temp_329;
#line 496 "AdvancedModule.cs"
                        if (((order) < (csharp2cuda_temp_328)))
                        {
#line 496 "AdvancedModule.cs"
                            csharp2cuda_temp_329 = (output)->boolean_value;
                        }
                        else
                        {
#line 496 "AdvancedModule.cs"
                            csharp2cuda_temp_329 = false;
                        }
                        if (!(csharp2cuda_temp_329))
                            break;
#line 498 "AdvancedModule.cs"
                        {
#line 499 "AdvancedModule.cs"
                            double csharp2cuda_temp_330;
#line 499 "AdvancedModule.cs"
                            if (((csharp2cuda_i32_and(order, 1)) == (0)))
                            {
#line 499 "AdvancedModule.cs"
                                csharp2cuda_temp_330 = 1.0;
                            }
                            else
                            {
#line 499 "AdvancedModule.cs"
                                csharp2cuda_temp_330 = (-(1.0));
                            }
#line 499 "AdvancedModule.cs"
                            double sign = csharp2cuda_temp_330;
#line 500 "AdvancedModule.cs"
                            {
#line 500 "AdvancedModule.cs"
                                int index = 0;
                                while (true)
                                {
                                    if (!(((index) < (length))))
                                        break;
#line 501 "AdvancedModule.cs"
#line 501 "AdvancedModule.cs"
                                    double csharp2cuda_temp_332 = (scratch)[index];
                                    if (((__dmul_rn(sign, csharp2cuda_temp_332)) < (0.0)))
#line 502 "AdvancedModule.cs"
                                    {
#line 503 "AdvancedModule.cs"
#line 503 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_333 = &((output)->boolean_value);
                                        (*(csharp2cuda_temp_333) = 0);
#line 504 "AdvancedModule.cs"
                                        break;
                                    }
#line 500 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_331 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_331));
                                }
                            }
#line 506 "AdvancedModule.cs"
                            {
#line 506 "AdvancedModule.cs"
                                int index = 1;
                                while (true)
                                {
#line 506 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_335 = (output)->boolean_value;
#line 506 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_336;
#line 506 "AdvancedModule.cs"
                                    if (csharp2cuda_temp_335)
                                    {
#line 506 "AdvancedModule.cs"
                                        csharp2cuda_temp_336 = ((index) < (length));
                                    }
                                    else
                                    {
#line 506 "AdvancedModule.cs"
                                        csharp2cuda_temp_336 = false;
                                    }
                                    if (!(csharp2cuda_temp_336))
                                        break;
#line 507 "AdvancedModule.cs"
#line 507 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_337 = &((scratch)[csharp2cuda_i32_sub(index, 1)]);
#line 507 "AdvancedModule.cs"
                                    double csharp2cuda_temp_338 = (scratch)[index];
#line 507 "AdvancedModule.cs"
                                    double csharp2cuda_temp_339 = (scratch)[csharp2cuda_i32_sub(index, 1)];
                                    (*(csharp2cuda_temp_337) = __dsub_rn(csharp2cuda_temp_338, csharp2cuda_temp_339));
#line 506 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_334 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_334));
                                }
                            }
                        }
#line 497 "AdvancedModule.cs"
                        int* csharp2cuda_temp_326 = &(order);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_326));
#line 497 "AdvancedModule.cs"
                        int* csharp2cuda_temp_327 = &(length);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_327));
                    }
                }
#line 509 "AdvancedModule.cs"
                break;
#line 510 "AdvancedModule.cs"
            case 15:
#line 511 "AdvancedModule.cs"
#line 511 "AdvancedModule.cs"
                int* csharp2cuda_temp_340 = &((output)->boolean_value);
                (*(csharp2cuda_temp_340) = 1);
#line 512 "AdvancedModule.cs"
                {
#line 512 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 512 "AdvancedModule.cs"
                        int csharp2cuda_temp_342 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_342))))
                            break;
#line 513 "AdvancedModule.cs"
#line 513 "AdvancedModule.cs"
                        double csharp2cuda_temp_343 = (a)[index];
                        if (((csharp2cuda_temp_343) < (0.0)))
                        {
#line 513 "AdvancedModule.cs"
#line 513 "AdvancedModule.cs"
                            int* csharp2cuda_temp_344 = &((output)->boolean_value);
                            (*(csharp2cuda_temp_344) = 0);
                        }
#line 512 "AdvancedModule.cs"
                        int* csharp2cuda_temp_341 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_341));
                    }
                }
#line 514 "AdvancedModule.cs"
                {
#line 514 "AdvancedModule.cs"
                    int index = 1;
                    while (true)
                    {
#line 514 "AdvancedModule.cs"
                        bool csharp2cuda_temp_346 = (output)->boolean_value;
#line 514 "AdvancedModule.cs"
                        bool csharp2cuda_temp_347;
#line 514 "AdvancedModule.cs"
                        if (csharp2cuda_temp_346)
                        {
#line 514 "AdvancedModule.cs"
                            int csharp2cuda_temp_348 = (first)->count;
#line 514 "AdvancedModule.cs"
                            csharp2cuda_temp_347 = ((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_348, 1)));
                        }
                        else
                        {
#line 514 "AdvancedModule.cs"
                            csharp2cuda_temp_347 = false;
                        }
                        if (!(csharp2cuda_temp_347))
                            break;
#line 515 "AdvancedModule.cs"
#line 515 "AdvancedModule.cs"
                        double csharp2cuda_temp_349 = (a)[index];
#line 515 "AdvancedModule.cs"
                        double csharp2cuda_temp_350 = (a)[index];
#line 515 "AdvancedModule.cs"
                        double csharp2cuda_temp_351 = (a)[csharp2cuda_i32_sub(index, 1)];
#line 515 "AdvancedModule.cs"
                        double csharp2cuda_temp_352 = (a)[csharp2cuda_i32_add(index, 1)];
                        if (((__dmul_rn(csharp2cuda_temp_349, csharp2cuda_temp_350)) < (__dmul_rn(csharp2cuda_temp_351, csharp2cuda_temp_352))))
                        {
#line 516 "AdvancedModule.cs"
#line 516 "AdvancedModule.cs"
                            int* csharp2cuda_temp_353 = &((output)->boolean_value);
                            (*(csharp2cuda_temp_353) = 0);
                        }
#line 514 "AdvancedModule.cs"
                        int* csharp2cuda_temp_345 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_345));
                    }
                }
#line 517 "AdvancedModule.cs"
                break;
#line 518 "AdvancedModule.cs"
            case 17:
#line 519 "AdvancedModule.cs"
#line 519 "AdvancedModule.cs"
                int csharp2cuda_temp_354 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_354);
#line 520 "AdvancedModule.cs"
#line 520 "AdvancedModule.cs"
                int csharp2cuda_temp_355 = (first)->count;
#line 520 "AdvancedModule.cs"
                bool csharp2cuda_temp_356 = mathblocks_advanced_distribution(a, csharp2cuda_temp_355);
                if ((!(csharp2cuda_temp_356)))
#line 521 "AdvancedModule.cs"
                {
#line 522 "AdvancedModule.cs"
#line 522 "AdvancedModule.cs"
                    int* csharp2cuda_temp_357 = &((output)->valid);
                    (*(csharp2cuda_temp_357) = 0);
#line 523 "AdvancedModule.cs"
                    break;
                }
#line 525 "AdvancedModule.cs"
                {
#line 526 "AdvancedModule.cs"
                    double survival = 1.0;
#line 527 "AdvancedModule.cs"
                    {
#line 527 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 527 "AdvancedModule.cs"
                            int csharp2cuda_temp_359 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_359))))
                                break;
#line 528 "AdvancedModule.cs"
                            {
#line 529 "AdvancedModule.cs"
#line 529 "AdvancedModule.cs"
                                double* csharp2cuda_temp_360 = &((result)[index]);
#line 529 "AdvancedModule.cs"
                                double csharp2cuda_temp_361 = (a)[index];
#line 529 "AdvancedModule.cs"
                                double csharp2cuda_temp_362 = __ddiv_rn(csharp2cuda_temp_361, survival);
                                (*(csharp2cuda_temp_360) = csharp2cuda_temp_362);
#line 530 "AdvancedModule.cs"
#line 530 "AdvancedModule.cs"
                                double* csharp2cuda_temp_363 = &(survival);
#line 530 "AdvancedModule.cs"
                                double csharp2cuda_temp_364 = *(csharp2cuda_temp_363);
#line 530 "AdvancedModule.cs"
                                double csharp2cuda_temp_365 = (a)[index];
                                (*(csharp2cuda_temp_363) = __dsub_rn(csharp2cuda_temp_364, csharp2cuda_temp_365));
                            }
#line 527 "AdvancedModule.cs"
                            int* csharp2cuda_temp_358 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_358));
                        }
                    }
#line 532 "AdvancedModule.cs"
                    break;
                }
#line 534 "AdvancedModule.cs"
            case 18:
#line 535 "AdvancedModule.cs"
#line 535 "AdvancedModule.cs"
                int csharp2cuda_temp_366 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_366);
#line 536 "AdvancedModule.cs"
#line 536 "AdvancedModule.cs"
                int csharp2cuda_temp_367 = (first)->count;
#line 536 "AdvancedModule.cs"
                int csharp2cuda_temp_368 = (second)->count;
                if (((csharp2cuda_temp_367) != (csharp2cuda_temp_368)))
#line 537 "AdvancedModule.cs"
                {
#line 538 "AdvancedModule.cs"
#line 538 "AdvancedModule.cs"
                    int* csharp2cuda_temp_369 = &((output)->valid);
                    (*(csharp2cuda_temp_369) = 0);
#line 539 "AdvancedModule.cs"
                    break;
                }
#line 541 "AdvancedModule.cs"
                {
#line 542 "AdvancedModule.cs"
                    double survival = 1.0;
#line 543 "AdvancedModule.cs"
                    {
#line 543 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 543 "AdvancedModule.cs"
                            int csharp2cuda_temp_371 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_371))))
                                break;
#line 544 "AdvancedModule.cs"
                            {
#line 545 "AdvancedModule.cs"
#line 545 "AdvancedModule.cs"
                                double csharp2cuda_temp_372 = (a)[index];
#line 545 "AdvancedModule.cs"
                                bool csharp2cuda_temp_373;
#line 545 "AdvancedModule.cs"
                                if (!(((csharp2cuda_temp_372) < (0.0))))
                                {
#line 545 "AdvancedModule.cs"
                                    double csharp2cuda_temp_374 = (b)[index];
#line 545 "AdvancedModule.cs"
                                    csharp2cuda_temp_373 = ((csharp2cuda_temp_374) <= (0.0));
                                }
                                else
                                {
#line 545 "AdvancedModule.cs"
                                    csharp2cuda_temp_373 = true;
                                }
#line 545 "AdvancedModule.cs"
                                bool csharp2cuda_temp_375;
#line 545 "AdvancedModule.cs"
                                if (!(csharp2cuda_temp_373))
                                {
#line 545 "AdvancedModule.cs"
                                    double csharp2cuda_temp_376 = (a)[index];
#line 545 "AdvancedModule.cs"
                                    double csharp2cuda_temp_377 = (b)[index];
#line 545 "AdvancedModule.cs"
                                    csharp2cuda_temp_375 = ((csharp2cuda_temp_376) > (csharp2cuda_temp_377));
                                }
                                else
                                {
#line 545 "AdvancedModule.cs"
                                    csharp2cuda_temp_375 = true;
                                }
                                if (csharp2cuda_temp_375)
#line 546 "AdvancedModule.cs"
                                {
#line 547 "AdvancedModule.cs"
#line 547 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_378 = &((output)->valid);
                                    (*(csharp2cuda_temp_378) = 0);
#line 548 "AdvancedModule.cs"
                                    break;
                                }
#line 550 "AdvancedModule.cs"
#line 550 "AdvancedModule.cs"
                                double* csharp2cuda_temp_379 = &(survival);
#line 550 "AdvancedModule.cs"
                                double csharp2cuda_temp_380 = *(csharp2cuda_temp_379);
#line 550 "AdvancedModule.cs"
                                double csharp2cuda_temp_381 = (a)[index];
#line 550 "AdvancedModule.cs"
                                double csharp2cuda_temp_382 = (b)[index];
#line 550 "AdvancedModule.cs"
                                double csharp2cuda_temp_383 = __ddiv_rn(csharp2cuda_temp_381, csharp2cuda_temp_382);
                                (*(csharp2cuda_temp_379) = __dmul_rn(csharp2cuda_temp_380, __dsub_rn(1.0, csharp2cuda_temp_383)));
#line 551 "AdvancedModule.cs"
#line 551 "AdvancedModule.cs"
                                double* csharp2cuda_temp_384 = &((result)[index]);
                                (*(csharp2cuda_temp_384) = survival);
                            }
#line 543 "AdvancedModule.cs"
                            int* csharp2cuda_temp_370 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_370));
                        }
                    }
#line 553 "AdvancedModule.cs"
                    break;
                }
        }
#line 557 "AdvancedModule.cs"
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_385 = (output)->valid;
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_386;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_385)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_386 = ((opcode) != (1));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_386 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_387;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_386)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_387 = ((opcode) != (2));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_387 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_388;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_387)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_388 = ((opcode) != (3));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_388 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_389;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_388)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_389 = ((opcode) != (4));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_389 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_390;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_389)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_390 = ((opcode) != (5));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_390 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_391;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_390)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_391 = ((opcode) != (7));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_391 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_392;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_391)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_392 = ((opcode) != (9));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_392 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_393;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_392)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_393 = ((opcode) != (10));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_393 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_394;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_393)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_394 = ((opcode) != (11));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_394 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_395;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_394)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_395 = ((opcode) != (13));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_395 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_396;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_395)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_396 = ((opcode) != (14));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_396 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_397;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_396)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_397 = ((opcode) != (15));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_397 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_398;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_397)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_398 = ((opcode) != (16));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_398 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_399;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_398)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_399 = ((opcode) != (17));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_399 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_400;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_399)
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_400 = ((opcode) != (18));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_400 = false;
        }
#line 557 "AdvancedModule.cs"
        bool csharp2cuda_temp_401;
#line 557 "AdvancedModule.cs"
        if (csharp2cuda_temp_400)
        {
#line 561 "AdvancedModule.cs"
            double csharp2cuda_temp_402 = (output)->scalar_value;
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_401 = (!(isfinite(csharp2cuda_temp_402)));
        }
        else
        {
#line 557 "AdvancedModule.cs"
            csharp2cuda_temp_401 = false;
        }
        if (csharp2cuda_temp_401)
#line 562 "AdvancedModule.cs"
        {
#line 563 "AdvancedModule.cs"
#line 563 "AdvancedModule.cs"
            int* csharp2cuda_temp_403 = &((output)->valid);
            (*(csharp2cuda_temp_403) = 0);
        }
#line 565 "AdvancedModule.cs"
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_404 = (output)->valid;
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_405;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_404)
        {
#line 566 "AdvancedModule.cs"
            bool csharp2cuda_temp_406;
#line 566 "AdvancedModule.cs"
            if (!(((opcode) == (2))))
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_406 = ((opcode) == (3));
            }
            else
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_406 = true;
            }
#line 566 "AdvancedModule.cs"
            bool csharp2cuda_temp_407;
#line 566 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_406))
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_407 = ((opcode) == (4));
            }
            else
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_407 = true;
            }
#line 566 "AdvancedModule.cs"
            bool csharp2cuda_temp_408;
#line 566 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_407))
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_408 = ((opcode) == (5));
            }
            else
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_408 = true;
            }
#line 566 "AdvancedModule.cs"
            bool csharp2cuda_temp_409;
#line 566 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_408))
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_409 = ((opcode) == (7));
            }
            else
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_409 = true;
            }
#line 566 "AdvancedModule.cs"
            bool csharp2cuda_temp_410;
#line 566 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_409))
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_410 = ((opcode) == (9));
            }
            else
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_410 = true;
            }
#line 566 "AdvancedModule.cs"
            bool csharp2cuda_temp_411;
#line 566 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_410))
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_411 = ((opcode) == (10));
            }
            else
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_411 = true;
            }
#line 566 "AdvancedModule.cs"
            bool csharp2cuda_temp_412;
#line 566 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_411))
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_412 = ((opcode) == (13));
            }
            else
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_412 = true;
            }
#line 566 "AdvancedModule.cs"
            bool csharp2cuda_temp_413;
#line 566 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_412))
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_413 = ((opcode) == (16));
            }
            else
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_413 = true;
            }
#line 566 "AdvancedModule.cs"
            bool csharp2cuda_temp_414;
#line 566 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_413))
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_414 = ((opcode) == (17));
            }
            else
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_414 = true;
            }
#line 566 "AdvancedModule.cs"
            bool csharp2cuda_temp_415;
#line 566 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_414))
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_415 = ((opcode) == (18));
            }
            else
            {
#line 566 "AdvancedModule.cs"
                csharp2cuda_temp_415 = true;
            }
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_405 = csharp2cuda_temp_415;
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_405 = false;
        }
        if (csharp2cuda_temp_405)
#line 569 "AdvancedModule.cs"
        {
#line 570 "AdvancedModule.cs"
            {
#line 570 "AdvancedModule.cs"
                int index = 0;
                while (true)
                {
#line 570 "AdvancedModule.cs"
                    int csharp2cuda_temp_417 = (output)->count;
                    if (!(((index) < (csharp2cuda_temp_417))))
                        break;
#line 571 "AdvancedModule.cs"
#line 571 "AdvancedModule.cs"
                    double csharp2cuda_temp_418 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_418))))
                    {
#line 571 "AdvancedModule.cs"
#line 571 "AdvancedModule.cs"
                        int* csharp2cuda_temp_419 = &((output)->valid);
                        (*(csharp2cuda_temp_419) = 0);
                    }
#line 570 "AdvancedModule.cs"
                    int* csharp2cuda_temp_416 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_416));
                }
            }
        }
    }
}

#line 79 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_distribution(const double* values, int count)
#line 81 "AdvancedModule.cs"
{
#line 82 "AdvancedModule.cs"
    return mathblocks_probability_distribution(values, count);
}

#line 70 "AdvancedModule.cs"
__device__ double mathblocks_advanced_factorial(int value)
#line 72 "AdvancedModule.cs"
{
#line 73 "AdvancedModule.cs"
    double result = 1.0;
#line 74 "AdvancedModule.cs"
    {
#line 74 "AdvancedModule.cs"
        int index = 2;
        while (true)
        {
            if (!(((index) <= (value))))
                break;
#line 75 "AdvancedModule.cs"
#line 75 "AdvancedModule.cs"
            double* csharp2cuda_temp_1 = &(result);
#line 75 "AdvancedModule.cs"
            double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
            (*(csharp2cuda_temp_1) = __dmul_rn(csharp2cuda_temp_2, ((double)(index))));
#line 74 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 76 "AdvancedModule.cs"
    return result;
}

#line 46 "AdvancedModule.cs"
__device__ int mathblocks_advanced_log_two(int value)
#line 48 "AdvancedModule.cs"
{
#line 49 "AdvancedModule.cs"
    int result = 0;
#line 50 "AdvancedModule.cs"
    while (true)
    {
        if (!(((value) > (1))))
            break;
#line 51 "AdvancedModule.cs"
        {
#line 52 "AdvancedModule.cs"
#line 52 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(value);
#line 52 "AdvancedModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_shr(csharp2cuda_temp_1, 1));
#line 53 "AdvancedModule.cs"
#line 53 "AdvancedModule.cs"
            int* csharp2cuda_temp_2 = &(result);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 55 "AdvancedModule.cs"
    return result;
}

#line 58 "AdvancedModule.cs"
__device__ int mathblocks_advanced_popcount(int value)
#line 60 "AdvancedModule.cs"
{
#line 61 "AdvancedModule.cs"
    int result = 0;
#line 62 "AdvancedModule.cs"
    while (true)
    {
        if (!(((value) != (0))))
            break;
#line 63 "AdvancedModule.cs"
        {
#line 64 "AdvancedModule.cs"
#line 64 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(result);
#line 64 "AdvancedModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, csharp2cuda_i32_and(value, 1)));
#line 65 "AdvancedModule.cs"
#line 65 "AdvancedModule.cs"
            int* csharp2cuda_temp_2 = &(value);
#line 65 "AdvancedModule.cs"
            int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
            (*(csharp2cuda_temp_2) = csharp2cuda_i32_shr(csharp2cuda_temp_3, 1));
        }
    }
#line 67 "AdvancedModule.cs"
    return result;
}

#line 40 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_power_of_two(int value)
#line 42 "AdvancedModule.cs"
{
#line 43 "AdvancedModule.cs"
#line 43 "AdvancedModule.cs"
    bool csharp2cuda_temp_0;
#line 43 "AdvancedModule.cs"
    if (((value) > (0)))
    {
#line 43 "AdvancedModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_i32_and(value, csharp2cuda_i32_sub(value, 1))) == (0));
    }
    else
    {
#line 43 "AdvancedModule.cs"
        csharp2cuda_temp_0 = false;
    }
    return csharp2cuda_temp_0;
}

#line 85 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_transition(
    const double* values,
    int rows,
    int columns)
#line 90 "AdvancedModule.cs"
{
#line 91 "AdvancedModule.cs"
    if (((rows) != (columns)))
    {
#line 92 "AdvancedModule.cs"
        return false;
    }
#line 93 "AdvancedModule.cs"
    {
#line 93 "AdvancedModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (rows))))
                break;
#line 94 "AdvancedModule.cs"
            {
#line 95 "AdvancedModule.cs"
                double sum = 0.0;
#line 96 "AdvancedModule.cs"
                {
#line 96 "AdvancedModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (columns))))
                            break;
#line 97 "AdvancedModule.cs"
                        {
#line 98 "AdvancedModule.cs"
                            double value = (values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 99 "AdvancedModule.cs"
                            if (((value) < (0.0)))
                            {
#line 100 "AdvancedModule.cs"
                                return false;
                            }
#line 101 "AdvancedModule.cs"
#line 101 "AdvancedModule.cs"
                            double* csharp2cuda_temp_2 = &(sum);
#line 101 "AdvancedModule.cs"
                            double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                            (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, value));
                        }
#line 96 "AdvancedModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 103 "AdvancedModule.cs"
                if (((fabs(__dsub_rn(sum, 1.0))) > (1E-10)))
                {
#line 104 "AdvancedModule.cs"
                    return false;
                }
            }
#line 93 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 106 "AdvancedModule.cs"
    return true;
}