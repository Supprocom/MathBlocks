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

#line 41 "SequencePathModule.cs"
struct MathBlockSequencePathRun
{
    int start;
    int length;
    double value;
};

#line 481 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_decline_value(
    const double* values,
    int count,
    bool relative,
    double* value);

#line 447 "SequencePathModule.cs"
__device__ double mathblocks_sequence_first_passage_value(
    const double* values,
    int count,
    double threshold,
    bool at_or_above);

#line 281 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_insert(
    int* heap,
    int* count,
    int item,
    int kind,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum);

#line 210 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_heap_precedes(
    int left,
    int right,
    const int* ranks,
    bool maximum);

#line 304 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_remove(
    int* heap,
    int* count,
    int item,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum);

#line 246 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_down(
    int* heap,
    int count,
    int position,
    int* positions,
    const int* ranks,
    bool maximum);

#line 222 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_up(
    int* heap,
    int position,
    int* positions,
    const int* ranks,
    bool maximum);

#line 196 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_swap(
    int* heap,
    int left,
    int right,
    int* positions);

#line 95 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_is_power_of_two(int value);

#line 466 "SequencePathModule.cs"
__device__ double mathblocks_sequence_longest_run_value(
    const int* values,
    int count);

#line 84 "SequencePathModule.cs"
__device__ unsigned long long mathblocks_sequence_order_key(double value);

#line 570 "SequencePathModule.cs"
__device__ void mathblocks_sequence_path_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 48 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_positive_integer(double value, int* result);

#line 101 "SequencePathModule.cs"
__device__ void mathblocks_sequence_prepare_order_ranks(
    const double* values,
    int count,
    unsigned char* scratch,
    MathBlockSlot* output);

#line 347 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rebalance_heaps(
    int* lower_heap,
    int* lower_count,
    int* upper_heap,
    int* upper_count,
    int target_lower_count,
    int* positions,
    int* kinds,
    const int* ranks);

#line 528 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_recurrence_value(
    const double* values,
    int count,
    double threshold,
    double* value);

#line 402 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_extreme(
    const double* values,
    int count,
    int width,
    double* result,
    int* deque,
    bool minimum);

#line 429 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_sum(
    const double* values,
    int count,
    int width,
    double* result);

#line 67 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_matrix_shape(
    MathBlockSlot* output,
    int rows,
    int columns);

#line 54 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_vector_shape(MathBlockSlot* output, int count);

#line 548 "SequencePathModule.cs"
__device__ double mathblocks_sequence_sign_change_value(
    const double* values,
    int count,
    bool differenced);

#line 506 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_variation_value(
    const double* values,
    int count,
    double order,
    bool absolute,
    double* value);

#line 481 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_decline_value(
    const double* values,
    int count,
    bool relative,
    double* value)
#line 487 "SequencePathModule.cs"
{
#line 488 "SequencePathModule.cs"
    if (((count) <= (0)))
    {
#line 489 "SequencePathModule.cs"
        return false;
    }
#line 490 "SequencePathModule.cs"
    double maximum = (values)[0];
#line 491 "SequencePathModule.cs"
    double decline = 0.0;
#line 492 "SequencePathModule.cs"
    {
#line 492 "SequencePathModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 493 "SequencePathModule.cs"
            {
#line 495 "SequencePathModule.cs"
#line 495 "SequencePathModule.cs"
                double* csharp2cuda_temp_1 = &(maximum);
#line 495 "SequencePathModule.cs"
                double csharp2cuda_temp_2 = (values)[index];
                (*(csharp2cuda_temp_1) = mathblocks_maximum(maximum, csharp2cuda_temp_2));
#line 496 "SequencePathModule.cs"
                double csharp2cuda_temp_3;
#line 496 "SequencePathModule.cs"
                if ((!(relative)))
                {
#line 497 "SequencePathModule.cs"
                    double csharp2cuda_temp_4 = (values)[index];
#line 496 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = __dsub_rn(maximum, csharp2cuda_temp_4);
                }
                else
                {
#line 498 "SequencePathModule.cs"
                    double csharp2cuda_temp_5 = (values)[index];
#line 496 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = __ddiv_rn(__dsub_rn(maximum, csharp2cuda_temp_5), maximum);
                }
#line 496 "SequencePathModule.cs"
                double candidate = csharp2cuda_temp_3;
#line 499 "SequencePathModule.cs"
#line 499 "SequencePathModule.cs"
                double* csharp2cuda_temp_6 = &(decline);
                (*(csharp2cuda_temp_6) = mathblocks_maximum(decline, candidate));
            }
#line 492 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 501 "SequencePathModule.cs"
#line 501 "SequencePathModule.cs"
    double* csharp2cuda_temp_7 = value;
    (*(csharp2cuda_temp_7) = decline);
#line 502 "SequencePathModule.cs"
    return isfinite(decline);
}

#line 447 "SequencePathModule.cs"
__device__ double mathblocks_sequence_first_passage_value(
    const double* values,
    int count,
    double threshold,
    bool at_or_above)
#line 453 "SequencePathModule.cs"
{
#line 454 "SequencePathModule.cs"
    int result_index = -1;
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
                bool csharp2cuda_temp_1;
#line 457 "SequencePathModule.cs"
                if (at_or_above)
                {
#line 457 "SequencePathModule.cs"
                    double csharp2cuda_temp_2 = (values)[index];
#line 457 "SequencePathModule.cs"
                    csharp2cuda_temp_1 = ((csharp2cuda_temp_2) >= (threshold));
                }
                else
                {
#line 457 "SequencePathModule.cs"
                    double csharp2cuda_temp_3 = (values)[index];
#line 457 "SequencePathModule.cs"
                    csharp2cuda_temp_1 = ((csharp2cuda_temp_3) <= (threshold));
                }
                if (csharp2cuda_temp_1)
#line 458 "SequencePathModule.cs"
                {
#line 459 "SequencePathModule.cs"
#line 459 "SequencePathModule.cs"
                    int* csharp2cuda_temp_4 = &(result_index);
                    (*(csharp2cuda_temp_4) = index);
#line 460 "SequencePathModule.cs"
                    break;
                }
            }
#line 455 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 463 "SequencePathModule.cs"
    return ((double)(result_index));
}

#line 281 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_insert(
    int* heap,
    int* count,
    int item,
    int kind,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum)
#line 291 "SequencePathModule.cs"
{
#line 292 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = count;
#line 292 "SequencePathModule.cs"
    int position = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
#line 293 "SequencePathModule.cs"
#line 293 "SequencePathModule.cs"
    int* csharp2cuda_temp_1 = &((heap)[position]);
    (*(csharp2cuda_temp_1) = item);
#line 294 "SequencePathModule.cs"
#line 294 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((positions)[item]);
    (*(csharp2cuda_temp_2) = position);
#line 295 "SequencePathModule.cs"
#line 295 "SequencePathModule.cs"
    int* csharp2cuda_temp_3 = &((kinds)[item]);
    (*(csharp2cuda_temp_3) = kind);
#line 296 "SequencePathModule.cs"
    mathblocks_sequence_heap_sift_up(heap, position, positions, ranks, maximum);
}

#line 210 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_heap_precedes(
    int left,
    int right,
    const int* ranks,
    bool maximum)
#line 216 "SequencePathModule.cs"
{
#line 217 "SequencePathModule.cs"
#line 217 "SequencePathModule.cs"
    bool csharp2cuda_temp_0;
#line 217 "SequencePathModule.cs"
    if (maximum)
    {
#line 218 "SequencePathModule.cs"
        int csharp2cuda_temp_1 = (ranks)[left];
#line 218 "SequencePathModule.cs"
        int csharp2cuda_temp_2 = (ranks)[right];
#line 217 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_temp_1) > (csharp2cuda_temp_2));
    }
    else
    {
#line 219 "SequencePathModule.cs"
        int csharp2cuda_temp_3 = (ranks)[left];
#line 219 "SequencePathModule.cs"
        int csharp2cuda_temp_4 = (ranks)[right];
#line 217 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_temp_3) < (csharp2cuda_temp_4));
    }
    return csharp2cuda_temp_0;
}

#line 304 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_remove(
    int* heap,
    int* count,
    int item,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum)
#line 313 "SequencePathModule.cs"
{
#line 314 "SequencePathModule.cs"
    int position = (positions)[item];
#line 315 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = count;
#line 315 "SequencePathModule.cs"
    int csharp2cuda_temp_1 = csharp2cuda_i32_pre_decrement(*(csharp2cuda_temp_0));
#line 315 "SequencePathModule.cs"
    int replacement = (heap)[csharp2cuda_temp_1];
#line 316 "SequencePathModule.cs"
#line 316 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((kinds)[item]);
    (*(csharp2cuda_temp_2) = csharp2cuda_i32_neg(1));
#line 317 "SequencePathModule.cs"
#line 317 "SequencePathModule.cs"
    int* csharp2cuda_temp_3 = &((positions)[item]);
    (*(csharp2cuda_temp_3) = csharp2cuda_i32_neg(1));
#line 318 "SequencePathModule.cs"
#line 318 "SequencePathModule.cs"
    int csharp2cuda_temp_4 = *(count);
    if (((position) >= (csharp2cuda_temp_4)))
    {
#line 319 "SequencePathModule.cs"
        return;
    }
#line 320 "SequencePathModule.cs"
#line 320 "SequencePathModule.cs"
    int* csharp2cuda_temp_5 = &((heap)[position]);
    (*(csharp2cuda_temp_5) = replacement);
#line 321 "SequencePathModule.cs"
#line 321 "SequencePathModule.cs"
    int* csharp2cuda_temp_6 = &((positions)[replacement]);
    (*(csharp2cuda_temp_6) = position);
#line 322 "SequencePathModule.cs"
#line 322 "SequencePathModule.cs"
    bool csharp2cuda_temp_7;
#line 322 "SequencePathModule.cs"
    if (((position) > (0)))
    {
#line 323 "SequencePathModule.cs"
        int csharp2cuda_temp_8 = (heap)[position];
#line 324 "SequencePathModule.cs"
        int csharp2cuda_temp_9 = (heap)[csharp2cuda_i32_shr(csharp2cuda_i32_sub(position, 1), 1)];
#line 322 "SequencePathModule.cs"
        csharp2cuda_temp_7 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_8, csharp2cuda_temp_9, ranks, maximum);
    }
    else
    {
#line 322 "SequencePathModule.cs"
        csharp2cuda_temp_7 = false;
    }
    if (csharp2cuda_temp_7)
#line 327 "SequencePathModule.cs"
    {
#line 328 "SequencePathModule.cs"
        mathblocks_sequence_heap_sift_up(heap, position, positions, ranks, maximum);
    }
    else
#line 336 "SequencePathModule.cs"
    {
#line 337 "SequencePathModule.cs"
#line 339 "SequencePathModule.cs"
        int csharp2cuda_temp_10 = *(count);
        mathblocks_sequence_heap_sift_down(heap, csharp2cuda_temp_10, position, positions, ranks, maximum);
    }
}

#line 246 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_down(
    int* heap,
    int count,
    int position,
    int* positions,
    const int* ranks,
    bool maximum)
#line 254 "SequencePathModule.cs"
{
#line 255 "SequencePathModule.cs"
    while (true)
    {
        if (!(true))
            break;
#line 256 "SequencePathModule.cs"
        {
#line 257 "SequencePathModule.cs"
            int left = csharp2cuda_i32_add(csharp2cuda_i32_mul(position, 2), 1);
#line 258 "SequencePathModule.cs"
            if (((left) >= (count)))
            {
#line 259 "SequencePathModule.cs"
                return;
            }
#line 260 "SequencePathModule.cs"
            int right = csharp2cuda_i32_add(left, 1);
#line 261 "SequencePathModule.cs"
            bool csharp2cuda_temp_0;
#line 261 "SequencePathModule.cs"
            if (((right) < (count)))
            {
#line 262 "SequencePathModule.cs"
                int csharp2cuda_temp_1 = (heap)[right];
#line 263 "SequencePathModule.cs"
                int csharp2cuda_temp_2 = (heap)[left];
#line 261 "SequencePathModule.cs"
                csharp2cuda_temp_0 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_1, csharp2cuda_temp_2, ranks, maximum);
            }
            else
            {
#line 261 "SequencePathModule.cs"
                csharp2cuda_temp_0 = false;
            }
#line 261 "SequencePathModule.cs"
            int csharp2cuda_temp_3;
#line 261 "SequencePathModule.cs"
            if (csharp2cuda_temp_0)
            {
#line 261 "SequencePathModule.cs"
                csharp2cuda_temp_3 = right;
            }
            else
            {
#line 261 "SequencePathModule.cs"
                csharp2cuda_temp_3 = left;
            }
#line 261 "SequencePathModule.cs"
            int selected = csharp2cuda_temp_3;
#line 268 "SequencePathModule.cs"
#line 269 "SequencePathModule.cs"
            int csharp2cuda_temp_4 = (heap)[selected];
#line 270 "SequencePathModule.cs"
            int csharp2cuda_temp_5 = (heap)[position];
#line 268 "SequencePathModule.cs"
            bool csharp2cuda_temp_6 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_4, csharp2cuda_temp_5, ranks, maximum);
            if ((!(csharp2cuda_temp_6)))
#line 273 "SequencePathModule.cs"
            {
#line 274 "SequencePathModule.cs"
                return;
            }
#line 276 "SequencePathModule.cs"
            mathblocks_sequence_heap_swap(heap, position, selected, positions);
#line 277 "SequencePathModule.cs"
#line 277 "SequencePathModule.cs"
            int* csharp2cuda_temp_7 = &(position);
            (*(csharp2cuda_temp_7) = selected);
        }
    }
}

#line 222 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_up(
    int* heap,
    int position,
    int* positions,
    const int* ranks,
    bool maximum)
#line 229 "SequencePathModule.cs"
{
#line 230 "SequencePathModule.cs"
    while (true)
    {
        if (!(((position) > (0))))
            break;
#line 231 "SequencePathModule.cs"
        {
#line 232 "SequencePathModule.cs"
            int parent = csharp2cuda_i32_shr(csharp2cuda_i32_sub(position, 1), 1);
#line 233 "SequencePathModule.cs"
#line 234 "SequencePathModule.cs"
            int csharp2cuda_temp_0 = (heap)[position];
#line 235 "SequencePathModule.cs"
            int csharp2cuda_temp_1 = (heap)[parent];
#line 233 "SequencePathModule.cs"
            bool csharp2cuda_temp_2 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_0, csharp2cuda_temp_1, ranks, maximum);
            if ((!(csharp2cuda_temp_2)))
#line 238 "SequencePathModule.cs"
            {
#line 239 "SequencePathModule.cs"
                break;
            }
#line 241 "SequencePathModule.cs"
            mathblocks_sequence_heap_swap(heap, position, parent, positions);
#line 242 "SequencePathModule.cs"
#line 242 "SequencePathModule.cs"
            int* csharp2cuda_temp_3 = &(position);
            (*(csharp2cuda_temp_3) = parent);
        }
    }
}

#line 196 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_swap(
    int* heap,
    int left,
    int right,
    int* positions)
#line 202 "SequencePathModule.cs"
{
#line 203 "SequencePathModule.cs"
    int value = (heap)[left];
#line 204 "SequencePathModule.cs"
#line 204 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = &((heap)[left]);
#line 204 "SequencePathModule.cs"
    int csharp2cuda_temp_1 = (heap)[right];
    (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
#line 205 "SequencePathModule.cs"
#line 205 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((heap)[right]);
    (*(csharp2cuda_temp_2) = value);
#line 206 "SequencePathModule.cs"
#line 206 "SequencePathModule.cs"
    int csharp2cuda_temp_3 = (heap)[left];
#line 206 "SequencePathModule.cs"
    int* csharp2cuda_temp_4 = &((positions)[csharp2cuda_temp_3]);
    (*(csharp2cuda_temp_4) = left);
#line 207 "SequencePathModule.cs"
#line 207 "SequencePathModule.cs"
    int csharp2cuda_temp_5 = (heap)[right];
#line 207 "SequencePathModule.cs"
    int* csharp2cuda_temp_6 = &((positions)[csharp2cuda_temp_5]);
    (*(csharp2cuda_temp_6) = right);
}

#line 95 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_is_power_of_two(int value)
#line 97 "SequencePathModule.cs"
{
#line 98 "SequencePathModule.cs"
#line 98 "SequencePathModule.cs"
    bool csharp2cuda_temp_0;
#line 98 "SequencePathModule.cs"
    if (((value) > (0)))
    {
#line 98 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_i32_and(value, csharp2cuda_i32_sub(value, 1))) == (0));
    }
    else
    {
#line 98 "SequencePathModule.cs"
        csharp2cuda_temp_0 = false;
    }
    return csharp2cuda_temp_0;
}

#line 466 "SequencePathModule.cs"
__device__ double mathblocks_sequence_longest_run_value(
    const int* values,
    int count)
#line 470 "SequencePathModule.cs"
{
#line 471 "SequencePathModule.cs"
    int maximum = 0;
#line 472 "SequencePathModule.cs"
    int current = 0;
#line 473 "SequencePathModule.cs"
    {
#line 473 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 474 "SequencePathModule.cs"
            {
#line 475 "SequencePathModule.cs"
#line 475 "SequencePathModule.cs"
                int* csharp2cuda_temp_1 = &(current);
#line 475 "SequencePathModule.cs"
                bool csharp2cuda_temp_2 = (values)[index];
#line 475 "SequencePathModule.cs"
                int csharp2cuda_temp_3;
#line 475 "SequencePathModule.cs"
                if (csharp2cuda_temp_2)
                {
#line 475 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = csharp2cuda_i32_add(current, 1);
                }
                else
                {
#line 475 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = 0;
                }
                (*(csharp2cuda_temp_1) = csharp2cuda_temp_3);
#line 476 "SequencePathModule.cs"
#line 476 "SequencePathModule.cs"
                int* csharp2cuda_temp_4 = &(maximum);
#line 476 "SequencePathModule.cs"
                int csharp2cuda_temp_5;
#line 476 "SequencePathModule.cs"
                if (((maximum) > (current)))
                {
#line 476 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = maximum;
                }
                else
                {
#line 476 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = current;
                }
                (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
            }
#line 473 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 478 "SequencePathModule.cs"
    return ((double)(maximum));
}

#line 84 "SequencePathModule.cs"
__device__ unsigned long long mathblocks_sequence_order_key(double value)
#line 86 "SequencePathModule.cs"
{
#line 87 "SequencePathModule.cs"
    unsigned long long bits = ((unsigned long long)(__double_as_longlong(value)));
#line 88 "SequencePathModule.cs"
    if (((value) == (0.0)))
    {
#line 89 "SequencePathModule.cs"
#line 89 "SequencePathModule.cs"
        unsigned long long* csharp2cuda_temp_0 = &(bits);
        (*(csharp2cuda_temp_0) = 0ull);
    }
#line 90 "SequencePathModule.cs"
#line 90 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_1;
#line 90 "SequencePathModule.cs"
    if (((((bits) & (9223372036854775808ull))) != (0ull)))
    {
#line 90 "SequencePathModule.cs"
        csharp2cuda_temp_1 = (~(bits));
    }
    else
    {
#line 90 "SequencePathModule.cs"
        csharp2cuda_temp_1 = ((bits) ^ (9223372036854775808ull));
    }
    return csharp2cuda_temp_1;
}

#line 570 "SequencePathModule.cs"
__device__ void mathblocks_sequence_path_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 576 "SequencePathModule.cs"
{
#line 577 "SequencePathModule.cs"
    int thread = threadIdx.x;
#line 578 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 578 "SequencePathModule.cs"
    if (((input_count) > (0)))
    {
#line 578 "SequencePathModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 578 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 578 "SequencePathModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 579 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 579 "SequencePathModule.cs"
    if (((input_count) > (1)))
    {
#line 579 "SequencePathModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 579 "SequencePathModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 579 "SequencePathModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 580 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 580 "SequencePathModule.cs"
    if (((input_count) > (2)))
    {
#line 580 "SequencePathModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 580 "SequencePathModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 580 "SequencePathModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 581 "SequencePathModule.cs"
    if (((thread) == (0)))
#line 582 "SequencePathModule.cs"
    {
#line 583 "SequencePathModule.cs"
#line 583 "SequencePathModule.cs"
        double* csharp2cuda_temp_3 = &((output)->scalar_value);
        (*(csharp2cuda_temp_3) = 0.0);
#line 584 "SequencePathModule.cs"
#line 584 "SequencePathModule.cs"
        int* csharp2cuda_temp_4 = &((output)->boolean_value);
        (*(csharp2cuda_temp_4) = 0);
#line 585 "SequencePathModule.cs"
#line 585 "SequencePathModule.cs"
        int* csharp2cuda_temp_5 = &((output)->rows);
        (*(csharp2cuda_temp_5) = 0);
#line 586 "SequencePathModule.cs"
#line 586 "SequencePathModule.cs"
        int* csharp2cuda_temp_6 = &((output)->columns);
        (*(csharp2cuda_temp_6) = 0);
#line 587 "SequencePathModule.cs"
#line 587 "SequencePathModule.cs"
        int* csharp2cuda_temp_7 = &((output)->count);
        (*(csharp2cuda_temp_7) = 0);
#line 588 "SequencePathModule.cs"
#line 588 "SequencePathModule.cs"
        int* csharp2cuda_temp_8 = &((output)->valid);
#line 588 "SequencePathModule.cs"
        bool csharp2cuda_temp_9;
#line 588 "SequencePathModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 588 "SequencePathModule.cs"
            csharp2cuda_temp_9 = (first)->valid;
        }
        else
        {
#line 588 "SequencePathModule.cs"
            csharp2cuda_temp_9 = true;
        }
        (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
#line 589 "SequencePathModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 590 "SequencePathModule.cs"
#line 590 "SequencePathModule.cs"
            int* csharp2cuda_temp_10 = &((output)->valid);
#line 590 "SequencePathModule.cs"
            bool csharp2cuda_temp_11 = (output)->valid;
#line 590 "SequencePathModule.cs"
            bool csharp2cuda_temp_12;
#line 590 "SequencePathModule.cs"
            if (csharp2cuda_temp_11)
            {
#line 590 "SequencePathModule.cs"
                csharp2cuda_temp_12 = (second)->valid;
            }
            else
            {
#line 590 "SequencePathModule.cs"
                csharp2cuda_temp_12 = false;
            }
            (*(csharp2cuda_temp_10) = csharp2cuda_temp_12);
        }
#line 591 "SequencePathModule.cs"
        if (((((void*)(third))) != (((void*)(nullptr)))))
        {
#line 592 "SequencePathModule.cs"
#line 592 "SequencePathModule.cs"
            int* csharp2cuda_temp_13 = &((output)->valid);
#line 592 "SequencePathModule.cs"
            bool csharp2cuda_temp_14 = (output)->valid;
#line 592 "SequencePathModule.cs"
            bool csharp2cuda_temp_15;
#line 592 "SequencePathModule.cs"
            if (csharp2cuda_temp_14)
            {
#line 592 "SequencePathModule.cs"
                csharp2cuda_temp_15 = (third)->valid;
            }
            else
            {
#line 592 "SequencePathModule.cs"
                csharp2cuda_temp_15 = false;
            }
            (*(csharp2cuda_temp_13) = csharp2cuda_temp_15);
        }
    }
#line 594 "SequencePathModule.cs"
    __syncthreads();
#line 595 "SequencePathModule.cs"
#line 595 "SequencePathModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 596 "SequencePathModule.cs"
        return;
    }
#line 598 "SequencePathModule.cs"
    double* csharp2cuda_temp_17;
#line 598 "SequencePathModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 598 "SequencePathModule.cs"
        csharp2cuda_temp_17 = ((double*)(nullptr));
    }
    else
    {
#line 598 "SequencePathModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 598 "SequencePathModule.cs"
        csharp2cuda_temp_17 = ((double*)(csharp2cuda_temp_18));
    }
#line 598 "SequencePathModule.cs"
    const double* a = csharp2cuda_temp_17;
#line 599 "SequencePathModule.cs"
    double* csharp2cuda_temp_19;
#line 599 "SequencePathModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 599 "SequencePathModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 599 "SequencePathModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 599 "SequencePathModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 599 "SequencePathModule.cs"
    const double* b = csharp2cuda_temp_19;
#line 600 "SequencePathModule.cs"
    int* csharp2cuda_temp_21;
#line 600 "SequencePathModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 600 "SequencePathModule.cs"
        csharp2cuda_temp_21 = ((int*)(nullptr));
    }
    else
    {
#line 600 "SequencePathModule.cs"
        unsigned long long csharp2cuda_temp_22 = (first)->data_pointer;
#line 600 "SequencePathModule.cs"
        csharp2cuda_temp_21 = ((int*)(csharp2cuda_temp_22));
    }
#line 600 "SequencePathModule.cs"
    const int* boolean_a = csharp2cuda_temp_21;
#line 601 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_23 = (output)->data_pointer;
#line 601 "SequencePathModule.cs"
    double* result = ((double*)(csharp2cuda_temp_23));
#line 602 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_24 = (output)->scratch_pointer;
#line 602 "SequencePathModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_24));
#line 608 "SequencePathModule.cs"
    if (((opcode) == (0)))
#line 609 "SequencePathModule.cs"
    {
#line 610 "SequencePathModule.cs"
        int csharp2cuda_temp_25 = (first)->count;
#line 610 "SequencePathModule.cs"
        int csharp2cuda_temp_26 = (second)->count;
#line 610 "SequencePathModule.cs"
        int convolution_count = csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_temp_25, csharp2cuda_temp_26), 1);
#line 611 "SequencePathModule.cs"
#line 611 "SequencePathModule.cs"
        int csharp2cuda_temp_27 = (first)->count;
#line 611 "SequencePathModule.cs"
        bool csharp2cuda_temp_28;
#line 611 "SequencePathModule.cs"
        if (((csharp2cuda_temp_27) > (0)))
        {
#line 611 "SequencePathModule.cs"
            int csharp2cuda_temp_29 = (second)->count;
#line 611 "SequencePathModule.cs"
            csharp2cuda_temp_28 = ((csharp2cuda_temp_29) > (0));
        }
        else
        {
#line 611 "SequencePathModule.cs"
            csharp2cuda_temp_28 = false;
        }
#line 611 "SequencePathModule.cs"
        bool csharp2cuda_temp_30;
#line 611 "SequencePathModule.cs"
        if (csharp2cuda_temp_28)
        {
#line 611 "SequencePathModule.cs"
            int csharp2cuda_temp_31 = (output)->capacity;
#line 611 "SequencePathModule.cs"
            csharp2cuda_temp_30 = ((convolution_count) <= (csharp2cuda_temp_31));
        }
        else
        {
#line 611 "SequencePathModule.cs"
            csharp2cuda_temp_30 = false;
        }
        if (csharp2cuda_temp_30)
#line 612 "SequencePathModule.cs"
        {
#line 613 "SequencePathModule.cs"
            {
#line 613 "SequencePathModule.cs"
                int output_index = thread;
                while (true)
                {
                    if (!(((output_index) < (convolution_count))))
                        break;
#line 614 "SequencePathModule.cs"
                    {
#line 615 "SequencePathModule.cs"
                        int csharp2cuda_temp_34 = (second)->count;
#line 615 "SequencePathModule.cs"
                        int low = csharp2cuda_i32_sub(output_index, csharp2cuda_i32_sub(csharp2cuda_temp_34, 1));
#line 616 "SequencePathModule.cs"
                        int csharp2cuda_temp_35;
#line 616 "SequencePathModule.cs"
                        if (((low) > (0)))
                        {
#line 616 "SequencePathModule.cs"
                            csharp2cuda_temp_35 = low;
                        }
                        else
                        {
#line 616 "SequencePathModule.cs"
                            csharp2cuda_temp_35 = 0;
                        }
#line 616 "SequencePathModule.cs"
                        int left_start = csharp2cuda_temp_35;
#line 617 "SequencePathModule.cs"
                        int csharp2cuda_temp_36 = (first)->count;
#line 617 "SequencePathModule.cs"
                        int csharp2cuda_temp_37;
#line 617 "SequencePathModule.cs"
                        if (((output_index) < (csharp2cuda_i32_sub(csharp2cuda_temp_36, 1))))
                        {
#line 617 "SequencePathModule.cs"
                            csharp2cuda_temp_37 = output_index;
                        }
                        else
                        {
#line 617 "SequencePathModule.cs"
                            int csharp2cuda_temp_38 = (first)->count;
#line 617 "SequencePathModule.cs"
                            csharp2cuda_temp_37 = csharp2cuda_i32_sub(csharp2cuda_temp_38, 1);
                        }
#line 617 "SequencePathModule.cs"
                        int left_end = csharp2cuda_temp_37;
#line 618 "SequencePathModule.cs"
                        double sum = 0.0;
#line 619 "SequencePathModule.cs"
                        {
#line 619 "SequencePathModule.cs"
                            int left = left_start;
                            while (true)
                            {
                                if (!(((left) <= (left_end))))
                                    break;
#line 620 "SequencePathModule.cs"
#line 620 "SequencePathModule.cs"
                                double* csharp2cuda_temp_40 = &(sum);
#line 620 "SequencePathModule.cs"
                                double csharp2cuda_temp_41 = *(csharp2cuda_temp_40);
#line 620 "SequencePathModule.cs"
                                double csharp2cuda_temp_42 = (a)[left];
#line 620 "SequencePathModule.cs"
                                double csharp2cuda_temp_43 = (b)[csharp2cuda_i32_sub(output_index, left)];
                                (*(csharp2cuda_temp_40) = __dadd_rn(csharp2cuda_temp_41, __dmul_rn(csharp2cuda_temp_42, csharp2cuda_temp_43)));
#line 619 "SequencePathModule.cs"
                                int* csharp2cuda_temp_39 = &(left);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_39));
                            }
                        }
#line 621 "SequencePathModule.cs"
#line 621 "SequencePathModule.cs"
                        double* csharp2cuda_temp_44 = &((result)[output_index]);
                        (*(csharp2cuda_temp_44) = sum);
                    }
#line 613 "SequencePathModule.cs"
                    int* csharp2cuda_temp_32 = &(output_index);
#line 613 "SequencePathModule.cs"
                    int csharp2cuda_temp_33 = *(csharp2cuda_temp_32);
                    (*(csharp2cuda_temp_32) = csharp2cuda_i32_add(csharp2cuda_temp_33, blockDim.x));
                }
            }
        }
#line 624 "SequencePathModule.cs"
        __syncthreads();
    }
#line 627 "SequencePathModule.cs"
    switch (opcode)
    {
#line 629 "SequencePathModule.cs"
        case 0:
#line 630 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 631 "SequencePathModule.cs"
            {
#line 632 "SequencePathModule.cs"
                int csharp2cuda_temp_45 = (first)->count;
#line 632 "SequencePathModule.cs"
                int csharp2cuda_temp_46 = (second)->count;
#line 632 "SequencePathModule.cs"
                int count = csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_temp_45, csharp2cuda_temp_46), 1);
#line 633 "SequencePathModule.cs"
                mathblocks_sequence_set_vector_shape(output, count);
#line 634 "SequencePathModule.cs"
#line 634 "SequencePathModule.cs"
                int csharp2cuda_temp_47 = (first)->count;
#line 634 "SequencePathModule.cs"
                bool csharp2cuda_temp_48;
#line 634 "SequencePathModule.cs"
                if (!(((csharp2cuda_temp_47) <= (0))))
                {
#line 634 "SequencePathModule.cs"
                    int csharp2cuda_temp_49 = (second)->count;
#line 634 "SequencePathModule.cs"
                    csharp2cuda_temp_48 = ((csharp2cuda_temp_49) <= (0));
                }
                else
                {
#line 634 "SequencePathModule.cs"
                    csharp2cuda_temp_48 = true;
                }
                if (csharp2cuda_temp_48)
                {
#line 635 "SequencePathModule.cs"
#line 635 "SequencePathModule.cs"
                    int* csharp2cuda_temp_50 = &((output)->valid);
                    (*(csharp2cuda_temp_50) = 0);
                }
#line 639 "SequencePathModule.cs"
                bool finite = true;
#line 640 "SequencePathModule.cs"
                {
#line 640 "SequencePathModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 640 "SequencePathModule.cs"
                        bool csharp2cuda_temp_52 = (output)->valid;
#line 640 "SequencePathModule.cs"
                        bool csharp2cuda_temp_53;
#line 640 "SequencePathModule.cs"
                        if (csharp2cuda_temp_52)
                        {
#line 640 "SequencePathModule.cs"
                            csharp2cuda_temp_53 = ((index) < (count));
                        }
                        else
                        {
#line 640 "SequencePathModule.cs"
                            csharp2cuda_temp_53 = false;
                        }
                        if (!(csharp2cuda_temp_53))
                            break;
#line 641 "SequencePathModule.cs"
#line 641 "SequencePathModule.cs"
                        double csharp2cuda_temp_54 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_54))))
                        {
#line 642 "SequencePathModule.cs"
#line 642 "SequencePathModule.cs"
                            bool* csharp2cuda_temp_55 = &(finite);
                            (*(csharp2cuda_temp_55) = false);
                        }
#line 640 "SequencePathModule.cs"
                        int* csharp2cuda_temp_51 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_51));
                    }
                }
#line 643 "SequencePathModule.cs"
                if (finite)
                {
#line 644 "SequencePathModule.cs"
                    break;
                }
#line 645 "SequencePathModule.cs"
                {
#line 645 "SequencePathModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 645 "SequencePathModule.cs"
                        bool csharp2cuda_temp_57 = (output)->valid;
#line 645 "SequencePathModule.cs"
                        bool csharp2cuda_temp_58;
#line 645 "SequencePathModule.cs"
                        if (csharp2cuda_temp_57)
                        {
#line 645 "SequencePathModule.cs"
                            csharp2cuda_temp_58 = ((index) < (count));
                        }
                        else
                        {
#line 645 "SequencePathModule.cs"
                            csharp2cuda_temp_58 = false;
                        }
                        if (!(csharp2cuda_temp_58))
                            break;
#line 646 "SequencePathModule.cs"
#line 646 "SequencePathModule.cs"
                        double* csharp2cuda_temp_59 = &((result)[index]);
                        (*(csharp2cuda_temp_59) = 0.0);
#line 645 "SequencePathModule.cs"
                        int* csharp2cuda_temp_56 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_56));
                    }
                }
#line 647 "SequencePathModule.cs"
                {
#line 647 "SequencePathModule.cs"
                    int left = 0;
                    while (true)
                    {
#line 647 "SequencePathModule.cs"
                        bool csharp2cuda_temp_61 = (output)->valid;
#line 647 "SequencePathModule.cs"
                        bool csharp2cuda_temp_62;
#line 647 "SequencePathModule.cs"
                        if (csharp2cuda_temp_61)
                        {
#line 647 "SequencePathModule.cs"
                            int csharp2cuda_temp_63 = (first)->count;
#line 647 "SequencePathModule.cs"
                            csharp2cuda_temp_62 = ((left) < (csharp2cuda_temp_63));
                        }
                        else
                        {
#line 647 "SequencePathModule.cs"
                            csharp2cuda_temp_62 = false;
                        }
                        if (!(csharp2cuda_temp_62))
                            break;
#line 648 "SequencePathModule.cs"
                        {
#line 649 "SequencePathModule.cs"
                            {
#line 649 "SequencePathModule.cs"
                                int right = 0;
                                while (true)
                                {
#line 649 "SequencePathModule.cs"
                                    int csharp2cuda_temp_65 = (second)->count;
                                    if (!(((right) < (csharp2cuda_temp_65))))
                                        break;
#line 650 "SequencePathModule.cs"
                                    {
#line 651 "SequencePathModule.cs"
#line 651 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_66 = &((result)[csharp2cuda_i32_add(left, right)]);
#line 651 "SequencePathModule.cs"
                                        double csharp2cuda_temp_67 = *(csharp2cuda_temp_66);
#line 651 "SequencePathModule.cs"
                                        double csharp2cuda_temp_68 = (a)[left];
#line 651 "SequencePathModule.cs"
                                        double csharp2cuda_temp_69 = (b)[right];
                                        (*(csharp2cuda_temp_66) = __dadd_rn(csharp2cuda_temp_67, __dmul_rn(csharp2cuda_temp_68, csharp2cuda_temp_69)));
#line 652 "SequencePathModule.cs"
#line 652 "SequencePathModule.cs"
                                        double csharp2cuda_temp_70 = (result)[csharp2cuda_i32_add(left, right)];
                                        if ((!(isfinite(csharp2cuda_temp_70))))
                                        {
#line 653 "SequencePathModule.cs"
#line 653 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_71 = &((output)->valid);
                                            (*(csharp2cuda_temp_71) = 0);
                                        }
                                    }
#line 649 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_64 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_64));
                                }
                            }
                        }
#line 647 "SequencePathModule.cs"
                        int* csharp2cuda_temp_60 = &(left);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_60));
                    }
                }
            }
#line 657 "SequencePathModule.cs"
            break;
#line 658 "SequencePathModule.cs"
        case 1:
#line 659 "SequencePathModule.cs"
            {
#line 660 "SequencePathModule.cs"
                int lag = 0;
#line 661 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 662 "SequencePathModule.cs"
                {
#line 663 "SequencePathModule.cs"
#line 663 "SequencePathModule.cs"
                    double csharp2cuda_temp_72 = (second)->scalar_value;
#line 663 "SequencePathModule.cs"
                    int* csharp2cuda_temp_73 = &(lag);
#line 663 "SequencePathModule.cs"
                    bool csharp2cuda_temp_74 = mathblocks_sequence_positive_integer(csharp2cuda_temp_72, csharp2cuda_temp_73);
#line 663 "SequencePathModule.cs"
                    bool csharp2cuda_temp_75;
#line 663 "SequencePathModule.cs"
                    if (!((!(csharp2cuda_temp_74))))
                    {
#line 663 "SequencePathModule.cs"
                        int csharp2cuda_temp_76 = (first)->count;
#line 663 "SequencePathModule.cs"
                        csharp2cuda_temp_75 = ((lag) >= (csharp2cuda_temp_76));
                    }
                    else
                    {
#line 663 "SequencePathModule.cs"
                        csharp2cuda_temp_75 = true;
                    }
                    if (csharp2cuda_temp_75)
                    {
#line 664 "SequencePathModule.cs"
#line 664 "SequencePathModule.cs"
                        int* csharp2cuda_temp_77 = &((output)->valid);
                        (*(csharp2cuda_temp_77) = 0);
                    }
                    else
                    {
#line 666 "SequencePathModule.cs"
#line 666 "SequencePathModule.cs"
                        int csharp2cuda_temp_78 = (first)->count;
                        mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_sub(csharp2cuda_temp_78, lag));
                    }
#line 667 "SequencePathModule.cs"
#line 667 "SequencePathModule.cs"
                    double* csharp2cuda_temp_79 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_79) = ((double)(lag)));
                }
#line 669 "SequencePathModule.cs"
                __syncthreads();
#line 670 "SequencePathModule.cs"
#line 670 "SequencePathModule.cs"
                int* csharp2cuda_temp_80 = &(lag);
#line 670 "SequencePathModule.cs"
                double csharp2cuda_temp_81 = (output)->scalar_value;
                (*(csharp2cuda_temp_80) = csharp2cuda_f64_to_i32(csharp2cuda_temp_81));
#line 671 "SequencePathModule.cs"
                {
#line 671 "SequencePathModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 671 "SequencePathModule.cs"
                        bool csharp2cuda_temp_84 = (output)->valid;
#line 671 "SequencePathModule.cs"
                        bool csharp2cuda_temp_85;
#line 671 "SequencePathModule.cs"
                        if (csharp2cuda_temp_84)
                        {
#line 671 "SequencePathModule.cs"
                            int csharp2cuda_temp_86 = (output)->count;
#line 671 "SequencePathModule.cs"
                            csharp2cuda_temp_85 = ((index) < (csharp2cuda_temp_86));
                        }
                        else
                        {
#line 671 "SequencePathModule.cs"
                            csharp2cuda_temp_85 = false;
                        }
                        if (!(csharp2cuda_temp_85))
                            break;
#line 672 "SequencePathModule.cs"
                        {
#line 673 "SequencePathModule.cs"
#line 673 "SequencePathModule.cs"
                            double* csharp2cuda_temp_87 = &((result)[index]);
#line 673 "SequencePathModule.cs"
                            double csharp2cuda_temp_88 = (a)[csharp2cuda_i32_add(index, lag)];
#line 673 "SequencePathModule.cs"
                            double csharp2cuda_temp_89 = (a)[index];
                            (*(csharp2cuda_temp_87) = __dsub_rn(csharp2cuda_temp_88, csharp2cuda_temp_89));
#line 674 "SequencePathModule.cs"
#line 674 "SequencePathModule.cs"
                            double csharp2cuda_temp_90 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_90))))
                            {
#line 674 "SequencePathModule.cs"
                                atomicExch(&((output)->valid), 0);
                            }
                        }
#line 671 "SequencePathModule.cs"
                        int* csharp2cuda_temp_82 = &(index);
#line 671 "SequencePathModule.cs"
                        int csharp2cuda_temp_83 = *(csharp2cuda_temp_82);
                        (*(csharp2cuda_temp_82) = csharp2cuda_i32_add(csharp2cuda_temp_83, blockDim.x));
                    }
                }
#line 676 "SequencePathModule.cs"
                break;
            }
#line 678 "SequencePathModule.cs"
        case 2:
#line 679 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 680 "SequencePathModule.cs"
            {
#line 681 "SequencePathModule.cs"
                double alpha = (second)->scalar_value;
#line 682 "SequencePathModule.cs"
#line 682 "SequencePathModule.cs"
                int csharp2cuda_temp_91 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_91);
#line 683 "SequencePathModule.cs"
#line 683 "SequencePathModule.cs"
                int csharp2cuda_temp_92 = (first)->count;
#line 683 "SequencePathModule.cs"
                bool csharp2cuda_temp_93;
#line 683 "SequencePathModule.cs"
                if (!(((csharp2cuda_temp_92) <= (0))))
                {
#line 683 "SequencePathModule.cs"
                    bool csharp2cuda_temp_94;
#line 683 "SequencePathModule.cs"
                    if (((alpha) > (0.0)))
                    {
#line 683 "SequencePathModule.cs"
                        csharp2cuda_temp_94 = ((alpha) <= (1.0));
                    }
                    else
                    {
#line 683 "SequencePathModule.cs"
                        csharp2cuda_temp_94 = false;
                    }
#line 683 "SequencePathModule.cs"
                    csharp2cuda_temp_93 = (!(csharp2cuda_temp_94));
                }
                else
                {
#line 683 "SequencePathModule.cs"
                    csharp2cuda_temp_93 = true;
                }
                if (csharp2cuda_temp_93)
                {
#line 684 "SequencePathModule.cs"
#line 684 "SequencePathModule.cs"
                    int* csharp2cuda_temp_95 = &((output)->valid);
                    (*(csharp2cuda_temp_95) = 0);
                }
#line 685 "SequencePathModule.cs"
                if ((output)->valid)
#line 686 "SequencePathModule.cs"
                {
#line 687 "SequencePathModule.cs"
#line 687 "SequencePathModule.cs"
                    double* csharp2cuda_temp_96 = &((result)[0]);
#line 687 "SequencePathModule.cs"
                    double csharp2cuda_temp_97 = (a)[0];
                    (*(csharp2cuda_temp_96) = csharp2cuda_temp_97);
#line 688 "SequencePathModule.cs"
                    {
#line 688 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 688 "SequencePathModule.cs"
                            int csharp2cuda_temp_99 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_99))))
                                break;
#line 689 "SequencePathModule.cs"
                            {
#line 690 "SequencePathModule.cs"
#line 690 "SequencePathModule.cs"
                                double* csharp2cuda_temp_100 = &((result)[index]);
#line 690 "SequencePathModule.cs"
                                double csharp2cuda_temp_101 = (a)[index];
#line 690 "SequencePathModule.cs"
                                double csharp2cuda_temp_102 = (result)[csharp2cuda_i32_sub(index, 1)];
                                (*(csharp2cuda_temp_100) = __dadd_rn(__dmul_rn(alpha, csharp2cuda_temp_101), __dmul_rn(__dsub_rn(1.0, alpha), csharp2cuda_temp_102)));
#line 691 "SequencePathModule.cs"
#line 691 "SequencePathModule.cs"
                                double csharp2cuda_temp_103 = (result)[index];
                                if ((!(isfinite(csharp2cuda_temp_103))))
                                {
#line 692 "SequencePathModule.cs"
#line 692 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_104 = &((output)->valid);
                                    (*(csharp2cuda_temp_104) = 0);
                                }
                            }
#line 688 "SequencePathModule.cs"
                            int* csharp2cuda_temp_98 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_98));
                        }
                    }
                }
            }
#line 696 "SequencePathModule.cs"
            break;
#line 697 "SequencePathModule.cs"
        case 3:
        case 6:
#line 699 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 700 "SequencePathModule.cs"
            {
#line 701 "SequencePathModule.cs"
                int width = 0;
#line 702 "SequencePathModule.cs"
#line 702 "SequencePathModule.cs"
                double csharp2cuda_temp_105 = (second)->scalar_value;
#line 702 "SequencePathModule.cs"
                int* csharp2cuda_temp_106 = &(width);
#line 702 "SequencePathModule.cs"
                bool csharp2cuda_temp_107 = mathblocks_sequence_positive_integer(csharp2cuda_temp_105, csharp2cuda_temp_106);
#line 702 "SequencePathModule.cs"
                bool csharp2cuda_temp_108;
#line 702 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_107))))
                {
#line 703 "SequencePathModule.cs"
                    int csharp2cuda_temp_109 = (first)->count;
#line 702 "SequencePathModule.cs"
                    csharp2cuda_temp_108 = ((width) > (csharp2cuda_temp_109));
                }
                else
                {
#line 702 "SequencePathModule.cs"
                    csharp2cuda_temp_108 = true;
                }
#line 702 "SequencePathModule.cs"
                bool csharp2cuda_temp_110;
#line 702 "SequencePathModule.cs"
                if (!(csharp2cuda_temp_108))
                {
#line 702 "SequencePathModule.cs"
                    csharp2cuda_temp_110 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 702 "SequencePathModule.cs"
                    csharp2cuda_temp_110 = true;
                }
                if (csharp2cuda_temp_110)
#line 704 "SequencePathModule.cs"
                {
#line 705 "SequencePathModule.cs"
#line 705 "SequencePathModule.cs"
                    int* csharp2cuda_temp_111 = &((output)->valid);
                    (*(csharp2cuda_temp_111) = 0);
                }
                else
#line 708 "SequencePathModule.cs"
                {
#line 709 "SequencePathModule.cs"
#line 709 "SequencePathModule.cs"
                    int csharp2cuda_temp_112 = (first)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_112, width), 1));
#line 710 "SequencePathModule.cs"
                    int* deque = ((int*)(scratch));
#line 711 "SequencePathModule.cs"
                    int head = 0;
#line 712 "SequencePathModule.cs"
                    int tail = 0;
#line 713 "SequencePathModule.cs"
                    {
#line 713 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 713 "SequencePathModule.cs"
                            int csharp2cuda_temp_114 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_114))))
                                break;
#line 714 "SequencePathModule.cs"
                            {
#line 715 "SequencePathModule.cs"
                                while (true)
                                {
#line 715 "SequencePathModule.cs"
                                    bool csharp2cuda_temp_115;
#line 715 "SequencePathModule.cs"
                                    if (((head) < (tail)))
                                    {
#line 715 "SequencePathModule.cs"
                                        int csharp2cuda_temp_116 = (deque)[head];
#line 715 "SequencePathModule.cs"
                                        csharp2cuda_temp_115 = ((csharp2cuda_temp_116) <= (csharp2cuda_i32_sub(index, width)));
                                    }
                                    else
                                    {
#line 715 "SequencePathModule.cs"
                                        csharp2cuda_temp_115 = false;
                                    }
                                    if (!(csharp2cuda_temp_115))
                                        break;
#line 716 "SequencePathModule.cs"
#line 716 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_117 = &(head);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_117));
                                }
#line 717 "SequencePathModule.cs"
                                while (true)
                                {
#line 717 "SequencePathModule.cs"
                                    bool csharp2cuda_temp_118;
#line 717 "SequencePathModule.cs"
                                    if (((head) < (tail)))
                                    {
#line 717 "SequencePathModule.cs"
                                        bool csharp2cuda_temp_119;
#line 717 "SequencePathModule.cs"
                                        if (((opcode) == (6)))
                                        {
#line 718 "SequencePathModule.cs"
                                            int csharp2cuda_temp_120 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 718 "SequencePathModule.cs"
                                            double csharp2cuda_temp_121 = (a)[csharp2cuda_temp_120];
#line 718 "SequencePathModule.cs"
                                            double csharp2cuda_temp_122 = (a)[index];
#line 717 "SequencePathModule.cs"
                                            csharp2cuda_temp_119 = ((csharp2cuda_temp_121) >= (csharp2cuda_temp_122));
                                        }
                                        else
                                        {
#line 719 "SequencePathModule.cs"
                                            int csharp2cuda_temp_123 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 719 "SequencePathModule.cs"
                                            double csharp2cuda_temp_124 = (a)[csharp2cuda_temp_123];
#line 719 "SequencePathModule.cs"
                                            double csharp2cuda_temp_125 = (a)[index];
#line 717 "SequencePathModule.cs"
                                            csharp2cuda_temp_119 = ((csharp2cuda_temp_124) <= (csharp2cuda_temp_125));
                                        }
#line 717 "SequencePathModule.cs"
                                        csharp2cuda_temp_118 = csharp2cuda_temp_119;
                                    }
                                    else
                                    {
#line 717 "SequencePathModule.cs"
                                        csharp2cuda_temp_118 = false;
                                    }
                                    if (!(csharp2cuda_temp_118))
                                        break;
#line 720 "SequencePathModule.cs"
                                    {
#line 721 "SequencePathModule.cs"
#line 721 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_126 = &(tail);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_126));
                                    }
                                }
#line 723 "SequencePathModule.cs"
#line 723 "SequencePathModule.cs"
                                int* csharp2cuda_temp_127 = &(tail);
#line 723 "SequencePathModule.cs"
                                int csharp2cuda_temp_128 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_127));
#line 723 "SequencePathModule.cs"
                                int* csharp2cuda_temp_129 = &((deque)[csharp2cuda_temp_128]);
                                (*(csharp2cuda_temp_129) = index);
#line 724 "SequencePathModule.cs"
                                if (((index) >= (csharp2cuda_i32_sub(width, 1))))
                                {
#line 725 "SequencePathModule.cs"
#line 725 "SequencePathModule.cs"
                                    double* csharp2cuda_temp_130 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_sub(index, width), 1)]);
#line 725 "SequencePathModule.cs"
                                    int csharp2cuda_temp_131 = (deque)[head];
#line 725 "SequencePathModule.cs"
                                    double csharp2cuda_temp_132 = (a)[csharp2cuda_temp_131];
                                    (*(csharp2cuda_temp_130) = csharp2cuda_temp_132);
                                }
                            }
#line 713 "SequencePathModule.cs"
                            int* csharp2cuda_temp_113 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_113));
                        }
                    }
                }
            }
#line 729 "SequencePathModule.cs"
            break;
#line 730 "SequencePathModule.cs"
        case 4:
        case 9:
#line 732 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 733 "SequencePathModule.cs"
            {
#line 734 "SequencePathModule.cs"
                int width = 0;
#line 735 "SequencePathModule.cs"
#line 735 "SequencePathModule.cs"
                double csharp2cuda_temp_133 = (second)->scalar_value;
#line 735 "SequencePathModule.cs"
                int* csharp2cuda_temp_134 = &(width);
#line 735 "SequencePathModule.cs"
                bool csharp2cuda_temp_135 = mathblocks_sequence_positive_integer(csharp2cuda_temp_133, csharp2cuda_temp_134);
#line 735 "SequencePathModule.cs"
                bool csharp2cuda_temp_136;
#line 735 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_135))))
                {
#line 735 "SequencePathModule.cs"
                    int csharp2cuda_temp_137 = (first)->count;
#line 735 "SequencePathModule.cs"
                    csharp2cuda_temp_136 = ((width) > (csharp2cuda_temp_137));
                }
                else
                {
#line 735 "SequencePathModule.cs"
                    csharp2cuda_temp_136 = true;
                }
                if (csharp2cuda_temp_136)
#line 736 "SequencePathModule.cs"
                {
#line 737 "SequencePathModule.cs"
#line 737 "SequencePathModule.cs"
                    int* csharp2cuda_temp_138 = &((output)->valid);
                    (*(csharp2cuda_temp_138) = 0);
                }
                else
#line 740 "SequencePathModule.cs"
                {
#line 741 "SequencePathModule.cs"
#line 741 "SequencePathModule.cs"
                    int csharp2cuda_temp_139 = (first)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_139, width), 1));
#line 742 "SequencePathModule.cs"
#line 742 "SequencePathModule.cs"
                    int csharp2cuda_temp_140 = (first)->count;
                    mathblocks_sequence_rolling_sum(a, csharp2cuda_temp_140, width, result);
#line 743 "SequencePathModule.cs"
                    if (((opcode) == (4)))
#line 744 "SequencePathModule.cs"
                    {
#line 745 "SequencePathModule.cs"
                        double scale = __ddiv_rn(1.0, ((double)(width)));
#line 746 "SequencePathModule.cs"
                        {
#line 746 "SequencePathModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 746 "SequencePathModule.cs"
                                int csharp2cuda_temp_142 = (output)->count;
                                if (!(((index) < (csharp2cuda_temp_142))))
                                    break;
#line 747 "SequencePathModule.cs"
#line 747 "SequencePathModule.cs"
                                double* csharp2cuda_temp_143 = &((result)[index]);
#line 747 "SequencePathModule.cs"
                                double csharp2cuda_temp_144 = *(csharp2cuda_temp_143);
                                (*(csharp2cuda_temp_143) = __dmul_rn(csharp2cuda_temp_144, scale));
#line 746 "SequencePathModule.cs"
                                int* csharp2cuda_temp_141 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_141));
                            }
                        }
                    }
#line 749 "SequencePathModule.cs"
                    {
#line 749 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 749 "SequencePathModule.cs"
                            int csharp2cuda_temp_146 = (output)->count;
                            if (!(((index) < (csharp2cuda_temp_146))))
                                break;
#line 750 "SequencePathModule.cs"
#line 750 "SequencePathModule.cs"
                            double csharp2cuda_temp_147 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_147))))
                            {
#line 750 "SequencePathModule.cs"
#line 750 "SequencePathModule.cs"
                                int* csharp2cuda_temp_148 = &((output)->valid);
                                (*(csharp2cuda_temp_148) = 0);
                            }
#line 749 "SequencePathModule.cs"
                            int* csharp2cuda_temp_145 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_145));
                        }
                    }
                }
            }
#line 753 "SequencePathModule.cs"
            break;
#line 754 "SequencePathModule.cs"
        case 5:
        case 7:
#line 756 "SequencePathModule.cs"
            {
#line 757 "SequencePathModule.cs"
                int width = 0;
#line 758 "SequencePathModule.cs"
                double probability = 0.0;
#line 759 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 760 "SequencePathModule.cs"
                {
#line 761 "SequencePathModule.cs"
#line 761 "SequencePathModule.cs"
                    double* csharp2cuda_temp_149 = &(probability);
#line 761 "SequencePathModule.cs"
                    double csharp2cuda_temp_150;
#line 761 "SequencePathModule.cs"
                    if (((opcode) == (5)))
                    {
#line 761 "SequencePathModule.cs"
                        csharp2cuda_temp_150 = 0.5;
                    }
                    else
                    {
#line 761 "SequencePathModule.cs"
                        csharp2cuda_temp_150 = (third)->scalar_value;
                    }
                    (*(csharp2cuda_temp_149) = csharp2cuda_temp_150);
#line 762 "SequencePathModule.cs"
#line 762 "SequencePathModule.cs"
                    double csharp2cuda_temp_151 = (second)->scalar_value;
#line 762 "SequencePathModule.cs"
                    int* csharp2cuda_temp_152 = &(width);
#line 762 "SequencePathModule.cs"
                    bool csharp2cuda_temp_153 = mathblocks_sequence_positive_integer(csharp2cuda_temp_151, csharp2cuda_temp_152);
#line 762 "SequencePathModule.cs"
                    bool csharp2cuda_temp_154;
#line 762 "SequencePathModule.cs"
                    if (!((!(csharp2cuda_temp_153))))
                    {
#line 763 "SequencePathModule.cs"
                        int csharp2cuda_temp_155 = (first)->count;
#line 762 "SequencePathModule.cs"
                        csharp2cuda_temp_154 = ((width) > (csharp2cuda_temp_155));
                    }
                    else
                    {
#line 762 "SequencePathModule.cs"
                        csharp2cuda_temp_154 = true;
                    }
#line 762 "SequencePathModule.cs"
                    bool csharp2cuda_temp_156;
#line 762 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_154))
                    {
#line 763 "SequencePathModule.cs"
                        bool csharp2cuda_temp_157;
#line 763 "SequencePathModule.cs"
                        if (((probability) >= (0.0)))
                        {
#line 763 "SequencePathModule.cs"
                            csharp2cuda_temp_157 = ((probability) <= (1.0));
                        }
                        else
                        {
#line 763 "SequencePathModule.cs"
                            csharp2cuda_temp_157 = false;
                        }
#line 762 "SequencePathModule.cs"
                        csharp2cuda_temp_156 = (!(csharp2cuda_temp_157));
                    }
                    else
                    {
#line 762 "SequencePathModule.cs"
                        csharp2cuda_temp_156 = true;
                    }
#line 762 "SequencePathModule.cs"
                    bool csharp2cuda_temp_158;
#line 762 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_156))
                    {
#line 764 "SequencePathModule.cs"
                        bool csharp2cuda_temp_159;
#line 764 "SequencePathModule.cs"
                        if (((width) > (1)))
                        {
#line 764 "SequencePathModule.cs"
                            csharp2cuda_temp_159 = ((((void*)(scratch))) == (((void*)(nullptr))));
                        }
                        else
                        {
#line 764 "SequencePathModule.cs"
                            csharp2cuda_temp_159 = false;
                        }
#line 762 "SequencePathModule.cs"
                        csharp2cuda_temp_158 = csharp2cuda_temp_159;
                    }
                    else
                    {
#line 762 "SequencePathModule.cs"
                        csharp2cuda_temp_158 = true;
                    }
                    if (csharp2cuda_temp_158)
#line 765 "SequencePathModule.cs"
                    {
#line 766 "SequencePathModule.cs"
#line 766 "SequencePathModule.cs"
                        int* csharp2cuda_temp_160 = &((output)->valid);
                        (*(csharp2cuda_temp_160) = 0);
                    }
                    else
#line 769 "SequencePathModule.cs"
                    {
#line 770 "SequencePathModule.cs"
#line 770 "SequencePathModule.cs"
                        int csharp2cuda_temp_161 = (first)->count;
                        mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_161, width), 1));
                    }
#line 772 "SequencePathModule.cs"
#line 772 "SequencePathModule.cs"
                    double* csharp2cuda_temp_162 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_162) = probability);
#line 773 "SequencePathModule.cs"
#line 773 "SequencePathModule.cs"
                    int* csharp2cuda_temp_163 = &((output)->boolean_value);
                    (*(csharp2cuda_temp_163) = width);
                }
#line 775 "SequencePathModule.cs"
                __syncthreads();
#line 776 "SequencePathModule.cs"
#line 776 "SequencePathModule.cs"
                int* csharp2cuda_temp_164 = &(width);
#line 776 "SequencePathModule.cs"
                int csharp2cuda_temp_165 = (output)->boolean_value;
                (*(csharp2cuda_temp_164) = csharp2cuda_temp_165);
#line 777 "SequencePathModule.cs"
#line 777 "SequencePathModule.cs"
                double* csharp2cuda_temp_166 = &(probability);
#line 777 "SequencePathModule.cs"
                double csharp2cuda_temp_167 = (output)->scalar_value;
                (*(csharp2cuda_temp_166) = csharp2cuda_temp_167);
#line 779 "SequencePathModule.cs"
                __syncthreads();
#line 780 "SequencePathModule.cs"
#line 780 "SequencePathModule.cs"
                bool csharp2cuda_temp_168 = (output)->valid;
                if ((!(csharp2cuda_temp_168)))
                {
#line 781 "SequencePathModule.cs"
                    break;
                }
#line 782 "SequencePathModule.cs"
                if (((width) == (1)))
#line 783 "SequencePathModule.cs"
                {
#line 784 "SequencePathModule.cs"
                    {
#line 784 "SequencePathModule.cs"
                        int index = thread;
                        while (true)
                        {
#line 784 "SequencePathModule.cs"
                            int csharp2cuda_temp_171 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_171))))
                                break;
#line 785 "SequencePathModule.cs"
#line 785 "SequencePathModule.cs"
                            double* csharp2cuda_temp_172 = &((result)[index]);
#line 785 "SequencePathModule.cs"
                            double csharp2cuda_temp_173 = (a)[index];
                            (*(csharp2cuda_temp_172) = csharp2cuda_temp_173);
#line 784 "SequencePathModule.cs"
                            int* csharp2cuda_temp_169 = &(index);
#line 784 "SequencePathModule.cs"
                            int csharp2cuda_temp_170 = *(csharp2cuda_temp_169);
                            (*(csharp2cuda_temp_169) = csharp2cuda_i32_add(csharp2cuda_temp_170, blockDim.x));
                        }
                    }
#line 786 "SequencePathModule.cs"
                    __syncthreads();
#line 787 "SequencePathModule.cs"
                    if (((thread) == (0)))
#line 788 "SequencePathModule.cs"
                    {
#line 789 "SequencePathModule.cs"
#line 789 "SequencePathModule.cs"
                        double* csharp2cuda_temp_174 = &((output)->scalar_value);
#line 789 "SequencePathModule.cs"
                        int csharp2cuda_temp_175 = (first)->count;
                        (*(csharp2cuda_temp_174) = ((double)(csharp2cuda_temp_175)));
#line 790 "SequencePathModule.cs"
#line 790 "SequencePathModule.cs"
                        int* csharp2cuda_temp_176 = &((output)->boolean_value);
                        (*(csharp2cuda_temp_176) = 0);
                    }
#line 792 "SequencePathModule.cs"
                    break;
                }
#line 794 "SequencePathModule.cs"
#line 794 "SequencePathModule.cs"
                bool csharp2cuda_temp_177;
#line 794 "SequencePathModule.cs"
                if (!(((probability) == (0.0))))
                {
#line 794 "SequencePathModule.cs"
                    csharp2cuda_temp_177 = ((probability) == (1.0));
                }
                else
                {
#line 794 "SequencePathModule.cs"
                    csharp2cuda_temp_177 = true;
                }
                if (csharp2cuda_temp_177)
#line 795 "SequencePathModule.cs"
                {
#line 796 "SequencePathModule.cs"
                    if (((thread) == (0)))
#line 797 "SequencePathModule.cs"
                    {
#line 798 "SequencePathModule.cs"
#line 800 "SequencePathModule.cs"
                        int csharp2cuda_temp_178 = (first)->count;
                        mathblocks_sequence_rolling_extreme(a, csharp2cuda_temp_178, width, result, ((int*)(scratch)), ((probability) == (0.0)));
#line 805 "SequencePathModule.cs"
#line 805 "SequencePathModule.cs"
                        double* csharp2cuda_temp_179 = &((output)->scalar_value);
#line 806 "SequencePathModule.cs"
                        int csharp2cuda_temp_180 = (first)->count;
#line 806 "SequencePathModule.cs"
                        int csharp2cuda_temp_181 = (output)->count;
                        (*(csharp2cuda_temp_179) = ((double)(csharp2cuda_i64_add(csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_180)), ((long long)(3))), ((long long)(csharp2cuda_temp_181))))));
#line 807 "SequencePathModule.cs"
#line 807 "SequencePathModule.cs"
                        int* csharp2cuda_temp_182 = &((output)->boolean_value);
                        (*(csharp2cuda_temp_182) = 0);
                    }
#line 809 "SequencePathModule.cs"
                    __syncthreads();
#line 810 "SequencePathModule.cs"
                    break;
                }
#line 813 "SequencePathModule.cs"
                unsigned char* order_scratch = ((unsigned char*)(scratch));
#line 814 "SequencePathModule.cs"
#line 816 "SequencePathModule.cs"
                int csharp2cuda_temp_183 = (first)->count;
                mathblocks_sequence_prepare_order_ranks(a, csharp2cuda_temp_183, order_scratch, output);
#line 819 "SequencePathModule.cs"
#line 819 "SequencePathModule.cs"
                bool csharp2cuda_temp_184 = (output)->valid;
                if ((!(csharp2cuda_temp_184)))
                {
#line 820 "SequencePathModule.cs"
                    break;
                }
#line 821 "SequencePathModule.cs"
                unsigned long long* first_keys = ((unsigned long long*)(order_scratch));
#line 822 "SequencePathModule.cs"
                int csharp2cuda_temp_185 = (first)->count;
#line 822 "SequencePathModule.cs"
                unsigned long long* second_keys = csharp2cuda_pointer_add(first_keys, csharp2cuda_temp_185);
#line 823 "SequencePathModule.cs"
                int csharp2cuda_temp_186 = (first)->count;
#line 823 "SequencePathModule.cs"
                int* first_indexes = ((int*)(csharp2cuda_pointer_add(second_keys, csharp2cuda_temp_186)));
#line 824 "SequencePathModule.cs"
                int csharp2cuda_temp_187 = (first)->count;
#line 824 "SequencePathModule.cs"
                int* second_indexes = csharp2cuda_pointer_add(first_indexes, csharp2cuda_temp_187);
#line 825 "SequencePathModule.cs"
                int csharp2cuda_temp_188 = (first)->count;
#line 825 "SequencePathModule.cs"
                int* ranks = csharp2cuda_pointer_add(second_indexes, csharp2cuda_temp_188);
#line 826 "SequencePathModule.cs"
                int csharp2cuda_temp_189 = (first)->count;
#line 826 "SequencePathModule.cs"
                int* lower_heap = csharp2cuda_pointer_add(ranks, csharp2cuda_temp_189);
#line 827 "SequencePathModule.cs"
                int* upper_heap = csharp2cuda_pointer_add(lower_heap, width);
#line 828 "SequencePathModule.cs"
                int* positions = csharp2cuda_pointer_add(upper_heap, width);
#line 829 "SequencePathModule.cs"
                int csharp2cuda_temp_190 = (first)->count;
#line 829 "SequencePathModule.cs"
                int* kinds = csharp2cuda_pointer_add(positions, csharp2cuda_temp_190);
#line 830 "SequencePathModule.cs"
                double quantile_position = __dmul_rn(probability, ((double)(csharp2cuda_i32_sub(width, 1))));
#line 831 "SequencePathModule.cs"
                int lower_index = csharp2cuda_f64_to_i32(floor(quantile_position));
#line 832 "SequencePathModule.cs"
                int upper_index = csharp2cuda_f64_to_i32(ceil(quantile_position));
#line 833 "SequencePathModule.cs"
                double weight = __dsub_rn(quantile_position, ((double)(lower_index)));
#line 835 "SequencePathModule.cs"
#line 835 "SequencePathModule.cs"
                int csharp2cuda_temp_191 = (output)->count;
                if (((csharp2cuda_temp_191) == (1)))
#line 836 "SequencePathModule.cs"
                {
#line 837 "SequencePathModule.cs"
                    if (((thread) == (0)))
#line 838 "SequencePathModule.cs"
                    {
#line 839 "SequencePathModule.cs"
                        int csharp2cuda_temp_192 = (first_indexes)[lower_index];
#line 839 "SequencePathModule.cs"
                        double lower_value = (a)[csharp2cuda_temp_192];
#line 840 "SequencePathModule.cs"
                        int csharp2cuda_temp_193 = (first_indexes)[upper_index];
#line 840 "SequencePathModule.cs"
                        double upper_value = (a)[csharp2cuda_temp_193];
#line 841 "SequencePathModule.cs"
#line 841 "SequencePathModule.cs"
                        double* csharp2cuda_temp_194 = &((result)[0]);
                        (*(csharp2cuda_temp_194) = __dadd_rn(__dmul_rn(lower_value, __dsub_rn(1.0, weight)), __dmul_rn(upper_value, weight)));
#line 842 "SequencePathModule.cs"
#line 842 "SequencePathModule.cs"
                        int* csharp2cuda_temp_195 = &((output)->valid);
#line 842 "SequencePathModule.cs"
                        double csharp2cuda_temp_196 = (result)[0];
                        (*(csharp2cuda_temp_195) = isfinite(csharp2cuda_temp_196));
#line 843 "SequencePathModule.cs"
#line 843 "SequencePathModule.cs"
                        double* csharp2cuda_temp_197 = &((output)->scalar_value);
#line 843 "SequencePathModule.cs"
                        int csharp2cuda_temp_198 = (first)->count;
                        (*(csharp2cuda_temp_197) = ((double)(csharp2cuda_i64_add(csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_198)), ((long long)(64))), ((long long)(2))))));
#line 844 "SequencePathModule.cs"
#line 844 "SequencePathModule.cs"
                        int* csharp2cuda_temp_199 = &((output)->boolean_value);
                        (*(csharp2cuda_temp_199) = 64);
                    }
#line 846 "SequencePathModule.cs"
                    __syncthreads();
#line 847 "SequencePathModule.cs"
                    break;
                }
#line 850 "SequencePathModule.cs"
                {
#line 850 "SequencePathModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 850 "SequencePathModule.cs"
                        int csharp2cuda_temp_202 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_202))))
                            break;
#line 851 "SequencePathModule.cs"
                        {
#line 852 "SequencePathModule.cs"
#line 852 "SequencePathModule.cs"
                            int* csharp2cuda_temp_203 = &((positions)[index]);
                            (*(csharp2cuda_temp_203) = csharp2cuda_i32_neg(1));
#line 853 "SequencePathModule.cs"
#line 853 "SequencePathModule.cs"
                            int* csharp2cuda_temp_204 = &((kinds)[index]);
                            (*(csharp2cuda_temp_204) = csharp2cuda_i32_neg(1));
                        }
#line 850 "SequencePathModule.cs"
                        int* csharp2cuda_temp_200 = &(index);
#line 850 "SequencePathModule.cs"
                        int csharp2cuda_temp_201 = *(csharp2cuda_temp_200);
                        (*(csharp2cuda_temp_200) = csharp2cuda_i32_add(csharp2cuda_temp_201, blockDim.x));
                    }
                }
#line 855 "SequencePathModule.cs"
                __syncthreads();
#line 856 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 857 "SequencePathModule.cs"
                {
#line 858 "SequencePathModule.cs"
                    int lower_count = 0;
#line 859 "SequencePathModule.cs"
                    int upper_count = 0;
#line 860 "SequencePathModule.cs"
                    int target_lower_count = csharp2cuda_i32_add(lower_index, 1);
#line 861 "SequencePathModule.cs"
                    {
#line 861 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (width))))
                                break;
#line 862 "SequencePathModule.cs"
                            {
#line 863 "SequencePathModule.cs"
#line 863 "SequencePathModule.cs"
                                bool csharp2cuda_temp_206;
#line 863 "SequencePathModule.cs"
                                if (((lower_count) == (0)))
                                {
#line 863 "SequencePathModule.cs"
                                    csharp2cuda_temp_206 = ((upper_count) == (0));
                                }
                                else
                                {
#line 863 "SequencePathModule.cs"
                                    csharp2cuda_temp_206 = false;
                                }
                                if (csharp2cuda_temp_206)
#line 864 "SequencePathModule.cs"
                                {
#line 865 "SequencePathModule.cs"
#line 867 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_207 = &(lower_count);
                                    mathblocks_sequence_heap_insert(lower_heap, csharp2cuda_temp_207, index, 0, positions, kinds, ranks, true);
                                }
                                else
                                {
#line 875 "SequencePathModule.cs"
                                    if (((lower_count) == (0)))
#line 876 "SequencePathModule.cs"
                                    {
#line 877 "SequencePathModule.cs"
#line 879 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_208 = &(upper_count);
                                        mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_208, index, 1, positions, kinds, ranks, false);
                                    }
                                    else
                                    {
#line 887 "SequencePathModule.cs"
#line 887 "SequencePathModule.cs"
                                        int csharp2cuda_temp_209 = (ranks)[index];
#line 887 "SequencePathModule.cs"
                                        int csharp2cuda_temp_210 = (lower_heap)[0];
#line 887 "SequencePathModule.cs"
                                        int csharp2cuda_temp_211 = (ranks)[csharp2cuda_temp_210];
                                        if (((csharp2cuda_temp_209) <= (csharp2cuda_temp_211)))
#line 888 "SequencePathModule.cs"
                                        {
#line 889 "SequencePathModule.cs"
#line 891 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_212 = &(lower_count);
                                            mathblocks_sequence_heap_insert(lower_heap, csharp2cuda_temp_212, index, 0, positions, kinds, ranks, true);
                                        }
                                        else
#line 900 "SequencePathModule.cs"
                                        {
#line 901 "SequencePathModule.cs"
#line 903 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_213 = &(upper_count);
                                            mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_213, index, 1, positions, kinds, ranks, false);
                                        }
                                    }
                                }
#line 911 "SequencePathModule.cs"
                                int csharp2cuda_temp_214;
#line 911 "SequencePathModule.cs"
                                if (((target_lower_count) < (csharp2cuda_i32_add(index, 1))))
                                {
#line 911 "SequencePathModule.cs"
                                    csharp2cuda_temp_214 = target_lower_count;
                                }
                                else
                                {
#line 911 "SequencePathModule.cs"
                                    csharp2cuda_temp_214 = csharp2cuda_i32_add(index, 1);
                                }
#line 911 "SequencePathModule.cs"
                                int active_target = csharp2cuda_temp_214;
#line 914 "SequencePathModule.cs"
#line 916 "SequencePathModule.cs"
                                int* csharp2cuda_temp_215 = &(lower_count);
#line 918 "SequencePathModule.cs"
                                int* csharp2cuda_temp_216 = &(upper_count);
                                mathblocks_sequence_rebalance_heaps(lower_heap, csharp2cuda_temp_215, upper_heap, csharp2cuda_temp_216, active_target, positions, kinds, ranks);
                            }
#line 861 "SequencePathModule.cs"
                            int* csharp2cuda_temp_205 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_205));
                        }
                    }
#line 924 "SequencePathModule.cs"
                    {
#line 924 "SequencePathModule.cs"
                        int start = 0;
                        while (true)
                        {
#line 924 "SequencePathModule.cs"
                            int csharp2cuda_temp_218 = (output)->count;
                            if (!(((start) < (csharp2cuda_temp_218))))
                                break;
#line 925 "SequencePathModule.cs"
                            {
#line 926 "SequencePathModule.cs"
                                int csharp2cuda_temp_219 = (lower_heap)[0];
#line 926 "SequencePathModule.cs"
                                double lower_value = (a)[csharp2cuda_temp_219];
#line 927 "SequencePathModule.cs"
                                double csharp2cuda_temp_220;
#line 927 "SequencePathModule.cs"
                                if (((lower_index) == (upper_index)))
                                {
#line 927 "SequencePathModule.cs"
                                    csharp2cuda_temp_220 = lower_value;
                                }
                                else
                                {
#line 929 "SequencePathModule.cs"
                                    int csharp2cuda_temp_221 = (upper_heap)[0];
#line 927 "SequencePathModule.cs"
                                    csharp2cuda_temp_220 = (a)[csharp2cuda_temp_221];
                                }
#line 927 "SequencePathModule.cs"
                                double upper_value = csharp2cuda_temp_220;
#line 930 "SequencePathModule.cs"
#line 930 "SequencePathModule.cs"
                                double* csharp2cuda_temp_222 = &((result)[start]);
                                (*(csharp2cuda_temp_222) = __dadd_rn(__dmul_rn(lower_value, __dsub_rn(1.0, weight)), __dmul_rn(upper_value, weight)));
#line 931 "SequencePathModule.cs"
#line 931 "SequencePathModule.cs"
                                double csharp2cuda_temp_223 = (result)[start];
                                if ((!(isfinite(csharp2cuda_temp_223))))
#line 932 "SequencePathModule.cs"
                                {
#line 933 "SequencePathModule.cs"
#line 933 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_224 = &((output)->valid);
                                    (*(csharp2cuda_temp_224) = 0);
#line 934 "SequencePathModule.cs"
                                    break;
                                }
#line 936 "SequencePathModule.cs"
#line 936 "SequencePathModule.cs"
                                int csharp2cuda_temp_225 = (output)->count;
                                if (((csharp2cuda_i32_add(start, 1)) == (csharp2cuda_temp_225)))
                                {
#line 937 "SequencePathModule.cs"
                                    break;
                                }
#line 938 "SequencePathModule.cs"
                                int outgoing = start;
#line 939 "SequencePathModule.cs"
                                int incoming = csharp2cuda_i32_add(start, width);
#line 940 "SequencePathModule.cs"
#line 940 "SequencePathModule.cs"
                                int csharp2cuda_temp_226 = (kinds)[outgoing];
                                if (((csharp2cuda_temp_226) == (0)))
#line 941 "SequencePathModule.cs"
                                {
#line 942 "SequencePathModule.cs"
#line 944 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_227 = &(lower_count);
                                    mathblocks_sequence_heap_remove(lower_heap, csharp2cuda_temp_227, outgoing, positions, kinds, ranks, true);
                                }
                                else
#line 952 "SequencePathModule.cs"
                                {
#line 953 "SequencePathModule.cs"
#line 955 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_228 = &(upper_count);
                                    mathblocks_sequence_heap_remove(upper_heap, csharp2cuda_temp_228, outgoing, positions, kinds, ranks, false);
                                }
#line 962 "SequencePathModule.cs"
                                if (((lower_count) == (0)))
#line 963 "SequencePathModule.cs"
                                {
#line 964 "SequencePathModule.cs"
#line 966 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_229 = &(upper_count);
                                    mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_229, incoming, 1, positions, kinds, ranks, false);
                                }
                                else
                                {
#line 974 "SequencePathModule.cs"
#line 974 "SequencePathModule.cs"
                                    int csharp2cuda_temp_230 = (ranks)[incoming];
#line 974 "SequencePathModule.cs"
                                    int csharp2cuda_temp_231 = (lower_heap)[0];
#line 974 "SequencePathModule.cs"
                                    int csharp2cuda_temp_232 = (ranks)[csharp2cuda_temp_231];
                                    if (((csharp2cuda_temp_230) <= (csharp2cuda_temp_232)))
#line 975 "SequencePathModule.cs"
                                    {
#line 976 "SequencePathModule.cs"
#line 978 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_233 = &(lower_count);
                                        mathblocks_sequence_heap_insert(lower_heap, csharp2cuda_temp_233, incoming, 0, positions, kinds, ranks, true);
                                    }
                                    else
#line 987 "SequencePathModule.cs"
                                    {
#line 988 "SequencePathModule.cs"
#line 990 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_234 = &(upper_count);
                                        mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_234, incoming, 1, positions, kinds, ranks, false);
                                    }
                                }
#line 998 "SequencePathModule.cs"
#line 1000 "SequencePathModule.cs"
                                int* csharp2cuda_temp_235 = &(lower_count);
#line 1002 "SequencePathModule.cs"
                                int* csharp2cuda_temp_236 = &(upper_count);
                                mathblocks_sequence_rebalance_heaps(lower_heap, csharp2cuda_temp_235, upper_heap, csharp2cuda_temp_236, target_lower_count, positions, kinds, ranks);
                            }
#line 924 "SequencePathModule.cs"
                            int* csharp2cuda_temp_217 = &(start);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_217));
                        }
                    }
#line 1008 "SequencePathModule.cs"
                    int heap_height = 1;
#line 1009 "SequencePathModule.cs"
                    {
#line 1009 "SequencePathModule.cs"
                        int value = width;
                        while (true)
                        {
                            if (!(((value) > (1))))
                                break;
#line 1010 "SequencePathModule.cs"
#line 1010 "SequencePathModule.cs"
                            int* csharp2cuda_temp_238 = &(heap_height);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_238));
#line 1009 "SequencePathModule.cs"
                            int* csharp2cuda_temp_237 = &(value);
                            (*(csharp2cuda_temp_237) = csharp2cuda_i32_shr(csharp2cuda_i32_add(value, 1), 1));
                        }
                    }
#line 1012 "SequencePathModule.cs"
                    int csharp2cuda_temp_239 = (first)->count;
#line 1011 "SequencePathModule.cs"
                    long long heap_bound = csharp2cuda_i64_mul(csharp2cuda_i64_add(((long long)(width)), csharp2cuda_i64_mul(2LL, ((long long)(csharp2cuda_i32_sub(csharp2cuda_temp_239, width))))), ((long long)(heap_height)));
#line 1013 "SequencePathModule.cs"
                    int csharp2cuda_temp_240 = (output)->count;
#line 1013 "SequencePathModule.cs"
                    long long selection_bound = csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_240)), ((long long)(2)));
#line 1014 "SequencePathModule.cs"
#line 1014 "SequencePathModule.cs"
                    double* csharp2cuda_temp_241 = &((output)->scalar_value);
#line 1015 "SequencePathModule.cs"
                    int csharp2cuda_temp_242 = (first)->count;
                    (*(csharp2cuda_temp_241) = ((double)(csharp2cuda_i64_add(csharp2cuda_i64_add(csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_242)), ((long long)(64))), heap_bound), selection_bound))));
#line 1016 "SequencePathModule.cs"
#line 1016 "SequencePathModule.cs"
                    int* csharp2cuda_temp_243 = &((output)->boolean_value);
                    (*(csharp2cuda_temp_243) = 64);
                }
#line 1018 "SequencePathModule.cs"
                __syncthreads();
#line 1019 "SequencePathModule.cs"
                break;
            }
#line 1021 "SequencePathModule.cs"
        case 8:
        case 10:
#line 1023 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1024 "SequencePathModule.cs"
            {
#line 1025 "SequencePathModule.cs"
                int width = 0;
#line 1026 "SequencePathModule.cs"
#line 1026 "SequencePathModule.cs"
                double csharp2cuda_temp_244 = (second)->scalar_value;
#line 1026 "SequencePathModule.cs"
                int* csharp2cuda_temp_245 = &(width);
#line 1026 "SequencePathModule.cs"
                bool csharp2cuda_temp_246 = mathblocks_sequence_positive_integer(csharp2cuda_temp_244, csharp2cuda_temp_245);
#line 1026 "SequencePathModule.cs"
                bool csharp2cuda_temp_247;
#line 1026 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_246))))
                {
#line 1026 "SequencePathModule.cs"
                    int csharp2cuda_temp_248 = (first)->count;
#line 1026 "SequencePathModule.cs"
                    csharp2cuda_temp_247 = ((width) > (csharp2cuda_temp_248));
                }
                else
                {
#line 1026 "SequencePathModule.cs"
                    csharp2cuda_temp_247 = true;
                }
                if (csharp2cuda_temp_247)
#line 1027 "SequencePathModule.cs"
                {
#line 1028 "SequencePathModule.cs"
#line 1028 "SequencePathModule.cs"
                    int* csharp2cuda_temp_249 = &((output)->valid);
                    (*(csharp2cuda_temp_249) = 0);
                }
                else
#line 1031 "SequencePathModule.cs"
                {
#line 1032 "SequencePathModule.cs"
#line 1032 "SequencePathModule.cs"
                    int csharp2cuda_temp_250 = (first)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_250, width), 1));
#line 1033 "SequencePathModule.cs"
                    {
#line 1033 "SequencePathModule.cs"
                        int start = 0;
                        while (true)
                        {
#line 1033 "SequencePathModule.cs"
                            int csharp2cuda_temp_252 = (output)->count;
                            if (!(((start) < (csharp2cuda_temp_252))))
                                break;
#line 1034 "SequencePathModule.cs"
                            {
#line 1035 "SequencePathModule.cs"
                                double mean = 0.0;
#line 1036 "SequencePathModule.cs"
                                {
#line 1036 "SequencePathModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
                                        if (!(((index) < (width))))
                                            break;
#line 1037 "SequencePathModule.cs"
#line 1037 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_254 = &(mean);
#line 1037 "SequencePathModule.cs"
                                        double csharp2cuda_temp_255 = *(csharp2cuda_temp_254);
#line 1037 "SequencePathModule.cs"
                                        double csharp2cuda_temp_256 = (a)[csharp2cuda_i32_add(start, index)];
                                        (*(csharp2cuda_temp_254) = __dadd_rn(csharp2cuda_temp_255, csharp2cuda_temp_256));
#line 1036 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_253 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_253));
                                    }
                                }
#line 1038 "SequencePathModule.cs"
#line 1038 "SequencePathModule.cs"
                                double* csharp2cuda_temp_257 = &(mean);
#line 1038 "SequencePathModule.cs"
                                double csharp2cuda_temp_258 = *(csharp2cuda_temp_257);
                                (*(csharp2cuda_temp_257) = __ddiv_rn(csharp2cuda_temp_258, ((double)(width))));
#line 1039 "SequencePathModule.cs"
                                double sum_squares = 0.0;
#line 1040 "SequencePathModule.cs"
                                {
#line 1040 "SequencePathModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
                                        if (!(((index) < (width))))
                                            break;
#line 1041 "SequencePathModule.cs"
                                        {
#line 1042 "SequencePathModule.cs"
                                            double csharp2cuda_temp_260 = (a)[csharp2cuda_i32_add(start, index)];
#line 1042 "SequencePathModule.cs"
                                            double difference = __dsub_rn(csharp2cuda_temp_260, mean);
#line 1043 "SequencePathModule.cs"
#line 1043 "SequencePathModule.cs"
                                            double* csharp2cuda_temp_261 = &(sum_squares);
#line 1043 "SequencePathModule.cs"
                                            double csharp2cuda_temp_262 = *(csharp2cuda_temp_261);
                                            (*(csharp2cuda_temp_261) = __dadd_rn(csharp2cuda_temp_262, __dmul_rn(difference, difference)));
                                        }
#line 1040 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_259 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_259));
                                    }
                                }
#line 1045 "SequencePathModule.cs"
                                double csharp2cuda_temp_263 = __ddiv_rn(sum_squares, ((double)(width)));
#line 1045 "SequencePathModule.cs"
                                double deviation = mathblocks_square_root(csharp2cuda_temp_263);
#line 1046 "SequencePathModule.cs"
#line 1046 "SequencePathModule.cs"
                                double* csharp2cuda_temp_264 = &((result)[start]);
#line 1046 "SequencePathModule.cs"
                                double csharp2cuda_temp_265;
#line 1046 "SequencePathModule.cs"
                                if (((opcode) == (8)))
                                {
#line 1046 "SequencePathModule.cs"
                                    csharp2cuda_temp_265 = deviation;
                                }
                                else
                                {
#line 1046 "SequencePathModule.cs"
                                    csharp2cuda_temp_265 = __dmul_rn(deviation, deviation);
                                }
                                (*(csharp2cuda_temp_264) = csharp2cuda_temp_265);
#line 1047 "SequencePathModule.cs"
#line 1047 "SequencePathModule.cs"
                                double csharp2cuda_temp_266 = (result)[start];
                                if ((!(isfinite(csharp2cuda_temp_266))))
                                {
#line 1048 "SequencePathModule.cs"
#line 1048 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_267 = &((output)->valid);
                                    (*(csharp2cuda_temp_267) = 0);
                                }
                            }
#line 1033 "SequencePathModule.cs"
                            int* csharp2cuda_temp_251 = &(start);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_251));
                        }
                    }
                }
            }
#line 1052 "SequencePathModule.cs"
            break;
#line 1053 "SequencePathModule.cs"
        case 11:
#line 1054 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1055 "SequencePathModule.cs"
            {
#line 1056 "SequencePathModule.cs"
#line 1056 "SequencePathModule.cs"
                int csharp2cuda_temp_268 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_268);
#line 1057 "SequencePathModule.cs"
#line 1057 "SequencePathModule.cs"
                int csharp2cuda_temp_269 = (first)->count;
#line 1057 "SequencePathModule.cs"
                bool csharp2cuda_temp_270;
#line 1057 "SequencePathModule.cs"
                if (!((!(mathblocks_sequence_is_power_of_two(csharp2cuda_temp_269)))))
                {
#line 1057 "SequencePathModule.cs"
                    csharp2cuda_temp_270 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 1057 "SequencePathModule.cs"
                    csharp2cuda_temp_270 = true;
                }
                if (csharp2cuda_temp_270)
#line 1058 "SequencePathModule.cs"
                {
#line 1059 "SequencePathModule.cs"
#line 1059 "SequencePathModule.cs"
                    int* csharp2cuda_temp_271 = &((output)->valid);
                    (*(csharp2cuda_temp_271) = 0);
                }
                else
#line 1062 "SequencePathModule.cs"
                {
#line 1063 "SequencePathModule.cs"
                    {
#line 1063 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1063 "SequencePathModule.cs"
                            int csharp2cuda_temp_273 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_273))))
                                break;
#line 1064 "SequencePathModule.cs"
#line 1064 "SequencePathModule.cs"
                            double* csharp2cuda_temp_274 = &((result)[index]);
#line 1064 "SequencePathModule.cs"
                            double csharp2cuda_temp_275 = (a)[index];
                            (*(csharp2cuda_temp_274) = csharp2cuda_temp_275);
#line 1063 "SequencePathModule.cs"
                            int* csharp2cuda_temp_272 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_272));
                        }
                    }
#line 1065 "SequencePathModule.cs"
                    int length = (first)->count;
#line 1066 "SequencePathModule.cs"
                    double scale = __ddiv_rn(1.0, mathblocks_square_root(2.0));
#line 1067 "SequencePathModule.cs"
                    while (true)
                    {
                        if (!(((length) > (1))))
                            break;
#line 1068 "SequencePathModule.cs"
                        {
#line 1069 "SequencePathModule.cs"
                            int half = csharp2cuda_i32_div(length, 2);
#line 1070 "SequencePathModule.cs"
                            {
#line 1070 "SequencePathModule.cs"
                                int index = 0;
                                while (true)
                                {
                                    if (!(((index) < (half))))
                                        break;
#line 1071 "SequencePathModule.cs"
                                    {
#line 1072 "SequencePathModule.cs"
#line 1072 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_277 = &((scratch)[index]);
#line 1072 "SequencePathModule.cs"
                                        double csharp2cuda_temp_278 = (result)[csharp2cuda_i32_mul(2, index)];
#line 1072 "SequencePathModule.cs"
                                        double csharp2cuda_temp_279 = (result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                        (*(csharp2cuda_temp_277) = __dmul_rn(__dadd_rn(csharp2cuda_temp_278, csharp2cuda_temp_279), scale));
#line 1073 "SequencePathModule.cs"
#line 1073 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_280 = &((scratch)[csharp2cuda_i32_add(half, index)]);
#line 1073 "SequencePathModule.cs"
                                        double csharp2cuda_temp_281 = (result)[csharp2cuda_i32_mul(2, index)];
#line 1073 "SequencePathModule.cs"
                                        double csharp2cuda_temp_282 = (result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                        (*(csharp2cuda_temp_280) = __dmul_rn(__dsub_rn(csharp2cuda_temp_281, csharp2cuda_temp_282), scale));
                                    }
#line 1070 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_276 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_276));
                                }
                            }
#line 1075 "SequencePathModule.cs"
                            {
#line 1075 "SequencePathModule.cs"
                                int index = 0;
                                while (true)
                                {
                                    if (!(((index) < (length))))
                                        break;
#line 1076 "SequencePathModule.cs"
#line 1076 "SequencePathModule.cs"
                                    double* csharp2cuda_temp_284 = &((result)[index]);
#line 1076 "SequencePathModule.cs"
                                    double csharp2cuda_temp_285 = (scratch)[index];
                                    (*(csharp2cuda_temp_284) = csharp2cuda_temp_285);
#line 1075 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_283 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_283));
                                }
                            }
#line 1077 "SequencePathModule.cs"
#line 1077 "SequencePathModule.cs"
                            int* csharp2cuda_temp_286 = &(length);
                            (*(csharp2cuda_temp_286) = half);
                        }
                    }
#line 1079 "SequencePathModule.cs"
                    {
#line 1079 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1079 "SequencePathModule.cs"
                            int csharp2cuda_temp_288 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_288))))
                                break;
#line 1080 "SequencePathModule.cs"
#line 1080 "SequencePathModule.cs"
                            double csharp2cuda_temp_289 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_289))))
                            {
#line 1080 "SequencePathModule.cs"
#line 1080 "SequencePathModule.cs"
                                int* csharp2cuda_temp_290 = &((output)->valid);
                                (*(csharp2cuda_temp_290) = 0);
                            }
#line 1079 "SequencePathModule.cs"
                            int* csharp2cuda_temp_287 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_287));
                        }
                    }
                }
            }
#line 1083 "SequencePathModule.cs"
            break;
#line 1084 "SequencePathModule.cs"
        case 12:
#line 1085 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1086 "SequencePathModule.cs"
            {
#line 1087 "SequencePathModule.cs"
#line 1087 "SequencePathModule.cs"
                int csharp2cuda_temp_291 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_291);
#line 1088 "SequencePathModule.cs"
#line 1088 "SequencePathModule.cs"
                int csharp2cuda_temp_292 = (first)->count;
                if ((!(mathblocks_sequence_is_power_of_two(csharp2cuda_temp_292))))
#line 1089 "SequencePathModule.cs"
                {
#line 1090 "SequencePathModule.cs"
#line 1090 "SequencePathModule.cs"
                    int* csharp2cuda_temp_293 = &((output)->valid);
                    (*(csharp2cuda_temp_293) = 0);
                }
                else
#line 1093 "SequencePathModule.cs"
                {
#line 1094 "SequencePathModule.cs"
                    {
#line 1094 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1094 "SequencePathModule.cs"
                            int csharp2cuda_temp_295 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_295))))
                                break;
#line 1095 "SequencePathModule.cs"
#line 1095 "SequencePathModule.cs"
                            double* csharp2cuda_temp_296 = &((result)[index]);
#line 1095 "SequencePathModule.cs"
                            double csharp2cuda_temp_297 = (a)[index];
                            (*(csharp2cuda_temp_296) = csharp2cuda_temp_297);
#line 1094 "SequencePathModule.cs"
                            int* csharp2cuda_temp_294 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_294));
                        }
                    }
#line 1096 "SequencePathModule.cs"
                    {
#line 1096 "SequencePathModule.cs"
                        int width = 1;
                        while (true)
                        {
#line 1096 "SequencePathModule.cs"
                            int csharp2cuda_temp_300 = (first)->count;
                            if (!(((width) < (csharp2cuda_temp_300))))
                                break;
#line 1097 "SequencePathModule.cs"
                            {
#line 1098 "SequencePathModule.cs"
                                {
#line 1098 "SequencePathModule.cs"
                                    int start = 0;
                                    while (true)
                                    {
#line 1098 "SequencePathModule.cs"
                                        int csharp2cuda_temp_303 = (first)->count;
                                        if (!(((start) < (csharp2cuda_temp_303))))
                                            break;
#line 1099 "SequencePathModule.cs"
                                        {
#line 1100 "SequencePathModule.cs"
                                            {
#line 1100 "SequencePathModule.cs"
                                                int offset = 0;
                                                while (true)
                                                {
                                                    if (!(((offset) < (width))))
                                                        break;
#line 1101 "SequencePathModule.cs"
                                                    {
#line 1102 "SequencePathModule.cs"
                                                        double left = (result)[csharp2cuda_i32_add(start, offset)];
#line 1103 "SequencePathModule.cs"
                                                        double right = (result)[csharp2cuda_i32_add(csharp2cuda_i32_add(start, width), offset)];
#line 1104 "SequencePathModule.cs"
#line 1104 "SequencePathModule.cs"
                                                        double* csharp2cuda_temp_305 = &((result)[csharp2cuda_i32_add(start, offset)]);
                                                        (*(csharp2cuda_temp_305) = __dadd_rn(left, right));
#line 1105 "SequencePathModule.cs"
#line 1105 "SequencePathModule.cs"
                                                        double* csharp2cuda_temp_306 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_add(start, width), offset)]);
                                                        (*(csharp2cuda_temp_306) = __dsub_rn(left, right));
                                                    }
#line 1100 "SequencePathModule.cs"
                                                    int* csharp2cuda_temp_304 = &(offset);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_304));
                                                }
                                            }
                                        }
#line 1098 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_301 = &(start);
#line 1098 "SequencePathModule.cs"
                                        int csharp2cuda_temp_302 = *(csharp2cuda_temp_301);
                                        (*(csharp2cuda_temp_301) = csharp2cuda_i32_add(csharp2cuda_temp_302, csharp2cuda_i32_mul(2, width)));
                                    }
                                }
                            }
#line 1096 "SequencePathModule.cs"
                            int* csharp2cuda_temp_298 = &(width);
#line 1096 "SequencePathModule.cs"
                            int csharp2cuda_temp_299 = *(csharp2cuda_temp_298);
                            (*(csharp2cuda_temp_298) = csharp2cuda_i32_mul(csharp2cuda_temp_299, 2));
                        }
                    }
#line 1109 "SequencePathModule.cs"
                    int csharp2cuda_temp_307 = (first)->count;
#line 1109 "SequencePathModule.cs"
                    double scale = __ddiv_rn(1.0, mathblocks_square_root(((double)(csharp2cuda_temp_307))));
#line 1110 "SequencePathModule.cs"
                    {
#line 1110 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1110 "SequencePathModule.cs"
                            int csharp2cuda_temp_309 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_309))))
                                break;
#line 1111 "SequencePathModule.cs"
                            {
#line 1112 "SequencePathModule.cs"
#line 1112 "SequencePathModule.cs"
                                double* csharp2cuda_temp_310 = &((result)[index]);
#line 1112 "SequencePathModule.cs"
                                double csharp2cuda_temp_311 = *(csharp2cuda_temp_310);
                                (*(csharp2cuda_temp_310) = __dmul_rn(csharp2cuda_temp_311, scale));
#line 1113 "SequencePathModule.cs"
#line 1113 "SequencePathModule.cs"
                                double csharp2cuda_temp_312 = (result)[index];
                                if ((!(isfinite(csharp2cuda_temp_312))))
                                {
#line 1113 "SequencePathModule.cs"
#line 1113 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_313 = &((output)->valid);
                                    (*(csharp2cuda_temp_313) = 0);
                                }
                            }
#line 1110 "SequencePathModule.cs"
                            int* csharp2cuda_temp_308 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_308));
                        }
                    }
                }
            }
#line 1117 "SequencePathModule.cs"
            break;
#line 1118 "SequencePathModule.cs"
        case 13:
#line 1119 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1120 "SequencePathModule.cs"
            {
#line 1121 "SequencePathModule.cs"
#line 1121 "SequencePathModule.cs"
                int csharp2cuda_temp_314 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_314);
#line 1122 "SequencePathModule.cs"
                double sum = 0.0;
#line 1123 "SequencePathModule.cs"
                {
#line 1123 "SequencePathModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 1123 "SequencePathModule.cs"
                        int csharp2cuda_temp_316 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_316))))
                            break;
#line 1124 "SequencePathModule.cs"
                        {
#line 1125 "SequencePathModule.cs"
#line 1125 "SequencePathModule.cs"
                            double* csharp2cuda_temp_317 = &(sum);
#line 1125 "SequencePathModule.cs"
                            double csharp2cuda_temp_318 = *(csharp2cuda_temp_317);
#line 1125 "SequencePathModule.cs"
                            double csharp2cuda_temp_319 = (a)[index];
#line 1125 "SequencePathModule.cs"
                            double csharp2cuda_temp_320 = (second)->scalar_value;
                            (*(csharp2cuda_temp_317) = __dadd_rn(csharp2cuda_temp_318, __dsub_rn(csharp2cuda_temp_319, csharp2cuda_temp_320)));
#line 1126 "SequencePathModule.cs"
#line 1126 "SequencePathModule.cs"
                            double* csharp2cuda_temp_321 = &((result)[index]);
                            (*(csharp2cuda_temp_321) = sum);
#line 1127 "SequencePathModule.cs"
                            if ((!(isfinite(sum))))
                            {
#line 1128 "SequencePathModule.cs"
#line 1128 "SequencePathModule.cs"
                                int* csharp2cuda_temp_322 = &((output)->valid);
                                (*(csharp2cuda_temp_322) = 0);
                            }
                        }
#line 1123 "SequencePathModule.cs"
                        int* csharp2cuda_temp_315 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_315));
                    }
                }
            }
#line 1131 "SequencePathModule.cs"
            break;
#line 1132 "SequencePathModule.cs"
        case 14:
#line 1133 "SequencePathModule.cs"
            {
#line 1134 "SequencePathModule.cs"
                int rows_count = (first)->count;
#line 1135 "SequencePathModule.cs"
                int columns_count = (second)->count;
#line 1136 "SequencePathModule.cs"
#line 1136 "SequencePathModule.cs"
                bool csharp2cuda_temp_323;
#line 1136 "SequencePathModule.cs"
                if (!(((rows_count) <= (0))))
                {
#line 1136 "SequencePathModule.cs"
                    csharp2cuda_temp_323 = ((columns_count) <= (0));
                }
                else
                {
#line 1136 "SequencePathModule.cs"
                    csharp2cuda_temp_323 = true;
                }
#line 1136 "SequencePathModule.cs"
                bool csharp2cuda_temp_324;
#line 1136 "SequencePathModule.cs"
                if (!(csharp2cuda_temp_323))
                {
#line 1136 "SequencePathModule.cs"
                    csharp2cuda_temp_324 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 1136 "SequencePathModule.cs"
                    csharp2cuda_temp_324 = true;
                }
                if (csharp2cuda_temp_324)
#line 1137 "SequencePathModule.cs"
                {
#line 1138 "SequencePathModule.cs"
                    __syncthreads();
#line 1139 "SequencePathModule.cs"
                    if (((thread) == (0)))
                    {
#line 1140 "SequencePathModule.cs"
#line 1140 "SequencePathModule.cs"
                        int* csharp2cuda_temp_325 = &((output)->valid);
                        (*(csharp2cuda_temp_325) = 0);
                    }
#line 1141 "SequencePathModule.cs"
                    break;
                }
#line 1144 "SequencePathModule.cs"
                double* diagonal_even = scratch;
#line 1145 "SequencePathModule.cs"
                double* diagonal_odd = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_add(columns_count, 1));
#line 1146 "SequencePathModule.cs"
                {
#line 1146 "SequencePathModule.cs"
                    int diagonal = 2;
                    while (true)
                    {
                        if (!(((diagonal) <= (csharp2cuda_i32_add(rows_count, columns_count)))))
                            break;
#line 1147 "SequencePathModule.cs"
                        {
#line 1148 "SequencePathModule.cs"
                            double* csharp2cuda_temp_327;
#line 1148 "SequencePathModule.cs"
                            if (((csharp2cuda_i32_and(diagonal, 1)) == (0)))
                            {
#line 1148 "SequencePathModule.cs"
                                csharp2cuda_temp_327 = diagonal_even;
                            }
                            else
                            {
#line 1148 "SequencePathModule.cs"
                                csharp2cuda_temp_327 = diagonal_odd;
                            }
#line 1148 "SequencePathModule.cs"
                            double* older = csharp2cuda_temp_327;
#line 1149 "SequencePathModule.cs"
                            double* csharp2cuda_temp_328;
#line 1149 "SequencePathModule.cs"
                            if (((csharp2cuda_i32_and(diagonal, 1)) == (0)))
                            {
#line 1149 "SequencePathModule.cs"
                                csharp2cuda_temp_328 = diagonal_odd;
                            }
                            else
                            {
#line 1149 "SequencePathModule.cs"
                                csharp2cuda_temp_328 = diagonal_even;
                            }
#line 1149 "SequencePathModule.cs"
                            double* newer = csharp2cuda_temp_328;
#line 1150 "SequencePathModule.cs"
                            int csharp2cuda_temp_329;
#line 1150 "SequencePathModule.cs"
                            if (((csharp2cuda_i32_sub(diagonal, rows_count)) > (1)))
                            {
#line 1150 "SequencePathModule.cs"
                                csharp2cuda_temp_329 = csharp2cuda_i32_sub(diagonal, rows_count);
                            }
                            else
                            {
#line 1150 "SequencePathModule.cs"
                                csharp2cuda_temp_329 = 1;
                            }
#line 1150 "SequencePathModule.cs"
                            int low = csharp2cuda_temp_329;
#line 1151 "SequencePathModule.cs"
                            int csharp2cuda_temp_330;
#line 1151 "SequencePathModule.cs"
                            if (((columns_count) < (csharp2cuda_i32_sub(diagonal, 1))))
                            {
#line 1151 "SequencePathModule.cs"
                                csharp2cuda_temp_330 = columns_count;
                            }
                            else
                            {
#line 1151 "SequencePathModule.cs"
                                csharp2cuda_temp_330 = csharp2cuda_i32_sub(diagonal, 1);
                            }
#line 1151 "SequencePathModule.cs"
                            int high = csharp2cuda_temp_330;
#line 1152 "SequencePathModule.cs"
                            {
#line 1152 "SequencePathModule.cs"
                                int top = high;
                                while (true)
                                {
                                    if (!(((top) >= (low))))
                                        break;
#line 1153 "SequencePathModule.cs"
                                    {
#line 1154 "SequencePathModule.cs"
                                        int right = csharp2cuda_i32_sub(top, thread);
#line 1155 "SequencePathModule.cs"
                                        bool active = ((right) >= (low));
#line 1156 "SequencePathModule.cs"
                                        double value = 0.0;
#line 1157 "SequencePathModule.cs"
                                        if (active)
#line 1158 "SequencePathModule.cs"
                                        {
#line 1159 "SequencePathModule.cs"
                                            int left = csharp2cuda_i32_sub(diagonal, right);
#line 1160 "SequencePathModule.cs"
                                            double csharp2cuda_temp_333;
#line 1160 "SequencePathModule.cs"
                                            if (((left) == (1)))
                                            {
#line 1160 "SequencePathModule.cs"
                                                csharp2cuda_temp_333 = mathblocks_positive_infinity();
                                            }
                                            else
                                            {
#line 1160 "SequencePathModule.cs"
                                                csharp2cuda_temp_333 = (newer)[right];
                                            }
#line 1160 "SequencePathModule.cs"
                                            double above = csharp2cuda_temp_333;
#line 1161 "SequencePathModule.cs"
                                            double csharp2cuda_temp_334;
#line 1161 "SequencePathModule.cs"
                                            if (((right) == (1)))
                                            {
#line 1161 "SequencePathModule.cs"
                                                csharp2cuda_temp_334 = mathblocks_positive_infinity();
                                            }
                                            else
                                            {
#line 1161 "SequencePathModule.cs"
                                                csharp2cuda_temp_334 = (newer)[csharp2cuda_i32_sub(right, 1)];
                                            }
#line 1161 "SequencePathModule.cs"
                                            double before = csharp2cuda_temp_334;
#line 1162 "SequencePathModule.cs"
                                            bool csharp2cuda_temp_335;
#line 1162 "SequencePathModule.cs"
                                            if (!(((left) == (1))))
                                            {
#line 1162 "SequencePathModule.cs"
                                                csharp2cuda_temp_335 = ((right) == (1));
                                            }
                                            else
                                            {
#line 1162 "SequencePathModule.cs"
                                                csharp2cuda_temp_335 = true;
                                            }
#line 1162 "SequencePathModule.cs"
                                            double csharp2cuda_temp_336;
#line 1162 "SequencePathModule.cs"
                                            if (csharp2cuda_temp_335)
                                            {
#line 1163 "SequencePathModule.cs"
                                                bool csharp2cuda_temp_337;
#line 1163 "SequencePathModule.cs"
                                                if (((left) == (1)))
                                                {
#line 1163 "SequencePathModule.cs"
                                                    csharp2cuda_temp_337 = ((right) == (1));
                                                }
                                                else
                                                {
#line 1163 "SequencePathModule.cs"
                                                    csharp2cuda_temp_337 = false;
                                                }
#line 1163 "SequencePathModule.cs"
                                                double csharp2cuda_temp_338;
#line 1163 "SequencePathModule.cs"
                                                if (csharp2cuda_temp_337)
                                                {
#line 1163 "SequencePathModule.cs"
                                                    csharp2cuda_temp_338 = 0.0;
                                                }
                                                else
                                                {
#line 1163 "SequencePathModule.cs"
                                                    csharp2cuda_temp_338 = mathblocks_positive_infinity();
                                                }
#line 1162 "SequencePathModule.cs"
                                                csharp2cuda_temp_336 = csharp2cuda_temp_338;
                                            }
                                            else
                                            {
#line 1162 "SequencePathModule.cs"
                                                csharp2cuda_temp_336 = (older)[csharp2cuda_i32_sub(right, 1)];
                                            }
#line 1162 "SequencePathModule.cs"
                                            double corner = csharp2cuda_temp_336;
#line 1165 "SequencePathModule.cs"
                                            double csharp2cuda_temp_339;
#line 1165 "SequencePathModule.cs"
                                            if (((above) < (before)))
                                            {
#line 1165 "SequencePathModule.cs"
                                                csharp2cuda_temp_339 = above;
                                            }
                                            else
                                            {
#line 1165 "SequencePathModule.cs"
                                                csharp2cuda_temp_339 = before;
                                            }
#line 1165 "SequencePathModule.cs"
                                            double minimum = csharp2cuda_temp_339;
#line 1166 "SequencePathModule.cs"
#line 1166 "SequencePathModule.cs"
                                            double* csharp2cuda_temp_340 = &(minimum);
#line 1166 "SequencePathModule.cs"
                                            double csharp2cuda_temp_341;
#line 1166 "SequencePathModule.cs"
                                            if (((minimum) < (corner)))
                                            {
#line 1166 "SequencePathModule.cs"
                                                csharp2cuda_temp_341 = minimum;
                                            }
                                            else
                                            {
#line 1166 "SequencePathModule.cs"
                                                csharp2cuda_temp_341 = corner;
                                            }
                                            (*(csharp2cuda_temp_340) = csharp2cuda_temp_341);
#line 1167 "SequencePathModule.cs"
#line 1167 "SequencePathModule.cs"
                                            double* csharp2cuda_temp_342 = &(value);
#line 1167 "SequencePathModule.cs"
                                            double csharp2cuda_temp_343 = (a)[csharp2cuda_i32_sub(left, 1)];
#line 1167 "SequencePathModule.cs"
                                            double csharp2cuda_temp_344 = (b)[csharp2cuda_i32_sub(right, 1)];
                                            (*(csharp2cuda_temp_342) = __dadd_rn(fabs(__dsub_rn(csharp2cuda_temp_343, csharp2cuda_temp_344)), minimum));
                                        }
#line 1169 "SequencePathModule.cs"
                                        __syncthreads();
#line 1170 "SequencePathModule.cs"
                                        if (active)
                                        {
#line 1171 "SequencePathModule.cs"
#line 1171 "SequencePathModule.cs"
                                            double* csharp2cuda_temp_345 = &((older)[right]);
                                            (*(csharp2cuda_temp_345) = value);
                                        }
#line 1172 "SequencePathModule.cs"
                                        __syncthreads();
                                    }
#line 1152 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_331 = &(top);
#line 1152 "SequencePathModule.cs"
                                    int csharp2cuda_temp_332 = *(csharp2cuda_temp_331);
                                    (*(csharp2cuda_temp_331) = csharp2cuda_i32_sub(csharp2cuda_temp_332, blockDim.x));
                                }
                            }
                        }
#line 1146 "SequencePathModule.cs"
                        int* csharp2cuda_temp_326 = &(diagonal);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_326));
                    }
                }
#line 1176 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 1177 "SequencePathModule.cs"
                {
#line 1178 "SequencePathModule.cs"
                    double* csharp2cuda_temp_346;
#line 1178 "SequencePathModule.cs"
                    if (((csharp2cuda_i32_and(csharp2cuda_i32_add(rows_count, columns_count), 1)) == (0)))
                    {
#line 1178 "SequencePathModule.cs"
                        csharp2cuda_temp_346 = diagonal_even;
                    }
                    else
                    {
#line 1178 "SequencePathModule.cs"
                        csharp2cuda_temp_346 = diagonal_odd;
                    }
#line 1178 "SequencePathModule.cs"
                    double* last = csharp2cuda_temp_346;
#line 1179 "SequencePathModule.cs"
#line 1179 "SequencePathModule.cs"
                    double* csharp2cuda_temp_347 = &((output)->scalar_value);
#line 1179 "SequencePathModule.cs"
                    double csharp2cuda_temp_348 = (last)[columns_count];
                    (*(csharp2cuda_temp_347) = csharp2cuda_temp_348);
#line 1180 "SequencePathModule.cs"
#line 1180 "SequencePathModule.cs"
                    double csharp2cuda_temp_349 = (output)->scalar_value;
                    if ((!(isfinite(csharp2cuda_temp_349))))
                    {
#line 1181 "SequencePathModule.cs"
#line 1181 "SequencePathModule.cs"
                        int* csharp2cuda_temp_350 = &((output)->valid);
                        (*(csharp2cuda_temp_350) = 0);
                    }
                }
            }
#line 1184 "SequencePathModule.cs"
            break;
#line 1185 "SequencePathModule.cs"
        case 15:
#line 1186 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1187 "SequencePathModule.cs"
            {
#line 1188 "SequencePathModule.cs"
#line 1188 "SequencePathModule.cs"
                double* csharp2cuda_temp_351 = &((output)->scalar_value);
#line 1190 "SequencePathModule.cs"
                int csharp2cuda_temp_352 = (first)->count;
#line 1191 "SequencePathModule.cs"
                double csharp2cuda_temp_353 = (second)->scalar_value;
#line 1192 "SequencePathModule.cs"
                int csharp2cuda_temp_354 = (third)->boolean_value;
#line 1188 "SequencePathModule.cs"
                double csharp2cuda_temp_355 = mathblocks_sequence_first_passage_value(a, csharp2cuda_temp_352, csharp2cuda_temp_353, ((csharp2cuda_temp_354) != (0)));
                (*(csharp2cuda_temp_351) = csharp2cuda_temp_355);
            }
#line 1194 "SequencePathModule.cs"
            break;
#line 1195 "SequencePathModule.cs"
        case 16:
#line 1196 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1197 "SequencePathModule.cs"
            {
#line 1198 "SequencePathModule.cs"
                double lower = (second)->scalar_value;
#line 1199 "SequencePathModule.cs"
                double upper = (third)->scalar_value;
#line 1200 "SequencePathModule.cs"
#line 1200 "SequencePathModule.cs"
                int csharp2cuda_temp_356 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_356);
#line 1201 "SequencePathModule.cs"
                if ((!(((lower) < (upper)))))
#line 1202 "SequencePathModule.cs"
                {
#line 1203 "SequencePathModule.cs"
#line 1203 "SequencePathModule.cs"
                    int* csharp2cuda_temp_357 = &((output)->valid);
                    (*(csharp2cuda_temp_357) = 0);
                }
                else
#line 1206 "SequencePathModule.cs"
                {
#line 1207 "SequencePathModule.cs"
                    double state = 0.0;
#line 1208 "SequencePathModule.cs"
                    {
#line 1208 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1208 "SequencePathModule.cs"
                            int csharp2cuda_temp_359 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_359))))
                                break;
#line 1209 "SequencePathModule.cs"
                            {
#line 1210 "SequencePathModule.cs"
#line 1210 "SequencePathModule.cs"
                                double csharp2cuda_temp_360 = (a)[index];
                                if (((csharp2cuda_temp_360) >= (upper)))
                                {
#line 1211 "SequencePathModule.cs"
#line 1211 "SequencePathModule.cs"
                                    double* csharp2cuda_temp_361 = &(state);
                                    (*(csharp2cuda_temp_361) = 1.0);
                                }
                                else
                                {
#line 1212 "SequencePathModule.cs"
#line 1212 "SequencePathModule.cs"
                                    double csharp2cuda_temp_362 = (a)[index];
                                    if (((csharp2cuda_temp_362) <= (lower)))
                                    {
#line 1213 "SequencePathModule.cs"
#line 1213 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_363 = &(state);
                                        (*(csharp2cuda_temp_363) = (-(1.0)));
                                    }
                                }
#line 1214 "SequencePathModule.cs"
#line 1214 "SequencePathModule.cs"
                                double* csharp2cuda_temp_364 = &((result)[index]);
                                (*(csharp2cuda_temp_364) = state);
                            }
#line 1208 "SequencePathModule.cs"
                            int* csharp2cuda_temp_358 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_358));
                        }
                    }
                }
            }
#line 1218 "SequencePathModule.cs"
            break;
#line 1219 "SequencePathModule.cs"
        case 17:
#line 1220 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1221 "SequencePathModule.cs"
            {
#line 1222 "SequencePathModule.cs"
                int csharp2cuda_temp_365 = (first)->count;
#line 1222 "SequencePathModule.cs"
                int csharp2cuda_temp_366;
#line 1222 "SequencePathModule.cs"
                if (((csharp2cuda_temp_365) == (0)))
                {
#line 1222 "SequencePathModule.cs"
                    csharp2cuda_temp_366 = 0;
                }
                else
                {
#line 1222 "SequencePathModule.cs"
                    int csharp2cuda_temp_367 = (first)->count;
#line 1222 "SequencePathModule.cs"
                    csharp2cuda_temp_366 = csharp2cuda_i32_sub(csharp2cuda_i32_mul(2, csharp2cuda_temp_367), 1);
                }
#line 1222 "SequencePathModule.cs"
                int rows = csharp2cuda_temp_366;
#line 1223 "SequencePathModule.cs"
                mathblocks_sequence_set_matrix_shape(output, rows, 2);
#line 1224 "SequencePathModule.cs"
#line 1224 "SequencePathModule.cs"
                int csharp2cuda_temp_368 = (first)->count;
                if (((csharp2cuda_temp_368) <= (0)))
#line 1225 "SequencePathModule.cs"
                {
#line 1226 "SequencePathModule.cs"
#line 1226 "SequencePathModule.cs"
                    int* csharp2cuda_temp_369 = &((output)->valid);
                    (*(csharp2cuda_temp_369) = 0);
                }
                else
#line 1229 "SequencePathModule.cs"
                {
#line 1230 "SequencePathModule.cs"
#line 1230 "SequencePathModule.cs"
                    double* csharp2cuda_temp_370 = &((result)[0]);
#line 1230 "SequencePathModule.cs"
                    double csharp2cuda_temp_371 = (a)[0];
                    (*(csharp2cuda_temp_370) = csharp2cuda_temp_371);
#line 1231 "SequencePathModule.cs"
#line 1231 "SequencePathModule.cs"
                    double* csharp2cuda_temp_372 = &((result)[1]);
#line 1231 "SequencePathModule.cs"
                    double csharp2cuda_temp_373 = (a)[0];
                    (*(csharp2cuda_temp_372) = csharp2cuda_temp_373);
#line 1232 "SequencePathModule.cs"
                    int row = 0;
#line 1233 "SequencePathModule.cs"
                    {
#line 1233 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 1233 "SequencePathModule.cs"
                            int csharp2cuda_temp_375 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_375))))
                                break;
#line 1234 "SequencePathModule.cs"
                            {
#line 1235 "SequencePathModule.cs"
#line 1235 "SequencePathModule.cs"
                                int* csharp2cuda_temp_376 = &(row);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_376));
#line 1236 "SequencePathModule.cs"
#line 1236 "SequencePathModule.cs"
                                double* csharp2cuda_temp_377 = &((result)[csharp2cuda_i32_mul(row, 2)]);
#line 1236 "SequencePathModule.cs"
                                double csharp2cuda_temp_378 = (a)[index];
                                (*(csharp2cuda_temp_377) = csharp2cuda_temp_378);
#line 1237 "SequencePathModule.cs"
#line 1237 "SequencePathModule.cs"
                                double* csharp2cuda_temp_379 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, 2), 1)]);
#line 1237 "SequencePathModule.cs"
                                double csharp2cuda_temp_380 = (a)[csharp2cuda_i32_sub(index, 1)];
                                (*(csharp2cuda_temp_379) = csharp2cuda_temp_380);
#line 1238 "SequencePathModule.cs"
#line 1238 "SequencePathModule.cs"
                                int* csharp2cuda_temp_381 = &(row);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_381));
#line 1239 "SequencePathModule.cs"
#line 1239 "SequencePathModule.cs"
                                double* csharp2cuda_temp_382 = &((result)[csharp2cuda_i32_mul(row, 2)]);
#line 1239 "SequencePathModule.cs"
                                double csharp2cuda_temp_383 = (a)[index];
                                (*(csharp2cuda_temp_382) = csharp2cuda_temp_383);
#line 1240 "SequencePathModule.cs"
#line 1240 "SequencePathModule.cs"
                                double* csharp2cuda_temp_384 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, 2), 1)]);
#line 1240 "SequencePathModule.cs"
                                double csharp2cuda_temp_385 = (a)[index];
                                (*(csharp2cuda_temp_384) = csharp2cuda_temp_385);
                            }
#line 1233 "SequencePathModule.cs"
                            int* csharp2cuda_temp_374 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_374));
                        }
                    }
                }
            }
#line 1244 "SequencePathModule.cs"
            break;
#line 1245 "SequencePathModule.cs"
        case 18:
#line 1246 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1247 "SequencePathModule.cs"
#line 1247 "SequencePathModule.cs"
                double* csharp2cuda_temp_386 = &((output)->scalar_value);
#line 1247 "SequencePathModule.cs"
                int csharp2cuda_temp_387 = (first)->count;
#line 1247 "SequencePathModule.cs"
                double csharp2cuda_temp_388 = mathblocks_sequence_longest_run_value(boolean_a, csharp2cuda_temp_387);
                (*(csharp2cuda_temp_386) = csharp2cuda_temp_388);
            }
#line 1248 "SequencePathModule.cs"
            break;
#line 1249 "SequencePathModule.cs"
        case 19:
        case 20:
#line 1251 "SequencePathModule.cs"
#line 1251 "SequencePathModule.cs"
            bool csharp2cuda_temp_389;
#line 1251 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1252 "SequencePathModule.cs"
                int csharp2cuda_temp_390 = (first)->count;
#line 1252 "SequencePathModule.cs"
                double* csharp2cuda_temp_391 = &((output)->scalar_value);
#line 1252 "SequencePathModule.cs"
                bool csharp2cuda_temp_392 = mathblocks_sequence_decline_value(a, csharp2cuda_temp_390, ((opcode) == (20)), csharp2cuda_temp_391);
#line 1251 "SequencePathModule.cs"
                csharp2cuda_temp_389 = (!(csharp2cuda_temp_392));
            }
            else
            {
#line 1251 "SequencePathModule.cs"
                csharp2cuda_temp_389 = false;
            }
            if (csharp2cuda_temp_389)
            {
#line 1253 "SequencePathModule.cs"
#line 1253 "SequencePathModule.cs"
                int* csharp2cuda_temp_393 = &((output)->valid);
                (*(csharp2cuda_temp_393) = 0);
            }
#line 1254 "SequencePathModule.cs"
            break;
#line 1255 "SequencePathModule.cs"
        case 21:
        case 22:
        case 29:
#line 1258 "SequencePathModule.cs"
#line 1258 "SequencePathModule.cs"
            bool csharp2cuda_temp_394;
#line 1258 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1261 "SequencePathModule.cs"
                int csharp2cuda_temp_395 = (first)->count;
#line 1262 "SequencePathModule.cs"
                double csharp2cuda_temp_396;
#line 1262 "SequencePathModule.cs"
                if (((opcode) == (22)))
                {
#line 1262 "SequencePathModule.cs"
                    csharp2cuda_temp_396 = 2.0;
                }
                else
                {
#line 1262 "SequencePathModule.cs"
                    double csharp2cuda_temp_397;
#line 1262 "SequencePathModule.cs"
                    if (((((void*)(second))) == (((void*)(nullptr)))))
                    {
#line 1262 "SequencePathModule.cs"
                        csharp2cuda_temp_397 = 1.0;
                    }
                    else
                    {
#line 1262 "SequencePathModule.cs"
                        csharp2cuda_temp_397 = (second)->scalar_value;
                    }
#line 1262 "SequencePathModule.cs"
                    csharp2cuda_temp_396 = csharp2cuda_temp_397;
                }
#line 1264 "SequencePathModule.cs"
                double* csharp2cuda_temp_398 = &((output)->scalar_value);
#line 1259 "SequencePathModule.cs"
                bool csharp2cuda_temp_399 = mathblocks_sequence_variation_value(a, csharp2cuda_temp_395, csharp2cuda_temp_396, ((opcode) == (29)), csharp2cuda_temp_398);
#line 1258 "SequencePathModule.cs"
                csharp2cuda_temp_394 = (!(csharp2cuda_temp_399));
            }
            else
            {
#line 1258 "SequencePathModule.cs"
                csharp2cuda_temp_394 = false;
            }
            if (csharp2cuda_temp_394)
            {
#line 1265 "SequencePathModule.cs"
#line 1265 "SequencePathModule.cs"
                int* csharp2cuda_temp_400 = &((output)->valid);
                (*(csharp2cuda_temp_400) = 0);
            }
#line 1266 "SequencePathModule.cs"
            break;
#line 1267 "SequencePathModule.cs"
        case 23:
#line 1268 "SequencePathModule.cs"
#line 1268 "SequencePathModule.cs"
            bool csharp2cuda_temp_401;
#line 1268 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1271 "SequencePathModule.cs"
                int csharp2cuda_temp_402 = (first)->count;
#line 1272 "SequencePathModule.cs"
                double csharp2cuda_temp_403 = (second)->scalar_value;
#line 1273 "SequencePathModule.cs"
                double* csharp2cuda_temp_404 = &((output)->scalar_value);
#line 1269 "SequencePathModule.cs"
                bool csharp2cuda_temp_405 = mathblocks_sequence_recurrence_value(a, csharp2cuda_temp_402, csharp2cuda_temp_403, csharp2cuda_temp_404);
#line 1268 "SequencePathModule.cs"
                csharp2cuda_temp_401 = (!(csharp2cuda_temp_405));
            }
            else
            {
#line 1268 "SequencePathModule.cs"
                csharp2cuda_temp_401 = false;
            }
            if (csharp2cuda_temp_401)
            {
#line 1274 "SequencePathModule.cs"
#line 1274 "SequencePathModule.cs"
                int* csharp2cuda_temp_406 = &((output)->valid);
                (*(csharp2cuda_temp_406) = 0);
            }
#line 1275 "SequencePathModule.cs"
            break;
#line 1276 "SequencePathModule.cs"
        case 24:
#line 1277 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1278 "SequencePathModule.cs"
            {
#line 1279 "SequencePathModule.cs"
#line 1279 "SequencePathModule.cs"
                int csharp2cuda_temp_407 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_407);
#line 1280 "SequencePathModule.cs"
#line 1280 "SequencePathModule.cs"
                int csharp2cuda_temp_408 = (first)->count;
                if (((csharp2cuda_temp_408) <= (0)))
#line 1281 "SequencePathModule.cs"
                {
#line 1282 "SequencePathModule.cs"
#line 1282 "SequencePathModule.cs"
                    int* csharp2cuda_temp_409 = &((output)->valid);
                    (*(csharp2cuda_temp_409) = 0);
                }
                else
#line 1285 "SequencePathModule.cs"
                {
#line 1286 "SequencePathModule.cs"
                    double cumulative = 0.0;
#line 1287 "SequencePathModule.cs"
                    double minimum = 0.0;
#line 1288 "SequencePathModule.cs"
                    {
#line 1288 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1288 "SequencePathModule.cs"
                            int csharp2cuda_temp_411 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_411))))
                                break;
#line 1289 "SequencePathModule.cs"
                            {
#line 1290 "SequencePathModule.cs"
#line 1290 "SequencePathModule.cs"
                                double* csharp2cuda_temp_412 = &(cumulative);
#line 1290 "SequencePathModule.cs"
                                double csharp2cuda_temp_413 = *(csharp2cuda_temp_412);
#line 1290 "SequencePathModule.cs"
                                double csharp2cuda_temp_414 = (a)[index];
                                (*(csharp2cuda_temp_412) = __dadd_rn(csharp2cuda_temp_413, csharp2cuda_temp_414));
#line 1291 "SequencePathModule.cs"
#line 1291 "SequencePathModule.cs"
                                double* csharp2cuda_temp_415 = &(minimum);
#line 1291 "SequencePathModule.cs"
                                double csharp2cuda_temp_416;
#line 1291 "SequencePathModule.cs"
                                if (((minimum) < (cumulative)))
                                {
#line 1291 "SequencePathModule.cs"
                                    csharp2cuda_temp_416 = minimum;
                                }
                                else
                                {
#line 1291 "SequencePathModule.cs"
                                    csharp2cuda_temp_416 = cumulative;
                                }
                                (*(csharp2cuda_temp_415) = csharp2cuda_temp_416);
#line 1292 "SequencePathModule.cs"
#line 1292 "SequencePathModule.cs"
                                double* csharp2cuda_temp_417 = &((result)[index]);
                                (*(csharp2cuda_temp_417) = __dsub_rn(cumulative, minimum));
#line 1293 "SequencePathModule.cs"
#line 1293 "SequencePathModule.cs"
                                double csharp2cuda_temp_418 = (result)[index];
                                if ((!(isfinite(csharp2cuda_temp_418))))
                                {
#line 1294 "SequencePathModule.cs"
#line 1294 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_419 = &((output)->valid);
                                    (*(csharp2cuda_temp_419) = 0);
                                }
                            }
#line 1288 "SequencePathModule.cs"
                            int* csharp2cuda_temp_410 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_410));
                        }
                    }
                }
            }
#line 1298 "SequencePathModule.cs"
            break;
#line 1299 "SequencePathModule.cs"
        case 25:
#line 1300 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1301 "SequencePathModule.cs"
            {
#line 1302 "SequencePathModule.cs"
                unsigned long long csharp2cuda_temp_420 = (output)->data_pointer;
#line 1302 "SequencePathModule.cs"
                MathBlockSequencePathRun* runs = ((MathBlockSequencePathRun*)(csharp2cuda_temp_420));
#line 1303 "SequencePathModule.cs"
#line 1303 "SequencePathModule.cs"
                int csharp2cuda_temp_421 = (first)->count;
                if (((csharp2cuda_temp_421) == (0)))
#line 1304 "SequencePathModule.cs"
                {
#line 1305 "SequencePathModule.cs"
#line 1305 "SequencePathModule.cs"
                    int* csharp2cuda_temp_422 = &((output)->count);
                    (*(csharp2cuda_temp_422) = 0);
#line 1306 "SequencePathModule.cs"
#line 1306 "SequencePathModule.cs"
                    int* csharp2cuda_temp_423 = &((output)->rows);
                    (*(csharp2cuda_temp_423) = 0);
                }
                else
#line 1309 "SequencePathModule.cs"
                {
#line 1310 "SequencePathModule.cs"
                    int start = 0;
#line 1311 "SequencePathModule.cs"
                    int count = 0;
#line 1312 "SequencePathModule.cs"
                    {
#line 1312 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 1312 "SequencePathModule.cs"
                            int csharp2cuda_temp_425 = (first)->count;
                            if (!(((index) <= (csharp2cuda_temp_425))))
                                break;
#line 1313 "SequencePathModule.cs"
                            {
#line 1314 "SequencePathModule.cs"
#line 1314 "SequencePathModule.cs"
                                int csharp2cuda_temp_426 = (first)->count;
#line 1314 "SequencePathModule.cs"
                                bool csharp2cuda_temp_427;
#line 1314 "SequencePathModule.cs"
                                if (((index) < (csharp2cuda_temp_426)))
                                {
#line 1314 "SequencePathModule.cs"
                                    double csharp2cuda_temp_428 = (a)[index];
#line 1314 "SequencePathModule.cs"
                                    double csharp2cuda_temp_429 = (a)[start];
#line 1314 "SequencePathModule.cs"
                                    csharp2cuda_temp_427 = ((csharp2cuda_temp_428) == (csharp2cuda_temp_429));
                                }
                                else
                                {
#line 1314 "SequencePathModule.cs"
                                    csharp2cuda_temp_427 = false;
                                }
                                if (csharp2cuda_temp_427)
                                {
#line 1315 "SequencePathModule.cs"
                                    goto csharp2cuda_for_continue_34;
                                }
#line 1316 "SequencePathModule.cs"
#line 1316 "SequencePathModule.cs"
                                int csharp2cuda_temp_430 = (output)->capacity;
                                if (((count) >= (csharp2cuda_temp_430)))
#line 1317 "SequencePathModule.cs"
                                {
#line 1318 "SequencePathModule.cs"
#line 1318 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_431 = &((output)->count);
#line 1318 "SequencePathModule.cs"
                                    int csharp2cuda_temp_432 = (output)->capacity;
#line 1318 "SequencePathModule.cs"
                                    int csharp2cuda_temp_433;
#line 1318 "SequencePathModule.cs"
                                    if (((csharp2cuda_temp_432) == (2147483647)))
                                    {
#line 1318 "SequencePathModule.cs"
                                        csharp2cuda_temp_433 = csharp2cuda_i32_neg(1);
                                    }
                                    else
                                    {
#line 1320 "SequencePathModule.cs"
                                        int csharp2cuda_temp_434 = (output)->capacity;
#line 1318 "SequencePathModule.cs"
                                        csharp2cuda_temp_433 = csharp2cuda_i32_add(csharp2cuda_temp_434, 1);
                                    }
                                    (*(csharp2cuda_temp_431) = csharp2cuda_temp_433);
#line 1321 "SequencePathModule.cs"
#line 1321 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_435 = &((output)->rows);
#line 1321 "SequencePathModule.cs"
                                    int csharp2cuda_temp_436 = (output)->count;
                                    (*(csharp2cuda_temp_435) = csharp2cuda_temp_436);
#line 1322 "SequencePathModule.cs"
#line 1322 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_437 = &((output)->valid);
                                    (*(csharp2cuda_temp_437) = 0);
#line 1323 "SequencePathModule.cs"
                                    break;
                                }
#line 1325 "SequencePathModule.cs"
#line 1325 "SequencePathModule.cs"
                                int* csharp2cuda_temp_438 = &(((runs)[count]).start);
                                (*(csharp2cuda_temp_438) = start);
#line 1326 "SequencePathModule.cs"
#line 1326 "SequencePathModule.cs"
                                int* csharp2cuda_temp_439 = &(((runs)[count]).length);
                                (*(csharp2cuda_temp_439) = csharp2cuda_i32_sub(index, start));
#line 1327 "SequencePathModule.cs"
#line 1327 "SequencePathModule.cs"
                                double* csharp2cuda_temp_440 = &(((runs)[count]).value);
#line 1327 "SequencePathModule.cs"
                                double csharp2cuda_temp_441 = (a)[start];
                                (*(csharp2cuda_temp_440) = csharp2cuda_temp_441);
#line 1328 "SequencePathModule.cs"
#line 1328 "SequencePathModule.cs"
                                int* csharp2cuda_temp_442 = &(count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_442));
#line 1329 "SequencePathModule.cs"
#line 1329 "SequencePathModule.cs"
                                int* csharp2cuda_temp_443 = &(start);
                                (*(csharp2cuda_temp_443) = index);
                            }
                            csharp2cuda_for_continue_34:
#line 1312 "SequencePathModule.cs"
                            int* csharp2cuda_temp_424 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_424));
                        }
                    }
#line 1331 "SequencePathModule.cs"
                    if ((output)->valid)
#line 1332 "SequencePathModule.cs"
                    {
#line 1333 "SequencePathModule.cs"
#line 1333 "SequencePathModule.cs"
                        int* csharp2cuda_temp_444 = &((output)->count);
                        (*(csharp2cuda_temp_444) = count);
#line 1334 "SequencePathModule.cs"
#line 1334 "SequencePathModule.cs"
                        int* csharp2cuda_temp_445 = &((output)->rows);
                        (*(csharp2cuda_temp_445) = count);
                    }
                }
            }
#line 1338 "SequencePathModule.cs"
            break;
#line 1339 "SequencePathModule.cs"
        case 26:
#line 1340 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1341 "SequencePathModule.cs"
            {
#line 1342 "SequencePathModule.cs"
#line 1342 "SequencePathModule.cs"
                int csharp2cuda_temp_446 = (first)->columns;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_446);
#line 1343 "SequencePathModule.cs"
#line 1343 "SequencePathModule.cs"
                int csharp2cuda_temp_447 = (first)->rows;
                if (((csharp2cuda_temp_447) <= (0)))
#line 1344 "SequencePathModule.cs"
                {
#line 1345 "SequencePathModule.cs"
#line 1345 "SequencePathModule.cs"
                    int* csharp2cuda_temp_448 = &((output)->valid);
                    (*(csharp2cuda_temp_448) = 0);
                }
                else
#line 1348 "SequencePathModule.cs"
                {
#line 1349 "SequencePathModule.cs"
                    {
#line 1349 "SequencePathModule.cs"
                        int column = 0;
                        while (true)
                        {
#line 1349 "SequencePathModule.cs"
                            int csharp2cuda_temp_450 = (first)->columns;
                            if (!(((column) < (csharp2cuda_temp_450))))
                                break;
#line 1350 "SequencePathModule.cs"
                            {
#line 1351 "SequencePathModule.cs"
#line 1351 "SequencePathModule.cs"
                                double* csharp2cuda_temp_451 = &((result)[column]);
#line 1351 "SequencePathModule.cs"
                                int csharp2cuda_temp_452 = (first)->rows;
#line 1351 "SequencePathModule.cs"
                                int csharp2cuda_temp_453 = (first)->columns;
#line 1351 "SequencePathModule.cs"
                                double csharp2cuda_temp_454 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(csharp2cuda_temp_452, 1), csharp2cuda_temp_453), column)];
#line 1351 "SequencePathModule.cs"
                                double csharp2cuda_temp_455 = (a)[column];
                                (*(csharp2cuda_temp_451) = __dsub_rn(csharp2cuda_temp_454, csharp2cuda_temp_455));
#line 1352 "SequencePathModule.cs"
#line 1352 "SequencePathModule.cs"
                                double csharp2cuda_temp_456 = (result)[column];
                                if ((!(isfinite(csharp2cuda_temp_456))))
                                {
#line 1352 "SequencePathModule.cs"
#line 1352 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_457 = &((output)->valid);
                                    (*(csharp2cuda_temp_457) = 0);
                                }
                            }
#line 1349 "SequencePathModule.cs"
                            int* csharp2cuda_temp_449 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_449));
                        }
                    }
                }
            }
#line 1356 "SequencePathModule.cs"
            break;
#line 1357 "SequencePathModule.cs"
        case 27:
#line 1358 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1359 "SequencePathModule.cs"
            {
#line 1360 "SequencePathModule.cs"
                int dimension = (first)->columns;
#line 1361 "SequencePathModule.cs"
                int count = csharp2cuda_i32_mul(csharp2cuda_i32_mul(dimension, dimension), dimension);
#line 1362 "SequencePathModule.cs"
                mathblocks_sequence_set_vector_shape(output, count);
#line 1363 "SequencePathModule.cs"
#line 1363 "SequencePathModule.cs"
                int csharp2cuda_temp_458 = (first)->rows;
#line 1363 "SequencePathModule.cs"
                bool csharp2cuda_temp_459;
#line 1363 "SequencePathModule.cs"
                if (!(((csharp2cuda_temp_458) < (1))))
                {
#line 1363 "SequencePathModule.cs"
                    csharp2cuda_temp_459 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 1363 "SequencePathModule.cs"
                    csharp2cuda_temp_459 = true;
                }
                if (csharp2cuda_temp_459)
#line 1364 "SequencePathModule.cs"
                {
#line 1365 "SequencePathModule.cs"
#line 1365 "SequencePathModule.cs"
                    int* csharp2cuda_temp_460 = &((output)->valid);
                    (*(csharp2cuda_temp_460) = 0);
                }
                else
#line 1368 "SequencePathModule.cs"
                {
#line 1369 "SequencePathModule.cs"
                    double* level_one = scratch;
#line 1370 "SequencePathModule.cs"
                    double* level_two = csharp2cuda_pointer_add(scratch, dimension);
#line 1371 "SequencePathModule.cs"
                    double* increment = csharp2cuda_pointer_add(level_two, csharp2cuda_i32_mul(dimension, dimension));
#line 1372 "SequencePathModule.cs"
                    {
#line 1372 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (dimension))))
                                break;
#line 1373 "SequencePathModule.cs"
#line 1373 "SequencePathModule.cs"
                            double* csharp2cuda_temp_462 = &((level_one)[index]);
                            (*(csharp2cuda_temp_462) = 0.0);
#line 1372 "SequencePathModule.cs"
                            int* csharp2cuda_temp_461 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_461));
                        }
                    }
#line 1374 "SequencePathModule.cs"
                    {
#line 1374 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(dimension, dimension)))))
                                break;
#line 1375 "SequencePathModule.cs"
#line 1375 "SequencePathModule.cs"
                            double* csharp2cuda_temp_464 = &((level_two)[index]);
                            (*(csharp2cuda_temp_464) = 0.0);
#line 1374 "SequencePathModule.cs"
                            int* csharp2cuda_temp_463 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_463));
                        }
                    }
#line 1376 "SequencePathModule.cs"
                    {
#line 1376 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (count))))
                                break;
#line 1377 "SequencePathModule.cs"
#line 1377 "SequencePathModule.cs"
                            double* csharp2cuda_temp_466 = &((result)[index]);
                            (*(csharp2cuda_temp_466) = 0.0);
#line 1376 "SequencePathModule.cs"
                            int* csharp2cuda_temp_465 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_465));
                        }
                    }
#line 1378 "SequencePathModule.cs"
                    {
#line 1378 "SequencePathModule.cs"
                        int row = 1;
                        while (true)
                        {
#line 1378 "SequencePathModule.cs"
                            int csharp2cuda_temp_468 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_468))))
                                break;
#line 1379 "SequencePathModule.cs"
                            {
#line 1380 "SequencePathModule.cs"
                                {
#line 1380 "SequencePathModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
                                        if (!(((index) < (dimension))))
                                            break;
#line 1381 "SequencePathModule.cs"
#line 1381 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_470 = &((increment)[index]);
#line 1381 "SequencePathModule.cs"
                                        double csharp2cuda_temp_471 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, dimension), index)];
#line 1381 "SequencePathModule.cs"
                                        double csharp2cuda_temp_472 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(row, 1), dimension), index)];
                                        (*(csharp2cuda_temp_470) = __dsub_rn(csharp2cuda_temp_471, csharp2cuda_temp_472));
#line 1380 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_469 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_469));
                                    }
                                }
#line 1382 "SequencePathModule.cs"
                                {
#line 1382 "SequencePathModule.cs"
                                    int left = 0;
                                    while (true)
                                    {
                                        if (!(((left) < (dimension))))
                                            break;
#line 1383 "SequencePathModule.cs"
                                        {
#line 1384 "SequencePathModule.cs"
                                            {
#line 1384 "SequencePathModule.cs"
                                                int middle = 0;
                                                while (true)
                                                {
                                                    if (!(((middle) < (dimension))))
                                                        break;
#line 1385 "SequencePathModule.cs"
                                                    {
#line 1386 "SequencePathModule.cs"
                                                        {
#line 1386 "SequencePathModule.cs"
                                                            int right = 0;
                                                            while (true)
                                                            {
                                                                if (!(((right) < (dimension))))
                                                                    break;
#line 1387 "SequencePathModule.cs"
                                                                {
#line 1388 "SequencePathModule.cs"
                                                                    int target = csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), middle), dimension), right);
#line 1389 "SequencePathModule.cs"
#line 1389 "SequencePathModule.cs"
                                                                    double* csharp2cuda_temp_476 = &((result)[target]);
#line 1389 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_477 = *(csharp2cuda_temp_476);
#line 1390 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_478 = (level_two)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), middle)];
#line 1390 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_479 = (increment)[right];
#line 1391 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_480 = (level_one)[left];
#line 1391 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_481 = (increment)[middle];
#line 1391 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_482 = (increment)[right];
#line 1391 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_483 = __ddiv_rn(__dmul_rn(__dmul_rn(csharp2cuda_temp_480, csharp2cuda_temp_481), csharp2cuda_temp_482), 2.0);
#line 1392 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_484 = (increment)[left];
#line 1392 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_485 = (increment)[middle];
#line 1392 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_486 = (increment)[right];
#line 1392 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_487 = __ddiv_rn(__dmul_rn(__dmul_rn(csharp2cuda_temp_484, csharp2cuda_temp_485), csharp2cuda_temp_486), 6.0);
                                                                    (*(csharp2cuda_temp_476) = __dadd_rn(csharp2cuda_temp_477, __dadd_rn(__dadd_rn(__dmul_rn(csharp2cuda_temp_478, csharp2cuda_temp_479), csharp2cuda_temp_483), csharp2cuda_temp_487)));
                                                                }
#line 1386 "SequencePathModule.cs"
                                                                int* csharp2cuda_temp_475 = &(right);
                                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_475));
                                                            }
                                                        }
#line 1394 "SequencePathModule.cs"
#line 1394 "SequencePathModule.cs"
                                                        double* csharp2cuda_temp_488 = &((level_two)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), middle)]);
#line 1394 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_489 = *(csharp2cuda_temp_488);
#line 1395 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_490 = (level_one)[left];
#line 1395 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_491 = (increment)[middle];
#line 1396 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_492 = (increment)[left];
#line 1396 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_493 = (increment)[middle];
#line 1396 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_494 = __ddiv_rn(__dmul_rn(csharp2cuda_temp_492, csharp2cuda_temp_493), 2.0);
                                                        (*(csharp2cuda_temp_488) = __dadd_rn(csharp2cuda_temp_489, __dadd_rn(__dmul_rn(csharp2cuda_temp_490, csharp2cuda_temp_491), csharp2cuda_temp_494)));
                                                    }
#line 1384 "SequencePathModule.cs"
                                                    int* csharp2cuda_temp_474 = &(middle);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_474));
                                                }
                                            }
#line 1398 "SequencePathModule.cs"
#line 1398 "SequencePathModule.cs"
                                            double* csharp2cuda_temp_495 = &((level_one)[left]);
#line 1398 "SequencePathModule.cs"
                                            double csharp2cuda_temp_496 = *(csharp2cuda_temp_495);
#line 1398 "SequencePathModule.cs"
                                            double csharp2cuda_temp_497 = (increment)[left];
                                            (*(csharp2cuda_temp_495) = __dadd_rn(csharp2cuda_temp_496, csharp2cuda_temp_497));
                                        }
#line 1382 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_473 = &(left);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_473));
                                    }
                                }
                            }
#line 1378 "SequencePathModule.cs"
                            int* csharp2cuda_temp_467 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_467));
                        }
                    }
#line 1401 "SequencePathModule.cs"
                    {
#line 1401 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (count))))
                                break;
#line 1402 "SequencePathModule.cs"
#line 1402 "SequencePathModule.cs"
                            double csharp2cuda_temp_499 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_499))))
                            {
#line 1402 "SequencePathModule.cs"
#line 1402 "SequencePathModule.cs"
                                int* csharp2cuda_temp_500 = &((output)->valid);
                                (*(csharp2cuda_temp_500) = 0);
                            }
#line 1401 "SequencePathModule.cs"
                            int* csharp2cuda_temp_498 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_498));
                        }
                    }
                }
            }
#line 1405 "SequencePathModule.cs"
            break;
#line 1406 "SequencePathModule.cs"
        case 28:
#line 1407 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1408 "SequencePathModule.cs"
            {
#line 1409 "SequencePathModule.cs"
                int dimension = (first)->columns;
#line 1410 "SequencePathModule.cs"
                mathblocks_sequence_set_matrix_shape(output, dimension, dimension);
#line 1411 "SequencePathModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 1412 "SequencePathModule.cs"
                {
#line 1413 "SequencePathModule.cs"
#line 1413 "SequencePathModule.cs"
                    int* csharp2cuda_temp_501 = &((output)->valid);
                    (*(csharp2cuda_temp_501) = 0);
                }
                else
#line 1416 "SequencePathModule.cs"
                {
#line 1417 "SequencePathModule.cs"
                    double* cumulative = scratch;
#line 1418 "SequencePathModule.cs"
                    double* increment = csharp2cuda_pointer_add(scratch, dimension);
#line 1419 "SequencePathModule.cs"
                    {
#line 1419 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (dimension))))
                                break;
#line 1420 "SequencePathModule.cs"
#line 1420 "SequencePathModule.cs"
                            double* csharp2cuda_temp_503 = &((cumulative)[index]);
                            (*(csharp2cuda_temp_503) = 0.0);
#line 1419 "SequencePathModule.cs"
                            int* csharp2cuda_temp_502 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_502));
                        }
                    }
#line 1421 "SequencePathModule.cs"
                    {
#line 1421 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(dimension, dimension)))))
                                break;
#line 1422 "SequencePathModule.cs"
#line 1422 "SequencePathModule.cs"
                            double* csharp2cuda_temp_505 = &((result)[index]);
                            (*(csharp2cuda_temp_505) = 0.0);
#line 1421 "SequencePathModule.cs"
                            int* csharp2cuda_temp_504 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_504));
                        }
                    }
#line 1423 "SequencePathModule.cs"
                    {
#line 1423 "SequencePathModule.cs"
                        int row = 1;
                        while (true)
                        {
#line 1423 "SequencePathModule.cs"
                            int csharp2cuda_temp_507 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_507))))
                                break;
#line 1424 "SequencePathModule.cs"
                            {
#line 1425 "SequencePathModule.cs"
                                {
#line 1425 "SequencePathModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
                                        if (!(((column) < (dimension))))
                                            break;
#line 1426 "SequencePathModule.cs"
#line 1426 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_509 = &((increment)[column]);
#line 1426 "SequencePathModule.cs"
                                        double csharp2cuda_temp_510 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, dimension), column)];
#line 1426 "SequencePathModule.cs"
                                        double csharp2cuda_temp_511 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(row, 1), dimension), column)];
                                        (*(csharp2cuda_temp_509) = __dsub_rn(csharp2cuda_temp_510, csharp2cuda_temp_511));
#line 1425 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_508 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_508));
                                    }
                                }
#line 1427 "SequencePathModule.cs"
                                {
#line 1427 "SequencePathModule.cs"
                                    int left = 0;
                                    while (true)
                                    {
                                        if (!(((left) < (dimension))))
                                            break;
#line 1428 "SequencePathModule.cs"
                                        {
#line 1429 "SequencePathModule.cs"
                                            {
#line 1429 "SequencePathModule.cs"
                                                int right = 0;
                                                while (true)
                                                {
                                                    if (!(((right) < (dimension))))
                                                        break;
#line 1430 "SequencePathModule.cs"
                                                    {
#line 1431 "SequencePathModule.cs"
#line 1431 "SequencePathModule.cs"
                                                        double* csharp2cuda_temp_514 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), right)]);
#line 1431 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_515 = *(csharp2cuda_temp_514);
#line 1432 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_516 = (cumulative)[left];
#line 1432 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_517 = (increment)[right];
#line 1433 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_518 = (increment)[left];
#line 1433 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_519 = (increment)[right];
                                                        (*(csharp2cuda_temp_514) = __dadd_rn(csharp2cuda_temp_515, __dadd_rn(__dmul_rn(csharp2cuda_temp_516, csharp2cuda_temp_517), __dmul_rn(__dmul_rn(0.5, csharp2cuda_temp_518), csharp2cuda_temp_519))));
                                                    }
#line 1429 "SequencePathModule.cs"
                                                    int* csharp2cuda_temp_513 = &(right);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_513));
                                                }
                                            }
                                        }
#line 1427 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_512 = &(left);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_512));
                                    }
                                }
#line 1436 "SequencePathModule.cs"
                                {
#line 1436 "SequencePathModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
                                        if (!(((column) < (dimension))))
                                            break;
#line 1437 "SequencePathModule.cs"
#line 1437 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_521 = &((cumulative)[column]);
#line 1437 "SequencePathModule.cs"
                                        double csharp2cuda_temp_522 = *(csharp2cuda_temp_521);
#line 1437 "SequencePathModule.cs"
                                        double csharp2cuda_temp_523 = (increment)[column];
                                        (*(csharp2cuda_temp_521) = __dadd_rn(csharp2cuda_temp_522, csharp2cuda_temp_523));
#line 1436 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_520 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_520));
                                    }
                                }
                            }
#line 1423 "SequencePathModule.cs"
                            int* csharp2cuda_temp_506 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_506));
                        }
                    }
#line 1439 "SequencePathModule.cs"
                    {
#line 1439 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(dimension, dimension)))))
                                break;
#line 1440 "SequencePathModule.cs"
#line 1440 "SequencePathModule.cs"
                            double csharp2cuda_temp_525 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_525))))
                            {
#line 1440 "SequencePathModule.cs"
#line 1440 "SequencePathModule.cs"
                                int* csharp2cuda_temp_526 = &((output)->valid);
                                (*(csharp2cuda_temp_526) = 0);
                            }
#line 1439 "SequencePathModule.cs"
                            int* csharp2cuda_temp_524 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_524));
                        }
                    }
                }
            }
#line 1443 "SequencePathModule.cs"
            break;
#line 1444 "SequencePathModule.cs"
        case 30:
        case 31:
#line 1446 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1447 "SequencePathModule.cs"
#line 1447 "SequencePathModule.cs"
                double* csharp2cuda_temp_527 = &((output)->scalar_value);
#line 1447 "SequencePathModule.cs"
                int csharp2cuda_temp_528 = (first)->count;
#line 1447 "SequencePathModule.cs"
                double csharp2cuda_temp_529 = mathblocks_sequence_sign_change_value(a, csharp2cuda_temp_528, ((opcode) == (30)));
                (*(csharp2cuda_temp_527) = csharp2cuda_temp_529);
            }
#line 1448 "SequencePathModule.cs"
            break;
#line 1449 "SequencePathModule.cs"
        case 32:
#line 1450 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1451 "SequencePathModule.cs"
            {
#line 1452 "SequencePathModule.cs"
                int state_count = 0;
#line 1453 "SequencePathModule.cs"
#line 1453 "SequencePathModule.cs"
                double csharp2cuda_temp_530 = (second)->scalar_value;
#line 1453 "SequencePathModule.cs"
                int* csharp2cuda_temp_531 = &(state_count);
#line 1453 "SequencePathModule.cs"
                bool csharp2cuda_temp_532 = mathblocks_sequence_positive_integer(csharp2cuda_temp_530, csharp2cuda_temp_531);
#line 1453 "SequencePathModule.cs"
                bool csharp2cuda_temp_533;
#line 1453 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_532))))
                {
#line 1453 "SequencePathModule.cs"
                    csharp2cuda_temp_533 = ((state_count) > (mathblocks_limit_state_count()));
                }
                else
                {
#line 1453 "SequencePathModule.cs"
                    csharp2cuda_temp_533 = true;
                }
                if (csharp2cuda_temp_533)
#line 1454 "SequencePathModule.cs"
                {
#line 1455 "SequencePathModule.cs"
#line 1455 "SequencePathModule.cs"
                    int* csharp2cuda_temp_534 = &((output)->valid);
                    (*(csharp2cuda_temp_534) = 0);
                }
                else
#line 1458 "SequencePathModule.cs"
                {
#line 1459 "SequencePathModule.cs"
                    mathblocks_sequence_set_matrix_shape(output, state_count, state_count);
#line 1460 "SequencePathModule.cs"
                    {
#line 1460 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1460 "SequencePathModule.cs"
                            bool csharp2cuda_temp_536 = (output)->valid;
#line 1460 "SequencePathModule.cs"
                            bool csharp2cuda_temp_537;
#line 1460 "SequencePathModule.cs"
                            if (csharp2cuda_temp_536)
                            {
#line 1460 "SequencePathModule.cs"
                                int csharp2cuda_temp_538 = (output)->count;
#line 1460 "SequencePathModule.cs"
                                csharp2cuda_temp_537 = ((index) < (csharp2cuda_temp_538));
                            }
                            else
                            {
#line 1460 "SequencePathModule.cs"
                                csharp2cuda_temp_537 = false;
                            }
                            if (!(csharp2cuda_temp_537))
                                break;
#line 1461 "SequencePathModule.cs"
#line 1461 "SequencePathModule.cs"
                            double* csharp2cuda_temp_539 = &((result)[index]);
                            (*(csharp2cuda_temp_539) = 0.0);
#line 1460 "SequencePathModule.cs"
                            int* csharp2cuda_temp_535 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_535));
                        }
                    }
#line 1462 "SequencePathModule.cs"
                    {
#line 1462 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1462 "SequencePathModule.cs"
                            bool csharp2cuda_temp_541 = (output)->valid;
#line 1462 "SequencePathModule.cs"
                            bool csharp2cuda_temp_542;
#line 1462 "SequencePathModule.cs"
                            if (csharp2cuda_temp_541)
                            {
#line 1462 "SequencePathModule.cs"
                                int csharp2cuda_temp_543 = (first)->count;
#line 1462 "SequencePathModule.cs"
                                csharp2cuda_temp_542 = ((index) < (csharp2cuda_temp_543));
                            }
                            else
                            {
#line 1462 "SequencePathModule.cs"
                                csharp2cuda_temp_542 = false;
                            }
                            if (!(csharp2cuda_temp_542))
                                break;
#line 1463 "SequencePathModule.cs"
                            {
#line 1464 "SequencePathModule.cs"
                                int state = 0;
#line 1465 "SequencePathModule.cs"
#line 1465 "SequencePathModule.cs"
                                double csharp2cuda_temp_544 = (a)[index];
#line 1465 "SequencePathModule.cs"
                                int* csharp2cuda_temp_545 = &(state);
#line 1465 "SequencePathModule.cs"
                                bool csharp2cuda_temp_546 = mathblocks_nonnegative_integer(csharp2cuda_temp_544, csharp2cuda_temp_545);
#line 1465 "SequencePathModule.cs"
                                bool csharp2cuda_temp_547;
#line 1465 "SequencePathModule.cs"
                                if (!((!(csharp2cuda_temp_546))))
                                {
#line 1465 "SequencePathModule.cs"
                                    csharp2cuda_temp_547 = ((state) >= (state_count));
                                }
                                else
                                {
#line 1465 "SequencePathModule.cs"
                                    csharp2cuda_temp_547 = true;
                                }
                                if (csharp2cuda_temp_547)
                                {
#line 1466 "SequencePathModule.cs"
#line 1466 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_548 = &((output)->valid);
                                    (*(csharp2cuda_temp_548) = 0);
                                }
                            }
#line 1462 "SequencePathModule.cs"
                            int* csharp2cuda_temp_540 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_540));
                        }
                    }
#line 1468 "SequencePathModule.cs"
                    {
#line 1468 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 1468 "SequencePathModule.cs"
                            bool csharp2cuda_temp_550 = (output)->valid;
#line 1468 "SequencePathModule.cs"
                            bool csharp2cuda_temp_551;
#line 1468 "SequencePathModule.cs"
                            if (csharp2cuda_temp_550)
                            {
#line 1468 "SequencePathModule.cs"
                                int csharp2cuda_temp_552 = (first)->count;
#line 1468 "SequencePathModule.cs"
                                csharp2cuda_temp_551 = ((index) < (csharp2cuda_temp_552));
                            }
                            else
                            {
#line 1468 "SequencePathModule.cs"
                                csharp2cuda_temp_551 = false;
                            }
                            if (!(csharp2cuda_temp_551))
                                break;
#line 1469 "SequencePathModule.cs"
#line 1469 "SequencePathModule.cs"
                            double csharp2cuda_temp_553 = (a)[csharp2cuda_i32_sub(index, 1)];
#line 1469 "SequencePathModule.cs"
                            double csharp2cuda_temp_554 = (a)[index];
#line 1469 "SequencePathModule.cs"
                            double* csharp2cuda_temp_555 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_f64_to_i32(csharp2cuda_temp_553), state_count), csharp2cuda_f64_to_i32(csharp2cuda_temp_554))]);
#line 1469 "SequencePathModule.cs"
                            double csharp2cuda_temp_556 = *(csharp2cuda_temp_555);
                            (*(csharp2cuda_temp_555) = __dadd_rn(csharp2cuda_temp_556, 1.0));
#line 1468 "SequencePathModule.cs"
                            int* csharp2cuda_temp_549 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_549));
                        }
                    }
                }
            }
#line 1472 "SequencePathModule.cs"
            break;
    }
}

#line 48 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_positive_integer(double value, int* result)
#line 50 "SequencePathModule.cs"
{
#line 51 "SequencePathModule.cs"
#line 51 "SequencePathModule.cs"
    bool csharp2cuda_temp_0 = mathblocks_nonnegative_integer(value, result);
#line 51 "SequencePathModule.cs"
    bool csharp2cuda_temp_1;
#line 51 "SequencePathModule.cs"
    if (csharp2cuda_temp_0)
    {
#line 51 "SequencePathModule.cs"
        int csharp2cuda_temp_2 = *(result);
#line 51 "SequencePathModule.cs"
        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) > (0));
    }
    else
    {
#line 51 "SequencePathModule.cs"
        csharp2cuda_temp_1 = false;
    }
    return csharp2cuda_temp_1;
}

#line 101 "SequencePathModule.cs"
__device__ void mathblocks_sequence_prepare_order_ranks(
    const double* values,
    int count,
    unsigned char* scratch,
    MathBlockSlot* output)
#line 107 "SequencePathModule.cs"
{
#line 108 "SequencePathModule.cs"
    int thread = threadIdx.x;
#line 109 "SequencePathModule.cs"
    unsigned long long* first_keys = ((unsigned long long*)(scratch));
#line 110 "SequencePathModule.cs"
    unsigned long long* second_keys = csharp2cuda_pointer_add(first_keys, count);
#line 111 "SequencePathModule.cs"
    int* first_indexes = ((int*)(csharp2cuda_pointer_add(second_keys, count)));
#line 112 "SequencePathModule.cs"
    int* second_indexes = csharp2cuda_pointer_add(first_indexes, count);
#line 113 "SequencePathModule.cs"
    int* ranks = csharp2cuda_pointer_add(second_indexes, count);
#line 114 "SequencePathModule.cs"
    int* lower_heap = csharp2cuda_pointer_add(ranks, count);
#line 115 "SequencePathModule.cs"
    int csharp2cuda_temp_0 = (output)->boolean_value;
#line 115 "SequencePathModule.cs"
    int* upper_heap = csharp2cuda_pointer_add(lower_heap, csharp2cuda_temp_0);
#line 116 "SequencePathModule.cs"
    int csharp2cuda_temp_1 = (output)->boolean_value;
#line 116 "SequencePathModule.cs"
    int* positions = csharp2cuda_pointer_add(upper_heap, csharp2cuda_temp_1);
#line 117 "SequencePathModule.cs"
    int* kinds = csharp2cuda_pointer_add(positions, count);
#line 121 "SequencePathModule.cs"
    const int virtual_lanes = 128;
#line 122 "SequencePathModule.cs"
    int* zero_counts = csharp2cuda_pointer_add(kinds, count);
#line 123 "SequencePathModule.cs"
    int* zero_prefix = csharp2cuda_pointer_add(zero_counts, virtual_lanes);
#line 125 "SequencePathModule.cs"
    {
#line 125 "SequencePathModule.cs"
        int index = thread;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 126 "SequencePathModule.cs"
            {
#line 127 "SequencePathModule.cs"
#line 127 "SequencePathModule.cs"
                double csharp2cuda_temp_4 = (values)[index];
                if ((!(isfinite(csharp2cuda_temp_4))))
                {
#line 128 "SequencePathModule.cs"
                    atomicExch(&((output)->valid), 0);
                }
#line 129 "SequencePathModule.cs"
#line 129 "SequencePathModule.cs"
                unsigned long long* csharp2cuda_temp_5 = &((first_keys)[index]);
#line 129 "SequencePathModule.cs"
                double csharp2cuda_temp_6 = (values)[index];
                (*(csharp2cuda_temp_5) = mathblocks_sequence_order_key(csharp2cuda_temp_6));
#line 130 "SequencePathModule.cs"
#line 130 "SequencePathModule.cs"
                int* csharp2cuda_temp_7 = &((first_indexes)[index]);
                (*(csharp2cuda_temp_7) = index);
            }
#line 125 "SequencePathModule.cs"
            int* csharp2cuda_temp_2 = &(index);
#line 125 "SequencePathModule.cs"
            int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
            (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, blockDim.x));
        }
    }
#line 132 "SequencePathModule.cs"
    __syncthreads();
#line 133 "SequencePathModule.cs"
#line 133 "SequencePathModule.cs"
    bool csharp2cuda_temp_8 = (output)->valid;
    if ((!(csharp2cuda_temp_8)))
    {
#line 134 "SequencePathModule.cs"
        return;
    }
#line 136 "SequencePathModule.cs"
    unsigned long long* source_keys = first_keys;
#line 137 "SequencePathModule.cs"
    unsigned long long* destination_keys = second_keys;
#line 138 "SequencePathModule.cs"
    int* source_indexes = first_indexes;
#line 139 "SequencePathModule.cs"
    int* destination_indexes = second_indexes;
#line 140 "SequencePathModule.cs"
    {
#line 140 "SequencePathModule.cs"
        int bit = 0;
        while (true)
        {
            if (!(((bit) < (64))))
                break;
#line 141 "SequencePathModule.cs"
            {
#line 142 "SequencePathModule.cs"
                {
#line 142 "SequencePathModule.cs"
                    int lane = thread;
                    while (true)
                    {
                        if (!(((lane) < (virtual_lanes))))
                            break;
#line 143 "SequencePathModule.cs"
                        {
#line 144 "SequencePathModule.cs"
                            long long csharp2cuda_temp_12 = csharp2cuda_i64_div(csharp2cuda_i64_mul(((long long)(count)), ((long long)(lane))), ((long long)(virtual_lanes)));
#line 144 "SequencePathModule.cs"
                            int begin = csharp2cuda_i32_from_bits(csharp2cuda_temp_12);
#line 145 "SequencePathModule.cs"
                            long long csharp2cuda_temp_13 = csharp2cuda_i64_div(csharp2cuda_i64_mul(((long long)(count)), ((long long)(csharp2cuda_i32_add(lane, 1)))), ((long long)(virtual_lanes)));
#line 145 "SequencePathModule.cs"
                            int end = csharp2cuda_i32_from_bits(csharp2cuda_temp_13);
#line 146 "SequencePathModule.cs"
                            int zeros = 0;
#line 147 "SequencePathModule.cs"
                            {
#line 147 "SequencePathModule.cs"
                                int index = begin;
                                while (true)
                                {
                                    if (!(((index) < (end))))
                                        break;
#line 148 "SequencePathModule.cs"
#line 148 "SequencePathModule.cs"
                                    unsigned long long csharp2cuda_temp_15 = (source_keys)[index];
                                    if (((((csharp2cuda_u64_shr(csharp2cuda_temp_15, bit)) & (1ull))) == (0ull)))
                                    {
#line 149 "SequencePathModule.cs"
#line 149 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_16 = &(zeros);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
                                    }
#line 147 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_14 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_14));
                                }
                            }
#line 150 "SequencePathModule.cs"
#line 150 "SequencePathModule.cs"
                            int* csharp2cuda_temp_17 = &((zero_counts)[lane]);
                            (*(csharp2cuda_temp_17) = zeros);
                        }
#line 142 "SequencePathModule.cs"
                        int* csharp2cuda_temp_10 = &(lane);
#line 142 "SequencePathModule.cs"
                        int csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
                        (*(csharp2cuda_temp_10) = csharp2cuda_i32_add(csharp2cuda_temp_11, blockDim.x));
                    }
                }
#line 152 "SequencePathModule.cs"
                __syncthreads();
#line 153 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 154 "SequencePathModule.cs"
                {
#line 155 "SequencePathModule.cs"
                    int prefix = 0;
#line 156 "SequencePathModule.cs"
                    {
#line 156 "SequencePathModule.cs"
                        int lane = 0;
                        while (true)
                        {
                            if (!(((lane) < (virtual_lanes))))
                                break;
#line 157 "SequencePathModule.cs"
                            {
#line 158 "SequencePathModule.cs"
#line 158 "SequencePathModule.cs"
                                int* csharp2cuda_temp_19 = &((zero_prefix)[lane]);
                                (*(csharp2cuda_temp_19) = prefix);
#line 159 "SequencePathModule.cs"
#line 159 "SequencePathModule.cs"
                                int* csharp2cuda_temp_20 = &(prefix);
#line 159 "SequencePathModule.cs"
                                int csharp2cuda_temp_21 = *(csharp2cuda_temp_20);
#line 159 "SequencePathModule.cs"
                                int csharp2cuda_temp_22 = (zero_counts)[lane];
                                (*(csharp2cuda_temp_20) = csharp2cuda_i32_add(csharp2cuda_temp_21, csharp2cuda_temp_22));
                            }
#line 156 "SequencePathModule.cs"
                            int* csharp2cuda_temp_18 = &(lane);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_18));
                        }
                    }
#line 161 "SequencePathModule.cs"
#line 161 "SequencePathModule.cs"
                    int* csharp2cuda_temp_23 = &((output)->columns);
                    (*(csharp2cuda_temp_23) = prefix);
                }
#line 163 "SequencePathModule.cs"
                __syncthreads();
#line 164 "SequencePathModule.cs"
                {
#line 164 "SequencePathModule.cs"
                    int lane = thread;
                    while (true)
                    {
                        if (!(((lane) < (virtual_lanes))))
                            break;
#line 165 "SequencePathModule.cs"
                        {
#line 166 "SequencePathModule.cs"
                            long long csharp2cuda_temp_26 = csharp2cuda_i64_div(csharp2cuda_i64_mul(((long long)(count)), ((long long)(lane))), ((long long)(virtual_lanes)));
#line 166 "SequencePathModule.cs"
                            int begin = csharp2cuda_i32_from_bits(csharp2cuda_temp_26);
#line 167 "SequencePathModule.cs"
                            long long csharp2cuda_temp_27 = csharp2cuda_i64_div(csharp2cuda_i64_mul(((long long)(count)), ((long long)(csharp2cuda_i32_add(lane, 1)))), ((long long)(virtual_lanes)));
#line 167 "SequencePathModule.cs"
                            int end = csharp2cuda_i32_from_bits(csharp2cuda_temp_27);
#line 168 "SequencePathModule.cs"
                            int zero_destination = (zero_prefix)[lane];
#line 169 "SequencePathModule.cs"
                            int csharp2cuda_temp_28 = (output)->columns;
#line 169 "SequencePathModule.cs"
                            int one_destination = csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_temp_28, begin), zero_destination);
#line 170 "SequencePathModule.cs"
                            {
#line 170 "SequencePathModule.cs"
                                int index = begin;
                                while (true)
                                {
                                    if (!(((index) < (end))))
                                        break;
#line 171 "SequencePathModule.cs"
                                    {
#line 172 "SequencePathModule.cs"
                                        unsigned long long key = (source_keys)[index];
#line 173 "SequencePathModule.cs"
                                        int csharp2cuda_temp_30;
#line 173 "SequencePathModule.cs"
                                        if (((((csharp2cuda_u64_shr(key, bit)) & (1ull))) == (0ull)))
                                        {
#line 174 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_31 = &(zero_destination);
#line 173 "SequencePathModule.cs"
                                            csharp2cuda_temp_30 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                                        }
                                        else
                                        {
#line 175 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_32 = &(one_destination);
#line 173 "SequencePathModule.cs"
                                            csharp2cuda_temp_30 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_32));
                                        }
#line 173 "SequencePathModule.cs"
                                        int destination = csharp2cuda_temp_30;
#line 176 "SequencePathModule.cs"
#line 176 "SequencePathModule.cs"
                                        unsigned long long* csharp2cuda_temp_33 = &((destination_keys)[destination]);
                                        (*(csharp2cuda_temp_33) = key);
#line 177 "SequencePathModule.cs"
#line 177 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_34 = &((destination_indexes)[destination]);
#line 177 "SequencePathModule.cs"
                                        int csharp2cuda_temp_35 = (source_indexes)[index];
                                        (*(csharp2cuda_temp_34) = csharp2cuda_temp_35);
                                    }
#line 170 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_29 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_29));
                                }
                            }
                        }
#line 164 "SequencePathModule.cs"
                        int* csharp2cuda_temp_24 = &(lane);
#line 164 "SequencePathModule.cs"
                        int csharp2cuda_temp_25 = *(csharp2cuda_temp_24);
                        (*(csharp2cuda_temp_24) = csharp2cuda_i32_add(csharp2cuda_temp_25, blockDim.x));
                    }
                }
#line 180 "SequencePathModule.cs"
                __syncthreads();
#line 181 "SequencePathModule.cs"
                unsigned long long* key_swap = source_keys;
#line 182 "SequencePathModule.cs"
#line 182 "SequencePathModule.cs"
                unsigned long long** csharp2cuda_temp_36 = &(source_keys);
                (*(csharp2cuda_temp_36) = destination_keys);
#line 183 "SequencePathModule.cs"
#line 183 "SequencePathModule.cs"
                unsigned long long** csharp2cuda_temp_37 = &(destination_keys);
                (*(csharp2cuda_temp_37) = key_swap);
#line 184 "SequencePathModule.cs"
                int* index_swap = source_indexes;
#line 185 "SequencePathModule.cs"
#line 185 "SequencePathModule.cs"
                int** csharp2cuda_temp_38 = &(source_indexes);
                (*(csharp2cuda_temp_38) = destination_indexes);
#line 186 "SequencePathModule.cs"
#line 186 "SequencePathModule.cs"
                int** csharp2cuda_temp_39 = &(destination_indexes);
                (*(csharp2cuda_temp_39) = index_swap);
            }
#line 140 "SequencePathModule.cs"
            int* csharp2cuda_temp_9 = &(bit);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
        }
    }
#line 188 "SequencePathModule.cs"
    {
#line 188 "SequencePathModule.cs"
        int index = thread;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 189 "SequencePathModule.cs"
#line 189 "SequencePathModule.cs"
            int csharp2cuda_temp_42 = (source_indexes)[index];
#line 189 "SequencePathModule.cs"
            int* csharp2cuda_temp_43 = &((ranks)[csharp2cuda_temp_42]);
            (*(csharp2cuda_temp_43) = index);
#line 188 "SequencePathModule.cs"
            int* csharp2cuda_temp_40 = &(index);
#line 188 "SequencePathModule.cs"
            int csharp2cuda_temp_41 = *(csharp2cuda_temp_40);
            (*(csharp2cuda_temp_40) = csharp2cuda_i32_add(csharp2cuda_temp_41, blockDim.x));
        }
    }
#line 190 "SequencePathModule.cs"
    __syncthreads();
#line 191 "SequencePathModule.cs"
    if (((thread) == (0)))
    {
#line 192 "SequencePathModule.cs"
#line 192 "SequencePathModule.cs"
        int* csharp2cuda_temp_44 = &((output)->columns);
        (*(csharp2cuda_temp_44) = 0);
    }
#line 193 "SequencePathModule.cs"
    __syncthreads();
}

#line 347 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rebalance_heaps(
    int* lower_heap,
    int* lower_count,
    int* upper_heap,
    int* upper_count,
    int target_lower_count,
    int* positions,
    int* kinds,
    const int* ranks)
#line 357 "SequencePathModule.cs"
{
#line 358 "SequencePathModule.cs"
    while (true)
    {
#line 358 "SequencePathModule.cs"
        int csharp2cuda_temp_0 = *(lower_count);
        if (!(((csharp2cuda_temp_0) > (target_lower_count))))
            break;
#line 359 "SequencePathModule.cs"
        {
#line 360 "SequencePathModule.cs"
            int item = (lower_heap)[0];
#line 361 "SequencePathModule.cs"
            mathblocks_sequence_heap_remove(lower_heap, lower_count, item, positions, kinds, ranks, true);
#line 369 "SequencePathModule.cs"
            mathblocks_sequence_heap_insert(upper_heap, upper_count, item, 1, positions, kinds, ranks, false);
        }
    }
#line 379 "SequencePathModule.cs"
    while (true)
    {
#line 379 "SequencePathModule.cs"
        int csharp2cuda_temp_1 = *(lower_count);
        if (!(((csharp2cuda_temp_1) < (target_lower_count))))
            break;
#line 380 "SequencePathModule.cs"
        {
#line 381 "SequencePathModule.cs"
            int item = (upper_heap)[0];
#line 382 "SequencePathModule.cs"
            mathblocks_sequence_heap_remove(upper_heap, upper_count, item, positions, kinds, ranks, false);
#line 390 "SequencePathModule.cs"
            mathblocks_sequence_heap_insert(lower_heap, lower_count, item, 0, positions, kinds, ranks, true);
        }
    }
}

#line 528 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_recurrence_value(
    const double* values,
    int count,
    double threshold,
    double* value)
#line 534 "SequencePathModule.cs"
{
#line 535 "SequencePathModule.cs"
#line 535 "SequencePathModule.cs"
    bool csharp2cuda_temp_0;
#line 535 "SequencePathModule.cs"
    if (!(((count) <= (0))))
    {
#line 535 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((threshold) < (0.0));
    }
    else
    {
#line 535 "SequencePathModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 536 "SequencePathModule.cs"
        return false;
    }
#line 537 "SequencePathModule.cs"
    long long recurrent = ((long long)(0));
#line 538 "SequencePathModule.cs"
    long long total = csharp2cuda_i64_mul(((long long)(count)), ((long long)(count)));
#line 539 "SequencePathModule.cs"
    {
#line 539 "SequencePathModule.cs"
        int left = 0;
        while (true)
        {
            if (!(((left) < (count))))
                break;
#line 540 "SequencePathModule.cs"
            {
#line 540 "SequencePathModule.cs"
                int right = 0;
                while (true)
                {
                    if (!(((right) < (count))))
                        break;
#line 541 "SequencePathModule.cs"
#line 541 "SequencePathModule.cs"
                    double csharp2cuda_temp_3 = (values)[left];
#line 541 "SequencePathModule.cs"
                    double csharp2cuda_temp_4 = (values)[right];
                    if (((fabs(__dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4))) <= (threshold)))
                    {
#line 542 "SequencePathModule.cs"
#line 542 "SequencePathModule.cs"
                        long long* csharp2cuda_temp_5 = &(recurrent);
                        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_5));
                    }
#line 540 "SequencePathModule.cs"
                    int* csharp2cuda_temp_2 = &(right);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                }
            }
#line 539 "SequencePathModule.cs"
            int* csharp2cuda_temp_1 = &(left);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 543 "SequencePathModule.cs"
#line 543 "SequencePathModule.cs"
    double* csharp2cuda_temp_6 = value;
#line 543 "SequencePathModule.cs"
    double csharp2cuda_temp_7 = __ddiv_rn(((double)(recurrent)), ((double)(total)));
    (*(csharp2cuda_temp_6) = csharp2cuda_temp_7);
#line 544 "SequencePathModule.cs"
    return true;
}

#line 402 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_extreme(
    const double* values,
    int count,
    int width,
    double* result,
    int* deque,
    bool minimum)
#line 410 "SequencePathModule.cs"
{
#line 411 "SequencePathModule.cs"
    int head = 0;
#line 412 "SequencePathModule.cs"
    int tail = 0;
#line 413 "SequencePathModule.cs"
    {
#line 413 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 414 "SequencePathModule.cs"
            {
#line 415 "SequencePathModule.cs"
                while (true)
                {
#line 415 "SequencePathModule.cs"
                    bool csharp2cuda_temp_1;
#line 415 "SequencePathModule.cs"
                    if (((head) < (tail)))
                    {
#line 415 "SequencePathModule.cs"
                        int csharp2cuda_temp_2 = (deque)[head];
#line 415 "SequencePathModule.cs"
                        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) <= (csharp2cuda_i32_sub(index, width)));
                    }
                    else
                    {
#line 415 "SequencePathModule.cs"
                        csharp2cuda_temp_1 = false;
                    }
                    if (!(csharp2cuda_temp_1))
                        break;
#line 416 "SequencePathModule.cs"
#line 416 "SequencePathModule.cs"
                    int* csharp2cuda_temp_3 = &(head);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
                }
#line 417 "SequencePathModule.cs"
                while (true)
                {
#line 417 "SequencePathModule.cs"
                    bool csharp2cuda_temp_4;
#line 417 "SequencePathModule.cs"
                    if (((head) < (tail)))
                    {
#line 417 "SequencePathModule.cs"
                        bool csharp2cuda_temp_5;
#line 417 "SequencePathModule.cs"
                        if (minimum)
                        {
#line 418 "SequencePathModule.cs"
                            int csharp2cuda_temp_6 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 418 "SequencePathModule.cs"
                            double csharp2cuda_temp_7 = (values)[csharp2cuda_temp_6];
#line 418 "SequencePathModule.cs"
                            double csharp2cuda_temp_8 = (values)[index];
#line 417 "SequencePathModule.cs"
                            csharp2cuda_temp_5 = ((csharp2cuda_temp_7) > (csharp2cuda_temp_8));
                        }
                        else
                        {
#line 419 "SequencePathModule.cs"
                            int csharp2cuda_temp_9 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 419 "SequencePathModule.cs"
                            double csharp2cuda_temp_10 = (values)[csharp2cuda_temp_9];
#line 419 "SequencePathModule.cs"
                            double csharp2cuda_temp_11 = (values)[index];
#line 417 "SequencePathModule.cs"
                            csharp2cuda_temp_5 = ((csharp2cuda_temp_10) < (csharp2cuda_temp_11));
                        }
#line 417 "SequencePathModule.cs"
                        csharp2cuda_temp_4 = csharp2cuda_temp_5;
                    }
                    else
                    {
#line 417 "SequencePathModule.cs"
                        csharp2cuda_temp_4 = false;
                    }
                    if (!(csharp2cuda_temp_4))
                        break;
#line 420 "SequencePathModule.cs"
                    {
#line 421 "SequencePathModule.cs"
#line 421 "SequencePathModule.cs"
                        int* csharp2cuda_temp_12 = &(tail);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_12));
                    }
                }
#line 423 "SequencePathModule.cs"
#line 423 "SequencePathModule.cs"
                int* csharp2cuda_temp_13 = &(tail);
#line 423 "SequencePathModule.cs"
                int csharp2cuda_temp_14 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
#line 423 "SequencePathModule.cs"
                int* csharp2cuda_temp_15 = &((deque)[csharp2cuda_temp_14]);
                (*(csharp2cuda_temp_15) = index);
#line 424 "SequencePathModule.cs"
                if (((index) >= (csharp2cuda_i32_sub(width, 1))))
                {
#line 425 "SequencePathModule.cs"
#line 425 "SequencePathModule.cs"
                    double* csharp2cuda_temp_16 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_sub(index, width), 1)]);
#line 425 "SequencePathModule.cs"
                    int csharp2cuda_temp_17 = (deque)[head];
#line 425 "SequencePathModule.cs"
                    double csharp2cuda_temp_18 = (values)[csharp2cuda_temp_17];
                    (*(csharp2cuda_temp_16) = csharp2cuda_temp_18);
                }
            }
#line 413 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 429 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_sum(
    const double* values,
    int count,
    int width,
    double* result)
#line 435 "SequencePathModule.cs"
{
#line 436 "SequencePathModule.cs"
    double sum = 0.0;
#line 437 "SequencePathModule.cs"
    {
#line 437 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (width))))
                break;
#line 438 "SequencePathModule.cs"
#line 438 "SequencePathModule.cs"
            double* csharp2cuda_temp_1 = &(sum);
#line 438 "SequencePathModule.cs"
            double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
#line 438 "SequencePathModule.cs"
            double csharp2cuda_temp_3 = (values)[index];
            (*(csharp2cuda_temp_1) = __dadd_rn(csharp2cuda_temp_2, csharp2cuda_temp_3));
#line 437 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 439 "SequencePathModule.cs"
#line 439 "SequencePathModule.cs"
    double* csharp2cuda_temp_4 = &((result)[0]);
    (*(csharp2cuda_temp_4) = sum);
#line 440 "SequencePathModule.cs"
    {
#line 440 "SequencePathModule.cs"
        int index = width;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 441 "SequencePathModule.cs"
            {
#line 442 "SequencePathModule.cs"
#line 442 "SequencePathModule.cs"
                double* csharp2cuda_temp_6 = &(sum);
#line 442 "SequencePathModule.cs"
                double csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
#line 442 "SequencePathModule.cs"
                double csharp2cuda_temp_8 = (values)[index];
#line 442 "SequencePathModule.cs"
                double csharp2cuda_temp_9 = (values)[csharp2cuda_i32_sub(index, width)];
                (*(csharp2cuda_temp_6) = __dadd_rn(csharp2cuda_temp_7, __dsub_rn(csharp2cuda_temp_8, csharp2cuda_temp_9)));
#line 443 "SequencePathModule.cs"
#line 443 "SequencePathModule.cs"
                double* csharp2cuda_temp_10 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_sub(index, width), 1)]);
                (*(csharp2cuda_temp_10) = sum);
            }
#line 440 "SequencePathModule.cs"
            int* csharp2cuda_temp_5 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
        }
    }
}

#line 67 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_matrix_shape(
    MathBlockSlot* output,
    int rows,
    int columns)
#line 72 "SequencePathModule.cs"
{
#line 73 "SequencePathModule.cs"
    long long count = csharp2cuda_i64_mul(((long long)(rows)), ((long long)(columns)));
#line 74 "SequencePathModule.cs"
#line 74 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = &((output)->rows);
    (*(csharp2cuda_temp_0) = rows);
#line 75 "SequencePathModule.cs"
#line 75 "SequencePathModule.cs"
    int* csharp2cuda_temp_1 = &((output)->columns);
    (*(csharp2cuda_temp_1) = columns);
#line 76 "SequencePathModule.cs"
#line 76 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((output)->count);
#line 76 "SequencePathModule.cs"
    int csharp2cuda_temp_3;
#line 76 "SequencePathModule.cs"
    if (((count) > (2147483647LL)))
    {
#line 76 "SequencePathModule.cs"
        csharp2cuda_temp_3 = csharp2cuda_i32_neg(1);
    }
    else
    {
#line 76 "SequencePathModule.cs"
        csharp2cuda_temp_3 = csharp2cuda_i32_from_bits(count);
    }
    (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
#line 77 "SequencePathModule.cs"
#line 77 "SequencePathModule.cs"
    bool csharp2cuda_temp_4;
#line 77 "SequencePathModule.cs"
    if (!(((rows) < (0))))
    {
#line 77 "SequencePathModule.cs"
        csharp2cuda_temp_4 = ((columns) < (0));
    }
    else
    {
#line 77 "SequencePathModule.cs"
        csharp2cuda_temp_4 = true;
    }
#line 77 "SequencePathModule.cs"
    bool csharp2cuda_temp_5;
#line 77 "SequencePathModule.cs"
    if (!(csharp2cuda_temp_4))
    {
#line 77 "SequencePathModule.cs"
        int csharp2cuda_temp_6 = (output)->capacity;
#line 77 "SequencePathModule.cs"
        csharp2cuda_temp_5 = ((count) > (((long long)(csharp2cuda_temp_6))));
    }
    else
    {
#line 77 "SequencePathModule.cs"
        csharp2cuda_temp_5 = true;
    }
    if (csharp2cuda_temp_5)
#line 78 "SequencePathModule.cs"
    {
#line 79 "SequencePathModule.cs"
#line 79 "SequencePathModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
        (*(csharp2cuda_temp_7) = 0);
#line 80 "SequencePathModule.cs"
        return;
    }
}

#line 54 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_vector_shape(MathBlockSlot* output, int count)
#line 56 "SequencePathModule.cs"
{
#line 57 "SequencePathModule.cs"
#line 57 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = &((output)->rows);
    (*(csharp2cuda_temp_0) = count);
#line 58 "SequencePathModule.cs"
#line 58 "SequencePathModule.cs"
    int* csharp2cuda_temp_1 = &((output)->columns);
    (*(csharp2cuda_temp_1) = 0);
#line 59 "SequencePathModule.cs"
#line 59 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((output)->count);
    (*(csharp2cuda_temp_2) = count);
#line 60 "SequencePathModule.cs"
#line 60 "SequencePathModule.cs"
    bool csharp2cuda_temp_3;
#line 60 "SequencePathModule.cs"
    if (!(((count) < (0))))
    {
#line 60 "SequencePathModule.cs"
        int csharp2cuda_temp_4 = (output)->capacity;
#line 60 "SequencePathModule.cs"
        csharp2cuda_temp_3 = ((count) > (csharp2cuda_temp_4));
    }
    else
    {
#line 60 "SequencePathModule.cs"
        csharp2cuda_temp_3 = true;
    }
    if (csharp2cuda_temp_3)
#line 61 "SequencePathModule.cs"
    {
#line 62 "SequencePathModule.cs"
#line 62 "SequencePathModule.cs"
        int* csharp2cuda_temp_5 = &((output)->valid);
        (*(csharp2cuda_temp_5) = 0);
#line 63 "SequencePathModule.cs"
        return;
    }
}

#line 548 "SequencePathModule.cs"
__device__ double mathblocks_sequence_sign_change_value(
    const double* values,
    int count,
    bool differenced)
#line 553 "SequencePathModule.cs"
{
#line 554 "SequencePathModule.cs"
    int changes = 0;
#line 555 "SequencePathModule.cs"
    int previous = 0;
#line 556 "SequencePathModule.cs"
    int csharp2cuda_temp_0;
#line 556 "SequencePathModule.cs"
    if (differenced)
    {
#line 556 "SequencePathModule.cs"
        csharp2cuda_temp_0 = 1;
    }
    else
    {
#line 556 "SequencePathModule.cs"
        csharp2cuda_temp_0 = 0;
    }
#line 556 "SequencePathModule.cs"
    int start = csharp2cuda_temp_0;
#line 557 "SequencePathModule.cs"
    {
#line 557 "SequencePathModule.cs"
        int index = start;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 558 "SequencePathModule.cs"
            {
#line 559 "SequencePathModule.cs"
                double csharp2cuda_temp_2;
#line 559 "SequencePathModule.cs"
                if (differenced)
                {
#line 559 "SequencePathModule.cs"
                    double csharp2cuda_temp_3 = (values)[index];
#line 559 "SequencePathModule.cs"
                    double csharp2cuda_temp_4 = (values)[csharp2cuda_i32_sub(index, 1)];
#line 559 "SequencePathModule.cs"
                    csharp2cuda_temp_2 = __dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4);
                }
                else
                {
#line 559 "SequencePathModule.cs"
                    csharp2cuda_temp_2 = (values)[index];
                }
#line 559 "SequencePathModule.cs"
                double difference = csharp2cuda_temp_2;
#line 560 "SequencePathModule.cs"
                int csharp2cuda_temp_5;
#line 560 "SequencePathModule.cs"
                if (((difference) > (0.0)))
                {
#line 560 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = 1;
                }
                else
                {
#line 560 "SequencePathModule.cs"
                    int csharp2cuda_temp_6;
#line 560 "SequencePathModule.cs"
                    if (((difference) < (0.0)))
                    {
#line 560 "SequencePathModule.cs"
                        csharp2cuda_temp_6 = csharp2cuda_i32_neg(1);
                    }
                    else
                    {
#line 560 "SequencePathModule.cs"
                        csharp2cuda_temp_6 = 0;
                    }
#line 560 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = csharp2cuda_temp_6;
                }
#line 560 "SequencePathModule.cs"
                int current = csharp2cuda_temp_5;
#line 561 "SequencePathModule.cs"
                if (((current) == (0)))
                {
#line 562 "SequencePathModule.cs"
                    goto csharp2cuda_for_continue_0;
                }
#line 563 "SequencePathModule.cs"
#line 563 "SequencePathModule.cs"
                bool csharp2cuda_temp_7;
#line 563 "SequencePathModule.cs"
                if (((previous) != (0)))
                {
#line 563 "SequencePathModule.cs"
                    csharp2cuda_temp_7 = ((current) != (previous));
                }
                else
                {
#line 563 "SequencePathModule.cs"
                    csharp2cuda_temp_7 = false;
                }
                if (csharp2cuda_temp_7)
                {
#line 564 "SequencePathModule.cs"
#line 564 "SequencePathModule.cs"
                    int* csharp2cuda_temp_8 = &(changes);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_8));
                }
#line 565 "SequencePathModule.cs"
#line 565 "SequencePathModule.cs"
                int* csharp2cuda_temp_9 = &(previous);
                (*(csharp2cuda_temp_9) = current);
            }
            csharp2cuda_for_continue_0:
#line 557 "SequencePathModule.cs"
            int* csharp2cuda_temp_1 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 567 "SequencePathModule.cs"
    return ((double)(changes));
}

#line 506 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_variation_value(
    const double* values,
    int count,
    double order,
    bool absolute,
    double* value)
#line 513 "SequencePathModule.cs"
{
#line 514 "SequencePathModule.cs"
    if (((count) <= (0)))
    {
#line 515 "SequencePathModule.cs"
        return false;
    }
#line 516 "SequencePathModule.cs"
    if ((!(((order) > (0.0)))))
    {
#line 517 "SequencePathModule.cs"
        return false;
    }
#line 518 "SequencePathModule.cs"
    double total = 0.0;
#line 519 "SequencePathModule.cs"
    {
#line 519 "SequencePathModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 520 "SequencePathModule.cs"
            {
#line 521 "SequencePathModule.cs"
                double csharp2cuda_temp_1 = (values)[index];
#line 521 "SequencePathModule.cs"
                double csharp2cuda_temp_2 = (values)[csharp2cuda_i32_sub(index, 1)];
#line 521 "SequencePathModule.cs"
                double change = fabs(__dsub_rn(csharp2cuda_temp_1, csharp2cuda_temp_2));
#line 522 "SequencePathModule.cs"
#line 522 "SequencePathModule.cs"
                double* csharp2cuda_temp_3 = &(total);
#line 522 "SequencePathModule.cs"
                double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 522 "SequencePathModule.cs"
                double csharp2cuda_temp_5;
#line 522 "SequencePathModule.cs"
                if (absolute)
                {
#line 522 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = change;
                }
                else
                {
#line 522 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = mathblocks_power(change, order);
                }
                (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, csharp2cuda_temp_5));
            }
#line 519 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 524 "SequencePathModule.cs"
#line 524 "SequencePathModule.cs"
    double* csharp2cuda_temp_6 = value;
    (*(csharp2cuda_temp_6) = total);
#line 525 "SequencePathModule.cs"
    return isfinite(total);
}