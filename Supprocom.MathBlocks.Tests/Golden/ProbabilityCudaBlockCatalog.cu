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

#ifndef CSHARP2CUDA_ARRAY_VIEWS_0_3
#define CSHARP2CUDA_ARRAY_VIEWS_0_3
template <typename T>
struct csharp2cuda_readonly_array_view
{
    const T* data;
    int length;
    bool is_null;

    __device__ csharp2cuda_readonly_array_view()
        : data(nullptr), length(0), is_null(false)
    {
    }

    __device__ csharp2cuda_readonly_array_view(const T* address, int count)
        : data(address), length(count), is_null(false)
    {
        if (count < 0 || (address == nullptr && count != 0))
            asm volatile("trap;");
    }

    __device__ csharp2cuda_readonly_array_view(
        const T* address,
        int count,
        bool null_state)
        : data(address), length(count), is_null(null_state)
    {
        if (count < 0) asm volatile("trap;");
    }

    __device__ int get_length() const
    {
        if (is_null) asm volatile("trap;");
        return length;
    }

    __device__ bool is_empty() const
    {
        return get_length() == 0;
    }

    __device__ const T& operator[](int index) const
    {
        if (is_null || (unsigned int)index >= (unsigned int)length)
            asm volatile("trap;");
        return data[index];
    }

    __device__ csharp2cuda_readonly_array_view<T> slice(int start) const
    {
        if (is_null || (unsigned int)start > (unsigned int)length)
            asm volatile("trap;");
        return csharp2cuda_readonly_array_view<T>(
            data == nullptr ? nullptr : data + start,
            length - start);
    }

    __device__ csharp2cuda_readonly_array_view<T> slice(int start, int count) const
    {
        if (is_null ||
            (unsigned int)start > (unsigned int)length ||
            (unsigned int)count > (unsigned int)(length - start))
            asm volatile("trap;");
        return csharp2cuda_readonly_array_view<T>(
            data == nullptr ? nullptr : data + start,
            count);
    }

    template <typename TDestination>
    __device__ void copy_to(TDestination destination) const
    {
        if (!try_copy_to(destination)) asm volatile("trap;");
    }

    template <typename TDestination>
    __device__ bool try_copy_to(TDestination destination) const
    {
        if (is_null || destination.is_null) asm volatile("trap;");
        if (destination.length < length)
            return false;
        unsigned long long source_address = (unsigned long long)data;
        unsigned long long destination_address =
            (unsigned long long)destination.data;
        unsigned long long byte_length =
            (unsigned long long)length * (unsigned long long)sizeof(T);
        if (destination_address > source_address &&
            destination_address < source_address + byte_length)
        {
            for (int index = length; index-- > 0;)
                destination.data[index] = data[index];
        }
        else
        {
            for (int index = 0; index < length; index++)
                destination.data[index] = data[index];
        }
        return true;
    }
};

template <typename T>
struct csharp2cuda_array_view
{
    T* data;
    int length;
    bool is_null;

    __device__ csharp2cuda_array_view()
        : data(nullptr), length(0), is_null(false)
    {
    }

    __device__ csharp2cuda_array_view(T* address, int count)
        : data(address), length(count), is_null(false)
    {
        if (count < 0 || (address == nullptr && count != 0))
            asm volatile("trap;");
    }

    __device__ csharp2cuda_array_view(T* address, int count, bool null_state)
        : data(address), length(count), is_null(null_state)
    {
        if (count < 0) asm volatile("trap;");
    }

    __device__ int get_length() const
    {
        if (is_null) asm volatile("trap;");
        return length;
    }

    __device__ bool is_empty() const
    {
        return get_length() == 0;
    }

    __device__ T& operator[](int index) const
    {
        if (is_null || (unsigned int)index >= (unsigned int)length)
            asm volatile("trap;");
        return data[index];
    }

    __device__ csharp2cuda_array_view<T> slice(int start) const
    {
        if (is_null || (unsigned int)start > (unsigned int)length)
            asm volatile("trap;");
        return csharp2cuda_array_view<T>(
            data == nullptr ? nullptr : data + start,
            length - start);
    }

    __device__ csharp2cuda_array_view<T> slice(int start, int count) const
    {
        if (is_null ||
            (unsigned int)start > (unsigned int)length ||
            (unsigned int)count > (unsigned int)(length - start))
            asm volatile("trap;");
        return csharp2cuda_array_view<T>(
            data == nullptr ? nullptr : data + start,
            count);
    }

    __device__ csharp2cuda_array_view<T> as_span() const
    {
        return is_null
            ? csharp2cuda_array_view<T>(nullptr, 0, false)
            : csharp2cuda_array_view<T>(data, length, false);
    }

    __device__ void clear() const
    {
        if (is_null) asm volatile("trap;");
        for (int index = 0; index < length; index++)
            data[index] = T{};
    }

    __device__ void fill(T value) const
    {
        if (is_null) asm volatile("trap;");
        for (int index = 0; index < length; index++)
            data[index] = value;
    }

    __device__ void copy_to(csharp2cuda_array_view<T> destination) const
    {
        if (!try_copy_to(destination)) asm volatile("trap;");
    }

    __device__ bool try_copy_to(csharp2cuda_array_view<T> destination) const
    {
        if (is_null || destination.is_null) asm volatile("trap;");
        if (destination.length < length)
            return false;
        unsigned long long source_address = (unsigned long long)data;
        unsigned long long destination_address =
            (unsigned long long)destination.data;
        unsigned long long byte_length =
            (unsigned long long)length * (unsigned long long)sizeof(T);
        if (destination_address > source_address &&
            destination_address < source_address + byte_length)
        {
            for (int index = length; index-- > 0;)
                destination.data[index] = data[index];
        }
        else
        {
            for (int index = 0; index < length; index++)
                destination.data[index] = data[index];
        }
        return true;
    }

    __device__ operator csharp2cuda_readonly_array_view<T>() const
    {
        return csharp2cuda_readonly_array_view<T>(data, length, is_null);
    }
};

template <typename TSourceView, typename T>
static __device__ __forceinline__ csharp2cuda_array_view<T>
csharp2cuda_copy_array(
    TSourceView source,
    T* destination,
    int capacity)
{
    if (source.is_null || source.length < 0 || source.length > capacity)
        asm volatile("trap;");
    for (int index = 0; index < source.length; index++)
        destination[index] = source.data[index];
    return csharp2cuda_array_view<T>(destination, source.length, false);
}
#endif

#line 212 "ProbabilityModule.cs"
__device__ double mathblocks_probability_beta_fraction(double x, double left, double right, bool* converged);

#line 125 "ProbabilityModule.cs"
__device__ double mathblocks_probability_binomial(int n, int k);

#line 277 "ProbabilityModule.cs"
__device__ MathBlockComplexValue mathblocks_probability_complex_cube_root(
    MathBlockComplexValue value);

#line 445 "ProbabilityModule.cs"
__device__ void mathblocks_probability_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 138 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_distribution(const double* values, int count);

#line 148 "ProbabilityModule.cs"
__device__ double mathblocks_probability_entropy(const double* values, int count);

#line 256 "ProbabilityModule.cs"
__device__ double mathblocks_probability_incomplete_beta(
    double x,
    double left,
    double right,
    bool* converged);

#line 116 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_integer(double value, int* result);

#line 158 "ProbabilityModule.cs"
__device__ double mathblocks_probability_kl(
    const double* probabilities,
    const double* reference,
    int count);

#line 199 "ProbabilityModule.cs"
__device__ double mathblocks_probability_log_gamma(double value);

#line 172 "ProbabilityModule.cs"
__device__ double mathblocks_probability_log_gamma_core(double value);

#line 290 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_ordered_entropy_value(
    const double* values,
    int count,
    double order,
    bool renyi,
    double* value);

#line 320 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_scalar_value(int opcode, double a, double b, double c, double* value, bool* converged);

#line 212 "ProbabilityModule.cs"
__device__ double mathblocks_probability_beta_fraction(double x, double left, double right, bool* converged)
#line 214 "ProbabilityModule.cs"
{
#line 215 "ProbabilityModule.cs"
    int maximum_iterations = mathblocks_limit_incomplete_beta_maximum_iterations();
#line 216 "ProbabilityModule.cs"
    double tolerance = mathblocks_limit_incomplete_beta_tolerance();
#line 217 "ProbabilityModule.cs"
    const double minimum = 1E-300;
#line 218 "ProbabilityModule.cs"
#line 218 "ProbabilityModule.cs"
    bool* csharp2cuda_temp_0 = converged;
    (*(csharp2cuda_temp_0) = false);
#line 219 "ProbabilityModule.cs"
    double qab = __dadd_rn(left, right);
#line 220 "ProbabilityModule.cs"
    double qap = __dadd_rn(left, 1.0);
#line 221 "ProbabilityModule.cs"
    double qam = __dsub_rn(left, 1.0);
#line 222 "ProbabilityModule.cs"
    double c = 1.0;
#line 223 "ProbabilityModule.cs"
    double csharp2cuda_temp_1 = __ddiv_rn(__dmul_rn(qab, x), qap);
#line 223 "ProbabilityModule.cs"
    double d = __dsub_rn(1.0, csharp2cuda_temp_1);
#line 224 "ProbabilityModule.cs"
    if (((fabs(d)) < (minimum)))
    {
#line 224 "ProbabilityModule.cs"
#line 224 "ProbabilityModule.cs"
        double* csharp2cuda_temp_2 = &(d);
        (*(csharp2cuda_temp_2) = minimum);
    }
#line 225 "ProbabilityModule.cs"
#line 225 "ProbabilityModule.cs"
    double* csharp2cuda_temp_3 = &(d);
#line 225 "ProbabilityModule.cs"
    double csharp2cuda_temp_4 = __ddiv_rn(1.0, d);
    (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 226 "ProbabilityModule.cs"
    double result = d;
#line 227 "ProbabilityModule.cs"
    {
#line 227 "ProbabilityModule.cs"
        int iteration = 1;
        while (true)
        {
            if (!(((iteration) <= (maximum_iterations))))
                break;
#line 228 "ProbabilityModule.cs"
            {
#line 229 "ProbabilityModule.cs"
                double doubled = __dmul_rn(2.0, ((double)(iteration)));
#line 230 "ProbabilityModule.cs"
                double coefficient = __ddiv_rn(__dmul_rn(__dmul_rn(((double)(iteration)), __dsub_rn(right, ((double)(iteration)))), x), __dmul_rn(__dadd_rn(qam, doubled), __dadd_rn(left, doubled)));
#line 232 "ProbabilityModule.cs"
#line 232 "ProbabilityModule.cs"
                double* csharp2cuda_temp_6 = &(d);
                (*(csharp2cuda_temp_6) = __dadd_rn(1.0, __dmul_rn(coefficient, d)));
#line 233 "ProbabilityModule.cs"
                if (((fabs(d)) < (minimum)))
                {
#line 233 "ProbabilityModule.cs"
#line 233 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_7 = &(d);
                    (*(csharp2cuda_temp_7) = minimum);
                }
#line 234 "ProbabilityModule.cs"
#line 234 "ProbabilityModule.cs"
                double* csharp2cuda_temp_8 = &(c);
#line 234 "ProbabilityModule.cs"
                double csharp2cuda_temp_9 = __ddiv_rn(coefficient, c);
                (*(csharp2cuda_temp_8) = __dadd_rn(1.0, csharp2cuda_temp_9));
#line 235 "ProbabilityModule.cs"
                if (((fabs(c)) < (minimum)))
                {
#line 235 "ProbabilityModule.cs"
#line 235 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_10 = &(c);
                    (*(csharp2cuda_temp_10) = minimum);
                }
#line 236 "ProbabilityModule.cs"
#line 236 "ProbabilityModule.cs"
                double* csharp2cuda_temp_11 = &(d);
#line 236 "ProbabilityModule.cs"
                double csharp2cuda_temp_12 = __ddiv_rn(1.0, d);
                (*(csharp2cuda_temp_11) = csharp2cuda_temp_12);
#line 237 "ProbabilityModule.cs"
#line 237 "ProbabilityModule.cs"
                double* csharp2cuda_temp_13 = &(result);
#line 237 "ProbabilityModule.cs"
                double csharp2cuda_temp_14 = *(csharp2cuda_temp_13);
                (*(csharp2cuda_temp_13) = __dmul_rn(csharp2cuda_temp_14, __dmul_rn(d, c)));
#line 238 "ProbabilityModule.cs"
#line 238 "ProbabilityModule.cs"
                double* csharp2cuda_temp_15 = &(coefficient);
#line 238 "ProbabilityModule.cs"
                double csharp2cuda_temp_16 = __ddiv_rn(__dmul_rn(__dmul_rn((-(__dadd_rn(left, ((double)(iteration))))), __dadd_rn(qab, ((double)(iteration)))), x), __dmul_rn(__dadd_rn(left, doubled), __dadd_rn(qap, doubled)));
                (*(csharp2cuda_temp_15) = csharp2cuda_temp_16);
#line 240 "ProbabilityModule.cs"
#line 240 "ProbabilityModule.cs"
                double* csharp2cuda_temp_17 = &(d);
                (*(csharp2cuda_temp_17) = __dadd_rn(1.0, __dmul_rn(coefficient, d)));
#line 241 "ProbabilityModule.cs"
                if (((fabs(d)) < (minimum)))
                {
#line 241 "ProbabilityModule.cs"
#line 241 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_18 = &(d);
                    (*(csharp2cuda_temp_18) = minimum);
                }
#line 242 "ProbabilityModule.cs"
#line 242 "ProbabilityModule.cs"
                double* csharp2cuda_temp_19 = &(c);
#line 242 "ProbabilityModule.cs"
                double csharp2cuda_temp_20 = __ddiv_rn(coefficient, c);
                (*(csharp2cuda_temp_19) = __dadd_rn(1.0, csharp2cuda_temp_20));
#line 243 "ProbabilityModule.cs"
                if (((fabs(c)) < (minimum)))
                {
#line 243 "ProbabilityModule.cs"
#line 243 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_21 = &(c);
                    (*(csharp2cuda_temp_21) = minimum);
                }
#line 244 "ProbabilityModule.cs"
#line 244 "ProbabilityModule.cs"
                double* csharp2cuda_temp_22 = &(d);
#line 244 "ProbabilityModule.cs"
                double csharp2cuda_temp_23 = __ddiv_rn(1.0, d);
                (*(csharp2cuda_temp_22) = csharp2cuda_temp_23);
#line 245 "ProbabilityModule.cs"
                double delta = __dmul_rn(d, c);
#line 246 "ProbabilityModule.cs"
#line 246 "ProbabilityModule.cs"
                double* csharp2cuda_temp_24 = &(result);
#line 246 "ProbabilityModule.cs"
                double csharp2cuda_temp_25 = *(csharp2cuda_temp_24);
                (*(csharp2cuda_temp_24) = __dmul_rn(csharp2cuda_temp_25, delta));
#line 247 "ProbabilityModule.cs"
                if (((fabs(__dsub_rn(delta, 1.0))) <= (tolerance)))
#line 248 "ProbabilityModule.cs"
                {
#line 249 "ProbabilityModule.cs"
#line 249 "ProbabilityModule.cs"
                    bool* csharp2cuda_temp_26 = converged;
                    (*(csharp2cuda_temp_26) = true);
#line 250 "ProbabilityModule.cs"
                    break;
                }
            }
#line 227 "ProbabilityModule.cs"
            int* csharp2cuda_temp_5 = &(iteration);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
        }
    }
#line 253 "ProbabilityModule.cs"
    return result;
}

#line 125 "ProbabilityModule.cs"
__device__ double mathblocks_probability_binomial(int n, int k)
#line 127 "ProbabilityModule.cs"
{
#line 128 "ProbabilityModule.cs"
#line 128 "ProbabilityModule.cs"
    bool csharp2cuda_temp_0;
#line 128 "ProbabilityModule.cs"
    if (!(((k) < (0))))
    {
#line 128 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = ((k) > (n));
    }
    else
    {
#line 128 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 129 "ProbabilityModule.cs"
        return 0.0;
    }
#line 130 "ProbabilityModule.cs"
    if (((k) > (csharp2cuda_i32_sub(n, k))))
    {
#line 131 "ProbabilityModule.cs"
#line 131 "ProbabilityModule.cs"
        int* csharp2cuda_temp_1 = &(k);
        (*(csharp2cuda_temp_1) = csharp2cuda_i32_sub(n, k));
    }
#line 132 "ProbabilityModule.cs"
    double result = 1.0;
#line 133 "ProbabilityModule.cs"
    {
#line 133 "ProbabilityModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) <= (k))))
                break;
#line 134 "ProbabilityModule.cs"
#line 134 "ProbabilityModule.cs"
            double* csharp2cuda_temp_3 = &(result);
#line 134 "ProbabilityModule.cs"
            double csharp2cuda_temp_4 = __ddiv_rn(__dmul_rn(result, ((double)(csharp2cuda_i32_add(csharp2cuda_i32_sub(n, k), index)))), ((double)(index)));
            (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 133 "ProbabilityModule.cs"
            int* csharp2cuda_temp_2 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 135 "ProbabilityModule.cs"
    return result;
}

#line 277 "ProbabilityModule.cs"
__device__ MathBlockComplexValue mathblocks_probability_complex_cube_root(
    MathBlockComplexValue value)
#line 280 "ProbabilityModule.cs"
{
#line 281 "ProbabilityModule.cs"
#line 281 "ProbabilityModule.cs"
    double csharp2cuda_temp_0 = (value).real;
#line 281 "ProbabilityModule.cs"
    bool csharp2cuda_temp_1;
#line 281 "ProbabilityModule.cs"
    if (((csharp2cuda_temp_0) == (0.0)))
    {
#line 281 "ProbabilityModule.cs"
        double csharp2cuda_temp_2 = (value).imaginary;
#line 281 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) == (0.0));
    }
    else
    {
#line 281 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = false;
    }
    if (csharp2cuda_temp_1)
    {
#line 282 "ProbabilityModule.cs"
        return mathblocks_complex_make(0.0, 0.0);
    }
#line 283 "ProbabilityModule.cs"
#line 285 "ProbabilityModule.cs"
    double csharp2cuda_temp_3 = __ddiv_rn(mathblocks_complex_phase(value), 3.0);
    return mathblocks_complex_from_polar(mathblocks_cube_root(mathblocks_complex_magnitude(value)), csharp2cuda_temp_3);
}

#line 445 "ProbabilityModule.cs"
__device__ void mathblocks_probability_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 451 "ProbabilityModule.cs"
{
#line 452 "ProbabilityModule.cs"
    int thread = threadIdx.x;
#line 453 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 453 "ProbabilityModule.cs"
    if (((input_count) > (0)))
    {
#line 453 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 453 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 453 "ProbabilityModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 454 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 454 "ProbabilityModule.cs"
    if (((input_count) > (1)))
    {
#line 454 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 454 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 454 "ProbabilityModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 455 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 455 "ProbabilityModule.cs"
    if (((input_count) > (2)))
    {
#line 455 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 455 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 455 "ProbabilityModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 456 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_3;
#line 456 "ProbabilityModule.cs"
    if (((input_count) > (3)))
    {
#line 456 "ProbabilityModule.cs"
        csharp2cuda_temp_3 = (inputs)[3];
    }
    else
    {
#line 456 "ProbabilityModule.cs"
        csharp2cuda_temp_3 = ((MathBlockSlot*)(nullptr));
    }
#line 456 "ProbabilityModule.cs"
    const MathBlockSlot* fourth = csharp2cuda_temp_3;
#line 457 "ProbabilityModule.cs"
    if (((thread) == (0)))
#line 458 "ProbabilityModule.cs"
    {
#line 459 "ProbabilityModule.cs"
#line 459 "ProbabilityModule.cs"
        double* csharp2cuda_temp_4 = &((output)->scalar_value);
        (*(csharp2cuda_temp_4) = 0.0);
#line 460 "ProbabilityModule.cs"
#line 460 "ProbabilityModule.cs"
        int* csharp2cuda_temp_5 = &((output)->boolean_value);
        (*(csharp2cuda_temp_5) = 0);
#line 461 "ProbabilityModule.cs"
#line 461 "ProbabilityModule.cs"
        int* csharp2cuda_temp_6 = &((output)->rows);
        (*(csharp2cuda_temp_6) = 0);
#line 462 "ProbabilityModule.cs"
#line 462 "ProbabilityModule.cs"
        int* csharp2cuda_temp_7 = &((output)->columns);
        (*(csharp2cuda_temp_7) = 0);
#line 463 "ProbabilityModule.cs"
#line 463 "ProbabilityModule.cs"
        int* csharp2cuda_temp_8 = &((output)->count);
        (*(csharp2cuda_temp_8) = 0);
#line 464 "ProbabilityModule.cs"
#line 464 "ProbabilityModule.cs"
        int* csharp2cuda_temp_9 = &((output)->valid);
        (*(csharp2cuda_temp_9) = 1);
#line 465 "ProbabilityModule.cs"
        {
#line 465 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 466 "ProbabilityModule.cs"
#line 466 "ProbabilityModule.cs"
                MathBlockSlot* csharp2cuda_temp_11 = (inputs)[index];
#line 466 "ProbabilityModule.cs"
                bool csharp2cuda_temp_12;
#line 466 "ProbabilityModule.cs"
                if (!(((((void*)(csharp2cuda_temp_11))) == (((void*)(nullptr))))))
                {
#line 466 "ProbabilityModule.cs"
                    MathBlockSlot* csharp2cuda_temp_13 = (inputs)[index];
#line 466 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_14 = (csharp2cuda_temp_13)->valid;
#line 466 "ProbabilityModule.cs"
                    csharp2cuda_temp_12 = (!(csharp2cuda_temp_14));
                }
                else
                {
#line 466 "ProbabilityModule.cs"
                    csharp2cuda_temp_12 = true;
                }
                if (csharp2cuda_temp_12)
                {
#line 466 "ProbabilityModule.cs"
#line 466 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_15 = &((output)->valid);
                    (*(csharp2cuda_temp_15) = 0);
                }
#line 465 "ProbabilityModule.cs"
                int* csharp2cuda_temp_10 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_10));
            }
        }
    }
#line 468 "ProbabilityModule.cs"
    __syncthreads();
#line 469 "ProbabilityModule.cs"
#line 469 "ProbabilityModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 470 "ProbabilityModule.cs"
        return;
    }
#line 472 "ProbabilityModule.cs"
    double* csharp2cuda_temp_17;
#line 472 "ProbabilityModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 472 "ProbabilityModule.cs"
        csharp2cuda_temp_17 = ((double*)(nullptr));
    }
    else
    {
#line 472 "ProbabilityModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 472 "ProbabilityModule.cs"
        csharp2cuda_temp_17 = ((double*)(csharp2cuda_temp_18));
    }
#line 472 "ProbabilityModule.cs"
    const double* a = csharp2cuda_temp_17;
#line 473 "ProbabilityModule.cs"
    double* csharp2cuda_temp_19;
#line 473 "ProbabilityModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 473 "ProbabilityModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 473 "ProbabilityModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 473 "ProbabilityModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 473 "ProbabilityModule.cs"
    const double* b = csharp2cuda_temp_19;
#line 474 "ProbabilityModule.cs"
    unsigned long long csharp2cuda_temp_21 = (output)->data_pointer;
#line 474 "ProbabilityModule.cs"
    double* result = ((double*)(csharp2cuda_temp_21));
#line 475 "ProbabilityModule.cs"
    unsigned long long csharp2cuda_temp_22 = (output)->scratch_pointer;
#line 475 "ProbabilityModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_22));
#line 477 "ProbabilityModule.cs"
    if (((opcode) == (3)))
#line 478 "ProbabilityModule.cs"
    {
#line 480 "ProbabilityModule.cs"
#line 480 "ProbabilityModule.cs"
        int csharp2cuda_temp_23 = (first)->count;
        if (((csharp2cuda_temp_23) > (mathblocks_limit_explicit_subset_size())))
#line 481 "ProbabilityModule.cs"
        {
#line 482 "ProbabilityModule.cs"
            if (((thread) == (0)))
            {
#line 483 "ProbabilityModule.cs"
#line 483 "ProbabilityModule.cs"
                int* csharp2cuda_temp_24 = &((output)->valid);
                (*(csharp2cuda_temp_24) = 0);
            }
#line 484 "ProbabilityModule.cs"
            return;
        }
#line 486 "ProbabilityModule.cs"
        if (((thread) == (0)))
        {
#line 487 "ProbabilityModule.cs"
#line 487 "ProbabilityModule.cs"
            int csharp2cuda_temp_25 = (first)->count;
            mathblocks_set_vector_shape(output, csharp2cuda_i32_sub(csharp2cuda_i32_shl(1, csharp2cuda_temp_25), 1));
        }
#line 488 "ProbabilityModule.cs"
        __syncthreads();
#line 489 "ProbabilityModule.cs"
        {
#line 489 "ProbabilityModule.cs"
            int mask = csharp2cuda_i32_add(thread, 1);
            while (true)
            {
#line 489 "ProbabilityModule.cs"
                bool csharp2cuda_temp_28 = (output)->valid;
#line 489 "ProbabilityModule.cs"
                bool csharp2cuda_temp_29;
#line 489 "ProbabilityModule.cs"
                if (csharp2cuda_temp_28)
                {
#line 489 "ProbabilityModule.cs"
                    int csharp2cuda_temp_30 = (output)->count;
#line 489 "ProbabilityModule.cs"
                    csharp2cuda_temp_29 = ((mask) <= (csharp2cuda_temp_30));
                }
                else
                {
#line 489 "ProbabilityModule.cs"
                    csharp2cuda_temp_29 = false;
                }
                if (!(csharp2cuda_temp_29))
                    break;
#line 490 "ProbabilityModule.cs"
                {
#line 491 "ProbabilityModule.cs"
                    double sum = 0.0;
#line 492 "ProbabilityModule.cs"
                    {
#line 492 "ProbabilityModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 492 "ProbabilityModule.cs"
                            int csharp2cuda_temp_32 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_32))))
                                break;
#line 493 "ProbabilityModule.cs"
                            if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, index))) != (0)))
                            {
#line 493 "ProbabilityModule.cs"
#line 493 "ProbabilityModule.cs"
                                double* csharp2cuda_temp_33 = &(sum);
#line 493 "ProbabilityModule.cs"
                                double csharp2cuda_temp_34 = *(csharp2cuda_temp_33);
#line 493 "ProbabilityModule.cs"
                                double csharp2cuda_temp_35 = (a)[index];
                                (*(csharp2cuda_temp_33) = __dadd_rn(csharp2cuda_temp_34, csharp2cuda_temp_35));
                            }
#line 492 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_31 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                        }
                    }
#line 494 "ProbabilityModule.cs"
#line 494 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_36 = &((result)[csharp2cuda_i32_sub(mask, 1)]);
                    (*(csharp2cuda_temp_36) = sum);
#line 495 "ProbabilityModule.cs"
                    if ((!(isfinite(sum))))
                    {
#line 495 "ProbabilityModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 489 "ProbabilityModule.cs"
                int* csharp2cuda_temp_26 = &(mask);
#line 489 "ProbabilityModule.cs"
                int csharp2cuda_temp_27 = *(csharp2cuda_temp_26);
                (*(csharp2cuda_temp_26) = csharp2cuda_i32_add(csharp2cuda_temp_27, blockDim.x));
            }
        }
#line 497 "ProbabilityModule.cs"
        return;
    }
#line 500 "ProbabilityModule.cs"
    if (((opcode) == (19)))
#line 501 "ProbabilityModule.cs"
    {
#line 502 "ProbabilityModule.cs"
        int csharp2cuda_temp_37 = (first)->count;
#line 502 "ProbabilityModule.cs"
        int csharp2cuda_temp_38;
#line 502 "ProbabilityModule.cs"
        if (((csharp2cuda_temp_37) <= (1)))
        {
#line 502 "ProbabilityModule.cs"
            csharp2cuda_temp_38 = 1;
        }
        else
        {
#line 502 "ProbabilityModule.cs"
            int csharp2cuda_temp_39 = (first)->count;
#line 502 "ProbabilityModule.cs"
            csharp2cuda_temp_38 = csharp2cuda_i32_sub(csharp2cuda_temp_39, 1);
        }
#line 502 "ProbabilityModule.cs"
        int count = csharp2cuda_temp_38;
#line 503 "ProbabilityModule.cs"
        if (((thread) == (0)))
        {
#line 503 "ProbabilityModule.cs"
            mathblocks_set_vector_shape(output, count);
        }
#line 504 "ProbabilityModule.cs"
        __syncthreads();
#line 505 "ProbabilityModule.cs"
#line 505 "ProbabilityModule.cs"
        int csharp2cuda_temp_40 = (first)->count;
        if (((csharp2cuda_temp_40) <= (1)))
#line 506 "ProbabilityModule.cs"
        {
#line 507 "ProbabilityModule.cs"
            if (((thread) == (0)))
            {
#line 507 "ProbabilityModule.cs"
#line 507 "ProbabilityModule.cs"
                double* csharp2cuda_temp_41 = &((result)[0]);
                (*(csharp2cuda_temp_41) = 0.0);
            }
        }
        else
#line 510 "ProbabilityModule.cs"
        {
#line 511 "ProbabilityModule.cs"
            {
#line 511 "ProbabilityModule.cs"
                int index = csharp2cuda_i32_add(thread, 1);
                while (true)
                {
#line 511 "ProbabilityModule.cs"
                    int csharp2cuda_temp_44 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_44))))
                        break;
#line 512 "ProbabilityModule.cs"
                    {
#line 513 "ProbabilityModule.cs"
#line 513 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_45 = &((result)[csharp2cuda_i32_sub(index, 1)]);
#line 513 "ProbabilityModule.cs"
                        double csharp2cuda_temp_46 = (a)[index];
                        (*(csharp2cuda_temp_45) = __dmul_rn(((double)(index)), csharp2cuda_temp_46));
#line 514 "ProbabilityModule.cs"
#line 514 "ProbabilityModule.cs"
                        double csharp2cuda_temp_47 = (result)[csharp2cuda_i32_sub(index, 1)];
                        if ((!(isfinite(csharp2cuda_temp_47))))
                        {
#line 514 "ProbabilityModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 511 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_42 = &(index);
#line 511 "ProbabilityModule.cs"
                    int csharp2cuda_temp_43 = *(csharp2cuda_temp_42);
                    (*(csharp2cuda_temp_42) = csharp2cuda_i32_add(csharp2cuda_temp_43, blockDim.x));
                }
            }
        }
#line 517 "ProbabilityModule.cs"
        return;
    }
#line 520 "ProbabilityModule.cs"
#line 520 "ProbabilityModule.cs"
    bool csharp2cuda_temp_48;
#line 520 "ProbabilityModule.cs"
    if (!(((opcode) == (24))))
    {
#line 520 "ProbabilityModule.cs"
        csharp2cuda_temp_48 = ((opcode) == (27));
    }
    else
    {
#line 520 "ProbabilityModule.cs"
        csharp2cuda_temp_48 = true;
    }
    if (csharp2cuda_temp_48)
#line 521 "ProbabilityModule.cs"
    {
#line 522 "ProbabilityModule.cs"
        if (((thread) == (0)))
#line 523 "ProbabilityModule.cs"
        {
#line 524 "ProbabilityModule.cs"
#line 524 "ProbabilityModule.cs"
            int csharp2cuda_temp_49 = (first)->count;
            if (((csharp2cuda_temp_49) <= (0)))
#line 525 "ProbabilityModule.cs"
            {
#line 526 "ProbabilityModule.cs"
#line 526 "ProbabilityModule.cs"
                int* csharp2cuda_temp_50 = &((output)->valid);
                (*(csharp2cuda_temp_50) = 0);
#line 527 "ProbabilityModule.cs"
                return;
            }
#line 529 "ProbabilityModule.cs"
            {
#line 529 "ProbabilityModule.cs"
                int index = 0;
                while (true)
                {
#line 529 "ProbabilityModule.cs"
                    int csharp2cuda_temp_52 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_52))))
                        break;
#line 530 "ProbabilityModule.cs"
#line 530 "ProbabilityModule.cs"
                    double csharp2cuda_temp_53 = (a)[index];
                    if (((csharp2cuda_temp_53) < (0.0)))
                    {
#line 530 "ProbabilityModule.cs"
#line 530 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_54 = &((output)->valid);
                        (*(csharp2cuda_temp_54) = 0);
                    }
#line 529 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_51 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_51));
                }
            }
#line 531 "ProbabilityModule.cs"
#line 531 "ProbabilityModule.cs"
            int csharp2cuda_temp_55 = (first)->count;
            mathblocks_set_vector_shape(output, csharp2cuda_temp_55);
#line 532 "ProbabilityModule.cs"
            if (((opcode) == (24)))
#line 533 "ProbabilityModule.cs"
            {
#line 534 "ProbabilityModule.cs"
                int csharp2cuda_temp_56 = (first)->count;
#line 534 "ProbabilityModule.cs"
                double total = mathblocks_compensated_sum(a, csharp2cuda_temp_56);
#line 535 "ProbabilityModule.cs"
                {
#line 535 "ProbabilityModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 535 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_58 = (output)->valid;
#line 535 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_59;
#line 535 "ProbabilityModule.cs"
                        if (csharp2cuda_temp_58)
                        {
#line 535 "ProbabilityModule.cs"
                            int csharp2cuda_temp_60 = (first)->count;
#line 535 "ProbabilityModule.cs"
                            csharp2cuda_temp_59 = ((index) < (csharp2cuda_temp_60));
                        }
                        else
                        {
#line 535 "ProbabilityModule.cs"
                            csharp2cuda_temp_59 = false;
                        }
                        if (!(csharp2cuda_temp_59))
                            break;
#line 536 "ProbabilityModule.cs"
#line 536 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_61 = &((result)[index]);
#line 536 "ProbabilityModule.cs"
                        double csharp2cuda_temp_62 = (a)[index];
#line 536 "ProbabilityModule.cs"
                        double csharp2cuda_temp_63 = __ddiv_rn(1.0, total);
                        (*(csharp2cuda_temp_61) = __dmul_rn(csharp2cuda_temp_62, csharp2cuda_temp_63));
#line 535 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_57 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_57));
                    }
                }
            }
            else
#line 539 "ProbabilityModule.cs"
            {
#line 540 "ProbabilityModule.cs"
                double maximum = (a)[0];
#line 541 "ProbabilityModule.cs"
                {
#line 541 "ProbabilityModule.cs"
                    int index = 1;
                    while (true)
                    {
#line 541 "ProbabilityModule.cs"
                        int csharp2cuda_temp_65 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_65))))
                            break;
#line 542 "ProbabilityModule.cs"
#line 542 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_66 = &(maximum);
#line 542 "ProbabilityModule.cs"
                        double csharp2cuda_temp_67 = (a)[index];
                        (*(csharp2cuda_temp_66) = mathblocks_maximum(maximum, csharp2cuda_temp_67));
#line 541 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_64 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_64));
                    }
                }
#line 543 "ProbabilityModule.cs"
                {
#line 543 "ProbabilityModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 543 "ProbabilityModule.cs"
                        int csharp2cuda_temp_69 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_69))))
                            break;
#line 544 "ProbabilityModule.cs"
#line 544 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_70 = &((result)[index]);
#line 544 "ProbabilityModule.cs"
                        double csharp2cuda_temp_71 = (a)[index];
                        (*(csharp2cuda_temp_70) = mathblocks_exponential(__dsub_rn(csharp2cuda_temp_71, maximum)));
#line 543 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_68 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_68));
                    }
                }
#line 545 "ProbabilityModule.cs"
                int csharp2cuda_temp_72 = (first)->count;
#line 545 "ProbabilityModule.cs"
                double total = mathblocks_compensated_sum(result, csharp2cuda_temp_72);
#line 546 "ProbabilityModule.cs"
                double scale = __ddiv_rn(1.0, total);
#line 547 "ProbabilityModule.cs"
                {
#line 547 "ProbabilityModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 547 "ProbabilityModule.cs"
                        int csharp2cuda_temp_74 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_74))))
                            break;
#line 548 "ProbabilityModule.cs"
#line 548 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_75 = &((result)[index]);
#line 548 "ProbabilityModule.cs"
                        double csharp2cuda_temp_76 = *(csharp2cuda_temp_75);
                        (*(csharp2cuda_temp_75) = __dmul_rn(csharp2cuda_temp_76, scale));
#line 547 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_73 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_73));
                    }
                }
            }
#line 550 "ProbabilityModule.cs"
            {
#line 550 "ProbabilityModule.cs"
                int index = 0;
                while (true)
                {
#line 550 "ProbabilityModule.cs"
                    int csharp2cuda_temp_78 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_78))))
                        break;
#line 551 "ProbabilityModule.cs"
#line 551 "ProbabilityModule.cs"
                    double csharp2cuda_temp_79 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_79))))
                    {
#line 551 "ProbabilityModule.cs"
#line 551 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_80 = &((output)->valid);
                        (*(csharp2cuda_temp_80) = 0);
                    }
#line 550 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_77 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_77));
                }
            }
        }
#line 553 "ProbabilityModule.cs"
        return;
    }
#line 556 "ProbabilityModule.cs"
    if (((thread) != (0)))
    {
#line 557 "ProbabilityModule.cs"
        return;
    }
#line 559 "ProbabilityModule.cs"
#line 559 "ProbabilityModule.cs"
    bool csharp2cuda_temp_81;
#line 559 "ProbabilityModule.cs"
    if (!(((opcode) == (0))))
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_81 = ((opcode) == (1));
    }
    else
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_81 = true;
    }
#line 559 "ProbabilityModule.cs"
    bool csharp2cuda_temp_82;
#line 559 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_81))
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_82 = ((opcode) == (2));
    }
    else
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_82 = true;
    }
#line 559 "ProbabilityModule.cs"
    bool csharp2cuda_temp_83;
#line 559 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_82))
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_83 = ((opcode) == (23));
    }
    else
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_83 = true;
    }
#line 559 "ProbabilityModule.cs"
    bool csharp2cuda_temp_84;
#line 559 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_83))
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_84 = ((opcode) == (25));
    }
    else
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_84 = true;
    }
#line 559 "ProbabilityModule.cs"
    bool csharp2cuda_temp_85;
#line 559 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_84))
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_85 = ((opcode) == (26));
    }
    else
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_85 = true;
    }
#line 559 "ProbabilityModule.cs"
    bool csharp2cuda_temp_86;
#line 559 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_85))
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_86 = ((opcode) == (28));
    }
    else
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_86 = true;
    }
#line 559 "ProbabilityModule.cs"
    bool csharp2cuda_temp_87;
#line 559 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_86))
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_87 = ((opcode) == (29));
    }
    else
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_87 = true;
    }
#line 559 "ProbabilityModule.cs"
    bool csharp2cuda_temp_88;
#line 559 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_87))
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_88 = ((opcode) == (30));
    }
    else
    {
#line 559 "ProbabilityModule.cs"
        csharp2cuda_temp_88 = true;
    }
    if (csharp2cuda_temp_88)
#line 561 "ProbabilityModule.cs"
    {
#line 562 "ProbabilityModule.cs"
        double value = 0.0;
#line 563 "ProbabilityModule.cs"
        bool converged = true;
#line 566 "ProbabilityModule.cs"
        double csharp2cuda_temp_89;
#line 566 "ProbabilityModule.cs"
        if (((((void*)(first))) == (((void*)(nullptr)))))
        {
#line 566 "ProbabilityModule.cs"
            csharp2cuda_temp_89 = 0.0;
        }
        else
        {
#line 566 "ProbabilityModule.cs"
            csharp2cuda_temp_89 = (first)->scalar_value;
        }
#line 567 "ProbabilityModule.cs"
        double csharp2cuda_temp_90;
#line 567 "ProbabilityModule.cs"
        if (((((void*)(second))) == (((void*)(nullptr)))))
        {
#line 567 "ProbabilityModule.cs"
            csharp2cuda_temp_90 = 0.0;
        }
        else
        {
#line 567 "ProbabilityModule.cs"
            csharp2cuda_temp_90 = (second)->scalar_value;
        }
#line 568 "ProbabilityModule.cs"
        double csharp2cuda_temp_91;
#line 568 "ProbabilityModule.cs"
        if (((((void*)(third))) == (((void*)(nullptr)))))
        {
#line 568 "ProbabilityModule.cs"
            csharp2cuda_temp_91 = 0.0;
        }
        else
        {
#line 568 "ProbabilityModule.cs"
            csharp2cuda_temp_91 = (third)->scalar_value;
        }
#line 569 "ProbabilityModule.cs"
        double* csharp2cuda_temp_92 = &(value);
#line 570 "ProbabilityModule.cs"
        bool* csharp2cuda_temp_93 = &(converged);
#line 564 "ProbabilityModule.cs"
        bool valid = mathblocks_probability_scalar_value(opcode, csharp2cuda_temp_89, csharp2cuda_temp_90, csharp2cuda_temp_91, csharp2cuda_temp_92, csharp2cuda_temp_93);
#line 571 "ProbabilityModule.cs"
        if ((!(converged)))
        {
#line 571 "ProbabilityModule.cs"
            mathblocks_nonconvergence_record_probability(opcode);
        }
#line 572 "ProbabilityModule.cs"
#line 572 "ProbabilityModule.cs"
        double* csharp2cuda_temp_94 = &((output)->scalar_value);
        (*(csharp2cuda_temp_94) = value);
#line 573 "ProbabilityModule.cs"
        if ((!(valid)))
        {
#line 573 "ProbabilityModule.cs"
#line 573 "ProbabilityModule.cs"
            int* csharp2cuda_temp_95 = &((output)->valid);
            (*(csharp2cuda_temp_95) = 0);
        }
#line 574 "ProbabilityModule.cs"
        return;
    }
#line 577 "ProbabilityModule.cs"
#line 577 "ProbabilityModule.cs"
    bool csharp2cuda_temp_96;
#line 577 "ProbabilityModule.cs"
    if (((opcode) >= (4)))
    {
#line 577 "ProbabilityModule.cs"
        csharp2cuda_temp_96 = ((opcode) <= (16));
    }
    else
    {
#line 577 "ProbabilityModule.cs"
        csharp2cuda_temp_96 = false;
    }
    if (csharp2cuda_temp_96)
#line 578 "ProbabilityModule.cs"
    {
#line 579 "ProbabilityModule.cs"
        bool csharp2cuda_temp_97;
#line 579 "ProbabilityModule.cs"
        if (((opcode) == (12)))
        {
#line 580 "ProbabilityModule.cs"
            int csharp2cuda_temp_98 = (first)->count;
#line 579 "ProbabilityModule.cs"
            csharp2cuda_temp_97 = mathblocks_probability_distribution(a, csharp2cuda_temp_98);
        }
        else
        {
#line 581 "ProbabilityModule.cs"
            int csharp2cuda_temp_99 = (first)->count;
#line 579 "ProbabilityModule.cs"
            csharp2cuda_temp_97 = mathblocks_probability_distribution(a, csharp2cuda_temp_99);
        }
#line 579 "ProbabilityModule.cs"
        bool first_distribution = csharp2cuda_temp_97;
#line 582 "ProbabilityModule.cs"
        bool csharp2cuda_temp_100;
#line 582 "ProbabilityModule.cs"
        if (!(((opcode) == (4))))
        {
#line 582 "ProbabilityModule.cs"
            csharp2cuda_temp_100 = ((opcode) == (7));
        }
        else
        {
#line 582 "ProbabilityModule.cs"
            csharp2cuda_temp_100 = true;
        }
#line 582 "ProbabilityModule.cs"
        bool csharp2cuda_temp_101;
#line 582 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_100))
        {
#line 582 "ProbabilityModule.cs"
            csharp2cuda_temp_101 = ((opcode) == (9));
        }
        else
        {
#line 582 "ProbabilityModule.cs"
            csharp2cuda_temp_101 = true;
        }
#line 582 "ProbabilityModule.cs"
        bool csharp2cuda_temp_102;
#line 582 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_101))
        {
#line 582 "ProbabilityModule.cs"
            csharp2cuda_temp_102 = ((opcode) == (10));
        }
        else
        {
#line 582 "ProbabilityModule.cs"
            csharp2cuda_temp_102 = true;
        }
#line 582 "ProbabilityModule.cs"
        bool csharp2cuda_temp_103;
#line 582 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_102))
        {
#line 582 "ProbabilityModule.cs"
            csharp2cuda_temp_103 = ((opcode) == (11));
        }
        else
        {
#line 582 "ProbabilityModule.cs"
            csharp2cuda_temp_103 = true;
        }
#line 582 "ProbabilityModule.cs"
        bool csharp2cuda_temp_104;
#line 582 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_103))
        {
#line 582 "ProbabilityModule.cs"
            csharp2cuda_temp_104 = ((opcode) == (15));
        }
        else
        {
#line 582 "ProbabilityModule.cs"
            csharp2cuda_temp_104 = true;
        }
#line 582 "ProbabilityModule.cs"
        bool pair = csharp2cuda_temp_104;
#line 584 "ProbabilityModule.cs"
#line 584 "ProbabilityModule.cs"
        bool csharp2cuda_temp_105;
#line 584 "ProbabilityModule.cs"
        if (!((!(first_distribution))))
        {
#line 584 "ProbabilityModule.cs"
            bool csharp2cuda_temp_106;
#line 584 "ProbabilityModule.cs"
            if (pair)
            {
#line 585 "ProbabilityModule.cs"
                int csharp2cuda_temp_107 = (first)->count;
#line 585 "ProbabilityModule.cs"
                int csharp2cuda_temp_108 = (second)->count;
#line 585 "ProbabilityModule.cs"
                bool csharp2cuda_temp_109;
#line 585 "ProbabilityModule.cs"
                if (!(((csharp2cuda_temp_107) != (csharp2cuda_temp_108))))
                {
#line 585 "ProbabilityModule.cs"
                    int csharp2cuda_temp_110 = (second)->count;
#line 585 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_111 = mathblocks_probability_distribution(b, csharp2cuda_temp_110);
#line 585 "ProbabilityModule.cs"
                    csharp2cuda_temp_109 = (!(csharp2cuda_temp_111));
                }
                else
                {
#line 585 "ProbabilityModule.cs"
                    csharp2cuda_temp_109 = true;
                }
#line 584 "ProbabilityModule.cs"
                csharp2cuda_temp_106 = csharp2cuda_temp_109;
            }
            else
            {
#line 584 "ProbabilityModule.cs"
                csharp2cuda_temp_106 = false;
            }
#line 584 "ProbabilityModule.cs"
            csharp2cuda_temp_105 = csharp2cuda_temp_106;
        }
        else
        {
#line 584 "ProbabilityModule.cs"
            csharp2cuda_temp_105 = true;
        }
        if (csharp2cuda_temp_105)
#line 586 "ProbabilityModule.cs"
        {
#line 587 "ProbabilityModule.cs"
#line 587 "ProbabilityModule.cs"
            int* csharp2cuda_temp_112 = &((output)->valid);
            (*(csharp2cuda_temp_112) = 0);
#line 588 "ProbabilityModule.cs"
            return;
        }
#line 590 "ProbabilityModule.cs"
        double value = 0.0;
#line 591 "ProbabilityModule.cs"
        if (((opcode) == (4)))
#line 592 "ProbabilityModule.cs"
        {
#line 593 "ProbabilityModule.cs"
            {
#line 593 "ProbabilityModule.cs"
                int index = 0;
                while (true)
                {
#line 593 "ProbabilityModule.cs"
                    int csharp2cuda_temp_114 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_114))))
                        break;
#line 594 "ProbabilityModule.cs"
#line 594 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_115 = &(value);
#line 594 "ProbabilityModule.cs"
                    double csharp2cuda_temp_116 = *(csharp2cuda_temp_115);
#line 594 "ProbabilityModule.cs"
                    double csharp2cuda_temp_117 = (a)[index];
#line 594 "ProbabilityModule.cs"
                    double csharp2cuda_temp_118 = (b)[index];
                    (*(csharp2cuda_temp_115) = __dadd_rn(csharp2cuda_temp_116, mathblocks_square_root(__dmul_rn(csharp2cuda_temp_117, csharp2cuda_temp_118))));
#line 593 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_113 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_113));
                }
            }
        }
        else
        {
#line 596 "ProbabilityModule.cs"
            if (((opcode) == (5)))
#line 597 "ProbabilityModule.cs"
            {
#line 598 "ProbabilityModule.cs"
#line 598 "ProbabilityModule.cs"
                double* csharp2cuda_temp_119 = &(value);
#line 598 "ProbabilityModule.cs"
                int csharp2cuda_temp_120 = (first)->count;
#line 598 "ProbabilityModule.cs"
                double csharp2cuda_temp_121 = mathblocks_probability_entropy(a, csharp2cuda_temp_120);
#line 598 "ProbabilityModule.cs"
                double csharp2cuda_temp_122 = __ddiv_rn(csharp2cuda_temp_121, mathblocks_natural_logarithm(2.0));
                (*(csharp2cuda_temp_119) = csharp2cuda_temp_122);
            }
            else
            {
#line 601 "ProbabilityModule.cs"
                if (((opcode) == (6)))
#line 602 "ProbabilityModule.cs"
                {
#line 603 "ProbabilityModule.cs"
                    int first_count = 0;
#line 604 "ProbabilityModule.cs"
                    int second_count = 0;
#line 605 "ProbabilityModule.cs"
                    int condition_count = 0;
#line 606 "ProbabilityModule.cs"
#line 606 "ProbabilityModule.cs"
                    double csharp2cuda_temp_123 = (second)->scalar_value;
#line 606 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_124 = &(first_count);
#line 606 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_125 = mathblocks_probability_integer(csharp2cuda_temp_123, csharp2cuda_temp_124);
#line 606 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_126;
#line 606 "ProbabilityModule.cs"
                    if (!((!(csharp2cuda_temp_125))))
                    {
#line 606 "ProbabilityModule.cs"
                        csharp2cuda_temp_126 = ((first_count) <= (0));
                    }
                    else
                    {
#line 606 "ProbabilityModule.cs"
                        csharp2cuda_temp_126 = true;
                    }
#line 606 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_127;
#line 606 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_126))
                    {
#line 607 "ProbabilityModule.cs"
                        double csharp2cuda_temp_128 = (third)->scalar_value;
#line 607 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_129 = &(second_count);
#line 607 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_130 = mathblocks_probability_integer(csharp2cuda_temp_128, csharp2cuda_temp_129);
#line 606 "ProbabilityModule.cs"
                        csharp2cuda_temp_127 = (!(csharp2cuda_temp_130));
                    }
                    else
                    {
#line 606 "ProbabilityModule.cs"
                        csharp2cuda_temp_127 = true;
                    }
#line 606 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_131;
#line 606 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_127))
                    {
#line 606 "ProbabilityModule.cs"
                        csharp2cuda_temp_131 = ((second_count) <= (0));
                    }
                    else
                    {
#line 606 "ProbabilityModule.cs"
                        csharp2cuda_temp_131 = true;
                    }
#line 606 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_132;
#line 606 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_131))
                    {
#line 608 "ProbabilityModule.cs"
                        double csharp2cuda_temp_133 = (fourth)->scalar_value;
#line 608 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_134 = &(condition_count);
#line 608 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_135 = mathblocks_probability_integer(csharp2cuda_temp_133, csharp2cuda_temp_134);
#line 606 "ProbabilityModule.cs"
                        csharp2cuda_temp_132 = (!(csharp2cuda_temp_135));
                    }
                    else
                    {
#line 606 "ProbabilityModule.cs"
                        csharp2cuda_temp_132 = true;
                    }
#line 606 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_136;
#line 606 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_132))
                    {
#line 606 "ProbabilityModule.cs"
                        csharp2cuda_temp_136 = ((condition_count) <= (0));
                    }
                    else
                    {
#line 606 "ProbabilityModule.cs"
                        csharp2cuda_temp_136 = true;
                    }
#line 606 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_137;
#line 606 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_136))
                    {
#line 609 "ProbabilityModule.cs"
                        int csharp2cuda_temp_138 = (first)->count;
#line 606 "ProbabilityModule.cs"
                        csharp2cuda_temp_137 = ((csharp2cuda_i64_mul(csharp2cuda_i64_mul(((long long)(first_count)), ((long long)(second_count))), ((long long)(condition_count)))) != (((long long)(csharp2cuda_temp_138))));
                    }
                    else
                    {
#line 606 "ProbabilityModule.cs"
                        csharp2cuda_temp_137 = true;
                    }
#line 606 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_139;
#line 606 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_137))
                    {
#line 606 "ProbabilityModule.cs"
                        csharp2cuda_temp_139 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 606 "ProbabilityModule.cs"
                        csharp2cuda_temp_139 = true;
                    }
                    if (csharp2cuda_temp_139)
#line 610 "ProbabilityModule.cs"
                    {
#line 611 "ProbabilityModule.cs"
#line 611 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_140 = &((output)->valid);
                        (*(csharp2cuda_temp_140) = 0);
#line 612 "ProbabilityModule.cs"
                        return;
                    }
#line 614 "ProbabilityModule.cs"
                    int first_condition_count = csharp2cuda_i32_mul(first_count, condition_count);
#line 615 "ProbabilityModule.cs"
                    int second_condition_count = csharp2cuda_i32_mul(second_count, condition_count);
#line 616 "ProbabilityModule.cs"
                    double* first_condition = scratch;
#line 617 "ProbabilityModule.cs"
                    double* second_condition = csharp2cuda_pointer_add(first_condition, first_condition_count);
#line 618 "ProbabilityModule.cs"
                    double* condition = csharp2cuda_pointer_add(second_condition, second_condition_count);
#line 619 "ProbabilityModule.cs"
                    {
#line 619 "ProbabilityModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_add(csharp2cuda_i32_add(first_condition_count, second_condition_count), condition_count)))))
                                break;
#line 620 "ProbabilityModule.cs"
#line 620 "ProbabilityModule.cs"
                            double* csharp2cuda_temp_142 = &((scratch)[index]);
                            (*(csharp2cuda_temp_142) = 0.0);
#line 619 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_141 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_141));
                        }
                    }
#line 621 "ProbabilityModule.cs"
                    {
#line 621 "ProbabilityModule.cs"
                        int first_index = 0;
                        while (true)
                        {
                            if (!(((first_index) < (first_count))))
                                break;
#line 622 "ProbabilityModule.cs"
                            {
#line 622 "ProbabilityModule.cs"
                                int second_index = 0;
                                while (true)
                                {
                                    if (!(((second_index) < (second_count))))
                                        break;
#line 623 "ProbabilityModule.cs"
                                    {
#line 623 "ProbabilityModule.cs"
                                        int state = 0;
                                        while (true)
                                        {
                                            if (!(((state) < (condition_count))))
                                                break;
#line 624 "ProbabilityModule.cs"
                                            {
#line 625 "ProbabilityModule.cs"
                                                double probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, second_count), second_index), condition_count), state)];
#line 627 "ProbabilityModule.cs"
#line 627 "ProbabilityModule.cs"
                                                double* csharp2cuda_temp_146 = &((first_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, condition_count), state)]);
#line 627 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_147 = *(csharp2cuda_temp_146);
                                                (*(csharp2cuda_temp_146) = __dadd_rn(csharp2cuda_temp_147, probability));
#line 628 "ProbabilityModule.cs"
#line 628 "ProbabilityModule.cs"
                                                double* csharp2cuda_temp_148 = &((second_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(second_index, condition_count), state)]);
#line 628 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_149 = *(csharp2cuda_temp_148);
                                                (*(csharp2cuda_temp_148) = __dadd_rn(csharp2cuda_temp_149, probability));
#line 629 "ProbabilityModule.cs"
#line 629 "ProbabilityModule.cs"
                                                double* csharp2cuda_temp_150 = &((condition)[state]);
#line 629 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_151 = *(csharp2cuda_temp_150);
                                                (*(csharp2cuda_temp_150) = __dadd_rn(csharp2cuda_temp_151, probability));
                                            }
#line 623 "ProbabilityModule.cs"
                                            int* csharp2cuda_temp_145 = &(state);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_145));
                                        }
                                    }
#line 622 "ProbabilityModule.cs"
                                    int* csharp2cuda_temp_144 = &(second_index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_144));
                                }
                            }
#line 621 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_143 = &(first_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_143));
                        }
                    }
#line 631 "ProbabilityModule.cs"
                    {
#line 631 "ProbabilityModule.cs"
                        int first_index = 0;
                        while (true)
                        {
                            if (!(((first_index) < (first_count))))
                                break;
#line 632 "ProbabilityModule.cs"
                            {
#line 632 "ProbabilityModule.cs"
                                int second_index = 0;
                                while (true)
                                {
                                    if (!(((second_index) < (second_count))))
                                        break;
#line 633 "ProbabilityModule.cs"
                                    {
#line 633 "ProbabilityModule.cs"
                                        int state = 0;
                                        while (true)
                                        {
                                            if (!(((state) < (condition_count))))
                                                break;
#line 634 "ProbabilityModule.cs"
                                            {
#line 635 "ProbabilityModule.cs"
                                                double probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, second_count), second_index), condition_count), state)];
#line 637 "ProbabilityModule.cs"
                                                if (((probability) == (0.0)))
                                                {
#line 637 "ProbabilityModule.cs"
                                                    goto csharp2cuda_for_continue_15;
                                                }
#line 638 "ProbabilityModule.cs"
#line 638 "ProbabilityModule.cs"
                                                double* csharp2cuda_temp_155 = &(value);
#line 638 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_156 = *(csharp2cuda_temp_155);
#line 639 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_157 = (condition)[state];
#line 640 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_158 = (first_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, condition_count), state)];
#line 641 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_159 = (second_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(second_index, condition_count), state)];
#line 639 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_160 = __ddiv_rn(__dmul_rn(probability, csharp2cuda_temp_157), __dmul_rn(csharp2cuda_temp_158, csharp2cuda_temp_159));
                                                (*(csharp2cuda_temp_155) = __dadd_rn(csharp2cuda_temp_156, __dmul_rn(probability, mathblocks_natural_logarithm(csharp2cuda_temp_160))));
                                            }
                                            csharp2cuda_for_continue_15:
#line 633 "ProbabilityModule.cs"
                                            int* csharp2cuda_temp_154 = &(state);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_154));
                                        }
                                    }
#line 632 "ProbabilityModule.cs"
                                    int* csharp2cuda_temp_153 = &(second_index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_153));
                                }
                            }
#line 631 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_152 = &(first_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_152));
                        }
                    }
                }
                else
                {
#line 644 "ProbabilityModule.cs"
                    if (((opcode) == (7)))
#line 645 "ProbabilityModule.cs"
                    {
#line 646 "ProbabilityModule.cs"
                        {
#line 646 "ProbabilityModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 646 "ProbabilityModule.cs"
                                int csharp2cuda_temp_162 = (first)->count;
                                if (!(((index) < (csharp2cuda_temp_162))))
                                    break;
#line 647 "ProbabilityModule.cs"
                                {
#line 648 "ProbabilityModule.cs"
#line 648 "ProbabilityModule.cs"
                                    double csharp2cuda_temp_163 = (a)[index];
#line 648 "ProbabilityModule.cs"
                                    bool csharp2cuda_temp_164;
#line 648 "ProbabilityModule.cs"
                                    if (((csharp2cuda_temp_163) > (0.0)))
                                    {
#line 648 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_165 = (b)[index];
#line 648 "ProbabilityModule.cs"
                                        csharp2cuda_temp_164 = ((csharp2cuda_temp_165) == (0.0));
                                    }
                                    else
                                    {
#line 648 "ProbabilityModule.cs"
                                        csharp2cuda_temp_164 = false;
                                    }
                                    if (csharp2cuda_temp_164)
#line 649 "ProbabilityModule.cs"
                                    {
#line 650 "ProbabilityModule.cs"
#line 650 "ProbabilityModule.cs"
                                        int* csharp2cuda_temp_166 = &((output)->valid);
                                        (*(csharp2cuda_temp_166) = 0);
#line 651 "ProbabilityModule.cs"
                                        return;
                                    }
#line 653 "ProbabilityModule.cs"
#line 653 "ProbabilityModule.cs"
                                    double csharp2cuda_temp_167 = (a)[index];
                                    if (((csharp2cuda_temp_167) > (0.0)))
                                    {
#line 654 "ProbabilityModule.cs"
#line 654 "ProbabilityModule.cs"
                                        double* csharp2cuda_temp_168 = &(value);
#line 654 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_169 = *(csharp2cuda_temp_168);
#line 654 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_170 = (a)[index];
#line 654 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_171 = (b)[index];
                                        (*(csharp2cuda_temp_168) = __dsub_rn(csharp2cuda_temp_169, __dmul_rn(csharp2cuda_temp_170, mathblocks_natural_logarithm(csharp2cuda_temp_171))));
                                    }
                                }
#line 646 "ProbabilityModule.cs"
                                int* csharp2cuda_temp_161 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_161));
                            }
                        }
                    }
                    else
                    {
#line 657 "ProbabilityModule.cs"
                        if (((opcode) == (8)))
#line 658 "ProbabilityModule.cs"
                        {
#line 659 "ProbabilityModule.cs"
#line 659 "ProbabilityModule.cs"
                            double* csharp2cuda_temp_172 = &(value);
#line 659 "ProbabilityModule.cs"
                            int csharp2cuda_temp_173 = (first)->count;
                            (*(csharp2cuda_temp_172) = __dsub_rn(1.0, mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_173)));
                        }
                        else
                        {
#line 661 "ProbabilityModule.cs"
                            if (((opcode) == (9)))
#line 662 "ProbabilityModule.cs"
                            {
#line 663 "ProbabilityModule.cs"
                                {
#line 663 "ProbabilityModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 663 "ProbabilityModule.cs"
                                        int csharp2cuda_temp_175 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_175))))
                                            break;
#line 664 "ProbabilityModule.cs"
                                        {
#line 665 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_176 = (a)[index];
#line 665 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_177 = (b)[index];
#line 665 "ProbabilityModule.cs"
                                            double difference = __dsub_rn(mathblocks_square_root(csharp2cuda_temp_176), mathblocks_square_root(csharp2cuda_temp_177));
#line 666 "ProbabilityModule.cs"
#line 666 "ProbabilityModule.cs"
                                            double* csharp2cuda_temp_178 = &(value);
#line 666 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_179 = *(csharp2cuda_temp_178);
                                            (*(csharp2cuda_temp_178) = __dadd_rn(csharp2cuda_temp_179, __dmul_rn(difference, difference)));
                                        }
#line 663 "ProbabilityModule.cs"
                                        int* csharp2cuda_temp_174 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_174));
                                    }
                                }
#line 668 "ProbabilityModule.cs"
#line 668 "ProbabilityModule.cs"
                                double* csharp2cuda_temp_180 = &(value);
#line 668 "ProbabilityModule.cs"
                                double csharp2cuda_temp_181 = __ddiv_rn(value, 2.0);
                                (*(csharp2cuda_temp_180) = mathblocks_square_root(csharp2cuda_temp_181));
                            }
                            else
                            {
#line 670 "ProbabilityModule.cs"
                                if (((opcode) == (10)))
#line 671 "ProbabilityModule.cs"
                                {
#line 672 "ProbabilityModule.cs"
                                    if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 673 "ProbabilityModule.cs"
                                    {
#line 674 "ProbabilityModule.cs"
#line 674 "ProbabilityModule.cs"
                                        int* csharp2cuda_temp_182 = &((output)->valid);
                                        (*(csharp2cuda_temp_182) = 0);
#line 675 "ProbabilityModule.cs"
                                        return;
                                    }
#line 677 "ProbabilityModule.cs"
                                    {
#line 677 "ProbabilityModule.cs"
                                        int index = 0;
                                        while (true)
                                        {
#line 677 "ProbabilityModule.cs"
                                            int csharp2cuda_temp_184 = (first)->count;
                                            if (!(((index) < (csharp2cuda_temp_184))))
                                                break;
#line 678 "ProbabilityModule.cs"
#line 678 "ProbabilityModule.cs"
                                            double* csharp2cuda_temp_185 = &((scratch)[index]);
#line 678 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_186 = (a)[index];
#line 678 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_187 = (b)[index];
#line 678 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_188 = __ddiv_rn(__dadd_rn(csharp2cuda_temp_186, csharp2cuda_temp_187), 2.0);
                                            (*(csharp2cuda_temp_185) = csharp2cuda_temp_188);
#line 677 "ProbabilityModule.cs"
                                            int* csharp2cuda_temp_183 = &(index);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_183));
                                        }
                                    }
#line 679 "ProbabilityModule.cs"
#line 679 "ProbabilityModule.cs"
                                    double* csharp2cuda_temp_189 = &(value);
#line 679 "ProbabilityModule.cs"
                                    int csharp2cuda_temp_190 = (first)->count;
#line 679 "ProbabilityModule.cs"
                                    double csharp2cuda_temp_191 = mathblocks_probability_kl(a, scratch, csharp2cuda_temp_190);
#line 680 "ProbabilityModule.cs"
                                    int csharp2cuda_temp_192 = (first)->count;
#line 680 "ProbabilityModule.cs"
                                    double csharp2cuda_temp_193 = mathblocks_probability_kl(b, scratch, csharp2cuda_temp_192);
                                    (*(csharp2cuda_temp_189) = __dmul_rn(0.5, __dadd_rn(csharp2cuda_temp_191, csharp2cuda_temp_193)));
                                }
                                else
                                {
#line 682 "ProbabilityModule.cs"
                                    if (((opcode) == (11)))
#line 683 "ProbabilityModule.cs"
                                    {
#line 684 "ProbabilityModule.cs"
                                        {
#line 684 "ProbabilityModule.cs"
                                            int index = 0;
                                            while (true)
                                            {
#line 684 "ProbabilityModule.cs"
                                                int csharp2cuda_temp_195 = (first)->count;
                                                if (!(((index) < (csharp2cuda_temp_195))))
                                                    break;
#line 685 "ProbabilityModule.cs"
#line 685 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_196 = (a)[index];
#line 685 "ProbabilityModule.cs"
                                                bool csharp2cuda_temp_197;
#line 685 "ProbabilityModule.cs"
                                                if (((csharp2cuda_temp_196) > (0.0)))
                                                {
#line 685 "ProbabilityModule.cs"
                                                    double csharp2cuda_temp_198 = (b)[index];
#line 685 "ProbabilityModule.cs"
                                                    csharp2cuda_temp_197 = ((csharp2cuda_temp_198) == (0.0));
                                                }
                                                else
                                                {
#line 685 "ProbabilityModule.cs"
                                                    csharp2cuda_temp_197 = false;
                                                }
                                                if (csharp2cuda_temp_197)
#line 686 "ProbabilityModule.cs"
                                                {
#line 687 "ProbabilityModule.cs"
#line 687 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_199 = &((output)->valid);
                                                    (*(csharp2cuda_temp_199) = 0);
#line 688 "ProbabilityModule.cs"
                                                    return;
                                                }
#line 684 "ProbabilityModule.cs"
                                                int* csharp2cuda_temp_194 = &(index);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_194));
                                            }
                                        }
#line 690 "ProbabilityModule.cs"
#line 690 "ProbabilityModule.cs"
                                        double* csharp2cuda_temp_200 = &(value);
#line 690 "ProbabilityModule.cs"
                                        int csharp2cuda_temp_201 = (first)->count;
#line 690 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_202 = mathblocks_probability_kl(a, b, csharp2cuda_temp_201);
                                        (*(csharp2cuda_temp_200) = csharp2cuda_temp_202);
                                    }
                                    else
                                    {
#line 692 "ProbabilityModule.cs"
                                        if (((opcode) == (12)))
#line 693 "ProbabilityModule.cs"
                                        {
#line 694 "ProbabilityModule.cs"
                                            int rows = (first)->rows;
#line 695 "ProbabilityModule.cs"
                                            int columns = (first)->columns;
#line 696 "ProbabilityModule.cs"
                                            if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 697 "ProbabilityModule.cs"
                                            {
#line 698 "ProbabilityModule.cs"
#line 698 "ProbabilityModule.cs"
                                                int* csharp2cuda_temp_203 = &((output)->valid);
                                                (*(csharp2cuda_temp_203) = 0);
#line 699 "ProbabilityModule.cs"
                                                return;
                                            }
#line 701 "ProbabilityModule.cs"
                                            double* row_totals = scratch;
#line 702 "ProbabilityModule.cs"
                                            double* column_totals = csharp2cuda_pointer_add(scratch, rows);
#line 703 "ProbabilityModule.cs"
                                            {
#line 703 "ProbabilityModule.cs"
                                                int index = 0;
                                                while (true)
                                                {
                                                    if (!(((index) < (csharp2cuda_i32_add(rows, columns)))))
                                                        break;
#line 703 "ProbabilityModule.cs"
#line 703 "ProbabilityModule.cs"
                                                    double* csharp2cuda_temp_205 = &((scratch)[index]);
                                                    (*(csharp2cuda_temp_205) = 0.0);
#line 703 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_204 = &(index);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_204));
                                                }
                                            }
#line 704 "ProbabilityModule.cs"
                                            {
#line 704 "ProbabilityModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
                                                    if (!(((row) < (rows))))
                                                        break;
#line 705 "ProbabilityModule.cs"
                                                    {
#line 705 "ProbabilityModule.cs"
                                                        int column = 0;
                                                        while (true)
                                                        {
                                                            if (!(((column) < (columns))))
                                                                break;
#line 706 "ProbabilityModule.cs"
                                                            {
#line 707 "ProbabilityModule.cs"
                                                                double probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 708 "ProbabilityModule.cs"
#line 708 "ProbabilityModule.cs"
                                                                double* csharp2cuda_temp_208 = &((row_totals)[row]);
#line 708 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_209 = *(csharp2cuda_temp_208);
                                                                (*(csharp2cuda_temp_208) = __dadd_rn(csharp2cuda_temp_209, probability));
#line 709 "ProbabilityModule.cs"
#line 709 "ProbabilityModule.cs"
                                                                double* csharp2cuda_temp_210 = &((column_totals)[column]);
#line 709 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_211 = *(csharp2cuda_temp_210);
                                                                (*(csharp2cuda_temp_210) = __dadd_rn(csharp2cuda_temp_211, probability));
                                                            }
#line 705 "ProbabilityModule.cs"
                                                            int* csharp2cuda_temp_207 = &(column);
                                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_207));
                                                        }
                                                    }
#line 704 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_206 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_206));
                                                }
                                            }
#line 711 "ProbabilityModule.cs"
                                            {
#line 711 "ProbabilityModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
                                                    if (!(((row) < (rows))))
                                                        break;
#line 712 "ProbabilityModule.cs"
                                                    {
#line 712 "ProbabilityModule.cs"
                                                        int column = 0;
                                                        while (true)
                                                        {
                                                            if (!(((column) < (columns))))
                                                                break;
#line 713 "ProbabilityModule.cs"
                                                            {
#line 714 "ProbabilityModule.cs"
                                                                double probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 715 "ProbabilityModule.cs"
                                                                if (((probability) > (0.0)))
                                                                {
#line 716 "ProbabilityModule.cs"
#line 716 "ProbabilityModule.cs"
                                                                    double* csharp2cuda_temp_214 = &(value);
#line 716 "ProbabilityModule.cs"
                                                                    double csharp2cuda_temp_215 = *(csharp2cuda_temp_214);
#line 717 "ProbabilityModule.cs"
                                                                    double csharp2cuda_temp_216 = (row_totals)[row];
#line 717 "ProbabilityModule.cs"
                                                                    double csharp2cuda_temp_217 = (column_totals)[column];
#line 717 "ProbabilityModule.cs"
                                                                    double csharp2cuda_temp_218 = __ddiv_rn(probability, __dmul_rn(csharp2cuda_temp_216, csharp2cuda_temp_217));
                                                                    (*(csharp2cuda_temp_214) = __dadd_rn(csharp2cuda_temp_215, __dmul_rn(probability, mathblocks_natural_logarithm(csharp2cuda_temp_218))));
                                                                }
                                                            }
#line 712 "ProbabilityModule.cs"
                                                            int* csharp2cuda_temp_213 = &(column);
                                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_213));
                                                        }
                                                    }
#line 711 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_212 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_212));
                                                }
                                            }
                                        }
                                        else
                                        {
#line 720 "ProbabilityModule.cs"
#line 720 "ProbabilityModule.cs"
                                            bool csharp2cuda_temp_219;
#line 720 "ProbabilityModule.cs"
                                            if (!(((opcode) == (13))))
                                            {
#line 720 "ProbabilityModule.cs"
                                                csharp2cuda_temp_219 = ((opcode) == (16));
                                            }
                                            else
                                            {
#line 720 "ProbabilityModule.cs"
                                                csharp2cuda_temp_219 = true;
                                            }
                                            if (csharp2cuda_temp_219)
#line 721 "ProbabilityModule.cs"
                                            {
#line 722 "ProbabilityModule.cs"
#line 724 "ProbabilityModule.cs"
                                                int csharp2cuda_temp_220 = (first)->count;
#line 725 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_221 = (second)->scalar_value;
#line 727 "ProbabilityModule.cs"
                                                double* csharp2cuda_temp_222 = &(value);
#line 722 "ProbabilityModule.cs"
                                                bool csharp2cuda_temp_223 = mathblocks_probability_ordered_entropy_value(a, csharp2cuda_temp_220, csharp2cuda_temp_221, ((opcode) == (13)), csharp2cuda_temp_222);
                                                if ((!(csharp2cuda_temp_223)))
#line 728 "ProbabilityModule.cs"
                                                {
#line 729 "ProbabilityModule.cs"
#line 729 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_224 = &((output)->valid);
                                                    (*(csharp2cuda_temp_224) = 0);
#line 730 "ProbabilityModule.cs"
                                                    return;
                                                }
                                            }
                                            else
                                            {
#line 733 "ProbabilityModule.cs"
                                                if (((opcode) == (14)))
#line 734 "ProbabilityModule.cs"
                                                {
#line 735 "ProbabilityModule.cs"
#line 735 "ProbabilityModule.cs"
                                                    double* csharp2cuda_temp_225 = &(value);
#line 735 "ProbabilityModule.cs"
                                                    int csharp2cuda_temp_226 = (first)->count;
#line 735 "ProbabilityModule.cs"
                                                    double csharp2cuda_temp_227 = mathblocks_probability_entropy(a, csharp2cuda_temp_226);
                                                    (*(csharp2cuda_temp_225) = csharp2cuda_temp_227);
                                                }
                                                else
                                                {
#line 737 "ProbabilityModule.cs"
                                                    if (((opcode) == (15)))
#line 738 "ProbabilityModule.cs"
                                                    {
#line 739 "ProbabilityModule.cs"
                                                        {
#line 739 "ProbabilityModule.cs"
                                                            int index = 0;
                                                            while (true)
                                                            {
#line 739 "ProbabilityModule.cs"
                                                                int csharp2cuda_temp_229 = (first)->count;
                                                                if (!(((index) < (csharp2cuda_temp_229))))
                                                                    break;
#line 740 "ProbabilityModule.cs"
#line 740 "ProbabilityModule.cs"
                                                                double* csharp2cuda_temp_230 = &(value);
#line 740 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_231 = *(csharp2cuda_temp_230);
#line 740 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_232 = (a)[index];
#line 740 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_233 = (b)[index];
                                                                (*(csharp2cuda_temp_230) = __dadd_rn(csharp2cuda_temp_231, fabs(__dsub_rn(csharp2cuda_temp_232, csharp2cuda_temp_233))));
#line 739 "ProbabilityModule.cs"
                                                                int* csharp2cuda_temp_228 = &(index);
                                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_228));
                                                            }
                                                        }
#line 741 "ProbabilityModule.cs"
#line 741 "ProbabilityModule.cs"
                                                        double* csharp2cuda_temp_234 = &(value);
#line 741 "ProbabilityModule.cs"
                                                        double csharp2cuda_temp_235 = *(csharp2cuda_temp_234);
                                                        (*(csharp2cuda_temp_234) = __ddiv_rn(csharp2cuda_temp_235, 2.0));
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
#line 743 "ProbabilityModule.cs"
#line 743 "ProbabilityModule.cs"
        double* csharp2cuda_temp_236 = &((output)->scalar_value);
        (*(csharp2cuda_temp_236) = value);
#line 744 "ProbabilityModule.cs"
        if ((!(isfinite(value))))
        {
#line 744 "ProbabilityModule.cs"
#line 744 "ProbabilityModule.cs"
            int* csharp2cuda_temp_237 = &((output)->valid);
            (*(csharp2cuda_temp_237) = 0);
        }
#line 745 "ProbabilityModule.cs"
        return;
    }
#line 748 "ProbabilityModule.cs"
    if (((opcode) == (17)))
#line 749 "ProbabilityModule.cs"
    {
#line 750 "ProbabilityModule.cs"
        double parameter = (second)->scalar_value;
#line 751 "ProbabilityModule.cs"
#line 751 "ProbabilityModule.cs"
        int csharp2cuda_temp_238 = (first)->count;
#line 751 "ProbabilityModule.cs"
        bool csharp2cuda_temp_239;
#line 751 "ProbabilityModule.cs"
        if (!(((csharp2cuda_temp_238) <= (0))))
        {
#line 751 "ProbabilityModule.cs"
            csharp2cuda_temp_239 = ((parameter) < (0.0));
        }
        else
        {
#line 751 "ProbabilityModule.cs"
            csharp2cuda_temp_239 = true;
        }
#line 751 "ProbabilityModule.cs"
        bool csharp2cuda_temp_240;
#line 751 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_239))
        {
#line 751 "ProbabilityModule.cs"
            csharp2cuda_temp_240 = ((parameter) > (1.0));
        }
        else
        {
#line 751 "ProbabilityModule.cs"
            csharp2cuda_temp_240 = true;
        }
        if (csharp2cuda_temp_240)
#line 752 "ProbabilityModule.cs"
        {
#line 753 "ProbabilityModule.cs"
#line 753 "ProbabilityModule.cs"
            int* csharp2cuda_temp_241 = &((output)->valid);
            (*(csharp2cuda_temp_241) = 0);
#line 754 "ProbabilityModule.cs"
            return;
        }
#line 756 "ProbabilityModule.cs"
        int csharp2cuda_temp_242 = (first)->count;
#line 756 "ProbabilityModule.cs"
        int degree = csharp2cuda_i32_sub(csharp2cuda_temp_242, 1);
#line 757 "ProbabilityModule.cs"
        double value = 0.0;
#line 758 "ProbabilityModule.cs"
        {
#line 758 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) <= (degree))))
                    break;
#line 759 "ProbabilityModule.cs"
#line 759 "ProbabilityModule.cs"
                double* csharp2cuda_temp_244 = &(value);
#line 759 "ProbabilityModule.cs"
                double csharp2cuda_temp_245 = *(csharp2cuda_temp_244);
#line 759 "ProbabilityModule.cs"
                double csharp2cuda_temp_246 = (a)[index];
                (*(csharp2cuda_temp_244) = __dadd_rn(csharp2cuda_temp_245, __dmul_rn(__dmul_rn(__dmul_rn(csharp2cuda_temp_246, mathblocks_probability_binomial(degree, index)), mathblocks_power(parameter, ((double)(index)))), mathblocks_power(__dsub_rn(1.0, parameter), ((double)(csharp2cuda_i32_sub(degree, index)))))));
#line 758 "ProbabilityModule.cs"
                int* csharp2cuda_temp_243 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_243));
            }
        }
#line 762 "ProbabilityModule.cs"
#line 762 "ProbabilityModule.cs"
        double* csharp2cuda_temp_247 = &((output)->scalar_value);
        (*(csharp2cuda_temp_247) = value);
#line 763 "ProbabilityModule.cs"
        if ((!(isfinite(value))))
        {
#line 763 "ProbabilityModule.cs"
#line 763 "ProbabilityModule.cs"
            int* csharp2cuda_temp_248 = &((output)->valid);
            (*(csharp2cuda_temp_248) = 0);
        }
#line 764 "ProbabilityModule.cs"
        return;
    }
#line 767 "ProbabilityModule.cs"
    if (((opcode) == (18)))
#line 768 "ProbabilityModule.cs"
    {
#line 769 "ProbabilityModule.cs"
#line 769 "ProbabilityModule.cs"
        int csharp2cuda_temp_249 = (first)->count;
        if (((csharp2cuda_temp_249) != (4)))
#line 770 "ProbabilityModule.cs"
        {
#line 771 "ProbabilityModule.cs"
#line 771 "ProbabilityModule.cs"
            int* csharp2cuda_temp_250 = &((output)->valid);
            (*(csharp2cuda_temp_250) = 0);
#line 772 "ProbabilityModule.cs"
            return;
        }
#line 774 "ProbabilityModule.cs"
        unsigned long long csharp2cuda_temp_251 = (output)->data_pointer;
#line 774 "ProbabilityModule.cs"
        MathBlockComplexValue* roots = ((MathBlockComplexValue*)(csharp2cuda_temp_251));
#line 775 "ProbabilityModule.cs"
        mathblocks_complex_shape(output, 3);
#line 776 "ProbabilityModule.cs"
        double constant = (a)[0];
#line 777 "ProbabilityModule.cs"
        double linear = (a)[1];
#line 778 "ProbabilityModule.cs"
        double quadratic = (a)[2];
#line 779 "ProbabilityModule.cs"
        double leading = (a)[3];
#line 780 "ProbabilityModule.cs"
        if (((leading) == (0.0)))
#line 781 "ProbabilityModule.cs"
        {
#line 782 "ProbabilityModule.cs"
#line 782 "ProbabilityModule.cs"
            int* csharp2cuda_temp_252 = &((output)->valid);
            (*(csharp2cuda_temp_252) = 0);
#line 783 "ProbabilityModule.cs"
            return;
        }
#line 785 "ProbabilityModule.cs"
        double normalized_a = __ddiv_rn(quadratic, leading);
#line 786 "ProbabilityModule.cs"
        double normalized_b = __ddiv_rn(linear, leading);
#line 787 "ProbabilityModule.cs"
        double normalized_c = __ddiv_rn(constant, leading);
#line 788 "ProbabilityModule.cs"
        double csharp2cuda_temp_253 = __ddiv_rn(__dmul_rn(normalized_a, normalized_a), 3.0);
#line 788 "ProbabilityModule.cs"
        double p = __dsub_rn(normalized_b, csharp2cuda_temp_253);
#line 789 "ProbabilityModule.cs"
        double csharp2cuda_temp_254 = __ddiv_rn(__dmul_rn(__dmul_rn(__dmul_rn(2.0, normalized_a), normalized_a), normalized_a), 27.0);
#line 790 "ProbabilityModule.cs"
        double csharp2cuda_temp_255 = __ddiv_rn(__dmul_rn(normalized_a, normalized_b), 3.0);
#line 789 "ProbabilityModule.cs"
        double q = __dadd_rn(__dsub_rn(csharp2cuda_temp_254, csharp2cuda_temp_255), normalized_c);
#line 792 "ProbabilityModule.cs"
        double csharp2cuda_temp_256 = __ddiv_rn(__dmul_rn(q, q), 4.0);
#line 792 "ProbabilityModule.cs"
        double csharp2cuda_temp_257 = __ddiv_rn(__dmul_rn(__dmul_rn(p, p), p), 27.0);
#line 791 "ProbabilityModule.cs"
        MathBlockComplexValue square_root = mathblocks_complex_square_root(mathblocks_complex_make(__dadd_rn(csharp2cuda_temp_256, csharp2cuda_temp_257), 0.0));
#line 794 "ProbabilityModule.cs"
        double csharp2cuda_temp_258 = __ddiv_rn((-(q)), 2.0);
#line 793 "ProbabilityModule.cs"
        MathBlockComplexValue u = mathblocks_probability_complex_cube_root(mathblocks_complex_add(mathblocks_complex_make(csharp2cuda_temp_258, 0.0), square_root));
#line 795 "ProbabilityModule.cs"
        double csharp2cuda_temp_259 = (u).real;
#line 795 "ProbabilityModule.cs"
        bool csharp2cuda_temp_260;
#line 795 "ProbabilityModule.cs"
        if (((csharp2cuda_temp_259) == (0.0)))
        {
#line 795 "ProbabilityModule.cs"
            double csharp2cuda_temp_261 = (u).imaginary;
#line 795 "ProbabilityModule.cs"
            csharp2cuda_temp_260 = ((csharp2cuda_temp_261) == (0.0));
        }
        else
        {
#line 795 "ProbabilityModule.cs"
            csharp2cuda_temp_260 = false;
        }
#line 795 "ProbabilityModule.cs"
        MathBlockComplexValue csharp2cuda_temp_262;
#line 795 "ProbabilityModule.cs"
        if (csharp2cuda_temp_260)
        {
#line 797 "ProbabilityModule.cs"
            double csharp2cuda_temp_263 = __ddiv_rn((-(q)), 2.0);
#line 795 "ProbabilityModule.cs"
            csharp2cuda_temp_262 = mathblocks_probability_complex_cube_root(mathblocks_complex_subtract(mathblocks_complex_make(csharp2cuda_temp_263, 0.0), square_root));
        }
        else
        {
#line 795 "ProbabilityModule.cs"
            csharp2cuda_temp_262 = mathblocks_complex_divide(mathblocks_complex_make((-(p)), 0.0), mathblocks_complex_multiply(mathblocks_complex_make(3.0, 0.0), u));
        }
#line 795 "ProbabilityModule.cs"
        MathBlockComplexValue v = csharp2cuda_temp_262;
#line 803 "ProbabilityModule.cs"
        double csharp2cuda_temp_264 = __ddiv_rn(mathblocks_square_root(3.0), 2.0);
#line 801 "ProbabilityModule.cs"
        MathBlockComplexValue omega = mathblocks_complex_make((-(0.5)), csharp2cuda_temp_264);
#line 804 "ProbabilityModule.cs"
#line 804 "ProbabilityModule.cs"
        MathBlockComplexValue* csharp2cuda_temp_265 = &((roots)[0]);
#line 806 "ProbabilityModule.cs"
        double csharp2cuda_temp_266 = __ddiv_rn(normalized_a, 3.0);
        (*(csharp2cuda_temp_265) = mathblocks_complex_subtract(mathblocks_complex_add(u, v), mathblocks_complex_make(csharp2cuda_temp_266, 0.0)));
#line 807 "ProbabilityModule.cs"
#line 807 "ProbabilityModule.cs"
        MathBlockComplexValue* csharp2cuda_temp_267 = &((roots)[1]);
#line 811 "ProbabilityModule.cs"
        double csharp2cuda_temp_268 = __ddiv_rn(normalized_a, 3.0);
        (*(csharp2cuda_temp_267) = mathblocks_complex_subtract(mathblocks_complex_add(mathblocks_complex_multiply(omega, u), mathblocks_complex_multiply(mathblocks_complex_conjugate(omega), v)), mathblocks_complex_make(csharp2cuda_temp_268, 0.0)));
#line 812 "ProbabilityModule.cs"
#line 812 "ProbabilityModule.cs"
        MathBlockComplexValue* csharp2cuda_temp_269 = &((roots)[2]);
#line 816 "ProbabilityModule.cs"
        double csharp2cuda_temp_270 = __ddiv_rn(normalized_a, 3.0);
        (*(csharp2cuda_temp_269) = mathblocks_complex_subtract(mathblocks_complex_add(mathblocks_complex_multiply(mathblocks_complex_conjugate(omega), u), mathblocks_complex_multiply(omega, v)), mathblocks_complex_make(csharp2cuda_temp_270, 0.0)));
#line 817 "ProbabilityModule.cs"
        {
#line 817 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (3))))
                    break;
#line 818 "ProbabilityModule.cs"
#line 818 "ProbabilityModule.cs"
                MathBlockComplexValue csharp2cuda_temp_272 = (roots)[index];
                if ((!(mathblocks_complex_finite(csharp2cuda_temp_272))))
                {
#line 818 "ProbabilityModule.cs"
#line 818 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_273 = &((output)->valid);
                    (*(csharp2cuda_temp_273) = 0);
                }
#line 817 "ProbabilityModule.cs"
                int* csharp2cuda_temp_271 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_271));
            }
        }
#line 819 "ProbabilityModule.cs"
        return;
    }
#line 822 "ProbabilityModule.cs"
    if (((opcode) == (20)))
#line 823 "ProbabilityModule.cs"
    {
#line 824 "ProbabilityModule.cs"
        int order = 0;
#line 825 "ProbabilityModule.cs"
#line 825 "ProbabilityModule.cs"
        double csharp2cuda_temp_274 = (second)->scalar_value;
#line 825 "ProbabilityModule.cs"
        int* csharp2cuda_temp_275 = &(order);
#line 825 "ProbabilityModule.cs"
        bool csharp2cuda_temp_276 = mathblocks_probability_integer(csharp2cuda_temp_274, csharp2cuda_temp_275);
#line 825 "ProbabilityModule.cs"
        bool csharp2cuda_temp_277;
#line 825 "ProbabilityModule.cs"
        if (!((!(csharp2cuda_temp_276))))
        {
#line 825 "ProbabilityModule.cs"
            csharp2cuda_temp_277 = ((order) < (0));
        }
        else
        {
#line 825 "ProbabilityModule.cs"
            csharp2cuda_temp_277 = true;
        }
#line 825 "ProbabilityModule.cs"
        bool csharp2cuda_temp_278;
#line 825 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_277))
        {
#line 826 "ProbabilityModule.cs"
            int csharp2cuda_temp_279 = (first)->count;
#line 825 "ProbabilityModule.cs"
            csharp2cuda_temp_278 = ((order) > (csharp2cuda_temp_279));
        }
        else
        {
#line 825 "ProbabilityModule.cs"
            csharp2cuda_temp_278 = true;
        }
#line 825 "ProbabilityModule.cs"
        bool csharp2cuda_temp_280;
#line 825 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_278))
        {
#line 825 "ProbabilityModule.cs"
            csharp2cuda_temp_280 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 825 "ProbabilityModule.cs"
            csharp2cuda_temp_280 = true;
        }
        if (csharp2cuda_temp_280)
#line 827 "ProbabilityModule.cs"
        {
#line 828 "ProbabilityModule.cs"
#line 828 "ProbabilityModule.cs"
            int* csharp2cuda_temp_281 = &((output)->valid);
            (*(csharp2cuda_temp_281) = 0);
#line 829 "ProbabilityModule.cs"
            return;
        }
#line 831 "ProbabilityModule.cs"
        {
#line 831 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) <= (order))))
                    break;
#line 831 "ProbabilityModule.cs"
#line 831 "ProbabilityModule.cs"
                double* csharp2cuda_temp_283 = &((scratch)[index]);
                (*(csharp2cuda_temp_283) = 0.0);
#line 831 "ProbabilityModule.cs"
                int* csharp2cuda_temp_282 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_282));
            }
        }
#line 832 "ProbabilityModule.cs"
#line 832 "ProbabilityModule.cs"
        double* csharp2cuda_temp_284 = &((scratch)[0]);
        (*(csharp2cuda_temp_284) = 1.0);
#line 833 "ProbabilityModule.cs"
        {
#line 833 "ProbabilityModule.cs"
            int value_index = 0;
            while (true)
            {
#line 833 "ProbabilityModule.cs"
                int csharp2cuda_temp_286 = (first)->count;
                if (!(((value_index) < (csharp2cuda_temp_286))))
                    break;
#line 834 "ProbabilityModule.cs"
                {
#line 835 "ProbabilityModule.cs"
                    int csharp2cuda_temp_287;
#line 835 "ProbabilityModule.cs"
                    if (((order) < (csharp2cuda_i32_add(value_index, 1))))
                    {
#line 835 "ProbabilityModule.cs"
                        csharp2cuda_temp_287 = order;
                    }
                    else
                    {
#line 835 "ProbabilityModule.cs"
                        csharp2cuda_temp_287 = csharp2cuda_i32_add(value_index, 1);
                    }
#line 835 "ProbabilityModule.cs"
                    int maximum = csharp2cuda_temp_287;
#line 836 "ProbabilityModule.cs"
                    {
#line 836 "ProbabilityModule.cs"
                        int degree = maximum;
                        while (true)
                        {
                            if (!(((degree) >= (1))))
                                break;
#line 837 "ProbabilityModule.cs"
#line 837 "ProbabilityModule.cs"
                            double* csharp2cuda_temp_289 = &((scratch)[degree]);
#line 837 "ProbabilityModule.cs"
                            double csharp2cuda_temp_290 = *(csharp2cuda_temp_289);
#line 837 "ProbabilityModule.cs"
                            double csharp2cuda_temp_291 = (a)[value_index];
#line 837 "ProbabilityModule.cs"
                            double csharp2cuda_temp_292 = (scratch)[csharp2cuda_i32_sub(degree, 1)];
                            (*(csharp2cuda_temp_289) = __dadd_rn(csharp2cuda_temp_290, __dmul_rn(csharp2cuda_temp_291, csharp2cuda_temp_292)));
#line 836 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_288 = &(degree);
                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_288));
                        }
                    }
                }
#line 833 "ProbabilityModule.cs"
                int* csharp2cuda_temp_285 = &(value_index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_285));
            }
        }
#line 839 "ProbabilityModule.cs"
#line 839 "ProbabilityModule.cs"
        double* csharp2cuda_temp_293 = &((output)->scalar_value);
#line 839 "ProbabilityModule.cs"
        double csharp2cuda_temp_294 = (scratch)[order];
        (*(csharp2cuda_temp_293) = csharp2cuda_temp_294);
#line 840 "ProbabilityModule.cs"
#line 840 "ProbabilityModule.cs"
        double csharp2cuda_temp_295 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_295))))
        {
#line 840 "ProbabilityModule.cs"
#line 840 "ProbabilityModule.cs"
            int* csharp2cuda_temp_296 = &((output)->valid);
            (*(csharp2cuda_temp_296) = 0);
        }
#line 841 "ProbabilityModule.cs"
        return;
    }
#line 844 "ProbabilityModule.cs"
    if (((opcode) == (21)))
#line 845 "ProbabilityModule.cs"
    {
#line 846 "ProbabilityModule.cs"
        double value = 0.0;
#line 847 "ProbabilityModule.cs"
        {
#line 847 "ProbabilityModule.cs"
            int csharp2cuda_temp_297 = (first)->count;
#line 847 "ProbabilityModule.cs"
            int index = csharp2cuda_i32_sub(csharp2cuda_temp_297, 1);
            while (true)
            {
                if (!(((index) >= (0))))
                    break;
#line 848 "ProbabilityModule.cs"
#line 848 "ProbabilityModule.cs"
                double* csharp2cuda_temp_299 = &(value);
#line 848 "ProbabilityModule.cs"
                double csharp2cuda_temp_300 = (second)->scalar_value;
#line 848 "ProbabilityModule.cs"
                double csharp2cuda_temp_301 = (a)[index];
                (*(csharp2cuda_temp_299) = __dadd_rn(__dmul_rn(value, csharp2cuda_temp_300), csharp2cuda_temp_301));
#line 847 "ProbabilityModule.cs"
                int* csharp2cuda_temp_298 = &(index);
                csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_298));
            }
        }
#line 849 "ProbabilityModule.cs"
#line 849 "ProbabilityModule.cs"
        double* csharp2cuda_temp_302 = &((output)->scalar_value);
        (*(csharp2cuda_temp_302) = value);
#line 850 "ProbabilityModule.cs"
        if ((!(isfinite(value))))
        {
#line 850 "ProbabilityModule.cs"
#line 850 "ProbabilityModule.cs"
            int* csharp2cuda_temp_303 = &((output)->valid);
            (*(csharp2cuda_temp_303) = 0);
        }
#line 851 "ProbabilityModule.cs"
        return;
    }
#line 854 "ProbabilityModule.cs"
    if (((opcode) == (22)))
#line 855 "ProbabilityModule.cs"
    {
#line 856 "ProbabilityModule.cs"
#line 856 "ProbabilityModule.cs"
        int csharp2cuda_temp_304 = (first)->count;
        if (((csharp2cuda_temp_304) <= (0)))
#line 857 "ProbabilityModule.cs"
        {
#line 858 "ProbabilityModule.cs"
#line 858 "ProbabilityModule.cs"
            int* csharp2cuda_temp_305 = &((output)->valid);
            (*(csharp2cuda_temp_305) = 0);
#line 859 "ProbabilityModule.cs"
            return;
        }
#line 861 "ProbabilityModule.cs"
        double maximum = (a)[0];
#line 862 "ProbabilityModule.cs"
        {
#line 862 "ProbabilityModule.cs"
            int index = 1;
            while (true)
            {
#line 862 "ProbabilityModule.cs"
                int csharp2cuda_temp_307 = (first)->count;
                if (!(((index) < (csharp2cuda_temp_307))))
                    break;
#line 863 "ProbabilityModule.cs"
#line 863 "ProbabilityModule.cs"
                double* csharp2cuda_temp_308 = &(maximum);
#line 863 "ProbabilityModule.cs"
                double csharp2cuda_temp_309 = (a)[index];
                (*(csharp2cuda_temp_308) = mathblocks_maximum(maximum, csharp2cuda_temp_309));
#line 862 "ProbabilityModule.cs"
                int* csharp2cuda_temp_306 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_306));
            }
        }
#line 864 "ProbabilityModule.cs"
        double sum = 0.0;
#line 865 "ProbabilityModule.cs"
        {
#line 865 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
#line 865 "ProbabilityModule.cs"
                int csharp2cuda_temp_311 = (first)->count;
                if (!(((index) < (csharp2cuda_temp_311))))
                    break;
#line 866 "ProbabilityModule.cs"
#line 866 "ProbabilityModule.cs"
                double* csharp2cuda_temp_312 = &(sum);
#line 866 "ProbabilityModule.cs"
                double csharp2cuda_temp_313 = *(csharp2cuda_temp_312);
#line 866 "ProbabilityModule.cs"
                double csharp2cuda_temp_314 = (a)[index];
                (*(csharp2cuda_temp_312) = __dadd_rn(csharp2cuda_temp_313, mathblocks_exponential(__dsub_rn(csharp2cuda_temp_314, maximum))));
#line 865 "ProbabilityModule.cs"
                int* csharp2cuda_temp_310 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_310));
            }
        }
#line 867 "ProbabilityModule.cs"
#line 867 "ProbabilityModule.cs"
        double* csharp2cuda_temp_315 = &((output)->scalar_value);
        (*(csharp2cuda_temp_315) = __dadd_rn(maximum, mathblocks_natural_logarithm(sum)));
#line 868 "ProbabilityModule.cs"
#line 868 "ProbabilityModule.cs"
        double csharp2cuda_temp_316 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_316))))
        {
#line 868 "ProbabilityModule.cs"
#line 868 "ProbabilityModule.cs"
            int* csharp2cuda_temp_317 = &((output)->valid);
            (*(csharp2cuda_temp_317) = 0);
        }
#line 869 "ProbabilityModule.cs"
        return;
    }
#line 872 "ProbabilityModule.cs"
#line 872 "ProbabilityModule.cs"
    int* csharp2cuda_temp_318 = &((output)->valid);
    (*(csharp2cuda_temp_318) = 0);
}

#line 138 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_distribution(const double* values, int count)
#line 140 "ProbabilityModule.cs"
{
#line 141 "ProbabilityModule.cs"
    if (((count) <= (0)))
    {
#line 142 "ProbabilityModule.cs"
        return false;
    }
#line 143 "ProbabilityModule.cs"
    {
#line 143 "ProbabilityModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 144 "ProbabilityModule.cs"
#line 144 "ProbabilityModule.cs"
            double csharp2cuda_temp_1 = (values)[index];
            if (((csharp2cuda_temp_1) < (0.0)))
            {
#line 144 "ProbabilityModule.cs"
                return false;
            }
#line 143 "ProbabilityModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 145 "ProbabilityModule.cs"
    return ((fabs(__dsub_rn(mathblocks_compensated_sum(values, count), 1.0))) <= (1E-10));
}

#line 148 "ProbabilityModule.cs"
__device__ double mathblocks_probability_entropy(const double* values, int count)
#line 150 "ProbabilityModule.cs"
{
#line 151 "ProbabilityModule.cs"
    double entropy = 0.0;
#line 152 "ProbabilityModule.cs"
    {
#line 152 "ProbabilityModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 153 "ProbabilityModule.cs"
#line 153 "ProbabilityModule.cs"
            double csharp2cuda_temp_1 = (values)[index];
            if (((csharp2cuda_temp_1) > (0.0)))
            {
#line 154 "ProbabilityModule.cs"
#line 154 "ProbabilityModule.cs"
                double* csharp2cuda_temp_2 = &(entropy);
#line 154 "ProbabilityModule.cs"
                double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 154 "ProbabilityModule.cs"
                double csharp2cuda_temp_4 = (values)[index];
#line 154 "ProbabilityModule.cs"
                double csharp2cuda_temp_5 = (values)[index];
                (*(csharp2cuda_temp_2) = __dsub_rn(csharp2cuda_temp_3, __dmul_rn(csharp2cuda_temp_4, mathblocks_natural_logarithm(csharp2cuda_temp_5))));
            }
#line 152 "ProbabilityModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 155 "ProbabilityModule.cs"
    return entropy;
}

#line 256 "ProbabilityModule.cs"
__device__ double mathblocks_probability_incomplete_beta(
    double x,
    double left,
    double right,
    bool* converged)
#line 262 "ProbabilityModule.cs"
{
#line 263 "ProbabilityModule.cs"
#line 263 "ProbabilityModule.cs"
    bool* csharp2cuda_temp_0 = converged;
    (*(csharp2cuda_temp_0) = true);
#line 264 "ProbabilityModule.cs"
    if (((x) == (0.0)))
    {
#line 264 "ProbabilityModule.cs"
        return 0.0;
    }
#line 265 "ProbabilityModule.cs"
    if (((x) == (1.0)))
    {
#line 265 "ProbabilityModule.cs"
        return 1.0;
    }
#line 266 "ProbabilityModule.cs"
    double front = mathblocks_exponential(__dadd_rn(__dadd_rn(__dsub_rn(__dsub_rn(mathblocks_probability_log_gamma(__dadd_rn(left, right)), mathblocks_probability_log_gamma(left)), mathblocks_probability_log_gamma(right)), __dmul_rn(left, mathblocks_natural_logarithm(x))), __dmul_rn(right, mathblocks_log_one_plus((-(x))))));
#line 272 "ProbabilityModule.cs"
#line 272 "ProbabilityModule.cs"
    double csharp2cuda_temp_1 = __ddiv_rn(__dadd_rn(left, 1.0), __dadd_rn(__dadd_rn(left, right), 2.0));
#line 272 "ProbabilityModule.cs"
    double csharp2cuda_temp_2;
#line 272 "ProbabilityModule.cs"
    if (((x) < (csharp2cuda_temp_1)))
    {
#line 273 "ProbabilityModule.cs"
        double csharp2cuda_temp_3 = mathblocks_probability_beta_fraction(x, left, right, converged);
#line 272 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = __ddiv_rn(__dmul_rn(front, csharp2cuda_temp_3), left);
    }
    else
    {
#line 274 "ProbabilityModule.cs"
        double csharp2cuda_temp_4 = mathblocks_probability_beta_fraction(__dsub_rn(1.0, x), right, left, converged);
#line 274 "ProbabilityModule.cs"
        double csharp2cuda_temp_5 = __ddiv_rn(__dmul_rn(front, csharp2cuda_temp_4), right);
#line 272 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = __dsub_rn(1.0, csharp2cuda_temp_5);
    }
    return csharp2cuda_temp_2;
}

#line 116 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_integer(double value, int* result)
#line 118 "ProbabilityModule.cs"
{
#line 119 "ProbabilityModule.cs"
#line 119 "ProbabilityModule.cs"
    bool csharp2cuda_temp_0;
#line 119 "ProbabilityModule.cs"
    if (!(((value) < ((-(2147483648.0))))))
    {
#line 119 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = ((value) > (2147483647.0));
    }
    else
    {
#line 119 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 119 "ProbabilityModule.cs"
    bool csharp2cuda_temp_1;
#line 119 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_0))
    {
#line 119 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = ((value) != (trunc(value)));
    }
    else
    {
#line 119 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = true;
    }
    if (csharp2cuda_temp_1)
    {
#line 120 "ProbabilityModule.cs"
        return false;
    }
#line 121 "ProbabilityModule.cs"
#line 121 "ProbabilityModule.cs"
    int* csharp2cuda_temp_2 = result;
    (*(csharp2cuda_temp_2) = csharp2cuda_f64_to_i32(value));
#line 122 "ProbabilityModule.cs"
    return true;
}

#line 158 "ProbabilityModule.cs"
__device__ double mathblocks_probability_kl(
    const double* probabilities,
    const double* reference,
    int count)
#line 163 "ProbabilityModule.cs"
{
#line 164 "ProbabilityModule.cs"
    double result = 0.0;
#line 165 "ProbabilityModule.cs"
    {
#line 165 "ProbabilityModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 166 "ProbabilityModule.cs"
#line 166 "ProbabilityModule.cs"
            double csharp2cuda_temp_1 = (probabilities)[index];
            if (((csharp2cuda_temp_1) > (0.0)))
            {
#line 167 "ProbabilityModule.cs"
#line 167 "ProbabilityModule.cs"
                double* csharp2cuda_temp_2 = &(result);
#line 167 "ProbabilityModule.cs"
                double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 167 "ProbabilityModule.cs"
                double csharp2cuda_temp_4 = (probabilities)[index];
#line 168 "ProbabilityModule.cs"
                double csharp2cuda_temp_5 = (probabilities)[index];
#line 168 "ProbabilityModule.cs"
                double csharp2cuda_temp_6 = (reference)[index];
#line 168 "ProbabilityModule.cs"
                double csharp2cuda_temp_7 = __ddiv_rn(csharp2cuda_temp_5, csharp2cuda_temp_6);
                (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, __dmul_rn(csharp2cuda_temp_4, mathblocks_natural_logarithm(csharp2cuda_temp_7))));
            }
#line 165 "ProbabilityModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 169 "ProbabilityModule.cs"
    return result;
}

#line 199 "ProbabilityModule.cs"
__device__ double mathblocks_probability_log_gamma(double value)
#line 201 "ProbabilityModule.cs"
{
#line 202 "ProbabilityModule.cs"
    if (((value) < (0.5)))
#line 203 "ProbabilityModule.cs"
    {
#line 204 "ProbabilityModule.cs"
        return __dsub_rn(__dsub_rn(mathblocks_natural_logarithm(3.141592653589793), mathblocks_natural_logarithm(mathblocks_sine(__dmul_rn(3.141592653589793, value)))), mathblocks_probability_log_gamma_core(__dsub_rn(1.0, value)));
    }
#line 209 "ProbabilityModule.cs"
    return mathblocks_probability_log_gamma_core(value);
}

#line 172 "ProbabilityModule.cs"
__device__ double mathblocks_probability_log_gamma_core(double value)
#line 174 "ProbabilityModule.cs"
{
#line 175 "ProbabilityModule.cs"
    const double csharp2cuda_temp_0_storage[8] = { 676.5203681218851, -1259.1392167224028, 771.3234287776531, -176.6150291621406, 12.507343278686905, -0.13857109526572012, 9.984369578019572E-06, 1.5056327351493116E-07 };
    csharp2cuda_readonly_array_view<double> coefficients(csharp2cuda_temp_0_storage, 8, false);
#line 186 "ProbabilityModule.cs"
#line 186 "ProbabilityModule.cs"
    double* csharp2cuda_temp_1 = &(value);
#line 186 "ProbabilityModule.cs"
    double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
    (*(csharp2cuda_temp_1) = __dsub_rn(csharp2cuda_temp_2, 1.0));
#line 187 "ProbabilityModule.cs"
    double sum = 0.9999999999998099;
#line 188 "ProbabilityModule.cs"
    {
#line 188 "ProbabilityModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (8))))
                break;
#line 189 "ProbabilityModule.cs"
#line 189 "ProbabilityModule.cs"
            double* csharp2cuda_temp_4 = &(sum);
#line 189 "ProbabilityModule.cs"
            double csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
#line 189 "ProbabilityModule.cs"
            double csharp2cuda_temp_6 = (coefficients)[index];
#line 189 "ProbabilityModule.cs"
            double csharp2cuda_temp_7 = __ddiv_rn(csharp2cuda_temp_6, __dadd_rn(__dadd_rn(value, ((double)(index))), 1.0));
            (*(csharp2cuda_temp_4) = __dadd_rn(csharp2cuda_temp_5, csharp2cuda_temp_7));
#line 188 "ProbabilityModule.cs"
            int* csharp2cuda_temp_3 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
        }
    }
#line 191 "ProbabilityModule.cs"
    double shifted = __dadd_rn(value, 8.0);
#line 192 "ProbabilityModule.cs"
    double t = __dsub_rn(shifted, 0.5);
#line 193 "ProbabilityModule.cs"
    return __dadd_rn(__dsub_rn(__dadd_rn(__dmul_rn(0.5, mathblocks_natural_logarithm(__dmul_rn(2.0, 3.141592653589793))), __dmul_rn(__dadd_rn(value, 0.5), mathblocks_natural_logarithm(t))), t), mathblocks_natural_logarithm(sum));
}

#line 290 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_ordered_entropy_value(
    const double* values,
    int count,
    double order,
    bool renyi,
    double* value)
#line 297 "ProbabilityModule.cs"
{
#line 298 "ProbabilityModule.cs"
    if (((order) <= (0.0)))
    {
#line 299 "ProbabilityModule.cs"
        return false;
    }
#line 300 "ProbabilityModule.cs"
    if (((order) == (1.0)))
#line 301 "ProbabilityModule.cs"
    {
#line 302 "ProbabilityModule.cs"
#line 302 "ProbabilityModule.cs"
        double* csharp2cuda_temp_0 = value;
#line 302 "ProbabilityModule.cs"
        double csharp2cuda_temp_1 = mathblocks_probability_entropy(values, count);
        (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
    }
    else
#line 305 "ProbabilityModule.cs"
    {
#line 306 "ProbabilityModule.cs"
        double sum = 0.0;
#line 307 "ProbabilityModule.cs"
        {
#line 307 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 308 "ProbabilityModule.cs"
#line 308 "ProbabilityModule.cs"
                double* csharp2cuda_temp_3 = &(sum);
#line 308 "ProbabilityModule.cs"
                double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 308 "ProbabilityModule.cs"
                double csharp2cuda_temp_5 = (values)[index];
                (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, mathblocks_power(csharp2cuda_temp_5, order)));
#line 307 "ProbabilityModule.cs"
                int* csharp2cuda_temp_2 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
            }
        }
#line 309 "ProbabilityModule.cs"
#line 309 "ProbabilityModule.cs"
        double* csharp2cuda_temp_6 = value;
#line 309 "ProbabilityModule.cs"
        double csharp2cuda_temp_7;
#line 309 "ProbabilityModule.cs"
        if (renyi)
        {
#line 309 "ProbabilityModule.cs"
            csharp2cuda_temp_7 = __ddiv_rn(mathblocks_natural_logarithm(sum), __dsub_rn(1.0, order));
        }
        else
        {
#line 309 "ProbabilityModule.cs"
            csharp2cuda_temp_7 = __ddiv_rn(__dsub_rn(1.0, sum), __dsub_rn(order, 1.0));
        }
        (*(csharp2cuda_temp_6) = csharp2cuda_temp_7);
    }
#line 313 "ProbabilityModule.cs"
    return true;
}

#line 320 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_scalar_value(int opcode, double a, double b, double c, double* value, bool* converged)
#line 322 "ProbabilityModule.cs"
{
#line 323 "ProbabilityModule.cs"
#line 323 "ProbabilityModule.cs"
    double* csharp2cuda_temp_0 = value;
    (*(csharp2cuda_temp_0) = 0.0);
#line 324 "ProbabilityModule.cs"
#line 324 "ProbabilityModule.cs"
    bool* csharp2cuda_temp_1 = converged;
    (*(csharp2cuda_temp_1) = true);
#line 325 "ProbabilityModule.cs"
#line 325 "ProbabilityModule.cs"
    bool csharp2cuda_temp_2;
#line 325 "ProbabilityModule.cs"
    if (!(((opcode) == (0))))
    {
#line 325 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = ((opcode) == (1));
    }
    else
    {
#line 325 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = true;
    }
#line 325 "ProbabilityModule.cs"
    bool csharp2cuda_temp_3;
#line 325 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_2))
    {
#line 325 "ProbabilityModule.cs"
        csharp2cuda_temp_3 = ((opcode) == (2));
    }
    else
    {
#line 325 "ProbabilityModule.cs"
        csharp2cuda_temp_3 = true;
    }
    if (csharp2cuda_temp_3)
#line 326 "ProbabilityModule.cs"
    {
#line 327 "ProbabilityModule.cs"
        int first_integer = 0;
#line 328 "ProbabilityModule.cs"
        int second_integer = 0;
#line 329 "ProbabilityModule.cs"
#line 329 "ProbabilityModule.cs"
        int* csharp2cuda_temp_4 = &(first_integer);
#line 329 "ProbabilityModule.cs"
        bool csharp2cuda_temp_5 = mathblocks_probability_integer(a, csharp2cuda_temp_4);
#line 329 "ProbabilityModule.cs"
        bool csharp2cuda_temp_6;
#line 329 "ProbabilityModule.cs"
        if (!((!(csharp2cuda_temp_5))))
        {
#line 329 "ProbabilityModule.cs"
            csharp2cuda_temp_6 = ((first_integer) < (0));
        }
        else
        {
#line 329 "ProbabilityModule.cs"
            csharp2cuda_temp_6 = true;
        }
#line 329 "ProbabilityModule.cs"
        bool csharp2cuda_temp_7;
#line 329 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_6))
        {
#line 330 "ProbabilityModule.cs"
            bool csharp2cuda_temp_8;
#line 330 "ProbabilityModule.cs"
            if (((opcode) != (2)))
            {
#line 330 "ProbabilityModule.cs"
                int* csharp2cuda_temp_9 = &(second_integer);
#line 330 "ProbabilityModule.cs"
                bool csharp2cuda_temp_10 = mathblocks_probability_integer(b, csharp2cuda_temp_9);
#line 330 "ProbabilityModule.cs"
                csharp2cuda_temp_8 = (!(csharp2cuda_temp_10));
            }
            else
            {
#line 330 "ProbabilityModule.cs"
                csharp2cuda_temp_8 = false;
            }
#line 329 "ProbabilityModule.cs"
            csharp2cuda_temp_7 = csharp2cuda_temp_8;
        }
        else
        {
#line 329 "ProbabilityModule.cs"
            csharp2cuda_temp_7 = true;
        }
#line 329 "ProbabilityModule.cs"
        bool csharp2cuda_temp_11;
#line 329 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_7))
        {
#line 331 "ProbabilityModule.cs"
            bool csharp2cuda_temp_12;
#line 331 "ProbabilityModule.cs"
            if (((opcode) == (2)))
            {
#line 331 "ProbabilityModule.cs"
                csharp2cuda_temp_12 = ((first_integer) > (170));
            }
            else
            {
#line 331 "ProbabilityModule.cs"
                csharp2cuda_temp_12 = false;
            }
#line 329 "ProbabilityModule.cs"
            csharp2cuda_temp_11 = csharp2cuda_temp_12;
        }
        else
        {
#line 329 "ProbabilityModule.cs"
            csharp2cuda_temp_11 = true;
        }
#line 329 "ProbabilityModule.cs"
        bool csharp2cuda_temp_13;
#line 329 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_11))
        {
#line 332 "ProbabilityModule.cs"
            bool csharp2cuda_temp_14;
#line 332 "ProbabilityModule.cs"
            if (((opcode) == (0)))
            {
#line 332 "ProbabilityModule.cs"
                bool csharp2cuda_temp_15;
#line 332 "ProbabilityModule.cs"
                if (!(((first_integer) <= (second_integer))))
                {
#line 332 "ProbabilityModule.cs"
                    csharp2cuda_temp_15 = ((second_integer) < (0));
                }
                else
                {
#line 332 "ProbabilityModule.cs"
                    csharp2cuda_temp_15 = true;
                }
#line 332 "ProbabilityModule.cs"
                csharp2cuda_temp_14 = csharp2cuda_temp_15;
            }
            else
            {
#line 332 "ProbabilityModule.cs"
                csharp2cuda_temp_14 = false;
            }
#line 329 "ProbabilityModule.cs"
            csharp2cuda_temp_13 = csharp2cuda_temp_14;
        }
        else
        {
#line 329 "ProbabilityModule.cs"
            csharp2cuda_temp_13 = true;
        }
        if (csharp2cuda_temp_13)
#line 333 "ProbabilityModule.cs"
        {
#line 334 "ProbabilityModule.cs"
            return false;
        }
#line 336 "ProbabilityModule.cs"
        if (((opcode) == (0)))
#line 337 "ProbabilityModule.cs"
        {
#line 338 "ProbabilityModule.cs"
#line 338 "ProbabilityModule.cs"
            double* csharp2cuda_temp_16 = value;
#line 338 "ProbabilityModule.cs"
            double csharp2cuda_temp_17 = __ddiv_rn(((double)(csharp2cuda_i32_sub(first_integer, second_integer))), ((double)(csharp2cuda_i32_add(first_integer, second_integer))));
            (*(csharp2cuda_temp_16) = __dmul_rn(csharp2cuda_temp_17, mathblocks_probability_binomial(csharp2cuda_i32_add(first_integer, second_integer), second_integer)));
        }
        else
        {
#line 342 "ProbabilityModule.cs"
            if (((opcode) == (1)))
#line 343 "ProbabilityModule.cs"
            {
#line 344 "ProbabilityModule.cs"
#line 344 "ProbabilityModule.cs"
                double* csharp2cuda_temp_18 = value;
                (*(csharp2cuda_temp_18) = mathblocks_probability_binomial(first_integer, second_integer));
            }
            else
#line 347 "ProbabilityModule.cs"
            {
#line 348 "ProbabilityModule.cs"
                double factorial = 1.0;
#line 349 "ProbabilityModule.cs"
                {
#line 349 "ProbabilityModule.cs"
                    int index = 2;
                    while (true)
                    {
                        if (!(((index) <= (first_integer))))
                            break;
#line 349 "ProbabilityModule.cs"
#line 349 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_20 = &(factorial);
#line 349 "ProbabilityModule.cs"
                        double csharp2cuda_temp_21 = *(csharp2cuda_temp_20);
                        (*(csharp2cuda_temp_20) = __dmul_rn(csharp2cuda_temp_21, ((double)(index))));
#line 349 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_19 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_19));
                    }
                }
#line 350 "ProbabilityModule.cs"
#line 350 "ProbabilityModule.cs"
                double* csharp2cuda_temp_22 = value;
                (*(csharp2cuda_temp_22) = factorial);
            }
        }
#line 352 "ProbabilityModule.cs"
#line 352 "ProbabilityModule.cs"
        double csharp2cuda_temp_23 = *(value);
        return isfinite(csharp2cuda_temp_23);
    }
#line 355 "ProbabilityModule.cs"
    if (((opcode) == (23)))
#line 356 "ProbabilityModule.cs"
    {
#line 357 "ProbabilityModule.cs"
#line 357 "ProbabilityModule.cs"
        double* csharp2cuda_temp_24 = value;
#line 357 "ProbabilityModule.cs"
        double csharp2cuda_temp_25 = __ddiv_rn(a, mathblocks_square_root(2.0));
        (*(csharp2cuda_temp_24) = __dmul_rn(0.5, __dadd_rn(1.0, mathblocks_error_function(csharp2cuda_temp_25))));
#line 358 "ProbabilityModule.cs"
#line 358 "ProbabilityModule.cs"
        double csharp2cuda_temp_26 = *(value);
        return isfinite(csharp2cuda_temp_26);
    }
#line 361 "ProbabilityModule.cs"
#line 361 "ProbabilityModule.cs"
    bool csharp2cuda_temp_27;
#line 361 "ProbabilityModule.cs"
    if (!(((opcode) == (25))))
    {
#line 361 "ProbabilityModule.cs"
        csharp2cuda_temp_27 = ((opcode) == (26));
    }
    else
    {
#line 361 "ProbabilityModule.cs"
        csharp2cuda_temp_27 = true;
    }
    if (csharp2cuda_temp_27)
#line 362 "ProbabilityModule.cs"
    {
#line 363 "ProbabilityModule.cs"
        int count = 0;
#line 364 "ProbabilityModule.cs"
        double rate = a;
#line 365 "ProbabilityModule.cs"
#line 365 "ProbabilityModule.cs"
        int* csharp2cuda_temp_28 = &(count);
#line 365 "ProbabilityModule.cs"
        bool csharp2cuda_temp_29 = mathblocks_probability_integer(b, csharp2cuda_temp_28);
#line 365 "ProbabilityModule.cs"
        bool csharp2cuda_temp_30;
#line 365 "ProbabilityModule.cs"
        if (!((!(csharp2cuda_temp_29))))
        {
#line 365 "ProbabilityModule.cs"
            csharp2cuda_temp_30 = ((count) < (0));
        }
        else
        {
#line 365 "ProbabilityModule.cs"
            csharp2cuda_temp_30 = true;
        }
#line 365 "ProbabilityModule.cs"
        bool csharp2cuda_temp_31;
#line 365 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_30))
        {
#line 365 "ProbabilityModule.cs"
            csharp2cuda_temp_31 = ((rate) < (0.0));
        }
        else
        {
#line 365 "ProbabilityModule.cs"
            csharp2cuda_temp_31 = true;
        }
        if (csharp2cuda_temp_31)
        {
#line 366 "ProbabilityModule.cs"
            return false;
        }
#line 367 "ProbabilityModule.cs"
        double sum = 0.0;
#line 368 "ProbabilityModule.cs"
#line 368 "ProbabilityModule.cs"
        bool csharp2cuda_temp_32;
#line 368 "ProbabilityModule.cs"
        if (((opcode) == (25)))
        {
#line 368 "ProbabilityModule.cs"
            csharp2cuda_temp_32 = ((rate) == (0.0));
        }
        else
        {
#line 368 "ProbabilityModule.cs"
            csharp2cuda_temp_32 = false;
        }
        if (csharp2cuda_temp_32)
#line 369 "ProbabilityModule.cs"
        {
#line 371 "ProbabilityModule.cs"
#line 371 "ProbabilityModule.cs"
            double* csharp2cuda_temp_33 = &(sum);
            (*(csharp2cuda_temp_33) = 1.0);
        }
        else
        {
#line 373 "ProbabilityModule.cs"
            if (((opcode) == (25)))
#line 374 "ProbabilityModule.cs"
            {
#line 378 "ProbabilityModule.cs"
                double log_rate = mathblocks_natural_logarithm(rate);
#line 379 "ProbabilityModule.cs"
                int csharp2cuda_temp_34;
#line 379 "ProbabilityModule.cs"
                if (((rate) < (((double)(count)))))
                {
#line 379 "ProbabilityModule.cs"
                    csharp2cuda_temp_34 = csharp2cuda_f64_to_i32(rate);
                }
                else
                {
#line 379 "ProbabilityModule.cs"
                    csharp2cuda_temp_34 = count;
                }
#line 379 "ProbabilityModule.cs"
                int peak = csharp2cuda_temp_34;
#line 380 "ProbabilityModule.cs"
                int first = 0;
#line 381 "ProbabilityModule.cs"
                bool reached = ((__dsub_rn(__dadd_rn((-(rate)), __dmul_rn(((double)(peak)), log_rate)), mathblocks_probability_log_gamma(__dadd_rn(((double)(peak)), 1.0)))) >= ((-(800.0))));
#line 382 "ProbabilityModule.cs"
                if (reached)
#line 383 "ProbabilityModule.cs"
                {
#line 384 "ProbabilityModule.cs"
                    int high = peak;
#line 385 "ProbabilityModule.cs"
                    while (true)
                    {
                        if (!(((first) < (high))))
                            break;
#line 386 "ProbabilityModule.cs"
                        {
#line 387 "ProbabilityModule.cs"
                            int csharp2cuda_temp_35 = csharp2cuda_i32_div(csharp2cuda_i32_sub(high, first), 2);
#line 387 "ProbabilityModule.cs"
                            int middle = csharp2cuda_i32_add(first, csharp2cuda_temp_35);
#line 388 "ProbabilityModule.cs"
                            if (((__dsub_rn(__dadd_rn((-(rate)), __dmul_rn(((double)(middle)), log_rate)), mathblocks_probability_log_gamma(__dadd_rn(((double)(middle)), 1.0)))) >= ((-(800.0)))))
                            {
#line 389 "ProbabilityModule.cs"
#line 389 "ProbabilityModule.cs"
                                int* csharp2cuda_temp_36 = &(high);
                                (*(csharp2cuda_temp_36) = middle);
                            }
                            else
                            {
#line 391 "ProbabilityModule.cs"
#line 391 "ProbabilityModule.cs"
                                int* csharp2cuda_temp_37 = &(first);
                                (*(csharp2cuda_temp_37) = csharp2cuda_i32_add(middle, 1));
                            }
                        }
                    }
#line 393 "ProbabilityModule.cs"
                    {
#line 393 "ProbabilityModule.cs"
                        int index = first;
                        while (true)
                        {
                            if (!(((index) <= (count))))
                                break;
#line 394 "ProbabilityModule.cs"
                            {
#line 395 "ProbabilityModule.cs"
                                double exponent = __dsub_rn(__dadd_rn((-(rate)), __dmul_rn(((double)(index)), log_rate)), mathblocks_probability_log_gamma(__dadd_rn(((double)(index)), 1.0)));
#line 396 "ProbabilityModule.cs"
#line 396 "ProbabilityModule.cs"
                                bool csharp2cuda_temp_39;
#line 396 "ProbabilityModule.cs"
                                if (((((double)(index))) > (rate)))
                                {
#line 396 "ProbabilityModule.cs"
                                    csharp2cuda_temp_39 = ((exponent) < ((-(800.0))));
                                }
                                else
                                {
#line 396 "ProbabilityModule.cs"
                                    csharp2cuda_temp_39 = false;
                                }
                                if (csharp2cuda_temp_39)
                                {
#line 397 "ProbabilityModule.cs"
                                    break;
                                }
#line 398 "ProbabilityModule.cs"
#line 398 "ProbabilityModule.cs"
                                double* csharp2cuda_temp_40 = &(sum);
#line 398 "ProbabilityModule.cs"
                                double csharp2cuda_temp_41 = *(csharp2cuda_temp_40);
                                (*(csharp2cuda_temp_40) = __dadd_rn(csharp2cuda_temp_41, mathblocks_exponential(exponent)));
                            }
#line 393 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_38 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_38));
                        }
                    }
                }
            }
            else
#line 403 "ProbabilityModule.cs"
            {
#line 404 "ProbabilityModule.cs"
                {
#line 404 "ProbabilityModule.cs"
                    int index = count;
                    while (true)
                    {
                        if (!(((index) <= (count))))
                            break;
#line 405 "ProbabilityModule.cs"
                        {
#line 406 "ProbabilityModule.cs"
                            double csharp2cuda_temp_43;
#line 406 "ProbabilityModule.cs"
                            if (((rate) == (0.0)))
                            {
#line 407 "ProbabilityModule.cs"
                                double csharp2cuda_temp_44;
#line 407 "ProbabilityModule.cs"
                                if (((index) == (0)))
                                {
#line 407 "ProbabilityModule.cs"
                                    csharp2cuda_temp_44 = 1.0;
                                }
                                else
                                {
#line 407 "ProbabilityModule.cs"
                                    csharp2cuda_temp_44 = 0.0;
                                }
#line 406 "ProbabilityModule.cs"
                                csharp2cuda_temp_43 = csharp2cuda_temp_44;
                            }
                            else
                            {
#line 406 "ProbabilityModule.cs"
                                csharp2cuda_temp_43 = mathblocks_exponential(__dsub_rn(__dadd_rn((-(rate)), __dmul_rn(((double)(index)), mathblocks_natural_logarithm(rate))), mathblocks_probability_log_gamma(__dadd_rn(((double)(index)), 1.0))));
                            }
#line 406 "ProbabilityModule.cs"
                            double probability = csharp2cuda_temp_43;
#line 411 "ProbabilityModule.cs"
#line 411 "ProbabilityModule.cs"
                            double* csharp2cuda_temp_45 = &(sum);
#line 411 "ProbabilityModule.cs"
                            double csharp2cuda_temp_46 = *(csharp2cuda_temp_45);
                            (*(csharp2cuda_temp_45) = __dadd_rn(csharp2cuda_temp_46, probability));
                        }
#line 404 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_42 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_42));
                    }
                }
            }
        }
#line 414 "ProbabilityModule.cs"
#line 414 "ProbabilityModule.cs"
        double* csharp2cuda_temp_47 = value;
        (*(csharp2cuda_temp_47) = sum);
#line 415 "ProbabilityModule.cs"
        return isfinite(sum);
    }
#line 418 "ProbabilityModule.cs"
    if (((opcode) == (28)))
#line 419 "ProbabilityModule.cs"
    {
#line 420 "ProbabilityModule.cs"
#line 420 "ProbabilityModule.cs"
        double* csharp2cuda_temp_48 = value;
        (*(csharp2cuda_temp_48) = mathblocks_exponential(__dsub_rn(__dadd_rn(mathblocks_probability_log_gamma(a), mathblocks_probability_log_gamma(b)), mathblocks_probability_log_gamma(__dadd_rn(a, b)))));
    }
    else
    {
#line 425 "ProbabilityModule.cs"
        if (((opcode) == (29)))
#line 426 "ProbabilityModule.cs"
        {
#line 427 "ProbabilityModule.cs"
#line 427 "ProbabilityModule.cs"
            double* csharp2cuda_temp_49 = value;
            (*(csharp2cuda_temp_49) = mathblocks_probability_log_gamma(a));
        }
        else
        {
#line 429 "ProbabilityModule.cs"
            if (((opcode) == (30)))
#line 430 "ProbabilityModule.cs"
            {
#line 431 "ProbabilityModule.cs"
#line 431 "ProbabilityModule.cs"
                bool csharp2cuda_temp_50;
#line 431 "ProbabilityModule.cs"
                if (!(((a) < (0.0))))
                {
#line 431 "ProbabilityModule.cs"
                    csharp2cuda_temp_50 = ((a) > (1.0));
                }
                else
                {
#line 431 "ProbabilityModule.cs"
                    csharp2cuda_temp_50 = true;
                }
#line 431 "ProbabilityModule.cs"
                bool csharp2cuda_temp_51;
#line 431 "ProbabilityModule.cs"
                if (!(csharp2cuda_temp_50))
                {
#line 431 "ProbabilityModule.cs"
                    csharp2cuda_temp_51 = ((b) <= (0.0));
                }
                else
                {
#line 431 "ProbabilityModule.cs"
                    csharp2cuda_temp_51 = true;
                }
#line 431 "ProbabilityModule.cs"
                bool csharp2cuda_temp_52;
#line 431 "ProbabilityModule.cs"
                if (!(csharp2cuda_temp_51))
                {
#line 431 "ProbabilityModule.cs"
                    csharp2cuda_temp_52 = ((c) <= (0.0));
                }
                else
                {
#line 431 "ProbabilityModule.cs"
                    csharp2cuda_temp_52 = true;
                }
                if (csharp2cuda_temp_52)
                {
#line 432 "ProbabilityModule.cs"
                    return false;
                }
#line 433 "ProbabilityModule.cs"
#line 433 "ProbabilityModule.cs"
                double* csharp2cuda_temp_53 = value;
#line 433 "ProbabilityModule.cs"
                double csharp2cuda_temp_54 = mathblocks_probability_incomplete_beta(a, b, c, converged);
                (*(csharp2cuda_temp_53) = csharp2cuda_temp_54);
#line 435 "ProbabilityModule.cs"
#line 435 "ProbabilityModule.cs"
                bool csharp2cuda_temp_55 = *(converged);
#line 435 "ProbabilityModule.cs"
                bool csharp2cuda_temp_56;
#line 435 "ProbabilityModule.cs"
                if ((!(csharp2cuda_temp_55)))
                {
#line 435 "ProbabilityModule.cs"
                    csharp2cuda_temp_56 = ((mathblocks_limit_incomplete_beta_policy()) == (1));
                }
                else
                {
#line 435 "ProbabilityModule.cs"
                    csharp2cuda_temp_56 = false;
                }
                if (csharp2cuda_temp_56)
                {
#line 436 "ProbabilityModule.cs"
                    return false;
                }
            }
            else
#line 439 "ProbabilityModule.cs"
            {
#line 440 "ProbabilityModule.cs"
                return false;
            }
        }
    }
#line 442 "ProbabilityModule.cs"
#line 442 "ProbabilityModule.cs"
    double csharp2cuda_temp_57 = *(value);
    return isfinite(csharp2cuda_temp_57);
}