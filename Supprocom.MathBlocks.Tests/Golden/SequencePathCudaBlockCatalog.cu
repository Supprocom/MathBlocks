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

struct MathBlockSequencePathRun;

#line 35 "SequencePathModule.cs"
struct MathBlockSequencePathRun
{
    int start;
    int length;
    double value;
};

#line 463 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_decline_value(
    const double* values,
    int count,
    bool relative,
    double* value);

#line 429 "SequencePathModule.cs"
__device__ double mathblocks_sequence_first_passage_value(
    const double* values,
    int count,
    double threshold,
    bool at_or_above);

#line 263 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_insert(
    int* heap,
    int* count,
    int item,
    int kind,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum);

#line 192 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_heap_precedes(
    int left,
    int right,
    const int* ranks,
    bool maximum);

#line 286 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_remove(
    int* heap,
    int* count,
    int item,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum);

#line 228 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_down(
    int* heap,
    int count,
    int position,
    int* positions,
    const int* ranks,
    bool maximum);

#line 204 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_up(
    int* heap,
    int position,
    int* positions,
    const int* ranks,
    bool maximum);

#line 178 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_swap(
    int* heap,
    int left,
    int right,
    int* positions);

#line 89 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_is_power_of_two(int value);

#line 448 "SequencePathModule.cs"
__device__ double mathblocks_sequence_longest_run_value(
    const int* values,
    int count);

#line 78 "SequencePathModule.cs"
__device__ unsigned long long mathblocks_sequence_order_key(double value);

#line 551 "SequencePathModule.cs"
__device__ void mathblocks_sequence_path_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 42 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_positive_integer(double value, int* result);

#line 95 "SequencePathModule.cs"
__device__ void mathblocks_sequence_prepare_order_ranks(
    const double* values,
    int count,
    unsigned char* scratch,
    MathBlockSlot* output);

#line 329 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rebalance_heaps(
    int* lower_heap,
    int* lower_count,
    int* upper_heap,
    int* upper_count,
    int target_lower_count,
    int* positions,
    int* kinds,
    const int* ranks);

#line 509 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_recurrence_value(
    const double* values,
    int count,
    double threshold,
    double* value);

#line 384 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_extreme(
    const double* values,
    int count,
    int width,
    double* result,
    int* deque,
    bool minimum);

#line 411 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_sum(
    const double* values,
    int count,
    int width,
    double* result);

#line 61 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_matrix_shape(
    MathBlockSlot* output,
    int rows,
    int columns);

#line 48 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_vector_shape(MathBlockSlot* output, int count);

#line 529 "SequencePathModule.cs"
__device__ double mathblocks_sequence_sign_change_value(
    const double* values,
    int count,
    bool differenced);

#line 487 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_variation_value(
    const double* values,
    int count,
    double order,
    bool absolute,
    double* value);

#line 463 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_decline_value(
    const double* values,
    int count,
    bool relative,
    double* value)
#line 469 "SequencePathModule.cs"
{
#line 470 "SequencePathModule.cs"
    if (((count) <= (0)))
    {
#line 471 "SequencePathModule.cs"
        return false;
    }
#line 472 "SequencePathModule.cs"
    double maximum = (values)[0];
#line 473 "SequencePathModule.cs"
    double decline = 0.0;
#line 474 "SequencePathModule.cs"
    {
#line 474 "SequencePathModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 475 "SequencePathModule.cs"
            {
#line 476 "SequencePathModule.cs"
#line 476 "SequencePathModule.cs"
                double* csharp2cuda_temp_1 = &(maximum);
#line 476 "SequencePathModule.cs"
                double csharp2cuda_temp_2 = (values)[index];
#line 476 "SequencePathModule.cs"
                double csharp2cuda_temp_3;
#line 476 "SequencePathModule.cs"
                if (((maximum) > (csharp2cuda_temp_2)))
                {
#line 476 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = maximum;
                }
                else
                {
#line 476 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = (values)[index];
                }
                (*(csharp2cuda_temp_1) = csharp2cuda_temp_3);
#line 477 "SequencePathModule.cs"
                double csharp2cuda_temp_4;
#line 477 "SequencePathModule.cs"
                if ((!(relative)))
                {
#line 478 "SequencePathModule.cs"
                    double csharp2cuda_temp_5 = (values)[index];
#line 477 "SequencePathModule.cs"
                    csharp2cuda_temp_4 = __dsub_rn(maximum, csharp2cuda_temp_5);
                }
                else
                {
#line 479 "SequencePathModule.cs"
                    double csharp2cuda_temp_6 = (values)[index];
#line 477 "SequencePathModule.cs"
                    csharp2cuda_temp_4 = __ddiv_rn(__dsub_rn(maximum, csharp2cuda_temp_6), maximum);
                }
#line 477 "SequencePathModule.cs"
                double candidate = csharp2cuda_temp_4;
#line 480 "SequencePathModule.cs"
#line 480 "SequencePathModule.cs"
                double* csharp2cuda_temp_7 = &(decline);
#line 480 "SequencePathModule.cs"
                double csharp2cuda_temp_8;
#line 480 "SequencePathModule.cs"
                if (((decline) > (candidate)))
                {
#line 480 "SequencePathModule.cs"
                    csharp2cuda_temp_8 = decline;
                }
                else
                {
#line 480 "SequencePathModule.cs"
                    csharp2cuda_temp_8 = candidate;
                }
                (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
            }
#line 474 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 482 "SequencePathModule.cs"
#line 482 "SequencePathModule.cs"
    double* csharp2cuda_temp_9 = value;
    (*(csharp2cuda_temp_9) = decline);
#line 483 "SequencePathModule.cs"
    return isfinite(decline);
}

#line 429 "SequencePathModule.cs"
__device__ double mathblocks_sequence_first_passage_value(
    const double* values,
    int count,
    double threshold,
    bool at_or_above)
#line 435 "SequencePathModule.cs"
{
#line 436 "SequencePathModule.cs"
    int result_index = -1;
#line 437 "SequencePathModule.cs"
    {
#line 437 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 438 "SequencePathModule.cs"
            {
#line 439 "SequencePathModule.cs"
#line 439 "SequencePathModule.cs"
                bool csharp2cuda_temp_1;
#line 439 "SequencePathModule.cs"
                if (at_or_above)
                {
#line 439 "SequencePathModule.cs"
                    double csharp2cuda_temp_2 = (values)[index];
#line 439 "SequencePathModule.cs"
                    csharp2cuda_temp_1 = ((csharp2cuda_temp_2) >= (threshold));
                }
                else
                {
#line 439 "SequencePathModule.cs"
                    double csharp2cuda_temp_3 = (values)[index];
#line 439 "SequencePathModule.cs"
                    csharp2cuda_temp_1 = ((csharp2cuda_temp_3) <= (threshold));
                }
                if (csharp2cuda_temp_1)
#line 440 "SequencePathModule.cs"
                {
#line 441 "SequencePathModule.cs"
#line 441 "SequencePathModule.cs"
                    int* csharp2cuda_temp_4 = &(result_index);
                    (*(csharp2cuda_temp_4) = index);
#line 442 "SequencePathModule.cs"
                    break;
                }
            }
#line 437 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 445 "SequencePathModule.cs"
    return ((double)(result_index));
}

#line 263 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_insert(
    int* heap,
    int* count,
    int item,
    int kind,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum)
#line 273 "SequencePathModule.cs"
{
#line 274 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = count;
#line 274 "SequencePathModule.cs"
    int position = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
#line 275 "SequencePathModule.cs"
#line 275 "SequencePathModule.cs"
    int* csharp2cuda_temp_1 = &((heap)[position]);
    (*(csharp2cuda_temp_1) = item);
#line 276 "SequencePathModule.cs"
#line 276 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((positions)[item]);
    (*(csharp2cuda_temp_2) = position);
#line 277 "SequencePathModule.cs"
#line 277 "SequencePathModule.cs"
    int* csharp2cuda_temp_3 = &((kinds)[item]);
    (*(csharp2cuda_temp_3) = kind);
#line 278 "SequencePathModule.cs"
    mathblocks_sequence_heap_sift_up(heap, position, positions, ranks, maximum);
}

#line 192 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_heap_precedes(
    int left,
    int right,
    const int* ranks,
    bool maximum)
#line 198 "SequencePathModule.cs"
{
#line 199 "SequencePathModule.cs"
#line 199 "SequencePathModule.cs"
    bool csharp2cuda_temp_0;
#line 199 "SequencePathModule.cs"
    if (maximum)
    {
#line 200 "SequencePathModule.cs"
        int csharp2cuda_temp_1 = (ranks)[left];
#line 200 "SequencePathModule.cs"
        int csharp2cuda_temp_2 = (ranks)[right];
#line 199 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_temp_1) > (csharp2cuda_temp_2));
    }
    else
    {
#line 201 "SequencePathModule.cs"
        int csharp2cuda_temp_3 = (ranks)[left];
#line 201 "SequencePathModule.cs"
        int csharp2cuda_temp_4 = (ranks)[right];
#line 199 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_temp_3) < (csharp2cuda_temp_4));
    }
    return csharp2cuda_temp_0;
}

#line 286 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_remove(
    int* heap,
    int* count,
    int item,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum)
#line 295 "SequencePathModule.cs"
{
#line 296 "SequencePathModule.cs"
    int position = (positions)[item];
#line 297 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = count;
#line 297 "SequencePathModule.cs"
    int csharp2cuda_temp_1 = csharp2cuda_i32_pre_decrement(*(csharp2cuda_temp_0));
#line 297 "SequencePathModule.cs"
    int replacement = (heap)[csharp2cuda_temp_1];
#line 298 "SequencePathModule.cs"
#line 298 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((kinds)[item]);
    (*(csharp2cuda_temp_2) = csharp2cuda_i32_neg(1));
#line 299 "SequencePathModule.cs"
#line 299 "SequencePathModule.cs"
    int* csharp2cuda_temp_3 = &((positions)[item]);
    (*(csharp2cuda_temp_3) = csharp2cuda_i32_neg(1));
#line 300 "SequencePathModule.cs"
#line 300 "SequencePathModule.cs"
    int csharp2cuda_temp_4 = *(count);
    if (((position) >= (csharp2cuda_temp_4)))
    {
#line 301 "SequencePathModule.cs"
        return;
    }
#line 302 "SequencePathModule.cs"
#line 302 "SequencePathModule.cs"
    int* csharp2cuda_temp_5 = &((heap)[position]);
    (*(csharp2cuda_temp_5) = replacement);
#line 303 "SequencePathModule.cs"
#line 303 "SequencePathModule.cs"
    int* csharp2cuda_temp_6 = &((positions)[replacement]);
    (*(csharp2cuda_temp_6) = position);
#line 304 "SequencePathModule.cs"
#line 304 "SequencePathModule.cs"
    bool csharp2cuda_temp_7;
#line 304 "SequencePathModule.cs"
    if (((position) > (0)))
    {
#line 305 "SequencePathModule.cs"
        int csharp2cuda_temp_8 = (heap)[position];
#line 306 "SequencePathModule.cs"
        int csharp2cuda_temp_9 = (heap)[csharp2cuda_i32_shr(csharp2cuda_i32_sub(position, 1), 1)];
#line 304 "SequencePathModule.cs"
        csharp2cuda_temp_7 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_8, csharp2cuda_temp_9, ranks, maximum);
    }
    else
    {
#line 304 "SequencePathModule.cs"
        csharp2cuda_temp_7 = false;
    }
    if (csharp2cuda_temp_7)
#line 309 "SequencePathModule.cs"
    {
#line 310 "SequencePathModule.cs"
        mathblocks_sequence_heap_sift_up(heap, position, positions, ranks, maximum);
    }
    else
#line 318 "SequencePathModule.cs"
    {
#line 319 "SequencePathModule.cs"
#line 321 "SequencePathModule.cs"
        int csharp2cuda_temp_10 = *(count);
        mathblocks_sequence_heap_sift_down(heap, csharp2cuda_temp_10, position, positions, ranks, maximum);
    }
}

#line 228 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_down(
    int* heap,
    int count,
    int position,
    int* positions,
    const int* ranks,
    bool maximum)
#line 236 "SequencePathModule.cs"
{
#line 237 "SequencePathModule.cs"
    while (true)
    {
        if (!(true))
            break;
#line 238 "SequencePathModule.cs"
        {
#line 239 "SequencePathModule.cs"
            int left = csharp2cuda_i32_add(csharp2cuda_i32_mul(position, 2), 1);
#line 240 "SequencePathModule.cs"
            if (((left) >= (count)))
            {
#line 241 "SequencePathModule.cs"
                return;
            }
#line 242 "SequencePathModule.cs"
            int right = csharp2cuda_i32_add(left, 1);
#line 243 "SequencePathModule.cs"
            bool csharp2cuda_temp_0;
#line 243 "SequencePathModule.cs"
            if (((right) < (count)))
            {
#line 244 "SequencePathModule.cs"
                int csharp2cuda_temp_1 = (heap)[right];
#line 245 "SequencePathModule.cs"
                int csharp2cuda_temp_2 = (heap)[left];
#line 243 "SequencePathModule.cs"
                csharp2cuda_temp_0 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_1, csharp2cuda_temp_2, ranks, maximum);
            }
            else
            {
#line 243 "SequencePathModule.cs"
                csharp2cuda_temp_0 = false;
            }
#line 243 "SequencePathModule.cs"
            int csharp2cuda_temp_3;
#line 243 "SequencePathModule.cs"
            if (csharp2cuda_temp_0)
            {
#line 243 "SequencePathModule.cs"
                csharp2cuda_temp_3 = right;
            }
            else
            {
#line 243 "SequencePathModule.cs"
                csharp2cuda_temp_3 = left;
            }
#line 243 "SequencePathModule.cs"
            int selected = csharp2cuda_temp_3;
#line 250 "SequencePathModule.cs"
#line 251 "SequencePathModule.cs"
            int csharp2cuda_temp_4 = (heap)[selected];
#line 252 "SequencePathModule.cs"
            int csharp2cuda_temp_5 = (heap)[position];
#line 250 "SequencePathModule.cs"
            bool csharp2cuda_temp_6 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_4, csharp2cuda_temp_5, ranks, maximum);
            if ((!(csharp2cuda_temp_6)))
#line 255 "SequencePathModule.cs"
            {
#line 256 "SequencePathModule.cs"
                return;
            }
#line 258 "SequencePathModule.cs"
            mathblocks_sequence_heap_swap(heap, position, selected, positions);
#line 259 "SequencePathModule.cs"
#line 259 "SequencePathModule.cs"
            int* csharp2cuda_temp_7 = &(position);
            (*(csharp2cuda_temp_7) = selected);
        }
    }
}

#line 204 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_up(
    int* heap,
    int position,
    int* positions,
    const int* ranks,
    bool maximum)
#line 211 "SequencePathModule.cs"
{
#line 212 "SequencePathModule.cs"
    while (true)
    {
        if (!(((position) > (0))))
            break;
#line 213 "SequencePathModule.cs"
        {
#line 214 "SequencePathModule.cs"
            int parent = csharp2cuda_i32_shr(csharp2cuda_i32_sub(position, 1), 1);
#line 215 "SequencePathModule.cs"
#line 216 "SequencePathModule.cs"
            int csharp2cuda_temp_0 = (heap)[position];
#line 217 "SequencePathModule.cs"
            int csharp2cuda_temp_1 = (heap)[parent];
#line 215 "SequencePathModule.cs"
            bool csharp2cuda_temp_2 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_0, csharp2cuda_temp_1, ranks, maximum);
            if ((!(csharp2cuda_temp_2)))
#line 220 "SequencePathModule.cs"
            {
#line 221 "SequencePathModule.cs"
                break;
            }
#line 223 "SequencePathModule.cs"
            mathblocks_sequence_heap_swap(heap, position, parent, positions);
#line 224 "SequencePathModule.cs"
#line 224 "SequencePathModule.cs"
            int* csharp2cuda_temp_3 = &(position);
            (*(csharp2cuda_temp_3) = parent);
        }
    }
}

#line 178 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_swap(
    int* heap,
    int left,
    int right,
    int* positions)
#line 184 "SequencePathModule.cs"
{
#line 185 "SequencePathModule.cs"
    int value = (heap)[left];
#line 186 "SequencePathModule.cs"
#line 186 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = &((heap)[left]);
#line 186 "SequencePathModule.cs"
    int csharp2cuda_temp_1 = (heap)[right];
    (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
#line 187 "SequencePathModule.cs"
#line 187 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((heap)[right]);
    (*(csharp2cuda_temp_2) = value);
#line 188 "SequencePathModule.cs"
#line 188 "SequencePathModule.cs"
    int csharp2cuda_temp_3 = (heap)[left];
#line 188 "SequencePathModule.cs"
    int* csharp2cuda_temp_4 = &((positions)[csharp2cuda_temp_3]);
    (*(csharp2cuda_temp_4) = left);
#line 189 "SequencePathModule.cs"
#line 189 "SequencePathModule.cs"
    int csharp2cuda_temp_5 = (heap)[right];
#line 189 "SequencePathModule.cs"
    int* csharp2cuda_temp_6 = &((positions)[csharp2cuda_temp_5]);
    (*(csharp2cuda_temp_6) = right);
}

#line 89 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_is_power_of_two(int value)
#line 91 "SequencePathModule.cs"
{
#line 92 "SequencePathModule.cs"
#line 92 "SequencePathModule.cs"
    bool csharp2cuda_temp_0;
#line 92 "SequencePathModule.cs"
    if (((value) > (0)))
    {
#line 92 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_i32_and(value, csharp2cuda_i32_sub(value, 1))) == (0));
    }
    else
    {
#line 92 "SequencePathModule.cs"
        csharp2cuda_temp_0 = false;
    }
    return csharp2cuda_temp_0;
}

#line 448 "SequencePathModule.cs"
__device__ double mathblocks_sequence_longest_run_value(
    const int* values,
    int count)
#line 452 "SequencePathModule.cs"
{
#line 453 "SequencePathModule.cs"
    int maximum = 0;
#line 454 "SequencePathModule.cs"
    int current = 0;
#line 455 "SequencePathModule.cs"
    {
#line 455 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 456 "SequencePathModule.cs"
            {
#line 457 "SequencePathModule.cs"
#line 457 "SequencePathModule.cs"
                int* csharp2cuda_temp_1 = &(current);
#line 457 "SequencePathModule.cs"
                bool csharp2cuda_temp_2 = (values)[index];
#line 457 "SequencePathModule.cs"
                int csharp2cuda_temp_3;
#line 457 "SequencePathModule.cs"
                if (csharp2cuda_temp_2)
                {
#line 457 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = csharp2cuda_i32_add(current, 1);
                }
                else
                {
#line 457 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = 0;
                }
                (*(csharp2cuda_temp_1) = csharp2cuda_temp_3);
#line 458 "SequencePathModule.cs"
#line 458 "SequencePathModule.cs"
                int* csharp2cuda_temp_4 = &(maximum);
#line 458 "SequencePathModule.cs"
                int csharp2cuda_temp_5;
#line 458 "SequencePathModule.cs"
                if (((maximum) > (current)))
                {
#line 458 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = maximum;
                }
                else
                {
#line 458 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = current;
                }
                (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
            }
#line 455 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 460 "SequencePathModule.cs"
    return ((double)(maximum));
}

#line 78 "SequencePathModule.cs"
__device__ unsigned long long mathblocks_sequence_order_key(double value)
#line 80 "SequencePathModule.cs"
{
#line 81 "SequencePathModule.cs"
    unsigned long long bits = ((unsigned long long)(__double_as_longlong(value)));
#line 82 "SequencePathModule.cs"
    if (((value) == (0.0)))
    {
#line 83 "SequencePathModule.cs"
#line 83 "SequencePathModule.cs"
        unsigned long long* csharp2cuda_temp_0 = &(bits);
        (*(csharp2cuda_temp_0) = 0ull);
    }
#line 84 "SequencePathModule.cs"
#line 84 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_1;
#line 84 "SequencePathModule.cs"
    if (((((bits) & (9223372036854775808ull))) != (0ull)))
    {
#line 84 "SequencePathModule.cs"
        csharp2cuda_temp_1 = (~(bits));
    }
    else
    {
#line 84 "SequencePathModule.cs"
        csharp2cuda_temp_1 = ((bits) ^ (9223372036854775808ull));
    }
    return csharp2cuda_temp_1;
}

#line 551 "SequencePathModule.cs"
__device__ void mathblocks_sequence_path_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 557 "SequencePathModule.cs"
{
#line 558 "SequencePathModule.cs"
    int thread = threadIdx.x;
#line 559 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 559 "SequencePathModule.cs"
    if (((input_count) > (0)))
    {
#line 559 "SequencePathModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 559 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 559 "SequencePathModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 560 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 560 "SequencePathModule.cs"
    if (((input_count) > (1)))
    {
#line 560 "SequencePathModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 560 "SequencePathModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 560 "SequencePathModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 561 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 561 "SequencePathModule.cs"
    if (((input_count) > (2)))
    {
#line 561 "SequencePathModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 561 "SequencePathModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 561 "SequencePathModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 562 "SequencePathModule.cs"
    if (((thread) == (0)))
#line 563 "SequencePathModule.cs"
    {
#line 564 "SequencePathModule.cs"
#line 564 "SequencePathModule.cs"
        double* csharp2cuda_temp_3 = &((output)->scalar_value);
        (*(csharp2cuda_temp_3) = 0.0);
#line 565 "SequencePathModule.cs"
#line 565 "SequencePathModule.cs"
        int* csharp2cuda_temp_4 = &((output)->boolean_value);
        (*(csharp2cuda_temp_4) = 0);
#line 566 "SequencePathModule.cs"
#line 566 "SequencePathModule.cs"
        int* csharp2cuda_temp_5 = &((output)->rows);
        (*(csharp2cuda_temp_5) = 0);
#line 567 "SequencePathModule.cs"
#line 567 "SequencePathModule.cs"
        int* csharp2cuda_temp_6 = &((output)->columns);
        (*(csharp2cuda_temp_6) = 0);
#line 568 "SequencePathModule.cs"
#line 568 "SequencePathModule.cs"
        int* csharp2cuda_temp_7 = &((output)->count);
        (*(csharp2cuda_temp_7) = 0);
#line 569 "SequencePathModule.cs"
#line 569 "SequencePathModule.cs"
        int* csharp2cuda_temp_8 = &((output)->valid);
#line 569 "SequencePathModule.cs"
        bool csharp2cuda_temp_9;
#line 569 "SequencePathModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 569 "SequencePathModule.cs"
            csharp2cuda_temp_9 = (first)->valid;
        }
        else
        {
#line 569 "SequencePathModule.cs"
            csharp2cuda_temp_9 = true;
        }
        (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
#line 570 "SequencePathModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 571 "SequencePathModule.cs"
#line 571 "SequencePathModule.cs"
            int* csharp2cuda_temp_10 = &((output)->valid);
#line 571 "SequencePathModule.cs"
            bool csharp2cuda_temp_11 = (output)->valid;
#line 571 "SequencePathModule.cs"
            bool csharp2cuda_temp_12;
#line 571 "SequencePathModule.cs"
            if (csharp2cuda_temp_11)
            {
#line 571 "SequencePathModule.cs"
                csharp2cuda_temp_12 = (second)->valid;
            }
            else
            {
#line 571 "SequencePathModule.cs"
                csharp2cuda_temp_12 = false;
            }
            (*(csharp2cuda_temp_10) = csharp2cuda_temp_12);
        }
#line 572 "SequencePathModule.cs"
        if (((((void*)(third))) != (((void*)(nullptr)))))
        {
#line 573 "SequencePathModule.cs"
#line 573 "SequencePathModule.cs"
            int* csharp2cuda_temp_13 = &((output)->valid);
#line 573 "SequencePathModule.cs"
            bool csharp2cuda_temp_14 = (output)->valid;
#line 573 "SequencePathModule.cs"
            bool csharp2cuda_temp_15;
#line 573 "SequencePathModule.cs"
            if (csharp2cuda_temp_14)
            {
#line 573 "SequencePathModule.cs"
                csharp2cuda_temp_15 = (third)->valid;
            }
            else
            {
#line 573 "SequencePathModule.cs"
                csharp2cuda_temp_15 = false;
            }
            (*(csharp2cuda_temp_13) = csharp2cuda_temp_15);
        }
    }
#line 575 "SequencePathModule.cs"
    __syncthreads();
#line 576 "SequencePathModule.cs"
#line 576 "SequencePathModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 577 "SequencePathModule.cs"
        return;
    }
#line 579 "SequencePathModule.cs"
    double* csharp2cuda_temp_17;
#line 579 "SequencePathModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 579 "SequencePathModule.cs"
        csharp2cuda_temp_17 = ((double*)(nullptr));
    }
    else
    {
#line 579 "SequencePathModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 579 "SequencePathModule.cs"
        csharp2cuda_temp_17 = ((double*)(csharp2cuda_temp_18));
    }
#line 579 "SequencePathModule.cs"
    const double* a = csharp2cuda_temp_17;
#line 580 "SequencePathModule.cs"
    double* csharp2cuda_temp_19;
#line 580 "SequencePathModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 580 "SequencePathModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 580 "SequencePathModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 580 "SequencePathModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 580 "SequencePathModule.cs"
    const double* b = csharp2cuda_temp_19;
#line 581 "SequencePathModule.cs"
    int* csharp2cuda_temp_21;
#line 581 "SequencePathModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 581 "SequencePathModule.cs"
        csharp2cuda_temp_21 = ((int*)(nullptr));
    }
    else
    {
#line 581 "SequencePathModule.cs"
        unsigned long long csharp2cuda_temp_22 = (first)->data_pointer;
#line 581 "SequencePathModule.cs"
        csharp2cuda_temp_21 = ((int*)(csharp2cuda_temp_22));
    }
#line 581 "SequencePathModule.cs"
    const int* boolean_a = csharp2cuda_temp_21;
#line 582 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_23 = (output)->data_pointer;
#line 582 "SequencePathModule.cs"
    double* result = ((double*)(csharp2cuda_temp_23));
#line 583 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_24 = (output)->scratch_pointer;
#line 583 "SequencePathModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_24));
#line 585 "SequencePathModule.cs"
    switch (opcode)
    {
#line 587 "SequencePathModule.cs"
        case 0:
#line 588 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 589 "SequencePathModule.cs"
            {
#line 590 "SequencePathModule.cs"
                int csharp2cuda_temp_25 = (first)->count;
#line 590 "SequencePathModule.cs"
                int csharp2cuda_temp_26 = (second)->count;
#line 590 "SequencePathModule.cs"
                int count = csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_temp_25, csharp2cuda_temp_26), 1);
#line 591 "SequencePathModule.cs"
                mathblocks_sequence_set_vector_shape(output, count);
#line 592 "SequencePathModule.cs"
#line 592 "SequencePathModule.cs"
                int csharp2cuda_temp_27 = (first)->count;
#line 592 "SequencePathModule.cs"
                bool csharp2cuda_temp_28;
#line 592 "SequencePathModule.cs"
                if (!(((csharp2cuda_temp_27) <= (0))))
                {
#line 592 "SequencePathModule.cs"
                    int csharp2cuda_temp_29 = (second)->count;
#line 592 "SequencePathModule.cs"
                    csharp2cuda_temp_28 = ((csharp2cuda_temp_29) <= (0));
                }
                else
                {
#line 592 "SequencePathModule.cs"
                    csharp2cuda_temp_28 = true;
                }
                if (csharp2cuda_temp_28)
                {
#line 593 "SequencePathModule.cs"
#line 593 "SequencePathModule.cs"
                    int* csharp2cuda_temp_30 = &((output)->valid);
                    (*(csharp2cuda_temp_30) = 0);
                }
#line 594 "SequencePathModule.cs"
                {
#line 594 "SequencePathModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 594 "SequencePathModule.cs"
                        bool csharp2cuda_temp_32 = (output)->valid;
#line 594 "SequencePathModule.cs"
                        bool csharp2cuda_temp_33;
#line 594 "SequencePathModule.cs"
                        if (csharp2cuda_temp_32)
                        {
#line 594 "SequencePathModule.cs"
                            csharp2cuda_temp_33 = ((index) < (count));
                        }
                        else
                        {
#line 594 "SequencePathModule.cs"
                            csharp2cuda_temp_33 = false;
                        }
                        if (!(csharp2cuda_temp_33))
                            break;
#line 595 "SequencePathModule.cs"
#line 595 "SequencePathModule.cs"
                        double* csharp2cuda_temp_34 = &((result)[index]);
                        (*(csharp2cuda_temp_34) = 0.0);
#line 594 "SequencePathModule.cs"
                        int* csharp2cuda_temp_31 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                    }
                }
#line 596 "SequencePathModule.cs"
                {
#line 596 "SequencePathModule.cs"
                    int left = 0;
                    while (true)
                    {
#line 596 "SequencePathModule.cs"
                        bool csharp2cuda_temp_36 = (output)->valid;
#line 596 "SequencePathModule.cs"
                        bool csharp2cuda_temp_37;
#line 596 "SequencePathModule.cs"
                        if (csharp2cuda_temp_36)
                        {
#line 596 "SequencePathModule.cs"
                            int csharp2cuda_temp_38 = (first)->count;
#line 596 "SequencePathModule.cs"
                            csharp2cuda_temp_37 = ((left) < (csharp2cuda_temp_38));
                        }
                        else
                        {
#line 596 "SequencePathModule.cs"
                            csharp2cuda_temp_37 = false;
                        }
                        if (!(csharp2cuda_temp_37))
                            break;
#line 597 "SequencePathModule.cs"
                        {
#line 598 "SequencePathModule.cs"
                            {
#line 598 "SequencePathModule.cs"
                                int right = 0;
                                while (true)
                                {
#line 598 "SequencePathModule.cs"
                                    int csharp2cuda_temp_40 = (second)->count;
                                    if (!(((right) < (csharp2cuda_temp_40))))
                                        break;
#line 599 "SequencePathModule.cs"
                                    {
#line 600 "SequencePathModule.cs"
#line 600 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_41 = &((result)[csharp2cuda_i32_add(left, right)]);
#line 600 "SequencePathModule.cs"
                                        double csharp2cuda_temp_42 = *(csharp2cuda_temp_41);
#line 600 "SequencePathModule.cs"
                                        double csharp2cuda_temp_43 = (a)[left];
#line 600 "SequencePathModule.cs"
                                        double csharp2cuda_temp_44 = (b)[right];
                                        (*(csharp2cuda_temp_41) = __dadd_rn(csharp2cuda_temp_42, __dmul_rn(csharp2cuda_temp_43, csharp2cuda_temp_44)));
#line 601 "SequencePathModule.cs"
#line 601 "SequencePathModule.cs"
                                        double csharp2cuda_temp_45 = (result)[csharp2cuda_i32_add(left, right)];
                                        if ((!(isfinite(csharp2cuda_temp_45))))
                                        {
#line 602 "SequencePathModule.cs"
#line 602 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_46 = &((output)->valid);
                                            (*(csharp2cuda_temp_46) = 0);
                                        }
                                    }
#line 598 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_39 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_39));
                                }
                            }
                        }
#line 596 "SequencePathModule.cs"
                        int* csharp2cuda_temp_35 = &(left);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_35));
                    }
                }
            }
#line 606 "SequencePathModule.cs"
            break;
#line 607 "SequencePathModule.cs"
        case 1:
#line 608 "SequencePathModule.cs"
            {
#line 609 "SequencePathModule.cs"
                int lag = 0;
#line 610 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 611 "SequencePathModule.cs"
                {
#line 612 "SequencePathModule.cs"
#line 612 "SequencePathModule.cs"
                    double csharp2cuda_temp_47 = (second)->scalar_value;
#line 612 "SequencePathModule.cs"
                    int* csharp2cuda_temp_48 = &(lag);
#line 612 "SequencePathModule.cs"
                    bool csharp2cuda_temp_49 = mathblocks_sequence_positive_integer(csharp2cuda_temp_47, csharp2cuda_temp_48);
#line 612 "SequencePathModule.cs"
                    bool csharp2cuda_temp_50;
#line 612 "SequencePathModule.cs"
                    if (!((!(csharp2cuda_temp_49))))
                    {
#line 612 "SequencePathModule.cs"
                        int csharp2cuda_temp_51 = (first)->count;
#line 612 "SequencePathModule.cs"
                        csharp2cuda_temp_50 = ((lag) >= (csharp2cuda_temp_51));
                    }
                    else
                    {
#line 612 "SequencePathModule.cs"
                        csharp2cuda_temp_50 = true;
                    }
                    if (csharp2cuda_temp_50)
                    {
#line 613 "SequencePathModule.cs"
#line 613 "SequencePathModule.cs"
                        int* csharp2cuda_temp_52 = &((output)->valid);
                        (*(csharp2cuda_temp_52) = 0);
                    }
                    else
                    {
#line 615 "SequencePathModule.cs"
#line 615 "SequencePathModule.cs"
                        int csharp2cuda_temp_53 = (first)->count;
                        mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_sub(csharp2cuda_temp_53, lag));
                    }
#line 616 "SequencePathModule.cs"
#line 616 "SequencePathModule.cs"
                    double* csharp2cuda_temp_54 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_54) = ((double)(lag)));
                }
#line 618 "SequencePathModule.cs"
                __syncthreads();
#line 619 "SequencePathModule.cs"
#line 619 "SequencePathModule.cs"
                int* csharp2cuda_temp_55 = &(lag);
#line 619 "SequencePathModule.cs"
                double csharp2cuda_temp_56 = (output)->scalar_value;
                (*(csharp2cuda_temp_55) = csharp2cuda_f64_to_i32(csharp2cuda_temp_56));
#line 620 "SequencePathModule.cs"
                {
#line 620 "SequencePathModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 620 "SequencePathModule.cs"
                        bool csharp2cuda_temp_59 = (output)->valid;
#line 620 "SequencePathModule.cs"
                        bool csharp2cuda_temp_60;
#line 620 "SequencePathModule.cs"
                        if (csharp2cuda_temp_59)
                        {
#line 620 "SequencePathModule.cs"
                            int csharp2cuda_temp_61 = (output)->count;
#line 620 "SequencePathModule.cs"
                            csharp2cuda_temp_60 = ((index) < (csharp2cuda_temp_61));
                        }
                        else
                        {
#line 620 "SequencePathModule.cs"
                            csharp2cuda_temp_60 = false;
                        }
                        if (!(csharp2cuda_temp_60))
                            break;
#line 621 "SequencePathModule.cs"
#line 621 "SequencePathModule.cs"
                        double* csharp2cuda_temp_62 = &((result)[index]);
#line 621 "SequencePathModule.cs"
                        double csharp2cuda_temp_63 = (a)[csharp2cuda_i32_add(index, lag)];
#line 621 "SequencePathModule.cs"
                        double csharp2cuda_temp_64 = (a)[index];
                        (*(csharp2cuda_temp_62) = __dsub_rn(csharp2cuda_temp_63, csharp2cuda_temp_64));
#line 620 "SequencePathModule.cs"
                        int* csharp2cuda_temp_57 = &(index);
#line 620 "SequencePathModule.cs"
                        int csharp2cuda_temp_58 = *(csharp2cuda_temp_57);
                        (*(csharp2cuda_temp_57) = csharp2cuda_i32_add(csharp2cuda_temp_58, blockDim.x));
                    }
                }
#line 622 "SequencePathModule.cs"
                break;
            }
#line 624 "SequencePathModule.cs"
        case 2:
#line 625 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 626 "SequencePathModule.cs"
            {
#line 627 "SequencePathModule.cs"
                double alpha = (second)->scalar_value;
#line 628 "SequencePathModule.cs"
#line 628 "SequencePathModule.cs"
                int csharp2cuda_temp_65 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_65);
#line 629 "SequencePathModule.cs"
#line 629 "SequencePathModule.cs"
                int csharp2cuda_temp_66 = (first)->count;
#line 629 "SequencePathModule.cs"
                bool csharp2cuda_temp_67;
#line 629 "SequencePathModule.cs"
                if (!(((csharp2cuda_temp_66) <= (0))))
                {
#line 629 "SequencePathModule.cs"
                    bool csharp2cuda_temp_68;
#line 629 "SequencePathModule.cs"
                    if (((alpha) > (0.0)))
                    {
#line 629 "SequencePathModule.cs"
                        csharp2cuda_temp_68 = ((alpha) <= (1.0));
                    }
                    else
                    {
#line 629 "SequencePathModule.cs"
                        csharp2cuda_temp_68 = false;
                    }
#line 629 "SequencePathModule.cs"
                    csharp2cuda_temp_67 = (!(csharp2cuda_temp_68));
                }
                else
                {
#line 629 "SequencePathModule.cs"
                    csharp2cuda_temp_67 = true;
                }
                if (csharp2cuda_temp_67)
                {
#line 630 "SequencePathModule.cs"
#line 630 "SequencePathModule.cs"
                    int* csharp2cuda_temp_69 = &((output)->valid);
                    (*(csharp2cuda_temp_69) = 0);
                }
#line 631 "SequencePathModule.cs"
                if ((output)->valid)
#line 632 "SequencePathModule.cs"
                {
#line 633 "SequencePathModule.cs"
#line 633 "SequencePathModule.cs"
                    double* csharp2cuda_temp_70 = &((result)[0]);
#line 633 "SequencePathModule.cs"
                    double csharp2cuda_temp_71 = (a)[0];
                    (*(csharp2cuda_temp_70) = csharp2cuda_temp_71);
#line 634 "SequencePathModule.cs"
                    {
#line 634 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 634 "SequencePathModule.cs"
                            int csharp2cuda_temp_73 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_73))))
                                break;
#line 635 "SequencePathModule.cs"
                            {
#line 636 "SequencePathModule.cs"
#line 636 "SequencePathModule.cs"
                                double* csharp2cuda_temp_74 = &((result)[index]);
#line 636 "SequencePathModule.cs"
                                double csharp2cuda_temp_75 = (a)[index];
#line 636 "SequencePathModule.cs"
                                double csharp2cuda_temp_76 = (result)[csharp2cuda_i32_sub(index, 1)];
                                (*(csharp2cuda_temp_74) = __dadd_rn(__dmul_rn(alpha, csharp2cuda_temp_75), __dmul_rn(__dsub_rn(1.0, alpha), csharp2cuda_temp_76)));
#line 637 "SequencePathModule.cs"
#line 637 "SequencePathModule.cs"
                                double csharp2cuda_temp_77 = (result)[index];
                                if ((!(isfinite(csharp2cuda_temp_77))))
                                {
#line 638 "SequencePathModule.cs"
#line 638 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_78 = &((output)->valid);
                                    (*(csharp2cuda_temp_78) = 0);
                                }
                            }
#line 634 "SequencePathModule.cs"
                            int* csharp2cuda_temp_72 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_72));
                        }
                    }
                }
            }
#line 642 "SequencePathModule.cs"
            break;
#line 643 "SequencePathModule.cs"
        case 3:
        case 6:
#line 645 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 646 "SequencePathModule.cs"
            {
#line 647 "SequencePathModule.cs"
                int width = 0;
#line 648 "SequencePathModule.cs"
#line 648 "SequencePathModule.cs"
                double csharp2cuda_temp_79 = (second)->scalar_value;
#line 648 "SequencePathModule.cs"
                int* csharp2cuda_temp_80 = &(width);
#line 648 "SequencePathModule.cs"
                bool csharp2cuda_temp_81 = mathblocks_sequence_positive_integer(csharp2cuda_temp_79, csharp2cuda_temp_80);
#line 648 "SequencePathModule.cs"
                bool csharp2cuda_temp_82;
#line 648 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_81))))
                {
#line 649 "SequencePathModule.cs"
                    int csharp2cuda_temp_83 = (first)->count;
#line 648 "SequencePathModule.cs"
                    csharp2cuda_temp_82 = ((width) > (csharp2cuda_temp_83));
                }
                else
                {
#line 648 "SequencePathModule.cs"
                    csharp2cuda_temp_82 = true;
                }
#line 648 "SequencePathModule.cs"
                bool csharp2cuda_temp_84;
#line 648 "SequencePathModule.cs"
                if (!(csharp2cuda_temp_82))
                {
#line 648 "SequencePathModule.cs"
                    csharp2cuda_temp_84 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 648 "SequencePathModule.cs"
                    csharp2cuda_temp_84 = true;
                }
                if (csharp2cuda_temp_84)
#line 650 "SequencePathModule.cs"
                {
#line 651 "SequencePathModule.cs"
#line 651 "SequencePathModule.cs"
                    int* csharp2cuda_temp_85 = &((output)->valid);
                    (*(csharp2cuda_temp_85) = 0);
                }
                else
#line 654 "SequencePathModule.cs"
                {
#line 655 "SequencePathModule.cs"
#line 655 "SequencePathModule.cs"
                    int csharp2cuda_temp_86 = (first)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_86, width), 1));
#line 656 "SequencePathModule.cs"
                    int* deque = ((int*)(scratch));
#line 657 "SequencePathModule.cs"
                    int head = 0;
#line 658 "SequencePathModule.cs"
                    int tail = 0;
#line 659 "SequencePathModule.cs"
                    {
#line 659 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 659 "SequencePathModule.cs"
                            int csharp2cuda_temp_88 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_88))))
                                break;
#line 660 "SequencePathModule.cs"
                            {
#line 661 "SequencePathModule.cs"
                                while (true)
                                {
#line 661 "SequencePathModule.cs"
                                    bool csharp2cuda_temp_89;
#line 661 "SequencePathModule.cs"
                                    if (((head) < (tail)))
                                    {
#line 661 "SequencePathModule.cs"
                                        int csharp2cuda_temp_90 = (deque)[head];
#line 661 "SequencePathModule.cs"
                                        csharp2cuda_temp_89 = ((csharp2cuda_temp_90) <= (csharp2cuda_i32_sub(index, width)));
                                    }
                                    else
                                    {
#line 661 "SequencePathModule.cs"
                                        csharp2cuda_temp_89 = false;
                                    }
                                    if (!(csharp2cuda_temp_89))
                                        break;
#line 662 "SequencePathModule.cs"
#line 662 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_91 = &(head);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_91));
                                }
#line 663 "SequencePathModule.cs"
                                while (true)
                                {
#line 663 "SequencePathModule.cs"
                                    bool csharp2cuda_temp_92;
#line 663 "SequencePathModule.cs"
                                    if (((head) < (tail)))
                                    {
#line 663 "SequencePathModule.cs"
                                        bool csharp2cuda_temp_93;
#line 663 "SequencePathModule.cs"
                                        if (((opcode) == (6)))
                                        {
#line 664 "SequencePathModule.cs"
                                            int csharp2cuda_temp_94 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 664 "SequencePathModule.cs"
                                            double csharp2cuda_temp_95 = (a)[csharp2cuda_temp_94];
#line 664 "SequencePathModule.cs"
                                            double csharp2cuda_temp_96 = (a)[index];
#line 663 "SequencePathModule.cs"
                                            csharp2cuda_temp_93 = ((csharp2cuda_temp_95) >= (csharp2cuda_temp_96));
                                        }
                                        else
                                        {
#line 665 "SequencePathModule.cs"
                                            int csharp2cuda_temp_97 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 665 "SequencePathModule.cs"
                                            double csharp2cuda_temp_98 = (a)[csharp2cuda_temp_97];
#line 665 "SequencePathModule.cs"
                                            double csharp2cuda_temp_99 = (a)[index];
#line 663 "SequencePathModule.cs"
                                            csharp2cuda_temp_93 = ((csharp2cuda_temp_98) <= (csharp2cuda_temp_99));
                                        }
#line 663 "SequencePathModule.cs"
                                        csharp2cuda_temp_92 = csharp2cuda_temp_93;
                                    }
                                    else
                                    {
#line 663 "SequencePathModule.cs"
                                        csharp2cuda_temp_92 = false;
                                    }
                                    if (!(csharp2cuda_temp_92))
                                        break;
#line 666 "SequencePathModule.cs"
                                    {
#line 667 "SequencePathModule.cs"
#line 667 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_100 = &(tail);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_100));
                                    }
                                }
#line 669 "SequencePathModule.cs"
#line 669 "SequencePathModule.cs"
                                int* csharp2cuda_temp_101 = &(tail);
#line 669 "SequencePathModule.cs"
                                int csharp2cuda_temp_102 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_101));
#line 669 "SequencePathModule.cs"
                                int* csharp2cuda_temp_103 = &((deque)[csharp2cuda_temp_102]);
                                (*(csharp2cuda_temp_103) = index);
#line 670 "SequencePathModule.cs"
                                if (((index) >= (csharp2cuda_i32_sub(width, 1))))
                                {
#line 671 "SequencePathModule.cs"
#line 671 "SequencePathModule.cs"
                                    double* csharp2cuda_temp_104 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_sub(index, width), 1)]);
#line 671 "SequencePathModule.cs"
                                    int csharp2cuda_temp_105 = (deque)[head];
#line 671 "SequencePathModule.cs"
                                    double csharp2cuda_temp_106 = (a)[csharp2cuda_temp_105];
                                    (*(csharp2cuda_temp_104) = csharp2cuda_temp_106);
                                }
                            }
#line 659 "SequencePathModule.cs"
                            int* csharp2cuda_temp_87 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_87));
                        }
                    }
                }
            }
#line 675 "SequencePathModule.cs"
            break;
#line 676 "SequencePathModule.cs"
        case 4:
        case 9:
#line 678 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 679 "SequencePathModule.cs"
            {
#line 680 "SequencePathModule.cs"
                int width = 0;
#line 681 "SequencePathModule.cs"
#line 681 "SequencePathModule.cs"
                double csharp2cuda_temp_107 = (second)->scalar_value;
#line 681 "SequencePathModule.cs"
                int* csharp2cuda_temp_108 = &(width);
#line 681 "SequencePathModule.cs"
                bool csharp2cuda_temp_109 = mathblocks_sequence_positive_integer(csharp2cuda_temp_107, csharp2cuda_temp_108);
#line 681 "SequencePathModule.cs"
                bool csharp2cuda_temp_110;
#line 681 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_109))))
                {
#line 681 "SequencePathModule.cs"
                    int csharp2cuda_temp_111 = (first)->count;
#line 681 "SequencePathModule.cs"
                    csharp2cuda_temp_110 = ((width) > (csharp2cuda_temp_111));
                }
                else
                {
#line 681 "SequencePathModule.cs"
                    csharp2cuda_temp_110 = true;
                }
                if (csharp2cuda_temp_110)
#line 682 "SequencePathModule.cs"
                {
#line 683 "SequencePathModule.cs"
#line 683 "SequencePathModule.cs"
                    int* csharp2cuda_temp_112 = &((output)->valid);
                    (*(csharp2cuda_temp_112) = 0);
                }
                else
#line 686 "SequencePathModule.cs"
                {
#line 687 "SequencePathModule.cs"
#line 687 "SequencePathModule.cs"
                    int csharp2cuda_temp_113 = (first)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_113, width), 1));
#line 688 "SequencePathModule.cs"
#line 688 "SequencePathModule.cs"
                    int csharp2cuda_temp_114 = (first)->count;
                    mathblocks_sequence_rolling_sum(a, csharp2cuda_temp_114, width, result);
#line 689 "SequencePathModule.cs"
                    if (((opcode) == (4)))
#line 690 "SequencePathModule.cs"
                    {
#line 691 "SequencePathModule.cs"
                        double scale = __ddiv_rn(1.0, ((double)(width)));
#line 692 "SequencePathModule.cs"
                        {
#line 692 "SequencePathModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 692 "SequencePathModule.cs"
                                int csharp2cuda_temp_116 = (output)->count;
                                if (!(((index) < (csharp2cuda_temp_116))))
                                    break;
#line 693 "SequencePathModule.cs"
#line 693 "SequencePathModule.cs"
                                double* csharp2cuda_temp_117 = &((result)[index]);
#line 693 "SequencePathModule.cs"
                                double csharp2cuda_temp_118 = *(csharp2cuda_temp_117);
                                (*(csharp2cuda_temp_117) = __dmul_rn(csharp2cuda_temp_118, scale));
#line 692 "SequencePathModule.cs"
                                int* csharp2cuda_temp_115 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_115));
                            }
                        }
                    }
                }
            }
#line 697 "SequencePathModule.cs"
            break;
#line 698 "SequencePathModule.cs"
        case 5:
        case 7:
#line 700 "SequencePathModule.cs"
            {
#line 701 "SequencePathModule.cs"
                int width = 0;
#line 702 "SequencePathModule.cs"
                double probability = 0.0;
#line 703 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 704 "SequencePathModule.cs"
                {
#line 705 "SequencePathModule.cs"
#line 705 "SequencePathModule.cs"
                    double* csharp2cuda_temp_119 = &(probability);
#line 705 "SequencePathModule.cs"
                    double csharp2cuda_temp_120;
#line 705 "SequencePathModule.cs"
                    if (((opcode) == (5)))
                    {
#line 705 "SequencePathModule.cs"
                        csharp2cuda_temp_120 = 0.5;
                    }
                    else
                    {
#line 705 "SequencePathModule.cs"
                        csharp2cuda_temp_120 = (third)->scalar_value;
                    }
                    (*(csharp2cuda_temp_119) = csharp2cuda_temp_120);
#line 706 "SequencePathModule.cs"
#line 706 "SequencePathModule.cs"
                    double csharp2cuda_temp_121 = (second)->scalar_value;
#line 706 "SequencePathModule.cs"
                    int* csharp2cuda_temp_122 = &(width);
#line 706 "SequencePathModule.cs"
                    bool csharp2cuda_temp_123 = mathblocks_sequence_positive_integer(csharp2cuda_temp_121, csharp2cuda_temp_122);
#line 706 "SequencePathModule.cs"
                    bool csharp2cuda_temp_124;
#line 706 "SequencePathModule.cs"
                    if (!((!(csharp2cuda_temp_123))))
                    {
#line 707 "SequencePathModule.cs"
                        int csharp2cuda_temp_125 = (first)->count;
#line 706 "SequencePathModule.cs"
                        csharp2cuda_temp_124 = ((width) > (csharp2cuda_temp_125));
                    }
                    else
                    {
#line 706 "SequencePathModule.cs"
                        csharp2cuda_temp_124 = true;
                    }
#line 706 "SequencePathModule.cs"
                    bool csharp2cuda_temp_126;
#line 706 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_124))
                    {
#line 707 "SequencePathModule.cs"
                        bool csharp2cuda_temp_127;
#line 707 "SequencePathModule.cs"
                        if (((probability) >= (0.0)))
                        {
#line 707 "SequencePathModule.cs"
                            csharp2cuda_temp_127 = ((probability) <= (1.0));
                        }
                        else
                        {
#line 707 "SequencePathModule.cs"
                            csharp2cuda_temp_127 = false;
                        }
#line 706 "SequencePathModule.cs"
                        csharp2cuda_temp_126 = (!(csharp2cuda_temp_127));
                    }
                    else
                    {
#line 706 "SequencePathModule.cs"
                        csharp2cuda_temp_126 = true;
                    }
#line 706 "SequencePathModule.cs"
                    bool csharp2cuda_temp_128;
#line 706 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_126))
                    {
#line 708 "SequencePathModule.cs"
                        bool csharp2cuda_temp_129;
#line 708 "SequencePathModule.cs"
                        if (((width) > (1)))
                        {
#line 708 "SequencePathModule.cs"
                            csharp2cuda_temp_129 = ((((void*)(scratch))) == (((void*)(nullptr))));
                        }
                        else
                        {
#line 708 "SequencePathModule.cs"
                            csharp2cuda_temp_129 = false;
                        }
#line 706 "SequencePathModule.cs"
                        csharp2cuda_temp_128 = csharp2cuda_temp_129;
                    }
                    else
                    {
#line 706 "SequencePathModule.cs"
                        csharp2cuda_temp_128 = true;
                    }
                    if (csharp2cuda_temp_128)
#line 709 "SequencePathModule.cs"
                    {
#line 710 "SequencePathModule.cs"
#line 710 "SequencePathModule.cs"
                        int* csharp2cuda_temp_130 = &((output)->valid);
                        (*(csharp2cuda_temp_130) = 0);
                    }
                    else
#line 713 "SequencePathModule.cs"
                    {
#line 714 "SequencePathModule.cs"
#line 714 "SequencePathModule.cs"
                        int csharp2cuda_temp_131 = (first)->count;
                        mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_131, width), 1));
                    }
#line 716 "SequencePathModule.cs"
#line 716 "SequencePathModule.cs"
                    double* csharp2cuda_temp_132 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_132) = probability);
#line 717 "SequencePathModule.cs"
#line 717 "SequencePathModule.cs"
                    int* csharp2cuda_temp_133 = &((output)->boolean_value);
                    (*(csharp2cuda_temp_133) = width);
                }
#line 719 "SequencePathModule.cs"
                __syncthreads();
#line 720 "SequencePathModule.cs"
#line 720 "SequencePathModule.cs"
                int* csharp2cuda_temp_134 = &(width);
#line 720 "SequencePathModule.cs"
                int csharp2cuda_temp_135 = (output)->boolean_value;
                (*(csharp2cuda_temp_134) = csharp2cuda_temp_135);
#line 721 "SequencePathModule.cs"
#line 721 "SequencePathModule.cs"
                double* csharp2cuda_temp_136 = &(probability);
#line 721 "SequencePathModule.cs"
                double csharp2cuda_temp_137 = (output)->scalar_value;
                (*(csharp2cuda_temp_136) = csharp2cuda_temp_137);
#line 722 "SequencePathModule.cs"
#line 722 "SequencePathModule.cs"
                bool csharp2cuda_temp_138 = (output)->valid;
                if ((!(csharp2cuda_temp_138)))
                {
#line 723 "SequencePathModule.cs"
                    break;
                }
#line 724 "SequencePathModule.cs"
                if (((width) == (1)))
#line 725 "SequencePathModule.cs"
                {
#line 726 "SequencePathModule.cs"
                    {
#line 726 "SequencePathModule.cs"
                        int index = thread;
                        while (true)
                        {
#line 726 "SequencePathModule.cs"
                            int csharp2cuda_temp_141 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_141))))
                                break;
#line 727 "SequencePathModule.cs"
#line 727 "SequencePathModule.cs"
                            double* csharp2cuda_temp_142 = &((result)[index]);
#line 727 "SequencePathModule.cs"
                            double csharp2cuda_temp_143 = (a)[index];
                            (*(csharp2cuda_temp_142) = csharp2cuda_temp_143);
#line 726 "SequencePathModule.cs"
                            int* csharp2cuda_temp_139 = &(index);
#line 726 "SequencePathModule.cs"
                            int csharp2cuda_temp_140 = *(csharp2cuda_temp_139);
                            (*(csharp2cuda_temp_139) = csharp2cuda_i32_add(csharp2cuda_temp_140, blockDim.x));
                        }
                    }
#line 728 "SequencePathModule.cs"
                    __syncthreads();
#line 729 "SequencePathModule.cs"
                    if (((thread) == (0)))
#line 730 "SequencePathModule.cs"
                    {
#line 731 "SequencePathModule.cs"
#line 731 "SequencePathModule.cs"
                        double* csharp2cuda_temp_144 = &((output)->scalar_value);
#line 731 "SequencePathModule.cs"
                        int csharp2cuda_temp_145 = (first)->count;
                        (*(csharp2cuda_temp_144) = ((double)(csharp2cuda_temp_145)));
#line 732 "SequencePathModule.cs"
#line 732 "SequencePathModule.cs"
                        int* csharp2cuda_temp_146 = &((output)->boolean_value);
                        (*(csharp2cuda_temp_146) = 0);
                    }
#line 734 "SequencePathModule.cs"
                    break;
                }
#line 736 "SequencePathModule.cs"
#line 736 "SequencePathModule.cs"
                bool csharp2cuda_temp_147;
#line 736 "SequencePathModule.cs"
                if (!(((probability) == (0.0))))
                {
#line 736 "SequencePathModule.cs"
                    csharp2cuda_temp_147 = ((probability) == (1.0));
                }
                else
                {
#line 736 "SequencePathModule.cs"
                    csharp2cuda_temp_147 = true;
                }
                if (csharp2cuda_temp_147)
#line 737 "SequencePathModule.cs"
                {
#line 738 "SequencePathModule.cs"
                    if (((thread) == (0)))
#line 739 "SequencePathModule.cs"
                    {
#line 740 "SequencePathModule.cs"
#line 742 "SequencePathModule.cs"
                        int csharp2cuda_temp_148 = (first)->count;
                        mathblocks_sequence_rolling_extreme(a, csharp2cuda_temp_148, width, result, ((int*)(scratch)), ((probability) == (0.0)));
#line 747 "SequencePathModule.cs"
#line 747 "SequencePathModule.cs"
                        double* csharp2cuda_temp_149 = &((output)->scalar_value);
#line 748 "SequencePathModule.cs"
                        int csharp2cuda_temp_150 = (first)->count;
#line 748 "SequencePathModule.cs"
                        int csharp2cuda_temp_151 = (output)->count;
                        (*(csharp2cuda_temp_149) = ((double)(csharp2cuda_i64_add(csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_150)), ((long long)(3))), ((long long)(csharp2cuda_temp_151))))));
#line 749 "SequencePathModule.cs"
#line 749 "SequencePathModule.cs"
                        int* csharp2cuda_temp_152 = &((output)->boolean_value);
                        (*(csharp2cuda_temp_152) = 0);
                    }
#line 751 "SequencePathModule.cs"
                    __syncthreads();
#line 752 "SequencePathModule.cs"
                    break;
                }
#line 755 "SequencePathModule.cs"
                unsigned char* order_scratch = ((unsigned char*)(scratch));
#line 756 "SequencePathModule.cs"
#line 758 "SequencePathModule.cs"
                int csharp2cuda_temp_153 = (first)->count;
                mathblocks_sequence_prepare_order_ranks(a, csharp2cuda_temp_153, order_scratch, output);
#line 761 "SequencePathModule.cs"
#line 761 "SequencePathModule.cs"
                bool csharp2cuda_temp_154 = (output)->valid;
                if ((!(csharp2cuda_temp_154)))
                {
#line 762 "SequencePathModule.cs"
                    break;
                }
#line 763 "SequencePathModule.cs"
                unsigned long long* first_keys = ((unsigned long long*)(order_scratch));
#line 764 "SequencePathModule.cs"
                int csharp2cuda_temp_155 = (first)->count;
#line 764 "SequencePathModule.cs"
                unsigned long long* second_keys = csharp2cuda_pointer_add(first_keys, csharp2cuda_temp_155);
#line 765 "SequencePathModule.cs"
                int csharp2cuda_temp_156 = (first)->count;
#line 765 "SequencePathModule.cs"
                int* first_indexes = ((int*)(csharp2cuda_pointer_add(second_keys, csharp2cuda_temp_156)));
#line 766 "SequencePathModule.cs"
                int csharp2cuda_temp_157 = (first)->count;
#line 766 "SequencePathModule.cs"
                int* second_indexes = csharp2cuda_pointer_add(first_indexes, csharp2cuda_temp_157);
#line 767 "SequencePathModule.cs"
                int csharp2cuda_temp_158 = (first)->count;
#line 767 "SequencePathModule.cs"
                int* ranks = csharp2cuda_pointer_add(second_indexes, csharp2cuda_temp_158);
#line 768 "SequencePathModule.cs"
                int csharp2cuda_temp_159 = (first)->count;
#line 768 "SequencePathModule.cs"
                int* lower_heap = csharp2cuda_pointer_add(ranks, csharp2cuda_temp_159);
#line 769 "SequencePathModule.cs"
                int* upper_heap = csharp2cuda_pointer_add(lower_heap, width);
#line 770 "SequencePathModule.cs"
                int* positions = csharp2cuda_pointer_add(upper_heap, width);
#line 771 "SequencePathModule.cs"
                int csharp2cuda_temp_160 = (first)->count;
#line 771 "SequencePathModule.cs"
                int* kinds = csharp2cuda_pointer_add(positions, csharp2cuda_temp_160);
#line 772 "SequencePathModule.cs"
                double quantile_position = __dmul_rn(probability, ((double)(csharp2cuda_i32_sub(width, 1))));
#line 773 "SequencePathModule.cs"
                int lower_index = csharp2cuda_f64_to_i32(floor(quantile_position));
#line 774 "SequencePathModule.cs"
                int upper_index = csharp2cuda_f64_to_i32(ceil(quantile_position));
#line 775 "SequencePathModule.cs"
                double weight = __dsub_rn(quantile_position, ((double)(lower_index)));
#line 777 "SequencePathModule.cs"
#line 777 "SequencePathModule.cs"
                int csharp2cuda_temp_161 = (output)->count;
                if (((csharp2cuda_temp_161) == (1)))
#line 778 "SequencePathModule.cs"
                {
#line 779 "SequencePathModule.cs"
                    if (((thread) == (0)))
#line 780 "SequencePathModule.cs"
                    {
#line 781 "SequencePathModule.cs"
                        int csharp2cuda_temp_162 = (first_indexes)[lower_index];
#line 781 "SequencePathModule.cs"
                        double lower_value = (a)[csharp2cuda_temp_162];
#line 782 "SequencePathModule.cs"
                        int csharp2cuda_temp_163 = (first_indexes)[upper_index];
#line 782 "SequencePathModule.cs"
                        double upper_value = (a)[csharp2cuda_temp_163];
#line 783 "SequencePathModule.cs"
#line 783 "SequencePathModule.cs"
                        double* csharp2cuda_temp_164 = &((result)[0]);
                        (*(csharp2cuda_temp_164) = __dadd_rn(__dmul_rn(lower_value, __dsub_rn(1.0, weight)), __dmul_rn(upper_value, weight)));
#line 784 "SequencePathModule.cs"
#line 784 "SequencePathModule.cs"
                        int* csharp2cuda_temp_165 = &((output)->valid);
#line 784 "SequencePathModule.cs"
                        double csharp2cuda_temp_166 = (result)[0];
                        (*(csharp2cuda_temp_165) = isfinite(csharp2cuda_temp_166));
#line 785 "SequencePathModule.cs"
#line 785 "SequencePathModule.cs"
                        double* csharp2cuda_temp_167 = &((output)->scalar_value);
#line 785 "SequencePathModule.cs"
                        int csharp2cuda_temp_168 = (first)->count;
                        (*(csharp2cuda_temp_167) = ((double)(csharp2cuda_i64_add(csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_168)), ((long long)(64))), ((long long)(2))))));
#line 786 "SequencePathModule.cs"
#line 786 "SequencePathModule.cs"
                        int* csharp2cuda_temp_169 = &((output)->boolean_value);
                        (*(csharp2cuda_temp_169) = 64);
                    }
#line 788 "SequencePathModule.cs"
                    __syncthreads();
#line 789 "SequencePathModule.cs"
                    break;
                }
#line 792 "SequencePathModule.cs"
                {
#line 792 "SequencePathModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 792 "SequencePathModule.cs"
                        int csharp2cuda_temp_172 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_172))))
                            break;
#line 793 "SequencePathModule.cs"
                        {
#line 794 "SequencePathModule.cs"
#line 794 "SequencePathModule.cs"
                            int* csharp2cuda_temp_173 = &((positions)[index]);
                            (*(csharp2cuda_temp_173) = csharp2cuda_i32_neg(1));
#line 795 "SequencePathModule.cs"
#line 795 "SequencePathModule.cs"
                            int* csharp2cuda_temp_174 = &((kinds)[index]);
                            (*(csharp2cuda_temp_174) = csharp2cuda_i32_neg(1));
                        }
#line 792 "SequencePathModule.cs"
                        int* csharp2cuda_temp_170 = &(index);
#line 792 "SequencePathModule.cs"
                        int csharp2cuda_temp_171 = *(csharp2cuda_temp_170);
                        (*(csharp2cuda_temp_170) = csharp2cuda_i32_add(csharp2cuda_temp_171, blockDim.x));
                    }
                }
#line 797 "SequencePathModule.cs"
                __syncthreads();
#line 798 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 799 "SequencePathModule.cs"
                {
#line 800 "SequencePathModule.cs"
                    int lower_count = 0;
#line 801 "SequencePathModule.cs"
                    int upper_count = 0;
#line 802 "SequencePathModule.cs"
                    int target_lower_count = csharp2cuda_i32_add(lower_index, 1);
#line 803 "SequencePathModule.cs"
                    {
#line 803 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (width))))
                                break;
#line 804 "SequencePathModule.cs"
                            {
#line 805 "SequencePathModule.cs"
#line 805 "SequencePathModule.cs"
                                bool csharp2cuda_temp_176;
#line 805 "SequencePathModule.cs"
                                if (((lower_count) == (0)))
                                {
#line 805 "SequencePathModule.cs"
                                    csharp2cuda_temp_176 = ((upper_count) == (0));
                                }
                                else
                                {
#line 805 "SequencePathModule.cs"
                                    csharp2cuda_temp_176 = false;
                                }
                                if (csharp2cuda_temp_176)
#line 806 "SequencePathModule.cs"
                                {
#line 807 "SequencePathModule.cs"
#line 809 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_177 = &(lower_count);
                                    mathblocks_sequence_heap_insert(lower_heap, csharp2cuda_temp_177, index, 0, positions, kinds, ranks, true);
                                }
                                else
                                {
#line 817 "SequencePathModule.cs"
                                    if (((lower_count) == (0)))
#line 818 "SequencePathModule.cs"
                                    {
#line 819 "SequencePathModule.cs"
#line 821 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_178 = &(upper_count);
                                        mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_178, index, 1, positions, kinds, ranks, false);
                                    }
                                    else
                                    {
#line 829 "SequencePathModule.cs"
#line 829 "SequencePathModule.cs"
                                        int csharp2cuda_temp_179 = (ranks)[index];
#line 829 "SequencePathModule.cs"
                                        int csharp2cuda_temp_180 = (lower_heap)[0];
#line 829 "SequencePathModule.cs"
                                        int csharp2cuda_temp_181 = (ranks)[csharp2cuda_temp_180];
                                        if (((csharp2cuda_temp_179) <= (csharp2cuda_temp_181)))
#line 830 "SequencePathModule.cs"
                                        {
#line 831 "SequencePathModule.cs"
#line 833 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_182 = &(lower_count);
                                            mathblocks_sequence_heap_insert(lower_heap, csharp2cuda_temp_182, index, 0, positions, kinds, ranks, true);
                                        }
                                        else
#line 842 "SequencePathModule.cs"
                                        {
#line 843 "SequencePathModule.cs"
#line 845 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_183 = &(upper_count);
                                            mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_183, index, 1, positions, kinds, ranks, false);
                                        }
                                    }
                                }
#line 853 "SequencePathModule.cs"
                                int csharp2cuda_temp_184;
#line 853 "SequencePathModule.cs"
                                if (((target_lower_count) < (csharp2cuda_i32_add(index, 1))))
                                {
#line 853 "SequencePathModule.cs"
                                    csharp2cuda_temp_184 = target_lower_count;
                                }
                                else
                                {
#line 853 "SequencePathModule.cs"
                                    csharp2cuda_temp_184 = csharp2cuda_i32_add(index, 1);
                                }
#line 853 "SequencePathModule.cs"
                                int active_target = csharp2cuda_temp_184;
#line 856 "SequencePathModule.cs"
#line 858 "SequencePathModule.cs"
                                int* csharp2cuda_temp_185 = &(lower_count);
#line 860 "SequencePathModule.cs"
                                int* csharp2cuda_temp_186 = &(upper_count);
                                mathblocks_sequence_rebalance_heaps(lower_heap, csharp2cuda_temp_185, upper_heap, csharp2cuda_temp_186, active_target, positions, kinds, ranks);
                            }
#line 803 "SequencePathModule.cs"
                            int* csharp2cuda_temp_175 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_175));
                        }
                    }
#line 866 "SequencePathModule.cs"
                    {
#line 866 "SequencePathModule.cs"
                        int start = 0;
                        while (true)
                        {
#line 866 "SequencePathModule.cs"
                            int csharp2cuda_temp_188 = (output)->count;
                            if (!(((start) < (csharp2cuda_temp_188))))
                                break;
#line 867 "SequencePathModule.cs"
                            {
#line 868 "SequencePathModule.cs"
                                int csharp2cuda_temp_189 = (lower_heap)[0];
#line 868 "SequencePathModule.cs"
                                double lower_value = (a)[csharp2cuda_temp_189];
#line 869 "SequencePathModule.cs"
                                double csharp2cuda_temp_190;
#line 869 "SequencePathModule.cs"
                                if (((lower_index) == (upper_index)))
                                {
#line 869 "SequencePathModule.cs"
                                    csharp2cuda_temp_190 = lower_value;
                                }
                                else
                                {
#line 871 "SequencePathModule.cs"
                                    int csharp2cuda_temp_191 = (upper_heap)[0];
#line 869 "SequencePathModule.cs"
                                    csharp2cuda_temp_190 = (a)[csharp2cuda_temp_191];
                                }
#line 869 "SequencePathModule.cs"
                                double upper_value = csharp2cuda_temp_190;
#line 872 "SequencePathModule.cs"
#line 872 "SequencePathModule.cs"
                                double* csharp2cuda_temp_192 = &((result)[start]);
                                (*(csharp2cuda_temp_192) = __dadd_rn(__dmul_rn(lower_value, __dsub_rn(1.0, weight)), __dmul_rn(upper_value, weight)));
#line 873 "SequencePathModule.cs"
#line 873 "SequencePathModule.cs"
                                double csharp2cuda_temp_193 = (result)[start];
                                if ((!(isfinite(csharp2cuda_temp_193))))
#line 874 "SequencePathModule.cs"
                                {
#line 875 "SequencePathModule.cs"
#line 875 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_194 = &((output)->valid);
                                    (*(csharp2cuda_temp_194) = 0);
#line 876 "SequencePathModule.cs"
                                    break;
                                }
#line 878 "SequencePathModule.cs"
#line 878 "SequencePathModule.cs"
                                int csharp2cuda_temp_195 = (output)->count;
                                if (((csharp2cuda_i32_add(start, 1)) == (csharp2cuda_temp_195)))
                                {
#line 879 "SequencePathModule.cs"
                                    break;
                                }
#line 880 "SequencePathModule.cs"
                                int outgoing = start;
#line 881 "SequencePathModule.cs"
                                int incoming = csharp2cuda_i32_add(start, width);
#line 882 "SequencePathModule.cs"
#line 882 "SequencePathModule.cs"
                                int csharp2cuda_temp_196 = (kinds)[outgoing];
                                if (((csharp2cuda_temp_196) == (0)))
#line 883 "SequencePathModule.cs"
                                {
#line 884 "SequencePathModule.cs"
#line 886 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_197 = &(lower_count);
                                    mathblocks_sequence_heap_remove(lower_heap, csharp2cuda_temp_197, outgoing, positions, kinds, ranks, true);
                                }
                                else
#line 894 "SequencePathModule.cs"
                                {
#line 895 "SequencePathModule.cs"
#line 897 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_198 = &(upper_count);
                                    mathblocks_sequence_heap_remove(upper_heap, csharp2cuda_temp_198, outgoing, positions, kinds, ranks, false);
                                }
#line 904 "SequencePathModule.cs"
                                if (((lower_count) == (0)))
#line 905 "SequencePathModule.cs"
                                {
#line 906 "SequencePathModule.cs"
#line 908 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_199 = &(upper_count);
                                    mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_199, incoming, 1, positions, kinds, ranks, false);
                                }
                                else
                                {
#line 916 "SequencePathModule.cs"
#line 916 "SequencePathModule.cs"
                                    int csharp2cuda_temp_200 = (ranks)[incoming];
#line 916 "SequencePathModule.cs"
                                    int csharp2cuda_temp_201 = (lower_heap)[0];
#line 916 "SequencePathModule.cs"
                                    int csharp2cuda_temp_202 = (ranks)[csharp2cuda_temp_201];
                                    if (((csharp2cuda_temp_200) <= (csharp2cuda_temp_202)))
#line 917 "SequencePathModule.cs"
                                    {
#line 918 "SequencePathModule.cs"
#line 920 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_203 = &(lower_count);
                                        mathblocks_sequence_heap_insert(lower_heap, csharp2cuda_temp_203, incoming, 0, positions, kinds, ranks, true);
                                    }
                                    else
#line 929 "SequencePathModule.cs"
                                    {
#line 930 "SequencePathModule.cs"
#line 932 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_204 = &(upper_count);
                                        mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_204, incoming, 1, positions, kinds, ranks, false);
                                    }
                                }
#line 940 "SequencePathModule.cs"
#line 942 "SequencePathModule.cs"
                                int* csharp2cuda_temp_205 = &(lower_count);
#line 944 "SequencePathModule.cs"
                                int* csharp2cuda_temp_206 = &(upper_count);
                                mathblocks_sequence_rebalance_heaps(lower_heap, csharp2cuda_temp_205, upper_heap, csharp2cuda_temp_206, target_lower_count, positions, kinds, ranks);
                            }
#line 866 "SequencePathModule.cs"
                            int* csharp2cuda_temp_187 = &(start);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_187));
                        }
                    }
#line 950 "SequencePathModule.cs"
                    int heap_height = 1;
#line 951 "SequencePathModule.cs"
                    {
#line 951 "SequencePathModule.cs"
                        int value = width;
                        while (true)
                        {
                            if (!(((value) > (1))))
                                break;
#line 952 "SequencePathModule.cs"
#line 952 "SequencePathModule.cs"
                            int* csharp2cuda_temp_208 = &(heap_height);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_208));
#line 951 "SequencePathModule.cs"
                            int* csharp2cuda_temp_207 = &(value);
                            (*(csharp2cuda_temp_207) = csharp2cuda_i32_shr(csharp2cuda_i32_add(value, 1), 1));
                        }
                    }
#line 954 "SequencePathModule.cs"
                    int csharp2cuda_temp_209 = (first)->count;
#line 953 "SequencePathModule.cs"
                    long long heap_bound = csharp2cuda_i64_mul(csharp2cuda_i64_add(((long long)(width)), csharp2cuda_i64_mul(2LL, ((long long)(csharp2cuda_i32_sub(csharp2cuda_temp_209, width))))), ((long long)(heap_height)));
#line 955 "SequencePathModule.cs"
                    int csharp2cuda_temp_210 = (output)->count;
#line 955 "SequencePathModule.cs"
                    long long selection_bound = csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_210)), ((long long)(2)));
#line 956 "SequencePathModule.cs"
#line 956 "SequencePathModule.cs"
                    double* csharp2cuda_temp_211 = &((output)->scalar_value);
#line 957 "SequencePathModule.cs"
                    int csharp2cuda_temp_212 = (first)->count;
                    (*(csharp2cuda_temp_211) = ((double)(csharp2cuda_i64_add(csharp2cuda_i64_add(csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_212)), ((long long)(64))), heap_bound), selection_bound))));
#line 958 "SequencePathModule.cs"
#line 958 "SequencePathModule.cs"
                    int* csharp2cuda_temp_213 = &((output)->boolean_value);
                    (*(csharp2cuda_temp_213) = 64);
                }
#line 960 "SequencePathModule.cs"
                __syncthreads();
#line 961 "SequencePathModule.cs"
                break;
            }
#line 963 "SequencePathModule.cs"
        case 8:
        case 10:
#line 965 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 966 "SequencePathModule.cs"
            {
#line 967 "SequencePathModule.cs"
                int width = 0;
#line 968 "SequencePathModule.cs"
#line 968 "SequencePathModule.cs"
                double csharp2cuda_temp_214 = (second)->scalar_value;
#line 968 "SequencePathModule.cs"
                int* csharp2cuda_temp_215 = &(width);
#line 968 "SequencePathModule.cs"
                bool csharp2cuda_temp_216 = mathblocks_sequence_positive_integer(csharp2cuda_temp_214, csharp2cuda_temp_215);
#line 968 "SequencePathModule.cs"
                bool csharp2cuda_temp_217;
#line 968 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_216))))
                {
#line 968 "SequencePathModule.cs"
                    int csharp2cuda_temp_218 = (first)->count;
#line 968 "SequencePathModule.cs"
                    csharp2cuda_temp_217 = ((width) > (csharp2cuda_temp_218));
                }
                else
                {
#line 968 "SequencePathModule.cs"
                    csharp2cuda_temp_217 = true;
                }
                if (csharp2cuda_temp_217)
#line 969 "SequencePathModule.cs"
                {
#line 970 "SequencePathModule.cs"
#line 970 "SequencePathModule.cs"
                    int* csharp2cuda_temp_219 = &((output)->valid);
                    (*(csharp2cuda_temp_219) = 0);
                }
                else
#line 973 "SequencePathModule.cs"
                {
#line 974 "SequencePathModule.cs"
#line 974 "SequencePathModule.cs"
                    int csharp2cuda_temp_220 = (first)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_220, width), 1));
#line 975 "SequencePathModule.cs"
                    {
#line 975 "SequencePathModule.cs"
                        int start = 0;
                        while (true)
                        {
#line 975 "SequencePathModule.cs"
                            int csharp2cuda_temp_222 = (output)->count;
                            if (!(((start) < (csharp2cuda_temp_222))))
                                break;
#line 976 "SequencePathModule.cs"
                            {
#line 977 "SequencePathModule.cs"
                                double mean = 0.0;
#line 978 "SequencePathModule.cs"
                                {
#line 978 "SequencePathModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
                                        if (!(((index) < (width))))
                                            break;
#line 979 "SequencePathModule.cs"
#line 979 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_224 = &(mean);
#line 979 "SequencePathModule.cs"
                                        double csharp2cuda_temp_225 = *(csharp2cuda_temp_224);
#line 979 "SequencePathModule.cs"
                                        double csharp2cuda_temp_226 = (a)[csharp2cuda_i32_add(start, index)];
                                        (*(csharp2cuda_temp_224) = __dadd_rn(csharp2cuda_temp_225, csharp2cuda_temp_226));
#line 978 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_223 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_223));
                                    }
                                }
#line 980 "SequencePathModule.cs"
#line 980 "SequencePathModule.cs"
                                double* csharp2cuda_temp_227 = &(mean);
#line 980 "SequencePathModule.cs"
                                double csharp2cuda_temp_228 = *(csharp2cuda_temp_227);
                                (*(csharp2cuda_temp_227) = __ddiv_rn(csharp2cuda_temp_228, ((double)(width))));
#line 981 "SequencePathModule.cs"
                                double sum_squares = 0.0;
#line 982 "SequencePathModule.cs"
                                {
#line 982 "SequencePathModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
                                        if (!(((index) < (width))))
                                            break;
#line 983 "SequencePathModule.cs"
                                        {
#line 984 "SequencePathModule.cs"
                                            double csharp2cuda_temp_230 = (a)[csharp2cuda_i32_add(start, index)];
#line 984 "SequencePathModule.cs"
                                            double difference = __dsub_rn(csharp2cuda_temp_230, mean);
#line 985 "SequencePathModule.cs"
#line 985 "SequencePathModule.cs"
                                            double* csharp2cuda_temp_231 = &(sum_squares);
#line 985 "SequencePathModule.cs"
                                            double csharp2cuda_temp_232 = *(csharp2cuda_temp_231);
                                            (*(csharp2cuda_temp_231) = __dadd_rn(csharp2cuda_temp_232, __dmul_rn(difference, difference)));
                                        }
#line 982 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_229 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_229));
                                    }
                                }
#line 987 "SequencePathModule.cs"
                                double csharp2cuda_temp_233 = __ddiv_rn(sum_squares, ((double)(width)));
#line 987 "SequencePathModule.cs"
                                double deviation = mathblocks_square_root(csharp2cuda_temp_233);
#line 988 "SequencePathModule.cs"
#line 988 "SequencePathModule.cs"
                                double* csharp2cuda_temp_234 = &((result)[start]);
#line 988 "SequencePathModule.cs"
                                double csharp2cuda_temp_235;
#line 988 "SequencePathModule.cs"
                                if (((opcode) == (8)))
                                {
#line 988 "SequencePathModule.cs"
                                    csharp2cuda_temp_235 = deviation;
                                }
                                else
                                {
#line 988 "SequencePathModule.cs"
                                    csharp2cuda_temp_235 = __dmul_rn(deviation, deviation);
                                }
                                (*(csharp2cuda_temp_234) = csharp2cuda_temp_235);
#line 989 "SequencePathModule.cs"
#line 989 "SequencePathModule.cs"
                                double csharp2cuda_temp_236 = (result)[start];
                                if ((!(isfinite(csharp2cuda_temp_236))))
                                {
#line 990 "SequencePathModule.cs"
#line 990 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_237 = &((output)->valid);
                                    (*(csharp2cuda_temp_237) = 0);
                                }
                            }
#line 975 "SequencePathModule.cs"
                            int* csharp2cuda_temp_221 = &(start);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_221));
                        }
                    }
                }
            }
#line 994 "SequencePathModule.cs"
            break;
#line 995 "SequencePathModule.cs"
        case 11:
#line 996 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 997 "SequencePathModule.cs"
            {
#line 998 "SequencePathModule.cs"
#line 998 "SequencePathModule.cs"
                int csharp2cuda_temp_238 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_238);
#line 999 "SequencePathModule.cs"
#line 999 "SequencePathModule.cs"
                int csharp2cuda_temp_239 = (first)->count;
#line 999 "SequencePathModule.cs"
                bool csharp2cuda_temp_240;
#line 999 "SequencePathModule.cs"
                if (!((!(mathblocks_sequence_is_power_of_two(csharp2cuda_temp_239)))))
                {
#line 999 "SequencePathModule.cs"
                    csharp2cuda_temp_240 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 999 "SequencePathModule.cs"
                    csharp2cuda_temp_240 = true;
                }
                if (csharp2cuda_temp_240)
#line 1000 "SequencePathModule.cs"
                {
#line 1001 "SequencePathModule.cs"
#line 1001 "SequencePathModule.cs"
                    int* csharp2cuda_temp_241 = &((output)->valid);
                    (*(csharp2cuda_temp_241) = 0);
                }
                else
#line 1004 "SequencePathModule.cs"
                {
#line 1005 "SequencePathModule.cs"
                    {
#line 1005 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1005 "SequencePathModule.cs"
                            int csharp2cuda_temp_243 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_243))))
                                break;
#line 1006 "SequencePathModule.cs"
#line 1006 "SequencePathModule.cs"
                            double* csharp2cuda_temp_244 = &((result)[index]);
#line 1006 "SequencePathModule.cs"
                            double csharp2cuda_temp_245 = (a)[index];
                            (*(csharp2cuda_temp_244) = csharp2cuda_temp_245);
#line 1005 "SequencePathModule.cs"
                            int* csharp2cuda_temp_242 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_242));
                        }
                    }
#line 1007 "SequencePathModule.cs"
                    int length = (first)->count;
#line 1008 "SequencePathModule.cs"
                    double scale = __ddiv_rn(1.0, mathblocks_square_root(2.0));
#line 1009 "SequencePathModule.cs"
                    while (true)
                    {
                        if (!(((length) > (1))))
                            break;
#line 1010 "SequencePathModule.cs"
                        {
#line 1011 "SequencePathModule.cs"
                            int half = csharp2cuda_i32_div(length, 2);
#line 1012 "SequencePathModule.cs"
                            {
#line 1012 "SequencePathModule.cs"
                                int index = 0;
                                while (true)
                                {
                                    if (!(((index) < (half))))
                                        break;
#line 1013 "SequencePathModule.cs"
                                    {
#line 1014 "SequencePathModule.cs"
#line 1014 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_247 = &((scratch)[index]);
#line 1014 "SequencePathModule.cs"
                                        double csharp2cuda_temp_248 = (result)[csharp2cuda_i32_mul(2, index)];
#line 1014 "SequencePathModule.cs"
                                        double csharp2cuda_temp_249 = (result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                        (*(csharp2cuda_temp_247) = __dmul_rn(__dadd_rn(csharp2cuda_temp_248, csharp2cuda_temp_249), scale));
#line 1015 "SequencePathModule.cs"
#line 1015 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_250 = &((scratch)[csharp2cuda_i32_add(half, index)]);
#line 1015 "SequencePathModule.cs"
                                        double csharp2cuda_temp_251 = (result)[csharp2cuda_i32_mul(2, index)];
#line 1015 "SequencePathModule.cs"
                                        double csharp2cuda_temp_252 = (result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                        (*(csharp2cuda_temp_250) = __dmul_rn(__dsub_rn(csharp2cuda_temp_251, csharp2cuda_temp_252), scale));
                                    }
#line 1012 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_246 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_246));
                                }
                            }
#line 1017 "SequencePathModule.cs"
                            {
#line 1017 "SequencePathModule.cs"
                                int index = 0;
                                while (true)
                                {
                                    if (!(((index) < (length))))
                                        break;
#line 1018 "SequencePathModule.cs"
#line 1018 "SequencePathModule.cs"
                                    double* csharp2cuda_temp_254 = &((result)[index]);
#line 1018 "SequencePathModule.cs"
                                    double csharp2cuda_temp_255 = (scratch)[index];
                                    (*(csharp2cuda_temp_254) = csharp2cuda_temp_255);
#line 1017 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_253 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_253));
                                }
                            }
#line 1019 "SequencePathModule.cs"
#line 1019 "SequencePathModule.cs"
                            int* csharp2cuda_temp_256 = &(length);
                            (*(csharp2cuda_temp_256) = half);
                        }
                    }
                }
            }
#line 1023 "SequencePathModule.cs"
            break;
#line 1024 "SequencePathModule.cs"
        case 12:
#line 1025 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1026 "SequencePathModule.cs"
            {
#line 1027 "SequencePathModule.cs"
#line 1027 "SequencePathModule.cs"
                int csharp2cuda_temp_257 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_257);
#line 1028 "SequencePathModule.cs"
#line 1028 "SequencePathModule.cs"
                int csharp2cuda_temp_258 = (first)->count;
                if ((!(mathblocks_sequence_is_power_of_two(csharp2cuda_temp_258))))
#line 1029 "SequencePathModule.cs"
                {
#line 1030 "SequencePathModule.cs"
#line 1030 "SequencePathModule.cs"
                    int* csharp2cuda_temp_259 = &((output)->valid);
                    (*(csharp2cuda_temp_259) = 0);
                }
                else
#line 1033 "SequencePathModule.cs"
                {
#line 1034 "SequencePathModule.cs"
                    {
#line 1034 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1034 "SequencePathModule.cs"
                            int csharp2cuda_temp_261 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_261))))
                                break;
#line 1035 "SequencePathModule.cs"
#line 1035 "SequencePathModule.cs"
                            double* csharp2cuda_temp_262 = &((result)[index]);
#line 1035 "SequencePathModule.cs"
                            double csharp2cuda_temp_263 = (a)[index];
                            (*(csharp2cuda_temp_262) = csharp2cuda_temp_263);
#line 1034 "SequencePathModule.cs"
                            int* csharp2cuda_temp_260 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_260));
                        }
                    }
#line 1036 "SequencePathModule.cs"
                    {
#line 1036 "SequencePathModule.cs"
                        int width = 1;
                        while (true)
                        {
#line 1036 "SequencePathModule.cs"
                            int csharp2cuda_temp_266 = (first)->count;
                            if (!(((width) < (csharp2cuda_temp_266))))
                                break;
#line 1037 "SequencePathModule.cs"
                            {
#line 1038 "SequencePathModule.cs"
                                {
#line 1038 "SequencePathModule.cs"
                                    int start = 0;
                                    while (true)
                                    {
#line 1038 "SequencePathModule.cs"
                                        int csharp2cuda_temp_269 = (first)->count;
                                        if (!(((start) < (csharp2cuda_temp_269))))
                                            break;
#line 1039 "SequencePathModule.cs"
                                        {
#line 1040 "SequencePathModule.cs"
                                            {
#line 1040 "SequencePathModule.cs"
                                                int offset = 0;
                                                while (true)
                                                {
                                                    if (!(((offset) < (width))))
                                                        break;
#line 1041 "SequencePathModule.cs"
                                                    {
#line 1042 "SequencePathModule.cs"
                                                        double left = (result)[csharp2cuda_i32_add(start, offset)];
#line 1043 "SequencePathModule.cs"
                                                        double right = (result)[csharp2cuda_i32_add(csharp2cuda_i32_add(start, width), offset)];
#line 1044 "SequencePathModule.cs"
#line 1044 "SequencePathModule.cs"
                                                        double* csharp2cuda_temp_271 = &((result)[csharp2cuda_i32_add(start, offset)]);
                                                        (*(csharp2cuda_temp_271) = __dadd_rn(left, right));
#line 1045 "SequencePathModule.cs"
#line 1045 "SequencePathModule.cs"
                                                        double* csharp2cuda_temp_272 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_add(start, width), offset)]);
                                                        (*(csharp2cuda_temp_272) = __dsub_rn(left, right));
                                                    }
#line 1040 "SequencePathModule.cs"
                                                    int* csharp2cuda_temp_270 = &(offset);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_270));
                                                }
                                            }
                                        }
#line 1038 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_267 = &(start);
#line 1038 "SequencePathModule.cs"
                                        int csharp2cuda_temp_268 = *(csharp2cuda_temp_267);
                                        (*(csharp2cuda_temp_267) = csharp2cuda_i32_add(csharp2cuda_temp_268, csharp2cuda_i32_mul(2, width)));
                                    }
                                }
                            }
#line 1036 "SequencePathModule.cs"
                            int* csharp2cuda_temp_264 = &(width);
#line 1036 "SequencePathModule.cs"
                            int csharp2cuda_temp_265 = *(csharp2cuda_temp_264);
                            (*(csharp2cuda_temp_264) = csharp2cuda_i32_mul(csharp2cuda_temp_265, 2));
                        }
                    }
#line 1049 "SequencePathModule.cs"
                    int csharp2cuda_temp_273 = (first)->count;
#line 1049 "SequencePathModule.cs"
                    double scale = __ddiv_rn(1.0, mathblocks_square_root(((double)(csharp2cuda_temp_273))));
#line 1050 "SequencePathModule.cs"
                    {
#line 1050 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1050 "SequencePathModule.cs"
                            int csharp2cuda_temp_275 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_275))))
                                break;
#line 1051 "SequencePathModule.cs"
#line 1051 "SequencePathModule.cs"
                            double* csharp2cuda_temp_276 = &((result)[index]);
#line 1051 "SequencePathModule.cs"
                            double csharp2cuda_temp_277 = *(csharp2cuda_temp_276);
                            (*(csharp2cuda_temp_276) = __dmul_rn(csharp2cuda_temp_277, scale));
#line 1050 "SequencePathModule.cs"
                            int* csharp2cuda_temp_274 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_274));
                        }
                    }
                }
            }
#line 1054 "SequencePathModule.cs"
            break;
#line 1055 "SequencePathModule.cs"
        case 13:
#line 1056 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1057 "SequencePathModule.cs"
            {
#line 1058 "SequencePathModule.cs"
#line 1058 "SequencePathModule.cs"
                int csharp2cuda_temp_278 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_278);
#line 1059 "SequencePathModule.cs"
                double sum = 0.0;
#line 1060 "SequencePathModule.cs"
                {
#line 1060 "SequencePathModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 1060 "SequencePathModule.cs"
                        int csharp2cuda_temp_280 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_280))))
                            break;
#line 1061 "SequencePathModule.cs"
                        {
#line 1062 "SequencePathModule.cs"
#line 1062 "SequencePathModule.cs"
                            double* csharp2cuda_temp_281 = &(sum);
#line 1062 "SequencePathModule.cs"
                            double csharp2cuda_temp_282 = *(csharp2cuda_temp_281);
#line 1062 "SequencePathModule.cs"
                            double csharp2cuda_temp_283 = (a)[index];
#line 1062 "SequencePathModule.cs"
                            double csharp2cuda_temp_284 = (second)->scalar_value;
                            (*(csharp2cuda_temp_281) = __dadd_rn(csharp2cuda_temp_282, __dsub_rn(csharp2cuda_temp_283, csharp2cuda_temp_284)));
#line 1063 "SequencePathModule.cs"
#line 1063 "SequencePathModule.cs"
                            double* csharp2cuda_temp_285 = &((result)[index]);
                            (*(csharp2cuda_temp_285) = sum);
#line 1064 "SequencePathModule.cs"
                            if ((!(isfinite(sum))))
                            {
#line 1065 "SequencePathModule.cs"
#line 1065 "SequencePathModule.cs"
                                int* csharp2cuda_temp_286 = &((output)->valid);
                                (*(csharp2cuda_temp_286) = 0);
                            }
                        }
#line 1060 "SequencePathModule.cs"
                        int* csharp2cuda_temp_279 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_279));
                    }
                }
            }
#line 1068 "SequencePathModule.cs"
            break;
#line 1069 "SequencePathModule.cs"
        case 14:
#line 1070 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1071 "SequencePathModule.cs"
            {
#line 1072 "SequencePathModule.cs"
#line 1072 "SequencePathModule.cs"
                int csharp2cuda_temp_287 = (first)->count;
#line 1072 "SequencePathModule.cs"
                bool csharp2cuda_temp_288;
#line 1072 "SequencePathModule.cs"
                if (!(((csharp2cuda_temp_287) <= (0))))
                {
#line 1072 "SequencePathModule.cs"
                    int csharp2cuda_temp_289 = (second)->count;
#line 1072 "SequencePathModule.cs"
                    csharp2cuda_temp_288 = ((csharp2cuda_temp_289) <= (0));
                }
                else
                {
#line 1072 "SequencePathModule.cs"
                    csharp2cuda_temp_288 = true;
                }
#line 1072 "SequencePathModule.cs"
                bool csharp2cuda_temp_290;
#line 1072 "SequencePathModule.cs"
                if (!(csharp2cuda_temp_288))
                {
#line 1072 "SequencePathModule.cs"
                    csharp2cuda_temp_290 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 1072 "SequencePathModule.cs"
                    csharp2cuda_temp_290 = true;
                }
                if (csharp2cuda_temp_290)
#line 1073 "SequencePathModule.cs"
                {
#line 1074 "SequencePathModule.cs"
#line 1074 "SequencePathModule.cs"
                    int* csharp2cuda_temp_291 = &((output)->valid);
                    (*(csharp2cuda_temp_291) = 0);
                }
                else
#line 1077 "SequencePathModule.cs"
                {
#line 1078 "SequencePathModule.cs"
                    int csharp2cuda_temp_292 = (second)->count;
#line 1078 "SequencePathModule.cs"
                    int width = csharp2cuda_i32_add(csharp2cuda_temp_292, 1);
#line 1079 "SequencePathModule.cs"
                    double* previous = scratch;
#line 1080 "SequencePathModule.cs"
                    double* current = csharp2cuda_pointer_add(scratch, width);
#line 1081 "SequencePathModule.cs"
                    {
#line 1081 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (width))))
                                break;
#line 1082 "SequencePathModule.cs"
#line 1082 "SequencePathModule.cs"
                            double* csharp2cuda_temp_294 = &((previous)[index]);
                            (*(csharp2cuda_temp_294) = mathblocks_positive_infinity());
#line 1081 "SequencePathModule.cs"
                            int* csharp2cuda_temp_293 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_293));
                        }
                    }
#line 1083 "SequencePathModule.cs"
#line 1083 "SequencePathModule.cs"
                    double* csharp2cuda_temp_295 = &((previous)[0]);
                    (*(csharp2cuda_temp_295) = 0.0);
#line 1084 "SequencePathModule.cs"
                    {
#line 1084 "SequencePathModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 1084 "SequencePathModule.cs"
                            int csharp2cuda_temp_297 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_297))))
                                break;
#line 1085 "SequencePathModule.cs"
                            {
#line 1086 "SequencePathModule.cs"
#line 1086 "SequencePathModule.cs"
                                double* csharp2cuda_temp_298 = &((current)[0]);
                                (*(csharp2cuda_temp_298) = mathblocks_positive_infinity());
#line 1087 "SequencePathModule.cs"
                                {
#line 1087 "SequencePathModule.cs"
                                    int right = 0;
                                    while (true)
                                    {
#line 1087 "SequencePathModule.cs"
                                        int csharp2cuda_temp_300 = (second)->count;
                                        if (!(((right) < (csharp2cuda_temp_300))))
                                            break;
#line 1088 "SequencePathModule.cs"
                                        {
#line 1089 "SequencePathModule.cs"
                                            double csharp2cuda_temp_301 = (previous)[csharp2cuda_i32_add(right, 1)];
#line 1089 "SequencePathModule.cs"
                                            double csharp2cuda_temp_302 = (current)[right];
#line 1089 "SequencePathModule.cs"
                                            double csharp2cuda_temp_303;
#line 1089 "SequencePathModule.cs"
                                            if (((csharp2cuda_temp_301) < (csharp2cuda_temp_302)))
                                            {
#line 1089 "SequencePathModule.cs"
                                                csharp2cuda_temp_303 = (previous)[csharp2cuda_i32_add(right, 1)];
                                            }
                                            else
                                            {
#line 1089 "SequencePathModule.cs"
                                                csharp2cuda_temp_303 = (current)[right];
                                            }
#line 1089 "SequencePathModule.cs"
                                            double minimum = csharp2cuda_temp_303;
#line 1092 "SequencePathModule.cs"
#line 1092 "SequencePathModule.cs"
                                            double* csharp2cuda_temp_304 = &(minimum);
#line 1092 "SequencePathModule.cs"
                                            double csharp2cuda_temp_305 = (previous)[right];
#line 1092 "SequencePathModule.cs"
                                            double csharp2cuda_temp_306;
#line 1092 "SequencePathModule.cs"
                                            if (((minimum) < (csharp2cuda_temp_305)))
                                            {
#line 1092 "SequencePathModule.cs"
                                                csharp2cuda_temp_306 = minimum;
                                            }
                                            else
                                            {
#line 1092 "SequencePathModule.cs"
                                                csharp2cuda_temp_306 = (previous)[right];
                                            }
                                            (*(csharp2cuda_temp_304) = csharp2cuda_temp_306);
#line 1093 "SequencePathModule.cs"
#line 1093 "SequencePathModule.cs"
                                            double* csharp2cuda_temp_307 = &((current)[csharp2cuda_i32_add(right, 1)]);
#line 1093 "SequencePathModule.cs"
                                            double csharp2cuda_temp_308 = (a)[left];
#line 1093 "SequencePathModule.cs"
                                            double csharp2cuda_temp_309 = (b)[right];
                                            (*(csharp2cuda_temp_307) = __dadd_rn(fabs(__dsub_rn(csharp2cuda_temp_308, csharp2cuda_temp_309)), minimum));
                                        }
#line 1087 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_299 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_299));
                                    }
                                }
#line 1095 "SequencePathModule.cs"
                                double* swap = previous;
#line 1096 "SequencePathModule.cs"
#line 1096 "SequencePathModule.cs"
                                double** csharp2cuda_temp_310 = &(previous);
                                (*(csharp2cuda_temp_310) = current);
#line 1097 "SequencePathModule.cs"
#line 1097 "SequencePathModule.cs"
                                double** csharp2cuda_temp_311 = &(current);
                                (*(csharp2cuda_temp_311) = swap);
                            }
#line 1084 "SequencePathModule.cs"
                            int* csharp2cuda_temp_296 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_296));
                        }
                    }
#line 1099 "SequencePathModule.cs"
#line 1099 "SequencePathModule.cs"
                    double* csharp2cuda_temp_312 = &((output)->scalar_value);
#line 1099 "SequencePathModule.cs"
                    int csharp2cuda_temp_313 = (second)->count;
#line 1099 "SequencePathModule.cs"
                    double csharp2cuda_temp_314 = (previous)[csharp2cuda_temp_313];
                    (*(csharp2cuda_temp_312) = csharp2cuda_temp_314);
#line 1100 "SequencePathModule.cs"
#line 1100 "SequencePathModule.cs"
                    double csharp2cuda_temp_315 = (output)->scalar_value;
                    if ((!(isfinite(csharp2cuda_temp_315))))
                    {
#line 1101 "SequencePathModule.cs"
#line 1101 "SequencePathModule.cs"
                        int* csharp2cuda_temp_316 = &((output)->valid);
                        (*(csharp2cuda_temp_316) = 0);
                    }
                }
            }
#line 1104 "SequencePathModule.cs"
            break;
#line 1105 "SequencePathModule.cs"
        case 15:
#line 1106 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1107 "SequencePathModule.cs"
            {
#line 1108 "SequencePathModule.cs"
#line 1108 "SequencePathModule.cs"
                double* csharp2cuda_temp_317 = &((output)->scalar_value);
#line 1110 "SequencePathModule.cs"
                int csharp2cuda_temp_318 = (first)->count;
#line 1111 "SequencePathModule.cs"
                double csharp2cuda_temp_319 = (second)->scalar_value;
#line 1112 "SequencePathModule.cs"
                int csharp2cuda_temp_320 = (third)->boolean_value;
#line 1108 "SequencePathModule.cs"
                double csharp2cuda_temp_321 = mathblocks_sequence_first_passage_value(a, csharp2cuda_temp_318, csharp2cuda_temp_319, ((csharp2cuda_temp_320) != (0)));
                (*(csharp2cuda_temp_317) = csharp2cuda_temp_321);
            }
#line 1114 "SequencePathModule.cs"
            break;
#line 1115 "SequencePathModule.cs"
        case 16:
#line 1116 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1117 "SequencePathModule.cs"
            {
#line 1118 "SequencePathModule.cs"
                double lower = (second)->scalar_value;
#line 1119 "SequencePathModule.cs"
                double upper = (third)->scalar_value;
#line 1120 "SequencePathModule.cs"
#line 1120 "SequencePathModule.cs"
                int csharp2cuda_temp_322 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_322);
#line 1121 "SequencePathModule.cs"
                if ((!(((lower) < (upper)))))
#line 1122 "SequencePathModule.cs"
                {
#line 1123 "SequencePathModule.cs"
#line 1123 "SequencePathModule.cs"
                    int* csharp2cuda_temp_323 = &((output)->valid);
                    (*(csharp2cuda_temp_323) = 0);
                }
                else
#line 1126 "SequencePathModule.cs"
                {
#line 1127 "SequencePathModule.cs"
                    double state = 0.0;
#line 1128 "SequencePathModule.cs"
                    {
#line 1128 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1128 "SequencePathModule.cs"
                            int csharp2cuda_temp_325 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_325))))
                                break;
#line 1129 "SequencePathModule.cs"
                            {
#line 1130 "SequencePathModule.cs"
#line 1130 "SequencePathModule.cs"
                                double csharp2cuda_temp_326 = (a)[index];
                                if (((csharp2cuda_temp_326) >= (upper)))
                                {
#line 1131 "SequencePathModule.cs"
#line 1131 "SequencePathModule.cs"
                                    double* csharp2cuda_temp_327 = &(state);
                                    (*(csharp2cuda_temp_327) = 1.0);
                                }
                                else
                                {
#line 1132 "SequencePathModule.cs"
#line 1132 "SequencePathModule.cs"
                                    double csharp2cuda_temp_328 = (a)[index];
                                    if (((csharp2cuda_temp_328) <= (lower)))
                                    {
#line 1133 "SequencePathModule.cs"
#line 1133 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_329 = &(state);
                                        (*(csharp2cuda_temp_329) = (-(1.0)));
                                    }
                                }
#line 1134 "SequencePathModule.cs"
#line 1134 "SequencePathModule.cs"
                                double* csharp2cuda_temp_330 = &((result)[index]);
                                (*(csharp2cuda_temp_330) = state);
                            }
#line 1128 "SequencePathModule.cs"
                            int* csharp2cuda_temp_324 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_324));
                        }
                    }
                }
            }
#line 1138 "SequencePathModule.cs"
            break;
#line 1139 "SequencePathModule.cs"
        case 17:
#line 1140 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1141 "SequencePathModule.cs"
            {
#line 1142 "SequencePathModule.cs"
                int csharp2cuda_temp_331 = (first)->count;
#line 1142 "SequencePathModule.cs"
                int csharp2cuda_temp_332;
#line 1142 "SequencePathModule.cs"
                if (((csharp2cuda_temp_331) == (0)))
                {
#line 1142 "SequencePathModule.cs"
                    csharp2cuda_temp_332 = 0;
                }
                else
                {
#line 1142 "SequencePathModule.cs"
                    int csharp2cuda_temp_333 = (first)->count;
#line 1142 "SequencePathModule.cs"
                    csharp2cuda_temp_332 = csharp2cuda_i32_sub(csharp2cuda_i32_mul(2, csharp2cuda_temp_333), 1);
                }
#line 1142 "SequencePathModule.cs"
                int rows = csharp2cuda_temp_332;
#line 1143 "SequencePathModule.cs"
                mathblocks_sequence_set_matrix_shape(output, rows, 2);
#line 1144 "SequencePathModule.cs"
#line 1144 "SequencePathModule.cs"
                int csharp2cuda_temp_334 = (first)->count;
                if (((csharp2cuda_temp_334) <= (0)))
#line 1145 "SequencePathModule.cs"
                {
#line 1146 "SequencePathModule.cs"
#line 1146 "SequencePathModule.cs"
                    int* csharp2cuda_temp_335 = &((output)->valid);
                    (*(csharp2cuda_temp_335) = 0);
                }
                else
#line 1149 "SequencePathModule.cs"
                {
#line 1150 "SequencePathModule.cs"
#line 1150 "SequencePathModule.cs"
                    double* csharp2cuda_temp_336 = &((result)[0]);
#line 1150 "SequencePathModule.cs"
                    double csharp2cuda_temp_337 = (a)[0];
                    (*(csharp2cuda_temp_336) = csharp2cuda_temp_337);
#line 1151 "SequencePathModule.cs"
#line 1151 "SequencePathModule.cs"
                    double* csharp2cuda_temp_338 = &((result)[1]);
#line 1151 "SequencePathModule.cs"
                    double csharp2cuda_temp_339 = (a)[0];
                    (*(csharp2cuda_temp_338) = csharp2cuda_temp_339);
#line 1152 "SequencePathModule.cs"
                    int row = 0;
#line 1153 "SequencePathModule.cs"
                    {
#line 1153 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 1153 "SequencePathModule.cs"
                            int csharp2cuda_temp_341 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_341))))
                                break;
#line 1154 "SequencePathModule.cs"
                            {
#line 1155 "SequencePathModule.cs"
#line 1155 "SequencePathModule.cs"
                                int* csharp2cuda_temp_342 = &(row);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_342));
#line 1156 "SequencePathModule.cs"
#line 1156 "SequencePathModule.cs"
                                double* csharp2cuda_temp_343 = &((result)[csharp2cuda_i32_mul(row, 2)]);
#line 1156 "SequencePathModule.cs"
                                double csharp2cuda_temp_344 = (a)[index];
                                (*(csharp2cuda_temp_343) = csharp2cuda_temp_344);
#line 1157 "SequencePathModule.cs"
#line 1157 "SequencePathModule.cs"
                                double* csharp2cuda_temp_345 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, 2), 1)]);
#line 1157 "SequencePathModule.cs"
                                double csharp2cuda_temp_346 = (a)[csharp2cuda_i32_sub(index, 1)];
                                (*(csharp2cuda_temp_345) = csharp2cuda_temp_346);
#line 1158 "SequencePathModule.cs"
#line 1158 "SequencePathModule.cs"
                                int* csharp2cuda_temp_347 = &(row);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_347));
#line 1159 "SequencePathModule.cs"
#line 1159 "SequencePathModule.cs"
                                double* csharp2cuda_temp_348 = &((result)[csharp2cuda_i32_mul(row, 2)]);
#line 1159 "SequencePathModule.cs"
                                double csharp2cuda_temp_349 = (a)[index];
                                (*(csharp2cuda_temp_348) = csharp2cuda_temp_349);
#line 1160 "SequencePathModule.cs"
#line 1160 "SequencePathModule.cs"
                                double* csharp2cuda_temp_350 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, 2), 1)]);
#line 1160 "SequencePathModule.cs"
                                double csharp2cuda_temp_351 = (a)[index];
                                (*(csharp2cuda_temp_350) = csharp2cuda_temp_351);
                            }
#line 1153 "SequencePathModule.cs"
                            int* csharp2cuda_temp_340 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_340));
                        }
                    }
                }
            }
#line 1164 "SequencePathModule.cs"
            break;
#line 1165 "SequencePathModule.cs"
        case 18:
#line 1166 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1167 "SequencePathModule.cs"
#line 1167 "SequencePathModule.cs"
                double* csharp2cuda_temp_352 = &((output)->scalar_value);
#line 1167 "SequencePathModule.cs"
                int csharp2cuda_temp_353 = (first)->count;
#line 1167 "SequencePathModule.cs"
                double csharp2cuda_temp_354 = mathblocks_sequence_longest_run_value(boolean_a, csharp2cuda_temp_353);
                (*(csharp2cuda_temp_352) = csharp2cuda_temp_354);
            }
#line 1168 "SequencePathModule.cs"
            break;
#line 1169 "SequencePathModule.cs"
        case 19:
        case 20:
#line 1171 "SequencePathModule.cs"
#line 1171 "SequencePathModule.cs"
            bool csharp2cuda_temp_355;
#line 1171 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1172 "SequencePathModule.cs"
                int csharp2cuda_temp_356 = (first)->count;
#line 1172 "SequencePathModule.cs"
                double* csharp2cuda_temp_357 = &((output)->scalar_value);
#line 1172 "SequencePathModule.cs"
                bool csharp2cuda_temp_358 = mathblocks_sequence_decline_value(a, csharp2cuda_temp_356, ((opcode) == (20)), csharp2cuda_temp_357);
#line 1171 "SequencePathModule.cs"
                csharp2cuda_temp_355 = (!(csharp2cuda_temp_358));
            }
            else
            {
#line 1171 "SequencePathModule.cs"
                csharp2cuda_temp_355 = false;
            }
            if (csharp2cuda_temp_355)
            {
#line 1173 "SequencePathModule.cs"
#line 1173 "SequencePathModule.cs"
                int* csharp2cuda_temp_359 = &((output)->valid);
                (*(csharp2cuda_temp_359) = 0);
            }
#line 1174 "SequencePathModule.cs"
            break;
#line 1175 "SequencePathModule.cs"
        case 21:
        case 22:
        case 29:
#line 1178 "SequencePathModule.cs"
#line 1178 "SequencePathModule.cs"
            bool csharp2cuda_temp_360;
#line 1178 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1181 "SequencePathModule.cs"
                int csharp2cuda_temp_361 = (first)->count;
#line 1182 "SequencePathModule.cs"
                double csharp2cuda_temp_362;
#line 1182 "SequencePathModule.cs"
                if (((opcode) == (22)))
                {
#line 1182 "SequencePathModule.cs"
                    csharp2cuda_temp_362 = 2.0;
                }
                else
                {
#line 1182 "SequencePathModule.cs"
                    double csharp2cuda_temp_363;
#line 1182 "SequencePathModule.cs"
                    if (((((void*)(second))) == (((void*)(nullptr)))))
                    {
#line 1182 "SequencePathModule.cs"
                        csharp2cuda_temp_363 = 1.0;
                    }
                    else
                    {
#line 1182 "SequencePathModule.cs"
                        csharp2cuda_temp_363 = (second)->scalar_value;
                    }
#line 1182 "SequencePathModule.cs"
                    csharp2cuda_temp_362 = csharp2cuda_temp_363;
                }
#line 1184 "SequencePathModule.cs"
                double* csharp2cuda_temp_364 = &((output)->scalar_value);
#line 1179 "SequencePathModule.cs"
                bool csharp2cuda_temp_365 = mathblocks_sequence_variation_value(a, csharp2cuda_temp_361, csharp2cuda_temp_362, ((opcode) == (29)), csharp2cuda_temp_364);
#line 1178 "SequencePathModule.cs"
                csharp2cuda_temp_360 = (!(csharp2cuda_temp_365));
            }
            else
            {
#line 1178 "SequencePathModule.cs"
                csharp2cuda_temp_360 = false;
            }
            if (csharp2cuda_temp_360)
            {
#line 1185 "SequencePathModule.cs"
#line 1185 "SequencePathModule.cs"
                int* csharp2cuda_temp_366 = &((output)->valid);
                (*(csharp2cuda_temp_366) = 0);
            }
#line 1186 "SequencePathModule.cs"
            break;
#line 1187 "SequencePathModule.cs"
        case 23:
#line 1188 "SequencePathModule.cs"
#line 1188 "SequencePathModule.cs"
            bool csharp2cuda_temp_367;
#line 1188 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1191 "SequencePathModule.cs"
                int csharp2cuda_temp_368 = (first)->count;
#line 1192 "SequencePathModule.cs"
                double csharp2cuda_temp_369 = (second)->scalar_value;
#line 1193 "SequencePathModule.cs"
                double* csharp2cuda_temp_370 = &((output)->scalar_value);
#line 1189 "SequencePathModule.cs"
                bool csharp2cuda_temp_371 = mathblocks_sequence_recurrence_value(a, csharp2cuda_temp_368, csharp2cuda_temp_369, csharp2cuda_temp_370);
#line 1188 "SequencePathModule.cs"
                csharp2cuda_temp_367 = (!(csharp2cuda_temp_371));
            }
            else
            {
#line 1188 "SequencePathModule.cs"
                csharp2cuda_temp_367 = false;
            }
            if (csharp2cuda_temp_367)
            {
#line 1194 "SequencePathModule.cs"
#line 1194 "SequencePathModule.cs"
                int* csharp2cuda_temp_372 = &((output)->valid);
                (*(csharp2cuda_temp_372) = 0);
            }
#line 1195 "SequencePathModule.cs"
            break;
#line 1196 "SequencePathModule.cs"
        case 24:
#line 1197 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1198 "SequencePathModule.cs"
            {
#line 1199 "SequencePathModule.cs"
#line 1199 "SequencePathModule.cs"
                int csharp2cuda_temp_373 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_373);
#line 1200 "SequencePathModule.cs"
#line 1200 "SequencePathModule.cs"
                int csharp2cuda_temp_374 = (first)->count;
                if (((csharp2cuda_temp_374) <= (0)))
#line 1201 "SequencePathModule.cs"
                {
#line 1202 "SequencePathModule.cs"
#line 1202 "SequencePathModule.cs"
                    int* csharp2cuda_temp_375 = &((output)->valid);
                    (*(csharp2cuda_temp_375) = 0);
                }
                else
#line 1205 "SequencePathModule.cs"
                {
#line 1206 "SequencePathModule.cs"
                    double cumulative = 0.0;
#line 1207 "SequencePathModule.cs"
                    double minimum = 0.0;
#line 1208 "SequencePathModule.cs"
                    {
#line 1208 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1208 "SequencePathModule.cs"
                            int csharp2cuda_temp_377 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_377))))
                                break;
#line 1209 "SequencePathModule.cs"
                            {
#line 1210 "SequencePathModule.cs"
#line 1210 "SequencePathModule.cs"
                                double* csharp2cuda_temp_378 = &(cumulative);
#line 1210 "SequencePathModule.cs"
                                double csharp2cuda_temp_379 = *(csharp2cuda_temp_378);
#line 1210 "SequencePathModule.cs"
                                double csharp2cuda_temp_380 = (a)[index];
                                (*(csharp2cuda_temp_378) = __dadd_rn(csharp2cuda_temp_379, csharp2cuda_temp_380));
#line 1211 "SequencePathModule.cs"
#line 1211 "SequencePathModule.cs"
                                double* csharp2cuda_temp_381 = &(minimum);
#line 1211 "SequencePathModule.cs"
                                double csharp2cuda_temp_382;
#line 1211 "SequencePathModule.cs"
                                if (((minimum) < (cumulative)))
                                {
#line 1211 "SequencePathModule.cs"
                                    csharp2cuda_temp_382 = minimum;
                                }
                                else
                                {
#line 1211 "SequencePathModule.cs"
                                    csharp2cuda_temp_382 = cumulative;
                                }
                                (*(csharp2cuda_temp_381) = csharp2cuda_temp_382);
#line 1212 "SequencePathModule.cs"
#line 1212 "SequencePathModule.cs"
                                double* csharp2cuda_temp_383 = &((result)[index]);
                                (*(csharp2cuda_temp_383) = __dsub_rn(cumulative, minimum));
#line 1213 "SequencePathModule.cs"
#line 1213 "SequencePathModule.cs"
                                double csharp2cuda_temp_384 = (result)[index];
                                if ((!(isfinite(csharp2cuda_temp_384))))
                                {
#line 1214 "SequencePathModule.cs"
#line 1214 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_385 = &((output)->valid);
                                    (*(csharp2cuda_temp_385) = 0);
                                }
                            }
#line 1208 "SequencePathModule.cs"
                            int* csharp2cuda_temp_376 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_376));
                        }
                    }
                }
            }
#line 1218 "SequencePathModule.cs"
            break;
#line 1219 "SequencePathModule.cs"
        case 25:
#line 1220 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1221 "SequencePathModule.cs"
            {
#line 1222 "SequencePathModule.cs"
                unsigned long long csharp2cuda_temp_386 = (output)->data_pointer;
#line 1222 "SequencePathModule.cs"
                MathBlockSequencePathRun* runs = ((MathBlockSequencePathRun*)(csharp2cuda_temp_386));
#line 1223 "SequencePathModule.cs"
#line 1223 "SequencePathModule.cs"
                int csharp2cuda_temp_387 = (first)->count;
                if (((csharp2cuda_temp_387) == (0)))
#line 1224 "SequencePathModule.cs"
                {
#line 1225 "SequencePathModule.cs"
#line 1225 "SequencePathModule.cs"
                    int* csharp2cuda_temp_388 = &((output)->count);
                    (*(csharp2cuda_temp_388) = 0);
#line 1226 "SequencePathModule.cs"
#line 1226 "SequencePathModule.cs"
                    int* csharp2cuda_temp_389 = &((output)->rows);
                    (*(csharp2cuda_temp_389) = 0);
                }
                else
#line 1229 "SequencePathModule.cs"
                {
#line 1230 "SequencePathModule.cs"
                    int start = 0;
#line 1231 "SequencePathModule.cs"
                    int count = 0;
#line 1232 "SequencePathModule.cs"
                    {
#line 1232 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 1232 "SequencePathModule.cs"
                            int csharp2cuda_temp_391 = (first)->count;
                            if (!(((index) <= (csharp2cuda_temp_391))))
                                break;
#line 1233 "SequencePathModule.cs"
                            {
#line 1234 "SequencePathModule.cs"
#line 1234 "SequencePathModule.cs"
                                int csharp2cuda_temp_392 = (first)->count;
#line 1234 "SequencePathModule.cs"
                                bool csharp2cuda_temp_393;
#line 1234 "SequencePathModule.cs"
                                if (((index) < (csharp2cuda_temp_392)))
                                {
#line 1234 "SequencePathModule.cs"
                                    double csharp2cuda_temp_394 = (a)[index];
#line 1234 "SequencePathModule.cs"
                                    double csharp2cuda_temp_395 = (a)[start];
#line 1234 "SequencePathModule.cs"
                                    csharp2cuda_temp_393 = ((csharp2cuda_temp_394) == (csharp2cuda_temp_395));
                                }
                                else
                                {
#line 1234 "SequencePathModule.cs"
                                    csharp2cuda_temp_393 = false;
                                }
                                if (csharp2cuda_temp_393)
                                {
#line 1235 "SequencePathModule.cs"
                                    goto csharp2cuda_for_continue_30;
                                }
#line 1236 "SequencePathModule.cs"
#line 1236 "SequencePathModule.cs"
                                int csharp2cuda_temp_396 = (output)->capacity;
                                if (((count) >= (csharp2cuda_temp_396)))
#line 1237 "SequencePathModule.cs"
                                {
#line 1238 "SequencePathModule.cs"
#line 1238 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_397 = &((output)->count);
#line 1238 "SequencePathModule.cs"
                                    int csharp2cuda_temp_398 = (output)->capacity;
#line 1238 "SequencePathModule.cs"
                                    int csharp2cuda_temp_399;
#line 1238 "SequencePathModule.cs"
                                    if (((csharp2cuda_temp_398) == (2147483647)))
                                    {
#line 1238 "SequencePathModule.cs"
                                        csharp2cuda_temp_399 = csharp2cuda_i32_neg(1);
                                    }
                                    else
                                    {
#line 1240 "SequencePathModule.cs"
                                        int csharp2cuda_temp_400 = (output)->capacity;
#line 1238 "SequencePathModule.cs"
                                        csharp2cuda_temp_399 = csharp2cuda_i32_add(csharp2cuda_temp_400, 1);
                                    }
                                    (*(csharp2cuda_temp_397) = csharp2cuda_temp_399);
#line 1241 "SequencePathModule.cs"
#line 1241 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_401 = &((output)->rows);
#line 1241 "SequencePathModule.cs"
                                    int csharp2cuda_temp_402 = (output)->count;
                                    (*(csharp2cuda_temp_401) = csharp2cuda_temp_402);
#line 1242 "SequencePathModule.cs"
#line 1242 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_403 = &((output)->valid);
                                    (*(csharp2cuda_temp_403) = 0);
#line 1243 "SequencePathModule.cs"
                                    break;
                                }
#line 1245 "SequencePathModule.cs"
#line 1245 "SequencePathModule.cs"
                                int* csharp2cuda_temp_404 = &(((runs)[count]).start);
                                (*(csharp2cuda_temp_404) = start);
#line 1246 "SequencePathModule.cs"
#line 1246 "SequencePathModule.cs"
                                int* csharp2cuda_temp_405 = &(((runs)[count]).length);
                                (*(csharp2cuda_temp_405) = csharp2cuda_i32_sub(index, start));
#line 1247 "SequencePathModule.cs"
#line 1247 "SequencePathModule.cs"
                                double* csharp2cuda_temp_406 = &(((runs)[count]).value);
#line 1247 "SequencePathModule.cs"
                                double csharp2cuda_temp_407 = (a)[start];
                                (*(csharp2cuda_temp_406) = csharp2cuda_temp_407);
#line 1248 "SequencePathModule.cs"
#line 1248 "SequencePathModule.cs"
                                int* csharp2cuda_temp_408 = &(count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_408));
#line 1249 "SequencePathModule.cs"
#line 1249 "SequencePathModule.cs"
                                int* csharp2cuda_temp_409 = &(start);
                                (*(csharp2cuda_temp_409) = index);
                            }
                            csharp2cuda_for_continue_30:
#line 1232 "SequencePathModule.cs"
                            int* csharp2cuda_temp_390 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_390));
                        }
                    }
#line 1251 "SequencePathModule.cs"
                    if ((output)->valid)
#line 1252 "SequencePathModule.cs"
                    {
#line 1253 "SequencePathModule.cs"
#line 1253 "SequencePathModule.cs"
                        int* csharp2cuda_temp_410 = &((output)->count);
                        (*(csharp2cuda_temp_410) = count);
#line 1254 "SequencePathModule.cs"
#line 1254 "SequencePathModule.cs"
                        int* csharp2cuda_temp_411 = &((output)->rows);
                        (*(csharp2cuda_temp_411) = count);
                    }
                }
            }
#line 1258 "SequencePathModule.cs"
            break;
#line 1259 "SequencePathModule.cs"
        case 26:
#line 1260 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1261 "SequencePathModule.cs"
            {
#line 1262 "SequencePathModule.cs"
#line 1262 "SequencePathModule.cs"
                int csharp2cuda_temp_412 = (first)->columns;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_412);
#line 1263 "SequencePathModule.cs"
#line 1263 "SequencePathModule.cs"
                int csharp2cuda_temp_413 = (first)->rows;
                if (((csharp2cuda_temp_413) <= (0)))
#line 1264 "SequencePathModule.cs"
                {
#line 1265 "SequencePathModule.cs"
#line 1265 "SequencePathModule.cs"
                    int* csharp2cuda_temp_414 = &((output)->valid);
                    (*(csharp2cuda_temp_414) = 0);
                }
                else
#line 1268 "SequencePathModule.cs"
                {
#line 1269 "SequencePathModule.cs"
                    {
#line 1269 "SequencePathModule.cs"
                        int column = 0;
                        while (true)
                        {
#line 1269 "SequencePathModule.cs"
                            int csharp2cuda_temp_416 = (first)->columns;
                            if (!(((column) < (csharp2cuda_temp_416))))
                                break;
#line 1270 "SequencePathModule.cs"
#line 1270 "SequencePathModule.cs"
                            double* csharp2cuda_temp_417 = &((result)[column]);
#line 1270 "SequencePathModule.cs"
                            int csharp2cuda_temp_418 = (first)->rows;
#line 1270 "SequencePathModule.cs"
                            int csharp2cuda_temp_419 = (first)->columns;
#line 1270 "SequencePathModule.cs"
                            double csharp2cuda_temp_420 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(csharp2cuda_temp_418, 1), csharp2cuda_temp_419), column)];
#line 1270 "SequencePathModule.cs"
                            double csharp2cuda_temp_421 = (a)[column];
                            (*(csharp2cuda_temp_417) = __dsub_rn(csharp2cuda_temp_420, csharp2cuda_temp_421));
#line 1269 "SequencePathModule.cs"
                            int* csharp2cuda_temp_415 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_415));
                        }
                    }
                }
            }
#line 1273 "SequencePathModule.cs"
            break;
#line 1274 "SequencePathModule.cs"
        case 27:
#line 1275 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1276 "SequencePathModule.cs"
            {
#line 1277 "SequencePathModule.cs"
                int dimension = (first)->columns;
#line 1278 "SequencePathModule.cs"
                int count = csharp2cuda_i32_mul(csharp2cuda_i32_mul(dimension, dimension), dimension);
#line 1279 "SequencePathModule.cs"
                mathblocks_sequence_set_vector_shape(output, count);
#line 1280 "SequencePathModule.cs"
#line 1280 "SequencePathModule.cs"
                int csharp2cuda_temp_422 = (first)->rows;
#line 1280 "SequencePathModule.cs"
                bool csharp2cuda_temp_423;
#line 1280 "SequencePathModule.cs"
                if (!(((csharp2cuda_temp_422) < (1))))
                {
#line 1280 "SequencePathModule.cs"
                    csharp2cuda_temp_423 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 1280 "SequencePathModule.cs"
                    csharp2cuda_temp_423 = true;
                }
                if (csharp2cuda_temp_423)
#line 1281 "SequencePathModule.cs"
                {
#line 1282 "SequencePathModule.cs"
#line 1282 "SequencePathModule.cs"
                    int* csharp2cuda_temp_424 = &((output)->valid);
                    (*(csharp2cuda_temp_424) = 0);
                }
                else
#line 1285 "SequencePathModule.cs"
                {
#line 1286 "SequencePathModule.cs"
                    double* level_one = scratch;
#line 1287 "SequencePathModule.cs"
                    double* level_two = csharp2cuda_pointer_add(scratch, dimension);
#line 1288 "SequencePathModule.cs"
                    double* increment = csharp2cuda_pointer_add(level_two, csharp2cuda_i32_mul(dimension, dimension));
#line 1289 "SequencePathModule.cs"
                    {
#line 1289 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (dimension))))
                                break;
#line 1290 "SequencePathModule.cs"
#line 1290 "SequencePathModule.cs"
                            double* csharp2cuda_temp_426 = &((level_one)[index]);
                            (*(csharp2cuda_temp_426) = 0.0);
#line 1289 "SequencePathModule.cs"
                            int* csharp2cuda_temp_425 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_425));
                        }
                    }
#line 1291 "SequencePathModule.cs"
                    {
#line 1291 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(dimension, dimension)))))
                                break;
#line 1292 "SequencePathModule.cs"
#line 1292 "SequencePathModule.cs"
                            double* csharp2cuda_temp_428 = &((level_two)[index]);
                            (*(csharp2cuda_temp_428) = 0.0);
#line 1291 "SequencePathModule.cs"
                            int* csharp2cuda_temp_427 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_427));
                        }
                    }
#line 1293 "SequencePathModule.cs"
                    {
#line 1293 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (count))))
                                break;
#line 1294 "SequencePathModule.cs"
#line 1294 "SequencePathModule.cs"
                            double* csharp2cuda_temp_430 = &((result)[index]);
                            (*(csharp2cuda_temp_430) = 0.0);
#line 1293 "SequencePathModule.cs"
                            int* csharp2cuda_temp_429 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_429));
                        }
                    }
#line 1295 "SequencePathModule.cs"
                    {
#line 1295 "SequencePathModule.cs"
                        int row = 1;
                        while (true)
                        {
#line 1295 "SequencePathModule.cs"
                            int csharp2cuda_temp_432 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_432))))
                                break;
#line 1296 "SequencePathModule.cs"
                            {
#line 1297 "SequencePathModule.cs"
                                {
#line 1297 "SequencePathModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
                                        if (!(((index) < (dimension))))
                                            break;
#line 1298 "SequencePathModule.cs"
#line 1298 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_434 = &((increment)[index]);
#line 1298 "SequencePathModule.cs"
                                        double csharp2cuda_temp_435 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, dimension), index)];
#line 1298 "SequencePathModule.cs"
                                        double csharp2cuda_temp_436 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(row, 1), dimension), index)];
                                        (*(csharp2cuda_temp_434) = __dsub_rn(csharp2cuda_temp_435, csharp2cuda_temp_436));
#line 1297 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_433 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_433));
                                    }
                                }
#line 1299 "SequencePathModule.cs"
                                {
#line 1299 "SequencePathModule.cs"
                                    int left = 0;
                                    while (true)
                                    {
                                        if (!(((left) < (dimension))))
                                            break;
#line 1300 "SequencePathModule.cs"
                                        {
#line 1301 "SequencePathModule.cs"
                                            {
#line 1301 "SequencePathModule.cs"
                                                int middle = 0;
                                                while (true)
                                                {
                                                    if (!(((middle) < (dimension))))
                                                        break;
#line 1302 "SequencePathModule.cs"
                                                    {
#line 1303 "SequencePathModule.cs"
                                                        {
#line 1303 "SequencePathModule.cs"
                                                            int right = 0;
                                                            while (true)
                                                            {
                                                                if (!(((right) < (dimension))))
                                                                    break;
#line 1304 "SequencePathModule.cs"
                                                                {
#line 1305 "SequencePathModule.cs"
                                                                    int target = csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), middle), dimension), right);
#line 1306 "SequencePathModule.cs"
#line 1306 "SequencePathModule.cs"
                                                                    double* csharp2cuda_temp_440 = &((result)[target]);
#line 1306 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_441 = *(csharp2cuda_temp_440);
#line 1307 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_442 = (level_two)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), middle)];
#line 1307 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_443 = (increment)[right];
#line 1308 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_444 = (level_one)[left];
#line 1308 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_445 = (increment)[middle];
#line 1308 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_446 = (increment)[right];
#line 1308 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_447 = __ddiv_rn(__dmul_rn(__dmul_rn(csharp2cuda_temp_444, csharp2cuda_temp_445), csharp2cuda_temp_446), 2.0);
#line 1309 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_448 = (increment)[left];
#line 1309 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_449 = (increment)[middle];
#line 1309 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_450 = (increment)[right];
#line 1309 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_451 = __ddiv_rn(__dmul_rn(__dmul_rn(csharp2cuda_temp_448, csharp2cuda_temp_449), csharp2cuda_temp_450), 6.0);
                                                                    (*(csharp2cuda_temp_440) = __dadd_rn(csharp2cuda_temp_441, __dadd_rn(__dadd_rn(__dmul_rn(csharp2cuda_temp_442, csharp2cuda_temp_443), csharp2cuda_temp_447), csharp2cuda_temp_451)));
                                                                }
#line 1303 "SequencePathModule.cs"
                                                                int* csharp2cuda_temp_439 = &(right);
                                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_439));
                                                            }
                                                        }
#line 1311 "SequencePathModule.cs"
#line 1311 "SequencePathModule.cs"
                                                        double* csharp2cuda_temp_452 = &((level_two)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), middle)]);
#line 1311 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_453 = *(csharp2cuda_temp_452);
#line 1312 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_454 = (level_one)[left];
#line 1312 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_455 = (increment)[middle];
#line 1313 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_456 = (increment)[left];
#line 1313 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_457 = (increment)[middle];
#line 1313 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_458 = __ddiv_rn(__dmul_rn(csharp2cuda_temp_456, csharp2cuda_temp_457), 2.0);
                                                        (*(csharp2cuda_temp_452) = __dadd_rn(csharp2cuda_temp_453, __dadd_rn(__dmul_rn(csharp2cuda_temp_454, csharp2cuda_temp_455), csharp2cuda_temp_458)));
                                                    }
#line 1301 "SequencePathModule.cs"
                                                    int* csharp2cuda_temp_438 = &(middle);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_438));
                                                }
                                            }
#line 1315 "SequencePathModule.cs"
#line 1315 "SequencePathModule.cs"
                                            double* csharp2cuda_temp_459 = &((level_one)[left]);
#line 1315 "SequencePathModule.cs"
                                            double csharp2cuda_temp_460 = *(csharp2cuda_temp_459);
#line 1315 "SequencePathModule.cs"
                                            double csharp2cuda_temp_461 = (increment)[left];
                                            (*(csharp2cuda_temp_459) = __dadd_rn(csharp2cuda_temp_460, csharp2cuda_temp_461));
                                        }
#line 1299 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_437 = &(left);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_437));
                                    }
                                }
                            }
#line 1295 "SequencePathModule.cs"
                            int* csharp2cuda_temp_431 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_431));
                        }
                    }
                }
            }
#line 1320 "SequencePathModule.cs"
            break;
#line 1321 "SequencePathModule.cs"
        case 28:
#line 1322 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1323 "SequencePathModule.cs"
            {
#line 1324 "SequencePathModule.cs"
                int dimension = (first)->columns;
#line 1325 "SequencePathModule.cs"
                mathblocks_sequence_set_matrix_shape(output, dimension, dimension);
#line 1326 "SequencePathModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 1327 "SequencePathModule.cs"
                {
#line 1328 "SequencePathModule.cs"
#line 1328 "SequencePathModule.cs"
                    int* csharp2cuda_temp_462 = &((output)->valid);
                    (*(csharp2cuda_temp_462) = 0);
                }
                else
#line 1331 "SequencePathModule.cs"
                {
#line 1332 "SequencePathModule.cs"
                    double* cumulative = scratch;
#line 1333 "SequencePathModule.cs"
                    double* increment = csharp2cuda_pointer_add(scratch, dimension);
#line 1334 "SequencePathModule.cs"
                    {
#line 1334 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (dimension))))
                                break;
#line 1335 "SequencePathModule.cs"
#line 1335 "SequencePathModule.cs"
                            double* csharp2cuda_temp_464 = &((cumulative)[index]);
                            (*(csharp2cuda_temp_464) = 0.0);
#line 1334 "SequencePathModule.cs"
                            int* csharp2cuda_temp_463 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_463));
                        }
                    }
#line 1336 "SequencePathModule.cs"
                    {
#line 1336 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(dimension, dimension)))))
                                break;
#line 1337 "SequencePathModule.cs"
#line 1337 "SequencePathModule.cs"
                            double* csharp2cuda_temp_466 = &((result)[index]);
                            (*(csharp2cuda_temp_466) = 0.0);
#line 1336 "SequencePathModule.cs"
                            int* csharp2cuda_temp_465 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_465));
                        }
                    }
#line 1338 "SequencePathModule.cs"
                    {
#line 1338 "SequencePathModule.cs"
                        int row = 1;
                        while (true)
                        {
#line 1338 "SequencePathModule.cs"
                            int csharp2cuda_temp_468 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_468))))
                                break;
#line 1339 "SequencePathModule.cs"
                            {
#line 1340 "SequencePathModule.cs"
                                {
#line 1340 "SequencePathModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
                                        if (!(((column) < (dimension))))
                                            break;
#line 1341 "SequencePathModule.cs"
#line 1341 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_470 = &((increment)[column]);
#line 1341 "SequencePathModule.cs"
                                        double csharp2cuda_temp_471 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, dimension), column)];
#line 1341 "SequencePathModule.cs"
                                        double csharp2cuda_temp_472 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(row, 1), dimension), column)];
                                        (*(csharp2cuda_temp_470) = __dsub_rn(csharp2cuda_temp_471, csharp2cuda_temp_472));
#line 1340 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_469 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_469));
                                    }
                                }
#line 1342 "SequencePathModule.cs"
                                {
#line 1342 "SequencePathModule.cs"
                                    int left = 0;
                                    while (true)
                                    {
                                        if (!(((left) < (dimension))))
                                            break;
#line 1343 "SequencePathModule.cs"
                                        {
#line 1344 "SequencePathModule.cs"
                                            {
#line 1344 "SequencePathModule.cs"
                                                int right = 0;
                                                while (true)
                                                {
                                                    if (!(((right) < (dimension))))
                                                        break;
#line 1345 "SequencePathModule.cs"
                                                    {
#line 1346 "SequencePathModule.cs"
#line 1346 "SequencePathModule.cs"
                                                        double* csharp2cuda_temp_475 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), right)]);
#line 1346 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_476 = *(csharp2cuda_temp_475);
#line 1347 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_477 = (cumulative)[left];
#line 1347 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_478 = (increment)[right];
#line 1348 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_479 = (increment)[left];
#line 1348 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_480 = (increment)[right];
                                                        (*(csharp2cuda_temp_475) = __dadd_rn(csharp2cuda_temp_476, __dadd_rn(__dmul_rn(csharp2cuda_temp_477, csharp2cuda_temp_478), __dmul_rn(__dmul_rn(0.5, csharp2cuda_temp_479), csharp2cuda_temp_480))));
                                                    }
#line 1344 "SequencePathModule.cs"
                                                    int* csharp2cuda_temp_474 = &(right);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_474));
                                                }
                                            }
                                        }
#line 1342 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_473 = &(left);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_473));
                                    }
                                }
#line 1351 "SequencePathModule.cs"
                                {
#line 1351 "SequencePathModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
                                        if (!(((column) < (dimension))))
                                            break;
#line 1352 "SequencePathModule.cs"
#line 1352 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_482 = &((cumulative)[column]);
#line 1352 "SequencePathModule.cs"
                                        double csharp2cuda_temp_483 = *(csharp2cuda_temp_482);
#line 1352 "SequencePathModule.cs"
                                        double csharp2cuda_temp_484 = (increment)[column];
                                        (*(csharp2cuda_temp_482) = __dadd_rn(csharp2cuda_temp_483, csharp2cuda_temp_484));
#line 1351 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_481 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_481));
                                    }
                                }
                            }
#line 1338 "SequencePathModule.cs"
                            int* csharp2cuda_temp_467 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_467));
                        }
                    }
                }
            }
#line 1356 "SequencePathModule.cs"
            break;
#line 1357 "SequencePathModule.cs"
        case 30:
        case 31:
#line 1359 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1360 "SequencePathModule.cs"
#line 1360 "SequencePathModule.cs"
                double* csharp2cuda_temp_485 = &((output)->scalar_value);
#line 1360 "SequencePathModule.cs"
                int csharp2cuda_temp_486 = (first)->count;
#line 1360 "SequencePathModule.cs"
                double csharp2cuda_temp_487 = mathblocks_sequence_sign_change_value(a, csharp2cuda_temp_486, ((opcode) == (30)));
                (*(csharp2cuda_temp_485) = csharp2cuda_temp_487);
            }
#line 1361 "SequencePathModule.cs"
            break;
#line 1362 "SequencePathModule.cs"
        case 32:
#line 1363 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1364 "SequencePathModule.cs"
            {
#line 1365 "SequencePathModule.cs"
                int state_count = 0;
#line 1366 "SequencePathModule.cs"
#line 1366 "SequencePathModule.cs"
                double csharp2cuda_temp_488 = (second)->scalar_value;
#line 1366 "SequencePathModule.cs"
                int* csharp2cuda_temp_489 = &(state_count);
#line 1366 "SequencePathModule.cs"
                bool csharp2cuda_temp_490 = mathblocks_sequence_positive_integer(csharp2cuda_temp_488, csharp2cuda_temp_489);
#line 1366 "SequencePathModule.cs"
                bool csharp2cuda_temp_491;
#line 1366 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_490))))
                {
#line 1366 "SequencePathModule.cs"
                    csharp2cuda_temp_491 = ((state_count) > (4096));
                }
                else
                {
#line 1366 "SequencePathModule.cs"
                    csharp2cuda_temp_491 = true;
                }
                if (csharp2cuda_temp_491)
#line 1367 "SequencePathModule.cs"
                {
#line 1368 "SequencePathModule.cs"
#line 1368 "SequencePathModule.cs"
                    int* csharp2cuda_temp_492 = &((output)->valid);
                    (*(csharp2cuda_temp_492) = 0);
                }
                else
#line 1371 "SequencePathModule.cs"
                {
#line 1372 "SequencePathModule.cs"
                    mathblocks_sequence_set_matrix_shape(output, state_count, state_count);
#line 1373 "SequencePathModule.cs"
                    {
#line 1373 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1373 "SequencePathModule.cs"
                            bool csharp2cuda_temp_494 = (output)->valid;
#line 1373 "SequencePathModule.cs"
                            bool csharp2cuda_temp_495;
#line 1373 "SequencePathModule.cs"
                            if (csharp2cuda_temp_494)
                            {
#line 1373 "SequencePathModule.cs"
                                int csharp2cuda_temp_496 = (output)->count;
#line 1373 "SequencePathModule.cs"
                                csharp2cuda_temp_495 = ((index) < (csharp2cuda_temp_496));
                            }
                            else
                            {
#line 1373 "SequencePathModule.cs"
                                csharp2cuda_temp_495 = false;
                            }
                            if (!(csharp2cuda_temp_495))
                                break;
#line 1374 "SequencePathModule.cs"
#line 1374 "SequencePathModule.cs"
                            double* csharp2cuda_temp_497 = &((result)[index]);
                            (*(csharp2cuda_temp_497) = 0.0);
#line 1373 "SequencePathModule.cs"
                            int* csharp2cuda_temp_493 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_493));
                        }
                    }
#line 1375 "SequencePathModule.cs"
                    {
#line 1375 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1375 "SequencePathModule.cs"
                            bool csharp2cuda_temp_499 = (output)->valid;
#line 1375 "SequencePathModule.cs"
                            bool csharp2cuda_temp_500;
#line 1375 "SequencePathModule.cs"
                            if (csharp2cuda_temp_499)
                            {
#line 1375 "SequencePathModule.cs"
                                int csharp2cuda_temp_501 = (first)->count;
#line 1375 "SequencePathModule.cs"
                                csharp2cuda_temp_500 = ((index) < (csharp2cuda_temp_501));
                            }
                            else
                            {
#line 1375 "SequencePathModule.cs"
                                csharp2cuda_temp_500 = false;
                            }
                            if (!(csharp2cuda_temp_500))
                                break;
#line 1376 "SequencePathModule.cs"
                            {
#line 1377 "SequencePathModule.cs"
                                int state = 0;
#line 1378 "SequencePathModule.cs"
#line 1378 "SequencePathModule.cs"
                                double csharp2cuda_temp_502 = (a)[index];
#line 1378 "SequencePathModule.cs"
                                int* csharp2cuda_temp_503 = &(state);
#line 1378 "SequencePathModule.cs"
                                bool csharp2cuda_temp_504 = mathblocks_nonnegative_integer(csharp2cuda_temp_502, csharp2cuda_temp_503);
#line 1378 "SequencePathModule.cs"
                                bool csharp2cuda_temp_505;
#line 1378 "SequencePathModule.cs"
                                if (!((!(csharp2cuda_temp_504))))
                                {
#line 1378 "SequencePathModule.cs"
                                    csharp2cuda_temp_505 = ((state) >= (state_count));
                                }
                                else
                                {
#line 1378 "SequencePathModule.cs"
                                    csharp2cuda_temp_505 = true;
                                }
                                if (csharp2cuda_temp_505)
                                {
#line 1379 "SequencePathModule.cs"
#line 1379 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_506 = &((output)->valid);
                                    (*(csharp2cuda_temp_506) = 0);
                                }
                            }
#line 1375 "SequencePathModule.cs"
                            int* csharp2cuda_temp_498 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_498));
                        }
                    }
#line 1381 "SequencePathModule.cs"
                    {
#line 1381 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 1381 "SequencePathModule.cs"
                            bool csharp2cuda_temp_508 = (output)->valid;
#line 1381 "SequencePathModule.cs"
                            bool csharp2cuda_temp_509;
#line 1381 "SequencePathModule.cs"
                            if (csharp2cuda_temp_508)
                            {
#line 1381 "SequencePathModule.cs"
                                int csharp2cuda_temp_510 = (first)->count;
#line 1381 "SequencePathModule.cs"
                                csharp2cuda_temp_509 = ((index) < (csharp2cuda_temp_510));
                            }
                            else
                            {
#line 1381 "SequencePathModule.cs"
                                csharp2cuda_temp_509 = false;
                            }
                            if (!(csharp2cuda_temp_509))
                                break;
#line 1382 "SequencePathModule.cs"
#line 1382 "SequencePathModule.cs"
                            double csharp2cuda_temp_511 = (a)[csharp2cuda_i32_sub(index, 1)];
#line 1382 "SequencePathModule.cs"
                            double csharp2cuda_temp_512 = (a)[index];
#line 1382 "SequencePathModule.cs"
                            double* csharp2cuda_temp_513 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_f64_to_i32(csharp2cuda_temp_511), state_count), csharp2cuda_f64_to_i32(csharp2cuda_temp_512))]);
#line 1382 "SequencePathModule.cs"
                            double csharp2cuda_temp_514 = *(csharp2cuda_temp_513);
                            (*(csharp2cuda_temp_513) = __dadd_rn(csharp2cuda_temp_514, 1.0));
#line 1381 "SequencePathModule.cs"
                            int* csharp2cuda_temp_507 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_507));
                        }
                    }
                }
            }
#line 1385 "SequencePathModule.cs"
            break;
    }
}

#line 42 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_positive_integer(double value, int* result)
#line 44 "SequencePathModule.cs"
{
#line 45 "SequencePathModule.cs"
#line 45 "SequencePathModule.cs"
    bool csharp2cuda_temp_0 = mathblocks_nonnegative_integer(value, result);
#line 45 "SequencePathModule.cs"
    bool csharp2cuda_temp_1;
#line 45 "SequencePathModule.cs"
    if (csharp2cuda_temp_0)
    {
#line 45 "SequencePathModule.cs"
        int csharp2cuda_temp_2 = *(result);
#line 45 "SequencePathModule.cs"
        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) > (0));
    }
    else
    {
#line 45 "SequencePathModule.cs"
        csharp2cuda_temp_1 = false;
    }
    return csharp2cuda_temp_1;
}

#line 95 "SequencePathModule.cs"
__device__ void mathblocks_sequence_prepare_order_ranks(
    const double* values,
    int count,
    unsigned char* scratch,
    MathBlockSlot* output)
#line 101 "SequencePathModule.cs"
{
#line 102 "SequencePathModule.cs"
    int thread = threadIdx.x;
#line 103 "SequencePathModule.cs"
    unsigned long long* first_keys = ((unsigned long long*)(scratch));
#line 104 "SequencePathModule.cs"
    unsigned long long* second_keys = csharp2cuda_pointer_add(first_keys, count);
#line 105 "SequencePathModule.cs"
    int* first_indexes = ((int*)(csharp2cuda_pointer_add(second_keys, count)));
#line 106 "SequencePathModule.cs"
    int* second_indexes = csharp2cuda_pointer_add(first_indexes, count);
#line 107 "SequencePathModule.cs"
    int* ranks = csharp2cuda_pointer_add(second_indexes, count);
#line 108 "SequencePathModule.cs"
    int* lower_heap = csharp2cuda_pointer_add(ranks, count);
#line 109 "SequencePathModule.cs"
    int csharp2cuda_temp_0 = (output)->boolean_value;
#line 109 "SequencePathModule.cs"
    int* upper_heap = csharp2cuda_pointer_add(lower_heap, csharp2cuda_temp_0);
#line 110 "SequencePathModule.cs"
    int csharp2cuda_temp_1 = (output)->boolean_value;
#line 110 "SequencePathModule.cs"
    int* positions = csharp2cuda_pointer_add(upper_heap, csharp2cuda_temp_1);
#line 111 "SequencePathModule.cs"
    int* kinds = csharp2cuda_pointer_add(positions, count);
#line 112 "SequencePathModule.cs"
    int* zero_counts = csharp2cuda_pointer_add(kinds, count);
#line 113 "SequencePathModule.cs"
    int* zero_prefix = csharp2cuda_pointer_add(zero_counts, 128);
#line 115 "SequencePathModule.cs"
    {
#line 115 "SequencePathModule.cs"
        int index = thread;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 116 "SequencePathModule.cs"
            {
#line 117 "SequencePathModule.cs"
#line 117 "SequencePathModule.cs"
                double csharp2cuda_temp_4 = (values)[index];
                if ((!(isfinite(csharp2cuda_temp_4))))
                {
#line 118 "SequencePathModule.cs"
                    atomicExch(&((output)->valid), 0);
                }
#line 119 "SequencePathModule.cs"
#line 119 "SequencePathModule.cs"
                unsigned long long* csharp2cuda_temp_5 = &((first_keys)[index]);
#line 119 "SequencePathModule.cs"
                double csharp2cuda_temp_6 = (values)[index];
                (*(csharp2cuda_temp_5) = mathblocks_sequence_order_key(csharp2cuda_temp_6));
#line 120 "SequencePathModule.cs"
#line 120 "SequencePathModule.cs"
                int* csharp2cuda_temp_7 = &((first_indexes)[index]);
                (*(csharp2cuda_temp_7) = index);
            }
#line 115 "SequencePathModule.cs"
            int* csharp2cuda_temp_2 = &(index);
#line 115 "SequencePathModule.cs"
            int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
            (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, blockDim.x));
        }
    }
#line 122 "SequencePathModule.cs"
    __syncthreads();
#line 123 "SequencePathModule.cs"
#line 123 "SequencePathModule.cs"
    bool csharp2cuda_temp_8 = (output)->valid;
    if ((!(csharp2cuda_temp_8)))
    {
#line 124 "SequencePathModule.cs"
        return;
    }
#line 126 "SequencePathModule.cs"
    unsigned long long* source_keys = first_keys;
#line 127 "SequencePathModule.cs"
    unsigned long long* destination_keys = second_keys;
#line 128 "SequencePathModule.cs"
    int* source_indexes = first_indexes;
#line 129 "SequencePathModule.cs"
    int* destination_indexes = second_indexes;
#line 130 "SequencePathModule.cs"
    {
#line 130 "SequencePathModule.cs"
        int bit = 0;
        while (true)
        {
            if (!(((bit) < (64))))
                break;
#line 131 "SequencePathModule.cs"
            {
#line 132 "SequencePathModule.cs"
                long long csharp2cuda_temp_10 = csharp2cuda_i64_div(csharp2cuda_i64_mul(((long long)(count)), ((long long)(thread))), ((long long)(blockDim.x)));
#line 132 "SequencePathModule.cs"
                int begin = csharp2cuda_i32_from_bits(csharp2cuda_temp_10);
#line 133 "SequencePathModule.cs"
                long long csharp2cuda_temp_11 = csharp2cuda_i64_div(csharp2cuda_i64_mul(((long long)(count)), ((long long)(csharp2cuda_i32_add(thread, 1)))), ((long long)(blockDim.x)));
#line 133 "SequencePathModule.cs"
                int end = csharp2cuda_i32_from_bits(csharp2cuda_temp_11);
#line 134 "SequencePathModule.cs"
                int zeros = 0;
#line 135 "SequencePathModule.cs"
                {
#line 135 "SequencePathModule.cs"
                    int index = begin;
                    while (true)
                    {
                        if (!(((index) < (end))))
                            break;
#line 136 "SequencePathModule.cs"
#line 136 "SequencePathModule.cs"
                        unsigned long long csharp2cuda_temp_13 = (source_keys)[index];
                        if (((((csharp2cuda_u64_shr(csharp2cuda_temp_13, bit)) & (1ull))) == (0ull)))
                        {
#line 137 "SequencePathModule.cs"
#line 137 "SequencePathModule.cs"
                            int* csharp2cuda_temp_14 = &(zeros);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_14));
                        }
#line 135 "SequencePathModule.cs"
                        int* csharp2cuda_temp_12 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_12));
                    }
                }
#line 138 "SequencePathModule.cs"
#line 138 "SequencePathModule.cs"
                int* csharp2cuda_temp_15 = &((zero_counts)[thread]);
                (*(csharp2cuda_temp_15) = zeros);
#line 139 "SequencePathModule.cs"
                __syncthreads();
#line 140 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 141 "SequencePathModule.cs"
                {
#line 142 "SequencePathModule.cs"
                    int prefix = 0;
#line 143 "SequencePathModule.cs"
                    {
#line 143 "SequencePathModule.cs"
                        int lane = 0;
                        while (true)
                        {
                            if (!(((lane) < (blockDim.x))))
                                break;
#line 144 "SequencePathModule.cs"
                            {
#line 145 "SequencePathModule.cs"
#line 145 "SequencePathModule.cs"
                                int* csharp2cuda_temp_17 = &((zero_prefix)[lane]);
                                (*(csharp2cuda_temp_17) = prefix);
#line 146 "SequencePathModule.cs"
#line 146 "SequencePathModule.cs"
                                int* csharp2cuda_temp_18 = &(prefix);
#line 146 "SequencePathModule.cs"
                                int csharp2cuda_temp_19 = *(csharp2cuda_temp_18);
#line 146 "SequencePathModule.cs"
                                int csharp2cuda_temp_20 = (zero_counts)[lane];
                                (*(csharp2cuda_temp_18) = csharp2cuda_i32_add(csharp2cuda_temp_19, csharp2cuda_temp_20));
                            }
#line 143 "SequencePathModule.cs"
                            int* csharp2cuda_temp_16 = &(lane);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
                        }
                    }
#line 148 "SequencePathModule.cs"
#line 148 "SequencePathModule.cs"
                    int* csharp2cuda_temp_21 = &((output)->columns);
                    (*(csharp2cuda_temp_21) = prefix);
                }
#line 150 "SequencePathModule.cs"
                __syncthreads();
#line 151 "SequencePathModule.cs"
                int zero_destination = (zero_prefix)[thread];
#line 152 "SequencePathModule.cs"
                int csharp2cuda_temp_22 = (output)->columns;
#line 152 "SequencePathModule.cs"
                int one_destination = csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_temp_22, begin), zero_destination);
#line 153 "SequencePathModule.cs"
                {
#line 153 "SequencePathModule.cs"
                    int index = begin;
                    while (true)
                    {
                        if (!(((index) < (end))))
                            break;
#line 154 "SequencePathModule.cs"
                        {
#line 155 "SequencePathModule.cs"
                            unsigned long long key = (source_keys)[index];
#line 156 "SequencePathModule.cs"
                            int csharp2cuda_temp_24;
#line 156 "SequencePathModule.cs"
                            if (((((csharp2cuda_u64_shr(key, bit)) & (1ull))) == (0ull)))
                            {
#line 157 "SequencePathModule.cs"
                                int* csharp2cuda_temp_25 = &(zero_destination);
#line 156 "SequencePathModule.cs"
                                csharp2cuda_temp_24 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_25));
                            }
                            else
                            {
#line 158 "SequencePathModule.cs"
                                int* csharp2cuda_temp_26 = &(one_destination);
#line 156 "SequencePathModule.cs"
                                csharp2cuda_temp_24 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_26));
                            }
#line 156 "SequencePathModule.cs"
                            int destination = csharp2cuda_temp_24;
#line 159 "SequencePathModule.cs"
#line 159 "SequencePathModule.cs"
                            unsigned long long* csharp2cuda_temp_27 = &((destination_keys)[destination]);
                            (*(csharp2cuda_temp_27) = key);
#line 160 "SequencePathModule.cs"
#line 160 "SequencePathModule.cs"
                            int* csharp2cuda_temp_28 = &((destination_indexes)[destination]);
#line 160 "SequencePathModule.cs"
                            int csharp2cuda_temp_29 = (source_indexes)[index];
                            (*(csharp2cuda_temp_28) = csharp2cuda_temp_29);
                        }
#line 153 "SequencePathModule.cs"
                        int* csharp2cuda_temp_23 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_23));
                    }
                }
#line 162 "SequencePathModule.cs"
                __syncthreads();
#line 163 "SequencePathModule.cs"
                unsigned long long* key_swap = source_keys;
#line 164 "SequencePathModule.cs"
#line 164 "SequencePathModule.cs"
                unsigned long long** csharp2cuda_temp_30 = &(source_keys);
                (*(csharp2cuda_temp_30) = destination_keys);
#line 165 "SequencePathModule.cs"
#line 165 "SequencePathModule.cs"
                unsigned long long** csharp2cuda_temp_31 = &(destination_keys);
                (*(csharp2cuda_temp_31) = key_swap);
#line 166 "SequencePathModule.cs"
                int* index_swap = source_indexes;
#line 167 "SequencePathModule.cs"
#line 167 "SequencePathModule.cs"
                int** csharp2cuda_temp_32 = &(source_indexes);
                (*(csharp2cuda_temp_32) = destination_indexes);
#line 168 "SequencePathModule.cs"
#line 168 "SequencePathModule.cs"
                int** csharp2cuda_temp_33 = &(destination_indexes);
                (*(csharp2cuda_temp_33) = index_swap);
            }
#line 130 "SequencePathModule.cs"
            int* csharp2cuda_temp_9 = &(bit);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
        }
    }
#line 170 "SequencePathModule.cs"
    {
#line 170 "SequencePathModule.cs"
        int index = thread;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 171 "SequencePathModule.cs"
#line 171 "SequencePathModule.cs"
            int csharp2cuda_temp_36 = (source_indexes)[index];
#line 171 "SequencePathModule.cs"
            int* csharp2cuda_temp_37 = &((ranks)[csharp2cuda_temp_36]);
            (*(csharp2cuda_temp_37) = index);
#line 170 "SequencePathModule.cs"
            int* csharp2cuda_temp_34 = &(index);
#line 170 "SequencePathModule.cs"
            int csharp2cuda_temp_35 = *(csharp2cuda_temp_34);
            (*(csharp2cuda_temp_34) = csharp2cuda_i32_add(csharp2cuda_temp_35, blockDim.x));
        }
    }
#line 172 "SequencePathModule.cs"
    __syncthreads();
#line 173 "SequencePathModule.cs"
    if (((thread) == (0)))
    {
#line 174 "SequencePathModule.cs"
#line 174 "SequencePathModule.cs"
        int* csharp2cuda_temp_38 = &((output)->columns);
        (*(csharp2cuda_temp_38) = 0);
    }
#line 175 "SequencePathModule.cs"
    __syncthreads();
}

#line 329 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rebalance_heaps(
    int* lower_heap,
    int* lower_count,
    int* upper_heap,
    int* upper_count,
    int target_lower_count,
    int* positions,
    int* kinds,
    const int* ranks)
#line 339 "SequencePathModule.cs"
{
#line 340 "SequencePathModule.cs"
    while (true)
    {
#line 340 "SequencePathModule.cs"
        int csharp2cuda_temp_0 = *(lower_count);
        if (!(((csharp2cuda_temp_0) > (target_lower_count))))
            break;
#line 341 "SequencePathModule.cs"
        {
#line 342 "SequencePathModule.cs"
            int item = (lower_heap)[0];
#line 343 "SequencePathModule.cs"
            mathblocks_sequence_heap_remove(lower_heap, lower_count, item, positions, kinds, ranks, true);
#line 351 "SequencePathModule.cs"
            mathblocks_sequence_heap_insert(upper_heap, upper_count, item, 1, positions, kinds, ranks, false);
        }
    }
#line 361 "SequencePathModule.cs"
    while (true)
    {
#line 361 "SequencePathModule.cs"
        int csharp2cuda_temp_1 = *(lower_count);
        if (!(((csharp2cuda_temp_1) < (target_lower_count))))
            break;
#line 362 "SequencePathModule.cs"
        {
#line 363 "SequencePathModule.cs"
            int item = (upper_heap)[0];
#line 364 "SequencePathModule.cs"
            mathblocks_sequence_heap_remove(upper_heap, upper_count, item, positions, kinds, ranks, false);
#line 372 "SequencePathModule.cs"
            mathblocks_sequence_heap_insert(lower_heap, lower_count, item, 0, positions, kinds, ranks, true);
        }
    }
}

#line 509 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_recurrence_value(
    const double* values,
    int count,
    double threshold,
    double* value)
#line 515 "SequencePathModule.cs"
{
#line 516 "SequencePathModule.cs"
#line 516 "SequencePathModule.cs"
    bool csharp2cuda_temp_0;
#line 516 "SequencePathModule.cs"
    if (!(((count) <= (0))))
    {
#line 516 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((threshold) < (0.0));
    }
    else
    {
#line 516 "SequencePathModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 517 "SequencePathModule.cs"
        return false;
    }
#line 518 "SequencePathModule.cs"
    long long recurrent = ((long long)(0));
#line 519 "SequencePathModule.cs"
    long long total = csharp2cuda_i64_mul(((long long)(count)), ((long long)(count)));
#line 520 "SequencePathModule.cs"
    {
#line 520 "SequencePathModule.cs"
        int left = 0;
        while (true)
        {
            if (!(((left) < (count))))
                break;
#line 521 "SequencePathModule.cs"
            {
#line 521 "SequencePathModule.cs"
                int right = 0;
                while (true)
                {
                    if (!(((right) < (count))))
                        break;
#line 522 "SequencePathModule.cs"
#line 522 "SequencePathModule.cs"
                    double csharp2cuda_temp_3 = (values)[left];
#line 522 "SequencePathModule.cs"
                    double csharp2cuda_temp_4 = (values)[right];
                    if (((fabs(__dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4))) <= (threshold)))
                    {
#line 523 "SequencePathModule.cs"
#line 523 "SequencePathModule.cs"
                        long long* csharp2cuda_temp_5 = &(recurrent);
                        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_5));
                    }
#line 521 "SequencePathModule.cs"
                    int* csharp2cuda_temp_2 = &(right);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                }
            }
#line 520 "SequencePathModule.cs"
            int* csharp2cuda_temp_1 = &(left);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 524 "SequencePathModule.cs"
#line 524 "SequencePathModule.cs"
    double* csharp2cuda_temp_6 = value;
#line 524 "SequencePathModule.cs"
    double csharp2cuda_temp_7 = __ddiv_rn(((double)(recurrent)), ((double)(total)));
    (*(csharp2cuda_temp_6) = csharp2cuda_temp_7);
#line 525 "SequencePathModule.cs"
    return true;
}

#line 384 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_extreme(
    const double* values,
    int count,
    int width,
    double* result,
    int* deque,
    bool minimum)
#line 392 "SequencePathModule.cs"
{
#line 393 "SequencePathModule.cs"
    int head = 0;
#line 394 "SequencePathModule.cs"
    int tail = 0;
#line 395 "SequencePathModule.cs"
    {
#line 395 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 396 "SequencePathModule.cs"
            {
#line 397 "SequencePathModule.cs"
                while (true)
                {
#line 397 "SequencePathModule.cs"
                    bool csharp2cuda_temp_1;
#line 397 "SequencePathModule.cs"
                    if (((head) < (tail)))
                    {
#line 397 "SequencePathModule.cs"
                        int csharp2cuda_temp_2 = (deque)[head];
#line 397 "SequencePathModule.cs"
                        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) <= (csharp2cuda_i32_sub(index, width)));
                    }
                    else
                    {
#line 397 "SequencePathModule.cs"
                        csharp2cuda_temp_1 = false;
                    }
                    if (!(csharp2cuda_temp_1))
                        break;
#line 398 "SequencePathModule.cs"
#line 398 "SequencePathModule.cs"
                    int* csharp2cuda_temp_3 = &(head);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
                }
#line 399 "SequencePathModule.cs"
                while (true)
                {
#line 399 "SequencePathModule.cs"
                    bool csharp2cuda_temp_4;
#line 399 "SequencePathModule.cs"
                    if (((head) < (tail)))
                    {
#line 399 "SequencePathModule.cs"
                        bool csharp2cuda_temp_5;
#line 399 "SequencePathModule.cs"
                        if (minimum)
                        {
#line 400 "SequencePathModule.cs"
                            int csharp2cuda_temp_6 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 400 "SequencePathModule.cs"
                            double csharp2cuda_temp_7 = (values)[csharp2cuda_temp_6];
#line 400 "SequencePathModule.cs"
                            double csharp2cuda_temp_8 = (values)[index];
#line 399 "SequencePathModule.cs"
                            csharp2cuda_temp_5 = ((csharp2cuda_temp_7) > (csharp2cuda_temp_8));
                        }
                        else
                        {
#line 401 "SequencePathModule.cs"
                            int csharp2cuda_temp_9 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 401 "SequencePathModule.cs"
                            double csharp2cuda_temp_10 = (values)[csharp2cuda_temp_9];
#line 401 "SequencePathModule.cs"
                            double csharp2cuda_temp_11 = (values)[index];
#line 399 "SequencePathModule.cs"
                            csharp2cuda_temp_5 = ((csharp2cuda_temp_10) < (csharp2cuda_temp_11));
                        }
#line 399 "SequencePathModule.cs"
                        csharp2cuda_temp_4 = csharp2cuda_temp_5;
                    }
                    else
                    {
#line 399 "SequencePathModule.cs"
                        csharp2cuda_temp_4 = false;
                    }
                    if (!(csharp2cuda_temp_4))
                        break;
#line 402 "SequencePathModule.cs"
                    {
#line 403 "SequencePathModule.cs"
#line 403 "SequencePathModule.cs"
                        int* csharp2cuda_temp_12 = &(tail);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_12));
                    }
                }
#line 405 "SequencePathModule.cs"
#line 405 "SequencePathModule.cs"
                int* csharp2cuda_temp_13 = &(tail);
#line 405 "SequencePathModule.cs"
                int csharp2cuda_temp_14 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
#line 405 "SequencePathModule.cs"
                int* csharp2cuda_temp_15 = &((deque)[csharp2cuda_temp_14]);
                (*(csharp2cuda_temp_15) = index);
#line 406 "SequencePathModule.cs"
                if (((index) >= (csharp2cuda_i32_sub(width, 1))))
                {
#line 407 "SequencePathModule.cs"
#line 407 "SequencePathModule.cs"
                    double* csharp2cuda_temp_16 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_sub(index, width), 1)]);
#line 407 "SequencePathModule.cs"
                    int csharp2cuda_temp_17 = (deque)[head];
#line 407 "SequencePathModule.cs"
                    double csharp2cuda_temp_18 = (values)[csharp2cuda_temp_17];
                    (*(csharp2cuda_temp_16) = csharp2cuda_temp_18);
                }
            }
#line 395 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 411 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_sum(
    const double* values,
    int count,
    int width,
    double* result)
#line 417 "SequencePathModule.cs"
{
#line 418 "SequencePathModule.cs"
    double sum = 0.0;
#line 419 "SequencePathModule.cs"
    {
#line 419 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (width))))
                break;
#line 420 "SequencePathModule.cs"
#line 420 "SequencePathModule.cs"
            double* csharp2cuda_temp_1 = &(sum);
#line 420 "SequencePathModule.cs"
            double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
#line 420 "SequencePathModule.cs"
            double csharp2cuda_temp_3 = (values)[index];
            (*(csharp2cuda_temp_1) = __dadd_rn(csharp2cuda_temp_2, csharp2cuda_temp_3));
#line 419 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 421 "SequencePathModule.cs"
#line 421 "SequencePathModule.cs"
    double* csharp2cuda_temp_4 = &((result)[0]);
    (*(csharp2cuda_temp_4) = sum);
#line 422 "SequencePathModule.cs"
    {
#line 422 "SequencePathModule.cs"
        int index = width;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 423 "SequencePathModule.cs"
            {
#line 424 "SequencePathModule.cs"
#line 424 "SequencePathModule.cs"
                double* csharp2cuda_temp_6 = &(sum);
#line 424 "SequencePathModule.cs"
                double csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
#line 424 "SequencePathModule.cs"
                double csharp2cuda_temp_8 = (values)[index];
#line 424 "SequencePathModule.cs"
                double csharp2cuda_temp_9 = (values)[csharp2cuda_i32_sub(index, width)];
                (*(csharp2cuda_temp_6) = __dadd_rn(csharp2cuda_temp_7, __dsub_rn(csharp2cuda_temp_8, csharp2cuda_temp_9)));
#line 425 "SequencePathModule.cs"
#line 425 "SequencePathModule.cs"
                double* csharp2cuda_temp_10 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_sub(index, width), 1)]);
                (*(csharp2cuda_temp_10) = sum);
            }
#line 422 "SequencePathModule.cs"
            int* csharp2cuda_temp_5 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
        }
    }
}

#line 61 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_matrix_shape(
    MathBlockSlot* output,
    int rows,
    int columns)
#line 66 "SequencePathModule.cs"
{
#line 67 "SequencePathModule.cs"
    long long count = csharp2cuda_i64_mul(((long long)(rows)), ((long long)(columns)));
#line 68 "SequencePathModule.cs"
#line 68 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = &((output)->rows);
    (*(csharp2cuda_temp_0) = rows);
#line 69 "SequencePathModule.cs"
#line 69 "SequencePathModule.cs"
    int* csharp2cuda_temp_1 = &((output)->columns);
    (*(csharp2cuda_temp_1) = columns);
#line 70 "SequencePathModule.cs"
#line 70 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((output)->count);
#line 70 "SequencePathModule.cs"
    int csharp2cuda_temp_3;
#line 70 "SequencePathModule.cs"
    if (((count) > (2147483647LL)))
    {
#line 70 "SequencePathModule.cs"
        csharp2cuda_temp_3 = csharp2cuda_i32_neg(1);
    }
    else
    {
#line 70 "SequencePathModule.cs"
        csharp2cuda_temp_3 = csharp2cuda_i32_from_bits(count);
    }
    (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
#line 71 "SequencePathModule.cs"
#line 71 "SequencePathModule.cs"
    bool csharp2cuda_temp_4;
#line 71 "SequencePathModule.cs"
    if (!(((rows) < (0))))
    {
#line 71 "SequencePathModule.cs"
        csharp2cuda_temp_4 = ((columns) < (0));
    }
    else
    {
#line 71 "SequencePathModule.cs"
        csharp2cuda_temp_4 = true;
    }
#line 71 "SequencePathModule.cs"
    bool csharp2cuda_temp_5;
#line 71 "SequencePathModule.cs"
    if (!(csharp2cuda_temp_4))
    {
#line 71 "SequencePathModule.cs"
        int csharp2cuda_temp_6 = (output)->capacity;
#line 71 "SequencePathModule.cs"
        csharp2cuda_temp_5 = ((count) > (((long long)(csharp2cuda_temp_6))));
    }
    else
    {
#line 71 "SequencePathModule.cs"
        csharp2cuda_temp_5 = true;
    }
    if (csharp2cuda_temp_5)
#line 72 "SequencePathModule.cs"
    {
#line 73 "SequencePathModule.cs"
#line 73 "SequencePathModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
        (*(csharp2cuda_temp_7) = 0);
#line 74 "SequencePathModule.cs"
        return;
    }
}

#line 48 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_vector_shape(MathBlockSlot* output, int count)
#line 50 "SequencePathModule.cs"
{
#line 51 "SequencePathModule.cs"
#line 51 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = &((output)->rows);
    (*(csharp2cuda_temp_0) = count);
#line 52 "SequencePathModule.cs"
#line 52 "SequencePathModule.cs"
    int* csharp2cuda_temp_1 = &((output)->columns);
    (*(csharp2cuda_temp_1) = 0);
#line 53 "SequencePathModule.cs"
#line 53 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((output)->count);
    (*(csharp2cuda_temp_2) = count);
#line 54 "SequencePathModule.cs"
#line 54 "SequencePathModule.cs"
    bool csharp2cuda_temp_3;
#line 54 "SequencePathModule.cs"
    if (!(((count) < (0))))
    {
#line 54 "SequencePathModule.cs"
        int csharp2cuda_temp_4 = (output)->capacity;
#line 54 "SequencePathModule.cs"
        csharp2cuda_temp_3 = ((count) > (csharp2cuda_temp_4));
    }
    else
    {
#line 54 "SequencePathModule.cs"
        csharp2cuda_temp_3 = true;
    }
    if (csharp2cuda_temp_3)
#line 55 "SequencePathModule.cs"
    {
#line 56 "SequencePathModule.cs"
#line 56 "SequencePathModule.cs"
        int* csharp2cuda_temp_5 = &((output)->valid);
        (*(csharp2cuda_temp_5) = 0);
#line 57 "SequencePathModule.cs"
        return;
    }
}

#line 529 "SequencePathModule.cs"
__device__ double mathblocks_sequence_sign_change_value(
    const double* values,
    int count,
    bool differenced)
#line 534 "SequencePathModule.cs"
{
#line 535 "SequencePathModule.cs"
    int changes = 0;
#line 536 "SequencePathModule.cs"
    int previous = 0;
#line 537 "SequencePathModule.cs"
    int csharp2cuda_temp_0;
#line 537 "SequencePathModule.cs"
    if (differenced)
    {
#line 537 "SequencePathModule.cs"
        csharp2cuda_temp_0 = 1;
    }
    else
    {
#line 537 "SequencePathModule.cs"
        csharp2cuda_temp_0 = 0;
    }
#line 537 "SequencePathModule.cs"
    int start = csharp2cuda_temp_0;
#line 538 "SequencePathModule.cs"
    {
#line 538 "SequencePathModule.cs"
        int index = start;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 539 "SequencePathModule.cs"
            {
#line 540 "SequencePathModule.cs"
                double csharp2cuda_temp_2;
#line 540 "SequencePathModule.cs"
                if (differenced)
                {
#line 540 "SequencePathModule.cs"
                    double csharp2cuda_temp_3 = (values)[index];
#line 540 "SequencePathModule.cs"
                    double csharp2cuda_temp_4 = (values)[csharp2cuda_i32_sub(index, 1)];
#line 540 "SequencePathModule.cs"
                    csharp2cuda_temp_2 = __dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4);
                }
                else
                {
#line 540 "SequencePathModule.cs"
                    csharp2cuda_temp_2 = (values)[index];
                }
#line 540 "SequencePathModule.cs"
                double difference = csharp2cuda_temp_2;
#line 541 "SequencePathModule.cs"
                int csharp2cuda_temp_5;
#line 541 "SequencePathModule.cs"
                if (((difference) > (0.0)))
                {
#line 541 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = 1;
                }
                else
                {
#line 541 "SequencePathModule.cs"
                    int csharp2cuda_temp_6;
#line 541 "SequencePathModule.cs"
                    if (((difference) < (0.0)))
                    {
#line 541 "SequencePathModule.cs"
                        csharp2cuda_temp_6 = csharp2cuda_i32_neg(1);
                    }
                    else
                    {
#line 541 "SequencePathModule.cs"
                        csharp2cuda_temp_6 = 0;
                    }
#line 541 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = csharp2cuda_temp_6;
                }
#line 541 "SequencePathModule.cs"
                int current = csharp2cuda_temp_5;
#line 542 "SequencePathModule.cs"
                if (((current) == (0)))
                {
#line 543 "SequencePathModule.cs"
                    goto csharp2cuda_for_continue_0;
                }
#line 544 "SequencePathModule.cs"
#line 544 "SequencePathModule.cs"
                bool csharp2cuda_temp_7;
#line 544 "SequencePathModule.cs"
                if (((previous) != (0)))
                {
#line 544 "SequencePathModule.cs"
                    csharp2cuda_temp_7 = ((current) != (previous));
                }
                else
                {
#line 544 "SequencePathModule.cs"
                    csharp2cuda_temp_7 = false;
                }
                if (csharp2cuda_temp_7)
                {
#line 545 "SequencePathModule.cs"
#line 545 "SequencePathModule.cs"
                    int* csharp2cuda_temp_8 = &(changes);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_8));
                }
#line 546 "SequencePathModule.cs"
#line 546 "SequencePathModule.cs"
                int* csharp2cuda_temp_9 = &(previous);
                (*(csharp2cuda_temp_9) = current);
            }
            csharp2cuda_for_continue_0:
#line 538 "SequencePathModule.cs"
            int* csharp2cuda_temp_1 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 548 "SequencePathModule.cs"
    return ((double)(changes));
}

#line 487 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_variation_value(
    const double* values,
    int count,
    double order,
    bool absolute,
    double* value)
#line 494 "SequencePathModule.cs"
{
#line 495 "SequencePathModule.cs"
    if (((count) <= (0)))
    {
#line 496 "SequencePathModule.cs"
        return false;
    }
#line 497 "SequencePathModule.cs"
    if ((!(((order) > (0.0)))))
    {
#line 498 "SequencePathModule.cs"
        return false;
    }
#line 499 "SequencePathModule.cs"
    double total = 0.0;
#line 500 "SequencePathModule.cs"
    {
#line 500 "SequencePathModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 501 "SequencePathModule.cs"
            {
#line 502 "SequencePathModule.cs"
                double csharp2cuda_temp_1 = (values)[index];
#line 502 "SequencePathModule.cs"
                double csharp2cuda_temp_2 = (values)[csharp2cuda_i32_sub(index, 1)];
#line 502 "SequencePathModule.cs"
                double change = fabs(__dsub_rn(csharp2cuda_temp_1, csharp2cuda_temp_2));
#line 503 "SequencePathModule.cs"
#line 503 "SequencePathModule.cs"
                double* csharp2cuda_temp_3 = &(total);
#line 503 "SequencePathModule.cs"
                double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 503 "SequencePathModule.cs"
                double csharp2cuda_temp_5;
#line 503 "SequencePathModule.cs"
                if (absolute)
                {
#line 503 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = change;
                }
                else
                {
#line 503 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = mathblocks_power(change, order);
                }
                (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, csharp2cuda_temp_5));
            }
#line 500 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 505 "SequencePathModule.cs"
#line 505 "SequencePathModule.cs"
    double* csharp2cuda_temp_6 = value;
    (*(csharp2cuda_temp_6) = total);
#line 506 "SequencePathModule.cs"
    return isfinite(total);
}