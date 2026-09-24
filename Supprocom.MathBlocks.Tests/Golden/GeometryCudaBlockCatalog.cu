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

struct MathBlockGeometryEdge;

#line 37 "GeometryModule.cs"
struct MathBlockGeometryEdge
{
    int from;
    int to;
    double weight;
};

#line 107 "GeometryModule.cs"
__device__ void mathblocks_geometry_barycentric(
    double point_x,
    double point_y,
    double first_x,
    double first_y,
    double second_x,
    double second_y,
    double third_x,
    double third_y,
    double* result);

#line 70 "GeometryModule.cs"
__device__ double mathblocks_geometry_cross(
    double origin_x,
    double origin_y,
    double left_x,
    double left_y,
    double right_x,
    double right_y);

#line 238 "GeometryModule.cs"
__device__ void mathblocks_geometry_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 56 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance(
    const double* left,
    int left_index,
    const double* right,
    int right_index);

#line 44 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance_coordinates(
    double left_x,
    double left_y,
    double right_x,
    double right_y);

#line 222 "GeometryModule.cs"
__device__ bool mathblocks_geometry_edge_less(
    const MathBlockGeometryEdge* left,
    const MathBlockGeometryEdge* right);

#line 211 "GeometryModule.cs"
__device__ int mathblocks_geometry_find(int* parent, int value);

#line 171 "GeometryModule.cs"
__device__ bool mathblocks_geometry_point_less(
    const double* points,
    int left,
    int right);

#line 83 "GeometryModule.cs"
__device__ double mathblocks_geometry_point_to_segment(
    double point_x,
    double point_y,
    double start_x,
    double start_y,
    double end_x,
    double end_y);

#line 192 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_indices(
    const double* points,
    int count,
    int* indices);

#line 130 "GeometryModule.cs"
__device__ bool mathblocks_geometry_try_circumcircle(
    const double* points,
    int first,
    int second,
    int third,
    double* center_x,
    double* center_y,
    double* radius_square);

#line 107 "GeometryModule.cs"
__device__ void mathblocks_geometry_barycentric(
    double point_x,
    double point_y,
    double first_x,
    double first_y,
    double second_x,
    double second_y,
    double third_x,
    double third_y,
    double* result)
#line 118 "GeometryModule.cs"
{
#line 119 "GeometryModule.cs"
    double denominator = __dadd_rn(__dmul_rn(__dsub_rn(second_y, third_y), __dsub_rn(first_x, third_x)), __dmul_rn(__dsub_rn(third_x, second_x), __dsub_rn(first_y, third_y)));
#line 121 "GeometryModule.cs"
    double first_weight = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(second_y, third_y), __dsub_rn(point_x, third_x)), __dmul_rn(__dsub_rn(third_x, second_x), __dsub_rn(point_y, third_y))), denominator);
#line 123 "GeometryModule.cs"
    double second_weight = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(third_y, first_y), __dsub_rn(point_x, third_x)), __dmul_rn(__dsub_rn(first_x, third_x), __dsub_rn(point_y, third_y))), denominator);
#line 125 "GeometryModule.cs"
#line 125 "GeometryModule.cs"
    double* csharp2cuda_temp_0 = &((result)[0]);
    (*(csharp2cuda_temp_0) = first_weight);
#line 126 "GeometryModule.cs"
#line 126 "GeometryModule.cs"
    double* csharp2cuda_temp_1 = &((result)[1]);
    (*(csharp2cuda_temp_1) = second_weight);
#line 127 "GeometryModule.cs"
#line 127 "GeometryModule.cs"
    double* csharp2cuda_temp_2 = &((result)[2]);
    (*(csharp2cuda_temp_2) = __dsub_rn(__dsub_rn(1.0, first_weight), second_weight));
}

#line 70 "GeometryModule.cs"
__device__ double mathblocks_geometry_cross(
    double origin_x,
    double origin_y,
    double left_x,
    double left_y,
    double right_x,
    double right_y)
#line 78 "GeometryModule.cs"
{
#line 79 "GeometryModule.cs"
    return __dsub_rn(__dmul_rn(__dsub_rn(left_x, origin_x), __dsub_rn(right_y, origin_y)), __dmul_rn(__dsub_rn(left_y, origin_y), __dsub_rn(right_x, origin_x)));
}

#line 238 "GeometryModule.cs"
__device__ void mathblocks_geometry_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 244 "GeometryModule.cs"
{
#line 245 "GeometryModule.cs"
    int thread = threadIdx.x;
#line 246 "GeometryModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 246 "GeometryModule.cs"
    if (((input_count) > (0)))
    {
#line 246 "GeometryModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 246 "GeometryModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 246 "GeometryModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 247 "GeometryModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 247 "GeometryModule.cs"
    if (((input_count) > (1)))
    {
#line 247 "GeometryModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 247 "GeometryModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 247 "GeometryModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 248 "GeometryModule.cs"
    if (((thread) == (0)))
#line 249 "GeometryModule.cs"
    {
#line 250 "GeometryModule.cs"
#line 250 "GeometryModule.cs"
        double* csharp2cuda_temp_2 = &((output)->scalar_value);
        (*(csharp2cuda_temp_2) = 0.0);
#line 251 "GeometryModule.cs"
#line 251 "GeometryModule.cs"
        int* csharp2cuda_temp_3 = &((output)->boolean_value);
        (*(csharp2cuda_temp_3) = 0);
#line 252 "GeometryModule.cs"
#line 252 "GeometryModule.cs"
        int* csharp2cuda_temp_4 = &((output)->rows);
        (*(csharp2cuda_temp_4) = 0);
#line 253 "GeometryModule.cs"
#line 253 "GeometryModule.cs"
        int* csharp2cuda_temp_5 = &((output)->columns);
        (*(csharp2cuda_temp_5) = 0);
#line 254 "GeometryModule.cs"
#line 254 "GeometryModule.cs"
        int* csharp2cuda_temp_6 = &((output)->count);
        (*(csharp2cuda_temp_6) = 0);
#line 255 "GeometryModule.cs"
#line 255 "GeometryModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
#line 255 "GeometryModule.cs"
        bool csharp2cuda_temp_8;
#line 255 "GeometryModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 255 "GeometryModule.cs"
            csharp2cuda_temp_8 = (first)->valid;
        }
        else
        {
#line 255 "GeometryModule.cs"
            csharp2cuda_temp_8 = true;
        }
        (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 256 "GeometryModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 257 "GeometryModule.cs"
#line 257 "GeometryModule.cs"
            int* csharp2cuda_temp_9 = &((output)->valid);
#line 257 "GeometryModule.cs"
            bool csharp2cuda_temp_10 = (output)->valid;
#line 257 "GeometryModule.cs"
            bool csharp2cuda_temp_11;
#line 257 "GeometryModule.cs"
            if (csharp2cuda_temp_10)
            {
#line 257 "GeometryModule.cs"
                csharp2cuda_temp_11 = (second)->valid;
            }
            else
            {
#line 257 "GeometryModule.cs"
                csharp2cuda_temp_11 = false;
            }
            (*(csharp2cuda_temp_9) = csharp2cuda_temp_11);
        }
    }
#line 259 "GeometryModule.cs"
    __syncthreads();
#line 260 "GeometryModule.cs"
#line 260 "GeometryModule.cs"
    bool csharp2cuda_temp_12 = (output)->valid;
    if ((!(csharp2cuda_temp_12)))
    {
#line 261 "GeometryModule.cs"
        return;
    }
#line 263 "GeometryModule.cs"
    double* csharp2cuda_temp_13;
#line 263 "GeometryModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 263 "GeometryModule.cs"
        csharp2cuda_temp_13 = ((double*)(nullptr));
    }
    else
    {
#line 263 "GeometryModule.cs"
        unsigned long long csharp2cuda_temp_14 = (first)->data_pointer;
#line 263 "GeometryModule.cs"
        csharp2cuda_temp_13 = ((double*)(csharp2cuda_temp_14));
    }
#line 263 "GeometryModule.cs"
    const double* a = csharp2cuda_temp_13;
#line 264 "GeometryModule.cs"
    double* csharp2cuda_temp_15;
#line 264 "GeometryModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 264 "GeometryModule.cs"
        csharp2cuda_temp_15 = ((double*)(nullptr));
    }
    else
    {
#line 264 "GeometryModule.cs"
        unsigned long long csharp2cuda_temp_16 = (second)->data_pointer;
#line 264 "GeometryModule.cs"
        csharp2cuda_temp_15 = ((double*)(csharp2cuda_temp_16));
    }
#line 264 "GeometryModule.cs"
    const double* b = csharp2cuda_temp_15;
#line 265 "GeometryModule.cs"
    unsigned long long csharp2cuda_temp_17 = (output)->data_pointer;
#line 265 "GeometryModule.cs"
    double* result = ((double*)(csharp2cuda_temp_17));
#line 266 "GeometryModule.cs"
    unsigned long long csharp2cuda_temp_18 = (output)->scratch_pointer;
#line 266 "GeometryModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_18));
#line 268 "GeometryModule.cs"
    if (((thread) == (0)))
#line 269 "GeometryModule.cs"
    {
#line 270 "GeometryModule.cs"
        switch (opcode)
        {
#line 272 "GeometryModule.cs"
            case 0:
#line 273 "GeometryModule.cs"
                mathblocks_sequence_set_vector_shape(output, 3);
#line 274 "GeometryModule.cs"
#line 274 "GeometryModule.cs"
                int csharp2cuda_temp_19 = (first)->count;
#line 274 "GeometryModule.cs"
                bool csharp2cuda_temp_20;
#line 274 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_19) != (1))))
                {
#line 274 "GeometryModule.cs"
                    int csharp2cuda_temp_21 = (second)->count;
#line 274 "GeometryModule.cs"
                    csharp2cuda_temp_20 = ((csharp2cuda_temp_21) != (3));
                }
                else
                {
#line 274 "GeometryModule.cs"
                    csharp2cuda_temp_20 = true;
                }
                if (csharp2cuda_temp_20)
#line 275 "GeometryModule.cs"
                {
#line 276 "GeometryModule.cs"
#line 276 "GeometryModule.cs"
                    int* csharp2cuda_temp_22 = &((output)->valid);
                    (*(csharp2cuda_temp_22) = 0);
#line 277 "GeometryModule.cs"
                    break;
                }
#line 279 "GeometryModule.cs"
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_23 = (a)[0];
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_24 = (a)[1];
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_25 = (b)[0];
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_26 = (b)[1];
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_27 = (b)[2];
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_28 = (b)[3];
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_29 = (b)[4];
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_30 = (b)[5];
                mathblocks_geometry_barycentric(csharp2cuda_temp_23, csharp2cuda_temp_24, csharp2cuda_temp_25, csharp2cuda_temp_26, csharp2cuda_temp_27, csharp2cuda_temp_28, csharp2cuda_temp_29, csharp2cuda_temp_30, result);
#line 281 "GeometryModule.cs"
                {
#line 281 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (3))))
                            break;
#line 282 "GeometryModule.cs"
#line 282 "GeometryModule.cs"
                        double csharp2cuda_temp_32 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_32))))
                        {
#line 282 "GeometryModule.cs"
#line 282 "GeometryModule.cs"
                            int* csharp2cuda_temp_33 = &((output)->valid);
                            (*(csharp2cuda_temp_33) = 0);
                        }
#line 281 "GeometryModule.cs"
                        int* csharp2cuda_temp_31 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                    }
                }
#line 283 "GeometryModule.cs"
                break;
#line 284 "GeometryModule.cs"
            case 1:
#line 285 "GeometryModule.cs"
#line 285 "GeometryModule.cs"
                int* csharp2cuda_temp_34 = &((output)->rows);
                (*(csharp2cuda_temp_34) = 1);
#line 286 "GeometryModule.cs"
#line 286 "GeometryModule.cs"
                int* csharp2cuda_temp_35 = &((output)->count);
                (*(csharp2cuda_temp_35) = 1);
#line 287 "GeometryModule.cs"
#line 287 "GeometryModule.cs"
                int csharp2cuda_temp_36 = (first)->count;
#line 287 "GeometryModule.cs"
                bool csharp2cuda_temp_37;
#line 287 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_36) <= (0))))
                {
#line 287 "GeometryModule.cs"
                    int csharp2cuda_temp_38 = (output)->capacity;
#line 287 "GeometryModule.cs"
                    csharp2cuda_temp_37 = ((csharp2cuda_temp_38) < (1));
                }
                else
                {
#line 287 "GeometryModule.cs"
                    csharp2cuda_temp_37 = true;
                }
                if (csharp2cuda_temp_37)
#line 288 "GeometryModule.cs"
                {
#line 289 "GeometryModule.cs"
#line 289 "GeometryModule.cs"
                    int* csharp2cuda_temp_39 = &((output)->valid);
                    (*(csharp2cuda_temp_39) = 0);
#line 290 "GeometryModule.cs"
                    break;
                }
#line 292 "GeometryModule.cs"
#line 292 "GeometryModule.cs"
                double* csharp2cuda_temp_40 = &((result)[0]);
                (*(csharp2cuda_temp_40) = 0.0);
#line 293 "GeometryModule.cs"
#line 293 "GeometryModule.cs"
                double* csharp2cuda_temp_41 = &((result)[1]);
                (*(csharp2cuda_temp_41) = 0.0);
#line 294 "GeometryModule.cs"
                {
#line 294 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 294 "GeometryModule.cs"
                        int csharp2cuda_temp_43 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_43))))
                            break;
#line 295 "GeometryModule.cs"
                        {
#line 296 "GeometryModule.cs"
#line 296 "GeometryModule.cs"
                            double* csharp2cuda_temp_44 = &((result)[0]);
#line 296 "GeometryModule.cs"
                            double csharp2cuda_temp_45 = *(csharp2cuda_temp_44);
#line 296 "GeometryModule.cs"
                            double csharp2cuda_temp_46 = (a)[csharp2cuda_i32_mul(2, index)];
                            (*(csharp2cuda_temp_44) = __dadd_rn(csharp2cuda_temp_45, csharp2cuda_temp_46));
#line 297 "GeometryModule.cs"
#line 297 "GeometryModule.cs"
                            double* csharp2cuda_temp_47 = &((result)[1]);
#line 297 "GeometryModule.cs"
                            double csharp2cuda_temp_48 = *(csharp2cuda_temp_47);
#line 297 "GeometryModule.cs"
                            double csharp2cuda_temp_49 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                            (*(csharp2cuda_temp_47) = __dadd_rn(csharp2cuda_temp_48, csharp2cuda_temp_49));
                        }
#line 294 "GeometryModule.cs"
                        int* csharp2cuda_temp_42 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_42));
                    }
                }
#line 299 "GeometryModule.cs"
#line 299 "GeometryModule.cs"
                double* csharp2cuda_temp_50 = &((result)[0]);
#line 299 "GeometryModule.cs"
                double csharp2cuda_temp_51 = *(csharp2cuda_temp_50);
#line 299 "GeometryModule.cs"
                int csharp2cuda_temp_52 = (first)->count;
                (*(csharp2cuda_temp_50) = __ddiv_rn(csharp2cuda_temp_51, ((double)(csharp2cuda_temp_52))));
#line 300 "GeometryModule.cs"
#line 300 "GeometryModule.cs"
                double* csharp2cuda_temp_53 = &((result)[1]);
#line 300 "GeometryModule.cs"
                double csharp2cuda_temp_54 = *(csharp2cuda_temp_53);
#line 300 "GeometryModule.cs"
                int csharp2cuda_temp_55 = (first)->count;
                (*(csharp2cuda_temp_53) = __ddiv_rn(csharp2cuda_temp_54, ((double)(csharp2cuda_temp_55))));
#line 301 "GeometryModule.cs"
                break;
#line 302 "GeometryModule.cs"
            case 2:
#line 303 "GeometryModule.cs"
#line 303 "GeometryModule.cs"
                int csharp2cuda_temp_56 = (first)->count;
                if (((csharp2cuda_temp_56) != (3)))
#line 304 "GeometryModule.cs"
                {
#line 305 "GeometryModule.cs"
#line 305 "GeometryModule.cs"
                    int* csharp2cuda_temp_57 = &((output)->valid);
                    (*(csharp2cuda_temp_57) = 0);
#line 306 "GeometryModule.cs"
                    break;
                }
#line 308 "GeometryModule.cs"
                {
#line 309 "GeometryModule.cs"
                    double first_length = mathblocks_geometry_distance(a, 1, a, 2);
#line 310 "GeometryModule.cs"
                    double second_length = mathblocks_geometry_distance(a, 0, a, 2);
#line 311 "GeometryModule.cs"
                    double third_length = mathblocks_geometry_distance(a, 0, a, 1);
#line 313 "GeometryModule.cs"
                    double csharp2cuda_temp_58 = (a)[0];
#line 313 "GeometryModule.cs"
                    double csharp2cuda_temp_59 = (a)[1];
#line 313 "GeometryModule.cs"
                    double csharp2cuda_temp_60 = (a)[2];
#line 313 "GeometryModule.cs"
                    double csharp2cuda_temp_61 = (a)[3];
#line 313 "GeometryModule.cs"
                    double csharp2cuda_temp_62 = (a)[4];
#line 313 "GeometryModule.cs"
                    double csharp2cuda_temp_63 = (a)[5];
#line 312 "GeometryModule.cs"
                    double cross = mathblocks_geometry_cross(csharp2cuda_temp_58, csharp2cuda_temp_59, csharp2cuda_temp_60, csharp2cuda_temp_61, csharp2cuda_temp_62, csharp2cuda_temp_63);
#line 314 "GeometryModule.cs"
#line 314 "GeometryModule.cs"
                    double* csharp2cuda_temp_64 = &((output)->scalar_value);
#line 314 "GeometryModule.cs"
                    double csharp2cuda_temp_65 = __ddiv_rn(__dmul_rn(__dmul_rn(first_length, second_length), third_length), __dmul_rn(2.0, fabs(cross)));
                    (*(csharp2cuda_temp_64) = csharp2cuda_temp_65);
#line 316 "GeometryModule.cs"
                    break;
                }
#line 318 "GeometryModule.cs"
            case 3:
#line 319 "GeometryModule.cs"
#line 319 "GeometryModule.cs"
                int csharp2cuda_temp_66 = (first)->count;
#line 319 "GeometryModule.cs"
                bool csharp2cuda_temp_67;
#line 319 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_66) < (3))))
                {
#line 319 "GeometryModule.cs"
                    int csharp2cuda_temp_68 = (second)->count;
#line 319 "GeometryModule.cs"
                    csharp2cuda_temp_67 = ((csharp2cuda_temp_68) != (1));
                }
                else
                {
#line 319 "GeometryModule.cs"
                    csharp2cuda_temp_67 = true;
                }
                if (csharp2cuda_temp_67)
#line 320 "GeometryModule.cs"
                {
#line 321 "GeometryModule.cs"
#line 321 "GeometryModule.cs"
                    int* csharp2cuda_temp_69 = &((output)->valid);
                    (*(csharp2cuda_temp_69) = 0);
#line 322 "GeometryModule.cs"
                    break;
                }
#line 324 "GeometryModule.cs"
                {
#line 325 "GeometryModule.cs"
                    bool inside = false;
#line 326 "GeometryModule.cs"
                    double point_x = (b)[0];
#line 327 "GeometryModule.cs"
                    double point_y = (b)[1];
#line 328 "GeometryModule.cs"
                    {
#line 328 "GeometryModule.cs"
                        int current = 0;
                        while (true)
                        {
#line 328 "GeometryModule.cs"
                            int csharp2cuda_temp_71 = (first)->count;
                            if (!(((current) < (csharp2cuda_temp_71))))
                                break;
#line 329 "GeometryModule.cs"
                            {
#line 330 "GeometryModule.cs"
                                int csharp2cuda_temp_72;
#line 330 "GeometryModule.cs"
                                if (((current) == (0)))
                                {
#line 330 "GeometryModule.cs"
                                    int csharp2cuda_temp_73 = (first)->count;
#line 330 "GeometryModule.cs"
                                    csharp2cuda_temp_72 = csharp2cuda_i32_sub(csharp2cuda_temp_73, 1);
                                }
                                else
                                {
#line 330 "GeometryModule.cs"
                                    csharp2cuda_temp_72 = csharp2cuda_i32_sub(current, 1);
                                }
#line 330 "GeometryModule.cs"
                                int previous = csharp2cuda_temp_72;
#line 331 "GeometryModule.cs"
                                double left_x = (a)[csharp2cuda_i32_mul(2, current)];
#line 332 "GeometryModule.cs"
                                double left_y = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, current), 1)];
#line 333 "GeometryModule.cs"
                                double right_x = (a)[csharp2cuda_i32_mul(2, previous)];
#line 334 "GeometryModule.cs"
                                double right_y = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, previous), 1)];
#line 335 "GeometryModule.cs"
                                if (((mathblocks_geometry_point_to_segment(point_x, point_y, left_x, left_y, right_x, right_y)) == (0.0)))
#line 337 "GeometryModule.cs"
                                {
#line 338 "GeometryModule.cs"
#line 338 "GeometryModule.cs"
                                    bool* csharp2cuda_temp_74 = &(inside);
                                    (*(csharp2cuda_temp_74) = true);
#line 339 "GeometryModule.cs"
                                    break;
                                }
#line 341 "GeometryModule.cs"
#line 341 "GeometryModule.cs"
                                bool csharp2cuda_temp_75;
#line 341 "GeometryModule.cs"
                                if (((((left_y) > (point_y))) != (((right_y) > (point_y)))))
                                {
#line 342 "GeometryModule.cs"
                                    double csharp2cuda_temp_76 = __ddiv_rn(__dmul_rn(__dsub_rn(right_x, left_x), __dsub_rn(point_y, left_y)), __dsub_rn(right_y, left_y));
#line 341 "GeometryModule.cs"
                                    csharp2cuda_temp_75 = ((point_x) < (__dadd_rn(csharp2cuda_temp_76, left_x)));
                                }
                                else
                                {
#line 341 "GeometryModule.cs"
                                    csharp2cuda_temp_75 = false;
                                }
                                if (csharp2cuda_temp_75)
#line 344 "GeometryModule.cs"
                                {
#line 345 "GeometryModule.cs"
#line 345 "GeometryModule.cs"
                                    bool* csharp2cuda_temp_77 = &(inside);
                                    (*(csharp2cuda_temp_77) = (!(inside)));
                                }
                            }
#line 328 "GeometryModule.cs"
                            int* csharp2cuda_temp_70 = &(current);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_70));
                        }
                    }
#line 348 "GeometryModule.cs"
#line 348 "GeometryModule.cs"
                    int* csharp2cuda_temp_78 = &((output)->boolean_value);
#line 348 "GeometryModule.cs"
                    int csharp2cuda_temp_79;
#line 348 "GeometryModule.cs"
                    if (inside)
                    {
#line 348 "GeometryModule.cs"
                        csharp2cuda_temp_79 = 1;
                    }
                    else
                    {
#line 348 "GeometryModule.cs"
                        csharp2cuda_temp_79 = 0;
                    }
                    (*(csharp2cuda_temp_78) = csharp2cuda_temp_79);
#line 349 "GeometryModule.cs"
                    break;
                }
#line 351 "GeometryModule.cs"
            case 4:
#line 352 "GeometryModule.cs"
#line 352 "GeometryModule.cs"
                int csharp2cuda_temp_80 = (first)->count;
#line 352 "GeometryModule.cs"
                bool csharp2cuda_temp_81;
#line 352 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_80) <= (0))))
                {
#line 352 "GeometryModule.cs"
                    csharp2cuda_temp_81 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 352 "GeometryModule.cs"
                    csharp2cuda_temp_81 = true;
                }
                if (csharp2cuda_temp_81)
#line 353 "GeometryModule.cs"
                {
#line 354 "GeometryModule.cs"
#line 354 "GeometryModule.cs"
                    int* csharp2cuda_temp_82 = &((output)->valid);
                    (*(csharp2cuda_temp_82) = 0);
#line 355 "GeometryModule.cs"
                    break;
                }
#line 357 "GeometryModule.cs"
                {
#line 358 "GeometryModule.cs"
                    double* sorted = scratch;
#line 359 "GeometryModule.cs"
                    int csharp2cuda_temp_83 = (first)->count;
#line 359 "GeometryModule.cs"
                    double* hull = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(csharp2cuda_temp_83, 2));
#line 360 "GeometryModule.cs"
                    int unique_count = 0;
#line 361 "GeometryModule.cs"
                    {
#line 361 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 361 "GeometryModule.cs"
                            int csharp2cuda_temp_85 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_85))))
                                break;
#line 362 "GeometryModule.cs"
                            {
#line 363 "GeometryModule.cs"
                                double x = (a)[csharp2cuda_i32_mul(2, index)];
#line 364 "GeometryModule.cs"
                                double y = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 365 "GeometryModule.cs"
                                int position = unique_count;
#line 366 "GeometryModule.cs"
                                while (true)
                                {
#line 366 "GeometryModule.cs"
                                    bool csharp2cuda_temp_86;
#line 366 "GeometryModule.cs"
                                    if (((position) > (0)))
                                    {
#line 367 "GeometryModule.cs"
                                        double csharp2cuda_temp_87 = (sorted)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(position, 1))];
#line 367 "GeometryModule.cs"
                                        bool csharp2cuda_temp_88;
#line 367 "GeometryModule.cs"
                                        if (!(((csharp2cuda_temp_87) > (x))))
                                        {
#line 368 "GeometryModule.cs"
                                            double csharp2cuda_temp_89 = (sorted)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(position, 1))];
#line 368 "GeometryModule.cs"
                                            bool csharp2cuda_temp_90;
#line 368 "GeometryModule.cs"
                                            if (((csharp2cuda_temp_89) == (x)))
                                            {
#line 369 "GeometryModule.cs"
                                                double csharp2cuda_temp_91 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(position, 1)), 1)];
#line 368 "GeometryModule.cs"
                                                csharp2cuda_temp_90 = ((csharp2cuda_temp_91) > (y));
                                            }
                                            else
                                            {
#line 368 "GeometryModule.cs"
                                                csharp2cuda_temp_90 = false;
                                            }
#line 367 "GeometryModule.cs"
                                            csharp2cuda_temp_88 = csharp2cuda_temp_90;
                                        }
                                        else
                                        {
#line 367 "GeometryModule.cs"
                                            csharp2cuda_temp_88 = true;
                                        }
#line 366 "GeometryModule.cs"
                                        csharp2cuda_temp_86 = csharp2cuda_temp_88;
                                    }
                                    else
                                    {
#line 366 "GeometryModule.cs"
                                        csharp2cuda_temp_86 = false;
                                    }
                                    if (!(csharp2cuda_temp_86))
                                        break;
#line 370 "GeometryModule.cs"
#line 370 "GeometryModule.cs"
                                    int* csharp2cuda_temp_92 = &(position);
                                    csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_92));
                                }
#line 371 "GeometryModule.cs"
#line 371 "GeometryModule.cs"
                                bool csharp2cuda_temp_93;
#line 371 "GeometryModule.cs"
                                if (((position) < (unique_count)))
                                {
#line 371 "GeometryModule.cs"
                                    double csharp2cuda_temp_94 = (sorted)[csharp2cuda_i32_mul(2, position)];
#line 371 "GeometryModule.cs"
                                    csharp2cuda_temp_93 = ((csharp2cuda_temp_94) == (x));
                                }
                                else
                                {
#line 371 "GeometryModule.cs"
                                    csharp2cuda_temp_93 = false;
                                }
#line 371 "GeometryModule.cs"
                                bool csharp2cuda_temp_95;
#line 371 "GeometryModule.cs"
                                if (csharp2cuda_temp_93)
                                {
#line 372 "GeometryModule.cs"
                                    double csharp2cuda_temp_96 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, position), 1)];
#line 371 "GeometryModule.cs"
                                    csharp2cuda_temp_95 = ((csharp2cuda_temp_96) == (y));
                                }
                                else
                                {
#line 371 "GeometryModule.cs"
                                    csharp2cuda_temp_95 = false;
                                }
                                if (csharp2cuda_temp_95)
#line 373 "GeometryModule.cs"
                                {
#line 374 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_4;
                                }
#line 376 "GeometryModule.cs"
                                {
#line 376 "GeometryModule.cs"
                                    int move = unique_count;
                                    while (true)
                                    {
                                        if (!(((move) > (position))))
                                            break;
#line 377 "GeometryModule.cs"
                                        {
#line 378 "GeometryModule.cs"
#line 378 "GeometryModule.cs"
                                            double* csharp2cuda_temp_98 = &((sorted)[csharp2cuda_i32_mul(2, move)]);
#line 378 "GeometryModule.cs"
                                            double csharp2cuda_temp_99 = (sorted)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(move, 1))];
                                            (*(csharp2cuda_temp_98) = csharp2cuda_temp_99);
#line 379 "GeometryModule.cs"
#line 379 "GeometryModule.cs"
                                            double* csharp2cuda_temp_100 = &((sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, move), 1)]);
#line 379 "GeometryModule.cs"
                                            double csharp2cuda_temp_101 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(move, 1)), 1)];
                                            (*(csharp2cuda_temp_100) = csharp2cuda_temp_101);
                                        }
#line 376 "GeometryModule.cs"
                                        int* csharp2cuda_temp_97 = &(move);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_97));
                                    }
                                }
#line 381 "GeometryModule.cs"
#line 381 "GeometryModule.cs"
                                double* csharp2cuda_temp_102 = &((sorted)[csharp2cuda_i32_mul(2, position)]);
                                (*(csharp2cuda_temp_102) = x);
#line 382 "GeometryModule.cs"
#line 382 "GeometryModule.cs"
                                double* csharp2cuda_temp_103 = &((sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, position), 1)]);
                                (*(csharp2cuda_temp_103) = y);
#line 383 "GeometryModule.cs"
#line 383 "GeometryModule.cs"
                                int* csharp2cuda_temp_104 = &(unique_count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_104));
                            }
                            csharp2cuda_for_continue_4:
#line 361 "GeometryModule.cs"
                            int* csharp2cuda_temp_84 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_84));
                        }
                    }
#line 385 "GeometryModule.cs"
                    int count = 0;
#line 386 "GeometryModule.cs"
                    if (((unique_count) <= (1)))
#line 387 "GeometryModule.cs"
                    {
#line 388 "GeometryModule.cs"
#line 388 "GeometryModule.cs"
                        int* csharp2cuda_temp_105 = &(count);
                        (*(csharp2cuda_temp_105) = unique_count);
#line 389 "GeometryModule.cs"
                        if (((count) == (1)))
#line 390 "GeometryModule.cs"
                        {
#line 391 "GeometryModule.cs"
#line 391 "GeometryModule.cs"
                            double* csharp2cuda_temp_106 = &((hull)[0]);
#line 391 "GeometryModule.cs"
                            double csharp2cuda_temp_107 = (sorted)[0];
                            (*(csharp2cuda_temp_106) = csharp2cuda_temp_107);
#line 392 "GeometryModule.cs"
#line 392 "GeometryModule.cs"
                            double* csharp2cuda_temp_108 = &((hull)[1]);
#line 392 "GeometryModule.cs"
                            double csharp2cuda_temp_109 = (sorted)[1];
                            (*(csharp2cuda_temp_108) = csharp2cuda_temp_109);
                        }
                    }
                    else
#line 396 "GeometryModule.cs"
                    {
#line 397 "GeometryModule.cs"
                        {
#line 397 "GeometryModule.cs"
                            int index = 0;
                            while (true)
                            {
                                if (!(((index) < (unique_count))))
                                    break;
#line 398 "GeometryModule.cs"
                                {
#line 399 "GeometryModule.cs"
                                    while (true)
                                    {
#line 399 "GeometryModule.cs"
                                        bool csharp2cuda_temp_111;
#line 399 "GeometryModule.cs"
                                        if (((count) >= (2)))
                                        {
#line 400 "GeometryModule.cs"
                                            double csharp2cuda_temp_112 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2))];
#line 400 "GeometryModule.cs"
                                            double csharp2cuda_temp_113 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2)), 1)];
#line 401 "GeometryModule.cs"
                                            double csharp2cuda_temp_114 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1))];
#line 401 "GeometryModule.cs"
                                            double csharp2cuda_temp_115 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1)), 1)];
#line 402 "GeometryModule.cs"
                                            double csharp2cuda_temp_116 = (sorted)[csharp2cuda_i32_mul(2, index)];
#line 402 "GeometryModule.cs"
                                            double csharp2cuda_temp_117 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 399 "GeometryModule.cs"
                                            csharp2cuda_temp_111 = ((mathblocks_geometry_cross(csharp2cuda_temp_112, csharp2cuda_temp_113, csharp2cuda_temp_114, csharp2cuda_temp_115, csharp2cuda_temp_116, csharp2cuda_temp_117)) <= (0.0));
                                        }
                                        else
                                        {
#line 399 "GeometryModule.cs"
                                            csharp2cuda_temp_111 = false;
                                        }
                                        if (!(csharp2cuda_temp_111))
                                            break;
#line 403 "GeometryModule.cs"
                                        {
#line 404 "GeometryModule.cs"
#line 404 "GeometryModule.cs"
                                            int* csharp2cuda_temp_118 = &(count);
                                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_118));
                                        }
                                    }
#line 406 "GeometryModule.cs"
#line 406 "GeometryModule.cs"
                                    double* csharp2cuda_temp_119 = &((hull)[csharp2cuda_i32_mul(2, count)]);
#line 406 "GeometryModule.cs"
                                    double csharp2cuda_temp_120 = (sorted)[csharp2cuda_i32_mul(2, index)];
                                    (*(csharp2cuda_temp_119) = csharp2cuda_temp_120);
#line 407 "GeometryModule.cs"
#line 407 "GeometryModule.cs"
                                    double* csharp2cuda_temp_121 = &((hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, count), 1)]);
#line 407 "GeometryModule.cs"
                                    double csharp2cuda_temp_122 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                    (*(csharp2cuda_temp_121) = csharp2cuda_temp_122);
#line 408 "GeometryModule.cs"
#line 408 "GeometryModule.cs"
                                    int* csharp2cuda_temp_123 = &(count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_123));
                                }
#line 397 "GeometryModule.cs"
                                int* csharp2cuda_temp_110 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_110));
                            }
                        }
#line 410 "GeometryModule.cs"
                        int lower_count = count;
#line 411 "GeometryModule.cs"
                        {
#line 411 "GeometryModule.cs"
                            int index = csharp2cuda_i32_sub(unique_count, 2);
                            while (true)
                            {
                                if (!(((index) >= (0))))
                                    break;
#line 412 "GeometryModule.cs"
                                {
#line 413 "GeometryModule.cs"
                                    while (true)
                                    {
#line 413 "GeometryModule.cs"
                                        bool csharp2cuda_temp_125;
#line 413 "GeometryModule.cs"
                                        if (((count) > (lower_count)))
                                        {
#line 414 "GeometryModule.cs"
                                            double csharp2cuda_temp_126 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2))];
#line 414 "GeometryModule.cs"
                                            double csharp2cuda_temp_127 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2)), 1)];
#line 415 "GeometryModule.cs"
                                            double csharp2cuda_temp_128 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1))];
#line 415 "GeometryModule.cs"
                                            double csharp2cuda_temp_129 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1)), 1)];
#line 416 "GeometryModule.cs"
                                            double csharp2cuda_temp_130 = (sorted)[csharp2cuda_i32_mul(2, index)];
#line 416 "GeometryModule.cs"
                                            double csharp2cuda_temp_131 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 413 "GeometryModule.cs"
                                            csharp2cuda_temp_125 = ((mathblocks_geometry_cross(csharp2cuda_temp_126, csharp2cuda_temp_127, csharp2cuda_temp_128, csharp2cuda_temp_129, csharp2cuda_temp_130, csharp2cuda_temp_131)) <= (0.0));
                                        }
                                        else
                                        {
#line 413 "GeometryModule.cs"
                                            csharp2cuda_temp_125 = false;
                                        }
                                        if (!(csharp2cuda_temp_125))
                                            break;
#line 417 "GeometryModule.cs"
                                        {
#line 418 "GeometryModule.cs"
#line 418 "GeometryModule.cs"
                                            int* csharp2cuda_temp_132 = &(count);
                                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_132));
                                        }
                                    }
#line 420 "GeometryModule.cs"
#line 420 "GeometryModule.cs"
                                    double* csharp2cuda_temp_133 = &((hull)[csharp2cuda_i32_mul(2, count)]);
#line 420 "GeometryModule.cs"
                                    double csharp2cuda_temp_134 = (sorted)[csharp2cuda_i32_mul(2, index)];
                                    (*(csharp2cuda_temp_133) = csharp2cuda_temp_134);
#line 421 "GeometryModule.cs"
#line 421 "GeometryModule.cs"
                                    double* csharp2cuda_temp_135 = &((hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, count), 1)]);
#line 421 "GeometryModule.cs"
                                    double csharp2cuda_temp_136 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                    (*(csharp2cuda_temp_135) = csharp2cuda_temp_136);
#line 422 "GeometryModule.cs"
#line 422 "GeometryModule.cs"
                                    int* csharp2cuda_temp_137 = &(count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_137));
                                }
#line 411 "GeometryModule.cs"
                                int* csharp2cuda_temp_124 = &(index);
                                csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_124));
                            }
                        }
#line 424 "GeometryModule.cs"
#line 424 "GeometryModule.cs"
                        int* csharp2cuda_temp_138 = &(count);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_138));
                    }
#line 426 "GeometryModule.cs"
#line 426 "GeometryModule.cs"
                    int* csharp2cuda_temp_139 = &((output)->rows);
                    (*(csharp2cuda_temp_139) = count);
#line 427 "GeometryModule.cs"
#line 427 "GeometryModule.cs"
                    int* csharp2cuda_temp_140 = &((output)->count);
                    (*(csharp2cuda_temp_140) = count);
#line 428 "GeometryModule.cs"
#line 428 "GeometryModule.cs"
                    int csharp2cuda_temp_141 = (output)->capacity;
                    if (((count) > (csharp2cuda_temp_141)))
#line 429 "GeometryModule.cs"
                    {
#line 430 "GeometryModule.cs"
#line 430 "GeometryModule.cs"
                        int* csharp2cuda_temp_142 = &((output)->valid);
                        (*(csharp2cuda_temp_142) = 0);
#line 431 "GeometryModule.cs"
                        break;
                    }
#line 433 "GeometryModule.cs"
                    {
#line 433 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(count, 2)))))
                                break;
#line 434 "GeometryModule.cs"
#line 434 "GeometryModule.cs"
                            double* csharp2cuda_temp_144 = &((result)[index]);
#line 434 "GeometryModule.cs"
                            double csharp2cuda_temp_145 = (hull)[index];
                            (*(csharp2cuda_temp_144) = csharp2cuda_temp_145);
#line 433 "GeometryModule.cs"
                            int* csharp2cuda_temp_143 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_143));
                        }
                    }
#line 435 "GeometryModule.cs"
                    break;
                }
#line 437 "GeometryModule.cs"
            case 5:
#line 438 "GeometryModule.cs"
#line 438 "GeometryModule.cs"
                int csharp2cuda_temp_146 = (first)->count;
#line 438 "GeometryModule.cs"
                bool csharp2cuda_temp_147;
#line 438 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_146) < (2))))
                {
#line 438 "GeometryModule.cs"
                    csharp2cuda_temp_147 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 438 "GeometryModule.cs"
                    csharp2cuda_temp_147 = true;
                }
                if (csharp2cuda_temp_147)
#line 439 "GeometryModule.cs"
                {
#line 440 "GeometryModule.cs"
#line 440 "GeometryModule.cs"
                    int* csharp2cuda_temp_148 = &((output)->valid);
                    (*(csharp2cuda_temp_148) = 0);
#line 441 "GeometryModule.cs"
                    break;
                }
#line 443 "GeometryModule.cs"
                {
#line 444 "GeometryModule.cs"
                    int count = (first)->count;
#line 445 "GeometryModule.cs"
                    int* adjacency = ((int*)(scratch));
#line 446 "GeometryModule.cs"
                    int* ordered = csharp2cuda_pointer_add(adjacency, csharp2cuda_i32_mul(count, count));
#line 447 "GeometryModule.cs"
                    {
#line 447 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(count, count)))))
                                break;
#line 448 "GeometryModule.cs"
#line 448 "GeometryModule.cs"
                            int* csharp2cuda_temp_150 = &((adjacency)[index]);
                            (*(csharp2cuda_temp_150) = 0);
#line 447 "GeometryModule.cs"
                            int* csharp2cuda_temp_149 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_149));
                        }
                    }
#line 449 "GeometryModule.cs"
                    {
#line 449 "GeometryModule.cs"
                        int first_index = 0;
                        while (true)
                        {
                            if (!(((first_index) < (count))))
                                break;
#line 450 "GeometryModule.cs"
                            {
#line 451 "GeometryModule.cs"
                                {
#line 451 "GeometryModule.cs"
                                    int second_index = csharp2cuda_i32_add(first_index, 1);
                                    while (true)
                                    {
                                        if (!(((second_index) < (count))))
                                            break;
#line 452 "GeometryModule.cs"
                                        {
#line 453 "GeometryModule.cs"
                                            {
#line 453 "GeometryModule.cs"
                                                int third_index = csharp2cuda_i32_add(second_index, 1);
                                                while (true)
                                                {
                                                    if (!(((third_index) < (count))))
                                                        break;
#line 454 "GeometryModule.cs"
                                                    {
#line 455 "GeometryModule.cs"
                                                        double center_x;
#line 456 "GeometryModule.cs"
                                                        double center_y;
#line 457 "GeometryModule.cs"
                                                        double radius_square;
#line 458 "GeometryModule.cs"
#line 460 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_154 = &(center_x);
#line 460 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_155 = &(center_y);
#line 460 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_156 = &(radius_square);
#line 458 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_157 = mathblocks_geometry_try_circumcircle(a, first_index, second_index, third_index, csharp2cuda_temp_154, csharp2cuda_temp_155, csharp2cuda_temp_156);
                                                        if ((!(csharp2cuda_temp_157)))
#line 461 "GeometryModule.cs"
                                                        {
#line 462 "GeometryModule.cs"
                                                            goto csharp2cuda_for_continue_10;
                                                        }
#line 464 "GeometryModule.cs"
                                                        bool empty = true;
#line 465 "GeometryModule.cs"
                                                        {
#line 465 "GeometryModule.cs"
                                                            int index = 0;
                                                            while (true)
                                                            {
                                                                if (!(((index) < (count))))
                                                                    break;
#line 466 "GeometryModule.cs"
                                                                {
#line 467 "GeometryModule.cs"
#line 467 "GeometryModule.cs"
                                                                    bool csharp2cuda_temp_159;
#line 467 "GeometryModule.cs"
                                                                    if (!(((index) == (first_index))))
                                                                    {
#line 467 "GeometryModule.cs"
                                                                        csharp2cuda_temp_159 = ((index) == (second_index));
                                                                    }
                                                                    else
                                                                    {
#line 467 "GeometryModule.cs"
                                                                        csharp2cuda_temp_159 = true;
                                                                    }
#line 467 "GeometryModule.cs"
                                                                    bool csharp2cuda_temp_160;
#line 467 "GeometryModule.cs"
                                                                    if (!(csharp2cuda_temp_159))
                                                                    {
#line 467 "GeometryModule.cs"
                                                                        csharp2cuda_temp_160 = ((index) == (third_index));
                                                                    }
                                                                    else
                                                                    {
#line 467 "GeometryModule.cs"
                                                                        csharp2cuda_temp_160 = true;
                                                                    }
                                                                    if (csharp2cuda_temp_160)
                                                                    {
#line 468 "GeometryModule.cs"
                                                                        goto csharp2cuda_for_continue_9;
                                                                    }
#line 469 "GeometryModule.cs"
                                                                    double csharp2cuda_temp_161 = (a)[csharp2cuda_i32_mul(2, index)];
#line 469 "GeometryModule.cs"
                                                                    double x = __dsub_rn(csharp2cuda_temp_161, center_x);
#line 470 "GeometryModule.cs"
                                                                    double csharp2cuda_temp_162 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 470 "GeometryModule.cs"
                                                                    double y = __dsub_rn(csharp2cuda_temp_162, center_y);
#line 471 "GeometryModule.cs"
                                                                    if (((__dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y))) < (radius_square)))
#line 472 "GeometryModule.cs"
                                                                    {
#line 473 "GeometryModule.cs"
#line 473 "GeometryModule.cs"
                                                                        bool* csharp2cuda_temp_163 = &(empty);
                                                                        (*(csharp2cuda_temp_163) = false);
#line 474 "GeometryModule.cs"
                                                                        break;
                                                                    }
                                                                }
                                                                csharp2cuda_for_continue_9:
#line 465 "GeometryModule.cs"
                                                                int* csharp2cuda_temp_158 = &(index);
                                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_158));
                                                            }
                                                        }
#line 477 "GeometryModule.cs"
                                                        if ((!(empty)))
                                                        {
#line 478 "GeometryModule.cs"
                                                            goto csharp2cuda_for_continue_10;
                                                        }
#line 479 "GeometryModule.cs"
#line 479 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_164 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, count), second_index)]);
                                                        (*(csharp2cuda_temp_164) = 1);
#line 480 "GeometryModule.cs"
#line 480 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_165 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, count), third_index)]);
                                                        (*(csharp2cuda_temp_165) = 1);
#line 481 "GeometryModule.cs"
#line 481 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_166 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(second_index, count), third_index)]);
                                                        (*(csharp2cuda_temp_166) = 1);
                                                    }
                                                    csharp2cuda_for_continue_10:
#line 453 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_153 = &(third_index);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_153));
                                                }
                                            }
                                        }
#line 451 "GeometryModule.cs"
                                        int* csharp2cuda_temp_152 = &(second_index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_152));
                                    }
                                }
                            }
#line 449 "GeometryModule.cs"
                            int* csharp2cuda_temp_151 = &(first_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_151));
                        }
                    }
#line 485 "GeometryModule.cs"
                    int edge_count = 0;
#line 486 "GeometryModule.cs"
                    {
#line 486 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (count))))
                                break;
#line 487 "GeometryModule.cs"
                            {
#line 487 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
                                    if (!(((right) < (count))))
                                        break;
#line 488 "GeometryModule.cs"
#line 488 "GeometryModule.cs"
                                    int* csharp2cuda_temp_169 = &(edge_count);
#line 488 "GeometryModule.cs"
                                    int csharp2cuda_temp_170 = *(csharp2cuda_temp_169);
#line 488 "GeometryModule.cs"
                                    int csharp2cuda_temp_171 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)];
                                    (*(csharp2cuda_temp_169) = csharp2cuda_i32_add(csharp2cuda_temp_170, csharp2cuda_temp_171));
#line 487 "GeometryModule.cs"
                                    int* csharp2cuda_temp_168 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_168));
                                }
                            }
#line 486 "GeometryModule.cs"
                            int* csharp2cuda_temp_167 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_167));
                        }
                    }
#line 489 "GeometryModule.cs"
                    if (((edge_count) == (0)))
#line 490 "GeometryModule.cs"
                    {
#line 491 "GeometryModule.cs"
                        mathblocks_geometry_sort_indices(a, count, ordered);
#line 492 "GeometryModule.cs"
                        {
#line 492 "GeometryModule.cs"
                            int index = 1;
                            while (true)
                            {
                                if (!(((index) < (count))))
                                    break;
#line 493 "GeometryModule.cs"
                                {
#line 494 "GeometryModule.cs"
                                    int csharp2cuda_temp_173 = (ordered)[csharp2cuda_i32_sub(index, 1)];
#line 494 "GeometryModule.cs"
                                    int csharp2cuda_temp_174 = (ordered)[index];
#line 494 "GeometryModule.cs"
                                    int csharp2cuda_temp_175;
#line 494 "GeometryModule.cs"
                                    if (((csharp2cuda_temp_173) < (csharp2cuda_temp_174)))
                                    {
#line 494 "GeometryModule.cs"
                                        csharp2cuda_temp_175 = (ordered)[csharp2cuda_i32_sub(index, 1)];
                                    }
                                    else
                                    {
#line 494 "GeometryModule.cs"
                                        csharp2cuda_temp_175 = (ordered)[index];
                                    }
#line 494 "GeometryModule.cs"
                                    int left = csharp2cuda_temp_175;
#line 497 "GeometryModule.cs"
                                    int csharp2cuda_temp_176 = (ordered)[csharp2cuda_i32_sub(index, 1)];
#line 497 "GeometryModule.cs"
                                    int csharp2cuda_temp_177 = (ordered)[index];
#line 497 "GeometryModule.cs"
                                    int csharp2cuda_temp_178;
#line 497 "GeometryModule.cs"
                                    if (((csharp2cuda_temp_176) < (csharp2cuda_temp_177)))
                                    {
#line 497 "GeometryModule.cs"
                                        csharp2cuda_temp_178 = (ordered)[index];
                                    }
                                    else
                                    {
#line 497 "GeometryModule.cs"
                                        csharp2cuda_temp_178 = (ordered)[csharp2cuda_i32_sub(index, 1)];
                                    }
#line 497 "GeometryModule.cs"
                                    int right = csharp2cuda_temp_178;
#line 500 "GeometryModule.cs"
#line 500 "GeometryModule.cs"
                                    int* csharp2cuda_temp_179 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)]);
                                    (*(csharp2cuda_temp_179) = 1);
                                }
#line 492 "GeometryModule.cs"
                                int* csharp2cuda_temp_172 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_172));
                            }
                        }
                    }
#line 503 "GeometryModule.cs"
                    unsigned long long csharp2cuda_temp_180 = (output)->data_pointer;
#line 503 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(csharp2cuda_temp_180));
#line 504 "GeometryModule.cs"
#line 504 "GeometryModule.cs"
                    int* csharp2cuda_temp_181 = &(edge_count);
                    (*(csharp2cuda_temp_181) = 0);
#line 505 "GeometryModule.cs"
                    {
#line 505 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (count))))
                                break;
#line 506 "GeometryModule.cs"
                            {
#line 507 "GeometryModule.cs"
                                {
#line 507 "GeometryModule.cs"
                                    int right = csharp2cuda_i32_add(left, 1);
                                    while (true)
                                    {
                                        if (!(((right) < (count))))
                                            break;
#line 508 "GeometryModule.cs"
                                        {
#line 509 "GeometryModule.cs"
#line 509 "GeometryModule.cs"
                                            int csharp2cuda_temp_184 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)];
                                            if ((!(((csharp2cuda_temp_184) != 0))))
                                            {
#line 510 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_16;
                                            }
#line 511 "GeometryModule.cs"
#line 511 "GeometryModule.cs"
                                            int csharp2cuda_temp_185 = (output)->capacity;
                                            if (((edge_count) >= (csharp2cuda_temp_185)))
#line 512 "GeometryModule.cs"
                                            {
#line 513 "GeometryModule.cs"
#line 513 "GeometryModule.cs"
                                                int* csharp2cuda_temp_186 = &((output)->count);
#line 513 "GeometryModule.cs"
                                                int csharp2cuda_temp_187 = (output)->capacity;
#line 513 "GeometryModule.cs"
                                                int csharp2cuda_temp_188;
#line 513 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_187) == (2147483647)))
                                                {
#line 513 "GeometryModule.cs"
                                                    csharp2cuda_temp_188 = csharp2cuda_i32_neg(1);
                                                }
                                                else
                                                {
#line 515 "GeometryModule.cs"
                                                    int csharp2cuda_temp_189 = (output)->capacity;
#line 513 "GeometryModule.cs"
                                                    csharp2cuda_temp_188 = csharp2cuda_i32_add(csharp2cuda_temp_189, 1);
                                                }
                                                (*(csharp2cuda_temp_186) = csharp2cuda_temp_188);
#line 516 "GeometryModule.cs"
#line 516 "GeometryModule.cs"
                                                int* csharp2cuda_temp_190 = &((output)->valid);
                                                (*(csharp2cuda_temp_190) = 0);
#line 517 "GeometryModule.cs"
                                                break;
                                            }
#line 519 "GeometryModule.cs"
#line 519 "GeometryModule.cs"
                                            int* csharp2cuda_temp_191 = &(((edges)[edge_count]).from);
                                            (*(csharp2cuda_temp_191) = left);
#line 520 "GeometryModule.cs"
#line 520 "GeometryModule.cs"
                                            int* csharp2cuda_temp_192 = &(((edges)[edge_count]).to);
                                            (*(csharp2cuda_temp_192) = right);
#line 521 "GeometryModule.cs"
#line 521 "GeometryModule.cs"
                                            double* csharp2cuda_temp_193 = &(((edges)[edge_count]).weight);
#line 521 "GeometryModule.cs"
                                            double csharp2cuda_temp_194 = mathblocks_geometry_distance(a, left, a, right);
                                            (*(csharp2cuda_temp_193) = csharp2cuda_temp_194);
#line 522 "GeometryModule.cs"
#line 522 "GeometryModule.cs"
                                            int* csharp2cuda_temp_195 = &(edge_count);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_195));
                                        }
                                        csharp2cuda_for_continue_16:
#line 507 "GeometryModule.cs"
                                        int* csharp2cuda_temp_183 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_183));
                                    }
                                }
                            }
#line 505 "GeometryModule.cs"
                            int* csharp2cuda_temp_182 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_182));
                        }
                    }
#line 525 "GeometryModule.cs"
#line 525 "GeometryModule.cs"
                    int* csharp2cuda_temp_196 = &((output)->rows);
                    (*(csharp2cuda_temp_196) = count);
#line 526 "GeometryModule.cs"
                    if ((output)->valid)
                    {
#line 527 "GeometryModule.cs"
#line 527 "GeometryModule.cs"
                        int* csharp2cuda_temp_197 = &((output)->count);
                        (*(csharp2cuda_temp_197) = edge_count);
                    }
#line 528 "GeometryModule.cs"
                    break;
                }
#line 530 "GeometryModule.cs"
            case 6:
#line 531 "GeometryModule.cs"
#line 531 "GeometryModule.cs"
                int csharp2cuda_temp_198 = (first)->count;
                if (((csharp2cuda_temp_198) <= (0)))
#line 532 "GeometryModule.cs"
                {
#line 533 "GeometryModule.cs"
#line 533 "GeometryModule.cs"
                    int* csharp2cuda_temp_199 = &((output)->valid);
                    (*(csharp2cuda_temp_199) = 0);
#line 534 "GeometryModule.cs"
                    break;
                }
#line 536 "GeometryModule.cs"
                {
#line 537 "GeometryModule.cs"
                    double maximum = 0.0;
#line 538 "GeometryModule.cs"
                    {
#line 538 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 538 "GeometryModule.cs"
                            int csharp2cuda_temp_201 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_201))))
                                break;
#line 539 "GeometryModule.cs"
                            {
#line 539 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
#line 539 "GeometryModule.cs"
                                    int csharp2cuda_temp_203 = (first)->count;
                                    if (!(((right) < (csharp2cuda_temp_203))))
                                        break;
#line 540 "GeometryModule.cs"
                                    {
#line 541 "GeometryModule.cs"
                                        double distance = mathblocks_geometry_distance(a, left, a, right);
#line 542 "GeometryModule.cs"
#line 542 "GeometryModule.cs"
                                        double* csharp2cuda_temp_204 = &(maximum);
#line 542 "GeometryModule.cs"
                                        double csharp2cuda_temp_205;
#line 542 "GeometryModule.cs"
                                        if (((maximum) > (distance)))
                                        {
#line 542 "GeometryModule.cs"
                                            csharp2cuda_temp_205 = maximum;
                                        }
                                        else
                                        {
#line 542 "GeometryModule.cs"
                                            csharp2cuda_temp_205 = distance;
                                        }
                                        (*(csharp2cuda_temp_204) = csharp2cuda_temp_205);
                                    }
#line 539 "GeometryModule.cs"
                                    int* csharp2cuda_temp_202 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_202));
                                }
                            }
#line 538 "GeometryModule.cs"
                            int* csharp2cuda_temp_200 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_200));
                        }
                    }
#line 544 "GeometryModule.cs"
#line 544 "GeometryModule.cs"
                    double* csharp2cuda_temp_206 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_206) = maximum);
#line 545 "GeometryModule.cs"
                    break;
                }
#line 547 "GeometryModule.cs"
            case 7:
#line 548 "GeometryModule.cs"
#line 548 "GeometryModule.cs"
                int csharp2cuda_temp_207 = (first)->count;
#line 548 "GeometryModule.cs"
                bool csharp2cuda_temp_208;
#line 548 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_207) <= (0))))
                {
#line 548 "GeometryModule.cs"
                    int csharp2cuda_temp_209 = (second)->count;
#line 548 "GeometryModule.cs"
                    csharp2cuda_temp_208 = ((csharp2cuda_temp_209) <= (0));
                }
                else
                {
#line 548 "GeometryModule.cs"
                    csharp2cuda_temp_208 = true;
                }
#line 548 "GeometryModule.cs"
                bool csharp2cuda_temp_210;
#line 548 "GeometryModule.cs"
                if (!(csharp2cuda_temp_208))
                {
#line 548 "GeometryModule.cs"
                    csharp2cuda_temp_210 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 548 "GeometryModule.cs"
                    csharp2cuda_temp_210 = true;
                }
                if (csharp2cuda_temp_210)
#line 549 "GeometryModule.cs"
                {
#line 550 "GeometryModule.cs"
#line 550 "GeometryModule.cs"
                    int* csharp2cuda_temp_211 = &((output)->valid);
                    (*(csharp2cuda_temp_211) = 0);
#line 551 "GeometryModule.cs"
                    break;
                }
#line 553 "GeometryModule.cs"
                {
#line 554 "GeometryModule.cs"
                    {
#line 554 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 554 "GeometryModule.cs"
                            int csharp2cuda_temp_213 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_213))))
                                break;
#line 555 "GeometryModule.cs"
                            {
#line 556 "GeometryModule.cs"
                                {
#line 556 "GeometryModule.cs"
                                    int right = 0;
                                    while (true)
                                    {
#line 556 "GeometryModule.cs"
                                        int csharp2cuda_temp_215 = (second)->count;
                                        if (!(((right) < (csharp2cuda_temp_215))))
                                            break;
#line 557 "GeometryModule.cs"
                                        {
#line 558 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(a, left, b, right);
#line 559 "GeometryModule.cs"
                                            int csharp2cuda_temp_216 = (second)->count;
#line 559 "GeometryModule.cs"
                                            int target = csharp2cuda_i32_add(csharp2cuda_i32_mul(left, csharp2cuda_temp_216), right);
#line 560 "GeometryModule.cs"
#line 560 "GeometryModule.cs"
                                            bool csharp2cuda_temp_217;
#line 560 "GeometryModule.cs"
                                            if (((left) == (0)))
                                            {
#line 560 "GeometryModule.cs"
                                                csharp2cuda_temp_217 = ((right) == (0));
                                            }
                                            else
                                            {
#line 560 "GeometryModule.cs"
                                                csharp2cuda_temp_217 = false;
                                            }
                                            if (csharp2cuda_temp_217)
                                            {
#line 561 "GeometryModule.cs"
#line 561 "GeometryModule.cs"
                                                double* csharp2cuda_temp_218 = &((scratch)[0]);
                                                (*(csharp2cuda_temp_218) = distance);
                                            }
                                            else
                                            {
#line 562 "GeometryModule.cs"
                                                if (((left) == (0)))
                                                {
#line 563 "GeometryModule.cs"
#line 563 "GeometryModule.cs"
                                                    double* csharp2cuda_temp_219 = &((scratch)[right]);
#line 563 "GeometryModule.cs"
                                                    double csharp2cuda_temp_220 = (scratch)[csharp2cuda_i32_sub(right, 1)];
#line 563 "GeometryModule.cs"
                                                    double csharp2cuda_temp_221;
#line 563 "GeometryModule.cs"
                                                    if (((csharp2cuda_temp_220) > (distance)))
                                                    {
#line 563 "GeometryModule.cs"
                                                        csharp2cuda_temp_221 = (scratch)[csharp2cuda_i32_sub(right, 1)];
                                                    }
                                                    else
                                                    {
#line 563 "GeometryModule.cs"
                                                        csharp2cuda_temp_221 = distance;
                                                    }
                                                    (*(csharp2cuda_temp_219) = csharp2cuda_temp_221);
                                                }
                                                else
                                                {
#line 566 "GeometryModule.cs"
                                                    if (((right) == (0)))
                                                    {
#line 567 "GeometryModule.cs"
#line 567 "GeometryModule.cs"
                                                        int csharp2cuda_temp_222 = (second)->count;
#line 567 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_223 = &((scratch)[csharp2cuda_i32_mul(left, csharp2cuda_temp_222)]);
#line 567 "GeometryModule.cs"
                                                        int csharp2cuda_temp_224 = (second)->count;
#line 567 "GeometryModule.cs"
                                                        double csharp2cuda_temp_225 = (scratch)[csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_224)];
#line 567 "GeometryModule.cs"
                                                        double csharp2cuda_temp_226;
#line 567 "GeometryModule.cs"
                                                        if (((csharp2cuda_temp_225) > (distance)))
                                                        {
#line 568 "GeometryModule.cs"
                                                            int csharp2cuda_temp_227 = (second)->count;
#line 567 "GeometryModule.cs"
                                                            csharp2cuda_temp_226 = (scratch)[csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_227)];
                                                        }
                                                        else
                                                        {
#line 567 "GeometryModule.cs"
                                                            csharp2cuda_temp_226 = distance;
                                                        }
                                                        (*(csharp2cuda_temp_223) = csharp2cuda_temp_226);
                                                    }
                                                    else
#line 571 "GeometryModule.cs"
                                                    {
#line 572 "GeometryModule.cs"
                                                        int csharp2cuda_temp_228 = (second)->count;
#line 572 "GeometryModule.cs"
                                                        double preceding = (scratch)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_228), right)];
#line 573 "GeometryModule.cs"
                                                        int csharp2cuda_temp_229 = (second)->count;
#line 573 "GeometryModule.cs"
                                                        double candidate = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_229), right), 1)];
#line 574 "GeometryModule.cs"
#line 574 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_230 = &(preceding);
#line 574 "GeometryModule.cs"
                                                        double csharp2cuda_temp_231;
#line 574 "GeometryModule.cs"
                                                        if (((preceding) < (candidate)))
                                                        {
#line 574 "GeometryModule.cs"
                                                            csharp2cuda_temp_231 = preceding;
                                                        }
                                                        else
                                                        {
#line 574 "GeometryModule.cs"
                                                            csharp2cuda_temp_231 = candidate;
                                                        }
                                                        (*(csharp2cuda_temp_230) = csharp2cuda_temp_231);
#line 575 "GeometryModule.cs"
#line 575 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_232 = &(candidate);
#line 575 "GeometryModule.cs"
                                                        int csharp2cuda_temp_233 = (second)->count;
#line 575 "GeometryModule.cs"
                                                        double csharp2cuda_temp_234 = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(left, csharp2cuda_temp_233), right), 1)];
                                                        (*(csharp2cuda_temp_232) = csharp2cuda_temp_234);
#line 576 "GeometryModule.cs"
#line 576 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_235 = &(preceding);
#line 576 "GeometryModule.cs"
                                                        double csharp2cuda_temp_236;
#line 576 "GeometryModule.cs"
                                                        if (((preceding) < (candidate)))
                                                        {
#line 576 "GeometryModule.cs"
                                                            csharp2cuda_temp_236 = preceding;
                                                        }
                                                        else
                                                        {
#line 576 "GeometryModule.cs"
                                                            csharp2cuda_temp_236 = candidate;
                                                        }
                                                        (*(csharp2cuda_temp_235) = csharp2cuda_temp_236);
#line 577 "GeometryModule.cs"
#line 577 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_237 = &((scratch)[target]);
#line 577 "GeometryModule.cs"
                                                        double csharp2cuda_temp_238;
#line 577 "GeometryModule.cs"
                                                        if (((preceding) > (distance)))
                                                        {
#line 577 "GeometryModule.cs"
                                                            csharp2cuda_temp_238 = preceding;
                                                        }
                                                        else
                                                        {
#line 577 "GeometryModule.cs"
                                                            csharp2cuda_temp_238 = distance;
                                                        }
                                                        (*(csharp2cuda_temp_237) = csharp2cuda_temp_238);
                                                    }
                                                }
                                            }
                                        }
#line 556 "GeometryModule.cs"
                                        int* csharp2cuda_temp_214 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_214));
                                    }
                                }
                            }
#line 554 "GeometryModule.cs"
                            int* csharp2cuda_temp_212 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_212));
                        }
                    }
#line 581 "GeometryModule.cs"
#line 581 "GeometryModule.cs"
                    double* csharp2cuda_temp_239 = &((output)->scalar_value);
#line 581 "GeometryModule.cs"
                    int csharp2cuda_temp_240 = (first)->count;
#line 581 "GeometryModule.cs"
                    int csharp2cuda_temp_241 = (second)->count;
#line 581 "GeometryModule.cs"
                    double csharp2cuda_temp_242 = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_mul(csharp2cuda_temp_240, csharp2cuda_temp_241), 1)];
                    (*(csharp2cuda_temp_239) = csharp2cuda_temp_242);
#line 582 "GeometryModule.cs"
                    break;
                }
#line 584 "GeometryModule.cs"
            case 8:
#line 585 "GeometryModule.cs"
#line 585 "GeometryModule.cs"
                int csharp2cuda_temp_243 = (first)->count;
#line 585 "GeometryModule.cs"
                bool csharp2cuda_temp_244;
#line 585 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_243) <= (0))))
                {
#line 585 "GeometryModule.cs"
                    int csharp2cuda_temp_245 = (second)->count;
#line 585 "GeometryModule.cs"
                    csharp2cuda_temp_244 = ((csharp2cuda_temp_245) <= (0));
                }
                else
                {
#line 585 "GeometryModule.cs"
                    csharp2cuda_temp_244 = true;
                }
                if (csharp2cuda_temp_244)
                {
#line 586 "GeometryModule.cs"
#line 586 "GeometryModule.cs"
                    int* csharp2cuda_temp_246 = &((output)->valid);
                    (*(csharp2cuda_temp_246) = 0);
                }
                else
                {
#line 588 "GeometryModule.cs"
#line 588 "GeometryModule.cs"
                    double* csharp2cuda_temp_247 = &((output)->scalar_value);
#line 588 "GeometryModule.cs"
                    double csharp2cuda_temp_248 = mathblocks_geometry_distance(a, 0, b, 0);
                    (*(csharp2cuda_temp_247) = csharp2cuda_temp_248);
                }
#line 589 "GeometryModule.cs"
                break;
#line 590 "GeometryModule.cs"
            case 9:
#line 591 "GeometryModule.cs"
#line 591 "GeometryModule.cs"
                int csharp2cuda_temp_249 = (first)->count;
#line 591 "GeometryModule.cs"
                bool csharp2cuda_temp_250;
#line 591 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_249) <= (0))))
                {
#line 591 "GeometryModule.cs"
                    int csharp2cuda_temp_251 = (first)->count;
#line 591 "GeometryModule.cs"
                    int csharp2cuda_temp_252 = (second)->count;
#line 591 "GeometryModule.cs"
                    csharp2cuda_temp_250 = ((csharp2cuda_temp_251) != (csharp2cuda_temp_252));
                }
                else
                {
#line 591 "GeometryModule.cs"
                    csharp2cuda_temp_250 = true;
                }
                if (csharp2cuda_temp_250)
#line 592 "GeometryModule.cs"
                {
#line 593 "GeometryModule.cs"
#line 593 "GeometryModule.cs"
                    int* csharp2cuda_temp_253 = &((output)->valid);
                    (*(csharp2cuda_temp_253) = 0);
#line 594 "GeometryModule.cs"
                    break;
                }
#line 596 "GeometryModule.cs"
                {
#line 597 "GeometryModule.cs"
                    double affinity = 0.0;
#line 598 "GeometryModule.cs"
                    {
#line 598 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 598 "GeometryModule.cs"
                            int csharp2cuda_temp_255 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_255))))
                                break;
#line 599 "GeometryModule.cs"
#line 599 "GeometryModule.cs"
                            double* csharp2cuda_temp_256 = &(affinity);
#line 599 "GeometryModule.cs"
                            double csharp2cuda_temp_257 = *(csharp2cuda_temp_256);
#line 599 "GeometryModule.cs"
                            double csharp2cuda_temp_258 = (a)[index];
#line 599 "GeometryModule.cs"
                            double csharp2cuda_temp_259 = (b)[index];
                            (*(csharp2cuda_temp_256) = __dadd_rn(csharp2cuda_temp_257, mathblocks_square_root(__dmul_rn(csharp2cuda_temp_258, csharp2cuda_temp_259))));
#line 598 "GeometryModule.cs"
                            int* csharp2cuda_temp_254 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_254));
                        }
                    }
#line 600 "GeometryModule.cs"
#line 600 "GeometryModule.cs"
                    double* csharp2cuda_temp_260 = &(affinity);
#line 600 "GeometryModule.cs"
                    double csharp2cuda_temp_261;
#line 600 "GeometryModule.cs"
                    if (((affinity) < ((-(1.0)))))
                    {
#line 600 "GeometryModule.cs"
                        csharp2cuda_temp_261 = (-(1.0));
                    }
                    else
                    {
#line 600 "GeometryModule.cs"
                        double csharp2cuda_temp_262;
#line 600 "GeometryModule.cs"
                        if (((affinity) > (1.0)))
                        {
#line 600 "GeometryModule.cs"
                            csharp2cuda_temp_262 = 1.0;
                        }
                        else
                        {
#line 600 "GeometryModule.cs"
                            csharp2cuda_temp_262 = affinity;
                        }
#line 600 "GeometryModule.cs"
                        csharp2cuda_temp_261 = csharp2cuda_temp_262;
                    }
                    (*(csharp2cuda_temp_260) = csharp2cuda_temp_261);
#line 601 "GeometryModule.cs"
#line 601 "GeometryModule.cs"
                    double* csharp2cuda_temp_263 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_263) = __dmul_rn(2.0, mathblocks_arc_cosine(affinity)));
#line 602 "GeometryModule.cs"
                    break;
                }
#line 604 "GeometryModule.cs"
            case 10:
#line 605 "GeometryModule.cs"
#line 605 "GeometryModule.cs"
                int csharp2cuda_temp_264 = (first)->count;
                if (((csharp2cuda_temp_264) < (2)))
#line 606 "GeometryModule.cs"
                {
#line 607 "GeometryModule.cs"
#line 607 "GeometryModule.cs"
                    int* csharp2cuda_temp_265 = &((output)->valid);
                    (*(csharp2cuda_temp_265) = 0);
#line 608 "GeometryModule.cs"
                    break;
                }
#line 610 "GeometryModule.cs"
                {
#line 611 "GeometryModule.cs"
                    unsigned long long csharp2cuda_temp_266 = (output)->data_pointer;
#line 611 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(csharp2cuda_temp_266));
#line 612 "GeometryModule.cs"
                    int edge_count = 0;
#line 613 "GeometryModule.cs"
                    {
#line 613 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 613 "GeometryModule.cs"
                            int csharp2cuda_temp_268 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_268))))
                                break;
#line 614 "GeometryModule.cs"
                            {
#line 615 "GeometryModule.cs"
                                {
#line 615 "GeometryModule.cs"
                                    int right = csharp2cuda_i32_add(left, 1);
                                    while (true)
                                    {
#line 615 "GeometryModule.cs"
                                        int csharp2cuda_temp_270 = (first)->count;
                                        if (!(((right) < (csharp2cuda_temp_270))))
                                            break;
#line 616 "GeometryModule.cs"
                                        {
#line 617 "GeometryModule.cs"
                                            double csharp2cuda_temp_271 = (a)[csharp2cuda_i32_mul(2, left)];
#line 617 "GeometryModule.cs"
                                            double csharp2cuda_temp_272 = (a)[csharp2cuda_i32_mul(2, right)];
#line 617 "GeometryModule.cs"
                                            double center_x = __ddiv_rn(__dadd_rn(csharp2cuda_temp_271, csharp2cuda_temp_272), 2.0);
#line 618 "GeometryModule.cs"
                                            double csharp2cuda_temp_273 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
#line 618 "GeometryModule.cs"
                                            double csharp2cuda_temp_274 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
#line 618 "GeometryModule.cs"
                                            double center_y = __ddiv_rn(__dadd_rn(csharp2cuda_temp_273, csharp2cuda_temp_274), 2.0);
#line 619 "GeometryModule.cs"
                                            double csharp2cuda_temp_275 = mathblocks_geometry_distance(a, left, a, right);
#line 619 "GeometryModule.cs"
                                            double radius = __ddiv_rn(csharp2cuda_temp_275, 2.0);
#line 620 "GeometryModule.cs"
                                            bool empty = true;
#line 621 "GeometryModule.cs"
                                            {
#line 621 "GeometryModule.cs"
                                                int index = 0;
                                                while (true)
                                                {
#line 621 "GeometryModule.cs"
                                                    int csharp2cuda_temp_277 = (first)->count;
                                                    if (!(((index) < (csharp2cuda_temp_277))))
                                                        break;
#line 622 "GeometryModule.cs"
                                                    {
#line 623 "GeometryModule.cs"
#line 623 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_278;
#line 623 "GeometryModule.cs"
                                                        if (((index) != (left)))
                                                        {
#line 623 "GeometryModule.cs"
                                                            csharp2cuda_temp_278 = ((index) != (right));
                                                        }
                                                        else
                                                        {
#line 623 "GeometryModule.cs"
                                                            csharp2cuda_temp_278 = false;
                                                        }
#line 623 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_279;
#line 623 "GeometryModule.cs"
                                                        if (csharp2cuda_temp_278)
                                                        {
#line 625 "GeometryModule.cs"
                                                            double csharp2cuda_temp_280 = (a)[csharp2cuda_i32_mul(2, index)];
#line 625 "GeometryModule.cs"
                                                            double csharp2cuda_temp_281 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 623 "GeometryModule.cs"
                                                            csharp2cuda_temp_279 = ((mathblocks_geometry_distance_coordinates(csharp2cuda_temp_280, csharp2cuda_temp_281, center_x, center_y)) < (radius));
                                                        }
                                                        else
                                                        {
#line 623 "GeometryModule.cs"
                                                            csharp2cuda_temp_279 = false;
                                                        }
                                                        if (csharp2cuda_temp_279)
#line 626 "GeometryModule.cs"
                                                        {
#line 627 "GeometryModule.cs"
#line 627 "GeometryModule.cs"
                                                            bool* csharp2cuda_temp_282 = &(empty);
                                                            (*(csharp2cuda_temp_282) = false);
#line 628 "GeometryModule.cs"
                                                            break;
                                                        }
                                                    }
#line 621 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_276 = &(index);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_276));
                                                }
                                            }
#line 631 "GeometryModule.cs"
                                            if ((!(empty)))
                                            {
#line 632 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_24;
                                            }
#line 633 "GeometryModule.cs"
#line 633 "GeometryModule.cs"
                                            int csharp2cuda_temp_283 = (output)->capacity;
                                            if (((edge_count) >= (csharp2cuda_temp_283)))
#line 634 "GeometryModule.cs"
                                            {
#line 635 "GeometryModule.cs"
#line 635 "GeometryModule.cs"
                                                int* csharp2cuda_temp_284 = &((output)->count);
#line 635 "GeometryModule.cs"
                                                int csharp2cuda_temp_285 = (output)->capacity;
#line 635 "GeometryModule.cs"
                                                int csharp2cuda_temp_286;
#line 635 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_285) == (2147483647)))
                                                {
#line 635 "GeometryModule.cs"
                                                    csharp2cuda_temp_286 = csharp2cuda_i32_neg(1);
                                                }
                                                else
                                                {
#line 637 "GeometryModule.cs"
                                                    int csharp2cuda_temp_287 = (output)->capacity;
#line 635 "GeometryModule.cs"
                                                    csharp2cuda_temp_286 = csharp2cuda_i32_add(csharp2cuda_temp_287, 1);
                                                }
                                                (*(csharp2cuda_temp_284) = csharp2cuda_temp_286);
#line 638 "GeometryModule.cs"
#line 638 "GeometryModule.cs"
                                                int* csharp2cuda_temp_288 = &((output)->valid);
                                                (*(csharp2cuda_temp_288) = 0);
#line 639 "GeometryModule.cs"
                                                break;
                                            }
#line 641 "GeometryModule.cs"
#line 641 "GeometryModule.cs"
                                            int* csharp2cuda_temp_289 = &(((edges)[edge_count]).from);
                                            (*(csharp2cuda_temp_289) = left);
#line 642 "GeometryModule.cs"
#line 642 "GeometryModule.cs"
                                            int* csharp2cuda_temp_290 = &(((edges)[edge_count]).to);
                                            (*(csharp2cuda_temp_290) = right);
#line 643 "GeometryModule.cs"
#line 643 "GeometryModule.cs"
                                            double* csharp2cuda_temp_291 = &(((edges)[edge_count]).weight);
                                            (*(csharp2cuda_temp_291) = __dmul_rn(2.0, radius));
#line 644 "GeometryModule.cs"
#line 644 "GeometryModule.cs"
                                            int* csharp2cuda_temp_292 = &(edge_count);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_292));
                                        }
                                        csharp2cuda_for_continue_24:
#line 615 "GeometryModule.cs"
                                        int* csharp2cuda_temp_269 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_269));
                                    }
                                }
                            }
#line 613 "GeometryModule.cs"
                            int* csharp2cuda_temp_267 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_267));
                        }
                    }
#line 647 "GeometryModule.cs"
#line 647 "GeometryModule.cs"
                    int* csharp2cuda_temp_293 = &((output)->rows);
#line 647 "GeometryModule.cs"
                    int csharp2cuda_temp_294 = (first)->count;
                    (*(csharp2cuda_temp_293) = csharp2cuda_temp_294);
#line 648 "GeometryModule.cs"
                    if ((output)->valid)
                    {
#line 649 "GeometryModule.cs"
#line 649 "GeometryModule.cs"
                        int* csharp2cuda_temp_295 = &((output)->count);
                        (*(csharp2cuda_temp_295) = edge_count);
                    }
#line 650 "GeometryModule.cs"
                    break;
                }
#line 652 "GeometryModule.cs"
            case 11:
#line 653 "GeometryModule.cs"
#line 653 "GeometryModule.cs"
                int csharp2cuda_temp_296 = (first)->count;
#line 653 "GeometryModule.cs"
                bool csharp2cuda_temp_297;
#line 653 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_296) <= (0))))
                {
#line 653 "GeometryModule.cs"
                    int csharp2cuda_temp_298 = (second)->count;
#line 653 "GeometryModule.cs"
                    csharp2cuda_temp_297 = ((csharp2cuda_temp_298) != (1));
                }
                else
                {
#line 653 "GeometryModule.cs"
                    csharp2cuda_temp_297 = true;
                }
                if (csharp2cuda_temp_297)
#line 654 "GeometryModule.cs"
                {
#line 655 "GeometryModule.cs"
#line 655 "GeometryModule.cs"
                    int* csharp2cuda_temp_299 = &((output)->valid);
                    (*(csharp2cuda_temp_299) = 0);
#line 656 "GeometryModule.cs"
                    break;
                }
#line 658 "GeometryModule.cs"
                {
#line 659 "GeometryModule.cs"
                    double point_x = (b)[0];
#line 660 "GeometryModule.cs"
                    double point_y = (b)[1];
#line 661 "GeometryModule.cs"
                    int coincident = 0;
#line 662 "GeometryModule.cs"
                    int vector_count = 0;
#line 663 "GeometryModule.cs"
                    {
#line 663 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 663 "GeometryModule.cs"
                            int csharp2cuda_temp_301 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_301))))
                                break;
#line 664 "GeometryModule.cs"
                            {
#line 665 "GeometryModule.cs"
                                double csharp2cuda_temp_302 = (a)[csharp2cuda_i32_mul(2, index)];
#line 665 "GeometryModule.cs"
                                double x = __dsub_rn(csharp2cuda_temp_302, point_x);
#line 666 "GeometryModule.cs"
                                double csharp2cuda_temp_303 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 666 "GeometryModule.cs"
                                double y = __dsub_rn(csharp2cuda_temp_303, point_y);
#line 667 "GeometryModule.cs"
#line 667 "GeometryModule.cs"
                                bool csharp2cuda_temp_304;
#line 667 "GeometryModule.cs"
                                if (((x) == (0.0)))
                                {
#line 667 "GeometryModule.cs"
                                    csharp2cuda_temp_304 = ((y) == (0.0));
                                }
                                else
                                {
#line 667 "GeometryModule.cs"
                                    csharp2cuda_temp_304 = false;
                                }
                                if (csharp2cuda_temp_304)
                                {
#line 668 "GeometryModule.cs"
#line 668 "GeometryModule.cs"
                                    int* csharp2cuda_temp_305 = &(coincident);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_305));
                                }
                                else
                                {
#line 670 "GeometryModule.cs"
#line 670 "GeometryModule.cs"
                                    int* csharp2cuda_temp_306 = &(vector_count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_306));
                                }
                            }
#line 663 "GeometryModule.cs"
                            int* csharp2cuda_temp_300 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_300));
                        }
                    }
#line 672 "GeometryModule.cs"
                    if (((vector_count) == (0)))
#line 673 "GeometryModule.cs"
                    {
#line 674 "GeometryModule.cs"
#line 674 "GeometryModule.cs"
                        double* csharp2cuda_temp_307 = &((output)->scalar_value);
                        (*(csharp2cuda_temp_307) = 1.0);
#line 675 "GeometryModule.cs"
                        break;
                    }
#line 677 "GeometryModule.cs"
                    int maximum = 0;
#line 678 "GeometryModule.cs"
                    {
#line 678 "GeometryModule.cs"
                        int pivot = 0;
                        while (true)
                        {
#line 678 "GeometryModule.cs"
                            int csharp2cuda_temp_309 = (first)->count;
                            if (!(((pivot) < (csharp2cuda_temp_309))))
                                break;
#line 679 "GeometryModule.cs"
                            {
#line 680 "GeometryModule.cs"
                                double csharp2cuda_temp_310 = (a)[csharp2cuda_i32_mul(2, pivot)];
#line 680 "GeometryModule.cs"
                                double pivot_x = __dsub_rn(csharp2cuda_temp_310, point_x);
#line 681 "GeometryModule.cs"
                                double csharp2cuda_temp_311 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, pivot), 1)];
#line 681 "GeometryModule.cs"
                                double pivot_y = __dsub_rn(csharp2cuda_temp_311, point_y);
#line 682 "GeometryModule.cs"
#line 682 "GeometryModule.cs"
                                bool csharp2cuda_temp_312;
#line 682 "GeometryModule.cs"
                                if (((pivot_x) == (0.0)))
                                {
#line 682 "GeometryModule.cs"
                                    csharp2cuda_temp_312 = ((pivot_y) == (0.0));
                                }
                                else
                                {
#line 682 "GeometryModule.cs"
                                    csharp2cuda_temp_312 = false;
                                }
                                if (csharp2cuda_temp_312)
                                {
#line 683 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_28;
                                }
#line 684 "GeometryModule.cs"
                                int count = 0;
#line 685 "GeometryModule.cs"
                                {
#line 685 "GeometryModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 685 "GeometryModule.cs"
                                        int csharp2cuda_temp_314 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_314))))
                                            break;
#line 686 "GeometryModule.cs"
                                        {
#line 687 "GeometryModule.cs"
                                            double csharp2cuda_temp_315 = (a)[csharp2cuda_i32_mul(2, index)];
#line 687 "GeometryModule.cs"
                                            double x = __dsub_rn(csharp2cuda_temp_315, point_x);
#line 688 "GeometryModule.cs"
                                            double csharp2cuda_temp_316 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 688 "GeometryModule.cs"
                                            double y = __dsub_rn(csharp2cuda_temp_316, point_y);
#line 689 "GeometryModule.cs"
#line 689 "GeometryModule.cs"
                                            bool csharp2cuda_temp_317;
#line 689 "GeometryModule.cs"
                                            if (((x) == (0.0)))
                                            {
#line 689 "GeometryModule.cs"
                                                csharp2cuda_temp_317 = ((y) == (0.0));
                                            }
                                            else
                                            {
#line 689 "GeometryModule.cs"
                                                csharp2cuda_temp_317 = false;
                                            }
                                            if (csharp2cuda_temp_317)
                                            {
#line 690 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_27;
                                            }
#line 691 "GeometryModule.cs"
                                            double cross = __dsub_rn(__dmul_rn(pivot_x, y), __dmul_rn(pivot_y, x));
#line 692 "GeometryModule.cs"
                                            double dot = __dadd_rn(__dmul_rn(pivot_x, x), __dmul_rn(pivot_y, y));
#line 693 "GeometryModule.cs"
#line 693 "GeometryModule.cs"
                                            bool csharp2cuda_temp_318;
#line 693 "GeometryModule.cs"
                                            if (!(((cross) > (0.0))))
                                            {
#line 693 "GeometryModule.cs"
                                                bool csharp2cuda_temp_319;
#line 693 "GeometryModule.cs"
                                                if (((cross) == (0.0)))
                                                {
#line 693 "GeometryModule.cs"
                                                    csharp2cuda_temp_319 = ((dot) > (0.0));
                                                }
                                                else
                                                {
#line 693 "GeometryModule.cs"
                                                    csharp2cuda_temp_319 = false;
                                                }
#line 693 "GeometryModule.cs"
                                                csharp2cuda_temp_318 = csharp2cuda_temp_319;
                                            }
                                            else
                                            {
#line 693 "GeometryModule.cs"
                                                csharp2cuda_temp_318 = true;
                                            }
                                            if (csharp2cuda_temp_318)
                                            {
#line 694 "GeometryModule.cs"
#line 694 "GeometryModule.cs"
                                                int* csharp2cuda_temp_320 = &(count);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_320));
                                            }
                                        }
                                        csharp2cuda_for_continue_27:
#line 685 "GeometryModule.cs"
                                        int* csharp2cuda_temp_313 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_313));
                                    }
                                }
#line 696 "GeometryModule.cs"
#line 696 "GeometryModule.cs"
                                int* csharp2cuda_temp_321 = &(maximum);
#line 696 "GeometryModule.cs"
                                int csharp2cuda_temp_322;
#line 696 "GeometryModule.cs"
                                if (((maximum) > (count)))
                                {
#line 696 "GeometryModule.cs"
                                    csharp2cuda_temp_322 = maximum;
                                }
                                else
                                {
#line 696 "GeometryModule.cs"
                                    csharp2cuda_temp_322 = count;
                                }
                                (*(csharp2cuda_temp_321) = csharp2cuda_temp_322);
                            }
                            csharp2cuda_for_continue_28:
#line 678 "GeometryModule.cs"
                            int* csharp2cuda_temp_308 = &(pivot);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_308));
                        }
                    }
#line 698 "GeometryModule.cs"
#line 698 "GeometryModule.cs"
                    double* csharp2cuda_temp_323 = &((output)->scalar_value);
#line 699 "GeometryModule.cs"
                    int csharp2cuda_temp_324 = (first)->count;
#line 698 "GeometryModule.cs"
                    double csharp2cuda_temp_325 = __ddiv_rn(((double)(csharp2cuda_i32_sub(csharp2cuda_i32_add(coincident, vector_count), maximum))), ((double)(csharp2cuda_temp_324)));
                    (*(csharp2cuda_temp_323) = csharp2cuda_temp_325);
#line 700 "GeometryModule.cs"
                    break;
                }
#line 702 "GeometryModule.cs"
            case 12:
#line 703 "GeometryModule.cs"
#line 703 "GeometryModule.cs"
                int csharp2cuda_temp_326 = (first)->count;
#line 703 "GeometryModule.cs"
                bool csharp2cuda_temp_327;
#line 703 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_326) <= (0))))
                {
#line 703 "GeometryModule.cs"
                    int csharp2cuda_temp_328 = (second)->count;
#line 703 "GeometryModule.cs"
                    csharp2cuda_temp_327 = ((csharp2cuda_temp_328) <= (0));
                }
                else
                {
#line 703 "GeometryModule.cs"
                    csharp2cuda_temp_327 = true;
                }
                if (csharp2cuda_temp_327)
#line 704 "GeometryModule.cs"
                {
#line 705 "GeometryModule.cs"
#line 705 "GeometryModule.cs"
                    int* csharp2cuda_temp_329 = &((output)->valid);
                    (*(csharp2cuda_temp_329) = 0);
#line 706 "GeometryModule.cs"
                    break;
                }
#line 708 "GeometryModule.cs"
                {
#line 709 "GeometryModule.cs"
                    double directed_left = 0.0;
#line 710 "GeometryModule.cs"
                    {
#line 710 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 710 "GeometryModule.cs"
                            int csharp2cuda_temp_331 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_331))))
                                break;
#line 711 "GeometryModule.cs"
                            {
#line 712 "GeometryModule.cs"
                                double minimum = mathblocks_positive_infinity();
#line 713 "GeometryModule.cs"
                                {
#line 713 "GeometryModule.cs"
                                    int right = 0;
                                    while (true)
                                    {
#line 713 "GeometryModule.cs"
                                        int csharp2cuda_temp_333 = (second)->count;
                                        if (!(((right) < (csharp2cuda_temp_333))))
                                            break;
#line 714 "GeometryModule.cs"
                                        {
#line 715 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(a, left, b, right);
#line 716 "GeometryModule.cs"
#line 716 "GeometryModule.cs"
                                            double* csharp2cuda_temp_334 = &(minimum);
#line 716 "GeometryModule.cs"
                                            double csharp2cuda_temp_335;
#line 716 "GeometryModule.cs"
                                            if (((minimum) < (distance)))
                                            {
#line 716 "GeometryModule.cs"
                                                csharp2cuda_temp_335 = minimum;
                                            }
                                            else
                                            {
#line 716 "GeometryModule.cs"
                                                csharp2cuda_temp_335 = distance;
                                            }
                                            (*(csharp2cuda_temp_334) = csharp2cuda_temp_335);
                                        }
#line 713 "GeometryModule.cs"
                                        int* csharp2cuda_temp_332 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_332));
                                    }
                                }
#line 718 "GeometryModule.cs"
#line 718 "GeometryModule.cs"
                                double* csharp2cuda_temp_336 = &(directed_left);
#line 718 "GeometryModule.cs"
                                double csharp2cuda_temp_337;
#line 718 "GeometryModule.cs"
                                if (((directed_left) > (minimum)))
                                {
#line 718 "GeometryModule.cs"
                                    csharp2cuda_temp_337 = directed_left;
                                }
                                else
                                {
#line 718 "GeometryModule.cs"
                                    csharp2cuda_temp_337 = minimum;
                                }
                                (*(csharp2cuda_temp_336) = csharp2cuda_temp_337);
                            }
#line 710 "GeometryModule.cs"
                            int* csharp2cuda_temp_330 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_330));
                        }
                    }
#line 720 "GeometryModule.cs"
                    double directed_right = 0.0;
#line 721 "GeometryModule.cs"
                    {
#line 721 "GeometryModule.cs"
                        int right = 0;
                        while (true)
                        {
#line 721 "GeometryModule.cs"
                            int csharp2cuda_temp_339 = (second)->count;
                            if (!(((right) < (csharp2cuda_temp_339))))
                                break;
#line 722 "GeometryModule.cs"
                            {
#line 723 "GeometryModule.cs"
                                double minimum = mathblocks_positive_infinity();
#line 724 "GeometryModule.cs"
                                {
#line 724 "GeometryModule.cs"
                                    int left = 0;
                                    while (true)
                                    {
#line 724 "GeometryModule.cs"
                                        int csharp2cuda_temp_341 = (first)->count;
                                        if (!(((left) < (csharp2cuda_temp_341))))
                                            break;
#line 725 "GeometryModule.cs"
                                        {
#line 726 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(b, right, a, left);
#line 727 "GeometryModule.cs"
#line 727 "GeometryModule.cs"
                                            double* csharp2cuda_temp_342 = &(minimum);
#line 727 "GeometryModule.cs"
                                            double csharp2cuda_temp_343;
#line 727 "GeometryModule.cs"
                                            if (((minimum) < (distance)))
                                            {
#line 727 "GeometryModule.cs"
                                                csharp2cuda_temp_343 = minimum;
                                            }
                                            else
                                            {
#line 727 "GeometryModule.cs"
                                                csharp2cuda_temp_343 = distance;
                                            }
                                            (*(csharp2cuda_temp_342) = csharp2cuda_temp_343);
                                        }
#line 724 "GeometryModule.cs"
                                        int* csharp2cuda_temp_340 = &(left);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_340));
                                    }
                                }
#line 729 "GeometryModule.cs"
#line 729 "GeometryModule.cs"
                                double* csharp2cuda_temp_344 = &(directed_right);
#line 729 "GeometryModule.cs"
                                double csharp2cuda_temp_345;
#line 729 "GeometryModule.cs"
                                if (((directed_right) > (minimum)))
                                {
#line 729 "GeometryModule.cs"
                                    csharp2cuda_temp_345 = directed_right;
                                }
                                else
                                {
#line 729 "GeometryModule.cs"
                                    csharp2cuda_temp_345 = minimum;
                                }
                                (*(csharp2cuda_temp_344) = csharp2cuda_temp_345);
                            }
#line 721 "GeometryModule.cs"
                            int* csharp2cuda_temp_338 = &(right);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_338));
                        }
                    }
#line 731 "GeometryModule.cs"
#line 731 "GeometryModule.cs"
                    double* csharp2cuda_temp_346 = &((output)->scalar_value);
#line 731 "GeometryModule.cs"
                    double csharp2cuda_temp_347;
#line 731 "GeometryModule.cs"
                    if (((directed_left) > (directed_right)))
                    {
#line 731 "GeometryModule.cs"
                        csharp2cuda_temp_347 = directed_left;
                    }
                    else
                    {
#line 731 "GeometryModule.cs"
                        csharp2cuda_temp_347 = directed_right;
                    }
                    (*(csharp2cuda_temp_346) = csharp2cuda_temp_347);
#line 734 "GeometryModule.cs"
                    break;
                }
#line 736 "GeometryModule.cs"
            case 13:
            case 14:
#line 738 "GeometryModule.cs"
#line 738 "GeometryModule.cs"
                int csharp2cuda_temp_348 = (first)->count;
                if (((csharp2cuda_temp_348) <= (0)))
#line 739 "GeometryModule.cs"
                {
#line 740 "GeometryModule.cs"
#line 740 "GeometryModule.cs"
                    int* csharp2cuda_temp_349 = &((output)->valid);
                    (*(csharp2cuda_temp_349) = 0);
#line 741 "GeometryModule.cs"
                    break;
                }
#line 743 "GeometryModule.cs"
                {
#line 744 "GeometryModule.cs"
                    double total = 0.0;
#line 745 "GeometryModule.cs"
                    int csharp2cuda_temp_350;
#line 745 "GeometryModule.cs"
                    if (((opcode) == (13)))
                    {
#line 745 "GeometryModule.cs"
                        csharp2cuda_temp_350 = 1;
                    }
                    else
                    {
#line 745 "GeometryModule.cs"
                        csharp2cuda_temp_350 = 0;
                    }
#line 745 "GeometryModule.cs"
                    int start = csharp2cuda_temp_350;
#line 746 "GeometryModule.cs"
                    {
#line 746 "GeometryModule.cs"
                        int index = start;
                        while (true)
                        {
#line 746 "GeometryModule.cs"
                            int csharp2cuda_temp_352 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_352))))
                                break;
#line 747 "GeometryModule.cs"
                            {
#line 748 "GeometryModule.cs"
                                int csharp2cuda_temp_353;
#line 748 "GeometryModule.cs"
                                if (((opcode) == (13)))
                                {
#line 748 "GeometryModule.cs"
                                    csharp2cuda_temp_353 = csharp2cuda_i32_sub(index, 1);
                                }
                                else
                                {
#line 748 "GeometryModule.cs"
                                    csharp2cuda_temp_353 = index;
                                }
#line 748 "GeometryModule.cs"
                                int previous = csharp2cuda_temp_353;
#line 749 "GeometryModule.cs"
                                int csharp2cuda_temp_354;
#line 749 "GeometryModule.cs"
                                if (((opcode) == (13)))
                                {
#line 749 "GeometryModule.cs"
                                    csharp2cuda_temp_354 = index;
                                }
                                else
                                {
#line 749 "GeometryModule.cs"
                                    int csharp2cuda_temp_355 = (first)->count;
#line 749 "GeometryModule.cs"
                                    csharp2cuda_temp_354 = csharp2cuda_i32_rem(csharp2cuda_i32_add(index, 1), csharp2cuda_temp_355);
                                }
#line 749 "GeometryModule.cs"
                                int next = csharp2cuda_temp_354;
#line 750 "GeometryModule.cs"
#line 750 "GeometryModule.cs"
                                double* csharp2cuda_temp_356 = &(total);
#line 750 "GeometryModule.cs"
                                double csharp2cuda_temp_357 = *(csharp2cuda_temp_356);
#line 750 "GeometryModule.cs"
                                double csharp2cuda_temp_358 = mathblocks_geometry_distance(a, previous, a, next);
                                (*(csharp2cuda_temp_356) = __dadd_rn(csharp2cuda_temp_357, csharp2cuda_temp_358));
                            }
#line 746 "GeometryModule.cs"
                            int* csharp2cuda_temp_351 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_351));
                        }
                    }
#line 752 "GeometryModule.cs"
#line 752 "GeometryModule.cs"
                    double* csharp2cuda_temp_359 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_359) = total);
#line 753 "GeometryModule.cs"
                    break;
                }
#line 755 "GeometryModule.cs"
            case 15:
#line 756 "GeometryModule.cs"
#line 756 "GeometryModule.cs"
                int csharp2cuda_temp_360 = (first)->count;
#line 756 "GeometryModule.cs"
                bool csharp2cuda_temp_361;
#line 756 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_360) != (1))))
                {
#line 756 "GeometryModule.cs"
                    int csharp2cuda_temp_362 = (second)->count;
#line 756 "GeometryModule.cs"
                    csharp2cuda_temp_361 = ((csharp2cuda_temp_362) != (2));
                }
                else
                {
#line 756 "GeometryModule.cs"
                    csharp2cuda_temp_361 = true;
                }
                if (csharp2cuda_temp_361)
#line 757 "GeometryModule.cs"
                {
#line 758 "GeometryModule.cs"
#line 758 "GeometryModule.cs"
                    int* csharp2cuda_temp_363 = &((output)->valid);
                    (*(csharp2cuda_temp_363) = 0);
#line 759 "GeometryModule.cs"
                    break;
                }
#line 761 "GeometryModule.cs"
#line 761 "GeometryModule.cs"
                double* csharp2cuda_temp_364 = &((output)->scalar_value);
#line 762 "GeometryModule.cs"
                double csharp2cuda_temp_365 = (a)[0];
#line 762 "GeometryModule.cs"
                double csharp2cuda_temp_366 = (a)[1];
#line 762 "GeometryModule.cs"
                double csharp2cuda_temp_367 = (b)[0];
#line 762 "GeometryModule.cs"
                double csharp2cuda_temp_368 = (b)[1];
#line 762 "GeometryModule.cs"
                double csharp2cuda_temp_369 = (b)[2];
#line 762 "GeometryModule.cs"
                double csharp2cuda_temp_370 = (b)[3];
                (*(csharp2cuda_temp_364) = mathblocks_geometry_point_to_segment(csharp2cuda_temp_365, csharp2cuda_temp_366, csharp2cuda_temp_367, csharp2cuda_temp_368, csharp2cuda_temp_369, csharp2cuda_temp_370));
#line 763 "GeometryModule.cs"
                break;
#line 764 "GeometryModule.cs"
            case 16:
            case 17:
#line 766 "GeometryModule.cs"
#line 766 "GeometryModule.cs"
                int csharp2cuda_temp_371 = (first)->count;
                if (((csharp2cuda_temp_371) <= (0)))
#line 767 "GeometryModule.cs"
                {
#line 768 "GeometryModule.cs"
#line 768 "GeometryModule.cs"
                    int* csharp2cuda_temp_372 = &((output)->valid);
                    (*(csharp2cuda_temp_372) = 0);
#line 769 "GeometryModule.cs"
                    break;
                }
#line 771 "GeometryModule.cs"
                {
#line 772 "GeometryModule.cs"
                    double twice_area = 0.0;
#line 773 "GeometryModule.cs"
                    {
#line 773 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 773 "GeometryModule.cs"
                            int csharp2cuda_temp_374 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_374))))
                                break;
#line 774 "GeometryModule.cs"
                            {
#line 775 "GeometryModule.cs"
                                int csharp2cuda_temp_375 = (first)->count;
#line 775 "GeometryModule.cs"
                                int next = csharp2cuda_i32_rem(csharp2cuda_i32_add(index, 1), csharp2cuda_temp_375);
#line 776 "GeometryModule.cs"
#line 776 "GeometryModule.cs"
                                double* csharp2cuda_temp_376 = &(twice_area);
#line 776 "GeometryModule.cs"
                                double csharp2cuda_temp_377 = *(csharp2cuda_temp_376);
#line 776 "GeometryModule.cs"
                                double csharp2cuda_temp_378 = (a)[csharp2cuda_i32_mul(2, index)];
#line 776 "GeometryModule.cs"
                                double csharp2cuda_temp_379 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, next), 1)];
#line 777 "GeometryModule.cs"
                                double csharp2cuda_temp_380 = (a)[csharp2cuda_i32_mul(2, next)];
#line 777 "GeometryModule.cs"
                                double csharp2cuda_temp_381 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                (*(csharp2cuda_temp_376) = __dadd_rn(csharp2cuda_temp_377, __dsub_rn(__dmul_rn(csharp2cuda_temp_378, csharp2cuda_temp_379), __dmul_rn(csharp2cuda_temp_380, csharp2cuda_temp_381))));
                            }
#line 773 "GeometryModule.cs"
                            int* csharp2cuda_temp_373 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_373));
                        }
                    }
#line 779 "GeometryModule.cs"
#line 779 "GeometryModule.cs"
                    double* csharp2cuda_temp_382 = &((output)->scalar_value);
#line 779 "GeometryModule.cs"
                    double csharp2cuda_temp_383;
#line 779 "GeometryModule.cs"
                    if (((opcode) == (16)))
                    {
#line 779 "GeometryModule.cs"
                        double csharp2cuda_temp_384 = __ddiv_rn(twice_area, 2.0);
#line 779 "GeometryModule.cs"
                        csharp2cuda_temp_383 = fabs(csharp2cuda_temp_384);
                    }
                    else
                    {
#line 779 "GeometryModule.cs"
                        csharp2cuda_temp_383 = __ddiv_rn(twice_area, 2.0);
                    }
                    (*(csharp2cuda_temp_382) = csharp2cuda_temp_383);
#line 780 "GeometryModule.cs"
                    break;
                }
#line 782 "GeometryModule.cs"
            case 18:
#line 783 "GeometryModule.cs"
#line 783 "GeometryModule.cs"
                int csharp2cuda_temp_385 = (first)->count;
#line 783 "GeometryModule.cs"
                bool csharp2cuda_temp_386;
#line 783 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_385) < (3))))
                {
#line 783 "GeometryModule.cs"
                    int csharp2cuda_temp_387 = (second)->count;
#line 783 "GeometryModule.cs"
                    csharp2cuda_temp_386 = ((csharp2cuda_temp_387) != (1));
                }
                else
                {
#line 783 "GeometryModule.cs"
                    csharp2cuda_temp_386 = true;
                }
                if (csharp2cuda_temp_386)
#line 784 "GeometryModule.cs"
                {
#line 785 "GeometryModule.cs"
#line 785 "GeometryModule.cs"
                    int* csharp2cuda_temp_388 = &((output)->valid);
                    (*(csharp2cuda_temp_388) = 0);
#line 786 "GeometryModule.cs"
                    break;
                }
#line 788 "GeometryModule.cs"
                {
#line 789 "GeometryModule.cs"
                    int containing = 0;
#line 790 "GeometryModule.cs"
                    int total = 0;
#line 791 "GeometryModule.cs"
                    double csharp2cuda_temp_389_storage[3];
                    double* coordinates = csharp2cuda_temp_389_storage;
#line 792 "GeometryModule.cs"
                    {
#line 792 "GeometryModule.cs"
                        int one = 0;
                        while (true)
                        {
#line 792 "GeometryModule.cs"
                            int csharp2cuda_temp_391 = (first)->count;
                            if (!(((one) < (csharp2cuda_temp_391))))
                                break;
#line 793 "GeometryModule.cs"
                            {
#line 793 "GeometryModule.cs"
                                int two = csharp2cuda_i32_add(one, 1);
                                while (true)
                                {
#line 793 "GeometryModule.cs"
                                    int csharp2cuda_temp_393 = (first)->count;
                                    if (!(((two) < (csharp2cuda_temp_393))))
                                        break;
#line 794 "GeometryModule.cs"
                                    {
#line 794 "GeometryModule.cs"
                                        int three = csharp2cuda_i32_add(two, 1);
                                        while (true)
                                        {
#line 794 "GeometryModule.cs"
                                            int csharp2cuda_temp_395 = (first)->count;
                                            if (!(((three) < (csharp2cuda_temp_395))))
                                                break;
#line 795 "GeometryModule.cs"
                                            {
#line 796 "GeometryModule.cs"
#line 796 "GeometryModule.cs"
                                                int* csharp2cuda_temp_396 = &(total);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_396));
#line 797 "GeometryModule.cs"
#line 798 "GeometryModule.cs"
                                                double csharp2cuda_temp_397 = (b)[0];
#line 798 "GeometryModule.cs"
                                                double csharp2cuda_temp_398 = (b)[1];
#line 799 "GeometryModule.cs"
                                                double csharp2cuda_temp_399 = (a)[csharp2cuda_i32_mul(2, one)];
#line 799 "GeometryModule.cs"
                                                double csharp2cuda_temp_400 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, one), 1)];
#line 800 "GeometryModule.cs"
                                                double csharp2cuda_temp_401 = (a)[csharp2cuda_i32_mul(2, two)];
#line 800 "GeometryModule.cs"
                                                double csharp2cuda_temp_402 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, two), 1)];
#line 801 "GeometryModule.cs"
                                                double csharp2cuda_temp_403 = (a)[csharp2cuda_i32_mul(2, three)];
#line 801 "GeometryModule.cs"
                                                double csharp2cuda_temp_404 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, three), 1)];
                                                mathblocks_geometry_barycentric(csharp2cuda_temp_397, csharp2cuda_temp_398, csharp2cuda_temp_399, csharp2cuda_temp_400, csharp2cuda_temp_401, csharp2cuda_temp_402, csharp2cuda_temp_403, csharp2cuda_temp_404, coordinates);
#line 803 "GeometryModule.cs"
#line 803 "GeometryModule.cs"
                                                double csharp2cuda_temp_405 = (coordinates)[0];
#line 803 "GeometryModule.cs"
                                                bool csharp2cuda_temp_406;
#line 803 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_405) >= (0.0)))
                                                {
#line 803 "GeometryModule.cs"
                                                    double csharp2cuda_temp_407 = (coordinates)[0];
#line 803 "GeometryModule.cs"
                                                    csharp2cuda_temp_406 = ((csharp2cuda_temp_407) <= (1.0));
                                                }
                                                else
                                                {
#line 803 "GeometryModule.cs"
                                                    csharp2cuda_temp_406 = false;
                                                }
#line 803 "GeometryModule.cs"
                                                bool csharp2cuda_temp_408;
#line 803 "GeometryModule.cs"
                                                if (csharp2cuda_temp_406)
                                                {
#line 804 "GeometryModule.cs"
                                                    double csharp2cuda_temp_409 = (coordinates)[1];
#line 803 "GeometryModule.cs"
                                                    csharp2cuda_temp_408 = ((csharp2cuda_temp_409) >= (0.0));
                                                }
                                                else
                                                {
#line 803 "GeometryModule.cs"
                                                    csharp2cuda_temp_408 = false;
                                                }
#line 803 "GeometryModule.cs"
                                                bool csharp2cuda_temp_410;
#line 803 "GeometryModule.cs"
                                                if (csharp2cuda_temp_408)
                                                {
#line 804 "GeometryModule.cs"
                                                    double csharp2cuda_temp_411 = (coordinates)[1];
#line 803 "GeometryModule.cs"
                                                    csharp2cuda_temp_410 = ((csharp2cuda_temp_411) <= (1.0));
                                                }
                                                else
                                                {
#line 803 "GeometryModule.cs"
                                                    csharp2cuda_temp_410 = false;
                                                }
#line 803 "GeometryModule.cs"
                                                bool csharp2cuda_temp_412;
#line 803 "GeometryModule.cs"
                                                if (csharp2cuda_temp_410)
                                                {
#line 805 "GeometryModule.cs"
                                                    double csharp2cuda_temp_413 = (coordinates)[2];
#line 803 "GeometryModule.cs"
                                                    csharp2cuda_temp_412 = ((csharp2cuda_temp_413) >= (0.0));
                                                }
                                                else
                                                {
#line 803 "GeometryModule.cs"
                                                    csharp2cuda_temp_412 = false;
                                                }
#line 803 "GeometryModule.cs"
                                                bool csharp2cuda_temp_414;
#line 803 "GeometryModule.cs"
                                                if (csharp2cuda_temp_412)
                                                {
#line 805 "GeometryModule.cs"
                                                    double csharp2cuda_temp_415 = (coordinates)[2];
#line 803 "GeometryModule.cs"
                                                    csharp2cuda_temp_414 = ((csharp2cuda_temp_415) <= (1.0));
                                                }
                                                else
                                                {
#line 803 "GeometryModule.cs"
                                                    csharp2cuda_temp_414 = false;
                                                }
                                                if (csharp2cuda_temp_414)
#line 806 "GeometryModule.cs"
                                                {
#line 807 "GeometryModule.cs"
#line 807 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_416 = &(containing);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_416));
                                                }
                                            }
#line 794 "GeometryModule.cs"
                                            int* csharp2cuda_temp_394 = &(three);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_394));
                                        }
                                    }
#line 793 "GeometryModule.cs"
                                    int* csharp2cuda_temp_392 = &(two);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_392));
                                }
                            }
#line 792 "GeometryModule.cs"
                            int* csharp2cuda_temp_390 = &(one);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_390));
                        }
                    }
#line 810 "GeometryModule.cs"
#line 810 "GeometryModule.cs"
                    double* csharp2cuda_temp_417 = &((output)->scalar_value);
#line 810 "GeometryModule.cs"
                    double csharp2cuda_temp_418 = __ddiv_rn(((double)(containing)), ((double)(total)));
                    (*(csharp2cuda_temp_417) = csharp2cuda_temp_418);
#line 811 "GeometryModule.cs"
                    break;
                }
#line 813 "GeometryModule.cs"
            case 19:
#line 814 "GeometryModule.cs"
#line 814 "GeometryModule.cs"
                int* csharp2cuda_temp_419 = &((output)->rows);
#line 814 "GeometryModule.cs"
                int csharp2cuda_temp_420 = (first)->rows;
                (*(csharp2cuda_temp_419) = csharp2cuda_temp_420);
#line 815 "GeometryModule.cs"
#line 815 "GeometryModule.cs"
                int* csharp2cuda_temp_421 = &((output)->count);
#line 815 "GeometryModule.cs"
                int csharp2cuda_temp_422 = (first)->rows;
                (*(csharp2cuda_temp_421) = csharp2cuda_temp_422);
#line 816 "GeometryModule.cs"
#line 816 "GeometryModule.cs"
                int csharp2cuda_temp_423 = (first)->columns;
#line 816 "GeometryModule.cs"
                bool csharp2cuda_temp_424;
#line 816 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_423) != (2))))
                {
#line 816 "GeometryModule.cs"
                    int csharp2cuda_temp_425 = (first)->rows;
#line 816 "GeometryModule.cs"
                    int csharp2cuda_temp_426 = (output)->capacity;
#line 816 "GeometryModule.cs"
                    csharp2cuda_temp_424 = ((csharp2cuda_temp_425) > (csharp2cuda_temp_426));
                }
                else
                {
#line 816 "GeometryModule.cs"
                    csharp2cuda_temp_424 = true;
                }
                if (csharp2cuda_temp_424)
#line 817 "GeometryModule.cs"
                {
#line 818 "GeometryModule.cs"
#line 818 "GeometryModule.cs"
                    int* csharp2cuda_temp_427 = &((output)->valid);
                    (*(csharp2cuda_temp_427) = 0);
#line 819 "GeometryModule.cs"
                    break;
                }
#line 821 "GeometryModule.cs"
                {
#line 821 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 821 "GeometryModule.cs"
                        int csharp2cuda_temp_429 = (first)->rows;
                        if (!(((index) < (csharp2cuda_i32_mul(csharp2cuda_temp_429, 2)))))
                            break;
#line 822 "GeometryModule.cs"
#line 822 "GeometryModule.cs"
                        double* csharp2cuda_temp_430 = &((result)[index]);
#line 822 "GeometryModule.cs"
                        double csharp2cuda_temp_431 = (a)[index];
                        (*(csharp2cuda_temp_430) = csharp2cuda_temp_431);
#line 821 "GeometryModule.cs"
                        int* csharp2cuda_temp_428 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_428));
                    }
                }
#line 823 "GeometryModule.cs"
                break;
#line 824 "GeometryModule.cs"
            case 20:
#line 825 "GeometryModule.cs"
#line 825 "GeometryModule.cs"
                int csharp2cuda_temp_432 = (first)->count;
                mathblocks_sequence_set_matrix_shape(output, csharp2cuda_temp_432, 2);
#line 826 "GeometryModule.cs"
#line 826 "GeometryModule.cs"
                int csharp2cuda_temp_433 = (first)->count;
                if (((csharp2cuda_temp_433) <= (0)))
#line 827 "GeometryModule.cs"
                {
#line 828 "GeometryModule.cs"
#line 828 "GeometryModule.cs"
                    int* csharp2cuda_temp_434 = &((output)->valid);
                    (*(csharp2cuda_temp_434) = 0);
#line 829 "GeometryModule.cs"
                    break;
                }
#line 831 "GeometryModule.cs"
                {
#line 831 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 831 "GeometryModule.cs"
                        int csharp2cuda_temp_436 = (first)->count;
                        if (!(((index) < (csharp2cuda_i32_mul(csharp2cuda_temp_436, 2)))))
                            break;
#line 832 "GeometryModule.cs"
#line 832 "GeometryModule.cs"
                        double* csharp2cuda_temp_437 = &((result)[index]);
#line 832 "GeometryModule.cs"
                        double csharp2cuda_temp_438 = (a)[index];
                        (*(csharp2cuda_temp_437) = csharp2cuda_temp_438);
#line 831 "GeometryModule.cs"
                        int* csharp2cuda_temp_435 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_435));
                    }
                }
#line 833 "GeometryModule.cs"
                break;
#line 834 "GeometryModule.cs"
            case 21:
#line 835 "GeometryModule.cs"
#line 835 "GeometryModule.cs"
                int csharp2cuda_temp_439 = (first)->count;
#line 835 "GeometryModule.cs"
                bool csharp2cuda_temp_440;
#line 835 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_439) <= (0))))
                {
#line 835 "GeometryModule.cs"
                    csharp2cuda_temp_440 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 835 "GeometryModule.cs"
                    csharp2cuda_temp_440 = true;
                }
                if (csharp2cuda_temp_440)
#line 836 "GeometryModule.cs"
                {
#line 837 "GeometryModule.cs"
#line 837 "GeometryModule.cs"
                    int* csharp2cuda_temp_441 = &((output)->valid);
                    (*(csharp2cuda_temp_441) = 0);
#line 838 "GeometryModule.cs"
                    break;
                }
#line 840 "GeometryModule.cs"
#line 840 "GeometryModule.cs"
                int csharp2cuda_temp_442 = (first)->count;
                if (((csharp2cuda_temp_442) == (1)))
#line 841 "GeometryModule.cs"
                {
#line 842 "GeometryModule.cs"
                    mathblocks_sequence_set_vector_shape(output, 0);
#line 843 "GeometryModule.cs"
                    break;
                }
#line 845 "GeometryModule.cs"
                {
#line 846 "GeometryModule.cs"
                    int vertex_count = (first)->count;
#line 847 "GeometryModule.cs"
                    int edge_capacity = csharp2cuda_i32_div(csharp2cuda_i32_mul(vertex_count, csharp2cuda_i32_sub(vertex_count, 1)), 2);
#line 848 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(scratch));
#line 849 "GeometryModule.cs"
                    int edge_count = 0;
#line 850 "GeometryModule.cs"
                    {
#line 850 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (vertex_count))))
                                break;
#line 851 "GeometryModule.cs"
                            {
#line 851 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
                                    if (!(((right) < (vertex_count))))
                                        break;
#line 852 "GeometryModule.cs"
                                    {
#line 853 "GeometryModule.cs"
#line 853 "GeometryModule.cs"
                                        int* csharp2cuda_temp_445 = &(((edges)[edge_count]).from);
                                        (*(csharp2cuda_temp_445) = left);
#line 854 "GeometryModule.cs"
#line 854 "GeometryModule.cs"
                                        int* csharp2cuda_temp_446 = &(((edges)[edge_count]).to);
                                        (*(csharp2cuda_temp_446) = right);
#line 855 "GeometryModule.cs"
#line 855 "GeometryModule.cs"
                                        double* csharp2cuda_temp_447 = &(((edges)[edge_count]).weight);
#line 855 "GeometryModule.cs"
                                        double csharp2cuda_temp_448 = mathblocks_geometry_distance(a, left, a, right);
                                        (*(csharp2cuda_temp_447) = csharp2cuda_temp_448);
#line 856 "GeometryModule.cs"
#line 856 "GeometryModule.cs"
                                        int* csharp2cuda_temp_449 = &(edge_count);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_449));
                                    }
#line 851 "GeometryModule.cs"
                                    int* csharp2cuda_temp_444 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_444));
                                }
                            }
#line 850 "GeometryModule.cs"
                            int* csharp2cuda_temp_443 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_443));
                        }
                    }
#line 858 "GeometryModule.cs"
                    {
#line 858 "GeometryModule.cs"
                        int index = 1;
                        while (true)
                        {
                            if (!(((index) < (edge_count))))
                                break;
#line 859 "GeometryModule.cs"
                            {
#line 860 "GeometryModule.cs"
                                MathBlockGeometryEdge value = (edges)[index];
#line 861 "GeometryModule.cs"
                                int position = index;
#line 862 "GeometryModule.cs"
                                while (true)
                                {
#line 862 "GeometryModule.cs"
                                    bool csharp2cuda_temp_451;
#line 862 "GeometryModule.cs"
                                    if (((position) > (0)))
                                    {
#line 862 "GeometryModule.cs"
                                        MathBlockGeometryEdge* csharp2cuda_temp_452 = &(value);
#line 862 "GeometryModule.cs"
                                        MathBlockGeometryEdge* csharp2cuda_temp_453 = &((edges)[csharp2cuda_i32_sub(position, 1)]);
#line 862 "GeometryModule.cs"
                                        csharp2cuda_temp_451 = mathblocks_geometry_edge_less(csharp2cuda_temp_452, csharp2cuda_temp_453);
                                    }
                                    else
                                    {
#line 862 "GeometryModule.cs"
                                        csharp2cuda_temp_451 = false;
                                    }
                                    if (!(csharp2cuda_temp_451))
                                        break;
#line 863 "GeometryModule.cs"
                                    {
#line 864 "GeometryModule.cs"
#line 864 "GeometryModule.cs"
                                        MathBlockGeometryEdge* csharp2cuda_temp_454 = &((edges)[position]);
#line 864 "GeometryModule.cs"
                                        MathBlockGeometryEdge csharp2cuda_temp_455 = (edges)[csharp2cuda_i32_sub(position, 1)];
                                        (*(csharp2cuda_temp_454) = csharp2cuda_temp_455);
#line 865 "GeometryModule.cs"
#line 865 "GeometryModule.cs"
                                        int* csharp2cuda_temp_456 = &(position);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_456));
                                    }
                                }
#line 867 "GeometryModule.cs"
#line 867 "GeometryModule.cs"
                                MathBlockGeometryEdge* csharp2cuda_temp_457 = &((edges)[position]);
                                (*(csharp2cuda_temp_457) = value);
                            }
#line 858 "GeometryModule.cs"
                            int* csharp2cuda_temp_450 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_450));
                        }
                    }
#line 869 "GeometryModule.cs"
                    int* parent = ((int*)(csharp2cuda_pointer_add(edges, edge_capacity)));
#line 870 "GeometryModule.cs"
                    unsigned char* rank = ((unsigned char*)(csharp2cuda_pointer_add(parent, vertex_count)));
#line 871 "GeometryModule.cs"
                    {
#line 871 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (vertex_count))))
                                break;
#line 872 "GeometryModule.cs"
                            {
#line 873 "GeometryModule.cs"
#line 873 "GeometryModule.cs"
                                int* csharp2cuda_temp_459 = &((parent)[index]);
                                (*(csharp2cuda_temp_459) = index);
#line 874 "GeometryModule.cs"
#line 874 "GeometryModule.cs"
                                unsigned char* csharp2cuda_temp_460 = &((rank)[index]);
                                (*(csharp2cuda_temp_460) = ((unsigned char)(0)));
                            }
#line 871 "GeometryModule.cs"
                            int* csharp2cuda_temp_458 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_458));
                        }
                    }
#line 876 "GeometryModule.cs"
                    int selected = 0;
#line 877 "GeometryModule.cs"
                    {
#line 877 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 877 "GeometryModule.cs"
                            bool csharp2cuda_temp_462;
#line 877 "GeometryModule.cs"
                            if (((index) < (edge_count)))
                            {
#line 877 "GeometryModule.cs"
                                csharp2cuda_temp_462 = ((selected) < (csharp2cuda_i32_sub(vertex_count, 1)));
                            }
                            else
                            {
#line 877 "GeometryModule.cs"
                                csharp2cuda_temp_462 = false;
                            }
                            if (!(csharp2cuda_temp_462))
                                break;
#line 878 "GeometryModule.cs"
                            {
#line 879 "GeometryModule.cs"
                                int csharp2cuda_temp_463 = ((edges)[index]).from;
#line 879 "GeometryModule.cs"
                                int left = mathblocks_geometry_find(parent, csharp2cuda_temp_463);
#line 880 "GeometryModule.cs"
                                int csharp2cuda_temp_464 = ((edges)[index]).to;
#line 880 "GeometryModule.cs"
                                int right = mathblocks_geometry_find(parent, csharp2cuda_temp_464);
#line 881 "GeometryModule.cs"
                                if (((left) == (right)))
                                {
#line 882 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_44;
                                }
#line 883 "GeometryModule.cs"
#line 883 "GeometryModule.cs"
                                unsigned char csharp2cuda_temp_465 = (rank)[left];
#line 883 "GeometryModule.cs"
                                unsigned char csharp2cuda_temp_466 = (rank)[right];
                                if (((((int)(csharp2cuda_temp_465))) < (((int)(csharp2cuda_temp_466)))))
                                {
#line 884 "GeometryModule.cs"
#line 884 "GeometryModule.cs"
                                    int* csharp2cuda_temp_467 = &((parent)[left]);
                                    (*(csharp2cuda_temp_467) = right);
                                }
                                else
                                {
#line 885 "GeometryModule.cs"
#line 885 "GeometryModule.cs"
                                    unsigned char csharp2cuda_temp_468 = (rank)[left];
#line 885 "GeometryModule.cs"
                                    unsigned char csharp2cuda_temp_469 = (rank)[right];
                                    if (((((int)(csharp2cuda_temp_468))) > (((int)(csharp2cuda_temp_469)))))
                                    {
#line 886 "GeometryModule.cs"
#line 886 "GeometryModule.cs"
                                        int* csharp2cuda_temp_470 = &((parent)[right]);
                                        (*(csharp2cuda_temp_470) = left);
                                    }
                                    else
#line 888 "GeometryModule.cs"
                                    {
#line 889 "GeometryModule.cs"
#line 889 "GeometryModule.cs"
                                        int* csharp2cuda_temp_471 = &((parent)[right]);
                                        (*(csharp2cuda_temp_471) = left);
#line 890 "GeometryModule.cs"
#line 890 "GeometryModule.cs"
                                        unsigned char* csharp2cuda_temp_472 = &((rank)[left]);
                                        (*(csharp2cuda_temp_472))++;
                                    }
                                }
#line 892 "GeometryModule.cs"
#line 892 "GeometryModule.cs"
                                int* csharp2cuda_temp_473 = &(selected);
#line 892 "GeometryModule.cs"
                                int csharp2cuda_temp_474 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_473));
#line 892 "GeometryModule.cs"
                                double* csharp2cuda_temp_475 = &((result)[csharp2cuda_temp_474]);
#line 892 "GeometryModule.cs"
                                double csharp2cuda_temp_476 = ((edges)[index]).weight;
                                (*(csharp2cuda_temp_475) = csharp2cuda_temp_476);
                            }
                            csharp2cuda_for_continue_44:
#line 877 "GeometryModule.cs"
                            int* csharp2cuda_temp_461 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_461));
                        }
                    }
#line 894 "GeometryModule.cs"
                    mathblocks_sequence_set_vector_shape(output, selected);
#line 895 "GeometryModule.cs"
                    break;
                }
        }
#line 898 "GeometryModule.cs"
#line 898 "GeometryModule.cs"
        bool csharp2cuda_temp_477 = (output)->valid;
#line 898 "GeometryModule.cs"
        bool csharp2cuda_temp_478;
#line 898 "GeometryModule.cs"
        if (csharp2cuda_temp_477)
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_478 = ((opcode) != (0));
        }
        else
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_478 = false;
        }
#line 898 "GeometryModule.cs"
        bool csharp2cuda_temp_479;
#line 898 "GeometryModule.cs"
        if (csharp2cuda_temp_478)
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_479 = ((opcode) != (1));
        }
        else
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_479 = false;
        }
#line 898 "GeometryModule.cs"
        bool csharp2cuda_temp_480;
#line 898 "GeometryModule.cs"
        if (csharp2cuda_temp_479)
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_480 = ((opcode) != (3));
        }
        else
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_480 = false;
        }
#line 898 "GeometryModule.cs"
        bool csharp2cuda_temp_481;
#line 898 "GeometryModule.cs"
        if (csharp2cuda_temp_480)
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_481 = ((opcode) != (4));
        }
        else
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_481 = false;
        }
#line 898 "GeometryModule.cs"
        bool csharp2cuda_temp_482;
#line 898 "GeometryModule.cs"
        if (csharp2cuda_temp_481)
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_482 = ((opcode) != (5));
        }
        else
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_482 = false;
        }
#line 898 "GeometryModule.cs"
        bool csharp2cuda_temp_483;
#line 898 "GeometryModule.cs"
        if (csharp2cuda_temp_482)
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_483 = ((opcode) != (10));
        }
        else
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_483 = false;
        }
#line 898 "GeometryModule.cs"
        bool csharp2cuda_temp_484;
#line 898 "GeometryModule.cs"
        if (csharp2cuda_temp_483)
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_484 = ((opcode) != (19));
        }
        else
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_484 = false;
        }
#line 898 "GeometryModule.cs"
        bool csharp2cuda_temp_485;
#line 898 "GeometryModule.cs"
        if (csharp2cuda_temp_484)
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_485 = ((opcode) != (20));
        }
        else
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_485 = false;
        }
#line 898 "GeometryModule.cs"
        bool csharp2cuda_temp_486;
#line 898 "GeometryModule.cs"
        if (csharp2cuda_temp_485)
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_486 = ((opcode) != (21));
        }
        else
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_486 = false;
        }
#line 898 "GeometryModule.cs"
        bool csharp2cuda_temp_487;
#line 898 "GeometryModule.cs"
        if (csharp2cuda_temp_486)
        {
#line 901 "GeometryModule.cs"
            double csharp2cuda_temp_488 = (output)->scalar_value;
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_487 = (!(isfinite(csharp2cuda_temp_488)));
        }
        else
        {
#line 898 "GeometryModule.cs"
            csharp2cuda_temp_487 = false;
        }
        if (csharp2cuda_temp_487)
#line 902 "GeometryModule.cs"
        {
#line 903 "GeometryModule.cs"
#line 903 "GeometryModule.cs"
            int* csharp2cuda_temp_489 = &((output)->valid);
            (*(csharp2cuda_temp_489) = 0);
        }
    }
}

#line 56 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance(
    const double* left,
    int left_index,
    const double* right,
    int right_index)
#line 62 "GeometryModule.cs"
{
#line 63 "GeometryModule.cs"
#line 64 "GeometryModule.cs"
    double csharp2cuda_temp_0 = (left)[csharp2cuda_i32_mul(2, left_index)];
#line 65 "GeometryModule.cs"
    double csharp2cuda_temp_1 = (left)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left_index), 1)];
#line 66 "GeometryModule.cs"
    double csharp2cuda_temp_2 = (right)[csharp2cuda_i32_mul(2, right_index)];
#line 67 "GeometryModule.cs"
    double csharp2cuda_temp_3 = (right)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right_index), 1)];
    return mathblocks_geometry_distance_coordinates(csharp2cuda_temp_0, csharp2cuda_temp_1, csharp2cuda_temp_2, csharp2cuda_temp_3);
}

#line 44 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance_coordinates(
    double left_x,
    double left_y,
    double right_x,
    double right_y)
#line 50 "GeometryModule.cs"
{
#line 51 "GeometryModule.cs"
    double x = __dsub_rn(left_x, right_x);
#line 52 "GeometryModule.cs"
    double y = __dsub_rn(left_y, right_y);
#line 53 "GeometryModule.cs"
    return mathblocks_square_root(__dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y)));
}

#line 222 "GeometryModule.cs"
__device__ bool mathblocks_geometry_edge_less(
    const MathBlockGeometryEdge* left,
    const MathBlockGeometryEdge* right)
#line 226 "GeometryModule.cs"
{
#line 227 "GeometryModule.cs"
#line 227 "GeometryModule.cs"
    double csharp2cuda_temp_0 = (*(left)).weight;
#line 227 "GeometryModule.cs"
    double csharp2cuda_temp_1 = (*(right)).weight;
    if (((csharp2cuda_temp_0) < (csharp2cuda_temp_1)))
    {
#line 228 "GeometryModule.cs"
        return true;
    }
#line 229 "GeometryModule.cs"
#line 229 "GeometryModule.cs"
    double csharp2cuda_temp_2 = (*(right)).weight;
#line 229 "GeometryModule.cs"
    double csharp2cuda_temp_3 = (*(left)).weight;
    if (((csharp2cuda_temp_2) < (csharp2cuda_temp_3)))
    {
#line 230 "GeometryModule.cs"
        return false;
    }
#line 231 "GeometryModule.cs"
#line 231 "GeometryModule.cs"
    int csharp2cuda_temp_4 = (*(left)).from;
#line 231 "GeometryModule.cs"
    int csharp2cuda_temp_5 = (*(right)).from;
    if (((csharp2cuda_temp_4) < (csharp2cuda_temp_5)))
    {
#line 232 "GeometryModule.cs"
        return true;
    }
#line 233 "GeometryModule.cs"
#line 233 "GeometryModule.cs"
    int csharp2cuda_temp_6 = (*(right)).from;
#line 233 "GeometryModule.cs"
    int csharp2cuda_temp_7 = (*(left)).from;
    if (((csharp2cuda_temp_6) < (csharp2cuda_temp_7)))
    {
#line 234 "GeometryModule.cs"
        return false;
    }
#line 235 "GeometryModule.cs"
#line 235 "GeometryModule.cs"
    int csharp2cuda_temp_8 = (*(left)).to;
#line 235 "GeometryModule.cs"
    int csharp2cuda_temp_9 = (*(right)).to;
    return ((csharp2cuda_temp_8) < (csharp2cuda_temp_9));
}

#line 211 "GeometryModule.cs"
__device__ int mathblocks_geometry_find(int* parent, int value)
#line 213 "GeometryModule.cs"
{
#line 214 "GeometryModule.cs"
    while (true)
    {
#line 214 "GeometryModule.cs"
        int csharp2cuda_temp_0 = (parent)[value];
        if (!(((csharp2cuda_temp_0) != (value))))
            break;
#line 215 "GeometryModule.cs"
        {
#line 216 "GeometryModule.cs"
#line 216 "GeometryModule.cs"
            int* csharp2cuda_temp_1 = &((parent)[value]);
#line 216 "GeometryModule.cs"
            int csharp2cuda_temp_2 = (parent)[value];
#line 216 "GeometryModule.cs"
            int csharp2cuda_temp_3 = (parent)[csharp2cuda_temp_2];
            (*(csharp2cuda_temp_1) = csharp2cuda_temp_3);
#line 217 "GeometryModule.cs"
#line 217 "GeometryModule.cs"
            int* csharp2cuda_temp_4 = &(value);
#line 217 "GeometryModule.cs"
            int csharp2cuda_temp_5 = (parent)[value];
            (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
        }
    }
#line 219 "GeometryModule.cs"
    return value;
}

#line 171 "GeometryModule.cs"
__device__ bool mathblocks_geometry_point_less(
    const double* points,
    int left,
    int right)
#line 176 "GeometryModule.cs"
{
#line 177 "GeometryModule.cs"
    double left_x = (points)[csharp2cuda_i32_mul(2, left)];
#line 178 "GeometryModule.cs"
    double right_x = (points)[csharp2cuda_i32_mul(2, right)];
#line 179 "GeometryModule.cs"
    if (((left_x) < (right_x)))
    {
#line 180 "GeometryModule.cs"
        return true;
    }
#line 181 "GeometryModule.cs"
    if (((right_x) < (left_x)))
    {
#line 182 "GeometryModule.cs"
        return false;
    }
#line 183 "GeometryModule.cs"
    double left_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
#line 184 "GeometryModule.cs"
    double right_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
#line 185 "GeometryModule.cs"
    if (((left_y) < (right_y)))
    {
#line 186 "GeometryModule.cs"
        return true;
    }
#line 187 "GeometryModule.cs"
    if (((right_y) < (left_y)))
    {
#line 188 "GeometryModule.cs"
        return false;
    }
#line 189 "GeometryModule.cs"
    return ((left) < (right));
}

#line 83 "GeometryModule.cs"
__device__ double mathblocks_geometry_point_to_segment(
    double point_x,
    double point_y,
    double start_x,
    double start_y,
    double end_x,
    double end_y)
#line 91 "GeometryModule.cs"
{
#line 92 "GeometryModule.cs"
    double x = __dsub_rn(end_x, start_x);
#line 93 "GeometryModule.cs"
    double y = __dsub_rn(end_y, start_y);
#line 94 "GeometryModule.cs"
    double length_square = __dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y));
#line 95 "GeometryModule.cs"
    if (((length_square) == (0.0)))
    {
#line 96 "GeometryModule.cs"
        return mathblocks_geometry_distance_coordinates(point_x, point_y, start_x, start_y);
    }
#line 97 "GeometryModule.cs"
    double projection = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(point_x, start_x), x), __dmul_rn(__dsub_rn(point_y, start_y), y)), length_square);
#line 99 "GeometryModule.cs"
#line 99 "GeometryModule.cs"
    double* csharp2cuda_temp_0 = &(projection);
#line 99 "GeometryModule.cs"
    double csharp2cuda_temp_1;
#line 99 "GeometryModule.cs"
    if (((projection) < (0.0)))
    {
#line 99 "GeometryModule.cs"
        csharp2cuda_temp_1 = 0.0;
    }
    else
    {
#line 99 "GeometryModule.cs"
        double csharp2cuda_temp_2;
#line 99 "GeometryModule.cs"
        if (((projection) > (1.0)))
        {
#line 99 "GeometryModule.cs"
            csharp2cuda_temp_2 = 1.0;
        }
        else
        {
#line 99 "GeometryModule.cs"
            csharp2cuda_temp_2 = projection;
        }
#line 99 "GeometryModule.cs"
        csharp2cuda_temp_1 = csharp2cuda_temp_2;
    }
    (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
#line 100 "GeometryModule.cs"
    return mathblocks_geometry_distance_coordinates(point_x, point_y, __dadd_rn(start_x, __dmul_rn(projection, x)), __dadd_rn(start_y, __dmul_rn(projection, y)));
}

#line 192 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_indices(
    const double* points,
    int count,
    int* indices)
#line 197 "GeometryModule.cs"
{
#line 198 "GeometryModule.cs"
    {
#line 198 "GeometryModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 199 "GeometryModule.cs"
            {
#line 200 "GeometryModule.cs"
                int value = index;
#line 201 "GeometryModule.cs"
                int position = index;
#line 202 "GeometryModule.cs"
                while (true)
                {
#line 202 "GeometryModule.cs"
                    bool csharp2cuda_temp_1;
#line 202 "GeometryModule.cs"
                    if (((position) > (0)))
                    {
#line 202 "GeometryModule.cs"
                        int csharp2cuda_temp_2 = (indices)[csharp2cuda_i32_sub(position, 1)];
#line 202 "GeometryModule.cs"
                        csharp2cuda_temp_1 = mathblocks_geometry_point_less(points, value, csharp2cuda_temp_2);
                    }
                    else
                    {
#line 202 "GeometryModule.cs"
                        csharp2cuda_temp_1 = false;
                    }
                    if (!(csharp2cuda_temp_1))
                        break;
#line 203 "GeometryModule.cs"
                    {
#line 204 "GeometryModule.cs"
#line 204 "GeometryModule.cs"
                        int* csharp2cuda_temp_3 = &((indices)[position]);
#line 204 "GeometryModule.cs"
                        int csharp2cuda_temp_4 = (indices)[csharp2cuda_i32_sub(position, 1)];
                        (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 205 "GeometryModule.cs"
#line 205 "GeometryModule.cs"
                        int* csharp2cuda_temp_5 = &(position);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_5));
                    }
                }
#line 207 "GeometryModule.cs"
#line 207 "GeometryModule.cs"
                int* csharp2cuda_temp_6 = &((indices)[position]);
                (*(csharp2cuda_temp_6) = value);
            }
#line 198 "GeometryModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 130 "GeometryModule.cs"
__device__ bool mathblocks_geometry_try_circumcircle(
    const double* points,
    int first,
    int second,
    int third,
    double* center_x,
    double* center_y,
    double* radius_square)
#line 139 "GeometryModule.cs"
{
#line 140 "GeometryModule.cs"
    double first_x = (points)[csharp2cuda_i32_mul(2, first)];
#line 141 "GeometryModule.cs"
    double first_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, first), 1)];
#line 142 "GeometryModule.cs"
    double second_x = (points)[csharp2cuda_i32_mul(2, second)];
#line 143 "GeometryModule.cs"
    double second_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, second), 1)];
#line 144 "GeometryModule.cs"
    double third_x = (points)[csharp2cuda_i32_mul(2, third)];
#line 145 "GeometryModule.cs"
    double third_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, third), 1)];
#line 146 "GeometryModule.cs"
    double denominator = __dmul_rn(2.0, __dadd_rn(__dadd_rn(__dmul_rn(first_x, __dsub_rn(second_y, third_y)), __dmul_rn(second_x, __dsub_rn(third_y, first_y))), __dmul_rn(third_x, __dsub_rn(first_y, second_y))));
#line 149 "GeometryModule.cs"
    if (((denominator) == (0.0)))
#line 150 "GeometryModule.cs"
    {
#line 151 "GeometryModule.cs"
#line 151 "GeometryModule.cs"
        double* csharp2cuda_temp_0 = center_x;
        (*(csharp2cuda_temp_0) = 0.0);
#line 152 "GeometryModule.cs"
#line 152 "GeometryModule.cs"
        double* csharp2cuda_temp_1 = center_y;
        (*(csharp2cuda_temp_1) = 0.0);
#line 153 "GeometryModule.cs"
#line 153 "GeometryModule.cs"
        double* csharp2cuda_temp_2 = radius_square;
        (*(csharp2cuda_temp_2) = 0.0);
#line 154 "GeometryModule.cs"
        return false;
    }
#line 156 "GeometryModule.cs"
    double first_square = __dadd_rn(__dmul_rn(first_x, first_x), __dmul_rn(first_y, first_y));
#line 157 "GeometryModule.cs"
    double second_square = __dadd_rn(__dmul_rn(second_x, second_x), __dmul_rn(second_y, second_y));
#line 158 "GeometryModule.cs"
    double third_square = __dadd_rn(__dmul_rn(third_x, third_x), __dmul_rn(third_y, third_y));
#line 159 "GeometryModule.cs"
#line 159 "GeometryModule.cs"
    double* csharp2cuda_temp_3 = center_x;
#line 159 "GeometryModule.cs"
    double csharp2cuda_temp_4 = __ddiv_rn(__dadd_rn(__dadd_rn(__dmul_rn(first_square, __dsub_rn(second_y, third_y)), __dmul_rn(second_square, __dsub_rn(third_y, first_y))), __dmul_rn(third_square, __dsub_rn(first_y, second_y))), denominator);
    (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 162 "GeometryModule.cs"
#line 162 "GeometryModule.cs"
    double* csharp2cuda_temp_5 = center_y;
#line 162 "GeometryModule.cs"
    double csharp2cuda_temp_6 = __ddiv_rn(__dadd_rn(__dadd_rn(__dmul_rn(first_square, __dsub_rn(third_x, second_x)), __dmul_rn(second_square, __dsub_rn(first_x, third_x))), __dmul_rn(third_square, __dsub_rn(second_x, first_x))), denominator);
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 165 "GeometryModule.cs"
    double csharp2cuda_temp_7 = *(center_x);
#line 165 "GeometryModule.cs"
    double x = __dsub_rn(first_x, csharp2cuda_temp_7);
#line 166 "GeometryModule.cs"
    double csharp2cuda_temp_8 = *(center_y);
#line 166 "GeometryModule.cs"
    double y = __dsub_rn(first_y, csharp2cuda_temp_8);
#line 167 "GeometryModule.cs"
#line 167 "GeometryModule.cs"
    double* csharp2cuda_temp_9 = radius_square;
    (*(csharp2cuda_temp_9) = __dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y)));
#line 168 "GeometryModule.cs"
    return true;
}