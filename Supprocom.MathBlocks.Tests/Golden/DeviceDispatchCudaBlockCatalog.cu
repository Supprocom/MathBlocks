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

#line 189 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_advanced(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output);

#line 119 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_complex(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output);

#line 56 "DeviceDispatchModule.cs"
__device__ MathBlockSlot** mathblocks_dispatch_inputs(
    const MathBlockSlot* const* inputs);

#line 169 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_geometry(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output);

#line 179 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_graph(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output);

#line 129 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_matrix(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output);

#line 66 "DeviceDispatchModule.cs"
__device__ void mathblocks_operation_dispatch(
    int family,
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output);

#line 139 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_probability(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output);

#line 99 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_scalar(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output);

#line 149 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_sequence_path(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output);

#line 159 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_statistics(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output);

#line 199 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_transport(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output);

#line 109 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_vector(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output);

#line 189 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_advanced(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output)
#line 195 "DeviceDispatchModule.cs"
{
#line 196 "DeviceDispatchModule.cs"
#line 196 "DeviceDispatchModule.cs"
    MathBlockSlot** csharp2cuda_temp_0 = mathblocks_dispatch_inputs(inputs);
    mathblocks_advanced_dispatch(opcode, csharp2cuda_temp_0, input_count, output);
}

#line 119 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_complex(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output)
#line 125 "DeviceDispatchModule.cs"
{
#line 126 "DeviceDispatchModule.cs"
#line 126 "DeviceDispatchModule.cs"
    MathBlockSlot** csharp2cuda_temp_0 = mathblocks_dispatch_inputs(inputs);
    mathblocks_complex_dispatch(opcode, csharp2cuda_temp_0, input_count, output);
}

#line 56 "DeviceDispatchModule.cs"
__device__ MathBlockSlot** mathblocks_dispatch_inputs(
    const MathBlockSlot* const* inputs)
#line 59 "DeviceDispatchModule.cs"
{
#line 63 "DeviceDispatchModule.cs"
    return ((MathBlockSlot**)(((unsigned long long)(inputs))));
}

#line 169 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_geometry(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output)
#line 175 "DeviceDispatchModule.cs"
{
#line 176 "DeviceDispatchModule.cs"
#line 176 "DeviceDispatchModule.cs"
    MathBlockSlot** csharp2cuda_temp_0 = mathblocks_dispatch_inputs(inputs);
    mathblocks_geometry_dispatch(opcode, csharp2cuda_temp_0, input_count, output);
}

#line 179 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_graph(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output)
#line 185 "DeviceDispatchModule.cs"
{
#line 186 "DeviceDispatchModule.cs"
#line 186 "DeviceDispatchModule.cs"
    MathBlockSlot** csharp2cuda_temp_0 = mathblocks_dispatch_inputs(inputs);
    mathblocks_graph_dispatch(opcode, csharp2cuda_temp_0, input_count, output);
}

#line 129 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_matrix(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output)
#line 135 "DeviceDispatchModule.cs"
{
#line 136 "DeviceDispatchModule.cs"
#line 136 "DeviceDispatchModule.cs"
    MathBlockSlot** csharp2cuda_temp_0 = mathblocks_dispatch_inputs(inputs);
    mathblocks_matrix_dispatch(opcode, csharp2cuda_temp_0, input_count, output);
}

#line 66 "DeviceDispatchModule.cs"
__device__ void mathblocks_operation_dispatch(
    int family,
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output)
#line 73 "DeviceDispatchModule.cs"
{
#line 74 "DeviceDispatchModule.cs"
    MathBlockSlot** dispatchInputs = mathblocks_dispatch_inputs(inputs);
#line 75 "DeviceDispatchModule.cs"
    switch (family)
    {
#line 77 "DeviceDispatchModule.cs"
        case 0:
#line 77 "DeviceDispatchModule.cs"
            mathblocks_advanced_dispatch(opcode, dispatchInputs, input_count, output);
#line 77 "DeviceDispatchModule.cs"
            break;
#line 78 "DeviceDispatchModule.cs"
        case 1:
#line 78 "DeviceDispatchModule.cs"
            mathblocks_complex_dispatch(opcode, dispatchInputs, input_count, output);
#line 78 "DeviceDispatchModule.cs"
            break;
#line 79 "DeviceDispatchModule.cs"
        case 2:
#line 79 "DeviceDispatchModule.cs"
            mathblocks_geometry_dispatch(opcode, dispatchInputs, input_count, output);
#line 79 "DeviceDispatchModule.cs"
            break;
#line 80 "DeviceDispatchModule.cs"
        case 3:
#line 80 "DeviceDispatchModule.cs"
            mathblocks_graph_dispatch(opcode, dispatchInputs, input_count, output);
#line 80 "DeviceDispatchModule.cs"
            break;
#line 81 "DeviceDispatchModule.cs"
        case 4:
#line 81 "DeviceDispatchModule.cs"
            mathblocks_matrix_dispatch(opcode, dispatchInputs, input_count, output);
#line 81 "DeviceDispatchModule.cs"
            break;
#line 82 "DeviceDispatchModule.cs"
        case 5:
#line 82 "DeviceDispatchModule.cs"
            mathblocks_probability_dispatch(opcode, dispatchInputs, input_count, output);
#line 82 "DeviceDispatchModule.cs"
            break;
#line 83 "DeviceDispatchModule.cs"
        case 6:
#line 83 "DeviceDispatchModule.cs"
            mathblocks_scalar_dispatch(opcode, dispatchInputs, input_count, output);
#line 83 "DeviceDispatchModule.cs"
            break;
#line 84 "DeviceDispatchModule.cs"
        case 7:
#line 84 "DeviceDispatchModule.cs"
            mathblocks_sequence_path_dispatch(opcode, dispatchInputs, input_count, output);
#line 84 "DeviceDispatchModule.cs"
            break;
#line 85 "DeviceDispatchModule.cs"
        case 8:
#line 85 "DeviceDispatchModule.cs"
            mathblocks_statistics_dispatch(opcode, dispatchInputs, input_count, output);
#line 85 "DeviceDispatchModule.cs"
            break;
#line 86 "DeviceDispatchModule.cs"
        case 9:
#line 86 "DeviceDispatchModule.cs"
            mathblocks_transport_dispatch(opcode, dispatchInputs, input_count, output);
#line 86 "DeviceDispatchModule.cs"
            break;
#line 87 "DeviceDispatchModule.cs"
        case 10:
#line 87 "DeviceDispatchModule.cs"
            mathblocks_vector_dispatch(opcode, dispatchInputs, input_count, output);
#line 87 "DeviceDispatchModule.cs"
            break;
#line 88 "DeviceDispatchModule.cs"
        default:
#line 89 "DeviceDispatchModule.cs"
            if (((threadIdx.x) == (0)))
#line 90 "DeviceDispatchModule.cs"
            {
#line 91 "DeviceDispatchModule.cs"
#line 91 "DeviceDispatchModule.cs"
                int* csharp2cuda_temp_0 = &((output)->valid);
                (*(csharp2cuda_temp_0) = 0);
#line 92 "DeviceDispatchModule.cs"
#line 92 "DeviceDispatchModule.cs"
                int* csharp2cuda_temp_1 = &((output)->count);
                (*(csharp2cuda_temp_1) = 0);
            }
#line 94 "DeviceDispatchModule.cs"
            break;
    }
#line 96 "DeviceDispatchModule.cs"
    __syncthreads();
}

#line 139 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_probability(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output)
#line 145 "DeviceDispatchModule.cs"
{
#line 146 "DeviceDispatchModule.cs"
#line 146 "DeviceDispatchModule.cs"
    MathBlockSlot** csharp2cuda_temp_0 = mathblocks_dispatch_inputs(inputs);
    mathblocks_probability_dispatch(opcode, csharp2cuda_temp_0, input_count, output);
}

#line 99 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_scalar(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output)
#line 105 "DeviceDispatchModule.cs"
{
#line 106 "DeviceDispatchModule.cs"
#line 106 "DeviceDispatchModule.cs"
    MathBlockSlot** csharp2cuda_temp_0 = mathblocks_dispatch_inputs(inputs);
    mathblocks_scalar_dispatch(opcode, csharp2cuda_temp_0, input_count, output);
}

#line 149 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_sequence_path(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output)
#line 155 "DeviceDispatchModule.cs"
{
#line 156 "DeviceDispatchModule.cs"
#line 156 "DeviceDispatchModule.cs"
    MathBlockSlot** csharp2cuda_temp_0 = mathblocks_dispatch_inputs(inputs);
    mathblocks_sequence_path_dispatch(opcode, csharp2cuda_temp_0, input_count, output);
}

#line 159 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_statistics(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output)
#line 165 "DeviceDispatchModule.cs"
{
#line 166 "DeviceDispatchModule.cs"
#line 166 "DeviceDispatchModule.cs"
    MathBlockSlot** csharp2cuda_temp_0 = mathblocks_dispatch_inputs(inputs);
    mathblocks_statistics_dispatch(opcode, csharp2cuda_temp_0, input_count, output);
}

#line 199 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_transport(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output)
#line 205 "DeviceDispatchModule.cs"
{
#line 206 "DeviceDispatchModule.cs"
#line 206 "DeviceDispatchModule.cs"
    MathBlockSlot** csharp2cuda_temp_0 = mathblocks_dispatch_inputs(inputs);
    mathblocks_transport_dispatch(opcode, csharp2cuda_temp_0, input_count, output);
}

#line 109 "DeviceDispatchModule.cs"
extern "C" __global__ void mathblocks_vector(
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output)
#line 115 "DeviceDispatchModule.cs"
{
#line 116 "DeviceDispatchModule.cs"
#line 116 "DeviceDispatchModule.cs"
    MathBlockSlot** csharp2cuda_temp_0 = mathblocks_dispatch_inputs(inputs);
    mathblocks_vector_dispatch(opcode, csharp2cuda_temp_0, input_count, output);
}