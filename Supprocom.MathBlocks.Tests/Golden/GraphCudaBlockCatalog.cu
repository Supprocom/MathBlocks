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

#line 53 "GraphModule.cs"
__device__ int mathblocks_graph_component_count(
    const MathBlockGraphKernelEdge* edges,
    int edge_count,
    int vertex_count,
    int* visited,
    int* queue);

#line 120 "GraphModule.cs"
__device__ void mathblocks_graph_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 93 "GraphModule.cs"
__device__ bool mathblocks_graph_edge_less(
    const MathBlockGraphKernelEdge* left,
    const MathBlockGraphKernelEdge* right);

#line 109 "GraphModule.cs"
__device__ int mathblocks_graph_find(int* parent, int vertex);

#line 53 "GraphModule.cs"
__device__ int mathblocks_graph_component_count(
    const MathBlockGraphKernelEdge* edges,
    int edge_count,
    int vertex_count,
    int* visited,
    int* queue)
#line 60 "GraphModule.cs"
{
#line 61 "GraphModule.cs"
    {
#line 61 "GraphModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (vertex_count))))
                break;
#line 62 "GraphModule.cs"
#line 62 "GraphModule.cs"
            int* csharp2cuda_temp_1 = &((visited)[index]);
            (*(csharp2cuda_temp_1) = 0);
#line 61 "GraphModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 63 "GraphModule.cs"
    int components = 0;
#line 64 "GraphModule.cs"
    {
#line 64 "GraphModule.cs"
        int start = 0;
        while (true)
        {
            if (!(((start) < (vertex_count))))
                break;
#line 65 "GraphModule.cs"
            {
#line 66 "GraphModule.cs"
#line 66 "GraphModule.cs"
                int csharp2cuda_temp_3 = (visited)[start];
                if (((csharp2cuda_temp_3) != 0))
                {
#line 67 "GraphModule.cs"
                    goto csharp2cuda_for_continue_2;
                }
#line 68 "GraphModule.cs"
#line 68 "GraphModule.cs"
                int* csharp2cuda_temp_4 = &(components);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
#line 69 "GraphModule.cs"
                int head = 0;
#line 70 "GraphModule.cs"
                int tail = 0;
#line 71 "GraphModule.cs"
#line 71 "GraphModule.cs"
                int* csharp2cuda_temp_5 = &(tail);
#line 71 "GraphModule.cs"
                int csharp2cuda_temp_6 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
#line 71 "GraphModule.cs"
                int* csharp2cuda_temp_7 = &((queue)[csharp2cuda_temp_6]);
                (*(csharp2cuda_temp_7) = start);
#line 72 "GraphModule.cs"
#line 72 "GraphModule.cs"
                int* csharp2cuda_temp_8 = &((visited)[start]);
                (*(csharp2cuda_temp_8) = 1);
#line 73 "GraphModule.cs"
                while (true)
                {
                    if (!(((head) < (tail))))
                        break;
#line 74 "GraphModule.cs"
                    {
#line 75 "GraphModule.cs"
                        int* csharp2cuda_temp_9 = &(head);
#line 75 "GraphModule.cs"
                        int csharp2cuda_temp_10 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
#line 75 "GraphModule.cs"
                        int vertex = (queue)[csharp2cuda_temp_10];
#line 76 "GraphModule.cs"
                        {
#line 76 "GraphModule.cs"
                            int edge_index = 0;
                            while (true)
                            {
                                if (!(((edge_index) < (edge_count))))
                                    break;
#line 77 "GraphModule.cs"
                                {
#line 78 "GraphModule.cs"
                                    int csharp2cuda_temp_12 = ((edges)[edge_index]).from;
#line 78 "GraphModule.cs"
                                    int csharp2cuda_temp_13;
#line 78 "GraphModule.cs"
                                    if (((csharp2cuda_temp_12) == (vertex)))
                                    {
#line 78 "GraphModule.cs"
                                        csharp2cuda_temp_13 = ((edges)[edge_index]).to;
                                    }
                                    else
                                    {
#line 80 "GraphModule.cs"
                                        int csharp2cuda_temp_14 = ((edges)[edge_index]).to;
#line 80 "GraphModule.cs"
                                        int csharp2cuda_temp_15;
#line 80 "GraphModule.cs"
                                        if (((csharp2cuda_temp_14) == (vertex)))
                                        {
#line 80 "GraphModule.cs"
                                            csharp2cuda_temp_15 = ((edges)[edge_index]).from;
                                        }
                                        else
                                        {
#line 80 "GraphModule.cs"
                                            csharp2cuda_temp_15 = csharp2cuda_i32_neg(1);
                                        }
#line 78 "GraphModule.cs"
                                        csharp2cuda_temp_13 = csharp2cuda_temp_15;
                                    }
#line 78 "GraphModule.cs"
                                    int neighbor = csharp2cuda_temp_13;
#line 83 "GraphModule.cs"
#line 83 "GraphModule.cs"
                                    bool csharp2cuda_temp_16;
#line 83 "GraphModule.cs"
                                    if (!(((neighbor) < (0))))
                                    {
#line 83 "GraphModule.cs"
                                        int csharp2cuda_temp_17 = (visited)[neighbor];
#line 83 "GraphModule.cs"
                                        csharp2cuda_temp_16 = ((csharp2cuda_temp_17) != 0);
                                    }
                                    else
                                    {
#line 83 "GraphModule.cs"
                                        csharp2cuda_temp_16 = true;
                                    }
                                    if (csharp2cuda_temp_16)
                                    {
#line 84 "GraphModule.cs"
                                        goto csharp2cuda_for_continue_1;
                                    }
#line 85 "GraphModule.cs"
#line 85 "GraphModule.cs"
                                    int* csharp2cuda_temp_18 = &((visited)[neighbor]);
                                    (*(csharp2cuda_temp_18) = 1);
#line 86 "GraphModule.cs"
#line 86 "GraphModule.cs"
                                    int* csharp2cuda_temp_19 = &(tail);
#line 86 "GraphModule.cs"
                                    int csharp2cuda_temp_20 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_19));
#line 86 "GraphModule.cs"
                                    int* csharp2cuda_temp_21 = &((queue)[csharp2cuda_temp_20]);
                                    (*(csharp2cuda_temp_21) = neighbor);
                                }
                                csharp2cuda_for_continue_1:
#line 76 "GraphModule.cs"
                                int* csharp2cuda_temp_11 = &(edge_index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_11));
                            }
                        }
                    }
                }
            }
            csharp2cuda_for_continue_2:
#line 64 "GraphModule.cs"
            int* csharp2cuda_temp_2 = &(start);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 90 "GraphModule.cs"
    return components;
}

#line 120 "GraphModule.cs"
__device__ void mathblocks_graph_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 126 "GraphModule.cs"
{
#line 127 "GraphModule.cs"
    int thread = threadIdx.x;
#line 128 "GraphModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 128 "GraphModule.cs"
    if (((input_count) > (0)))
    {
#line 128 "GraphModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 128 "GraphModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 128 "GraphModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 129 "GraphModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 129 "GraphModule.cs"
    if (((input_count) > (1)))
    {
#line 129 "GraphModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 129 "GraphModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 129 "GraphModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 130 "GraphModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 130 "GraphModule.cs"
    if (((input_count) > (2)))
    {
#line 130 "GraphModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 130 "GraphModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 130 "GraphModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 131 "GraphModule.cs"
    if (((thread) == (0)))
#line 132 "GraphModule.cs"
    {
#line 133 "GraphModule.cs"
#line 133 "GraphModule.cs"
        double* csharp2cuda_temp_3 = &((output)->scalar_value);
        (*(csharp2cuda_temp_3) = 0.0);
#line 134 "GraphModule.cs"
#line 134 "GraphModule.cs"
        int* csharp2cuda_temp_4 = &((output)->boolean_value);
        (*(csharp2cuda_temp_4) = 0);
#line 135 "GraphModule.cs"
#line 135 "GraphModule.cs"
        int* csharp2cuda_temp_5 = &((output)->rows);
        (*(csharp2cuda_temp_5) = 0);
#line 136 "GraphModule.cs"
#line 136 "GraphModule.cs"
        int* csharp2cuda_temp_6 = &((output)->columns);
        (*(csharp2cuda_temp_6) = 0);
#line 137 "GraphModule.cs"
#line 137 "GraphModule.cs"
        int* csharp2cuda_temp_7 = &((output)->count);
        (*(csharp2cuda_temp_7) = 0);
#line 138 "GraphModule.cs"
#line 138 "GraphModule.cs"
        int* csharp2cuda_temp_8 = &((output)->valid);
#line 138 "GraphModule.cs"
        bool csharp2cuda_temp_9;
#line 138 "GraphModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 138 "GraphModule.cs"
            csharp2cuda_temp_9 = (first)->valid;
        }
        else
        {
#line 138 "GraphModule.cs"
            csharp2cuda_temp_9 = true;
        }
        (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
#line 139 "GraphModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 140 "GraphModule.cs"
#line 140 "GraphModule.cs"
            int* csharp2cuda_temp_10 = &((output)->valid);
#line 140 "GraphModule.cs"
            bool csharp2cuda_temp_11 = (output)->valid;
#line 140 "GraphModule.cs"
            bool csharp2cuda_temp_12;
#line 140 "GraphModule.cs"
            if (csharp2cuda_temp_11)
            {
#line 140 "GraphModule.cs"
                csharp2cuda_temp_12 = (second)->valid;
            }
            else
            {
#line 140 "GraphModule.cs"
                csharp2cuda_temp_12 = false;
            }
            (*(csharp2cuda_temp_10) = csharp2cuda_temp_12);
        }
#line 141 "GraphModule.cs"
        if (((((void*)(third))) != (((void*)(nullptr)))))
        {
#line 142 "GraphModule.cs"
#line 142 "GraphModule.cs"
            int* csharp2cuda_temp_13 = &((output)->valid);
#line 142 "GraphModule.cs"
            bool csharp2cuda_temp_14 = (output)->valid;
#line 142 "GraphModule.cs"
            bool csharp2cuda_temp_15;
#line 142 "GraphModule.cs"
            if (csharp2cuda_temp_14)
            {
#line 142 "GraphModule.cs"
                csharp2cuda_temp_15 = (third)->valid;
            }
            else
            {
#line 142 "GraphModule.cs"
                csharp2cuda_temp_15 = false;
            }
            (*(csharp2cuda_temp_13) = csharp2cuda_temp_15);
        }
    }
#line 144 "GraphModule.cs"
    __syncthreads();
#line 145 "GraphModule.cs"
#line 145 "GraphModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 146 "GraphModule.cs"
        return;
    }
#line 149 "GraphModule.cs"
    MathBlockGraphKernelEdge* csharp2cuda_temp_17;
#line 149 "GraphModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 149 "GraphModule.cs"
        csharp2cuda_temp_17 = ((MathBlockGraphKernelEdge*)(nullptr));
    }
    else
    {
#line 149 "GraphModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 149 "GraphModule.cs"
        csharp2cuda_temp_17 = ((MathBlockGraphKernelEdge*)(csharp2cuda_temp_18));
    }
#line 148 "GraphModule.cs"
    const MathBlockGraphKernelEdge* edges = csharp2cuda_temp_17;
#line 150 "GraphModule.cs"
    double* csharp2cuda_temp_19;
#line 150 "GraphModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 150 "GraphModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 150 "GraphModule.cs"
        unsigned long long csharp2cuda_temp_20 = (first)->data_pointer;
#line 150 "GraphModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 150 "GraphModule.cs"
    const double* matrix = csharp2cuda_temp_19;
#line 151 "GraphModule.cs"
    int* csharp2cuda_temp_21;
#line 151 "GraphModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 151 "GraphModule.cs"
        csharp2cuda_temp_21 = ((int*)(nullptr));
    }
    else
    {
#line 151 "GraphModule.cs"
        unsigned long long csharp2cuda_temp_22 = (second)->data_pointer;
#line 151 "GraphModule.cs"
        csharp2cuda_temp_21 = ((int*)(csharp2cuda_temp_22));
    }
#line 151 "GraphModule.cs"
    const int* boolean_values = csharp2cuda_temp_21;
#line 152 "GraphModule.cs"
    double* csharp2cuda_temp_23;
#line 152 "GraphModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 152 "GraphModule.cs"
        csharp2cuda_temp_23 = ((double*)(nullptr));
    }
    else
    {
#line 152 "GraphModule.cs"
        unsigned long long csharp2cuda_temp_24 = (second)->data_pointer;
#line 152 "GraphModule.cs"
        csharp2cuda_temp_23 = ((double*)(csharp2cuda_temp_24));
    }
#line 152 "GraphModule.cs"
    const double* vector = csharp2cuda_temp_23;
#line 153 "GraphModule.cs"
    unsigned long long csharp2cuda_temp_25 = (output)->data_pointer;
#line 153 "GraphModule.cs"
    double* result = ((double*)(csharp2cuda_temp_25));
#line 154 "GraphModule.cs"
    unsigned long long csharp2cuda_temp_26 = (output)->scratch_pointer;
#line 154 "GraphModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_26));
#line 156 "GraphModule.cs"
    if (((thread) == (0)))
#line 157 "GraphModule.cs"
    {
#line 158 "GraphModule.cs"
        int vertex_count = (first)->rows;
#line 159 "GraphModule.cs"
        switch (opcode)
        {
#line 161 "GraphModule.cs"
            case 0:
#line 162 "GraphModule.cs"
                if (((vertex_count) <= (1)))
#line 163 "GraphModule.cs"
                {
#line 164 "GraphModule.cs"
#line 164 "GraphModule.cs"
                    double* csharp2cuda_temp_27 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_27) = 0.0);
#line 165 "GraphModule.cs"
                    break;
                }
#line 167 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 168 "GraphModule.cs"
                {
#line 169 "GraphModule.cs"
#line 169 "GraphModule.cs"
                    int* csharp2cuda_temp_28 = &((output)->valid);
                    (*(csharp2cuda_temp_28) = 0);
#line 170 "GraphModule.cs"
                    break;
                }
#line 172 "GraphModule.cs"
                {
#line 173 "GraphModule.cs"
                    double* laplacian = scratch;
#line 174 "GraphModule.cs"
                    double* work = csharp2cuda_pointer_add(laplacian, csharp2cuda_i32_mul(vertex_count, vertex_count));
#line 175 "GraphModule.cs"
                    double* eigenvalues = csharp2cuda_pointer_add(work, csharp2cuda_i32_mul(vertex_count, vertex_count));
#line 176 "GraphModule.cs"
                    {
#line 176 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(vertex_count, vertex_count)))))
                                break;
#line 177 "GraphModule.cs"
#line 177 "GraphModule.cs"
                            double* csharp2cuda_temp_30 = &((laplacian)[index]);
                            (*(csharp2cuda_temp_30) = 0.0);
#line 176 "GraphModule.cs"
                            int* csharp2cuda_temp_29 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_29));
                        }
                    }
#line 178 "GraphModule.cs"
                    {
#line 178 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 178 "GraphModule.cs"
                            int csharp2cuda_temp_32 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_32))))
                                break;
#line 179 "GraphModule.cs"
                            {
#line 180 "GraphModule.cs"
                                int from = ((edges)[index]).from;
#line 181 "GraphModule.cs"
                                int to = ((edges)[index]).to;
#line 182 "GraphModule.cs"
                                double weight = ((edges)[index]).weight;
#line 183 "GraphModule.cs"
#line 183 "GraphModule.cs"
                                double* csharp2cuda_temp_33 = &((laplacian)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), from)]);
#line 183 "GraphModule.cs"
                                double csharp2cuda_temp_34 = *(csharp2cuda_temp_33);
                                (*(csharp2cuda_temp_33) = __dadd_rn(csharp2cuda_temp_34, weight));
#line 184 "GraphModule.cs"
#line 184 "GraphModule.cs"
                                double* csharp2cuda_temp_35 = &((laplacian)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), to)]);
#line 184 "GraphModule.cs"
                                double csharp2cuda_temp_36 = *(csharp2cuda_temp_35);
                                (*(csharp2cuda_temp_35) = __dadd_rn(csharp2cuda_temp_36, weight));
#line 185 "GraphModule.cs"
#line 185 "GraphModule.cs"
                                double* csharp2cuda_temp_37 = &((laplacian)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), to)]);
#line 185 "GraphModule.cs"
                                double csharp2cuda_temp_38 = *(csharp2cuda_temp_37);
                                (*(csharp2cuda_temp_37) = __dsub_rn(csharp2cuda_temp_38, weight));
#line 186 "GraphModule.cs"
#line 186 "GraphModule.cs"
                                double* csharp2cuda_temp_39 = &((laplacian)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), from)]);
#line 186 "GraphModule.cs"
                                double csharp2cuda_temp_40 = *(csharp2cuda_temp_39);
                                (*(csharp2cuda_temp_39) = __dsub_rn(csharp2cuda_temp_40, weight));
                            }
#line 178 "GraphModule.cs"
                            int* csharp2cuda_temp_31 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                        }
                    }
#line 188 "GraphModule.cs"
                    mathblocks_matrix_symmetric_eigenvalues(laplacian, vertex_count, work, eigenvalues);
#line 193 "GraphModule.cs"
#line 193 "GraphModule.cs"
                    double* csharp2cuda_temp_41 = &((output)->scalar_value);
#line 193 "GraphModule.cs"
                    double csharp2cuda_temp_42 = (eigenvalues)[1];
                    (*(csharp2cuda_temp_41) = csharp2cuda_temp_42);
#line 194 "GraphModule.cs"
                    break;
                }
#line 196 "GraphModule.cs"
            case 1:
#line 197 "GraphModule.cs"
#line 197 "GraphModule.cs"
                int csharp2cuda_temp_43 = (second)->count;
                if (((csharp2cuda_temp_43) != (vertex_count)))
#line 198 "GraphModule.cs"
                {
#line 199 "GraphModule.cs"
#line 199 "GraphModule.cs"
                    int* csharp2cuda_temp_44 = &((output)->valid);
                    (*(csharp2cuda_temp_44) = 0);
#line 200 "GraphModule.cs"
                    break;
                }
#line 202 "GraphModule.cs"
                {
#line 203 "GraphModule.cs"
                    bool all = true;
#line 204 "GraphModule.cs"
                    bool none = true;
#line 205 "GraphModule.cs"
                    {
#line 205 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 205 "GraphModule.cs"
                            int csharp2cuda_temp_46 = (second)->count;
                            if (!(((index) < (csharp2cuda_temp_46))))
                                break;
#line 206 "GraphModule.cs"
                            {
#line 207 "GraphModule.cs"
#line 207 "GraphModule.cs"
                                bool* csharp2cuda_temp_47 = &(all);
#line 207 "GraphModule.cs"
                                bool csharp2cuda_temp_48;
#line 207 "GraphModule.cs"
                                if (all)
                                {
#line 207 "GraphModule.cs"
                                    int csharp2cuda_temp_49 = (boolean_values)[index];
#line 207 "GraphModule.cs"
                                    csharp2cuda_temp_48 = ((csharp2cuda_temp_49) != (0));
                                }
                                else
                                {
#line 207 "GraphModule.cs"
                                    csharp2cuda_temp_48 = false;
                                }
                                (*(csharp2cuda_temp_47) = csharp2cuda_temp_48);
#line 208 "GraphModule.cs"
#line 208 "GraphModule.cs"
                                bool* csharp2cuda_temp_50 = &(none);
#line 208 "GraphModule.cs"
                                bool csharp2cuda_temp_51;
#line 208 "GraphModule.cs"
                                if (none)
                                {
#line 208 "GraphModule.cs"
                                    int csharp2cuda_temp_52 = (boolean_values)[index];
#line 208 "GraphModule.cs"
                                    csharp2cuda_temp_51 = ((csharp2cuda_temp_52) == (0));
                                }
                                else
                                {
#line 208 "GraphModule.cs"
                                    csharp2cuda_temp_51 = false;
                                }
                                (*(csharp2cuda_temp_50) = csharp2cuda_temp_51);
                            }
#line 205 "GraphModule.cs"
                            int* csharp2cuda_temp_45 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_45));
                        }
                    }
#line 210 "GraphModule.cs"
                    double cut = 0.0;
#line 211 "GraphModule.cs"
                    double left_volume = 0.0;
#line 212 "GraphModule.cs"
                    double right_volume = 0.0;
#line 213 "GraphModule.cs"
                    {
#line 213 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 213 "GraphModule.cs"
                            int csharp2cuda_temp_54 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_54))))
                                break;
#line 214 "GraphModule.cs"
                            {
#line 215 "GraphModule.cs"
#line 215 "GraphModule.cs"
                                double csharp2cuda_temp_55 = ((edges)[index]).weight;
                                if (((csharp2cuda_temp_55) < (0.0)))
#line 216 "GraphModule.cs"
                                {
#line 217 "GraphModule.cs"
#line 217 "GraphModule.cs"
                                    int* csharp2cuda_temp_56 = &((output)->valid);
                                    (*(csharp2cuda_temp_56) = 0);
#line 218 "GraphModule.cs"
                                    break;
                                }
#line 220 "GraphModule.cs"
#line 220 "GraphModule.cs"
                                int csharp2cuda_temp_57 = ((edges)[index]).from;
#line 220 "GraphModule.cs"
                                int csharp2cuda_temp_58 = (boolean_values)[csharp2cuda_temp_57];
                                if (((csharp2cuda_temp_58) != 0))
                                {
#line 221 "GraphModule.cs"
#line 221 "GraphModule.cs"
                                    double* csharp2cuda_temp_59 = &(left_volume);
#line 221 "GraphModule.cs"
                                    double csharp2cuda_temp_60 = *(csharp2cuda_temp_59);
#line 221 "GraphModule.cs"
                                    double csharp2cuda_temp_61 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_59) = __dadd_rn(csharp2cuda_temp_60, csharp2cuda_temp_61));
                                }
                                else
                                {
#line 223 "GraphModule.cs"
#line 223 "GraphModule.cs"
                                    double* csharp2cuda_temp_62 = &(right_volume);
#line 223 "GraphModule.cs"
                                    double csharp2cuda_temp_63 = *(csharp2cuda_temp_62);
#line 223 "GraphModule.cs"
                                    double csharp2cuda_temp_64 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_62) = __dadd_rn(csharp2cuda_temp_63, csharp2cuda_temp_64));
                                }
#line 224 "GraphModule.cs"
#line 224 "GraphModule.cs"
                                int csharp2cuda_temp_65 = ((edges)[index]).to;
#line 224 "GraphModule.cs"
                                int csharp2cuda_temp_66 = (boolean_values)[csharp2cuda_temp_65];
                                if (((csharp2cuda_temp_66) != 0))
                                {
#line 225 "GraphModule.cs"
#line 225 "GraphModule.cs"
                                    double* csharp2cuda_temp_67 = &(left_volume);
#line 225 "GraphModule.cs"
                                    double csharp2cuda_temp_68 = *(csharp2cuda_temp_67);
#line 225 "GraphModule.cs"
                                    double csharp2cuda_temp_69 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_67) = __dadd_rn(csharp2cuda_temp_68, csharp2cuda_temp_69));
                                }
                                else
                                {
#line 227 "GraphModule.cs"
#line 227 "GraphModule.cs"
                                    double* csharp2cuda_temp_70 = &(right_volume);
#line 227 "GraphModule.cs"
                                    double csharp2cuda_temp_71 = *(csharp2cuda_temp_70);
#line 227 "GraphModule.cs"
                                    double csharp2cuda_temp_72 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_70) = __dadd_rn(csharp2cuda_temp_71, csharp2cuda_temp_72));
                                }
#line 228 "GraphModule.cs"
#line 228 "GraphModule.cs"
                                int csharp2cuda_temp_73 = ((edges)[index]).from;
#line 228 "GraphModule.cs"
                                int csharp2cuda_temp_74 = (boolean_values)[csharp2cuda_temp_73];
#line 228 "GraphModule.cs"
                                int csharp2cuda_temp_75 = ((edges)[index]).to;
#line 228 "GraphModule.cs"
                                int csharp2cuda_temp_76 = (boolean_values)[csharp2cuda_temp_75];
                                if (((csharp2cuda_temp_74) != (csharp2cuda_temp_76)))
                                {
#line 229 "GraphModule.cs"
#line 229 "GraphModule.cs"
                                    double* csharp2cuda_temp_77 = &(cut);
#line 229 "GraphModule.cs"
                                    double csharp2cuda_temp_78 = *(csharp2cuda_temp_77);
#line 229 "GraphModule.cs"
                                    double csharp2cuda_temp_79 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_77) = __dadd_rn(csharp2cuda_temp_78, csharp2cuda_temp_79));
                                }
                            }
#line 213 "GraphModule.cs"
                            int* csharp2cuda_temp_53 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_53));
                        }
                    }
#line 231 "GraphModule.cs"
#line 231 "GraphModule.cs"
                    bool csharp2cuda_temp_80;
#line 231 "GraphModule.cs"
                    if (!(all))
                    {
#line 231 "GraphModule.cs"
                        csharp2cuda_temp_80 = none;
                    }
                    else
                    {
#line 231 "GraphModule.cs"
                        csharp2cuda_temp_80 = true;
                    }
                    if (csharp2cuda_temp_80)
                    {
#line 232 "GraphModule.cs"
#line 232 "GraphModule.cs"
                        int* csharp2cuda_temp_81 = &((output)->valid);
                        (*(csharp2cuda_temp_81) = 0);
                    }
                    else
                    {
#line 234 "GraphModule.cs"
#line 234 "GraphModule.cs"
                        double* csharp2cuda_temp_82 = &((output)->scalar_value);
#line 235 "GraphModule.cs"
                        double csharp2cuda_temp_83;
#line 235 "GraphModule.cs"
                        if (((left_volume) < (right_volume)))
                        {
#line 235 "GraphModule.cs"
                            csharp2cuda_temp_83 = left_volume;
                        }
                        else
                        {
#line 235 "GraphModule.cs"
                            csharp2cuda_temp_83 = right_volume;
                        }
#line 234 "GraphModule.cs"
                        double csharp2cuda_temp_84 = __ddiv_rn(cut, csharp2cuda_temp_83);
                        (*(csharp2cuda_temp_82) = csharp2cuda_temp_84);
                    }
#line 236 "GraphModule.cs"
                    break;
                }
#line 238 "GraphModule.cs"
            case 2:
            case 7:
#line 240 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 241 "GraphModule.cs"
                {
#line 242 "GraphModule.cs"
#line 242 "GraphModule.cs"
                    int* csharp2cuda_temp_85 = &((output)->valid);
                    (*(csharp2cuda_temp_85) = 0);
#line 243 "GraphModule.cs"
                    break;
                }
#line 245 "GraphModule.cs"
                {
#line 246 "GraphModule.cs"
                    int* visited = ((int*)(scratch));
#line 247 "GraphModule.cs"
                    int* queue = csharp2cuda_pointer_add(visited, vertex_count);
#line 250 "GraphModule.cs"
                    int csharp2cuda_temp_86 = (first)->count;
#line 248 "GraphModule.cs"
                    int components = mathblocks_graph_component_count(edges, csharp2cuda_temp_86, vertex_count, visited, queue);
#line 254 "GraphModule.cs"
                    if (((opcode) == (2)))
                    {
#line 255 "GraphModule.cs"
#line 255 "GraphModule.cs"
                        double* csharp2cuda_temp_87 = &((output)->scalar_value);
                        (*(csharp2cuda_temp_87) = ((double)(components)));
                    }
                    else
                    {
#line 257 "GraphModule.cs"
#line 257 "GraphModule.cs"
                        int* csharp2cuda_temp_88 = &((output)->boolean_value);
#line 257 "GraphModule.cs"
                        int csharp2cuda_temp_89;
#line 257 "GraphModule.cs"
                        if (((components) == (1)))
                        {
#line 257 "GraphModule.cs"
                            csharp2cuda_temp_89 = 1;
                        }
                        else
                        {
#line 257 "GraphModule.cs"
                            csharp2cuda_temp_89 = 0;
                        }
                        (*(csharp2cuda_temp_88) = csharp2cuda_temp_89);
                    }
#line 258 "GraphModule.cs"
                    break;
                }
#line 260 "GraphModule.cs"
            case 3:
            case 15:
#line 262 "GraphModule.cs"
                mathblocks_sequence_set_vector_shape(output, vertex_count);
#line 263 "GraphModule.cs"
                {
#line 263 "GraphModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (vertex_count))))
                            break;
#line 264 "GraphModule.cs"
#line 264 "GraphModule.cs"
                        double* csharp2cuda_temp_91 = &((result)[index]);
                        (*(csharp2cuda_temp_91) = 0.0);
#line 263 "GraphModule.cs"
                        int* csharp2cuda_temp_90 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_90));
                    }
                }
#line 265 "GraphModule.cs"
                {
#line 265 "GraphModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 265 "GraphModule.cs"
                        int csharp2cuda_temp_93 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_93))))
                            break;
#line 266 "GraphModule.cs"
                        {
#line 267 "GraphModule.cs"
                            double csharp2cuda_temp_94;
#line 267 "GraphModule.cs"
                            if (((opcode) == (3)))
                            {
#line 267 "GraphModule.cs"
                                csharp2cuda_temp_94 = 1.0;
                            }
                            else
                            {
#line 267 "GraphModule.cs"
                                csharp2cuda_temp_94 = ((edges)[index]).weight;
                            }
#line 267 "GraphModule.cs"
                            double amount = csharp2cuda_temp_94;
#line 268 "GraphModule.cs"
#line 268 "GraphModule.cs"
                            int csharp2cuda_temp_95 = ((edges)[index]).from;
#line 268 "GraphModule.cs"
                            double* csharp2cuda_temp_96 = &((result)[csharp2cuda_temp_95]);
#line 268 "GraphModule.cs"
                            double csharp2cuda_temp_97 = *(csharp2cuda_temp_96);
                            (*(csharp2cuda_temp_96) = __dadd_rn(csharp2cuda_temp_97, amount));
#line 269 "GraphModule.cs"
#line 269 "GraphModule.cs"
                            int csharp2cuda_temp_98 = ((edges)[index]).to;
#line 269 "GraphModule.cs"
                            double* csharp2cuda_temp_99 = &((result)[csharp2cuda_temp_98]);
#line 269 "GraphModule.cs"
                            double csharp2cuda_temp_100 = *(csharp2cuda_temp_99);
                            (*(csharp2cuda_temp_99) = __dadd_rn(csharp2cuda_temp_100, amount));
                        }
#line 265 "GraphModule.cs"
                        int* csharp2cuda_temp_92 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_92));
                    }
                }
#line 271 "GraphModule.cs"
                break;
#line 272 "GraphModule.cs"
            case 4:
#line 273 "GraphModule.cs"
#line 273 "GraphModule.cs"
                int csharp2cuda_temp_101 = (first)->rows;
#line 273 "GraphModule.cs"
                int csharp2cuda_temp_102 = (first)->columns;
                if (((csharp2cuda_temp_101) != (csharp2cuda_temp_102)))
#line 274 "GraphModule.cs"
                {
#line 275 "GraphModule.cs"
#line 275 "GraphModule.cs"
                    int* csharp2cuda_temp_103 = &((output)->valid);
                    (*(csharp2cuda_temp_103) = 0);
#line 276 "GraphModule.cs"
                    break;
                }
#line 278 "GraphModule.cs"
                {
#line 280 "GraphModule.cs"
                    unsigned long long csharp2cuda_temp_104 = (output)->data_pointer;
#line 279 "GraphModule.cs"
                    MathBlockGraphKernelEdge* graph = ((MathBlockGraphKernelEdge*)(csharp2cuda_temp_104));
#line 281 "GraphModule.cs"
                    int edge_count = 0;
#line 282 "GraphModule.cs"
                    {
#line 282 "GraphModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 282 "GraphModule.cs"
                            int csharp2cuda_temp_106 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_106))))
                                break;
#line 283 "GraphModule.cs"
                            {
#line 283 "GraphModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 283 "GraphModule.cs"
                                    int csharp2cuda_temp_108 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_108))))
                                        break;
#line 284 "GraphModule.cs"
#line 284 "GraphModule.cs"
                                    bool csharp2cuda_temp_109;
#line 284 "GraphModule.cs"
                                    if (((row) != (column)))
                                    {
#line 284 "GraphModule.cs"
                                        int csharp2cuda_temp_110 = (first)->columns;
#line 284 "GraphModule.cs"
                                        double csharp2cuda_temp_111 = (matrix)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_110), column)];
#line 284 "GraphModule.cs"
                                        csharp2cuda_temp_109 = ((csharp2cuda_temp_111) != (0.0));
                                    }
                                    else
                                    {
#line 284 "GraphModule.cs"
                                        csharp2cuda_temp_109 = false;
                                    }
                                    if (csharp2cuda_temp_109)
#line 285 "GraphModule.cs"
                                    {
#line 286 "GraphModule.cs"
#line 286 "GraphModule.cs"
                                        int csharp2cuda_temp_112 = (output)->capacity;
                                        if (((edge_count) >= (csharp2cuda_temp_112)))
#line 287 "GraphModule.cs"
                                        {
#line 288 "GraphModule.cs"
#line 288 "GraphModule.cs"
                                            int* csharp2cuda_temp_113 = &((output)->count);
#line 288 "GraphModule.cs"
                                            int csharp2cuda_temp_114 = (output)->capacity;
#line 288 "GraphModule.cs"
                                            int csharp2cuda_temp_115;
#line 288 "GraphModule.cs"
                                            if (((csharp2cuda_temp_114) == (2147483647)))
                                            {
#line 288 "GraphModule.cs"
                                                csharp2cuda_temp_115 = csharp2cuda_i32_neg(1);
                                            }
                                            else
                                            {
#line 290 "GraphModule.cs"
                                                int csharp2cuda_temp_116 = (output)->capacity;
#line 288 "GraphModule.cs"
                                                csharp2cuda_temp_115 = csharp2cuda_i32_add(csharp2cuda_temp_116, 1);
                                            }
                                            (*(csharp2cuda_temp_113) = csharp2cuda_temp_115);
#line 291 "GraphModule.cs"
#line 291 "GraphModule.cs"
                                            int* csharp2cuda_temp_117 = &((output)->valid);
                                            (*(csharp2cuda_temp_117) = 0);
#line 292 "GraphModule.cs"
                                            break;
                                        }
#line 294 "GraphModule.cs"
#line 294 "GraphModule.cs"
                                        int* csharp2cuda_temp_118 = &(((graph)[edge_count]).from);
                                        (*(csharp2cuda_temp_118) = row);
#line 295 "GraphModule.cs"
#line 295 "GraphModule.cs"
                                        int* csharp2cuda_temp_119 = &(((graph)[edge_count]).to);
                                        (*(csharp2cuda_temp_119) = column);
#line 296 "GraphModule.cs"
#line 296 "GraphModule.cs"
                                        double* csharp2cuda_temp_120 = &(((graph)[edge_count]).weight);
#line 296 "GraphModule.cs"
                                        int csharp2cuda_temp_121 = (first)->columns;
#line 296 "GraphModule.cs"
                                        double csharp2cuda_temp_122 = (matrix)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_121), column)];
                                        (*(csharp2cuda_temp_120) = csharp2cuda_temp_122);
#line 297 "GraphModule.cs"
#line 297 "GraphModule.cs"
                                        int* csharp2cuda_temp_123 = &(edge_count);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_123));
                                    }
#line 283 "GraphModule.cs"
                                    int* csharp2cuda_temp_107 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_107));
                                }
                            }
#line 282 "GraphModule.cs"
                            int* csharp2cuda_temp_105 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_105));
                        }
                    }
#line 299 "GraphModule.cs"
#line 299 "GraphModule.cs"
                    int* csharp2cuda_temp_124 = &((output)->rows);
#line 299 "GraphModule.cs"
                    int csharp2cuda_temp_125 = (first)->rows;
                    (*(csharp2cuda_temp_124) = csharp2cuda_temp_125);
#line 300 "GraphModule.cs"
                    if ((output)->valid)
                    {
#line 301 "GraphModule.cs"
#line 301 "GraphModule.cs"
                        int* csharp2cuda_temp_126 = &((output)->count);
                        (*(csharp2cuda_temp_126) = edge_count);
                    }
#line 302 "GraphModule.cs"
                    break;
                }
#line 304 "GraphModule.cs"
            case 5:
#line 305 "GraphModule.cs"
                mathblocks_sequence_set_vector_shape(output, vertex_count);
#line 306 "GraphModule.cs"
#line 306 "GraphModule.cs"
                bool csharp2cuda_temp_127;
#line 306 "GraphModule.cs"
                if (!(((vertex_count) <= (0))))
                {
#line 306 "GraphModule.cs"
                    csharp2cuda_temp_127 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 306 "GraphModule.cs"
                    csharp2cuda_temp_127 = true;
                }
                if (csharp2cuda_temp_127)
#line 307 "GraphModule.cs"
                {
#line 308 "GraphModule.cs"
#line 308 "GraphModule.cs"
                    int* csharp2cuda_temp_128 = &((output)->valid);
                    (*(csharp2cuda_temp_128) = 0);
#line 309 "GraphModule.cs"
                    break;
                }
#line 311 "GraphModule.cs"
#line 311 "GraphModule.cs"
                double* csharp2cuda_temp_129 = &((result)[0]);
                (*(csharp2cuda_temp_129) = 0.0);
#line 312 "GraphModule.cs"
                if (((vertex_count) == (1)))
                {
#line 313 "GraphModule.cs"
                    break;
                }
#line 314 "GraphModule.cs"
                {
#line 315 "GraphModule.cs"
                    int size = csharp2cuda_i32_sub(vertex_count, 1);
#line 316 "GraphModule.cs"
                    double* reduced_matrix = scratch;
#line 317 "GraphModule.cs"
                    double* right = csharp2cuda_pointer_add(reduced_matrix, csharp2cuda_i32_mul(size, size));
#line 318 "GraphModule.cs"
                    double* augmented = csharp2cuda_pointer_add(right, size);
#line 319 "GraphModule.cs"
                    {
#line 319 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(size, size)))))
                                break;
#line 320 "GraphModule.cs"
#line 320 "GraphModule.cs"
                            double* csharp2cuda_temp_131 = &((reduced_matrix)[index]);
                            (*(csharp2cuda_temp_131) = 0.0);
#line 319 "GraphModule.cs"
                            int* csharp2cuda_temp_130 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_130));
                        }
                    }
#line 321 "GraphModule.cs"
                    {
#line 321 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (size))))
                                break;
#line 322 "GraphModule.cs"
#line 322 "GraphModule.cs"
                            double* csharp2cuda_temp_133 = &((right)[index]);
                            (*(csharp2cuda_temp_133) = 0.0);
#line 321 "GraphModule.cs"
                            int* csharp2cuda_temp_132 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_132));
                        }
                    }
#line 323 "GraphModule.cs"
                    {
#line 323 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 323 "GraphModule.cs"
                            int csharp2cuda_temp_135 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_135))))
                                break;
#line 324 "GraphModule.cs"
                            {
#line 325 "GraphModule.cs"
                                int from = ((edges)[index]).from;
#line 326 "GraphModule.cs"
                                int to = ((edges)[index]).to;
#line 327 "GraphModule.cs"
                                if (((from) != (0)))
#line 328 "GraphModule.cs"
                                {
#line 329 "GraphModule.cs"
#line 329 "GraphModule.cs"
                                    double* csharp2cuda_temp_136 = &((reduced_matrix)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(from, 1), size), from), 1)]);
#line 329 "GraphModule.cs"
                                    double csharp2cuda_temp_137 = *(csharp2cuda_temp_136);
                                    (*(csharp2cuda_temp_136) = __dadd_rn(csharp2cuda_temp_137, 1.0));
#line 330 "GraphModule.cs"
#line 330 "GraphModule.cs"
                                    double* csharp2cuda_temp_138 = &((right)[csharp2cuda_i32_sub(from, 1)]);
#line 330 "GraphModule.cs"
                                    double csharp2cuda_temp_139 = *(csharp2cuda_temp_138);
#line 330 "GraphModule.cs"
                                    double csharp2cuda_temp_140 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_138) = __dsub_rn(csharp2cuda_temp_139, csharp2cuda_temp_140));
                                }
#line 332 "GraphModule.cs"
                                if (((to) != (0)))
#line 333 "GraphModule.cs"
                                {
#line 334 "GraphModule.cs"
#line 334 "GraphModule.cs"
                                    double* csharp2cuda_temp_141 = &((reduced_matrix)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(to, 1), size), to), 1)]);
#line 334 "GraphModule.cs"
                                    double csharp2cuda_temp_142 = *(csharp2cuda_temp_141);
                                    (*(csharp2cuda_temp_141) = __dadd_rn(csharp2cuda_temp_142, 1.0));
#line 335 "GraphModule.cs"
#line 335 "GraphModule.cs"
                                    double* csharp2cuda_temp_143 = &((right)[csharp2cuda_i32_sub(to, 1)]);
#line 335 "GraphModule.cs"
                                    double csharp2cuda_temp_144 = *(csharp2cuda_temp_143);
#line 335 "GraphModule.cs"
                                    double csharp2cuda_temp_145 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_143) = __dadd_rn(csharp2cuda_temp_144, csharp2cuda_temp_145));
                                }
#line 337 "GraphModule.cs"
#line 337 "GraphModule.cs"
                                bool csharp2cuda_temp_146;
#line 337 "GraphModule.cs"
                                if (((from) != (0)))
                                {
#line 337 "GraphModule.cs"
                                    csharp2cuda_temp_146 = ((to) != (0));
                                }
                                else
                                {
#line 337 "GraphModule.cs"
                                    csharp2cuda_temp_146 = false;
                                }
                                if (csharp2cuda_temp_146)
#line 338 "GraphModule.cs"
                                {
#line 339 "GraphModule.cs"
#line 339 "GraphModule.cs"
                                    double* csharp2cuda_temp_147 = &((reduced_matrix)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(from, 1), size), to), 1)]);
#line 339 "GraphModule.cs"
                                    double csharp2cuda_temp_148 = *(csharp2cuda_temp_147);
                                    (*(csharp2cuda_temp_147) = __dsub_rn(csharp2cuda_temp_148, 1.0));
#line 340 "GraphModule.cs"
#line 340 "GraphModule.cs"
                                    double* csharp2cuda_temp_149 = &((reduced_matrix)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(to, 1), size), from), 1)]);
#line 340 "GraphModule.cs"
                                    double csharp2cuda_temp_150 = *(csharp2cuda_temp_149);
                                    (*(csharp2cuda_temp_149) = __dsub_rn(csharp2cuda_temp_150, 1.0));
                                }
                            }
#line 323 "GraphModule.cs"
                            int* csharp2cuda_temp_134 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_134));
                        }
                    }
#line 343 "GraphModule.cs"
#line 343 "GraphModule.cs"
                    bool csharp2cuda_temp_151 = mathblocks_matrix_try_solve(reduced_matrix, right, size, augmented, csharp2cuda_pointer_add(result, 1));
                    if ((!(csharp2cuda_temp_151)))
#line 349 "GraphModule.cs"
                    {
#line 350 "GraphModule.cs"
#line 350 "GraphModule.cs"
                        int* csharp2cuda_temp_152 = &((output)->valid);
                        (*(csharp2cuda_temp_152) = 0);
                    }
#line 352 "GraphModule.cs"
                    break;
                }
#line 354 "GraphModule.cs"
            case 6:
#line 355 "GraphModule.cs"
#line 355 "GraphModule.cs"
                int csharp2cuda_temp_153 = (second)->count;
                if (((csharp2cuda_temp_153) != (vertex_count)))
#line 356 "GraphModule.cs"
                {
#line 357 "GraphModule.cs"
#line 357 "GraphModule.cs"
                    int* csharp2cuda_temp_154 = &((output)->valid);
                    (*(csharp2cuda_temp_154) = 0);
#line 358 "GraphModule.cs"
                    break;
                }
#line 360 "GraphModule.cs"
                {
#line 361 "GraphModule.cs"
                    double sum_squares = 0.0;
#line 362 "GraphModule.cs"
                    {
#line 362 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 362 "GraphModule.cs"
                            int csharp2cuda_temp_156 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_156))))
                                break;
#line 363 "GraphModule.cs"
                            {
#line 364 "GraphModule.cs"
                                int csharp2cuda_temp_157 = ((edges)[index]).to;
#line 364 "GraphModule.cs"
                                double csharp2cuda_temp_158 = (vector)[csharp2cuda_temp_157];
#line 365 "GraphModule.cs"
                                int csharp2cuda_temp_159 = ((edges)[index]).from;
#line 365 "GraphModule.cs"
                                double csharp2cuda_temp_160 = (vector)[csharp2cuda_temp_159];
#line 366 "GraphModule.cs"
                                double csharp2cuda_temp_161 = ((edges)[index]).weight;
#line 364 "GraphModule.cs"
                                double residual = __dsub_rn(__dsub_rn(csharp2cuda_temp_158, csharp2cuda_temp_160), csharp2cuda_temp_161);
#line 367 "GraphModule.cs"
#line 367 "GraphModule.cs"
                                double* csharp2cuda_temp_162 = &(sum_squares);
#line 367 "GraphModule.cs"
                                double csharp2cuda_temp_163 = *(csharp2cuda_temp_162);
                                (*(csharp2cuda_temp_162) = __dadd_rn(csharp2cuda_temp_163, __dmul_rn(residual, residual)));
                            }
#line 362 "GraphModule.cs"
                            int* csharp2cuda_temp_155 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_155));
                        }
                    }
#line 369 "GraphModule.cs"
#line 369 "GraphModule.cs"
                    double* csharp2cuda_temp_164 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_164) = mathblocks_square_root(sum_squares));
#line 370 "GraphModule.cs"
                    break;
                }
#line 372 "GraphModule.cs"
            case 8:
#line 373 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 374 "GraphModule.cs"
                {
#line 375 "GraphModule.cs"
#line 375 "GraphModule.cs"
                    int* csharp2cuda_temp_165 = &((output)->valid);
                    (*(csharp2cuda_temp_165) = 0);
#line 376 "GraphModule.cs"
                    break;
                }
#line 378 "GraphModule.cs"
                {
#line 379 "GraphModule.cs"
                    MathBlockGraphKernelEdge* work = ((MathBlockGraphKernelEdge*)(scratch));
#line 380 "GraphModule.cs"
                    {
#line 380 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 380 "GraphModule.cs"
                            int csharp2cuda_temp_167 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_167))))
                                break;
#line 381 "GraphModule.cs"
#line 381 "GraphModule.cs"
                            MathBlockGraphKernelEdge* csharp2cuda_temp_168 = &((work)[index]);
#line 381 "GraphModule.cs"
                            MathBlockGraphKernelEdge csharp2cuda_temp_169 = (edges)[index];
                            (*(csharp2cuda_temp_168) = csharp2cuda_temp_169);
#line 380 "GraphModule.cs"
                            int* csharp2cuda_temp_166 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_166));
                        }
                    }
#line 382 "GraphModule.cs"
                    {
#line 382 "GraphModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 382 "GraphModule.cs"
                            int csharp2cuda_temp_171 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_171))))
                                break;
#line 383 "GraphModule.cs"
                            {
#line 384 "GraphModule.cs"
                                MathBlockGraphKernelEdge value = (work)[index];
#line 385 "GraphModule.cs"
                                int position = index;
#line 386 "GraphModule.cs"
                                while (true)
                                {
#line 386 "GraphModule.cs"
                                    bool csharp2cuda_temp_172;
#line 386 "GraphModule.cs"
                                    if (((position) > (0)))
                                    {
#line 386 "GraphModule.cs"
                                        MathBlockGraphKernelEdge* csharp2cuda_temp_173 = &(value);
#line 386 "GraphModule.cs"
                                        MathBlockGraphKernelEdge* csharp2cuda_temp_174 = &((work)[csharp2cuda_i32_sub(position, 1)]);
#line 386 "GraphModule.cs"
                                        csharp2cuda_temp_172 = mathblocks_graph_edge_less(csharp2cuda_temp_173, csharp2cuda_temp_174);
                                    }
                                    else
                                    {
#line 386 "GraphModule.cs"
                                        csharp2cuda_temp_172 = false;
                                    }
                                    if (!(csharp2cuda_temp_172))
                                        break;
#line 387 "GraphModule.cs"
                                    {
#line 388 "GraphModule.cs"
#line 388 "GraphModule.cs"
                                        MathBlockGraphKernelEdge* csharp2cuda_temp_175 = &((work)[position]);
#line 388 "GraphModule.cs"
                                        MathBlockGraphKernelEdge csharp2cuda_temp_176 = (work)[csharp2cuda_i32_sub(position, 1)];
                                        (*(csharp2cuda_temp_175) = csharp2cuda_temp_176);
#line 389 "GraphModule.cs"
#line 389 "GraphModule.cs"
                                        int* csharp2cuda_temp_177 = &(position);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_177));
                                    }
                                }
#line 391 "GraphModule.cs"
#line 391 "GraphModule.cs"
                                MathBlockGraphKernelEdge* csharp2cuda_temp_178 = &((work)[position]);
                                (*(csharp2cuda_temp_178) = value);
                            }
#line 382 "GraphModule.cs"
                            int* csharp2cuda_temp_170 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_170));
                        }
                    }
#line 393 "GraphModule.cs"
                    int csharp2cuda_temp_179 = (first)->count;
#line 393 "GraphModule.cs"
                    int* parent = ((int*)(csharp2cuda_pointer_add(work, csharp2cuda_temp_179)));
#line 394 "GraphModule.cs"
                    unsigned char* rank = ((unsigned char*)(csharp2cuda_pointer_add(parent, vertex_count)));
#line 395 "GraphModule.cs"
                    {
#line 395 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (vertex_count))))
                                break;
#line 396 "GraphModule.cs"
                            {
#line 397 "GraphModule.cs"
#line 397 "GraphModule.cs"
                                int* csharp2cuda_temp_181 = &((parent)[index]);
                                (*(csharp2cuda_temp_181) = index);
#line 398 "GraphModule.cs"
#line 398 "GraphModule.cs"
                                unsigned char* csharp2cuda_temp_182 = &((rank)[index]);
                                (*(csharp2cuda_temp_182) = ((unsigned char)(0)));
                            }
#line 395 "GraphModule.cs"
                            int* csharp2cuda_temp_180 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_180));
                        }
                    }
#line 401 "GraphModule.cs"
                    unsigned long long csharp2cuda_temp_183 = (output)->data_pointer;
#line 400 "GraphModule.cs"
                    MathBlockGraphKernelEdge* selected = ((MathBlockGraphKernelEdge*)(csharp2cuda_temp_183));
#line 402 "GraphModule.cs"
                    int selected_count = 0;
#line 403 "GraphModule.cs"
                    {
#line 403 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 403 "GraphModule.cs"
                            int csharp2cuda_temp_185 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_185))))
                                break;
#line 404 "GraphModule.cs"
                            {
#line 405 "GraphModule.cs"
                                int csharp2cuda_temp_186 = ((work)[index]).from;
#line 405 "GraphModule.cs"
                                int left = mathblocks_graph_find(parent, csharp2cuda_temp_186);
#line 406 "GraphModule.cs"
                                int csharp2cuda_temp_187 = ((work)[index]).to;
#line 406 "GraphModule.cs"
                                int right = mathblocks_graph_find(parent, csharp2cuda_temp_187);
#line 407 "GraphModule.cs"
                                if (((left) == (right)))
                                {
#line 408 "GraphModule.cs"
                                    goto csharp2cuda_for_continue_15;
                                }
#line 409 "GraphModule.cs"
#line 409 "GraphModule.cs"
                                unsigned char csharp2cuda_temp_188 = (rank)[left];
#line 409 "GraphModule.cs"
                                unsigned char csharp2cuda_temp_189 = (rank)[right];
                                if (((((int)(csharp2cuda_temp_188))) < (((int)(csharp2cuda_temp_189)))))
                                {
#line 410 "GraphModule.cs"
#line 410 "GraphModule.cs"
                                    int* csharp2cuda_temp_190 = &((parent)[left]);
                                    (*(csharp2cuda_temp_190) = right);
                                }
                                else
                                {
#line 411 "GraphModule.cs"
#line 411 "GraphModule.cs"
                                    unsigned char csharp2cuda_temp_191 = (rank)[left];
#line 411 "GraphModule.cs"
                                    unsigned char csharp2cuda_temp_192 = (rank)[right];
                                    if (((((int)(csharp2cuda_temp_191))) > (((int)(csharp2cuda_temp_192)))))
                                    {
#line 412 "GraphModule.cs"
#line 412 "GraphModule.cs"
                                        int* csharp2cuda_temp_193 = &((parent)[right]);
                                        (*(csharp2cuda_temp_193) = left);
                                    }
                                    else
#line 414 "GraphModule.cs"
                                    {
#line 415 "GraphModule.cs"
#line 415 "GraphModule.cs"
                                        int* csharp2cuda_temp_194 = &((parent)[right]);
                                        (*(csharp2cuda_temp_194) = left);
#line 416 "GraphModule.cs"
#line 416 "GraphModule.cs"
                                        unsigned char* csharp2cuda_temp_195 = &((rank)[left]);
                                        (*(csharp2cuda_temp_195))++;
                                    }
                                }
#line 418 "GraphModule.cs"
#line 418 "GraphModule.cs"
                                int* csharp2cuda_temp_196 = &(selected_count);
#line 418 "GraphModule.cs"
                                int csharp2cuda_temp_197 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_196));
#line 418 "GraphModule.cs"
                                MathBlockGraphKernelEdge* csharp2cuda_temp_198 = &((selected)[csharp2cuda_temp_197]);
#line 418 "GraphModule.cs"
                                MathBlockGraphKernelEdge csharp2cuda_temp_199 = (work)[index];
                                (*(csharp2cuda_temp_198) = csharp2cuda_temp_199);
                            }
                            csharp2cuda_for_continue_15:
#line 403 "GraphModule.cs"
                            int* csharp2cuda_temp_184 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_184));
                        }
                    }
#line 420 "GraphModule.cs"
#line 420 "GraphModule.cs"
                    int* csharp2cuda_temp_200 = &((output)->rows);
                    (*(csharp2cuda_temp_200) = vertex_count);
#line 421 "GraphModule.cs"
#line 421 "GraphModule.cs"
                    int* csharp2cuda_temp_201 = &((output)->count);
                    (*(csharp2cuda_temp_201) = selected_count);
#line 422 "GraphModule.cs"
                    break;
                }
#line 424 "GraphModule.cs"
            case 9:
#line 425 "GraphModule.cs"
                mathblocks_sequence_set_vector_shape(output, vertex_count);
#line 426 "GraphModule.cs"
#line 426 "GraphModule.cs"
                bool csharp2cuda_temp_202;
#line 426 "GraphModule.cs"
                if (!(((vertex_count) <= (0))))
                {
#line 426 "GraphModule.cs"
                    csharp2cuda_temp_202 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 426 "GraphModule.cs"
                    csharp2cuda_temp_202 = true;
                }
                if (csharp2cuda_temp_202)
#line 427 "GraphModule.cs"
                {
#line 428 "GraphModule.cs"
#line 428 "GraphModule.cs"
                    int* csharp2cuda_temp_203 = &((output)->valid);
                    (*(csharp2cuda_temp_203) = 0);
#line 429 "GraphModule.cs"
                    break;
                }
#line 431 "GraphModule.cs"
                {
#line 432 "GraphModule.cs"
                    double damping = (second)->scalar_value;
#line 433 "GraphModule.cs"
                    int iterations = 0;
#line 434 "GraphModule.cs"
#line 434 "GraphModule.cs"
                    bool csharp2cuda_temp_204;
#line 434 "GraphModule.cs"
                    if (!(((damping) < (0.0))))
                    {
#line 434 "GraphModule.cs"
                        csharp2cuda_temp_204 = ((damping) > (1.0));
                    }
                    else
                    {
#line 434 "GraphModule.cs"
                        csharp2cuda_temp_204 = true;
                    }
#line 434 "GraphModule.cs"
                    bool csharp2cuda_temp_205;
#line 434 "GraphModule.cs"
                    if (!(csharp2cuda_temp_204))
                    {
#line 435 "GraphModule.cs"
                        double csharp2cuda_temp_206 = (third)->scalar_value;
#line 435 "GraphModule.cs"
                        int* csharp2cuda_temp_207 = &(iterations);
#line 435 "GraphModule.cs"
                        bool csharp2cuda_temp_208 = mathblocks_sequence_positive_integer(csharp2cuda_temp_206, csharp2cuda_temp_207);
#line 434 "GraphModule.cs"
                        csharp2cuda_temp_205 = (!(csharp2cuda_temp_208));
                    }
                    else
                    {
#line 434 "GraphModule.cs"
                        csharp2cuda_temp_205 = true;
                    }
#line 434 "GraphModule.cs"
                    bool csharp2cuda_temp_209;
#line 434 "GraphModule.cs"
                    if (!(csharp2cuda_temp_205))
                    {
#line 434 "GraphModule.cs"
                        csharp2cuda_temp_209 = ((iterations) > (10000));
                    }
                    else
                    {
#line 434 "GraphModule.cs"
                        csharp2cuda_temp_209 = true;
                    }
                    if (csharp2cuda_temp_209)
#line 437 "GraphModule.cs"
                    {
#line 438 "GraphModule.cs"
#line 438 "GraphModule.cs"
                        int* csharp2cuda_temp_210 = &((output)->valid);
                        (*(csharp2cuda_temp_210) = 0);
#line 439 "GraphModule.cs"
                        break;
                    }
#line 441 "GraphModule.cs"
                    double* outgoing = scratch;
#line 442 "GraphModule.cs"
                    double* next = csharp2cuda_pointer_add(scratch, vertex_count);
#line 443 "GraphModule.cs"
                    {
#line 443 "GraphModule.cs"
                        int vertex = 0;
                        while (true)
                        {
                            if (!(((vertex) < (vertex_count))))
                                break;
#line 444 "GraphModule.cs"
                            {
#line 445 "GraphModule.cs"
#line 445 "GraphModule.cs"
                                double* csharp2cuda_temp_212 = &((result)[vertex]);
#line 445 "GraphModule.cs"
                                double csharp2cuda_temp_213 = __ddiv_rn(1.0, ((double)(vertex_count)));
                                (*(csharp2cuda_temp_212) = csharp2cuda_temp_213);
#line 446 "GraphModule.cs"
#line 446 "GraphModule.cs"
                                double* csharp2cuda_temp_214 = &((outgoing)[vertex]);
                                (*(csharp2cuda_temp_214) = 0.0);
                            }
#line 443 "GraphModule.cs"
                            int* csharp2cuda_temp_211 = &(vertex);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_211));
                        }
                    }
#line 448 "GraphModule.cs"
                    {
#line 448 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 448 "GraphModule.cs"
                            int csharp2cuda_temp_216 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_216))))
                                break;
#line 449 "GraphModule.cs"
                            {
#line 450 "GraphModule.cs"
#line 450 "GraphModule.cs"
                                double csharp2cuda_temp_217 = ((edges)[index]).weight;
                                if (((csharp2cuda_temp_217) < (0.0)))
#line 451 "GraphModule.cs"
                                {
#line 452 "GraphModule.cs"
#line 452 "GraphModule.cs"
                                    int* csharp2cuda_temp_218 = &((output)->valid);
                                    (*(csharp2cuda_temp_218) = 0);
#line 453 "GraphModule.cs"
                                    break;
                                }
#line 455 "GraphModule.cs"
#line 455 "GraphModule.cs"
                                int csharp2cuda_temp_219 = ((edges)[index]).from;
#line 455 "GraphModule.cs"
                                double* csharp2cuda_temp_220 = &((outgoing)[csharp2cuda_temp_219]);
#line 455 "GraphModule.cs"
                                double csharp2cuda_temp_221 = *(csharp2cuda_temp_220);
#line 455 "GraphModule.cs"
                                double csharp2cuda_temp_222 = ((edges)[index]).weight;
                                (*(csharp2cuda_temp_220) = __dadd_rn(csharp2cuda_temp_221, csharp2cuda_temp_222));
                            }
#line 448 "GraphModule.cs"
                            int* csharp2cuda_temp_215 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_215));
                        }
                    }
#line 457 "GraphModule.cs"
                    {
#line 457 "GraphModule.cs"
                        int iteration = 0;
                        while (true)
                        {
#line 457 "GraphModule.cs"
                            bool csharp2cuda_temp_224 = (output)->valid;
#line 457 "GraphModule.cs"
                            bool csharp2cuda_temp_225;
#line 457 "GraphModule.cs"
                            if (csharp2cuda_temp_224)
                            {
#line 457 "GraphModule.cs"
                                csharp2cuda_temp_225 = ((iteration) < (iterations));
                            }
                            else
                            {
#line 457 "GraphModule.cs"
                                csharp2cuda_temp_225 = false;
                            }
                            if (!(csharp2cuda_temp_225))
                                break;
#line 458 "GraphModule.cs"
                            {
#line 459 "GraphModule.cs"
                                {
#line 459 "GraphModule.cs"
                                    int vertex = 0;
                                    while (true)
                                    {
                                        if (!(((vertex) < (vertex_count))))
                                            break;
#line 460 "GraphModule.cs"
#line 460 "GraphModule.cs"
                                        double* csharp2cuda_temp_227 = &((next)[vertex]);
#line 460 "GraphModule.cs"
                                        double csharp2cuda_temp_228 = __ddiv_rn(__dsub_rn(1.0, damping), ((double)(vertex_count)));
                                        (*(csharp2cuda_temp_227) = csharp2cuda_temp_228);
#line 459 "GraphModule.cs"
                                        int* csharp2cuda_temp_226 = &(vertex);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_226));
                                    }
                                }
#line 461 "GraphModule.cs"
                                double dangling = 0.0;
#line 462 "GraphModule.cs"
                                {
#line 462 "GraphModule.cs"
                                    int vertex = 0;
                                    while (true)
                                    {
                                        if (!(((vertex) < (vertex_count))))
                                            break;
#line 463 "GraphModule.cs"
#line 463 "GraphModule.cs"
                                        double csharp2cuda_temp_230 = (outgoing)[vertex];
                                        if (((csharp2cuda_temp_230) == (0.0)))
                                        {
#line 464 "GraphModule.cs"
#line 464 "GraphModule.cs"
                                            double* csharp2cuda_temp_231 = &(dangling);
#line 464 "GraphModule.cs"
                                            double csharp2cuda_temp_232 = *(csharp2cuda_temp_231);
#line 464 "GraphModule.cs"
                                            double csharp2cuda_temp_233 = (result)[vertex];
                                            (*(csharp2cuda_temp_231) = __dadd_rn(csharp2cuda_temp_232, csharp2cuda_temp_233));
                                        }
#line 462 "GraphModule.cs"
                                        int* csharp2cuda_temp_229 = &(vertex);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_229));
                                    }
                                }
#line 465 "GraphModule.cs"
                                double dangling_share = __ddiv_rn(__dmul_rn(damping, dangling), ((double)(vertex_count)));
#line 466 "GraphModule.cs"
                                {
#line 466 "GraphModule.cs"
                                    int vertex = 0;
                                    while (true)
                                    {
                                        if (!(((vertex) < (vertex_count))))
                                            break;
#line 467 "GraphModule.cs"
#line 467 "GraphModule.cs"
                                        double* csharp2cuda_temp_235 = &((next)[vertex]);
#line 467 "GraphModule.cs"
                                        double csharp2cuda_temp_236 = *(csharp2cuda_temp_235);
                                        (*(csharp2cuda_temp_235) = __dadd_rn(csharp2cuda_temp_236, dangling_share));
#line 466 "GraphModule.cs"
                                        int* csharp2cuda_temp_234 = &(vertex);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_234));
                                    }
                                }
#line 468 "GraphModule.cs"
                                {
#line 468 "GraphModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 468 "GraphModule.cs"
                                        int csharp2cuda_temp_238 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_238))))
                                            break;
#line 469 "GraphModule.cs"
#line 469 "GraphModule.cs"
                                        int csharp2cuda_temp_239 = ((edges)[index]).to;
#line 469 "GraphModule.cs"
                                        double* csharp2cuda_temp_240 = &((next)[csharp2cuda_temp_239]);
#line 469 "GraphModule.cs"
                                        double csharp2cuda_temp_241 = *(csharp2cuda_temp_240);
#line 469 "GraphModule.cs"
                                        int csharp2cuda_temp_242 = ((edges)[index]).from;
#line 469 "GraphModule.cs"
                                        double csharp2cuda_temp_243 = (result)[csharp2cuda_temp_242];
#line 470 "GraphModule.cs"
                                        double csharp2cuda_temp_244 = ((edges)[index]).weight;
#line 470 "GraphModule.cs"
                                        int csharp2cuda_temp_245 = ((edges)[index]).from;
#line 470 "GraphModule.cs"
                                        double csharp2cuda_temp_246 = (outgoing)[csharp2cuda_temp_245];
#line 469 "GraphModule.cs"
                                        double csharp2cuda_temp_247 = __ddiv_rn(__dmul_rn(__dmul_rn(damping, csharp2cuda_temp_243), csharp2cuda_temp_244), csharp2cuda_temp_246);
                                        (*(csharp2cuda_temp_240) = __dadd_rn(csharp2cuda_temp_241, csharp2cuda_temp_247));
#line 468 "GraphModule.cs"
                                        int* csharp2cuda_temp_237 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_237));
                                    }
                                }
#line 471 "GraphModule.cs"
                                {
#line 471 "GraphModule.cs"
                                    int vertex = 0;
                                    while (true)
                                    {
                                        if (!(((vertex) < (vertex_count))))
                                            break;
#line 472 "GraphModule.cs"
#line 472 "GraphModule.cs"
                                        double* csharp2cuda_temp_249 = &((result)[vertex]);
#line 472 "GraphModule.cs"
                                        double csharp2cuda_temp_250 = (next)[vertex];
                                        (*(csharp2cuda_temp_249) = csharp2cuda_temp_250);
#line 471 "GraphModule.cs"
                                        int* csharp2cuda_temp_248 = &(vertex);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_248));
                                    }
                                }
                            }
#line 457 "GraphModule.cs"
                            int* csharp2cuda_temp_223 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_223));
                        }
                    }
#line 474 "GraphModule.cs"
                    break;
                }
#line 476 "GraphModule.cs"
            case 10:
            case 12:
            case 13:
#line 479 "GraphModule.cs"
                mathblocks_sequence_set_matrix_shape(output, vertex_count, vertex_count);
#line 480 "GraphModule.cs"
                {
#line 480 "GraphModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (csharp2cuda_i32_mul(vertex_count, vertex_count)))))
                            break;
#line 481 "GraphModule.cs"
#line 481 "GraphModule.cs"
                        double* csharp2cuda_temp_252 = &((result)[index]);
                        (*(csharp2cuda_temp_252) = 0.0);
#line 480 "GraphModule.cs"
                        int* csharp2cuda_temp_251 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_251));
                    }
                }
#line 482 "GraphModule.cs"
                {
#line 482 "GraphModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 482 "GraphModule.cs"
                        int csharp2cuda_temp_254 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_254))))
                            break;
#line 483 "GraphModule.cs"
                        {
#line 484 "GraphModule.cs"
                            int from = ((edges)[index]).from;
#line 485 "GraphModule.cs"
                            int to = ((edges)[index]).to;
#line 486 "GraphModule.cs"
                            double weight = ((edges)[index]).weight;
#line 487 "GraphModule.cs"
                            if (((opcode) == (10)))
#line 488 "GraphModule.cs"
                            {
#line 489 "GraphModule.cs"
#line 489 "GraphModule.cs"
                                double* csharp2cuda_temp_255 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), to)]);
#line 489 "GraphModule.cs"
                                double csharp2cuda_temp_256 = *(csharp2cuda_temp_255);
                                (*(csharp2cuda_temp_255) = __dadd_rn(csharp2cuda_temp_256, weight));
                            }
                            else
                            {
#line 491 "GraphModule.cs"
                                if (((opcode) == (12)))
#line 492 "GraphModule.cs"
                                {
#line 493 "GraphModule.cs"
#line 493 "GraphModule.cs"
                                    double* csharp2cuda_temp_257 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), to)]);
#line 493 "GraphModule.cs"
                                    double csharp2cuda_temp_258 = *(csharp2cuda_temp_257);
                                    (*(csharp2cuda_temp_257) = __dadd_rn(csharp2cuda_temp_258, weight));
#line 494 "GraphModule.cs"
#line 494 "GraphModule.cs"
                                    double* csharp2cuda_temp_259 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), from)]);
#line 494 "GraphModule.cs"
                                    double csharp2cuda_temp_260 = *(csharp2cuda_temp_259);
                                    (*(csharp2cuda_temp_259) = __dadd_rn(csharp2cuda_temp_260, weight));
                                }
                                else
#line 497 "GraphModule.cs"
                                {
#line 498 "GraphModule.cs"
#line 498 "GraphModule.cs"
                                    double* csharp2cuda_temp_261 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), from)]);
#line 498 "GraphModule.cs"
                                    double csharp2cuda_temp_262 = *(csharp2cuda_temp_261);
                                    (*(csharp2cuda_temp_261) = __dadd_rn(csharp2cuda_temp_262, weight));
#line 499 "GraphModule.cs"
#line 499 "GraphModule.cs"
                                    double* csharp2cuda_temp_263 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), to)]);
#line 499 "GraphModule.cs"
                                    double csharp2cuda_temp_264 = *(csharp2cuda_temp_263);
                                    (*(csharp2cuda_temp_263) = __dadd_rn(csharp2cuda_temp_264, weight));
#line 500 "GraphModule.cs"
#line 500 "GraphModule.cs"
                                    double* csharp2cuda_temp_265 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), to)]);
#line 500 "GraphModule.cs"
                                    double csharp2cuda_temp_266 = *(csharp2cuda_temp_265);
                                    (*(csharp2cuda_temp_265) = __dsub_rn(csharp2cuda_temp_266, weight));
#line 501 "GraphModule.cs"
#line 501 "GraphModule.cs"
                                    double* csharp2cuda_temp_267 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), from)]);
#line 501 "GraphModule.cs"
                                    double csharp2cuda_temp_268 = *(csharp2cuda_temp_267);
                                    (*(csharp2cuda_temp_267) = __dsub_rn(csharp2cuda_temp_268, weight));
                                }
                            }
                        }
#line 482 "GraphModule.cs"
                        int* csharp2cuda_temp_253 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_253));
                    }
                }
#line 504 "GraphModule.cs"
                break;
#line 505 "GraphModule.cs"
            case 11:
#line 506 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 507 "GraphModule.cs"
                {
#line 508 "GraphModule.cs"
#line 508 "GraphModule.cs"
                    int* csharp2cuda_temp_269 = &((output)->valid);
                    (*(csharp2cuda_temp_269) = 0);
#line 509 "GraphModule.cs"
                    break;
                }
#line 511 "GraphModule.cs"
                {
#line 512 "GraphModule.cs"
                    int* adjacency = ((int*)(scratch));
#line 513 "GraphModule.cs"
                    {
#line 513 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(vertex_count, vertex_count)))))
                                break;
#line 514 "GraphModule.cs"
#line 514 "GraphModule.cs"
                            int* csharp2cuda_temp_271 = &((adjacency)[index]);
                            (*(csharp2cuda_temp_271) = 0);
#line 513 "GraphModule.cs"
                            int* csharp2cuda_temp_270 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_270));
                        }
                    }
#line 515 "GraphModule.cs"
                    {
#line 515 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 515 "GraphModule.cs"
                            int csharp2cuda_temp_273 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_273))))
                                break;
#line 516 "GraphModule.cs"
                            {
#line 517 "GraphModule.cs"
#line 517 "GraphModule.cs"
                                int csharp2cuda_temp_274 = ((edges)[index]).from;
#line 517 "GraphModule.cs"
                                int csharp2cuda_temp_275 = ((edges)[index]).to;
#line 517 "GraphModule.cs"
                                int* csharp2cuda_temp_276 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_temp_274, vertex_count), csharp2cuda_temp_275)]);
                                (*(csharp2cuda_temp_276) = 1);
#line 518 "GraphModule.cs"
#line 518 "GraphModule.cs"
                                int csharp2cuda_temp_277 = ((edges)[index]).to;
#line 518 "GraphModule.cs"
                                int csharp2cuda_temp_278 = ((edges)[index]).from;
#line 518 "GraphModule.cs"
                                int* csharp2cuda_temp_279 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_temp_277, vertex_count), csharp2cuda_temp_278)]);
                                (*(csharp2cuda_temp_279) = 1);
                            }
#line 515 "GraphModule.cs"
                            int* csharp2cuda_temp_272 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_272));
                        }
                    }
#line 520 "GraphModule.cs"
                    int count = 0;
#line 521 "GraphModule.cs"
                    {
#line 521 "GraphModule.cs"
                        int one = 0;
                        while (true)
                        {
                            if (!(((one) < (vertex_count))))
                                break;
#line 522 "GraphModule.cs"
                            {
#line 522 "GraphModule.cs"
                                int two = csharp2cuda_i32_add(one, 1);
                                while (true)
                                {
                                    if (!(((two) < (vertex_count))))
                                        break;
#line 523 "GraphModule.cs"
                                    {
#line 523 "GraphModule.cs"
                                        int three = csharp2cuda_i32_add(two, 1);
                                        while (true)
                                        {
                                            if (!(((three) < (vertex_count))))
                                                break;
#line 524 "GraphModule.cs"
#line 524 "GraphModule.cs"
                                            int csharp2cuda_temp_283 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(one, vertex_count), two)];
#line 524 "GraphModule.cs"
                                            bool csharp2cuda_temp_284;
#line 524 "GraphModule.cs"
                                            if (((csharp2cuda_temp_283) != 0))
                                            {
#line 525 "GraphModule.cs"
                                                int csharp2cuda_temp_285 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(one, vertex_count), three)];
#line 524 "GraphModule.cs"
                                                csharp2cuda_temp_284 = ((csharp2cuda_temp_285) != 0);
                                            }
                                            else
                                            {
#line 524 "GraphModule.cs"
                                                csharp2cuda_temp_284 = false;
                                            }
#line 524 "GraphModule.cs"
                                            bool csharp2cuda_temp_286;
#line 524 "GraphModule.cs"
                                            if (csharp2cuda_temp_284)
                                            {
#line 526 "GraphModule.cs"
                                                int csharp2cuda_temp_287 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(two, vertex_count), three)];
#line 524 "GraphModule.cs"
                                                csharp2cuda_temp_286 = ((csharp2cuda_temp_287) != 0);
                                            }
                                            else
                                            {
#line 524 "GraphModule.cs"
                                                csharp2cuda_temp_286 = false;
                                            }
                                            if (csharp2cuda_temp_286)
#line 527 "GraphModule.cs"
                                            {
#line 528 "GraphModule.cs"
#line 528 "GraphModule.cs"
                                                int* csharp2cuda_temp_288 = &(count);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_288));
                                            }
#line 523 "GraphModule.cs"
                                            int* csharp2cuda_temp_282 = &(three);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_282));
                                        }
                                    }
#line 522 "GraphModule.cs"
                                    int* csharp2cuda_temp_281 = &(two);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_281));
                                }
                            }
#line 521 "GraphModule.cs"
                            int* csharp2cuda_temp_280 = &(one);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_280));
                        }
                    }
#line 530 "GraphModule.cs"
#line 530 "GraphModule.cs"
                    double* csharp2cuda_temp_289 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_289) = ((double)(count)));
#line 531 "GraphModule.cs"
                    break;
                }
#line 533 "GraphModule.cs"
            case 14:
#line 534 "GraphModule.cs"
                mathblocks_sequence_set_vector_shape(output, vertex_count);
#line 535 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 536 "GraphModule.cs"
                {
#line 537 "GraphModule.cs"
#line 537 "GraphModule.cs"
                    int* csharp2cuda_temp_290 = &((output)->valid);
                    (*(csharp2cuda_temp_290) = 0);
#line 538 "GraphModule.cs"
                    break;
                }
#line 540 "GraphModule.cs"
                {
#line 541 "GraphModule.cs"
                    int source = 0;
#line 542 "GraphModule.cs"
#line 542 "GraphModule.cs"
                    double csharp2cuda_temp_291 = (second)->scalar_value;
#line 542 "GraphModule.cs"
                    int* csharp2cuda_temp_292 = &(source);
#line 542 "GraphModule.cs"
                    bool csharp2cuda_temp_293 = mathblocks_nonnegative_integer(csharp2cuda_temp_291, csharp2cuda_temp_292);
#line 542 "GraphModule.cs"
                    bool csharp2cuda_temp_294;
#line 542 "GraphModule.cs"
                    if (!((!(csharp2cuda_temp_293))))
                    {
#line 542 "GraphModule.cs"
                        csharp2cuda_temp_294 = ((source) >= (vertex_count));
                    }
                    else
                    {
#line 542 "GraphModule.cs"
                        csharp2cuda_temp_294 = true;
                    }
                    if (csharp2cuda_temp_294)
#line 543 "GraphModule.cs"
                    {
#line 544 "GraphModule.cs"
#line 544 "GraphModule.cs"
                        int* csharp2cuda_temp_295 = &((output)->valid);
                        (*(csharp2cuda_temp_295) = 0);
#line 545 "GraphModule.cs"
                        break;
                    }
#line 547 "GraphModule.cs"
                    int* visited = ((int*)(scratch));
#line 548 "GraphModule.cs"
                    {
#line 548 "GraphModule.cs"
                        int vertex = 0;
                        while (true)
                        {
                            if (!(((vertex) < (vertex_count))))
                                break;
#line 549 "GraphModule.cs"
                            {
#line 550 "GraphModule.cs"
#line 550 "GraphModule.cs"
                                double* csharp2cuda_temp_297 = &((result)[vertex]);
                                (*(csharp2cuda_temp_297) = mathblocks_positive_infinity());
#line 551 "GraphModule.cs"
#line 551 "GraphModule.cs"
                                int* csharp2cuda_temp_298 = &((visited)[vertex]);
                                (*(csharp2cuda_temp_298) = 0);
                            }
#line 548 "GraphModule.cs"
                            int* csharp2cuda_temp_296 = &(vertex);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_296));
                        }
                    }
#line 553 "GraphModule.cs"
#line 553 "GraphModule.cs"
                    double* csharp2cuda_temp_299 = &((result)[source]);
                    (*(csharp2cuda_temp_299) = 0.0);
#line 554 "GraphModule.cs"
                    {
#line 554 "GraphModule.cs"
                        int iteration = 0;
                        while (true)
                        {
                            if (!(((iteration) < (vertex_count))))
                                break;
#line 555 "GraphModule.cs"
                            {
#line 556 "GraphModule.cs"
                                int vertex = -1;
#line 557 "GraphModule.cs"
                                double best = mathblocks_positive_infinity();
#line 558 "GraphModule.cs"
                                {
#line 558 "GraphModule.cs"
                                    int candidate = 0;
                                    while (true)
                                    {
                                        if (!(((candidate) < (vertex_count))))
                                            break;
#line 559 "GraphModule.cs"
#line 559 "GraphModule.cs"
                                        int csharp2cuda_temp_302 = (visited)[candidate];
#line 559 "GraphModule.cs"
                                        bool csharp2cuda_temp_303;
#line 559 "GraphModule.cs"
                                        if ((!(((csharp2cuda_temp_302) != 0))))
                                        {
#line 559 "GraphModule.cs"
                                            double csharp2cuda_temp_304 = (result)[candidate];
#line 559 "GraphModule.cs"
                                            csharp2cuda_temp_303 = ((csharp2cuda_temp_304) < (best));
                                        }
                                        else
                                        {
#line 559 "GraphModule.cs"
                                            csharp2cuda_temp_303 = false;
                                        }
                                        if (csharp2cuda_temp_303)
#line 560 "GraphModule.cs"
                                        {
#line 561 "GraphModule.cs"
#line 561 "GraphModule.cs"
                                            double* csharp2cuda_temp_305 = &(best);
#line 561 "GraphModule.cs"
                                            double csharp2cuda_temp_306 = (result)[candidate];
                                            (*(csharp2cuda_temp_305) = csharp2cuda_temp_306);
#line 562 "GraphModule.cs"
#line 562 "GraphModule.cs"
                                            int* csharp2cuda_temp_307 = &(vertex);
                                            (*(csharp2cuda_temp_307) = candidate);
                                        }
#line 558 "GraphModule.cs"
                                        int* csharp2cuda_temp_301 = &(candidate);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_301));
                                    }
                                }
#line 564 "GraphModule.cs"
                                if (((vertex) < (0)))
                                {
#line 565 "GraphModule.cs"
                                    break;
                                }
#line 566 "GraphModule.cs"
#line 566 "GraphModule.cs"
                                int* csharp2cuda_temp_308 = &((visited)[vertex]);
                                (*(csharp2cuda_temp_308) = 1);
#line 567 "GraphModule.cs"
                                {
#line 567 "GraphModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 567 "GraphModule.cs"
                                        int csharp2cuda_temp_310 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_310))))
                                            break;
#line 568 "GraphModule.cs"
                                        {
#line 569 "GraphModule.cs"
#line 569 "GraphModule.cs"
                                            double csharp2cuda_temp_311 = ((edges)[index]).weight;
                                            if (((csharp2cuda_temp_311) < (0.0)))
#line 570 "GraphModule.cs"
                                            {
#line 571 "GraphModule.cs"
#line 571 "GraphModule.cs"
                                                int* csharp2cuda_temp_312 = &((output)->valid);
                                                (*(csharp2cuda_temp_312) = 0);
#line 572 "GraphModule.cs"
                                                break;
                                            }
#line 574 "GraphModule.cs"
                                            int csharp2cuda_temp_313 = ((edges)[index]).from;
#line 574 "GraphModule.cs"
                                            int csharp2cuda_temp_314;
#line 574 "GraphModule.cs"
                                            if (((csharp2cuda_temp_313) == (vertex)))
                                            {
#line 574 "GraphModule.cs"
                                                csharp2cuda_temp_314 = ((edges)[index]).to;
                                            }
                                            else
                                            {
#line 576 "GraphModule.cs"
                                                int csharp2cuda_temp_315 = ((edges)[index]).to;
#line 576 "GraphModule.cs"
                                                int csharp2cuda_temp_316;
#line 576 "GraphModule.cs"
                                                if (((csharp2cuda_temp_315) == (vertex)))
                                                {
#line 576 "GraphModule.cs"
                                                    csharp2cuda_temp_316 = ((edges)[index]).from;
                                                }
                                                else
                                                {
#line 576 "GraphModule.cs"
                                                    csharp2cuda_temp_316 = csharp2cuda_i32_neg(1);
                                                }
#line 574 "GraphModule.cs"
                                                csharp2cuda_temp_314 = csharp2cuda_temp_316;
                                            }
#line 574 "GraphModule.cs"
                                            int neighbor = csharp2cuda_temp_314;
#line 579 "GraphModule.cs"
                                            if (((neighbor) < (0)))
                                            {
#line 580 "GraphModule.cs"
                                                goto csharp2cuda_for_continue_33;
                                            }
#line 581 "GraphModule.cs"
                                            double csharp2cuda_temp_317 = (result)[vertex];
#line 581 "GraphModule.cs"
                                            double csharp2cuda_temp_318 = ((edges)[index]).weight;
#line 581 "GraphModule.cs"
                                            double candidate = __dadd_rn(csharp2cuda_temp_317, csharp2cuda_temp_318);
#line 582 "GraphModule.cs"
#line 582 "GraphModule.cs"
                                            double* csharp2cuda_temp_319 = &((result)[neighbor]);
#line 582 "GraphModule.cs"
                                            double csharp2cuda_temp_320 = (result)[neighbor];
#line 582 "GraphModule.cs"
                                            double csharp2cuda_temp_321;
#line 582 "GraphModule.cs"
                                            if (((csharp2cuda_temp_320) < (candidate)))
                                            {
#line 582 "GraphModule.cs"
                                                csharp2cuda_temp_321 = (result)[neighbor];
                                            }
                                            else
                                            {
#line 582 "GraphModule.cs"
                                                csharp2cuda_temp_321 = candidate;
                                            }
                                            (*(csharp2cuda_temp_319) = csharp2cuda_temp_321);
                                        }
                                        csharp2cuda_for_continue_33:
#line 567 "GraphModule.cs"
                                        int* csharp2cuda_temp_309 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_309));
                                    }
                                }
                            }
#line 554 "GraphModule.cs"
                            int* csharp2cuda_temp_300 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_300));
                        }
                    }
#line 587 "GraphModule.cs"
                    break;
                }
        }
#line 591 "GraphModule.cs"
#line 591 "GraphModule.cs"
        bool csharp2cuda_temp_322 = (output)->valid;
#line 591 "GraphModule.cs"
        bool csharp2cuda_temp_323;
#line 591 "GraphModule.cs"
        if (csharp2cuda_temp_322)
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_323 = ((opcode) != (3));
        }
        else
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_323 = false;
        }
#line 591 "GraphModule.cs"
        bool csharp2cuda_temp_324;
#line 591 "GraphModule.cs"
        if (csharp2cuda_temp_323)
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_324 = ((opcode) != (4));
        }
        else
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_324 = false;
        }
#line 591 "GraphModule.cs"
        bool csharp2cuda_temp_325;
#line 591 "GraphModule.cs"
        if (csharp2cuda_temp_324)
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_325 = ((opcode) != (5));
        }
        else
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_325 = false;
        }
#line 591 "GraphModule.cs"
        bool csharp2cuda_temp_326;
#line 591 "GraphModule.cs"
        if (csharp2cuda_temp_325)
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_326 = ((opcode) != (7));
        }
        else
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_326 = false;
        }
#line 591 "GraphModule.cs"
        bool csharp2cuda_temp_327;
#line 591 "GraphModule.cs"
        if (csharp2cuda_temp_326)
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_327 = ((opcode) != (8));
        }
        else
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_327 = false;
        }
#line 591 "GraphModule.cs"
        bool csharp2cuda_temp_328;
#line 591 "GraphModule.cs"
        if (csharp2cuda_temp_327)
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_328 = ((opcode) != (9));
        }
        else
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_328 = false;
        }
#line 591 "GraphModule.cs"
        bool csharp2cuda_temp_329;
#line 591 "GraphModule.cs"
        if (csharp2cuda_temp_328)
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_329 = ((opcode) != (10));
        }
        else
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_329 = false;
        }
#line 591 "GraphModule.cs"
        bool csharp2cuda_temp_330;
#line 591 "GraphModule.cs"
        if (csharp2cuda_temp_329)
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_330 = ((opcode) != (12));
        }
        else
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_330 = false;
        }
#line 591 "GraphModule.cs"
        bool csharp2cuda_temp_331;
#line 591 "GraphModule.cs"
        if (csharp2cuda_temp_330)
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_331 = ((opcode) != (13));
        }
        else
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_331 = false;
        }
#line 591 "GraphModule.cs"
        bool csharp2cuda_temp_332;
#line 591 "GraphModule.cs"
        if (csharp2cuda_temp_331)
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_332 = ((opcode) != (14));
        }
        else
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_332 = false;
        }
#line 591 "GraphModule.cs"
        bool csharp2cuda_temp_333;
#line 591 "GraphModule.cs"
        if (csharp2cuda_temp_332)
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_333 = ((opcode) != (15));
        }
        else
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_333 = false;
        }
#line 591 "GraphModule.cs"
        bool csharp2cuda_temp_334;
#line 591 "GraphModule.cs"
        if (csharp2cuda_temp_333)
        {
#line 594 "GraphModule.cs"
            double csharp2cuda_temp_335 = (output)->scalar_value;
#line 591 "GraphModule.cs"
            csharp2cuda_temp_334 = (!(isfinite(csharp2cuda_temp_335)));
        }
        else
        {
#line 591 "GraphModule.cs"
            csharp2cuda_temp_334 = false;
        }
        if (csharp2cuda_temp_334)
#line 595 "GraphModule.cs"
        {
#line 596 "GraphModule.cs"
#line 596 "GraphModule.cs"
            int* csharp2cuda_temp_336 = &((output)->valid);
            (*(csharp2cuda_temp_336) = 0);
        }
#line 598 "GraphModule.cs"
#line 598 "GraphModule.cs"
        bool csharp2cuda_temp_337 = (output)->valid;
#line 598 "GraphModule.cs"
        bool csharp2cuda_temp_338;
#line 598 "GraphModule.cs"
        if (csharp2cuda_temp_337)
        {
#line 599 "GraphModule.cs"
            bool csharp2cuda_temp_339;
#line 599 "GraphModule.cs"
            if (!(((opcode) == (3))))
            {
#line 599 "GraphModule.cs"
                csharp2cuda_temp_339 = ((opcode) == (5));
            }
            else
            {
#line 599 "GraphModule.cs"
                csharp2cuda_temp_339 = true;
            }
#line 599 "GraphModule.cs"
            bool csharp2cuda_temp_340;
#line 599 "GraphModule.cs"
            if (!(csharp2cuda_temp_339))
            {
#line 599 "GraphModule.cs"
                csharp2cuda_temp_340 = ((opcode) == (9));
            }
            else
            {
#line 599 "GraphModule.cs"
                csharp2cuda_temp_340 = true;
            }
#line 599 "GraphModule.cs"
            bool csharp2cuda_temp_341;
#line 599 "GraphModule.cs"
            if (!(csharp2cuda_temp_340))
            {
#line 599 "GraphModule.cs"
                csharp2cuda_temp_341 = ((opcode) == (10));
            }
            else
            {
#line 599 "GraphModule.cs"
                csharp2cuda_temp_341 = true;
            }
#line 599 "GraphModule.cs"
            bool csharp2cuda_temp_342;
#line 599 "GraphModule.cs"
            if (!(csharp2cuda_temp_341))
            {
#line 599 "GraphModule.cs"
                csharp2cuda_temp_342 = ((opcode) == (12));
            }
            else
            {
#line 599 "GraphModule.cs"
                csharp2cuda_temp_342 = true;
            }
#line 599 "GraphModule.cs"
            bool csharp2cuda_temp_343;
#line 599 "GraphModule.cs"
            if (!(csharp2cuda_temp_342))
            {
#line 599 "GraphModule.cs"
                csharp2cuda_temp_343 = ((opcode) == (13));
            }
            else
            {
#line 599 "GraphModule.cs"
                csharp2cuda_temp_343 = true;
            }
#line 599 "GraphModule.cs"
            bool csharp2cuda_temp_344;
#line 599 "GraphModule.cs"
            if (!(csharp2cuda_temp_343))
            {
#line 599 "GraphModule.cs"
                csharp2cuda_temp_344 = ((opcode) == (14));
            }
            else
            {
#line 599 "GraphModule.cs"
                csharp2cuda_temp_344 = true;
            }
#line 599 "GraphModule.cs"
            bool csharp2cuda_temp_345;
#line 599 "GraphModule.cs"
            if (!(csharp2cuda_temp_344))
            {
#line 599 "GraphModule.cs"
                csharp2cuda_temp_345 = ((opcode) == (15));
            }
            else
            {
#line 599 "GraphModule.cs"
                csharp2cuda_temp_345 = true;
            }
#line 598 "GraphModule.cs"
            csharp2cuda_temp_338 = csharp2cuda_temp_345;
        }
        else
        {
#line 598 "GraphModule.cs"
            csharp2cuda_temp_338 = false;
        }
        if (csharp2cuda_temp_338)
#line 601 "GraphModule.cs"
        {
#line 602 "GraphModule.cs"
            {
#line 602 "GraphModule.cs"
                int index = 0;
                while (true)
                {
#line 602 "GraphModule.cs"
                    int csharp2cuda_temp_347 = (output)->count;
                    if (!(((index) < (csharp2cuda_temp_347))))
                        break;
#line 603 "GraphModule.cs"
#line 603 "GraphModule.cs"
                    double csharp2cuda_temp_348 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_348))))
                    {
#line 603 "GraphModule.cs"
#line 603 "GraphModule.cs"
                        int* csharp2cuda_temp_349 = &((output)->valid);
                        (*(csharp2cuda_temp_349) = 0);
                    }
#line 602 "GraphModule.cs"
                    int* csharp2cuda_temp_346 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_346));
                }
            }
        }
    }
}

#line 93 "GraphModule.cs"
__device__ bool mathblocks_graph_edge_less(
    const MathBlockGraphKernelEdge* left,
    const MathBlockGraphKernelEdge* right)
#line 97 "GraphModule.cs"
{
#line 98 "GraphModule.cs"
#line 98 "GraphModule.cs"
    double csharp2cuda_temp_0 = (*(left)).weight;
#line 98 "GraphModule.cs"
    double csharp2cuda_temp_1 = (*(right)).weight;
    if (((csharp2cuda_temp_0) < (csharp2cuda_temp_1)))
    {
#line 99 "GraphModule.cs"
        return true;
    }
#line 100 "GraphModule.cs"
#line 100 "GraphModule.cs"
    double csharp2cuda_temp_2 = (*(right)).weight;
#line 100 "GraphModule.cs"
    double csharp2cuda_temp_3 = (*(left)).weight;
    if (((csharp2cuda_temp_2) < (csharp2cuda_temp_3)))
    {
#line 101 "GraphModule.cs"
        return false;
    }
#line 102 "GraphModule.cs"
#line 102 "GraphModule.cs"
    int csharp2cuda_temp_4 = (*(left)).from;
#line 102 "GraphModule.cs"
    int csharp2cuda_temp_5 = (*(right)).from;
    if (((csharp2cuda_temp_4) < (csharp2cuda_temp_5)))
    {
#line 103 "GraphModule.cs"
        return true;
    }
#line 104 "GraphModule.cs"
#line 104 "GraphModule.cs"
    int csharp2cuda_temp_6 = (*(right)).from;
#line 104 "GraphModule.cs"
    int csharp2cuda_temp_7 = (*(left)).from;
    if (((csharp2cuda_temp_6) < (csharp2cuda_temp_7)))
    {
#line 105 "GraphModule.cs"
        return false;
    }
#line 106 "GraphModule.cs"
#line 106 "GraphModule.cs"
    int csharp2cuda_temp_8 = (*(left)).to;
#line 106 "GraphModule.cs"
    int csharp2cuda_temp_9 = (*(right)).to;
    return ((csharp2cuda_temp_8) < (csharp2cuda_temp_9));
}

#line 109 "GraphModule.cs"
__device__ int mathblocks_graph_find(int* parent, int vertex)
#line 111 "GraphModule.cs"
{
#line 112 "GraphModule.cs"
    while (true)
    {
#line 112 "GraphModule.cs"
        int csharp2cuda_temp_0 = (parent)[vertex];
        if (!(((csharp2cuda_temp_0) != (vertex))))
            break;
#line 113 "GraphModule.cs"
        {
#line 114 "GraphModule.cs"
#line 114 "GraphModule.cs"
            int* csharp2cuda_temp_1 = &((parent)[vertex]);
#line 114 "GraphModule.cs"
            int csharp2cuda_temp_2 = (parent)[vertex];
#line 114 "GraphModule.cs"
            int csharp2cuda_temp_3 = (parent)[csharp2cuda_temp_2];
            (*(csharp2cuda_temp_1) = csharp2cuda_temp_3);
#line 115 "GraphModule.cs"
#line 115 "GraphModule.cs"
            int* csharp2cuda_temp_4 = &(vertex);
#line 115 "GraphModule.cs"
            int csharp2cuda_temp_5 = (parent)[vertex];
            (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
        }
    }
#line 117 "GraphModule.cs"
    return vertex;
}