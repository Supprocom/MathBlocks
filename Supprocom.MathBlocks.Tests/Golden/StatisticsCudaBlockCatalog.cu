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

#line 200 "StatisticsModule.cs"
__device__ void mathblocks_statistics_center_distance(
    const double* values,
    int count,
    double* result,
    double* row_means);

#line 94 "StatisticsModule.cs"
__device__ double mathblocks_statistics_correlation_value(double covariance, double left_variance, double right_variance);

#line 387 "StatisticsModule.cs"
__device__ void mathblocks_statistics_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 106 "StatisticsModule.cs"
__device__ double mathblocks_statistics_distance_correlation_value(
    double covariance_square,
    double left_variance_square,
    double right_variance_square);

#line 247 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_kendall_value(
    const double* left_values,
    const double* right_values,
    int count,
    double* value);

#line 49 "StatisticsModule.cs"
__device__ double mathblocks_statistics_mean(const double* values, int count);

#line 163 "StatisticsModule.cs"
__device__ double mathblocks_statistics_median(double* values, int count);

#line 227 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_moment_value(
    const double* values,
    int count,
    double order_value,
    bool central,
    double* value);

#line 343 "StatisticsModule.cs"
__device__ int mathblocks_statistics_pair_averages(
    const double* values,
    int count,
    double* averages);

#line 358 "StatisticsModule.cs"
__device__ int mathblocks_statistics_pair_slopes(
    const double* x,
    const double* y,
    int count,
    double* slopes);

#line 119 "StatisticsModule.cs"
__device__ double mathblocks_statistics_pearson(
    const double* left,
    const double* right,
    int count);

#line 70 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_covariance(
    const double* left,
    const double* right,
    int count);

#line 55 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_variance(
    const double* values,
    int count);

#line 85 "StatisticsModule.cs"
__device__ double mathblocks_statistics_quotient_by_variance(double covariance, double variance);

#line 190 "StatisticsModule.cs"
__device__ void mathblocks_statistics_rank(
    const double* values,
    int count,
    double* result);

#line 172 "StatisticsModule.cs"
__device__ double mathblocks_statistics_rank_at(
    const double* values,
    int count,
    int index);

#line 285 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_shape_moment_value(
    const double* values,
    int count,
    bool kurtosis,
    double* value);

#line 138 "StatisticsModule.cs"
__device__ void mathblocks_statistics_sort_copy(
    const double* values,
    int count,
    double* result,
    bool descending);

#line 148 "StatisticsModule.cs"
__device__ double mathblocks_statistics_sorted_quantile(
    const double* sorted,
    int count,
    double probability);

#line 312 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_weighted_value(
    const double* values,
    const double* weights,
    int count,
    bool variance,
    double* value);

#line 200 "StatisticsModule.cs"
__device__ void mathblocks_statistics_center_distance(
    const double* values,
    int count,
    double* result,
    double* row_means)
#line 206 "StatisticsModule.cs"
{
#line 207 "StatisticsModule.cs"
    double total_mean = 0.0;
#line 208 "StatisticsModule.cs"
    {
#line 208 "StatisticsModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 209 "StatisticsModule.cs"
            {
#line 210 "StatisticsModule.cs"
#line 210 "StatisticsModule.cs"
                double* csharp2cuda_temp_1 = &((row_means)[row]);
                (*(csharp2cuda_temp_1) = 0.0);
#line 211 "StatisticsModule.cs"
                {
#line 211 "StatisticsModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (count))))
                            break;
#line 212 "StatisticsModule.cs"
                        {
#line 213 "StatisticsModule.cs"
                            double csharp2cuda_temp_3 = (values)[row];
#line 213 "StatisticsModule.cs"
                            double csharp2cuda_temp_4 = (values)[column];
#line 213 "StatisticsModule.cs"
                            double distance = fabs(__dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4));
#line 214 "StatisticsModule.cs"
#line 214 "StatisticsModule.cs"
                            double* csharp2cuda_temp_5 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, count), column)]);
                            (*(csharp2cuda_temp_5) = distance);
#line 215 "StatisticsModule.cs"
#line 215 "StatisticsModule.cs"
                            double* csharp2cuda_temp_6 = &((row_means)[row]);
#line 215 "StatisticsModule.cs"
                            double csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
                            (*(csharp2cuda_temp_6) = __dadd_rn(csharp2cuda_temp_7, distance));
#line 216 "StatisticsModule.cs"
#line 216 "StatisticsModule.cs"
                            double* csharp2cuda_temp_8 = &(total_mean);
#line 216 "StatisticsModule.cs"
                            double csharp2cuda_temp_9 = *(csharp2cuda_temp_8);
                            (*(csharp2cuda_temp_8) = __dadd_rn(csharp2cuda_temp_9, distance));
                        }
#line 211 "StatisticsModule.cs"
                        int* csharp2cuda_temp_2 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                    }
                }
#line 218 "StatisticsModule.cs"
#line 218 "StatisticsModule.cs"
                double* csharp2cuda_temp_10 = &((row_means)[row]);
#line 218 "StatisticsModule.cs"
                double csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
                (*(csharp2cuda_temp_10) = __ddiv_rn(csharp2cuda_temp_11, ((double)(count))));
            }
#line 208 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 220 "StatisticsModule.cs"
#line 220 "StatisticsModule.cs"
    double* csharp2cuda_temp_12 = &(total_mean);
#line 220 "StatisticsModule.cs"
    double csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
    (*(csharp2cuda_temp_12) = __ddiv_rn(csharp2cuda_temp_13, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 221 "StatisticsModule.cs"
    {
#line 221 "StatisticsModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 222 "StatisticsModule.cs"
            {
#line 222 "StatisticsModule.cs"
                int column = 0;
                while (true)
                {
                    if (!(((column) < (count))))
                        break;
#line 223 "StatisticsModule.cs"
#line 223 "StatisticsModule.cs"
                    double* csharp2cuda_temp_16 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, count), column)]);
#line 223 "StatisticsModule.cs"
                    double csharp2cuda_temp_17 = *(csharp2cuda_temp_16);
#line 224 "StatisticsModule.cs"
                    double csharp2cuda_temp_18 = (row_means)[row];
#line 224 "StatisticsModule.cs"
                    double csharp2cuda_temp_19 = (row_means)[column];
                    (*(csharp2cuda_temp_16) = __dsub_rn(csharp2cuda_temp_17, __dsub_rn(__dadd_rn(csharp2cuda_temp_18, csharp2cuda_temp_19), total_mean)));
#line 222 "StatisticsModule.cs"
                    int* csharp2cuda_temp_15 = &(column);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
                }
            }
#line 221 "StatisticsModule.cs"
            int* csharp2cuda_temp_14 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_14));
        }
    }
}

#line 94 "StatisticsModule.cs"
__device__ double mathblocks_statistics_correlation_value(double covariance, double left_variance, double right_variance)
#line 96 "StatisticsModule.cs"
{
#line 97 "StatisticsModule.cs"
#line 97 "StatisticsModule.cs"
    bool csharp2cuda_temp_0;
#line 97 "StatisticsModule.cs"
    if (!((!(isfinite(left_variance)))))
    {
#line 97 "StatisticsModule.cs"
        csharp2cuda_temp_0 = (!(isfinite(right_variance)));
    }
    else
    {
#line 97 "StatisticsModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 98 "StatisticsModule.cs"
        return mathblocks_quiet_nan();
    }
#line 99 "StatisticsModule.cs"
    double denominator = __dmul_rn(mathblocks_square_root(left_variance), mathblocks_square_root(right_variance));
#line 100 "StatisticsModule.cs"
    if ((!(isfinite(denominator))))
    {
#line 101 "StatisticsModule.cs"
        return mathblocks_quiet_nan();
    }
#line 102 "StatisticsModule.cs"
    return __ddiv_rn(covariance, denominator);
}

#line 387 "StatisticsModule.cs"
__device__ void mathblocks_statistics_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 393 "StatisticsModule.cs"
{
#line 394 "StatisticsModule.cs"
    int thread = threadIdx.x;
#line 395 "StatisticsModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 395 "StatisticsModule.cs"
    if (((input_count) > (0)))
    {
#line 395 "StatisticsModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 395 "StatisticsModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 395 "StatisticsModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 396 "StatisticsModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 396 "StatisticsModule.cs"
    if (((input_count) > (1)))
    {
#line 396 "StatisticsModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 396 "StatisticsModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 396 "StatisticsModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 397 "StatisticsModule.cs"
    if (((thread) == (0)))
#line 398 "StatisticsModule.cs"
    {
#line 399 "StatisticsModule.cs"
#line 399 "StatisticsModule.cs"
        double* csharp2cuda_temp_2 = &((output)->scalar_value);
        (*(csharp2cuda_temp_2) = 0.0);
#line 400 "StatisticsModule.cs"
#line 400 "StatisticsModule.cs"
        int* csharp2cuda_temp_3 = &((output)->boolean_value);
        (*(csharp2cuda_temp_3) = 0);
#line 401 "StatisticsModule.cs"
#line 401 "StatisticsModule.cs"
        int* csharp2cuda_temp_4 = &((output)->rows);
        (*(csharp2cuda_temp_4) = 0);
#line 402 "StatisticsModule.cs"
#line 402 "StatisticsModule.cs"
        int* csharp2cuda_temp_5 = &((output)->columns);
        (*(csharp2cuda_temp_5) = 0);
#line 403 "StatisticsModule.cs"
#line 403 "StatisticsModule.cs"
        int* csharp2cuda_temp_6 = &((output)->count);
        (*(csharp2cuda_temp_6) = 0);
#line 404 "StatisticsModule.cs"
#line 404 "StatisticsModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
#line 404 "StatisticsModule.cs"
        bool csharp2cuda_temp_8;
#line 404 "StatisticsModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 404 "StatisticsModule.cs"
            csharp2cuda_temp_8 = (first)->valid;
        }
        else
        {
#line 404 "StatisticsModule.cs"
            csharp2cuda_temp_8 = true;
        }
        (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 405 "StatisticsModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 406 "StatisticsModule.cs"
#line 406 "StatisticsModule.cs"
            int* csharp2cuda_temp_9 = &((output)->valid);
#line 406 "StatisticsModule.cs"
            bool csharp2cuda_temp_10 = (output)->valid;
#line 406 "StatisticsModule.cs"
            bool csharp2cuda_temp_11;
#line 406 "StatisticsModule.cs"
            if (csharp2cuda_temp_10)
            {
#line 406 "StatisticsModule.cs"
                csharp2cuda_temp_11 = (second)->valid;
            }
            else
            {
#line 406 "StatisticsModule.cs"
                csharp2cuda_temp_11 = false;
            }
            (*(csharp2cuda_temp_9) = csharp2cuda_temp_11);
        }
    }
#line 408 "StatisticsModule.cs"
    __syncthreads();
#line 409 "StatisticsModule.cs"
#line 409 "StatisticsModule.cs"
    bool csharp2cuda_temp_12 = (output)->valid;
    if ((!(csharp2cuda_temp_12)))
    {
#line 410 "StatisticsModule.cs"
        return;
    }
#line 412 "StatisticsModule.cs"
    double* csharp2cuda_temp_13;
#line 412 "StatisticsModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 412 "StatisticsModule.cs"
        csharp2cuda_temp_13 = ((double*)(nullptr));
    }
    else
    {
#line 412 "StatisticsModule.cs"
        unsigned long long csharp2cuda_temp_14 = (first)->data_pointer;
#line 412 "StatisticsModule.cs"
        csharp2cuda_temp_13 = ((double*)(csharp2cuda_temp_14));
    }
#line 412 "StatisticsModule.cs"
    const double* a = csharp2cuda_temp_13;
#line 413 "StatisticsModule.cs"
    double* csharp2cuda_temp_15;
#line 413 "StatisticsModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 413 "StatisticsModule.cs"
        csharp2cuda_temp_15 = ((double*)(nullptr));
    }
    else
    {
#line 413 "StatisticsModule.cs"
        unsigned long long csharp2cuda_temp_16 = (second)->data_pointer;
#line 413 "StatisticsModule.cs"
        csharp2cuda_temp_15 = ((double*)(csharp2cuda_temp_16));
    }
#line 413 "StatisticsModule.cs"
    const double* b = csharp2cuda_temp_15;
#line 414 "StatisticsModule.cs"
    unsigned long long csharp2cuda_temp_17 = (output)->data_pointer;
#line 414 "StatisticsModule.cs"
    double* result = ((double*)(csharp2cuda_temp_17));
#line 415 "StatisticsModule.cs"
    unsigned long long csharp2cuda_temp_18 = (output)->scratch_pointer;
#line 415 "StatisticsModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_18));
#line 419 "StatisticsModule.cs"
#line 419 "StatisticsModule.cs"
    bool csharp2cuda_temp_19;
#line 419 "StatisticsModule.cs"
    if (((opcode) == (23)))
    {
#line 419 "StatisticsModule.cs"
        int csharp2cuda_temp_20 = (first)->count;
#line 419 "StatisticsModule.cs"
        csharp2cuda_temp_19 = ((csharp2cuda_temp_20) > (0));
    }
    else
    {
#line 419 "StatisticsModule.cs"
        csharp2cuda_temp_19 = false;
    }
#line 419 "StatisticsModule.cs"
    bool csharp2cuda_temp_21;
#line 419 "StatisticsModule.cs"
    if (csharp2cuda_temp_19)
    {
#line 419 "StatisticsModule.cs"
        int csharp2cuda_temp_22 = (first)->count;
#line 419 "StatisticsModule.cs"
        int csharp2cuda_temp_23 = (second)->count;
#line 419 "StatisticsModule.cs"
        csharp2cuda_temp_21 = ((csharp2cuda_temp_22) == (csharp2cuda_temp_23));
    }
    else
    {
#line 419 "StatisticsModule.cs"
        csharp2cuda_temp_21 = false;
    }
#line 419 "StatisticsModule.cs"
    bool csharp2cuda_temp_24;
#line 419 "StatisticsModule.cs"
    if (csharp2cuda_temp_21)
    {
#line 419 "StatisticsModule.cs"
        csharp2cuda_temp_24 = ((((void*)(scratch))) != (((void*)(nullptr))));
    }
    else
    {
#line 419 "StatisticsModule.cs"
        csharp2cuda_temp_24 = false;
    }
    if (csharp2cuda_temp_24)
#line 420 "StatisticsModule.cs"
    {
#line 421 "StatisticsModule.cs"
        {
#line 421 "StatisticsModule.cs"
            int index = thread;
            while (true)
            {
#line 421 "StatisticsModule.cs"
                int csharp2cuda_temp_27 = (first)->count;
                if (!(((index) < (csharp2cuda_temp_27))))
                    break;
#line 422 "StatisticsModule.cs"
                {
#line 423 "StatisticsModule.cs"
#line 423 "StatisticsModule.cs"
                    double* csharp2cuda_temp_28 = &((scratch)[index]);
#line 423 "StatisticsModule.cs"
                    int csharp2cuda_temp_29 = (first)->count;
#line 423 "StatisticsModule.cs"
                    double csharp2cuda_temp_30 = mathblocks_statistics_rank_at(a, csharp2cuda_temp_29, index);
                    (*(csharp2cuda_temp_28) = csharp2cuda_temp_30);
#line 424 "StatisticsModule.cs"
#line 424 "StatisticsModule.cs"
                    int csharp2cuda_temp_31 = (first)->count;
#line 424 "StatisticsModule.cs"
                    double* csharp2cuda_temp_32 = &((scratch)[csharp2cuda_i32_add(csharp2cuda_temp_31, index)]);
#line 424 "StatisticsModule.cs"
                    int csharp2cuda_temp_33 = (first)->count;
#line 424 "StatisticsModule.cs"
                    double csharp2cuda_temp_34 = mathblocks_statistics_rank_at(b, csharp2cuda_temp_33, index);
                    (*(csharp2cuda_temp_32) = csharp2cuda_temp_34);
                }
#line 421 "StatisticsModule.cs"
                int* csharp2cuda_temp_25 = &(index);
#line 421 "StatisticsModule.cs"
                int csharp2cuda_temp_26 = *(csharp2cuda_temp_25);
                (*(csharp2cuda_temp_25) = csharp2cuda_i32_add(csharp2cuda_temp_26, blockDim.x));
            }
        }
#line 426 "StatisticsModule.cs"
        __syncthreads();
    }
#line 429 "StatisticsModule.cs"
    if (((thread) == (0)))
#line 430 "StatisticsModule.cs"
    {
#line 431 "StatisticsModule.cs"
        switch (opcode)
        {
#line 433 "StatisticsModule.cs"
            case 0:
#line 434 "StatisticsModule.cs"
                {
#line 435 "StatisticsModule.cs"
                    int lag = 0;
#line 436 "StatisticsModule.cs"
#line 436 "StatisticsModule.cs"
                    double csharp2cuda_temp_35 = (second)->scalar_value;
#line 436 "StatisticsModule.cs"
                    int* csharp2cuda_temp_36 = &(lag);
#line 436 "StatisticsModule.cs"
                    bool csharp2cuda_temp_37 = mathblocks_sequence_positive_integer(csharp2cuda_temp_35, csharp2cuda_temp_36);
#line 436 "StatisticsModule.cs"
                    bool csharp2cuda_temp_38;
#line 436 "StatisticsModule.cs"
                    if (!((!(csharp2cuda_temp_37))))
                    {
#line 436 "StatisticsModule.cs"
                        int csharp2cuda_temp_39 = (first)->count;
#line 436 "StatisticsModule.cs"
                        csharp2cuda_temp_38 = ((lag) >= (csharp2cuda_temp_39));
                    }
                    else
                    {
#line 436 "StatisticsModule.cs"
                        csharp2cuda_temp_38 = true;
                    }
                    if (csharp2cuda_temp_38)
#line 437 "StatisticsModule.cs"
                    {
#line 438 "StatisticsModule.cs"
#line 438 "StatisticsModule.cs"
                        int* csharp2cuda_temp_40 = &((output)->valid);
                        (*(csharp2cuda_temp_40) = 0);
#line 439 "StatisticsModule.cs"
                        break;
                    }
#line 441 "StatisticsModule.cs"
                    int csharp2cuda_temp_41 = (first)->count;
#line 441 "StatisticsModule.cs"
                    int count = csharp2cuda_i32_sub(csharp2cuda_temp_41, lag);
#line 442 "StatisticsModule.cs"
#line 442 "StatisticsModule.cs"
                    double* csharp2cuda_temp_42 = &((output)->scalar_value);
#line 442 "StatisticsModule.cs"
                    double csharp2cuda_temp_43 = mathblocks_statistics_pearson(a, csharp2cuda_pointer_add(a, lag), count);
                    (*(csharp2cuda_temp_42) = csharp2cuda_temp_43);
#line 443 "StatisticsModule.cs"
                    break;
                }
#line 445 "StatisticsModule.cs"
            case 1:
            case 18:
#line 447 "StatisticsModule.cs"
#line 449 "StatisticsModule.cs"
                int csharp2cuda_temp_44 = (first)->count;
#line 450 "StatisticsModule.cs"
                double csharp2cuda_temp_45 = (second)->scalar_value;
#line 452 "StatisticsModule.cs"
                double* csharp2cuda_temp_46 = &((output)->scalar_value);
#line 447 "StatisticsModule.cs"
                bool csharp2cuda_temp_47 = mathblocks_statistics_moment_value(a, csharp2cuda_temp_44, csharp2cuda_temp_45, ((opcode) == (1)), csharp2cuda_temp_46);
                if ((!(csharp2cuda_temp_47)))
                {
#line 453 "StatisticsModule.cs"
#line 453 "StatisticsModule.cs"
                    int* csharp2cuda_temp_48 = &((output)->valid);
                    (*(csharp2cuda_temp_48) = 0);
                }
#line 454 "StatisticsModule.cs"
                break;
#line 455 "StatisticsModule.cs"
            case 2:
#line 456 "StatisticsModule.cs"
                {
#line 457 "StatisticsModule.cs"
                    int rows = (first)->rows;
#line 458 "StatisticsModule.cs"
                    int columns = (first)->columns;
#line 459 "StatisticsModule.cs"
                    mathblocks_sequence_set_matrix_shape(output, columns, columns);
#line 460 "StatisticsModule.cs"
#line 460 "StatisticsModule.cs"
                    bool csharp2cuda_temp_49;
#line 460 "StatisticsModule.cs"
                    if (!(((rows) <= (0))))
                    {
#line 460 "StatisticsModule.cs"
                        csharp2cuda_temp_49 = ((columns) <= (0));
                    }
                    else
                    {
#line 460 "StatisticsModule.cs"
                        csharp2cuda_temp_49 = true;
                    }
#line 460 "StatisticsModule.cs"
                    bool csharp2cuda_temp_50;
#line 460 "StatisticsModule.cs"
                    if (!(csharp2cuda_temp_49))
                    {
#line 460 "StatisticsModule.cs"
                        csharp2cuda_temp_50 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 460 "StatisticsModule.cs"
                        csharp2cuda_temp_50 = true;
                    }
                    if (csharp2cuda_temp_50)
#line 461 "StatisticsModule.cs"
                    {
#line 462 "StatisticsModule.cs"
#line 462 "StatisticsModule.cs"
                        int* csharp2cuda_temp_51 = &((output)->valid);
                        (*(csharp2cuda_temp_51) = 0);
#line 463 "StatisticsModule.cs"
                        break;
                    }
#line 465 "StatisticsModule.cs"
                    {
#line 465 "StatisticsModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (columns))))
                                break;
#line 466 "StatisticsModule.cs"
                            {
#line 467 "StatisticsModule.cs"
#line 467 "StatisticsModule.cs"
                                double* csharp2cuda_temp_53 = &((scratch)[column]);
                                (*(csharp2cuda_temp_53) = 0.0);
#line 468 "StatisticsModule.cs"
                                {
#line 468 "StatisticsModule.cs"
                                    int row = 0;
                                    while (true)
                                    {
                                        if (!(((row) < (rows))))
                                            break;
#line 469 "StatisticsModule.cs"
#line 469 "StatisticsModule.cs"
                                        double* csharp2cuda_temp_55 = &((scratch)[column]);
#line 469 "StatisticsModule.cs"
                                        double csharp2cuda_temp_56 = *(csharp2cuda_temp_55);
#line 469 "StatisticsModule.cs"
                                        double csharp2cuda_temp_57 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 469 "StatisticsModule.cs"
                                        double csharp2cuda_temp_58 = __ddiv_rn(csharp2cuda_temp_57, ((double)(rows)));
                                        (*(csharp2cuda_temp_55) = __dadd_rn(csharp2cuda_temp_56, csharp2cuda_temp_58));
#line 468 "StatisticsModule.cs"
                                        int* csharp2cuda_temp_54 = &(row);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_54));
                                    }
                                }
                            }
#line 465 "StatisticsModule.cs"
                            int* csharp2cuda_temp_52 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_52));
                        }
                    }
#line 471 "StatisticsModule.cs"
                    {
#line 471 "StatisticsModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (columns))))
                                break;
#line 472 "StatisticsModule.cs"
                            {
#line 473 "StatisticsModule.cs"
                                {
#line 473 "StatisticsModule.cs"
                                    int right = left;
                                    while (true)
                                    {
                                        if (!(((right) < (columns))))
                                            break;
#line 474 "StatisticsModule.cs"
                                        {
#line 475 "StatisticsModule.cs"
                                            double sum = 0.0;
#line 476 "StatisticsModule.cs"
                                            {
#line 476 "StatisticsModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
                                                    if (!(((row) < (rows))))
                                                        break;
#line 477 "StatisticsModule.cs"
                                                    {
#line 478 "StatisticsModule.cs"
#line 478 "StatisticsModule.cs"
                                                        double* csharp2cuda_temp_62 = &(sum);
#line 478 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_63 = *(csharp2cuda_temp_62);
#line 478 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_64 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), left)];
#line 478 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_65 = (scratch)[left];
#line 479 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_66 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), right)];
#line 479 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_67 = (scratch)[right];
                                                        (*(csharp2cuda_temp_62) = __dadd_rn(csharp2cuda_temp_63, __dmul_rn(__dsub_rn(csharp2cuda_temp_64, csharp2cuda_temp_65), __dsub_rn(csharp2cuda_temp_66, csharp2cuda_temp_67))));
                                                    }
#line 476 "StatisticsModule.cs"
                                                    int* csharp2cuda_temp_61 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_61));
                                                }
                                            }
#line 481 "StatisticsModule.cs"
                                            double covariance = __ddiv_rn(sum, ((double)(rows)));
#line 482 "StatisticsModule.cs"
#line 482 "StatisticsModule.cs"
                                            double* csharp2cuda_temp_68 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, columns), right)]);
                                            (*(csharp2cuda_temp_68) = covariance);
#line 483 "StatisticsModule.cs"
#line 483 "StatisticsModule.cs"
                                            double* csharp2cuda_temp_69 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(right, columns), left)]);
                                            (*(csharp2cuda_temp_69) = covariance);
#line 484 "StatisticsModule.cs"
                                            if ((!(isfinite(covariance))))
                                            {
#line 484 "StatisticsModule.cs"
#line 484 "StatisticsModule.cs"
                                                int* csharp2cuda_temp_70 = &((output)->valid);
                                                (*(csharp2cuda_temp_70) = 0);
                                            }
                                        }
#line 473 "StatisticsModule.cs"
                                        int* csharp2cuda_temp_60 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_60));
                                    }
                                }
                            }
#line 471 "StatisticsModule.cs"
                            int* csharp2cuda_temp_59 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_59));
                        }
                    }
#line 487 "StatisticsModule.cs"
                    break;
                }
#line 489 "StatisticsModule.cs"
            case 3:
#line 490 "StatisticsModule.cs"
                {
#line 491 "StatisticsModule.cs"
                    int count = (first)->count;
#line 492 "StatisticsModule.cs"
#line 492 "StatisticsModule.cs"
                    bool csharp2cuda_temp_71;
#line 492 "StatisticsModule.cs"
                    if (!(((count) <= (0))))
                    {
#line 492 "StatisticsModule.cs"
                        int csharp2cuda_temp_72 = (second)->count;
#line 492 "StatisticsModule.cs"
                        csharp2cuda_temp_71 = ((count) != (csharp2cuda_temp_72));
                    }
                    else
                    {
#line 492 "StatisticsModule.cs"
                        csharp2cuda_temp_71 = true;
                    }
#line 492 "StatisticsModule.cs"
                    bool csharp2cuda_temp_73;
#line 492 "StatisticsModule.cs"
                    if (!(csharp2cuda_temp_71))
                    {
#line 492 "StatisticsModule.cs"
                        csharp2cuda_temp_73 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 492 "StatisticsModule.cs"
                        csharp2cuda_temp_73 = true;
                    }
                    if (csharp2cuda_temp_73)
#line 493 "StatisticsModule.cs"
                    {
#line 494 "StatisticsModule.cs"
#line 494 "StatisticsModule.cs"
                        int* csharp2cuda_temp_74 = &((output)->valid);
                        (*(csharp2cuda_temp_74) = 0);
#line 495 "StatisticsModule.cs"
                        break;
                    }
#line 497 "StatisticsModule.cs"
                    double* left_distances = scratch;
#line 498 "StatisticsModule.cs"
                    double* right_distances = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(count, count));
#line 499 "StatisticsModule.cs"
                    double* row_means = csharp2cuda_pointer_add(right_distances, csharp2cuda_i32_mul(count, count));
#line 500 "StatisticsModule.cs"
                    mathblocks_statistics_center_distance(a, count, left_distances, row_means);
#line 501 "StatisticsModule.cs"
                    mathblocks_statistics_center_distance(b, count, right_distances, row_means);
#line 502 "StatisticsModule.cs"
                    double covariance_square = 0.0;
#line 503 "StatisticsModule.cs"
                    double left_variance_square = 0.0;
#line 504 "StatisticsModule.cs"
                    double right_variance_square = 0.0;
#line 505 "StatisticsModule.cs"
                    {
#line 505 "StatisticsModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(count, count)))))
                                break;
#line 506 "StatisticsModule.cs"
                            {
#line 507 "StatisticsModule.cs"
#line 507 "StatisticsModule.cs"
                                double* csharp2cuda_temp_76 = &(covariance_square);
#line 507 "StatisticsModule.cs"
                                double csharp2cuda_temp_77 = *(csharp2cuda_temp_76);
#line 507 "StatisticsModule.cs"
                                double csharp2cuda_temp_78 = (left_distances)[index];
#line 507 "StatisticsModule.cs"
                                double csharp2cuda_temp_79 = (right_distances)[index];
                                (*(csharp2cuda_temp_76) = __dadd_rn(csharp2cuda_temp_77, __dmul_rn(csharp2cuda_temp_78, csharp2cuda_temp_79)));
#line 508 "StatisticsModule.cs"
#line 508 "StatisticsModule.cs"
                                double* csharp2cuda_temp_80 = &(left_variance_square);
#line 508 "StatisticsModule.cs"
                                double csharp2cuda_temp_81 = *(csharp2cuda_temp_80);
#line 508 "StatisticsModule.cs"
                                double csharp2cuda_temp_82 = (left_distances)[index];
#line 508 "StatisticsModule.cs"
                                double csharp2cuda_temp_83 = (left_distances)[index];
                                (*(csharp2cuda_temp_80) = __dadd_rn(csharp2cuda_temp_81, __dmul_rn(csharp2cuda_temp_82, csharp2cuda_temp_83)));
#line 509 "StatisticsModule.cs"
#line 509 "StatisticsModule.cs"
                                double* csharp2cuda_temp_84 = &(right_variance_square);
#line 509 "StatisticsModule.cs"
                                double csharp2cuda_temp_85 = *(csharp2cuda_temp_84);
#line 509 "StatisticsModule.cs"
                                double csharp2cuda_temp_86 = (right_distances)[index];
#line 509 "StatisticsModule.cs"
                                double csharp2cuda_temp_87 = (right_distances)[index];
                                (*(csharp2cuda_temp_84) = __dadd_rn(csharp2cuda_temp_85, __dmul_rn(csharp2cuda_temp_86, csharp2cuda_temp_87)));
                            }
#line 505 "StatisticsModule.cs"
                            int* csharp2cuda_temp_75 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_75));
                        }
                    }
#line 511 "StatisticsModule.cs"
#line 511 "StatisticsModule.cs"
                    double* csharp2cuda_temp_88 = &(covariance_square);
#line 511 "StatisticsModule.cs"
                    double csharp2cuda_temp_89 = *(csharp2cuda_temp_88);
                    (*(csharp2cuda_temp_88) = __ddiv_rn(csharp2cuda_temp_89, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 512 "StatisticsModule.cs"
#line 512 "StatisticsModule.cs"
                    double* csharp2cuda_temp_90 = &(left_variance_square);
#line 512 "StatisticsModule.cs"
                    double csharp2cuda_temp_91 = *(csharp2cuda_temp_90);
                    (*(csharp2cuda_temp_90) = __ddiv_rn(csharp2cuda_temp_91, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 513 "StatisticsModule.cs"
#line 513 "StatisticsModule.cs"
                    double* csharp2cuda_temp_92 = &(right_variance_square);
#line 513 "StatisticsModule.cs"
                    double csharp2cuda_temp_93 = *(csharp2cuda_temp_92);
                    (*(csharp2cuda_temp_92) = __ddiv_rn(csharp2cuda_temp_93, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 514 "StatisticsModule.cs"
#line 514 "StatisticsModule.cs"
                    double* csharp2cuda_temp_94 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_94) = mathblocks_statistics_distance_correlation_value(covariance_square, left_variance_square, right_variance_square));
#line 516 "StatisticsModule.cs"
                    break;
                }
#line 518 "StatisticsModule.cs"
            case 4:
#line 519 "StatisticsModule.cs"
                {
#line 520 "StatisticsModule.cs"
#line 520 "StatisticsModule.cs"
                    int csharp2cuda_temp_95 = (second)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_95, 1));
#line 521 "StatisticsModule.cs"
                    {
#line 521 "StatisticsModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 521 "StatisticsModule.cs"
                            int csharp2cuda_temp_97 = (second)->count;
                            if (!(((index) < (csharp2cuda_temp_97))))
                                break;
#line 522 "StatisticsModule.cs"
                            {
#line 523 "StatisticsModule.cs"
#line 523 "StatisticsModule.cs"
                                double csharp2cuda_temp_98 = (b)[index];
#line 523 "StatisticsModule.cs"
                                double csharp2cuda_temp_99 = (b)[csharp2cuda_i32_sub(index, 1)];
                                if (((csharp2cuda_temp_98) <= (csharp2cuda_temp_99)))
#line 524 "StatisticsModule.cs"
                                {
#line 525 "StatisticsModule.cs"
#line 525 "StatisticsModule.cs"
                                    int* csharp2cuda_temp_100 = &((output)->valid);
                                    (*(csharp2cuda_temp_100) = 0);
#line 526 "StatisticsModule.cs"
                                    break;
                                }
                            }
#line 521 "StatisticsModule.cs"
                            int* csharp2cuda_temp_96 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_96));
                        }
                    }
#line 529 "StatisticsModule.cs"
                    {
#line 529 "StatisticsModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 529 "StatisticsModule.cs"
                            bool csharp2cuda_temp_102 = (output)->valid;
#line 529 "StatisticsModule.cs"
                            bool csharp2cuda_temp_103;
#line 529 "StatisticsModule.cs"
                            if (csharp2cuda_temp_102)
                            {
#line 529 "StatisticsModule.cs"
                                int csharp2cuda_temp_104 = (output)->count;
#line 529 "StatisticsModule.cs"
                                csharp2cuda_temp_103 = ((index) < (csharp2cuda_temp_104));
                            }
                            else
                            {
#line 529 "StatisticsModule.cs"
                                csharp2cuda_temp_103 = false;
                            }
                            if (!(csharp2cuda_temp_103))
                                break;
#line 530 "StatisticsModule.cs"
#line 530 "StatisticsModule.cs"
                            double* csharp2cuda_temp_105 = &((result)[index]);
                            (*(csharp2cuda_temp_105) = 0.0);
#line 529 "StatisticsModule.cs"
                            int* csharp2cuda_temp_101 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_101));
                        }
                    }
#line 531 "StatisticsModule.cs"
                    {
#line 531 "StatisticsModule.cs"
                        int value_index = 0;
                        while (true)
                        {
#line 531 "StatisticsModule.cs"
                            bool csharp2cuda_temp_107 = (output)->valid;
#line 531 "StatisticsModule.cs"
                            bool csharp2cuda_temp_108;
#line 531 "StatisticsModule.cs"
                            if (csharp2cuda_temp_107)
                            {
#line 531 "StatisticsModule.cs"
                                int csharp2cuda_temp_109 = (first)->count;
#line 531 "StatisticsModule.cs"
                                csharp2cuda_temp_108 = ((value_index) < (csharp2cuda_temp_109));
                            }
                            else
                            {
#line 531 "StatisticsModule.cs"
                                csharp2cuda_temp_108 = false;
                            }
                            if (!(csharp2cuda_temp_108))
                                break;
#line 532 "StatisticsModule.cs"
                            {
#line 533 "StatisticsModule.cs"
                                int lower = 0;
#line 534 "StatisticsModule.cs"
                                int upper = (second)->count;
#line 535 "StatisticsModule.cs"
                                while (true)
                                {
                                    if (!(((lower) < (upper))))
                                        break;
#line 536 "StatisticsModule.cs"
                                    {
#line 537 "StatisticsModule.cs"
                                        int csharp2cuda_temp_110 = csharp2cuda_i32_div(csharp2cuda_i32_sub(upper, lower), 2);
#line 537 "StatisticsModule.cs"
                                        int middle = csharp2cuda_i32_add(lower, csharp2cuda_temp_110);
#line 538 "StatisticsModule.cs"
#line 538 "StatisticsModule.cs"
                                        double csharp2cuda_temp_111 = (a)[value_index];
#line 538 "StatisticsModule.cs"
                                        double csharp2cuda_temp_112 = (b)[middle];
                                        if (((csharp2cuda_temp_111) <= (csharp2cuda_temp_112)))
                                        {
#line 539 "StatisticsModule.cs"
#line 539 "StatisticsModule.cs"
                                            int* csharp2cuda_temp_113 = &(upper);
                                            (*(csharp2cuda_temp_113) = middle);
                                        }
                                        else
                                        {
#line 541 "StatisticsModule.cs"
#line 541 "StatisticsModule.cs"
                                            int* csharp2cuda_temp_114 = &(lower);
                                            (*(csharp2cuda_temp_114) = csharp2cuda_i32_add(middle, 1));
                                        }
                                    }
                                }
#line 543 "StatisticsModule.cs"
#line 543 "StatisticsModule.cs"
                                double* csharp2cuda_temp_115 = &((result)[lower]);
#line 543 "StatisticsModule.cs"
                                double csharp2cuda_temp_116 = *(csharp2cuda_temp_115);
                                (*(csharp2cuda_temp_115) = __dadd_rn(csharp2cuda_temp_116, 1.0));
                            }
#line 531 "StatisticsModule.cs"
                            int* csharp2cuda_temp_106 = &(value_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_106));
                        }
                    }
#line 545 "StatisticsModule.cs"
                    break;
                }
#line 547 "StatisticsModule.cs"
            case 5:
#line 548 "StatisticsModule.cs"
                {
#line 549 "StatisticsModule.cs"
#line 549 "StatisticsModule.cs"
                    int csharp2cuda_temp_117 = (first)->count;
#line 549 "StatisticsModule.cs"
                    bool csharp2cuda_temp_118;
#line 549 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_117) <= (0))))
                    {
#line 549 "StatisticsModule.cs"
                        csharp2cuda_temp_118 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 549 "StatisticsModule.cs"
                        csharp2cuda_temp_118 = true;
                    }
                    if (csharp2cuda_temp_118)
#line 550 "StatisticsModule.cs"
                    {
#line 551 "StatisticsModule.cs"
#line 551 "StatisticsModule.cs"
                        int* csharp2cuda_temp_119 = &((output)->valid);
                        (*(csharp2cuda_temp_119) = 0);
#line 552 "StatisticsModule.cs"
                        break;
                    }
#line 554 "StatisticsModule.cs"
#line 554 "StatisticsModule.cs"
                    int csharp2cuda_temp_120 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_120, scratch, false);
#line 555 "StatisticsModule.cs"
#line 555 "StatisticsModule.cs"
                    double* csharp2cuda_temp_121 = &((output)->scalar_value);
#line 556 "StatisticsModule.cs"
                    int csharp2cuda_temp_122 = (first)->count;
#line 556 "StatisticsModule.cs"
                    double csharp2cuda_temp_123 = mathblocks_statistics_sorted_quantile(scratch, csharp2cuda_temp_122, 0.75);
#line 557 "StatisticsModule.cs"
                    int csharp2cuda_temp_124 = (first)->count;
#line 557 "StatisticsModule.cs"
                    double csharp2cuda_temp_125 = mathblocks_statistics_sorted_quantile(scratch, csharp2cuda_temp_124, 0.25);
                    (*(csharp2cuda_temp_121) = __dsub_rn(csharp2cuda_temp_123, csharp2cuda_temp_125));
#line 558 "StatisticsModule.cs"
                    break;
                }
#line 560 "StatisticsModule.cs"
            case 6:
#line 561 "StatisticsModule.cs"
#line 561 "StatisticsModule.cs"
                int csharp2cuda_temp_126 = (first)->count;
#line 561 "StatisticsModule.cs"
                int csharp2cuda_temp_127 = (second)->count;
#line 561 "StatisticsModule.cs"
                bool csharp2cuda_temp_128;
#line 561 "StatisticsModule.cs"
                if (!(((csharp2cuda_temp_126) != (csharp2cuda_temp_127))))
                {
#line 562 "StatisticsModule.cs"
                    int csharp2cuda_temp_129 = (first)->count;
#line 562 "StatisticsModule.cs"
                    double* csharp2cuda_temp_130 = &((output)->scalar_value);
#line 562 "StatisticsModule.cs"
                    bool csharp2cuda_temp_131 = mathblocks_statistics_kendall_value(a, b, csharp2cuda_temp_129, csharp2cuda_temp_130);
#line 561 "StatisticsModule.cs"
                    csharp2cuda_temp_128 = (!(csharp2cuda_temp_131));
                }
                else
                {
#line 561 "StatisticsModule.cs"
                    csharp2cuda_temp_128 = true;
                }
                if (csharp2cuda_temp_128)
                {
#line 563 "StatisticsModule.cs"
#line 563 "StatisticsModule.cs"
                    int* csharp2cuda_temp_132 = &((output)->valid);
                    (*(csharp2cuda_temp_132) = 0);
                }
#line 564 "StatisticsModule.cs"
                break;
#line 565 "StatisticsModule.cs"
            case 7:
            case 8:
            case 9:
            case 11:
            case 12:
            case 20:
#line 571 "StatisticsModule.cs"
                {
#line 572 "StatisticsModule.cs"
#line 572 "StatisticsModule.cs"
                    int csharp2cuda_temp_133 = (first)->count;
#line 572 "StatisticsModule.cs"
                    bool csharp2cuda_temp_134;
#line 572 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_133) <= (0))))
                    {
#line 572 "StatisticsModule.cs"
                        int csharp2cuda_temp_135 = (first)->count;
#line 572 "StatisticsModule.cs"
                        int csharp2cuda_temp_136 = (second)->count;
#line 572 "StatisticsModule.cs"
                        csharp2cuda_temp_134 = ((csharp2cuda_temp_135) != (csharp2cuda_temp_136));
                    }
                    else
                    {
#line 572 "StatisticsModule.cs"
                        csharp2cuda_temp_134 = true;
                    }
                    if (csharp2cuda_temp_134)
#line 573 "StatisticsModule.cs"
                    {
#line 574 "StatisticsModule.cs"
#line 574 "StatisticsModule.cs"
                        int* csharp2cuda_temp_137 = &((output)->valid);
                        (*(csharp2cuda_temp_137) = 0);
#line 575 "StatisticsModule.cs"
                        break;
                    }
#line 577 "StatisticsModule.cs"
                    int csharp2cuda_temp_138 = (first)->count;
#line 577 "StatisticsModule.cs"
                    double covariance = mathblocks_statistics_population_covariance(a, b, csharp2cuda_temp_138);
#line 578 "StatisticsModule.cs"
#line 578 "StatisticsModule.cs"
                    bool csharp2cuda_temp_139;
#line 578 "StatisticsModule.cs"
                    if (!(((opcode) == (12))))
                    {
#line 578 "StatisticsModule.cs"
                        csharp2cuda_temp_139 = ((opcode) == (20));
                    }
                    else
                    {
#line 578 "StatisticsModule.cs"
                        csharp2cuda_temp_139 = true;
                    }
                    if (csharp2cuda_temp_139)
#line 579 "StatisticsModule.cs"
                    {
#line 580 "StatisticsModule.cs"
#line 580 "StatisticsModule.cs"
                        double* csharp2cuda_temp_140 = &((output)->scalar_value);
#line 580 "StatisticsModule.cs"
                        double csharp2cuda_temp_141;
#line 580 "StatisticsModule.cs"
                        if (((opcode) == (12)))
                        {
#line 580 "StatisticsModule.cs"
                            csharp2cuda_temp_141 = covariance;
                        }
                        else
                        {
#line 582 "StatisticsModule.cs"
                            int csharp2cuda_temp_142 = (first)->count;
#line 582 "StatisticsModule.cs"
                            int csharp2cuda_temp_143 = (first)->count;
#line 580 "StatisticsModule.cs"
                            csharp2cuda_temp_141 = __ddiv_rn(__dmul_rn(covariance, ((double)(csharp2cuda_temp_142))), __dsub_rn(((double)(csharp2cuda_temp_143)), 1.0));
                        }
                        (*(csharp2cuda_temp_140) = csharp2cuda_temp_141);
                    }
                    else
                    {
#line 584 "StatisticsModule.cs"
                        if (((opcode) == (9)))
#line 585 "StatisticsModule.cs"
                        {
#line 586 "StatisticsModule.cs"
#line 586 "StatisticsModule.cs"
                            double* csharp2cuda_temp_144 = &((output)->scalar_value);
#line 587 "StatisticsModule.cs"
                            int csharp2cuda_temp_145 = (first)->count;
#line 587 "StatisticsModule.cs"
                            double csharp2cuda_temp_146 = mathblocks_statistics_population_variance(a, csharp2cuda_temp_145);
                            (*(csharp2cuda_temp_144) = mathblocks_statistics_quotient_by_variance(covariance, csharp2cuda_temp_146));
                        }
                        else
                        {
#line 589 "StatisticsModule.cs"
                            if (((opcode) == (7)))
#line 590 "StatisticsModule.cs"
                            {
#line 592 "StatisticsModule.cs"
                                int csharp2cuda_temp_147 = (first)->count;
#line 592 "StatisticsModule.cs"
                                double csharp2cuda_temp_148 = mathblocks_statistics_population_variance(a, csharp2cuda_temp_147);
#line 591 "StatisticsModule.cs"
                                double slope = mathblocks_statistics_quotient_by_variance(covariance, csharp2cuda_temp_148);
#line 593 "StatisticsModule.cs"
#line 593 "StatisticsModule.cs"
                                double* csharp2cuda_temp_149 = &((output)->scalar_value);
#line 593 "StatisticsModule.cs"
                                int csharp2cuda_temp_150 = (first)->count;
#line 593 "StatisticsModule.cs"
                                double csharp2cuda_temp_151 = mathblocks_statistics_mean(b, csharp2cuda_temp_150);
#line 594 "StatisticsModule.cs"
                                int csharp2cuda_temp_152 = (first)->count;
#line 594 "StatisticsModule.cs"
                                double csharp2cuda_temp_153 = mathblocks_statistics_mean(a, csharp2cuda_temp_152);
                                (*(csharp2cuda_temp_149) = __dsub_rn(csharp2cuda_temp_151, __dmul_rn(slope, csharp2cuda_temp_153)));
                            }
                            else
#line 597 "StatisticsModule.cs"
                            {
#line 600 "StatisticsModule.cs"
                                int csharp2cuda_temp_154 = (first)->count;
#line 600 "StatisticsModule.cs"
                                double csharp2cuda_temp_155 = mathblocks_statistics_population_variance(a, csharp2cuda_temp_154);
#line 601 "StatisticsModule.cs"
                                int csharp2cuda_temp_156 = (first)->count;
#line 601 "StatisticsModule.cs"
                                double csharp2cuda_temp_157 = mathblocks_statistics_population_variance(b, csharp2cuda_temp_156);
#line 598 "StatisticsModule.cs"
                                double correlation = mathblocks_statistics_correlation_value(covariance, csharp2cuda_temp_155, csharp2cuda_temp_157);
#line 602 "StatisticsModule.cs"
#line 602 "StatisticsModule.cs"
                                double* csharp2cuda_temp_158 = &((output)->scalar_value);
#line 602 "StatisticsModule.cs"
                                double csharp2cuda_temp_159;
#line 602 "StatisticsModule.cs"
                                if (((opcode) == (8)))
                                {
#line 602 "StatisticsModule.cs"
                                    csharp2cuda_temp_159 = __dmul_rn(correlation, correlation);
                                }
                                else
                                {
#line 602 "StatisticsModule.cs"
                                    csharp2cuda_temp_159 = correlation;
                                }
                                (*(csharp2cuda_temp_158) = csharp2cuda_temp_159);
                            }
                        }
                    }
#line 604 "StatisticsModule.cs"
                    break;
                }
#line 606 "StatisticsModule.cs"
            case 10:
#line 607 "StatisticsModule.cs"
                {
#line 608 "StatisticsModule.cs"
#line 608 "StatisticsModule.cs"
                    int csharp2cuda_temp_160 = (first)->count;
#line 608 "StatisticsModule.cs"
                    bool csharp2cuda_temp_161;
#line 608 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_160) <= (0))))
                    {
#line 608 "StatisticsModule.cs"
                        csharp2cuda_temp_161 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 608 "StatisticsModule.cs"
                        csharp2cuda_temp_161 = true;
                    }
                    if (csharp2cuda_temp_161)
#line 609 "StatisticsModule.cs"
                    {
#line 610 "StatisticsModule.cs"
#line 610 "StatisticsModule.cs"
                        int* csharp2cuda_temp_162 = &((output)->valid);
                        (*(csharp2cuda_temp_162) = 0);
#line 611 "StatisticsModule.cs"
                        break;
                    }
#line 613 "StatisticsModule.cs"
                    double* sorted = scratch;
#line 614 "StatisticsModule.cs"
                    int csharp2cuda_temp_163 = (first)->count;
#line 614 "StatisticsModule.cs"
                    double* deviations = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_163);
#line 615 "StatisticsModule.cs"
#line 615 "StatisticsModule.cs"
                    int csharp2cuda_temp_164 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_164, sorted, false);
#line 616 "StatisticsModule.cs"
                    int csharp2cuda_temp_165 = (first)->count;
#line 616 "StatisticsModule.cs"
                    double median = mathblocks_statistics_sorted_quantile(sorted, csharp2cuda_temp_165, 0.5);
#line 617 "StatisticsModule.cs"
                    {
#line 617 "StatisticsModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 617 "StatisticsModule.cs"
                            int csharp2cuda_temp_167 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_167))))
                                break;
#line 618 "StatisticsModule.cs"
#line 618 "StatisticsModule.cs"
                            double* csharp2cuda_temp_168 = &((deviations)[index]);
#line 618 "StatisticsModule.cs"
                            double csharp2cuda_temp_169 = (a)[index];
                            (*(csharp2cuda_temp_168) = fabs(__dsub_rn(csharp2cuda_temp_169, median)));
#line 617 "StatisticsModule.cs"
                            int* csharp2cuda_temp_166 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_166));
                        }
                    }
#line 619 "StatisticsModule.cs"
#line 619 "StatisticsModule.cs"
                    int csharp2cuda_temp_170 = (first)->count;
                    mathblocks_statistics_sort_copy(deviations, csharp2cuda_temp_170, sorted, false);
#line 620 "StatisticsModule.cs"
#line 620 "StatisticsModule.cs"
                    double* csharp2cuda_temp_171 = &((output)->scalar_value);
#line 620 "StatisticsModule.cs"
                    int csharp2cuda_temp_172 = (first)->count;
#line 620 "StatisticsModule.cs"
                    double csharp2cuda_temp_173 = mathblocks_statistics_sorted_quantile(sorted, csharp2cuda_temp_172, 0.5);
                    (*(csharp2cuda_temp_171) = csharp2cuda_temp_173);
#line 621 "StatisticsModule.cs"
                    break;
                }
#line 623 "StatisticsModule.cs"
            case 13:
            case 14:
#line 625 "StatisticsModule.cs"
#line 627 "StatisticsModule.cs"
                int csharp2cuda_temp_174 = (first)->count;
#line 629 "StatisticsModule.cs"
                double* csharp2cuda_temp_175 = &((output)->scalar_value);
#line 625 "StatisticsModule.cs"
                bool csharp2cuda_temp_176 = mathblocks_statistics_shape_moment_value(a, csharp2cuda_temp_174, ((opcode) == (13)), csharp2cuda_temp_175);
                if ((!(csharp2cuda_temp_176)))
                {
#line 630 "StatisticsModule.cs"
#line 630 "StatisticsModule.cs"
                    int* csharp2cuda_temp_177 = &((output)->valid);
                    (*(csharp2cuda_temp_177) = 0);
                }
#line 631 "StatisticsModule.cs"
                break;
#line 632 "StatisticsModule.cs"
            case 15:
            case 16:
            case 21:
            case 22:
#line 636 "StatisticsModule.cs"
                {
#line 637 "StatisticsModule.cs"
#line 637 "StatisticsModule.cs"
                    int csharp2cuda_temp_178 = (first)->count;
                    if (((csharp2cuda_temp_178) <= (0)))
#line 638 "StatisticsModule.cs"
                    {
#line 639 "StatisticsModule.cs"
#line 639 "StatisticsModule.cs"
                        int* csharp2cuda_temp_179 = &((output)->valid);
                        (*(csharp2cuda_temp_179) = 0);
#line 640 "StatisticsModule.cs"
                        break;
                    }
#line 642 "StatisticsModule.cs"
                    int csharp2cuda_temp_180 = (first)->count;
#line 642 "StatisticsModule.cs"
                    double variance = mathblocks_statistics_population_variance(a, csharp2cuda_temp_180);
#line 643 "StatisticsModule.cs"
#line 643 "StatisticsModule.cs"
                    bool csharp2cuda_temp_181;
#line 643 "StatisticsModule.cs"
                    if (!(((opcode) == (21))))
                    {
#line 643 "StatisticsModule.cs"
                        csharp2cuda_temp_181 = ((opcode) == (22));
                    }
                    else
                    {
#line 643 "StatisticsModule.cs"
                        csharp2cuda_temp_181 = true;
                    }
                    if (csharp2cuda_temp_181)
                    {
#line 644 "StatisticsModule.cs"
#line 644 "StatisticsModule.cs"
                        double* csharp2cuda_temp_182 = &(variance);
#line 644 "StatisticsModule.cs"
                        int csharp2cuda_temp_183 = (first)->count;
#line 644 "StatisticsModule.cs"
                        int csharp2cuda_temp_184 = (first)->count;
#line 644 "StatisticsModule.cs"
                        double csharp2cuda_temp_185 = __ddiv_rn(__dmul_rn(variance, ((double)(csharp2cuda_temp_183))), __dsub_rn(((double)(csharp2cuda_temp_184)), 1.0));
                        (*(csharp2cuda_temp_182) = csharp2cuda_temp_185);
                    }
#line 645 "StatisticsModule.cs"
#line 645 "StatisticsModule.cs"
                    double* csharp2cuda_temp_186 = &((output)->scalar_value);
#line 645 "StatisticsModule.cs"
                    bool csharp2cuda_temp_187;
#line 645 "StatisticsModule.cs"
                    if (!(((opcode) == (15))))
                    {
#line 645 "StatisticsModule.cs"
                        csharp2cuda_temp_187 = ((opcode) == (21));
                    }
                    else
                    {
#line 645 "StatisticsModule.cs"
                        csharp2cuda_temp_187 = true;
                    }
#line 645 "StatisticsModule.cs"
                    double csharp2cuda_temp_188;
#line 645 "StatisticsModule.cs"
                    if (csharp2cuda_temp_187)
                    {
#line 645 "StatisticsModule.cs"
                        csharp2cuda_temp_188 = mathblocks_square_root(variance);
                    }
                    else
                    {
#line 645 "StatisticsModule.cs"
                        csharp2cuda_temp_188 = variance;
                    }
                    (*(csharp2cuda_temp_186) = csharp2cuda_temp_188);
#line 648 "StatisticsModule.cs"
                    break;
                }
#line 650 "StatisticsModule.cs"
            case 17:
#line 651 "StatisticsModule.cs"
                {
#line 652 "StatisticsModule.cs"
#line 652 "StatisticsModule.cs"
                    int csharp2cuda_temp_189 = (first)->count;
#line 652 "StatisticsModule.cs"
                    bool csharp2cuda_temp_190;
#line 652 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_189) <= (0))))
                    {
#line 652 "StatisticsModule.cs"
                        csharp2cuda_temp_190 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 652 "StatisticsModule.cs"
                        csharp2cuda_temp_190 = true;
                    }
                    if (csharp2cuda_temp_190)
#line 653 "StatisticsModule.cs"
                    {
#line 654 "StatisticsModule.cs"
#line 654 "StatisticsModule.cs"
                        int* csharp2cuda_temp_191 = &((output)->valid);
                        (*(csharp2cuda_temp_191) = 0);
#line 655 "StatisticsModule.cs"
                        break;
                    }
#line 657 "StatisticsModule.cs"
                    int csharp2cuda_temp_192 = (first)->count;
#line 657 "StatisticsModule.cs"
                    int count = mathblocks_statistics_pair_averages(a, csharp2cuda_temp_192, scratch);
#line 658 "StatisticsModule.cs"
#line 658 "StatisticsModule.cs"
                    double* csharp2cuda_temp_193 = &((output)->scalar_value);
#line 658 "StatisticsModule.cs"
                    double csharp2cuda_temp_194 = mathblocks_statistics_median(scratch, count);
                    (*(csharp2cuda_temp_193) = csharp2cuda_temp_194);
#line 659 "StatisticsModule.cs"
                    break;
                }
#line 661 "StatisticsModule.cs"
            case 19:
#line 662 "StatisticsModule.cs"
#line 662 "StatisticsModule.cs"
                double* csharp2cuda_temp_195 = &((output)->scalar_value);
#line 663 "StatisticsModule.cs"
                int csharp2cuda_temp_196 = (first)->count;
#line 663 "StatisticsModule.cs"
                int csharp2cuda_temp_197 = (first)->count;
#line 663 "StatisticsModule.cs"
                double csharp2cuda_temp_198 = __ddiv_rn(mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_196), ((double)(csharp2cuda_temp_197)));
                (*(csharp2cuda_temp_195) = mathblocks_square_root(csharp2cuda_temp_198));
#line 664 "StatisticsModule.cs"
                break;
#line 665 "StatisticsModule.cs"
            case 23:
#line 666 "StatisticsModule.cs"
                {
#line 667 "StatisticsModule.cs"
#line 667 "StatisticsModule.cs"
                    int csharp2cuda_temp_199 = (first)->count;
#line 667 "StatisticsModule.cs"
                    bool csharp2cuda_temp_200;
#line 667 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_199) <= (0))))
                    {
#line 667 "StatisticsModule.cs"
                        int csharp2cuda_temp_201 = (first)->count;
#line 667 "StatisticsModule.cs"
                        int csharp2cuda_temp_202 = (second)->count;
#line 667 "StatisticsModule.cs"
                        csharp2cuda_temp_200 = ((csharp2cuda_temp_201) != (csharp2cuda_temp_202));
                    }
                    else
                    {
#line 667 "StatisticsModule.cs"
                        csharp2cuda_temp_200 = true;
                    }
#line 667 "StatisticsModule.cs"
                    bool csharp2cuda_temp_203;
#line 667 "StatisticsModule.cs"
                    if (!(csharp2cuda_temp_200))
                    {
#line 667 "StatisticsModule.cs"
                        csharp2cuda_temp_203 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 667 "StatisticsModule.cs"
                        csharp2cuda_temp_203 = true;
                    }
                    if (csharp2cuda_temp_203)
#line 668 "StatisticsModule.cs"
                    {
#line 669 "StatisticsModule.cs"
#line 669 "StatisticsModule.cs"
                        int* csharp2cuda_temp_204 = &((output)->valid);
                        (*(csharp2cuda_temp_204) = 0);
#line 670 "StatisticsModule.cs"
                        break;
                    }
#line 673 "StatisticsModule.cs"
                    double* left_ranks = scratch;
#line 674 "StatisticsModule.cs"
                    int csharp2cuda_temp_205 = (first)->count;
#line 674 "StatisticsModule.cs"
                    double* right_ranks = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_205);
#line 675 "StatisticsModule.cs"
#line 675 "StatisticsModule.cs"
                    double* csharp2cuda_temp_206 = &((output)->scalar_value);
#line 678 "StatisticsModule.cs"
                    int csharp2cuda_temp_207 = (first)->count;
#line 675 "StatisticsModule.cs"
                    double csharp2cuda_temp_208 = mathblocks_statistics_pearson(left_ranks, right_ranks, csharp2cuda_temp_207);
                    (*(csharp2cuda_temp_206) = csharp2cuda_temp_208);
#line 679 "StatisticsModule.cs"
                    break;
                }
#line 681 "StatisticsModule.cs"
            case 24:
#line 682 "StatisticsModule.cs"
                {
#line 683 "StatisticsModule.cs"
#line 683 "StatisticsModule.cs"
                    int csharp2cuda_temp_209 = (first)->count;
#line 683 "StatisticsModule.cs"
                    int csharp2cuda_temp_210 = (second)->count;
#line 683 "StatisticsModule.cs"
                    bool csharp2cuda_temp_211;
#line 683 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_209) != (csharp2cuda_temp_210))))
                    {
#line 683 "StatisticsModule.cs"
                        csharp2cuda_temp_211 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 683 "StatisticsModule.cs"
                        csharp2cuda_temp_211 = true;
                    }
                    if (csharp2cuda_temp_211)
#line 684 "StatisticsModule.cs"
                    {
#line 685 "StatisticsModule.cs"
#line 685 "StatisticsModule.cs"
                        int* csharp2cuda_temp_212 = &((output)->valid);
                        (*(csharp2cuda_temp_212) = 0);
#line 686 "StatisticsModule.cs"
                        break;
                    }
#line 688 "StatisticsModule.cs"
                    int csharp2cuda_temp_213 = (first)->count;
#line 688 "StatisticsModule.cs"
                    int count = mathblocks_statistics_pair_slopes(a, b, csharp2cuda_temp_213, scratch);
#line 689 "StatisticsModule.cs"
                    if (((count) <= (0)))
                    {
#line 690 "StatisticsModule.cs"
#line 690 "StatisticsModule.cs"
                        int* csharp2cuda_temp_214 = &((output)->valid);
                        (*(csharp2cuda_temp_214) = 0);
                    }
                    else
                    {
#line 692 "StatisticsModule.cs"
#line 692 "StatisticsModule.cs"
                        double* csharp2cuda_temp_215 = &((output)->scalar_value);
#line 692 "StatisticsModule.cs"
                        double csharp2cuda_temp_216 = mathblocks_statistics_median(scratch, count);
                        (*(csharp2cuda_temp_215) = csharp2cuda_temp_216);
                    }
#line 693 "StatisticsModule.cs"
                    break;
                }
#line 695 "StatisticsModule.cs"
            case 25:
            case 26:
#line 697 "StatisticsModule.cs"
#line 697 "StatisticsModule.cs"
                int csharp2cuda_temp_217 = (first)->count;
#line 697 "StatisticsModule.cs"
                int csharp2cuda_temp_218 = (second)->count;
#line 697 "StatisticsModule.cs"
                bool csharp2cuda_temp_219;
#line 697 "StatisticsModule.cs"
                if (!(((csharp2cuda_temp_217) != (csharp2cuda_temp_218))))
                {
#line 701 "StatisticsModule.cs"
                    int csharp2cuda_temp_220 = (first)->count;
#line 703 "StatisticsModule.cs"
                    double* csharp2cuda_temp_221 = &((output)->scalar_value);
#line 698 "StatisticsModule.cs"
                    bool csharp2cuda_temp_222 = mathblocks_statistics_weighted_value(a, b, csharp2cuda_temp_220, ((opcode) == (26)), csharp2cuda_temp_221);
#line 697 "StatisticsModule.cs"
                    csharp2cuda_temp_219 = (!(csharp2cuda_temp_222));
                }
                else
                {
#line 697 "StatisticsModule.cs"
                    csharp2cuda_temp_219 = true;
                }
                if (csharp2cuda_temp_219)
                {
#line 704 "StatisticsModule.cs"
#line 704 "StatisticsModule.cs"
                    int* csharp2cuda_temp_223 = &((output)->valid);
                    (*(csharp2cuda_temp_223) = 0);
                }
#line 705 "StatisticsModule.cs"
                break;
        }
#line 707 "StatisticsModule.cs"
#line 707 "StatisticsModule.cs"
        bool csharp2cuda_temp_224 = (output)->valid;
#line 707 "StatisticsModule.cs"
        bool csharp2cuda_temp_225;
#line 707 "StatisticsModule.cs"
        if (csharp2cuda_temp_224)
        {
#line 707 "StatisticsModule.cs"
            csharp2cuda_temp_225 = ((opcode) != (2));
        }
        else
        {
#line 707 "StatisticsModule.cs"
            csharp2cuda_temp_225 = false;
        }
#line 707 "StatisticsModule.cs"
        bool csharp2cuda_temp_226;
#line 707 "StatisticsModule.cs"
        if (csharp2cuda_temp_225)
        {
#line 707 "StatisticsModule.cs"
            csharp2cuda_temp_226 = ((opcode) != (4));
        }
        else
        {
#line 707 "StatisticsModule.cs"
            csharp2cuda_temp_226 = false;
        }
#line 707 "StatisticsModule.cs"
        bool csharp2cuda_temp_227;
#line 707 "StatisticsModule.cs"
        if (csharp2cuda_temp_226)
        {
#line 707 "StatisticsModule.cs"
            double csharp2cuda_temp_228 = (output)->scalar_value;
#line 707 "StatisticsModule.cs"
            csharp2cuda_temp_227 = (!(isfinite(csharp2cuda_temp_228)));
        }
        else
        {
#line 707 "StatisticsModule.cs"
            csharp2cuda_temp_227 = false;
        }
        if (csharp2cuda_temp_227)
        {
#line 708 "StatisticsModule.cs"
#line 708 "StatisticsModule.cs"
            int* csharp2cuda_temp_229 = &((output)->valid);
            (*(csharp2cuda_temp_229) = 0);
        }
    }
}

#line 106 "StatisticsModule.cs"
__device__ double mathblocks_statistics_distance_correlation_value(
    double covariance_square,
    double left_variance_square,
    double right_variance_square)
#line 111 "StatisticsModule.cs"
{
#line 112 "StatisticsModule.cs"
    double denominator = mathblocks_square_root(__dmul_rn(left_variance_square, right_variance_square));
#line 113 "StatisticsModule.cs"
#line 113 "StatisticsModule.cs"
    bool csharp2cuda_temp_0;
#line 113 "StatisticsModule.cs"
    if (!((!(isfinite(covariance_square)))))
    {
#line 113 "StatisticsModule.cs"
        csharp2cuda_temp_0 = (!(isfinite(left_variance_square)));
    }
    else
    {
#line 113 "StatisticsModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 113 "StatisticsModule.cs"
    bool csharp2cuda_temp_1;
#line 113 "StatisticsModule.cs"
    if (!(csharp2cuda_temp_0))
    {
#line 113 "StatisticsModule.cs"
        csharp2cuda_temp_1 = (!(isfinite(right_variance_square)));
    }
    else
    {
#line 113 "StatisticsModule.cs"
        csharp2cuda_temp_1 = true;
    }
#line 113 "StatisticsModule.cs"
    bool csharp2cuda_temp_2;
#line 113 "StatisticsModule.cs"
    if (!(csharp2cuda_temp_1))
    {
#line 113 "StatisticsModule.cs"
        csharp2cuda_temp_2 = (!(isfinite(denominator)));
    }
    else
    {
#line 113 "StatisticsModule.cs"
        csharp2cuda_temp_2 = true;
    }
    if (csharp2cuda_temp_2)
    {
#line 115 "StatisticsModule.cs"
        return mathblocks_quiet_nan();
    }
#line 116 "StatisticsModule.cs"
#line 116 "StatisticsModule.cs"
    double csharp2cuda_temp_3 = __ddiv_rn(covariance_square, denominator);
    return mathblocks_square_root(csharp2cuda_temp_3);
}

#line 247 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_kendall_value(
    const double* left_values,
    const double* right_values,
    int count,
    double* value)
#line 253 "StatisticsModule.cs"
{
#line 254 "StatisticsModule.cs"
    long long concordant = ((long long)(0));
#line 255 "StatisticsModule.cs"
    long long discordant = ((long long)(0));
#line 256 "StatisticsModule.cs"
    long long left_ties = ((long long)(0));
#line 257 "StatisticsModule.cs"
    long long right_ties = ((long long)(0));
#line 258 "StatisticsModule.cs"
    {
#line 258 "StatisticsModule.cs"
        int left = 0;
        while (true)
        {
            if (!(((left) < (count))))
                break;
#line 259 "StatisticsModule.cs"
            {
#line 260 "StatisticsModule.cs"
                {
#line 260 "StatisticsModule.cs"
                    int right = csharp2cuda_i32_add(left, 1);
                    while (true)
                    {
                        if (!(((right) < (count))))
                            break;
#line 261 "StatisticsModule.cs"
                        {
#line 262 "StatisticsModule.cs"
                            double csharp2cuda_temp_2 = (left_values)[left];
#line 262 "StatisticsModule.cs"
                            double csharp2cuda_temp_3 = (left_values)[right];
#line 262 "StatisticsModule.cs"
                            double left_difference = __dsub_rn(csharp2cuda_temp_2, csharp2cuda_temp_3);
#line 263 "StatisticsModule.cs"
                            double csharp2cuda_temp_4 = (right_values)[left];
#line 263 "StatisticsModule.cs"
                            double csharp2cuda_temp_5 = (right_values)[right];
#line 263 "StatisticsModule.cs"
                            double right_difference = __dsub_rn(csharp2cuda_temp_4, csharp2cuda_temp_5);
#line 264 "StatisticsModule.cs"
                            int csharp2cuda_temp_6;
#line 264 "StatisticsModule.cs"
                            if (((left_difference) > (0.0)))
                            {
#line 264 "StatisticsModule.cs"
                                csharp2cuda_temp_6 = 1;
                            }
                            else
                            {
#line 264 "StatisticsModule.cs"
                                int csharp2cuda_temp_7;
#line 264 "StatisticsModule.cs"
                                if (((left_difference) < (0.0)))
                                {
#line 264 "StatisticsModule.cs"
                                    csharp2cuda_temp_7 = csharp2cuda_i32_neg(1);
                                }
                                else
                                {
#line 264 "StatisticsModule.cs"
                                    csharp2cuda_temp_7 = 0;
                                }
#line 264 "StatisticsModule.cs"
                                csharp2cuda_temp_6 = csharp2cuda_temp_7;
                            }
#line 264 "StatisticsModule.cs"
                            int left_sign = csharp2cuda_temp_6;
#line 265 "StatisticsModule.cs"
                            int csharp2cuda_temp_8;
#line 265 "StatisticsModule.cs"
                            if (((right_difference) > (0.0)))
                            {
#line 265 "StatisticsModule.cs"
                                csharp2cuda_temp_8 = 1;
                            }
                            else
                            {
#line 265 "StatisticsModule.cs"
                                int csharp2cuda_temp_9;
#line 265 "StatisticsModule.cs"
                                if (((right_difference) < (0.0)))
                                {
#line 265 "StatisticsModule.cs"
                                    csharp2cuda_temp_9 = csharp2cuda_i32_neg(1);
                                }
                                else
                                {
#line 265 "StatisticsModule.cs"
                                    csharp2cuda_temp_9 = 0;
                                }
#line 265 "StatisticsModule.cs"
                                csharp2cuda_temp_8 = csharp2cuda_temp_9;
                            }
#line 265 "StatisticsModule.cs"
                            int right_sign = csharp2cuda_temp_8;
#line 266 "StatisticsModule.cs"
#line 266 "StatisticsModule.cs"
                            bool csharp2cuda_temp_10;
#line 266 "StatisticsModule.cs"
                            if (((left_sign) == (0)))
                            {
#line 266 "StatisticsModule.cs"
                                csharp2cuda_temp_10 = ((right_sign) == (0));
                            }
                            else
                            {
#line 266 "StatisticsModule.cs"
                                csharp2cuda_temp_10 = false;
                            }
                            if (csharp2cuda_temp_10)
                            {
#line 267 "StatisticsModule.cs"
                                goto csharp2cuda_for_continue_0;
                            }
#line 268 "StatisticsModule.cs"
                            if (((left_sign) == (0)))
                            {
#line 269 "StatisticsModule.cs"
#line 269 "StatisticsModule.cs"
                                long long* csharp2cuda_temp_11 = &(left_ties);
                                csharp2cuda_i64_post_increment(*(csharp2cuda_temp_11));
                            }
                            else
                            {
#line 270 "StatisticsModule.cs"
                                if (((right_sign) == (0)))
                                {
#line 271 "StatisticsModule.cs"
#line 271 "StatisticsModule.cs"
                                    long long* csharp2cuda_temp_12 = &(right_ties);
                                    csharp2cuda_i64_post_increment(*(csharp2cuda_temp_12));
                                }
                                else
                                {
#line 272 "StatisticsModule.cs"
                                    if (((left_sign) == (right_sign)))
                                    {
#line 273 "StatisticsModule.cs"
#line 273 "StatisticsModule.cs"
                                        long long* csharp2cuda_temp_13 = &(concordant);
                                        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_13));
                                    }
                                    else
                                    {
#line 275 "StatisticsModule.cs"
#line 275 "StatisticsModule.cs"
                                        long long* csharp2cuda_temp_14 = &(discordant);
                                        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_14));
                                    }
                                }
                            }
                        }
                        csharp2cuda_for_continue_0:
#line 260 "StatisticsModule.cs"
                        int* csharp2cuda_temp_1 = &(right);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
            }
#line 258 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(left);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 278 "StatisticsModule.cs"
#line 278 "StatisticsModule.cs"
    double* csharp2cuda_temp_15 = value;
#line 278 "StatisticsModule.cs"
    double csharp2cuda_temp_16 = __ddiv_rn(((double)(csharp2cuda_i64_sub(concordant, discordant))), mathblocks_square_root(__dmul_rn(((double)(csharp2cuda_i64_add(csharp2cuda_i64_add(concordant, discordant), left_ties))), ((double)(csharp2cuda_i64_add(csharp2cuda_i64_add(concordant, discordant), right_ties))))));
    (*(csharp2cuda_temp_15) = csharp2cuda_temp_16);
#line 282 "StatisticsModule.cs"
#line 282 "StatisticsModule.cs"
    double csharp2cuda_temp_17 = *(value);
    return isfinite(csharp2cuda_temp_17);
}

#line 49 "StatisticsModule.cs"
__device__ double mathblocks_statistics_mean(const double* values, int count)
#line 51 "StatisticsModule.cs"
{
#line 52 "StatisticsModule.cs"
    return __ddiv_rn(mathblocks_compensated_sum(values, count), ((double)(count)));
}

#line 163 "StatisticsModule.cs"
__device__ double mathblocks_statistics_median(double* values, int count)
#line 165 "StatisticsModule.cs"
{
#line 166 "StatisticsModule.cs"
    double* sorted = mathblocks_stable_merge_sort(values, csharp2cuda_pointer_add(values, count), count, false);
#line 167 "StatisticsModule.cs"
    return mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
}

#line 227 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_moment_value(
    const double* values,
    int count,
    double order_value,
    bool central,
    double* value)
#line 234 "StatisticsModule.cs"
{
#line 235 "StatisticsModule.cs"
    int order = 0;
#line 236 "StatisticsModule.cs"
#line 236 "StatisticsModule.cs"
    bool csharp2cuda_temp_0;
#line 236 "StatisticsModule.cs"
    if (!(((count) <= (0))))
    {
#line 237 "StatisticsModule.cs"
        int* csharp2cuda_temp_1 = &(order);
#line 237 "StatisticsModule.cs"
        bool csharp2cuda_temp_2 = mathblocks_nonnegative_integer(order_value, csharp2cuda_temp_1);
#line 236 "StatisticsModule.cs"
        csharp2cuda_temp_0 = (!(csharp2cuda_temp_2));
    }
    else
    {
#line 236 "StatisticsModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 238 "StatisticsModule.cs"
        return false;
    }
#line 239 "StatisticsModule.cs"
    double csharp2cuda_temp_3;
#line 239 "StatisticsModule.cs"
    if (central)
    {
#line 239 "StatisticsModule.cs"
        csharp2cuda_temp_3 = mathblocks_statistics_mean(values, count);
    }
    else
    {
#line 239 "StatisticsModule.cs"
        csharp2cuda_temp_3 = 0.0;
    }
#line 239 "StatisticsModule.cs"
    double mean = csharp2cuda_temp_3;
#line 240 "StatisticsModule.cs"
    double sum = 0.0;
#line 241 "StatisticsModule.cs"
    {
#line 241 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 242 "StatisticsModule.cs"
#line 242 "StatisticsModule.cs"
            double* csharp2cuda_temp_5 = &(sum);
#line 242 "StatisticsModule.cs"
            double csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
#line 242 "StatisticsModule.cs"
            double csharp2cuda_temp_7 = (values)[index];
            (*(csharp2cuda_temp_5) = __dadd_rn(csharp2cuda_temp_6, mathblocks_power(__dsub_rn(csharp2cuda_temp_7, mean), ((double)(order)))));
#line 241 "StatisticsModule.cs"
            int* csharp2cuda_temp_4 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
        }
    }
#line 243 "StatisticsModule.cs"
#line 243 "StatisticsModule.cs"
    double* csharp2cuda_temp_8 = value;
#line 243 "StatisticsModule.cs"
    double csharp2cuda_temp_9 = __ddiv_rn(sum, ((double)(count)));
    (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
#line 244 "StatisticsModule.cs"
#line 244 "StatisticsModule.cs"
    double csharp2cuda_temp_10 = *(value);
    return isfinite(csharp2cuda_temp_10);
}

#line 343 "StatisticsModule.cs"
__device__ int mathblocks_statistics_pair_averages(
    const double* values,
    int count,
    double* averages)
#line 348 "StatisticsModule.cs"
{
#line 349 "StatisticsModule.cs"
    int average_count = 0;
#line 350 "StatisticsModule.cs"
    {
#line 350 "StatisticsModule.cs"
        int left = 0;
        while (true)
        {
            if (!(((left) < (count))))
                break;
#line 351 "StatisticsModule.cs"
            {
#line 351 "StatisticsModule.cs"
                int right = left;
                while (true)
                {
                    if (!(((right) < (count))))
                        break;
#line 352 "StatisticsModule.cs"
#line 352 "StatisticsModule.cs"
                    int* csharp2cuda_temp_2 = &(average_count);
#line 352 "StatisticsModule.cs"
                    int csharp2cuda_temp_3 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
#line 352 "StatisticsModule.cs"
                    double* csharp2cuda_temp_4 = &((averages)[csharp2cuda_temp_3]);
#line 352 "StatisticsModule.cs"
                    double csharp2cuda_temp_5 = (values)[left];
#line 352 "StatisticsModule.cs"
                    double csharp2cuda_temp_6 = (values)[right];
#line 352 "StatisticsModule.cs"
                    double csharp2cuda_temp_7 = __ddiv_rn(__dadd_rn(csharp2cuda_temp_5, csharp2cuda_temp_6), 2.0);
                    (*(csharp2cuda_temp_4) = csharp2cuda_temp_7);
#line 351 "StatisticsModule.cs"
                    int* csharp2cuda_temp_1 = &(right);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                }
            }
#line 350 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(left);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 353 "StatisticsModule.cs"
    return average_count;
}

#line 358 "StatisticsModule.cs"
__device__ int mathblocks_statistics_pair_slopes(
    const double* x,
    const double* y,
    int count,
    double* slopes)
#line 364 "StatisticsModule.cs"
{
#line 365 "StatisticsModule.cs"
    int slope_count = 0;
#line 366 "StatisticsModule.cs"
    {
#line 366 "StatisticsModule.cs"
        int left = 0;
        while (true)
        {
            if (!(((left) < (count))))
                break;
#line 367 "StatisticsModule.cs"
            {
#line 368 "StatisticsModule.cs"
                {
#line 368 "StatisticsModule.cs"
                    int right = csharp2cuda_i32_add(left, 1);
                    while (true)
                    {
                        if (!(((right) < (count))))
                            break;
#line 369 "StatisticsModule.cs"
                        {
#line 370 "StatisticsModule.cs"
                            double csharp2cuda_temp_2 = (x)[right];
#line 370 "StatisticsModule.cs"
                            double csharp2cuda_temp_3 = (x)[left];
#line 370 "StatisticsModule.cs"
                            double difference = __dsub_rn(csharp2cuda_temp_2, csharp2cuda_temp_3);
#line 372 "StatisticsModule.cs"
                            if ((!(isfinite(difference))))
                            {
#line 373 "StatisticsModule.cs"
                                return csharp2cuda_i32_neg(1);
                            }
#line 374 "StatisticsModule.cs"
                            if (((difference) != (0.0)))
#line 375 "StatisticsModule.cs"
                            {
#line 376 "StatisticsModule.cs"
                                double csharp2cuda_temp_4 = (y)[right];
#line 376 "StatisticsModule.cs"
                                double csharp2cuda_temp_5 = (y)[left];
#line 376 "StatisticsModule.cs"
                                double rise = __dsub_rn(csharp2cuda_temp_4, csharp2cuda_temp_5);
#line 377 "StatisticsModule.cs"
                                double slope = __ddiv_rn(rise, difference);
#line 378 "StatisticsModule.cs"
#line 378 "StatisticsModule.cs"
                                bool csharp2cuda_temp_6;
#line 378 "StatisticsModule.cs"
                                if (!((!(isfinite(rise)))))
                                {
#line 378 "StatisticsModule.cs"
                                    csharp2cuda_temp_6 = (!(isfinite(slope)));
                                }
                                else
                                {
#line 378 "StatisticsModule.cs"
                                    csharp2cuda_temp_6 = true;
                                }
                                if (csharp2cuda_temp_6)
                                {
#line 379 "StatisticsModule.cs"
                                    return csharp2cuda_i32_neg(1);
                                }
#line 380 "StatisticsModule.cs"
#line 380 "StatisticsModule.cs"
                                int* csharp2cuda_temp_7 = &(slope_count);
#line 380 "StatisticsModule.cs"
                                int csharp2cuda_temp_8 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_7));
#line 380 "StatisticsModule.cs"
                                double* csharp2cuda_temp_9 = &((slopes)[csharp2cuda_temp_8]);
                                (*(csharp2cuda_temp_9) = slope);
                            }
                        }
#line 368 "StatisticsModule.cs"
                        int* csharp2cuda_temp_1 = &(right);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
            }
#line 366 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(left);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 384 "StatisticsModule.cs"
    return slope_count;
}

#line 119 "StatisticsModule.cs"
__device__ double mathblocks_statistics_pearson(
    const double* left,
    const double* right,
    int count)
#line 124 "StatisticsModule.cs"
{
#line 125 "StatisticsModule.cs"
#line 126 "StatisticsModule.cs"
    double csharp2cuda_temp_0 = mathblocks_statistics_population_covariance(left, right, count);
#line 127 "StatisticsModule.cs"
    double csharp2cuda_temp_1 = mathblocks_statistics_population_variance(left, count);
#line 128 "StatisticsModule.cs"
    double csharp2cuda_temp_2 = mathblocks_statistics_population_variance(right, count);
    return mathblocks_statistics_correlation_value(csharp2cuda_temp_0, csharp2cuda_temp_1, csharp2cuda_temp_2);
}

#line 70 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_covariance(
    const double* left,
    const double* right,
    int count)
#line 75 "StatisticsModule.cs"
{
#line 76 "StatisticsModule.cs"
    double left_mean = mathblocks_statistics_mean(left, count);
#line 77 "StatisticsModule.cs"
    double right_mean = mathblocks_statistics_mean(right, count);
#line 78 "StatisticsModule.cs"
    double sum = 0.0;
#line 79 "StatisticsModule.cs"
    {
#line 79 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 80 "StatisticsModule.cs"
#line 80 "StatisticsModule.cs"
            double* csharp2cuda_temp_1 = &(sum);
#line 80 "StatisticsModule.cs"
            double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
#line 80 "StatisticsModule.cs"
            double csharp2cuda_temp_3 = (left)[index];
#line 80 "StatisticsModule.cs"
            double csharp2cuda_temp_4 = (right)[index];
            (*(csharp2cuda_temp_1) = __dadd_rn(csharp2cuda_temp_2, __dmul_rn(__dsub_rn(csharp2cuda_temp_3, left_mean), __dsub_rn(csharp2cuda_temp_4, right_mean))));
#line 79 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 81 "StatisticsModule.cs"
    return __ddiv_rn(sum, ((double)(count)));
}

#line 55 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_variance(
    const double* values,
    int count)
#line 59 "StatisticsModule.cs"
{
#line 60 "StatisticsModule.cs"
    double mean = mathblocks_statistics_mean(values, count);
#line 61 "StatisticsModule.cs"
    double sum = 0.0;
#line 62 "StatisticsModule.cs"
    {
#line 62 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 63 "StatisticsModule.cs"
            {
#line 64 "StatisticsModule.cs"
                double csharp2cuda_temp_1 = (values)[index];
#line 64 "StatisticsModule.cs"
                double difference = __dsub_rn(csharp2cuda_temp_1, mean);
#line 65 "StatisticsModule.cs"
#line 65 "StatisticsModule.cs"
                double* csharp2cuda_temp_2 = &(sum);
#line 65 "StatisticsModule.cs"
                double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, __dmul_rn(difference, difference)));
            }
#line 62 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 67 "StatisticsModule.cs"
    return __ddiv_rn(sum, ((double)(count)));
}

#line 85 "StatisticsModule.cs"
__device__ double mathblocks_statistics_quotient_by_variance(double covariance, double variance)
#line 87 "StatisticsModule.cs"
{
#line 88 "StatisticsModule.cs"
    if ((!(isfinite(variance))))
    {
#line 89 "StatisticsModule.cs"
        return mathblocks_quiet_nan();
    }
#line 90 "StatisticsModule.cs"
    return __ddiv_rn(covariance, variance);
}

#line 190 "StatisticsModule.cs"
__device__ void mathblocks_statistics_rank(
    const double* values,
    int count,
    double* result)
#line 195 "StatisticsModule.cs"
{
#line 196 "StatisticsModule.cs"
    {
#line 196 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 197 "StatisticsModule.cs"
#line 197 "StatisticsModule.cs"
            double* csharp2cuda_temp_1 = &((result)[index]);
#line 197 "StatisticsModule.cs"
            double csharp2cuda_temp_2 = mathblocks_statistics_rank_at(values, count, index);
            (*(csharp2cuda_temp_1) = csharp2cuda_temp_2);
#line 196 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 172 "StatisticsModule.cs"
__device__ double mathblocks_statistics_rank_at(
    const double* values,
    int count,
    int index)
#line 177 "StatisticsModule.cs"
{
#line 178 "StatisticsModule.cs"
    int lower = 0;
#line 179 "StatisticsModule.cs"
    int equal = 0;
#line 180 "StatisticsModule.cs"
    {
#line 180 "StatisticsModule.cs"
        int candidate = 0;
        while (true)
        {
            if (!(((candidate) < (count))))
                break;
#line 181 "StatisticsModule.cs"
            {
#line 182 "StatisticsModule.cs"
#line 182 "StatisticsModule.cs"
                double csharp2cuda_temp_1 = (values)[candidate];
#line 182 "StatisticsModule.cs"
                double csharp2cuda_temp_2 = (values)[index];
                if (((csharp2cuda_temp_1) < (csharp2cuda_temp_2)))
                {
#line 183 "StatisticsModule.cs"
#line 183 "StatisticsModule.cs"
                    int* csharp2cuda_temp_3 = &(lower);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
                }
                else
                {
#line 184 "StatisticsModule.cs"
#line 184 "StatisticsModule.cs"
                    double csharp2cuda_temp_4 = (values)[candidate];
#line 184 "StatisticsModule.cs"
                    double csharp2cuda_temp_5 = (values)[index];
                    if (((csharp2cuda_temp_4) == (csharp2cuda_temp_5)))
                    {
#line 185 "StatisticsModule.cs"
#line 185 "StatisticsModule.cs"
                        int* csharp2cuda_temp_6 = &(equal);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
                    }
                }
            }
#line 180 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(candidate);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 187 "StatisticsModule.cs"
#line 187 "StatisticsModule.cs"
    double csharp2cuda_temp_7 = __ddiv_rn(__dadd_rn(((double)(equal)), 1.0), 2.0);
    return __dadd_rn(((double)(lower)), csharp2cuda_temp_7);
}

#line 285 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_shape_moment_value(
    const double* values,
    int count,
    bool kurtosis,
    double* value)
#line 291 "StatisticsModule.cs"
{
#line 292 "StatisticsModule.cs"
    if (((count) <= (0)))
    {
#line 293 "StatisticsModule.cs"
        return false;
    }
#line 294 "StatisticsModule.cs"
    double mean = mathblocks_statistics_mean(values, count);
#line 295 "StatisticsModule.cs"
    double second_moment = 0.0;
#line 296 "StatisticsModule.cs"
    double higher_moment = 0.0;
#line 297 "StatisticsModule.cs"
    {
#line 297 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 298 "StatisticsModule.cs"
            {
#line 299 "StatisticsModule.cs"
                double csharp2cuda_temp_1 = (values)[index];
#line 299 "StatisticsModule.cs"
                double difference = __dsub_rn(csharp2cuda_temp_1, mean);
#line 300 "StatisticsModule.cs"
                double square = __dmul_rn(difference, difference);
#line 301 "StatisticsModule.cs"
#line 301 "StatisticsModule.cs"
                double* csharp2cuda_temp_2 = &(second_moment);
#line 301 "StatisticsModule.cs"
                double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, square));
#line 302 "StatisticsModule.cs"
#line 302 "StatisticsModule.cs"
                double* csharp2cuda_temp_4 = &(higher_moment);
#line 302 "StatisticsModule.cs"
                double csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
#line 302 "StatisticsModule.cs"
                double csharp2cuda_temp_6;
#line 302 "StatisticsModule.cs"
                if (kurtosis)
                {
#line 302 "StatisticsModule.cs"
                    csharp2cuda_temp_6 = __dmul_rn(square, square);
                }
                else
                {
#line 302 "StatisticsModule.cs"
                    csharp2cuda_temp_6 = __dmul_rn(square, difference);
                }
                (*(csharp2cuda_temp_4) = __dadd_rn(csharp2cuda_temp_5, csharp2cuda_temp_6));
            }
#line 297 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 304 "StatisticsModule.cs"
#line 304 "StatisticsModule.cs"
    double* csharp2cuda_temp_7 = &(second_moment);
#line 304 "StatisticsModule.cs"
    double csharp2cuda_temp_8 = *(csharp2cuda_temp_7);
    (*(csharp2cuda_temp_7) = __ddiv_rn(csharp2cuda_temp_8, ((double)(count))));
#line 305 "StatisticsModule.cs"
#line 305 "StatisticsModule.cs"
    double* csharp2cuda_temp_9 = &(higher_moment);
#line 305 "StatisticsModule.cs"
    double csharp2cuda_temp_10 = *(csharp2cuda_temp_9);
    (*(csharp2cuda_temp_9) = __ddiv_rn(csharp2cuda_temp_10, ((double)(count))));
#line 306 "StatisticsModule.cs"
#line 306 "StatisticsModule.cs"
    double* csharp2cuda_temp_11 = value;
#line 306 "StatisticsModule.cs"
    double csharp2cuda_temp_12;
#line 306 "StatisticsModule.cs"
    if (kurtosis)
    {
#line 307 "StatisticsModule.cs"
        double csharp2cuda_temp_13 = __ddiv_rn(higher_moment, __dmul_rn(second_moment, second_moment));
#line 306 "StatisticsModule.cs"
        csharp2cuda_temp_12 = __dsub_rn(csharp2cuda_temp_13, 3.0);
    }
    else
    {
#line 306 "StatisticsModule.cs"
        csharp2cuda_temp_12 = __ddiv_rn(higher_moment, mathblocks_power(second_moment, 1.5));
    }
    (*(csharp2cuda_temp_11) = csharp2cuda_temp_12);
#line 309 "StatisticsModule.cs"
#line 309 "StatisticsModule.cs"
    double csharp2cuda_temp_14 = *(value);
    return isfinite(csharp2cuda_temp_14);
}

#line 138 "StatisticsModule.cs"
__device__ void mathblocks_statistics_sort_copy(
    const double* values,
    int count,
    double* result,
    bool descending)
#line 144 "StatisticsModule.cs"
{
#line 145 "StatisticsModule.cs"
    mathblocks_stable_sort_into(values, count, result, csharp2cuda_pointer_add(result, count), descending);
}

#line 148 "StatisticsModule.cs"
__device__ double mathblocks_statistics_sorted_quantile(
    const double* sorted,
    int count,
    double probability)
#line 153 "StatisticsModule.cs"
{
#line 154 "StatisticsModule.cs"
    if (((count) == (1)))
    {
#line 155 "StatisticsModule.cs"
        return (sorted)[0];
    }
#line 156 "StatisticsModule.cs"
    double position = __dmul_rn(probability, ((double)(csharp2cuda_i32_sub(count, 1))));
#line 157 "StatisticsModule.cs"
    int lower = csharp2cuda_f64_to_i32(floor(position));
#line 158 "StatisticsModule.cs"
    int upper = csharp2cuda_f64_to_i32(ceil(position));
#line 159 "StatisticsModule.cs"
    double weight = __dsub_rn(position, ((double)(lower)));
#line 160 "StatisticsModule.cs"
#line 160 "StatisticsModule.cs"
    double csharp2cuda_temp_0 = (sorted)[lower];
#line 160 "StatisticsModule.cs"
    double csharp2cuda_temp_1 = (sorted)[upper];
    return __dadd_rn(__dmul_rn(csharp2cuda_temp_0, __dsub_rn(1.0, weight)), __dmul_rn(csharp2cuda_temp_1, weight));
}

#line 312 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_weighted_value(
    const double* values,
    const double* weights,
    int count,
    bool variance,
    double* value)
#line 319 "StatisticsModule.cs"
{
#line 320 "StatisticsModule.cs"
    if (((count) <= (0)))
    {
#line 321 "StatisticsModule.cs"
        return false;
    }
#line 322 "StatisticsModule.cs"
    double weight_sum = mathblocks_compensated_sum(weights, count);
#line 323 "StatisticsModule.cs"
    double mean = __ddiv_rn(mathblocks_compensated_product_sum(values, weights, count), weight_sum);
#line 324 "StatisticsModule.cs"
    if ((!(variance)))
#line 325 "StatisticsModule.cs"
    {
#line 326 "StatisticsModule.cs"
#line 326 "StatisticsModule.cs"
        double* csharp2cuda_temp_0 = value;
        (*(csharp2cuda_temp_0) = mean);
    }
    else
#line 329 "StatisticsModule.cs"
    {
#line 330 "StatisticsModule.cs"
        double numerator = 0.0;
#line 331 "StatisticsModule.cs"
        {
#line 331 "StatisticsModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 332 "StatisticsModule.cs"
                {
#line 333 "StatisticsModule.cs"
                    double csharp2cuda_temp_2 = (values)[index];
#line 333 "StatisticsModule.cs"
                    double difference = __dsub_rn(csharp2cuda_temp_2, mean);
#line 334 "StatisticsModule.cs"
#line 334 "StatisticsModule.cs"
                    double* csharp2cuda_temp_3 = &(numerator);
#line 334 "StatisticsModule.cs"
                    double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 334 "StatisticsModule.cs"
                    double csharp2cuda_temp_5 = (weights)[index];
                    (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, __dmul_rn(__dmul_rn(csharp2cuda_temp_5, difference), difference)));
                }
#line 331 "StatisticsModule.cs"
                int* csharp2cuda_temp_1 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
            }
        }
#line 336 "StatisticsModule.cs"
#line 336 "StatisticsModule.cs"
        double* csharp2cuda_temp_6 = value;
#line 336 "StatisticsModule.cs"
        double csharp2cuda_temp_7 = __ddiv_rn(numerator, weight_sum);
        (*(csharp2cuda_temp_6) = csharp2cuda_temp_7);
    }
#line 338 "StatisticsModule.cs"
#line 338 "StatisticsModule.cs"
    double csharp2cuda_temp_8 = *(value);
    return isfinite(csharp2cuda_temp_8);
}