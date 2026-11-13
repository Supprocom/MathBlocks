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

#line 94 "MatrixModule.cs"
__device__ bool mathblocks_matrix_compatible(
    const MathBlockSlot* left,
    const MathBlockSlot* right);

#line 102 "MatrixModule.cs"
__device__ void mathblocks_matrix_copy(const double* source, double* destination, int count);

#line 126 "MatrixModule.cs"
__device__ double mathblocks_matrix_determinant(
    const double* source,
    int size,
    double* work);

#line 474 "MatrixModule.cs"
__device__ void mathblocks_matrix_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 271 "MatrixModule.cs"
__device__ bool mathblocks_matrix_is_positive_definite(
    const double* values,
    int size,
    double* lower);

#line 259 "MatrixModule.cs"
__device__ bool mathblocks_matrix_is_symmetric(const double* values, int rows, int columns);

#line 416 "MatrixModule.cs"
__device__ void mathblocks_matrix_multiply_square(
    const double* left,
    const double* right,
    int size,
    double* destination);

#line 382 "MatrixModule.cs"
__device__ int mathblocks_matrix_rank(const double* source, int rows, int columns, double* work);

#line 83 "MatrixModule.cs"
__device__ void mathblocks_matrix_shape(MathBlockSlot* output, int rows, int columns);

#line 447 "MatrixModule.cs"
__device__ void mathblocks_matrix_submatrix_from_masks(
    const double* source,
    int source_columns,
    int row_mask,
    int column_mask,
    int order,
    double* destination);

#line 109 "MatrixModule.cs"
__device__ void mathblocks_matrix_swap_rows(
    double* values,
    int columns,
    int left,
    int right);

#line 306 "MatrixModule.cs"
__device__ bool mathblocks_matrix_symmetric_eigenvalues(
    const double* source,
    int size,
    double* work,
    double* eigenvalues,
    double* buffer);

#line 159 "MatrixModule.cs"
__device__ bool mathblocks_matrix_try_solve(
    const double* matrix,
    const double* right,
    int size,
    double* augmented,
    double* solution);

#line 209 "MatrixModule.cs"
__device__ bool mathblocks_matrix_try_solve_basis(
    const double* matrix,
    int size,
    int basis,
    double* augmented,
    double* solution);

#line 435 "MatrixModule.cs"
__device__ int mathblocks_pop_count(int value);

#line 94 "MatrixModule.cs"
__device__ bool mathblocks_matrix_compatible(
    const MathBlockSlot* left,
    const MathBlockSlot* right)
#line 98 "MatrixModule.cs"
{
#line 99 "MatrixModule.cs"
#line 99 "MatrixModule.cs"
    int csharp2cuda_temp_0 = (left)->rows;
#line 99 "MatrixModule.cs"
    int csharp2cuda_temp_1 = (right)->rows;
#line 99 "MatrixModule.cs"
    bool csharp2cuda_temp_2;
#line 99 "MatrixModule.cs"
    if (((csharp2cuda_temp_0) == (csharp2cuda_temp_1)))
    {
#line 99 "MatrixModule.cs"
        int csharp2cuda_temp_3 = (left)->columns;
#line 99 "MatrixModule.cs"
        int csharp2cuda_temp_4 = (right)->columns;
#line 99 "MatrixModule.cs"
        csharp2cuda_temp_2 = ((csharp2cuda_temp_3) == (csharp2cuda_temp_4));
    }
    else
    {
#line 99 "MatrixModule.cs"
        csharp2cuda_temp_2 = false;
    }
    return csharp2cuda_temp_2;
}

#line 102 "MatrixModule.cs"
__device__ void mathblocks_matrix_copy(const double* source, double* destination, int count)
#line 104 "MatrixModule.cs"
{
#line 105 "MatrixModule.cs"
    {
#line 105 "MatrixModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 106 "MatrixModule.cs"
#line 106 "MatrixModule.cs"
            double* csharp2cuda_temp_1 = &((destination)[index]);
#line 106 "MatrixModule.cs"
            double csharp2cuda_temp_2 = (source)[index];
            (*(csharp2cuda_temp_1) = csharp2cuda_temp_2);
#line 105 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 126 "MatrixModule.cs"
__device__ double mathblocks_matrix_determinant(
    const double* source,
    int size,
    double* work)
#line 131 "MatrixModule.cs"
{
#line 132 "MatrixModule.cs"
    mathblocks_matrix_copy(source, work, csharp2cuda_i32_mul(size, size));
#line 133 "MatrixModule.cs"
    double determinant = 1.0;
#line 134 "MatrixModule.cs"
    {
#line 134 "MatrixModule.cs"
        int pivot = 0;
        while (true)
        {
            if (!(((pivot) < (size))))
                break;
#line 135 "MatrixModule.cs"
            {
#line 136 "MatrixModule.cs"
                int pivot_row = pivot;
#line 137 "MatrixModule.cs"
                {
#line 137 "MatrixModule.cs"
                    int row = csharp2cuda_i32_add(pivot, 1);
                    while (true)
                    {
                        if (!(((row) < (size))))
                            break;
#line 138 "MatrixModule.cs"
#line 138 "MatrixModule.cs"
                        double csharp2cuda_temp_2 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), pivot)];
#line 138 "MatrixModule.cs"
                        double csharp2cuda_temp_3 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot)];
                        if (((fabs(csharp2cuda_temp_2)) > (fabs(csharp2cuda_temp_3))))
                        {
#line 139 "MatrixModule.cs"
#line 139 "MatrixModule.cs"
                            int* csharp2cuda_temp_4 = &(pivot_row);
                            (*(csharp2cuda_temp_4) = row);
                        }
#line 137 "MatrixModule.cs"
                        int* csharp2cuda_temp_1 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 140 "MatrixModule.cs"
#line 140 "MatrixModule.cs"
                double csharp2cuda_temp_5 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot)];
                if (((csharp2cuda_temp_5) == (0.0)))
                {
#line 141 "MatrixModule.cs"
                    return 0.0;
                }
#line 142 "MatrixModule.cs"
                if (((pivot_row) != (pivot)))
#line 143 "MatrixModule.cs"
                {
#line 144 "MatrixModule.cs"
                    mathblocks_matrix_swap_rows(work, size, pivot, pivot_row);
#line 145 "MatrixModule.cs"
#line 145 "MatrixModule.cs"
                    double* csharp2cuda_temp_6 = &(determinant);
                    (*(csharp2cuda_temp_6) = (-(determinant)));
                }
#line 147 "MatrixModule.cs"
                double diagonal = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, size), pivot)];
#line 148 "MatrixModule.cs"
#line 148 "MatrixModule.cs"
                double* csharp2cuda_temp_7 = &(determinant);
#line 148 "MatrixModule.cs"
                double csharp2cuda_temp_8 = *(csharp2cuda_temp_7);
                (*(csharp2cuda_temp_7) = __dmul_rn(csharp2cuda_temp_8, diagonal));
#line 149 "MatrixModule.cs"
                {
#line 149 "MatrixModule.cs"
                    int row = csharp2cuda_i32_add(pivot, 1);
                    while (true)
                    {
                        if (!(((row) < (size))))
                            break;
#line 150 "MatrixModule.cs"
                        {
#line 151 "MatrixModule.cs"
                            double csharp2cuda_temp_10 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), pivot)];
#line 151 "MatrixModule.cs"
                            double scale = __ddiv_rn(csharp2cuda_temp_10, diagonal);
#line 152 "MatrixModule.cs"
                            {
#line 152 "MatrixModule.cs"
                                int column = csharp2cuda_i32_add(pivot, 1);
                                while (true)
                                {
                                    if (!(((column) < (size))))
                                        break;
#line 153 "MatrixModule.cs"
#line 153 "MatrixModule.cs"
                                    double* csharp2cuda_temp_12 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)]);
#line 153 "MatrixModule.cs"
                                    double csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
#line 153 "MatrixModule.cs"
                                    double csharp2cuda_temp_14 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, size), column)];
                                    (*(csharp2cuda_temp_12) = __dsub_rn(csharp2cuda_temp_13, __dmul_rn(scale, csharp2cuda_temp_14)));
#line 152 "MatrixModule.cs"
                                    int* csharp2cuda_temp_11 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_11));
                                }
                            }
                        }
#line 149 "MatrixModule.cs"
                        int* csharp2cuda_temp_9 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
                    }
                }
            }
#line 134 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(pivot);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 156 "MatrixModule.cs"
    return determinant;
}

#line 474 "MatrixModule.cs"
__device__ void mathblocks_matrix_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 480 "MatrixModule.cs"
{
#line 481 "MatrixModule.cs"
    int thread = threadIdx.x;
#line 482 "MatrixModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 482 "MatrixModule.cs"
    if (((input_count) > (0)))
    {
#line 482 "MatrixModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 482 "MatrixModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 482 "MatrixModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 483 "MatrixModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 483 "MatrixModule.cs"
    if (((input_count) > (1)))
    {
#line 483 "MatrixModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 483 "MatrixModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 483 "MatrixModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 484 "MatrixModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 484 "MatrixModule.cs"
    if (((input_count) > (2)))
    {
#line 484 "MatrixModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 484 "MatrixModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 484 "MatrixModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 485 "MatrixModule.cs"
    if (((thread) == (0)))
#line 486 "MatrixModule.cs"
    {
#line 487 "MatrixModule.cs"
#line 487 "MatrixModule.cs"
        double* csharp2cuda_temp_3 = &((output)->scalar_value);
        (*(csharp2cuda_temp_3) = 0.0);
#line 488 "MatrixModule.cs"
#line 488 "MatrixModule.cs"
        int* csharp2cuda_temp_4 = &((output)->boolean_value);
        (*(csharp2cuda_temp_4) = 0);
#line 489 "MatrixModule.cs"
#line 489 "MatrixModule.cs"
        int* csharp2cuda_temp_5 = &((output)->rows);
        (*(csharp2cuda_temp_5) = 0);
#line 490 "MatrixModule.cs"
#line 490 "MatrixModule.cs"
        int* csharp2cuda_temp_6 = &((output)->columns);
        (*(csharp2cuda_temp_6) = 0);
#line 491 "MatrixModule.cs"
#line 491 "MatrixModule.cs"
        int* csharp2cuda_temp_7 = &((output)->count);
        (*(csharp2cuda_temp_7) = 0);
#line 492 "MatrixModule.cs"
#line 492 "MatrixModule.cs"
        int* csharp2cuda_temp_8 = &((output)->valid);
        (*(csharp2cuda_temp_8) = 1);
#line 493 "MatrixModule.cs"
        {
#line 493 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 494 "MatrixModule.cs"
#line 494 "MatrixModule.cs"
                MathBlockSlot* csharp2cuda_temp_10 = (inputs)[index];
#line 494 "MatrixModule.cs"
                bool csharp2cuda_temp_11;
#line 494 "MatrixModule.cs"
                if (!(((((void*)(csharp2cuda_temp_10))) == (((void*)(nullptr))))))
                {
#line 494 "MatrixModule.cs"
                    MathBlockSlot* csharp2cuda_temp_12 = (inputs)[index];
#line 494 "MatrixModule.cs"
                    bool csharp2cuda_temp_13 = (csharp2cuda_temp_12)->valid;
#line 494 "MatrixModule.cs"
                    csharp2cuda_temp_11 = (!(csharp2cuda_temp_13));
                }
                else
                {
#line 494 "MatrixModule.cs"
                    csharp2cuda_temp_11 = true;
                }
                if (csharp2cuda_temp_11)
                {
#line 494 "MatrixModule.cs"
#line 494 "MatrixModule.cs"
                    int* csharp2cuda_temp_14 = &((output)->valid);
                    (*(csharp2cuda_temp_14) = 0);
                }
#line 493 "MatrixModule.cs"
                int* csharp2cuda_temp_9 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
            }
        }
    }
#line 496 "MatrixModule.cs"
    __syncthreads();
#line 497 "MatrixModule.cs"
#line 497 "MatrixModule.cs"
    bool csharp2cuda_temp_15 = (output)->valid;
    if ((!(csharp2cuda_temp_15)))
    {
#line 498 "MatrixModule.cs"
        return;
    }
#line 500 "MatrixModule.cs"
    double* csharp2cuda_temp_16;
#line 500 "MatrixModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 500 "MatrixModule.cs"
        csharp2cuda_temp_16 = ((double*)(nullptr));
    }
    else
    {
#line 500 "MatrixModule.cs"
        unsigned long long csharp2cuda_temp_17 = (first)->data_pointer;
#line 500 "MatrixModule.cs"
        csharp2cuda_temp_16 = ((double*)(csharp2cuda_temp_17));
    }
#line 500 "MatrixModule.cs"
    const double* a = csharp2cuda_temp_16;
#line 501 "MatrixModule.cs"
    double* csharp2cuda_temp_18;
#line 501 "MatrixModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 501 "MatrixModule.cs"
        csharp2cuda_temp_18 = ((double*)(nullptr));
    }
    else
    {
#line 501 "MatrixModule.cs"
        unsigned long long csharp2cuda_temp_19 = (second)->data_pointer;
#line 501 "MatrixModule.cs"
        csharp2cuda_temp_18 = ((double*)(csharp2cuda_temp_19));
    }
#line 501 "MatrixModule.cs"
    const double* b = csharp2cuda_temp_18;
#line 502 "MatrixModule.cs"
    unsigned long long csharp2cuda_temp_20 = (output)->data_pointer;
#line 502 "MatrixModule.cs"
    double* result = ((double*)(csharp2cuda_temp_20));
#line 503 "MatrixModule.cs"
    unsigned long long csharp2cuda_temp_21 = (output)->scratch_pointer;
#line 503 "MatrixModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_21));
#line 505 "MatrixModule.cs"
#line 505 "MatrixModule.cs"
    bool csharp2cuda_temp_22;
#line 505 "MatrixModule.cs"
    if (!(((opcode) == (0))))
    {
#line 505 "MatrixModule.cs"
        csharp2cuda_temp_22 = ((opcode) == (10));
    }
    else
    {
#line 505 "MatrixModule.cs"
        csharp2cuda_temp_22 = true;
    }
#line 505 "MatrixModule.cs"
    bool csharp2cuda_temp_23;
#line 505 "MatrixModule.cs"
    if (!(csharp2cuda_temp_22))
    {
#line 505 "MatrixModule.cs"
        csharp2cuda_temp_23 = ((opcode) == (22));
    }
    else
    {
#line 505 "MatrixModule.cs"
        csharp2cuda_temp_23 = true;
    }
    if (csharp2cuda_temp_23)
#line 506 "MatrixModule.cs"
    {
#line 507 "MatrixModule.cs"
        if (((thread) == (0)))
#line 508 "MatrixModule.cs"
        {
#line 509 "MatrixModule.cs"
#line 509 "MatrixModule.cs"
            int csharp2cuda_temp_24 = (first)->rows;
#line 509 "MatrixModule.cs"
            int csharp2cuda_temp_25 = (first)->columns;
            mathblocks_matrix_shape(output, csharp2cuda_temp_24, csharp2cuda_temp_25);
#line 510 "MatrixModule.cs"
#line 510 "MatrixModule.cs"
            bool csharp2cuda_temp_26 = mathblocks_matrix_compatible(first, second);
            if ((!(csharp2cuda_temp_26)))
            {
#line 510 "MatrixModule.cs"
#line 510 "MatrixModule.cs"
                int* csharp2cuda_temp_27 = &((output)->valid);
                (*(csharp2cuda_temp_27) = 0);
            }
        }
#line 512 "MatrixModule.cs"
        __syncthreads();
#line 513 "MatrixModule.cs"
        {
#line 513 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 513 "MatrixModule.cs"
                bool csharp2cuda_temp_30 = (output)->valid;
#line 513 "MatrixModule.cs"
                bool csharp2cuda_temp_31;
#line 513 "MatrixModule.cs"
                if (csharp2cuda_temp_30)
                {
#line 513 "MatrixModule.cs"
                    int csharp2cuda_temp_32 = (first)->count;
#line 513 "MatrixModule.cs"
                    csharp2cuda_temp_31 = ((index) < (csharp2cuda_temp_32));
                }
                else
                {
#line 513 "MatrixModule.cs"
                    csharp2cuda_temp_31 = false;
                }
                if (!(csharp2cuda_temp_31))
                    break;
#line 514 "MatrixModule.cs"
                {
#line 515 "MatrixModule.cs"
                    double csharp2cuda_temp_33;
#line 515 "MatrixModule.cs"
                    if (((opcode) == (0)))
                    {
#line 515 "MatrixModule.cs"
                        double csharp2cuda_temp_34 = (a)[index];
#line 515 "MatrixModule.cs"
                        double csharp2cuda_temp_35 = (b)[index];
#line 515 "MatrixModule.cs"
                        csharp2cuda_temp_33 = __dadd_rn(csharp2cuda_temp_34, csharp2cuda_temp_35);
                    }
                    else
                    {
#line 516 "MatrixModule.cs"
                        double csharp2cuda_temp_36;
#line 516 "MatrixModule.cs"
                        if (((opcode) == (10)))
                        {
#line 516 "MatrixModule.cs"
                            double csharp2cuda_temp_37 = (a)[index];
#line 516 "MatrixModule.cs"
                            double csharp2cuda_temp_38 = (b)[index];
#line 516 "MatrixModule.cs"
                            csharp2cuda_temp_36 = __dmul_rn(csharp2cuda_temp_37, csharp2cuda_temp_38);
                        }
                        else
                        {
#line 517 "MatrixModule.cs"
                            double csharp2cuda_temp_39 = (a)[index];
#line 517 "MatrixModule.cs"
                            double csharp2cuda_temp_40 = (b)[index];
#line 516 "MatrixModule.cs"
                            csharp2cuda_temp_36 = __dsub_rn(csharp2cuda_temp_39, csharp2cuda_temp_40);
                        }
#line 515 "MatrixModule.cs"
                        csharp2cuda_temp_33 = csharp2cuda_temp_36;
                    }
#line 515 "MatrixModule.cs"
                    double value = csharp2cuda_temp_33;
#line 518 "MatrixModule.cs"
#line 518 "MatrixModule.cs"
                    double* csharp2cuda_temp_41 = &((result)[index]);
                    (*(csharp2cuda_temp_41) = value);
#line 519 "MatrixModule.cs"
                    if ((!(isfinite(value))))
                    {
#line 519 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 513 "MatrixModule.cs"
                int* csharp2cuda_temp_28 = &(index);
#line 513 "MatrixModule.cs"
                int csharp2cuda_temp_29 = *(csharp2cuda_temp_28);
                (*(csharp2cuda_temp_28) = csharp2cuda_i32_add(csharp2cuda_temp_29, blockDim.x));
            }
        }
#line 521 "MatrixModule.cs"
        return;
    }
#line 524 "MatrixModule.cs"
    if (((opcode) == (1)))
#line 525 "MatrixModule.cs"
    {
#line 526 "MatrixModule.cs"
        if (((thread) == (0)))
#line 527 "MatrixModule.cs"
        {
#line 528 "MatrixModule.cs"
#line 528 "MatrixModule.cs"
            int csharp2cuda_temp_42 = (first)->rows;
#line 528 "MatrixModule.cs"
            int csharp2cuda_temp_43 = (first)->columns;
            mathblocks_matrix_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_42, 1), csharp2cuda_temp_43);
#line 529 "MatrixModule.cs"
#line 529 "MatrixModule.cs"
            int csharp2cuda_temp_44 = (second)->count;
#line 529 "MatrixModule.cs"
            int csharp2cuda_temp_45 = (first)->columns;
            if (((csharp2cuda_temp_44) != (csharp2cuda_temp_45)))
            {
#line 529 "MatrixModule.cs"
#line 529 "MatrixModule.cs"
                int* csharp2cuda_temp_46 = &((output)->valid);
                (*(csharp2cuda_temp_46) = 0);
            }
        }
#line 531 "MatrixModule.cs"
        __syncthreads();
#line 532 "MatrixModule.cs"
        {
#line 532 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 532 "MatrixModule.cs"
                bool csharp2cuda_temp_49 = (output)->valid;
#line 532 "MatrixModule.cs"
                bool csharp2cuda_temp_50;
#line 532 "MatrixModule.cs"
                if (csharp2cuda_temp_49)
                {
#line 532 "MatrixModule.cs"
                    int csharp2cuda_temp_51 = (output)->count;
#line 532 "MatrixModule.cs"
                    csharp2cuda_temp_50 = ((index) < (csharp2cuda_temp_51));
                }
                else
                {
#line 532 "MatrixModule.cs"
                    csharp2cuda_temp_50 = false;
                }
                if (!(csharp2cuda_temp_50))
                    break;
#line 533 "MatrixModule.cs"
#line 533 "MatrixModule.cs"
                double* csharp2cuda_temp_52 = &((result)[index]);
#line 533 "MatrixModule.cs"
                int csharp2cuda_temp_53 = (first)->count;
#line 533 "MatrixModule.cs"
                double csharp2cuda_temp_54;
#line 533 "MatrixModule.cs"
                if (((index) < (csharp2cuda_temp_53)))
                {
#line 533 "MatrixModule.cs"
                    csharp2cuda_temp_54 = (a)[index];
                }
                else
                {
#line 533 "MatrixModule.cs"
                    int csharp2cuda_temp_55 = (first)->count;
#line 533 "MatrixModule.cs"
                    csharp2cuda_temp_54 = (b)[csharp2cuda_i32_sub(index, csharp2cuda_temp_55)];
                }
                (*(csharp2cuda_temp_52) = csharp2cuda_temp_54);
#line 532 "MatrixModule.cs"
                int* csharp2cuda_temp_47 = &(index);
#line 532 "MatrixModule.cs"
                int csharp2cuda_temp_48 = *(csharp2cuda_temp_47);
                (*(csharp2cuda_temp_47) = csharp2cuda_i32_add(csharp2cuda_temp_48, blockDim.x));
            }
        }
#line 534 "MatrixModule.cs"
        return;
    }
#line 537 "MatrixModule.cs"
#line 537 "MatrixModule.cs"
    bool csharp2cuda_temp_56;
#line 537 "MatrixModule.cs"
    if (!(((opcode) == (2))))
    {
#line 537 "MatrixModule.cs"
        csharp2cuda_temp_56 = ((opcode) == (18));
    }
    else
    {
#line 537 "MatrixModule.cs"
        csharp2cuda_temp_56 = true;
    }
    if (csharp2cuda_temp_56)
#line 538 "MatrixModule.cs"
    {
#line 539 "MatrixModule.cs"
        int csharp2cuda_temp_57;
#line 539 "MatrixModule.cs"
        if (((opcode) == (2)))
        {
#line 539 "MatrixModule.cs"
            csharp2cuda_temp_57 = (first)->columns;
        }
        else
        {
#line 539 "MatrixModule.cs"
            csharp2cuda_temp_57 = (first)->rows;
        }
#line 539 "MatrixModule.cs"
        int count = csharp2cuda_temp_57;
#line 540 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 540 "MatrixModule.cs"
            mathblocks_set_vector_shape(output, count);
        }
#line 541 "MatrixModule.cs"
        __syncthreads();
#line 542 "MatrixModule.cs"
        {
#line 542 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 542 "MatrixModule.cs"
                bool csharp2cuda_temp_60 = (output)->valid;
#line 542 "MatrixModule.cs"
                bool csharp2cuda_temp_61;
#line 542 "MatrixModule.cs"
                if (csharp2cuda_temp_60)
                {
#line 542 "MatrixModule.cs"
                    csharp2cuda_temp_61 = ((index) < (count));
                }
                else
                {
#line 542 "MatrixModule.cs"
                    csharp2cuda_temp_61 = false;
                }
                if (!(csharp2cuda_temp_61))
                    break;
#line 543 "MatrixModule.cs"
                {
#line 544 "MatrixModule.cs"
                    double sum = 0.0;
#line 545 "MatrixModule.cs"
                    if (((opcode) == (2)))
#line 546 "MatrixModule.cs"
                    {
#line 547 "MatrixModule.cs"
                        {
#line 547 "MatrixModule.cs"
                            int row = 0;
                            while (true)
                            {
#line 547 "MatrixModule.cs"
                                int csharp2cuda_temp_63 = (first)->rows;
                                if (!(((row) < (csharp2cuda_temp_63))))
                                    break;
#line 548 "MatrixModule.cs"
#line 548 "MatrixModule.cs"
                                double* csharp2cuda_temp_64 = &(sum);
#line 548 "MatrixModule.cs"
                                double csharp2cuda_temp_65 = *(csharp2cuda_temp_64);
#line 548 "MatrixModule.cs"
                                int csharp2cuda_temp_66 = (first)->columns;
#line 548 "MatrixModule.cs"
                                double csharp2cuda_temp_67 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_66), index)];
                                (*(csharp2cuda_temp_64) = __dadd_rn(csharp2cuda_temp_65, csharp2cuda_temp_67));
#line 547 "MatrixModule.cs"
                                int* csharp2cuda_temp_62 = &(row);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_62));
                            }
                        }
                    }
                    else
#line 551 "MatrixModule.cs"
                    {
#line 552 "MatrixModule.cs"
                        {
#line 552 "MatrixModule.cs"
                            int column = 0;
                            while (true)
                            {
#line 552 "MatrixModule.cs"
                                int csharp2cuda_temp_69 = (first)->columns;
                                if (!(((column) < (csharp2cuda_temp_69))))
                                    break;
#line 553 "MatrixModule.cs"
#line 553 "MatrixModule.cs"
                                double* csharp2cuda_temp_70 = &(sum);
#line 553 "MatrixModule.cs"
                                double csharp2cuda_temp_71 = *(csharp2cuda_temp_70);
#line 553 "MatrixModule.cs"
                                int csharp2cuda_temp_72 = (first)->columns;
#line 553 "MatrixModule.cs"
                                double csharp2cuda_temp_73 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, csharp2cuda_temp_72), column)];
                                (*(csharp2cuda_temp_70) = __dadd_rn(csharp2cuda_temp_71, csharp2cuda_temp_73));
#line 552 "MatrixModule.cs"
                                int* csharp2cuda_temp_68 = &(column);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_68));
                            }
                        }
                    }
#line 555 "MatrixModule.cs"
#line 555 "MatrixModule.cs"
                    double* csharp2cuda_temp_74 = &((result)[index]);
                    (*(csharp2cuda_temp_74) = sum);
#line 556 "MatrixModule.cs"
                    if ((!(isfinite(sum))))
                    {
#line 556 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 542 "MatrixModule.cs"
                int* csharp2cuda_temp_58 = &(index);
#line 542 "MatrixModule.cs"
                int csharp2cuda_temp_59 = *(csharp2cuda_temp_58);
                (*(csharp2cuda_temp_58) = csharp2cuda_i32_add(csharp2cuda_temp_59, blockDim.x));
            }
        }
#line 558 "MatrixModule.cs"
        return;
    }
#line 561 "MatrixModule.cs"
#line 561 "MatrixModule.cs"
    bool csharp2cuda_temp_75;
#line 561 "MatrixModule.cs"
    if (!(((opcode) == (3))))
    {
#line 561 "MatrixModule.cs"
        csharp2cuda_temp_75 = ((opcode) == (19));
    }
    else
    {
#line 561 "MatrixModule.cs"
        csharp2cuda_temp_75 = true;
    }
    if (csharp2cuda_temp_75)
#line 562 "MatrixModule.cs"
    {
#line 563 "MatrixModule.cs"
        int selected = 0;
#line 564 "MatrixModule.cs"
        double csharp2cuda_temp_76 = (second)->scalar_value;
#line 564 "MatrixModule.cs"
        int* csharp2cuda_temp_77 = &(selected);
#line 564 "MatrixModule.cs"
        bool valid_index = mathblocks_nonnegative_integer(csharp2cuda_temp_76, csharp2cuda_temp_77);
#line 565 "MatrixModule.cs"
        int csharp2cuda_temp_78;
#line 565 "MatrixModule.cs"
        if (((opcode) == (3)))
        {
#line 565 "MatrixModule.cs"
            csharp2cuda_temp_78 = (first)->columns;
        }
        else
        {
#line 565 "MatrixModule.cs"
            csharp2cuda_temp_78 = (first)->rows;
        }
#line 565 "MatrixModule.cs"
        int limit = csharp2cuda_temp_78;
#line 566 "MatrixModule.cs"
        int csharp2cuda_temp_79;
#line 566 "MatrixModule.cs"
        if (((opcode) == (3)))
        {
#line 566 "MatrixModule.cs"
            csharp2cuda_temp_79 = (first)->rows;
        }
        else
        {
#line 566 "MatrixModule.cs"
            csharp2cuda_temp_79 = (first)->columns;
        }
#line 566 "MatrixModule.cs"
        int count = csharp2cuda_temp_79;
#line 567 "MatrixModule.cs"
        if (((thread) == (0)))
#line 568 "MatrixModule.cs"
        {
#line 569 "MatrixModule.cs"
            mathblocks_set_vector_shape(output, count);
#line 570 "MatrixModule.cs"
#line 570 "MatrixModule.cs"
            bool csharp2cuda_temp_80;
#line 570 "MatrixModule.cs"
            if (!((!(valid_index))))
            {
#line 570 "MatrixModule.cs"
                csharp2cuda_temp_80 = ((selected) >= (limit));
            }
            else
            {
#line 570 "MatrixModule.cs"
                csharp2cuda_temp_80 = true;
            }
            if (csharp2cuda_temp_80)
            {
#line 570 "MatrixModule.cs"
#line 570 "MatrixModule.cs"
                int* csharp2cuda_temp_81 = &((output)->valid);
                (*(csharp2cuda_temp_81) = 0);
            }
        }
#line 572 "MatrixModule.cs"
        __syncthreads();
#line 573 "MatrixModule.cs"
        {
#line 573 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 573 "MatrixModule.cs"
                bool csharp2cuda_temp_84 = (output)->valid;
#line 573 "MatrixModule.cs"
                bool csharp2cuda_temp_85;
#line 573 "MatrixModule.cs"
                if (csharp2cuda_temp_84)
                {
#line 573 "MatrixModule.cs"
                    csharp2cuda_temp_85 = ((index) < (count));
                }
                else
                {
#line 573 "MatrixModule.cs"
                    csharp2cuda_temp_85 = false;
                }
                if (!(csharp2cuda_temp_85))
                    break;
#line 574 "MatrixModule.cs"
#line 574 "MatrixModule.cs"
                double* csharp2cuda_temp_86 = &((result)[index]);
#line 574 "MatrixModule.cs"
                double csharp2cuda_temp_87;
#line 574 "MatrixModule.cs"
                if (((opcode) == (3)))
                {
#line 575 "MatrixModule.cs"
                    int csharp2cuda_temp_88 = (first)->columns;
#line 574 "MatrixModule.cs"
                    csharp2cuda_temp_87 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, csharp2cuda_temp_88), selected)];
                }
                else
                {
#line 576 "MatrixModule.cs"
                    int csharp2cuda_temp_89 = (first)->columns;
#line 574 "MatrixModule.cs"
                    csharp2cuda_temp_87 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(selected, csharp2cuda_temp_89), index)];
                }
                (*(csharp2cuda_temp_86) = csharp2cuda_temp_87);
#line 573 "MatrixModule.cs"
                int* csharp2cuda_temp_82 = &(index);
#line 573 "MatrixModule.cs"
                int csharp2cuda_temp_83 = *(csharp2cuda_temp_82);
                (*(csharp2cuda_temp_82) = csharp2cuda_i32_add(csharp2cuda_temp_83, blockDim.x));
            }
        }
#line 577 "MatrixModule.cs"
        return;
    }
#line 580 "MatrixModule.cs"
    if (((opcode) == (4)))
#line 581 "MatrixModule.cs"
    {
#line 582 "MatrixModule.cs"
        if (((thread) == (0)))
#line 583 "MatrixModule.cs"
        {
#line 584 "MatrixModule.cs"
#line 584 "MatrixModule.cs"
            int csharp2cuda_temp_90 = (first)->rows;
#line 584 "MatrixModule.cs"
            int csharp2cuda_temp_91 = (first)->columns;
            mathblocks_matrix_shape(output, csharp2cuda_temp_90, csharp2cuda_temp_91);
#line 585 "MatrixModule.cs"
#line 585 "MatrixModule.cs"
            bool csharp2cuda_temp_92 = mathblocks_matrix_compatible(first, second);
#line 585 "MatrixModule.cs"
            bool csharp2cuda_temp_93;
#line 585 "MatrixModule.cs"
            if (!((!(csharp2cuda_temp_92))))
            {
#line 585 "MatrixModule.cs"
                int csharp2cuda_temp_94 = (first)->rows;
#line 585 "MatrixModule.cs"
                int csharp2cuda_temp_95 = (first)->columns;
#line 585 "MatrixModule.cs"
                csharp2cuda_temp_93 = ((csharp2cuda_temp_94) != (csharp2cuda_temp_95));
            }
            else
            {
#line 585 "MatrixModule.cs"
                csharp2cuda_temp_93 = true;
            }
            if (csharp2cuda_temp_93)
            {
#line 586 "MatrixModule.cs"
#line 586 "MatrixModule.cs"
                int* csharp2cuda_temp_96 = &((output)->valid);
                (*(csharp2cuda_temp_96) = 0);
            }
        }
#line 588 "MatrixModule.cs"
        __syncthreads();
#line 589 "MatrixModule.cs"
        {
#line 589 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 589 "MatrixModule.cs"
                bool csharp2cuda_temp_99 = (output)->valid;
#line 589 "MatrixModule.cs"
                bool csharp2cuda_temp_100;
#line 589 "MatrixModule.cs"
                if (csharp2cuda_temp_99)
                {
#line 589 "MatrixModule.cs"
                    int csharp2cuda_temp_101 = (output)->count;
#line 589 "MatrixModule.cs"
                    csharp2cuda_temp_100 = ((flat) < (csharp2cuda_temp_101));
                }
                else
                {
#line 589 "MatrixModule.cs"
                    csharp2cuda_temp_100 = false;
                }
                if (!(csharp2cuda_temp_100))
                    break;
#line 590 "MatrixModule.cs"
                {
#line 591 "MatrixModule.cs"
                    int csharp2cuda_temp_102 = (first)->columns;
#line 591 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, csharp2cuda_temp_102);
#line 592 "MatrixModule.cs"
                    int csharp2cuda_temp_103 = (first)->columns;
#line 592 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, csharp2cuda_temp_103));
#line 593 "MatrixModule.cs"
                    double left_product = 0.0;
#line 594 "MatrixModule.cs"
                    double right_product = 0.0;
#line 595 "MatrixModule.cs"
                    {
#line 595 "MatrixModule.cs"
                        int inner = 0;
                        while (true)
                        {
#line 595 "MatrixModule.cs"
                            int csharp2cuda_temp_105 = (first)->columns;
                            if (!(((inner) < (csharp2cuda_temp_105))))
                                break;
#line 596 "MatrixModule.cs"
                            {
#line 597 "MatrixModule.cs"
#line 597 "MatrixModule.cs"
                                double* csharp2cuda_temp_106 = &(left_product);
#line 597 "MatrixModule.cs"
                                double csharp2cuda_temp_107 = *(csharp2cuda_temp_106);
#line 597 "MatrixModule.cs"
                                int csharp2cuda_temp_108 = (first)->columns;
#line 597 "MatrixModule.cs"
                                double csharp2cuda_temp_109 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_108), inner)];
#line 598 "MatrixModule.cs"
                                int csharp2cuda_temp_110 = (second)->columns;
#line 598 "MatrixModule.cs"
                                double csharp2cuda_temp_111 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_110), column)];
                                (*(csharp2cuda_temp_106) = __dadd_rn(csharp2cuda_temp_107, __dmul_rn(csharp2cuda_temp_109, csharp2cuda_temp_111)));
#line 599 "MatrixModule.cs"
#line 599 "MatrixModule.cs"
                                double* csharp2cuda_temp_112 = &(right_product);
#line 599 "MatrixModule.cs"
                                double csharp2cuda_temp_113 = *(csharp2cuda_temp_112);
#line 599 "MatrixModule.cs"
                                int csharp2cuda_temp_114 = (second)->columns;
#line 599 "MatrixModule.cs"
                                double csharp2cuda_temp_115 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_114), inner)];
#line 600 "MatrixModule.cs"
                                int csharp2cuda_temp_116 = (first)->columns;
#line 600 "MatrixModule.cs"
                                double csharp2cuda_temp_117 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_116), column)];
                                (*(csharp2cuda_temp_112) = __dadd_rn(csharp2cuda_temp_113, __dmul_rn(csharp2cuda_temp_115, csharp2cuda_temp_117)));
                            }
#line 595 "MatrixModule.cs"
                            int* csharp2cuda_temp_104 = &(inner);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_104));
                        }
                    }
#line 602 "MatrixModule.cs"
#line 602 "MatrixModule.cs"
                    double* csharp2cuda_temp_118 = &((result)[flat]);
                    (*(csharp2cuda_temp_118) = __dsub_rn(left_product, right_product));
#line 603 "MatrixModule.cs"
#line 603 "MatrixModule.cs"
                    double csharp2cuda_temp_119 = (result)[flat];
                    if ((!(isfinite(csharp2cuda_temp_119))))
                    {
#line 603 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 589 "MatrixModule.cs"
                int* csharp2cuda_temp_97 = &(flat);
#line 589 "MatrixModule.cs"
                int csharp2cuda_temp_98 = *(csharp2cuda_temp_97);
                (*(csharp2cuda_temp_97) = csharp2cuda_i32_add(csharp2cuda_temp_98, blockDim.x));
            }
        }
#line 605 "MatrixModule.cs"
        return;
    }
#line 608 "MatrixModule.cs"
    if (((opcode) == (5)))
#line 609 "MatrixModule.cs"
    {
#line 610 "MatrixModule.cs"
        int size = (first)->count;
#line 611 "MatrixModule.cs"
        if (((thread) == (0)))
#line 612 "MatrixModule.cs"
        {
#line 613 "MatrixModule.cs"
            mathblocks_matrix_shape(output, size, size);
#line 614 "MatrixModule.cs"
            if (((size) <= (0)))
            {
#line 614 "MatrixModule.cs"
#line 614 "MatrixModule.cs"
                int* csharp2cuda_temp_120 = &((output)->valid);
                (*(csharp2cuda_temp_120) = 0);
            }
        }
#line 616 "MatrixModule.cs"
        __syncthreads();
#line 617 "MatrixModule.cs"
        {
#line 617 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 617 "MatrixModule.cs"
                bool csharp2cuda_temp_123 = (output)->valid;
#line 617 "MatrixModule.cs"
                bool csharp2cuda_temp_124;
#line 617 "MatrixModule.cs"
                if (csharp2cuda_temp_123)
                {
#line 617 "MatrixModule.cs"
                    csharp2cuda_temp_124 = ((flat) < (csharp2cuda_i32_mul(size, size)));
                }
                else
                {
#line 617 "MatrixModule.cs"
                    csharp2cuda_temp_124 = false;
                }
                if (!(csharp2cuda_temp_124))
                    break;
#line 618 "MatrixModule.cs"
                {
#line 619 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, size);
#line 620 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, size));
#line 621 "MatrixModule.cs"
#line 621 "MatrixModule.cs"
                    double* csharp2cuda_temp_125 = &((result)[flat]);
#line 621 "MatrixModule.cs"
                    double csharp2cuda_temp_126;
#line 621 "MatrixModule.cs"
                    if (((row) == (column)))
                    {
#line 621 "MatrixModule.cs"
                        csharp2cuda_temp_126 = (a)[row];
                    }
                    else
                    {
#line 621 "MatrixModule.cs"
                        csharp2cuda_temp_126 = 0.0;
                    }
                    (*(csharp2cuda_temp_125) = csharp2cuda_temp_126);
                }
#line 617 "MatrixModule.cs"
                int* csharp2cuda_temp_121 = &(flat);
#line 617 "MatrixModule.cs"
                int csharp2cuda_temp_122 = *(csharp2cuda_temp_121);
                (*(csharp2cuda_temp_121) = csharp2cuda_i32_add(csharp2cuda_temp_122, blockDim.x));
            }
        }
#line 623 "MatrixModule.cs"
        return;
    }
#line 626 "MatrixModule.cs"
    if (((opcode) == (6)))
#line 627 "MatrixModule.cs"
    {
#line 628 "MatrixModule.cs"
        int csharp2cuda_temp_127 = (first)->rows;
#line 628 "MatrixModule.cs"
        int csharp2cuda_temp_128 = (first)->columns;
#line 628 "MatrixModule.cs"
        int csharp2cuda_temp_129;
#line 628 "MatrixModule.cs"
        if (((csharp2cuda_temp_127) < (csharp2cuda_temp_128)))
        {
#line 628 "MatrixModule.cs"
            csharp2cuda_temp_129 = (first)->rows;
        }
        else
        {
#line 628 "MatrixModule.cs"
            csharp2cuda_temp_129 = (first)->columns;
        }
#line 628 "MatrixModule.cs"
        int count = csharp2cuda_temp_129;
#line 629 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 629 "MatrixModule.cs"
            mathblocks_set_vector_shape(output, count);
        }
#line 630 "MatrixModule.cs"
        __syncthreads();
#line 631 "MatrixModule.cs"
        {
#line 631 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 631 "MatrixModule.cs"
                bool csharp2cuda_temp_132 = (output)->valid;
#line 631 "MatrixModule.cs"
                bool csharp2cuda_temp_133;
#line 631 "MatrixModule.cs"
                if (csharp2cuda_temp_132)
                {
#line 631 "MatrixModule.cs"
                    csharp2cuda_temp_133 = ((index) < (count));
                }
                else
                {
#line 631 "MatrixModule.cs"
                    csharp2cuda_temp_133 = false;
                }
                if (!(csharp2cuda_temp_133))
                    break;
#line 632 "MatrixModule.cs"
#line 632 "MatrixModule.cs"
                double* csharp2cuda_temp_134 = &((result)[index]);
#line 632 "MatrixModule.cs"
                int csharp2cuda_temp_135 = (first)->columns;
#line 632 "MatrixModule.cs"
                double csharp2cuda_temp_136 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, csharp2cuda_temp_135), index)];
                (*(csharp2cuda_temp_134) = csharp2cuda_temp_136);
#line 631 "MatrixModule.cs"
                int* csharp2cuda_temp_130 = &(index);
#line 631 "MatrixModule.cs"
                int csharp2cuda_temp_131 = *(csharp2cuda_temp_130);
                (*(csharp2cuda_temp_130) = csharp2cuda_i32_add(csharp2cuda_temp_131, blockDim.x));
            }
        }
#line 633 "MatrixModule.cs"
        return;
    }
#line 636 "MatrixModule.cs"
    if (((opcode) == (7)))
#line 637 "MatrixModule.cs"
    {
#line 638 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 638 "MatrixModule.cs"
#line 638 "MatrixModule.cs"
            int csharp2cuda_temp_137 = (first)->count;
            mathblocks_set_vector_shape(output, csharp2cuda_temp_137);
        }
#line 639 "MatrixModule.cs"
        __syncthreads();
#line 640 "MatrixModule.cs"
        {
#line 640 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 640 "MatrixModule.cs"
                bool csharp2cuda_temp_140 = (output)->valid;
#line 640 "MatrixModule.cs"
                bool csharp2cuda_temp_141;
#line 640 "MatrixModule.cs"
                if (csharp2cuda_temp_140)
                {
#line 640 "MatrixModule.cs"
                    int csharp2cuda_temp_142 = (first)->count;
#line 640 "MatrixModule.cs"
                    csharp2cuda_temp_141 = ((index) < (csharp2cuda_temp_142));
                }
                else
                {
#line 640 "MatrixModule.cs"
                    csharp2cuda_temp_141 = false;
                }
                if (!(csharp2cuda_temp_141))
                    break;
#line 641 "MatrixModule.cs"
#line 641 "MatrixModule.cs"
                double* csharp2cuda_temp_143 = &((result)[index]);
#line 641 "MatrixModule.cs"
                double csharp2cuda_temp_144 = (a)[index];
                (*(csharp2cuda_temp_143) = csharp2cuda_temp_144);
#line 640 "MatrixModule.cs"
                int* csharp2cuda_temp_138 = &(index);
#line 640 "MatrixModule.cs"
                int csharp2cuda_temp_139 = *(csharp2cuda_temp_138);
                (*(csharp2cuda_temp_138) = csharp2cuda_i32_add(csharp2cuda_temp_139, blockDim.x));
            }
        }
#line 642 "MatrixModule.cs"
        return;
    }
#line 645 "MatrixModule.cs"
    if (((opcode) == (8)))
#line 646 "MatrixModule.cs"
    {
#line 647 "MatrixModule.cs"
        if (((thread) == (0)))
#line 648 "MatrixModule.cs"
        {
#line 649 "MatrixModule.cs"
#line 649 "MatrixModule.cs"
            double* csharp2cuda_temp_145 = &((output)->scalar_value);
#line 650 "MatrixModule.cs"
            int csharp2cuda_temp_146 = (first)->count;
            (*(csharp2cuda_temp_145) = mathblocks_square_root(mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_146)));
#line 651 "MatrixModule.cs"
#line 651 "MatrixModule.cs"
            double csharp2cuda_temp_147 = (output)->scalar_value;
            if ((!(isfinite(csharp2cuda_temp_147))))
            {
#line 651 "MatrixModule.cs"
#line 651 "MatrixModule.cs"
                int* csharp2cuda_temp_148 = &((output)->valid);
                (*(csharp2cuda_temp_148) = 0);
            }
        }
#line 653 "MatrixModule.cs"
        return;
    }
#line 656 "MatrixModule.cs"
    if (((opcode) == (9)))
#line 657 "MatrixModule.cs"
    {
#line 658 "MatrixModule.cs"
        int size = (first)->columns;
#line 659 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 659 "MatrixModule.cs"
            mathblocks_matrix_shape(output, size, size);
        }
#line 660 "MatrixModule.cs"
        __syncthreads();
#line 661 "MatrixModule.cs"
        {
#line 661 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 661 "MatrixModule.cs"
                bool csharp2cuda_temp_151 = (output)->valid;
#line 661 "MatrixModule.cs"
                bool csharp2cuda_temp_152;
#line 661 "MatrixModule.cs"
                if (csharp2cuda_temp_151)
                {
#line 661 "MatrixModule.cs"
                    csharp2cuda_temp_152 = ((flat) < (csharp2cuda_i32_mul(size, size)));
                }
                else
                {
#line 661 "MatrixModule.cs"
                    csharp2cuda_temp_152 = false;
                }
                if (!(csharp2cuda_temp_152))
                    break;
#line 662 "MatrixModule.cs"
                {
#line 663 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, size);
#line 664 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, size));
#line 665 "MatrixModule.cs"
                    double sum = 0.0;
#line 666 "MatrixModule.cs"
                    {
#line 666 "MatrixModule.cs"
                        int inner = 0;
                        while (true)
                        {
#line 666 "MatrixModule.cs"
                            int csharp2cuda_temp_154 = (first)->rows;
                            if (!(((inner) < (csharp2cuda_temp_154))))
                                break;
#line 667 "MatrixModule.cs"
#line 667 "MatrixModule.cs"
                            double* csharp2cuda_temp_155 = &(sum);
#line 667 "MatrixModule.cs"
                            double csharp2cuda_temp_156 = *(csharp2cuda_temp_155);
#line 667 "MatrixModule.cs"
                            int csharp2cuda_temp_157 = (first)->columns;
#line 667 "MatrixModule.cs"
                            double csharp2cuda_temp_158 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_157), row)];
#line 667 "MatrixModule.cs"
                            int csharp2cuda_temp_159 = (first)->columns;
#line 667 "MatrixModule.cs"
                            double csharp2cuda_temp_160 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_159), column)];
                            (*(csharp2cuda_temp_155) = __dadd_rn(csharp2cuda_temp_156, __dmul_rn(csharp2cuda_temp_158, csharp2cuda_temp_160)));
#line 666 "MatrixModule.cs"
                            int* csharp2cuda_temp_153 = &(inner);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_153));
                        }
                    }
#line 668 "MatrixModule.cs"
#line 668 "MatrixModule.cs"
                    double* csharp2cuda_temp_161 = &((result)[flat]);
                    (*(csharp2cuda_temp_161) = sum);
#line 669 "MatrixModule.cs"
                    if ((!(isfinite(sum))))
                    {
#line 669 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 661 "MatrixModule.cs"
                int* csharp2cuda_temp_149 = &(flat);
#line 661 "MatrixModule.cs"
                int csharp2cuda_temp_150 = *(csharp2cuda_temp_149);
                (*(csharp2cuda_temp_149) = csharp2cuda_i32_add(csharp2cuda_temp_150, blockDim.x));
            }
        }
#line 671 "MatrixModule.cs"
        return;
    }
#line 674 "MatrixModule.cs"
#line 674 "MatrixModule.cs"
    bool csharp2cuda_temp_162;
#line 674 "MatrixModule.cs"
    if (!(((opcode) == (11))))
    {
#line 674 "MatrixModule.cs"
        csharp2cuda_temp_162 = ((opcode) == (23));
    }
    else
    {
#line 674 "MatrixModule.cs"
        csharp2cuda_temp_162 = true;
    }
    if (csharp2cuda_temp_162)
#line 675 "MatrixModule.cs"
    {
#line 676 "MatrixModule.cs"
        if (((thread) == (0)))
#line 677 "MatrixModule.cs"
        {
#line 678 "MatrixModule.cs"
#line 678 "MatrixModule.cs"
            int csharp2cuda_temp_163 = (first)->count;
#line 678 "MatrixModule.cs"
            int csharp2cuda_temp_164 = (second)->count;
            mathblocks_matrix_shape(output, csharp2cuda_temp_163, csharp2cuda_temp_164);
#line 679 "MatrixModule.cs"
#line 679 "MatrixModule.cs"
            int csharp2cuda_temp_165 = (first)->count;
#line 679 "MatrixModule.cs"
            bool csharp2cuda_temp_166;
#line 679 "MatrixModule.cs"
            if (!(((csharp2cuda_temp_165) <= (0))))
            {
#line 679 "MatrixModule.cs"
                int csharp2cuda_temp_167 = (second)->count;
#line 679 "MatrixModule.cs"
                csharp2cuda_temp_166 = ((csharp2cuda_temp_167) <= (0));
            }
            else
            {
#line 679 "MatrixModule.cs"
                csharp2cuda_temp_166 = true;
            }
#line 679 "MatrixModule.cs"
            bool csharp2cuda_temp_168;
#line 679 "MatrixModule.cs"
            if (!(csharp2cuda_temp_166))
            {
#line 680 "MatrixModule.cs"
                bool csharp2cuda_temp_169;
#line 680 "MatrixModule.cs"
                if (((opcode) == (11)))
                {
#line 680 "MatrixModule.cs"
                    int csharp2cuda_temp_170 = (first)->count;
#line 680 "MatrixModule.cs"
                    double csharp2cuda_temp_171 = (a)[csharp2cuda_i32_sub(csharp2cuda_temp_170, 1)];
#line 680 "MatrixModule.cs"
                    double csharp2cuda_temp_172 = (b)[0];
#line 680 "MatrixModule.cs"
                    csharp2cuda_temp_169 = ((csharp2cuda_temp_171) != (csharp2cuda_temp_172));
                }
                else
                {
#line 680 "MatrixModule.cs"
                    double csharp2cuda_temp_173 = (a)[0];
#line 680 "MatrixModule.cs"
                    double csharp2cuda_temp_174 = (b)[0];
#line 680 "MatrixModule.cs"
                    csharp2cuda_temp_169 = ((csharp2cuda_temp_173) != (csharp2cuda_temp_174));
                }
#line 679 "MatrixModule.cs"
                csharp2cuda_temp_168 = csharp2cuda_temp_169;
            }
            else
            {
#line 679 "MatrixModule.cs"
                csharp2cuda_temp_168 = true;
            }
            if (csharp2cuda_temp_168)
#line 681 "MatrixModule.cs"
            {
#line 682 "MatrixModule.cs"
#line 682 "MatrixModule.cs"
                int* csharp2cuda_temp_175 = &((output)->valid);
                (*(csharp2cuda_temp_175) = 0);
            }
        }
#line 685 "MatrixModule.cs"
        __syncthreads();
#line 686 "MatrixModule.cs"
        {
#line 686 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 686 "MatrixModule.cs"
                bool csharp2cuda_temp_178 = (output)->valid;
#line 686 "MatrixModule.cs"
                bool csharp2cuda_temp_179;
#line 686 "MatrixModule.cs"
                if (csharp2cuda_temp_178)
                {
#line 686 "MatrixModule.cs"
                    int csharp2cuda_temp_180 = (output)->count;
#line 686 "MatrixModule.cs"
                    csharp2cuda_temp_179 = ((flat) < (csharp2cuda_temp_180));
                }
                else
                {
#line 686 "MatrixModule.cs"
                    csharp2cuda_temp_179 = false;
                }
                if (!(csharp2cuda_temp_179))
                    break;
#line 687 "MatrixModule.cs"
                {
#line 688 "MatrixModule.cs"
                    int csharp2cuda_temp_181 = (second)->count;
#line 688 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, csharp2cuda_temp_181);
#line 689 "MatrixModule.cs"
                    int csharp2cuda_temp_182 = (second)->count;
#line 689 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, csharp2cuda_temp_182));
#line 690 "MatrixModule.cs"
                    if (((opcode) == (23)))
#line 691 "MatrixModule.cs"
                    {
#line 692 "MatrixModule.cs"
#line 692 "MatrixModule.cs"
                        double* csharp2cuda_temp_183 = &((result)[flat]);
#line 692 "MatrixModule.cs"
                        double csharp2cuda_temp_184;
#line 692 "MatrixModule.cs"
                        if (((column) >= (row)))
                        {
#line 692 "MatrixModule.cs"
                            csharp2cuda_temp_184 = (b)[csharp2cuda_i32_sub(column, row)];
                        }
                        else
                        {
#line 692 "MatrixModule.cs"
                            csharp2cuda_temp_184 = (a)[csharp2cuda_i32_sub(row, column)];
                        }
                        (*(csharp2cuda_temp_183) = csharp2cuda_temp_184);
                    }
                    else
#line 695 "MatrixModule.cs"
                    {
#line 696 "MatrixModule.cs"
                        int index = csharp2cuda_i32_add(row, column);
#line 697 "MatrixModule.cs"
#line 697 "MatrixModule.cs"
                        double* csharp2cuda_temp_185 = &((result)[flat]);
#line 697 "MatrixModule.cs"
                        int csharp2cuda_temp_186 = (first)->count;
#line 697 "MatrixModule.cs"
                        double csharp2cuda_temp_187;
#line 697 "MatrixModule.cs"
                        if (((index) < (csharp2cuda_temp_186)))
                        {
#line 697 "MatrixModule.cs"
                            csharp2cuda_temp_187 = (a)[index];
                        }
                        else
                        {
#line 697 "MatrixModule.cs"
                            int csharp2cuda_temp_188 = (first)->count;
#line 697 "MatrixModule.cs"
                            csharp2cuda_temp_187 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_sub(index, csharp2cuda_temp_188), 1)];
                        }
                        (*(csharp2cuda_temp_185) = csharp2cuda_temp_187);
                    }
                }
#line 686 "MatrixModule.cs"
                int* csharp2cuda_temp_176 = &(flat);
#line 686 "MatrixModule.cs"
                int csharp2cuda_temp_177 = *(csharp2cuda_temp_176);
                (*(csharp2cuda_temp_176) = csharp2cuda_i32_add(csharp2cuda_temp_177, blockDim.x));
            }
        }
#line 700 "MatrixModule.cs"
        return;
    }
#line 703 "MatrixModule.cs"
    if (((opcode) == (12)))
#line 704 "MatrixModule.cs"
    {
#line 705 "MatrixModule.cs"
        int size = 0;
#line 706 "MatrixModule.cs"
        double csharp2cuda_temp_189 = (first)->scalar_value;
#line 706 "MatrixModule.cs"
        int* csharp2cuda_temp_190 = &(size);
#line 706 "MatrixModule.cs"
        bool valid_size = mathblocks_nonnegative_integer(csharp2cuda_temp_189, csharp2cuda_temp_190);
#line 707 "MatrixModule.cs"
        if (((thread) == (0)))
#line 708 "MatrixModule.cs"
        {
#line 709 "MatrixModule.cs"
            mathblocks_matrix_shape(output, size, size);
#line 710 "MatrixModule.cs"
#line 710 "MatrixModule.cs"
            bool csharp2cuda_temp_191;
#line 710 "MatrixModule.cs"
            if (!((!(valid_size))))
            {
#line 710 "MatrixModule.cs"
                csharp2cuda_temp_191 = ((size) <= (0));
            }
            else
            {
#line 710 "MatrixModule.cs"
                csharp2cuda_temp_191 = true;
            }
#line 710 "MatrixModule.cs"
            bool csharp2cuda_temp_192;
#line 710 "MatrixModule.cs"
            if (!(csharp2cuda_temp_191))
            {
#line 710 "MatrixModule.cs"
                csharp2cuda_temp_192 = ((size) > (mathblocks_limit_matrix_size()));
            }
            else
            {
#line 710 "MatrixModule.cs"
                csharp2cuda_temp_192 = true;
            }
            if (csharp2cuda_temp_192)
            {
#line 710 "MatrixModule.cs"
#line 710 "MatrixModule.cs"
                int* csharp2cuda_temp_193 = &((output)->valid);
                (*(csharp2cuda_temp_193) = 0);
            }
        }
#line 712 "MatrixModule.cs"
        __syncthreads();
#line 713 "MatrixModule.cs"
        {
#line 713 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 713 "MatrixModule.cs"
                bool csharp2cuda_temp_196 = (output)->valid;
#line 713 "MatrixModule.cs"
                bool csharp2cuda_temp_197;
#line 713 "MatrixModule.cs"
                if (csharp2cuda_temp_196)
                {
#line 713 "MatrixModule.cs"
                    csharp2cuda_temp_197 = ((flat) < (csharp2cuda_i32_mul(size, size)));
                }
                else
                {
#line 713 "MatrixModule.cs"
                    csharp2cuda_temp_197 = false;
                }
                if (!(csharp2cuda_temp_197))
                    break;
#line 714 "MatrixModule.cs"
                {
#line 715 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, size);
#line 716 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, size));
#line 717 "MatrixModule.cs"
#line 717 "MatrixModule.cs"
                    double* csharp2cuda_temp_198 = &((result)[flat]);
#line 717 "MatrixModule.cs"
                    double csharp2cuda_temp_199;
#line 717 "MatrixModule.cs"
                    if (((row) == (column)))
                    {
#line 717 "MatrixModule.cs"
                        csharp2cuda_temp_199 = 1.0;
                    }
                    else
                    {
#line 717 "MatrixModule.cs"
                        csharp2cuda_temp_199 = 0.0;
                    }
                    (*(csharp2cuda_temp_198) = csharp2cuda_temp_199);
                }
#line 713 "MatrixModule.cs"
                int* csharp2cuda_temp_194 = &(flat);
#line 713 "MatrixModule.cs"
                int csharp2cuda_temp_195 = *(csharp2cuda_temp_194);
                (*(csharp2cuda_temp_194) = csharp2cuda_i32_add(csharp2cuda_temp_195, blockDim.x));
            }
        }
#line 719 "MatrixModule.cs"
        return;
    }
#line 722 "MatrixModule.cs"
    if (((opcode) == (13)))
#line 723 "MatrixModule.cs"
    {
#line 724 "MatrixModule.cs"
        int csharp2cuda_temp_200 = (first)->rows;
#line 724 "MatrixModule.cs"
        int csharp2cuda_temp_201 = (second)->rows;
#line 724 "MatrixModule.cs"
        int rows = csharp2cuda_i32_mul(csharp2cuda_temp_200, csharp2cuda_temp_201);
#line 725 "MatrixModule.cs"
        int csharp2cuda_temp_202 = (first)->columns;
#line 725 "MatrixModule.cs"
        int csharp2cuda_temp_203 = (second)->columns;
#line 725 "MatrixModule.cs"
        int columns = csharp2cuda_i32_mul(csharp2cuda_temp_202, csharp2cuda_temp_203);
#line 726 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 726 "MatrixModule.cs"
            mathblocks_matrix_shape(output, rows, columns);
        }
#line 727 "MatrixModule.cs"
        __syncthreads();
#line 728 "MatrixModule.cs"
        {
#line 728 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 728 "MatrixModule.cs"
                bool csharp2cuda_temp_206 = (output)->valid;
#line 728 "MatrixModule.cs"
                bool csharp2cuda_temp_207;
#line 728 "MatrixModule.cs"
                if (csharp2cuda_temp_206)
                {
#line 728 "MatrixModule.cs"
                    csharp2cuda_temp_207 = ((flat) < (csharp2cuda_i32_mul(rows, columns)));
                }
                else
                {
#line 728 "MatrixModule.cs"
                    csharp2cuda_temp_207 = false;
                }
                if (!(csharp2cuda_temp_207))
                    break;
#line 729 "MatrixModule.cs"
                {
#line 730 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, columns);
#line 731 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, columns));
#line 732 "MatrixModule.cs"
                    int csharp2cuda_temp_208 = (second)->rows;
#line 732 "MatrixModule.cs"
                    int left_row = csharp2cuda_i32_div(row, csharp2cuda_temp_208);
#line 733 "MatrixModule.cs"
                    int csharp2cuda_temp_209 = (second)->rows;
#line 733 "MatrixModule.cs"
                    int right_row = csharp2cuda_i32_sub(row, csharp2cuda_i32_mul(left_row, csharp2cuda_temp_209));
#line 734 "MatrixModule.cs"
                    int csharp2cuda_temp_210 = (second)->columns;
#line 734 "MatrixModule.cs"
                    int left_column = csharp2cuda_i32_div(column, csharp2cuda_temp_210);
#line 735 "MatrixModule.cs"
                    int csharp2cuda_temp_211 = (second)->columns;
#line 735 "MatrixModule.cs"
                    int right_column = csharp2cuda_i32_sub(column, csharp2cuda_i32_mul(left_column, csharp2cuda_temp_211));
#line 736 "MatrixModule.cs"
#line 736 "MatrixModule.cs"
                    double* csharp2cuda_temp_212 = &((result)[flat]);
#line 736 "MatrixModule.cs"
                    int csharp2cuda_temp_213 = (first)->columns;
#line 736 "MatrixModule.cs"
                    double csharp2cuda_temp_214 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left_row, csharp2cuda_temp_213), left_column)];
#line 737 "MatrixModule.cs"
                    int csharp2cuda_temp_215 = (second)->columns;
#line 737 "MatrixModule.cs"
                    double csharp2cuda_temp_216 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_mul(right_row, csharp2cuda_temp_215), right_column)];
                    (*(csharp2cuda_temp_212) = __dmul_rn(csharp2cuda_temp_214, csharp2cuda_temp_216));
#line 738 "MatrixModule.cs"
#line 738 "MatrixModule.cs"
                    double csharp2cuda_temp_217 = (result)[flat];
                    if ((!(isfinite(csharp2cuda_temp_217))))
                    {
#line 738 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 728 "MatrixModule.cs"
                int* csharp2cuda_temp_204 = &(flat);
#line 728 "MatrixModule.cs"
                int csharp2cuda_temp_205 = *(csharp2cuda_temp_204);
                (*(csharp2cuda_temp_204) = csharp2cuda_i32_add(csharp2cuda_temp_205, blockDim.x));
            }
        }
#line 740 "MatrixModule.cs"
        return;
    }
#line 743 "MatrixModule.cs"
    if (((opcode) == (14)))
#line 744 "MatrixModule.cs"
    {
#line 745 "MatrixModule.cs"
        if (((thread) == (0)))
#line 746 "MatrixModule.cs"
        {
#line 747 "MatrixModule.cs"
#line 747 "MatrixModule.cs"
            int csharp2cuda_temp_218 = (first)->rows;
            mathblocks_set_vector_shape(output, csharp2cuda_temp_218);
#line 748 "MatrixModule.cs"
#line 748 "MatrixModule.cs"
            int csharp2cuda_temp_219 = (first)->columns;
#line 748 "MatrixModule.cs"
            int csharp2cuda_temp_220 = (second)->count;
            if (((csharp2cuda_temp_219) != (csharp2cuda_temp_220)))
            {
#line 748 "MatrixModule.cs"
#line 748 "MatrixModule.cs"
                int* csharp2cuda_temp_221 = &((output)->valid);
                (*(csharp2cuda_temp_221) = 0);
            }
        }
#line 750 "MatrixModule.cs"
        __syncthreads();
#line 751 "MatrixModule.cs"
        {
#line 751 "MatrixModule.cs"
            int row = thread;
            while (true)
            {
#line 751 "MatrixModule.cs"
                bool csharp2cuda_temp_224 = (output)->valid;
#line 751 "MatrixModule.cs"
                bool csharp2cuda_temp_225;
#line 751 "MatrixModule.cs"
                if (csharp2cuda_temp_224)
                {
#line 751 "MatrixModule.cs"
                    int csharp2cuda_temp_226 = (first)->rows;
#line 751 "MatrixModule.cs"
                    csharp2cuda_temp_225 = ((row) < (csharp2cuda_temp_226));
                }
                else
                {
#line 751 "MatrixModule.cs"
                    csharp2cuda_temp_225 = false;
                }
                if (!(csharp2cuda_temp_225))
                    break;
#line 752 "MatrixModule.cs"
                {
#line 753 "MatrixModule.cs"
                    double sum = 0.0;
#line 754 "MatrixModule.cs"
                    {
#line 754 "MatrixModule.cs"
                        int column = 0;
                        while (true)
                        {
#line 754 "MatrixModule.cs"
                            int csharp2cuda_temp_228 = (first)->columns;
                            if (!(((column) < (csharp2cuda_temp_228))))
                                break;
#line 755 "MatrixModule.cs"
#line 755 "MatrixModule.cs"
                            double* csharp2cuda_temp_229 = &(sum);
#line 755 "MatrixModule.cs"
                            double csharp2cuda_temp_230 = *(csharp2cuda_temp_229);
#line 755 "MatrixModule.cs"
                            int csharp2cuda_temp_231 = (first)->columns;
#line 755 "MatrixModule.cs"
                            double csharp2cuda_temp_232 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_231), column)];
#line 755 "MatrixModule.cs"
                            double csharp2cuda_temp_233 = (b)[column];
                            (*(csharp2cuda_temp_229) = __dadd_rn(csharp2cuda_temp_230, __dmul_rn(csharp2cuda_temp_232, csharp2cuda_temp_233)));
#line 754 "MatrixModule.cs"
                            int* csharp2cuda_temp_227 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_227));
                        }
                    }
#line 756 "MatrixModule.cs"
#line 756 "MatrixModule.cs"
                    double* csharp2cuda_temp_234 = &((result)[row]);
                    (*(csharp2cuda_temp_234) = sum);
#line 757 "MatrixModule.cs"
                    if ((!(isfinite(sum))))
                    {
#line 757 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 751 "MatrixModule.cs"
                int* csharp2cuda_temp_222 = &(row);
#line 751 "MatrixModule.cs"
                int csharp2cuda_temp_223 = *(csharp2cuda_temp_222);
                (*(csharp2cuda_temp_222) = csharp2cuda_i32_add(csharp2cuda_temp_223, blockDim.x));
            }
        }
#line 759 "MatrixModule.cs"
        return;
    }
#line 762 "MatrixModule.cs"
    if (((opcode) == (15)))
#line 763 "MatrixModule.cs"
    {
#line 764 "MatrixModule.cs"
        if (((thread) == (0)))
#line 765 "MatrixModule.cs"
        {
#line 766 "MatrixModule.cs"
#line 766 "MatrixModule.cs"
            int csharp2cuda_temp_235 = (first)->rows;
#line 766 "MatrixModule.cs"
            int csharp2cuda_temp_236 = (second)->columns;
            mathblocks_matrix_shape(output, csharp2cuda_temp_235, csharp2cuda_temp_236);
#line 767 "MatrixModule.cs"
#line 767 "MatrixModule.cs"
            int csharp2cuda_temp_237 = (first)->columns;
#line 767 "MatrixModule.cs"
            int csharp2cuda_temp_238 = (second)->rows;
            if (((csharp2cuda_temp_237) != (csharp2cuda_temp_238)))
            {
#line 767 "MatrixModule.cs"
#line 767 "MatrixModule.cs"
                int* csharp2cuda_temp_239 = &((output)->valid);
                (*(csharp2cuda_temp_239) = 0);
            }
        }
#line 769 "MatrixModule.cs"
        __syncthreads();
#line 770 "MatrixModule.cs"
        {
#line 770 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 770 "MatrixModule.cs"
                bool csharp2cuda_temp_242 = (output)->valid;
#line 770 "MatrixModule.cs"
                bool csharp2cuda_temp_243;
#line 770 "MatrixModule.cs"
                if (csharp2cuda_temp_242)
                {
#line 770 "MatrixModule.cs"
                    int csharp2cuda_temp_244 = (output)->count;
#line 770 "MatrixModule.cs"
                    csharp2cuda_temp_243 = ((flat) < (csharp2cuda_temp_244));
                }
                else
                {
#line 770 "MatrixModule.cs"
                    csharp2cuda_temp_243 = false;
                }
                if (!(csharp2cuda_temp_243))
                    break;
#line 771 "MatrixModule.cs"
                {
#line 772 "MatrixModule.cs"
                    int csharp2cuda_temp_245 = (second)->columns;
#line 772 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, csharp2cuda_temp_245);
#line 773 "MatrixModule.cs"
                    int csharp2cuda_temp_246 = (second)->columns;
#line 773 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, csharp2cuda_temp_246));
#line 774 "MatrixModule.cs"
                    double sum = 0.0;
#line 775 "MatrixModule.cs"
                    {
#line 775 "MatrixModule.cs"
                        int inner = 0;
                        while (true)
                        {
#line 775 "MatrixModule.cs"
                            int csharp2cuda_temp_248 = (first)->columns;
                            if (!(((inner) < (csharp2cuda_temp_248))))
                                break;
#line 776 "MatrixModule.cs"
#line 776 "MatrixModule.cs"
                            double* csharp2cuda_temp_249 = &(sum);
#line 776 "MatrixModule.cs"
                            double csharp2cuda_temp_250 = *(csharp2cuda_temp_249);
#line 776 "MatrixModule.cs"
                            int csharp2cuda_temp_251 = (first)->columns;
#line 776 "MatrixModule.cs"
                            double csharp2cuda_temp_252 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_251), inner)];
#line 776 "MatrixModule.cs"
                            int csharp2cuda_temp_253 = (second)->columns;
#line 776 "MatrixModule.cs"
                            double csharp2cuda_temp_254 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_253), column)];
                            (*(csharp2cuda_temp_249) = __dadd_rn(csharp2cuda_temp_250, __dmul_rn(csharp2cuda_temp_252, csharp2cuda_temp_254)));
#line 775 "MatrixModule.cs"
                            int* csharp2cuda_temp_247 = &(inner);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_247));
                        }
                    }
#line 777 "MatrixModule.cs"
#line 777 "MatrixModule.cs"
                    double* csharp2cuda_temp_255 = &((result)[flat]);
                    (*(csharp2cuda_temp_255) = sum);
#line 778 "MatrixModule.cs"
                    if ((!(isfinite(sum))))
                    {
#line 778 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 770 "MatrixModule.cs"
                int* csharp2cuda_temp_240 = &(flat);
#line 770 "MatrixModule.cs"
                int csharp2cuda_temp_241 = *(csharp2cuda_temp_240);
                (*(csharp2cuda_temp_240) = csharp2cuda_i32_add(csharp2cuda_temp_241, blockDim.x));
            }
        }
#line 780 "MatrixModule.cs"
        return;
    }
#line 783 "MatrixModule.cs"
    if (((opcode) == (16)))
#line 784 "MatrixModule.cs"
    {
#line 785 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 785 "MatrixModule.cs"
#line 785 "MatrixModule.cs"
            int csharp2cuda_temp_256 = (first)->count;
#line 785 "MatrixModule.cs"
            int csharp2cuda_temp_257 = (second)->count;
            mathblocks_matrix_shape(output, csharp2cuda_temp_256, csharp2cuda_temp_257);
        }
#line 786 "MatrixModule.cs"
        __syncthreads();
#line 787 "MatrixModule.cs"
        {
#line 787 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 787 "MatrixModule.cs"
                bool csharp2cuda_temp_260 = (output)->valid;
#line 787 "MatrixModule.cs"
                bool csharp2cuda_temp_261;
#line 787 "MatrixModule.cs"
                if (csharp2cuda_temp_260)
                {
#line 787 "MatrixModule.cs"
                    int csharp2cuda_temp_262 = (output)->count;
#line 787 "MatrixModule.cs"
                    csharp2cuda_temp_261 = ((flat) < (csharp2cuda_temp_262));
                }
                else
                {
#line 787 "MatrixModule.cs"
                    csharp2cuda_temp_261 = false;
                }
                if (!(csharp2cuda_temp_261))
                    break;
#line 788 "MatrixModule.cs"
                {
#line 789 "MatrixModule.cs"
                    int csharp2cuda_temp_263 = (second)->count;
#line 789 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, csharp2cuda_temp_263);
#line 790 "MatrixModule.cs"
                    int csharp2cuda_temp_264 = (second)->count;
#line 790 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, csharp2cuda_temp_264));
#line 791 "MatrixModule.cs"
#line 791 "MatrixModule.cs"
                    double* csharp2cuda_temp_265 = &((result)[flat]);
#line 791 "MatrixModule.cs"
                    double csharp2cuda_temp_266 = (a)[row];
#line 791 "MatrixModule.cs"
                    double csharp2cuda_temp_267 = (b)[column];
                    (*(csharp2cuda_temp_265) = __dmul_rn(csharp2cuda_temp_266, csharp2cuda_temp_267));
#line 792 "MatrixModule.cs"
#line 792 "MatrixModule.cs"
                    double csharp2cuda_temp_268 = (result)[flat];
                    if ((!(isfinite(csharp2cuda_temp_268))))
                    {
#line 792 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 787 "MatrixModule.cs"
                int* csharp2cuda_temp_258 = &(flat);
#line 787 "MatrixModule.cs"
                int csharp2cuda_temp_259 = *(csharp2cuda_temp_258);
                (*(csharp2cuda_temp_258) = csharp2cuda_i32_add(csharp2cuda_temp_259, blockDim.x));
            }
        }
#line 794 "MatrixModule.cs"
        return;
    }
#line 797 "MatrixModule.cs"
    if (((opcode) == (17)))
#line 798 "MatrixModule.cs"
    {
#line 799 "MatrixModule.cs"
        int rows = 0;
#line 800 "MatrixModule.cs"
        int columns = 0;
#line 801 "MatrixModule.cs"
        double csharp2cuda_temp_269 = (second)->scalar_value;
#line 801 "MatrixModule.cs"
        int* csharp2cuda_temp_270 = &(rows);
#line 801 "MatrixModule.cs"
        bool valid_rows = mathblocks_nonnegative_integer(csharp2cuda_temp_269, csharp2cuda_temp_270);
#line 802 "MatrixModule.cs"
        double csharp2cuda_temp_271 = (third)->scalar_value;
#line 802 "MatrixModule.cs"
        int* csharp2cuda_temp_272 = &(columns);
#line 802 "MatrixModule.cs"
        bool valid_columns = mathblocks_nonnegative_integer(csharp2cuda_temp_271, csharp2cuda_temp_272);
#line 803 "MatrixModule.cs"
        if (((thread) == (0)))
#line 804 "MatrixModule.cs"
        {
#line 805 "MatrixModule.cs"
            mathblocks_matrix_shape(output, rows, columns);
#line 806 "MatrixModule.cs"
#line 806 "MatrixModule.cs"
            bool csharp2cuda_temp_273;
#line 806 "MatrixModule.cs"
            if (!((!(valid_rows))))
            {
#line 806 "MatrixModule.cs"
                csharp2cuda_temp_273 = (!(valid_columns));
            }
            else
            {
#line 806 "MatrixModule.cs"
                csharp2cuda_temp_273 = true;
            }
#line 806 "MatrixModule.cs"
            bool csharp2cuda_temp_274;
#line 806 "MatrixModule.cs"
            if (!(csharp2cuda_temp_273))
            {
#line 806 "MatrixModule.cs"
                csharp2cuda_temp_274 = ((rows) <= (0));
            }
            else
            {
#line 806 "MatrixModule.cs"
                csharp2cuda_temp_274 = true;
            }
#line 806 "MatrixModule.cs"
            bool csharp2cuda_temp_275;
#line 806 "MatrixModule.cs"
            if (!(csharp2cuda_temp_274))
            {
#line 806 "MatrixModule.cs"
                csharp2cuda_temp_275 = ((columns) <= (0));
            }
            else
            {
#line 806 "MatrixModule.cs"
                csharp2cuda_temp_275 = true;
            }
#line 806 "MatrixModule.cs"
            bool csharp2cuda_temp_276;
#line 806 "MatrixModule.cs"
            if (!(csharp2cuda_temp_275))
            {
#line 807 "MatrixModule.cs"
                int csharp2cuda_temp_277 = (first)->count;
#line 806 "MatrixModule.cs"
                csharp2cuda_temp_276 = ((csharp2cuda_i64_mul(((long long)(rows)), ((long long)(columns)))) != (((long long)(csharp2cuda_temp_277))));
            }
            else
            {
#line 806 "MatrixModule.cs"
                csharp2cuda_temp_276 = true;
            }
            if (csharp2cuda_temp_276)
#line 808 "MatrixModule.cs"
            {
#line 809 "MatrixModule.cs"
#line 809 "MatrixModule.cs"
                int* csharp2cuda_temp_278 = &((output)->valid);
                (*(csharp2cuda_temp_278) = 0);
            }
        }
#line 812 "MatrixModule.cs"
        __syncthreads();
#line 813 "MatrixModule.cs"
        {
#line 813 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 813 "MatrixModule.cs"
                bool csharp2cuda_temp_281 = (output)->valid;
#line 813 "MatrixModule.cs"
                bool csharp2cuda_temp_282;
#line 813 "MatrixModule.cs"
                if (csharp2cuda_temp_281)
                {
#line 813 "MatrixModule.cs"
                    int csharp2cuda_temp_283 = (first)->count;
#line 813 "MatrixModule.cs"
                    csharp2cuda_temp_282 = ((index) < (csharp2cuda_temp_283));
                }
                else
                {
#line 813 "MatrixModule.cs"
                    csharp2cuda_temp_282 = false;
                }
                if (!(csharp2cuda_temp_282))
                    break;
#line 814 "MatrixModule.cs"
#line 814 "MatrixModule.cs"
                double* csharp2cuda_temp_284 = &((result)[index]);
#line 814 "MatrixModule.cs"
                double csharp2cuda_temp_285 = (a)[index];
                (*(csharp2cuda_temp_284) = csharp2cuda_temp_285);
#line 813 "MatrixModule.cs"
                int* csharp2cuda_temp_279 = &(index);
#line 813 "MatrixModule.cs"
                int csharp2cuda_temp_280 = *(csharp2cuda_temp_279);
                (*(csharp2cuda_temp_279) = csharp2cuda_i32_add(csharp2cuda_temp_280, blockDim.x));
            }
        }
#line 815 "MatrixModule.cs"
        return;
    }
#line 818 "MatrixModule.cs"
    if (((opcode) == (20)))
#line 819 "MatrixModule.cs"
    {
#line 820 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 820 "MatrixModule.cs"
#line 820 "MatrixModule.cs"
            int csharp2cuda_temp_286 = (first)->rows;
#line 820 "MatrixModule.cs"
            int csharp2cuda_temp_287 = (first)->columns;
            mathblocks_matrix_shape(output, csharp2cuda_temp_286, csharp2cuda_temp_287);
        }
#line 821 "MatrixModule.cs"
        __syncthreads();
#line 822 "MatrixModule.cs"
        {
#line 822 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 822 "MatrixModule.cs"
                bool csharp2cuda_temp_290 = (output)->valid;
#line 822 "MatrixModule.cs"
                bool csharp2cuda_temp_291;
#line 822 "MatrixModule.cs"
                if (csharp2cuda_temp_290)
                {
#line 822 "MatrixModule.cs"
                    int csharp2cuda_temp_292 = (first)->count;
#line 822 "MatrixModule.cs"
                    csharp2cuda_temp_291 = ((index) < (csharp2cuda_temp_292));
                }
                else
                {
#line 822 "MatrixModule.cs"
                    csharp2cuda_temp_291 = false;
                }
                if (!(csharp2cuda_temp_291))
                    break;
#line 823 "MatrixModule.cs"
                {
#line 824 "MatrixModule.cs"
#line 824 "MatrixModule.cs"
                    double* csharp2cuda_temp_293 = &((result)[index]);
#line 824 "MatrixModule.cs"
                    double csharp2cuda_temp_294 = (a)[index];
#line 824 "MatrixModule.cs"
                    double csharp2cuda_temp_295 = (second)->scalar_value;
                    (*(csharp2cuda_temp_293) = __dmul_rn(csharp2cuda_temp_294, csharp2cuda_temp_295));
#line 825 "MatrixModule.cs"
#line 825 "MatrixModule.cs"
                    double csharp2cuda_temp_296 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_296))))
                    {
#line 825 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 822 "MatrixModule.cs"
                int* csharp2cuda_temp_288 = &(index);
#line 822 "MatrixModule.cs"
                int csharp2cuda_temp_289 = *(csharp2cuda_temp_288);
                (*(csharp2cuda_temp_288) = csharp2cuda_i32_add(csharp2cuda_temp_289, blockDim.x));
            }
        }
#line 827 "MatrixModule.cs"
        return;
    }
#line 830 "MatrixModule.cs"
    if (((opcode) == (21)))
#line 831 "MatrixModule.cs"
    {
#line 832 "MatrixModule.cs"
        if (((thread) == (0)))
#line 833 "MatrixModule.cs"
        {
#line 834 "MatrixModule.cs"
#line 834 "MatrixModule.cs"
            int csharp2cuda_temp_297 = (first)->count;
            mathblocks_matrix_shape(output, 2, csharp2cuda_temp_297);
#line 835 "MatrixModule.cs"
#line 835 "MatrixModule.cs"
            int csharp2cuda_temp_298 = (first)->count;
#line 835 "MatrixModule.cs"
            int csharp2cuda_temp_299 = (second)->count;
            if (((csharp2cuda_temp_298) != (csharp2cuda_temp_299)))
            {
#line 835 "MatrixModule.cs"
#line 835 "MatrixModule.cs"
                int* csharp2cuda_temp_300 = &((output)->valid);
                (*(csharp2cuda_temp_300) = 0);
            }
        }
#line 837 "MatrixModule.cs"
        __syncthreads();
#line 838 "MatrixModule.cs"
        {
#line 838 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 838 "MatrixModule.cs"
                bool csharp2cuda_temp_303 = (output)->valid;
#line 838 "MatrixModule.cs"
                bool csharp2cuda_temp_304;
#line 838 "MatrixModule.cs"
                if (csharp2cuda_temp_303)
                {
#line 838 "MatrixModule.cs"
                    int csharp2cuda_temp_305 = (first)->count;
#line 838 "MatrixModule.cs"
                    csharp2cuda_temp_304 = ((index) < (csharp2cuda_temp_305));
                }
                else
                {
#line 838 "MatrixModule.cs"
                    csharp2cuda_temp_304 = false;
                }
                if (!(csharp2cuda_temp_304))
                    break;
#line 839 "MatrixModule.cs"
                {
#line 840 "MatrixModule.cs"
#line 840 "MatrixModule.cs"
                    double* csharp2cuda_temp_306 = &((result)[index]);
#line 840 "MatrixModule.cs"
                    double csharp2cuda_temp_307 = (a)[index];
                    (*(csharp2cuda_temp_306) = csharp2cuda_temp_307);
#line 841 "MatrixModule.cs"
#line 841 "MatrixModule.cs"
                    int csharp2cuda_temp_308 = (first)->count;
#line 841 "MatrixModule.cs"
                    double* csharp2cuda_temp_309 = &((result)[csharp2cuda_i32_add(csharp2cuda_temp_308, index)]);
#line 841 "MatrixModule.cs"
                    double csharp2cuda_temp_310 = (b)[index];
                    (*(csharp2cuda_temp_309) = csharp2cuda_temp_310);
                }
#line 838 "MatrixModule.cs"
                int* csharp2cuda_temp_301 = &(index);
#line 838 "MatrixModule.cs"
                int csharp2cuda_temp_302 = *(csharp2cuda_temp_301);
                (*(csharp2cuda_temp_301) = csharp2cuda_i32_add(csharp2cuda_temp_302, blockDim.x));
            }
        }
#line 843 "MatrixModule.cs"
        return;
    }
#line 846 "MatrixModule.cs"
    if (((opcode) == (24)))
#line 847 "MatrixModule.cs"
    {
#line 848 "MatrixModule.cs"
        if (((thread) == (0)))
#line 849 "MatrixModule.cs"
        {
#line 850 "MatrixModule.cs"
#line 850 "MatrixModule.cs"
            int csharp2cuda_temp_311 = (first)->rows;
#line 850 "MatrixModule.cs"
            int csharp2cuda_temp_312 = (first)->columns;
            if (((csharp2cuda_temp_311) != (csharp2cuda_temp_312)))
#line 851 "MatrixModule.cs"
            {
#line 852 "MatrixModule.cs"
#line 852 "MatrixModule.cs"
                int* csharp2cuda_temp_313 = &((output)->valid);
                (*(csharp2cuda_temp_313) = 0);
#line 853 "MatrixModule.cs"
                return;
            }
#line 855 "MatrixModule.cs"
            double trace = 0.0;
#line 856 "MatrixModule.cs"
            {
#line 856 "MatrixModule.cs"
                int index = 0;
                while (true)
                {
#line 856 "MatrixModule.cs"
                    int csharp2cuda_temp_315 = (first)->rows;
                    if (!(((index) < (csharp2cuda_temp_315))))
                        break;
#line 857 "MatrixModule.cs"
#line 857 "MatrixModule.cs"
                    double* csharp2cuda_temp_316 = &(trace);
#line 857 "MatrixModule.cs"
                    double csharp2cuda_temp_317 = *(csharp2cuda_temp_316);
#line 857 "MatrixModule.cs"
                    int csharp2cuda_temp_318 = (first)->columns;
#line 857 "MatrixModule.cs"
                    double csharp2cuda_temp_319 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, csharp2cuda_temp_318), index)];
                    (*(csharp2cuda_temp_316) = __dadd_rn(csharp2cuda_temp_317, csharp2cuda_temp_319));
#line 856 "MatrixModule.cs"
                    int* csharp2cuda_temp_314 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_314));
                }
            }
#line 858 "MatrixModule.cs"
#line 858 "MatrixModule.cs"
            double* csharp2cuda_temp_320 = &((output)->scalar_value);
            (*(csharp2cuda_temp_320) = trace);
#line 859 "MatrixModule.cs"
            if ((!(isfinite(trace))))
            {
#line 859 "MatrixModule.cs"
#line 859 "MatrixModule.cs"
                int* csharp2cuda_temp_321 = &((output)->valid);
                (*(csharp2cuda_temp_321) = 0);
            }
        }
#line 861 "MatrixModule.cs"
        return;
    }
#line 864 "MatrixModule.cs"
    if (((opcode) == (25)))
#line 865 "MatrixModule.cs"
    {
#line 866 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 866 "MatrixModule.cs"
#line 866 "MatrixModule.cs"
            int csharp2cuda_temp_322 = (first)->columns;
#line 866 "MatrixModule.cs"
            int csharp2cuda_temp_323 = (first)->rows;
            mathblocks_matrix_shape(output, csharp2cuda_temp_322, csharp2cuda_temp_323);
        }
#line 867 "MatrixModule.cs"
        __syncthreads();
#line 868 "MatrixModule.cs"
        {
#line 868 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 868 "MatrixModule.cs"
                bool csharp2cuda_temp_326 = (output)->valid;
#line 868 "MatrixModule.cs"
                bool csharp2cuda_temp_327;
#line 868 "MatrixModule.cs"
                if (csharp2cuda_temp_326)
                {
#line 868 "MatrixModule.cs"
                    int csharp2cuda_temp_328 = (output)->count;
#line 868 "MatrixModule.cs"
                    csharp2cuda_temp_327 = ((flat) < (csharp2cuda_temp_328));
                }
                else
                {
#line 868 "MatrixModule.cs"
                    csharp2cuda_temp_327 = false;
                }
                if (!(csharp2cuda_temp_327))
                    break;
#line 869 "MatrixModule.cs"
                {
#line 870 "MatrixModule.cs"
                    int csharp2cuda_temp_329 = (first)->rows;
#line 870 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, csharp2cuda_temp_329);
#line 871 "MatrixModule.cs"
                    int csharp2cuda_temp_330 = (first)->rows;
#line 871 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, csharp2cuda_temp_330));
#line 872 "MatrixModule.cs"
#line 872 "MatrixModule.cs"
                    double* csharp2cuda_temp_331 = &((result)[flat]);
#line 872 "MatrixModule.cs"
                    int csharp2cuda_temp_332 = (first)->columns;
#line 872 "MatrixModule.cs"
                    double csharp2cuda_temp_333 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(column, csharp2cuda_temp_332), row)];
                    (*(csharp2cuda_temp_331) = csharp2cuda_temp_333);
                }
#line 868 "MatrixModule.cs"
                int* csharp2cuda_temp_324 = &(flat);
#line 868 "MatrixModule.cs"
                int csharp2cuda_temp_325 = *(csharp2cuda_temp_324);
                (*(csharp2cuda_temp_324) = csharp2cuda_i32_add(csharp2cuda_temp_325, blockDim.x));
            }
        }
#line 874 "MatrixModule.cs"
        return;
    }
#line 877 "MatrixModule.cs"
    if (((thread) != (0)))
    {
#line 878 "MatrixModule.cs"
        return;
    }
#line 880 "MatrixModule.cs"
    if (((opcode) == (26)))
#line 881 "MatrixModule.cs"
    {
#line 882 "MatrixModule.cs"
#line 882 "MatrixModule.cs"
        int csharp2cuda_temp_334 = (first)->rows;
#line 882 "MatrixModule.cs"
        int csharp2cuda_temp_335 = (first)->columns;
#line 882 "MatrixModule.cs"
        bool csharp2cuda_temp_336;
#line 882 "MatrixModule.cs"
        if (!(((csharp2cuda_temp_334) != (csharp2cuda_temp_335))))
        {
#line 882 "MatrixModule.cs"
            csharp2cuda_temp_336 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 882 "MatrixModule.cs"
            csharp2cuda_temp_336 = true;
        }
        if (csharp2cuda_temp_336)
#line 883 "MatrixModule.cs"
        {
#line 884 "MatrixModule.cs"
#line 884 "MatrixModule.cs"
            int* csharp2cuda_temp_337 = &((output)->valid);
            (*(csharp2cuda_temp_337) = 0);
#line 885 "MatrixModule.cs"
            return;
        }
#line 887 "MatrixModule.cs"
#line 887 "MatrixModule.cs"
        double* csharp2cuda_temp_338 = &((output)->scalar_value);
#line 887 "MatrixModule.cs"
        int csharp2cuda_temp_339 = (first)->rows;
#line 887 "MatrixModule.cs"
        double csharp2cuda_temp_340 = mathblocks_matrix_determinant(a, csharp2cuda_temp_339, scratch);
        (*(csharp2cuda_temp_338) = csharp2cuda_temp_340);
#line 888 "MatrixModule.cs"
#line 888 "MatrixModule.cs"
        double csharp2cuda_temp_341 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_341))))
        {
#line 888 "MatrixModule.cs"
#line 888 "MatrixModule.cs"
            int* csharp2cuda_temp_342 = &((output)->valid);
            (*(csharp2cuda_temp_342) = 0);
        }
#line 889 "MatrixModule.cs"
        return;
    }
#line 892 "MatrixModule.cs"
    if (((opcode) == (27)))
#line 893 "MatrixModule.cs"
    {
#line 894 "MatrixModule.cs"
        int size = (first)->rows;
#line 895 "MatrixModule.cs"
        int count = (first)->count;
#line 896 "MatrixModule.cs"
#line 896 "MatrixModule.cs"
        int csharp2cuda_temp_343 = (first)->columns;
#line 896 "MatrixModule.cs"
        bool csharp2cuda_temp_344;
#line 896 "MatrixModule.cs"
        if (!(((size) != (csharp2cuda_temp_343))))
        {
#line 896 "MatrixModule.cs"
            csharp2cuda_temp_344 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 896 "MatrixModule.cs"
            csharp2cuda_temp_344 = true;
        }
        if (csharp2cuda_temp_344)
#line 897 "MatrixModule.cs"
        {
#line 898 "MatrixModule.cs"
#line 898 "MatrixModule.cs"
            int* csharp2cuda_temp_345 = &((output)->valid);
            (*(csharp2cuda_temp_345) = 0);
#line 899 "MatrixModule.cs"
            return;
        }
#line 901 "MatrixModule.cs"
        mathblocks_matrix_shape(output, size, size);
#line 902 "MatrixModule.cs"
        double norm = 0.0;
#line 903 "MatrixModule.cs"
        {
#line 903 "MatrixModule.cs"
            int row = 0;
            while (true)
            {
                if (!(((row) < (size))))
                    break;
#line 904 "MatrixModule.cs"
                {
#line 905 "MatrixModule.cs"
                    double row_sum = 0.0;
#line 906 "MatrixModule.cs"
                    {
#line 906 "MatrixModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (size))))
                                break;
#line 907 "MatrixModule.cs"
#line 907 "MatrixModule.cs"
                            double* csharp2cuda_temp_348 = &(row_sum);
#line 907 "MatrixModule.cs"
                            double csharp2cuda_temp_349 = *(csharp2cuda_temp_348);
#line 907 "MatrixModule.cs"
                            double csharp2cuda_temp_350 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
                            (*(csharp2cuda_temp_348) = __dadd_rn(csharp2cuda_temp_349, fabs(csharp2cuda_temp_350)));
#line 906 "MatrixModule.cs"
                            int* csharp2cuda_temp_347 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_347));
                        }
                    }
#line 908 "MatrixModule.cs"
                    if (((row_sum) > (norm)))
                    {
#line 908 "MatrixModule.cs"
#line 908 "MatrixModule.cs"
                        double* csharp2cuda_temp_351 = &(norm);
                        (*(csharp2cuda_temp_351) = row_sum);
                    }
                }
#line 903 "MatrixModule.cs"
                int* csharp2cuda_temp_346 = &(row);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_346));
            }
        }
#line 911 "MatrixModule.cs"
        if ((!(isfinite(norm))))
#line 912 "MatrixModule.cs"
        {
#line 913 "MatrixModule.cs"
#line 913 "MatrixModule.cs"
            int* csharp2cuda_temp_352 = &((output)->valid);
            (*(csharp2cuda_temp_352) = 0);
#line 914 "MatrixModule.cs"
            return;
        }
#line 918 "MatrixModule.cs"
        double trace = 0.0;
#line 919 "MatrixModule.cs"
        {
#line 919 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (size))))
                    break;
#line 920 "MatrixModule.cs"
#line 920 "MatrixModule.cs"
                double* csharp2cuda_temp_354 = &(trace);
#line 920 "MatrixModule.cs"
                double csharp2cuda_temp_355 = *(csharp2cuda_temp_354);
#line 920 "MatrixModule.cs"
                double csharp2cuda_temp_356 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, size), index)];
                (*(csharp2cuda_temp_354) = __dadd_rn(csharp2cuda_temp_355, csharp2cuda_temp_356));
#line 919 "MatrixModule.cs"
                int* csharp2cuda_temp_353 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_353));
            }
        }
#line 921 "MatrixModule.cs"
#line 921 "MatrixModule.cs"
        double csharp2cuda_temp_357 = __ddiv_rn(trace, ((double)(size)));
        if (((csharp2cuda_temp_357) > (__dadd_rn(709.782712893384, __dmul_rn(0.5, __dmul_rn(mathblocks_binary_logarithm(((double)(size))), 0.6931471805599453))))))
#line 922 "MatrixModule.cs"
        {
#line 923 "MatrixModule.cs"
#line 923 "MatrixModule.cs"
            int* csharp2cuda_temp_358 = &((output)->valid);
            (*(csharp2cuda_temp_358) = 0);
#line 924 "MatrixModule.cs"
            return;
        }
#line 926 "MatrixModule.cs"
        int csharp2cuda_temp_359;
#line 926 "MatrixModule.cs"
        if (((norm) > (1.0)))
        {
#line 926 "MatrixModule.cs"
            csharp2cuda_temp_359 = csharp2cuda_f64_to_i32(ceil(mathblocks_binary_logarithm(norm)));
        }
        else
        {
#line 926 "MatrixModule.cs"
            csharp2cuda_temp_359 = 0;
        }
#line 926 "MatrixModule.cs"
        int scaling = csharp2cuda_temp_359;
#line 927 "MatrixModule.cs"
        if (((scaling) < (0)))
        {
#line 927 "MatrixModule.cs"
#line 927 "MatrixModule.cs"
            int* csharp2cuda_temp_360 = &(scaling);
            (*(csharp2cuda_temp_360) = 0);
        }
#line 928 "MatrixModule.cs"
        double scale = mathblocks_power(2.0, ((double)(csharp2cuda_i32_neg(scaling))));
#line 929 "MatrixModule.cs"
        double* scaled = scratch;
#line 930 "MatrixModule.cs"
        double* term = csharp2cuda_pointer_add(scratch, count);
#line 931 "MatrixModule.cs"
        double* temporary = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(count, 2));
#line 932 "MatrixModule.cs"
        {
#line 932 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 933 "MatrixModule.cs"
                {
#line 934 "MatrixModule.cs"
#line 934 "MatrixModule.cs"
                    double* csharp2cuda_temp_362 = &((scaled)[index]);
#line 934 "MatrixModule.cs"
                    double csharp2cuda_temp_363 = (a)[index];
                    (*(csharp2cuda_temp_362) = __dmul_rn(csharp2cuda_temp_363, scale));
#line 935 "MatrixModule.cs"
#line 935 "MatrixModule.cs"
                    double* csharp2cuda_temp_364 = &((result)[index]);
                    (*(csharp2cuda_temp_364) = 0.0);
#line 936 "MatrixModule.cs"
#line 936 "MatrixModule.cs"
                    double* csharp2cuda_temp_365 = &((term)[index]);
                    (*(csharp2cuda_temp_365) = 0.0);
                }
#line 932 "MatrixModule.cs"
                int* csharp2cuda_temp_361 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_361));
            }
        }
#line 938 "MatrixModule.cs"
        {
#line 938 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (size))))
                    break;
#line 939 "MatrixModule.cs"
                {
#line 940 "MatrixModule.cs"
#line 940 "MatrixModule.cs"
                    double* csharp2cuda_temp_367 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, size), index)]);
                    (*(csharp2cuda_temp_367) = 1.0);
#line 941 "MatrixModule.cs"
#line 941 "MatrixModule.cs"
                    double* csharp2cuda_temp_368 = &((term)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, size), index)]);
                    (*(csharp2cuda_temp_368) = 1.0);
                }
#line 938 "MatrixModule.cs"
                int* csharp2cuda_temp_366 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_366));
            }
        }
#line 943 "MatrixModule.cs"
        {
#line 943 "MatrixModule.cs"
            int order = 1;
            while (true)
            {
                if (!(((order) <= (mathblocks_limit_matrix_exponential_taylor_terms()))))
                    break;
#line 944 "MatrixModule.cs"
                {
#line 945 "MatrixModule.cs"
                    mathblocks_matrix_multiply_square(term, scaled, size, temporary);
#line 946 "MatrixModule.cs"
                    double order_scale = __ddiv_rn(1.0, ((double)(order)));
#line 947 "MatrixModule.cs"
                    {
#line 947 "MatrixModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (count))))
                                break;
#line 948 "MatrixModule.cs"
                            {
#line 949 "MatrixModule.cs"
#line 949 "MatrixModule.cs"
                                double* csharp2cuda_temp_371 = &((term)[index]);
#line 949 "MatrixModule.cs"
                                double csharp2cuda_temp_372 = (temporary)[index];
                                (*(csharp2cuda_temp_371) = __dmul_rn(csharp2cuda_temp_372, order_scale));
#line 950 "MatrixModule.cs"
#line 950 "MatrixModule.cs"
                                double* csharp2cuda_temp_373 = &((result)[index]);
#line 950 "MatrixModule.cs"
                                double csharp2cuda_temp_374 = *(csharp2cuda_temp_373);
#line 950 "MatrixModule.cs"
                                double csharp2cuda_temp_375 = (term)[index];
                                (*(csharp2cuda_temp_373) = __dadd_rn(csharp2cuda_temp_374, csharp2cuda_temp_375));
                            }
#line 947 "MatrixModule.cs"
                            int* csharp2cuda_temp_370 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_370));
                        }
                    }
                }
#line 943 "MatrixModule.cs"
                int* csharp2cuda_temp_369 = &(order);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_369));
            }
        }
#line 953 "MatrixModule.cs"
        {
#line 953 "MatrixModule.cs"
            int iteration = 0;
            while (true)
            {
                if (!(((iteration) < (scaling))))
                    break;
#line 954 "MatrixModule.cs"
                {
#line 955 "MatrixModule.cs"
                    mathblocks_matrix_multiply_square(result, result, size, temporary);
#line 956 "MatrixModule.cs"
                    mathblocks_matrix_copy(temporary, result, count);
                }
#line 953 "MatrixModule.cs"
                int* csharp2cuda_temp_376 = &(iteration);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_376));
            }
        }
#line 958 "MatrixModule.cs"
        {
#line 958 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 959 "MatrixModule.cs"
#line 959 "MatrixModule.cs"
                double csharp2cuda_temp_378 = (result)[index];
                if ((!(isfinite(csharp2cuda_temp_378))))
                {
#line 959 "MatrixModule.cs"
#line 959 "MatrixModule.cs"
                    int* csharp2cuda_temp_379 = &((output)->valid);
                    (*(csharp2cuda_temp_379) = 0);
                }
#line 958 "MatrixModule.cs"
                int* csharp2cuda_temp_377 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_377));
            }
        }
#line 960 "MatrixModule.cs"
        return;
    }
#line 963 "MatrixModule.cs"
    if (((opcode) == (28)))
#line 964 "MatrixModule.cs"
    {
#line 965 "MatrixModule.cs"
        int exponent = 0;
#line 966 "MatrixModule.cs"
#line 966 "MatrixModule.cs"
        int csharp2cuda_temp_380 = (first)->rows;
#line 966 "MatrixModule.cs"
        int csharp2cuda_temp_381 = (first)->columns;
#line 966 "MatrixModule.cs"
        bool csharp2cuda_temp_382;
#line 966 "MatrixModule.cs"
        if (!(((csharp2cuda_temp_380) != (csharp2cuda_temp_381))))
        {
#line 967 "MatrixModule.cs"
            double csharp2cuda_temp_383 = (second)->scalar_value;
#line 967 "MatrixModule.cs"
            int* csharp2cuda_temp_384 = &(exponent);
#line 967 "MatrixModule.cs"
            bool csharp2cuda_temp_385 = mathblocks_nonnegative_integer(csharp2cuda_temp_383, csharp2cuda_temp_384);
#line 966 "MatrixModule.cs"
            csharp2cuda_temp_382 = (!(csharp2cuda_temp_385));
        }
        else
        {
#line 966 "MatrixModule.cs"
            csharp2cuda_temp_382 = true;
        }
#line 966 "MatrixModule.cs"
        bool csharp2cuda_temp_386;
#line 966 "MatrixModule.cs"
        if (!(csharp2cuda_temp_382))
        {
#line 966 "MatrixModule.cs"
            csharp2cuda_temp_386 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 966 "MatrixModule.cs"
            csharp2cuda_temp_386 = true;
        }
        if (csharp2cuda_temp_386)
#line 969 "MatrixModule.cs"
        {
#line 970 "MatrixModule.cs"
#line 970 "MatrixModule.cs"
            int* csharp2cuda_temp_387 = &((output)->valid);
            (*(csharp2cuda_temp_387) = 0);
#line 971 "MatrixModule.cs"
            return;
        }
#line 973 "MatrixModule.cs"
        int size = (first)->rows;
#line 974 "MatrixModule.cs"
        int count = (first)->count;
#line 975 "MatrixModule.cs"
        mathblocks_matrix_shape(output, size, size);
#line 976 "MatrixModule.cs"
        double* power = scratch;
#line 977 "MatrixModule.cs"
        double* temporary = csharp2cuda_pointer_add(scratch, count);
#line 978 "MatrixModule.cs"
        mathblocks_matrix_copy(a, power, count);
#line 979 "MatrixModule.cs"
        {
#line 979 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 980 "MatrixModule.cs"
#line 980 "MatrixModule.cs"
                double* csharp2cuda_temp_389 = &((result)[index]);
                (*(csharp2cuda_temp_389) = 0.0);
#line 979 "MatrixModule.cs"
                int* csharp2cuda_temp_388 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_388));
            }
        }
#line 981 "MatrixModule.cs"
        {
#line 981 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (size))))
                    break;
#line 982 "MatrixModule.cs"
#line 982 "MatrixModule.cs"
                double* csharp2cuda_temp_391 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, size), index)]);
                (*(csharp2cuda_temp_391) = 1.0);
#line 981 "MatrixModule.cs"
                int* csharp2cuda_temp_390 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_390));
            }
        }
#line 983 "MatrixModule.cs"
        while (true)
        {
            if (!(((exponent) > (0))))
                break;
#line 984 "MatrixModule.cs"
            {
#line 985 "MatrixModule.cs"
                if (((csharp2cuda_i32_and(exponent, 1)) != (0)))
#line 986 "MatrixModule.cs"
                {
#line 987 "MatrixModule.cs"
                    mathblocks_matrix_multiply_square(result, power, size, temporary);
#line 988 "MatrixModule.cs"
                    mathblocks_matrix_copy(temporary, result, count);
                }
#line 990 "MatrixModule.cs"
#line 990 "MatrixModule.cs"
                int* csharp2cuda_temp_392 = &(exponent);
#line 990 "MatrixModule.cs"
                int csharp2cuda_temp_393 = *(csharp2cuda_temp_392);
                (*(csharp2cuda_temp_392) = csharp2cuda_i32_shr(csharp2cuda_temp_393, 1));
#line 991 "MatrixModule.cs"
                if (((exponent) > (0)))
#line 992 "MatrixModule.cs"
                {
#line 993 "MatrixModule.cs"
                    mathblocks_matrix_multiply_square(power, power, size, temporary);
#line 994 "MatrixModule.cs"
                    mathblocks_matrix_copy(temporary, power, count);
                }
            }
        }
#line 997 "MatrixModule.cs"
        {
#line 997 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 998 "MatrixModule.cs"
#line 998 "MatrixModule.cs"
                double csharp2cuda_temp_395 = (result)[index];
                if ((!(isfinite(csharp2cuda_temp_395))))
                {
#line 998 "MatrixModule.cs"
#line 998 "MatrixModule.cs"
                    int* csharp2cuda_temp_396 = &((output)->valid);
                    (*(csharp2cuda_temp_396) = 0);
                }
#line 997 "MatrixModule.cs"
                int* csharp2cuda_temp_394 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_394));
            }
        }
#line 999 "MatrixModule.cs"
        return;
    }
#line 1002 "MatrixModule.cs"
    if (((opcode) == (29)))
#line 1003 "MatrixModule.cs"
    {
#line 1004 "MatrixModule.cs"
        int size = (first)->rows;
#line 1005 "MatrixModule.cs"
#line 1005 "MatrixModule.cs"
        int csharp2cuda_temp_397 = (first)->columns;
#line 1005 "MatrixModule.cs"
        bool csharp2cuda_temp_398;
#line 1005 "MatrixModule.cs"
        if (!(((size) != (csharp2cuda_temp_397))))
        {
#line 1005 "MatrixModule.cs"
            csharp2cuda_temp_398 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1005 "MatrixModule.cs"
            csharp2cuda_temp_398 = true;
        }
        if (csharp2cuda_temp_398)
#line 1006 "MatrixModule.cs"
        {
#line 1007 "MatrixModule.cs"
#line 1007 "MatrixModule.cs"
            int* csharp2cuda_temp_399 = &((output)->valid);
            (*(csharp2cuda_temp_399) = 0);
#line 1008 "MatrixModule.cs"
            return;
        }
#line 1010 "MatrixModule.cs"
        mathblocks_matrix_shape(output, size, size);
#line 1011 "MatrixModule.cs"
        double* augmented = scratch;
#line 1012 "MatrixModule.cs"
        double* solution = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(size, csharp2cuda_i32_add(size, 1)));
#line 1013 "MatrixModule.cs"
        {
#line 1013 "MatrixModule.cs"
            int column = 0;
            while (true)
            {
                if (!(((column) < (size))))
                    break;
#line 1014 "MatrixModule.cs"
                {
#line 1015 "MatrixModule.cs"
#line 1015 "MatrixModule.cs"
                    bool csharp2cuda_temp_401 = mathblocks_matrix_try_solve_basis(a, size, column, augmented, solution);
                    if ((!(csharp2cuda_temp_401)))
#line 1016 "MatrixModule.cs"
                    {
#line 1017 "MatrixModule.cs"
#line 1017 "MatrixModule.cs"
                        int* csharp2cuda_temp_402 = &((output)->valid);
                        (*(csharp2cuda_temp_402) = 0);
#line 1018 "MatrixModule.cs"
                        return;
                    }
#line 1020 "MatrixModule.cs"
                    {
#line 1020 "MatrixModule.cs"
                        int row = 0;
                        while (true)
                        {
                            if (!(((row) < (size))))
                                break;
#line 1021 "MatrixModule.cs"
#line 1021 "MatrixModule.cs"
                            double* csharp2cuda_temp_404 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)]);
#line 1021 "MatrixModule.cs"
                            double csharp2cuda_temp_405 = (solution)[row];
                            (*(csharp2cuda_temp_404) = csharp2cuda_temp_405);
#line 1020 "MatrixModule.cs"
                            int* csharp2cuda_temp_403 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_403));
                        }
                    }
                }
#line 1013 "MatrixModule.cs"
                int* csharp2cuda_temp_400 = &(column);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_400));
            }
        }
#line 1023 "MatrixModule.cs"
        return;
    }
#line 1026 "MatrixModule.cs"
    if (((opcode) == (30)))
#line 1027 "MatrixModule.cs"
    {
#line 1028 "MatrixModule.cs"
#line 1028 "MatrixModule.cs"
        int* csharp2cuda_temp_406 = &((output)->boolean_value);
#line 1028 "MatrixModule.cs"
        int csharp2cuda_temp_407 = (first)->rows;
#line 1028 "MatrixModule.cs"
        int csharp2cuda_temp_408 = (first)->columns;
#line 1028 "MatrixModule.cs"
        bool csharp2cuda_temp_409;
#line 1028 "MatrixModule.cs"
        if (((csharp2cuda_temp_407) == (csharp2cuda_temp_408)))
        {
#line 1028 "MatrixModule.cs"
            csharp2cuda_temp_409 = ((((void*)(scratch))) != (((void*)(nullptr))));
        }
        else
        {
#line 1028 "MatrixModule.cs"
            csharp2cuda_temp_409 = false;
        }
#line 1028 "MatrixModule.cs"
        bool csharp2cuda_temp_410;
#line 1028 "MatrixModule.cs"
        if (csharp2cuda_temp_409)
        {
#line 1029 "MatrixModule.cs"
            int csharp2cuda_temp_411 = (first)->rows;
#line 1028 "MatrixModule.cs"
            csharp2cuda_temp_410 = mathblocks_matrix_is_positive_definite(a, csharp2cuda_temp_411, scratch);
        }
        else
        {
#line 1028 "MatrixModule.cs"
            csharp2cuda_temp_410 = false;
        }
        (*(csharp2cuda_temp_406) = csharp2cuda_temp_410);
#line 1030 "MatrixModule.cs"
        return;
    }
#line 1033 "MatrixModule.cs"
    if (((opcode) == (31)))
#line 1034 "MatrixModule.cs"
    {
#line 1035 "MatrixModule.cs"
#line 1035 "MatrixModule.cs"
        int* csharp2cuda_temp_412 = &((output)->boolean_value);
#line 1035 "MatrixModule.cs"
        int csharp2cuda_temp_413 = (first)->rows;
#line 1035 "MatrixModule.cs"
        int csharp2cuda_temp_414 = (first)->columns;
#line 1035 "MatrixModule.cs"
        int csharp2cuda_temp_415 = mathblocks_matrix_is_symmetric(a, csharp2cuda_temp_413, csharp2cuda_temp_414);
        (*(csharp2cuda_temp_412) = csharp2cuda_temp_415);
#line 1036 "MatrixModule.cs"
        return;
    }
#line 1039 "MatrixModule.cs"
    if (((opcode) == (32)))
#line 1040 "MatrixModule.cs"
    {
#line 1041 "MatrixModule.cs"
#line 1041 "MatrixModule.cs"
        int csharp2cuda_temp_416 = (first)->rows;
#line 1041 "MatrixModule.cs"
        bool csharp2cuda_temp_417;
#line 1041 "MatrixModule.cs"
        if (!(((csharp2cuda_temp_416) > (mathblocks_limit_totally_nonnegative_size()))))
        {
#line 1041 "MatrixModule.cs"
            int csharp2cuda_temp_418 = (first)->columns;
#line 1041 "MatrixModule.cs"
            csharp2cuda_temp_417 = ((csharp2cuda_temp_418) > (mathblocks_limit_totally_nonnegative_size()));
        }
        else
        {
#line 1041 "MatrixModule.cs"
            csharp2cuda_temp_417 = true;
        }
#line 1041 "MatrixModule.cs"
        bool csharp2cuda_temp_419;
#line 1041 "MatrixModule.cs"
        if (!(csharp2cuda_temp_417))
        {
#line 1041 "MatrixModule.cs"
            csharp2cuda_temp_419 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1041 "MatrixModule.cs"
            csharp2cuda_temp_419 = true;
        }
        if (csharp2cuda_temp_419)
#line 1042 "MatrixModule.cs"
        {
#line 1043 "MatrixModule.cs"
#line 1043 "MatrixModule.cs"
            int* csharp2cuda_temp_420 = &((output)->valid);
            (*(csharp2cuda_temp_420) = 0);
#line 1044 "MatrixModule.cs"
            return;
        }
#line 1046 "MatrixModule.cs"
        double* submatrix = scratch;
#line 1047 "MatrixModule.cs"
        int csharp2cuda_temp_421 = (first)->count;
#line 1047 "MatrixModule.cs"
        double* work = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_421);
#line 1048 "MatrixModule.cs"
#line 1048 "MatrixModule.cs"
        int* csharp2cuda_temp_422 = &((output)->boolean_value);
        (*(csharp2cuda_temp_422) = 1);
#line 1049 "MatrixModule.cs"
        {
#line 1049 "MatrixModule.cs"
            int order = 1;
            while (true)
            {
#line 1049 "MatrixModule.cs"
                bool csharp2cuda_temp_424 = (output)->boolean_value;
#line 1049 "MatrixModule.cs"
                bool csharp2cuda_temp_425;
#line 1049 "MatrixModule.cs"
                if (csharp2cuda_temp_424)
                {
#line 1050 "MatrixModule.cs"
                    int csharp2cuda_temp_426 = (first)->rows;
#line 1050 "MatrixModule.cs"
                    int csharp2cuda_temp_427 = (first)->columns;
#line 1050 "MatrixModule.cs"
                    int csharp2cuda_temp_428;
#line 1050 "MatrixModule.cs"
                    if (((csharp2cuda_temp_426) < (csharp2cuda_temp_427)))
                    {
#line 1050 "MatrixModule.cs"
                        csharp2cuda_temp_428 = (first)->rows;
                    }
                    else
                    {
#line 1050 "MatrixModule.cs"
                        csharp2cuda_temp_428 = (first)->columns;
                    }
#line 1049 "MatrixModule.cs"
                    csharp2cuda_temp_425 = ((order) <= (csharp2cuda_temp_428));
                }
                else
                {
#line 1049 "MatrixModule.cs"
                    csharp2cuda_temp_425 = false;
                }
                if (!(csharp2cuda_temp_425))
                    break;
#line 1051 "MatrixModule.cs"
                {
#line 1052 "MatrixModule.cs"
                    int csharp2cuda_temp_429 = (first)->rows;
#line 1052 "MatrixModule.cs"
                    int row_limit = csharp2cuda_i32_shl(1, csharp2cuda_temp_429);
#line 1053 "MatrixModule.cs"
                    int csharp2cuda_temp_430 = (first)->columns;
#line 1053 "MatrixModule.cs"
                    int column_limit = csharp2cuda_i32_shl(1, csharp2cuda_temp_430);
#line 1054 "MatrixModule.cs"
                    {
#line 1054 "MatrixModule.cs"
                        int row_mask = 1;
                        while (true)
                        {
#line 1054 "MatrixModule.cs"
                            bool csharp2cuda_temp_432 = (output)->boolean_value;
#line 1054 "MatrixModule.cs"
                            bool csharp2cuda_temp_433;
#line 1054 "MatrixModule.cs"
                            if (csharp2cuda_temp_432)
                            {
#line 1054 "MatrixModule.cs"
                                csharp2cuda_temp_433 = ((row_mask) < (row_limit));
                            }
                            else
                            {
#line 1054 "MatrixModule.cs"
                                csharp2cuda_temp_433 = false;
                            }
                            if (!(csharp2cuda_temp_433))
                                break;
#line 1055 "MatrixModule.cs"
                            {
#line 1056 "MatrixModule.cs"
                                if (((mathblocks_pop_count(row_mask)) != (order)))
                                {
#line 1057 "MatrixModule.cs"
                                    goto csharp2cuda_for_continue_42;
                                }
#line 1058 "MatrixModule.cs"
                                {
#line 1058 "MatrixModule.cs"
                                    int column_mask = 1;
                                    while (true)
                                    {
                                        if (!(((column_mask) < (column_limit))))
                                            break;
#line 1059 "MatrixModule.cs"
                                        {
#line 1060 "MatrixModule.cs"
                                            if (((mathblocks_pop_count(column_mask)) != (order)))
                                            {
#line 1061 "MatrixModule.cs"
                                                goto csharp2cuda_for_continue_41;
                                            }
#line 1062 "MatrixModule.cs"
#line 1064 "MatrixModule.cs"
                                            int csharp2cuda_temp_435 = (first)->columns;
                                            mathblocks_matrix_submatrix_from_masks(a, csharp2cuda_temp_435, row_mask, column_mask, order, submatrix);
#line 1069 "MatrixModule.cs"
#line 1069 "MatrixModule.cs"
                                            double csharp2cuda_temp_436 = mathblocks_matrix_determinant(submatrix, order, work);
                                            if (((csharp2cuda_temp_436) < (0.0)))
#line 1070 "MatrixModule.cs"
                                            {
#line 1071 "MatrixModule.cs"
#line 1071 "MatrixModule.cs"
                                                int* csharp2cuda_temp_437 = &((output)->boolean_value);
                                                (*(csharp2cuda_temp_437) = 0);
#line 1072 "MatrixModule.cs"
                                                break;
                                            }
                                        }
                                        csharp2cuda_for_continue_41:
#line 1058 "MatrixModule.cs"
                                        int* csharp2cuda_temp_434 = &(column_mask);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_434));
                                    }
                                }
                            }
                            csharp2cuda_for_continue_42:
#line 1054 "MatrixModule.cs"
                            int* csharp2cuda_temp_431 = &(row_mask);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_431));
                        }
                    }
                }
#line 1050 "MatrixModule.cs"
                int* csharp2cuda_temp_423 = &(order);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_423));
            }
        }
#line 1077 "MatrixModule.cs"
        return;
    }
#line 1080 "MatrixModule.cs"
#line 1080 "MatrixModule.cs"
    bool csharp2cuda_temp_438;
#line 1080 "MatrixModule.cs"
    if (!(((opcode) == (33))))
    {
#line 1080 "MatrixModule.cs"
        csharp2cuda_temp_438 = ((opcode) == (40));
    }
    else
    {
#line 1080 "MatrixModule.cs"
        csharp2cuda_temp_438 = true;
    }
#line 1080 "MatrixModule.cs"
    bool csharp2cuda_temp_439;
#line 1080 "MatrixModule.cs"
    if (!(csharp2cuda_temp_438))
    {
#line 1080 "MatrixModule.cs"
        csharp2cuda_temp_439 = ((opcode) == (43));
    }
    else
    {
#line 1080 "MatrixModule.cs"
        csharp2cuda_temp_439 = true;
    }
    if (csharp2cuda_temp_439)
#line 1081 "MatrixModule.cs"
    {
#line 1082 "MatrixModule.cs"
        int size = (first)->rows;
#line 1083 "MatrixModule.cs"
#line 1083 "MatrixModule.cs"
        int csharp2cuda_temp_440 = (first)->columns;
#line 1083 "MatrixModule.cs"
        bool csharp2cuda_temp_441;
#line 1083 "MatrixModule.cs"
        if (!(((size) != (csharp2cuda_temp_440))))
        {
#line 1083 "MatrixModule.cs"
            csharp2cuda_temp_441 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1083 "MatrixModule.cs"
            csharp2cuda_temp_441 = true;
        }
        if (csharp2cuda_temp_441)
#line 1084 "MatrixModule.cs"
        {
#line 1085 "MatrixModule.cs"
#line 1085 "MatrixModule.cs"
            int* csharp2cuda_temp_442 = &((output)->valid);
            (*(csharp2cuda_temp_442) = 0);
#line 1086 "MatrixModule.cs"
            return;
        }
#line 1088 "MatrixModule.cs"
        double* csharp2cuda_temp_443;
#line 1088 "MatrixModule.cs"
        if (((opcode) == (43)))
        {
#line 1088 "MatrixModule.cs"
            csharp2cuda_temp_443 = result;
        }
        else
        {
#line 1088 "MatrixModule.cs"
            int csharp2cuda_temp_444 = (first)->count;
#line 1088 "MatrixModule.cs"
            csharp2cuda_temp_443 = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_444);
        }
#line 1088 "MatrixModule.cs"
        double* eigenvalues = csharp2cuda_temp_443;
#line 1089 "MatrixModule.cs"
#line 1089 "MatrixModule.cs"
        bool csharp2cuda_temp_445;
#line 1089 "MatrixModule.cs"
        if (((opcode) == (43)))
        {
#line 1089 "MatrixModule.cs"
            bool csharp2cuda_temp_446 = mathblocks_matrix_is_symmetric(a, size, size);
#line 1089 "MatrixModule.cs"
            csharp2cuda_temp_445 = (!(csharp2cuda_temp_446));
        }
        else
        {
#line 1089 "MatrixModule.cs"
            csharp2cuda_temp_445 = false;
        }
        if (csharp2cuda_temp_445)
#line 1090 "MatrixModule.cs"
        {
#line 1091 "MatrixModule.cs"
#line 1091 "MatrixModule.cs"
            int* csharp2cuda_temp_447 = &((output)->valid);
            (*(csharp2cuda_temp_447) = 0);
#line 1092 "MatrixModule.cs"
            return;
        }
#line 1094 "MatrixModule.cs"
        if (((opcode) == (43)))
        {
#line 1094 "MatrixModule.cs"
            mathblocks_set_vector_shape(output, size);
        }
#line 1095 "MatrixModule.cs"
        int csharp2cuda_temp_448 = (first)->count;
#line 1095 "MatrixModule.cs"
        int csharp2cuda_temp_449;
#line 1095 "MatrixModule.cs"
        if (((opcode) == (43)))
        {
#line 1095 "MatrixModule.cs"
            csharp2cuda_temp_449 = 0;
        }
        else
        {
#line 1095 "MatrixModule.cs"
            csharp2cuda_temp_449 = size;
        }
#line 1095 "MatrixModule.cs"
        bool converged = mathblocks_matrix_symmetric_eigenvalues(a, size, scratch, eigenvalues, csharp2cuda_pointer_add(csharp2cuda_pointer_add(scratch, csharp2cuda_temp_448), csharp2cuda_temp_449));
#line 1096 "MatrixModule.cs"
        if ((!(converged)))
#line 1097 "MatrixModule.cs"
        {
#line 1098 "MatrixModule.cs"
            mathblocks_nonconvergence_record_matrix(opcode);
#line 1099 "MatrixModule.cs"
            if (((mathblocks_limit_jacobi_policy()) == (1)))
#line 1100 "MatrixModule.cs"
            {
#line 1101 "MatrixModule.cs"
#line 1101 "MatrixModule.cs"
                int* csharp2cuda_temp_450 = &((output)->valid);
                (*(csharp2cuda_temp_450) = 0);
#line 1102 "MatrixModule.cs"
                return;
            }
        }
#line 1105 "MatrixModule.cs"
        if (((opcode) == (33)))
        {
#line 1105 "MatrixModule.cs"
#line 1105 "MatrixModule.cs"
            double* csharp2cuda_temp_451 = &((output)->scalar_value);
#line 1105 "MatrixModule.cs"
            double csharp2cuda_temp_452 = (eigenvalues)[csharp2cuda_i32_sub(size, 1)];
            (*(csharp2cuda_temp_451) = csharp2cuda_temp_452);
        }
        else
        {
#line 1106 "MatrixModule.cs"
            if (((opcode) == (40)))
            {
#line 1106 "MatrixModule.cs"
#line 1106 "MatrixModule.cs"
                double* csharp2cuda_temp_453 = &((output)->scalar_value);
#line 1106 "MatrixModule.cs"
                double csharp2cuda_temp_454 = (eigenvalues)[0];
                (*(csharp2cuda_temp_453) = csharp2cuda_temp_454);
            }
        }
#line 1107 "MatrixModule.cs"
        {
#line 1107 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (size))))
                    break;
#line 1108 "MatrixModule.cs"
#line 1108 "MatrixModule.cs"
                double csharp2cuda_temp_456 = (eigenvalues)[index];
                if ((!(isfinite(csharp2cuda_temp_456))))
                {
#line 1108 "MatrixModule.cs"
#line 1108 "MatrixModule.cs"
                    int* csharp2cuda_temp_457 = &((output)->valid);
                    (*(csharp2cuda_temp_457) = 0);
                }
#line 1107 "MatrixModule.cs"
                int* csharp2cuda_temp_455 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_455));
            }
        }
#line 1109 "MatrixModule.cs"
        return;
    }
#line 1112 "MatrixModule.cs"
    if (((opcode) == (34)))
#line 1113 "MatrixModule.cs"
    {
#line 1114 "MatrixModule.cs"
#line 1114 "MatrixModule.cs"
        int csharp2cuda_temp_458 = (first)->rows;
#line 1114 "MatrixModule.cs"
        int csharp2cuda_temp_459 = (first)->columns;
#line 1114 "MatrixModule.cs"
        bool csharp2cuda_temp_460;
#line 1114 "MatrixModule.cs"
        if (!(((csharp2cuda_temp_458) > (csharp2cuda_temp_459))))
        {
#line 1114 "MatrixModule.cs"
            int csharp2cuda_temp_461 = (first)->columns;
#line 1114 "MatrixModule.cs"
            csharp2cuda_temp_460 = ((csharp2cuda_temp_461) > (mathblocks_limit_maximal_minor_columns()));
        }
        else
        {
#line 1114 "MatrixModule.cs"
            csharp2cuda_temp_460 = true;
        }
#line 1114 "MatrixModule.cs"
        bool csharp2cuda_temp_462;
#line 1114 "MatrixModule.cs"
        if (!(csharp2cuda_temp_460))
        {
#line 1114 "MatrixModule.cs"
            csharp2cuda_temp_462 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1114 "MatrixModule.cs"
            csharp2cuda_temp_462 = true;
        }
        if (csharp2cuda_temp_462)
#line 1115 "MatrixModule.cs"
        {
#line 1116 "MatrixModule.cs"
#line 1116 "MatrixModule.cs"
            int* csharp2cuda_temp_463 = &((output)->valid);
            (*(csharp2cuda_temp_463) = 0);
#line 1117 "MatrixModule.cs"
            return;
        }
#line 1119 "MatrixModule.cs"
        double* submatrix = scratch;
#line 1120 "MatrixModule.cs"
        int csharp2cuda_temp_464 = (first)->count;
#line 1120 "MatrixModule.cs"
        double* work = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_464);
#line 1121 "MatrixModule.cs"
        int csharp2cuda_temp_465 = (first)->rows;
#line 1121 "MatrixModule.cs"
        int row_mask = csharp2cuda_i32_sub(csharp2cuda_i32_shl(1, csharp2cuda_temp_465), 1);
#line 1122 "MatrixModule.cs"
        int csharp2cuda_temp_466 = (first)->columns;
#line 1122 "MatrixModule.cs"
        int limit = csharp2cuda_i32_shl(1, csharp2cuda_temp_466);
#line 1123 "MatrixModule.cs"
        int output_index = 0;
#line 1124 "MatrixModule.cs"
        {
#line 1124 "MatrixModule.cs"
            int column_mask = 1;
            while (true)
            {
                if (!(((column_mask) < (limit))))
                    break;
#line 1125 "MatrixModule.cs"
                {
#line 1126 "MatrixModule.cs"
#line 1126 "MatrixModule.cs"
                    int csharp2cuda_temp_468 = (first)->rows;
                    if (((mathblocks_pop_count(column_mask)) != (csharp2cuda_temp_468)))
                    {
#line 1127 "MatrixModule.cs"
                        goto csharp2cuda_for_continue_45;
                    }
#line 1128 "MatrixModule.cs"
#line 1130 "MatrixModule.cs"
                    int csharp2cuda_temp_469 = (first)->columns;
#line 1133 "MatrixModule.cs"
                    int csharp2cuda_temp_470 = (first)->rows;
                    mathblocks_matrix_submatrix_from_masks(a, csharp2cuda_temp_469, row_mask, column_mask, csharp2cuda_temp_470, submatrix);
#line 1135 "MatrixModule.cs"
#line 1135 "MatrixModule.cs"
                    int* csharp2cuda_temp_471 = &(output_index);
#line 1135 "MatrixModule.cs"
                    int csharp2cuda_temp_472 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_471));
#line 1135 "MatrixModule.cs"
                    double* csharp2cuda_temp_473 = &((result)[csharp2cuda_temp_472]);
#line 1137 "MatrixModule.cs"
                    int csharp2cuda_temp_474 = (first)->rows;
#line 1135 "MatrixModule.cs"
                    double csharp2cuda_temp_475 = mathblocks_matrix_determinant(submatrix, csharp2cuda_temp_474, work);
                    (*(csharp2cuda_temp_473) = csharp2cuda_temp_475);
                }
                csharp2cuda_for_continue_45:
#line 1124 "MatrixModule.cs"
                int* csharp2cuda_temp_467 = &(column_mask);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_467));
            }
        }
#line 1140 "MatrixModule.cs"
        mathblocks_set_vector_shape(output, output_index);
#line 1141 "MatrixModule.cs"
        {
#line 1141 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (output_index))))
                    break;
#line 1142 "MatrixModule.cs"
#line 1142 "MatrixModule.cs"
                double csharp2cuda_temp_477 = (result)[index];
                if ((!(isfinite(csharp2cuda_temp_477))))
                {
#line 1142 "MatrixModule.cs"
#line 1142 "MatrixModule.cs"
                    int* csharp2cuda_temp_478 = &((output)->valid);
                    (*(csharp2cuda_temp_478) = 0);
                }
#line 1141 "MatrixModule.cs"
                int* csharp2cuda_temp_476 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_476));
            }
        }
#line 1143 "MatrixModule.cs"
        return;
    }
#line 1146 "MatrixModule.cs"
#line 1146 "MatrixModule.cs"
    bool csharp2cuda_temp_479;
#line 1146 "MatrixModule.cs"
    if (!(((opcode) == (35))))
    {
#line 1146 "MatrixModule.cs"
        csharp2cuda_temp_479 = ((opcode) == (36));
    }
    else
    {
#line 1146 "MatrixModule.cs"
        csharp2cuda_temp_479 = true;
    }
    if (csharp2cuda_temp_479)
#line 1147 "MatrixModule.cs"
    {
#line 1148 "MatrixModule.cs"
        int iterations = 0;
#line 1149 "MatrixModule.cs"
        int size = (first)->rows;
#line 1150 "MatrixModule.cs"
#line 1150 "MatrixModule.cs"
        int csharp2cuda_temp_480 = (first)->columns;
#line 1150 "MatrixModule.cs"
        bool csharp2cuda_temp_481;
#line 1150 "MatrixModule.cs"
        if (!(((size) != (csharp2cuda_temp_480))))
        {
#line 1151 "MatrixModule.cs"
            double csharp2cuda_temp_482 = (second)->scalar_value;
#line 1151 "MatrixModule.cs"
            int* csharp2cuda_temp_483 = &(iterations);
#line 1151 "MatrixModule.cs"
            bool csharp2cuda_temp_484 = mathblocks_nonnegative_integer(csharp2cuda_temp_482, csharp2cuda_temp_483);
#line 1150 "MatrixModule.cs"
            csharp2cuda_temp_481 = (!(csharp2cuda_temp_484));
        }
        else
        {
#line 1150 "MatrixModule.cs"
            csharp2cuda_temp_481 = true;
        }
#line 1150 "MatrixModule.cs"
        bool csharp2cuda_temp_485;
#line 1150 "MatrixModule.cs"
        if (!(csharp2cuda_temp_481))
        {
#line 1150 "MatrixModule.cs"
            csharp2cuda_temp_485 = ((iterations) <= (0));
        }
        else
        {
#line 1150 "MatrixModule.cs"
            csharp2cuda_temp_485 = true;
        }
#line 1150 "MatrixModule.cs"
        bool csharp2cuda_temp_486;
#line 1150 "MatrixModule.cs"
        if (!(csharp2cuda_temp_485))
        {
#line 1150 "MatrixModule.cs"
            csharp2cuda_temp_486 = ((iterations) > (mathblocks_limit_iteration_count()));
        }
        else
        {
#line 1150 "MatrixModule.cs"
            csharp2cuda_temp_486 = true;
        }
#line 1150 "MatrixModule.cs"
        bool csharp2cuda_temp_487;
#line 1150 "MatrixModule.cs"
        if (!(csharp2cuda_temp_486))
        {
#line 1150 "MatrixModule.cs"
            csharp2cuda_temp_487 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1150 "MatrixModule.cs"
            csharp2cuda_temp_487 = true;
        }
        if (csharp2cuda_temp_487)
#line 1153 "MatrixModule.cs"
        {
#line 1154 "MatrixModule.cs"
#line 1154 "MatrixModule.cs"
            int* csharp2cuda_temp_488 = &((output)->valid);
            (*(csharp2cuda_temp_488) = 0);
#line 1155 "MatrixModule.cs"
            return;
        }
#line 1157 "MatrixModule.cs"
        {
#line 1157 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
#line 1157 "MatrixModule.cs"
                int csharp2cuda_temp_490 = (first)->count;
                if (!(((index) < (csharp2cuda_temp_490))))
                    break;
#line 1158 "MatrixModule.cs"
#line 1158 "MatrixModule.cs"
                double csharp2cuda_temp_491 = (a)[index];
                if (((csharp2cuda_temp_491) < (0.0)))
                {
#line 1158 "MatrixModule.cs"
#line 1158 "MatrixModule.cs"
                    int* csharp2cuda_temp_492 = &((output)->valid);
                    (*(csharp2cuda_temp_492) = 0);
                }
#line 1157 "MatrixModule.cs"
                int* csharp2cuda_temp_489 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_489));
            }
        }
#line 1159 "MatrixModule.cs"
#line 1159 "MatrixModule.cs"
        bool csharp2cuda_temp_493 = (output)->valid;
        if ((!(csharp2cuda_temp_493)))
        {
#line 1160 "MatrixModule.cs"
            return;
        }
#line 1161 "MatrixModule.cs"
        double* csharp2cuda_temp_494;
#line 1161 "MatrixModule.cs"
        if (((opcode) == (36)))
        {
#line 1161 "MatrixModule.cs"
            csharp2cuda_temp_494 = result;
        }
        else
        {
#line 1161 "MatrixModule.cs"
            csharp2cuda_temp_494 = scratch;
        }
#line 1161 "MatrixModule.cs"
        double* vector = csharp2cuda_temp_494;
#line 1162 "MatrixModule.cs"
        double* csharp2cuda_temp_495;
#line 1162 "MatrixModule.cs"
        if (((opcode) == (36)))
        {
#line 1162 "MatrixModule.cs"
            csharp2cuda_temp_495 = scratch;
        }
        else
        {
#line 1162 "MatrixModule.cs"
            csharp2cuda_temp_495 = csharp2cuda_pointer_add(scratch, size);
        }
#line 1162 "MatrixModule.cs"
        double* next = csharp2cuda_temp_495;
#line 1163 "MatrixModule.cs"
        double* csharp2cuda_temp_496;
#line 1163 "MatrixModule.cs"
        if (((opcode) == (36)))
        {
#line 1163 "MatrixModule.cs"
            csharp2cuda_temp_496 = csharp2cuda_pointer_add(scratch, size);
        }
        else
        {
#line 1163 "MatrixModule.cs"
            csharp2cuda_temp_496 = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(size, 2));
        }
#line 1163 "MatrixModule.cs"
        double* products = csharp2cuda_temp_496;
#line 1164 "MatrixModule.cs"
        {
#line 1164 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (size))))
                    break;
#line 1165 "MatrixModule.cs"
#line 1165 "MatrixModule.cs"
                double* csharp2cuda_temp_498 = &((vector)[index]);
#line 1165 "MatrixModule.cs"
                double csharp2cuda_temp_499 = __ddiv_rn(1.0, ((double)(size)));
                (*(csharp2cuda_temp_498) = csharp2cuda_temp_499);
#line 1164 "MatrixModule.cs"
                int* csharp2cuda_temp_497 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_497));
            }
        }
#line 1166 "MatrixModule.cs"
        {
#line 1166 "MatrixModule.cs"
            int iteration = 0;
            while (true)
            {
                if (!(((iteration) < (iterations))))
                    break;
#line 1167 "MatrixModule.cs"
                {
#line 1168 "MatrixModule.cs"
                    {
#line 1168 "MatrixModule.cs"
                        int row = 0;
                        while (true)
                        {
                            if (!(((row) < (size))))
                                break;
#line 1169 "MatrixModule.cs"
                            {
#line 1170 "MatrixModule.cs"
                                double sum = 0.0;
#line 1171 "MatrixModule.cs"
                                {
#line 1171 "MatrixModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
                                        if (!(((column) < (size))))
                                            break;
#line 1172 "MatrixModule.cs"
#line 1172 "MatrixModule.cs"
                                        double* csharp2cuda_temp_503 = &(sum);
#line 1172 "MatrixModule.cs"
                                        double csharp2cuda_temp_504 = *(csharp2cuda_temp_503);
#line 1172 "MatrixModule.cs"
                                        double csharp2cuda_temp_505 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
#line 1172 "MatrixModule.cs"
                                        double csharp2cuda_temp_506 = (vector)[column];
                                        (*(csharp2cuda_temp_503) = __dadd_rn(csharp2cuda_temp_504, __dmul_rn(csharp2cuda_temp_505, csharp2cuda_temp_506)));
#line 1171 "MatrixModule.cs"
                                        int* csharp2cuda_temp_502 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_502));
                                    }
                                }
#line 1173 "MatrixModule.cs"
#line 1173 "MatrixModule.cs"
                                double* csharp2cuda_temp_507 = &((next)[row]);
#line 1173 "MatrixModule.cs"
                                double csharp2cuda_temp_508 = (vector)[row];
                                (*(csharp2cuda_temp_507) = __dadd_rn(sum, csharp2cuda_temp_508));
                            }
#line 1168 "MatrixModule.cs"
                            int* csharp2cuda_temp_501 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_501));
                        }
                    }
#line 1175 "MatrixModule.cs"
                    double norm = mathblocks_compensated_sum(next, size);
#line 1176 "MatrixModule.cs"
                    {
#line 1176 "MatrixModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (size))))
                                break;
#line 1177 "MatrixModule.cs"
#line 1177 "MatrixModule.cs"
                            double* csharp2cuda_temp_510 = &((vector)[index]);
#line 1177 "MatrixModule.cs"
                            double csharp2cuda_temp_511 = (next)[index];
#line 1177 "MatrixModule.cs"
                            double csharp2cuda_temp_512 = __ddiv_rn(csharp2cuda_temp_511, norm);
                            (*(csharp2cuda_temp_510) = csharp2cuda_temp_512);
#line 1176 "MatrixModule.cs"
                            int* csharp2cuda_temp_509 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_509));
                        }
                    }
                }
#line 1166 "MatrixModule.cs"
                int* csharp2cuda_temp_500 = &(iteration);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_500));
            }
        }
#line 1179 "MatrixModule.cs"
        if (((opcode) == (36)))
#line 1180 "MatrixModule.cs"
        {
#line 1181 "MatrixModule.cs"
            mathblocks_set_vector_shape(output, size);
#line 1182 "MatrixModule.cs"
            {
#line 1182 "MatrixModule.cs"
                int index = 0;
                while (true)
                {
                    if (!(((index) < (size))))
                        break;
#line 1183 "MatrixModule.cs"
#line 1183 "MatrixModule.cs"
                    double csharp2cuda_temp_514 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_514))))
                    {
#line 1183 "MatrixModule.cs"
#line 1183 "MatrixModule.cs"
                        int* csharp2cuda_temp_515 = &((output)->valid);
                        (*(csharp2cuda_temp_515) = 0);
                    }
#line 1182 "MatrixModule.cs"
                    int* csharp2cuda_temp_513 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_513));
                }
            }
#line 1184 "MatrixModule.cs"
            return;
        }
#line 1186 "MatrixModule.cs"
        {
#line 1186 "MatrixModule.cs"
            int row = 0;
            while (true)
            {
                if (!(((row) < (size))))
                    break;
#line 1187 "MatrixModule.cs"
                {
#line 1188 "MatrixModule.cs"
                    double sum = 0.0;
#line 1189 "MatrixModule.cs"
                    {
#line 1189 "MatrixModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (size))))
                                break;
#line 1190 "MatrixModule.cs"
#line 1190 "MatrixModule.cs"
                            double* csharp2cuda_temp_518 = &(sum);
#line 1190 "MatrixModule.cs"
                            double csharp2cuda_temp_519 = *(csharp2cuda_temp_518);
#line 1190 "MatrixModule.cs"
                            double csharp2cuda_temp_520 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
#line 1190 "MatrixModule.cs"
                            double csharp2cuda_temp_521 = (vector)[column];
                            (*(csharp2cuda_temp_518) = __dadd_rn(csharp2cuda_temp_519, __dmul_rn(csharp2cuda_temp_520, csharp2cuda_temp_521)));
#line 1189 "MatrixModule.cs"
                            int* csharp2cuda_temp_517 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_517));
                        }
                    }
#line 1191 "MatrixModule.cs"
#line 1191 "MatrixModule.cs"
                    double* csharp2cuda_temp_522 = &((next)[row]);
                    (*(csharp2cuda_temp_522) = sum);
                }
#line 1186 "MatrixModule.cs"
                int* csharp2cuda_temp_516 = &(row);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_516));
            }
        }
#line 1193 "MatrixModule.cs"
        {
#line 1193 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (size))))
                    break;
#line 1194 "MatrixModule.cs"
#line 1194 "MatrixModule.cs"
                double* csharp2cuda_temp_524 = &((products)[index]);
#line 1194 "MatrixModule.cs"
                double csharp2cuda_temp_525 = (vector)[index];
#line 1194 "MatrixModule.cs"
                double csharp2cuda_temp_526 = (next)[index];
                (*(csharp2cuda_temp_524) = __dmul_rn(csharp2cuda_temp_525, csharp2cuda_temp_526));
#line 1193 "MatrixModule.cs"
                int* csharp2cuda_temp_523 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_523));
            }
        }
#line 1195 "MatrixModule.cs"
        double numerator = mathblocks_compensated_sum(products, size);
#line 1196 "MatrixModule.cs"
        {
#line 1196 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (size))))
                    break;
#line 1197 "MatrixModule.cs"
#line 1197 "MatrixModule.cs"
                double* csharp2cuda_temp_528 = &((products)[index]);
#line 1197 "MatrixModule.cs"
                double csharp2cuda_temp_529 = (vector)[index];
#line 1197 "MatrixModule.cs"
                double csharp2cuda_temp_530 = (vector)[index];
                (*(csharp2cuda_temp_528) = __dmul_rn(csharp2cuda_temp_529, csharp2cuda_temp_530));
#line 1196 "MatrixModule.cs"
                int* csharp2cuda_temp_527 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_527));
            }
        }
#line 1198 "MatrixModule.cs"
        double denominator = mathblocks_compensated_sum(products, size);
#line 1199 "MatrixModule.cs"
#line 1199 "MatrixModule.cs"
        double* csharp2cuda_temp_531 = &((output)->scalar_value);
#line 1199 "MatrixModule.cs"
        double csharp2cuda_temp_532 = __ddiv_rn(numerator, denominator);
        (*(csharp2cuda_temp_531) = csharp2cuda_temp_532);
#line 1200 "MatrixModule.cs"
#line 1200 "MatrixModule.cs"
        double csharp2cuda_temp_533 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_533))))
        {
#line 1200 "MatrixModule.cs"
#line 1200 "MatrixModule.cs"
            int* csharp2cuda_temp_534 = &((output)->valid);
            (*(csharp2cuda_temp_534) = 0);
        }
#line 1201 "MatrixModule.cs"
        return;
    }
#line 1204 "MatrixModule.cs"
    if (((opcode) == (37)))
#line 1205 "MatrixModule.cs"
    {
#line 1206 "MatrixModule.cs"
        int size = (first)->rows;
#line 1207 "MatrixModule.cs"
#line 1207 "MatrixModule.cs"
        int csharp2cuda_temp_535 = (first)->columns;
#line 1207 "MatrixModule.cs"
        bool csharp2cuda_temp_536;
#line 1207 "MatrixModule.cs"
        if (!(((size) != (csharp2cuda_temp_535))))
        {
#line 1207 "MatrixModule.cs"
            csharp2cuda_temp_536 = ((size) > (mathblocks_limit_explicit_subset_size()));
        }
        else
        {
#line 1207 "MatrixModule.cs"
            csharp2cuda_temp_536 = true;
        }
#line 1207 "MatrixModule.cs"
        bool csharp2cuda_temp_537;
#line 1207 "MatrixModule.cs"
        if (!(csharp2cuda_temp_536))
        {
#line 1207 "MatrixModule.cs"
            csharp2cuda_temp_537 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1207 "MatrixModule.cs"
            csharp2cuda_temp_537 = true;
        }
        if (csharp2cuda_temp_537)
#line 1208 "MatrixModule.cs"
        {
#line 1209 "MatrixModule.cs"
#line 1209 "MatrixModule.cs"
            int* csharp2cuda_temp_538 = &((output)->valid);
            (*(csharp2cuda_temp_538) = 0);
#line 1210 "MatrixModule.cs"
            return;
        }
#line 1212 "MatrixModule.cs"
        int limit = csharp2cuda_i32_shl(1, size);
#line 1213 "MatrixModule.cs"
        mathblocks_set_vector_shape(output, csharp2cuda_i32_sub(limit, 1));
#line 1214 "MatrixModule.cs"
        double* submatrix = scratch;
#line 1215 "MatrixModule.cs"
        int csharp2cuda_temp_539 = (first)->count;
#line 1215 "MatrixModule.cs"
        double* work = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_539);
#line 1216 "MatrixModule.cs"
        {
#line 1216 "MatrixModule.cs"
            int mask = 1;
            while (true)
            {
                if (!(((mask) < (limit))))
                    break;
#line 1217 "MatrixModule.cs"
                {
#line 1218 "MatrixModule.cs"
                    int order = mathblocks_pop_count(mask);
#line 1219 "MatrixModule.cs"
                    mathblocks_matrix_submatrix_from_masks(a, size, mask, mask, order, submatrix);
#line 1226 "MatrixModule.cs"
#line 1226 "MatrixModule.cs"
                    double* csharp2cuda_temp_541 = &((result)[csharp2cuda_i32_sub(mask, 1)]);
#line 1226 "MatrixModule.cs"
                    double csharp2cuda_temp_542 = mathblocks_matrix_determinant(submatrix, order, work);
                    (*(csharp2cuda_temp_541) = csharp2cuda_temp_542);
#line 1227 "MatrixModule.cs"
#line 1227 "MatrixModule.cs"
                    double csharp2cuda_temp_543 = (result)[csharp2cuda_i32_sub(mask, 1)];
                    if ((!(isfinite(csharp2cuda_temp_543))))
                    {
#line 1227 "MatrixModule.cs"
#line 1227 "MatrixModule.cs"
                        int* csharp2cuda_temp_544 = &((output)->valid);
                        (*(csharp2cuda_temp_544) = 0);
                    }
                }
#line 1216 "MatrixModule.cs"
                int* csharp2cuda_temp_540 = &(mask);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_540));
            }
        }
#line 1229 "MatrixModule.cs"
        return;
    }
#line 1232 "MatrixModule.cs"
    if (((opcode) == (38)))
#line 1233 "MatrixModule.cs"
    {
#line 1234 "MatrixModule.cs"
        if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 1235 "MatrixModule.cs"
        {
#line 1236 "MatrixModule.cs"
#line 1236 "MatrixModule.cs"
            int* csharp2cuda_temp_545 = &((output)->valid);
            (*(csharp2cuda_temp_545) = 0);
#line 1237 "MatrixModule.cs"
            return;
        }
#line 1239 "MatrixModule.cs"
#line 1239 "MatrixModule.cs"
        double* csharp2cuda_temp_546 = &((output)->scalar_value);
#line 1241 "MatrixModule.cs"
        int csharp2cuda_temp_547 = (first)->rows;
#line 1242 "MatrixModule.cs"
        int csharp2cuda_temp_548 = (first)->columns;
#line 1239 "MatrixModule.cs"
        int csharp2cuda_temp_549 = mathblocks_matrix_rank(a, csharp2cuda_temp_547, csharp2cuda_temp_548, scratch);
        (*(csharp2cuda_temp_546) = ((double)(csharp2cuda_temp_549)));
#line 1244 "MatrixModule.cs"
        return;
    }
#line 1247 "MatrixModule.cs"
    if (((opcode) == (39)))
#line 1248 "MatrixModule.cs"
    {
#line 1249 "MatrixModule.cs"
        int retained = 0;
#line 1250 "MatrixModule.cs"
        int size = (first)->rows;
#line 1251 "MatrixModule.cs"
#line 1251 "MatrixModule.cs"
        int csharp2cuda_temp_550 = (first)->columns;
#line 1251 "MatrixModule.cs"
        bool csharp2cuda_temp_551;
#line 1251 "MatrixModule.cs"
        if (!(((size) != (csharp2cuda_temp_550))))
        {
#line 1252 "MatrixModule.cs"
            double csharp2cuda_temp_552 = (second)->scalar_value;
#line 1252 "MatrixModule.cs"
            int* csharp2cuda_temp_553 = &(retained);
#line 1252 "MatrixModule.cs"
            bool csharp2cuda_temp_554 = mathblocks_nonnegative_integer(csharp2cuda_temp_552, csharp2cuda_temp_553);
#line 1251 "MatrixModule.cs"
            csharp2cuda_temp_551 = (!(csharp2cuda_temp_554));
        }
        else
        {
#line 1251 "MatrixModule.cs"
            csharp2cuda_temp_551 = true;
        }
#line 1251 "MatrixModule.cs"
        bool csharp2cuda_temp_555;
#line 1251 "MatrixModule.cs"
        if (!(csharp2cuda_temp_551))
        {
#line 1251 "MatrixModule.cs"
            csharp2cuda_temp_555 = ((retained) <= (0));
        }
        else
        {
#line 1251 "MatrixModule.cs"
            csharp2cuda_temp_555 = true;
        }
#line 1251 "MatrixModule.cs"
        bool csharp2cuda_temp_556;
#line 1251 "MatrixModule.cs"
        if (!(csharp2cuda_temp_555))
        {
#line 1251 "MatrixModule.cs"
            csharp2cuda_temp_556 = ((retained) >= (size));
        }
        else
        {
#line 1251 "MatrixModule.cs"
            csharp2cuda_temp_556 = true;
        }
#line 1251 "MatrixModule.cs"
        bool csharp2cuda_temp_557;
#line 1251 "MatrixModule.cs"
        if (!(csharp2cuda_temp_556))
        {
#line 1251 "MatrixModule.cs"
            csharp2cuda_temp_557 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1251 "MatrixModule.cs"
            csharp2cuda_temp_557 = true;
        }
        if (csharp2cuda_temp_557)
#line 1254 "MatrixModule.cs"
        {
#line 1255 "MatrixModule.cs"
#line 1255 "MatrixModule.cs"
            int* csharp2cuda_temp_558 = &((output)->valid);
            (*(csharp2cuda_temp_558) = 0);
#line 1256 "MatrixModule.cs"
            return;
        }
#line 1258 "MatrixModule.cs"
        int eliminated = csharp2cuda_i32_sub(size, retained);
#line 1259 "MatrixModule.cs"
        double* leading = scratch;
#line 1260 "MatrixModule.cs"
        double* upper = csharp2cuda_pointer_add(leading, csharp2cuda_i32_mul(retained, retained));
#line 1261 "MatrixModule.cs"
        double* lower = csharp2cuda_pointer_add(upper, csharp2cuda_i32_mul(retained, eliminated));
#line 1262 "MatrixModule.cs"
        double* trailing = csharp2cuda_pointer_add(lower, csharp2cuda_i32_mul(eliminated, retained));
#line 1263 "MatrixModule.cs"
        double* inverse = csharp2cuda_pointer_add(trailing, csharp2cuda_i32_mul(eliminated, eliminated));
#line 1264 "MatrixModule.cs"
        double* augmented = csharp2cuda_pointer_add(inverse, csharp2cuda_i32_mul(eliminated, eliminated));
#line 1265 "MatrixModule.cs"
        double* solution = csharp2cuda_pointer_add(augmented, csharp2cuda_i32_mul(eliminated, csharp2cuda_i32_add(eliminated, 1)));
#line 1266 "MatrixModule.cs"
        double* upper_inverse = csharp2cuda_pointer_add(solution, eliminated);
#line 1267 "MatrixModule.cs"
        double* product = csharp2cuda_pointer_add(upper_inverse, csharp2cuda_i32_mul(retained, eliminated));
#line 1268 "MatrixModule.cs"
        {
#line 1268 "MatrixModule.cs"
            int row = 0;
            while (true)
            {
                if (!(((row) < (size))))
                    break;
#line 1269 "MatrixModule.cs"
                {
#line 1270 "MatrixModule.cs"
                    {
#line 1270 "MatrixModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (size))))
                                break;
#line 1271 "MatrixModule.cs"
                            {
#line 1272 "MatrixModule.cs"
                                double value = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
#line 1273 "MatrixModule.cs"
#line 1273 "MatrixModule.cs"
                                bool csharp2cuda_temp_561;
#line 1273 "MatrixModule.cs"
                                if (((row) < (retained)))
                                {
#line 1273 "MatrixModule.cs"
                                    csharp2cuda_temp_561 = ((column) < (retained));
                                }
                                else
                                {
#line 1273 "MatrixModule.cs"
                                    csharp2cuda_temp_561 = false;
                                }
                                if (csharp2cuda_temp_561)
                                {
#line 1274 "MatrixModule.cs"
#line 1274 "MatrixModule.cs"
                                    double* csharp2cuda_temp_562 = &((leading)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, retained), column)]);
                                    (*(csharp2cuda_temp_562) = value);
                                }
                                else
                                {
#line 1275 "MatrixModule.cs"
                                    if (((row) < (retained)))
                                    {
#line 1276 "MatrixModule.cs"
#line 1276 "MatrixModule.cs"
                                        double* csharp2cuda_temp_563 = &((upper)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(row, eliminated), column), retained)]);
                                        (*(csharp2cuda_temp_563) = value);
                                    }
                                    else
                                    {
#line 1277 "MatrixModule.cs"
                                        if (((column) < (retained)))
                                        {
#line 1278 "MatrixModule.cs"
#line 1278 "MatrixModule.cs"
                                            double* csharp2cuda_temp_564 = &((lower)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(row, retained), retained), column)]);
                                            (*(csharp2cuda_temp_564) = value);
                                        }
                                        else
                                        {
#line 1280 "MatrixModule.cs"
#line 1280 "MatrixModule.cs"
                                            double* csharp2cuda_temp_565 = &((trailing)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(row, retained), eliminated), column), retained)]);
                                            (*(csharp2cuda_temp_565) = value);
                                        }
                                    }
                                }
                            }
#line 1270 "MatrixModule.cs"
                            int* csharp2cuda_temp_560 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_560));
                        }
                    }
                }
#line 1268 "MatrixModule.cs"
                int* csharp2cuda_temp_559 = &(row);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_559));
            }
        }
#line 1283 "MatrixModule.cs"
        {
#line 1283 "MatrixModule.cs"
            int column = 0;
            while (true)
            {
                if (!(((column) < (eliminated))))
                    break;
#line 1284 "MatrixModule.cs"
                {
#line 1285 "MatrixModule.cs"
#line 1285 "MatrixModule.cs"
                    bool csharp2cuda_temp_567 = mathblocks_matrix_try_solve_basis(trailing, eliminated, column, augmented, solution);
                    if ((!(csharp2cuda_temp_567)))
#line 1291 "MatrixModule.cs"
                    {
#line 1292 "MatrixModule.cs"
#line 1292 "MatrixModule.cs"
                        int* csharp2cuda_temp_568 = &((output)->valid);
                        (*(csharp2cuda_temp_568) = 0);
#line 1293 "MatrixModule.cs"
                        return;
                    }
#line 1295 "MatrixModule.cs"
                    {
#line 1295 "MatrixModule.cs"
                        int row = 0;
                        while (true)
                        {
                            if (!(((row) < (eliminated))))
                                break;
#line 1296 "MatrixModule.cs"
#line 1296 "MatrixModule.cs"
                            double* csharp2cuda_temp_570 = &((inverse)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, eliminated), column)]);
#line 1296 "MatrixModule.cs"
                            double csharp2cuda_temp_571 = (solution)[row];
                            (*(csharp2cuda_temp_570) = csharp2cuda_temp_571);
#line 1295 "MatrixModule.cs"
                            int* csharp2cuda_temp_569 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_569));
                        }
                    }
                }
#line 1283 "MatrixModule.cs"
                int* csharp2cuda_temp_566 = &(column);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_566));
            }
        }
#line 1298 "MatrixModule.cs"
        {
#line 1298 "MatrixModule.cs"
            int row = 0;
            while (true)
            {
                if (!(((row) < (retained))))
                    break;
#line 1299 "MatrixModule.cs"
                {
#line 1300 "MatrixModule.cs"
                    {
#line 1300 "MatrixModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (eliminated))))
                                break;
#line 1301 "MatrixModule.cs"
                            {
#line 1302 "MatrixModule.cs"
                                double sum = 0.0;
#line 1303 "MatrixModule.cs"
                                {
#line 1303 "MatrixModule.cs"
                                    int inner = 0;
                                    while (true)
                                    {
                                        if (!(((inner) < (eliminated))))
                                            break;
#line 1304 "MatrixModule.cs"
#line 1304 "MatrixModule.cs"
                                        double* csharp2cuda_temp_575 = &(sum);
#line 1304 "MatrixModule.cs"
                                        double csharp2cuda_temp_576 = *(csharp2cuda_temp_575);
#line 1304 "MatrixModule.cs"
                                        double csharp2cuda_temp_577 = (upper)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, eliminated), inner)];
#line 1305 "MatrixModule.cs"
                                        double csharp2cuda_temp_578 = (inverse)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, eliminated), column)];
                                        (*(csharp2cuda_temp_575) = __dadd_rn(csharp2cuda_temp_576, __dmul_rn(csharp2cuda_temp_577, csharp2cuda_temp_578)));
#line 1303 "MatrixModule.cs"
                                        int* csharp2cuda_temp_574 = &(inner);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_574));
                                    }
                                }
#line 1306 "MatrixModule.cs"
#line 1306 "MatrixModule.cs"
                                double* csharp2cuda_temp_579 = &((upper_inverse)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, eliminated), column)]);
                                (*(csharp2cuda_temp_579) = sum);
                            }
#line 1300 "MatrixModule.cs"
                            int* csharp2cuda_temp_573 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_573));
                        }
                    }
                }
#line 1298 "MatrixModule.cs"
                int* csharp2cuda_temp_572 = &(row);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_572));
            }
        }
#line 1309 "MatrixModule.cs"
        {
#line 1309 "MatrixModule.cs"
            int row = 0;
            while (true)
            {
                if (!(((row) < (retained))))
                    break;
#line 1310 "MatrixModule.cs"
                {
#line 1311 "MatrixModule.cs"
                    {
#line 1311 "MatrixModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (retained))))
                                break;
#line 1312 "MatrixModule.cs"
                            {
#line 1313 "MatrixModule.cs"
                                double sum = 0.0;
#line 1314 "MatrixModule.cs"
                                {
#line 1314 "MatrixModule.cs"
                                    int inner = 0;
                                    while (true)
                                    {
                                        if (!(((inner) < (eliminated))))
                                            break;
#line 1315 "MatrixModule.cs"
#line 1315 "MatrixModule.cs"
                                        double* csharp2cuda_temp_583 = &(sum);
#line 1315 "MatrixModule.cs"
                                        double csharp2cuda_temp_584 = *(csharp2cuda_temp_583);
#line 1315 "MatrixModule.cs"
                                        double csharp2cuda_temp_585 = (upper_inverse)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, eliminated), inner)];
#line 1316 "MatrixModule.cs"
                                        double csharp2cuda_temp_586 = (lower)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, retained), column)];
                                        (*(csharp2cuda_temp_583) = __dadd_rn(csharp2cuda_temp_584, __dmul_rn(csharp2cuda_temp_585, csharp2cuda_temp_586)));
#line 1314 "MatrixModule.cs"
                                        int* csharp2cuda_temp_582 = &(inner);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_582));
                                    }
                                }
#line 1317 "MatrixModule.cs"
#line 1317 "MatrixModule.cs"
                                double* csharp2cuda_temp_587 = &((product)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, retained), column)]);
                                (*(csharp2cuda_temp_587) = sum);
                            }
#line 1311 "MatrixModule.cs"
                            int* csharp2cuda_temp_581 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_581));
                        }
                    }
                }
#line 1309 "MatrixModule.cs"
                int* csharp2cuda_temp_580 = &(row);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_580));
            }
        }
#line 1320 "MatrixModule.cs"
        mathblocks_matrix_shape(output, retained, retained);
#line 1321 "MatrixModule.cs"
        {
#line 1321 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (csharp2cuda_i32_mul(retained, retained)))))
                    break;
#line 1322 "MatrixModule.cs"
                {
#line 1323 "MatrixModule.cs"
#line 1323 "MatrixModule.cs"
                    double* csharp2cuda_temp_589 = &((result)[index]);
#line 1323 "MatrixModule.cs"
                    double csharp2cuda_temp_590 = (leading)[index];
#line 1323 "MatrixModule.cs"
                    double csharp2cuda_temp_591 = (product)[index];
                    (*(csharp2cuda_temp_589) = __dsub_rn(csharp2cuda_temp_590, csharp2cuda_temp_591));
#line 1324 "MatrixModule.cs"
#line 1324 "MatrixModule.cs"
                    double csharp2cuda_temp_592 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_592))))
                    {
#line 1324 "MatrixModule.cs"
#line 1324 "MatrixModule.cs"
                        int* csharp2cuda_temp_593 = &((output)->valid);
                        (*(csharp2cuda_temp_593) = 0);
                    }
                }
#line 1321 "MatrixModule.cs"
                int* csharp2cuda_temp_588 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_588));
            }
        }
#line 1326 "MatrixModule.cs"
        return;
    }
#line 1329 "MatrixModule.cs"
    if (((opcode) == (41)))
#line 1330 "MatrixModule.cs"
    {
#line 1331 "MatrixModule.cs"
        int size = (first)->rows;
#line 1332 "MatrixModule.cs"
#line 1332 "MatrixModule.cs"
        int csharp2cuda_temp_594 = (first)->columns;
#line 1332 "MatrixModule.cs"
        bool csharp2cuda_temp_595;
#line 1332 "MatrixModule.cs"
        if (!(((size) != (csharp2cuda_temp_594))))
        {
#line 1332 "MatrixModule.cs"
            int csharp2cuda_temp_596 = (second)->count;
#line 1332 "MatrixModule.cs"
            csharp2cuda_temp_595 = ((csharp2cuda_temp_596) != (size));
        }
        else
        {
#line 1332 "MatrixModule.cs"
            csharp2cuda_temp_595 = true;
        }
#line 1332 "MatrixModule.cs"
        bool csharp2cuda_temp_597;
#line 1332 "MatrixModule.cs"
        if (!(csharp2cuda_temp_595))
        {
#line 1332 "MatrixModule.cs"
            csharp2cuda_temp_597 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1332 "MatrixModule.cs"
            csharp2cuda_temp_597 = true;
        }
        if (csharp2cuda_temp_597)
#line 1333 "MatrixModule.cs"
        {
#line 1334 "MatrixModule.cs"
#line 1334 "MatrixModule.cs"
            int* csharp2cuda_temp_598 = &((output)->valid);
            (*(csharp2cuda_temp_598) = 0);
#line 1335 "MatrixModule.cs"
            return;
        }
#line 1337 "MatrixModule.cs"
        mathblocks_set_vector_shape(output, size);
#line 1338 "MatrixModule.cs"
#line 1338 "MatrixModule.cs"
        bool csharp2cuda_temp_599 = mathblocks_matrix_try_solve(a, b, size, scratch, result);
        if ((!(csharp2cuda_temp_599)))
        {
#line 1339 "MatrixModule.cs"
#line 1339 "MatrixModule.cs"
            int* csharp2cuda_temp_600 = &((output)->valid);
            (*(csharp2cuda_temp_600) = 0);
        }
#line 1340 "MatrixModule.cs"
        return;
    }
#line 1343 "MatrixModule.cs"
    if (((opcode) == (42)))
#line 1344 "MatrixModule.cs"
    {
#line 1345 "MatrixModule.cs"
        int iterations = 0;
#line 1346 "MatrixModule.cs"
#line 1346 "MatrixModule.cs"
        double csharp2cuda_temp_601 = (second)->scalar_value;
#line 1346 "MatrixModule.cs"
        int* csharp2cuda_temp_602 = &(iterations);
#line 1346 "MatrixModule.cs"
        bool csharp2cuda_temp_603 = mathblocks_nonnegative_integer(csharp2cuda_temp_601, csharp2cuda_temp_602);
#line 1346 "MatrixModule.cs"
        bool csharp2cuda_temp_604;
#line 1346 "MatrixModule.cs"
        if (!((!(csharp2cuda_temp_603))))
        {
#line 1346 "MatrixModule.cs"
            csharp2cuda_temp_604 = ((iterations) <= (0));
        }
        else
        {
#line 1346 "MatrixModule.cs"
            csharp2cuda_temp_604 = true;
        }
#line 1346 "MatrixModule.cs"
        bool csharp2cuda_temp_605;
#line 1346 "MatrixModule.cs"
        if (!(csharp2cuda_temp_604))
        {
#line 1346 "MatrixModule.cs"
            csharp2cuda_temp_605 = ((iterations) > (mathblocks_limit_iteration_count()));
        }
        else
        {
#line 1346 "MatrixModule.cs"
            csharp2cuda_temp_605 = true;
        }
#line 1346 "MatrixModule.cs"
        bool csharp2cuda_temp_606;
#line 1346 "MatrixModule.cs"
        if (!(csharp2cuda_temp_605))
        {
#line 1346 "MatrixModule.cs"
            csharp2cuda_temp_606 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1346 "MatrixModule.cs"
            csharp2cuda_temp_606 = true;
        }
        if (csharp2cuda_temp_606)
#line 1348 "MatrixModule.cs"
        {
#line 1349 "MatrixModule.cs"
#line 1349 "MatrixModule.cs"
            int* csharp2cuda_temp_607 = &((output)->valid);
            (*(csharp2cuda_temp_607) = 0);
#line 1350 "MatrixModule.cs"
            return;
        }
#line 1352 "MatrixModule.cs"
        int size = (first)->columns;
#line 1353 "MatrixModule.cs"
        double* gram = scratch;
#line 1354 "MatrixModule.cs"
        double* work = csharp2cuda_pointer_add(gram, csharp2cuda_i32_mul(size, size));
#line 1355 "MatrixModule.cs"
        double* eigenvalues = csharp2cuda_pointer_add(work, csharp2cuda_i32_mul(size, size));
#line 1356 "MatrixModule.cs"
        {
#line 1356 "MatrixModule.cs"
            int row = 0;
            while (true)
            {
                if (!(((row) < (size))))
                    break;
#line 1357 "MatrixModule.cs"
                {
#line 1358 "MatrixModule.cs"
                    {
#line 1358 "MatrixModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (size))))
                                break;
#line 1359 "MatrixModule.cs"
                            {
#line 1360 "MatrixModule.cs"
                                double sum = 0.0;
#line 1361 "MatrixModule.cs"
                                {
#line 1361 "MatrixModule.cs"
                                    int inner = 0;
                                    while (true)
                                    {
#line 1361 "MatrixModule.cs"
                                        int csharp2cuda_temp_611 = (first)->rows;
                                        if (!(((inner) < (csharp2cuda_temp_611))))
                                            break;
#line 1362 "MatrixModule.cs"
#line 1362 "MatrixModule.cs"
                                        double* csharp2cuda_temp_612 = &(sum);
#line 1362 "MatrixModule.cs"
                                        double csharp2cuda_temp_613 = *(csharp2cuda_temp_612);
#line 1362 "MatrixModule.cs"
                                        int csharp2cuda_temp_614 = (first)->columns;
#line 1362 "MatrixModule.cs"
                                        double csharp2cuda_temp_615 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_614), row)];
#line 1363 "MatrixModule.cs"
                                        int csharp2cuda_temp_616 = (first)->columns;
#line 1363 "MatrixModule.cs"
                                        double csharp2cuda_temp_617 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_616), column)];
                                        (*(csharp2cuda_temp_612) = __dadd_rn(csharp2cuda_temp_613, __dmul_rn(csharp2cuda_temp_615, csharp2cuda_temp_617)));
#line 1361 "MatrixModule.cs"
                                        int* csharp2cuda_temp_610 = &(inner);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_610));
                                    }
                                }
#line 1365 "MatrixModule.cs"
                                if ((!(isfinite(sum))))
#line 1366 "MatrixModule.cs"
                                {
#line 1367 "MatrixModule.cs"
#line 1367 "MatrixModule.cs"
                                    int* csharp2cuda_temp_618 = &((output)->valid);
                                    (*(csharp2cuda_temp_618) = 0);
#line 1368 "MatrixModule.cs"
                                    return;
                                }
#line 1370 "MatrixModule.cs"
#line 1370 "MatrixModule.cs"
                                double* csharp2cuda_temp_619 = &((gram)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)]);
                                (*(csharp2cuda_temp_619) = sum);
                            }
#line 1358 "MatrixModule.cs"
                            int* csharp2cuda_temp_609 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_609));
                        }
                    }
                }
#line 1356 "MatrixModule.cs"
                int* csharp2cuda_temp_608 = &(row);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_608));
            }
        }
#line 1373 "MatrixModule.cs"
        bool converged = mathblocks_matrix_symmetric_eigenvalues(gram, size, work, eigenvalues, csharp2cuda_pointer_add(eigenvalues, size));
#line 1374 "MatrixModule.cs"
        if ((!(converged)))
#line 1375 "MatrixModule.cs"
        {
#line 1376 "MatrixModule.cs"
            mathblocks_nonconvergence_record_matrix(opcode);
#line 1377 "MatrixModule.cs"
            if (((mathblocks_limit_jacobi_policy()) == (1)))
#line 1378 "MatrixModule.cs"
            {
#line 1379 "MatrixModule.cs"
#line 1379 "MatrixModule.cs"
                int* csharp2cuda_temp_620 = &((output)->valid);
                (*(csharp2cuda_temp_620) = 0);
#line 1380 "MatrixModule.cs"
                return;
            }
        }
#line 1383 "MatrixModule.cs"
        double largest = (eigenvalues)[csharp2cuda_i32_sub(size, 1)];
#line 1385 "MatrixModule.cs"
#line 1385 "MatrixModule.cs"
        double* csharp2cuda_temp_621 = &(largest);
        (*(csharp2cuda_temp_621) = mathblocks_maximum(0.0, largest));
#line 1386 "MatrixModule.cs"
#line 1386 "MatrixModule.cs"
        double* csharp2cuda_temp_622 = &((output)->scalar_value);
        (*(csharp2cuda_temp_622) = mathblocks_square_root(largest));
#line 1387 "MatrixModule.cs"
#line 1387 "MatrixModule.cs"
        double csharp2cuda_temp_623 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_623))))
        {
#line 1387 "MatrixModule.cs"
#line 1387 "MatrixModule.cs"
            int* csharp2cuda_temp_624 = &((output)->valid);
            (*(csharp2cuda_temp_624) = 0);
        }
    }
}

#line 271 "MatrixModule.cs"
__device__ bool mathblocks_matrix_is_positive_definite(
    const double* values,
    int size,
    double* lower)
#line 276 "MatrixModule.cs"
{
#line 277 "MatrixModule.cs"
#line 277 "MatrixModule.cs"
    bool csharp2cuda_temp_0 = mathblocks_matrix_is_symmetric(values, size, size);
    if ((!(csharp2cuda_temp_0)))
    {
#line 278 "MatrixModule.cs"
        return false;
    }
#line 279 "MatrixModule.cs"
    {
#line 279 "MatrixModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (csharp2cuda_i32_mul(size, size)))))
                break;
#line 280 "MatrixModule.cs"
#line 280 "MatrixModule.cs"
            double* csharp2cuda_temp_2 = &((lower)[index]);
            (*(csharp2cuda_temp_2) = 0.0);
#line 279 "MatrixModule.cs"
            int* csharp2cuda_temp_1 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 281 "MatrixModule.cs"
    {
#line 281 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (size))))
                break;
#line 282 "MatrixModule.cs"
            {
#line 283 "MatrixModule.cs"
                {
#line 283 "MatrixModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) <= (row))))
                            break;
#line 284 "MatrixModule.cs"
                        {
#line 285 "MatrixModule.cs"
                            double sum = (values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
#line 286 "MatrixModule.cs"
                            {
#line 286 "MatrixModule.cs"
                                int inner = 0;
                                while (true)
                                {
                                    if (!(((inner) < (column))))
                                        break;
#line 287 "MatrixModule.cs"
#line 287 "MatrixModule.cs"
                                    double* csharp2cuda_temp_6 = &(sum);
#line 287 "MatrixModule.cs"
                                    double csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
#line 287 "MatrixModule.cs"
                                    double csharp2cuda_temp_8 = (lower)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), inner)];
#line 287 "MatrixModule.cs"
                                    double csharp2cuda_temp_9 = (lower)[csharp2cuda_i32_add(csharp2cuda_i32_mul(column, size), inner)];
                                    (*(csharp2cuda_temp_6) = __dsub_rn(csharp2cuda_temp_7, __dmul_rn(csharp2cuda_temp_8, csharp2cuda_temp_9)));
#line 286 "MatrixModule.cs"
                                    int* csharp2cuda_temp_5 = &(inner);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
                                }
                            }
#line 288 "MatrixModule.cs"
                            if (((row) == (column)))
#line 289 "MatrixModule.cs"
                            {
#line 290 "MatrixModule.cs"
                                if (((sum) <= (0.0)))
                                {
#line 291 "MatrixModule.cs"
                                    return false;
                                }
#line 292 "MatrixModule.cs"
#line 292 "MatrixModule.cs"
                                double* csharp2cuda_temp_10 = &((lower)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)]);
                                (*(csharp2cuda_temp_10) = mathblocks_square_root(sum));
                            }
                            else
#line 295 "MatrixModule.cs"
                            {
#line 296 "MatrixModule.cs"
#line 296 "MatrixModule.cs"
                                double* csharp2cuda_temp_11 = &((lower)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)]);
#line 296 "MatrixModule.cs"
                                double csharp2cuda_temp_12 = (lower)[csharp2cuda_i32_add(csharp2cuda_i32_mul(column, size), column)];
#line 296 "MatrixModule.cs"
                                double csharp2cuda_temp_13 = __ddiv_rn(sum, csharp2cuda_temp_12);
                                (*(csharp2cuda_temp_11) = csharp2cuda_temp_13);
                            }
                        }
#line 283 "MatrixModule.cs"
                        int* csharp2cuda_temp_4 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
                    }
                }
            }
#line 281 "MatrixModule.cs"
            int* csharp2cuda_temp_3 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
        }
    }
#line 300 "MatrixModule.cs"
    return true;
}

#line 259 "MatrixModule.cs"
__device__ bool mathblocks_matrix_is_symmetric(const double* values, int rows, int columns)
#line 261 "MatrixModule.cs"
{
#line 262 "MatrixModule.cs"
    if (((rows) != (columns)))
    {
#line 263 "MatrixModule.cs"
        return false;
    }
#line 264 "MatrixModule.cs"
    {
#line 264 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (rows))))
                break;
#line 265 "MatrixModule.cs"
            {
#line 265 "MatrixModule.cs"
                int column = csharp2cuda_i32_add(row, 1);
                while (true)
                {
                    if (!(((column) < (columns))))
                        break;
#line 266 "MatrixModule.cs"
#line 266 "MatrixModule.cs"
                    double csharp2cuda_temp_2 = (values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 266 "MatrixModule.cs"
                    double csharp2cuda_temp_3 = (values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(column, columns), row)];
                    if (((csharp2cuda_temp_2) != (csharp2cuda_temp_3)))
                    {
#line 267 "MatrixModule.cs"
                        return false;
                    }
#line 265 "MatrixModule.cs"
                    int* csharp2cuda_temp_1 = &(column);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                }
            }
#line 264 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 268 "MatrixModule.cs"
    return true;
}

#line 416 "MatrixModule.cs"
__device__ void mathblocks_matrix_multiply_square(
    const double* left,
    const double* right,
    int size,
    double* destination)
#line 422 "MatrixModule.cs"
{
#line 423 "MatrixModule.cs"
    {
#line 423 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (size))))
                break;
#line 424 "MatrixModule.cs"
            {
#line 425 "MatrixModule.cs"
                {
#line 425 "MatrixModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (size))))
                            break;
#line 426 "MatrixModule.cs"
                        {
#line 427 "MatrixModule.cs"
                            double sum = 0.0;
#line 428 "MatrixModule.cs"
                            {
#line 428 "MatrixModule.cs"
                                int inner = 0;
                                while (true)
                                {
                                    if (!(((inner) < (size))))
                                        break;
#line 429 "MatrixModule.cs"
#line 429 "MatrixModule.cs"
                                    double* csharp2cuda_temp_3 = &(sum);
#line 429 "MatrixModule.cs"
                                    double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 429 "MatrixModule.cs"
                                    double csharp2cuda_temp_5 = (left)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), inner)];
#line 429 "MatrixModule.cs"
                                    double csharp2cuda_temp_6 = (right)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, size), column)];
                                    (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, __dmul_rn(csharp2cuda_temp_5, csharp2cuda_temp_6)));
#line 428 "MatrixModule.cs"
                                    int* csharp2cuda_temp_2 = &(inner);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                                }
                            }
#line 430 "MatrixModule.cs"
#line 430 "MatrixModule.cs"
                            double* csharp2cuda_temp_7 = &((destination)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)]);
                            (*(csharp2cuda_temp_7) = sum);
                        }
#line 425 "MatrixModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
            }
#line 423 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 382 "MatrixModule.cs"
__device__ int mathblocks_matrix_rank(const double* source, int rows, int columns, double* work)
#line 384 "MatrixModule.cs"
{
#line 385 "MatrixModule.cs"
    mathblocks_matrix_copy(source, work, csharp2cuda_i32_mul(rows, columns));
#line 386 "MatrixModule.cs"
    int rank = 0;
#line 387 "MatrixModule.cs"
    int pivot_column = 0;
#line 388 "MatrixModule.cs"
    while (true)
    {
#line 388 "MatrixModule.cs"
        bool csharp2cuda_temp_0;
#line 388 "MatrixModule.cs"
        if (((rank) < (rows)))
        {
#line 388 "MatrixModule.cs"
            csharp2cuda_temp_0 = ((pivot_column) < (columns));
        }
        else
        {
#line 388 "MatrixModule.cs"
            csharp2cuda_temp_0 = false;
        }
        if (!(csharp2cuda_temp_0))
            break;
#line 389 "MatrixModule.cs"
        {
#line 390 "MatrixModule.cs"
            int pivot_row = rank;
#line 391 "MatrixModule.cs"
            {
#line 391 "MatrixModule.cs"
                int row = csharp2cuda_i32_add(rank, 1);
                while (true)
                {
                    if (!(((row) < (rows))))
                        break;
#line 392 "MatrixModule.cs"
#line 392 "MatrixModule.cs"
                    double csharp2cuda_temp_2 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), pivot_column)];
#line 393 "MatrixModule.cs"
                    double csharp2cuda_temp_3 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, columns), pivot_column)];
                    if (((fabs(csharp2cuda_temp_2)) > (fabs(csharp2cuda_temp_3))))
#line 394 "MatrixModule.cs"
                    {
#line 395 "MatrixModule.cs"
#line 395 "MatrixModule.cs"
                        int* csharp2cuda_temp_4 = &(pivot_row);
                        (*(csharp2cuda_temp_4) = row);
                    }
#line 391 "MatrixModule.cs"
                    int* csharp2cuda_temp_1 = &(row);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                }
            }
#line 397 "MatrixModule.cs"
#line 397 "MatrixModule.cs"
            double csharp2cuda_temp_5 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, columns), pivot_column)];
            if (((csharp2cuda_temp_5) == (0.0)))
#line 398 "MatrixModule.cs"
            {
#line 399 "MatrixModule.cs"
#line 399 "MatrixModule.cs"
                int* csharp2cuda_temp_6 = &(pivot_column);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
#line 400 "MatrixModule.cs"
                continue;
            }
#line 402 "MatrixModule.cs"
            mathblocks_matrix_swap_rows(work, columns, rank, pivot_row);
#line 403 "MatrixModule.cs"
            double pivot = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(rank, columns), pivot_column)];
#line 404 "MatrixModule.cs"
            {
#line 404 "MatrixModule.cs"
                int row = csharp2cuda_i32_add(rank, 1);
                while (true)
                {
                    if (!(((row) < (rows))))
                        break;
#line 405 "MatrixModule.cs"
                    {
#line 406 "MatrixModule.cs"
                        double csharp2cuda_temp_8 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), pivot_column)];
#line 406 "MatrixModule.cs"
                        double scale = __ddiv_rn(csharp2cuda_temp_8, pivot);
#line 407 "MatrixModule.cs"
                        {
#line 407 "MatrixModule.cs"
                            int column = pivot_column;
                            while (true)
                            {
                                if (!(((column) < (columns))))
                                    break;
#line 408 "MatrixModule.cs"
#line 408 "MatrixModule.cs"
                                double* csharp2cuda_temp_10 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)]);
#line 408 "MatrixModule.cs"
                                double csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
#line 408 "MatrixModule.cs"
                                double csharp2cuda_temp_12 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(rank, columns), column)];
                                (*(csharp2cuda_temp_10) = __dsub_rn(csharp2cuda_temp_11, __dmul_rn(scale, csharp2cuda_temp_12)));
#line 407 "MatrixModule.cs"
                                int* csharp2cuda_temp_9 = &(column);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
                            }
                        }
                    }
#line 404 "MatrixModule.cs"
                    int* csharp2cuda_temp_7 = &(row);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_7));
                }
            }
#line 410 "MatrixModule.cs"
#line 410 "MatrixModule.cs"
            int* csharp2cuda_temp_13 = &(rank);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
#line 411 "MatrixModule.cs"
#line 411 "MatrixModule.cs"
            int* csharp2cuda_temp_14 = &(pivot_column);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_14));
        }
    }
#line 413 "MatrixModule.cs"
    return rank;
}

#line 83 "MatrixModule.cs"
__device__ void mathblocks_matrix_shape(MathBlockSlot* output, int rows, int columns)
#line 85 "MatrixModule.cs"
{
#line 86 "MatrixModule.cs"
    long long count = csharp2cuda_i64_mul(((long long)(rows)), ((long long)(columns)));
#line 87 "MatrixModule.cs"
#line 87 "MatrixModule.cs"
    int* csharp2cuda_temp_0 = &((output)->rows);
    (*(csharp2cuda_temp_0) = rows);
#line 88 "MatrixModule.cs"
#line 88 "MatrixModule.cs"
    int* csharp2cuda_temp_1 = &((output)->columns);
    (*(csharp2cuda_temp_1) = columns);
#line 89 "MatrixModule.cs"
#line 89 "MatrixModule.cs"
    int* csharp2cuda_temp_2 = &((output)->count);
#line 89 "MatrixModule.cs"
    int csharp2cuda_temp_3;
#line 89 "MatrixModule.cs"
    if (((count) > (2147483647LL)))
    {
#line 89 "MatrixModule.cs"
        csharp2cuda_temp_3 = csharp2cuda_i32_neg(1);
    }
    else
    {
#line 89 "MatrixModule.cs"
        csharp2cuda_temp_3 = csharp2cuda_i32_from_bits(count);
    }
    (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
#line 90 "MatrixModule.cs"
#line 90 "MatrixModule.cs"
    bool csharp2cuda_temp_4;
#line 90 "MatrixModule.cs"
    if (!(((rows) <= (0))))
    {
#line 90 "MatrixModule.cs"
        csharp2cuda_temp_4 = ((columns) <= (0));
    }
    else
    {
#line 90 "MatrixModule.cs"
        csharp2cuda_temp_4 = true;
    }
#line 90 "MatrixModule.cs"
    bool csharp2cuda_temp_5;
#line 90 "MatrixModule.cs"
    if (!(csharp2cuda_temp_4))
    {
#line 90 "MatrixModule.cs"
        int csharp2cuda_temp_6 = (output)->capacity;
#line 90 "MatrixModule.cs"
        csharp2cuda_temp_5 = ((count) > (((long long)(csharp2cuda_temp_6))));
    }
    else
    {
#line 90 "MatrixModule.cs"
        csharp2cuda_temp_5 = true;
    }
    if (csharp2cuda_temp_5)
    {
#line 91 "MatrixModule.cs"
#line 91 "MatrixModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
        (*(csharp2cuda_temp_7) = 0);
    }
}

#line 447 "MatrixModule.cs"
__device__ void mathblocks_matrix_submatrix_from_masks(
    const double* source,
    int source_columns,
    int row_mask,
    int column_mask,
    int order,
    double* destination)
#line 455 "MatrixModule.cs"
{
#line 456 "MatrixModule.cs"
    int output_row = 0;
#line 457 "MatrixModule.cs"
    {
#line 457 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (31))))
                break;
#line 458 "MatrixModule.cs"
            {
#line 459 "MatrixModule.cs"
                if (((csharp2cuda_i32_and(row_mask, csharp2cuda_i32_shl(1, row))) == (0)))
                {
#line 460 "MatrixModule.cs"
                    goto csharp2cuda_for_continue_1;
                }
#line 461 "MatrixModule.cs"
                int output_column = 0;
#line 462 "MatrixModule.cs"
                {
#line 462 "MatrixModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (31))))
                            break;
#line 463 "MatrixModule.cs"
                        {
#line 464 "MatrixModule.cs"
                            if (((csharp2cuda_i32_and(column_mask, csharp2cuda_i32_shl(1, column))) == (0)))
                            {
#line 465 "MatrixModule.cs"
                                goto csharp2cuda_for_continue_0;
                            }
#line 466 "MatrixModule.cs"
#line 466 "MatrixModule.cs"
                            double* csharp2cuda_temp_2 = &((destination)[csharp2cuda_i32_add(csharp2cuda_i32_mul(output_row, order), output_column)]);
#line 467 "MatrixModule.cs"
                            double csharp2cuda_temp_3 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, source_columns), column)];
                            (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
#line 468 "MatrixModule.cs"
#line 468 "MatrixModule.cs"
                            int* csharp2cuda_temp_4 = &(output_column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
                        }
                        csharp2cuda_for_continue_0:
#line 462 "MatrixModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 470 "MatrixModule.cs"
#line 470 "MatrixModule.cs"
                int* csharp2cuda_temp_5 = &(output_row);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
            }
            csharp2cuda_for_continue_1:
#line 457 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 109 "MatrixModule.cs"
__device__ void mathblocks_matrix_swap_rows(
    double* values,
    int columns,
    int left,
    int right)
#line 115 "MatrixModule.cs"
{
#line 116 "MatrixModule.cs"
    if (((left) == (right)))
    {
#line 117 "MatrixModule.cs"
        return;
    }
#line 118 "MatrixModule.cs"
    {
#line 118 "MatrixModule.cs"
        int column = 0;
        while (true)
        {
            if (!(((column) < (columns))))
                break;
#line 119 "MatrixModule.cs"
            {
#line 120 "MatrixModule.cs"
                double temporary = (values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, columns), column)];
#line 121 "MatrixModule.cs"
#line 121 "MatrixModule.cs"
                double* csharp2cuda_temp_1 = &((values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, columns), column)]);
#line 121 "MatrixModule.cs"
                double csharp2cuda_temp_2 = (values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(right, columns), column)];
                (*(csharp2cuda_temp_1) = csharp2cuda_temp_2);
#line 122 "MatrixModule.cs"
#line 122 "MatrixModule.cs"
                double* csharp2cuda_temp_3 = &((values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(right, columns), column)]);
                (*(csharp2cuda_temp_3) = temporary);
            }
#line 118 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(column);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 306 "MatrixModule.cs"
__device__ bool mathblocks_matrix_symmetric_eigenvalues(
    const double* source,
    int size,
    double* work,
    double* eigenvalues,
    double* buffer)
#line 313 "MatrixModule.cs"
{
#line 314 "MatrixModule.cs"
    mathblocks_matrix_copy(source, work, csharp2cuda_i32_mul(size, size));
#line 315 "MatrixModule.cs"
    long long budget = mathblocks_limit_jacobi_rotation_budget(size);
#line 316 "MatrixModule.cs"
    bool converged = false;
#line 319 "MatrixModule.cs"
    {
#line 319 "MatrixModule.cs"
        long long iteration = ((long long)(0));
        while (true)
        {
            if (!(((iteration) <= (budget))))
                break;
#line 320 "MatrixModule.cs"
            {
#line 321 "MatrixModule.cs"
                int pivot_row = 0;
#line 322 "MatrixModule.cs"
                int pivot_column = 0;
#line 323 "MatrixModule.cs"
                double largest = 0.0;
#line 324 "MatrixModule.cs"
                {
#line 324 "MatrixModule.cs"
                    int row = 0;
                    while (true)
                    {
                        if (!(((row) < (size))))
                            break;
#line 325 "MatrixModule.cs"
                        {
#line 326 "MatrixModule.cs"
                            {
#line 326 "MatrixModule.cs"
                                int column = csharp2cuda_i32_add(row, 1);
                                while (true)
                                {
                                    if (!(((column) < (size))))
                                        break;
#line 327 "MatrixModule.cs"
                                    {
#line 328 "MatrixModule.cs"
                                        double csharp2cuda_temp_3 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
#line 328 "MatrixModule.cs"
                                        double magnitude = fabs(csharp2cuda_temp_3);
#line 329 "MatrixModule.cs"
                                        if (((magnitude) <= (largest)))
                                        {
#line 330 "MatrixModule.cs"
                                            goto csharp2cuda_for_continue_0;
                                        }
#line 331 "MatrixModule.cs"
#line 331 "MatrixModule.cs"
                                        double* csharp2cuda_temp_4 = &(largest);
                                        (*(csharp2cuda_temp_4) = magnitude);
#line 332 "MatrixModule.cs"
#line 332 "MatrixModule.cs"
                                        int* csharp2cuda_temp_5 = &(pivot_row);
                                        (*(csharp2cuda_temp_5) = row);
#line 333 "MatrixModule.cs"
#line 333 "MatrixModule.cs"
                                        int* csharp2cuda_temp_6 = &(pivot_column);
                                        (*(csharp2cuda_temp_6) = column);
                                    }
                                    csharp2cuda_for_continue_0:
#line 326 "MatrixModule.cs"
                                    int* csharp2cuda_temp_2 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                                }
                            }
                        }
#line 324 "MatrixModule.cs"
                        int* csharp2cuda_temp_1 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 336 "MatrixModule.cs"
                if (((largest) == (0.0)))
#line 337 "MatrixModule.cs"
                {
#line 338 "MatrixModule.cs"
#line 338 "MatrixModule.cs"
                    bool* csharp2cuda_temp_7 = &(converged);
                    (*(csharp2cuda_temp_7) = true);
#line 339 "MatrixModule.cs"
                    break;
                }
#line 341 "MatrixModule.cs"
                if (((iteration) >= (budget)))
                {
#line 342 "MatrixModule.cs"
                    break;
                }
#line 344 "MatrixModule.cs"
                double csharp2cuda_temp_8 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot_column)];
#line 345 "MatrixModule.cs"
                double csharp2cuda_temp_9 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_column, size), pivot_column)];
#line 346 "MatrixModule.cs"
                double csharp2cuda_temp_10 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot_row)];
#line 343 "MatrixModule.cs"
                double angle = __dmul_rn(0.5, mathblocks_arc_tangent_2(__dmul_rn(2.0, csharp2cuda_temp_8), __dsub_rn(csharp2cuda_temp_9, csharp2cuda_temp_10)));
#line 347 "MatrixModule.cs"
                double cosine = mathblocks_cosine(angle);
#line 348 "MatrixModule.cs"
                double sine = mathblocks_sine(angle);
#line 349 "MatrixModule.cs"
                double aa = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot_row)];
#line 350 "MatrixModule.cs"
                double bb = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_column, size), pivot_column)];
#line 351 "MatrixModule.cs"
                double ab = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot_column)];
#line 352 "MatrixModule.cs"
#line 352 "MatrixModule.cs"
                double* csharp2cuda_temp_11 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot_row)]);
                (*(csharp2cuda_temp_11) = __dadd_rn(__dsub_rn(__dmul_rn(__dmul_rn(cosine, cosine), aa), __dmul_rn(__dmul_rn(__dmul_rn(2.0, sine), cosine), ab)), __dmul_rn(__dmul_rn(sine, sine), bb)));
#line 354 "MatrixModule.cs"
#line 354 "MatrixModule.cs"
                double* csharp2cuda_temp_12 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_column, size), pivot_column)]);
                (*(csharp2cuda_temp_12) = __dadd_rn(__dadd_rn(__dmul_rn(__dmul_rn(sine, sine), aa), __dmul_rn(__dmul_rn(__dmul_rn(2.0, sine), cosine), ab)), __dmul_rn(__dmul_rn(cosine, cosine), bb)));
#line 356 "MatrixModule.cs"
#line 356 "MatrixModule.cs"
                double* csharp2cuda_temp_13 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot_column)]);
                (*(csharp2cuda_temp_13) = 0.0);
#line 357 "MatrixModule.cs"
#line 357 "MatrixModule.cs"
                double* csharp2cuda_temp_14 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_column, size), pivot_row)]);
                (*(csharp2cuda_temp_14) = 0.0);
#line 358 "MatrixModule.cs"
                {
#line 358 "MatrixModule.cs"
                    int other = 0;
                    while (true)
                    {
                        if (!(((other) < (size))))
                            break;
#line 359 "MatrixModule.cs"
                        {
#line 360 "MatrixModule.cs"
#line 360 "MatrixModule.cs"
                            bool csharp2cuda_temp_16;
#line 360 "MatrixModule.cs"
                            if (!(((other) == (pivot_row))))
                            {
#line 360 "MatrixModule.cs"
                                csharp2cuda_temp_16 = ((other) == (pivot_column));
                            }
                            else
                            {
#line 360 "MatrixModule.cs"
                                csharp2cuda_temp_16 = true;
                            }
                            if (csharp2cuda_temp_16)
                            {
#line 361 "MatrixModule.cs"
                                goto csharp2cuda_for_continue_2;
                            }
#line 362 "MatrixModule.cs"
                            double first = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(other, size), pivot_row)];
#line 363 "MatrixModule.cs"
                            double second = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(other, size), pivot_column)];
#line 364 "MatrixModule.cs"
                            double first_value = __dsub_rn(__dmul_rn(cosine, first), __dmul_rn(sine, second));
#line 365 "MatrixModule.cs"
                            double second_value = __dadd_rn(__dmul_rn(sine, first), __dmul_rn(cosine, second));
#line 366 "MatrixModule.cs"
#line 366 "MatrixModule.cs"
                            double* csharp2cuda_temp_17 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(other, size), pivot_row)]);
                            (*(csharp2cuda_temp_17) = first_value);
#line 367 "MatrixModule.cs"
#line 367 "MatrixModule.cs"
                            double* csharp2cuda_temp_18 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), other)]);
                            (*(csharp2cuda_temp_18) = first_value);
#line 368 "MatrixModule.cs"
#line 368 "MatrixModule.cs"
                            double* csharp2cuda_temp_19 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(other, size), pivot_column)]);
                            (*(csharp2cuda_temp_19) = second_value);
#line 369 "MatrixModule.cs"
#line 369 "MatrixModule.cs"
                            double* csharp2cuda_temp_20 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_column, size), other)]);
                            (*(csharp2cuda_temp_20) = second_value);
                        }
                        csharp2cuda_for_continue_2:
#line 358 "MatrixModule.cs"
                        int* csharp2cuda_temp_15 = &(other);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
                    }
                }
            }
#line 319 "MatrixModule.cs"
            long long* csharp2cuda_temp_0 = &(iteration);
            csharp2cuda_i64_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 372 "MatrixModule.cs"
    {
#line 372 "MatrixModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (size))))
                break;
#line 373 "MatrixModule.cs"
#line 373 "MatrixModule.cs"
            double* csharp2cuda_temp_22 = &((eigenvalues)[index]);
#line 373 "MatrixModule.cs"
            double csharp2cuda_temp_23 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, size), index)];
            (*(csharp2cuda_temp_22) = csharp2cuda_temp_23);
#line 372 "MatrixModule.cs"
            int* csharp2cuda_temp_21 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_21));
        }
    }
#line 375 "MatrixModule.cs"
    double* sorted = mathblocks_stable_merge_sort(eigenvalues, buffer, size, false);
#line 376 "MatrixModule.cs"
    if (((((void*)(sorted))) != (((void*)(eigenvalues)))))
    {
#line 377 "MatrixModule.cs"
        {
#line 377 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (size))))
                    break;
#line 378 "MatrixModule.cs"
#line 378 "MatrixModule.cs"
                double* csharp2cuda_temp_25 = &((eigenvalues)[index]);
#line 378 "MatrixModule.cs"
                double csharp2cuda_temp_26 = (sorted)[index];
                (*(csharp2cuda_temp_25) = csharp2cuda_temp_26);
#line 377 "MatrixModule.cs"
                int* csharp2cuda_temp_24 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_24));
            }
        }
    }
#line 379 "MatrixModule.cs"
    return converged;
}

#line 159 "MatrixModule.cs"
__device__ bool mathblocks_matrix_try_solve(
    const double* matrix,
    const double* right,
    int size,
    double* augmented,
    double* solution)
#line 166 "MatrixModule.cs"
{
#line 167 "MatrixModule.cs"
    int columns = csharp2cuda_i32_add(size, 1);
#line 168 "MatrixModule.cs"
    {
#line 168 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (size))))
                break;
#line 169 "MatrixModule.cs"
            {
#line 170 "MatrixModule.cs"
                {
#line 170 "MatrixModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (size))))
                            break;
#line 171 "MatrixModule.cs"
#line 171 "MatrixModule.cs"
                        double* csharp2cuda_temp_2 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)]);
#line 171 "MatrixModule.cs"
                        double csharp2cuda_temp_3 = (matrix)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
                        (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
#line 170 "MatrixModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 172 "MatrixModule.cs"
#line 172 "MatrixModule.cs"
                double* csharp2cuda_temp_4 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), size)]);
#line 172 "MatrixModule.cs"
                double csharp2cuda_temp_5 = (right)[row];
                (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
            }
#line 168 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 174 "MatrixModule.cs"
    {
#line 174 "MatrixModule.cs"
        int pivot = 0;
        while (true)
        {
            if (!(((pivot) < (size))))
                break;
#line 175 "MatrixModule.cs"
            {
#line 176 "MatrixModule.cs"
                int pivot_row = pivot;
#line 177 "MatrixModule.cs"
                {
#line 177 "MatrixModule.cs"
                    int row = csharp2cuda_i32_add(pivot, 1);
                    while (true)
                    {
                        if (!(((row) < (size))))
                            break;
#line 178 "MatrixModule.cs"
#line 178 "MatrixModule.cs"
                        double csharp2cuda_temp_8 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), pivot)];
#line 179 "MatrixModule.cs"
                        double csharp2cuda_temp_9 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, columns), pivot)];
                        if (((fabs(csharp2cuda_temp_8)) > (fabs(csharp2cuda_temp_9))))
#line 180 "MatrixModule.cs"
                        {
#line 181 "MatrixModule.cs"
#line 181 "MatrixModule.cs"
                            int* csharp2cuda_temp_10 = &(pivot_row);
                            (*(csharp2cuda_temp_10) = row);
                        }
#line 177 "MatrixModule.cs"
                        int* csharp2cuda_temp_7 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_7));
                    }
                }
#line 183 "MatrixModule.cs"
#line 183 "MatrixModule.cs"
                double csharp2cuda_temp_11 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, columns), pivot)];
                if (((csharp2cuda_temp_11) == (0.0)))
                {
#line 184 "MatrixModule.cs"
                    return false;
                }
#line 185 "MatrixModule.cs"
                if (((pivot_row) != (pivot)))
                {
#line 186 "MatrixModule.cs"
                    mathblocks_matrix_swap_rows(augmented, columns, pivot, pivot_row);
                }
#line 187 "MatrixModule.cs"
                double diagonal = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, columns), pivot)];
#line 188 "MatrixModule.cs"
                {
#line 188 "MatrixModule.cs"
                    int column = pivot;
                    while (true)
                    {
                        if (!(((column) <= (size))))
                            break;
#line 189 "MatrixModule.cs"
#line 189 "MatrixModule.cs"
                        double* csharp2cuda_temp_13 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, columns), column)]);
#line 189 "MatrixModule.cs"
                        double csharp2cuda_temp_14 = *(csharp2cuda_temp_13);
                        (*(csharp2cuda_temp_13) = __ddiv_rn(csharp2cuda_temp_14, diagonal));
#line 188 "MatrixModule.cs"
                        int* csharp2cuda_temp_12 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_12));
                    }
                }
#line 190 "MatrixModule.cs"
                {
#line 190 "MatrixModule.cs"
                    int row = 0;
                    while (true)
                    {
                        if (!(((row) < (size))))
                            break;
#line 191 "MatrixModule.cs"
                        {
#line 192 "MatrixModule.cs"
                            if (((row) == (pivot)))
                            {
#line 193 "MatrixModule.cs"
                                goto csharp2cuda_for_continue_5;
                            }
#line 194 "MatrixModule.cs"
                            double scale = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), pivot)];
#line 195 "MatrixModule.cs"
                            {
#line 195 "MatrixModule.cs"
                                int column = pivot;
                                while (true)
                                {
                                    if (!(((column) <= (size))))
                                        break;
#line 196 "MatrixModule.cs"
#line 196 "MatrixModule.cs"
                                    double* csharp2cuda_temp_17 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)]);
#line 196 "MatrixModule.cs"
                                    double csharp2cuda_temp_18 = *(csharp2cuda_temp_17);
#line 197 "MatrixModule.cs"
                                    double csharp2cuda_temp_19 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, columns), column)];
                                    (*(csharp2cuda_temp_17) = __dsub_rn(csharp2cuda_temp_18, __dmul_rn(scale, csharp2cuda_temp_19)));
#line 195 "MatrixModule.cs"
                                    int* csharp2cuda_temp_16 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
                                }
                            }
                        }
                        csharp2cuda_for_continue_5:
#line 190 "MatrixModule.cs"
                        int* csharp2cuda_temp_15 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
                    }
                }
            }
#line 174 "MatrixModule.cs"
            int* csharp2cuda_temp_6 = &(pivot);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
        }
    }
#line 200 "MatrixModule.cs"
    {
#line 200 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (size))))
                break;
#line 201 "MatrixModule.cs"
            {
#line 202 "MatrixModule.cs"
#line 202 "MatrixModule.cs"
                double* csharp2cuda_temp_21 = &((solution)[row]);
#line 202 "MatrixModule.cs"
                double csharp2cuda_temp_22 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), size)];
                (*(csharp2cuda_temp_21) = csharp2cuda_temp_22);
#line 203 "MatrixModule.cs"
#line 203 "MatrixModule.cs"
                double csharp2cuda_temp_23 = (solution)[row];
                if ((!(isfinite(csharp2cuda_temp_23))))
                {
#line 204 "MatrixModule.cs"
                    return false;
                }
            }
#line 200 "MatrixModule.cs"
            int* csharp2cuda_temp_20 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_20));
        }
    }
#line 206 "MatrixModule.cs"
    return true;
}

#line 209 "MatrixModule.cs"
__device__ bool mathblocks_matrix_try_solve_basis(
    const double* matrix,
    int size,
    int basis,
    double* augmented,
    double* solution)
#line 216 "MatrixModule.cs"
{
#line 217 "MatrixModule.cs"
    int columns = csharp2cuda_i32_add(size, 1);
#line 218 "MatrixModule.cs"
    {
#line 218 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (size))))
                break;
#line 219 "MatrixModule.cs"
            {
#line 220 "MatrixModule.cs"
                {
#line 220 "MatrixModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (size))))
                            break;
#line 221 "MatrixModule.cs"
#line 221 "MatrixModule.cs"
                        double* csharp2cuda_temp_2 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)]);
#line 221 "MatrixModule.cs"
                        double csharp2cuda_temp_3 = (matrix)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
                        (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
#line 220 "MatrixModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 222 "MatrixModule.cs"
#line 222 "MatrixModule.cs"
                double* csharp2cuda_temp_4 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), size)]);
#line 222 "MatrixModule.cs"
                double csharp2cuda_temp_5;
#line 222 "MatrixModule.cs"
                if (((row) == (basis)))
                {
#line 222 "MatrixModule.cs"
                    csharp2cuda_temp_5 = 1.0;
                }
                else
                {
#line 222 "MatrixModule.cs"
                    csharp2cuda_temp_5 = 0.0;
                }
                (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
            }
#line 218 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 224 "MatrixModule.cs"
    {
#line 224 "MatrixModule.cs"
        int pivot = 0;
        while (true)
        {
            if (!(((pivot) < (size))))
                break;
#line 225 "MatrixModule.cs"
            {
#line 226 "MatrixModule.cs"
                int pivot_row = pivot;
#line 227 "MatrixModule.cs"
                {
#line 227 "MatrixModule.cs"
                    int row = csharp2cuda_i32_add(pivot, 1);
                    while (true)
                    {
                        if (!(((row) < (size))))
                            break;
#line 228 "MatrixModule.cs"
#line 228 "MatrixModule.cs"
                        double csharp2cuda_temp_8 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), pivot)];
#line 229 "MatrixModule.cs"
                        double csharp2cuda_temp_9 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, columns), pivot)];
                        if (((fabs(csharp2cuda_temp_8)) > (fabs(csharp2cuda_temp_9))))
#line 230 "MatrixModule.cs"
                        {
#line 231 "MatrixModule.cs"
#line 231 "MatrixModule.cs"
                            int* csharp2cuda_temp_10 = &(pivot_row);
                            (*(csharp2cuda_temp_10) = row);
                        }
#line 227 "MatrixModule.cs"
                        int* csharp2cuda_temp_7 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_7));
                    }
                }
#line 233 "MatrixModule.cs"
#line 233 "MatrixModule.cs"
                double csharp2cuda_temp_11 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, columns), pivot)];
                if (((csharp2cuda_temp_11) == (0.0)))
                {
#line 234 "MatrixModule.cs"
                    return false;
                }
#line 235 "MatrixModule.cs"
                if (((pivot_row) != (pivot)))
                {
#line 236 "MatrixModule.cs"
                    mathblocks_matrix_swap_rows(augmented, columns, pivot, pivot_row);
                }
#line 237 "MatrixModule.cs"
                double diagonal = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, columns), pivot)];
#line 238 "MatrixModule.cs"
                {
#line 238 "MatrixModule.cs"
                    int column = pivot;
                    while (true)
                    {
                        if (!(((column) <= (size))))
                            break;
#line 239 "MatrixModule.cs"
#line 239 "MatrixModule.cs"
                        double* csharp2cuda_temp_13 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, columns), column)]);
#line 239 "MatrixModule.cs"
                        double csharp2cuda_temp_14 = *(csharp2cuda_temp_13);
                        (*(csharp2cuda_temp_13) = __ddiv_rn(csharp2cuda_temp_14, diagonal));
#line 238 "MatrixModule.cs"
                        int* csharp2cuda_temp_12 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_12));
                    }
                }
#line 240 "MatrixModule.cs"
                {
#line 240 "MatrixModule.cs"
                    int row = 0;
                    while (true)
                    {
                        if (!(((row) < (size))))
                            break;
#line 241 "MatrixModule.cs"
                        {
#line 242 "MatrixModule.cs"
                            if (((row) == (pivot)))
                            {
#line 243 "MatrixModule.cs"
                                goto csharp2cuda_for_continue_5;
                            }
#line 244 "MatrixModule.cs"
                            double scale = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), pivot)];
#line 245 "MatrixModule.cs"
                            {
#line 245 "MatrixModule.cs"
                                int column = pivot;
                                while (true)
                                {
                                    if (!(((column) <= (size))))
                                        break;
#line 246 "MatrixModule.cs"
#line 246 "MatrixModule.cs"
                                    double* csharp2cuda_temp_17 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)]);
#line 246 "MatrixModule.cs"
                                    double csharp2cuda_temp_18 = *(csharp2cuda_temp_17);
#line 247 "MatrixModule.cs"
                                    double csharp2cuda_temp_19 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, columns), column)];
                                    (*(csharp2cuda_temp_17) = __dsub_rn(csharp2cuda_temp_18, __dmul_rn(scale, csharp2cuda_temp_19)));
#line 245 "MatrixModule.cs"
                                    int* csharp2cuda_temp_16 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
                                }
                            }
                        }
                        csharp2cuda_for_continue_5:
#line 240 "MatrixModule.cs"
                        int* csharp2cuda_temp_15 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
                    }
                }
            }
#line 224 "MatrixModule.cs"
            int* csharp2cuda_temp_6 = &(pivot);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
        }
    }
#line 250 "MatrixModule.cs"
    {
#line 250 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (size))))
                break;
#line 251 "MatrixModule.cs"
            {
#line 252 "MatrixModule.cs"
#line 252 "MatrixModule.cs"
                double* csharp2cuda_temp_21 = &((solution)[row]);
#line 252 "MatrixModule.cs"
                double csharp2cuda_temp_22 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), size)];
                (*(csharp2cuda_temp_21) = csharp2cuda_temp_22);
#line 253 "MatrixModule.cs"
#line 253 "MatrixModule.cs"
                double csharp2cuda_temp_23 = (solution)[row];
                if ((!(isfinite(csharp2cuda_temp_23))))
                {
#line 254 "MatrixModule.cs"
                    return false;
                }
            }
#line 250 "MatrixModule.cs"
            int* csharp2cuda_temp_20 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_20));
        }
    }
#line 256 "MatrixModule.cs"
    return true;
}

#line 435 "MatrixModule.cs"
__device__ int mathblocks_pop_count(int value)
#line 437 "MatrixModule.cs"
{
#line 438 "MatrixModule.cs"
    int count = 0;
#line 439 "MatrixModule.cs"
    while (true)
    {
        if (!(((value) != (0))))
            break;
#line 440 "MatrixModule.cs"
        {
#line 441 "MatrixModule.cs"
#line 441 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(count);
#line 441 "MatrixModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, csharp2cuda_i32_and(value, 1)));
#line 442 "MatrixModule.cs"
#line 442 "MatrixModule.cs"
            int* csharp2cuda_temp_2 = &(value);
#line 442 "MatrixModule.cs"
            int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
            (*(csharp2cuda_temp_2) = csharp2cuda_i32_shr(csharp2cuda_temp_3, 1));
        }
    }
#line 444 "MatrixModule.cs"
    return count;
}