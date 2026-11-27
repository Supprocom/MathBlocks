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

#line 270 "ProbabilityModule.cs"
__device__ float mathblocks_probability_beta_fraction(float x, float left, float right, bool* converged);

#line 137 "ProbabilityModule.cs"
__device__ float mathblocks_probability_binomial(long long n, int k);

#line 177 "ProbabilityModule.cs"
__device__ float mathblocks_probability_binomial_memo(long long n, int k);

#line 163 "ProbabilityModule.cs"
__device__ float mathblocks_probability_binomial_ordered(long long n, int k);

#line 335 "ProbabilityModule.cs"
__device__ MathBlockComplexValue mathblocks_probability_complex_cube_root(
    MathBlockComplexValue value);

#line 508 "ProbabilityModule.cs"
__device__ void mathblocks_probability_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 193 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_distribution(const float* values, int count);

#line 203 "ProbabilityModule.cs"
__device__ float mathblocks_probability_entropy(const float* values, int count);

#line 314 "ProbabilityModule.cs"
__device__ float mathblocks_probability_incomplete_beta(
    float x,
    float left,
    float right,
    bool* converged);

#line 124 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_integer(float value, int* result);

#line 213 "ProbabilityModule.cs"
__device__ float mathblocks_probability_kl(
    const float* probabilities,
    const float* reference,
    int count);

#line 254 "ProbabilityModule.cs"
__device__ float mathblocks_probability_log_gamma(float value);

#line 227 "ProbabilityModule.cs"
__device__ float mathblocks_probability_log_gamma_core(float value);

#line 348 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_ordered_entropy_value(
    const float* values,
    int count,
    float order,
    bool renyi,
    float* value);

#line 378 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_scalar_value(int opcode, float a, float b, float c, float* value, bool* converged);

#line 270 "ProbabilityModule.cs"
__device__ float mathblocks_probability_beta_fraction(float x, float left, float right, bool* converged)
#line 272 "ProbabilityModule.cs"
{
#line 273 "ProbabilityModule.cs"
    int maximum_iterations = mathblocks_limit_incomplete_beta_maximum_iterations();
#line 274 "ProbabilityModule.cs"
    float tolerance = mathblocks_limit_incomplete_beta_tolerance();
#line 275 "ProbabilityModule.cs"
    const float minimum = 1E-30f;
#line 276 "ProbabilityModule.cs"
#line 276 "ProbabilityModule.cs"
    bool* csharp2cuda_temp_0 = converged;
    (*(csharp2cuda_temp_0) = false);
#line 277 "ProbabilityModule.cs"
    float qab = __fadd_rn(left, right);
#line 278 "ProbabilityModule.cs"
    float qap = __fadd_rn(left, 1.0f);
#line 279 "ProbabilityModule.cs"
    float qam = __fsub_rn(left, 1.0f);
#line 280 "ProbabilityModule.cs"
    float c = 1.0f;
#line 281 "ProbabilityModule.cs"
    float csharp2cuda_temp_1 = __fdiv_rn(__fmul_rn(qab, x), qap);
#line 281 "ProbabilityModule.cs"
    float d = __fsub_rn(1.0f, csharp2cuda_temp_1);
#line 282 "ProbabilityModule.cs"
    if (((fabsf(d)) < (minimum)))
    {
#line 282 "ProbabilityModule.cs"
#line 282 "ProbabilityModule.cs"
        float* csharp2cuda_temp_2 = &(d);
        (*(csharp2cuda_temp_2) = minimum);
    }
#line 283 "ProbabilityModule.cs"
#line 283 "ProbabilityModule.cs"
    float* csharp2cuda_temp_3 = &(d);
#line 283 "ProbabilityModule.cs"
    float csharp2cuda_temp_4 = __fdiv_rn(1.0f, d);
    (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 284 "ProbabilityModule.cs"
    float result = d;
#line 285 "ProbabilityModule.cs"
    {
#line 285 "ProbabilityModule.cs"
        int iteration = 1;
        while (true)
        {
            if (!(((iteration) <= (maximum_iterations))))
                break;
#line 286 "ProbabilityModule.cs"
            {
#line 287 "ProbabilityModule.cs"
                float doubled = __fmul_rn(2.0f, ((float)(iteration)));
#line 288 "ProbabilityModule.cs"
                float coefficient = __fdiv_rn(__fmul_rn(__fmul_rn(((float)(iteration)), __fsub_rn(right, ((float)(iteration)))), x), __fmul_rn(__fadd_rn(qam, doubled), __fadd_rn(left, doubled)));
#line 290 "ProbabilityModule.cs"
#line 290 "ProbabilityModule.cs"
                float* csharp2cuda_temp_6 = &(d);
                (*(csharp2cuda_temp_6) = __fadd_rn(1.0f, __fmul_rn(coefficient, d)));
#line 291 "ProbabilityModule.cs"
                if (((fabsf(d)) < (minimum)))
                {
#line 291 "ProbabilityModule.cs"
#line 291 "ProbabilityModule.cs"
                    float* csharp2cuda_temp_7 = &(d);
                    (*(csharp2cuda_temp_7) = minimum);
                }
#line 292 "ProbabilityModule.cs"
#line 292 "ProbabilityModule.cs"
                float* csharp2cuda_temp_8 = &(c);
#line 292 "ProbabilityModule.cs"
                float csharp2cuda_temp_9 = __fdiv_rn(coefficient, c);
                (*(csharp2cuda_temp_8) = __fadd_rn(1.0f, csharp2cuda_temp_9));
#line 293 "ProbabilityModule.cs"
                if (((fabsf(c)) < (minimum)))
                {
#line 293 "ProbabilityModule.cs"
#line 293 "ProbabilityModule.cs"
                    float* csharp2cuda_temp_10 = &(c);
                    (*(csharp2cuda_temp_10) = minimum);
                }
#line 294 "ProbabilityModule.cs"
#line 294 "ProbabilityModule.cs"
                float* csharp2cuda_temp_11 = &(d);
#line 294 "ProbabilityModule.cs"
                float csharp2cuda_temp_12 = __fdiv_rn(1.0f, d);
                (*(csharp2cuda_temp_11) = csharp2cuda_temp_12);
#line 295 "ProbabilityModule.cs"
#line 295 "ProbabilityModule.cs"
                float* csharp2cuda_temp_13 = &(result);
#line 295 "ProbabilityModule.cs"
                float csharp2cuda_temp_14 = *(csharp2cuda_temp_13);
                (*(csharp2cuda_temp_13) = __fmul_rn(csharp2cuda_temp_14, __fmul_rn(d, c)));
#line 296 "ProbabilityModule.cs"
#line 296 "ProbabilityModule.cs"
                float* csharp2cuda_temp_15 = &(coefficient);
#line 296 "ProbabilityModule.cs"
                float csharp2cuda_temp_16 = __fdiv_rn(__fmul_rn(__fmul_rn((-(__fadd_rn(left, ((float)(iteration))))), __fadd_rn(qab, ((float)(iteration)))), x), __fmul_rn(__fadd_rn(left, doubled), __fadd_rn(qap, doubled)));
                (*(csharp2cuda_temp_15) = csharp2cuda_temp_16);
#line 298 "ProbabilityModule.cs"
#line 298 "ProbabilityModule.cs"
                float* csharp2cuda_temp_17 = &(d);
                (*(csharp2cuda_temp_17) = __fadd_rn(1.0f, __fmul_rn(coefficient, d)));
#line 299 "ProbabilityModule.cs"
                if (((fabsf(d)) < (minimum)))
                {
#line 299 "ProbabilityModule.cs"
#line 299 "ProbabilityModule.cs"
                    float* csharp2cuda_temp_18 = &(d);
                    (*(csharp2cuda_temp_18) = minimum);
                }
#line 300 "ProbabilityModule.cs"
#line 300 "ProbabilityModule.cs"
                float* csharp2cuda_temp_19 = &(c);
#line 300 "ProbabilityModule.cs"
                float csharp2cuda_temp_20 = __fdiv_rn(coefficient, c);
                (*(csharp2cuda_temp_19) = __fadd_rn(1.0f, csharp2cuda_temp_20));
#line 301 "ProbabilityModule.cs"
                if (((fabsf(c)) < (minimum)))
                {
#line 301 "ProbabilityModule.cs"
#line 301 "ProbabilityModule.cs"
                    float* csharp2cuda_temp_21 = &(c);
                    (*(csharp2cuda_temp_21) = minimum);
                }
#line 302 "ProbabilityModule.cs"
#line 302 "ProbabilityModule.cs"
                float* csharp2cuda_temp_22 = &(d);
#line 302 "ProbabilityModule.cs"
                float csharp2cuda_temp_23 = __fdiv_rn(1.0f, d);
                (*(csharp2cuda_temp_22) = csharp2cuda_temp_23);
#line 303 "ProbabilityModule.cs"
                float delta = __fmul_rn(d, c);
#line 304 "ProbabilityModule.cs"
#line 304 "ProbabilityModule.cs"
                float* csharp2cuda_temp_24 = &(result);
#line 304 "ProbabilityModule.cs"
                float csharp2cuda_temp_25 = *(csharp2cuda_temp_24);
                (*(csharp2cuda_temp_24) = __fmul_rn(csharp2cuda_temp_25, delta));
#line 305 "ProbabilityModule.cs"
                if (((fabsf(__fsub_rn(delta, 1.0f))) <= (tolerance)))
#line 306 "ProbabilityModule.cs"
                {
#line 307 "ProbabilityModule.cs"
#line 307 "ProbabilityModule.cs"
                    bool* csharp2cuda_temp_26 = converged;
                    (*(csharp2cuda_temp_26) = true);
#line 308 "ProbabilityModule.cs"
                    break;
                }
            }
#line 285 "ProbabilityModule.cs"
            int* csharp2cuda_temp_5 = &(iteration);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
        }
    }
#line 311 "ProbabilityModule.cs"
    return result;
}

#line 137 "ProbabilityModule.cs"
__device__ float mathblocks_probability_binomial(long long n, int k)
#line 139 "ProbabilityModule.cs"
{
#line 140 "ProbabilityModule.cs"
#line 140 "ProbabilityModule.cs"
    bool csharp2cuda_temp_0;
#line 140 "ProbabilityModule.cs"
    if (!(((k) < (0))))
    {
#line 140 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = ((((long long)(k))) > (n));
    }
    else
    {
#line 140 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 141 "ProbabilityModule.cs"
        return 0.0f;
    }
#line 142 "ProbabilityModule.cs"
    if (((((long long)(k))) > (csharp2cuda_i64_sub(n, ((long long)(k))))))
    {
#line 143 "ProbabilityModule.cs"
#line 143 "ProbabilityModule.cs"
        int* csharp2cuda_temp_1 = &(k);
        (*(csharp2cuda_temp_1) = csharp2cuda_i32_from_bits(csharp2cuda_i64_sub(n, ((long long)(k)))));
    }
#line 144 "ProbabilityModule.cs"
    if (((k) >= (600)))
    {
#line 145 "ProbabilityModule.cs"
        return __int_as_float(2139095040);
    }
#line 146 "ProbabilityModule.cs"
    float result = 1.0f;
#line 147 "ProbabilityModule.cs"
    {
#line 147 "ProbabilityModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) <= (k))))
                break;
#line 148 "ProbabilityModule.cs"
            {
#line 149 "ProbabilityModule.cs"
#line 149 "ProbabilityModule.cs"
                float* csharp2cuda_temp_3 = &(result);
#line 149 "ProbabilityModule.cs"
                float csharp2cuda_temp_4 = __fdiv_rn(__fmul_rn(result, ((float)(csharp2cuda_i64_add(csharp2cuda_i64_sub(n, ((long long)(k))), ((long long)(index)))))), ((float)(index)));
                (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 151 "ProbabilityModule.cs"
                if (isinf(result))
                {
#line 152 "ProbabilityModule.cs"
                    break;
                }
            }
#line 147 "ProbabilityModule.cs"
            int* csharp2cuda_temp_2 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 155 "ProbabilityModule.cs"
    if (isinf(result))
    {
#line 156 "ProbabilityModule.cs"
        return mathblocks_probability_binomial_ordered(n, k);
    }
#line 157 "ProbabilityModule.cs"
    return result;
}

#line 177 "ProbabilityModule.cs"
__device__ float mathblocks_probability_binomial_memo(long long n, int k)
#line 179 "ProbabilityModule.cs"
{
#line 180 "ProbabilityModule.cs"
#line 180 "ProbabilityModule.cs"
    bool csharp2cuda_temp_0;
#line 180 "ProbabilityModule.cs"
    if (!(((k) < (0))))
    {
#line 180 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = ((((long long)(k))) > (n));
    }
    else
    {
#line 180 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 180 "ProbabilityModule.cs"
    bool csharp2cuda_temp_1;
#line 180 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_0))
    {
#line 180 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = ((n) > (((long long)(1023))));
    }
    else
    {
#line 180 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = true;
    }
    if (csharp2cuda_temp_1)
    {
#line 181 "ProbabilityModule.cs"
        return mathblocks_probability_binomial(n, k);
    }
#line 182 "ProbabilityModule.cs"
    int row = csharp2cuda_i32_from_bits(n);
#line 183 "ProbabilityModule.cs"
    int csharp2cuda_temp_2;
#line 183 "ProbabilityModule.cs"
    if (((k) > (csharp2cuda_i32_sub(row, k))))
    {
#line 183 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = csharp2cuda_i32_sub(row, k);
    }
    else
    {
#line 183 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = k;
    }
#line 183 "ProbabilityModule.cs"
    int half = csharp2cuda_temp_2;
#line 184 "ProbabilityModule.cs"
    int csharp2cuda_temp_3 = csharp2cuda_i32_div(row, 2);
#line 184 "ProbabilityModule.cs"
    int csharp2cuda_temp_4 = csharp2cuda_i32_div(csharp2cuda_i32_sub(row, 1), 2);
#line 184 "ProbabilityModule.cs"
    int index = csharp2cuda_i32_add(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_temp_3, csharp2cuda_temp_4), row), half);
#line 185 "ProbabilityModule.cs"
    float entry = mathblocks_binomial_table_load(index);
#line 186 "ProbabilityModule.cs"
    if (((entry) != (0.0f)))
    {
#line 187 "ProbabilityModule.cs"
        return entry;
    }
#line 188 "ProbabilityModule.cs"
#line 188 "ProbabilityModule.cs"
    float* csharp2cuda_temp_5 = &(entry);
    (*(csharp2cuda_temp_5) = mathblocks_probability_binomial(n, k));
#line 189 "ProbabilityModule.cs"
    mathblocks_binomial_table_store(index, entry);
#line 190 "ProbabilityModule.cs"
    return entry;
}

#line 163 "ProbabilityModule.cs"
__device__ float mathblocks_probability_binomial_ordered(long long n, int k)
#line 165 "ProbabilityModule.cs"
{
#line 166 "ProbabilityModule.cs"
    float result = 1.0f;
#line 167 "ProbabilityModule.cs"
    {
#line 167 "ProbabilityModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) <= (k))))
                break;
#line 168 "ProbabilityModule.cs"
#line 168 "ProbabilityModule.cs"
            float* csharp2cuda_temp_1 = &(result);
#line 168 "ProbabilityModule.cs"
            float csharp2cuda_temp_2 = __fdiv_rn(((float)(csharp2cuda_i64_add(csharp2cuda_i64_sub(n, ((long long)(k))), ((long long)(index))))), ((float)(index)));
            (*(csharp2cuda_temp_1) = __fmul_rn(result, csharp2cuda_temp_2));
#line 167 "ProbabilityModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 169 "ProbabilityModule.cs"
    return result;
}

#line 335 "ProbabilityModule.cs"
__device__ MathBlockComplexValue mathblocks_probability_complex_cube_root(
    MathBlockComplexValue value)
#line 338 "ProbabilityModule.cs"
{
#line 339 "ProbabilityModule.cs"
#line 339 "ProbabilityModule.cs"
    float csharp2cuda_temp_0 = (value).real;
#line 339 "ProbabilityModule.cs"
    bool csharp2cuda_temp_1;
#line 339 "ProbabilityModule.cs"
    if (((csharp2cuda_temp_0) == (0.0f)))
    {
#line 339 "ProbabilityModule.cs"
        float csharp2cuda_temp_2 = (value).imaginary;
#line 339 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) == (0.0f));
    }
    else
    {
#line 339 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = false;
    }
    if (csharp2cuda_temp_1)
    {
#line 340 "ProbabilityModule.cs"
        return mathblocks_complex_make(0.0f, 0.0f);
    }
#line 341 "ProbabilityModule.cs"
#line 343 "ProbabilityModule.cs"
    float csharp2cuda_temp_3 = __fdiv_rn(mathblocks_complex_phase(value), 3.0f);
    return mathblocks_complex_from_polar(mathblocks_cube_root(mathblocks_complex_magnitude(value)), csharp2cuda_temp_3);
}

#line 508 "ProbabilityModule.cs"
__device__ void mathblocks_probability_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 514 "ProbabilityModule.cs"
{
#line 515 "ProbabilityModule.cs"
    int thread = threadIdx.x;
#line 516 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 516 "ProbabilityModule.cs"
    if (((input_count) > (0)))
    {
#line 516 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 516 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 516 "ProbabilityModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 517 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 517 "ProbabilityModule.cs"
    if (((input_count) > (1)))
    {
#line 517 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 517 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 517 "ProbabilityModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 518 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 518 "ProbabilityModule.cs"
    if (((input_count) > (2)))
    {
#line 518 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 518 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 518 "ProbabilityModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 519 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_3;
#line 519 "ProbabilityModule.cs"
    if (((input_count) > (3)))
    {
#line 519 "ProbabilityModule.cs"
        csharp2cuda_temp_3 = (inputs)[3];
    }
    else
    {
#line 519 "ProbabilityModule.cs"
        csharp2cuda_temp_3 = ((MathBlockSlot*)(nullptr));
    }
#line 519 "ProbabilityModule.cs"
    const MathBlockSlot* fourth = csharp2cuda_temp_3;
#line 520 "ProbabilityModule.cs"
    if (((thread) == (0)))
#line 521 "ProbabilityModule.cs"
    {
#line 522 "ProbabilityModule.cs"
#line 522 "ProbabilityModule.cs"
        float* csharp2cuda_temp_4 = &((output)->scalar_value);
        (*(csharp2cuda_temp_4) = 0.0f);
#line 523 "ProbabilityModule.cs"
#line 523 "ProbabilityModule.cs"
        int* csharp2cuda_temp_5 = &((output)->boolean_value);
        (*(csharp2cuda_temp_5) = 0);
#line 524 "ProbabilityModule.cs"
#line 524 "ProbabilityModule.cs"
        int* csharp2cuda_temp_6 = &((output)->rows);
        (*(csharp2cuda_temp_6) = 0);
#line 525 "ProbabilityModule.cs"
#line 525 "ProbabilityModule.cs"
        int* csharp2cuda_temp_7 = &((output)->columns);
        (*(csharp2cuda_temp_7) = 0);
#line 526 "ProbabilityModule.cs"
#line 526 "ProbabilityModule.cs"
        int* csharp2cuda_temp_8 = &((output)->count);
        (*(csharp2cuda_temp_8) = 0);
#line 527 "ProbabilityModule.cs"
#line 527 "ProbabilityModule.cs"
        int* csharp2cuda_temp_9 = &((output)->valid);
        (*(csharp2cuda_temp_9) = 1);
#line 528 "ProbabilityModule.cs"
        {
#line 528 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 529 "ProbabilityModule.cs"
#line 529 "ProbabilityModule.cs"
                MathBlockSlot* csharp2cuda_temp_11 = (inputs)[index];
#line 529 "ProbabilityModule.cs"
                bool csharp2cuda_temp_12;
#line 529 "ProbabilityModule.cs"
                if (!(((((void*)(csharp2cuda_temp_11))) == (((void*)(nullptr))))))
                {
#line 529 "ProbabilityModule.cs"
                    MathBlockSlot* csharp2cuda_temp_13 = (inputs)[index];
#line 529 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_14 = (csharp2cuda_temp_13)->valid;
#line 529 "ProbabilityModule.cs"
                    csharp2cuda_temp_12 = (!(csharp2cuda_temp_14));
                }
                else
                {
#line 529 "ProbabilityModule.cs"
                    csharp2cuda_temp_12 = true;
                }
                if (csharp2cuda_temp_12)
                {
#line 529 "ProbabilityModule.cs"
#line 529 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_15 = &((output)->valid);
                    (*(csharp2cuda_temp_15) = 0);
                }
#line 528 "ProbabilityModule.cs"
                int* csharp2cuda_temp_10 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_10));
            }
        }
    }
#line 531 "ProbabilityModule.cs"
    __syncthreads();
#line 532 "ProbabilityModule.cs"
#line 532 "ProbabilityModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 533 "ProbabilityModule.cs"
        return;
    }
#line 535 "ProbabilityModule.cs"
    float* csharp2cuda_temp_17;
#line 535 "ProbabilityModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 535 "ProbabilityModule.cs"
        csharp2cuda_temp_17 = ((float*)(nullptr));
    }
    else
    {
#line 535 "ProbabilityModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 535 "ProbabilityModule.cs"
        csharp2cuda_temp_17 = ((float*)(csharp2cuda_temp_18));
    }
#line 535 "ProbabilityModule.cs"
    const float* a = csharp2cuda_temp_17;
#line 536 "ProbabilityModule.cs"
    float* csharp2cuda_temp_19;
#line 536 "ProbabilityModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 536 "ProbabilityModule.cs"
        csharp2cuda_temp_19 = ((float*)(nullptr));
    }
    else
    {
#line 536 "ProbabilityModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 536 "ProbabilityModule.cs"
        csharp2cuda_temp_19 = ((float*)(csharp2cuda_temp_20));
    }
#line 536 "ProbabilityModule.cs"
    const float* b = csharp2cuda_temp_19;
#line 537 "ProbabilityModule.cs"
    unsigned long long csharp2cuda_temp_21 = (output)->data_pointer;
#line 537 "ProbabilityModule.cs"
    float* result = ((float*)(csharp2cuda_temp_21));
#line 538 "ProbabilityModule.cs"
    unsigned long long csharp2cuda_temp_22 = (output)->scratch_pointer;
#line 538 "ProbabilityModule.cs"
    float* scratch = ((float*)(csharp2cuda_temp_22));
#line 540 "ProbabilityModule.cs"
    if (((opcode) == (3)))
#line 541 "ProbabilityModule.cs"
    {
#line 543 "ProbabilityModule.cs"
#line 543 "ProbabilityModule.cs"
        int csharp2cuda_temp_23 = (first)->count;
        if (((csharp2cuda_temp_23) > (mathblocks_limit_explicit_subset_size())))
#line 544 "ProbabilityModule.cs"
        {
#line 545 "ProbabilityModule.cs"
            if (((thread) == (0)))
            {
#line 546 "ProbabilityModule.cs"
#line 546 "ProbabilityModule.cs"
                int* csharp2cuda_temp_24 = &((output)->valid);
                (*(csharp2cuda_temp_24) = 0);
            }
#line 547 "ProbabilityModule.cs"
            return;
        }
#line 549 "ProbabilityModule.cs"
        if (((thread) == (0)))
        {
#line 550 "ProbabilityModule.cs"
#line 550 "ProbabilityModule.cs"
            int csharp2cuda_temp_25 = (first)->count;
            mathblocks_set_vector_shape(output, csharp2cuda_i32_sub(csharp2cuda_i32_shl(1, csharp2cuda_temp_25), 1));
        }
#line 551 "ProbabilityModule.cs"
        __syncthreads();
#line 552 "ProbabilityModule.cs"
        {
#line 552 "ProbabilityModule.cs"
            int mask = csharp2cuda_i32_add(thread, 1);
            while (true)
            {
#line 552 "ProbabilityModule.cs"
                bool csharp2cuda_temp_28 = (output)->valid;
#line 552 "ProbabilityModule.cs"
                bool csharp2cuda_temp_29;
#line 552 "ProbabilityModule.cs"
                if (csharp2cuda_temp_28)
                {
#line 552 "ProbabilityModule.cs"
                    int csharp2cuda_temp_30 = (output)->count;
#line 552 "ProbabilityModule.cs"
                    csharp2cuda_temp_29 = ((mask) <= (csharp2cuda_temp_30));
                }
                else
                {
#line 552 "ProbabilityModule.cs"
                    csharp2cuda_temp_29 = false;
                }
                if (!(csharp2cuda_temp_29))
                    break;
#line 553 "ProbabilityModule.cs"
                {
#line 554 "ProbabilityModule.cs"
                    float sum = 0.0f;
#line 555 "ProbabilityModule.cs"
                    {
#line 555 "ProbabilityModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 555 "ProbabilityModule.cs"
                            int csharp2cuda_temp_32 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_32))))
                                break;
#line 556 "ProbabilityModule.cs"
                            if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, index))) != (0)))
                            {
#line 556 "ProbabilityModule.cs"
#line 556 "ProbabilityModule.cs"
                                float* csharp2cuda_temp_33 = &(sum);
#line 556 "ProbabilityModule.cs"
                                float csharp2cuda_temp_34 = *(csharp2cuda_temp_33);
#line 556 "ProbabilityModule.cs"
                                float csharp2cuda_temp_35 = (a)[index];
                                (*(csharp2cuda_temp_33) = __fadd_rn(csharp2cuda_temp_34, csharp2cuda_temp_35));
                            }
#line 555 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_31 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                        }
                    }
#line 557 "ProbabilityModule.cs"
#line 557 "ProbabilityModule.cs"
                    float* csharp2cuda_temp_36 = &((result)[csharp2cuda_i32_sub(mask, 1)]);
                    (*(csharp2cuda_temp_36) = sum);
#line 558 "ProbabilityModule.cs"
                    if ((!(isfinite(sum))))
                    {
#line 558 "ProbabilityModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 552 "ProbabilityModule.cs"
                int* csharp2cuda_temp_26 = &(mask);
#line 552 "ProbabilityModule.cs"
                int csharp2cuda_temp_27 = *(csharp2cuda_temp_26);
                (*(csharp2cuda_temp_26) = csharp2cuda_i32_add(csharp2cuda_temp_27, blockDim.x));
            }
        }
#line 560 "ProbabilityModule.cs"
        return;
    }
#line 563 "ProbabilityModule.cs"
    if (((opcode) == (19)))
#line 564 "ProbabilityModule.cs"
    {
#line 565 "ProbabilityModule.cs"
        int csharp2cuda_temp_37 = (first)->count;
#line 565 "ProbabilityModule.cs"
        int csharp2cuda_temp_38;
#line 565 "ProbabilityModule.cs"
        if (((csharp2cuda_temp_37) <= (1)))
        {
#line 565 "ProbabilityModule.cs"
            csharp2cuda_temp_38 = 1;
        }
        else
        {
#line 565 "ProbabilityModule.cs"
            int csharp2cuda_temp_39 = (first)->count;
#line 565 "ProbabilityModule.cs"
            csharp2cuda_temp_38 = csharp2cuda_i32_sub(csharp2cuda_temp_39, 1);
        }
#line 565 "ProbabilityModule.cs"
        int count = csharp2cuda_temp_38;
#line 566 "ProbabilityModule.cs"
        if (((thread) == (0)))
        {
#line 566 "ProbabilityModule.cs"
            mathblocks_set_vector_shape(output, count);
        }
#line 567 "ProbabilityModule.cs"
        __syncthreads();
#line 568 "ProbabilityModule.cs"
#line 568 "ProbabilityModule.cs"
        int csharp2cuda_temp_40 = (first)->count;
        if (((csharp2cuda_temp_40) <= (1)))
#line 569 "ProbabilityModule.cs"
        {
#line 570 "ProbabilityModule.cs"
            if (((thread) == (0)))
            {
#line 570 "ProbabilityModule.cs"
#line 570 "ProbabilityModule.cs"
                float* csharp2cuda_temp_41 = &((result)[0]);
                (*(csharp2cuda_temp_41) = 0.0f);
            }
        }
        else
#line 573 "ProbabilityModule.cs"
        {
#line 574 "ProbabilityModule.cs"
            {
#line 574 "ProbabilityModule.cs"
                int index = csharp2cuda_i32_add(thread, 1);
                while (true)
                {
#line 574 "ProbabilityModule.cs"
                    int csharp2cuda_temp_44 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_44))))
                        break;
#line 575 "ProbabilityModule.cs"
                    {
#line 576 "ProbabilityModule.cs"
#line 576 "ProbabilityModule.cs"
                        float* csharp2cuda_temp_45 = &((result)[csharp2cuda_i32_sub(index, 1)]);
#line 576 "ProbabilityModule.cs"
                        float csharp2cuda_temp_46 = (a)[index];
                        (*(csharp2cuda_temp_45) = __fmul_rn(((float)(index)), csharp2cuda_temp_46));
#line 577 "ProbabilityModule.cs"
#line 577 "ProbabilityModule.cs"
                        float csharp2cuda_temp_47 = (result)[csharp2cuda_i32_sub(index, 1)];
                        if ((!(isfinite(csharp2cuda_temp_47))))
                        {
#line 577 "ProbabilityModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 574 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_42 = &(index);
#line 574 "ProbabilityModule.cs"
                    int csharp2cuda_temp_43 = *(csharp2cuda_temp_42);
                    (*(csharp2cuda_temp_42) = csharp2cuda_i32_add(csharp2cuda_temp_43, blockDim.x));
                }
            }
        }
#line 580 "ProbabilityModule.cs"
        return;
    }
#line 583 "ProbabilityModule.cs"
#line 583 "ProbabilityModule.cs"
    bool csharp2cuda_temp_48;
#line 583 "ProbabilityModule.cs"
    if (!(((opcode) == (24))))
    {
#line 583 "ProbabilityModule.cs"
        csharp2cuda_temp_48 = ((opcode) == (27));
    }
    else
    {
#line 583 "ProbabilityModule.cs"
        csharp2cuda_temp_48 = true;
    }
    if (csharp2cuda_temp_48)
#line 584 "ProbabilityModule.cs"
    {
#line 585 "ProbabilityModule.cs"
        if (((thread) == (0)))
#line 586 "ProbabilityModule.cs"
        {
#line 587 "ProbabilityModule.cs"
#line 587 "ProbabilityModule.cs"
            int csharp2cuda_temp_49 = (first)->count;
            if (((csharp2cuda_temp_49) <= (0)))
#line 588 "ProbabilityModule.cs"
            {
#line 589 "ProbabilityModule.cs"
#line 589 "ProbabilityModule.cs"
                int* csharp2cuda_temp_50 = &((output)->valid);
                (*(csharp2cuda_temp_50) = 0);
#line 590 "ProbabilityModule.cs"
                return;
            }
#line 592 "ProbabilityModule.cs"
            {
#line 592 "ProbabilityModule.cs"
                int index = 0;
                while (true)
                {
#line 592 "ProbabilityModule.cs"
                    int csharp2cuda_temp_52 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_52))))
                        break;
#line 593 "ProbabilityModule.cs"
#line 593 "ProbabilityModule.cs"
                    float csharp2cuda_temp_53 = (a)[index];
                    if (((csharp2cuda_temp_53) < (0.0f)))
                    {
#line 593 "ProbabilityModule.cs"
#line 593 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_54 = &((output)->valid);
                        (*(csharp2cuda_temp_54) = 0);
                    }
#line 592 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_51 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_51));
                }
            }
#line 594 "ProbabilityModule.cs"
#line 594 "ProbabilityModule.cs"
            int csharp2cuda_temp_55 = (first)->count;
            mathblocks_set_vector_shape(output, csharp2cuda_temp_55);
#line 595 "ProbabilityModule.cs"
            if (((opcode) == (24)))
#line 596 "ProbabilityModule.cs"
            {
#line 597 "ProbabilityModule.cs"
                int csharp2cuda_temp_56 = (first)->count;
#line 597 "ProbabilityModule.cs"
                float total = mathblocks_compensated_sum(a, csharp2cuda_temp_56);
#line 598 "ProbabilityModule.cs"
                {
#line 598 "ProbabilityModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 598 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_58 = (output)->valid;
#line 598 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_59;
#line 598 "ProbabilityModule.cs"
                        if (csharp2cuda_temp_58)
                        {
#line 598 "ProbabilityModule.cs"
                            int csharp2cuda_temp_60 = (first)->count;
#line 598 "ProbabilityModule.cs"
                            csharp2cuda_temp_59 = ((index) < (csharp2cuda_temp_60));
                        }
                        else
                        {
#line 598 "ProbabilityModule.cs"
                            csharp2cuda_temp_59 = false;
                        }
                        if (!(csharp2cuda_temp_59))
                            break;
#line 599 "ProbabilityModule.cs"
#line 599 "ProbabilityModule.cs"
                        float* csharp2cuda_temp_61 = &((result)[index]);
#line 599 "ProbabilityModule.cs"
                        float csharp2cuda_temp_62 = (a)[index];
#line 599 "ProbabilityModule.cs"
                        float csharp2cuda_temp_63 = __fdiv_rn(1.0f, total);
                        (*(csharp2cuda_temp_61) = __fmul_rn(csharp2cuda_temp_62, csharp2cuda_temp_63));
#line 598 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_57 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_57));
                    }
                }
            }
            else
#line 602 "ProbabilityModule.cs"
            {
#line 603 "ProbabilityModule.cs"
                float maximum = (a)[0];
#line 604 "ProbabilityModule.cs"
                {
#line 604 "ProbabilityModule.cs"
                    int index = 1;
                    while (true)
                    {
#line 604 "ProbabilityModule.cs"
                        int csharp2cuda_temp_65 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_65))))
                            break;
#line 605 "ProbabilityModule.cs"
#line 605 "ProbabilityModule.cs"
                        float* csharp2cuda_temp_66 = &(maximum);
#line 605 "ProbabilityModule.cs"
                        float csharp2cuda_temp_67 = (a)[index];
                        (*(csharp2cuda_temp_66) = mathblocks_maximum(maximum, csharp2cuda_temp_67));
#line 604 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_64 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_64));
                    }
                }
#line 606 "ProbabilityModule.cs"
                {
#line 606 "ProbabilityModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 606 "ProbabilityModule.cs"
                        int csharp2cuda_temp_69 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_69))))
                            break;
#line 607 "ProbabilityModule.cs"
#line 607 "ProbabilityModule.cs"
                        float* csharp2cuda_temp_70 = &((result)[index]);
#line 607 "ProbabilityModule.cs"
                        float csharp2cuda_temp_71 = (a)[index];
                        (*(csharp2cuda_temp_70) = mathblocks_exponential(__fsub_rn(csharp2cuda_temp_71, maximum)));
#line 606 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_68 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_68));
                    }
                }
#line 608 "ProbabilityModule.cs"
                int csharp2cuda_temp_72 = (first)->count;
#line 608 "ProbabilityModule.cs"
                float total = mathblocks_compensated_sum(result, csharp2cuda_temp_72);
#line 609 "ProbabilityModule.cs"
                float scale = __fdiv_rn(1.0f, total);
#line 610 "ProbabilityModule.cs"
                {
#line 610 "ProbabilityModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 610 "ProbabilityModule.cs"
                        int csharp2cuda_temp_74 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_74))))
                            break;
#line 611 "ProbabilityModule.cs"
#line 611 "ProbabilityModule.cs"
                        float* csharp2cuda_temp_75 = &((result)[index]);
#line 611 "ProbabilityModule.cs"
                        float csharp2cuda_temp_76 = *(csharp2cuda_temp_75);
                        (*(csharp2cuda_temp_75) = __fmul_rn(csharp2cuda_temp_76, scale));
#line 610 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_73 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_73));
                    }
                }
            }
#line 613 "ProbabilityModule.cs"
            {
#line 613 "ProbabilityModule.cs"
                int index = 0;
                while (true)
                {
#line 613 "ProbabilityModule.cs"
                    int csharp2cuda_temp_78 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_78))))
                        break;
#line 614 "ProbabilityModule.cs"
#line 614 "ProbabilityModule.cs"
                    float csharp2cuda_temp_79 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_79))))
                    {
#line 614 "ProbabilityModule.cs"
#line 614 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_80 = &((output)->valid);
                        (*(csharp2cuda_temp_80) = 0);
                    }
#line 613 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_77 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_77));
                }
            }
        }
#line 616 "ProbabilityModule.cs"
        return;
    }
#line 619 "ProbabilityModule.cs"
    if (((thread) != (0)))
    {
#line 620 "ProbabilityModule.cs"
        return;
    }
#line 622 "ProbabilityModule.cs"
#line 622 "ProbabilityModule.cs"
    bool csharp2cuda_temp_81;
#line 622 "ProbabilityModule.cs"
    if (!(((opcode) == (0))))
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_81 = ((opcode) == (1));
    }
    else
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_81 = true;
    }
#line 622 "ProbabilityModule.cs"
    bool csharp2cuda_temp_82;
#line 622 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_81))
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_82 = ((opcode) == (2));
    }
    else
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_82 = true;
    }
#line 622 "ProbabilityModule.cs"
    bool csharp2cuda_temp_83;
#line 622 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_82))
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_83 = ((opcode) == (23));
    }
    else
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_83 = true;
    }
#line 622 "ProbabilityModule.cs"
    bool csharp2cuda_temp_84;
#line 622 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_83))
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_84 = ((opcode) == (25));
    }
    else
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_84 = true;
    }
#line 622 "ProbabilityModule.cs"
    bool csharp2cuda_temp_85;
#line 622 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_84))
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_85 = ((opcode) == (26));
    }
    else
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_85 = true;
    }
#line 622 "ProbabilityModule.cs"
    bool csharp2cuda_temp_86;
#line 622 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_85))
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_86 = ((opcode) == (28));
    }
    else
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_86 = true;
    }
#line 622 "ProbabilityModule.cs"
    bool csharp2cuda_temp_87;
#line 622 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_86))
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_87 = ((opcode) == (29));
    }
    else
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_87 = true;
    }
#line 622 "ProbabilityModule.cs"
    bool csharp2cuda_temp_88;
#line 622 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_87))
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_88 = ((opcode) == (30));
    }
    else
    {
#line 622 "ProbabilityModule.cs"
        csharp2cuda_temp_88 = true;
    }
    if (csharp2cuda_temp_88)
#line 624 "ProbabilityModule.cs"
    {
#line 625 "ProbabilityModule.cs"
        float value = 0.0f;
#line 626 "ProbabilityModule.cs"
        bool converged = true;
#line 629 "ProbabilityModule.cs"
        float csharp2cuda_temp_89;
#line 629 "ProbabilityModule.cs"
        if (((((void*)(first))) == (((void*)(nullptr)))))
        {
#line 629 "ProbabilityModule.cs"
            csharp2cuda_temp_89 = 0.0f;
        }
        else
        {
#line 629 "ProbabilityModule.cs"
            csharp2cuda_temp_89 = (first)->scalar_value;
        }
#line 630 "ProbabilityModule.cs"
        float csharp2cuda_temp_90;
#line 630 "ProbabilityModule.cs"
        if (((((void*)(second))) == (((void*)(nullptr)))))
        {
#line 630 "ProbabilityModule.cs"
            csharp2cuda_temp_90 = 0.0f;
        }
        else
        {
#line 630 "ProbabilityModule.cs"
            csharp2cuda_temp_90 = (second)->scalar_value;
        }
#line 631 "ProbabilityModule.cs"
        float csharp2cuda_temp_91;
#line 631 "ProbabilityModule.cs"
        if (((((void*)(third))) == (((void*)(nullptr)))))
        {
#line 631 "ProbabilityModule.cs"
            csharp2cuda_temp_91 = 0.0f;
        }
        else
        {
#line 631 "ProbabilityModule.cs"
            csharp2cuda_temp_91 = (third)->scalar_value;
        }
#line 632 "ProbabilityModule.cs"
        float* csharp2cuda_temp_92 = &(value);
#line 633 "ProbabilityModule.cs"
        bool* csharp2cuda_temp_93 = &(converged);
#line 627 "ProbabilityModule.cs"
        bool valid = mathblocks_probability_scalar_value(opcode, csharp2cuda_temp_89, csharp2cuda_temp_90, csharp2cuda_temp_91, csharp2cuda_temp_92, csharp2cuda_temp_93);
#line 634 "ProbabilityModule.cs"
        if ((!(converged)))
        {
#line 634 "ProbabilityModule.cs"
            mathblocks_nonconvergence_record_probability(opcode);
        }
#line 635 "ProbabilityModule.cs"
#line 635 "ProbabilityModule.cs"
        float* csharp2cuda_temp_94 = &((output)->scalar_value);
        (*(csharp2cuda_temp_94) = value);
#line 636 "ProbabilityModule.cs"
        if ((!(valid)))
        {
#line 636 "ProbabilityModule.cs"
#line 636 "ProbabilityModule.cs"
            int* csharp2cuda_temp_95 = &((output)->valid);
            (*(csharp2cuda_temp_95) = 0);
        }
#line 637 "ProbabilityModule.cs"
        return;
    }
#line 640 "ProbabilityModule.cs"
#line 640 "ProbabilityModule.cs"
    bool csharp2cuda_temp_96;
#line 640 "ProbabilityModule.cs"
    if (((opcode) >= (4)))
    {
#line 640 "ProbabilityModule.cs"
        csharp2cuda_temp_96 = ((opcode) <= (16));
    }
    else
    {
#line 640 "ProbabilityModule.cs"
        csharp2cuda_temp_96 = false;
    }
    if (csharp2cuda_temp_96)
#line 641 "ProbabilityModule.cs"
    {
#line 642 "ProbabilityModule.cs"
        bool csharp2cuda_temp_97;
#line 642 "ProbabilityModule.cs"
        if (((opcode) == (12)))
        {
#line 643 "ProbabilityModule.cs"
            int csharp2cuda_temp_98 = (first)->count;
#line 642 "ProbabilityModule.cs"
            csharp2cuda_temp_97 = mathblocks_probability_distribution(a, csharp2cuda_temp_98);
        }
        else
        {
#line 644 "ProbabilityModule.cs"
            int csharp2cuda_temp_99 = (first)->count;
#line 642 "ProbabilityModule.cs"
            csharp2cuda_temp_97 = mathblocks_probability_distribution(a, csharp2cuda_temp_99);
        }
#line 642 "ProbabilityModule.cs"
        bool first_distribution = csharp2cuda_temp_97;
#line 645 "ProbabilityModule.cs"
        bool csharp2cuda_temp_100;
#line 645 "ProbabilityModule.cs"
        if (!(((opcode) == (4))))
        {
#line 645 "ProbabilityModule.cs"
            csharp2cuda_temp_100 = ((opcode) == (7));
        }
        else
        {
#line 645 "ProbabilityModule.cs"
            csharp2cuda_temp_100 = true;
        }
#line 645 "ProbabilityModule.cs"
        bool csharp2cuda_temp_101;
#line 645 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_100))
        {
#line 645 "ProbabilityModule.cs"
            csharp2cuda_temp_101 = ((opcode) == (9));
        }
        else
        {
#line 645 "ProbabilityModule.cs"
            csharp2cuda_temp_101 = true;
        }
#line 645 "ProbabilityModule.cs"
        bool csharp2cuda_temp_102;
#line 645 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_101))
        {
#line 645 "ProbabilityModule.cs"
            csharp2cuda_temp_102 = ((opcode) == (10));
        }
        else
        {
#line 645 "ProbabilityModule.cs"
            csharp2cuda_temp_102 = true;
        }
#line 645 "ProbabilityModule.cs"
        bool csharp2cuda_temp_103;
#line 645 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_102))
        {
#line 645 "ProbabilityModule.cs"
            csharp2cuda_temp_103 = ((opcode) == (11));
        }
        else
        {
#line 645 "ProbabilityModule.cs"
            csharp2cuda_temp_103 = true;
        }
#line 645 "ProbabilityModule.cs"
        bool csharp2cuda_temp_104;
#line 645 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_103))
        {
#line 645 "ProbabilityModule.cs"
            csharp2cuda_temp_104 = ((opcode) == (15));
        }
        else
        {
#line 645 "ProbabilityModule.cs"
            csharp2cuda_temp_104 = true;
        }
#line 645 "ProbabilityModule.cs"
        bool pair = csharp2cuda_temp_104;
#line 647 "ProbabilityModule.cs"
#line 647 "ProbabilityModule.cs"
        bool csharp2cuda_temp_105;
#line 647 "ProbabilityModule.cs"
        if (!((!(first_distribution))))
        {
#line 647 "ProbabilityModule.cs"
            bool csharp2cuda_temp_106;
#line 647 "ProbabilityModule.cs"
            if (pair)
            {
#line 648 "ProbabilityModule.cs"
                int csharp2cuda_temp_107 = (first)->count;
#line 648 "ProbabilityModule.cs"
                int csharp2cuda_temp_108 = (second)->count;
#line 648 "ProbabilityModule.cs"
                bool csharp2cuda_temp_109;
#line 648 "ProbabilityModule.cs"
                if (!(((csharp2cuda_temp_107) != (csharp2cuda_temp_108))))
                {
#line 648 "ProbabilityModule.cs"
                    int csharp2cuda_temp_110 = (second)->count;
#line 648 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_111 = mathblocks_probability_distribution(b, csharp2cuda_temp_110);
#line 648 "ProbabilityModule.cs"
                    csharp2cuda_temp_109 = (!(csharp2cuda_temp_111));
                }
                else
                {
#line 648 "ProbabilityModule.cs"
                    csharp2cuda_temp_109 = true;
                }
#line 647 "ProbabilityModule.cs"
                csharp2cuda_temp_106 = csharp2cuda_temp_109;
            }
            else
            {
#line 647 "ProbabilityModule.cs"
                csharp2cuda_temp_106 = false;
            }
#line 647 "ProbabilityModule.cs"
            csharp2cuda_temp_105 = csharp2cuda_temp_106;
        }
        else
        {
#line 647 "ProbabilityModule.cs"
            csharp2cuda_temp_105 = true;
        }
        if (csharp2cuda_temp_105)
#line 649 "ProbabilityModule.cs"
        {
#line 650 "ProbabilityModule.cs"
#line 650 "ProbabilityModule.cs"
            int* csharp2cuda_temp_112 = &((output)->valid);
            (*(csharp2cuda_temp_112) = 0);
#line 651 "ProbabilityModule.cs"
            return;
        }
#line 653 "ProbabilityModule.cs"
        float value = 0.0f;
#line 654 "ProbabilityModule.cs"
        if (((opcode) == (4)))
#line 655 "ProbabilityModule.cs"
        {
#line 656 "ProbabilityModule.cs"
            {
#line 656 "ProbabilityModule.cs"
                int index = 0;
                while (true)
                {
#line 656 "ProbabilityModule.cs"
                    int csharp2cuda_temp_114 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_114))))
                        break;
#line 657 "ProbabilityModule.cs"
#line 657 "ProbabilityModule.cs"
                    float* csharp2cuda_temp_115 = &(value);
#line 657 "ProbabilityModule.cs"
                    float csharp2cuda_temp_116 = *(csharp2cuda_temp_115);
#line 657 "ProbabilityModule.cs"
                    float csharp2cuda_temp_117 = (a)[index];
#line 657 "ProbabilityModule.cs"
                    float csharp2cuda_temp_118 = (b)[index];
                    (*(csharp2cuda_temp_115) = __fadd_rn(csharp2cuda_temp_116, mathblocks_square_root(__fmul_rn(csharp2cuda_temp_117, csharp2cuda_temp_118))));
#line 656 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_113 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_113));
                }
            }
        }
        else
        {
#line 659 "ProbabilityModule.cs"
            if (((opcode) == (5)))
#line 660 "ProbabilityModule.cs"
            {
#line 661 "ProbabilityModule.cs"
#line 661 "ProbabilityModule.cs"
                float* csharp2cuda_temp_119 = &(value);
#line 661 "ProbabilityModule.cs"
                int csharp2cuda_temp_120 = (first)->count;
#line 661 "ProbabilityModule.cs"
                float csharp2cuda_temp_121 = mathblocks_probability_entropy(a, csharp2cuda_temp_120);
#line 661 "ProbabilityModule.cs"
                float csharp2cuda_temp_122 = __fdiv_rn(csharp2cuda_temp_121, mathblocks_natural_logarithm(2.0f));
                (*(csharp2cuda_temp_119) = csharp2cuda_temp_122);
            }
            else
            {
#line 664 "ProbabilityModule.cs"
                if (((opcode) == (6)))
#line 665 "ProbabilityModule.cs"
                {
#line 666 "ProbabilityModule.cs"
                    int first_count = 0;
#line 667 "ProbabilityModule.cs"
                    int second_count = 0;
#line 668 "ProbabilityModule.cs"
                    int condition_count = 0;
#line 669 "ProbabilityModule.cs"
#line 669 "ProbabilityModule.cs"
                    float csharp2cuda_temp_123 = (second)->scalar_value;
#line 669 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_124 = &(first_count);
#line 669 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_125 = mathblocks_probability_integer(csharp2cuda_temp_123, csharp2cuda_temp_124);
#line 669 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_126;
#line 669 "ProbabilityModule.cs"
                    if (!((!(csharp2cuda_temp_125))))
                    {
#line 669 "ProbabilityModule.cs"
                        csharp2cuda_temp_126 = ((first_count) <= (0));
                    }
                    else
                    {
#line 669 "ProbabilityModule.cs"
                        csharp2cuda_temp_126 = true;
                    }
#line 669 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_127;
#line 669 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_126))
                    {
#line 670 "ProbabilityModule.cs"
                        float csharp2cuda_temp_128 = (third)->scalar_value;
#line 670 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_129 = &(second_count);
#line 670 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_130 = mathblocks_probability_integer(csharp2cuda_temp_128, csharp2cuda_temp_129);
#line 669 "ProbabilityModule.cs"
                        csharp2cuda_temp_127 = (!(csharp2cuda_temp_130));
                    }
                    else
                    {
#line 669 "ProbabilityModule.cs"
                        csharp2cuda_temp_127 = true;
                    }
#line 669 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_131;
#line 669 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_127))
                    {
#line 669 "ProbabilityModule.cs"
                        csharp2cuda_temp_131 = ((second_count) <= (0));
                    }
                    else
                    {
#line 669 "ProbabilityModule.cs"
                        csharp2cuda_temp_131 = true;
                    }
#line 669 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_132;
#line 669 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_131))
                    {
#line 671 "ProbabilityModule.cs"
                        float csharp2cuda_temp_133 = (fourth)->scalar_value;
#line 671 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_134 = &(condition_count);
#line 671 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_135 = mathblocks_probability_integer(csharp2cuda_temp_133, csharp2cuda_temp_134);
#line 669 "ProbabilityModule.cs"
                        csharp2cuda_temp_132 = (!(csharp2cuda_temp_135));
                    }
                    else
                    {
#line 669 "ProbabilityModule.cs"
                        csharp2cuda_temp_132 = true;
                    }
#line 669 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_136;
#line 669 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_132))
                    {
#line 669 "ProbabilityModule.cs"
                        csharp2cuda_temp_136 = ((condition_count) <= (0));
                    }
                    else
                    {
#line 669 "ProbabilityModule.cs"
                        csharp2cuda_temp_136 = true;
                    }
#line 669 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_137;
#line 669 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_136))
                    {
#line 672 "ProbabilityModule.cs"
                        int csharp2cuda_temp_138 = (first)->count;
#line 669 "ProbabilityModule.cs"
                        csharp2cuda_temp_137 = ((csharp2cuda_i64_mul(csharp2cuda_i64_mul(((long long)(first_count)), ((long long)(second_count))), ((long long)(condition_count)))) != (((long long)(csharp2cuda_temp_138))));
                    }
                    else
                    {
#line 669 "ProbabilityModule.cs"
                        csharp2cuda_temp_137 = true;
                    }
#line 669 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_139;
#line 669 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_137))
                    {
#line 669 "ProbabilityModule.cs"
                        csharp2cuda_temp_139 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 669 "ProbabilityModule.cs"
                        csharp2cuda_temp_139 = true;
                    }
                    if (csharp2cuda_temp_139)
#line 673 "ProbabilityModule.cs"
                    {
#line 674 "ProbabilityModule.cs"
#line 674 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_140 = &((output)->valid);
                        (*(csharp2cuda_temp_140) = 0);
#line 675 "ProbabilityModule.cs"
                        return;
                    }
#line 677 "ProbabilityModule.cs"
                    int first_condition_count = csharp2cuda_i32_mul(first_count, condition_count);
#line 678 "ProbabilityModule.cs"
                    int second_condition_count = csharp2cuda_i32_mul(second_count, condition_count);
#line 679 "ProbabilityModule.cs"
                    float* first_condition = scratch;
#line 680 "ProbabilityModule.cs"
                    float* second_condition = csharp2cuda_pointer_add(first_condition, first_condition_count);
#line 681 "ProbabilityModule.cs"
                    float* condition = csharp2cuda_pointer_add(second_condition, second_condition_count);
#line 682 "ProbabilityModule.cs"
                    {
#line 682 "ProbabilityModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_add(csharp2cuda_i32_add(first_condition_count, second_condition_count), condition_count)))))
                                break;
#line 683 "ProbabilityModule.cs"
#line 683 "ProbabilityModule.cs"
                            float* csharp2cuda_temp_142 = &((scratch)[index]);
                            (*(csharp2cuda_temp_142) = 0.0f);
#line 682 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_141 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_141));
                        }
                    }
#line 684 "ProbabilityModule.cs"
                    {
#line 684 "ProbabilityModule.cs"
                        int first_index = 0;
                        while (true)
                        {
                            if (!(((first_index) < (first_count))))
                                break;
#line 685 "ProbabilityModule.cs"
                            {
#line 685 "ProbabilityModule.cs"
                                int second_index = 0;
                                while (true)
                                {
                                    if (!(((second_index) < (second_count))))
                                        break;
#line 686 "ProbabilityModule.cs"
                                    {
#line 686 "ProbabilityModule.cs"
                                        int state = 0;
                                        while (true)
                                        {
                                            if (!(((state) < (condition_count))))
                                                break;
#line 687 "ProbabilityModule.cs"
                                            {
#line 688 "ProbabilityModule.cs"
                                                float probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, second_count), second_index), condition_count), state)];
#line 690 "ProbabilityModule.cs"
#line 690 "ProbabilityModule.cs"
                                                float* csharp2cuda_temp_146 = &((first_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, condition_count), state)]);
#line 690 "ProbabilityModule.cs"
                                                float csharp2cuda_temp_147 = *(csharp2cuda_temp_146);
                                                (*(csharp2cuda_temp_146) = __fadd_rn(csharp2cuda_temp_147, probability));
#line 691 "ProbabilityModule.cs"
#line 691 "ProbabilityModule.cs"
                                                float* csharp2cuda_temp_148 = &((second_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(second_index, condition_count), state)]);
#line 691 "ProbabilityModule.cs"
                                                float csharp2cuda_temp_149 = *(csharp2cuda_temp_148);
                                                (*(csharp2cuda_temp_148) = __fadd_rn(csharp2cuda_temp_149, probability));
#line 692 "ProbabilityModule.cs"
#line 692 "ProbabilityModule.cs"
                                                float* csharp2cuda_temp_150 = &((condition)[state]);
#line 692 "ProbabilityModule.cs"
                                                float csharp2cuda_temp_151 = *(csharp2cuda_temp_150);
                                                (*(csharp2cuda_temp_150) = __fadd_rn(csharp2cuda_temp_151, probability));
                                            }
#line 686 "ProbabilityModule.cs"
                                            int* csharp2cuda_temp_145 = &(state);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_145));
                                        }
                                    }
#line 685 "ProbabilityModule.cs"
                                    int* csharp2cuda_temp_144 = &(second_index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_144));
                                }
                            }
#line 684 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_143 = &(first_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_143));
                        }
                    }
#line 694 "ProbabilityModule.cs"
                    {
#line 694 "ProbabilityModule.cs"
                        int first_index = 0;
                        while (true)
                        {
                            if (!(((first_index) < (first_count))))
                                break;
#line 695 "ProbabilityModule.cs"
                            {
#line 695 "ProbabilityModule.cs"
                                int second_index = 0;
                                while (true)
                                {
                                    if (!(((second_index) < (second_count))))
                                        break;
#line 696 "ProbabilityModule.cs"
                                    {
#line 696 "ProbabilityModule.cs"
                                        int state = 0;
                                        while (true)
                                        {
                                            if (!(((state) < (condition_count))))
                                                break;
#line 697 "ProbabilityModule.cs"
                                            {
#line 698 "ProbabilityModule.cs"
                                                float probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, second_count), second_index), condition_count), state)];
#line 700 "ProbabilityModule.cs"
                                                if (((probability) == (0.0f)))
                                                {
#line 700 "ProbabilityModule.cs"
                                                    goto csharp2cuda_for_continue_15;
                                                }
#line 701 "ProbabilityModule.cs"
#line 701 "ProbabilityModule.cs"
                                                float* csharp2cuda_temp_155 = &(value);
#line 701 "ProbabilityModule.cs"
                                                float csharp2cuda_temp_156 = *(csharp2cuda_temp_155);
#line 702 "ProbabilityModule.cs"
                                                float csharp2cuda_temp_157 = (condition)[state];
#line 703 "ProbabilityModule.cs"
                                                float csharp2cuda_temp_158 = (first_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, condition_count), state)];
#line 704 "ProbabilityModule.cs"
                                                float csharp2cuda_temp_159 = (second_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(second_index, condition_count), state)];
#line 702 "ProbabilityModule.cs"
                                                float csharp2cuda_temp_160 = __fdiv_rn(__fmul_rn(probability, csharp2cuda_temp_157), __fmul_rn(csharp2cuda_temp_158, csharp2cuda_temp_159));
                                                (*(csharp2cuda_temp_155) = __fadd_rn(csharp2cuda_temp_156, __fmul_rn(probability, mathblocks_natural_logarithm(csharp2cuda_temp_160))));
                                            }
                                            csharp2cuda_for_continue_15:
#line 696 "ProbabilityModule.cs"
                                            int* csharp2cuda_temp_154 = &(state);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_154));
                                        }
                                    }
#line 695 "ProbabilityModule.cs"
                                    int* csharp2cuda_temp_153 = &(second_index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_153));
                                }
                            }
#line 694 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_152 = &(first_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_152));
                        }
                    }
                }
                else
                {
#line 707 "ProbabilityModule.cs"
                    if (((opcode) == (7)))
#line 708 "ProbabilityModule.cs"
                    {
#line 709 "ProbabilityModule.cs"
                        {
#line 709 "ProbabilityModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 709 "ProbabilityModule.cs"
                                int csharp2cuda_temp_162 = (first)->count;
                                if (!(((index) < (csharp2cuda_temp_162))))
                                    break;
#line 710 "ProbabilityModule.cs"
                                {
#line 711 "ProbabilityModule.cs"
#line 711 "ProbabilityModule.cs"
                                    float csharp2cuda_temp_163 = (a)[index];
#line 711 "ProbabilityModule.cs"
                                    bool csharp2cuda_temp_164;
#line 711 "ProbabilityModule.cs"
                                    if (((csharp2cuda_temp_163) > (0.0f)))
                                    {
#line 711 "ProbabilityModule.cs"
                                        float csharp2cuda_temp_165 = (b)[index];
#line 711 "ProbabilityModule.cs"
                                        csharp2cuda_temp_164 = ((csharp2cuda_temp_165) == (0.0f));
                                    }
                                    else
                                    {
#line 711 "ProbabilityModule.cs"
                                        csharp2cuda_temp_164 = false;
                                    }
                                    if (csharp2cuda_temp_164)
#line 712 "ProbabilityModule.cs"
                                    {
#line 713 "ProbabilityModule.cs"
#line 713 "ProbabilityModule.cs"
                                        int* csharp2cuda_temp_166 = &((output)->valid);
                                        (*(csharp2cuda_temp_166) = 0);
#line 714 "ProbabilityModule.cs"
                                        return;
                                    }
#line 716 "ProbabilityModule.cs"
#line 716 "ProbabilityModule.cs"
                                    float csharp2cuda_temp_167 = (a)[index];
                                    if (((csharp2cuda_temp_167) > (0.0f)))
                                    {
#line 717 "ProbabilityModule.cs"
#line 717 "ProbabilityModule.cs"
                                        float* csharp2cuda_temp_168 = &(value);
#line 717 "ProbabilityModule.cs"
                                        float csharp2cuda_temp_169 = *(csharp2cuda_temp_168);
#line 717 "ProbabilityModule.cs"
                                        float csharp2cuda_temp_170 = (a)[index];
#line 717 "ProbabilityModule.cs"
                                        float csharp2cuda_temp_171 = (b)[index];
                                        (*(csharp2cuda_temp_168) = __fsub_rn(csharp2cuda_temp_169, __fmul_rn(csharp2cuda_temp_170, mathblocks_natural_logarithm(csharp2cuda_temp_171))));
                                    }
                                }
#line 709 "ProbabilityModule.cs"
                                int* csharp2cuda_temp_161 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_161));
                            }
                        }
                    }
                    else
                    {
#line 720 "ProbabilityModule.cs"
                        if (((opcode) == (8)))
#line 721 "ProbabilityModule.cs"
                        {
#line 722 "ProbabilityModule.cs"
#line 722 "ProbabilityModule.cs"
                            float* csharp2cuda_temp_172 = &(value);
#line 722 "ProbabilityModule.cs"
                            int csharp2cuda_temp_173 = (first)->count;
                            (*(csharp2cuda_temp_172) = __fsub_rn(1.0f, mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_173)));
                        }
                        else
                        {
#line 724 "ProbabilityModule.cs"
                            if (((opcode) == (9)))
#line 725 "ProbabilityModule.cs"
                            {
#line 726 "ProbabilityModule.cs"
                                {
#line 726 "ProbabilityModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 726 "ProbabilityModule.cs"
                                        int csharp2cuda_temp_175 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_175))))
                                            break;
#line 727 "ProbabilityModule.cs"
                                        {
#line 728 "ProbabilityModule.cs"
                                            float csharp2cuda_temp_176 = (a)[index];
#line 728 "ProbabilityModule.cs"
                                            float csharp2cuda_temp_177 = (b)[index];
#line 728 "ProbabilityModule.cs"
                                            float difference = __fsub_rn(mathblocks_square_root(csharp2cuda_temp_176), mathblocks_square_root(csharp2cuda_temp_177));
#line 729 "ProbabilityModule.cs"
#line 729 "ProbabilityModule.cs"
                                            float* csharp2cuda_temp_178 = &(value);
#line 729 "ProbabilityModule.cs"
                                            float csharp2cuda_temp_179 = *(csharp2cuda_temp_178);
                                            (*(csharp2cuda_temp_178) = __fadd_rn(csharp2cuda_temp_179, __fmul_rn(difference, difference)));
                                        }
#line 726 "ProbabilityModule.cs"
                                        int* csharp2cuda_temp_174 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_174));
                                    }
                                }
#line 731 "ProbabilityModule.cs"
#line 731 "ProbabilityModule.cs"
                                float* csharp2cuda_temp_180 = &(value);
#line 731 "ProbabilityModule.cs"
                                float csharp2cuda_temp_181 = __fdiv_rn(value, 2.0f);
                                (*(csharp2cuda_temp_180) = mathblocks_square_root(csharp2cuda_temp_181));
                            }
                            else
                            {
#line 733 "ProbabilityModule.cs"
                                if (((opcode) == (10)))
#line 734 "ProbabilityModule.cs"
                                {
#line 735 "ProbabilityModule.cs"
                                    if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 736 "ProbabilityModule.cs"
                                    {
#line 737 "ProbabilityModule.cs"
#line 737 "ProbabilityModule.cs"
                                        int* csharp2cuda_temp_182 = &((output)->valid);
                                        (*(csharp2cuda_temp_182) = 0);
#line 738 "ProbabilityModule.cs"
                                        return;
                                    }
#line 740 "ProbabilityModule.cs"
                                    {
#line 740 "ProbabilityModule.cs"
                                        int index = 0;
                                        while (true)
                                        {
#line 740 "ProbabilityModule.cs"
                                            int csharp2cuda_temp_184 = (first)->count;
                                            if (!(((index) < (csharp2cuda_temp_184))))
                                                break;
#line 741 "ProbabilityModule.cs"
#line 741 "ProbabilityModule.cs"
                                            float* csharp2cuda_temp_185 = &((scratch)[index]);
#line 741 "ProbabilityModule.cs"
                                            float csharp2cuda_temp_186 = (a)[index];
#line 741 "ProbabilityModule.cs"
                                            float csharp2cuda_temp_187 = (b)[index];
#line 741 "ProbabilityModule.cs"
                                            float csharp2cuda_temp_188 = __fdiv_rn(__fadd_rn(csharp2cuda_temp_186, csharp2cuda_temp_187), 2.0f);
                                            (*(csharp2cuda_temp_185) = csharp2cuda_temp_188);
#line 740 "ProbabilityModule.cs"
                                            int* csharp2cuda_temp_183 = &(index);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_183));
                                        }
                                    }
#line 742 "ProbabilityModule.cs"
#line 742 "ProbabilityModule.cs"
                                    float* csharp2cuda_temp_189 = &(value);
#line 742 "ProbabilityModule.cs"
                                    int csharp2cuda_temp_190 = (first)->count;
#line 742 "ProbabilityModule.cs"
                                    float csharp2cuda_temp_191 = mathblocks_probability_kl(a, scratch, csharp2cuda_temp_190);
#line 743 "ProbabilityModule.cs"
                                    int csharp2cuda_temp_192 = (first)->count;
#line 743 "ProbabilityModule.cs"
                                    float csharp2cuda_temp_193 = mathblocks_probability_kl(b, scratch, csharp2cuda_temp_192);
                                    (*(csharp2cuda_temp_189) = __fmul_rn(0.5f, __fadd_rn(csharp2cuda_temp_191, csharp2cuda_temp_193)));
                                }
                                else
                                {
#line 745 "ProbabilityModule.cs"
                                    if (((opcode) == (11)))
#line 746 "ProbabilityModule.cs"
                                    {
#line 747 "ProbabilityModule.cs"
                                        {
#line 747 "ProbabilityModule.cs"
                                            int index = 0;
                                            while (true)
                                            {
#line 747 "ProbabilityModule.cs"
                                                int csharp2cuda_temp_195 = (first)->count;
                                                if (!(((index) < (csharp2cuda_temp_195))))
                                                    break;
#line 748 "ProbabilityModule.cs"
#line 748 "ProbabilityModule.cs"
                                                float csharp2cuda_temp_196 = (a)[index];
#line 748 "ProbabilityModule.cs"
                                                bool csharp2cuda_temp_197;
#line 748 "ProbabilityModule.cs"
                                                if (((csharp2cuda_temp_196) > (0.0f)))
                                                {
#line 748 "ProbabilityModule.cs"
                                                    float csharp2cuda_temp_198 = (b)[index];
#line 748 "ProbabilityModule.cs"
                                                    csharp2cuda_temp_197 = ((csharp2cuda_temp_198) == (0.0f));
                                                }
                                                else
                                                {
#line 748 "ProbabilityModule.cs"
                                                    csharp2cuda_temp_197 = false;
                                                }
                                                if (csharp2cuda_temp_197)
#line 749 "ProbabilityModule.cs"
                                                {
#line 750 "ProbabilityModule.cs"
#line 750 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_199 = &((output)->valid);
                                                    (*(csharp2cuda_temp_199) = 0);
#line 751 "ProbabilityModule.cs"
                                                    return;
                                                }
#line 747 "ProbabilityModule.cs"
                                                int* csharp2cuda_temp_194 = &(index);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_194));
                                            }
                                        }
#line 753 "ProbabilityModule.cs"
#line 753 "ProbabilityModule.cs"
                                        float* csharp2cuda_temp_200 = &(value);
#line 753 "ProbabilityModule.cs"
                                        int csharp2cuda_temp_201 = (first)->count;
#line 753 "ProbabilityModule.cs"
                                        float csharp2cuda_temp_202 = mathblocks_probability_kl(a, b, csharp2cuda_temp_201);
                                        (*(csharp2cuda_temp_200) = csharp2cuda_temp_202);
                                    }
                                    else
                                    {
#line 755 "ProbabilityModule.cs"
                                        if (((opcode) == (12)))
#line 756 "ProbabilityModule.cs"
                                        {
#line 757 "ProbabilityModule.cs"
                                            int rows = (first)->rows;
#line 758 "ProbabilityModule.cs"
                                            int columns = (first)->columns;
#line 759 "ProbabilityModule.cs"
                                            if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 760 "ProbabilityModule.cs"
                                            {
#line 761 "ProbabilityModule.cs"
#line 761 "ProbabilityModule.cs"
                                                int* csharp2cuda_temp_203 = &((output)->valid);
                                                (*(csharp2cuda_temp_203) = 0);
#line 762 "ProbabilityModule.cs"
                                                return;
                                            }
#line 764 "ProbabilityModule.cs"
                                            float* row_totals = scratch;
#line 765 "ProbabilityModule.cs"
                                            float* column_totals = csharp2cuda_pointer_add(scratch, rows);
#line 766 "ProbabilityModule.cs"
                                            {
#line 766 "ProbabilityModule.cs"
                                                int index = 0;
                                                while (true)
                                                {
                                                    if (!(((index) < (csharp2cuda_i32_add(rows, columns)))))
                                                        break;
#line 766 "ProbabilityModule.cs"
#line 766 "ProbabilityModule.cs"
                                                    float* csharp2cuda_temp_205 = &((scratch)[index]);
                                                    (*(csharp2cuda_temp_205) = 0.0f);
#line 766 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_204 = &(index);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_204));
                                                }
                                            }
#line 767 "ProbabilityModule.cs"
                                            {
#line 767 "ProbabilityModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
                                                    if (!(((row) < (rows))))
                                                        break;
#line 768 "ProbabilityModule.cs"
                                                    {
#line 768 "ProbabilityModule.cs"
                                                        int column = 0;
                                                        while (true)
                                                        {
                                                            if (!(((column) < (columns))))
                                                                break;
#line 769 "ProbabilityModule.cs"
                                                            {
#line 770 "ProbabilityModule.cs"
                                                                float probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 771 "ProbabilityModule.cs"
#line 771 "ProbabilityModule.cs"
                                                                float* csharp2cuda_temp_208 = &((row_totals)[row]);
#line 771 "ProbabilityModule.cs"
                                                                float csharp2cuda_temp_209 = *(csharp2cuda_temp_208);
                                                                (*(csharp2cuda_temp_208) = __fadd_rn(csharp2cuda_temp_209, probability));
#line 772 "ProbabilityModule.cs"
#line 772 "ProbabilityModule.cs"
                                                                float* csharp2cuda_temp_210 = &((column_totals)[column]);
#line 772 "ProbabilityModule.cs"
                                                                float csharp2cuda_temp_211 = *(csharp2cuda_temp_210);
                                                                (*(csharp2cuda_temp_210) = __fadd_rn(csharp2cuda_temp_211, probability));
                                                            }
#line 768 "ProbabilityModule.cs"
                                                            int* csharp2cuda_temp_207 = &(column);
                                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_207));
                                                        }
                                                    }
#line 767 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_206 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_206));
                                                }
                                            }
#line 774 "ProbabilityModule.cs"
                                            {
#line 774 "ProbabilityModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
                                                    if (!(((row) < (rows))))
                                                        break;
#line 775 "ProbabilityModule.cs"
                                                    {
#line 775 "ProbabilityModule.cs"
                                                        int column = 0;
                                                        while (true)
                                                        {
                                                            if (!(((column) < (columns))))
                                                                break;
#line 776 "ProbabilityModule.cs"
                                                            {
#line 777 "ProbabilityModule.cs"
                                                                float probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 778 "ProbabilityModule.cs"
                                                                if (((probability) > (0.0f)))
                                                                {
#line 779 "ProbabilityModule.cs"
#line 779 "ProbabilityModule.cs"
                                                                    float* csharp2cuda_temp_214 = &(value);
#line 779 "ProbabilityModule.cs"
                                                                    float csharp2cuda_temp_215 = *(csharp2cuda_temp_214);
#line 780 "ProbabilityModule.cs"
                                                                    float csharp2cuda_temp_216 = (row_totals)[row];
#line 780 "ProbabilityModule.cs"
                                                                    float csharp2cuda_temp_217 = (column_totals)[column];
#line 780 "ProbabilityModule.cs"
                                                                    float csharp2cuda_temp_218 = __fdiv_rn(probability, __fmul_rn(csharp2cuda_temp_216, csharp2cuda_temp_217));
                                                                    (*(csharp2cuda_temp_214) = __fadd_rn(csharp2cuda_temp_215, __fmul_rn(probability, mathblocks_natural_logarithm(csharp2cuda_temp_218))));
                                                                }
                                                            }
#line 775 "ProbabilityModule.cs"
                                                            int* csharp2cuda_temp_213 = &(column);
                                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_213));
                                                        }
                                                    }
#line 774 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_212 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_212));
                                                }
                                            }
                                        }
                                        else
                                        {
#line 783 "ProbabilityModule.cs"
#line 783 "ProbabilityModule.cs"
                                            bool csharp2cuda_temp_219;
#line 783 "ProbabilityModule.cs"
                                            if (!(((opcode) == (13))))
                                            {
#line 783 "ProbabilityModule.cs"
                                                csharp2cuda_temp_219 = ((opcode) == (16));
                                            }
                                            else
                                            {
#line 783 "ProbabilityModule.cs"
                                                csharp2cuda_temp_219 = true;
                                            }
                                            if (csharp2cuda_temp_219)
#line 784 "ProbabilityModule.cs"
                                            {
#line 785 "ProbabilityModule.cs"
#line 787 "ProbabilityModule.cs"
                                                int csharp2cuda_temp_220 = (first)->count;
#line 788 "ProbabilityModule.cs"
                                                float csharp2cuda_temp_221 = (second)->scalar_value;
#line 790 "ProbabilityModule.cs"
                                                float* csharp2cuda_temp_222 = &(value);
#line 785 "ProbabilityModule.cs"
                                                bool csharp2cuda_temp_223 = mathblocks_probability_ordered_entropy_value(a, csharp2cuda_temp_220, csharp2cuda_temp_221, ((opcode) == (13)), csharp2cuda_temp_222);
                                                if ((!(csharp2cuda_temp_223)))
#line 791 "ProbabilityModule.cs"
                                                {
#line 792 "ProbabilityModule.cs"
#line 792 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_224 = &((output)->valid);
                                                    (*(csharp2cuda_temp_224) = 0);
#line 793 "ProbabilityModule.cs"
                                                    return;
                                                }
                                            }
                                            else
                                            {
#line 796 "ProbabilityModule.cs"
                                                if (((opcode) == (14)))
#line 797 "ProbabilityModule.cs"
                                                {
#line 798 "ProbabilityModule.cs"
#line 798 "ProbabilityModule.cs"
                                                    float* csharp2cuda_temp_225 = &(value);
#line 798 "ProbabilityModule.cs"
                                                    int csharp2cuda_temp_226 = (first)->count;
#line 798 "ProbabilityModule.cs"
                                                    float csharp2cuda_temp_227 = mathblocks_probability_entropy(a, csharp2cuda_temp_226);
                                                    (*(csharp2cuda_temp_225) = csharp2cuda_temp_227);
                                                }
                                                else
                                                {
#line 800 "ProbabilityModule.cs"
                                                    if (((opcode) == (15)))
#line 801 "ProbabilityModule.cs"
                                                    {
#line 802 "ProbabilityModule.cs"
                                                        {
#line 802 "ProbabilityModule.cs"
                                                            int index = 0;
                                                            while (true)
                                                            {
#line 802 "ProbabilityModule.cs"
                                                                int csharp2cuda_temp_229 = (first)->count;
                                                                if (!(((index) < (csharp2cuda_temp_229))))
                                                                    break;
#line 803 "ProbabilityModule.cs"
#line 803 "ProbabilityModule.cs"
                                                                float* csharp2cuda_temp_230 = &(value);
#line 803 "ProbabilityModule.cs"
                                                                float csharp2cuda_temp_231 = *(csharp2cuda_temp_230);
#line 803 "ProbabilityModule.cs"
                                                                float csharp2cuda_temp_232 = (a)[index];
#line 803 "ProbabilityModule.cs"
                                                                float csharp2cuda_temp_233 = (b)[index];
                                                                (*(csharp2cuda_temp_230) = __fadd_rn(csharp2cuda_temp_231, fabsf(__fsub_rn(csharp2cuda_temp_232, csharp2cuda_temp_233))));
#line 802 "ProbabilityModule.cs"
                                                                int* csharp2cuda_temp_228 = &(index);
                                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_228));
                                                            }
                                                        }
#line 804 "ProbabilityModule.cs"
#line 804 "ProbabilityModule.cs"
                                                        float* csharp2cuda_temp_234 = &(value);
#line 804 "ProbabilityModule.cs"
                                                        float csharp2cuda_temp_235 = *(csharp2cuda_temp_234);
                                                        (*(csharp2cuda_temp_234) = __fdiv_rn(csharp2cuda_temp_235, 2.0f));
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
#line 806 "ProbabilityModule.cs"
#line 806 "ProbabilityModule.cs"
        float* csharp2cuda_temp_236 = &((output)->scalar_value);
        (*(csharp2cuda_temp_236) = value);
#line 807 "ProbabilityModule.cs"
        if ((!(isfinite(value))))
        {
#line 807 "ProbabilityModule.cs"
#line 807 "ProbabilityModule.cs"
            int* csharp2cuda_temp_237 = &((output)->valid);
            (*(csharp2cuda_temp_237) = 0);
        }
#line 808 "ProbabilityModule.cs"
        return;
    }
#line 811 "ProbabilityModule.cs"
    if (((opcode) == (17)))
#line 812 "ProbabilityModule.cs"
    {
#line 813 "ProbabilityModule.cs"
        float parameter = (second)->scalar_value;
#line 814 "ProbabilityModule.cs"
#line 814 "ProbabilityModule.cs"
        int csharp2cuda_temp_238 = (first)->count;
#line 814 "ProbabilityModule.cs"
        bool csharp2cuda_temp_239;
#line 814 "ProbabilityModule.cs"
        if (!(((csharp2cuda_temp_238) <= (0))))
        {
#line 814 "ProbabilityModule.cs"
            csharp2cuda_temp_239 = ((parameter) < (0.0f));
        }
        else
        {
#line 814 "ProbabilityModule.cs"
            csharp2cuda_temp_239 = true;
        }
#line 814 "ProbabilityModule.cs"
        bool csharp2cuda_temp_240;
#line 814 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_239))
        {
#line 814 "ProbabilityModule.cs"
            csharp2cuda_temp_240 = ((parameter) > (1.0f));
        }
        else
        {
#line 814 "ProbabilityModule.cs"
            csharp2cuda_temp_240 = true;
        }
        if (csharp2cuda_temp_240)
#line 815 "ProbabilityModule.cs"
        {
#line 816 "ProbabilityModule.cs"
#line 816 "ProbabilityModule.cs"
            int* csharp2cuda_temp_241 = &((output)->valid);
            (*(csharp2cuda_temp_241) = 0);
#line 817 "ProbabilityModule.cs"
            return;
        }
#line 819 "ProbabilityModule.cs"
        int csharp2cuda_temp_242 = (first)->count;
#line 819 "ProbabilityModule.cs"
        int degree = csharp2cuda_i32_sub(csharp2cuda_temp_242, 1);
#line 820 "ProbabilityModule.cs"
        float value = 0.0f;
#line 821 "ProbabilityModule.cs"
        {
#line 821 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) <= (degree))))
                    break;
#line 822 "ProbabilityModule.cs"
#line 822 "ProbabilityModule.cs"
                float* csharp2cuda_temp_244 = &(value);
#line 822 "ProbabilityModule.cs"
                float csharp2cuda_temp_245 = *(csharp2cuda_temp_244);
#line 822 "ProbabilityModule.cs"
                float csharp2cuda_temp_246 = (a)[index];
                (*(csharp2cuda_temp_244) = __fadd_rn(csharp2cuda_temp_245, __fmul_rn(__fmul_rn(__fmul_rn(csharp2cuda_temp_246, mathblocks_probability_binomial(((long long)(degree)), index)), mathblocks_power(parameter, ((float)(index)))), mathblocks_power(__fsub_rn(1.0f, parameter), ((float)(csharp2cuda_i32_sub(degree, index)))))));
#line 821 "ProbabilityModule.cs"
                int* csharp2cuda_temp_243 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_243));
            }
        }
#line 825 "ProbabilityModule.cs"
#line 825 "ProbabilityModule.cs"
        float* csharp2cuda_temp_247 = &((output)->scalar_value);
        (*(csharp2cuda_temp_247) = value);
#line 826 "ProbabilityModule.cs"
        if ((!(isfinite(value))))
        {
#line 826 "ProbabilityModule.cs"
#line 826 "ProbabilityModule.cs"
            int* csharp2cuda_temp_248 = &((output)->valid);
            (*(csharp2cuda_temp_248) = 0);
        }
#line 827 "ProbabilityModule.cs"
        return;
    }
#line 830 "ProbabilityModule.cs"
    if (((opcode) == (18)))
#line 831 "ProbabilityModule.cs"
    {
#line 832 "ProbabilityModule.cs"
#line 832 "ProbabilityModule.cs"
        int csharp2cuda_temp_249 = (first)->count;
        if (((csharp2cuda_temp_249) != (4)))
#line 833 "ProbabilityModule.cs"
        {
#line 834 "ProbabilityModule.cs"
#line 834 "ProbabilityModule.cs"
            int* csharp2cuda_temp_250 = &((output)->valid);
            (*(csharp2cuda_temp_250) = 0);
#line 835 "ProbabilityModule.cs"
            return;
        }
#line 837 "ProbabilityModule.cs"
        unsigned long long csharp2cuda_temp_251 = (output)->data_pointer;
#line 837 "ProbabilityModule.cs"
        MathBlockComplexValue* roots = ((MathBlockComplexValue*)(csharp2cuda_temp_251));
#line 838 "ProbabilityModule.cs"
        mathblocks_complex_shape(output, 3);
#line 839 "ProbabilityModule.cs"
        float constant = (a)[0];
#line 840 "ProbabilityModule.cs"
        float linear = (a)[1];
#line 841 "ProbabilityModule.cs"
        float quadratic = (a)[2];
#line 842 "ProbabilityModule.cs"
        float leading = (a)[3];
#line 843 "ProbabilityModule.cs"
        if (((leading) == (0.0f)))
#line 844 "ProbabilityModule.cs"
        {
#line 845 "ProbabilityModule.cs"
#line 845 "ProbabilityModule.cs"
            int* csharp2cuda_temp_252 = &((output)->valid);
            (*(csharp2cuda_temp_252) = 0);
#line 846 "ProbabilityModule.cs"
            return;
        }
#line 848 "ProbabilityModule.cs"
        float normalized_a = __fdiv_rn(quadratic, leading);
#line 849 "ProbabilityModule.cs"
        float normalized_b = __fdiv_rn(linear, leading);
#line 850 "ProbabilityModule.cs"
        float normalized_c = __fdiv_rn(constant, leading);
#line 851 "ProbabilityModule.cs"
        float csharp2cuda_temp_253 = __fdiv_rn(__fmul_rn(normalized_a, normalized_a), 3.0f);
#line 851 "ProbabilityModule.cs"
        float p = __fsub_rn(normalized_b, csharp2cuda_temp_253);
#line 852 "ProbabilityModule.cs"
        float csharp2cuda_temp_254 = __fdiv_rn(__fmul_rn(__fmul_rn(__fmul_rn(2.0f, normalized_a), normalized_a), normalized_a), 27.0f);
#line 853 "ProbabilityModule.cs"
        float csharp2cuda_temp_255 = __fdiv_rn(__fmul_rn(normalized_a, normalized_b), 3.0f);
#line 852 "ProbabilityModule.cs"
        float q = __fadd_rn(__fsub_rn(csharp2cuda_temp_254, csharp2cuda_temp_255), normalized_c);
#line 855 "ProbabilityModule.cs"
        float csharp2cuda_temp_256 = __fdiv_rn(__fmul_rn(q, q), 4.0f);
#line 855 "ProbabilityModule.cs"
        float csharp2cuda_temp_257 = __fdiv_rn(__fmul_rn(__fmul_rn(p, p), p), 27.0f);
#line 854 "ProbabilityModule.cs"
        MathBlockComplexValue square_root = mathblocks_complex_square_root(mathblocks_complex_make(__fadd_rn(csharp2cuda_temp_256, csharp2cuda_temp_257), 0.0f));
#line 857 "ProbabilityModule.cs"
        float csharp2cuda_temp_258 = __fdiv_rn((-(q)), 2.0f);
#line 856 "ProbabilityModule.cs"
        MathBlockComplexValue u = mathblocks_probability_complex_cube_root(mathblocks_complex_add(mathblocks_complex_make(csharp2cuda_temp_258, 0.0f), square_root));
#line 858 "ProbabilityModule.cs"
        float csharp2cuda_temp_259 = (u).real;
#line 858 "ProbabilityModule.cs"
        bool csharp2cuda_temp_260;
#line 858 "ProbabilityModule.cs"
        if (((csharp2cuda_temp_259) == (0.0f)))
        {
#line 858 "ProbabilityModule.cs"
            float csharp2cuda_temp_261 = (u).imaginary;
#line 858 "ProbabilityModule.cs"
            csharp2cuda_temp_260 = ((csharp2cuda_temp_261) == (0.0f));
        }
        else
        {
#line 858 "ProbabilityModule.cs"
            csharp2cuda_temp_260 = false;
        }
#line 858 "ProbabilityModule.cs"
        MathBlockComplexValue csharp2cuda_temp_262;
#line 858 "ProbabilityModule.cs"
        if (csharp2cuda_temp_260)
        {
#line 860 "ProbabilityModule.cs"
            float csharp2cuda_temp_263 = __fdiv_rn((-(q)), 2.0f);
#line 858 "ProbabilityModule.cs"
            csharp2cuda_temp_262 = mathblocks_probability_complex_cube_root(mathblocks_complex_subtract(mathblocks_complex_make(csharp2cuda_temp_263, 0.0f), square_root));
        }
        else
        {
#line 858 "ProbabilityModule.cs"
            csharp2cuda_temp_262 = mathblocks_complex_divide(mathblocks_complex_make((-(p)), 0.0f), mathblocks_complex_multiply(mathblocks_complex_make(3.0f, 0.0f), u));
        }
#line 858 "ProbabilityModule.cs"
        MathBlockComplexValue v = csharp2cuda_temp_262;
#line 866 "ProbabilityModule.cs"
        float csharp2cuda_temp_264 = __fdiv_rn(mathblocks_square_root(3.0f), 2.0f);
#line 864 "ProbabilityModule.cs"
        MathBlockComplexValue omega = mathblocks_complex_make((-(0.5f)), csharp2cuda_temp_264);
#line 867 "ProbabilityModule.cs"
#line 867 "ProbabilityModule.cs"
        MathBlockComplexValue* csharp2cuda_temp_265 = &((roots)[0]);
#line 869 "ProbabilityModule.cs"
        float csharp2cuda_temp_266 = __fdiv_rn(normalized_a, 3.0f);
        (*(csharp2cuda_temp_265) = mathblocks_complex_subtract(mathblocks_complex_add(u, v), mathblocks_complex_make(csharp2cuda_temp_266, 0.0f)));
#line 870 "ProbabilityModule.cs"
#line 870 "ProbabilityModule.cs"
        MathBlockComplexValue* csharp2cuda_temp_267 = &((roots)[1]);
#line 874 "ProbabilityModule.cs"
        float csharp2cuda_temp_268 = __fdiv_rn(normalized_a, 3.0f);
        (*(csharp2cuda_temp_267) = mathblocks_complex_subtract(mathblocks_complex_add(mathblocks_complex_multiply(omega, u), mathblocks_complex_multiply(mathblocks_complex_conjugate(omega), v)), mathblocks_complex_make(csharp2cuda_temp_268, 0.0f)));
#line 875 "ProbabilityModule.cs"
#line 875 "ProbabilityModule.cs"
        MathBlockComplexValue* csharp2cuda_temp_269 = &((roots)[2]);
#line 879 "ProbabilityModule.cs"
        float csharp2cuda_temp_270 = __fdiv_rn(normalized_a, 3.0f);
        (*(csharp2cuda_temp_269) = mathblocks_complex_subtract(mathblocks_complex_add(mathblocks_complex_multiply(mathblocks_complex_conjugate(omega), u), mathblocks_complex_multiply(omega, v)), mathblocks_complex_make(csharp2cuda_temp_270, 0.0f)));
#line 880 "ProbabilityModule.cs"
        {
#line 880 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (3))))
                    break;
#line 881 "ProbabilityModule.cs"
#line 881 "ProbabilityModule.cs"
                MathBlockComplexValue csharp2cuda_temp_272 = (roots)[index];
                if ((!(mathblocks_complex_finite(csharp2cuda_temp_272))))
                {
#line 881 "ProbabilityModule.cs"
#line 881 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_273 = &((output)->valid);
                    (*(csharp2cuda_temp_273) = 0);
                }
#line 880 "ProbabilityModule.cs"
                int* csharp2cuda_temp_271 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_271));
            }
        }
#line 882 "ProbabilityModule.cs"
        return;
    }
#line 885 "ProbabilityModule.cs"
    if (((opcode) == (20)))
#line 886 "ProbabilityModule.cs"
    {
#line 887 "ProbabilityModule.cs"
        int order = 0;
#line 888 "ProbabilityModule.cs"
#line 888 "ProbabilityModule.cs"
        float csharp2cuda_temp_274 = (second)->scalar_value;
#line 888 "ProbabilityModule.cs"
        int* csharp2cuda_temp_275 = &(order);
#line 888 "ProbabilityModule.cs"
        bool csharp2cuda_temp_276 = mathblocks_probability_integer(csharp2cuda_temp_274, csharp2cuda_temp_275);
#line 888 "ProbabilityModule.cs"
        bool csharp2cuda_temp_277;
#line 888 "ProbabilityModule.cs"
        if (!((!(csharp2cuda_temp_276))))
        {
#line 888 "ProbabilityModule.cs"
            csharp2cuda_temp_277 = ((order) < (0));
        }
        else
        {
#line 888 "ProbabilityModule.cs"
            csharp2cuda_temp_277 = true;
        }
#line 888 "ProbabilityModule.cs"
        bool csharp2cuda_temp_278;
#line 888 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_277))
        {
#line 889 "ProbabilityModule.cs"
            int csharp2cuda_temp_279 = (first)->count;
#line 888 "ProbabilityModule.cs"
            csharp2cuda_temp_278 = ((order) > (csharp2cuda_temp_279));
        }
        else
        {
#line 888 "ProbabilityModule.cs"
            csharp2cuda_temp_278 = true;
        }
#line 888 "ProbabilityModule.cs"
        bool csharp2cuda_temp_280;
#line 888 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_278))
        {
#line 888 "ProbabilityModule.cs"
            csharp2cuda_temp_280 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 888 "ProbabilityModule.cs"
            csharp2cuda_temp_280 = true;
        }
        if (csharp2cuda_temp_280)
#line 890 "ProbabilityModule.cs"
        {
#line 891 "ProbabilityModule.cs"
#line 891 "ProbabilityModule.cs"
            int* csharp2cuda_temp_281 = &((output)->valid);
            (*(csharp2cuda_temp_281) = 0);
#line 892 "ProbabilityModule.cs"
            return;
        }
#line 894 "ProbabilityModule.cs"
        {
#line 894 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) <= (order))))
                    break;
#line 894 "ProbabilityModule.cs"
#line 894 "ProbabilityModule.cs"
                float* csharp2cuda_temp_283 = &((scratch)[index]);
                (*(csharp2cuda_temp_283) = 0.0f);
#line 894 "ProbabilityModule.cs"
                int* csharp2cuda_temp_282 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_282));
            }
        }
#line 895 "ProbabilityModule.cs"
#line 895 "ProbabilityModule.cs"
        float* csharp2cuda_temp_284 = &((scratch)[0]);
        (*(csharp2cuda_temp_284) = 1.0f);
#line 896 "ProbabilityModule.cs"
        {
#line 896 "ProbabilityModule.cs"
            int value_index = 0;
            while (true)
            {
#line 896 "ProbabilityModule.cs"
                int csharp2cuda_temp_286 = (first)->count;
                if (!(((value_index) < (csharp2cuda_temp_286))))
                    break;
#line 897 "ProbabilityModule.cs"
                {
#line 898 "ProbabilityModule.cs"
                    int csharp2cuda_temp_287;
#line 898 "ProbabilityModule.cs"
                    if (((order) < (csharp2cuda_i32_add(value_index, 1))))
                    {
#line 898 "ProbabilityModule.cs"
                        csharp2cuda_temp_287 = order;
                    }
                    else
                    {
#line 898 "ProbabilityModule.cs"
                        csharp2cuda_temp_287 = csharp2cuda_i32_add(value_index, 1);
                    }
#line 898 "ProbabilityModule.cs"
                    int maximum = csharp2cuda_temp_287;
#line 899 "ProbabilityModule.cs"
                    {
#line 899 "ProbabilityModule.cs"
                        int degree = maximum;
                        while (true)
                        {
                            if (!(((degree) >= (1))))
                                break;
#line 900 "ProbabilityModule.cs"
#line 900 "ProbabilityModule.cs"
                            float* csharp2cuda_temp_289 = &((scratch)[degree]);
#line 900 "ProbabilityModule.cs"
                            float csharp2cuda_temp_290 = *(csharp2cuda_temp_289);
#line 900 "ProbabilityModule.cs"
                            float csharp2cuda_temp_291 = (a)[value_index];
#line 900 "ProbabilityModule.cs"
                            float csharp2cuda_temp_292 = (scratch)[csharp2cuda_i32_sub(degree, 1)];
                            (*(csharp2cuda_temp_289) = __fadd_rn(csharp2cuda_temp_290, __fmul_rn(csharp2cuda_temp_291, csharp2cuda_temp_292)));
#line 899 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_288 = &(degree);
                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_288));
                        }
                    }
                }
#line 896 "ProbabilityModule.cs"
                int* csharp2cuda_temp_285 = &(value_index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_285));
            }
        }
#line 902 "ProbabilityModule.cs"
#line 902 "ProbabilityModule.cs"
        float* csharp2cuda_temp_293 = &((output)->scalar_value);
#line 902 "ProbabilityModule.cs"
        float csharp2cuda_temp_294 = (scratch)[order];
        (*(csharp2cuda_temp_293) = csharp2cuda_temp_294);
#line 903 "ProbabilityModule.cs"
#line 903 "ProbabilityModule.cs"
        float csharp2cuda_temp_295 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_295))))
        {
#line 903 "ProbabilityModule.cs"
#line 903 "ProbabilityModule.cs"
            int* csharp2cuda_temp_296 = &((output)->valid);
            (*(csharp2cuda_temp_296) = 0);
        }
#line 904 "ProbabilityModule.cs"
        return;
    }
#line 907 "ProbabilityModule.cs"
    if (((opcode) == (21)))
#line 908 "ProbabilityModule.cs"
    {
#line 909 "ProbabilityModule.cs"
        float value = 0.0f;
#line 910 "ProbabilityModule.cs"
        {
#line 910 "ProbabilityModule.cs"
            int csharp2cuda_temp_297 = (first)->count;
#line 910 "ProbabilityModule.cs"
            int index = csharp2cuda_i32_sub(csharp2cuda_temp_297, 1);
            while (true)
            {
                if (!(((index) >= (0))))
                    break;
#line 911 "ProbabilityModule.cs"
#line 911 "ProbabilityModule.cs"
                float* csharp2cuda_temp_299 = &(value);
#line 911 "ProbabilityModule.cs"
                float csharp2cuda_temp_300 = (second)->scalar_value;
#line 911 "ProbabilityModule.cs"
                float csharp2cuda_temp_301 = (a)[index];
                (*(csharp2cuda_temp_299) = __fadd_rn(__fmul_rn(value, csharp2cuda_temp_300), csharp2cuda_temp_301));
#line 910 "ProbabilityModule.cs"
                int* csharp2cuda_temp_298 = &(index);
                csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_298));
            }
        }
#line 912 "ProbabilityModule.cs"
#line 912 "ProbabilityModule.cs"
        float* csharp2cuda_temp_302 = &((output)->scalar_value);
        (*(csharp2cuda_temp_302) = value);
#line 913 "ProbabilityModule.cs"
        if ((!(isfinite(value))))
        {
#line 913 "ProbabilityModule.cs"
#line 913 "ProbabilityModule.cs"
            int* csharp2cuda_temp_303 = &((output)->valid);
            (*(csharp2cuda_temp_303) = 0);
        }
#line 914 "ProbabilityModule.cs"
        return;
    }
#line 917 "ProbabilityModule.cs"
    if (((opcode) == (22)))
#line 918 "ProbabilityModule.cs"
    {
#line 919 "ProbabilityModule.cs"
#line 919 "ProbabilityModule.cs"
        int csharp2cuda_temp_304 = (first)->count;
        if (((csharp2cuda_temp_304) <= (0)))
#line 920 "ProbabilityModule.cs"
        {
#line 921 "ProbabilityModule.cs"
#line 921 "ProbabilityModule.cs"
            int* csharp2cuda_temp_305 = &((output)->valid);
            (*(csharp2cuda_temp_305) = 0);
#line 922 "ProbabilityModule.cs"
            return;
        }
#line 924 "ProbabilityModule.cs"
        float maximum = (a)[0];
#line 925 "ProbabilityModule.cs"
        {
#line 925 "ProbabilityModule.cs"
            int index = 1;
            while (true)
            {
#line 925 "ProbabilityModule.cs"
                int csharp2cuda_temp_307 = (first)->count;
                if (!(((index) < (csharp2cuda_temp_307))))
                    break;
#line 926 "ProbabilityModule.cs"
#line 926 "ProbabilityModule.cs"
                float* csharp2cuda_temp_308 = &(maximum);
#line 926 "ProbabilityModule.cs"
                float csharp2cuda_temp_309 = (a)[index];
                (*(csharp2cuda_temp_308) = mathblocks_maximum(maximum, csharp2cuda_temp_309));
#line 925 "ProbabilityModule.cs"
                int* csharp2cuda_temp_306 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_306));
            }
        }
#line 927 "ProbabilityModule.cs"
        float sum = 0.0f;
#line 928 "ProbabilityModule.cs"
        {
#line 928 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
#line 928 "ProbabilityModule.cs"
                int csharp2cuda_temp_311 = (first)->count;
                if (!(((index) < (csharp2cuda_temp_311))))
                    break;
#line 929 "ProbabilityModule.cs"
#line 929 "ProbabilityModule.cs"
                float* csharp2cuda_temp_312 = &(sum);
#line 929 "ProbabilityModule.cs"
                float csharp2cuda_temp_313 = *(csharp2cuda_temp_312);
#line 929 "ProbabilityModule.cs"
                float csharp2cuda_temp_314 = (a)[index];
                (*(csharp2cuda_temp_312) = __fadd_rn(csharp2cuda_temp_313, mathblocks_exponential(__fsub_rn(csharp2cuda_temp_314, maximum))));
#line 928 "ProbabilityModule.cs"
                int* csharp2cuda_temp_310 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_310));
            }
        }
#line 930 "ProbabilityModule.cs"
#line 930 "ProbabilityModule.cs"
        float* csharp2cuda_temp_315 = &((output)->scalar_value);
        (*(csharp2cuda_temp_315) = __fadd_rn(maximum, mathblocks_natural_logarithm(sum)));
#line 931 "ProbabilityModule.cs"
#line 931 "ProbabilityModule.cs"
        float csharp2cuda_temp_316 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_316))))
        {
#line 931 "ProbabilityModule.cs"
#line 931 "ProbabilityModule.cs"
            int* csharp2cuda_temp_317 = &((output)->valid);
            (*(csharp2cuda_temp_317) = 0);
        }
#line 932 "ProbabilityModule.cs"
        return;
    }
#line 935 "ProbabilityModule.cs"
#line 935 "ProbabilityModule.cs"
    int* csharp2cuda_temp_318 = &((output)->valid);
    (*(csharp2cuda_temp_318) = 0);
}

#line 193 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_distribution(const float* values, int count)
#line 195 "ProbabilityModule.cs"
{
#line 196 "ProbabilityModule.cs"
    if (((count) <= (0)))
    {
#line 197 "ProbabilityModule.cs"
        return false;
    }
#line 198 "ProbabilityModule.cs"
    {
#line 198 "ProbabilityModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 199 "ProbabilityModule.cs"
#line 199 "ProbabilityModule.cs"
            float csharp2cuda_temp_1 = (values)[index];
            if (((csharp2cuda_temp_1) < (0.0f)))
            {
#line 199 "ProbabilityModule.cs"
                return false;
            }
#line 198 "ProbabilityModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 200 "ProbabilityModule.cs"
    return ((fabsf(__fsub_rn(mathblocks_compensated_sum(values, count), 1.0f))) <= (1E-05f));
}

#line 203 "ProbabilityModule.cs"
__device__ float mathblocks_probability_entropy(const float* values, int count)
#line 205 "ProbabilityModule.cs"
{
#line 206 "ProbabilityModule.cs"
    float entropy = 0.0f;
#line 207 "ProbabilityModule.cs"
    {
#line 207 "ProbabilityModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 208 "ProbabilityModule.cs"
#line 208 "ProbabilityModule.cs"
            float csharp2cuda_temp_1 = (values)[index];
            if (((csharp2cuda_temp_1) > (0.0f)))
            {
#line 209 "ProbabilityModule.cs"
#line 209 "ProbabilityModule.cs"
                float* csharp2cuda_temp_2 = &(entropy);
#line 209 "ProbabilityModule.cs"
                float csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 209 "ProbabilityModule.cs"
                float csharp2cuda_temp_4 = (values)[index];
#line 209 "ProbabilityModule.cs"
                float csharp2cuda_temp_5 = (values)[index];
                (*(csharp2cuda_temp_2) = __fsub_rn(csharp2cuda_temp_3, __fmul_rn(csharp2cuda_temp_4, mathblocks_natural_logarithm(csharp2cuda_temp_5))));
            }
#line 207 "ProbabilityModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 210 "ProbabilityModule.cs"
    return entropy;
}

#line 314 "ProbabilityModule.cs"
__device__ float mathblocks_probability_incomplete_beta(
    float x,
    float left,
    float right,
    bool* converged)
#line 320 "ProbabilityModule.cs"
{
#line 321 "ProbabilityModule.cs"
#line 321 "ProbabilityModule.cs"
    bool* csharp2cuda_temp_0 = converged;
    (*(csharp2cuda_temp_0) = true);
#line 322 "ProbabilityModule.cs"
    if (((x) == (0.0f)))
    {
#line 322 "ProbabilityModule.cs"
        return 0.0f;
    }
#line 323 "ProbabilityModule.cs"
    if (((x) == (1.0f)))
    {
#line 323 "ProbabilityModule.cs"
        return 1.0f;
    }
#line 324 "ProbabilityModule.cs"
    float front = mathblocks_exponential(__fadd_rn(__fadd_rn(__fsub_rn(__fsub_rn(mathblocks_probability_log_gamma(__fadd_rn(left, right)), mathblocks_probability_log_gamma(left)), mathblocks_probability_log_gamma(right)), __fmul_rn(left, mathblocks_natural_logarithm(x))), __fmul_rn(right, mathblocks_log_one_plus((-(x))))));
#line 330 "ProbabilityModule.cs"
#line 330 "ProbabilityModule.cs"
    float csharp2cuda_temp_1 = __fdiv_rn(__fadd_rn(left, 1.0f), __fadd_rn(__fadd_rn(left, right), 2.0f));
#line 330 "ProbabilityModule.cs"
    float csharp2cuda_temp_2;
#line 330 "ProbabilityModule.cs"
    if (((x) < (csharp2cuda_temp_1)))
    {
#line 331 "ProbabilityModule.cs"
        float csharp2cuda_temp_3 = mathblocks_probability_beta_fraction(x, left, right, converged);
#line 330 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = __fdiv_rn(__fmul_rn(front, csharp2cuda_temp_3), left);
    }
    else
    {
#line 332 "ProbabilityModule.cs"
        float csharp2cuda_temp_4 = mathblocks_probability_beta_fraction(__fsub_rn(1.0f, x), right, left, converged);
#line 332 "ProbabilityModule.cs"
        float csharp2cuda_temp_5 = __fdiv_rn(__fmul_rn(front, csharp2cuda_temp_4), right);
#line 330 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = __fsub_rn(1.0f, csharp2cuda_temp_5);
    }
    return csharp2cuda_temp_2;
}

#line 124 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_integer(float value, int* result)
#line 126 "ProbabilityModule.cs"
{
#line 127 "ProbabilityModule.cs"
#line 127 "ProbabilityModule.cs"
    bool csharp2cuda_temp_0;
#line 127 "ProbabilityModule.cs"
    if (!(((value) < ((-(2.1474836E+09f))))))
    {
#line 127 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = ((value) > (2.1474836E+09f));
    }
    else
    {
#line 127 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 127 "ProbabilityModule.cs"
    bool csharp2cuda_temp_1;
#line 127 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_0))
    {
#line 127 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = ((value) != (truncf(value)));
    }
    else
    {
#line 127 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = true;
    }
    if (csharp2cuda_temp_1)
    {
#line 128 "ProbabilityModule.cs"
        return false;
    }
#line 129 "ProbabilityModule.cs"
#line 129 "ProbabilityModule.cs"
    int* csharp2cuda_temp_2 = result;
    (*(csharp2cuda_temp_2) = csharp2cuda_f64_to_i32(value));
#line 130 "ProbabilityModule.cs"
    return true;
}

#line 213 "ProbabilityModule.cs"
__device__ float mathblocks_probability_kl(
    const float* probabilities,
    const float* reference,
    int count)
#line 218 "ProbabilityModule.cs"
{
#line 219 "ProbabilityModule.cs"
    float result = 0.0f;
#line 220 "ProbabilityModule.cs"
    {
#line 220 "ProbabilityModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 221 "ProbabilityModule.cs"
#line 221 "ProbabilityModule.cs"
            float csharp2cuda_temp_1 = (probabilities)[index];
            if (((csharp2cuda_temp_1) > (0.0f)))
            {
#line 222 "ProbabilityModule.cs"
#line 222 "ProbabilityModule.cs"
                float* csharp2cuda_temp_2 = &(result);
#line 222 "ProbabilityModule.cs"
                float csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 222 "ProbabilityModule.cs"
                float csharp2cuda_temp_4 = (probabilities)[index];
#line 223 "ProbabilityModule.cs"
                float csharp2cuda_temp_5 = (probabilities)[index];
#line 223 "ProbabilityModule.cs"
                float csharp2cuda_temp_6 = (reference)[index];
#line 223 "ProbabilityModule.cs"
                float csharp2cuda_temp_7 = __fdiv_rn(csharp2cuda_temp_5, csharp2cuda_temp_6);
                (*(csharp2cuda_temp_2) = __fadd_rn(csharp2cuda_temp_3, __fmul_rn(csharp2cuda_temp_4, mathblocks_natural_logarithm(csharp2cuda_temp_7))));
            }
#line 220 "ProbabilityModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 224 "ProbabilityModule.cs"
    return result;
}

#line 254 "ProbabilityModule.cs"
__device__ float mathblocks_probability_log_gamma(float value)
#line 256 "ProbabilityModule.cs"
{
#line 258 "ProbabilityModule.cs"
#line 258 "ProbabilityModule.cs"
    bool csharp2cuda_temp_0;
#line 258 "ProbabilityModule.cs"
    if (((value) <= (0.0f)))
    {
#line 258 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = ((value) == (floorf(value)));
    }
    else
    {
#line 258 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = false;
    }
    if (csharp2cuda_temp_0)
    {
#line 259 "ProbabilityModule.cs"
        return __int_as_float(2143289344);
    }
#line 260 "ProbabilityModule.cs"
    if (((value) < (0.5f)))
#line 261 "ProbabilityModule.cs"
    {
#line 262 "ProbabilityModule.cs"
        return __fsub_rn(__fsub_rn(mathblocks_natural_logarithm(3.1415927f), mathblocks_natural_logarithm(fabsf(mathblocks_sine(__fmul_rn(3.1415927f, value))))), mathblocks_probability_log_gamma_core(__fsub_rn(1.0f, value)));
    }
#line 267 "ProbabilityModule.cs"
    return mathblocks_probability_log_gamma_core(value);
}

#line 227 "ProbabilityModule.cs"
__device__ float mathblocks_probability_log_gamma_core(float value)
#line 229 "ProbabilityModule.cs"
{
#line 230 "ProbabilityModule.cs"
    const float csharp2cuda_temp_0_storage[8] = { 676.5204f, -1259.1392f, 771.3234f, -176.61504f, 12.507343f, -0.1385711f, 9.984369E-06f, 1.5056327E-07f };
    csharp2cuda_readonly_array_view<float> coefficients(csharp2cuda_temp_0_storage, 8, false);
#line 241 "ProbabilityModule.cs"
#line 241 "ProbabilityModule.cs"
    float* csharp2cuda_temp_1 = &(value);
#line 241 "ProbabilityModule.cs"
    float csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
    (*(csharp2cuda_temp_1) = __fsub_rn(csharp2cuda_temp_2, 1.0f));
#line 242 "ProbabilityModule.cs"
    float sum = 1.0f;
#line 243 "ProbabilityModule.cs"
    {
#line 243 "ProbabilityModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (8))))
                break;
#line 244 "ProbabilityModule.cs"
#line 244 "ProbabilityModule.cs"
            float* csharp2cuda_temp_4 = &(sum);
#line 244 "ProbabilityModule.cs"
            float csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
#line 244 "ProbabilityModule.cs"
            float csharp2cuda_temp_6 = (coefficients)[index];
#line 244 "ProbabilityModule.cs"
            float csharp2cuda_temp_7 = __fdiv_rn(csharp2cuda_temp_6, __fadd_rn(__fadd_rn(value, ((float)(index))), 1.0f));
            (*(csharp2cuda_temp_4) = __fadd_rn(csharp2cuda_temp_5, csharp2cuda_temp_7));
#line 243 "ProbabilityModule.cs"
            int* csharp2cuda_temp_3 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
        }
    }
#line 246 "ProbabilityModule.cs"
    float shifted = __fadd_rn(value, 8.0f);
#line 247 "ProbabilityModule.cs"
    float t = __fsub_rn(shifted, 0.5f);
#line 248 "ProbabilityModule.cs"
    return __fadd_rn(__fsub_rn(__fadd_rn(__fmul_rn(0.5f, mathblocks_natural_logarithm(__fmul_rn(2.0f, 3.1415927f))), __fmul_rn(__fadd_rn(value, 0.5f), mathblocks_natural_logarithm(t))), t), mathblocks_natural_logarithm(sum));
}

#line 348 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_ordered_entropy_value(
    const float* values,
    int count,
    float order,
    bool renyi,
    float* value)
#line 355 "ProbabilityModule.cs"
{
#line 356 "ProbabilityModule.cs"
    if (((order) <= (0.0f)))
    {
#line 357 "ProbabilityModule.cs"
        return false;
    }
#line 358 "ProbabilityModule.cs"
    if (((order) == (1.0f)))
#line 359 "ProbabilityModule.cs"
    {
#line 360 "ProbabilityModule.cs"
#line 360 "ProbabilityModule.cs"
        float* csharp2cuda_temp_0 = value;
#line 360 "ProbabilityModule.cs"
        float csharp2cuda_temp_1 = mathblocks_probability_entropy(values, count);
        (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
    }
    else
#line 363 "ProbabilityModule.cs"
    {
#line 364 "ProbabilityModule.cs"
        float sum = 0.0f;
#line 365 "ProbabilityModule.cs"
        {
#line 365 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 366 "ProbabilityModule.cs"
#line 366 "ProbabilityModule.cs"
                float* csharp2cuda_temp_3 = &(sum);
#line 366 "ProbabilityModule.cs"
                float csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 366 "ProbabilityModule.cs"
                float csharp2cuda_temp_5 = (values)[index];
                (*(csharp2cuda_temp_3) = __fadd_rn(csharp2cuda_temp_4, mathblocks_power(csharp2cuda_temp_5, order)));
#line 365 "ProbabilityModule.cs"
                int* csharp2cuda_temp_2 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
            }
        }
#line 367 "ProbabilityModule.cs"
#line 367 "ProbabilityModule.cs"
        float* csharp2cuda_temp_6 = value;
#line 367 "ProbabilityModule.cs"
        float csharp2cuda_temp_7;
#line 367 "ProbabilityModule.cs"
        if (renyi)
        {
#line 367 "ProbabilityModule.cs"
            csharp2cuda_temp_7 = __fdiv_rn(mathblocks_natural_logarithm(sum), __fsub_rn(1.0f, order));
        }
        else
        {
#line 367 "ProbabilityModule.cs"
            csharp2cuda_temp_7 = __fdiv_rn(__fsub_rn(1.0f, sum), __fsub_rn(order, 1.0f));
        }
        (*(csharp2cuda_temp_6) = csharp2cuda_temp_7);
    }
#line 371 "ProbabilityModule.cs"
    return true;
}

#line 378 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_scalar_value(int opcode, float a, float b, float c, float* value, bool* converged)
#line 380 "ProbabilityModule.cs"
{
#line 381 "ProbabilityModule.cs"
#line 381 "ProbabilityModule.cs"
    float* csharp2cuda_temp_0 = value;
    (*(csharp2cuda_temp_0) = 0.0f);
#line 382 "ProbabilityModule.cs"
#line 382 "ProbabilityModule.cs"
    bool* csharp2cuda_temp_1 = converged;
    (*(csharp2cuda_temp_1) = true);
#line 383 "ProbabilityModule.cs"
#line 383 "ProbabilityModule.cs"
    bool csharp2cuda_temp_2;
#line 383 "ProbabilityModule.cs"
    if (!(((opcode) == (0))))
    {
#line 383 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = ((opcode) == (1));
    }
    else
    {
#line 383 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = true;
    }
#line 383 "ProbabilityModule.cs"
    bool csharp2cuda_temp_3;
#line 383 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_2))
    {
#line 383 "ProbabilityModule.cs"
        csharp2cuda_temp_3 = ((opcode) == (2));
    }
    else
    {
#line 383 "ProbabilityModule.cs"
        csharp2cuda_temp_3 = true;
    }
    if (csharp2cuda_temp_3)
#line 384 "ProbabilityModule.cs"
    {
#line 385 "ProbabilityModule.cs"
        int first_integer = 0;
#line 386 "ProbabilityModule.cs"
        int second_integer = 0;
#line 387 "ProbabilityModule.cs"
#line 387 "ProbabilityModule.cs"
        int* csharp2cuda_temp_4 = &(first_integer);
#line 387 "ProbabilityModule.cs"
        bool csharp2cuda_temp_5 = mathblocks_probability_integer(a, csharp2cuda_temp_4);
#line 387 "ProbabilityModule.cs"
        bool csharp2cuda_temp_6;
#line 387 "ProbabilityModule.cs"
        if (!((!(csharp2cuda_temp_5))))
        {
#line 387 "ProbabilityModule.cs"
            csharp2cuda_temp_6 = ((first_integer) < (0));
        }
        else
        {
#line 387 "ProbabilityModule.cs"
            csharp2cuda_temp_6 = true;
        }
#line 387 "ProbabilityModule.cs"
        bool csharp2cuda_temp_7;
#line 387 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_6))
        {
#line 388 "ProbabilityModule.cs"
            bool csharp2cuda_temp_8;
#line 388 "ProbabilityModule.cs"
            if (((opcode) != (2)))
            {
#line 388 "ProbabilityModule.cs"
                int* csharp2cuda_temp_9 = &(second_integer);
#line 388 "ProbabilityModule.cs"
                bool csharp2cuda_temp_10 = mathblocks_probability_integer(b, csharp2cuda_temp_9);
#line 388 "ProbabilityModule.cs"
                csharp2cuda_temp_8 = (!(csharp2cuda_temp_10));
            }
            else
            {
#line 388 "ProbabilityModule.cs"
                csharp2cuda_temp_8 = false;
            }
#line 387 "ProbabilityModule.cs"
            csharp2cuda_temp_7 = csharp2cuda_temp_8;
        }
        else
        {
#line 387 "ProbabilityModule.cs"
            csharp2cuda_temp_7 = true;
        }
#line 387 "ProbabilityModule.cs"
        bool csharp2cuda_temp_11;
#line 387 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_7))
        {
#line 389 "ProbabilityModule.cs"
            bool csharp2cuda_temp_12;
#line 389 "ProbabilityModule.cs"
            if (((opcode) == (2)))
            {
#line 389 "ProbabilityModule.cs"
                csharp2cuda_temp_12 = ((first_integer) > (170));
            }
            else
            {
#line 389 "ProbabilityModule.cs"
                csharp2cuda_temp_12 = false;
            }
#line 387 "ProbabilityModule.cs"
            csharp2cuda_temp_11 = csharp2cuda_temp_12;
        }
        else
        {
#line 387 "ProbabilityModule.cs"
            csharp2cuda_temp_11 = true;
        }
#line 387 "ProbabilityModule.cs"
        bool csharp2cuda_temp_13;
#line 387 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_11))
        {
#line 390 "ProbabilityModule.cs"
            bool csharp2cuda_temp_14;
#line 390 "ProbabilityModule.cs"
            if (((opcode) == (0)))
            {
#line 390 "ProbabilityModule.cs"
                bool csharp2cuda_temp_15;
#line 390 "ProbabilityModule.cs"
                if (!(((first_integer) <= (second_integer))))
                {
#line 390 "ProbabilityModule.cs"
                    csharp2cuda_temp_15 = ((second_integer) < (0));
                }
                else
                {
#line 390 "ProbabilityModule.cs"
                    csharp2cuda_temp_15 = true;
                }
#line 390 "ProbabilityModule.cs"
                csharp2cuda_temp_14 = csharp2cuda_temp_15;
            }
            else
            {
#line 390 "ProbabilityModule.cs"
                csharp2cuda_temp_14 = false;
            }
#line 387 "ProbabilityModule.cs"
            csharp2cuda_temp_13 = csharp2cuda_temp_14;
        }
        else
        {
#line 387 "ProbabilityModule.cs"
            csharp2cuda_temp_13 = true;
        }
        if (csharp2cuda_temp_13)
#line 391 "ProbabilityModule.cs"
        {
#line 392 "ProbabilityModule.cs"
            return false;
        }
#line 394 "ProbabilityModule.cs"
        if (((opcode) == (0)))
#line 395 "ProbabilityModule.cs"
        {
#line 396 "ProbabilityModule.cs"
            long long total = csharp2cuda_i64_add(((long long)(first_integer)), ((long long)(second_integer)));
#line 397 "ProbabilityModule.cs"
#line 397 "ProbabilityModule.cs"
            float* csharp2cuda_temp_16 = value;
#line 397 "ProbabilityModule.cs"
            float csharp2cuda_temp_17 = __fdiv_rn(((float)(csharp2cuda_i32_sub(first_integer, second_integer))), ((float)(total)));
#line 399 "ProbabilityModule.cs"
            float csharp2cuda_temp_18 = mathblocks_probability_binomial_memo(total, second_integer);
            (*(csharp2cuda_temp_16) = __fmul_rn(csharp2cuda_temp_17, csharp2cuda_temp_18));
        }
        else
        {
#line 401 "ProbabilityModule.cs"
            if (((opcode) == (1)))
#line 402 "ProbabilityModule.cs"
            {
#line 403 "ProbabilityModule.cs"
#line 403 "ProbabilityModule.cs"
                float* csharp2cuda_temp_19 = value;
#line 403 "ProbabilityModule.cs"
                float csharp2cuda_temp_20 = mathblocks_probability_binomial_memo(((long long)(first_integer)), second_integer);
                (*(csharp2cuda_temp_19) = csharp2cuda_temp_20);
            }
            else
#line 406 "ProbabilityModule.cs"
            {
#line 407 "ProbabilityModule.cs"
                float factorial = 1.0f;
#line 408 "ProbabilityModule.cs"
                {
#line 408 "ProbabilityModule.cs"
                    int index = 2;
                    while (true)
                    {
                        if (!(((index) <= (first_integer))))
                            break;
#line 408 "ProbabilityModule.cs"
#line 408 "ProbabilityModule.cs"
                        float* csharp2cuda_temp_22 = &(factorial);
#line 408 "ProbabilityModule.cs"
                        float csharp2cuda_temp_23 = *(csharp2cuda_temp_22);
                        (*(csharp2cuda_temp_22) = __fmul_rn(csharp2cuda_temp_23, ((float)(index))));
#line 408 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_21 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_21));
                    }
                }
#line 409 "ProbabilityModule.cs"
#line 409 "ProbabilityModule.cs"
                float* csharp2cuda_temp_24 = value;
                (*(csharp2cuda_temp_24) = factorial);
            }
        }
#line 411 "ProbabilityModule.cs"
#line 411 "ProbabilityModule.cs"
        float csharp2cuda_temp_25 = *(value);
        return isfinite(csharp2cuda_temp_25);
    }
#line 414 "ProbabilityModule.cs"
    if (((opcode) == (23)))
#line 415 "ProbabilityModule.cs"
    {
#line 416 "ProbabilityModule.cs"
#line 416 "ProbabilityModule.cs"
        float* csharp2cuda_temp_26 = value;
#line 416 "ProbabilityModule.cs"
        float csharp2cuda_temp_27 = __fdiv_rn(a, mathblocks_square_root(2.0f));
        (*(csharp2cuda_temp_26) = __fmul_rn(0.5f, __fadd_rn(1.0f, mathblocks_error_function(csharp2cuda_temp_27))));
#line 417 "ProbabilityModule.cs"
#line 417 "ProbabilityModule.cs"
        float csharp2cuda_temp_28 = *(value);
        return isfinite(csharp2cuda_temp_28);
    }
#line 420 "ProbabilityModule.cs"
#line 420 "ProbabilityModule.cs"
    bool csharp2cuda_temp_29;
#line 420 "ProbabilityModule.cs"
    if (!(((opcode) == (25))))
    {
#line 420 "ProbabilityModule.cs"
        csharp2cuda_temp_29 = ((opcode) == (26));
    }
    else
    {
#line 420 "ProbabilityModule.cs"
        csharp2cuda_temp_29 = true;
    }
    if (csharp2cuda_temp_29)
#line 421 "ProbabilityModule.cs"
    {
#line 422 "ProbabilityModule.cs"
        int count = 0;
#line 423 "ProbabilityModule.cs"
        float rate = a;
#line 424 "ProbabilityModule.cs"
#line 424 "ProbabilityModule.cs"
        int* csharp2cuda_temp_30 = &(count);
#line 424 "ProbabilityModule.cs"
        bool csharp2cuda_temp_31 = mathblocks_probability_integer(b, csharp2cuda_temp_30);
#line 424 "ProbabilityModule.cs"
        bool csharp2cuda_temp_32;
#line 424 "ProbabilityModule.cs"
        if (!((!(csharp2cuda_temp_31))))
        {
#line 424 "ProbabilityModule.cs"
            csharp2cuda_temp_32 = ((count) < (0));
        }
        else
        {
#line 424 "ProbabilityModule.cs"
            csharp2cuda_temp_32 = true;
        }
#line 424 "ProbabilityModule.cs"
        bool csharp2cuda_temp_33;
#line 424 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_32))
        {
#line 424 "ProbabilityModule.cs"
            csharp2cuda_temp_33 = ((rate) < (0.0f));
        }
        else
        {
#line 424 "ProbabilityModule.cs"
            csharp2cuda_temp_33 = true;
        }
        if (csharp2cuda_temp_33)
        {
#line 425 "ProbabilityModule.cs"
            return false;
        }
#line 426 "ProbabilityModule.cs"
        float sum = 0.0f;
#line 427 "ProbabilityModule.cs"
#line 427 "ProbabilityModule.cs"
        bool csharp2cuda_temp_34;
#line 427 "ProbabilityModule.cs"
        if (((opcode) == (25)))
        {
#line 427 "ProbabilityModule.cs"
            csharp2cuda_temp_34 = ((rate) == (0.0f));
        }
        else
        {
#line 427 "ProbabilityModule.cs"
            csharp2cuda_temp_34 = false;
        }
        if (csharp2cuda_temp_34)
#line 428 "ProbabilityModule.cs"
        {
#line 430 "ProbabilityModule.cs"
#line 430 "ProbabilityModule.cs"
            float* csharp2cuda_temp_35 = &(sum);
            (*(csharp2cuda_temp_35) = 1.0f);
        }
        else
        {
#line 432 "ProbabilityModule.cs"
            if (((opcode) == (25)))
#line 433 "ProbabilityModule.cs"
            {
#line 437 "ProbabilityModule.cs"
                float log_rate = mathblocks_natural_logarithm(rate);
#line 438 "ProbabilityModule.cs"
                int csharp2cuda_temp_36;
#line 438 "ProbabilityModule.cs"
                if (((rate) < (((float)(count)))))
                {
#line 438 "ProbabilityModule.cs"
                    csharp2cuda_temp_36 = csharp2cuda_f64_to_i32(rate);
                }
                else
                {
#line 438 "ProbabilityModule.cs"
                    csharp2cuda_temp_36 = count;
                }
#line 438 "ProbabilityModule.cs"
                int peak = csharp2cuda_temp_36;
#line 439 "ProbabilityModule.cs"
                int first = 0;
#line 440 "ProbabilityModule.cs"
                bool reached = ((__fsub_rn(__fadd_rn((-(rate)), __fmul_rn(((float)(peak)), log_rate)), mathblocks_probability_log_gamma(__fadd_rn(((float)(peak)), 1.0f)))) >= ((-(104.0f))));
#line 441 "ProbabilityModule.cs"
                if (reached)
#line 442 "ProbabilityModule.cs"
                {
#line 443 "ProbabilityModule.cs"
                    int high = peak;
#line 444 "ProbabilityModule.cs"
                    while (true)
                    {
                        if (!(((first) < (high))))
                            break;
#line 445 "ProbabilityModule.cs"
                        {
#line 446 "ProbabilityModule.cs"
                            int csharp2cuda_temp_37 = csharp2cuda_i32_div(csharp2cuda_i32_sub(high, first), 2);
#line 446 "ProbabilityModule.cs"
                            int middle = csharp2cuda_i32_add(first, csharp2cuda_temp_37);
#line 447 "ProbabilityModule.cs"
                            if (((__fsub_rn(__fadd_rn((-(rate)), __fmul_rn(((float)(middle)), log_rate)), mathblocks_probability_log_gamma(__fadd_rn(((float)(middle)), 1.0f)))) >= ((-(104.0f)))))
                            {
#line 448 "ProbabilityModule.cs"
#line 448 "ProbabilityModule.cs"
                                int* csharp2cuda_temp_38 = &(high);
                                (*(csharp2cuda_temp_38) = middle);
                            }
                            else
                            {
#line 450 "ProbabilityModule.cs"
#line 450 "ProbabilityModule.cs"
                                int* csharp2cuda_temp_39 = &(first);
                                (*(csharp2cuda_temp_39) = csharp2cuda_i32_add(middle, 1));
                            }
                        }
                    }
#line 452 "ProbabilityModule.cs"
                    {
#line 452 "ProbabilityModule.cs"
                        int index = first;
                        while (true)
                        {
                            if (!(((index) <= (count))))
                                break;
#line 453 "ProbabilityModule.cs"
                            {
#line 454 "ProbabilityModule.cs"
                                float exponent = __fsub_rn(__fadd_rn((-(rate)), __fmul_rn(((float)(index)), log_rate)), mathblocks_probability_log_gamma(__fadd_rn(((float)(index)), 1.0f)));
#line 455 "ProbabilityModule.cs"
#line 455 "ProbabilityModule.cs"
                                bool csharp2cuda_temp_41;
#line 455 "ProbabilityModule.cs"
                                if (((((float)(index))) > (rate)))
                                {
#line 455 "ProbabilityModule.cs"
                                    csharp2cuda_temp_41 = ((exponent) < ((-(104.0f))));
                                }
                                else
                                {
#line 455 "ProbabilityModule.cs"
                                    csharp2cuda_temp_41 = false;
                                }
                                if (csharp2cuda_temp_41)
                                {
#line 456 "ProbabilityModule.cs"
                                    break;
                                }
#line 458 "ProbabilityModule.cs"
                                float next_sum = __fadd_rn(sum, mathblocks_exponential(exponent));
#line 459 "ProbabilityModule.cs"
#line 459 "ProbabilityModule.cs"
                                bool csharp2cuda_temp_42;
#line 459 "ProbabilityModule.cs"
                                if (((((float)(index))) > (rate)))
                                {
#line 459 "ProbabilityModule.cs"
                                    csharp2cuda_temp_42 = ((next_sum) == (sum));
                                }
                                else
                                {
#line 459 "ProbabilityModule.cs"
                                    csharp2cuda_temp_42 = false;
                                }
                                if (csharp2cuda_temp_42)
                                {
#line 460 "ProbabilityModule.cs"
                                    break;
                                }
#line 461 "ProbabilityModule.cs"
#line 461 "ProbabilityModule.cs"
                                float* csharp2cuda_temp_43 = &(sum);
                                (*(csharp2cuda_temp_43) = next_sum);
                            }
#line 452 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_40 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_40));
                        }
                    }
                }
            }
            else
#line 466 "ProbabilityModule.cs"
            {
#line 467 "ProbabilityModule.cs"
                {
#line 467 "ProbabilityModule.cs"
                    int index = count;
                    while (true)
                    {
                        if (!(((index) <= (count))))
                            break;
#line 468 "ProbabilityModule.cs"
                        {
#line 469 "ProbabilityModule.cs"
                            float csharp2cuda_temp_45;
#line 469 "ProbabilityModule.cs"
                            if (((rate) == (0.0f)))
                            {
#line 470 "ProbabilityModule.cs"
                                float csharp2cuda_temp_46;
#line 470 "ProbabilityModule.cs"
                                if (((index) == (0)))
                                {
#line 470 "ProbabilityModule.cs"
                                    csharp2cuda_temp_46 = 1.0f;
                                }
                                else
                                {
#line 470 "ProbabilityModule.cs"
                                    csharp2cuda_temp_46 = 0.0f;
                                }
#line 469 "ProbabilityModule.cs"
                                csharp2cuda_temp_45 = csharp2cuda_temp_46;
                            }
                            else
                            {
#line 469 "ProbabilityModule.cs"
                                csharp2cuda_temp_45 = mathblocks_exponential(__fsub_rn(__fadd_rn((-(rate)), __fmul_rn(((float)(index)), mathblocks_natural_logarithm(rate))), mathblocks_probability_log_gamma(__fadd_rn(((float)(index)), 1.0f))));
                            }
#line 469 "ProbabilityModule.cs"
                            float probability = csharp2cuda_temp_45;
#line 474 "ProbabilityModule.cs"
#line 474 "ProbabilityModule.cs"
                            float* csharp2cuda_temp_47 = &(sum);
#line 474 "ProbabilityModule.cs"
                            float csharp2cuda_temp_48 = *(csharp2cuda_temp_47);
                            (*(csharp2cuda_temp_47) = __fadd_rn(csharp2cuda_temp_48, probability));
                        }
#line 467 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_44 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_44));
                    }
                }
            }
        }
#line 477 "ProbabilityModule.cs"
#line 477 "ProbabilityModule.cs"
        float* csharp2cuda_temp_49 = value;
        (*(csharp2cuda_temp_49) = sum);
#line 478 "ProbabilityModule.cs"
        return isfinite(sum);
    }
#line 481 "ProbabilityModule.cs"
    if (((opcode) == (28)))
#line 482 "ProbabilityModule.cs"
    {
#line 483 "ProbabilityModule.cs"
#line 483 "ProbabilityModule.cs"
        float* csharp2cuda_temp_50 = value;
        (*(csharp2cuda_temp_50) = mathblocks_exponential(__fsub_rn(__fadd_rn(mathblocks_probability_log_gamma(a), mathblocks_probability_log_gamma(b)), mathblocks_probability_log_gamma(__fadd_rn(a, b)))));
    }
    else
    {
#line 488 "ProbabilityModule.cs"
        if (((opcode) == (29)))
#line 489 "ProbabilityModule.cs"
        {
#line 490 "ProbabilityModule.cs"
#line 490 "ProbabilityModule.cs"
            float* csharp2cuda_temp_51 = value;
            (*(csharp2cuda_temp_51) = mathblocks_probability_log_gamma(a));
        }
        else
        {
#line 492 "ProbabilityModule.cs"
            if (((opcode) == (30)))
#line 493 "ProbabilityModule.cs"
            {
#line 494 "ProbabilityModule.cs"
#line 494 "ProbabilityModule.cs"
                bool csharp2cuda_temp_52;
#line 494 "ProbabilityModule.cs"
                if (!(((a) < (0.0f))))
                {
#line 494 "ProbabilityModule.cs"
                    csharp2cuda_temp_52 = ((a) > (1.0f));
                }
                else
                {
#line 494 "ProbabilityModule.cs"
                    csharp2cuda_temp_52 = true;
                }
#line 494 "ProbabilityModule.cs"
                bool csharp2cuda_temp_53;
#line 494 "ProbabilityModule.cs"
                if (!(csharp2cuda_temp_52))
                {
#line 494 "ProbabilityModule.cs"
                    csharp2cuda_temp_53 = ((b) <= (0.0f));
                }
                else
                {
#line 494 "ProbabilityModule.cs"
                    csharp2cuda_temp_53 = true;
                }
#line 494 "ProbabilityModule.cs"
                bool csharp2cuda_temp_54;
#line 494 "ProbabilityModule.cs"
                if (!(csharp2cuda_temp_53))
                {
#line 494 "ProbabilityModule.cs"
                    csharp2cuda_temp_54 = ((c) <= (0.0f));
                }
                else
                {
#line 494 "ProbabilityModule.cs"
                    csharp2cuda_temp_54 = true;
                }
                if (csharp2cuda_temp_54)
                {
#line 495 "ProbabilityModule.cs"
                    return false;
                }
#line 496 "ProbabilityModule.cs"
#line 496 "ProbabilityModule.cs"
                float* csharp2cuda_temp_55 = value;
#line 496 "ProbabilityModule.cs"
                float csharp2cuda_temp_56 = mathblocks_probability_incomplete_beta(a, b, c, converged);
                (*(csharp2cuda_temp_55) = csharp2cuda_temp_56);
#line 498 "ProbabilityModule.cs"
#line 498 "ProbabilityModule.cs"
                bool csharp2cuda_temp_57 = *(converged);
#line 498 "ProbabilityModule.cs"
                bool csharp2cuda_temp_58;
#line 498 "ProbabilityModule.cs"
                if ((!(csharp2cuda_temp_57)))
                {
#line 498 "ProbabilityModule.cs"
                    csharp2cuda_temp_58 = ((mathblocks_limit_incomplete_beta_policy()) == (1));
                }
                else
                {
#line 498 "ProbabilityModule.cs"
                    csharp2cuda_temp_58 = false;
                }
                if (csharp2cuda_temp_58)
                {
#line 499 "ProbabilityModule.cs"
                    return false;
                }
            }
            else
#line 502 "ProbabilityModule.cs"
            {
#line 503 "ProbabilityModule.cs"
                return false;
            }
        }
    }
#line 505 "ProbabilityModule.cs"
#line 505 "ProbabilityModule.cs"
    float csharp2cuda_temp_59 = *(value);
    return isfinite(csharp2cuda_temp_59);
}