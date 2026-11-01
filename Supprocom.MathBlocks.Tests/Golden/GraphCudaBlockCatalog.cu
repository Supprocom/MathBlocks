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

struct MathBlockGraphKernelEdge;

#line 46 "GraphModule.cs"
struct MathBlockGraphKernelEdge
{
    int from;
    int to;
    double weight;
};

#line 90 "GraphModule.cs"
__device__ int mathblocks_graph_component_count(
    const MathBlockGraphKernelEdge* edges,
    int edge_count,
    int vertex_count,
    int* visited,
    int* queue);

#line 157 "GraphModule.cs"
__device__ void mathblocks_graph_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 130 "GraphModule.cs"
__device__ bool mathblocks_graph_edge_less(
    const MathBlockGraphKernelEdge* left,
    const MathBlockGraphKernelEdge* right);

#line 146 "GraphModule.cs"
__device__ int mathblocks_graph_find(int* parent, int vertex);

#line 55 "GraphModule.cs"
__device__ void mathblocks_graph_sort_edges(MathBlockGraphKernelEdge* edges, MathBlockGraphKernelEdge* buffer, int count);

#line 90 "GraphModule.cs"
__device__ int mathblocks_graph_component_count(
    const MathBlockGraphKernelEdge* edges,
    int edge_count,
    int vertex_count,
    int* visited,
    int* queue)
#line 97 "GraphModule.cs"
{
#line 98 "GraphModule.cs"
    {
#line 98 "GraphModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (vertex_count))))
                break;
#line 99 "GraphModule.cs"
#line 99 "GraphModule.cs"
            int* csharp2cuda_temp_1 = &((visited)[index]);
            (*(csharp2cuda_temp_1) = 0);
#line 98 "GraphModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 100 "GraphModule.cs"
    int components = 0;
#line 101 "GraphModule.cs"
    {
#line 101 "GraphModule.cs"
        int start = 0;
        while (true)
        {
            if (!(((start) < (vertex_count))))
                break;
#line 102 "GraphModule.cs"
            {
#line 103 "GraphModule.cs"
#line 103 "GraphModule.cs"
                int csharp2cuda_temp_3 = (visited)[start];
                if (((csharp2cuda_temp_3) != 0))
                {
#line 104 "GraphModule.cs"
                    goto csharp2cuda_for_continue_2;
                }
#line 105 "GraphModule.cs"
#line 105 "GraphModule.cs"
                int* csharp2cuda_temp_4 = &(components);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
#line 106 "GraphModule.cs"
                int head = 0;
#line 107 "GraphModule.cs"
                int tail = 0;
#line 108 "GraphModule.cs"
#line 108 "GraphModule.cs"
                int* csharp2cuda_temp_5 = &(tail);
#line 108 "GraphModule.cs"
                int csharp2cuda_temp_6 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
#line 108 "GraphModule.cs"
                int* csharp2cuda_temp_7 = &((queue)[csharp2cuda_temp_6]);
                (*(csharp2cuda_temp_7) = start);
#line 109 "GraphModule.cs"
#line 109 "GraphModule.cs"
                int* csharp2cuda_temp_8 = &((visited)[start]);
                (*(csharp2cuda_temp_8) = 1);
#line 110 "GraphModule.cs"
                while (true)
                {
                    if (!(((head) < (tail))))
                        break;
#line 111 "GraphModule.cs"
                    {
#line 112 "GraphModule.cs"
                        int* csharp2cuda_temp_9 = &(head);
#line 112 "GraphModule.cs"
                        int csharp2cuda_temp_10 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
#line 112 "GraphModule.cs"
                        int vertex = (queue)[csharp2cuda_temp_10];
#line 113 "GraphModule.cs"
                        {
#line 113 "GraphModule.cs"
                            int edge_index = 0;
                            while (true)
                            {
                                if (!(((edge_index) < (edge_count))))
                                    break;
#line 114 "GraphModule.cs"
                                {
#line 115 "GraphModule.cs"
                                    int csharp2cuda_temp_12 = ((edges)[edge_index]).from;
#line 115 "GraphModule.cs"
                                    int csharp2cuda_temp_13;
#line 115 "GraphModule.cs"
                                    if (((csharp2cuda_temp_12) == (vertex)))
                                    {
#line 115 "GraphModule.cs"
                                        csharp2cuda_temp_13 = ((edges)[edge_index]).to;
                                    }
                                    else
                                    {
#line 117 "GraphModule.cs"
                                        int csharp2cuda_temp_14 = ((edges)[edge_index]).to;
#line 117 "GraphModule.cs"
                                        int csharp2cuda_temp_15;
#line 117 "GraphModule.cs"
                                        if (((csharp2cuda_temp_14) == (vertex)))
                                        {
#line 117 "GraphModule.cs"
                                            csharp2cuda_temp_15 = ((edges)[edge_index]).from;
                                        }
                                        else
                                        {
#line 117 "GraphModule.cs"
                                            csharp2cuda_temp_15 = csharp2cuda_i32_neg(1);
                                        }
#line 115 "GraphModule.cs"
                                        csharp2cuda_temp_13 = csharp2cuda_temp_15;
                                    }
#line 115 "GraphModule.cs"
                                    int neighbor = csharp2cuda_temp_13;
#line 120 "GraphModule.cs"
#line 120 "GraphModule.cs"
                                    bool csharp2cuda_temp_16;
#line 120 "GraphModule.cs"
                                    if (!(((neighbor) < (0))))
                                    {
#line 120 "GraphModule.cs"
                                        int csharp2cuda_temp_17 = (visited)[neighbor];
#line 120 "GraphModule.cs"
                                        csharp2cuda_temp_16 = ((csharp2cuda_temp_17) != 0);
                                    }
                                    else
                                    {
#line 120 "GraphModule.cs"
                                        csharp2cuda_temp_16 = true;
                                    }
                                    if (csharp2cuda_temp_16)
                                    {
#line 121 "GraphModule.cs"
                                        goto csharp2cuda_for_continue_1;
                                    }
#line 122 "GraphModule.cs"
#line 122 "GraphModule.cs"
                                    int* csharp2cuda_temp_18 = &((visited)[neighbor]);
                                    (*(csharp2cuda_temp_18) = 1);
#line 123 "GraphModule.cs"
#line 123 "GraphModule.cs"
                                    int* csharp2cuda_temp_19 = &(tail);
#line 123 "GraphModule.cs"
                                    int csharp2cuda_temp_20 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_19));
#line 123 "GraphModule.cs"
                                    int* csharp2cuda_temp_21 = &((queue)[csharp2cuda_temp_20]);
                                    (*(csharp2cuda_temp_21) = neighbor);
                                }
                                csharp2cuda_for_continue_1:
#line 113 "GraphModule.cs"
                                int* csharp2cuda_temp_11 = &(edge_index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_11));
                            }
                        }
                    }
                }
            }
            csharp2cuda_for_continue_2:
#line 101 "GraphModule.cs"
            int* csharp2cuda_temp_2 = &(start);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 127 "GraphModule.cs"
    return components;
}

#line 157 "GraphModule.cs"
__device__ void mathblocks_graph_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 163 "GraphModule.cs"
{
#line 164 "GraphModule.cs"
    int thread = threadIdx.x;
#line 165 "GraphModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 165 "GraphModule.cs"
    if (((input_count) > (0)))
    {
#line 165 "GraphModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 165 "GraphModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 165 "GraphModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 166 "GraphModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 166 "GraphModule.cs"
    if (((input_count) > (1)))
    {
#line 166 "GraphModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 166 "GraphModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 166 "GraphModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 167 "GraphModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 167 "GraphModule.cs"
    if (((input_count) > (2)))
    {
#line 167 "GraphModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 167 "GraphModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 167 "GraphModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 168 "GraphModule.cs"
    if (((thread) == (0)))
#line 169 "GraphModule.cs"
    {
#line 170 "GraphModule.cs"
#line 170 "GraphModule.cs"
        double* csharp2cuda_temp_3 = &((output)->scalar_value);
        (*(csharp2cuda_temp_3) = 0.0);
#line 171 "GraphModule.cs"
#line 171 "GraphModule.cs"
        int* csharp2cuda_temp_4 = &((output)->boolean_value);
        (*(csharp2cuda_temp_4) = 0);
#line 172 "GraphModule.cs"
#line 172 "GraphModule.cs"
        int* csharp2cuda_temp_5 = &((output)->rows);
        (*(csharp2cuda_temp_5) = 0);
#line 173 "GraphModule.cs"
#line 173 "GraphModule.cs"
        int* csharp2cuda_temp_6 = &((output)->columns);
        (*(csharp2cuda_temp_6) = 0);
#line 174 "GraphModule.cs"
#line 174 "GraphModule.cs"
        int* csharp2cuda_temp_7 = &((output)->count);
        (*(csharp2cuda_temp_7) = 0);
#line 175 "GraphModule.cs"
#line 175 "GraphModule.cs"
        int* csharp2cuda_temp_8 = &((output)->valid);
#line 175 "GraphModule.cs"
        bool csharp2cuda_temp_9;
#line 175 "GraphModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 175 "GraphModule.cs"
            csharp2cuda_temp_9 = (first)->valid;
        }
        else
        {
#line 175 "GraphModule.cs"
            csharp2cuda_temp_9 = true;
        }
        (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
#line 176 "GraphModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 177 "GraphModule.cs"
#line 177 "GraphModule.cs"
            int* csharp2cuda_temp_10 = &((output)->valid);
#line 177 "GraphModule.cs"
            bool csharp2cuda_temp_11 = (output)->valid;
#line 177 "GraphModule.cs"
            bool csharp2cuda_temp_12;
#line 177 "GraphModule.cs"
            if (csharp2cuda_temp_11)
            {
#line 177 "GraphModule.cs"
                csharp2cuda_temp_12 = (second)->valid;
            }
            else
            {
#line 177 "GraphModule.cs"
                csharp2cuda_temp_12 = false;
            }
            (*(csharp2cuda_temp_10) = csharp2cuda_temp_12);
        }
#line 178 "GraphModule.cs"
        if (((((void*)(third))) != (((void*)(nullptr)))))
        {
#line 179 "GraphModule.cs"
#line 179 "GraphModule.cs"
            int* csharp2cuda_temp_13 = &((output)->valid);
#line 179 "GraphModule.cs"
            bool csharp2cuda_temp_14 = (output)->valid;
#line 179 "GraphModule.cs"
            bool csharp2cuda_temp_15;
#line 179 "GraphModule.cs"
            if (csharp2cuda_temp_14)
            {
#line 179 "GraphModule.cs"
                csharp2cuda_temp_15 = (third)->valid;
            }
            else
            {
#line 179 "GraphModule.cs"
                csharp2cuda_temp_15 = false;
            }
            (*(csharp2cuda_temp_13) = csharp2cuda_temp_15);
        }
    }
#line 181 "GraphModule.cs"
    __syncthreads();
#line 182 "GraphModule.cs"
#line 182 "GraphModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 183 "GraphModule.cs"
        return;
    }
#line 186 "GraphModule.cs"
    MathBlockGraphKernelEdge* csharp2cuda_temp_17;
#line 186 "GraphModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 186 "GraphModule.cs"
        csharp2cuda_temp_17 = ((MathBlockGraphKernelEdge*)(nullptr));
    }
    else
    {
#line 186 "GraphModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 186 "GraphModule.cs"
        csharp2cuda_temp_17 = ((MathBlockGraphKernelEdge*)(csharp2cuda_temp_18));
    }
#line 185 "GraphModule.cs"
    const MathBlockGraphKernelEdge* edges = csharp2cuda_temp_17;
#line 187 "GraphModule.cs"
    double* csharp2cuda_temp_19;
#line 187 "GraphModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 187 "GraphModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 187 "GraphModule.cs"
        unsigned long long csharp2cuda_temp_20 = (first)->data_pointer;
#line 187 "GraphModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 187 "GraphModule.cs"
    const double* matrix = csharp2cuda_temp_19;
#line 188 "GraphModule.cs"
    int* csharp2cuda_temp_21;
#line 188 "GraphModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 188 "GraphModule.cs"
        csharp2cuda_temp_21 = ((int*)(nullptr));
    }
    else
    {
#line 188 "GraphModule.cs"
        unsigned long long csharp2cuda_temp_22 = (second)->data_pointer;
#line 188 "GraphModule.cs"
        csharp2cuda_temp_21 = ((int*)(csharp2cuda_temp_22));
    }
#line 188 "GraphModule.cs"
    const int* boolean_values = csharp2cuda_temp_21;
#line 189 "GraphModule.cs"
    double* csharp2cuda_temp_23;
#line 189 "GraphModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 189 "GraphModule.cs"
        csharp2cuda_temp_23 = ((double*)(nullptr));
    }
    else
    {
#line 189 "GraphModule.cs"
        unsigned long long csharp2cuda_temp_24 = (second)->data_pointer;
#line 189 "GraphModule.cs"
        csharp2cuda_temp_23 = ((double*)(csharp2cuda_temp_24));
    }
#line 189 "GraphModule.cs"
    const double* vector = csharp2cuda_temp_23;
#line 190 "GraphModule.cs"
    unsigned long long csharp2cuda_temp_25 = (output)->data_pointer;
#line 190 "GraphModule.cs"
    double* result = ((double*)(csharp2cuda_temp_25));
#line 191 "GraphModule.cs"
    unsigned long long csharp2cuda_temp_26 = (output)->scratch_pointer;
#line 191 "GraphModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_26));
#line 193 "GraphModule.cs"
    if (((thread) == (0)))
#line 194 "GraphModule.cs"
    {
#line 195 "GraphModule.cs"
        int vertex_count = (first)->rows;
#line 196 "GraphModule.cs"
        switch (opcode)
        {
#line 198 "GraphModule.cs"
            case 0:
#line 199 "GraphModule.cs"
                if (((vertex_count) <= (1)))
#line 200 "GraphModule.cs"
                {
#line 201 "GraphModule.cs"
#line 201 "GraphModule.cs"
                    double* csharp2cuda_temp_27 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_27) = 0.0);
#line 202 "GraphModule.cs"
                    break;
                }
#line 204 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 205 "GraphModule.cs"
                {
#line 206 "GraphModule.cs"
#line 206 "GraphModule.cs"
                    int* csharp2cuda_temp_28 = &((output)->valid);
                    (*(csharp2cuda_temp_28) = 0);
#line 207 "GraphModule.cs"
                    break;
                }
#line 209 "GraphModule.cs"
                {
#line 210 "GraphModule.cs"
                    double* laplacian = scratch;
#line 211 "GraphModule.cs"
                    double* work = csharp2cuda_pointer_add(laplacian, csharp2cuda_i32_mul(vertex_count, vertex_count));
#line 212 "GraphModule.cs"
                    double* eigenvalues = csharp2cuda_pointer_add(work, csharp2cuda_i32_mul(vertex_count, vertex_count));
#line 213 "GraphModule.cs"
                    {
#line 213 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(vertex_count, vertex_count)))))
                                break;
#line 214 "GraphModule.cs"
#line 214 "GraphModule.cs"
                            double* csharp2cuda_temp_30 = &((laplacian)[index]);
                            (*(csharp2cuda_temp_30) = 0.0);
#line 213 "GraphModule.cs"
                            int* csharp2cuda_temp_29 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_29));
                        }
                    }
#line 215 "GraphModule.cs"
                    {
#line 215 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 215 "GraphModule.cs"
                            int csharp2cuda_temp_32 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_32))))
                                break;
#line 216 "GraphModule.cs"
                            {
#line 217 "GraphModule.cs"
                                int from = ((edges)[index]).from;
#line 218 "GraphModule.cs"
                                int to = ((edges)[index]).to;
#line 219 "GraphModule.cs"
                                double weight = ((edges)[index]).weight;
#line 220 "GraphModule.cs"
#line 220 "GraphModule.cs"
                                double* csharp2cuda_temp_33 = &((laplacian)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), from)]);
#line 220 "GraphModule.cs"
                                double csharp2cuda_temp_34 = *(csharp2cuda_temp_33);
                                (*(csharp2cuda_temp_33) = __dadd_rn(csharp2cuda_temp_34, weight));
#line 221 "GraphModule.cs"
#line 221 "GraphModule.cs"
                                double* csharp2cuda_temp_35 = &((laplacian)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), to)]);
#line 221 "GraphModule.cs"
                                double csharp2cuda_temp_36 = *(csharp2cuda_temp_35);
                                (*(csharp2cuda_temp_35) = __dadd_rn(csharp2cuda_temp_36, weight));
#line 222 "GraphModule.cs"
#line 222 "GraphModule.cs"
                                double* csharp2cuda_temp_37 = &((laplacian)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), to)]);
#line 222 "GraphModule.cs"
                                double csharp2cuda_temp_38 = *(csharp2cuda_temp_37);
                                (*(csharp2cuda_temp_37) = __dsub_rn(csharp2cuda_temp_38, weight));
#line 223 "GraphModule.cs"
#line 223 "GraphModule.cs"
                                double* csharp2cuda_temp_39 = &((laplacian)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), from)]);
#line 223 "GraphModule.cs"
                                double csharp2cuda_temp_40 = *(csharp2cuda_temp_39);
                                (*(csharp2cuda_temp_39) = __dsub_rn(csharp2cuda_temp_40, weight));
                            }
#line 215 "GraphModule.cs"
                            int* csharp2cuda_temp_31 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                        }
                    }
#line 225 "GraphModule.cs"
                    mathblocks_matrix_symmetric_eigenvalues(laplacian, vertex_count, work, eigenvalues, csharp2cuda_pointer_add(eigenvalues, vertex_count));
#line 231 "GraphModule.cs"
#line 231 "GraphModule.cs"
                    double* csharp2cuda_temp_41 = &((output)->scalar_value);
#line 231 "GraphModule.cs"
                    double csharp2cuda_temp_42 = (eigenvalues)[1];
                    (*(csharp2cuda_temp_41) = csharp2cuda_temp_42);
#line 232 "GraphModule.cs"
                    break;
                }
#line 234 "GraphModule.cs"
            case 1:
#line 235 "GraphModule.cs"
#line 235 "GraphModule.cs"
                int csharp2cuda_temp_43 = (second)->count;
                if (((csharp2cuda_temp_43) != (vertex_count)))
#line 236 "GraphModule.cs"
                {
#line 237 "GraphModule.cs"
#line 237 "GraphModule.cs"
                    int* csharp2cuda_temp_44 = &((output)->valid);
                    (*(csharp2cuda_temp_44) = 0);
#line 238 "GraphModule.cs"
                    break;
                }
#line 240 "GraphModule.cs"
                {
#line 241 "GraphModule.cs"
                    bool all = true;
#line 242 "GraphModule.cs"
                    bool none = true;
#line 243 "GraphModule.cs"
                    {
#line 243 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 243 "GraphModule.cs"
                            int csharp2cuda_temp_46 = (second)->count;
                            if (!(((index) < (csharp2cuda_temp_46))))
                                break;
#line 244 "GraphModule.cs"
                            {
#line 245 "GraphModule.cs"
#line 245 "GraphModule.cs"
                                bool* csharp2cuda_temp_47 = &(all);
#line 245 "GraphModule.cs"
                                bool csharp2cuda_temp_48;
#line 245 "GraphModule.cs"
                                if (all)
                                {
#line 245 "GraphModule.cs"
                                    int csharp2cuda_temp_49 = (boolean_values)[index];
#line 245 "GraphModule.cs"
                                    csharp2cuda_temp_48 = ((csharp2cuda_temp_49) != (0));
                                }
                                else
                                {
#line 245 "GraphModule.cs"
                                    csharp2cuda_temp_48 = false;
                                }
                                (*(csharp2cuda_temp_47) = csharp2cuda_temp_48);
#line 246 "GraphModule.cs"
#line 246 "GraphModule.cs"
                                bool* csharp2cuda_temp_50 = &(none);
#line 246 "GraphModule.cs"
                                bool csharp2cuda_temp_51;
#line 246 "GraphModule.cs"
                                if (none)
                                {
#line 246 "GraphModule.cs"
                                    int csharp2cuda_temp_52 = (boolean_values)[index];
#line 246 "GraphModule.cs"
                                    csharp2cuda_temp_51 = ((csharp2cuda_temp_52) == (0));
                                }
                                else
                                {
#line 246 "GraphModule.cs"
                                    csharp2cuda_temp_51 = false;
                                }
                                (*(csharp2cuda_temp_50) = csharp2cuda_temp_51);
                            }
#line 243 "GraphModule.cs"
                            int* csharp2cuda_temp_45 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_45));
                        }
                    }
#line 248 "GraphModule.cs"
                    double cut = 0.0;
#line 249 "GraphModule.cs"
                    double left_volume = 0.0;
#line 250 "GraphModule.cs"
                    double right_volume = 0.0;
#line 251 "GraphModule.cs"
                    {
#line 251 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 251 "GraphModule.cs"
                            int csharp2cuda_temp_54 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_54))))
                                break;
#line 252 "GraphModule.cs"
                            {
#line 253 "GraphModule.cs"
#line 253 "GraphModule.cs"
                                double csharp2cuda_temp_55 = ((edges)[index]).weight;
                                if (((csharp2cuda_temp_55) < (0.0)))
#line 254 "GraphModule.cs"
                                {
#line 255 "GraphModule.cs"
#line 255 "GraphModule.cs"
                                    int* csharp2cuda_temp_56 = &((output)->valid);
                                    (*(csharp2cuda_temp_56) = 0);
#line 256 "GraphModule.cs"
                                    break;
                                }
#line 258 "GraphModule.cs"
#line 258 "GraphModule.cs"
                                int csharp2cuda_temp_57 = ((edges)[index]).from;
#line 258 "GraphModule.cs"
                                int csharp2cuda_temp_58 = (boolean_values)[csharp2cuda_temp_57];
                                if (((csharp2cuda_temp_58) != 0))
                                {
#line 259 "GraphModule.cs"
#line 259 "GraphModule.cs"
                                    double* csharp2cuda_temp_59 = &(left_volume);
#line 259 "GraphModule.cs"
                                    double csharp2cuda_temp_60 = *(csharp2cuda_temp_59);
#line 259 "GraphModule.cs"
                                    double csharp2cuda_temp_61 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_59) = __dadd_rn(csharp2cuda_temp_60, csharp2cuda_temp_61));
                                }
                                else
                                {
#line 261 "GraphModule.cs"
#line 261 "GraphModule.cs"
                                    double* csharp2cuda_temp_62 = &(right_volume);
#line 261 "GraphModule.cs"
                                    double csharp2cuda_temp_63 = *(csharp2cuda_temp_62);
#line 261 "GraphModule.cs"
                                    double csharp2cuda_temp_64 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_62) = __dadd_rn(csharp2cuda_temp_63, csharp2cuda_temp_64));
                                }
#line 262 "GraphModule.cs"
#line 262 "GraphModule.cs"
                                int csharp2cuda_temp_65 = ((edges)[index]).to;
#line 262 "GraphModule.cs"
                                int csharp2cuda_temp_66 = (boolean_values)[csharp2cuda_temp_65];
                                if (((csharp2cuda_temp_66) != 0))
                                {
#line 263 "GraphModule.cs"
#line 263 "GraphModule.cs"
                                    double* csharp2cuda_temp_67 = &(left_volume);
#line 263 "GraphModule.cs"
                                    double csharp2cuda_temp_68 = *(csharp2cuda_temp_67);
#line 263 "GraphModule.cs"
                                    double csharp2cuda_temp_69 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_67) = __dadd_rn(csharp2cuda_temp_68, csharp2cuda_temp_69));
                                }
                                else
                                {
#line 265 "GraphModule.cs"
#line 265 "GraphModule.cs"
                                    double* csharp2cuda_temp_70 = &(right_volume);
#line 265 "GraphModule.cs"
                                    double csharp2cuda_temp_71 = *(csharp2cuda_temp_70);
#line 265 "GraphModule.cs"
                                    double csharp2cuda_temp_72 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_70) = __dadd_rn(csharp2cuda_temp_71, csharp2cuda_temp_72));
                                }
#line 266 "GraphModule.cs"
#line 266 "GraphModule.cs"
                                int csharp2cuda_temp_73 = ((edges)[index]).from;
#line 266 "GraphModule.cs"
                                int csharp2cuda_temp_74 = (boolean_values)[csharp2cuda_temp_73];
#line 266 "GraphModule.cs"
                                int csharp2cuda_temp_75 = ((edges)[index]).to;
#line 266 "GraphModule.cs"
                                int csharp2cuda_temp_76 = (boolean_values)[csharp2cuda_temp_75];
                                if (((csharp2cuda_temp_74) != (csharp2cuda_temp_76)))
                                {
#line 267 "GraphModule.cs"
#line 267 "GraphModule.cs"
                                    double* csharp2cuda_temp_77 = &(cut);
#line 267 "GraphModule.cs"
                                    double csharp2cuda_temp_78 = *(csharp2cuda_temp_77);
#line 267 "GraphModule.cs"
                                    double csharp2cuda_temp_79 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_77) = __dadd_rn(csharp2cuda_temp_78, csharp2cuda_temp_79));
                                }
                            }
#line 251 "GraphModule.cs"
                            int* csharp2cuda_temp_53 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_53));
                        }
                    }
#line 269 "GraphModule.cs"
#line 269 "GraphModule.cs"
                    bool csharp2cuda_temp_80;
#line 269 "GraphModule.cs"
                    if (!(all))
                    {
#line 269 "GraphModule.cs"
                        csharp2cuda_temp_80 = none;
                    }
                    else
                    {
#line 269 "GraphModule.cs"
                        csharp2cuda_temp_80 = true;
                    }
                    if (csharp2cuda_temp_80)
                    {
#line 270 "GraphModule.cs"
#line 270 "GraphModule.cs"
                        int* csharp2cuda_temp_81 = &((output)->valid);
                        (*(csharp2cuda_temp_81) = 0);
                    }
                    else
                    {
#line 272 "GraphModule.cs"
#line 272 "GraphModule.cs"
                        double* csharp2cuda_temp_82 = &((output)->scalar_value);
#line 273 "GraphModule.cs"
                        double csharp2cuda_temp_83;
#line 273 "GraphModule.cs"
                        if (((left_volume) < (right_volume)))
                        {
#line 273 "GraphModule.cs"
                            csharp2cuda_temp_83 = left_volume;
                        }
                        else
                        {
#line 273 "GraphModule.cs"
                            csharp2cuda_temp_83 = right_volume;
                        }
#line 272 "GraphModule.cs"
                        double csharp2cuda_temp_84 = __ddiv_rn(cut, csharp2cuda_temp_83);
                        (*(csharp2cuda_temp_82) = csharp2cuda_temp_84);
                    }
#line 274 "GraphModule.cs"
                    break;
                }
#line 276 "GraphModule.cs"
            case 2:
            case 7:
#line 278 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 279 "GraphModule.cs"
                {
#line 280 "GraphModule.cs"
#line 280 "GraphModule.cs"
                    int* csharp2cuda_temp_85 = &((output)->valid);
                    (*(csharp2cuda_temp_85) = 0);
#line 281 "GraphModule.cs"
                    break;
                }
#line 283 "GraphModule.cs"
                {
#line 284 "GraphModule.cs"
                    int* visited = ((int*)(scratch));
#line 285 "GraphModule.cs"
                    int* queue = csharp2cuda_pointer_add(visited, vertex_count);
#line 288 "GraphModule.cs"
                    int csharp2cuda_temp_86 = (first)->count;
#line 286 "GraphModule.cs"
                    int components = mathblocks_graph_component_count(edges, csharp2cuda_temp_86, vertex_count, visited, queue);
#line 292 "GraphModule.cs"
                    if (((opcode) == (2)))
                    {
#line 293 "GraphModule.cs"
#line 293 "GraphModule.cs"
                        double* csharp2cuda_temp_87 = &((output)->scalar_value);
                        (*(csharp2cuda_temp_87) = ((double)(components)));
                    }
                    else
                    {
#line 295 "GraphModule.cs"
#line 295 "GraphModule.cs"
                        int* csharp2cuda_temp_88 = &((output)->boolean_value);
#line 295 "GraphModule.cs"
                        int csharp2cuda_temp_89;
#line 295 "GraphModule.cs"
                        if (((components) == (1)))
                        {
#line 295 "GraphModule.cs"
                            csharp2cuda_temp_89 = 1;
                        }
                        else
                        {
#line 295 "GraphModule.cs"
                            csharp2cuda_temp_89 = 0;
                        }
                        (*(csharp2cuda_temp_88) = csharp2cuda_temp_89);
                    }
#line 296 "GraphModule.cs"
                    break;
                }
#line 298 "GraphModule.cs"
            case 3:
            case 15:
#line 300 "GraphModule.cs"
                mathblocks_sequence_set_vector_shape(output, vertex_count);
#line 301 "GraphModule.cs"
                {
#line 301 "GraphModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (vertex_count))))
                            break;
#line 302 "GraphModule.cs"
#line 302 "GraphModule.cs"
                        double* csharp2cuda_temp_91 = &((result)[index]);
                        (*(csharp2cuda_temp_91) = 0.0);
#line 301 "GraphModule.cs"
                        int* csharp2cuda_temp_90 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_90));
                    }
                }
#line 303 "GraphModule.cs"
                {
#line 303 "GraphModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 303 "GraphModule.cs"
                        int csharp2cuda_temp_93 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_93))))
                            break;
#line 304 "GraphModule.cs"
                        {
#line 305 "GraphModule.cs"
                            double csharp2cuda_temp_94;
#line 305 "GraphModule.cs"
                            if (((opcode) == (3)))
                            {
#line 305 "GraphModule.cs"
                                csharp2cuda_temp_94 = 1.0;
                            }
                            else
                            {
#line 305 "GraphModule.cs"
                                csharp2cuda_temp_94 = ((edges)[index]).weight;
                            }
#line 305 "GraphModule.cs"
                            double amount = csharp2cuda_temp_94;
#line 306 "GraphModule.cs"
#line 306 "GraphModule.cs"
                            int csharp2cuda_temp_95 = ((edges)[index]).from;
#line 306 "GraphModule.cs"
                            double* csharp2cuda_temp_96 = &((result)[csharp2cuda_temp_95]);
#line 306 "GraphModule.cs"
                            double csharp2cuda_temp_97 = *(csharp2cuda_temp_96);
                            (*(csharp2cuda_temp_96) = __dadd_rn(csharp2cuda_temp_97, amount));
#line 307 "GraphModule.cs"
#line 307 "GraphModule.cs"
                            int csharp2cuda_temp_98 = ((edges)[index]).to;
#line 307 "GraphModule.cs"
                            double* csharp2cuda_temp_99 = &((result)[csharp2cuda_temp_98]);
#line 307 "GraphModule.cs"
                            double csharp2cuda_temp_100 = *(csharp2cuda_temp_99);
                            (*(csharp2cuda_temp_99) = __dadd_rn(csharp2cuda_temp_100, amount));
                        }
#line 303 "GraphModule.cs"
                        int* csharp2cuda_temp_92 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_92));
                    }
                }
#line 309 "GraphModule.cs"
                break;
#line 310 "GraphModule.cs"
            case 4:
#line 311 "GraphModule.cs"
#line 311 "GraphModule.cs"
                int csharp2cuda_temp_101 = (first)->rows;
#line 311 "GraphModule.cs"
                int csharp2cuda_temp_102 = (first)->columns;
                if (((csharp2cuda_temp_101) != (csharp2cuda_temp_102)))
#line 312 "GraphModule.cs"
                {
#line 313 "GraphModule.cs"
#line 313 "GraphModule.cs"
                    int* csharp2cuda_temp_103 = &((output)->valid);
                    (*(csharp2cuda_temp_103) = 0);
#line 314 "GraphModule.cs"
                    break;
                }
#line 316 "GraphModule.cs"
                {
#line 318 "GraphModule.cs"
                    unsigned long long csharp2cuda_temp_104 = (output)->data_pointer;
#line 317 "GraphModule.cs"
                    MathBlockGraphKernelEdge* graph = ((MathBlockGraphKernelEdge*)(csharp2cuda_temp_104));
#line 319 "GraphModule.cs"
                    int edge_count = 0;
#line 320 "GraphModule.cs"
                    {
#line 320 "GraphModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 320 "GraphModule.cs"
                            int csharp2cuda_temp_106 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_106))))
                                break;
#line 321 "GraphModule.cs"
                            {
#line 321 "GraphModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 321 "GraphModule.cs"
                                    int csharp2cuda_temp_108 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_108))))
                                        break;
#line 322 "GraphModule.cs"
#line 322 "GraphModule.cs"
                                    bool csharp2cuda_temp_109;
#line 322 "GraphModule.cs"
                                    if (((row) != (column)))
                                    {
#line 322 "GraphModule.cs"
                                        int csharp2cuda_temp_110 = (first)->columns;
#line 322 "GraphModule.cs"
                                        double csharp2cuda_temp_111 = (matrix)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_110), column)];
#line 322 "GraphModule.cs"
                                        csharp2cuda_temp_109 = ((csharp2cuda_temp_111) != (0.0));
                                    }
                                    else
                                    {
#line 322 "GraphModule.cs"
                                        csharp2cuda_temp_109 = false;
                                    }
                                    if (csharp2cuda_temp_109)
#line 323 "GraphModule.cs"
                                    {
#line 324 "GraphModule.cs"
#line 324 "GraphModule.cs"
                                        int csharp2cuda_temp_112 = (output)->capacity;
                                        if (((edge_count) >= (csharp2cuda_temp_112)))
#line 325 "GraphModule.cs"
                                        {
#line 326 "GraphModule.cs"
#line 326 "GraphModule.cs"
                                            int* csharp2cuda_temp_113 = &((output)->count);
#line 326 "GraphModule.cs"
                                            int csharp2cuda_temp_114 = (output)->capacity;
#line 326 "GraphModule.cs"
                                            int csharp2cuda_temp_115;
#line 326 "GraphModule.cs"
                                            if (((csharp2cuda_temp_114) == (2147483647)))
                                            {
#line 326 "GraphModule.cs"
                                                csharp2cuda_temp_115 = csharp2cuda_i32_neg(1);
                                            }
                                            else
                                            {
#line 328 "GraphModule.cs"
                                                int csharp2cuda_temp_116 = (output)->capacity;
#line 326 "GraphModule.cs"
                                                csharp2cuda_temp_115 = csharp2cuda_i32_add(csharp2cuda_temp_116, 1);
                                            }
                                            (*(csharp2cuda_temp_113) = csharp2cuda_temp_115);
#line 329 "GraphModule.cs"
#line 329 "GraphModule.cs"
                                            int* csharp2cuda_temp_117 = &((output)->valid);
                                            (*(csharp2cuda_temp_117) = 0);
#line 330 "GraphModule.cs"
                                            break;
                                        }
#line 332 "GraphModule.cs"
#line 332 "GraphModule.cs"
                                        int* csharp2cuda_temp_118 = &(((graph)[edge_count]).from);
                                        (*(csharp2cuda_temp_118) = row);
#line 333 "GraphModule.cs"
#line 333 "GraphModule.cs"
                                        int* csharp2cuda_temp_119 = &(((graph)[edge_count]).to);
                                        (*(csharp2cuda_temp_119) = column);
#line 334 "GraphModule.cs"
#line 334 "GraphModule.cs"
                                        double* csharp2cuda_temp_120 = &(((graph)[edge_count]).weight);
#line 334 "GraphModule.cs"
                                        int csharp2cuda_temp_121 = (first)->columns;
#line 334 "GraphModule.cs"
                                        double csharp2cuda_temp_122 = (matrix)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_121), column)];
                                        (*(csharp2cuda_temp_120) = csharp2cuda_temp_122);
#line 335 "GraphModule.cs"
#line 335 "GraphModule.cs"
                                        int* csharp2cuda_temp_123 = &(edge_count);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_123));
                                    }
#line 321 "GraphModule.cs"
                                    int* csharp2cuda_temp_107 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_107));
                                }
                            }
#line 320 "GraphModule.cs"
                            int* csharp2cuda_temp_105 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_105));
                        }
                    }
#line 337 "GraphModule.cs"
#line 337 "GraphModule.cs"
                    int* csharp2cuda_temp_124 = &((output)->rows);
#line 337 "GraphModule.cs"
                    int csharp2cuda_temp_125 = (first)->rows;
                    (*(csharp2cuda_temp_124) = csharp2cuda_temp_125);
#line 338 "GraphModule.cs"
                    if ((output)->valid)
                    {
#line 339 "GraphModule.cs"
#line 339 "GraphModule.cs"
                        int* csharp2cuda_temp_126 = &((output)->count);
                        (*(csharp2cuda_temp_126) = edge_count);
                    }
#line 340 "GraphModule.cs"
                    break;
                }
#line 342 "GraphModule.cs"
            case 5:
#line 343 "GraphModule.cs"
                mathblocks_sequence_set_vector_shape(output, vertex_count);
#line 344 "GraphModule.cs"
#line 344 "GraphModule.cs"
                bool csharp2cuda_temp_127;
#line 344 "GraphModule.cs"
                if (!(((vertex_count) <= (0))))
                {
#line 344 "GraphModule.cs"
                    csharp2cuda_temp_127 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 344 "GraphModule.cs"
                    csharp2cuda_temp_127 = true;
                }
                if (csharp2cuda_temp_127)
#line 345 "GraphModule.cs"
                {
#line 346 "GraphModule.cs"
#line 346 "GraphModule.cs"
                    int* csharp2cuda_temp_128 = &((output)->valid);
                    (*(csharp2cuda_temp_128) = 0);
#line 347 "GraphModule.cs"
                    break;
                }
#line 349 "GraphModule.cs"
#line 349 "GraphModule.cs"
                double* csharp2cuda_temp_129 = &((result)[0]);
                (*(csharp2cuda_temp_129) = 0.0);
#line 350 "GraphModule.cs"
                if (((vertex_count) == (1)))
                {
#line 351 "GraphModule.cs"
                    break;
                }
#line 352 "GraphModule.cs"
                {
#line 353 "GraphModule.cs"
                    int size = csharp2cuda_i32_sub(vertex_count, 1);
#line 354 "GraphModule.cs"
                    double* reduced_matrix = scratch;
#line 355 "GraphModule.cs"
                    double* right = csharp2cuda_pointer_add(reduced_matrix, csharp2cuda_i32_mul(size, size));
#line 356 "GraphModule.cs"
                    double* augmented = csharp2cuda_pointer_add(right, size);
#line 357 "GraphModule.cs"
                    {
#line 357 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(size, size)))))
                                break;
#line 358 "GraphModule.cs"
#line 358 "GraphModule.cs"
                            double* csharp2cuda_temp_131 = &((reduced_matrix)[index]);
                            (*(csharp2cuda_temp_131) = 0.0);
#line 357 "GraphModule.cs"
                            int* csharp2cuda_temp_130 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_130));
                        }
                    }
#line 359 "GraphModule.cs"
                    {
#line 359 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (size))))
                                break;
#line 360 "GraphModule.cs"
#line 360 "GraphModule.cs"
                            double* csharp2cuda_temp_133 = &((right)[index]);
                            (*(csharp2cuda_temp_133) = 0.0);
#line 359 "GraphModule.cs"
                            int* csharp2cuda_temp_132 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_132));
                        }
                    }
#line 361 "GraphModule.cs"
                    {
#line 361 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 361 "GraphModule.cs"
                            int csharp2cuda_temp_135 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_135))))
                                break;
#line 362 "GraphModule.cs"
                            {
#line 363 "GraphModule.cs"
                                int from = ((edges)[index]).from;
#line 364 "GraphModule.cs"
                                int to = ((edges)[index]).to;
#line 365 "GraphModule.cs"
                                if (((from) != (0)))
#line 366 "GraphModule.cs"
                                {
#line 367 "GraphModule.cs"
#line 367 "GraphModule.cs"
                                    double* csharp2cuda_temp_136 = &((reduced_matrix)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(from, 1), size), from), 1)]);
#line 367 "GraphModule.cs"
                                    double csharp2cuda_temp_137 = *(csharp2cuda_temp_136);
                                    (*(csharp2cuda_temp_136) = __dadd_rn(csharp2cuda_temp_137, 1.0));
#line 368 "GraphModule.cs"
#line 368 "GraphModule.cs"
                                    double* csharp2cuda_temp_138 = &((right)[csharp2cuda_i32_sub(from, 1)]);
#line 368 "GraphModule.cs"
                                    double csharp2cuda_temp_139 = *(csharp2cuda_temp_138);
#line 368 "GraphModule.cs"
                                    double csharp2cuda_temp_140 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_138) = __dsub_rn(csharp2cuda_temp_139, csharp2cuda_temp_140));
                                }
#line 370 "GraphModule.cs"
                                if (((to) != (0)))
#line 371 "GraphModule.cs"
                                {
#line 372 "GraphModule.cs"
#line 372 "GraphModule.cs"
                                    double* csharp2cuda_temp_141 = &((reduced_matrix)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(to, 1), size), to), 1)]);
#line 372 "GraphModule.cs"
                                    double csharp2cuda_temp_142 = *(csharp2cuda_temp_141);
                                    (*(csharp2cuda_temp_141) = __dadd_rn(csharp2cuda_temp_142, 1.0));
#line 373 "GraphModule.cs"
#line 373 "GraphModule.cs"
                                    double* csharp2cuda_temp_143 = &((right)[csharp2cuda_i32_sub(to, 1)]);
#line 373 "GraphModule.cs"
                                    double csharp2cuda_temp_144 = *(csharp2cuda_temp_143);
#line 373 "GraphModule.cs"
                                    double csharp2cuda_temp_145 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_143) = __dadd_rn(csharp2cuda_temp_144, csharp2cuda_temp_145));
                                }
#line 375 "GraphModule.cs"
#line 375 "GraphModule.cs"
                                bool csharp2cuda_temp_146;
#line 375 "GraphModule.cs"
                                if (((from) != (0)))
                                {
#line 375 "GraphModule.cs"
                                    csharp2cuda_temp_146 = ((to) != (0));
                                }
                                else
                                {
#line 375 "GraphModule.cs"
                                    csharp2cuda_temp_146 = false;
                                }
                                if (csharp2cuda_temp_146)
#line 376 "GraphModule.cs"
                                {
#line 377 "GraphModule.cs"
#line 377 "GraphModule.cs"
                                    double* csharp2cuda_temp_147 = &((reduced_matrix)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(from, 1), size), to), 1)]);
#line 377 "GraphModule.cs"
                                    double csharp2cuda_temp_148 = *(csharp2cuda_temp_147);
                                    (*(csharp2cuda_temp_147) = __dsub_rn(csharp2cuda_temp_148, 1.0));
#line 378 "GraphModule.cs"
#line 378 "GraphModule.cs"
                                    double* csharp2cuda_temp_149 = &((reduced_matrix)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(to, 1), size), from), 1)]);
#line 378 "GraphModule.cs"
                                    double csharp2cuda_temp_150 = *(csharp2cuda_temp_149);
                                    (*(csharp2cuda_temp_149) = __dsub_rn(csharp2cuda_temp_150, 1.0));
                                }
                            }
#line 361 "GraphModule.cs"
                            int* csharp2cuda_temp_134 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_134));
                        }
                    }
#line 381 "GraphModule.cs"
#line 381 "GraphModule.cs"
                    bool csharp2cuda_temp_151 = mathblocks_matrix_try_solve(reduced_matrix, right, size, augmented, csharp2cuda_pointer_add(result, 1));
                    if ((!(csharp2cuda_temp_151)))
#line 387 "GraphModule.cs"
                    {
#line 388 "GraphModule.cs"
#line 388 "GraphModule.cs"
                        int* csharp2cuda_temp_152 = &((output)->valid);
                        (*(csharp2cuda_temp_152) = 0);
                    }
#line 390 "GraphModule.cs"
                    break;
                }
#line 392 "GraphModule.cs"
            case 6:
#line 393 "GraphModule.cs"
#line 393 "GraphModule.cs"
                int csharp2cuda_temp_153 = (second)->count;
                if (((csharp2cuda_temp_153) != (vertex_count)))
#line 394 "GraphModule.cs"
                {
#line 395 "GraphModule.cs"
#line 395 "GraphModule.cs"
                    int* csharp2cuda_temp_154 = &((output)->valid);
                    (*(csharp2cuda_temp_154) = 0);
#line 396 "GraphModule.cs"
                    break;
                }
#line 398 "GraphModule.cs"
                {
#line 399 "GraphModule.cs"
                    double sum_squares = 0.0;
#line 400 "GraphModule.cs"
                    {
#line 400 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 400 "GraphModule.cs"
                            int csharp2cuda_temp_156 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_156))))
                                break;
#line 401 "GraphModule.cs"
                            {
#line 402 "GraphModule.cs"
                                int csharp2cuda_temp_157 = ((edges)[index]).to;
#line 402 "GraphModule.cs"
                                double csharp2cuda_temp_158 = (vector)[csharp2cuda_temp_157];
#line 403 "GraphModule.cs"
                                int csharp2cuda_temp_159 = ((edges)[index]).from;
#line 403 "GraphModule.cs"
                                double csharp2cuda_temp_160 = (vector)[csharp2cuda_temp_159];
#line 404 "GraphModule.cs"
                                double csharp2cuda_temp_161 = ((edges)[index]).weight;
#line 402 "GraphModule.cs"
                                double residual = __dsub_rn(__dsub_rn(csharp2cuda_temp_158, csharp2cuda_temp_160), csharp2cuda_temp_161);
#line 405 "GraphModule.cs"
#line 405 "GraphModule.cs"
                                double* csharp2cuda_temp_162 = &(sum_squares);
#line 405 "GraphModule.cs"
                                double csharp2cuda_temp_163 = *(csharp2cuda_temp_162);
                                (*(csharp2cuda_temp_162) = __dadd_rn(csharp2cuda_temp_163, __dmul_rn(residual, residual)));
                            }
#line 400 "GraphModule.cs"
                            int* csharp2cuda_temp_155 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_155));
                        }
                    }
#line 407 "GraphModule.cs"
#line 407 "GraphModule.cs"
                    double* csharp2cuda_temp_164 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_164) = mathblocks_square_root(sum_squares));
#line 408 "GraphModule.cs"
                    break;
                }
#line 410 "GraphModule.cs"
            case 8:
#line 411 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 412 "GraphModule.cs"
                {
#line 413 "GraphModule.cs"
#line 413 "GraphModule.cs"
                    int* csharp2cuda_temp_165 = &((output)->valid);
                    (*(csharp2cuda_temp_165) = 0);
#line 414 "GraphModule.cs"
                    break;
                }
#line 416 "GraphModule.cs"
                {
#line 417 "GraphModule.cs"
                    MathBlockGraphKernelEdge* work = ((MathBlockGraphKernelEdge*)(scratch));
#line 418 "GraphModule.cs"
                    {
#line 418 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 418 "GraphModule.cs"
                            int csharp2cuda_temp_167 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_167))))
                                break;
#line 419 "GraphModule.cs"
#line 419 "GraphModule.cs"
                            MathBlockGraphKernelEdge* csharp2cuda_temp_168 = &((work)[index]);
#line 419 "GraphModule.cs"
                            MathBlockGraphKernelEdge csharp2cuda_temp_169 = (edges)[index];
                            (*(csharp2cuda_temp_168) = csharp2cuda_temp_169);
#line 418 "GraphModule.cs"
                            int* csharp2cuda_temp_166 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_166));
                        }
                    }
#line 420 "GraphModule.cs"
#line 420 "GraphModule.cs"
                    int csharp2cuda_temp_170 = (first)->count;
#line 420 "GraphModule.cs"
                    int csharp2cuda_temp_171 = (first)->count;
                    mathblocks_graph_sort_edges(work, csharp2cuda_pointer_add(work, csharp2cuda_temp_170), csharp2cuda_temp_171);
#line 421 "GraphModule.cs"
                    int csharp2cuda_temp_172 = (first)->count;
#line 421 "GraphModule.cs"
                    int* parent = ((int*)(csharp2cuda_pointer_add(work, csharp2cuda_i32_mul(2, csharp2cuda_temp_172))));
#line 422 "GraphModule.cs"
                    unsigned char* rank = ((unsigned char*)(csharp2cuda_pointer_add(parent, vertex_count)));
#line 423 "GraphModule.cs"
                    {
#line 423 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (vertex_count))))
                                break;
#line 424 "GraphModule.cs"
                            {
#line 425 "GraphModule.cs"
#line 425 "GraphModule.cs"
                                int* csharp2cuda_temp_174 = &((parent)[index]);
                                (*(csharp2cuda_temp_174) = index);
#line 426 "GraphModule.cs"
#line 426 "GraphModule.cs"
                                unsigned char* csharp2cuda_temp_175 = &((rank)[index]);
                                (*(csharp2cuda_temp_175) = ((unsigned char)(0)));
                            }
#line 423 "GraphModule.cs"
                            int* csharp2cuda_temp_173 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_173));
                        }
                    }
#line 429 "GraphModule.cs"
                    unsigned long long csharp2cuda_temp_176 = (output)->data_pointer;
#line 428 "GraphModule.cs"
                    MathBlockGraphKernelEdge* selected = ((MathBlockGraphKernelEdge*)(csharp2cuda_temp_176));
#line 430 "GraphModule.cs"
                    int selected_count = 0;
#line 431 "GraphModule.cs"
                    {
#line 431 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 431 "GraphModule.cs"
                            int csharp2cuda_temp_178 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_178))))
                                break;
#line 432 "GraphModule.cs"
                            {
#line 433 "GraphModule.cs"
                                int csharp2cuda_temp_179 = ((work)[index]).from;
#line 433 "GraphModule.cs"
                                int left = mathblocks_graph_find(parent, csharp2cuda_temp_179);
#line 434 "GraphModule.cs"
                                int csharp2cuda_temp_180 = ((work)[index]).to;
#line 434 "GraphModule.cs"
                                int right = mathblocks_graph_find(parent, csharp2cuda_temp_180);
#line 435 "GraphModule.cs"
                                if (((left) == (right)))
                                {
#line 436 "GraphModule.cs"
                                    goto csharp2cuda_for_continue_14;
                                }
#line 437 "GraphModule.cs"
#line 437 "GraphModule.cs"
                                unsigned char csharp2cuda_temp_181 = (rank)[left];
#line 437 "GraphModule.cs"
                                unsigned char csharp2cuda_temp_182 = (rank)[right];
                                if (((((int)(csharp2cuda_temp_181))) < (((int)(csharp2cuda_temp_182)))))
                                {
#line 438 "GraphModule.cs"
#line 438 "GraphModule.cs"
                                    int* csharp2cuda_temp_183 = &((parent)[left]);
                                    (*(csharp2cuda_temp_183) = right);
                                }
                                else
                                {
#line 439 "GraphModule.cs"
#line 439 "GraphModule.cs"
                                    unsigned char csharp2cuda_temp_184 = (rank)[left];
#line 439 "GraphModule.cs"
                                    unsigned char csharp2cuda_temp_185 = (rank)[right];
                                    if (((((int)(csharp2cuda_temp_184))) > (((int)(csharp2cuda_temp_185)))))
                                    {
#line 440 "GraphModule.cs"
#line 440 "GraphModule.cs"
                                        int* csharp2cuda_temp_186 = &((parent)[right]);
                                        (*(csharp2cuda_temp_186) = left);
                                    }
                                    else
#line 442 "GraphModule.cs"
                                    {
#line 443 "GraphModule.cs"
#line 443 "GraphModule.cs"
                                        int* csharp2cuda_temp_187 = &((parent)[right]);
                                        (*(csharp2cuda_temp_187) = left);
#line 444 "GraphModule.cs"
#line 444 "GraphModule.cs"
                                        unsigned char* csharp2cuda_temp_188 = &((rank)[left]);
                                        (*(csharp2cuda_temp_188))++;
                                    }
                                }
#line 446 "GraphModule.cs"
#line 446 "GraphModule.cs"
                                int* csharp2cuda_temp_189 = &(selected_count);
#line 446 "GraphModule.cs"
                                int csharp2cuda_temp_190 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_189));
#line 446 "GraphModule.cs"
                                MathBlockGraphKernelEdge* csharp2cuda_temp_191 = &((selected)[csharp2cuda_temp_190]);
#line 446 "GraphModule.cs"
                                MathBlockGraphKernelEdge csharp2cuda_temp_192 = (work)[index];
                                (*(csharp2cuda_temp_191) = csharp2cuda_temp_192);
                            }
                            csharp2cuda_for_continue_14:
#line 431 "GraphModule.cs"
                            int* csharp2cuda_temp_177 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_177));
                        }
                    }
#line 448 "GraphModule.cs"
#line 448 "GraphModule.cs"
                    int* csharp2cuda_temp_193 = &((output)->rows);
                    (*(csharp2cuda_temp_193) = vertex_count);
#line 449 "GraphModule.cs"
#line 449 "GraphModule.cs"
                    int* csharp2cuda_temp_194 = &((output)->count);
                    (*(csharp2cuda_temp_194) = selected_count);
#line 450 "GraphModule.cs"
                    break;
                }
#line 452 "GraphModule.cs"
            case 9:
#line 453 "GraphModule.cs"
                mathblocks_sequence_set_vector_shape(output, vertex_count);
#line 454 "GraphModule.cs"
#line 454 "GraphModule.cs"
                bool csharp2cuda_temp_195;
#line 454 "GraphModule.cs"
                if (!(((vertex_count) <= (0))))
                {
#line 454 "GraphModule.cs"
                    csharp2cuda_temp_195 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 454 "GraphModule.cs"
                    csharp2cuda_temp_195 = true;
                }
                if (csharp2cuda_temp_195)
#line 455 "GraphModule.cs"
                {
#line 456 "GraphModule.cs"
#line 456 "GraphModule.cs"
                    int* csharp2cuda_temp_196 = &((output)->valid);
                    (*(csharp2cuda_temp_196) = 0);
#line 457 "GraphModule.cs"
                    break;
                }
#line 459 "GraphModule.cs"
                {
#line 460 "GraphModule.cs"
                    double damping = (second)->scalar_value;
#line 461 "GraphModule.cs"
                    int iterations = 0;
#line 462 "GraphModule.cs"
#line 462 "GraphModule.cs"
                    bool csharp2cuda_temp_197;
#line 462 "GraphModule.cs"
                    if (!(((damping) < (0.0))))
                    {
#line 462 "GraphModule.cs"
                        csharp2cuda_temp_197 = ((damping) > (1.0));
                    }
                    else
                    {
#line 462 "GraphModule.cs"
                        csharp2cuda_temp_197 = true;
                    }
#line 462 "GraphModule.cs"
                    bool csharp2cuda_temp_198;
#line 462 "GraphModule.cs"
                    if (!(csharp2cuda_temp_197))
                    {
#line 463 "GraphModule.cs"
                        double csharp2cuda_temp_199 = (third)->scalar_value;
#line 463 "GraphModule.cs"
                        int* csharp2cuda_temp_200 = &(iterations);
#line 463 "GraphModule.cs"
                        bool csharp2cuda_temp_201 = mathblocks_sequence_positive_integer(csharp2cuda_temp_199, csharp2cuda_temp_200);
#line 462 "GraphModule.cs"
                        csharp2cuda_temp_198 = (!(csharp2cuda_temp_201));
                    }
                    else
                    {
#line 462 "GraphModule.cs"
                        csharp2cuda_temp_198 = true;
                    }
#line 462 "GraphModule.cs"
                    bool csharp2cuda_temp_202;
#line 462 "GraphModule.cs"
                    if (!(csharp2cuda_temp_198))
                    {
#line 462 "GraphModule.cs"
                        csharp2cuda_temp_202 = ((iterations) > (10000));
                    }
                    else
                    {
#line 462 "GraphModule.cs"
                        csharp2cuda_temp_202 = true;
                    }
                    if (csharp2cuda_temp_202)
#line 465 "GraphModule.cs"
                    {
#line 466 "GraphModule.cs"
#line 466 "GraphModule.cs"
                        int* csharp2cuda_temp_203 = &((output)->valid);
                        (*(csharp2cuda_temp_203) = 0);
#line 467 "GraphModule.cs"
                        break;
                    }
#line 469 "GraphModule.cs"
                    double* outgoing = scratch;
#line 470 "GraphModule.cs"
                    double* next = csharp2cuda_pointer_add(scratch, vertex_count);
#line 471 "GraphModule.cs"
                    {
#line 471 "GraphModule.cs"
                        int vertex = 0;
                        while (true)
                        {
                            if (!(((vertex) < (vertex_count))))
                                break;
#line 472 "GraphModule.cs"
                            {
#line 473 "GraphModule.cs"
#line 473 "GraphModule.cs"
                                double* csharp2cuda_temp_205 = &((result)[vertex]);
#line 473 "GraphModule.cs"
                                double csharp2cuda_temp_206 = __ddiv_rn(1.0, ((double)(vertex_count)));
                                (*(csharp2cuda_temp_205) = csharp2cuda_temp_206);
#line 474 "GraphModule.cs"
#line 474 "GraphModule.cs"
                                double* csharp2cuda_temp_207 = &((outgoing)[vertex]);
                                (*(csharp2cuda_temp_207) = 0.0);
                            }
#line 471 "GraphModule.cs"
                            int* csharp2cuda_temp_204 = &(vertex);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_204));
                        }
                    }
#line 476 "GraphModule.cs"
                    {
#line 476 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 476 "GraphModule.cs"
                            int csharp2cuda_temp_209 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_209))))
                                break;
#line 477 "GraphModule.cs"
                            {
#line 478 "GraphModule.cs"
#line 478 "GraphModule.cs"
                                double csharp2cuda_temp_210 = ((edges)[index]).weight;
                                if (((csharp2cuda_temp_210) < (0.0)))
#line 479 "GraphModule.cs"
                                {
#line 480 "GraphModule.cs"
#line 480 "GraphModule.cs"
                                    int* csharp2cuda_temp_211 = &((output)->valid);
                                    (*(csharp2cuda_temp_211) = 0);
#line 481 "GraphModule.cs"
                                    break;
                                }
#line 483 "GraphModule.cs"
#line 483 "GraphModule.cs"
                                int csharp2cuda_temp_212 = ((edges)[index]).from;
#line 483 "GraphModule.cs"
                                double* csharp2cuda_temp_213 = &((outgoing)[csharp2cuda_temp_212]);
#line 483 "GraphModule.cs"
                                double csharp2cuda_temp_214 = *(csharp2cuda_temp_213);
#line 483 "GraphModule.cs"
                                double csharp2cuda_temp_215 = ((edges)[index]).weight;
                                (*(csharp2cuda_temp_213) = __dadd_rn(csharp2cuda_temp_214, csharp2cuda_temp_215));
                            }
#line 476 "GraphModule.cs"
                            int* csharp2cuda_temp_208 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_208));
                        }
                    }
#line 485 "GraphModule.cs"
                    {
#line 485 "GraphModule.cs"
                        int iteration = 0;
                        while (true)
                        {
#line 485 "GraphModule.cs"
                            bool csharp2cuda_temp_217 = (output)->valid;
#line 485 "GraphModule.cs"
                            bool csharp2cuda_temp_218;
#line 485 "GraphModule.cs"
                            if (csharp2cuda_temp_217)
                            {
#line 485 "GraphModule.cs"
                                csharp2cuda_temp_218 = ((iteration) < (iterations));
                            }
                            else
                            {
#line 485 "GraphModule.cs"
                                csharp2cuda_temp_218 = false;
                            }
                            if (!(csharp2cuda_temp_218))
                                break;
#line 486 "GraphModule.cs"
                            {
#line 487 "GraphModule.cs"
                                {
#line 487 "GraphModule.cs"
                                    int vertex = 0;
                                    while (true)
                                    {
                                        if (!(((vertex) < (vertex_count))))
                                            break;
#line 488 "GraphModule.cs"
#line 488 "GraphModule.cs"
                                        double* csharp2cuda_temp_220 = &((next)[vertex]);
#line 488 "GraphModule.cs"
                                        double csharp2cuda_temp_221 = __ddiv_rn(__dsub_rn(1.0, damping), ((double)(vertex_count)));
                                        (*(csharp2cuda_temp_220) = csharp2cuda_temp_221);
#line 487 "GraphModule.cs"
                                        int* csharp2cuda_temp_219 = &(vertex);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_219));
                                    }
                                }
#line 489 "GraphModule.cs"
                                double dangling = 0.0;
#line 490 "GraphModule.cs"
                                {
#line 490 "GraphModule.cs"
                                    int vertex = 0;
                                    while (true)
                                    {
                                        if (!(((vertex) < (vertex_count))))
                                            break;
#line 491 "GraphModule.cs"
#line 491 "GraphModule.cs"
                                        double csharp2cuda_temp_223 = (outgoing)[vertex];
                                        if (((csharp2cuda_temp_223) == (0.0)))
                                        {
#line 492 "GraphModule.cs"
#line 492 "GraphModule.cs"
                                            double* csharp2cuda_temp_224 = &(dangling);
#line 492 "GraphModule.cs"
                                            double csharp2cuda_temp_225 = *(csharp2cuda_temp_224);
#line 492 "GraphModule.cs"
                                            double csharp2cuda_temp_226 = (result)[vertex];
                                            (*(csharp2cuda_temp_224) = __dadd_rn(csharp2cuda_temp_225, csharp2cuda_temp_226));
                                        }
#line 490 "GraphModule.cs"
                                        int* csharp2cuda_temp_222 = &(vertex);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_222));
                                    }
                                }
#line 493 "GraphModule.cs"
                                double dangling_share = __ddiv_rn(__dmul_rn(damping, dangling), ((double)(vertex_count)));
#line 494 "GraphModule.cs"
                                {
#line 494 "GraphModule.cs"
                                    int vertex = 0;
                                    while (true)
                                    {
                                        if (!(((vertex) < (vertex_count))))
                                            break;
#line 495 "GraphModule.cs"
#line 495 "GraphModule.cs"
                                        double* csharp2cuda_temp_228 = &((next)[vertex]);
#line 495 "GraphModule.cs"
                                        double csharp2cuda_temp_229 = *(csharp2cuda_temp_228);
                                        (*(csharp2cuda_temp_228) = __dadd_rn(csharp2cuda_temp_229, dangling_share));
#line 494 "GraphModule.cs"
                                        int* csharp2cuda_temp_227 = &(vertex);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_227));
                                    }
                                }
#line 496 "GraphModule.cs"
                                {
#line 496 "GraphModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 496 "GraphModule.cs"
                                        int csharp2cuda_temp_231 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_231))))
                                            break;
#line 497 "GraphModule.cs"
#line 497 "GraphModule.cs"
                                        int csharp2cuda_temp_232 = ((edges)[index]).to;
#line 497 "GraphModule.cs"
                                        double* csharp2cuda_temp_233 = &((next)[csharp2cuda_temp_232]);
#line 497 "GraphModule.cs"
                                        double csharp2cuda_temp_234 = *(csharp2cuda_temp_233);
#line 497 "GraphModule.cs"
                                        int csharp2cuda_temp_235 = ((edges)[index]).from;
#line 497 "GraphModule.cs"
                                        double csharp2cuda_temp_236 = (result)[csharp2cuda_temp_235];
#line 498 "GraphModule.cs"
                                        double csharp2cuda_temp_237 = ((edges)[index]).weight;
#line 498 "GraphModule.cs"
                                        int csharp2cuda_temp_238 = ((edges)[index]).from;
#line 498 "GraphModule.cs"
                                        double csharp2cuda_temp_239 = (outgoing)[csharp2cuda_temp_238];
#line 497 "GraphModule.cs"
                                        double csharp2cuda_temp_240 = __ddiv_rn(__dmul_rn(__dmul_rn(damping, csharp2cuda_temp_236), csharp2cuda_temp_237), csharp2cuda_temp_239);
                                        (*(csharp2cuda_temp_233) = __dadd_rn(csharp2cuda_temp_234, csharp2cuda_temp_240));
#line 496 "GraphModule.cs"
                                        int* csharp2cuda_temp_230 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_230));
                                    }
                                }
#line 499 "GraphModule.cs"
                                {
#line 499 "GraphModule.cs"
                                    int vertex = 0;
                                    while (true)
                                    {
                                        if (!(((vertex) < (vertex_count))))
                                            break;
#line 500 "GraphModule.cs"
#line 500 "GraphModule.cs"
                                        double* csharp2cuda_temp_242 = &((result)[vertex]);
#line 500 "GraphModule.cs"
                                        double csharp2cuda_temp_243 = (next)[vertex];
                                        (*(csharp2cuda_temp_242) = csharp2cuda_temp_243);
#line 499 "GraphModule.cs"
                                        int* csharp2cuda_temp_241 = &(vertex);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_241));
                                    }
                                }
                            }
#line 485 "GraphModule.cs"
                            int* csharp2cuda_temp_216 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_216));
                        }
                    }
#line 502 "GraphModule.cs"
                    break;
                }
#line 504 "GraphModule.cs"
            case 10:
            case 12:
            case 13:
#line 507 "GraphModule.cs"
                mathblocks_sequence_set_matrix_shape(output, vertex_count, vertex_count);
#line 508 "GraphModule.cs"
                {
#line 508 "GraphModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (csharp2cuda_i32_mul(vertex_count, vertex_count)))))
                            break;
#line 509 "GraphModule.cs"
#line 509 "GraphModule.cs"
                        double* csharp2cuda_temp_245 = &((result)[index]);
                        (*(csharp2cuda_temp_245) = 0.0);
#line 508 "GraphModule.cs"
                        int* csharp2cuda_temp_244 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_244));
                    }
                }
#line 510 "GraphModule.cs"
                {
#line 510 "GraphModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 510 "GraphModule.cs"
                        int csharp2cuda_temp_247 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_247))))
                            break;
#line 511 "GraphModule.cs"
                        {
#line 512 "GraphModule.cs"
                            int from = ((edges)[index]).from;
#line 513 "GraphModule.cs"
                            int to = ((edges)[index]).to;
#line 514 "GraphModule.cs"
                            double weight = ((edges)[index]).weight;
#line 515 "GraphModule.cs"
                            if (((opcode) == (10)))
#line 516 "GraphModule.cs"
                            {
#line 517 "GraphModule.cs"
#line 517 "GraphModule.cs"
                                double* csharp2cuda_temp_248 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), to)]);
#line 517 "GraphModule.cs"
                                double csharp2cuda_temp_249 = *(csharp2cuda_temp_248);
                                (*(csharp2cuda_temp_248) = __dadd_rn(csharp2cuda_temp_249, weight));
                            }
                            else
                            {
#line 519 "GraphModule.cs"
                                if (((opcode) == (12)))
#line 520 "GraphModule.cs"
                                {
#line 521 "GraphModule.cs"
#line 521 "GraphModule.cs"
                                    double* csharp2cuda_temp_250 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), to)]);
#line 521 "GraphModule.cs"
                                    double csharp2cuda_temp_251 = *(csharp2cuda_temp_250);
                                    (*(csharp2cuda_temp_250) = __dadd_rn(csharp2cuda_temp_251, weight));
#line 522 "GraphModule.cs"
#line 522 "GraphModule.cs"
                                    double* csharp2cuda_temp_252 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), from)]);
#line 522 "GraphModule.cs"
                                    double csharp2cuda_temp_253 = *(csharp2cuda_temp_252);
                                    (*(csharp2cuda_temp_252) = __dadd_rn(csharp2cuda_temp_253, weight));
                                }
                                else
#line 525 "GraphModule.cs"
                                {
#line 526 "GraphModule.cs"
#line 526 "GraphModule.cs"
                                    double* csharp2cuda_temp_254 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), from)]);
#line 526 "GraphModule.cs"
                                    double csharp2cuda_temp_255 = *(csharp2cuda_temp_254);
                                    (*(csharp2cuda_temp_254) = __dadd_rn(csharp2cuda_temp_255, weight));
#line 527 "GraphModule.cs"
#line 527 "GraphModule.cs"
                                    double* csharp2cuda_temp_256 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), to)]);
#line 527 "GraphModule.cs"
                                    double csharp2cuda_temp_257 = *(csharp2cuda_temp_256);
                                    (*(csharp2cuda_temp_256) = __dadd_rn(csharp2cuda_temp_257, weight));
#line 528 "GraphModule.cs"
#line 528 "GraphModule.cs"
                                    double* csharp2cuda_temp_258 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), to)]);
#line 528 "GraphModule.cs"
                                    double csharp2cuda_temp_259 = *(csharp2cuda_temp_258);
                                    (*(csharp2cuda_temp_258) = __dsub_rn(csharp2cuda_temp_259, weight));
#line 529 "GraphModule.cs"
#line 529 "GraphModule.cs"
                                    double* csharp2cuda_temp_260 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), from)]);
#line 529 "GraphModule.cs"
                                    double csharp2cuda_temp_261 = *(csharp2cuda_temp_260);
                                    (*(csharp2cuda_temp_260) = __dsub_rn(csharp2cuda_temp_261, weight));
                                }
                            }
                        }
#line 510 "GraphModule.cs"
                        int* csharp2cuda_temp_246 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_246));
                    }
                }
#line 532 "GraphModule.cs"
                break;
#line 533 "GraphModule.cs"
            case 11:
#line 534 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 535 "GraphModule.cs"
                {
#line 536 "GraphModule.cs"
#line 536 "GraphModule.cs"
                    int* csharp2cuda_temp_262 = &((output)->valid);
                    (*(csharp2cuda_temp_262) = 0);
#line 537 "GraphModule.cs"
                    break;
                }
#line 539 "GraphModule.cs"
                {
#line 540 "GraphModule.cs"
                    int* adjacency = ((int*)(scratch));
#line 541 "GraphModule.cs"
                    {
#line 541 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(vertex_count, vertex_count)))))
                                break;
#line 542 "GraphModule.cs"
#line 542 "GraphModule.cs"
                            int* csharp2cuda_temp_264 = &((adjacency)[index]);
                            (*(csharp2cuda_temp_264) = 0);
#line 541 "GraphModule.cs"
                            int* csharp2cuda_temp_263 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_263));
                        }
                    }
#line 543 "GraphModule.cs"
                    {
#line 543 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 543 "GraphModule.cs"
                            int csharp2cuda_temp_266 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_266))))
                                break;
#line 544 "GraphModule.cs"
                            {
#line 545 "GraphModule.cs"
#line 545 "GraphModule.cs"
                                int csharp2cuda_temp_267 = ((edges)[index]).from;
#line 545 "GraphModule.cs"
                                int csharp2cuda_temp_268 = ((edges)[index]).to;
#line 545 "GraphModule.cs"
                                int* csharp2cuda_temp_269 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_temp_267, vertex_count), csharp2cuda_temp_268)]);
                                (*(csharp2cuda_temp_269) = 1);
#line 546 "GraphModule.cs"
#line 546 "GraphModule.cs"
                                int csharp2cuda_temp_270 = ((edges)[index]).to;
#line 546 "GraphModule.cs"
                                int csharp2cuda_temp_271 = ((edges)[index]).from;
#line 546 "GraphModule.cs"
                                int* csharp2cuda_temp_272 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_temp_270, vertex_count), csharp2cuda_temp_271)]);
                                (*(csharp2cuda_temp_272) = 1);
                            }
#line 543 "GraphModule.cs"
                            int* csharp2cuda_temp_265 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_265));
                        }
                    }
#line 548 "GraphModule.cs"
                    int count = 0;
#line 549 "GraphModule.cs"
                    {
#line 549 "GraphModule.cs"
                        int one = 0;
                        while (true)
                        {
                            if (!(((one) < (vertex_count))))
                                break;
#line 550 "GraphModule.cs"
                            {
#line 550 "GraphModule.cs"
                                int two = csharp2cuda_i32_add(one, 1);
                                while (true)
                                {
                                    if (!(((two) < (vertex_count))))
                                        break;
#line 551 "GraphModule.cs"
                                    {
#line 551 "GraphModule.cs"
                                        int three = csharp2cuda_i32_add(two, 1);
                                        while (true)
                                        {
                                            if (!(((three) < (vertex_count))))
                                                break;
#line 552 "GraphModule.cs"
#line 552 "GraphModule.cs"
                                            int csharp2cuda_temp_276 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(one, vertex_count), two)];
#line 552 "GraphModule.cs"
                                            bool csharp2cuda_temp_277;
#line 552 "GraphModule.cs"
                                            if (((csharp2cuda_temp_276) != 0))
                                            {
#line 553 "GraphModule.cs"
                                                int csharp2cuda_temp_278 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(one, vertex_count), three)];
#line 552 "GraphModule.cs"
                                                csharp2cuda_temp_277 = ((csharp2cuda_temp_278) != 0);
                                            }
                                            else
                                            {
#line 552 "GraphModule.cs"
                                                csharp2cuda_temp_277 = false;
                                            }
#line 552 "GraphModule.cs"
                                            bool csharp2cuda_temp_279;
#line 552 "GraphModule.cs"
                                            if (csharp2cuda_temp_277)
                                            {
#line 554 "GraphModule.cs"
                                                int csharp2cuda_temp_280 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(two, vertex_count), three)];
#line 552 "GraphModule.cs"
                                                csharp2cuda_temp_279 = ((csharp2cuda_temp_280) != 0);
                                            }
                                            else
                                            {
#line 552 "GraphModule.cs"
                                                csharp2cuda_temp_279 = false;
                                            }
                                            if (csharp2cuda_temp_279)
#line 555 "GraphModule.cs"
                                            {
#line 556 "GraphModule.cs"
#line 556 "GraphModule.cs"
                                                int* csharp2cuda_temp_281 = &(count);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_281));
                                            }
#line 551 "GraphModule.cs"
                                            int* csharp2cuda_temp_275 = &(three);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_275));
                                        }
                                    }
#line 550 "GraphModule.cs"
                                    int* csharp2cuda_temp_274 = &(two);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_274));
                                }
                            }
#line 549 "GraphModule.cs"
                            int* csharp2cuda_temp_273 = &(one);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_273));
                        }
                    }
#line 558 "GraphModule.cs"
#line 558 "GraphModule.cs"
                    double* csharp2cuda_temp_282 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_282) = ((double)(count)));
#line 559 "GraphModule.cs"
                    break;
                }
#line 561 "GraphModule.cs"
            case 14:
#line 562 "GraphModule.cs"
                mathblocks_sequence_set_vector_shape(output, vertex_count);
#line 563 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 564 "GraphModule.cs"
                {
#line 565 "GraphModule.cs"
#line 565 "GraphModule.cs"
                    int* csharp2cuda_temp_283 = &((output)->valid);
                    (*(csharp2cuda_temp_283) = 0);
#line 566 "GraphModule.cs"
                    break;
                }
#line 568 "GraphModule.cs"
                {
#line 569 "GraphModule.cs"
                    int source = 0;
#line 570 "GraphModule.cs"
#line 570 "GraphModule.cs"
                    double csharp2cuda_temp_284 = (second)->scalar_value;
#line 570 "GraphModule.cs"
                    int* csharp2cuda_temp_285 = &(source);
#line 570 "GraphModule.cs"
                    bool csharp2cuda_temp_286 = mathblocks_nonnegative_integer(csharp2cuda_temp_284, csharp2cuda_temp_285);
#line 570 "GraphModule.cs"
                    bool csharp2cuda_temp_287;
#line 570 "GraphModule.cs"
                    if (!((!(csharp2cuda_temp_286))))
                    {
#line 570 "GraphModule.cs"
                        csharp2cuda_temp_287 = ((source) >= (vertex_count));
                    }
                    else
                    {
#line 570 "GraphModule.cs"
                        csharp2cuda_temp_287 = true;
                    }
                    if (csharp2cuda_temp_287)
#line 571 "GraphModule.cs"
                    {
#line 572 "GraphModule.cs"
#line 572 "GraphModule.cs"
                        int* csharp2cuda_temp_288 = &((output)->valid);
                        (*(csharp2cuda_temp_288) = 0);
#line 573 "GraphModule.cs"
                        break;
                    }
#line 575 "GraphModule.cs"
                    int* visited = ((int*)(scratch));
#line 576 "GraphModule.cs"
                    {
#line 576 "GraphModule.cs"
                        int vertex = 0;
                        while (true)
                        {
                            if (!(((vertex) < (vertex_count))))
                                break;
#line 577 "GraphModule.cs"
                            {
#line 578 "GraphModule.cs"
#line 578 "GraphModule.cs"
                                double* csharp2cuda_temp_290 = &((result)[vertex]);
                                (*(csharp2cuda_temp_290) = mathblocks_positive_infinity());
#line 579 "GraphModule.cs"
#line 579 "GraphModule.cs"
                                int* csharp2cuda_temp_291 = &((visited)[vertex]);
                                (*(csharp2cuda_temp_291) = 0);
                            }
#line 576 "GraphModule.cs"
                            int* csharp2cuda_temp_289 = &(vertex);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_289));
                        }
                    }
#line 581 "GraphModule.cs"
#line 581 "GraphModule.cs"
                    double* csharp2cuda_temp_292 = &((result)[source]);
                    (*(csharp2cuda_temp_292) = 0.0);
#line 582 "GraphModule.cs"
                    {
#line 582 "GraphModule.cs"
                        int iteration = 0;
                        while (true)
                        {
                            if (!(((iteration) < (vertex_count))))
                                break;
#line 583 "GraphModule.cs"
                            {
#line 584 "GraphModule.cs"
                                int vertex = -1;
#line 585 "GraphModule.cs"
                                double best = mathblocks_positive_infinity();
#line 586 "GraphModule.cs"
                                {
#line 586 "GraphModule.cs"
                                    int candidate = 0;
                                    while (true)
                                    {
                                        if (!(((candidate) < (vertex_count))))
                                            break;
#line 587 "GraphModule.cs"
#line 587 "GraphModule.cs"
                                        int csharp2cuda_temp_295 = (visited)[candidate];
#line 587 "GraphModule.cs"
                                        bool csharp2cuda_temp_296;
#line 587 "GraphModule.cs"
                                        if ((!(((csharp2cuda_temp_295) != 0))))
                                        {
#line 587 "GraphModule.cs"
                                            double csharp2cuda_temp_297 = (result)[candidate];
#line 587 "GraphModule.cs"
                                            csharp2cuda_temp_296 = ((csharp2cuda_temp_297) < (best));
                                        }
                                        else
                                        {
#line 587 "GraphModule.cs"
                                            csharp2cuda_temp_296 = false;
                                        }
                                        if (csharp2cuda_temp_296)
#line 588 "GraphModule.cs"
                                        {
#line 589 "GraphModule.cs"
#line 589 "GraphModule.cs"
                                            double* csharp2cuda_temp_298 = &(best);
#line 589 "GraphModule.cs"
                                            double csharp2cuda_temp_299 = (result)[candidate];
                                            (*(csharp2cuda_temp_298) = csharp2cuda_temp_299);
#line 590 "GraphModule.cs"
#line 590 "GraphModule.cs"
                                            int* csharp2cuda_temp_300 = &(vertex);
                                            (*(csharp2cuda_temp_300) = candidate);
                                        }
#line 586 "GraphModule.cs"
                                        int* csharp2cuda_temp_294 = &(candidate);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_294));
                                    }
                                }
#line 592 "GraphModule.cs"
                                if (((vertex) < (0)))
                                {
#line 593 "GraphModule.cs"
                                    break;
                                }
#line 594 "GraphModule.cs"
#line 594 "GraphModule.cs"
                                int* csharp2cuda_temp_301 = &((visited)[vertex]);
                                (*(csharp2cuda_temp_301) = 1);
#line 595 "GraphModule.cs"
                                {
#line 595 "GraphModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 595 "GraphModule.cs"
                                        int csharp2cuda_temp_303 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_303))))
                                            break;
#line 596 "GraphModule.cs"
                                        {
#line 597 "GraphModule.cs"
#line 597 "GraphModule.cs"
                                            double csharp2cuda_temp_304 = ((edges)[index]).weight;
                                            if (((csharp2cuda_temp_304) < (0.0)))
#line 598 "GraphModule.cs"
                                            {
#line 599 "GraphModule.cs"
#line 599 "GraphModule.cs"
                                                int* csharp2cuda_temp_305 = &((output)->valid);
                                                (*(csharp2cuda_temp_305) = 0);
#line 600 "GraphModule.cs"
                                                break;
                                            }
#line 602 "GraphModule.cs"
                                            int csharp2cuda_temp_306 = ((edges)[index]).from;
#line 602 "GraphModule.cs"
                                            int csharp2cuda_temp_307;
#line 602 "GraphModule.cs"
                                            if (((csharp2cuda_temp_306) == (vertex)))
                                            {
#line 602 "GraphModule.cs"
                                                csharp2cuda_temp_307 = ((edges)[index]).to;
                                            }
                                            else
                                            {
#line 604 "GraphModule.cs"
                                                int csharp2cuda_temp_308 = ((edges)[index]).to;
#line 604 "GraphModule.cs"
                                                int csharp2cuda_temp_309;
#line 604 "GraphModule.cs"
                                                if (((csharp2cuda_temp_308) == (vertex)))
                                                {
#line 604 "GraphModule.cs"
                                                    csharp2cuda_temp_309 = ((edges)[index]).from;
                                                }
                                                else
                                                {
#line 604 "GraphModule.cs"
                                                    csharp2cuda_temp_309 = csharp2cuda_i32_neg(1);
                                                }
#line 602 "GraphModule.cs"
                                                csharp2cuda_temp_307 = csharp2cuda_temp_309;
                                            }
#line 602 "GraphModule.cs"
                                            int neighbor = csharp2cuda_temp_307;
#line 607 "GraphModule.cs"
                                            if (((neighbor) < (0)))
                                            {
#line 608 "GraphModule.cs"
                                                goto csharp2cuda_for_continue_32;
                                            }
#line 609 "GraphModule.cs"
                                            double csharp2cuda_temp_310 = (result)[vertex];
#line 609 "GraphModule.cs"
                                            double csharp2cuda_temp_311 = ((edges)[index]).weight;
#line 609 "GraphModule.cs"
                                            double candidate = __dadd_rn(csharp2cuda_temp_310, csharp2cuda_temp_311);
#line 610 "GraphModule.cs"
#line 610 "GraphModule.cs"
                                            double* csharp2cuda_temp_312 = &((result)[neighbor]);
#line 610 "GraphModule.cs"
                                            double csharp2cuda_temp_313 = (result)[neighbor];
#line 610 "GraphModule.cs"
                                            double csharp2cuda_temp_314;
#line 610 "GraphModule.cs"
                                            if (((csharp2cuda_temp_313) < (candidate)))
                                            {
#line 610 "GraphModule.cs"
                                                csharp2cuda_temp_314 = (result)[neighbor];
                                            }
                                            else
                                            {
#line 610 "GraphModule.cs"
                                                csharp2cuda_temp_314 = candidate;
                                            }
                                            (*(csharp2cuda_temp_312) = csharp2cuda_temp_314);
                                        }
                                        csharp2cuda_for_continue_32:
#line 595 "GraphModule.cs"
                                        int* csharp2cuda_temp_302 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_302));
                                    }
                                }
                            }
#line 582 "GraphModule.cs"
                            int* csharp2cuda_temp_293 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_293));
                        }
                    }
#line 615 "GraphModule.cs"
                    break;
                }
        }
#line 619 "GraphModule.cs"
#line 619 "GraphModule.cs"
        bool csharp2cuda_temp_315 = (output)->valid;
#line 619 "GraphModule.cs"
        bool csharp2cuda_temp_316;
#line 619 "GraphModule.cs"
        if (csharp2cuda_temp_315)
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_316 = ((opcode) != (3));
        }
        else
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_316 = false;
        }
#line 619 "GraphModule.cs"
        bool csharp2cuda_temp_317;
#line 619 "GraphModule.cs"
        if (csharp2cuda_temp_316)
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_317 = ((opcode) != (4));
        }
        else
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_317 = false;
        }
#line 619 "GraphModule.cs"
        bool csharp2cuda_temp_318;
#line 619 "GraphModule.cs"
        if (csharp2cuda_temp_317)
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_318 = ((opcode) != (5));
        }
        else
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_318 = false;
        }
#line 619 "GraphModule.cs"
        bool csharp2cuda_temp_319;
#line 619 "GraphModule.cs"
        if (csharp2cuda_temp_318)
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_319 = ((opcode) != (7));
        }
        else
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_319 = false;
        }
#line 619 "GraphModule.cs"
        bool csharp2cuda_temp_320;
#line 619 "GraphModule.cs"
        if (csharp2cuda_temp_319)
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_320 = ((opcode) != (8));
        }
        else
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_320 = false;
        }
#line 619 "GraphModule.cs"
        bool csharp2cuda_temp_321;
#line 619 "GraphModule.cs"
        if (csharp2cuda_temp_320)
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_321 = ((opcode) != (9));
        }
        else
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_321 = false;
        }
#line 619 "GraphModule.cs"
        bool csharp2cuda_temp_322;
#line 619 "GraphModule.cs"
        if (csharp2cuda_temp_321)
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_322 = ((opcode) != (10));
        }
        else
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_322 = false;
        }
#line 619 "GraphModule.cs"
        bool csharp2cuda_temp_323;
#line 619 "GraphModule.cs"
        if (csharp2cuda_temp_322)
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_323 = ((opcode) != (12));
        }
        else
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_323 = false;
        }
#line 619 "GraphModule.cs"
        bool csharp2cuda_temp_324;
#line 619 "GraphModule.cs"
        if (csharp2cuda_temp_323)
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_324 = ((opcode) != (13));
        }
        else
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_324 = false;
        }
#line 619 "GraphModule.cs"
        bool csharp2cuda_temp_325;
#line 619 "GraphModule.cs"
        if (csharp2cuda_temp_324)
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_325 = ((opcode) != (14));
        }
        else
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_325 = false;
        }
#line 619 "GraphModule.cs"
        bool csharp2cuda_temp_326;
#line 619 "GraphModule.cs"
        if (csharp2cuda_temp_325)
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_326 = ((opcode) != (15));
        }
        else
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_326 = false;
        }
#line 619 "GraphModule.cs"
        bool csharp2cuda_temp_327;
#line 619 "GraphModule.cs"
        if (csharp2cuda_temp_326)
        {
#line 622 "GraphModule.cs"
            double csharp2cuda_temp_328 = (output)->scalar_value;
#line 619 "GraphModule.cs"
            csharp2cuda_temp_327 = (!(isfinite(csharp2cuda_temp_328)));
        }
        else
        {
#line 619 "GraphModule.cs"
            csharp2cuda_temp_327 = false;
        }
        if (csharp2cuda_temp_327)
#line 623 "GraphModule.cs"
        {
#line 624 "GraphModule.cs"
#line 624 "GraphModule.cs"
            int* csharp2cuda_temp_329 = &((output)->valid);
            (*(csharp2cuda_temp_329) = 0);
        }
#line 626 "GraphModule.cs"
#line 626 "GraphModule.cs"
        bool csharp2cuda_temp_330 = (output)->valid;
#line 626 "GraphModule.cs"
        bool csharp2cuda_temp_331;
#line 626 "GraphModule.cs"
        if (csharp2cuda_temp_330)
        {
#line 627 "GraphModule.cs"
            bool csharp2cuda_temp_332;
#line 627 "GraphModule.cs"
            if (!(((opcode) == (3))))
            {
#line 627 "GraphModule.cs"
                csharp2cuda_temp_332 = ((opcode) == (5));
            }
            else
            {
#line 627 "GraphModule.cs"
                csharp2cuda_temp_332 = true;
            }
#line 627 "GraphModule.cs"
            bool csharp2cuda_temp_333;
#line 627 "GraphModule.cs"
            if (!(csharp2cuda_temp_332))
            {
#line 627 "GraphModule.cs"
                csharp2cuda_temp_333 = ((opcode) == (9));
            }
            else
            {
#line 627 "GraphModule.cs"
                csharp2cuda_temp_333 = true;
            }
#line 627 "GraphModule.cs"
            bool csharp2cuda_temp_334;
#line 627 "GraphModule.cs"
            if (!(csharp2cuda_temp_333))
            {
#line 627 "GraphModule.cs"
                csharp2cuda_temp_334 = ((opcode) == (10));
            }
            else
            {
#line 627 "GraphModule.cs"
                csharp2cuda_temp_334 = true;
            }
#line 627 "GraphModule.cs"
            bool csharp2cuda_temp_335;
#line 627 "GraphModule.cs"
            if (!(csharp2cuda_temp_334))
            {
#line 627 "GraphModule.cs"
                csharp2cuda_temp_335 = ((opcode) == (12));
            }
            else
            {
#line 627 "GraphModule.cs"
                csharp2cuda_temp_335 = true;
            }
#line 627 "GraphModule.cs"
            bool csharp2cuda_temp_336;
#line 627 "GraphModule.cs"
            if (!(csharp2cuda_temp_335))
            {
#line 627 "GraphModule.cs"
                csharp2cuda_temp_336 = ((opcode) == (13));
            }
            else
            {
#line 627 "GraphModule.cs"
                csharp2cuda_temp_336 = true;
            }
#line 627 "GraphModule.cs"
            bool csharp2cuda_temp_337;
#line 627 "GraphModule.cs"
            if (!(csharp2cuda_temp_336))
            {
#line 627 "GraphModule.cs"
                csharp2cuda_temp_337 = ((opcode) == (14));
            }
            else
            {
#line 627 "GraphModule.cs"
                csharp2cuda_temp_337 = true;
            }
#line 627 "GraphModule.cs"
            bool csharp2cuda_temp_338;
#line 627 "GraphModule.cs"
            if (!(csharp2cuda_temp_337))
            {
#line 627 "GraphModule.cs"
                csharp2cuda_temp_338 = ((opcode) == (15));
            }
            else
            {
#line 627 "GraphModule.cs"
                csharp2cuda_temp_338 = true;
            }
#line 626 "GraphModule.cs"
            csharp2cuda_temp_331 = csharp2cuda_temp_338;
        }
        else
        {
#line 626 "GraphModule.cs"
            csharp2cuda_temp_331 = false;
        }
        if (csharp2cuda_temp_331)
#line 629 "GraphModule.cs"
        {
#line 630 "GraphModule.cs"
            {
#line 630 "GraphModule.cs"
                int index = 0;
                while (true)
                {
#line 630 "GraphModule.cs"
                    int csharp2cuda_temp_340 = (output)->count;
                    if (!(((index) < (csharp2cuda_temp_340))))
                        break;
#line 631 "GraphModule.cs"
#line 631 "GraphModule.cs"
                    double csharp2cuda_temp_341 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_341))))
                    {
#line 631 "GraphModule.cs"
#line 631 "GraphModule.cs"
                        int* csharp2cuda_temp_342 = &((output)->valid);
                        (*(csharp2cuda_temp_342) = 0);
                    }
#line 630 "GraphModule.cs"
                    int* csharp2cuda_temp_339 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_339));
                }
            }
        }
    }
}

#line 130 "GraphModule.cs"
__device__ bool mathblocks_graph_edge_less(
    const MathBlockGraphKernelEdge* left,
    const MathBlockGraphKernelEdge* right)
#line 134 "GraphModule.cs"
{
#line 135 "GraphModule.cs"
#line 135 "GraphModule.cs"
    double csharp2cuda_temp_0 = (*(left)).weight;
#line 135 "GraphModule.cs"
    double csharp2cuda_temp_1 = (*(right)).weight;
    if (((csharp2cuda_temp_0) < (csharp2cuda_temp_1)))
    {
#line 136 "GraphModule.cs"
        return true;
    }
#line 137 "GraphModule.cs"
#line 137 "GraphModule.cs"
    double csharp2cuda_temp_2 = (*(right)).weight;
#line 137 "GraphModule.cs"
    double csharp2cuda_temp_3 = (*(left)).weight;
    if (((csharp2cuda_temp_2) < (csharp2cuda_temp_3)))
    {
#line 138 "GraphModule.cs"
        return false;
    }
#line 139 "GraphModule.cs"
#line 139 "GraphModule.cs"
    int csharp2cuda_temp_4 = (*(left)).from;
#line 139 "GraphModule.cs"
    int csharp2cuda_temp_5 = (*(right)).from;
    if (((csharp2cuda_temp_4) < (csharp2cuda_temp_5)))
    {
#line 140 "GraphModule.cs"
        return true;
    }
#line 141 "GraphModule.cs"
#line 141 "GraphModule.cs"
    int csharp2cuda_temp_6 = (*(right)).from;
#line 141 "GraphModule.cs"
    int csharp2cuda_temp_7 = (*(left)).from;
    if (((csharp2cuda_temp_6) < (csharp2cuda_temp_7)))
    {
#line 142 "GraphModule.cs"
        return false;
    }
#line 143 "GraphModule.cs"
#line 143 "GraphModule.cs"
    int csharp2cuda_temp_8 = (*(left)).to;
#line 143 "GraphModule.cs"
    int csharp2cuda_temp_9 = (*(right)).to;
    return ((csharp2cuda_temp_8) < (csharp2cuda_temp_9));
}

#line 146 "GraphModule.cs"
__device__ int mathblocks_graph_find(int* parent, int vertex)
#line 148 "GraphModule.cs"
{
#line 149 "GraphModule.cs"
    while (true)
    {
#line 149 "GraphModule.cs"
        int csharp2cuda_temp_0 = (parent)[vertex];
        if (!(((csharp2cuda_temp_0) != (vertex))))
            break;
#line 150 "GraphModule.cs"
        {
#line 151 "GraphModule.cs"
#line 151 "GraphModule.cs"
            int* csharp2cuda_temp_1 = &((parent)[vertex]);
#line 151 "GraphModule.cs"
            int csharp2cuda_temp_2 = (parent)[vertex];
#line 151 "GraphModule.cs"
            int csharp2cuda_temp_3 = (parent)[csharp2cuda_temp_2];
            (*(csharp2cuda_temp_1) = csharp2cuda_temp_3);
#line 152 "GraphModule.cs"
#line 152 "GraphModule.cs"
            int* csharp2cuda_temp_4 = &(vertex);
#line 152 "GraphModule.cs"
            int csharp2cuda_temp_5 = (parent)[vertex];
            (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
        }
    }
#line 154 "GraphModule.cs"
    return vertex;
}

#line 55 "GraphModule.cs"
__device__ void mathblocks_graph_sort_edges(MathBlockGraphKernelEdge* edges, MathBlockGraphKernelEdge* buffer, int count)
#line 57 "GraphModule.cs"
{
#line 58 "GraphModule.cs"
    MathBlockGraphKernelEdge* source = edges;
#line 59 "GraphModule.cs"
    MathBlockGraphKernelEdge* target = buffer;
#line 60 "GraphModule.cs"
    {
#line 60 "GraphModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 61 "GraphModule.cs"
            {
#line 62 "GraphModule.cs"
                {
#line 62 "GraphModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 63 "GraphModule.cs"
                        {
#line 64 "GraphModule.cs"
                            int csharp2cuda_temp_4;
#line 64 "GraphModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 64 "GraphModule.cs"
                                csharp2cuda_temp_4 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 64 "GraphModule.cs"
                                csharp2cuda_temp_4 = count;
                            }
#line 64 "GraphModule.cs"
                            int middle = csharp2cuda_temp_4;
#line 65 "GraphModule.cs"
                            int csharp2cuda_temp_5;
#line 65 "GraphModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 65 "GraphModule.cs"
                                csharp2cuda_temp_5 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 65 "GraphModule.cs"
                                csharp2cuda_temp_5 = count;
                            }
#line 65 "GraphModule.cs"
                            int end = csharp2cuda_temp_5;
#line 66 "GraphModule.cs"
                            int left = start;
#line 67 "GraphModule.cs"
                            int right = middle;
#line 68 "GraphModule.cs"
                            int position = start;
#line 69 "GraphModule.cs"
                            while (true)
                            {
#line 69 "GraphModule.cs"
                                bool csharp2cuda_temp_6;
#line 69 "GraphModule.cs"
                                if (((left) < (middle)))
                                {
#line 69 "GraphModule.cs"
                                    csharp2cuda_temp_6 = ((right) < (end));
                                }
                                else
                                {
#line 69 "GraphModule.cs"
                                    csharp2cuda_temp_6 = false;
                                }
                                if (!(csharp2cuda_temp_6))
                                    break;
#line 70 "GraphModule.cs"
                                {
#line 71 "GraphModule.cs"
#line 71 "GraphModule.cs"
                                    MathBlockGraphKernelEdge* csharp2cuda_temp_7 = &((source)[right]);
#line 71 "GraphModule.cs"
                                    MathBlockGraphKernelEdge* csharp2cuda_temp_8 = &((source)[left]);
                                    if (mathblocks_graph_edge_less(csharp2cuda_temp_7, csharp2cuda_temp_8))
                                    {
#line 72 "GraphModule.cs"
#line 72 "GraphModule.cs"
                                        int* csharp2cuda_temp_9 = &(position);
#line 72 "GraphModule.cs"
                                        int csharp2cuda_temp_10 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
#line 72 "GraphModule.cs"
                                        MathBlockGraphKernelEdge* csharp2cuda_temp_11 = &((target)[csharp2cuda_temp_10]);
#line 72 "GraphModule.cs"
                                        int* csharp2cuda_temp_12 = &(right);
#line 72 "GraphModule.cs"
                                        int csharp2cuda_temp_13 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_12));
#line 72 "GraphModule.cs"
                                        MathBlockGraphKernelEdge csharp2cuda_temp_14 = (source)[csharp2cuda_temp_13];
                                        (*(csharp2cuda_temp_11) = csharp2cuda_temp_14);
                                    }
                                    else
                                    {
#line 74 "GraphModule.cs"
#line 74 "GraphModule.cs"
                                        int* csharp2cuda_temp_15 = &(position);
#line 74 "GraphModule.cs"
                                        int csharp2cuda_temp_16 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
#line 74 "GraphModule.cs"
                                        MathBlockGraphKernelEdge* csharp2cuda_temp_17 = &((target)[csharp2cuda_temp_16]);
#line 74 "GraphModule.cs"
                                        int* csharp2cuda_temp_18 = &(left);
#line 74 "GraphModule.cs"
                                        int csharp2cuda_temp_19 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_18));
#line 74 "GraphModule.cs"
                                        MathBlockGraphKernelEdge csharp2cuda_temp_20 = (source)[csharp2cuda_temp_19];
                                        (*(csharp2cuda_temp_17) = csharp2cuda_temp_20);
                                    }
                                }
                            }
#line 76 "GraphModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 77 "GraphModule.cs"
#line 77 "GraphModule.cs"
                                int* csharp2cuda_temp_21 = &(position);
#line 77 "GraphModule.cs"
                                int csharp2cuda_temp_22 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_21));
#line 77 "GraphModule.cs"
                                MathBlockGraphKernelEdge* csharp2cuda_temp_23 = &((target)[csharp2cuda_temp_22]);
#line 77 "GraphModule.cs"
                                int* csharp2cuda_temp_24 = &(left);
#line 77 "GraphModule.cs"
                                int csharp2cuda_temp_25 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_24));
#line 77 "GraphModule.cs"
                                MathBlockGraphKernelEdge csharp2cuda_temp_26 = (source)[csharp2cuda_temp_25];
                                (*(csharp2cuda_temp_23) = csharp2cuda_temp_26);
                            }
#line 78 "GraphModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 79 "GraphModule.cs"
#line 79 "GraphModule.cs"
                                int* csharp2cuda_temp_27 = &(position);
#line 79 "GraphModule.cs"
                                int csharp2cuda_temp_28 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_27));
#line 79 "GraphModule.cs"
                                MathBlockGraphKernelEdge* csharp2cuda_temp_29 = &((target)[csharp2cuda_temp_28]);
#line 79 "GraphModule.cs"
                                int* csharp2cuda_temp_30 = &(right);
#line 79 "GraphModule.cs"
                                int csharp2cuda_temp_31 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_30));
#line 79 "GraphModule.cs"
                                MathBlockGraphKernelEdge csharp2cuda_temp_32 = (source)[csharp2cuda_temp_31];
                                (*(csharp2cuda_temp_29) = csharp2cuda_temp_32);
                            }
                        }
#line 62 "GraphModule.cs"
                        int* csharp2cuda_temp_2 = &(start);
#line 62 "GraphModule.cs"
                        int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                        (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 81 "GraphModule.cs"
                MathBlockGraphKernelEdge* sorted = target;
#line 82 "GraphModule.cs"
#line 82 "GraphModule.cs"
                MathBlockGraphKernelEdge** csharp2cuda_temp_33 = &(target);
                (*(csharp2cuda_temp_33) = source);
#line 83 "GraphModule.cs"
#line 83 "GraphModule.cs"
                MathBlockGraphKernelEdge** csharp2cuda_temp_34 = &(source);
                (*(csharp2cuda_temp_34) = sorted);
            }
#line 60 "GraphModule.cs"
            int* csharp2cuda_temp_0 = &(width);
#line 60 "GraphModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, width));
        }
    }
#line 85 "GraphModule.cs"
    if (((((void*)(source))) != (((void*)(edges)))))
    {
#line 86 "GraphModule.cs"
        {
#line 86 "GraphModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 87 "GraphModule.cs"
#line 87 "GraphModule.cs"
                MathBlockGraphKernelEdge* csharp2cuda_temp_36 = &((edges)[index]);
#line 87 "GraphModule.cs"
                MathBlockGraphKernelEdge csharp2cuda_temp_37 = (source)[index];
                (*(csharp2cuda_temp_36) = csharp2cuda_temp_37);
#line 86 "GraphModule.cs"
                int* csharp2cuda_temp_35 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_35));
            }
        }
    }
}