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

struct MathBlockSlot;

#line 9 "ScalarModule.cs"
struct MathBlockSlot
{
    double scalar_value;
    unsigned long long data_pointer;
    unsigned long long scratch_pointer;
    int boolean_value;
    int valid;
    int rows;
    int columns;
    int count;
    int capacity;
};

#line 328 "ScalarModule.cs"
__device__ double mathblocks_arc_cosine(double value);

#line 520 "ScalarModule.cs"
__device__ double mathblocks_arc_sine(double value);

#line 279 "ScalarModule.cs"
__device__ double mathblocks_arc_tangent(double value);

#line 311 "ScalarModule.cs"
__device__ double mathblocks_arc_tangent_2(double y, double x);

#line 126 "ScalarModule.cs"
__device__ double mathblocks_binary_logarithm(double value);

#line 234 "ScalarModule.cs"
__device__ double mathblocks_cosine(double value);

#line 171 "ScalarModule.cs"
__device__ double mathblocks_cube_root(double value);

#line 349 "ScalarModule.cs"
__device__ double mathblocks_error_function(double value);

#line 58 "ScalarModule.cs"
__device__ double mathblocks_exponential(double value);

#line 137 "ScalarModule.cs"
__device__ double mathblocks_integer_power(double value, long long exponent);

#line 338 "ScalarModule.cs"
__device__ double mathblocks_inverse_hyperbolic_sine(double value);

#line 117 "ScalarModule.cs"
__device__ double mathblocks_log_one_plus(double value);

#line 80 "ScalarModule.cs"
__device__ double mathblocks_natural_logarithm(double value);

#line 22 "ScalarModule.cs"
__device__ double mathblocks_positive_infinity();

#line 159 "ScalarModule.cs"
__device__ double mathblocks_power(double value, double exponent);

#line 28 "ScalarModule.cs"
__device__ double mathblocks_quiet_nan();

#line 370 "ScalarModule.cs"
__device__ void mathblocks_scalar_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 183 "ScalarModule.cs"
__device__ double mathblocks_sine(double value);

#line 34 "ScalarModule.cs"
__device__ double mathblocks_square_root(double value);

#line 328 "ScalarModule.cs"
__device__ double mathblocks_arc_cosine(double value)
#line 330 "ScalarModule.cs"
{
#line 331 "ScalarModule.cs"
#line 331 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 331 "ScalarModule.cs"
    if (!(((value) < ((-(1.0))))))
    {
#line 331 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((value) > (1.0));
    }
    else
    {
#line 331 "ScalarModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 332 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 333 "ScalarModule.cs"
    return mathblocks_arc_tangent_2(mathblocks_square_root(__dmul_rn(__dsub_rn(1.0, value), __dadd_rn(1.0, value))), value);
}

#line 520 "ScalarModule.cs"
__device__ double mathblocks_arc_sine(double value)
#line 522 "ScalarModule.cs"
{
#line 523 "ScalarModule.cs"
#line 523 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 523 "ScalarModule.cs"
    if (!(((value) < ((-(1.0))))))
    {
#line 523 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((value) > (1.0));
    }
    else
    {
#line 523 "ScalarModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 523 "ScalarModule.cs"
    bool csharp2cuda_temp_1;
#line 523 "ScalarModule.cs"
    if (!(csharp2cuda_temp_0))
    {
#line 523 "ScalarModule.cs"
        csharp2cuda_temp_1 = isnan(value);
    }
    else
    {
#line 523 "ScalarModule.cs"
        csharp2cuda_temp_1 = true;
    }
    if (csharp2cuda_temp_1)
    {
#line 524 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 525 "ScalarModule.cs"
    return mathblocks_arc_tangent_2(value, mathblocks_square_root(__dmul_rn(__dsub_rn(1.0, value), __dadd_rn(1.0, value))));
}

#line 279 "ScalarModule.cs"
__device__ double mathblocks_arc_tangent(double value)
#line 281 "ScalarModule.cs"
{
#line 283 "ScalarModule.cs"
    if (((value) == (0.0)))
    {
#line 284 "ScalarModule.cs"
        return value;
    }
#line 285 "ScalarModule.cs"
    double csharp2cuda_temp_0;
#line 285 "ScalarModule.cs"
    if (((value) < (0.0)))
    {
#line 285 "ScalarModule.cs"
        csharp2cuda_temp_0 = (-(1.0));
    }
    else
    {
#line 285 "ScalarModule.cs"
        csharp2cuda_temp_0 = 1.0;
    }
#line 285 "ScalarModule.cs"
    double sign = csharp2cuda_temp_0;
#line 286 "ScalarModule.cs"
    double x = fabs(value);
#line 287 "ScalarModule.cs"
    double offset = 0.0;
#line 288 "ScalarModule.cs"
    if (((x) > (2.414213562373095)))
#line 289 "ScalarModule.cs"
    {
#line 290 "ScalarModule.cs"
#line 290 "ScalarModule.cs"
        double* csharp2cuda_temp_1 = &(offset);
#line 290 "ScalarModule.cs"
        double csharp2cuda_temp_2 = __ddiv_rn(3.141592653589793, 2.0);
        (*(csharp2cuda_temp_1) = csharp2cuda_temp_2);
#line 291 "ScalarModule.cs"
#line 291 "ScalarModule.cs"
        double* csharp2cuda_temp_3 = &(x);
#line 291 "ScalarModule.cs"
        double csharp2cuda_temp_4 = __ddiv_rn((-(1.0)), x);
        (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
    }
    else
    {
#line 293 "ScalarModule.cs"
        if (((x) > (0.41421356237309503)))
#line 294 "ScalarModule.cs"
        {
#line 295 "ScalarModule.cs"
#line 295 "ScalarModule.cs"
            double* csharp2cuda_temp_5 = &(offset);
#line 295 "ScalarModule.cs"
            double csharp2cuda_temp_6 = __ddiv_rn(3.141592653589793, 4.0);
            (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 296 "ScalarModule.cs"
#line 296 "ScalarModule.cs"
            double* csharp2cuda_temp_7 = &(x);
#line 296 "ScalarModule.cs"
            double csharp2cuda_temp_8 = __ddiv_rn(__dsub_rn(x, 1.0), __dadd_rn(x, 1.0));
            (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
        }
    }
#line 299 "ScalarModule.cs"
    double z = __dmul_rn(x, x);
#line 300 "ScalarModule.cs"
    double numerator = __dsub_rn(__dmul_rn(__dsub_rn(__dmul_rn(__dsub_rn(__dmul_rn(__dsub_rn(__dmul_rn((-(0.8750608600031904)), z), 16.157537187333652), z), 75.00855792314705), z), 122.88666844901361), z), 64.85021904942025);
#line 304 "ScalarModule.cs"
    double denominator = __dadd_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dadd_rn(z, 24.858464901423062), z), 165.02700983169885), z), 432.88106049129027), z), 485.3903996359137), z), 194.5506571482614);
#line 308 "ScalarModule.cs"
#line 308 "ScalarModule.cs"
    double csharp2cuda_temp_9 = __ddiv_rn(__dmul_rn(__dmul_rn(x, z), numerator), denominator);
    return __dmul_rn(sign, __dadd_rn(__dadd_rn(offset, x), csharp2cuda_temp_9));
}

#line 311 "ScalarModule.cs"
__device__ double mathblocks_arc_tangent_2(double y, double x)
#line 313 "ScalarModule.cs"
{
#line 314 "ScalarModule.cs"
    const double pi = 3.141592653589793;
#line 315 "ScalarModule.cs"
    if (((x) > (0.0)))
    {
#line 316 "ScalarModule.cs"
#line 316 "ScalarModule.cs"
        double csharp2cuda_temp_0 = __ddiv_rn(y, x);
        return mathblocks_arc_tangent(csharp2cuda_temp_0);
    }
#line 317 "ScalarModule.cs"
    if (((x) < (0.0)))
    {
#line 318 "ScalarModule.cs"
#line 318 "ScalarModule.cs"
        double csharp2cuda_temp_1;
#line 318 "ScalarModule.cs"
        if (((y) >= (0.0)))
        {
#line 319 "ScalarModule.cs"
            double csharp2cuda_temp_2 = __ddiv_rn(y, x);
#line 318 "ScalarModule.cs"
            csharp2cuda_temp_1 = __dadd_rn(mathblocks_arc_tangent(csharp2cuda_temp_2), pi);
        }
        else
        {
#line 320 "ScalarModule.cs"
            double csharp2cuda_temp_3 = __ddiv_rn(y, x);
#line 318 "ScalarModule.cs"
            csharp2cuda_temp_1 = __dsub_rn(mathblocks_arc_tangent(csharp2cuda_temp_3), pi);
        }
        return csharp2cuda_temp_1;
    }
#line 321 "ScalarModule.cs"
    if (((y) > (0.0)))
    {
#line 322 "ScalarModule.cs"
        return __ddiv_rn(pi, 2.0);
    }
#line 323 "ScalarModule.cs"
    if (((y) < (0.0)))
    {
#line 324 "ScalarModule.cs"
        return __ddiv_rn((-(pi)), 2.0);
    }
#line 325 "ScalarModule.cs"
    return 0.0;
}

#line 126 "ScalarModule.cs"
__device__ double mathblocks_binary_logarithm(double value)
#line 128 "ScalarModule.cs"
{
#line 129 "ScalarModule.cs"
    unsigned long long bits = ((unsigned long long)(__double_as_longlong(value)));
#line 130 "ScalarModule.cs"
    int exponent = csharp2cuda_i32_from_bits(((csharp2cuda_u64_shr(bits, 52)) & (2047ull)));
#line 131 "ScalarModule.cs"
    unsigned long long fraction = ((bits) & (4503599627370495ull));
#line 132 "ScalarModule.cs"
#line 132 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 132 "ScalarModule.cs"
    if (((exponent) > (0)))
    {
#line 132 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((exponent) < (2047));
    }
    else
    {
#line 132 "ScalarModule.cs"
        csharp2cuda_temp_0 = false;
    }
#line 132 "ScalarModule.cs"
    bool csharp2cuda_temp_1;
#line 132 "ScalarModule.cs"
    if (csharp2cuda_temp_0)
    {
#line 132 "ScalarModule.cs"
        csharp2cuda_temp_1 = ((fraction) == (0ull));
    }
    else
    {
#line 132 "ScalarModule.cs"
        csharp2cuda_temp_1 = false;
    }
    if (csharp2cuda_temp_1)
    {
#line 133 "ScalarModule.cs"
        return ((double)(csharp2cuda_i32_sub(exponent, 1023)));
    }
#line 134 "ScalarModule.cs"
    return __ddiv_rn(mathblocks_natural_logarithm(value), 0.6931471805599453);
}

#line 234 "ScalarModule.cs"
__device__ double mathblocks_cosine(double value)
#line 236 "ScalarModule.cs"
{
#line 237 "ScalarModule.cs"
    double x = fabs(value);
#line 238 "ScalarModule.cs"
    double sign = 1.0;
#line 239 "ScalarModule.cs"
    double csharp2cuda_temp_0 = __ddiv_rn(x, 0.7853981633974483);
#line 239 "ScalarModule.cs"
    double octant_value = floor(csharp2cuda_temp_0);
#line 240 "ScalarModule.cs"
    int octant = csharp2cuda_f64_to_i32(__dsub_rn(octant_value, __dmul_rn(floor(__dmul_rn(octant_value, 0.125)), 8.0)));
#line 241 "ScalarModule.cs"
    if (((csharp2cuda_i32_and(octant, 1)) != (0)))
#line 242 "ScalarModule.cs"
    {
#line 243 "ScalarModule.cs"
#line 243 "ScalarModule.cs"
        int* csharp2cuda_temp_1 = &(octant);
        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
#line 244 "ScalarModule.cs"
#line 244 "ScalarModule.cs"
        double* csharp2cuda_temp_2 = &(octant_value);
        (*(csharp2cuda_temp_2))++;
    }
#line 246 "ScalarModule.cs"
#line 246 "ScalarModule.cs"
    int* csharp2cuda_temp_3 = &(octant);
#line 246 "ScalarModule.cs"
    int csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
    (*(csharp2cuda_temp_3) = csharp2cuda_i32_and(csharp2cuda_temp_4, 7));
#line 247 "ScalarModule.cs"
    if (((octant) > (3)))
#line 248 "ScalarModule.cs"
    {
#line 249 "ScalarModule.cs"
#line 249 "ScalarModule.cs"
        int* csharp2cuda_temp_5 = &(octant);
#line 249 "ScalarModule.cs"
        int csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
        (*(csharp2cuda_temp_5) = csharp2cuda_i32_sub(csharp2cuda_temp_6, 4));
#line 250 "ScalarModule.cs"
#line 250 "ScalarModule.cs"
        double* csharp2cuda_temp_7 = &(sign);
        (*(csharp2cuda_temp_7) = (-(sign)));
    }
#line 252 "ScalarModule.cs"
    if (((octant) > (1)))
    {
#line 253 "ScalarModule.cs"
#line 253 "ScalarModule.cs"
        double* csharp2cuda_temp_8 = &(sign);
        (*(csharp2cuda_temp_8) = (-(sign)));
    }
#line 254 "ScalarModule.cs"
    double reduced = __dsub_rn(__dsub_rn(__dsub_rn(x, __dmul_rn(octant_value, 0.7853981256484985)), __dmul_rn(octant_value, 3.774894707930798E-08)), __dmul_rn(octant_value, 2.6951514290790595E-15));
#line 257 "ScalarModule.cs"
    double square = __dmul_rn(reduced, reduced);
#line 258 "ScalarModule.cs"
#line 258 "ScalarModule.cs"
    bool csharp2cuda_temp_9;
#line 258 "ScalarModule.cs"
    if (!(((octant) == (1))))
    {
#line 258 "ScalarModule.cs"
        csharp2cuda_temp_9 = ((octant) == (2));
    }
    else
    {
#line 258 "ScalarModule.cs"
        csharp2cuda_temp_9 = true;
    }
    if (csharp2cuda_temp_9)
#line 259 "ScalarModule.cs"
    {
#line 260 "ScalarModule.cs"
        double sine_polynomial = __dsub_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dsub_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dsub_rn(__dmul_rn(1.5896230157654656E-10, square), 2.5050747762857807E-08), square), 2.7557313621385722E-06), square), 0.0001984126982958954), square), 0.008333333333322118), square), 0.1666666666666663);
#line 267 "ScalarModule.cs"
        return __dmul_rn(sign, __dadd_rn(reduced, __dmul_rn(__dmul_rn(reduced, square), sine_polynomial)));
    }
#line 269 "ScalarModule.cs"
    double polynomial = __dadd_rn(__dmul_rn(__dsub_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dsub_rn(__dmul_rn(__dadd_rn(__dmul_rn((-(1.1358536521387682E-11)), square), 2.087570084197473E-09), square), 2.755731417929674E-07), square), 2.4801587288851704E-05), square), 0.0013888888888873056), square), 0.041666666666666595);
#line 276 "ScalarModule.cs"
    return __dmul_rn(sign, __dadd_rn(__dsub_rn(1.0, __dmul_rn(0.5, square)), __dmul_rn(__dmul_rn(square, square), polynomial)));
}

#line 171 "ScalarModule.cs"
__device__ double mathblocks_cube_root(double value)
#line 173 "ScalarModule.cs"
{
#line 174 "ScalarModule.cs"
    if (((value) == (0.0)))
    {
#line 175 "ScalarModule.cs"
        return value;
    }
#line 176 "ScalarModule.cs"
    double magnitude = fabs(value);
#line 177 "ScalarModule.cs"
    double csharp2cuda_temp_0 = __ddiv_rn(mathblocks_natural_logarithm(magnitude), 3.0);
#line 177 "ScalarModule.cs"
    double estimate = mathblocks_exponential(csharp2cuda_temp_0);
#line 178 "ScalarModule.cs"
    {
#line 178 "ScalarModule.cs"
        int iteration = 0;
        while (true)
        {
            if (!(((iteration) < (3))))
                break;
#line 179 "ScalarModule.cs"
#line 179 "ScalarModule.cs"
            double* csharp2cuda_temp_2 = &(estimate);
#line 179 "ScalarModule.cs"
            double csharp2cuda_temp_3 = __ddiv_rn(magnitude, __dmul_rn(estimate, estimate));
#line 179 "ScalarModule.cs"
            double csharp2cuda_temp_4 = __ddiv_rn(__dadd_rn(__dmul_rn(2.0, estimate), csharp2cuda_temp_3), 3.0);
            (*(csharp2cuda_temp_2) = csharp2cuda_temp_4);
#line 178 "ScalarModule.cs"
            int* csharp2cuda_temp_1 = &(iteration);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 180 "ScalarModule.cs"
    return copysign(estimate, value);
}

#line 349 "ScalarModule.cs"
__device__ double mathblocks_error_function(double value)
#line 351 "ScalarModule.cs"
{
#line 353 "ScalarModule.cs"
    if (((value) == (0.0)))
    {
#line 354 "ScalarModule.cs"
        return value;
    }
#line 355 "ScalarModule.cs"
    double magnitude = fabs(value);
#line 356 "ScalarModule.cs"
    double t = __ddiv_rn(1.0, __dadd_rn(1.0, __dmul_rn(0.5, magnitude)));
#line 357 "ScalarModule.cs"
    double tau = __dmul_rn(t, mathblocks_exponential(__dadd_rn(__dsub_rn(__dmul_rn((-(magnitude)), magnitude), 1.26551223), __dmul_rn(t, __dadd_rn(1.00002368, __dmul_rn(t, __dadd_rn(0.37409196, __dmul_rn(t, __dadd_rn(0.09678418, __dmul_rn(t, __dadd_rn((-(0.18628806)), __dmul_rn(t, __dadd_rn(0.27886807, __dmul_rn(t, __dadd_rn((-(1.13520398)), __dmul_rn(t, __dadd_rn(1.48851587, __dmul_rn(t, __dadd_rn((-(0.82215223)), __dmul_rn(t, 0.17087277))))))))))))))))))));
#line 367 "ScalarModule.cs"
    return copysign(__dsub_rn(1.0, tau), value);
}

#line 58 "ScalarModule.cs"
__device__ double mathblocks_exponential(double value)
#line 60 "ScalarModule.cs"
{
#line 61 "ScalarModule.cs"
    if (((value) > (709.782712893384)))
    {
#line 62 "ScalarModule.cs"
        return mathblocks_positive_infinity();
    }
#line 63 "ScalarModule.cs"
    if (((value) < ((-(745.1332191019411)))))
    {
#line 64 "ScalarModule.cs"
        return 0.0;
    }
#line 66 "ScalarModule.cs"
    double exponent_value = floor(__dadd_rn(__dmul_rn(1.4426950408889634, value), 0.5));
#line 67 "ScalarModule.cs"
    int exponent = csharp2cuda_f64_to_i32(exponent_value);
#line 68 "ScalarModule.cs"
    double reduced = __dsub_rn(value, __dmul_rn(exponent_value, 0.693359375));
#line 69 "ScalarModule.cs"
#line 69 "ScalarModule.cs"
    double* csharp2cuda_temp_0 = &(reduced);
#line 69 "ScalarModule.cs"
    double csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
    (*(csharp2cuda_temp_0) = __dsub_rn(csharp2cuda_temp_1, __dmul_rn(exponent_value, (-(0.00021219444005469057)))));
#line 70 "ScalarModule.cs"
    double square = __dmul_rn(reduced, reduced);
#line 71 "ScalarModule.cs"
    double numerator = __dmul_rn(reduced, __dadd_rn(__dmul_rn(__dadd_rn(__dmul_rn(0.00012617719307481058, square), 0.030299440770744195), square), 1.0));
#line 73 "ScalarModule.cs"
    double denominator = __dadd_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dadd_rn(__dmul_rn(3.0019850513866446E-06, square), 0.002524483403496841), square), 0.22726554820815503), square), 2.0);
#line 76 "ScalarModule.cs"
    double csharp2cuda_temp_2 = __ddiv_rn(__dmul_rn(2.0, numerator), __dsub_rn(denominator, numerator));
#line 76 "ScalarModule.cs"
    double result = __dadd_rn(1.0, csharp2cuda_temp_2);
#line 77 "ScalarModule.cs"
    return ldexp(result, exponent);
}

#line 137 "ScalarModule.cs"
__device__ double mathblocks_integer_power(double value, long long exponent)
#line 139 "ScalarModule.cs"
{
#line 140 "ScalarModule.cs"
    if (((exponent) == (((long long)(0)))))
    {
#line 141 "ScalarModule.cs"
        return 1.0;
    }
#line 142 "ScalarModule.cs"
    bool negative = ((exponent) < (((long long)(0))));
#line 143 "ScalarModule.cs"
    unsigned long long csharp2cuda_temp_0;
#line 143 "ScalarModule.cs"
    if (negative)
    {
#line 143 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((((unsigned long long)(csharp2cuda_i64_neg(csharp2cuda_i64_add(exponent, ((long long)(1))))))) + (1ull));
    }
    else
    {
#line 143 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((unsigned long long)(exponent));
    }
#line 143 "ScalarModule.cs"
    unsigned long long remaining = csharp2cuda_temp_0;
#line 146 "ScalarModule.cs"
    double power_base = value;
#line 147 "ScalarModule.cs"
    double result = 1.0;
#line 148 "ScalarModule.cs"
    while (true)
    {
        if (!(((remaining) != (0ull))))
            break;
#line 149 "ScalarModule.cs"
        {
#line 150 "ScalarModule.cs"
            if (((((remaining) & (1ull))) != (0ull)))
            {
#line 151 "ScalarModule.cs"
#line 151 "ScalarModule.cs"
                double* csharp2cuda_temp_1 = &(result);
#line 151 "ScalarModule.cs"
                double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
                (*(csharp2cuda_temp_1) = __dmul_rn(csharp2cuda_temp_2, power_base));
            }
#line 152 "ScalarModule.cs"
#line 152 "ScalarModule.cs"
            unsigned long long* csharp2cuda_temp_3 = &(remaining);
#line 152 "ScalarModule.cs"
            unsigned long long csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
            (*(csharp2cuda_temp_3) = csharp2cuda_u64_shr(csharp2cuda_temp_4, 1));
#line 153 "ScalarModule.cs"
            if (((remaining) != (0ull)))
            {
#line 154 "ScalarModule.cs"
#line 154 "ScalarModule.cs"
                double* csharp2cuda_temp_5 = &(power_base);
#line 154 "ScalarModule.cs"
                double csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
                (*(csharp2cuda_temp_5) = __dmul_rn(csharp2cuda_temp_6, power_base));
            }
        }
    }
#line 156 "ScalarModule.cs"
#line 156 "ScalarModule.cs"
    double csharp2cuda_temp_7;
#line 156 "ScalarModule.cs"
    if (negative)
    {
#line 156 "ScalarModule.cs"
        csharp2cuda_temp_7 = __ddiv_rn(1.0, result);
    }
    else
    {
#line 156 "ScalarModule.cs"
        csharp2cuda_temp_7 = result;
    }
    return csharp2cuda_temp_7;
}

#line 338 "ScalarModule.cs"
__device__ double mathblocks_inverse_hyperbolic_sine(double value)
#line 340 "ScalarModule.cs"
{
#line 341 "ScalarModule.cs"
    if (((value) == (0.0)))
    {
#line 342 "ScalarModule.cs"
        return value;
    }
#line 343 "ScalarModule.cs"
    double magnitude = fabs(value);
#line 344 "ScalarModule.cs"
    return copysign(mathblocks_natural_logarithm(__dadd_rn(magnitude, mathblocks_square_root(__dadd_rn(__dmul_rn(magnitude, magnitude), 1.0)))), value);
}

#line 117 "ScalarModule.cs"
__device__ double mathblocks_log_one_plus(double value)
#line 119 "ScalarModule.cs"
{
#line 120 "ScalarModule.cs"
    double sum = __dadd_rn(1.0, value);
#line 121 "ScalarModule.cs"
#line 121 "ScalarModule.cs"
    double csharp2cuda_temp_0;
#line 121 "ScalarModule.cs"
    if (((sum) == (1.0)))
    {
#line 121 "ScalarModule.cs"
        csharp2cuda_temp_0 = value;
    }
    else
    {
#line 123 "ScalarModule.cs"
        double csharp2cuda_temp_1 = __ddiv_rn(__dsub_rn(__dsub_rn(sum, 1.0), value), sum);
#line 121 "ScalarModule.cs"
        csharp2cuda_temp_0 = __dsub_rn(mathblocks_natural_logarithm(sum), csharp2cuda_temp_1);
    }
    return csharp2cuda_temp_0;
}

#line 80 "ScalarModule.cs"
__device__ double mathblocks_natural_logarithm(double value)
#line 82 "ScalarModule.cs"
{
#line 83 "ScalarModule.cs"
    if (((value) == (0.0)))
    {
#line 84 "ScalarModule.cs"
        return (-(mathblocks_positive_infinity()));
    }
#line 85 "ScalarModule.cs"
#line 85 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 85 "ScalarModule.cs"
    if (!(((value) < (0.0))))
    {
#line 85 "ScalarModule.cs"
        csharp2cuda_temp_0 = isnan(value);
    }
    else
    {
#line 85 "ScalarModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 86 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 87 "ScalarModule.cs"
    if (isinf(value))
    {
#line 88 "ScalarModule.cs"
        return mathblocks_positive_infinity();
    }
#line 90 "ScalarModule.cs"
    int exponent = csharp2cuda_i32_add(ilogb(value), 1);
#line 91 "ScalarModule.cs"
    double reduced = ldexp(value, csharp2cuda_i32_neg(exponent));
#line 92 "ScalarModule.cs"
    if (((reduced) < (0.7071067811865476)))
#line 93 "ScalarModule.cs"
    {
#line 94 "ScalarModule.cs"
#line 94 "ScalarModule.cs"
        int* csharp2cuda_temp_1 = &(exponent);
        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_1));
#line 95 "ScalarModule.cs"
#line 95 "ScalarModule.cs"
        double* csharp2cuda_temp_2 = &(reduced);
        (*(csharp2cuda_temp_2) = __dsub_rn(__dmul_rn(2.0, reduced), 1.0));
    }
    else
#line 98 "ScalarModule.cs"
    {
#line 99 "ScalarModule.cs"
#line 99 "ScalarModule.cs"
        double* csharp2cuda_temp_3 = &(reduced);
#line 99 "ScalarModule.cs"
        double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
        (*(csharp2cuda_temp_3) = __dsub_rn(csharp2cuda_temp_4, 1.0));
    }
#line 102 "ScalarModule.cs"
    double square = __dmul_rn(reduced, reduced);
#line 103 "ScalarModule.cs"
    double numerator = __dadd_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dadd_rn(__dmul_rn(0.00010187566380458093, reduced), 0.497494994976747), reduced), 4.705791198788817), reduced), 14.498922534161093), reduced), 17.936867850781983), reduced), 7.708387337558854);
#line 107 "ScalarModule.cs"
    double denominator = __dadd_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dadd_rn(reduced, 11.287358718916746), reduced), 45.227914583753225), reduced), 82.98752669127767), reduced), 71.15447506185639), reduced), 23.125162012676533);
#line 111 "ScalarModule.cs"
    double csharp2cuda_temp_5 = __ddiv_rn(__dmul_rn(square, numerator), denominator);
#line 111 "ScalarModule.cs"
    double correction = __dmul_rn(reduced, csharp2cuda_temp_5);
#line 112 "ScalarModule.cs"
#line 112 "ScalarModule.cs"
    double* csharp2cuda_temp_6 = &(correction);
#line 112 "ScalarModule.cs"
    double csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
    (*(csharp2cuda_temp_6) = __dsub_rn(csharp2cuda_temp_7, __dmul_rn(((double)(exponent)), 0.00021219444005469057)));
#line 113 "ScalarModule.cs"
#line 113 "ScalarModule.cs"
    double* csharp2cuda_temp_8 = &(correction);
#line 113 "ScalarModule.cs"
    double csharp2cuda_temp_9 = *(csharp2cuda_temp_8);
    (*(csharp2cuda_temp_8) = __dsub_rn(csharp2cuda_temp_9, __dmul_rn(0.5, square)));
#line 114 "ScalarModule.cs"
    return __dadd_rn(__dadd_rn(reduced, correction), __dmul_rn(((double)(exponent)), 0.693359375));
}

#line 22 "ScalarModule.cs"
__device__ double mathblocks_positive_infinity()
#line 24 "ScalarModule.cs"
{
#line 25 "ScalarModule.cs"
    return __longlong_as_double(csharp2cuda_i64_from_bits(9218868437227405312ull));
}

#line 159 "ScalarModule.cs"
__device__ double mathblocks_power(double value, double exponent)
#line 161 "ScalarModule.cs"
{
#line 162 "ScalarModule.cs"
#line 162 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 162 "ScalarModule.cs"
    if (((exponent) == (trunc(exponent))))
    {
#line 162 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((fabs(exponent)) <= (9.223372036854776E+18));
    }
    else
    {
#line 162 "ScalarModule.cs"
        csharp2cuda_temp_0 = false;
    }
    if (csharp2cuda_temp_0)
    {
#line 163 "ScalarModule.cs"
        return mathblocks_integer_power(value, csharp2cuda_f64_to_i64(exponent));
    }
#line 164 "ScalarModule.cs"
    if (((value) < (0.0)))
    {
#line 165 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 166 "ScalarModule.cs"
    if (((value) == (0.0)))
    {
#line 167 "ScalarModule.cs"
#line 167 "ScalarModule.cs"
        double csharp2cuda_temp_1;
#line 167 "ScalarModule.cs"
        if (((exponent) > (0.0)))
        {
#line 167 "ScalarModule.cs"
            csharp2cuda_temp_1 = 0.0;
        }
        else
        {
#line 167 "ScalarModule.cs"
            csharp2cuda_temp_1 = mathblocks_positive_infinity();
        }
        return csharp2cuda_temp_1;
    }
#line 168 "ScalarModule.cs"
    return mathblocks_exponential(__dmul_rn(exponent, mathblocks_natural_logarithm(value)));
}

#line 28 "ScalarModule.cs"
__device__ double mathblocks_quiet_nan()
#line 30 "ScalarModule.cs"
{
#line 31 "ScalarModule.cs"
    return __longlong_as_double(csharp2cuda_i64_from_bits(9221120237041090560ull));
}

#line 370 "ScalarModule.cs"
__device__ void mathblocks_scalar_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 376 "ScalarModule.cs"
{
#line 377 "ScalarModule.cs"
    if (((threadIdx.x) != (0)))
    {
#line 378 "ScalarModule.cs"
        return;
    }
#line 380 "ScalarModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 380 "ScalarModule.cs"
    if (((input_count) > (0)))
    {
#line 380 "ScalarModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 380 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 380 "ScalarModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 381 "ScalarModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 381 "ScalarModule.cs"
    if (((input_count) > (1)))
    {
#line 381 "ScalarModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 381 "ScalarModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 381 "ScalarModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 382 "ScalarModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 382 "ScalarModule.cs"
    if (((input_count) > (2)))
    {
#line 382 "ScalarModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 382 "ScalarModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 382 "ScalarModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 384 "ScalarModule.cs"
#line 384 "ScalarModule.cs"
    double* csharp2cuda_temp_3 = &((output)->scalar_value);
    (*(csharp2cuda_temp_3) = 0.0);
#line 385 "ScalarModule.cs"
#line 385 "ScalarModule.cs"
    int* csharp2cuda_temp_4 = &((output)->boolean_value);
    (*(csharp2cuda_temp_4) = 0);
#line 386 "ScalarModule.cs"
#line 386 "ScalarModule.cs"
    int* csharp2cuda_temp_5 = &((output)->valid);
#line 386 "ScalarModule.cs"
    bool csharp2cuda_temp_6;
#line 386 "ScalarModule.cs"
    if (!(((((void*)(first))) == (((void*)(nullptr))))))
    {
#line 386 "ScalarModule.cs"
        csharp2cuda_temp_6 = (first)->valid;
    }
    else
    {
#line 386 "ScalarModule.cs"
        csharp2cuda_temp_6 = true;
    }
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 387 "ScalarModule.cs"
    if (((((void*)(second))) != (((void*)(nullptr)))))
    {
#line 388 "ScalarModule.cs"
#line 388 "ScalarModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
#line 388 "ScalarModule.cs"
        bool csharp2cuda_temp_8 = (output)->valid;
#line 388 "ScalarModule.cs"
        bool csharp2cuda_temp_9;
#line 388 "ScalarModule.cs"
        if (csharp2cuda_temp_8)
        {
#line 388 "ScalarModule.cs"
            csharp2cuda_temp_9 = (second)->valid;
        }
        else
        {
#line 388 "ScalarModule.cs"
            csharp2cuda_temp_9 = false;
        }
        (*(csharp2cuda_temp_7) = csharp2cuda_temp_9);
    }
#line 389 "ScalarModule.cs"
    if (((((void*)(third))) != (((void*)(nullptr)))))
    {
#line 390 "ScalarModule.cs"
#line 390 "ScalarModule.cs"
        int* csharp2cuda_temp_10 = &((output)->valid);
#line 390 "ScalarModule.cs"
        bool csharp2cuda_temp_11 = (output)->valid;
#line 390 "ScalarModule.cs"
        bool csharp2cuda_temp_12;
#line 390 "ScalarModule.cs"
        if (csharp2cuda_temp_11)
        {
#line 390 "ScalarModule.cs"
            csharp2cuda_temp_12 = (third)->valid;
        }
        else
        {
#line 390 "ScalarModule.cs"
            csharp2cuda_temp_12 = false;
        }
        (*(csharp2cuda_temp_10) = csharp2cuda_temp_12);
    }
#line 391 "ScalarModule.cs"
#line 391 "ScalarModule.cs"
    bool csharp2cuda_temp_13 = (output)->valid;
    if ((!(csharp2cuda_temp_13)))
    {
#line 392 "ScalarModule.cs"
        return;
    }
#line 394 "ScalarModule.cs"
    double csharp2cuda_temp_14;
#line 394 "ScalarModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 394 "ScalarModule.cs"
        csharp2cuda_temp_14 = 0.0;
    }
    else
    {
#line 394 "ScalarModule.cs"
        csharp2cuda_temp_14 = (first)->scalar_value;
    }
#line 394 "ScalarModule.cs"
    double a = csharp2cuda_temp_14;
#line 395 "ScalarModule.cs"
    double csharp2cuda_temp_15;
#line 395 "ScalarModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 395 "ScalarModule.cs"
        csharp2cuda_temp_15 = 0.0;
    }
    else
    {
#line 395 "ScalarModule.cs"
        csharp2cuda_temp_15 = (second)->scalar_value;
    }
#line 395 "ScalarModule.cs"
    double b = csharp2cuda_temp_15;
#line 396 "ScalarModule.cs"
    double csharp2cuda_temp_16;
#line 396 "ScalarModule.cs"
    if (((((void*)(third))) == (((void*)(nullptr)))))
    {
#line 396 "ScalarModule.cs"
        csharp2cuda_temp_16 = 0.0;
    }
    else
    {
#line 396 "ScalarModule.cs"
        csharp2cuda_temp_16 = (third)->scalar_value;
    }
#line 396 "ScalarModule.cs"
    double c = csharp2cuda_temp_16;
#line 397 "ScalarModule.cs"
    bool scalar_output = true;
#line 399 "ScalarModule.cs"
    switch (opcode)
    {
#line 401 "ScalarModule.cs"
        case 0:
#line 401 "ScalarModule.cs"
#line 401 "ScalarModule.cs"
            double* csharp2cuda_temp_17 = &((output)->scalar_value);
            (*(csharp2cuda_temp_17) = __dadd_rn(a, b));
#line 401 "ScalarModule.cs"
            break;
#line 402 "ScalarModule.cs"
        case 1:
#line 402 "ScalarModule.cs"
#line 402 "ScalarModule.cs"
            double* csharp2cuda_temp_18 = &((output)->scalar_value);
            (*(csharp2cuda_temp_18) = __dsub_rn(a, b));
#line 402 "ScalarModule.cs"
            break;
#line 403 "ScalarModule.cs"
        case 2:
#line 403 "ScalarModule.cs"
#line 403 "ScalarModule.cs"
            double* csharp2cuda_temp_19 = &((output)->scalar_value);
            (*(csharp2cuda_temp_19) = __dmul_rn(a, b));
#line 403 "ScalarModule.cs"
            break;
#line 404 "ScalarModule.cs"
        case 3:
#line 404 "ScalarModule.cs"
#line 404 "ScalarModule.cs"
            double* csharp2cuda_temp_20 = &((output)->scalar_value);
#line 404 "ScalarModule.cs"
            double csharp2cuda_temp_21 = __ddiv_rn(a, b);
            (*(csharp2cuda_temp_20) = csharp2cuda_temp_21);
#line 404 "ScalarModule.cs"
            break;
#line 405 "ScalarModule.cs"
        case 4:
#line 405 "ScalarModule.cs"
#line 405 "ScalarModule.cs"
            double* csharp2cuda_temp_22 = &((output)->scalar_value);
            (*(csharp2cuda_temp_22) = (-(a)));
#line 405 "ScalarModule.cs"
            break;
#line 406 "ScalarModule.cs"
        case 5:
#line 406 "ScalarModule.cs"
#line 406 "ScalarModule.cs"
            double* csharp2cuda_temp_23 = &((output)->scalar_value);
            (*(csharp2cuda_temp_23) = fabs(a));
#line 406 "ScalarModule.cs"
            break;
#line 407 "ScalarModule.cs"
        case 6:
#line 407 "ScalarModule.cs"
#line 407 "ScalarModule.cs"
            double* csharp2cuda_temp_24 = &((output)->scalar_value);
            (*(csharp2cuda_temp_24) = ((double)(csharp2cuda_i32_sub(((((a) > (0.0))) ? 1 : 0), ((((a) < (0.0))) ? 1 : 0)))));
#line 407 "ScalarModule.cs"
            break;
#line 408 "ScalarModule.cs"
        case 7:
#line 408 "ScalarModule.cs"
#line 408 "ScalarModule.cs"
            double* csharp2cuda_temp_25 = &((output)->scalar_value);
#line 408 "ScalarModule.cs"
            double csharp2cuda_temp_26;
#line 408 "ScalarModule.cs"
            if (((a) > (0.0)))
            {
#line 408 "ScalarModule.cs"
                csharp2cuda_temp_26 = a;
            }
            else
            {
#line 408 "ScalarModule.cs"
                csharp2cuda_temp_26 = 0.0;
            }
            (*(csharp2cuda_temp_25) = csharp2cuda_temp_26);
#line 408 "ScalarModule.cs"
            break;
#line 409 "ScalarModule.cs"
        case 8:
#line 409 "ScalarModule.cs"
#line 409 "ScalarModule.cs"
            double* csharp2cuda_temp_27 = &((output)->scalar_value);
            (*(csharp2cuda_temp_27) = csharp2cuda_f64_minimum(a, b));
#line 409 "ScalarModule.cs"
            break;
#line 410 "ScalarModule.cs"
        case 9:
#line 410 "ScalarModule.cs"
#line 410 "ScalarModule.cs"
            double* csharp2cuda_temp_28 = &((output)->scalar_value);
            (*(csharp2cuda_temp_28) = csharp2cuda_f64_maximum(a, b));
#line 410 "ScalarModule.cs"
            break;
#line 411 "ScalarModule.cs"
        case 10:
#line 411 "ScalarModule.cs"
#line 411 "ScalarModule.cs"
            double* csharp2cuda_temp_29 = &((output)->scalar_value);
            (*(csharp2cuda_temp_29) = csharp2cuda_f64_minimum(csharp2cuda_f64_maximum(a, b), c));
#line 411 "ScalarModule.cs"
            break;
#line 412 "ScalarModule.cs"
        case 11:
#line 412 "ScalarModule.cs"
#line 412 "ScalarModule.cs"
            double* csharp2cuda_temp_30 = &((output)->scalar_value);
#line 412 "ScalarModule.cs"
            double csharp2cuda_temp_31 = __ddiv_rn(1.0, a);
            (*(csharp2cuda_temp_30) = csharp2cuda_temp_31);
#line 412 "ScalarModule.cs"
            break;
#line 413 "ScalarModule.cs"
        case 12:
#line 413 "ScalarModule.cs"
#line 413 "ScalarModule.cs"
            double* csharp2cuda_temp_32 = &((output)->scalar_value);
            (*(csharp2cuda_temp_32) = __dmul_rn(a, a));
#line 413 "ScalarModule.cs"
            break;
#line 414 "ScalarModule.cs"
        case 13:
#line 414 "ScalarModule.cs"
#line 414 "ScalarModule.cs"
            double* csharp2cuda_temp_33 = &((output)->scalar_value);
            (*(csharp2cuda_temp_33) = __dmul_rn(__dmul_rn(a, a), a));
#line 414 "ScalarModule.cs"
            break;
#line 415 "ScalarModule.cs"
        case 14:
#line 415 "ScalarModule.cs"
#line 415 "ScalarModule.cs"
            double* csharp2cuda_temp_34 = &((output)->scalar_value);
            (*(csharp2cuda_temp_34) = mathblocks_square_root(a));
#line 415 "ScalarModule.cs"
            break;
#line 416 "ScalarModule.cs"
        case 15:
#line 416 "ScalarModule.cs"
#line 416 "ScalarModule.cs"
            double* csharp2cuda_temp_35 = &((output)->scalar_value);
            (*(csharp2cuda_temp_35) = mathblocks_cube_root(a));
#line 416 "ScalarModule.cs"
            break;
#line 417 "ScalarModule.cs"
        case 16:
#line 417 "ScalarModule.cs"
#line 417 "ScalarModule.cs"
            double* csharp2cuda_temp_36 = &((output)->scalar_value);
            (*(csharp2cuda_temp_36) = mathblocks_power(a, b));
#line 417 "ScalarModule.cs"
            break;
#line 418 "ScalarModule.cs"
        case 17:
#line 418 "ScalarModule.cs"
#line 418 "ScalarModule.cs"
            double* csharp2cuda_temp_37 = &((output)->scalar_value);
            (*(csharp2cuda_temp_37) = mathblocks_exponential(a));
#line 418 "ScalarModule.cs"
            break;
#line 419 "ScalarModule.cs"
        case 18:
#line 419 "ScalarModule.cs"
#line 419 "ScalarModule.cs"
            double* csharp2cuda_temp_38 = &((output)->scalar_value);
            (*(csharp2cuda_temp_38) = mathblocks_natural_logarithm(a));
#line 419 "ScalarModule.cs"
            break;
#line 420 "ScalarModule.cs"
        case 19:
#line 420 "ScalarModule.cs"
#line 420 "ScalarModule.cs"
            double* csharp2cuda_temp_39 = &((output)->scalar_value);
            (*(csharp2cuda_temp_39) = mathblocks_binary_logarithm(a));
#line 420 "ScalarModule.cs"
            break;
#line 421 "ScalarModule.cs"
        case 20:
#line 422 "ScalarModule.cs"
#line 422 "ScalarModule.cs"
            double* csharp2cuda_temp_40 = &((output)->scalar_value);
#line 422 "ScalarModule.cs"
            double csharp2cuda_temp_41 = __ddiv_rn(mathblocks_natural_logarithm(a), 2.302585092994046);
            (*(csharp2cuda_temp_40) = csharp2cuda_temp_41);
#line 423 "ScalarModule.cs"
            break;
#line 424 "ScalarModule.cs"
        case 21:
#line 424 "ScalarModule.cs"
#line 424 "ScalarModule.cs"
            double* csharp2cuda_temp_42 = &((output)->scalar_value);
            (*(csharp2cuda_temp_42) = mathblocks_sine(a));
#line 424 "ScalarModule.cs"
            break;
#line 425 "ScalarModule.cs"
        case 22:
#line 425 "ScalarModule.cs"
#line 425 "ScalarModule.cs"
            double* csharp2cuda_temp_43 = &((output)->scalar_value);
            (*(csharp2cuda_temp_43) = mathblocks_cosine(a));
#line 425 "ScalarModule.cs"
            break;
#line 426 "ScalarModule.cs"
        case 23:
#line 426 "ScalarModule.cs"
#line 426 "ScalarModule.cs"
            double* csharp2cuda_temp_44 = &((output)->scalar_value);
#line 426 "ScalarModule.cs"
            double csharp2cuda_temp_45 = __ddiv_rn(mathblocks_sine(a), mathblocks_cosine(a));
            (*(csharp2cuda_temp_44) = csharp2cuda_temp_45);
#line 426 "ScalarModule.cs"
            break;
#line 427 "ScalarModule.cs"
        case 24:
#line 427 "ScalarModule.cs"
#line 427 "ScalarModule.cs"
            double* csharp2cuda_temp_46 = &((output)->scalar_value);
            (*(csharp2cuda_temp_46) = mathblocks_arc_sine(a));
#line 427 "ScalarModule.cs"
            break;
#line 428 "ScalarModule.cs"
        case 25:
#line 428 "ScalarModule.cs"
#line 428 "ScalarModule.cs"
            double* csharp2cuda_temp_47 = &((output)->scalar_value);
            (*(csharp2cuda_temp_47) = mathblocks_arc_cosine(a));
#line 428 "ScalarModule.cs"
            break;
#line 429 "ScalarModule.cs"
        case 26:
#line 429 "ScalarModule.cs"
#line 429 "ScalarModule.cs"
            double* csharp2cuda_temp_48 = &((output)->scalar_value);
            (*(csharp2cuda_temp_48) = mathblocks_arc_tangent(a));
#line 429 "ScalarModule.cs"
            break;
#line 430 "ScalarModule.cs"
        case 27:
#line 430 "ScalarModule.cs"
#line 430 "ScalarModule.cs"
            double* csharp2cuda_temp_49 = &((output)->scalar_value);
            (*(csharp2cuda_temp_49) = mathblocks_arc_tangent_2(a, b));
#line 430 "ScalarModule.cs"
            break;
#line 431 "ScalarModule.cs"
        case 28:
#line 432 "ScalarModule.cs"
            {
#line 433 "ScalarModule.cs"
                if (((a) == (0.0)))
#line 434 "ScalarModule.cs"
                {
#line 435 "ScalarModule.cs"
#line 435 "ScalarModule.cs"
                    double* csharp2cuda_temp_50 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_50) = a);
#line 436 "ScalarModule.cs"
                    break;
                }
#line 438 "ScalarModule.cs"
                double positive = mathblocks_exponential(a);
#line 439 "ScalarModule.cs"
                double negative = mathblocks_exponential((-(a)));
#line 440 "ScalarModule.cs"
#line 440 "ScalarModule.cs"
                double* csharp2cuda_temp_51 = &((output)->scalar_value);
#line 440 "ScalarModule.cs"
                double csharp2cuda_temp_52 = __ddiv_rn(__dsub_rn(positive, negative), 2.0);
                (*(csharp2cuda_temp_51) = csharp2cuda_temp_52);
#line 441 "ScalarModule.cs"
                break;
            }
#line 443 "ScalarModule.cs"
        case 29:
#line 444 "ScalarModule.cs"
            {
#line 445 "ScalarModule.cs"
                double positive = mathblocks_exponential(a);
#line 446 "ScalarModule.cs"
                double negative = mathblocks_exponential((-(a)));
#line 447 "ScalarModule.cs"
#line 447 "ScalarModule.cs"
                double* csharp2cuda_temp_53 = &((output)->scalar_value);
#line 447 "ScalarModule.cs"
                double csharp2cuda_temp_54 = __ddiv_rn(__dadd_rn(positive, negative), 2.0);
                (*(csharp2cuda_temp_53) = csharp2cuda_temp_54);
#line 448 "ScalarModule.cs"
                break;
            }
#line 450 "ScalarModule.cs"
        case 30:
#line 451 "ScalarModule.cs"
            {
#line 452 "ScalarModule.cs"
                if (((a) == (0.0)))
#line 453 "ScalarModule.cs"
                {
#line 454 "ScalarModule.cs"
#line 454 "ScalarModule.cs"
                    double* csharp2cuda_temp_55 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_55) = a);
#line 455 "ScalarModule.cs"
                    break;
                }
#line 457 "ScalarModule.cs"
                double positive = mathblocks_exponential(a);
#line 458 "ScalarModule.cs"
                double negative = mathblocks_exponential((-(a)));
#line 459 "ScalarModule.cs"
#line 459 "ScalarModule.cs"
                double* csharp2cuda_temp_56 = &((output)->scalar_value);
#line 459 "ScalarModule.cs"
                double csharp2cuda_temp_57 = __ddiv_rn(__dsub_rn(positive, negative), __dadd_rn(positive, negative));
                (*(csharp2cuda_temp_56) = csharp2cuda_temp_57);
#line 460 "ScalarModule.cs"
                break;
            }
#line 462 "ScalarModule.cs"
        case 31:
#line 462 "ScalarModule.cs"
#line 462 "ScalarModule.cs"
            double* csharp2cuda_temp_58 = &((output)->scalar_value);
            (*(csharp2cuda_temp_58) = mathblocks_inverse_hyperbolic_sine(a));
#line 462 "ScalarModule.cs"
            break;
#line 463 "ScalarModule.cs"
        case 32:
#line 464 "ScalarModule.cs"
#line 464 "ScalarModule.cs"
            double* csharp2cuda_temp_59 = &((output)->scalar_value);
            (*(csharp2cuda_temp_59) = mathblocks_natural_logarithm(__dadd_rn(a, mathblocks_square_root(__dsub_rn(__dmul_rn(a, a), 1.0)))));
#line 466 "ScalarModule.cs"
            break;
#line 467 "ScalarModule.cs"
        case 33:
#line 467 "ScalarModule.cs"
#line 467 "ScalarModule.cs"
            double* csharp2cuda_temp_60 = &((output)->scalar_value);
#line 467 "ScalarModule.cs"
            double csharp2cuda_temp_61 = __ddiv_rn(__dmul_rn(2.0, a), __dsub_rn(1.0, a));
            (*(csharp2cuda_temp_60) = __dmul_rn(0.5, mathblocks_log_one_plus(csharp2cuda_temp_61)));
#line 467 "ScalarModule.cs"
            break;
#line 468 "ScalarModule.cs"
        case 34:
#line 468 "ScalarModule.cs"
#line 468 "ScalarModule.cs"
            double* csharp2cuda_temp_62 = &((output)->scalar_value);
            (*(csharp2cuda_temp_62) = floor(a));
#line 468 "ScalarModule.cs"
            break;
#line 469 "ScalarModule.cs"
        case 35:
#line 469 "ScalarModule.cs"
#line 469 "ScalarModule.cs"
            double* csharp2cuda_temp_63 = &((output)->scalar_value);
            (*(csharp2cuda_temp_63) = ceil(a));
#line 469 "ScalarModule.cs"
            break;
#line 470 "ScalarModule.cs"
        case 36:
#line 470 "ScalarModule.cs"
#line 470 "ScalarModule.cs"
            double* csharp2cuda_temp_64 = &((output)->scalar_value);
            (*(csharp2cuda_temp_64) = nearbyint(a));
#line 470 "ScalarModule.cs"
            break;
#line 471 "ScalarModule.cs"
        case 37:
#line 471 "ScalarModule.cs"
#line 471 "ScalarModule.cs"
            double* csharp2cuda_temp_65 = &((output)->scalar_value);
            (*(csharp2cuda_temp_65) = trunc(a));
#line 471 "ScalarModule.cs"
            break;
#line 472 "ScalarModule.cs"
        case 38:
#line 472 "ScalarModule.cs"
#line 472 "ScalarModule.cs"
            double* csharp2cuda_temp_66 = &((output)->scalar_value);
            (*(csharp2cuda_temp_66) = fmod(a, b));
#line 472 "ScalarModule.cs"
            break;
#line 473 "ScalarModule.cs"
        case 39:
#line 474 "ScalarModule.cs"
#line 474 "ScalarModule.cs"
            double* csharp2cuda_temp_67 = &((output)->scalar_value);
#line 474 "ScalarModule.cs"
            double csharp2cuda_temp_68;
#line 474 "ScalarModule.cs"
            if (((a) >= (0.0)))
            {
#line 474 "ScalarModule.cs"
                csharp2cuda_temp_68 = __ddiv_rn(1.0, __dadd_rn(1.0, mathblocks_exponential((-(a)))));
            }
            else
            {
#line 474 "ScalarModule.cs"
                csharp2cuda_temp_68 = __ddiv_rn(mathblocks_exponential(a), __dadd_rn(1.0, mathblocks_exponential(a)));
            }
            (*(csharp2cuda_temp_67) = csharp2cuda_temp_68);
#line 477 "ScalarModule.cs"
            break;
#line 478 "ScalarModule.cs"
        case 40:
#line 479 "ScalarModule.cs"
#line 479 "ScalarModule.cs"
            double* csharp2cuda_temp_69 = &((output)->scalar_value);
#line 479 "ScalarModule.cs"
            double csharp2cuda_temp_70 = __ddiv_rn(a, __dsub_rn(1.0, a));
            (*(csharp2cuda_temp_69) = mathblocks_natural_logarithm(csharp2cuda_temp_70));
#line 480 "ScalarModule.cs"
            break;
#line 481 "ScalarModule.cs"
        case 41:
#line 482 "ScalarModule.cs"
#line 482 "ScalarModule.cs"
            double* csharp2cuda_temp_71 = &((output)->scalar_value);
            (*(csharp2cuda_temp_71) = __dadd_rn(csharp2cuda_f64_maximum(a, 0.0), mathblocks_log_one_plus(mathblocks_exponential((-(fabs(a)))))));
#line 484 "ScalarModule.cs"
            break;
#line 485 "ScalarModule.cs"
        case 42:
#line 485 "ScalarModule.cs"
#line 485 "ScalarModule.cs"
            double* csharp2cuda_temp_72 = &((output)->scalar_value);
            (*(csharp2cuda_temp_72) = mathblocks_log_one_plus(a));
#line 485 "ScalarModule.cs"
            break;
#line 486 "ScalarModule.cs"
        case 43:
#line 486 "ScalarModule.cs"
#line 486 "ScalarModule.cs"
            double* csharp2cuda_temp_73 = &((output)->scalar_value);
            (*(csharp2cuda_temp_73) = mathblocks_error_function(a));
#line 486 "ScalarModule.cs"
            break;
#line 487 "ScalarModule.cs"
        case 44:
#line 487 "ScalarModule.cs"
#line 487 "ScalarModule.cs"
            int* csharp2cuda_temp_74 = &((output)->boolean_value);
            (*(csharp2cuda_temp_74) = ((a) == (b)));
#line 487 "ScalarModule.cs"
#line 487 "ScalarModule.cs"
            bool* csharp2cuda_temp_75 = &(scalar_output);
            (*(csharp2cuda_temp_75) = false);
#line 487 "ScalarModule.cs"
            break;
#line 488 "ScalarModule.cs"
        case 45:
#line 488 "ScalarModule.cs"
#line 488 "ScalarModule.cs"
            int* csharp2cuda_temp_76 = &((output)->boolean_value);
            (*(csharp2cuda_temp_76) = ((a) != (b)));
#line 488 "ScalarModule.cs"
#line 488 "ScalarModule.cs"
            bool* csharp2cuda_temp_77 = &(scalar_output);
            (*(csharp2cuda_temp_77) = false);
#line 488 "ScalarModule.cs"
            break;
#line 489 "ScalarModule.cs"
        case 46:
#line 489 "ScalarModule.cs"
#line 489 "ScalarModule.cs"
            int* csharp2cuda_temp_78 = &((output)->boolean_value);
            (*(csharp2cuda_temp_78) = ((a) < (b)));
#line 489 "ScalarModule.cs"
#line 489 "ScalarModule.cs"
            bool* csharp2cuda_temp_79 = &(scalar_output);
            (*(csharp2cuda_temp_79) = false);
#line 489 "ScalarModule.cs"
            break;
#line 490 "ScalarModule.cs"
        case 47:
#line 490 "ScalarModule.cs"
#line 490 "ScalarModule.cs"
            int* csharp2cuda_temp_80 = &((output)->boolean_value);
            (*(csharp2cuda_temp_80) = ((a) <= (b)));
#line 490 "ScalarModule.cs"
#line 490 "ScalarModule.cs"
            bool* csharp2cuda_temp_81 = &(scalar_output);
            (*(csharp2cuda_temp_81) = false);
#line 490 "ScalarModule.cs"
            break;
#line 491 "ScalarModule.cs"
        case 48:
#line 491 "ScalarModule.cs"
#line 491 "ScalarModule.cs"
            int* csharp2cuda_temp_82 = &((output)->boolean_value);
            (*(csharp2cuda_temp_82) = ((a) > (b)));
#line 491 "ScalarModule.cs"
#line 491 "ScalarModule.cs"
            bool* csharp2cuda_temp_83 = &(scalar_output);
            (*(csharp2cuda_temp_83) = false);
#line 491 "ScalarModule.cs"
            break;
#line 492 "ScalarModule.cs"
        case 49:
#line 492 "ScalarModule.cs"
#line 492 "ScalarModule.cs"
            int* csharp2cuda_temp_84 = &((output)->boolean_value);
            (*(csharp2cuda_temp_84) = ((a) >= (b)));
#line 492 "ScalarModule.cs"
#line 492 "ScalarModule.cs"
            bool* csharp2cuda_temp_85 = &(scalar_output);
            (*(csharp2cuda_temp_85) = false);
#line 492 "ScalarModule.cs"
            break;
#line 493 "ScalarModule.cs"
        case 50:
#line 494 "ScalarModule.cs"
#line 494 "ScalarModule.cs"
            int* csharp2cuda_temp_86 = &((output)->boolean_value);
#line 494 "ScalarModule.cs"
            bool csharp2cuda_temp_87 = (first)->boolean_value;
#line 494 "ScalarModule.cs"
            bool csharp2cuda_temp_88;
#line 494 "ScalarModule.cs"
            if (csharp2cuda_temp_87)
            {
#line 494 "ScalarModule.cs"
                csharp2cuda_temp_88 = (second)->boolean_value;
            }
            else
            {
#line 494 "ScalarModule.cs"
                csharp2cuda_temp_88 = false;
            }
            (*(csharp2cuda_temp_86) = csharp2cuda_temp_88);
#line 495 "ScalarModule.cs"
#line 495 "ScalarModule.cs"
            bool* csharp2cuda_temp_89 = &(scalar_output);
            (*(csharp2cuda_temp_89) = false);
#line 496 "ScalarModule.cs"
            break;
#line 497 "ScalarModule.cs"
        case 51:
#line 498 "ScalarModule.cs"
#line 498 "ScalarModule.cs"
            int* csharp2cuda_temp_90 = &((output)->boolean_value);
#line 498 "ScalarModule.cs"
            bool csharp2cuda_temp_91 = (first)->boolean_value;
#line 498 "ScalarModule.cs"
            bool csharp2cuda_temp_92;
#line 498 "ScalarModule.cs"
            if (!(csharp2cuda_temp_91))
            {
#line 498 "ScalarModule.cs"
                csharp2cuda_temp_92 = (second)->boolean_value;
            }
            else
            {
#line 498 "ScalarModule.cs"
                csharp2cuda_temp_92 = true;
            }
            (*(csharp2cuda_temp_90) = csharp2cuda_temp_92);
#line 499 "ScalarModule.cs"
#line 499 "ScalarModule.cs"
            bool* csharp2cuda_temp_93 = &(scalar_output);
            (*(csharp2cuda_temp_93) = false);
#line 500 "ScalarModule.cs"
            break;
#line 501 "ScalarModule.cs"
        case 52:
#line 502 "ScalarModule.cs"
#line 502 "ScalarModule.cs"
            int* csharp2cuda_temp_94 = &((output)->boolean_value);
#line 502 "ScalarModule.cs"
            int csharp2cuda_temp_95 = (first)->boolean_value;
#line 502 "ScalarModule.cs"
            int csharp2cuda_temp_96 = (second)->boolean_value;
            (*(csharp2cuda_temp_94) = ((csharp2cuda_temp_95) != (csharp2cuda_temp_96)));
#line 503 "ScalarModule.cs"
#line 503 "ScalarModule.cs"
            bool* csharp2cuda_temp_97 = &(scalar_output);
            (*(csharp2cuda_temp_97) = false);
#line 504 "ScalarModule.cs"
            break;
#line 505 "ScalarModule.cs"
        case 53:
#line 506 "ScalarModule.cs"
#line 506 "ScalarModule.cs"
            int* csharp2cuda_temp_98 = &((output)->boolean_value);
#line 506 "ScalarModule.cs"
            bool csharp2cuda_temp_99 = (first)->boolean_value;
            (*(csharp2cuda_temp_98) = (!(csharp2cuda_temp_99)));
#line 507 "ScalarModule.cs"
#line 507 "ScalarModule.cs"
            bool* csharp2cuda_temp_100 = &(scalar_output);
            (*(csharp2cuda_temp_100) = false);
#line 508 "ScalarModule.cs"
            break;
#line 509 "ScalarModule.cs"
        case 54:
#line 510 "ScalarModule.cs"
#line 510 "ScalarModule.cs"
            double* csharp2cuda_temp_101 = &((output)->scalar_value);
#line 510 "ScalarModule.cs"
            bool csharp2cuda_temp_102 = (first)->boolean_value;
#line 510 "ScalarModule.cs"
            double csharp2cuda_temp_103;
#line 510 "ScalarModule.cs"
            if (csharp2cuda_temp_102)
            {
#line 510 "ScalarModule.cs"
                csharp2cuda_temp_103 = (second)->scalar_value;
            }
            else
            {
#line 510 "ScalarModule.cs"
                csharp2cuda_temp_103 = (third)->scalar_value;
            }
            (*(csharp2cuda_temp_101) = csharp2cuda_temp_103);
#line 511 "ScalarModule.cs"
            break;
#line 512 "ScalarModule.cs"
        default:
#line 512 "ScalarModule.cs"
#line 512 "ScalarModule.cs"
            int* csharp2cuda_temp_104 = &((output)->valid);
            (*(csharp2cuda_temp_104) = 0);
#line 512 "ScalarModule.cs"
            return;
    }
#line 515 "ScalarModule.cs"
#line 515 "ScalarModule.cs"
    bool csharp2cuda_temp_105;
#line 515 "ScalarModule.cs"
    if (scalar_output)
    {
#line 515 "ScalarModule.cs"
        double csharp2cuda_temp_106 = (output)->scalar_value;
#line 515 "ScalarModule.cs"
        csharp2cuda_temp_105 = (!(isfinite(csharp2cuda_temp_106)));
    }
    else
    {
#line 515 "ScalarModule.cs"
        csharp2cuda_temp_105 = false;
    }
    if (csharp2cuda_temp_105)
    {
#line 516 "ScalarModule.cs"
#line 516 "ScalarModule.cs"
        int* csharp2cuda_temp_107 = &((output)->valid);
        (*(csharp2cuda_temp_107) = 0);
    }
}

#line 183 "ScalarModule.cs"
__device__ double mathblocks_sine(double value)
#line 185 "ScalarModule.cs"
{
#line 187 "ScalarModule.cs"
    if (((value) == (0.0)))
    {
#line 188 "ScalarModule.cs"
        return value;
    }
#line 189 "ScalarModule.cs"
    double sign = 1.0;
#line 190 "ScalarModule.cs"
    double x = value;
#line 191 "ScalarModule.cs"
    if (((x) < (0.0)))
#line 192 "ScalarModule.cs"
    {
#line 193 "ScalarModule.cs"
#line 193 "ScalarModule.cs"
        double* csharp2cuda_temp_0 = &(sign);
        (*(csharp2cuda_temp_0) = (-(1.0)));
#line 194 "ScalarModule.cs"
#line 194 "ScalarModule.cs"
        double* csharp2cuda_temp_1 = &(x);
        (*(csharp2cuda_temp_1) = (-(x)));
    }
#line 196 "ScalarModule.cs"
    double csharp2cuda_temp_2 = __ddiv_rn(x, 0.7853981633974483);
#line 196 "ScalarModule.cs"
    double octant_value = floor(csharp2cuda_temp_2);
#line 197 "ScalarModule.cs"
    int octant = csharp2cuda_f64_to_i32(__dsub_rn(octant_value, __dmul_rn(floor(__dmul_rn(octant_value, 0.125)), 8.0)));
#line 198 "ScalarModule.cs"
    if (((csharp2cuda_i32_and(octant, 1)) != (0)))
#line 199 "ScalarModule.cs"
    {
#line 200 "ScalarModule.cs"
#line 200 "ScalarModule.cs"
        int* csharp2cuda_temp_3 = &(octant);
        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
#line 201 "ScalarModule.cs"
#line 201 "ScalarModule.cs"
        double* csharp2cuda_temp_4 = &(octant_value);
        (*(csharp2cuda_temp_4))++;
    }
#line 203 "ScalarModule.cs"
#line 203 "ScalarModule.cs"
    int* csharp2cuda_temp_5 = &(octant);
#line 203 "ScalarModule.cs"
    int csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
    (*(csharp2cuda_temp_5) = csharp2cuda_i32_and(csharp2cuda_temp_6, 7));
#line 204 "ScalarModule.cs"
    if (((octant) > (3)))
#line 205 "ScalarModule.cs"
    {
#line 206 "ScalarModule.cs"
#line 206 "ScalarModule.cs"
        double* csharp2cuda_temp_7 = &(sign);
        (*(csharp2cuda_temp_7) = (-(sign)));
#line 207 "ScalarModule.cs"
#line 207 "ScalarModule.cs"
        int* csharp2cuda_temp_8 = &(octant);
#line 207 "ScalarModule.cs"
        int csharp2cuda_temp_9 = *(csharp2cuda_temp_8);
        (*(csharp2cuda_temp_8) = csharp2cuda_i32_sub(csharp2cuda_temp_9, 4));
    }
#line 209 "ScalarModule.cs"
    double reduced = __dsub_rn(__dsub_rn(__dsub_rn(x, __dmul_rn(octant_value, 0.7853981256484985)), __dmul_rn(octant_value, 3.774894707930798E-08)), __dmul_rn(octant_value, 2.6951514290790595E-15));
#line 212 "ScalarModule.cs"
    double square = __dmul_rn(reduced, reduced);
#line 213 "ScalarModule.cs"
#line 213 "ScalarModule.cs"
    bool csharp2cuda_temp_10;
#line 213 "ScalarModule.cs"
    if (!(((octant) == (1))))
    {
#line 213 "ScalarModule.cs"
        csharp2cuda_temp_10 = ((octant) == (2));
    }
    else
    {
#line 213 "ScalarModule.cs"
        csharp2cuda_temp_10 = true;
    }
    if (csharp2cuda_temp_10)
#line 214 "ScalarModule.cs"
    {
#line 215 "ScalarModule.cs"
        double polynomial = __dadd_rn(__dmul_rn(__dsub_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dsub_rn(__dmul_rn(__dadd_rn(__dmul_rn((-(1.1358536521387682E-11)), square), 2.087570084197473E-09), square), 2.755731417929674E-07), square), 2.4801587288851704E-05), square), 0.0013888888888873056), square), 0.041666666666666595);
#line 222 "ScalarModule.cs"
        return __dmul_rn(sign, __dadd_rn(__dsub_rn(1.0, __dmul_rn(0.5, square)), __dmul_rn(__dmul_rn(square, square), polynomial)));
    }
#line 224 "ScalarModule.cs"
    double sine_polynomial = __dsub_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dsub_rn(__dmul_rn(__dadd_rn(__dmul_rn(__dsub_rn(__dmul_rn(1.5896230157654656E-10, square), 2.5050747762857807E-08), square), 2.7557313621385722E-06), square), 0.0001984126982958954), square), 0.008333333333322118), square), 0.1666666666666663);
#line 231 "ScalarModule.cs"
    return __dmul_rn(sign, __dadd_rn(reduced, __dmul_rn(__dmul_rn(reduced, square), sine_polynomial)));
}

#line 34 "ScalarModule.cs"
__device__ double mathblocks_square_root(double value)
#line 36 "ScalarModule.cs"
{
#line 37 "ScalarModule.cs"
#line 37 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 37 "ScalarModule.cs"
    if (!(((value) == (0.0))))
    {
#line 37 "ScalarModule.cs"
        bool csharp2cuda_temp_1;
#line 37 "ScalarModule.cs"
        if (isinf(value))
        {
#line 37 "ScalarModule.cs"
            csharp2cuda_temp_1 = ((value) > (0.0));
        }
        else
        {
#line 37 "ScalarModule.cs"
            csharp2cuda_temp_1 = false;
        }
#line 37 "ScalarModule.cs"
        csharp2cuda_temp_0 = csharp2cuda_temp_1;
    }
    else
    {
#line 37 "ScalarModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 38 "ScalarModule.cs"
        return value;
    }
#line 39 "ScalarModule.cs"
#line 39 "ScalarModule.cs"
    bool csharp2cuda_temp_2;
#line 39 "ScalarModule.cs"
    if (!(((value) < (0.0))))
    {
#line 39 "ScalarModule.cs"
        csharp2cuda_temp_2 = isnan(value);
    }
    else
    {
#line 39 "ScalarModule.cs"
        csharp2cuda_temp_2 = true;
    }
    if (csharp2cuda_temp_2)
    {
#line 40 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 42 "ScalarModule.cs"
    double scaled = value;
#line 43 "ScalarModule.cs"
    double correction = 1.0;
#line 44 "ScalarModule.cs"
    unsigned long long bits = ((unsigned long long)(__double_as_longlong(scaled)));
#line 45 "ScalarModule.cs"
    if (((((bits) & (9218868437227405312ull))) == (0ull)))
#line 46 "ScalarModule.cs"
    {
#line 47 "ScalarModule.cs"
#line 47 "ScalarModule.cs"
        double* csharp2cuda_temp_3 = &(scaled);
#line 47 "ScalarModule.cs"
        double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
        (*(csharp2cuda_temp_3) = __dmul_rn(csharp2cuda_temp_4, __longlong_as_double(csharp2cuda_i64_from_bits(4850376798678024192ull))));
#line 48 "ScalarModule.cs"
#line 48 "ScalarModule.cs"
        double* csharp2cuda_temp_5 = &(correction);
        (*(csharp2cuda_temp_5) = __longlong_as_double(csharp2cuda_i64_from_bits(4485585228861014016ull)));
#line 49 "ScalarModule.cs"
#line 49 "ScalarModule.cs"
        unsigned long long* csharp2cuda_temp_6 = &(bits);
        (*(csharp2cuda_temp_6) = ((unsigned long long)(__double_as_longlong(scaled))));
    }
#line 52 "ScalarModule.cs"
    double estimate = __longlong_as_double(csharp2cuda_i64_from_bits(((csharp2cuda_u64_shr(bits, 1)) + (2303591209400008704ull))));
#line 53 "ScalarModule.cs"
    {
#line 53 "ScalarModule.cs"
        int iteration = 0;
        while (true)
        {
            if (!(((iteration) < (7))))
                break;
#line 54 "ScalarModule.cs"
#line 54 "ScalarModule.cs"
            double* csharp2cuda_temp_8 = &(estimate);
#line 54 "ScalarModule.cs"
            double csharp2cuda_temp_9 = __ddiv_rn(scaled, estimate);
            (*(csharp2cuda_temp_8) = __dmul_rn(0.5, __dadd_rn(estimate, csharp2cuda_temp_9)));
#line 53 "ScalarModule.cs"
            int* csharp2cuda_temp_7 = &(iteration);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_7));
        }
    }
#line 55 "ScalarModule.cs"
    return __dmul_rn(estimate, correction);
}