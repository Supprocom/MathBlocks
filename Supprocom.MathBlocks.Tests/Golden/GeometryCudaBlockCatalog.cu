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

#line 40 "GeometryModule.cs"
struct MathBlockGeometryEdge
{
    int from;
    int to;
    double weight;
};

#line 110 "GeometryModule.cs"
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

#line 73 "GeometryModule.cs"
__device__ double mathblocks_geometry_cross(
    double origin_x,
    double origin_y,
    double left_x,
    double left_y,
    double right_x,
    double right_y);

#line 349 "GeometryModule.cs"
__device__ void mathblocks_geometry_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 59 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance(
    const double* left,
    int left_index,
    const double* right,
    int right_index);

#line 47 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance_coordinates(
    double left_x,
    double left_y,
    double right_x,
    double right_y);

#line 296 "GeometryModule.cs"
__device__ bool mathblocks_geometry_edge_less(
    const MathBlockGeometryEdge* left,
    const MathBlockGeometryEdge* right);

#line 285 "GeometryModule.cs"
__device__ int mathblocks_geometry_find(int* parent, int value);

#line 196 "GeometryModule.cs"
__device__ void mathblocks_geometry_index_order(
    const double* points,
    int count,
    int* order,
    int* buffer);

#line 174 "GeometryModule.cs"
__device__ bool mathblocks_geometry_point_less(
    const double* points,
    int left,
    int right);

#line 86 "GeometryModule.cs"
__device__ double mathblocks_geometry_point_to_segment(
    double point_x,
    double point_y,
    double start_x,
    double start_y,
    double end_x,
    double end_y);

#line 314 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_edges(MathBlockGeometryEdge* edges, MathBlockGeometryEdge* buffer, int count);

#line 238 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_points(double* points, double* buffer, int count);

#line 133 "GeometryModule.cs"
__device__ bool mathblocks_geometry_try_circumcircle(
    const double* points,
    int first,
    int second,
    int third,
    double* center_x,
    double* center_y,
    double* radius_square);

#line 110 "GeometryModule.cs"
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
#line 121 "GeometryModule.cs"
{
#line 122 "GeometryModule.cs"
    double denominator = __dadd_rn(__dmul_rn(__dsub_rn(second_y, third_y), __dsub_rn(first_x, third_x)), __dmul_rn(__dsub_rn(third_x, second_x), __dsub_rn(first_y, third_y)));
#line 124 "GeometryModule.cs"
    double first_weight = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(second_y, third_y), __dsub_rn(point_x, third_x)), __dmul_rn(__dsub_rn(third_x, second_x), __dsub_rn(point_y, third_y))), denominator);
#line 126 "GeometryModule.cs"
    double second_weight = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(third_y, first_y), __dsub_rn(point_x, third_x)), __dmul_rn(__dsub_rn(first_x, third_x), __dsub_rn(point_y, third_y))), denominator);
#line 128 "GeometryModule.cs"
#line 128 "GeometryModule.cs"
    double* csharp2cuda_temp_0 = &((result)[0]);
    (*(csharp2cuda_temp_0) = first_weight);
#line 129 "GeometryModule.cs"
#line 129 "GeometryModule.cs"
    double* csharp2cuda_temp_1 = &((result)[1]);
    (*(csharp2cuda_temp_1) = second_weight);
#line 130 "GeometryModule.cs"
#line 130 "GeometryModule.cs"
    double* csharp2cuda_temp_2 = &((result)[2]);
    (*(csharp2cuda_temp_2) = __dsub_rn(__dsub_rn(1.0, first_weight), second_weight));
}

#line 73 "GeometryModule.cs"
__device__ double mathblocks_geometry_cross(
    double origin_x,
    double origin_y,
    double left_x,
    double left_y,
    double right_x,
    double right_y)
#line 81 "GeometryModule.cs"
{
#line 82 "GeometryModule.cs"
    return __dsub_rn(__dmul_rn(__dsub_rn(left_x, origin_x), __dsub_rn(right_y, origin_y)), __dmul_rn(__dsub_rn(left_y, origin_y), __dsub_rn(right_x, origin_x)));
}

#line 349 "GeometryModule.cs"
__device__ void mathblocks_geometry_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 355 "GeometryModule.cs"
{
#line 356 "GeometryModule.cs"
    int thread = threadIdx.x;
#line 357 "GeometryModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 357 "GeometryModule.cs"
    if (((input_count) > (0)))
    {
#line 357 "GeometryModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 357 "GeometryModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 357 "GeometryModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 358 "GeometryModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 358 "GeometryModule.cs"
    if (((input_count) > (1)))
    {
#line 358 "GeometryModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 358 "GeometryModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 358 "GeometryModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 359 "GeometryModule.cs"
    if (((thread) == (0)))
#line 360 "GeometryModule.cs"
    {
#line 361 "GeometryModule.cs"
#line 361 "GeometryModule.cs"
        double* csharp2cuda_temp_2 = &((output)->scalar_value);
        (*(csharp2cuda_temp_2) = 0.0);
#line 362 "GeometryModule.cs"
#line 362 "GeometryModule.cs"
        int* csharp2cuda_temp_3 = &((output)->boolean_value);
        (*(csharp2cuda_temp_3) = 0);
#line 363 "GeometryModule.cs"
#line 363 "GeometryModule.cs"
        int* csharp2cuda_temp_4 = &((output)->rows);
        (*(csharp2cuda_temp_4) = 0);
#line 364 "GeometryModule.cs"
#line 364 "GeometryModule.cs"
        int* csharp2cuda_temp_5 = &((output)->columns);
        (*(csharp2cuda_temp_5) = 0);
#line 365 "GeometryModule.cs"
#line 365 "GeometryModule.cs"
        int* csharp2cuda_temp_6 = &((output)->count);
        (*(csharp2cuda_temp_6) = 0);
#line 366 "GeometryModule.cs"
#line 366 "GeometryModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
#line 366 "GeometryModule.cs"
        bool csharp2cuda_temp_8;
#line 366 "GeometryModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 366 "GeometryModule.cs"
            csharp2cuda_temp_8 = (first)->valid;
        }
        else
        {
#line 366 "GeometryModule.cs"
            csharp2cuda_temp_8 = true;
        }
        (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 367 "GeometryModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 368 "GeometryModule.cs"
#line 368 "GeometryModule.cs"
            int* csharp2cuda_temp_9 = &((output)->valid);
#line 368 "GeometryModule.cs"
            bool csharp2cuda_temp_10 = (output)->valid;
#line 368 "GeometryModule.cs"
            bool csharp2cuda_temp_11;
#line 368 "GeometryModule.cs"
            if (csharp2cuda_temp_10)
            {
#line 368 "GeometryModule.cs"
                csharp2cuda_temp_11 = (second)->valid;
            }
            else
            {
#line 368 "GeometryModule.cs"
                csharp2cuda_temp_11 = false;
            }
            (*(csharp2cuda_temp_9) = csharp2cuda_temp_11);
        }
    }
#line 370 "GeometryModule.cs"
    __syncthreads();
#line 371 "GeometryModule.cs"
#line 371 "GeometryModule.cs"
    bool csharp2cuda_temp_12 = (output)->valid;
    if ((!(csharp2cuda_temp_12)))
    {
#line 372 "GeometryModule.cs"
        return;
    }
#line 374 "GeometryModule.cs"
    double* csharp2cuda_temp_13;
#line 374 "GeometryModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 374 "GeometryModule.cs"
        csharp2cuda_temp_13 = ((double*)(nullptr));
    }
    else
    {
#line 374 "GeometryModule.cs"
        unsigned long long csharp2cuda_temp_14 = (first)->data_pointer;
#line 374 "GeometryModule.cs"
        csharp2cuda_temp_13 = ((double*)(csharp2cuda_temp_14));
    }
#line 374 "GeometryModule.cs"
    const double* a = csharp2cuda_temp_13;
#line 375 "GeometryModule.cs"
    double* csharp2cuda_temp_15;
#line 375 "GeometryModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 375 "GeometryModule.cs"
        csharp2cuda_temp_15 = ((double*)(nullptr));
    }
    else
    {
#line 375 "GeometryModule.cs"
        unsigned long long csharp2cuda_temp_16 = (second)->data_pointer;
#line 375 "GeometryModule.cs"
        csharp2cuda_temp_15 = ((double*)(csharp2cuda_temp_16));
    }
#line 375 "GeometryModule.cs"
    const double* b = csharp2cuda_temp_15;
#line 376 "GeometryModule.cs"
    unsigned long long csharp2cuda_temp_17 = (output)->data_pointer;
#line 376 "GeometryModule.cs"
    double* result = ((double*)(csharp2cuda_temp_17));
#line 377 "GeometryModule.cs"
    unsigned long long csharp2cuda_temp_18 = (output)->scratch_pointer;
#line 377 "GeometryModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_18));
#line 379 "GeometryModule.cs"
    if (((thread) == (0)))
#line 380 "GeometryModule.cs"
    {
#line 381 "GeometryModule.cs"
        switch (opcode)
        {
#line 383 "GeometryModule.cs"
            case 0:
#line 384 "GeometryModule.cs"
                mathblocks_sequence_set_vector_shape(output, 3);
#line 385 "GeometryModule.cs"
#line 385 "GeometryModule.cs"
                int csharp2cuda_temp_19 = (first)->count;
#line 385 "GeometryModule.cs"
                bool csharp2cuda_temp_20;
#line 385 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_19) != (1))))
                {
#line 385 "GeometryModule.cs"
                    int csharp2cuda_temp_21 = (second)->count;
#line 385 "GeometryModule.cs"
                    csharp2cuda_temp_20 = ((csharp2cuda_temp_21) != (3));
                }
                else
                {
#line 385 "GeometryModule.cs"
                    csharp2cuda_temp_20 = true;
                }
                if (csharp2cuda_temp_20)
#line 386 "GeometryModule.cs"
                {
#line 387 "GeometryModule.cs"
#line 387 "GeometryModule.cs"
                    int* csharp2cuda_temp_22 = &((output)->valid);
                    (*(csharp2cuda_temp_22) = 0);
#line 388 "GeometryModule.cs"
                    break;
                }
#line 390 "GeometryModule.cs"
#line 391 "GeometryModule.cs"
                double csharp2cuda_temp_23 = (a)[0];
#line 391 "GeometryModule.cs"
                double csharp2cuda_temp_24 = (a)[1];
#line 391 "GeometryModule.cs"
                double csharp2cuda_temp_25 = (b)[0];
#line 391 "GeometryModule.cs"
                double csharp2cuda_temp_26 = (b)[1];
#line 391 "GeometryModule.cs"
                double csharp2cuda_temp_27 = (b)[2];
#line 391 "GeometryModule.cs"
                double csharp2cuda_temp_28 = (b)[3];
#line 391 "GeometryModule.cs"
                double csharp2cuda_temp_29 = (b)[4];
#line 391 "GeometryModule.cs"
                double csharp2cuda_temp_30 = (b)[5];
                mathblocks_geometry_barycentric(csharp2cuda_temp_23, csharp2cuda_temp_24, csharp2cuda_temp_25, csharp2cuda_temp_26, csharp2cuda_temp_27, csharp2cuda_temp_28, csharp2cuda_temp_29, csharp2cuda_temp_30, result);
#line 392 "GeometryModule.cs"
                {
#line 392 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (3))))
                            break;
#line 393 "GeometryModule.cs"
#line 393 "GeometryModule.cs"
                        double csharp2cuda_temp_32 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_32))))
                        {
#line 393 "GeometryModule.cs"
#line 393 "GeometryModule.cs"
                            int* csharp2cuda_temp_33 = &((output)->valid);
                            (*(csharp2cuda_temp_33) = 0);
                        }
#line 392 "GeometryModule.cs"
                        int* csharp2cuda_temp_31 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                    }
                }
#line 394 "GeometryModule.cs"
                break;
#line 395 "GeometryModule.cs"
            case 1:
#line 396 "GeometryModule.cs"
#line 396 "GeometryModule.cs"
                int* csharp2cuda_temp_34 = &((output)->rows);
                (*(csharp2cuda_temp_34) = 1);
#line 397 "GeometryModule.cs"
#line 397 "GeometryModule.cs"
                int* csharp2cuda_temp_35 = &((output)->count);
                (*(csharp2cuda_temp_35) = 1);
#line 398 "GeometryModule.cs"
#line 398 "GeometryModule.cs"
                int csharp2cuda_temp_36 = (first)->count;
#line 398 "GeometryModule.cs"
                bool csharp2cuda_temp_37;
#line 398 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_36) <= (0))))
                {
#line 398 "GeometryModule.cs"
                    int csharp2cuda_temp_38 = (output)->capacity;
#line 398 "GeometryModule.cs"
                    csharp2cuda_temp_37 = ((csharp2cuda_temp_38) < (1));
                }
                else
                {
#line 398 "GeometryModule.cs"
                    csharp2cuda_temp_37 = true;
                }
                if (csharp2cuda_temp_37)
#line 399 "GeometryModule.cs"
                {
#line 400 "GeometryModule.cs"
#line 400 "GeometryModule.cs"
                    int* csharp2cuda_temp_39 = &((output)->valid);
                    (*(csharp2cuda_temp_39) = 0);
#line 401 "GeometryModule.cs"
                    break;
                }
#line 403 "GeometryModule.cs"
#line 403 "GeometryModule.cs"
                double* csharp2cuda_temp_40 = &((result)[0]);
                (*(csharp2cuda_temp_40) = 0.0);
#line 404 "GeometryModule.cs"
#line 404 "GeometryModule.cs"
                double* csharp2cuda_temp_41 = &((result)[1]);
                (*(csharp2cuda_temp_41) = 0.0);
#line 405 "GeometryModule.cs"
                {
#line 405 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 405 "GeometryModule.cs"
                        int csharp2cuda_temp_43 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_43))))
                            break;
#line 406 "GeometryModule.cs"
                        {
#line 407 "GeometryModule.cs"
#line 407 "GeometryModule.cs"
                            double* csharp2cuda_temp_44 = &((result)[0]);
#line 407 "GeometryModule.cs"
                            double csharp2cuda_temp_45 = *(csharp2cuda_temp_44);
#line 407 "GeometryModule.cs"
                            double csharp2cuda_temp_46 = (a)[csharp2cuda_i32_mul(2, index)];
                            (*(csharp2cuda_temp_44) = __dadd_rn(csharp2cuda_temp_45, csharp2cuda_temp_46));
#line 408 "GeometryModule.cs"
#line 408 "GeometryModule.cs"
                            double* csharp2cuda_temp_47 = &((result)[1]);
#line 408 "GeometryModule.cs"
                            double csharp2cuda_temp_48 = *(csharp2cuda_temp_47);
#line 408 "GeometryModule.cs"
                            double csharp2cuda_temp_49 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                            (*(csharp2cuda_temp_47) = __dadd_rn(csharp2cuda_temp_48, csharp2cuda_temp_49));
                        }
#line 405 "GeometryModule.cs"
                        int* csharp2cuda_temp_42 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_42));
                    }
                }
#line 410 "GeometryModule.cs"
#line 410 "GeometryModule.cs"
                double* csharp2cuda_temp_50 = &((result)[0]);
#line 410 "GeometryModule.cs"
                double csharp2cuda_temp_51 = *(csharp2cuda_temp_50);
#line 410 "GeometryModule.cs"
                int csharp2cuda_temp_52 = (first)->count;
                (*(csharp2cuda_temp_50) = __ddiv_rn(csharp2cuda_temp_51, ((double)(csharp2cuda_temp_52))));
#line 411 "GeometryModule.cs"
#line 411 "GeometryModule.cs"
                double* csharp2cuda_temp_53 = &((result)[1]);
#line 411 "GeometryModule.cs"
                double csharp2cuda_temp_54 = *(csharp2cuda_temp_53);
#line 411 "GeometryModule.cs"
                int csharp2cuda_temp_55 = (first)->count;
                (*(csharp2cuda_temp_53) = __ddiv_rn(csharp2cuda_temp_54, ((double)(csharp2cuda_temp_55))));
#line 412 "GeometryModule.cs"
#line 412 "GeometryModule.cs"
                double csharp2cuda_temp_56 = (result)[0];
#line 412 "GeometryModule.cs"
                bool csharp2cuda_temp_57;
#line 412 "GeometryModule.cs"
                if (!((!(isfinite(csharp2cuda_temp_56)))))
                {
#line 412 "GeometryModule.cs"
                    double csharp2cuda_temp_58 = (result)[1];
#line 412 "GeometryModule.cs"
                    csharp2cuda_temp_57 = (!(isfinite(csharp2cuda_temp_58)));
                }
                else
                {
#line 412 "GeometryModule.cs"
                    csharp2cuda_temp_57 = true;
                }
                if (csharp2cuda_temp_57)
                {
#line 412 "GeometryModule.cs"
#line 412 "GeometryModule.cs"
                    int* csharp2cuda_temp_59 = &((output)->valid);
                    (*(csharp2cuda_temp_59) = 0);
                }
#line 413 "GeometryModule.cs"
                break;
#line 414 "GeometryModule.cs"
            case 2:
#line 415 "GeometryModule.cs"
#line 415 "GeometryModule.cs"
                int csharp2cuda_temp_60 = (first)->count;
                if (((csharp2cuda_temp_60) != (3)))
#line 416 "GeometryModule.cs"
                {
#line 417 "GeometryModule.cs"
#line 417 "GeometryModule.cs"
                    int* csharp2cuda_temp_61 = &((output)->valid);
                    (*(csharp2cuda_temp_61) = 0);
#line 418 "GeometryModule.cs"
                    break;
                }
#line 420 "GeometryModule.cs"
                {
#line 421 "GeometryModule.cs"
                    double first_length = mathblocks_geometry_distance(a, 1, a, 2);
#line 422 "GeometryModule.cs"
                    double second_length = mathblocks_geometry_distance(a, 0, a, 2);
#line 423 "GeometryModule.cs"
                    double third_length = mathblocks_geometry_distance(a, 0, a, 1);
#line 425 "GeometryModule.cs"
                    double csharp2cuda_temp_62 = (a)[0];
#line 425 "GeometryModule.cs"
                    double csharp2cuda_temp_63 = (a)[1];
#line 425 "GeometryModule.cs"
                    double csharp2cuda_temp_64 = (a)[2];
#line 425 "GeometryModule.cs"
                    double csharp2cuda_temp_65 = (a)[3];
#line 425 "GeometryModule.cs"
                    double csharp2cuda_temp_66 = (a)[4];
#line 425 "GeometryModule.cs"
                    double csharp2cuda_temp_67 = (a)[5];
#line 424 "GeometryModule.cs"
                    double cross = mathblocks_geometry_cross(csharp2cuda_temp_62, csharp2cuda_temp_63, csharp2cuda_temp_64, csharp2cuda_temp_65, csharp2cuda_temp_66, csharp2cuda_temp_67);
#line 426 "GeometryModule.cs"
#line 426 "GeometryModule.cs"
                    double* csharp2cuda_temp_68 = &((output)->scalar_value);
#line 426 "GeometryModule.cs"
                    double csharp2cuda_temp_69 = __ddiv_rn(__dmul_rn(__dmul_rn(first_length, second_length), third_length), __dmul_rn(2.0, fabs(cross)));
                    (*(csharp2cuda_temp_68) = csharp2cuda_temp_69);
#line 428 "GeometryModule.cs"
                    break;
                }
#line 430 "GeometryModule.cs"
            case 3:
#line 431 "GeometryModule.cs"
#line 431 "GeometryModule.cs"
                int csharp2cuda_temp_70 = (first)->count;
#line 431 "GeometryModule.cs"
                bool csharp2cuda_temp_71;
#line 431 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_70) < (3))))
                {
#line 431 "GeometryModule.cs"
                    int csharp2cuda_temp_72 = (second)->count;
#line 431 "GeometryModule.cs"
                    csharp2cuda_temp_71 = ((csharp2cuda_temp_72) != (1));
                }
                else
                {
#line 431 "GeometryModule.cs"
                    csharp2cuda_temp_71 = true;
                }
                if (csharp2cuda_temp_71)
#line 432 "GeometryModule.cs"
                {
#line 433 "GeometryModule.cs"
#line 433 "GeometryModule.cs"
                    int* csharp2cuda_temp_73 = &((output)->valid);
                    (*(csharp2cuda_temp_73) = 0);
#line 434 "GeometryModule.cs"
                    break;
                }
#line 436 "GeometryModule.cs"
                {
#line 437 "GeometryModule.cs"
                    bool inside = false;
#line 438 "GeometryModule.cs"
                    double point_x = (b)[0];
#line 439 "GeometryModule.cs"
                    double point_y = (b)[1];
#line 440 "GeometryModule.cs"
                    {
#line 440 "GeometryModule.cs"
                        int current = 0;
                        while (true)
                        {
#line 440 "GeometryModule.cs"
                            int csharp2cuda_temp_75 = (first)->count;
                            if (!(((current) < (csharp2cuda_temp_75))))
                                break;
#line 441 "GeometryModule.cs"
                            {
#line 442 "GeometryModule.cs"
                                int csharp2cuda_temp_76;
#line 442 "GeometryModule.cs"
                                if (((current) == (0)))
                                {
#line 442 "GeometryModule.cs"
                                    int csharp2cuda_temp_77 = (first)->count;
#line 442 "GeometryModule.cs"
                                    csharp2cuda_temp_76 = csharp2cuda_i32_sub(csharp2cuda_temp_77, 1);
                                }
                                else
                                {
#line 442 "GeometryModule.cs"
                                    csharp2cuda_temp_76 = csharp2cuda_i32_sub(current, 1);
                                }
#line 442 "GeometryModule.cs"
                                int previous = csharp2cuda_temp_76;
#line 443 "GeometryModule.cs"
                                double left_x = (a)[csharp2cuda_i32_mul(2, current)];
#line 444 "GeometryModule.cs"
                                double left_y = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, current), 1)];
#line 445 "GeometryModule.cs"
                                double right_x = (a)[csharp2cuda_i32_mul(2, previous)];
#line 446 "GeometryModule.cs"
                                double right_y = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, previous), 1)];
#line 447 "GeometryModule.cs"
                                if (((mathblocks_geometry_point_to_segment(point_x, point_y, left_x, left_y, right_x, right_y)) == (0.0)))
#line 449 "GeometryModule.cs"
                                {
#line 450 "GeometryModule.cs"
#line 450 "GeometryModule.cs"
                                    bool* csharp2cuda_temp_78 = &(inside);
                                    (*(csharp2cuda_temp_78) = true);
#line 451 "GeometryModule.cs"
                                    break;
                                }
#line 453 "GeometryModule.cs"
#line 453 "GeometryModule.cs"
                                bool csharp2cuda_temp_79;
#line 453 "GeometryModule.cs"
                                if (((((left_y) > (point_y))) != (((right_y) > (point_y)))))
                                {
#line 454 "GeometryModule.cs"
                                    double csharp2cuda_temp_80 = __ddiv_rn(__dmul_rn(__dsub_rn(right_x, left_x), __dsub_rn(point_y, left_y)), __dsub_rn(right_y, left_y));
#line 453 "GeometryModule.cs"
                                    csharp2cuda_temp_79 = ((point_x) < (__dadd_rn(csharp2cuda_temp_80, left_x)));
                                }
                                else
                                {
#line 453 "GeometryModule.cs"
                                    csharp2cuda_temp_79 = false;
                                }
                                if (csharp2cuda_temp_79)
#line 456 "GeometryModule.cs"
                                {
#line 457 "GeometryModule.cs"
#line 457 "GeometryModule.cs"
                                    bool* csharp2cuda_temp_81 = &(inside);
                                    (*(csharp2cuda_temp_81) = (!(inside)));
                                }
                            }
#line 440 "GeometryModule.cs"
                            int* csharp2cuda_temp_74 = &(current);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_74));
                        }
                    }
#line 460 "GeometryModule.cs"
#line 460 "GeometryModule.cs"
                    int* csharp2cuda_temp_82 = &((output)->boolean_value);
#line 460 "GeometryModule.cs"
                    int csharp2cuda_temp_83;
#line 460 "GeometryModule.cs"
                    if (inside)
                    {
#line 460 "GeometryModule.cs"
                        csharp2cuda_temp_83 = 1;
                    }
                    else
                    {
#line 460 "GeometryModule.cs"
                        csharp2cuda_temp_83 = 0;
                    }
                    (*(csharp2cuda_temp_82) = csharp2cuda_temp_83);
#line 461 "GeometryModule.cs"
                    break;
                }
#line 463 "GeometryModule.cs"
            case 4:
#line 464 "GeometryModule.cs"
#line 464 "GeometryModule.cs"
                int csharp2cuda_temp_84 = (first)->count;
#line 464 "GeometryModule.cs"
                bool csharp2cuda_temp_85;
#line 464 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_84) <= (0))))
                {
#line 464 "GeometryModule.cs"
                    csharp2cuda_temp_85 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 464 "GeometryModule.cs"
                    csharp2cuda_temp_85 = true;
                }
                if (csharp2cuda_temp_85)
#line 465 "GeometryModule.cs"
                {
#line 466 "GeometryModule.cs"
#line 466 "GeometryModule.cs"
                    int* csharp2cuda_temp_86 = &((output)->valid);
                    (*(csharp2cuda_temp_86) = 0);
#line 467 "GeometryModule.cs"
                    break;
                }
#line 469 "GeometryModule.cs"
                {
#line 470 "GeometryModule.cs"
                    double* sorted = scratch;
#line 471 "GeometryModule.cs"
                    int csharp2cuda_temp_87 = (first)->count;
#line 471 "GeometryModule.cs"
                    double* hull = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(csharp2cuda_temp_87, 4));
#line 472 "GeometryModule.cs"
                    {
#line 472 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 472 "GeometryModule.cs"
                            int csharp2cuda_temp_89 = (first)->count;
                            if (!(((index) < (csharp2cuda_i32_mul(csharp2cuda_temp_89, 2)))))
                                break;
#line 473 "GeometryModule.cs"
#line 473 "GeometryModule.cs"
                            double* csharp2cuda_temp_90 = &((sorted)[index]);
#line 473 "GeometryModule.cs"
                            double csharp2cuda_temp_91 = (a)[index];
                            (*(csharp2cuda_temp_90) = csharp2cuda_temp_91);
#line 472 "GeometryModule.cs"
                            int* csharp2cuda_temp_88 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_88));
                        }
                    }
#line 474 "GeometryModule.cs"
#line 474 "GeometryModule.cs"
                    int csharp2cuda_temp_92 = (first)->count;
#line 474 "GeometryModule.cs"
                    int csharp2cuda_temp_93 = (first)->count;
                    mathblocks_geometry_sort_points(sorted, csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(csharp2cuda_temp_92, 2)), csharp2cuda_temp_93);
#line 475 "GeometryModule.cs"
                    int unique_count = 0;
#line 476 "GeometryModule.cs"
                    {
#line 476 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 476 "GeometryModule.cs"
                            int csharp2cuda_temp_95 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_95))))
                                break;
#line 477 "GeometryModule.cs"
                            {
#line 478 "GeometryModule.cs"
                                double x = (sorted)[csharp2cuda_i32_mul(2, index)];
#line 479 "GeometryModule.cs"
                                double y = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 480 "GeometryModule.cs"
#line 480 "GeometryModule.cs"
                                bool csharp2cuda_temp_96;
#line 480 "GeometryModule.cs"
                                if (((unique_count) > (0)))
                                {
#line 480 "GeometryModule.cs"
                                    double csharp2cuda_temp_97 = (sorted)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(unique_count, 1))];
#line 480 "GeometryModule.cs"
                                    csharp2cuda_temp_96 = ((csharp2cuda_temp_97) == (x));
                                }
                                else
                                {
#line 480 "GeometryModule.cs"
                                    csharp2cuda_temp_96 = false;
                                }
#line 480 "GeometryModule.cs"
                                bool csharp2cuda_temp_98;
#line 480 "GeometryModule.cs"
                                if (csharp2cuda_temp_96)
                                {
#line 480 "GeometryModule.cs"
                                    double csharp2cuda_temp_99 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(unique_count, 1)), 1)];
#line 480 "GeometryModule.cs"
                                    csharp2cuda_temp_98 = ((csharp2cuda_temp_99) == (y));
                                }
                                else
                                {
#line 480 "GeometryModule.cs"
                                    csharp2cuda_temp_98 = false;
                                }
                                if (csharp2cuda_temp_98)
                                {
#line 481 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_4;
                                }
#line 482 "GeometryModule.cs"
#line 482 "GeometryModule.cs"
                                double* csharp2cuda_temp_100 = &((sorted)[csharp2cuda_i32_mul(2, unique_count)]);
                                (*(csharp2cuda_temp_100) = x);
#line 483 "GeometryModule.cs"
#line 483 "GeometryModule.cs"
                                double* csharp2cuda_temp_101 = &((sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, unique_count), 1)]);
                                (*(csharp2cuda_temp_101) = y);
#line 484 "GeometryModule.cs"
#line 484 "GeometryModule.cs"
                                int* csharp2cuda_temp_102 = &(unique_count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_102));
                            }
                            csharp2cuda_for_continue_4:
#line 476 "GeometryModule.cs"
                            int* csharp2cuda_temp_94 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_94));
                        }
                    }
#line 486 "GeometryModule.cs"
                    int count = 0;
#line 487 "GeometryModule.cs"
                    if (((unique_count) <= (1)))
#line 488 "GeometryModule.cs"
                    {
#line 489 "GeometryModule.cs"
#line 489 "GeometryModule.cs"
                        int* csharp2cuda_temp_103 = &(count);
                        (*(csharp2cuda_temp_103) = unique_count);
#line 490 "GeometryModule.cs"
                        if (((count) == (1)))
#line 491 "GeometryModule.cs"
                        {
#line 492 "GeometryModule.cs"
#line 492 "GeometryModule.cs"
                            double* csharp2cuda_temp_104 = &((hull)[0]);
#line 492 "GeometryModule.cs"
                            double csharp2cuda_temp_105 = (sorted)[0];
                            (*(csharp2cuda_temp_104) = csharp2cuda_temp_105);
#line 493 "GeometryModule.cs"
#line 493 "GeometryModule.cs"
                            double* csharp2cuda_temp_106 = &((hull)[1]);
#line 493 "GeometryModule.cs"
                            double csharp2cuda_temp_107 = (sorted)[1];
                            (*(csharp2cuda_temp_106) = csharp2cuda_temp_107);
                        }
                    }
                    else
#line 497 "GeometryModule.cs"
                    {
#line 498 "GeometryModule.cs"
                        {
#line 498 "GeometryModule.cs"
                            int index = 0;
                            while (true)
                            {
                                if (!(((index) < (unique_count))))
                                    break;
#line 499 "GeometryModule.cs"
                                {
#line 500 "GeometryModule.cs"
                                    while (true)
                                    {
#line 500 "GeometryModule.cs"
                                        bool csharp2cuda_temp_109;
#line 500 "GeometryModule.cs"
                                        if (((count) >= (2)))
                                        {
#line 501 "GeometryModule.cs"
                                            double csharp2cuda_temp_110 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2))];
#line 501 "GeometryModule.cs"
                                            double csharp2cuda_temp_111 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2)), 1)];
#line 502 "GeometryModule.cs"
                                            double csharp2cuda_temp_112 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1))];
#line 502 "GeometryModule.cs"
                                            double csharp2cuda_temp_113 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1)), 1)];
#line 503 "GeometryModule.cs"
                                            double csharp2cuda_temp_114 = (sorted)[csharp2cuda_i32_mul(2, index)];
#line 503 "GeometryModule.cs"
                                            double csharp2cuda_temp_115 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 500 "GeometryModule.cs"
                                            csharp2cuda_temp_109 = ((mathblocks_geometry_cross(csharp2cuda_temp_110, csharp2cuda_temp_111, csharp2cuda_temp_112, csharp2cuda_temp_113, csharp2cuda_temp_114, csharp2cuda_temp_115)) <= (0.0));
                                        }
                                        else
                                        {
#line 500 "GeometryModule.cs"
                                            csharp2cuda_temp_109 = false;
                                        }
                                        if (!(csharp2cuda_temp_109))
                                            break;
#line 504 "GeometryModule.cs"
                                        {
#line 505 "GeometryModule.cs"
#line 505 "GeometryModule.cs"
                                            int* csharp2cuda_temp_116 = &(count);
                                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_116));
                                        }
                                    }
#line 507 "GeometryModule.cs"
#line 507 "GeometryModule.cs"
                                    double* csharp2cuda_temp_117 = &((hull)[csharp2cuda_i32_mul(2, count)]);
#line 507 "GeometryModule.cs"
                                    double csharp2cuda_temp_118 = (sorted)[csharp2cuda_i32_mul(2, index)];
                                    (*(csharp2cuda_temp_117) = csharp2cuda_temp_118);
#line 508 "GeometryModule.cs"
#line 508 "GeometryModule.cs"
                                    double* csharp2cuda_temp_119 = &((hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, count), 1)]);
#line 508 "GeometryModule.cs"
                                    double csharp2cuda_temp_120 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                    (*(csharp2cuda_temp_119) = csharp2cuda_temp_120);
#line 509 "GeometryModule.cs"
#line 509 "GeometryModule.cs"
                                    int* csharp2cuda_temp_121 = &(count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_121));
                                }
#line 498 "GeometryModule.cs"
                                int* csharp2cuda_temp_108 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_108));
                            }
                        }
#line 511 "GeometryModule.cs"
                        int lower_count = count;
#line 512 "GeometryModule.cs"
                        {
#line 512 "GeometryModule.cs"
                            int index = csharp2cuda_i32_sub(unique_count, 2);
                            while (true)
                            {
                                if (!(((index) >= (0))))
                                    break;
#line 513 "GeometryModule.cs"
                                {
#line 514 "GeometryModule.cs"
                                    while (true)
                                    {
#line 514 "GeometryModule.cs"
                                        bool csharp2cuda_temp_123;
#line 514 "GeometryModule.cs"
                                        if (((count) > (lower_count)))
                                        {
#line 515 "GeometryModule.cs"
                                            double csharp2cuda_temp_124 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2))];
#line 515 "GeometryModule.cs"
                                            double csharp2cuda_temp_125 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2)), 1)];
#line 516 "GeometryModule.cs"
                                            double csharp2cuda_temp_126 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1))];
#line 516 "GeometryModule.cs"
                                            double csharp2cuda_temp_127 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1)), 1)];
#line 517 "GeometryModule.cs"
                                            double csharp2cuda_temp_128 = (sorted)[csharp2cuda_i32_mul(2, index)];
#line 517 "GeometryModule.cs"
                                            double csharp2cuda_temp_129 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 514 "GeometryModule.cs"
                                            csharp2cuda_temp_123 = ((mathblocks_geometry_cross(csharp2cuda_temp_124, csharp2cuda_temp_125, csharp2cuda_temp_126, csharp2cuda_temp_127, csharp2cuda_temp_128, csharp2cuda_temp_129)) <= (0.0));
                                        }
                                        else
                                        {
#line 514 "GeometryModule.cs"
                                            csharp2cuda_temp_123 = false;
                                        }
                                        if (!(csharp2cuda_temp_123))
                                            break;
#line 518 "GeometryModule.cs"
                                        {
#line 519 "GeometryModule.cs"
#line 519 "GeometryModule.cs"
                                            int* csharp2cuda_temp_130 = &(count);
                                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_130));
                                        }
                                    }
#line 521 "GeometryModule.cs"
#line 521 "GeometryModule.cs"
                                    double* csharp2cuda_temp_131 = &((hull)[csharp2cuda_i32_mul(2, count)]);
#line 521 "GeometryModule.cs"
                                    double csharp2cuda_temp_132 = (sorted)[csharp2cuda_i32_mul(2, index)];
                                    (*(csharp2cuda_temp_131) = csharp2cuda_temp_132);
#line 522 "GeometryModule.cs"
#line 522 "GeometryModule.cs"
                                    double* csharp2cuda_temp_133 = &((hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, count), 1)]);
#line 522 "GeometryModule.cs"
                                    double csharp2cuda_temp_134 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                    (*(csharp2cuda_temp_133) = csharp2cuda_temp_134);
#line 523 "GeometryModule.cs"
#line 523 "GeometryModule.cs"
                                    int* csharp2cuda_temp_135 = &(count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_135));
                                }
#line 512 "GeometryModule.cs"
                                int* csharp2cuda_temp_122 = &(index);
                                csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_122));
                            }
                        }
#line 525 "GeometryModule.cs"
#line 525 "GeometryModule.cs"
                        int* csharp2cuda_temp_136 = &(count);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_136));
                    }
#line 527 "GeometryModule.cs"
#line 527 "GeometryModule.cs"
                    int* csharp2cuda_temp_137 = &((output)->rows);
                    (*(csharp2cuda_temp_137) = count);
#line 528 "GeometryModule.cs"
#line 528 "GeometryModule.cs"
                    int* csharp2cuda_temp_138 = &((output)->count);
                    (*(csharp2cuda_temp_138) = count);
#line 529 "GeometryModule.cs"
#line 529 "GeometryModule.cs"
                    int csharp2cuda_temp_139 = (output)->capacity;
                    if (((count) > (csharp2cuda_temp_139)))
#line 530 "GeometryModule.cs"
                    {
#line 531 "GeometryModule.cs"
#line 531 "GeometryModule.cs"
                        int* csharp2cuda_temp_140 = &((output)->valid);
                        (*(csharp2cuda_temp_140) = 0);
#line 532 "GeometryModule.cs"
                        break;
                    }
#line 534 "GeometryModule.cs"
                    {
#line 534 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(count, 2)))))
                                break;
#line 535 "GeometryModule.cs"
#line 535 "GeometryModule.cs"
                            double* csharp2cuda_temp_142 = &((result)[index]);
#line 535 "GeometryModule.cs"
                            double csharp2cuda_temp_143 = (hull)[index];
                            (*(csharp2cuda_temp_142) = csharp2cuda_temp_143);
#line 534 "GeometryModule.cs"
                            int* csharp2cuda_temp_141 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_141));
                        }
                    }
#line 536 "GeometryModule.cs"
                    break;
                }
#line 538 "GeometryModule.cs"
            case 5:
#line 539 "GeometryModule.cs"
#line 539 "GeometryModule.cs"
                int csharp2cuda_temp_144 = (first)->count;
#line 539 "GeometryModule.cs"
                bool csharp2cuda_temp_145;
#line 539 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_144) < (2))))
                {
#line 539 "GeometryModule.cs"
                    csharp2cuda_temp_145 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 539 "GeometryModule.cs"
                    csharp2cuda_temp_145 = true;
                }
                if (csharp2cuda_temp_145)
#line 540 "GeometryModule.cs"
                {
#line 541 "GeometryModule.cs"
#line 541 "GeometryModule.cs"
                    int* csharp2cuda_temp_146 = &((output)->valid);
                    (*(csharp2cuda_temp_146) = 0);
#line 542 "GeometryModule.cs"
                    break;
                }
#line 544 "GeometryModule.cs"
                {
#line 545 "GeometryModule.cs"
                    int count = (first)->count;
#line 546 "GeometryModule.cs"
                    int* adjacency = ((int*)(scratch));
#line 547 "GeometryModule.cs"
                    int* ordered = csharp2cuda_pointer_add(adjacency, csharp2cuda_i32_mul(count, count));
#line 548 "GeometryModule.cs"
                    {
#line 548 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(count, count)))))
                                break;
#line 549 "GeometryModule.cs"
#line 549 "GeometryModule.cs"
                            int* csharp2cuda_temp_148 = &((adjacency)[index]);
                            (*(csharp2cuda_temp_148) = 0);
#line 548 "GeometryModule.cs"
                            int* csharp2cuda_temp_147 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_147));
                        }
                    }
#line 550 "GeometryModule.cs"
                    {
#line 550 "GeometryModule.cs"
                        int first_index = 0;
                        while (true)
                        {
                            if (!(((first_index) < (count))))
                                break;
#line 551 "GeometryModule.cs"
                            {
#line 552 "GeometryModule.cs"
                                {
#line 552 "GeometryModule.cs"
                                    int second_index = csharp2cuda_i32_add(first_index, 1);
                                    while (true)
                                    {
                                        if (!(((second_index) < (count))))
                                            break;
#line 553 "GeometryModule.cs"
                                        {
#line 554 "GeometryModule.cs"
                                            {
#line 554 "GeometryModule.cs"
                                                int third_index = csharp2cuda_i32_add(second_index, 1);
                                                while (true)
                                                {
                                                    if (!(((third_index) < (count))))
                                                        break;
#line 555 "GeometryModule.cs"
                                                    {
#line 556 "GeometryModule.cs"
                                                        double center_x;
#line 557 "GeometryModule.cs"
                                                        double center_y;
#line 558 "GeometryModule.cs"
                                                        double radius_square;
#line 559 "GeometryModule.cs"
#line 561 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_152 = &(center_x);
#line 561 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_153 = &(center_y);
#line 561 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_154 = &(radius_square);
#line 559 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_155 = mathblocks_geometry_try_circumcircle(a, first_index, second_index, third_index, csharp2cuda_temp_152, csharp2cuda_temp_153, csharp2cuda_temp_154);
                                                        if ((!(csharp2cuda_temp_155)))
#line 562 "GeometryModule.cs"
                                                        {
#line 563 "GeometryModule.cs"
                                                            goto csharp2cuda_for_continue_10;
                                                        }
#line 565 "GeometryModule.cs"
                                                        bool empty = true;
#line 566 "GeometryModule.cs"
                                                        {
#line 566 "GeometryModule.cs"
                                                            int index = 0;
                                                            while (true)
                                                            {
                                                                if (!(((index) < (count))))
                                                                    break;
#line 567 "GeometryModule.cs"
                                                                {
#line 568 "GeometryModule.cs"
#line 568 "GeometryModule.cs"
                                                                    bool csharp2cuda_temp_157;
#line 568 "GeometryModule.cs"
                                                                    if (!(((index) == (first_index))))
                                                                    {
#line 568 "GeometryModule.cs"
                                                                        csharp2cuda_temp_157 = ((index) == (second_index));
                                                                    }
                                                                    else
                                                                    {
#line 568 "GeometryModule.cs"
                                                                        csharp2cuda_temp_157 = true;
                                                                    }
#line 568 "GeometryModule.cs"
                                                                    bool csharp2cuda_temp_158;
#line 568 "GeometryModule.cs"
                                                                    if (!(csharp2cuda_temp_157))
                                                                    {
#line 568 "GeometryModule.cs"
                                                                        csharp2cuda_temp_158 = ((index) == (third_index));
                                                                    }
                                                                    else
                                                                    {
#line 568 "GeometryModule.cs"
                                                                        csharp2cuda_temp_158 = true;
                                                                    }
                                                                    if (csharp2cuda_temp_158)
                                                                    {
#line 569 "GeometryModule.cs"
                                                                        goto csharp2cuda_for_continue_9;
                                                                    }
#line 570 "GeometryModule.cs"
                                                                    double csharp2cuda_temp_159 = (a)[csharp2cuda_i32_mul(2, index)];
#line 570 "GeometryModule.cs"
                                                                    double x = __dsub_rn(csharp2cuda_temp_159, center_x);
#line 571 "GeometryModule.cs"
                                                                    double csharp2cuda_temp_160 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 571 "GeometryModule.cs"
                                                                    double y = __dsub_rn(csharp2cuda_temp_160, center_y);
#line 572 "GeometryModule.cs"
                                                                    if (((__dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y))) < (radius_square)))
#line 573 "GeometryModule.cs"
                                                                    {
#line 574 "GeometryModule.cs"
#line 574 "GeometryModule.cs"
                                                                        bool* csharp2cuda_temp_161 = &(empty);
                                                                        (*(csharp2cuda_temp_161) = false);
#line 575 "GeometryModule.cs"
                                                                        break;
                                                                    }
                                                                }
                                                                csharp2cuda_for_continue_9:
#line 566 "GeometryModule.cs"
                                                                int* csharp2cuda_temp_156 = &(index);
                                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_156));
                                                            }
                                                        }
#line 578 "GeometryModule.cs"
                                                        if ((!(empty)))
                                                        {
#line 579 "GeometryModule.cs"
                                                            goto csharp2cuda_for_continue_10;
                                                        }
#line 580 "GeometryModule.cs"
#line 580 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_162 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, count), second_index)]);
                                                        (*(csharp2cuda_temp_162) = 1);
#line 581 "GeometryModule.cs"
#line 581 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_163 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, count), third_index)]);
                                                        (*(csharp2cuda_temp_163) = 1);
#line 582 "GeometryModule.cs"
#line 582 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_164 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(second_index, count), third_index)]);
                                                        (*(csharp2cuda_temp_164) = 1);
                                                    }
                                                    csharp2cuda_for_continue_10:
#line 554 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_151 = &(third_index);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_151));
                                                }
                                            }
                                        }
#line 552 "GeometryModule.cs"
                                        int* csharp2cuda_temp_150 = &(second_index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_150));
                                    }
                                }
                            }
#line 550 "GeometryModule.cs"
                            int* csharp2cuda_temp_149 = &(first_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_149));
                        }
                    }
#line 586 "GeometryModule.cs"
                    int edge_count = 0;
#line 587 "GeometryModule.cs"
                    {
#line 587 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (count))))
                                break;
#line 588 "GeometryModule.cs"
                            {
#line 588 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
                                    if (!(((right) < (count))))
                                        break;
#line 589 "GeometryModule.cs"
#line 589 "GeometryModule.cs"
                                    int* csharp2cuda_temp_167 = &(edge_count);
#line 589 "GeometryModule.cs"
                                    int csharp2cuda_temp_168 = *(csharp2cuda_temp_167);
#line 589 "GeometryModule.cs"
                                    int csharp2cuda_temp_169 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)];
                                    (*(csharp2cuda_temp_167) = csharp2cuda_i32_add(csharp2cuda_temp_168, csharp2cuda_temp_169));
#line 588 "GeometryModule.cs"
                                    int* csharp2cuda_temp_166 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_166));
                                }
                            }
#line 587 "GeometryModule.cs"
                            int* csharp2cuda_temp_165 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_165));
                        }
                    }
#line 590 "GeometryModule.cs"
                    if (((edge_count) == (0)))
#line 591 "GeometryModule.cs"
                    {
#line 592 "GeometryModule.cs"
                        mathblocks_geometry_index_order(a, count, ordered, csharp2cuda_pointer_add(ordered, count));
#line 593 "GeometryModule.cs"
                        {
#line 593 "GeometryModule.cs"
                            int index = 1;
                            while (true)
                            {
                                if (!(((index) < (count))))
                                    break;
#line 594 "GeometryModule.cs"
                                {
#line 595 "GeometryModule.cs"
                                    int csharp2cuda_temp_171 = (ordered)[csharp2cuda_i32_sub(index, 1)];
#line 595 "GeometryModule.cs"
                                    int csharp2cuda_temp_172 = (ordered)[index];
#line 595 "GeometryModule.cs"
                                    int csharp2cuda_temp_173;
#line 595 "GeometryModule.cs"
                                    if (((csharp2cuda_temp_171) < (csharp2cuda_temp_172)))
                                    {
#line 595 "GeometryModule.cs"
                                        csharp2cuda_temp_173 = (ordered)[csharp2cuda_i32_sub(index, 1)];
                                    }
                                    else
                                    {
#line 595 "GeometryModule.cs"
                                        csharp2cuda_temp_173 = (ordered)[index];
                                    }
#line 595 "GeometryModule.cs"
                                    int left = csharp2cuda_temp_173;
#line 598 "GeometryModule.cs"
                                    int csharp2cuda_temp_174 = (ordered)[csharp2cuda_i32_sub(index, 1)];
#line 598 "GeometryModule.cs"
                                    int csharp2cuda_temp_175 = (ordered)[index];
#line 598 "GeometryModule.cs"
                                    int csharp2cuda_temp_176;
#line 598 "GeometryModule.cs"
                                    if (((csharp2cuda_temp_174) < (csharp2cuda_temp_175)))
                                    {
#line 598 "GeometryModule.cs"
                                        csharp2cuda_temp_176 = (ordered)[index];
                                    }
                                    else
                                    {
#line 598 "GeometryModule.cs"
                                        csharp2cuda_temp_176 = (ordered)[csharp2cuda_i32_sub(index, 1)];
                                    }
#line 598 "GeometryModule.cs"
                                    int right = csharp2cuda_temp_176;
#line 601 "GeometryModule.cs"
#line 601 "GeometryModule.cs"
                                    int* csharp2cuda_temp_177 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)]);
                                    (*(csharp2cuda_temp_177) = 1);
                                }
#line 593 "GeometryModule.cs"
                                int* csharp2cuda_temp_170 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_170));
                            }
                        }
                    }
#line 604 "GeometryModule.cs"
                    unsigned long long csharp2cuda_temp_178 = (output)->data_pointer;
#line 604 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(csharp2cuda_temp_178));
#line 605 "GeometryModule.cs"
#line 605 "GeometryModule.cs"
                    int* csharp2cuda_temp_179 = &(edge_count);
                    (*(csharp2cuda_temp_179) = 0);
#line 606 "GeometryModule.cs"
                    {
#line 606 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (count))))
                                break;
#line 607 "GeometryModule.cs"
                            {
#line 608 "GeometryModule.cs"
                                {
#line 608 "GeometryModule.cs"
                                    int right = csharp2cuda_i32_add(left, 1);
                                    while (true)
                                    {
                                        if (!(((right) < (count))))
                                            break;
#line 609 "GeometryModule.cs"
                                        {
#line 610 "GeometryModule.cs"
#line 610 "GeometryModule.cs"
                                            int csharp2cuda_temp_182 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)];
                                            if ((!(((csharp2cuda_temp_182) != 0))))
                                            {
#line 611 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_16;
                                            }
#line 612 "GeometryModule.cs"
#line 612 "GeometryModule.cs"
                                            int csharp2cuda_temp_183 = (output)->capacity;
                                            if (((edge_count) >= (csharp2cuda_temp_183)))
#line 613 "GeometryModule.cs"
                                            {
#line 614 "GeometryModule.cs"
#line 614 "GeometryModule.cs"
                                                int* csharp2cuda_temp_184 = &((output)->count);
#line 614 "GeometryModule.cs"
                                                int csharp2cuda_temp_185 = (output)->capacity;
#line 614 "GeometryModule.cs"
                                                int csharp2cuda_temp_186;
#line 614 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_185) == (2147483647)))
                                                {
#line 614 "GeometryModule.cs"
                                                    csharp2cuda_temp_186 = csharp2cuda_i32_neg(1);
                                                }
                                                else
                                                {
#line 616 "GeometryModule.cs"
                                                    int csharp2cuda_temp_187 = (output)->capacity;
#line 614 "GeometryModule.cs"
                                                    csharp2cuda_temp_186 = csharp2cuda_i32_add(csharp2cuda_temp_187, 1);
                                                }
                                                (*(csharp2cuda_temp_184) = csharp2cuda_temp_186);
#line 617 "GeometryModule.cs"
#line 617 "GeometryModule.cs"
                                                int* csharp2cuda_temp_188 = &((output)->valid);
                                                (*(csharp2cuda_temp_188) = 0);
#line 618 "GeometryModule.cs"
                                                break;
                                            }
#line 620 "GeometryModule.cs"
#line 620 "GeometryModule.cs"
                                            int* csharp2cuda_temp_189 = &(((edges)[edge_count]).from);
                                            (*(csharp2cuda_temp_189) = left);
#line 621 "GeometryModule.cs"
#line 621 "GeometryModule.cs"
                                            int* csharp2cuda_temp_190 = &(((edges)[edge_count]).to);
                                            (*(csharp2cuda_temp_190) = right);
#line 622 "GeometryModule.cs"
#line 622 "GeometryModule.cs"
                                            double* csharp2cuda_temp_191 = &(((edges)[edge_count]).weight);
#line 622 "GeometryModule.cs"
                                            double csharp2cuda_temp_192 = mathblocks_geometry_distance(a, left, a, right);
                                            (*(csharp2cuda_temp_191) = csharp2cuda_temp_192);
#line 623 "GeometryModule.cs"
#line 623 "GeometryModule.cs"
                                            double csharp2cuda_temp_193 = ((edges)[edge_count]).weight;
                                            if ((!(isfinite(csharp2cuda_temp_193))))
                                            {
#line 623 "GeometryModule.cs"
#line 623 "GeometryModule.cs"
                                                int* csharp2cuda_temp_194 = &((output)->valid);
                                                (*(csharp2cuda_temp_194) = 0);
                                            }
#line 624 "GeometryModule.cs"
#line 624 "GeometryModule.cs"
                                            int* csharp2cuda_temp_195 = &(edge_count);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_195));
                                        }
                                        csharp2cuda_for_continue_16:
#line 608 "GeometryModule.cs"
                                        int* csharp2cuda_temp_181 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_181));
                                    }
                                }
                            }
#line 606 "GeometryModule.cs"
                            int* csharp2cuda_temp_180 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_180));
                        }
                    }
#line 627 "GeometryModule.cs"
#line 627 "GeometryModule.cs"
                    int* csharp2cuda_temp_196 = &((output)->rows);
                    (*(csharp2cuda_temp_196) = count);
#line 628 "GeometryModule.cs"
                    if ((output)->valid)
                    {
#line 629 "GeometryModule.cs"
#line 629 "GeometryModule.cs"
                        int* csharp2cuda_temp_197 = &((output)->count);
                        (*(csharp2cuda_temp_197) = edge_count);
                    }
#line 630 "GeometryModule.cs"
                    break;
                }
#line 632 "GeometryModule.cs"
            case 6:
#line 633 "GeometryModule.cs"
#line 633 "GeometryModule.cs"
                int csharp2cuda_temp_198 = (first)->count;
                if (((csharp2cuda_temp_198) <= (0)))
#line 634 "GeometryModule.cs"
                {
#line 635 "GeometryModule.cs"
#line 635 "GeometryModule.cs"
                    int* csharp2cuda_temp_199 = &((output)->valid);
                    (*(csharp2cuda_temp_199) = 0);
#line 636 "GeometryModule.cs"
                    break;
                }
#line 638 "GeometryModule.cs"
                {
#line 639 "GeometryModule.cs"
                    double maximum = 0.0;
#line 640 "GeometryModule.cs"
                    {
#line 640 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 640 "GeometryModule.cs"
                            int csharp2cuda_temp_201 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_201))))
                                break;
#line 641 "GeometryModule.cs"
                            {
#line 641 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
#line 641 "GeometryModule.cs"
                                    int csharp2cuda_temp_203 = (first)->count;
                                    if (!(((right) < (csharp2cuda_temp_203))))
                                        break;
#line 642 "GeometryModule.cs"
                                    {
#line 643 "GeometryModule.cs"
                                        double distance = mathblocks_geometry_distance(a, left, a, right);
#line 644 "GeometryModule.cs"
#line 644 "GeometryModule.cs"
                                        double* csharp2cuda_temp_204 = &(maximum);
#line 644 "GeometryModule.cs"
                                        double csharp2cuda_temp_205;
#line 644 "GeometryModule.cs"
                                        if (((maximum) > (distance)))
                                        {
#line 644 "GeometryModule.cs"
                                            csharp2cuda_temp_205 = maximum;
                                        }
                                        else
                                        {
#line 644 "GeometryModule.cs"
                                            csharp2cuda_temp_205 = distance;
                                        }
                                        (*(csharp2cuda_temp_204) = csharp2cuda_temp_205);
                                    }
#line 641 "GeometryModule.cs"
                                    int* csharp2cuda_temp_202 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_202));
                                }
                            }
#line 640 "GeometryModule.cs"
                            int* csharp2cuda_temp_200 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_200));
                        }
                    }
#line 646 "GeometryModule.cs"
#line 646 "GeometryModule.cs"
                    double* csharp2cuda_temp_206 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_206) = maximum);
#line 647 "GeometryModule.cs"
                    break;
                }
#line 649 "GeometryModule.cs"
            case 7:
#line 650 "GeometryModule.cs"
#line 650 "GeometryModule.cs"
                int csharp2cuda_temp_207 = (first)->count;
#line 650 "GeometryModule.cs"
                bool csharp2cuda_temp_208;
#line 650 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_207) <= (0))))
                {
#line 650 "GeometryModule.cs"
                    int csharp2cuda_temp_209 = (second)->count;
#line 650 "GeometryModule.cs"
                    csharp2cuda_temp_208 = ((csharp2cuda_temp_209) <= (0));
                }
                else
                {
#line 650 "GeometryModule.cs"
                    csharp2cuda_temp_208 = true;
                }
#line 650 "GeometryModule.cs"
                bool csharp2cuda_temp_210;
#line 650 "GeometryModule.cs"
                if (!(csharp2cuda_temp_208))
                {
#line 650 "GeometryModule.cs"
                    csharp2cuda_temp_210 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 650 "GeometryModule.cs"
                    csharp2cuda_temp_210 = true;
                }
                if (csharp2cuda_temp_210)
#line 651 "GeometryModule.cs"
                {
#line 652 "GeometryModule.cs"
#line 652 "GeometryModule.cs"
                    int* csharp2cuda_temp_211 = &((output)->valid);
                    (*(csharp2cuda_temp_211) = 0);
#line 653 "GeometryModule.cs"
                    break;
                }
#line 655 "GeometryModule.cs"
                {
#line 656 "GeometryModule.cs"
                    {
#line 656 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 656 "GeometryModule.cs"
                            int csharp2cuda_temp_213 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_213))))
                                break;
#line 657 "GeometryModule.cs"
                            {
#line 658 "GeometryModule.cs"
                                {
#line 658 "GeometryModule.cs"
                                    int right = 0;
                                    while (true)
                                    {
#line 658 "GeometryModule.cs"
                                        int csharp2cuda_temp_215 = (second)->count;
                                        if (!(((right) < (csharp2cuda_temp_215))))
                                            break;
#line 659 "GeometryModule.cs"
                                        {
#line 660 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(a, left, b, right);
#line 661 "GeometryModule.cs"
                                            int csharp2cuda_temp_216 = (second)->count;
#line 661 "GeometryModule.cs"
                                            int target = csharp2cuda_i32_add(csharp2cuda_i32_mul(left, csharp2cuda_temp_216), right);
#line 662 "GeometryModule.cs"
#line 662 "GeometryModule.cs"
                                            bool csharp2cuda_temp_217;
#line 662 "GeometryModule.cs"
                                            if (((left) == (0)))
                                            {
#line 662 "GeometryModule.cs"
                                                csharp2cuda_temp_217 = ((right) == (0));
                                            }
                                            else
                                            {
#line 662 "GeometryModule.cs"
                                                csharp2cuda_temp_217 = false;
                                            }
                                            if (csharp2cuda_temp_217)
                                            {
#line 663 "GeometryModule.cs"
#line 663 "GeometryModule.cs"
                                                double* csharp2cuda_temp_218 = &((scratch)[0]);
                                                (*(csharp2cuda_temp_218) = distance);
                                            }
                                            else
                                            {
#line 664 "GeometryModule.cs"
                                                if (((left) == (0)))
                                                {
#line 665 "GeometryModule.cs"
#line 665 "GeometryModule.cs"
                                                    double* csharp2cuda_temp_219 = &((scratch)[right]);
#line 665 "GeometryModule.cs"
                                                    double csharp2cuda_temp_220 = (scratch)[csharp2cuda_i32_sub(right, 1)];
#line 665 "GeometryModule.cs"
                                                    double csharp2cuda_temp_221;
#line 665 "GeometryModule.cs"
                                                    if (((csharp2cuda_temp_220) > (distance)))
                                                    {
#line 665 "GeometryModule.cs"
                                                        csharp2cuda_temp_221 = (scratch)[csharp2cuda_i32_sub(right, 1)];
                                                    }
                                                    else
                                                    {
#line 665 "GeometryModule.cs"
                                                        csharp2cuda_temp_221 = distance;
                                                    }
                                                    (*(csharp2cuda_temp_219) = csharp2cuda_temp_221);
                                                }
                                                else
                                                {
#line 668 "GeometryModule.cs"
                                                    if (((right) == (0)))
                                                    {
#line 669 "GeometryModule.cs"
#line 669 "GeometryModule.cs"
                                                        int csharp2cuda_temp_222 = (second)->count;
#line 669 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_223 = &((scratch)[csharp2cuda_i32_mul(left, csharp2cuda_temp_222)]);
#line 669 "GeometryModule.cs"
                                                        int csharp2cuda_temp_224 = (second)->count;
#line 669 "GeometryModule.cs"
                                                        double csharp2cuda_temp_225 = (scratch)[csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_224)];
#line 669 "GeometryModule.cs"
                                                        double csharp2cuda_temp_226;
#line 669 "GeometryModule.cs"
                                                        if (((csharp2cuda_temp_225) > (distance)))
                                                        {
#line 670 "GeometryModule.cs"
                                                            int csharp2cuda_temp_227 = (second)->count;
#line 669 "GeometryModule.cs"
                                                            csharp2cuda_temp_226 = (scratch)[csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_227)];
                                                        }
                                                        else
                                                        {
#line 669 "GeometryModule.cs"
                                                            csharp2cuda_temp_226 = distance;
                                                        }
                                                        (*(csharp2cuda_temp_223) = csharp2cuda_temp_226);
                                                    }
                                                    else
#line 673 "GeometryModule.cs"
                                                    {
#line 674 "GeometryModule.cs"
                                                        int csharp2cuda_temp_228 = (second)->count;
#line 674 "GeometryModule.cs"
                                                        double preceding = (scratch)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_228), right)];
#line 675 "GeometryModule.cs"
                                                        int csharp2cuda_temp_229 = (second)->count;
#line 675 "GeometryModule.cs"
                                                        double candidate = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_229), right), 1)];
#line 676 "GeometryModule.cs"
#line 676 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_230 = &(preceding);
#line 676 "GeometryModule.cs"
                                                        double csharp2cuda_temp_231;
#line 676 "GeometryModule.cs"
                                                        if (((preceding) < (candidate)))
                                                        {
#line 676 "GeometryModule.cs"
                                                            csharp2cuda_temp_231 = preceding;
                                                        }
                                                        else
                                                        {
#line 676 "GeometryModule.cs"
                                                            csharp2cuda_temp_231 = candidate;
                                                        }
                                                        (*(csharp2cuda_temp_230) = csharp2cuda_temp_231);
#line 677 "GeometryModule.cs"
#line 677 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_232 = &(candidate);
#line 677 "GeometryModule.cs"
                                                        int csharp2cuda_temp_233 = (second)->count;
#line 677 "GeometryModule.cs"
                                                        double csharp2cuda_temp_234 = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(left, csharp2cuda_temp_233), right), 1)];
                                                        (*(csharp2cuda_temp_232) = csharp2cuda_temp_234);
#line 678 "GeometryModule.cs"
#line 678 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_235 = &(preceding);
#line 678 "GeometryModule.cs"
                                                        double csharp2cuda_temp_236;
#line 678 "GeometryModule.cs"
                                                        if (((preceding) < (candidate)))
                                                        {
#line 678 "GeometryModule.cs"
                                                            csharp2cuda_temp_236 = preceding;
                                                        }
                                                        else
                                                        {
#line 678 "GeometryModule.cs"
                                                            csharp2cuda_temp_236 = candidate;
                                                        }
                                                        (*(csharp2cuda_temp_235) = csharp2cuda_temp_236);
#line 679 "GeometryModule.cs"
#line 679 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_237 = &((scratch)[target]);
#line 679 "GeometryModule.cs"
                                                        double csharp2cuda_temp_238;
#line 679 "GeometryModule.cs"
                                                        if (((preceding) > (distance)))
                                                        {
#line 679 "GeometryModule.cs"
                                                            csharp2cuda_temp_238 = preceding;
                                                        }
                                                        else
                                                        {
#line 679 "GeometryModule.cs"
                                                            csharp2cuda_temp_238 = distance;
                                                        }
                                                        (*(csharp2cuda_temp_237) = csharp2cuda_temp_238);
                                                    }
                                                }
                                            }
                                        }
#line 658 "GeometryModule.cs"
                                        int* csharp2cuda_temp_214 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_214));
                                    }
                                }
                            }
#line 656 "GeometryModule.cs"
                            int* csharp2cuda_temp_212 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_212));
                        }
                    }
#line 683 "GeometryModule.cs"
#line 683 "GeometryModule.cs"
                    double* csharp2cuda_temp_239 = &((output)->scalar_value);
#line 683 "GeometryModule.cs"
                    int csharp2cuda_temp_240 = (first)->count;
#line 683 "GeometryModule.cs"
                    int csharp2cuda_temp_241 = (second)->count;
#line 683 "GeometryModule.cs"
                    double csharp2cuda_temp_242 = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_mul(csharp2cuda_temp_240, csharp2cuda_temp_241), 1)];
                    (*(csharp2cuda_temp_239) = csharp2cuda_temp_242);
#line 684 "GeometryModule.cs"
                    break;
                }
#line 686 "GeometryModule.cs"
            case 8:
#line 687 "GeometryModule.cs"
#line 687 "GeometryModule.cs"
                int csharp2cuda_temp_243 = (first)->count;
#line 687 "GeometryModule.cs"
                bool csharp2cuda_temp_244;
#line 687 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_243) <= (0))))
                {
#line 687 "GeometryModule.cs"
                    int csharp2cuda_temp_245 = (second)->count;
#line 687 "GeometryModule.cs"
                    csharp2cuda_temp_244 = ((csharp2cuda_temp_245) <= (0));
                }
                else
                {
#line 687 "GeometryModule.cs"
                    csharp2cuda_temp_244 = true;
                }
                if (csharp2cuda_temp_244)
                {
#line 688 "GeometryModule.cs"
#line 688 "GeometryModule.cs"
                    int* csharp2cuda_temp_246 = &((output)->valid);
                    (*(csharp2cuda_temp_246) = 0);
                }
                else
                {
#line 690 "GeometryModule.cs"
#line 690 "GeometryModule.cs"
                    double* csharp2cuda_temp_247 = &((output)->scalar_value);
#line 690 "GeometryModule.cs"
                    double csharp2cuda_temp_248 = mathblocks_geometry_distance(a, 0, b, 0);
                    (*(csharp2cuda_temp_247) = csharp2cuda_temp_248);
                }
#line 691 "GeometryModule.cs"
                break;
#line 692 "GeometryModule.cs"
            case 9:
#line 693 "GeometryModule.cs"
#line 693 "GeometryModule.cs"
                int csharp2cuda_temp_249 = (first)->count;
#line 693 "GeometryModule.cs"
                bool csharp2cuda_temp_250;
#line 693 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_249) <= (0))))
                {
#line 693 "GeometryModule.cs"
                    int csharp2cuda_temp_251 = (first)->count;
#line 693 "GeometryModule.cs"
                    int csharp2cuda_temp_252 = (second)->count;
#line 693 "GeometryModule.cs"
                    csharp2cuda_temp_250 = ((csharp2cuda_temp_251) != (csharp2cuda_temp_252));
                }
                else
                {
#line 693 "GeometryModule.cs"
                    csharp2cuda_temp_250 = true;
                }
#line 693 "GeometryModule.cs"
                bool csharp2cuda_temp_253;
#line 693 "GeometryModule.cs"
                if (!(csharp2cuda_temp_250))
                {
#line 694 "GeometryModule.cs"
                    int csharp2cuda_temp_254 = (first)->count;
#line 693 "GeometryModule.cs"
                    csharp2cuda_temp_253 = (!(mathblocks_probability_distribution(a, csharp2cuda_temp_254)));
                }
                else
                {
#line 693 "GeometryModule.cs"
                    csharp2cuda_temp_253 = true;
                }
#line 693 "GeometryModule.cs"
                bool csharp2cuda_temp_255;
#line 693 "GeometryModule.cs"
                if (!(csharp2cuda_temp_253))
                {
#line 695 "GeometryModule.cs"
                    int csharp2cuda_temp_256 = (second)->count;
#line 693 "GeometryModule.cs"
                    csharp2cuda_temp_255 = (!(mathblocks_probability_distribution(b, csharp2cuda_temp_256)));
                }
                else
                {
#line 693 "GeometryModule.cs"
                    csharp2cuda_temp_255 = true;
                }
                if (csharp2cuda_temp_255)
#line 696 "GeometryModule.cs"
                {
#line 697 "GeometryModule.cs"
#line 697 "GeometryModule.cs"
                    int* csharp2cuda_temp_257 = &((output)->valid);
                    (*(csharp2cuda_temp_257) = 0);
#line 698 "GeometryModule.cs"
                    break;
                }
#line 700 "GeometryModule.cs"
                {
#line 701 "GeometryModule.cs"
                    double affinity = 0.0;
#line 702 "GeometryModule.cs"
                    {
#line 702 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 702 "GeometryModule.cs"
                            int csharp2cuda_temp_259 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_259))))
                                break;
#line 703 "GeometryModule.cs"
#line 703 "GeometryModule.cs"
                            double* csharp2cuda_temp_260 = &(affinity);
#line 703 "GeometryModule.cs"
                            double csharp2cuda_temp_261 = *(csharp2cuda_temp_260);
#line 703 "GeometryModule.cs"
                            double csharp2cuda_temp_262 = (a)[index];
#line 703 "GeometryModule.cs"
                            double csharp2cuda_temp_263 = (b)[index];
                            (*(csharp2cuda_temp_260) = __dadd_rn(csharp2cuda_temp_261, mathblocks_square_root(__dmul_rn(csharp2cuda_temp_262, csharp2cuda_temp_263))));
#line 702 "GeometryModule.cs"
                            int* csharp2cuda_temp_258 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_258));
                        }
                    }
#line 704 "GeometryModule.cs"
#line 704 "GeometryModule.cs"
                    double* csharp2cuda_temp_264 = &(affinity);
#line 704 "GeometryModule.cs"
                    double csharp2cuda_temp_265;
#line 704 "GeometryModule.cs"
                    if (((affinity) < ((-(1.0)))))
                    {
#line 704 "GeometryModule.cs"
                        csharp2cuda_temp_265 = (-(1.0));
                    }
                    else
                    {
#line 704 "GeometryModule.cs"
                        double csharp2cuda_temp_266;
#line 704 "GeometryModule.cs"
                        if (((affinity) > (1.0)))
                        {
#line 704 "GeometryModule.cs"
                            csharp2cuda_temp_266 = 1.0;
                        }
                        else
                        {
#line 704 "GeometryModule.cs"
                            csharp2cuda_temp_266 = affinity;
                        }
#line 704 "GeometryModule.cs"
                        csharp2cuda_temp_265 = csharp2cuda_temp_266;
                    }
                    (*(csharp2cuda_temp_264) = csharp2cuda_temp_265);
#line 705 "GeometryModule.cs"
#line 705 "GeometryModule.cs"
                    double* csharp2cuda_temp_267 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_267) = __dmul_rn(2.0, mathblocks_arc_cosine(affinity)));
#line 706 "GeometryModule.cs"
                    break;
                }
#line 708 "GeometryModule.cs"
            case 10:
#line 709 "GeometryModule.cs"
#line 709 "GeometryModule.cs"
                int csharp2cuda_temp_268 = (first)->count;
                if (((csharp2cuda_temp_268) < (2)))
#line 710 "GeometryModule.cs"
                {
#line 711 "GeometryModule.cs"
#line 711 "GeometryModule.cs"
                    int* csharp2cuda_temp_269 = &((output)->valid);
                    (*(csharp2cuda_temp_269) = 0);
#line 712 "GeometryModule.cs"
                    break;
                }
#line 714 "GeometryModule.cs"
                {
#line 715 "GeometryModule.cs"
                    unsigned long long csharp2cuda_temp_270 = (output)->data_pointer;
#line 715 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(csharp2cuda_temp_270));
#line 716 "GeometryModule.cs"
                    int edge_count = 0;
#line 717 "GeometryModule.cs"
                    {
#line 717 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 717 "GeometryModule.cs"
                            int csharp2cuda_temp_272 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_272))))
                                break;
#line 718 "GeometryModule.cs"
                            {
#line 719 "GeometryModule.cs"
                                {
#line 719 "GeometryModule.cs"
                                    int right = csharp2cuda_i32_add(left, 1);
                                    while (true)
                                    {
#line 719 "GeometryModule.cs"
                                        int csharp2cuda_temp_274 = (first)->count;
                                        if (!(((right) < (csharp2cuda_temp_274))))
                                            break;
#line 720 "GeometryModule.cs"
                                        {
#line 721 "GeometryModule.cs"
                                            double csharp2cuda_temp_275 = (a)[csharp2cuda_i32_mul(2, left)];
#line 721 "GeometryModule.cs"
                                            double csharp2cuda_temp_276 = (a)[csharp2cuda_i32_mul(2, right)];
#line 721 "GeometryModule.cs"
                                            double center_x = __ddiv_rn(__dadd_rn(csharp2cuda_temp_275, csharp2cuda_temp_276), 2.0);
#line 722 "GeometryModule.cs"
                                            double csharp2cuda_temp_277 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
#line 722 "GeometryModule.cs"
                                            double csharp2cuda_temp_278 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
#line 722 "GeometryModule.cs"
                                            double center_y = __ddiv_rn(__dadd_rn(csharp2cuda_temp_277, csharp2cuda_temp_278), 2.0);
#line 723 "GeometryModule.cs"
                                            double csharp2cuda_temp_279 = mathblocks_geometry_distance(a, left, a, right);
#line 723 "GeometryModule.cs"
                                            double radius = __ddiv_rn(csharp2cuda_temp_279, 2.0);
#line 724 "GeometryModule.cs"
                                            bool empty = true;
#line 725 "GeometryModule.cs"
                                            {
#line 725 "GeometryModule.cs"
                                                int index = 0;
                                                while (true)
                                                {
#line 725 "GeometryModule.cs"
                                                    int csharp2cuda_temp_281 = (first)->count;
                                                    if (!(((index) < (csharp2cuda_temp_281))))
                                                        break;
#line 726 "GeometryModule.cs"
                                                    {
#line 727 "GeometryModule.cs"
#line 727 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_282;
#line 727 "GeometryModule.cs"
                                                        if (((index) != (left)))
                                                        {
#line 727 "GeometryModule.cs"
                                                            csharp2cuda_temp_282 = ((index) != (right));
                                                        }
                                                        else
                                                        {
#line 727 "GeometryModule.cs"
                                                            csharp2cuda_temp_282 = false;
                                                        }
#line 727 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_283;
#line 727 "GeometryModule.cs"
                                                        if (csharp2cuda_temp_282)
                                                        {
#line 729 "GeometryModule.cs"
                                                            double csharp2cuda_temp_284 = (a)[csharp2cuda_i32_mul(2, index)];
#line 729 "GeometryModule.cs"
                                                            double csharp2cuda_temp_285 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 727 "GeometryModule.cs"
                                                            csharp2cuda_temp_283 = ((mathblocks_geometry_distance_coordinates(csharp2cuda_temp_284, csharp2cuda_temp_285, center_x, center_y)) < (radius));
                                                        }
                                                        else
                                                        {
#line 727 "GeometryModule.cs"
                                                            csharp2cuda_temp_283 = false;
                                                        }
                                                        if (csharp2cuda_temp_283)
#line 730 "GeometryModule.cs"
                                                        {
#line 731 "GeometryModule.cs"
#line 731 "GeometryModule.cs"
                                                            bool* csharp2cuda_temp_286 = &(empty);
                                                            (*(csharp2cuda_temp_286) = false);
#line 732 "GeometryModule.cs"
                                                            break;
                                                        }
                                                    }
#line 725 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_280 = &(index);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_280));
                                                }
                                            }
#line 735 "GeometryModule.cs"
                                            if ((!(empty)))
                                            {
#line 736 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_24;
                                            }
#line 737 "GeometryModule.cs"
#line 737 "GeometryModule.cs"
                                            int csharp2cuda_temp_287 = (output)->capacity;
                                            if (((edge_count) >= (csharp2cuda_temp_287)))
#line 738 "GeometryModule.cs"
                                            {
#line 739 "GeometryModule.cs"
#line 739 "GeometryModule.cs"
                                                int* csharp2cuda_temp_288 = &((output)->count);
#line 739 "GeometryModule.cs"
                                                int csharp2cuda_temp_289 = (output)->capacity;
#line 739 "GeometryModule.cs"
                                                int csharp2cuda_temp_290;
#line 739 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_289) == (2147483647)))
                                                {
#line 739 "GeometryModule.cs"
                                                    csharp2cuda_temp_290 = csharp2cuda_i32_neg(1);
                                                }
                                                else
                                                {
#line 741 "GeometryModule.cs"
                                                    int csharp2cuda_temp_291 = (output)->capacity;
#line 739 "GeometryModule.cs"
                                                    csharp2cuda_temp_290 = csharp2cuda_i32_add(csharp2cuda_temp_291, 1);
                                                }
                                                (*(csharp2cuda_temp_288) = csharp2cuda_temp_290);
#line 742 "GeometryModule.cs"
#line 742 "GeometryModule.cs"
                                                int* csharp2cuda_temp_292 = &((output)->valid);
                                                (*(csharp2cuda_temp_292) = 0);
#line 743 "GeometryModule.cs"
                                                break;
                                            }
#line 745 "GeometryModule.cs"
#line 745 "GeometryModule.cs"
                                            int* csharp2cuda_temp_293 = &(((edges)[edge_count]).from);
                                            (*(csharp2cuda_temp_293) = left);
#line 746 "GeometryModule.cs"
#line 746 "GeometryModule.cs"
                                            int* csharp2cuda_temp_294 = &(((edges)[edge_count]).to);
                                            (*(csharp2cuda_temp_294) = right);
#line 747 "GeometryModule.cs"
#line 747 "GeometryModule.cs"
                                            double* csharp2cuda_temp_295 = &(((edges)[edge_count]).weight);
                                            (*(csharp2cuda_temp_295) = __dmul_rn(2.0, radius));
#line 748 "GeometryModule.cs"
#line 748 "GeometryModule.cs"
                                            double csharp2cuda_temp_296 = ((edges)[edge_count]).weight;
                                            if ((!(isfinite(csharp2cuda_temp_296))))
                                            {
#line 748 "GeometryModule.cs"
#line 748 "GeometryModule.cs"
                                                int* csharp2cuda_temp_297 = &((output)->valid);
                                                (*(csharp2cuda_temp_297) = 0);
                                            }
#line 749 "GeometryModule.cs"
#line 749 "GeometryModule.cs"
                                            int* csharp2cuda_temp_298 = &(edge_count);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_298));
                                        }
                                        csharp2cuda_for_continue_24:
#line 719 "GeometryModule.cs"
                                        int* csharp2cuda_temp_273 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_273));
                                    }
                                }
                            }
#line 717 "GeometryModule.cs"
                            int* csharp2cuda_temp_271 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_271));
                        }
                    }
#line 752 "GeometryModule.cs"
#line 752 "GeometryModule.cs"
                    int* csharp2cuda_temp_299 = &((output)->rows);
#line 752 "GeometryModule.cs"
                    int csharp2cuda_temp_300 = (first)->count;
                    (*(csharp2cuda_temp_299) = csharp2cuda_temp_300);
#line 753 "GeometryModule.cs"
                    if ((output)->valid)
                    {
#line 754 "GeometryModule.cs"
#line 754 "GeometryModule.cs"
                        int* csharp2cuda_temp_301 = &((output)->count);
                        (*(csharp2cuda_temp_301) = edge_count);
                    }
#line 755 "GeometryModule.cs"
                    break;
                }
#line 757 "GeometryModule.cs"
            case 11:
#line 758 "GeometryModule.cs"
#line 758 "GeometryModule.cs"
                int csharp2cuda_temp_302 = (first)->count;
#line 758 "GeometryModule.cs"
                bool csharp2cuda_temp_303;
#line 758 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_302) <= (0))))
                {
#line 758 "GeometryModule.cs"
                    int csharp2cuda_temp_304 = (second)->count;
#line 758 "GeometryModule.cs"
                    csharp2cuda_temp_303 = ((csharp2cuda_temp_304) != (1));
                }
                else
                {
#line 758 "GeometryModule.cs"
                    csharp2cuda_temp_303 = true;
                }
                if (csharp2cuda_temp_303)
#line 759 "GeometryModule.cs"
                {
#line 760 "GeometryModule.cs"
#line 760 "GeometryModule.cs"
                    int* csharp2cuda_temp_305 = &((output)->valid);
                    (*(csharp2cuda_temp_305) = 0);
#line 761 "GeometryModule.cs"
                    break;
                }
#line 763 "GeometryModule.cs"
                {
#line 764 "GeometryModule.cs"
                    double point_x = (b)[0];
#line 765 "GeometryModule.cs"
                    double point_y = (b)[1];
#line 766 "GeometryModule.cs"
                    int coincident = 0;
#line 767 "GeometryModule.cs"
                    int vector_count = 0;
#line 768 "GeometryModule.cs"
                    {
#line 768 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 768 "GeometryModule.cs"
                            int csharp2cuda_temp_307 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_307))))
                                break;
#line 769 "GeometryModule.cs"
                            {
#line 770 "GeometryModule.cs"
                                double csharp2cuda_temp_308 = (a)[csharp2cuda_i32_mul(2, index)];
#line 770 "GeometryModule.cs"
                                double x = __dsub_rn(csharp2cuda_temp_308, point_x);
#line 771 "GeometryModule.cs"
                                double csharp2cuda_temp_309 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 771 "GeometryModule.cs"
                                double y = __dsub_rn(csharp2cuda_temp_309, point_y);
#line 772 "GeometryModule.cs"
#line 772 "GeometryModule.cs"
                                bool csharp2cuda_temp_310;
#line 772 "GeometryModule.cs"
                                if (((x) == (0.0)))
                                {
#line 772 "GeometryModule.cs"
                                    csharp2cuda_temp_310 = ((y) == (0.0));
                                }
                                else
                                {
#line 772 "GeometryModule.cs"
                                    csharp2cuda_temp_310 = false;
                                }
                                if (csharp2cuda_temp_310)
                                {
#line 773 "GeometryModule.cs"
#line 773 "GeometryModule.cs"
                                    int* csharp2cuda_temp_311 = &(coincident);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_311));
                                }
                                else
                                {
#line 775 "GeometryModule.cs"
#line 775 "GeometryModule.cs"
                                    int* csharp2cuda_temp_312 = &(vector_count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_312));
                                }
                            }
#line 768 "GeometryModule.cs"
                            int* csharp2cuda_temp_306 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_306));
                        }
                    }
#line 777 "GeometryModule.cs"
                    if (((vector_count) == (0)))
#line 778 "GeometryModule.cs"
                    {
#line 779 "GeometryModule.cs"
#line 779 "GeometryModule.cs"
                        double* csharp2cuda_temp_313 = &((output)->scalar_value);
                        (*(csharp2cuda_temp_313) = 1.0);
#line 780 "GeometryModule.cs"
                        break;
                    }
#line 782 "GeometryModule.cs"
                    int maximum = 0;
#line 783 "GeometryModule.cs"
                    {
#line 783 "GeometryModule.cs"
                        int pivot = 0;
                        while (true)
                        {
#line 783 "GeometryModule.cs"
                            int csharp2cuda_temp_315 = (first)->count;
                            if (!(((pivot) < (csharp2cuda_temp_315))))
                                break;
#line 784 "GeometryModule.cs"
                            {
#line 785 "GeometryModule.cs"
                                double csharp2cuda_temp_316 = (a)[csharp2cuda_i32_mul(2, pivot)];
#line 785 "GeometryModule.cs"
                                double pivot_x = __dsub_rn(csharp2cuda_temp_316, point_x);
#line 786 "GeometryModule.cs"
                                double csharp2cuda_temp_317 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, pivot), 1)];
#line 786 "GeometryModule.cs"
                                double pivot_y = __dsub_rn(csharp2cuda_temp_317, point_y);
#line 787 "GeometryModule.cs"
#line 787 "GeometryModule.cs"
                                bool csharp2cuda_temp_318;
#line 787 "GeometryModule.cs"
                                if (((pivot_x) == (0.0)))
                                {
#line 787 "GeometryModule.cs"
                                    csharp2cuda_temp_318 = ((pivot_y) == (0.0));
                                }
                                else
                                {
#line 787 "GeometryModule.cs"
                                    csharp2cuda_temp_318 = false;
                                }
                                if (csharp2cuda_temp_318)
                                {
#line 788 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_28;
                                }
#line 789 "GeometryModule.cs"
                                int count = 0;
#line 790 "GeometryModule.cs"
                                {
#line 790 "GeometryModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 790 "GeometryModule.cs"
                                        int csharp2cuda_temp_320 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_320))))
                                            break;
#line 791 "GeometryModule.cs"
                                        {
#line 792 "GeometryModule.cs"
                                            double csharp2cuda_temp_321 = (a)[csharp2cuda_i32_mul(2, index)];
#line 792 "GeometryModule.cs"
                                            double x = __dsub_rn(csharp2cuda_temp_321, point_x);
#line 793 "GeometryModule.cs"
                                            double csharp2cuda_temp_322 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 793 "GeometryModule.cs"
                                            double y = __dsub_rn(csharp2cuda_temp_322, point_y);
#line 794 "GeometryModule.cs"
#line 794 "GeometryModule.cs"
                                            bool csharp2cuda_temp_323;
#line 794 "GeometryModule.cs"
                                            if (((x) == (0.0)))
                                            {
#line 794 "GeometryModule.cs"
                                                csharp2cuda_temp_323 = ((y) == (0.0));
                                            }
                                            else
                                            {
#line 794 "GeometryModule.cs"
                                                csharp2cuda_temp_323 = false;
                                            }
                                            if (csharp2cuda_temp_323)
                                            {
#line 795 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_27;
                                            }
#line 796 "GeometryModule.cs"
                                            double cross = __dsub_rn(__dmul_rn(pivot_x, y), __dmul_rn(pivot_y, x));
#line 797 "GeometryModule.cs"
                                            double dot = __dadd_rn(__dmul_rn(pivot_x, x), __dmul_rn(pivot_y, y));
#line 798 "GeometryModule.cs"
#line 798 "GeometryModule.cs"
                                            bool csharp2cuda_temp_324;
#line 798 "GeometryModule.cs"
                                            if (!(((cross) > (0.0))))
                                            {
#line 798 "GeometryModule.cs"
                                                bool csharp2cuda_temp_325;
#line 798 "GeometryModule.cs"
                                                if (((cross) == (0.0)))
                                                {
#line 798 "GeometryModule.cs"
                                                    csharp2cuda_temp_325 = ((dot) > (0.0));
                                                }
                                                else
                                                {
#line 798 "GeometryModule.cs"
                                                    csharp2cuda_temp_325 = false;
                                                }
#line 798 "GeometryModule.cs"
                                                csharp2cuda_temp_324 = csharp2cuda_temp_325;
                                            }
                                            else
                                            {
#line 798 "GeometryModule.cs"
                                                csharp2cuda_temp_324 = true;
                                            }
                                            if (csharp2cuda_temp_324)
                                            {
#line 799 "GeometryModule.cs"
#line 799 "GeometryModule.cs"
                                                int* csharp2cuda_temp_326 = &(count);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_326));
                                            }
                                        }
                                        csharp2cuda_for_continue_27:
#line 790 "GeometryModule.cs"
                                        int* csharp2cuda_temp_319 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_319));
                                    }
                                }
#line 801 "GeometryModule.cs"
#line 801 "GeometryModule.cs"
                                int* csharp2cuda_temp_327 = &(maximum);
#line 801 "GeometryModule.cs"
                                int csharp2cuda_temp_328;
#line 801 "GeometryModule.cs"
                                if (((maximum) > (count)))
                                {
#line 801 "GeometryModule.cs"
                                    csharp2cuda_temp_328 = maximum;
                                }
                                else
                                {
#line 801 "GeometryModule.cs"
                                    csharp2cuda_temp_328 = count;
                                }
                                (*(csharp2cuda_temp_327) = csharp2cuda_temp_328);
                            }
                            csharp2cuda_for_continue_28:
#line 783 "GeometryModule.cs"
                            int* csharp2cuda_temp_314 = &(pivot);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_314));
                        }
                    }
#line 803 "GeometryModule.cs"
#line 803 "GeometryModule.cs"
                    double* csharp2cuda_temp_329 = &((output)->scalar_value);
#line 804 "GeometryModule.cs"
                    int csharp2cuda_temp_330 = (first)->count;
#line 803 "GeometryModule.cs"
                    double csharp2cuda_temp_331 = __ddiv_rn(((double)(csharp2cuda_i32_sub(csharp2cuda_i32_add(coincident, vector_count), maximum))), ((double)(csharp2cuda_temp_330)));
                    (*(csharp2cuda_temp_329) = csharp2cuda_temp_331);
#line 805 "GeometryModule.cs"
                    break;
                }
#line 807 "GeometryModule.cs"
            case 12:
#line 808 "GeometryModule.cs"
#line 808 "GeometryModule.cs"
                int csharp2cuda_temp_332 = (first)->count;
#line 808 "GeometryModule.cs"
                bool csharp2cuda_temp_333;
#line 808 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_332) <= (0))))
                {
#line 808 "GeometryModule.cs"
                    int csharp2cuda_temp_334 = (second)->count;
#line 808 "GeometryModule.cs"
                    csharp2cuda_temp_333 = ((csharp2cuda_temp_334) <= (0));
                }
                else
                {
#line 808 "GeometryModule.cs"
                    csharp2cuda_temp_333 = true;
                }
                if (csharp2cuda_temp_333)
#line 809 "GeometryModule.cs"
                {
#line 810 "GeometryModule.cs"
#line 810 "GeometryModule.cs"
                    int* csharp2cuda_temp_335 = &((output)->valid);
                    (*(csharp2cuda_temp_335) = 0);
#line 811 "GeometryModule.cs"
                    break;
                }
#line 813 "GeometryModule.cs"
                {
#line 814 "GeometryModule.cs"
                    double directed_left = 0.0;
#line 815 "GeometryModule.cs"
                    {
#line 815 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 815 "GeometryModule.cs"
                            int csharp2cuda_temp_337 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_337))))
                                break;
#line 816 "GeometryModule.cs"
                            {
#line 817 "GeometryModule.cs"
                                double minimum = mathblocks_positive_infinity();
#line 818 "GeometryModule.cs"
                                {
#line 818 "GeometryModule.cs"
                                    int right = 0;
                                    while (true)
                                    {
#line 818 "GeometryModule.cs"
                                        int csharp2cuda_temp_339 = (second)->count;
                                        if (!(((right) < (csharp2cuda_temp_339))))
                                            break;
#line 819 "GeometryModule.cs"
                                        {
#line 820 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(a, left, b, right);
#line 821 "GeometryModule.cs"
#line 821 "GeometryModule.cs"
                                            double* csharp2cuda_temp_340 = &(minimum);
#line 821 "GeometryModule.cs"
                                            double csharp2cuda_temp_341;
#line 821 "GeometryModule.cs"
                                            if (((minimum) < (distance)))
                                            {
#line 821 "GeometryModule.cs"
                                                csharp2cuda_temp_341 = minimum;
                                            }
                                            else
                                            {
#line 821 "GeometryModule.cs"
                                                csharp2cuda_temp_341 = distance;
                                            }
                                            (*(csharp2cuda_temp_340) = csharp2cuda_temp_341);
                                        }
#line 818 "GeometryModule.cs"
                                        int* csharp2cuda_temp_338 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_338));
                                    }
                                }
#line 823 "GeometryModule.cs"
#line 823 "GeometryModule.cs"
                                double* csharp2cuda_temp_342 = &(directed_left);
#line 823 "GeometryModule.cs"
                                double csharp2cuda_temp_343;
#line 823 "GeometryModule.cs"
                                if (((directed_left) > (minimum)))
                                {
#line 823 "GeometryModule.cs"
                                    csharp2cuda_temp_343 = directed_left;
                                }
                                else
                                {
#line 823 "GeometryModule.cs"
                                    csharp2cuda_temp_343 = minimum;
                                }
                                (*(csharp2cuda_temp_342) = csharp2cuda_temp_343);
                            }
#line 815 "GeometryModule.cs"
                            int* csharp2cuda_temp_336 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_336));
                        }
                    }
#line 825 "GeometryModule.cs"
                    double directed_right = 0.0;
#line 826 "GeometryModule.cs"
                    {
#line 826 "GeometryModule.cs"
                        int right = 0;
                        while (true)
                        {
#line 826 "GeometryModule.cs"
                            int csharp2cuda_temp_345 = (second)->count;
                            if (!(((right) < (csharp2cuda_temp_345))))
                                break;
#line 827 "GeometryModule.cs"
                            {
#line 828 "GeometryModule.cs"
                                double minimum = mathblocks_positive_infinity();
#line 829 "GeometryModule.cs"
                                {
#line 829 "GeometryModule.cs"
                                    int left = 0;
                                    while (true)
                                    {
#line 829 "GeometryModule.cs"
                                        int csharp2cuda_temp_347 = (first)->count;
                                        if (!(((left) < (csharp2cuda_temp_347))))
                                            break;
#line 830 "GeometryModule.cs"
                                        {
#line 831 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(b, right, a, left);
#line 832 "GeometryModule.cs"
#line 832 "GeometryModule.cs"
                                            double* csharp2cuda_temp_348 = &(minimum);
#line 832 "GeometryModule.cs"
                                            double csharp2cuda_temp_349;
#line 832 "GeometryModule.cs"
                                            if (((minimum) < (distance)))
                                            {
#line 832 "GeometryModule.cs"
                                                csharp2cuda_temp_349 = minimum;
                                            }
                                            else
                                            {
#line 832 "GeometryModule.cs"
                                                csharp2cuda_temp_349 = distance;
                                            }
                                            (*(csharp2cuda_temp_348) = csharp2cuda_temp_349);
                                        }
#line 829 "GeometryModule.cs"
                                        int* csharp2cuda_temp_346 = &(left);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_346));
                                    }
                                }
#line 834 "GeometryModule.cs"
#line 834 "GeometryModule.cs"
                                double* csharp2cuda_temp_350 = &(directed_right);
#line 834 "GeometryModule.cs"
                                double csharp2cuda_temp_351;
#line 834 "GeometryModule.cs"
                                if (((directed_right) > (minimum)))
                                {
#line 834 "GeometryModule.cs"
                                    csharp2cuda_temp_351 = directed_right;
                                }
                                else
                                {
#line 834 "GeometryModule.cs"
                                    csharp2cuda_temp_351 = minimum;
                                }
                                (*(csharp2cuda_temp_350) = csharp2cuda_temp_351);
                            }
#line 826 "GeometryModule.cs"
                            int* csharp2cuda_temp_344 = &(right);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_344));
                        }
                    }
#line 836 "GeometryModule.cs"
#line 836 "GeometryModule.cs"
                    double* csharp2cuda_temp_352 = &((output)->scalar_value);
#line 836 "GeometryModule.cs"
                    double csharp2cuda_temp_353;
#line 836 "GeometryModule.cs"
                    if (((directed_left) > (directed_right)))
                    {
#line 836 "GeometryModule.cs"
                        csharp2cuda_temp_353 = directed_left;
                    }
                    else
                    {
#line 836 "GeometryModule.cs"
                        csharp2cuda_temp_353 = directed_right;
                    }
                    (*(csharp2cuda_temp_352) = csharp2cuda_temp_353);
#line 839 "GeometryModule.cs"
                    break;
                }
#line 841 "GeometryModule.cs"
            case 13:
            case 14:
#line 843 "GeometryModule.cs"
#line 843 "GeometryModule.cs"
                int csharp2cuda_temp_354 = (first)->count;
                if (((csharp2cuda_temp_354) <= (0)))
#line 844 "GeometryModule.cs"
                {
#line 845 "GeometryModule.cs"
#line 845 "GeometryModule.cs"
                    int* csharp2cuda_temp_355 = &((output)->valid);
                    (*(csharp2cuda_temp_355) = 0);
#line 846 "GeometryModule.cs"
                    break;
                }
#line 848 "GeometryModule.cs"
                {
#line 849 "GeometryModule.cs"
                    double total = 0.0;
#line 850 "GeometryModule.cs"
                    int csharp2cuda_temp_356;
#line 850 "GeometryModule.cs"
                    if (((opcode) == (13)))
                    {
#line 850 "GeometryModule.cs"
                        csharp2cuda_temp_356 = 1;
                    }
                    else
                    {
#line 850 "GeometryModule.cs"
                        csharp2cuda_temp_356 = 0;
                    }
#line 850 "GeometryModule.cs"
                    int start = csharp2cuda_temp_356;
#line 851 "GeometryModule.cs"
                    {
#line 851 "GeometryModule.cs"
                        int index = start;
                        while (true)
                        {
#line 851 "GeometryModule.cs"
                            int csharp2cuda_temp_358 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_358))))
                                break;
#line 852 "GeometryModule.cs"
                            {
#line 853 "GeometryModule.cs"
                                int csharp2cuda_temp_359;
#line 853 "GeometryModule.cs"
                                if (((opcode) == (13)))
                                {
#line 853 "GeometryModule.cs"
                                    csharp2cuda_temp_359 = csharp2cuda_i32_sub(index, 1);
                                }
                                else
                                {
#line 853 "GeometryModule.cs"
                                    csharp2cuda_temp_359 = index;
                                }
#line 853 "GeometryModule.cs"
                                int previous = csharp2cuda_temp_359;
#line 854 "GeometryModule.cs"
                                int csharp2cuda_temp_360;
#line 854 "GeometryModule.cs"
                                if (((opcode) == (13)))
                                {
#line 854 "GeometryModule.cs"
                                    csharp2cuda_temp_360 = index;
                                }
                                else
                                {
#line 854 "GeometryModule.cs"
                                    int csharp2cuda_temp_361 = (first)->count;
#line 854 "GeometryModule.cs"
                                    csharp2cuda_temp_360 = csharp2cuda_i32_rem(csharp2cuda_i32_add(index, 1), csharp2cuda_temp_361);
                                }
#line 854 "GeometryModule.cs"
                                int next = csharp2cuda_temp_360;
#line 855 "GeometryModule.cs"
#line 855 "GeometryModule.cs"
                                double* csharp2cuda_temp_362 = &(total);
#line 855 "GeometryModule.cs"
                                double csharp2cuda_temp_363 = *(csharp2cuda_temp_362);
#line 855 "GeometryModule.cs"
                                double csharp2cuda_temp_364 = mathblocks_geometry_distance(a, previous, a, next);
                                (*(csharp2cuda_temp_362) = __dadd_rn(csharp2cuda_temp_363, csharp2cuda_temp_364));
                            }
#line 851 "GeometryModule.cs"
                            int* csharp2cuda_temp_357 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_357));
                        }
                    }
#line 857 "GeometryModule.cs"
#line 857 "GeometryModule.cs"
                    double* csharp2cuda_temp_365 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_365) = total);
#line 858 "GeometryModule.cs"
                    break;
                }
#line 860 "GeometryModule.cs"
            case 15:
#line 861 "GeometryModule.cs"
#line 861 "GeometryModule.cs"
                int csharp2cuda_temp_366 = (first)->count;
#line 861 "GeometryModule.cs"
                bool csharp2cuda_temp_367;
#line 861 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_366) != (1))))
                {
#line 861 "GeometryModule.cs"
                    int csharp2cuda_temp_368 = (second)->count;
#line 861 "GeometryModule.cs"
                    csharp2cuda_temp_367 = ((csharp2cuda_temp_368) != (2));
                }
                else
                {
#line 861 "GeometryModule.cs"
                    csharp2cuda_temp_367 = true;
                }
                if (csharp2cuda_temp_367)
#line 862 "GeometryModule.cs"
                {
#line 863 "GeometryModule.cs"
#line 863 "GeometryModule.cs"
                    int* csharp2cuda_temp_369 = &((output)->valid);
                    (*(csharp2cuda_temp_369) = 0);
#line 864 "GeometryModule.cs"
                    break;
                }
#line 866 "GeometryModule.cs"
#line 866 "GeometryModule.cs"
                double* csharp2cuda_temp_370 = &((output)->scalar_value);
#line 867 "GeometryModule.cs"
                double csharp2cuda_temp_371 = (a)[0];
#line 867 "GeometryModule.cs"
                double csharp2cuda_temp_372 = (a)[1];
#line 867 "GeometryModule.cs"
                double csharp2cuda_temp_373 = (b)[0];
#line 867 "GeometryModule.cs"
                double csharp2cuda_temp_374 = (b)[1];
#line 867 "GeometryModule.cs"
                double csharp2cuda_temp_375 = (b)[2];
#line 867 "GeometryModule.cs"
                double csharp2cuda_temp_376 = (b)[3];
                (*(csharp2cuda_temp_370) = mathblocks_geometry_point_to_segment(csharp2cuda_temp_371, csharp2cuda_temp_372, csharp2cuda_temp_373, csharp2cuda_temp_374, csharp2cuda_temp_375, csharp2cuda_temp_376));
#line 868 "GeometryModule.cs"
                break;
#line 869 "GeometryModule.cs"
            case 16:
            case 17:
#line 871 "GeometryModule.cs"
#line 871 "GeometryModule.cs"
                int csharp2cuda_temp_377 = (first)->count;
                if (((csharp2cuda_temp_377) <= (0)))
#line 872 "GeometryModule.cs"
                {
#line 873 "GeometryModule.cs"
#line 873 "GeometryModule.cs"
                    int* csharp2cuda_temp_378 = &((output)->valid);
                    (*(csharp2cuda_temp_378) = 0);
#line 874 "GeometryModule.cs"
                    break;
                }
#line 876 "GeometryModule.cs"
                {
#line 877 "GeometryModule.cs"
                    double twice_area = 0.0;
#line 878 "GeometryModule.cs"
                    {
#line 878 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 878 "GeometryModule.cs"
                            int csharp2cuda_temp_380 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_380))))
                                break;
#line 879 "GeometryModule.cs"
                            {
#line 880 "GeometryModule.cs"
                                int csharp2cuda_temp_381 = (first)->count;
#line 880 "GeometryModule.cs"
                                int next = csharp2cuda_i32_rem(csharp2cuda_i32_add(index, 1), csharp2cuda_temp_381);
#line 881 "GeometryModule.cs"
#line 881 "GeometryModule.cs"
                                double* csharp2cuda_temp_382 = &(twice_area);
#line 881 "GeometryModule.cs"
                                double csharp2cuda_temp_383 = *(csharp2cuda_temp_382);
#line 881 "GeometryModule.cs"
                                double csharp2cuda_temp_384 = (a)[csharp2cuda_i32_mul(2, index)];
#line 881 "GeometryModule.cs"
                                double csharp2cuda_temp_385 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, next), 1)];
#line 882 "GeometryModule.cs"
                                double csharp2cuda_temp_386 = (a)[csharp2cuda_i32_mul(2, next)];
#line 882 "GeometryModule.cs"
                                double csharp2cuda_temp_387 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                (*(csharp2cuda_temp_382) = __dadd_rn(csharp2cuda_temp_383, __dsub_rn(__dmul_rn(csharp2cuda_temp_384, csharp2cuda_temp_385), __dmul_rn(csharp2cuda_temp_386, csharp2cuda_temp_387))));
                            }
#line 878 "GeometryModule.cs"
                            int* csharp2cuda_temp_379 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_379));
                        }
                    }
#line 884 "GeometryModule.cs"
#line 884 "GeometryModule.cs"
                    double* csharp2cuda_temp_388 = &((output)->scalar_value);
#line 884 "GeometryModule.cs"
                    double csharp2cuda_temp_389;
#line 884 "GeometryModule.cs"
                    if (((opcode) == (16)))
                    {
#line 884 "GeometryModule.cs"
                        double csharp2cuda_temp_390 = __ddiv_rn(twice_area, 2.0);
#line 884 "GeometryModule.cs"
                        csharp2cuda_temp_389 = fabs(csharp2cuda_temp_390);
                    }
                    else
                    {
#line 884 "GeometryModule.cs"
                        csharp2cuda_temp_389 = __ddiv_rn(twice_area, 2.0);
                    }
                    (*(csharp2cuda_temp_388) = csharp2cuda_temp_389);
#line 885 "GeometryModule.cs"
                    break;
                }
#line 887 "GeometryModule.cs"
            case 18:
#line 888 "GeometryModule.cs"
#line 888 "GeometryModule.cs"
                int csharp2cuda_temp_391 = (first)->count;
#line 888 "GeometryModule.cs"
                bool csharp2cuda_temp_392;
#line 888 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_391) < (3))))
                {
#line 888 "GeometryModule.cs"
                    int csharp2cuda_temp_393 = (second)->count;
#line 888 "GeometryModule.cs"
                    csharp2cuda_temp_392 = ((csharp2cuda_temp_393) != (1));
                }
                else
                {
#line 888 "GeometryModule.cs"
                    csharp2cuda_temp_392 = true;
                }
                if (csharp2cuda_temp_392)
#line 889 "GeometryModule.cs"
                {
#line 890 "GeometryModule.cs"
#line 890 "GeometryModule.cs"
                    int* csharp2cuda_temp_394 = &((output)->valid);
                    (*(csharp2cuda_temp_394) = 0);
#line 891 "GeometryModule.cs"
                    break;
                }
#line 893 "GeometryModule.cs"
                {
#line 894 "GeometryModule.cs"
                    int containing = 0;
#line 895 "GeometryModule.cs"
                    int total = 0;
#line 896 "GeometryModule.cs"
                    double csharp2cuda_temp_395_storage[3];
                    double* coordinates = csharp2cuda_temp_395_storage;
#line 897 "GeometryModule.cs"
                    {
#line 897 "GeometryModule.cs"
                        int one = 0;
                        while (true)
                        {
#line 897 "GeometryModule.cs"
                            int csharp2cuda_temp_397 = (first)->count;
                            if (!(((one) < (csharp2cuda_temp_397))))
                                break;
#line 898 "GeometryModule.cs"
                            {
#line 898 "GeometryModule.cs"
                                int two = csharp2cuda_i32_add(one, 1);
                                while (true)
                                {
#line 898 "GeometryModule.cs"
                                    int csharp2cuda_temp_399 = (first)->count;
                                    if (!(((two) < (csharp2cuda_temp_399))))
                                        break;
#line 899 "GeometryModule.cs"
                                    {
#line 899 "GeometryModule.cs"
                                        int three = csharp2cuda_i32_add(two, 1);
                                        while (true)
                                        {
#line 899 "GeometryModule.cs"
                                            int csharp2cuda_temp_401 = (first)->count;
                                            if (!(((three) < (csharp2cuda_temp_401))))
                                                break;
#line 900 "GeometryModule.cs"
                                            {
#line 901 "GeometryModule.cs"
#line 901 "GeometryModule.cs"
                                                int* csharp2cuda_temp_402 = &(total);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_402));
#line 902 "GeometryModule.cs"
#line 903 "GeometryModule.cs"
                                                double csharp2cuda_temp_403 = (b)[0];
#line 903 "GeometryModule.cs"
                                                double csharp2cuda_temp_404 = (b)[1];
#line 904 "GeometryModule.cs"
                                                double csharp2cuda_temp_405 = (a)[csharp2cuda_i32_mul(2, one)];
#line 904 "GeometryModule.cs"
                                                double csharp2cuda_temp_406 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, one), 1)];
#line 905 "GeometryModule.cs"
                                                double csharp2cuda_temp_407 = (a)[csharp2cuda_i32_mul(2, two)];
#line 905 "GeometryModule.cs"
                                                double csharp2cuda_temp_408 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, two), 1)];
#line 906 "GeometryModule.cs"
                                                double csharp2cuda_temp_409 = (a)[csharp2cuda_i32_mul(2, three)];
#line 906 "GeometryModule.cs"
                                                double csharp2cuda_temp_410 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, three), 1)];
                                                mathblocks_geometry_barycentric(csharp2cuda_temp_403, csharp2cuda_temp_404, csharp2cuda_temp_405, csharp2cuda_temp_406, csharp2cuda_temp_407, csharp2cuda_temp_408, csharp2cuda_temp_409, csharp2cuda_temp_410, coordinates);
#line 908 "GeometryModule.cs"
#line 908 "GeometryModule.cs"
                                                double csharp2cuda_temp_411 = (coordinates)[0];
#line 908 "GeometryModule.cs"
                                                bool csharp2cuda_temp_412;
#line 908 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_411) >= (0.0)))
                                                {
#line 908 "GeometryModule.cs"
                                                    double csharp2cuda_temp_413 = (coordinates)[0];
#line 908 "GeometryModule.cs"
                                                    csharp2cuda_temp_412 = ((csharp2cuda_temp_413) <= (1.0));
                                                }
                                                else
                                                {
#line 908 "GeometryModule.cs"
                                                    csharp2cuda_temp_412 = false;
                                                }
#line 908 "GeometryModule.cs"
                                                bool csharp2cuda_temp_414;
#line 908 "GeometryModule.cs"
                                                if (csharp2cuda_temp_412)
                                                {
#line 909 "GeometryModule.cs"
                                                    double csharp2cuda_temp_415 = (coordinates)[1];
#line 908 "GeometryModule.cs"
                                                    csharp2cuda_temp_414 = ((csharp2cuda_temp_415) >= (0.0));
                                                }
                                                else
                                                {
#line 908 "GeometryModule.cs"
                                                    csharp2cuda_temp_414 = false;
                                                }
#line 908 "GeometryModule.cs"
                                                bool csharp2cuda_temp_416;
#line 908 "GeometryModule.cs"
                                                if (csharp2cuda_temp_414)
                                                {
#line 909 "GeometryModule.cs"
                                                    double csharp2cuda_temp_417 = (coordinates)[1];
#line 908 "GeometryModule.cs"
                                                    csharp2cuda_temp_416 = ((csharp2cuda_temp_417) <= (1.0));
                                                }
                                                else
                                                {
#line 908 "GeometryModule.cs"
                                                    csharp2cuda_temp_416 = false;
                                                }
#line 908 "GeometryModule.cs"
                                                bool csharp2cuda_temp_418;
#line 908 "GeometryModule.cs"
                                                if (csharp2cuda_temp_416)
                                                {
#line 910 "GeometryModule.cs"
                                                    double csharp2cuda_temp_419 = (coordinates)[2];
#line 908 "GeometryModule.cs"
                                                    csharp2cuda_temp_418 = ((csharp2cuda_temp_419) >= (0.0));
                                                }
                                                else
                                                {
#line 908 "GeometryModule.cs"
                                                    csharp2cuda_temp_418 = false;
                                                }
#line 908 "GeometryModule.cs"
                                                bool csharp2cuda_temp_420;
#line 908 "GeometryModule.cs"
                                                if (csharp2cuda_temp_418)
                                                {
#line 910 "GeometryModule.cs"
                                                    double csharp2cuda_temp_421 = (coordinates)[2];
#line 908 "GeometryModule.cs"
                                                    csharp2cuda_temp_420 = ((csharp2cuda_temp_421) <= (1.0));
                                                }
                                                else
                                                {
#line 908 "GeometryModule.cs"
                                                    csharp2cuda_temp_420 = false;
                                                }
                                                if (csharp2cuda_temp_420)
#line 911 "GeometryModule.cs"
                                                {
#line 912 "GeometryModule.cs"
#line 912 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_422 = &(containing);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_422));
                                                }
                                            }
#line 899 "GeometryModule.cs"
                                            int* csharp2cuda_temp_400 = &(three);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_400));
                                        }
                                    }
#line 898 "GeometryModule.cs"
                                    int* csharp2cuda_temp_398 = &(two);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_398));
                                }
                            }
#line 897 "GeometryModule.cs"
                            int* csharp2cuda_temp_396 = &(one);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_396));
                        }
                    }
#line 915 "GeometryModule.cs"
#line 915 "GeometryModule.cs"
                    double* csharp2cuda_temp_423 = &((output)->scalar_value);
#line 915 "GeometryModule.cs"
                    double csharp2cuda_temp_424 = __ddiv_rn(((double)(containing)), ((double)(total)));
                    (*(csharp2cuda_temp_423) = csharp2cuda_temp_424);
#line 916 "GeometryModule.cs"
                    break;
                }
#line 918 "GeometryModule.cs"
            case 19:
#line 919 "GeometryModule.cs"
#line 919 "GeometryModule.cs"
                int* csharp2cuda_temp_425 = &((output)->rows);
#line 919 "GeometryModule.cs"
                int csharp2cuda_temp_426 = (first)->rows;
                (*(csharp2cuda_temp_425) = csharp2cuda_temp_426);
#line 920 "GeometryModule.cs"
#line 920 "GeometryModule.cs"
                int* csharp2cuda_temp_427 = &((output)->count);
#line 920 "GeometryModule.cs"
                int csharp2cuda_temp_428 = (first)->rows;
                (*(csharp2cuda_temp_427) = csharp2cuda_temp_428);
#line 921 "GeometryModule.cs"
#line 921 "GeometryModule.cs"
                int csharp2cuda_temp_429 = (first)->columns;
#line 921 "GeometryModule.cs"
                bool csharp2cuda_temp_430;
#line 921 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_429) != (2))))
                {
#line 921 "GeometryModule.cs"
                    int csharp2cuda_temp_431 = (first)->rows;
#line 921 "GeometryModule.cs"
                    int csharp2cuda_temp_432 = (output)->capacity;
#line 921 "GeometryModule.cs"
                    csharp2cuda_temp_430 = ((csharp2cuda_temp_431) > (csharp2cuda_temp_432));
                }
                else
                {
#line 921 "GeometryModule.cs"
                    csharp2cuda_temp_430 = true;
                }
                if (csharp2cuda_temp_430)
#line 922 "GeometryModule.cs"
                {
#line 923 "GeometryModule.cs"
#line 923 "GeometryModule.cs"
                    int* csharp2cuda_temp_433 = &((output)->valid);
                    (*(csharp2cuda_temp_433) = 0);
#line 924 "GeometryModule.cs"
                    break;
                }
#line 926 "GeometryModule.cs"
                {
#line 926 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 926 "GeometryModule.cs"
                        int csharp2cuda_temp_435 = (first)->rows;
                        if (!(((index) < (csharp2cuda_i32_mul(csharp2cuda_temp_435, 2)))))
                            break;
#line 927 "GeometryModule.cs"
#line 927 "GeometryModule.cs"
                        double* csharp2cuda_temp_436 = &((result)[index]);
#line 927 "GeometryModule.cs"
                        double csharp2cuda_temp_437 = (a)[index];
                        (*(csharp2cuda_temp_436) = csharp2cuda_temp_437);
#line 926 "GeometryModule.cs"
                        int* csharp2cuda_temp_434 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_434));
                    }
                }
#line 928 "GeometryModule.cs"
                break;
#line 929 "GeometryModule.cs"
            case 20:
#line 930 "GeometryModule.cs"
#line 930 "GeometryModule.cs"
                int csharp2cuda_temp_438 = (first)->count;
                mathblocks_sequence_set_matrix_shape(output, csharp2cuda_temp_438, 2);
#line 931 "GeometryModule.cs"
#line 931 "GeometryModule.cs"
                int csharp2cuda_temp_439 = (first)->count;
                if (((csharp2cuda_temp_439) <= (0)))
#line 932 "GeometryModule.cs"
                {
#line 933 "GeometryModule.cs"
#line 933 "GeometryModule.cs"
                    int* csharp2cuda_temp_440 = &((output)->valid);
                    (*(csharp2cuda_temp_440) = 0);
#line 934 "GeometryModule.cs"
                    break;
                }
#line 936 "GeometryModule.cs"
                {
#line 936 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 936 "GeometryModule.cs"
                        int csharp2cuda_temp_442 = (first)->count;
                        if (!(((index) < (csharp2cuda_i32_mul(csharp2cuda_temp_442, 2)))))
                            break;
#line 937 "GeometryModule.cs"
#line 937 "GeometryModule.cs"
                        double* csharp2cuda_temp_443 = &((result)[index]);
#line 937 "GeometryModule.cs"
                        double csharp2cuda_temp_444 = (a)[index];
                        (*(csharp2cuda_temp_443) = csharp2cuda_temp_444);
#line 936 "GeometryModule.cs"
                        int* csharp2cuda_temp_441 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_441));
                    }
                }
#line 938 "GeometryModule.cs"
                break;
#line 939 "GeometryModule.cs"
            case 21:
#line 940 "GeometryModule.cs"
#line 940 "GeometryModule.cs"
                int csharp2cuda_temp_445 = (first)->count;
#line 940 "GeometryModule.cs"
                bool csharp2cuda_temp_446;
#line 940 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_445) <= (0))))
                {
#line 940 "GeometryModule.cs"
                    csharp2cuda_temp_446 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 940 "GeometryModule.cs"
                    csharp2cuda_temp_446 = true;
                }
                if (csharp2cuda_temp_446)
#line 941 "GeometryModule.cs"
                {
#line 942 "GeometryModule.cs"
#line 942 "GeometryModule.cs"
                    int* csharp2cuda_temp_447 = &((output)->valid);
                    (*(csharp2cuda_temp_447) = 0);
#line 943 "GeometryModule.cs"
                    break;
                }
#line 945 "GeometryModule.cs"
#line 945 "GeometryModule.cs"
                int csharp2cuda_temp_448 = (first)->count;
                if (((csharp2cuda_temp_448) == (1)))
#line 946 "GeometryModule.cs"
                {
#line 947 "GeometryModule.cs"
                    mathblocks_sequence_set_vector_shape(output, 0);
#line 948 "GeometryModule.cs"
                    break;
                }
#line 950 "GeometryModule.cs"
                {
#line 951 "GeometryModule.cs"
                    int vertex_count = (first)->count;
#line 952 "GeometryModule.cs"
                    int edge_capacity = csharp2cuda_i32_div(csharp2cuda_i32_mul(vertex_count, csharp2cuda_i32_sub(vertex_count, 1)), 2);
#line 953 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(scratch));
#line 954 "GeometryModule.cs"
                    int edge_count = 0;
#line 955 "GeometryModule.cs"
                    {
#line 955 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (vertex_count))))
                                break;
#line 956 "GeometryModule.cs"
                            {
#line 956 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
                                    if (!(((right) < (vertex_count))))
                                        break;
#line 957 "GeometryModule.cs"
                                    {
#line 958 "GeometryModule.cs"
#line 958 "GeometryModule.cs"
                                        int* csharp2cuda_temp_451 = &(((edges)[edge_count]).from);
                                        (*(csharp2cuda_temp_451) = left);
#line 959 "GeometryModule.cs"
#line 959 "GeometryModule.cs"
                                        int* csharp2cuda_temp_452 = &(((edges)[edge_count]).to);
                                        (*(csharp2cuda_temp_452) = right);
#line 960 "GeometryModule.cs"
#line 960 "GeometryModule.cs"
                                        double* csharp2cuda_temp_453 = &(((edges)[edge_count]).weight);
#line 960 "GeometryModule.cs"
                                        double csharp2cuda_temp_454 = mathblocks_geometry_distance(a, left, a, right);
                                        (*(csharp2cuda_temp_453) = csharp2cuda_temp_454);
#line 961 "GeometryModule.cs"
#line 961 "GeometryModule.cs"
                                        int* csharp2cuda_temp_455 = &(edge_count);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_455));
                                    }
#line 956 "GeometryModule.cs"
                                    int* csharp2cuda_temp_450 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_450));
                                }
                            }
#line 955 "GeometryModule.cs"
                            int* csharp2cuda_temp_449 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_449));
                        }
                    }
#line 963 "GeometryModule.cs"
                    mathblocks_geometry_sort_edges(edges, csharp2cuda_pointer_add(edges, edge_capacity), edge_count);
#line 964 "GeometryModule.cs"
                    int* parent = ((int*)(csharp2cuda_pointer_add(edges, csharp2cuda_i32_mul(2, edge_capacity))));
#line 965 "GeometryModule.cs"
                    unsigned char* rank = ((unsigned char*)(csharp2cuda_pointer_add(parent, vertex_count)));
#line 966 "GeometryModule.cs"
                    {
#line 966 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (vertex_count))))
                                break;
#line 967 "GeometryModule.cs"
                            {
#line 968 "GeometryModule.cs"
#line 968 "GeometryModule.cs"
                                int* csharp2cuda_temp_457 = &((parent)[index]);
                                (*(csharp2cuda_temp_457) = index);
#line 969 "GeometryModule.cs"
#line 969 "GeometryModule.cs"
                                unsigned char* csharp2cuda_temp_458 = &((rank)[index]);
                                (*(csharp2cuda_temp_458) = ((unsigned char)(0)));
                            }
#line 966 "GeometryModule.cs"
                            int* csharp2cuda_temp_456 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_456));
                        }
                    }
#line 971 "GeometryModule.cs"
                    int selected = 0;
#line 972 "GeometryModule.cs"
                    {
#line 972 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 972 "GeometryModule.cs"
                            bool csharp2cuda_temp_460;
#line 972 "GeometryModule.cs"
                            if (((index) < (edge_count)))
                            {
#line 972 "GeometryModule.cs"
                                csharp2cuda_temp_460 = ((selected) < (csharp2cuda_i32_sub(vertex_count, 1)));
                            }
                            else
                            {
#line 972 "GeometryModule.cs"
                                csharp2cuda_temp_460 = false;
                            }
                            if (!(csharp2cuda_temp_460))
                                break;
#line 973 "GeometryModule.cs"
                            {
#line 974 "GeometryModule.cs"
                                int csharp2cuda_temp_461 = ((edges)[index]).from;
#line 974 "GeometryModule.cs"
                                int left = mathblocks_geometry_find(parent, csharp2cuda_temp_461);
#line 975 "GeometryModule.cs"
                                int csharp2cuda_temp_462 = ((edges)[index]).to;
#line 975 "GeometryModule.cs"
                                int right = mathblocks_geometry_find(parent, csharp2cuda_temp_462);
#line 976 "GeometryModule.cs"
                                if (((left) == (right)))
                                {
#line 977 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_43;
                                }
#line 978 "GeometryModule.cs"
#line 978 "GeometryModule.cs"
                                unsigned char csharp2cuda_temp_463 = (rank)[left];
#line 978 "GeometryModule.cs"
                                unsigned char csharp2cuda_temp_464 = (rank)[right];
                                if (((((int)(csharp2cuda_temp_463))) < (((int)(csharp2cuda_temp_464)))))
                                {
#line 979 "GeometryModule.cs"
#line 979 "GeometryModule.cs"
                                    int* csharp2cuda_temp_465 = &((parent)[left]);
                                    (*(csharp2cuda_temp_465) = right);
                                }
                                else
                                {
#line 980 "GeometryModule.cs"
#line 980 "GeometryModule.cs"
                                    unsigned char csharp2cuda_temp_466 = (rank)[left];
#line 980 "GeometryModule.cs"
                                    unsigned char csharp2cuda_temp_467 = (rank)[right];
                                    if (((((int)(csharp2cuda_temp_466))) > (((int)(csharp2cuda_temp_467)))))
                                    {
#line 981 "GeometryModule.cs"
#line 981 "GeometryModule.cs"
                                        int* csharp2cuda_temp_468 = &((parent)[right]);
                                        (*(csharp2cuda_temp_468) = left);
                                    }
                                    else
#line 983 "GeometryModule.cs"
                                    {
#line 984 "GeometryModule.cs"
#line 984 "GeometryModule.cs"
                                        int* csharp2cuda_temp_469 = &((parent)[right]);
                                        (*(csharp2cuda_temp_469) = left);
#line 985 "GeometryModule.cs"
#line 985 "GeometryModule.cs"
                                        unsigned char* csharp2cuda_temp_470 = &((rank)[left]);
                                        (*(csharp2cuda_temp_470))++;
                                    }
                                }
#line 987 "GeometryModule.cs"
#line 987 "GeometryModule.cs"
                                int* csharp2cuda_temp_471 = &(selected);
#line 987 "GeometryModule.cs"
                                int csharp2cuda_temp_472 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_471));
#line 987 "GeometryModule.cs"
                                double* csharp2cuda_temp_473 = &((result)[csharp2cuda_temp_472]);
#line 987 "GeometryModule.cs"
                                double csharp2cuda_temp_474 = ((edges)[index]).weight;
                                (*(csharp2cuda_temp_473) = csharp2cuda_temp_474);
                            }
                            csharp2cuda_for_continue_43:
#line 972 "GeometryModule.cs"
                            int* csharp2cuda_temp_459 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_459));
                        }
                    }
#line 989 "GeometryModule.cs"
                    mathblocks_sequence_set_vector_shape(output, selected);
#line 990 "GeometryModule.cs"
                    {
#line 990 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (selected))))
                                break;
#line 991 "GeometryModule.cs"
#line 991 "GeometryModule.cs"
                            double csharp2cuda_temp_476 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_476))))
                            {
#line 991 "GeometryModule.cs"
#line 991 "GeometryModule.cs"
                                int* csharp2cuda_temp_477 = &((output)->valid);
                                (*(csharp2cuda_temp_477) = 0);
                            }
#line 990 "GeometryModule.cs"
                            int* csharp2cuda_temp_475 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_475));
                        }
                    }
#line 992 "GeometryModule.cs"
                    break;
                }
        }
#line 995 "GeometryModule.cs"
#line 995 "GeometryModule.cs"
        bool csharp2cuda_temp_478 = (output)->valid;
#line 995 "GeometryModule.cs"
        bool csharp2cuda_temp_479;
#line 995 "GeometryModule.cs"
        if (csharp2cuda_temp_478)
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_479 = ((opcode) != (0));
        }
        else
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_479 = false;
        }
#line 995 "GeometryModule.cs"
        bool csharp2cuda_temp_480;
#line 995 "GeometryModule.cs"
        if (csharp2cuda_temp_479)
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_480 = ((opcode) != (1));
        }
        else
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_480 = false;
        }
#line 995 "GeometryModule.cs"
        bool csharp2cuda_temp_481;
#line 995 "GeometryModule.cs"
        if (csharp2cuda_temp_480)
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_481 = ((opcode) != (3));
        }
        else
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_481 = false;
        }
#line 995 "GeometryModule.cs"
        bool csharp2cuda_temp_482;
#line 995 "GeometryModule.cs"
        if (csharp2cuda_temp_481)
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_482 = ((opcode) != (4));
        }
        else
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_482 = false;
        }
#line 995 "GeometryModule.cs"
        bool csharp2cuda_temp_483;
#line 995 "GeometryModule.cs"
        if (csharp2cuda_temp_482)
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_483 = ((opcode) != (5));
        }
        else
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_483 = false;
        }
#line 995 "GeometryModule.cs"
        bool csharp2cuda_temp_484;
#line 995 "GeometryModule.cs"
        if (csharp2cuda_temp_483)
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_484 = ((opcode) != (10));
        }
        else
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_484 = false;
        }
#line 995 "GeometryModule.cs"
        bool csharp2cuda_temp_485;
#line 995 "GeometryModule.cs"
        if (csharp2cuda_temp_484)
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_485 = ((opcode) != (19));
        }
        else
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_485 = false;
        }
#line 995 "GeometryModule.cs"
        bool csharp2cuda_temp_486;
#line 995 "GeometryModule.cs"
        if (csharp2cuda_temp_485)
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_486 = ((opcode) != (20));
        }
        else
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_486 = false;
        }
#line 995 "GeometryModule.cs"
        bool csharp2cuda_temp_487;
#line 995 "GeometryModule.cs"
        if (csharp2cuda_temp_486)
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_487 = ((opcode) != (21));
        }
        else
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_487 = false;
        }
#line 995 "GeometryModule.cs"
        bool csharp2cuda_temp_488;
#line 995 "GeometryModule.cs"
        if (csharp2cuda_temp_487)
        {
#line 998 "GeometryModule.cs"
            double csharp2cuda_temp_489 = (output)->scalar_value;
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_488 = (!(isfinite(csharp2cuda_temp_489)));
        }
        else
        {
#line 995 "GeometryModule.cs"
            csharp2cuda_temp_488 = false;
        }
        if (csharp2cuda_temp_488)
#line 999 "GeometryModule.cs"
        {
#line 1000 "GeometryModule.cs"
#line 1000 "GeometryModule.cs"
            int* csharp2cuda_temp_490 = &((output)->valid);
            (*(csharp2cuda_temp_490) = 0);
        }
    }
}

#line 59 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance(
    const double* left,
    int left_index,
    const double* right,
    int right_index)
#line 65 "GeometryModule.cs"
{
#line 66 "GeometryModule.cs"
#line 67 "GeometryModule.cs"
    double csharp2cuda_temp_0 = (left)[csharp2cuda_i32_mul(2, left_index)];
#line 68 "GeometryModule.cs"
    double csharp2cuda_temp_1 = (left)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left_index), 1)];
#line 69 "GeometryModule.cs"
    double csharp2cuda_temp_2 = (right)[csharp2cuda_i32_mul(2, right_index)];
#line 70 "GeometryModule.cs"
    double csharp2cuda_temp_3 = (right)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right_index), 1)];
    return mathblocks_geometry_distance_coordinates(csharp2cuda_temp_0, csharp2cuda_temp_1, csharp2cuda_temp_2, csharp2cuda_temp_3);
}

#line 47 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance_coordinates(
    double left_x,
    double left_y,
    double right_x,
    double right_y)
#line 53 "GeometryModule.cs"
{
#line 54 "GeometryModule.cs"
    double x = __dsub_rn(left_x, right_x);
#line 55 "GeometryModule.cs"
    double y = __dsub_rn(left_y, right_y);
#line 56 "GeometryModule.cs"
    return mathblocks_square_root(__dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y)));
}

#line 296 "GeometryModule.cs"
__device__ bool mathblocks_geometry_edge_less(
    const MathBlockGeometryEdge* left,
    const MathBlockGeometryEdge* right)
#line 300 "GeometryModule.cs"
{
#line 301 "GeometryModule.cs"
#line 301 "GeometryModule.cs"
    double csharp2cuda_temp_0 = (*(left)).weight;
#line 301 "GeometryModule.cs"
    double csharp2cuda_temp_1 = (*(right)).weight;
    if (((csharp2cuda_temp_0) < (csharp2cuda_temp_1)))
    {
#line 302 "GeometryModule.cs"
        return true;
    }
#line 303 "GeometryModule.cs"
#line 303 "GeometryModule.cs"
    double csharp2cuda_temp_2 = (*(right)).weight;
#line 303 "GeometryModule.cs"
    double csharp2cuda_temp_3 = (*(left)).weight;
    if (((csharp2cuda_temp_2) < (csharp2cuda_temp_3)))
    {
#line 304 "GeometryModule.cs"
        return false;
    }
#line 305 "GeometryModule.cs"
#line 305 "GeometryModule.cs"
    int csharp2cuda_temp_4 = (*(left)).from;
#line 305 "GeometryModule.cs"
    int csharp2cuda_temp_5 = (*(right)).from;
    if (((csharp2cuda_temp_4) < (csharp2cuda_temp_5)))
    {
#line 306 "GeometryModule.cs"
        return true;
    }
#line 307 "GeometryModule.cs"
#line 307 "GeometryModule.cs"
    int csharp2cuda_temp_6 = (*(right)).from;
#line 307 "GeometryModule.cs"
    int csharp2cuda_temp_7 = (*(left)).from;
    if (((csharp2cuda_temp_6) < (csharp2cuda_temp_7)))
    {
#line 308 "GeometryModule.cs"
        return false;
    }
#line 309 "GeometryModule.cs"
#line 309 "GeometryModule.cs"
    int csharp2cuda_temp_8 = (*(left)).to;
#line 309 "GeometryModule.cs"
    int csharp2cuda_temp_9 = (*(right)).to;
    return ((csharp2cuda_temp_8) < (csharp2cuda_temp_9));
}

#line 285 "GeometryModule.cs"
__device__ int mathblocks_geometry_find(int* parent, int value)
#line 287 "GeometryModule.cs"
{
#line 288 "GeometryModule.cs"
    while (true)
    {
#line 288 "GeometryModule.cs"
        int csharp2cuda_temp_0 = (parent)[value];
        if (!(((csharp2cuda_temp_0) != (value))))
            break;
#line 289 "GeometryModule.cs"
        {
#line 290 "GeometryModule.cs"
#line 290 "GeometryModule.cs"
            int* csharp2cuda_temp_1 = &((parent)[value]);
#line 290 "GeometryModule.cs"
            int csharp2cuda_temp_2 = (parent)[value];
#line 290 "GeometryModule.cs"
            int csharp2cuda_temp_3 = (parent)[csharp2cuda_temp_2];
            (*(csharp2cuda_temp_1) = csharp2cuda_temp_3);
#line 291 "GeometryModule.cs"
#line 291 "GeometryModule.cs"
            int* csharp2cuda_temp_4 = &(value);
#line 291 "GeometryModule.cs"
            int csharp2cuda_temp_5 = (parent)[value];
            (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
        }
    }
#line 293 "GeometryModule.cs"
    return value;
}

#line 196 "GeometryModule.cs"
__device__ void mathblocks_geometry_index_order(
    const double* points,
    int count,
    int* order,
    int* buffer)
#line 202 "GeometryModule.cs"
{
#line 203 "GeometryModule.cs"
    {
#line 203 "GeometryModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 204 "GeometryModule.cs"
#line 204 "GeometryModule.cs"
            int* csharp2cuda_temp_1 = &((order)[index]);
            (*(csharp2cuda_temp_1) = index);
#line 203 "GeometryModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 205 "GeometryModule.cs"
    int* source = order;
#line 206 "GeometryModule.cs"
    int* target = buffer;
#line 207 "GeometryModule.cs"
    {
#line 207 "GeometryModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 208 "GeometryModule.cs"
            {
#line 209 "GeometryModule.cs"
                {
#line 209 "GeometryModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 210 "GeometryModule.cs"
                        {
#line 211 "GeometryModule.cs"
                            int csharp2cuda_temp_6;
#line 211 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 211 "GeometryModule.cs"
                                csharp2cuda_temp_6 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 211 "GeometryModule.cs"
                                csharp2cuda_temp_6 = count;
                            }
#line 211 "GeometryModule.cs"
                            int middle = csharp2cuda_temp_6;
#line 212 "GeometryModule.cs"
                            int csharp2cuda_temp_7;
#line 212 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 212 "GeometryModule.cs"
                                csharp2cuda_temp_7 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 212 "GeometryModule.cs"
                                csharp2cuda_temp_7 = count;
                            }
#line 212 "GeometryModule.cs"
                            int end = csharp2cuda_temp_7;
#line 213 "GeometryModule.cs"
                            int left = start;
#line 214 "GeometryModule.cs"
                            int right = middle;
#line 215 "GeometryModule.cs"
                            int position = start;
#line 216 "GeometryModule.cs"
                            while (true)
                            {
#line 216 "GeometryModule.cs"
                                bool csharp2cuda_temp_8;
#line 216 "GeometryModule.cs"
                                if (((left) < (middle)))
                                {
#line 216 "GeometryModule.cs"
                                    csharp2cuda_temp_8 = ((right) < (end));
                                }
                                else
                                {
#line 216 "GeometryModule.cs"
                                    csharp2cuda_temp_8 = false;
                                }
                                if (!(csharp2cuda_temp_8))
                                    break;
#line 217 "GeometryModule.cs"
                                {
#line 218 "GeometryModule.cs"
                                    int csharp2cuda_temp_9 = (source)[right];
#line 218 "GeometryModule.cs"
                                    int csharp2cuda_temp_10 = (source)[left];
#line 218 "GeometryModule.cs"
                                    bool take_right = mathblocks_geometry_point_less(points, csharp2cuda_temp_9, csharp2cuda_temp_10);
#line 219 "GeometryModule.cs"
#line 219 "GeometryModule.cs"
                                    int* csharp2cuda_temp_11 = &(position);
#line 219 "GeometryModule.cs"
                                    int csharp2cuda_temp_12 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_11));
#line 219 "GeometryModule.cs"
                                    int* csharp2cuda_temp_13 = &((target)[csharp2cuda_temp_12]);
#line 219 "GeometryModule.cs"
                                    int csharp2cuda_temp_14;
#line 219 "GeometryModule.cs"
                                    if (take_right)
                                    {
#line 219 "GeometryModule.cs"
                                        int* csharp2cuda_temp_15 = &(right);
#line 219 "GeometryModule.cs"
                                        int csharp2cuda_temp_16 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
#line 219 "GeometryModule.cs"
                                        csharp2cuda_temp_14 = (source)[csharp2cuda_temp_16];
                                    }
                                    else
                                    {
#line 219 "GeometryModule.cs"
                                        int* csharp2cuda_temp_17 = &(left);
#line 219 "GeometryModule.cs"
                                        int csharp2cuda_temp_18 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_17));
#line 219 "GeometryModule.cs"
                                        csharp2cuda_temp_14 = (source)[csharp2cuda_temp_18];
                                    }
                                    (*(csharp2cuda_temp_13) = csharp2cuda_temp_14);
                                }
                            }
#line 221 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 222 "GeometryModule.cs"
#line 222 "GeometryModule.cs"
                                int* csharp2cuda_temp_19 = &(position);
#line 222 "GeometryModule.cs"
                                int csharp2cuda_temp_20 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_19));
#line 222 "GeometryModule.cs"
                                int* csharp2cuda_temp_21 = &((target)[csharp2cuda_temp_20]);
#line 222 "GeometryModule.cs"
                                int* csharp2cuda_temp_22 = &(left);
#line 222 "GeometryModule.cs"
                                int csharp2cuda_temp_23 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_22));
#line 222 "GeometryModule.cs"
                                int csharp2cuda_temp_24 = (source)[csharp2cuda_temp_23];
                                (*(csharp2cuda_temp_21) = csharp2cuda_temp_24);
                            }
#line 223 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 224 "GeometryModule.cs"
#line 224 "GeometryModule.cs"
                                int* csharp2cuda_temp_25 = &(position);
#line 224 "GeometryModule.cs"
                                int csharp2cuda_temp_26 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_25));
#line 224 "GeometryModule.cs"
                                int* csharp2cuda_temp_27 = &((target)[csharp2cuda_temp_26]);
#line 224 "GeometryModule.cs"
                                int* csharp2cuda_temp_28 = &(right);
#line 224 "GeometryModule.cs"
                                int csharp2cuda_temp_29 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_28));
#line 224 "GeometryModule.cs"
                                int csharp2cuda_temp_30 = (source)[csharp2cuda_temp_29];
                                (*(csharp2cuda_temp_27) = csharp2cuda_temp_30);
                            }
                        }
#line 209 "GeometryModule.cs"
                        int* csharp2cuda_temp_4 = &(start);
#line 209 "GeometryModule.cs"
                        int csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
                        (*(csharp2cuda_temp_4) = csharp2cuda_i32_add(csharp2cuda_temp_5, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 226 "GeometryModule.cs"
                int* sorted = target;
#line 227 "GeometryModule.cs"
#line 227 "GeometryModule.cs"
                int** csharp2cuda_temp_31 = &(target);
                (*(csharp2cuda_temp_31) = source);
#line 228 "GeometryModule.cs"
#line 228 "GeometryModule.cs"
                int** csharp2cuda_temp_32 = &(source);
                (*(csharp2cuda_temp_32) = sorted);
            }
#line 207 "GeometryModule.cs"
            int* csharp2cuda_temp_2 = &(width);
#line 207 "GeometryModule.cs"
            int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
            (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, width));
        }
    }
#line 230 "GeometryModule.cs"
    if (((((void*)(source))) != (((void*)(order)))))
    {
#line 231 "GeometryModule.cs"
        {
#line 231 "GeometryModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 232 "GeometryModule.cs"
#line 232 "GeometryModule.cs"
                int* csharp2cuda_temp_34 = &((order)[index]);
#line 232 "GeometryModule.cs"
                int csharp2cuda_temp_35 = (source)[index];
                (*(csharp2cuda_temp_34) = csharp2cuda_temp_35);
#line 231 "GeometryModule.cs"
                int* csharp2cuda_temp_33 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_33));
            }
        }
    }
}

#line 174 "GeometryModule.cs"
__device__ bool mathblocks_geometry_point_less(
    const double* points,
    int left,
    int right)
#line 179 "GeometryModule.cs"
{
#line 180 "GeometryModule.cs"
    double left_x = (points)[csharp2cuda_i32_mul(2, left)];
#line 181 "GeometryModule.cs"
    double right_x = (points)[csharp2cuda_i32_mul(2, right)];
#line 182 "GeometryModule.cs"
    if (((left_x) < (right_x)))
    {
#line 183 "GeometryModule.cs"
        return true;
    }
#line 184 "GeometryModule.cs"
    if (((right_x) < (left_x)))
    {
#line 185 "GeometryModule.cs"
        return false;
    }
#line 186 "GeometryModule.cs"
    double left_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
#line 187 "GeometryModule.cs"
    double right_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
#line 188 "GeometryModule.cs"
    if (((left_y) < (right_y)))
    {
#line 189 "GeometryModule.cs"
        return true;
    }
#line 190 "GeometryModule.cs"
    if (((right_y) < (left_y)))
    {
#line 191 "GeometryModule.cs"
        return false;
    }
#line 192 "GeometryModule.cs"
    return ((left) < (right));
}

#line 86 "GeometryModule.cs"
__device__ double mathblocks_geometry_point_to_segment(
    double point_x,
    double point_y,
    double start_x,
    double start_y,
    double end_x,
    double end_y)
#line 94 "GeometryModule.cs"
{
#line 95 "GeometryModule.cs"
    double x = __dsub_rn(end_x, start_x);
#line 96 "GeometryModule.cs"
    double y = __dsub_rn(end_y, start_y);
#line 97 "GeometryModule.cs"
    double length_square = __dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y));
#line 98 "GeometryModule.cs"
    if (((length_square) == (0.0)))
    {
#line 99 "GeometryModule.cs"
        return mathblocks_geometry_distance_coordinates(point_x, point_y, start_x, start_y);
    }
#line 100 "GeometryModule.cs"
    double projection = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(point_x, start_x), x), __dmul_rn(__dsub_rn(point_y, start_y), y)), length_square);
#line 102 "GeometryModule.cs"
#line 102 "GeometryModule.cs"
    double* csharp2cuda_temp_0 = &(projection);
#line 102 "GeometryModule.cs"
    double csharp2cuda_temp_1;
#line 102 "GeometryModule.cs"
    if (((projection) < (0.0)))
    {
#line 102 "GeometryModule.cs"
        csharp2cuda_temp_1 = 0.0;
    }
    else
    {
#line 102 "GeometryModule.cs"
        double csharp2cuda_temp_2;
#line 102 "GeometryModule.cs"
        if (((projection) > (1.0)))
        {
#line 102 "GeometryModule.cs"
            csharp2cuda_temp_2 = 1.0;
        }
        else
        {
#line 102 "GeometryModule.cs"
            csharp2cuda_temp_2 = projection;
        }
#line 102 "GeometryModule.cs"
        csharp2cuda_temp_1 = csharp2cuda_temp_2;
    }
    (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
#line 103 "GeometryModule.cs"
    return mathblocks_geometry_distance_coordinates(point_x, point_y, __dadd_rn(start_x, __dmul_rn(projection, x)), __dadd_rn(start_y, __dmul_rn(projection, y)));
}

#line 314 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_edges(MathBlockGeometryEdge* edges, MathBlockGeometryEdge* buffer, int count)
#line 316 "GeometryModule.cs"
{
#line 317 "GeometryModule.cs"
    MathBlockGeometryEdge* source = edges;
#line 318 "GeometryModule.cs"
    MathBlockGeometryEdge* target = buffer;
#line 319 "GeometryModule.cs"
    {
#line 319 "GeometryModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 320 "GeometryModule.cs"
            {
#line 321 "GeometryModule.cs"
                {
#line 321 "GeometryModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 322 "GeometryModule.cs"
                        {
#line 323 "GeometryModule.cs"
                            int csharp2cuda_temp_4;
#line 323 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 323 "GeometryModule.cs"
                                csharp2cuda_temp_4 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 323 "GeometryModule.cs"
                                csharp2cuda_temp_4 = count;
                            }
#line 323 "GeometryModule.cs"
                            int middle = csharp2cuda_temp_4;
#line 324 "GeometryModule.cs"
                            int csharp2cuda_temp_5;
#line 324 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 324 "GeometryModule.cs"
                                csharp2cuda_temp_5 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 324 "GeometryModule.cs"
                                csharp2cuda_temp_5 = count;
                            }
#line 324 "GeometryModule.cs"
                            int end = csharp2cuda_temp_5;
#line 325 "GeometryModule.cs"
                            int left = start;
#line 326 "GeometryModule.cs"
                            int right = middle;
#line 327 "GeometryModule.cs"
                            int position = start;
#line 328 "GeometryModule.cs"
                            while (true)
                            {
#line 328 "GeometryModule.cs"
                                bool csharp2cuda_temp_6;
#line 328 "GeometryModule.cs"
                                if (((left) < (middle)))
                                {
#line 328 "GeometryModule.cs"
                                    csharp2cuda_temp_6 = ((right) < (end));
                                }
                                else
                                {
#line 328 "GeometryModule.cs"
                                    csharp2cuda_temp_6 = false;
                                }
                                if (!(csharp2cuda_temp_6))
                                    break;
#line 329 "GeometryModule.cs"
                                {
#line 330 "GeometryModule.cs"
#line 330 "GeometryModule.cs"
                                    MathBlockGeometryEdge* csharp2cuda_temp_7 = &((source)[right]);
#line 330 "GeometryModule.cs"
                                    MathBlockGeometryEdge* csharp2cuda_temp_8 = &((source)[left]);
                                    if (mathblocks_geometry_edge_less(csharp2cuda_temp_7, csharp2cuda_temp_8))
                                    {
#line 331 "GeometryModule.cs"
#line 331 "GeometryModule.cs"
                                        int* csharp2cuda_temp_9 = &(position);
#line 331 "GeometryModule.cs"
                                        int csharp2cuda_temp_10 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
#line 331 "GeometryModule.cs"
                                        MathBlockGeometryEdge* csharp2cuda_temp_11 = &((target)[csharp2cuda_temp_10]);
#line 331 "GeometryModule.cs"
                                        int* csharp2cuda_temp_12 = &(right);
#line 331 "GeometryModule.cs"
                                        int csharp2cuda_temp_13 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_12));
#line 331 "GeometryModule.cs"
                                        MathBlockGeometryEdge csharp2cuda_temp_14 = (source)[csharp2cuda_temp_13];
                                        (*(csharp2cuda_temp_11) = csharp2cuda_temp_14);
                                    }
                                    else
                                    {
#line 333 "GeometryModule.cs"
#line 333 "GeometryModule.cs"
                                        int* csharp2cuda_temp_15 = &(position);
#line 333 "GeometryModule.cs"
                                        int csharp2cuda_temp_16 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
#line 333 "GeometryModule.cs"
                                        MathBlockGeometryEdge* csharp2cuda_temp_17 = &((target)[csharp2cuda_temp_16]);
#line 333 "GeometryModule.cs"
                                        int* csharp2cuda_temp_18 = &(left);
#line 333 "GeometryModule.cs"
                                        int csharp2cuda_temp_19 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_18));
#line 333 "GeometryModule.cs"
                                        MathBlockGeometryEdge csharp2cuda_temp_20 = (source)[csharp2cuda_temp_19];
                                        (*(csharp2cuda_temp_17) = csharp2cuda_temp_20);
                                    }
                                }
                            }
#line 335 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 336 "GeometryModule.cs"
#line 336 "GeometryModule.cs"
                                int* csharp2cuda_temp_21 = &(position);
#line 336 "GeometryModule.cs"
                                int csharp2cuda_temp_22 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_21));
#line 336 "GeometryModule.cs"
                                MathBlockGeometryEdge* csharp2cuda_temp_23 = &((target)[csharp2cuda_temp_22]);
#line 336 "GeometryModule.cs"
                                int* csharp2cuda_temp_24 = &(left);
#line 336 "GeometryModule.cs"
                                int csharp2cuda_temp_25 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_24));
#line 336 "GeometryModule.cs"
                                MathBlockGeometryEdge csharp2cuda_temp_26 = (source)[csharp2cuda_temp_25];
                                (*(csharp2cuda_temp_23) = csharp2cuda_temp_26);
                            }
#line 337 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 338 "GeometryModule.cs"
#line 338 "GeometryModule.cs"
                                int* csharp2cuda_temp_27 = &(position);
#line 338 "GeometryModule.cs"
                                int csharp2cuda_temp_28 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_27));
#line 338 "GeometryModule.cs"
                                MathBlockGeometryEdge* csharp2cuda_temp_29 = &((target)[csharp2cuda_temp_28]);
#line 338 "GeometryModule.cs"
                                int* csharp2cuda_temp_30 = &(right);
#line 338 "GeometryModule.cs"
                                int csharp2cuda_temp_31 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_30));
#line 338 "GeometryModule.cs"
                                MathBlockGeometryEdge csharp2cuda_temp_32 = (source)[csharp2cuda_temp_31];
                                (*(csharp2cuda_temp_29) = csharp2cuda_temp_32);
                            }
                        }
#line 321 "GeometryModule.cs"
                        int* csharp2cuda_temp_2 = &(start);
#line 321 "GeometryModule.cs"
                        int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                        (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 340 "GeometryModule.cs"
                MathBlockGeometryEdge* sorted = target;
#line 341 "GeometryModule.cs"
#line 341 "GeometryModule.cs"
                MathBlockGeometryEdge** csharp2cuda_temp_33 = &(target);
                (*(csharp2cuda_temp_33) = source);
#line 342 "GeometryModule.cs"
#line 342 "GeometryModule.cs"
                MathBlockGeometryEdge** csharp2cuda_temp_34 = &(source);
                (*(csharp2cuda_temp_34) = sorted);
            }
#line 319 "GeometryModule.cs"
            int* csharp2cuda_temp_0 = &(width);
#line 319 "GeometryModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, width));
        }
    }
#line 344 "GeometryModule.cs"
    if (((((void*)(source))) != (((void*)(edges)))))
    {
#line 345 "GeometryModule.cs"
        {
#line 345 "GeometryModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 346 "GeometryModule.cs"
#line 346 "GeometryModule.cs"
                MathBlockGeometryEdge* csharp2cuda_temp_36 = &((edges)[index]);
#line 346 "GeometryModule.cs"
                MathBlockGeometryEdge csharp2cuda_temp_37 = (source)[index];
                (*(csharp2cuda_temp_36) = csharp2cuda_temp_37);
#line 345 "GeometryModule.cs"
                int* csharp2cuda_temp_35 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_35));
            }
        }
    }
}

#line 238 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_points(double* points, double* buffer, int count)
#line 240 "GeometryModule.cs"
{
#line 241 "GeometryModule.cs"
    double* source = points;
#line 242 "GeometryModule.cs"
    double* target = buffer;
#line 243 "GeometryModule.cs"
    {
#line 243 "GeometryModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 244 "GeometryModule.cs"
            {
#line 245 "GeometryModule.cs"
                {
#line 245 "GeometryModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 246 "GeometryModule.cs"
                        {
#line 247 "GeometryModule.cs"
                            int csharp2cuda_temp_4;
#line 247 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 247 "GeometryModule.cs"
                                csharp2cuda_temp_4 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 247 "GeometryModule.cs"
                                csharp2cuda_temp_4 = count;
                            }
#line 247 "GeometryModule.cs"
                            int middle = csharp2cuda_temp_4;
#line 248 "GeometryModule.cs"
                            int csharp2cuda_temp_5;
#line 248 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 248 "GeometryModule.cs"
                                csharp2cuda_temp_5 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 248 "GeometryModule.cs"
                                csharp2cuda_temp_5 = count;
                            }
#line 248 "GeometryModule.cs"
                            int end = csharp2cuda_temp_5;
#line 249 "GeometryModule.cs"
                            int left = start;
#line 250 "GeometryModule.cs"
                            int right = middle;
#line 251 "GeometryModule.cs"
                            int position = start;
#line 252 "GeometryModule.cs"
                            while (true)
                            {
#line 252 "GeometryModule.cs"
                                bool csharp2cuda_temp_6;
#line 252 "GeometryModule.cs"
                                if (((left) < (middle)))
                                {
#line 252 "GeometryModule.cs"
                                    csharp2cuda_temp_6 = ((right) < (end));
                                }
                                else
                                {
#line 252 "GeometryModule.cs"
                                    csharp2cuda_temp_6 = false;
                                }
                                if (!(csharp2cuda_temp_6))
                                    break;
#line 253 "GeometryModule.cs"
                                {
#line 254 "GeometryModule.cs"
                                    double csharp2cuda_temp_7 = (source)[csharp2cuda_i32_mul(2, right)];
#line 254 "GeometryModule.cs"
                                    double csharp2cuda_temp_8 = (source)[csharp2cuda_i32_mul(2, left)];
#line 254 "GeometryModule.cs"
                                    bool csharp2cuda_temp_9;
#line 254 "GeometryModule.cs"
                                    if (!(((csharp2cuda_temp_7) < (csharp2cuda_temp_8))))
                                    {
#line 255 "GeometryModule.cs"
                                        double csharp2cuda_temp_10 = (source)[csharp2cuda_i32_mul(2, right)];
#line 255 "GeometryModule.cs"
                                        double csharp2cuda_temp_11 = (source)[csharp2cuda_i32_mul(2, left)];
#line 255 "GeometryModule.cs"
                                        bool csharp2cuda_temp_12;
#line 255 "GeometryModule.cs"
                                        if (((csharp2cuda_temp_10) == (csharp2cuda_temp_11)))
                                        {
#line 255 "GeometryModule.cs"
                                            double csharp2cuda_temp_13 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
#line 255 "GeometryModule.cs"
                                            double csharp2cuda_temp_14 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
#line 255 "GeometryModule.cs"
                                            csharp2cuda_temp_12 = ((csharp2cuda_temp_13) < (csharp2cuda_temp_14));
                                        }
                                        else
                                        {
#line 255 "GeometryModule.cs"
                                            csharp2cuda_temp_12 = false;
                                        }
#line 254 "GeometryModule.cs"
                                        csharp2cuda_temp_9 = csharp2cuda_temp_12;
                                    }
                                    else
                                    {
#line 254 "GeometryModule.cs"
                                        csharp2cuda_temp_9 = true;
                                    }
#line 254 "GeometryModule.cs"
                                    bool take_right = csharp2cuda_temp_9;
#line 256 "GeometryModule.cs"
                                    int csharp2cuda_temp_15;
#line 256 "GeometryModule.cs"
                                    if (take_right)
                                    {
#line 256 "GeometryModule.cs"
                                        int* csharp2cuda_temp_16 = &(right);
#line 256 "GeometryModule.cs"
                                        csharp2cuda_temp_15 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
                                    }
                                    else
                                    {
#line 256 "GeometryModule.cs"
                                        int* csharp2cuda_temp_17 = &(left);
#line 256 "GeometryModule.cs"
                                        csharp2cuda_temp_15 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_17));
                                    }
#line 256 "GeometryModule.cs"
                                    int from = csharp2cuda_temp_15;
#line 257 "GeometryModule.cs"
#line 257 "GeometryModule.cs"
                                    double* csharp2cuda_temp_18 = &((target)[csharp2cuda_i32_mul(2, position)]);
#line 257 "GeometryModule.cs"
                                    double csharp2cuda_temp_19 = (source)[csharp2cuda_i32_mul(2, from)];
                                    (*(csharp2cuda_temp_18) = csharp2cuda_temp_19);
#line 258 "GeometryModule.cs"
#line 258 "GeometryModule.cs"
                                    double* csharp2cuda_temp_20 = &((target)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, position), 1)]);
#line 258 "GeometryModule.cs"
                                    double csharp2cuda_temp_21 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, from), 1)];
                                    (*(csharp2cuda_temp_20) = csharp2cuda_temp_21);
#line 259 "GeometryModule.cs"
#line 259 "GeometryModule.cs"
                                    int* csharp2cuda_temp_22 = &(position);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_22));
                                }
                            }
#line 261 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 262 "GeometryModule.cs"
                                {
#line 263 "GeometryModule.cs"
#line 263 "GeometryModule.cs"
                                    double* csharp2cuda_temp_23 = &((target)[csharp2cuda_i32_mul(2, position)]);
#line 263 "GeometryModule.cs"
                                    double csharp2cuda_temp_24 = (source)[csharp2cuda_i32_mul(2, left)];
                                    (*(csharp2cuda_temp_23) = csharp2cuda_temp_24);
#line 264 "GeometryModule.cs"
#line 264 "GeometryModule.cs"
                                    double* csharp2cuda_temp_25 = &((target)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, position), 1)]);
#line 264 "GeometryModule.cs"
                                    double csharp2cuda_temp_26 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
                                    (*(csharp2cuda_temp_25) = csharp2cuda_temp_26);
#line 265 "GeometryModule.cs"
#line 265 "GeometryModule.cs"
                                    int* csharp2cuda_temp_27 = &(position);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_27));
#line 266 "GeometryModule.cs"
#line 266 "GeometryModule.cs"
                                    int* csharp2cuda_temp_28 = &(left);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_28));
                                }
                            }
#line 268 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 269 "GeometryModule.cs"
                                {
#line 270 "GeometryModule.cs"
#line 270 "GeometryModule.cs"
                                    double* csharp2cuda_temp_29 = &((target)[csharp2cuda_i32_mul(2, position)]);
#line 270 "GeometryModule.cs"
                                    double csharp2cuda_temp_30 = (source)[csharp2cuda_i32_mul(2, right)];
                                    (*(csharp2cuda_temp_29) = csharp2cuda_temp_30);
#line 271 "GeometryModule.cs"
#line 271 "GeometryModule.cs"
                                    double* csharp2cuda_temp_31 = &((target)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, position), 1)]);
#line 271 "GeometryModule.cs"
                                    double csharp2cuda_temp_32 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
                                    (*(csharp2cuda_temp_31) = csharp2cuda_temp_32);
#line 272 "GeometryModule.cs"
#line 272 "GeometryModule.cs"
                                    int* csharp2cuda_temp_33 = &(position);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_33));
#line 273 "GeometryModule.cs"
#line 273 "GeometryModule.cs"
                                    int* csharp2cuda_temp_34 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_34));
                                }
                            }
                        }
#line 245 "GeometryModule.cs"
                        int* csharp2cuda_temp_2 = &(start);
#line 245 "GeometryModule.cs"
                        int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                        (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 276 "GeometryModule.cs"
                double* sorted = target;
#line 277 "GeometryModule.cs"
#line 277 "GeometryModule.cs"
                double** csharp2cuda_temp_35 = &(target);
                (*(csharp2cuda_temp_35) = source);
#line 278 "GeometryModule.cs"
#line 278 "GeometryModule.cs"
                double** csharp2cuda_temp_36 = &(source);
                (*(csharp2cuda_temp_36) = sorted);
            }
#line 243 "GeometryModule.cs"
            int* csharp2cuda_temp_0 = &(width);
#line 243 "GeometryModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, width));
        }
    }
#line 280 "GeometryModule.cs"
    if (((((void*)(source))) != (((void*)(points)))))
    {
#line 281 "GeometryModule.cs"
        {
#line 281 "GeometryModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (csharp2cuda_i32_mul(2, count)))))
                    break;
#line 282 "GeometryModule.cs"
#line 282 "GeometryModule.cs"
                double* csharp2cuda_temp_38 = &((points)[index]);
#line 282 "GeometryModule.cs"
                double csharp2cuda_temp_39 = (source)[index];
                (*(csharp2cuda_temp_38) = csharp2cuda_temp_39);
#line 281 "GeometryModule.cs"
                int* csharp2cuda_temp_37 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_37));
            }
        }
    }
}

#line 133 "GeometryModule.cs"
__device__ bool mathblocks_geometry_try_circumcircle(
    const double* points,
    int first,
    int second,
    int third,
    double* center_x,
    double* center_y,
    double* radius_square)
#line 142 "GeometryModule.cs"
{
#line 143 "GeometryModule.cs"
    double first_x = (points)[csharp2cuda_i32_mul(2, first)];
#line 144 "GeometryModule.cs"
    double first_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, first), 1)];
#line 145 "GeometryModule.cs"
    double second_x = (points)[csharp2cuda_i32_mul(2, second)];
#line 146 "GeometryModule.cs"
    double second_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, second), 1)];
#line 147 "GeometryModule.cs"
    double third_x = (points)[csharp2cuda_i32_mul(2, third)];
#line 148 "GeometryModule.cs"
    double third_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, third), 1)];
#line 149 "GeometryModule.cs"
    double denominator = __dmul_rn(2.0, __dadd_rn(__dadd_rn(__dmul_rn(first_x, __dsub_rn(second_y, third_y)), __dmul_rn(second_x, __dsub_rn(third_y, first_y))), __dmul_rn(third_x, __dsub_rn(first_y, second_y))));
#line 152 "GeometryModule.cs"
    if (((denominator) == (0.0)))
#line 153 "GeometryModule.cs"
    {
#line 154 "GeometryModule.cs"
#line 154 "GeometryModule.cs"
        double* csharp2cuda_temp_0 = center_x;
        (*(csharp2cuda_temp_0) = 0.0);
#line 155 "GeometryModule.cs"
#line 155 "GeometryModule.cs"
        double* csharp2cuda_temp_1 = center_y;
        (*(csharp2cuda_temp_1) = 0.0);
#line 156 "GeometryModule.cs"
#line 156 "GeometryModule.cs"
        double* csharp2cuda_temp_2 = radius_square;
        (*(csharp2cuda_temp_2) = 0.0);
#line 157 "GeometryModule.cs"
        return false;
    }
#line 159 "GeometryModule.cs"
    double first_square = __dadd_rn(__dmul_rn(first_x, first_x), __dmul_rn(first_y, first_y));
#line 160 "GeometryModule.cs"
    double second_square = __dadd_rn(__dmul_rn(second_x, second_x), __dmul_rn(second_y, second_y));
#line 161 "GeometryModule.cs"
    double third_square = __dadd_rn(__dmul_rn(third_x, third_x), __dmul_rn(third_y, third_y));
#line 162 "GeometryModule.cs"
#line 162 "GeometryModule.cs"
    double* csharp2cuda_temp_3 = center_x;
#line 162 "GeometryModule.cs"
    double csharp2cuda_temp_4 = __ddiv_rn(__dadd_rn(__dadd_rn(__dmul_rn(first_square, __dsub_rn(second_y, third_y)), __dmul_rn(second_square, __dsub_rn(third_y, first_y))), __dmul_rn(third_square, __dsub_rn(first_y, second_y))), denominator);
    (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 165 "GeometryModule.cs"
#line 165 "GeometryModule.cs"
    double* csharp2cuda_temp_5 = center_y;
#line 165 "GeometryModule.cs"
    double csharp2cuda_temp_6 = __ddiv_rn(__dadd_rn(__dadd_rn(__dmul_rn(first_square, __dsub_rn(third_x, second_x)), __dmul_rn(second_square, __dsub_rn(first_x, third_x))), __dmul_rn(third_square, __dsub_rn(second_x, first_x))), denominator);
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 168 "GeometryModule.cs"
    double csharp2cuda_temp_7 = *(center_x);
#line 168 "GeometryModule.cs"
    double x = __dsub_rn(first_x, csharp2cuda_temp_7);
#line 169 "GeometryModule.cs"
    double csharp2cuda_temp_8 = *(center_y);
#line 169 "GeometryModule.cs"
    double y = __dsub_rn(first_y, csharp2cuda_temp_8);
#line 170 "GeometryModule.cs"
#line 170 "GeometryModule.cs"
    double* csharp2cuda_temp_9 = radius_square;
    (*(csharp2cuda_temp_9) = __dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y)));
#line 171 "GeometryModule.cs"
    return true;
}