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

#line 144 "ElementwiseModule.cs"
__device__ double mathblocks_elementwise_argument(const MathBlockSlot* slot, bool vector, int row);

#line 256 "ElementwiseModule.cs"
__device__ void mathblocks_elementwise_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 152 "ElementwiseModule.cs"
__device__ void mathblocks_elementwise_publish(MathBlockSlot* output, bool valid, int count, int thread);

#line 134 "ElementwiseModule.cs"
__device__ bool mathblocks_elementwise_row_value(int source_opcode, double a, double b, double c, double* value, bool* converged);

#line 166 "ElementwiseModule.cs"
__device__ void mathblocks_elementwise_run(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output,
    int thread,
    int threads);

#line 106 "ElementwiseModule.cs"
__device__ int mathblocks_elementwise_source_arity(int source);

#line 43 "ElementwiseModule.cs"
__device__ int mathblocks_elementwise_source_opcode(int source);

#line 144 "ElementwiseModule.cs"
__device__ double mathblocks_elementwise_argument(const MathBlockSlot* slot, bool vector, int row)
#line 146 "ElementwiseModule.cs"
{
#line 147 "ElementwiseModule.cs"
    if (((((void*)(slot))) == (((void*)(nullptr)))))
    {
#line 148 "ElementwiseModule.cs"
        return 0.0;
    }
#line 149 "ElementwiseModule.cs"
#line 149 "ElementwiseModule.cs"
    double csharp2cuda_temp_0;
#line 149 "ElementwiseModule.cs"
    if (vector)
    {
#line 149 "ElementwiseModule.cs"
        unsigned long long csharp2cuda_temp_1 = (slot)->data_pointer;
#line 149 "ElementwiseModule.cs"
        csharp2cuda_temp_0 = (((double*)(csharp2cuda_temp_1)))[row];
    }
    else
    {
#line 149 "ElementwiseModule.cs"
        csharp2cuda_temp_0 = (slot)->scalar_value;
    }
    return csharp2cuda_temp_0;
}

#line 256 "ElementwiseModule.cs"
__device__ void mathblocks_elementwise_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 262 "ElementwiseModule.cs"
{
#line 263 "ElementwiseModule.cs"
    mathblocks_elementwise_run(opcode, inputs, input_count, output, threadIdx.x, blockDim.x);
}

#line 152 "ElementwiseModule.cs"
__device__ void mathblocks_elementwise_publish(MathBlockSlot* output, bool valid, int count, int thread)
#line 154 "ElementwiseModule.cs"
{
#line 155 "ElementwiseModule.cs"
    if (((thread) != (0)))
    {
#line 156 "ElementwiseModule.cs"
        return;
    }
#line 157 "ElementwiseModule.cs"
#line 157 "ElementwiseModule.cs"
    double* csharp2cuda_temp_0 = &((output)->scalar_value);
    (*(csharp2cuda_temp_0) = 0.0);
#line 158 "ElementwiseModule.cs"
#line 158 "ElementwiseModule.cs"
    int* csharp2cuda_temp_1 = &((output)->boolean_value);
    (*(csharp2cuda_temp_1) = 0);
#line 159 "ElementwiseModule.cs"
#line 159 "ElementwiseModule.cs"
    int* csharp2cuda_temp_2 = &((output)->columns);
    (*(csharp2cuda_temp_2) = 0);
#line 160 "ElementwiseModule.cs"
#line 160 "ElementwiseModule.cs"
    int* csharp2cuda_temp_3 = &((output)->rows);
#line 160 "ElementwiseModule.cs"
    int csharp2cuda_temp_4;
#line 160 "ElementwiseModule.cs"
    if (valid)
    {
#line 160 "ElementwiseModule.cs"
        csharp2cuda_temp_4 = count;
    }
    else
    {
#line 160 "ElementwiseModule.cs"
        csharp2cuda_temp_4 = 0;
    }
    (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 161 "ElementwiseModule.cs"
#line 161 "ElementwiseModule.cs"
    int* csharp2cuda_temp_5 = &((output)->count);
#line 161 "ElementwiseModule.cs"
    int csharp2cuda_temp_6;
#line 161 "ElementwiseModule.cs"
    if (valid)
    {
#line 161 "ElementwiseModule.cs"
        csharp2cuda_temp_6 = count;
    }
    else
    {
#line 161 "ElementwiseModule.cs"
        csharp2cuda_temp_6 = 0;
    }
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 162 "ElementwiseModule.cs"
#line 162 "ElementwiseModule.cs"
    int* csharp2cuda_temp_7 = &((output)->valid);
    (*(csharp2cuda_temp_7) = valid);
}

#line 134 "ElementwiseModule.cs"
__device__ bool mathblocks_elementwise_row_value(int source_opcode, double a, double b, double c, double* value, bool* converged)
#line 136 "ElementwiseModule.cs"
{
#line 137 "ElementwiseModule.cs"
#line 137 "ElementwiseModule.cs"
    bool* csharp2cuda_temp_0 = converged;
    (*(csharp2cuda_temp_0) = true);
#line 138 "ElementwiseModule.cs"
#line 138 "ElementwiseModule.cs"
    bool csharp2cuda_temp_1;
#line 138 "ElementwiseModule.cs"
    if (((source_opcode) >= (64)))
    {
#line 138 "ElementwiseModule.cs"
        csharp2cuda_temp_1 = mathblocks_probability_scalar_value(csharp2cuda_i32_sub(source_opcode, 64), a, b, c, value, converged);
    }
    else
    {
#line 138 "ElementwiseModule.cs"
        csharp2cuda_temp_1 = mathblocks_scalar_value(source_opcode, a, b, c, value);
    }
    return csharp2cuda_temp_1;
}

#line 166 "ElementwiseModule.cs"
__device__ void mathblocks_elementwise_run(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output,
    int thread,
    int threads)
#line 174 "ElementwiseModule.cs"
{
#line 177 "ElementwiseModule.cs"
    int passed_mask = csharp2cuda_i32_div(opcode, 128);
#line 178 "ElementwiseModule.cs"
    int form = csharp2cuda_i32_rem(opcode, 128);
#line 179 "ElementwiseModule.cs"
    if (((opcode) >= (1024)))
#line 180 "ElementwiseModule.cs"
    {
#line 181 "ElementwiseModule.cs"
        int relative = csharp2cuda_i32_sub(opcode, 1024);
#line 182 "ElementwiseModule.cs"
#line 182 "ElementwiseModule.cs"
        int* csharp2cuda_temp_0 = &(passed_mask);
#line 182 "ElementwiseModule.cs"
        int csharp2cuda_temp_1 = csharp2cuda_i32_div(relative, 65536);
        (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
#line 183 "ElementwiseModule.cs"
#line 183 "ElementwiseModule.cs"
        int* csharp2cuda_temp_2 = &(form);
#line 183 "ElementwiseModule.cs"
        int csharp2cuda_temp_3 = csharp2cuda_i32_rem(relative, 65536);
        (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
    }
#line 185 "ElementwiseModule.cs"
    int source = csharp2cuda_i32_div(form, 2);
#line 186 "ElementwiseModule.cs"
    int csharp2cuda_temp_4 = csharp2cuda_i32_rem(form, 2);
#line 186 "ElementwiseModule.cs"
    bool sibling = ((csharp2cuda_temp_4) != (0));
#line 187 "ElementwiseModule.cs"
    int arity = mathblocks_elementwise_source_arity(source);
#line 192 "ElementwiseModule.cs"
    int derived_mask = 0;
#line 193 "ElementwiseModule.cs"
    {
#line 193 "ElementwiseModule.cs"
        int index = 0;
        while (true)
        {
#line 193 "ElementwiseModule.cs"
            bool csharp2cuda_temp_6;
#line 193 "ElementwiseModule.cs"
            if (((index) < (arity)))
            {
#line 193 "ElementwiseModule.cs"
                csharp2cuda_temp_6 = ((index) < (input_count));
            }
            else
            {
#line 193 "ElementwiseModule.cs"
                csharp2cuda_temp_6 = false;
            }
            if (!(csharp2cuda_temp_6))
                break;
#line 194 "ElementwiseModule.cs"
#line 194 "ElementwiseModule.cs"
            MathBlockSlot* csharp2cuda_temp_7 = (inputs)[index];
#line 194 "ElementwiseModule.cs"
            bool csharp2cuda_temp_8;
#line 194 "ElementwiseModule.cs"
            if (((((void*)(csharp2cuda_temp_7))) != (((void*)(nullptr)))))
            {
#line 194 "ElementwiseModule.cs"
                MathBlockSlot* csharp2cuda_temp_9 = (inputs)[index];
#line 194 "ElementwiseModule.cs"
                int csharp2cuda_temp_10 = (csharp2cuda_temp_9)->count;
#line 194 "ElementwiseModule.cs"
                csharp2cuda_temp_8 = ((csharp2cuda_temp_10) > (0));
            }
            else
            {
#line 194 "ElementwiseModule.cs"
                csharp2cuda_temp_8 = false;
            }
            if (csharp2cuda_temp_8)
            {
#line 195 "ElementwiseModule.cs"
#line 195 "ElementwiseModule.cs"
                int* csharp2cuda_temp_11 = &(derived_mask);
#line 195 "ElementwiseModule.cs"
                int csharp2cuda_temp_12 = *(csharp2cuda_temp_11);
                (*(csharp2cuda_temp_11) = csharp2cuda_i32_or(csharp2cuda_temp_12, csharp2cuda_i32_shl(1, index)));
            }
#line 193 "ElementwiseModule.cs"
            int* csharp2cuda_temp_5 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
        }
    }
#line 196 "ElementwiseModule.cs"
    int csharp2cuda_temp_13;
#line 196 "ElementwiseModule.cs"
    if (((passed_mask) == (0)))
    {
#line 196 "ElementwiseModule.cs"
        csharp2cuda_temp_13 = derived_mask;
    }
    else
    {
#line 196 "ElementwiseModule.cs"
        csharp2cuda_temp_13 = passed_mask;
    }
#line 196 "ElementwiseModule.cs"
    int mask = csharp2cuda_temp_13;
#line 197 "ElementwiseModule.cs"
    bool csharp2cuda_temp_14;
#line 197 "ElementwiseModule.cs"
    if (((opcode) >= (0)))
    {
#line 197 "ElementwiseModule.cs"
        csharp2cuda_temp_14 = ((source) < (mathblocks_limit_elementwise_source_count()));
    }
    else
    {
#line 197 "ElementwiseModule.cs"
        csharp2cuda_temp_14 = false;
    }
#line 197 "ElementwiseModule.cs"
    bool csharp2cuda_temp_15;
#line 197 "ElementwiseModule.cs"
    if (csharp2cuda_temp_14)
    {
#line 197 "ElementwiseModule.cs"
        csharp2cuda_temp_15 = ((mask) > (0));
    }
    else
    {
#line 197 "ElementwiseModule.cs"
        csharp2cuda_temp_15 = false;
    }
#line 197 "ElementwiseModule.cs"
    bool csharp2cuda_temp_16;
#line 197 "ElementwiseModule.cs"
    if (csharp2cuda_temp_15)
    {
#line 197 "ElementwiseModule.cs"
        csharp2cuda_temp_16 = ((mask) < (csharp2cuda_i32_shl(1, arity)));
    }
    else
    {
#line 197 "ElementwiseModule.cs"
        csharp2cuda_temp_16 = false;
    }
#line 197 "ElementwiseModule.cs"
    bool csharp2cuda_temp_17;
#line 197 "ElementwiseModule.cs"
    if (csharp2cuda_temp_16)
    {
#line 197 "ElementwiseModule.cs"
        csharp2cuda_temp_17 = ((csharp2cuda_i32_and(derived_mask, csharp2cuda_i32_not(mask))) == (0));
    }
    else
    {
#line 197 "ElementwiseModule.cs"
        csharp2cuda_temp_17 = false;
    }
#line 197 "ElementwiseModule.cs"
    bool csharp2cuda_temp_18;
#line 197 "ElementwiseModule.cs"
    if (csharp2cuda_temp_17)
    {
#line 198 "ElementwiseModule.cs"
        int csharp2cuda_temp_19;
#line 198 "ElementwiseModule.cs"
        if (sibling)
        {
#line 198 "ElementwiseModule.cs"
            csharp2cuda_temp_19 = 0;
        }
        else
        {
#line 198 "ElementwiseModule.cs"
            csharp2cuda_temp_19 = 1;
        }
#line 197 "ElementwiseModule.cs"
        csharp2cuda_temp_18 = ((input_count) == (csharp2cuda_i32_add(arity, csharp2cuda_temp_19)));
    }
    else
    {
#line 197 "ElementwiseModule.cs"
        csharp2cuda_temp_18 = false;
    }
#line 197 "ElementwiseModule.cs"
    bool valid = csharp2cuda_temp_18;
#line 199 "ElementwiseModule.cs"
    {
#line 199 "ElementwiseModule.cs"
        int index = 0;
        while (true)
        {
#line 199 "ElementwiseModule.cs"
            bool csharp2cuda_temp_21;
#line 199 "ElementwiseModule.cs"
            if (valid)
            {
#line 199 "ElementwiseModule.cs"
                csharp2cuda_temp_21 = ((index) < (input_count));
            }
            else
            {
#line 199 "ElementwiseModule.cs"
                csharp2cuda_temp_21 = false;
            }
            if (!(csharp2cuda_temp_21))
                break;
#line 200 "ElementwiseModule.cs"
#line 200 "ElementwiseModule.cs"
            MathBlockSlot* csharp2cuda_temp_22 = (inputs)[index];
#line 200 "ElementwiseModule.cs"
            bool csharp2cuda_temp_23;
#line 200 "ElementwiseModule.cs"
            if (!(((((void*)(csharp2cuda_temp_22))) == (((void*)(nullptr))))))
            {
#line 200 "ElementwiseModule.cs"
                MathBlockSlot* csharp2cuda_temp_24 = (inputs)[index];
#line 200 "ElementwiseModule.cs"
                bool csharp2cuda_temp_25 = (csharp2cuda_temp_24)->valid;
#line 200 "ElementwiseModule.cs"
                csharp2cuda_temp_23 = (!(csharp2cuda_temp_25));
            }
            else
            {
#line 200 "ElementwiseModule.cs"
                csharp2cuda_temp_23 = true;
            }
            if (csharp2cuda_temp_23)
            {
#line 201 "ElementwiseModule.cs"
#line 201 "ElementwiseModule.cs"
                bool* csharp2cuda_temp_26 = &(valid);
                (*(csharp2cuda_temp_26) = false);
            }
#line 199 "ElementwiseModule.cs"
            int* csharp2cuda_temp_20 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_20));
        }
    }
#line 202 "ElementwiseModule.cs"
    int count = -1;
#line 203 "ElementwiseModule.cs"
    {
#line 203 "ElementwiseModule.cs"
        int index = 0;
        while (true)
        {
#line 203 "ElementwiseModule.cs"
            bool csharp2cuda_temp_28;
#line 203 "ElementwiseModule.cs"
            if (valid)
            {
#line 203 "ElementwiseModule.cs"
                csharp2cuda_temp_28 = ((index) < (arity));
            }
            else
            {
#line 203 "ElementwiseModule.cs"
                csharp2cuda_temp_28 = false;
            }
            if (!(csharp2cuda_temp_28))
                break;
#line 204 "ElementwiseModule.cs"
            {
#line 205 "ElementwiseModule.cs"
                if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, index))) == (0)))
                {
#line 206 "ElementwiseModule.cs"
                    goto csharp2cuda_for_continue_2;
                }
#line 207 "ElementwiseModule.cs"
                if (((count) < (0)))
                {
#line 208 "ElementwiseModule.cs"
#line 208 "ElementwiseModule.cs"
                    int* csharp2cuda_temp_29 = &(count);
#line 208 "ElementwiseModule.cs"
                    MathBlockSlot* csharp2cuda_temp_30 = (inputs)[index];
#line 208 "ElementwiseModule.cs"
                    int csharp2cuda_temp_31 = (csharp2cuda_temp_30)->count;
                    (*(csharp2cuda_temp_29) = csharp2cuda_temp_31);
                }
                else
                {
#line 209 "ElementwiseModule.cs"
#line 209 "ElementwiseModule.cs"
                    MathBlockSlot* csharp2cuda_temp_32 = (inputs)[index];
#line 209 "ElementwiseModule.cs"
                    int csharp2cuda_temp_33 = (csharp2cuda_temp_32)->count;
                    if (((csharp2cuda_temp_33) != (count)))
                    {
#line 210 "ElementwiseModule.cs"
#line 210 "ElementwiseModule.cs"
                        bool* csharp2cuda_temp_34 = &(valid);
                        (*(csharp2cuda_temp_34) = false);
                    }
                }
            }
            csharp2cuda_for_continue_2:
#line 203 "ElementwiseModule.cs"
            int* csharp2cuda_temp_27 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_27));
        }
    }
#line 212 "ElementwiseModule.cs"
#line 212 "ElementwiseModule.cs"
    bool csharp2cuda_temp_35;
#line 212 "ElementwiseModule.cs"
    if (valid)
    {
#line 212 "ElementwiseModule.cs"
        int csharp2cuda_temp_36 = (output)->capacity;
#line 212 "ElementwiseModule.cs"
        csharp2cuda_temp_35 = ((count) > (csharp2cuda_temp_36));
    }
    else
    {
#line 212 "ElementwiseModule.cs"
        csharp2cuda_temp_35 = false;
    }
    if (csharp2cuda_temp_35)
    {
#line 213 "ElementwiseModule.cs"
#line 213 "ElementwiseModule.cs"
        bool* csharp2cuda_temp_37 = &(valid);
        (*(csharp2cuda_temp_37) = false);
    }
#line 214 "ElementwiseModule.cs"
    mathblocks_elementwise_publish(output, valid, count, thread);
#line 215 "ElementwiseModule.cs"
    if ((!(valid)))
    {
#line 216 "ElementwiseModule.cs"
        return;
    }
#line 218 "ElementwiseModule.cs"
    MathBlockSlot* csharp2cuda_temp_38 = (inputs)[0];
#line 218 "ElementwiseModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_38;
#line 219 "ElementwiseModule.cs"
    MathBlockSlot* csharp2cuda_temp_39;
#line 219 "ElementwiseModule.cs"
    if (((arity) > (1)))
    {
#line 219 "ElementwiseModule.cs"
        csharp2cuda_temp_39 = (inputs)[1];
    }
    else
    {
#line 219 "ElementwiseModule.cs"
        csharp2cuda_temp_39 = ((MathBlockSlot*)(nullptr));
    }
#line 219 "ElementwiseModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_39;
#line 220 "ElementwiseModule.cs"
    MathBlockSlot* csharp2cuda_temp_40;
#line 220 "ElementwiseModule.cs"
    if (((arity) > (2)))
    {
#line 220 "ElementwiseModule.cs"
        csharp2cuda_temp_40 = (inputs)[2];
    }
    else
    {
#line 220 "ElementwiseModule.cs"
        csharp2cuda_temp_40 = ((MathBlockSlot*)(nullptr));
    }
#line 220 "ElementwiseModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_40;
#line 221 "ElementwiseModule.cs"
    bool first_vector = ((csharp2cuda_i32_and(mask, 1)) != (0));
#line 222 "ElementwiseModule.cs"
    bool second_vector = ((csharp2cuda_i32_and(mask, 2)) != (0));
#line 223 "ElementwiseModule.cs"
    bool third_vector = ((csharp2cuda_i32_and(mask, 4)) != (0));
#line 224 "ElementwiseModule.cs"
    double csharp2cuda_temp_41;
#line 224 "ElementwiseModule.cs"
    if (sibling)
    {
#line 224 "ElementwiseModule.cs"
        csharp2cuda_temp_41 = 0.0;
    }
    else
    {
#line 224 "ElementwiseModule.cs"
        MathBlockSlot* csharp2cuda_temp_42 = (inputs)[arity];
#line 224 "ElementwiseModule.cs"
        csharp2cuda_temp_41 = (csharp2cuda_temp_42)->scalar_value;
    }
#line 224 "ElementwiseModule.cs"
    double fill = csharp2cuda_temp_41;
#line 225 "ElementwiseModule.cs"
    int source_opcode = mathblocks_elementwise_source_opcode(source);
#line 226 "ElementwiseModule.cs"
    unsigned long long csharp2cuda_temp_43 = (output)->data_pointer;
#line 226 "ElementwiseModule.cs"
    double* result = ((double*)(csharp2cuda_temp_43));
#line 227 "ElementwiseModule.cs"
    unsigned long long csharp2cuda_temp_44 = (output)->data_pointer;
#line 227 "ElementwiseModule.cs"
    int* boolean_result = ((int*)(csharp2cuda_temp_44));
#line 228 "ElementwiseModule.cs"
    {
#line 228 "ElementwiseModule.cs"
        int row = thread;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 229 "ElementwiseModule.cs"
            {
#line 230 "ElementwiseModule.cs"
                double value = 0.0;
#line 231 "ElementwiseModule.cs"
                bool converged = true;
#line 232 "ElementwiseModule.cs"
                double argument_a = mathblocks_elementwise_argument(first, first_vector, row);
#line 233 "ElementwiseModule.cs"
                double argument_b = mathblocks_elementwise_argument(second, second_vector, row);
#line 234 "ElementwiseModule.cs"
                double argument_c = mathblocks_elementwise_argument(third, third_vector, row);
#line 237 "ElementwiseModule.cs"
                bool csharp2cuda_temp_47;
#line 237 "ElementwiseModule.cs"
                if (isfinite(argument_a))
                {
#line 238 "ElementwiseModule.cs"
                    bool csharp2cuda_temp_48;
#line 238 "ElementwiseModule.cs"
                    if (!(((arity) < (2))))
                    {
#line 238 "ElementwiseModule.cs"
                        csharp2cuda_temp_48 = isfinite(argument_b);
                    }
                    else
                    {
#line 238 "ElementwiseModule.cs"
                        csharp2cuda_temp_48 = true;
                    }
#line 237 "ElementwiseModule.cs"
                    csharp2cuda_temp_47 = csharp2cuda_temp_48;
                }
                else
                {
#line 237 "ElementwiseModule.cs"
                    csharp2cuda_temp_47 = false;
                }
#line 237 "ElementwiseModule.cs"
                bool csharp2cuda_temp_49;
#line 237 "ElementwiseModule.cs"
                if (csharp2cuda_temp_47)
                {
#line 239 "ElementwiseModule.cs"
                    bool csharp2cuda_temp_50;
#line 239 "ElementwiseModule.cs"
                    if (!(((arity) < (3))))
                    {
#line 239 "ElementwiseModule.cs"
                        csharp2cuda_temp_50 = isfinite(argument_c);
                    }
                    else
                    {
#line 239 "ElementwiseModule.cs"
                        csharp2cuda_temp_50 = true;
                    }
#line 237 "ElementwiseModule.cs"
                    csharp2cuda_temp_49 = csharp2cuda_temp_50;
                }
                else
                {
#line 237 "ElementwiseModule.cs"
                    csharp2cuda_temp_49 = false;
                }
#line 237 "ElementwiseModule.cs"
                bool row_valid = csharp2cuda_temp_49;
#line 240 "ElementwiseModule.cs"
                if (row_valid)
                {
#line 241 "ElementwiseModule.cs"
#line 241 "ElementwiseModule.cs"
                    bool* csharp2cuda_temp_51 = &(row_valid);
#line 246 "ElementwiseModule.cs"
                    double* csharp2cuda_temp_52 = &(value);
#line 247 "ElementwiseModule.cs"
                    bool* csharp2cuda_temp_53 = &(converged);
#line 241 "ElementwiseModule.cs"
                    bool csharp2cuda_temp_54 = mathblocks_elementwise_row_value(source_opcode, argument_a, argument_b, argument_c, csharp2cuda_temp_52, csharp2cuda_temp_53);
                    (*(csharp2cuda_temp_51) = csharp2cuda_temp_54);
                }
#line 248 "ElementwiseModule.cs"
                if ((!(converged)))
                {
#line 248 "ElementwiseModule.cs"
                    mathblocks_nonconvergence_record_elementwise(form);
                }
#line 249 "ElementwiseModule.cs"
                if (sibling)
                {
#line 250 "ElementwiseModule.cs"
#line 250 "ElementwiseModule.cs"
                    int* csharp2cuda_temp_55 = &((boolean_result)[row]);
                    (*(csharp2cuda_temp_55) = row_valid);
                }
                else
                {
#line 252 "ElementwiseModule.cs"
#line 252 "ElementwiseModule.cs"
                    double* csharp2cuda_temp_56 = &((result)[row]);
#line 252 "ElementwiseModule.cs"
                    double csharp2cuda_temp_57;
#line 252 "ElementwiseModule.cs"
                    if (row_valid)
                    {
#line 252 "ElementwiseModule.cs"
                        csharp2cuda_temp_57 = value;
                    }
                    else
                    {
#line 252 "ElementwiseModule.cs"
                        csharp2cuda_temp_57 = fill;
                    }
                    (*(csharp2cuda_temp_56) = csharp2cuda_temp_57);
                }
            }
#line 228 "ElementwiseModule.cs"
            int* csharp2cuda_temp_45 = &(row);
#line 228 "ElementwiseModule.cs"
            int csharp2cuda_temp_46 = *(csharp2cuda_temp_45);
            (*(csharp2cuda_temp_45) = csharp2cuda_i32_add(csharp2cuda_temp_46, threads));
        }
    }
}

#line 106 "ElementwiseModule.cs"
__device__ int mathblocks_elementwise_source_arity(int source)
#line 108 "ElementwiseModule.cs"
{
#line 109 "ElementwiseModule.cs"
    switch (source)
    {
#line 111 "ElementwiseModule.cs"
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
#line 125 "ElementwiseModule.cs"
            return 2;
#line 126 "ElementwiseModule.cs"
        case 12:
        case 40:
#line 128 "ElementwiseModule.cs"
            return 3;
#line 129 "ElementwiseModule.cs"
        default:
#line 130 "ElementwiseModule.cs"
            return 1;
    }
}

#line 43 "ElementwiseModule.cs"
__device__ int mathblocks_elementwise_source_opcode(int source)
#line 45 "ElementwiseModule.cs"
{
#line 46 "ElementwiseModule.cs"
    switch (source)
    {
#line 48 "ElementwiseModule.cs"
        case 0:
#line 48 "ElementwiseModule.cs"
            return 64;
#line 49 "ElementwiseModule.cs"
        case 1:
#line 49 "ElementwiseModule.cs"
            return 65;
#line 50 "ElementwiseModule.cs"
        case 2:
#line 50 "ElementwiseModule.cs"
            return 66;
#line 51 "ElementwiseModule.cs"
        case 3:
#line 51 "ElementwiseModule.cs"
            return 87;
#line 52 "ElementwiseModule.cs"
        case 4:
#line 52 "ElementwiseModule.cs"
            return 89;
#line 53 "ElementwiseModule.cs"
        case 5:
#line 53 "ElementwiseModule.cs"
            return 90;
#line 54 "ElementwiseModule.cs"
        case 6:
#line 54 "ElementwiseModule.cs"
            return 25;
#line 55 "ElementwiseModule.cs"
        case 7:
#line 55 "ElementwiseModule.cs"
            return 24;
#line 56 "ElementwiseModule.cs"
        case 8:
#line 56 "ElementwiseModule.cs"
            return 27;
#line 57 "ElementwiseModule.cs"
        case 9:
#line 57 "ElementwiseModule.cs"
            return 26;
#line 58 "ElementwiseModule.cs"
        case 10:
#line 58 "ElementwiseModule.cs"
            return 19;
#line 59 "ElementwiseModule.cs"
        case 11:
#line 59 "ElementwiseModule.cs"
            return 35;
#line 60 "ElementwiseModule.cs"
        case 12:
#line 60 "ElementwiseModule.cs"
            return 10;
#line 61 "ElementwiseModule.cs"
        case 13:
#line 61 "ElementwiseModule.cs"
            return 20;
#line 62 "ElementwiseModule.cs"
        case 14:
#line 62 "ElementwiseModule.cs"
            return 22;
#line 63 "ElementwiseModule.cs"
        case 15:
#line 63 "ElementwiseModule.cs"
            return 15;
#line 64 "ElementwiseModule.cs"
        case 16:
#line 64 "ElementwiseModule.cs"
            return 13;
#line 65 "ElementwiseModule.cs"
        case 17:
#line 65 "ElementwiseModule.cs"
            return 34;
#line 66 "ElementwiseModule.cs"
        case 18:
#line 66 "ElementwiseModule.cs"
            return 29;
#line 67 "ElementwiseModule.cs"
        case 19:
#line 67 "ElementwiseModule.cs"
            return 28;
#line 68 "ElementwiseModule.cs"
        case 20:
#line 68 "ElementwiseModule.cs"
            return 30;
#line 69 "ElementwiseModule.cs"
        case 21:
#line 69 "ElementwiseModule.cs"
            return 32;
#line 70 "ElementwiseModule.cs"
        case 22:
#line 70 "ElementwiseModule.cs"
            return 31;
#line 71 "ElementwiseModule.cs"
        case 23:
#line 71 "ElementwiseModule.cs"
            return 33;
#line 72 "ElementwiseModule.cs"
        case 24:
#line 72 "ElementwiseModule.cs"
            return 42;
#line 73 "ElementwiseModule.cs"
        case 25:
#line 73 "ElementwiseModule.cs"
            return 39;
#line 74 "ElementwiseModule.cs"
        case 26:
#line 74 "ElementwiseModule.cs"
            return 40;
#line 75 "ElementwiseModule.cs"
        case 27:
#line 75 "ElementwiseModule.cs"
            return 9;
#line 76 "ElementwiseModule.cs"
        case 28:
#line 76 "ElementwiseModule.cs"
            return 8;
#line 77 "ElementwiseModule.cs"
        case 29:
#line 77 "ElementwiseModule.cs"
            return 38;
#line 78 "ElementwiseModule.cs"
        case 30:
#line 78 "ElementwiseModule.cs"
            return 4;
#line 79 "ElementwiseModule.cs"
        case 31:
#line 79 "ElementwiseModule.cs"
            return 11;
#line 80 "ElementwiseModule.cs"
        case 32:
#line 80 "ElementwiseModule.cs"
            return 36;
#line 81 "ElementwiseModule.cs"
        case 33:
#line 81 "ElementwiseModule.cs"
            return 21;
#line 82 "ElementwiseModule.cs"
        case 34:
#line 82 "ElementwiseModule.cs"
            return 41;
#line 83 "ElementwiseModule.cs"
        case 35:
#line 83 "ElementwiseModule.cs"
            return 23;
#line 84 "ElementwiseModule.cs"
        case 36:
#line 84 "ElementwiseModule.cs"
            return 37;
#line 85 "ElementwiseModule.cs"
        case 37:
#line 85 "ElementwiseModule.cs"
            return 92;
#line 86 "ElementwiseModule.cs"
        case 38:
#line 86 "ElementwiseModule.cs"
            return 43;
#line 87 "ElementwiseModule.cs"
        case 39:
#line 87 "ElementwiseModule.cs"
            return 93;
#line 88 "ElementwiseModule.cs"
        case 40:
#line 88 "ElementwiseModule.cs"
            return 94;
#line 89 "ElementwiseModule.cs"
        case 41:
#line 89 "ElementwiseModule.cs"
            return 5;
#line 90 "ElementwiseModule.cs"
        case 42:
#line 90 "ElementwiseModule.cs"
            return 0;
#line 91 "ElementwiseModule.cs"
        case 43:
#line 91 "ElementwiseModule.cs"
            return 1;
#line 92 "ElementwiseModule.cs"
        case 44:
#line 92 "ElementwiseModule.cs"
            return 2;
#line 93 "ElementwiseModule.cs"
        case 45:
#line 93 "ElementwiseModule.cs"
            return 3;
#line 94 "ElementwiseModule.cs"
        case 46:
#line 94 "ElementwiseModule.cs"
            return 16;
#line 95 "ElementwiseModule.cs"
        case 47:
#line 95 "ElementwiseModule.cs"
            return 18;
#line 96 "ElementwiseModule.cs"
        case 48:
#line 96 "ElementwiseModule.cs"
            return 14;
#line 97 "ElementwiseModule.cs"
        case 49:
#line 97 "ElementwiseModule.cs"
            return 12;
#line 98 "ElementwiseModule.cs"
        case 50:
#line 98 "ElementwiseModule.cs"
            return 17;
#line 99 "ElementwiseModule.cs"
        case 51:
#line 99 "ElementwiseModule.cs"
            return 7;
#line 100 "ElementwiseModule.cs"
        case 52:
#line 100 "ElementwiseModule.cs"
            return 6;
#line 101 "ElementwiseModule.cs"
        default:
#line 101 "ElementwiseModule.cs"
            return csharp2cuda_i32_neg(1);
    }
}