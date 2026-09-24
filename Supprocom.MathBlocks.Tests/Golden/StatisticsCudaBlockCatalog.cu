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

#line 170 "StatisticsModule.cs"
__device__ void mathblocks_statistics_center_distance(
    const double* values,
    int count,
    double* result,
    double* row_means);

#line 197 "StatisticsModule.cs"
__device__ void mathblocks_statistics_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 46 "StatisticsModule.cs"
__device__ double mathblocks_statistics_mean(const double* values, int count);

#line 142 "StatisticsModule.cs"
__device__ double mathblocks_statistics_median(double* values, int count);

#line 81 "StatisticsModule.cs"
__device__ double mathblocks_statistics_pearson(
    const double* left,
    const double* right,
    int count);

#line 67 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_covariance(
    const double* left,
    const double* right,
    int count);

#line 52 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_variance(
    const double* values,
    int count);

#line 149 "StatisticsModule.cs"
__device__ void mathblocks_statistics_rank(
    const double* values,
    int count,
    double* result);

#line 92 "StatisticsModule.cs"
__device__ void mathblocks_statistics_sort_copy(
    const double* values,
    int count,
    double* result);

#line 111 "StatisticsModule.cs"
__device__ void mathblocks_statistics_sort_in_place(double* values, int count);

#line 127 "StatisticsModule.cs"
__device__ double mathblocks_statistics_sorted_quantile(
    const double* sorted,
    int count,
    double probability);

#line 170 "StatisticsModule.cs"
__device__ void mathblocks_statistics_center_distance(
    const double* values,
    int count,
    double* result,
    double* row_means)
#line 176 "StatisticsModule.cs"
{
#line 177 "StatisticsModule.cs"
    double total_mean = 0.0;
#line 178 "StatisticsModule.cs"
    {
#line 178 "StatisticsModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 179 "StatisticsModule.cs"
            {
#line 180 "StatisticsModule.cs"
#line 180 "StatisticsModule.cs"
                double* csharp2cuda_temp_1 = &((row_means)[row]);
                (*(csharp2cuda_temp_1) = 0.0);
#line 181 "StatisticsModule.cs"
                {
#line 181 "StatisticsModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (count))))
                            break;
#line 182 "StatisticsModule.cs"
                        {
#line 183 "StatisticsModule.cs"
                            double csharp2cuda_temp_3 = (values)[row];
#line 183 "StatisticsModule.cs"
                            double csharp2cuda_temp_4 = (values)[column];
#line 183 "StatisticsModule.cs"
                            double distance = fabs(__dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4));
#line 184 "StatisticsModule.cs"
#line 184 "StatisticsModule.cs"
                            double* csharp2cuda_temp_5 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, count), column)]);
                            (*(csharp2cuda_temp_5) = distance);
#line 185 "StatisticsModule.cs"
#line 185 "StatisticsModule.cs"
                            double* csharp2cuda_temp_6 = &((row_means)[row]);
#line 185 "StatisticsModule.cs"
                            double csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
                            (*(csharp2cuda_temp_6) = __dadd_rn(csharp2cuda_temp_7, distance));
#line 186 "StatisticsModule.cs"
#line 186 "StatisticsModule.cs"
                            double* csharp2cuda_temp_8 = &(total_mean);
#line 186 "StatisticsModule.cs"
                            double csharp2cuda_temp_9 = *(csharp2cuda_temp_8);
                            (*(csharp2cuda_temp_8) = __dadd_rn(csharp2cuda_temp_9, distance));
                        }
#line 181 "StatisticsModule.cs"
                        int* csharp2cuda_temp_2 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                    }
                }
#line 188 "StatisticsModule.cs"
#line 188 "StatisticsModule.cs"
                double* csharp2cuda_temp_10 = &((row_means)[row]);
#line 188 "StatisticsModule.cs"
                double csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
                (*(csharp2cuda_temp_10) = __ddiv_rn(csharp2cuda_temp_11, ((double)(count))));
            }
#line 178 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 190 "StatisticsModule.cs"
#line 190 "StatisticsModule.cs"
    double* csharp2cuda_temp_12 = &(total_mean);
#line 190 "StatisticsModule.cs"
    double csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
    (*(csharp2cuda_temp_12) = __ddiv_rn(csharp2cuda_temp_13, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 191 "StatisticsModule.cs"
    {
#line 191 "StatisticsModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 192 "StatisticsModule.cs"
            {
#line 192 "StatisticsModule.cs"
                int column = 0;
                while (true)
                {
                    if (!(((column) < (count))))
                        break;
#line 193 "StatisticsModule.cs"
#line 193 "StatisticsModule.cs"
                    double* csharp2cuda_temp_16 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, count), column)]);
#line 193 "StatisticsModule.cs"
                    double csharp2cuda_temp_17 = *(csharp2cuda_temp_16);
#line 194 "StatisticsModule.cs"
                    double csharp2cuda_temp_18 = (row_means)[row];
#line 194 "StatisticsModule.cs"
                    double csharp2cuda_temp_19 = (row_means)[column];
                    (*(csharp2cuda_temp_16) = __dsub_rn(csharp2cuda_temp_17, __dsub_rn(__dadd_rn(csharp2cuda_temp_18, csharp2cuda_temp_19), total_mean)));
#line 192 "StatisticsModule.cs"
                    int* csharp2cuda_temp_15 = &(column);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
                }
            }
#line 191 "StatisticsModule.cs"
            int* csharp2cuda_temp_14 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_14));
        }
    }
}

#line 197 "StatisticsModule.cs"
__device__ void mathblocks_statistics_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 203 "StatisticsModule.cs"
{
#line 204 "StatisticsModule.cs"
    int thread = threadIdx.x;
#line 205 "StatisticsModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 205 "StatisticsModule.cs"
    if (((input_count) > (0)))
    {
#line 205 "StatisticsModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 205 "StatisticsModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 205 "StatisticsModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 206 "StatisticsModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 206 "StatisticsModule.cs"
    if (((input_count) > (1)))
    {
#line 206 "StatisticsModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 206 "StatisticsModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 206 "StatisticsModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 207 "StatisticsModule.cs"
    if (((thread) == (0)))
#line 208 "StatisticsModule.cs"
    {
#line 209 "StatisticsModule.cs"
#line 209 "StatisticsModule.cs"
        double* csharp2cuda_temp_2 = &((output)->scalar_value);
        (*(csharp2cuda_temp_2) = 0.0);
#line 210 "StatisticsModule.cs"
#line 210 "StatisticsModule.cs"
        int* csharp2cuda_temp_3 = &((output)->boolean_value);
        (*(csharp2cuda_temp_3) = 0);
#line 211 "StatisticsModule.cs"
#line 211 "StatisticsModule.cs"
        int* csharp2cuda_temp_4 = &((output)->rows);
        (*(csharp2cuda_temp_4) = 0);
#line 212 "StatisticsModule.cs"
#line 212 "StatisticsModule.cs"
        int* csharp2cuda_temp_5 = &((output)->columns);
        (*(csharp2cuda_temp_5) = 0);
#line 213 "StatisticsModule.cs"
#line 213 "StatisticsModule.cs"
        int* csharp2cuda_temp_6 = &((output)->count);
        (*(csharp2cuda_temp_6) = 0);
#line 214 "StatisticsModule.cs"
#line 214 "StatisticsModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
#line 214 "StatisticsModule.cs"
        bool csharp2cuda_temp_8;
#line 214 "StatisticsModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 214 "StatisticsModule.cs"
            csharp2cuda_temp_8 = (first)->valid;
        }
        else
        {
#line 214 "StatisticsModule.cs"
            csharp2cuda_temp_8 = true;
        }
        (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 215 "StatisticsModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 216 "StatisticsModule.cs"
#line 216 "StatisticsModule.cs"
            int* csharp2cuda_temp_9 = &((output)->valid);
#line 216 "StatisticsModule.cs"
            bool csharp2cuda_temp_10 = (output)->valid;
#line 216 "StatisticsModule.cs"
            bool csharp2cuda_temp_11;
#line 216 "StatisticsModule.cs"
            if (csharp2cuda_temp_10)
            {
#line 216 "StatisticsModule.cs"
                csharp2cuda_temp_11 = (second)->valid;
            }
            else
            {
#line 216 "StatisticsModule.cs"
                csharp2cuda_temp_11 = false;
            }
            (*(csharp2cuda_temp_9) = csharp2cuda_temp_11);
        }
    }
#line 218 "StatisticsModule.cs"
    __syncthreads();
#line 219 "StatisticsModule.cs"
#line 219 "StatisticsModule.cs"
    bool csharp2cuda_temp_12 = (output)->valid;
    if ((!(csharp2cuda_temp_12)))
    {
#line 220 "StatisticsModule.cs"
        return;
    }
#line 222 "StatisticsModule.cs"
    double* csharp2cuda_temp_13;
#line 222 "StatisticsModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 222 "StatisticsModule.cs"
        csharp2cuda_temp_13 = ((double*)(nullptr));
    }
    else
    {
#line 222 "StatisticsModule.cs"
        unsigned long long csharp2cuda_temp_14 = (first)->data_pointer;
#line 222 "StatisticsModule.cs"
        csharp2cuda_temp_13 = ((double*)(csharp2cuda_temp_14));
    }
#line 222 "StatisticsModule.cs"
    const double* a = csharp2cuda_temp_13;
#line 223 "StatisticsModule.cs"
    double* csharp2cuda_temp_15;
#line 223 "StatisticsModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 223 "StatisticsModule.cs"
        csharp2cuda_temp_15 = ((double*)(nullptr));
    }
    else
    {
#line 223 "StatisticsModule.cs"
        unsigned long long csharp2cuda_temp_16 = (second)->data_pointer;
#line 223 "StatisticsModule.cs"
        csharp2cuda_temp_15 = ((double*)(csharp2cuda_temp_16));
    }
#line 223 "StatisticsModule.cs"
    const double* b = csharp2cuda_temp_15;
#line 224 "StatisticsModule.cs"
    unsigned long long csharp2cuda_temp_17 = (output)->data_pointer;
#line 224 "StatisticsModule.cs"
    double* result = ((double*)(csharp2cuda_temp_17));
#line 225 "StatisticsModule.cs"
    unsigned long long csharp2cuda_temp_18 = (output)->scratch_pointer;
#line 225 "StatisticsModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_18));
#line 227 "StatisticsModule.cs"
    if (((thread) == (0)))
#line 228 "StatisticsModule.cs"
    {
#line 229 "StatisticsModule.cs"
        switch (opcode)
        {
#line 231 "StatisticsModule.cs"
            case 0:
#line 232 "StatisticsModule.cs"
                {
#line 233 "StatisticsModule.cs"
                    int lag = 0;
#line 234 "StatisticsModule.cs"
#line 234 "StatisticsModule.cs"
                    double csharp2cuda_temp_19 = (second)->scalar_value;
#line 234 "StatisticsModule.cs"
                    int* csharp2cuda_temp_20 = &(lag);
#line 234 "StatisticsModule.cs"
                    bool csharp2cuda_temp_21 = mathblocks_sequence_positive_integer(csharp2cuda_temp_19, csharp2cuda_temp_20);
#line 234 "StatisticsModule.cs"
                    bool csharp2cuda_temp_22;
#line 234 "StatisticsModule.cs"
                    if (!((!(csharp2cuda_temp_21))))
                    {
#line 234 "StatisticsModule.cs"
                        int csharp2cuda_temp_23 = (first)->count;
#line 234 "StatisticsModule.cs"
                        csharp2cuda_temp_22 = ((lag) >= (csharp2cuda_temp_23));
                    }
                    else
                    {
#line 234 "StatisticsModule.cs"
                        csharp2cuda_temp_22 = true;
                    }
                    if (csharp2cuda_temp_22)
#line 235 "StatisticsModule.cs"
                    {
#line 236 "StatisticsModule.cs"
#line 236 "StatisticsModule.cs"
                        int* csharp2cuda_temp_24 = &((output)->valid);
                        (*(csharp2cuda_temp_24) = 0);
#line 237 "StatisticsModule.cs"
                        break;
                    }
#line 239 "StatisticsModule.cs"
                    int csharp2cuda_temp_25 = (first)->count;
#line 239 "StatisticsModule.cs"
                    int count = csharp2cuda_i32_sub(csharp2cuda_temp_25, lag);
#line 240 "StatisticsModule.cs"
#line 240 "StatisticsModule.cs"
                    double* csharp2cuda_temp_26 = &((output)->scalar_value);
#line 240 "StatisticsModule.cs"
                    double csharp2cuda_temp_27 = mathblocks_statistics_pearson(a, csharp2cuda_pointer_add(a, lag), count);
                    (*(csharp2cuda_temp_26) = csharp2cuda_temp_27);
#line 241 "StatisticsModule.cs"
                    break;
                }
#line 243 "StatisticsModule.cs"
            case 1:
            case 18:
#line 245 "StatisticsModule.cs"
                {
#line 246 "StatisticsModule.cs"
                    int order = 0;
#line 247 "StatisticsModule.cs"
#line 247 "StatisticsModule.cs"
                    int csharp2cuda_temp_28 = (first)->count;
#line 247 "StatisticsModule.cs"
                    bool csharp2cuda_temp_29;
#line 247 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_28) <= (0))))
                    {
#line 248 "StatisticsModule.cs"
                        double csharp2cuda_temp_30 = (second)->scalar_value;
#line 248 "StatisticsModule.cs"
                        int* csharp2cuda_temp_31 = &(order);
#line 248 "StatisticsModule.cs"
                        bool csharp2cuda_temp_32 = mathblocks_nonnegative_integer(csharp2cuda_temp_30, csharp2cuda_temp_31);
#line 247 "StatisticsModule.cs"
                        csharp2cuda_temp_29 = (!(csharp2cuda_temp_32));
                    }
                    else
                    {
#line 247 "StatisticsModule.cs"
                        csharp2cuda_temp_29 = true;
                    }
                    if (csharp2cuda_temp_29)
#line 249 "StatisticsModule.cs"
                    {
#line 250 "StatisticsModule.cs"
#line 250 "StatisticsModule.cs"
                        int* csharp2cuda_temp_33 = &((output)->valid);
                        (*(csharp2cuda_temp_33) = 0);
#line 251 "StatisticsModule.cs"
                        break;
                    }
#line 253 "StatisticsModule.cs"
                    double csharp2cuda_temp_34;
#line 253 "StatisticsModule.cs"
                    if (((opcode) == (1)))
                    {
#line 253 "StatisticsModule.cs"
                        int csharp2cuda_temp_35 = (first)->count;
#line 253 "StatisticsModule.cs"
                        csharp2cuda_temp_34 = mathblocks_statistics_mean(a, csharp2cuda_temp_35);
                    }
                    else
                    {
#line 253 "StatisticsModule.cs"
                        csharp2cuda_temp_34 = 0.0;
                    }
#line 253 "StatisticsModule.cs"
                    double mean = csharp2cuda_temp_34;
#line 254 "StatisticsModule.cs"
                    double sum = 0.0;
#line 255 "StatisticsModule.cs"
                    {
#line 255 "StatisticsModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 255 "StatisticsModule.cs"
                            int csharp2cuda_temp_37 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_37))))
                                break;
#line 256 "StatisticsModule.cs"
#line 256 "StatisticsModule.cs"
                            double* csharp2cuda_temp_38 = &(sum);
#line 256 "StatisticsModule.cs"
                            double csharp2cuda_temp_39 = *(csharp2cuda_temp_38);
#line 256 "StatisticsModule.cs"
                            double csharp2cuda_temp_40 = (a)[index];
                            (*(csharp2cuda_temp_38) = __dadd_rn(csharp2cuda_temp_39, mathblocks_power(__dsub_rn(csharp2cuda_temp_40, mean), ((double)(order)))));
#line 255 "StatisticsModule.cs"
                            int* csharp2cuda_temp_36 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_36));
                        }
                    }
#line 257 "StatisticsModule.cs"
#line 257 "StatisticsModule.cs"
                    double* csharp2cuda_temp_41 = &((output)->scalar_value);
#line 257 "StatisticsModule.cs"
                    int csharp2cuda_temp_42 = (first)->count;
#line 257 "StatisticsModule.cs"
                    double csharp2cuda_temp_43 = __ddiv_rn(sum, ((double)(csharp2cuda_temp_42)));
                    (*(csharp2cuda_temp_41) = csharp2cuda_temp_43);
#line 258 "StatisticsModule.cs"
                    break;
                }
#line 260 "StatisticsModule.cs"
            case 2:
#line 261 "StatisticsModule.cs"
                {
#line 262 "StatisticsModule.cs"
                    int rows = (first)->rows;
#line 263 "StatisticsModule.cs"
                    int columns = (first)->columns;
#line 264 "StatisticsModule.cs"
                    mathblocks_sequence_set_matrix_shape(output, columns, columns);
#line 265 "StatisticsModule.cs"
#line 265 "StatisticsModule.cs"
                    bool csharp2cuda_temp_44;
#line 265 "StatisticsModule.cs"
                    if (!(((rows) <= (0))))
                    {
#line 265 "StatisticsModule.cs"
                        csharp2cuda_temp_44 = ((columns) <= (0));
                    }
                    else
                    {
#line 265 "StatisticsModule.cs"
                        csharp2cuda_temp_44 = true;
                    }
#line 265 "StatisticsModule.cs"
                    bool csharp2cuda_temp_45;
#line 265 "StatisticsModule.cs"
                    if (!(csharp2cuda_temp_44))
                    {
#line 265 "StatisticsModule.cs"
                        csharp2cuda_temp_45 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 265 "StatisticsModule.cs"
                        csharp2cuda_temp_45 = true;
                    }
                    if (csharp2cuda_temp_45)
#line 266 "StatisticsModule.cs"
                    {
#line 267 "StatisticsModule.cs"
#line 267 "StatisticsModule.cs"
                        int* csharp2cuda_temp_46 = &((output)->valid);
                        (*(csharp2cuda_temp_46) = 0);
#line 268 "StatisticsModule.cs"
                        break;
                    }
#line 270 "StatisticsModule.cs"
                    {
#line 270 "StatisticsModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (columns))))
                                break;
#line 271 "StatisticsModule.cs"
                            {
#line 272 "StatisticsModule.cs"
#line 272 "StatisticsModule.cs"
                                double* csharp2cuda_temp_48 = &((scratch)[column]);
                                (*(csharp2cuda_temp_48) = 0.0);
#line 273 "StatisticsModule.cs"
                                {
#line 273 "StatisticsModule.cs"
                                    int row = 0;
                                    while (true)
                                    {
                                        if (!(((row) < (rows))))
                                            break;
#line 274 "StatisticsModule.cs"
#line 274 "StatisticsModule.cs"
                                        double* csharp2cuda_temp_50 = &((scratch)[column]);
#line 274 "StatisticsModule.cs"
                                        double csharp2cuda_temp_51 = *(csharp2cuda_temp_50);
#line 274 "StatisticsModule.cs"
                                        double csharp2cuda_temp_52 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 274 "StatisticsModule.cs"
                                        double csharp2cuda_temp_53 = __ddiv_rn(csharp2cuda_temp_52, ((double)(rows)));
                                        (*(csharp2cuda_temp_50) = __dadd_rn(csharp2cuda_temp_51, csharp2cuda_temp_53));
#line 273 "StatisticsModule.cs"
                                        int* csharp2cuda_temp_49 = &(row);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_49));
                                    }
                                }
                            }
#line 270 "StatisticsModule.cs"
                            int* csharp2cuda_temp_47 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_47));
                        }
                    }
#line 276 "StatisticsModule.cs"
                    {
#line 276 "StatisticsModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (columns))))
                                break;
#line 277 "StatisticsModule.cs"
                            {
#line 278 "StatisticsModule.cs"
                                {
#line 278 "StatisticsModule.cs"
                                    int right = left;
                                    while (true)
                                    {
                                        if (!(((right) < (columns))))
                                            break;
#line 279 "StatisticsModule.cs"
                                        {
#line 280 "StatisticsModule.cs"
                                            double sum = 0.0;
#line 281 "StatisticsModule.cs"
                                            {
#line 281 "StatisticsModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
                                                    if (!(((row) < (rows))))
                                                        break;
#line 282 "StatisticsModule.cs"
                                                    {
#line 283 "StatisticsModule.cs"
#line 283 "StatisticsModule.cs"
                                                        double* csharp2cuda_temp_57 = &(sum);
#line 283 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_58 = *(csharp2cuda_temp_57);
#line 283 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_59 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), left)];
#line 283 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_60 = (scratch)[left];
#line 284 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_61 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), right)];
#line 284 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_62 = (scratch)[right];
                                                        (*(csharp2cuda_temp_57) = __dadd_rn(csharp2cuda_temp_58, __dmul_rn(__dsub_rn(csharp2cuda_temp_59, csharp2cuda_temp_60), __dsub_rn(csharp2cuda_temp_61, csharp2cuda_temp_62))));
                                                    }
#line 281 "StatisticsModule.cs"
                                                    int* csharp2cuda_temp_56 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_56));
                                                }
                                            }
#line 286 "StatisticsModule.cs"
                                            double covariance = __ddiv_rn(sum, ((double)(rows)));
#line 287 "StatisticsModule.cs"
#line 287 "StatisticsModule.cs"
                                            double* csharp2cuda_temp_63 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, columns), right)]);
                                            (*(csharp2cuda_temp_63) = covariance);
#line 288 "StatisticsModule.cs"
#line 288 "StatisticsModule.cs"
                                            double* csharp2cuda_temp_64 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(right, columns), left)]);
                                            (*(csharp2cuda_temp_64) = covariance);
                                        }
#line 278 "StatisticsModule.cs"
                                        int* csharp2cuda_temp_55 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_55));
                                    }
                                }
                            }
#line 276 "StatisticsModule.cs"
                            int* csharp2cuda_temp_54 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_54));
                        }
                    }
#line 291 "StatisticsModule.cs"
                    break;
                }
#line 293 "StatisticsModule.cs"
            case 3:
#line 294 "StatisticsModule.cs"
                {
#line 295 "StatisticsModule.cs"
                    int count = (first)->count;
#line 296 "StatisticsModule.cs"
#line 296 "StatisticsModule.cs"
                    bool csharp2cuda_temp_65;
#line 296 "StatisticsModule.cs"
                    if (!(((count) <= (0))))
                    {
#line 296 "StatisticsModule.cs"
                        int csharp2cuda_temp_66 = (second)->count;
#line 296 "StatisticsModule.cs"
                        csharp2cuda_temp_65 = ((count) != (csharp2cuda_temp_66));
                    }
                    else
                    {
#line 296 "StatisticsModule.cs"
                        csharp2cuda_temp_65 = true;
                    }
#line 296 "StatisticsModule.cs"
                    bool csharp2cuda_temp_67;
#line 296 "StatisticsModule.cs"
                    if (!(csharp2cuda_temp_65))
                    {
#line 296 "StatisticsModule.cs"
                        csharp2cuda_temp_67 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 296 "StatisticsModule.cs"
                        csharp2cuda_temp_67 = true;
                    }
                    if (csharp2cuda_temp_67)
#line 297 "StatisticsModule.cs"
                    {
#line 298 "StatisticsModule.cs"
#line 298 "StatisticsModule.cs"
                        int* csharp2cuda_temp_68 = &((output)->valid);
                        (*(csharp2cuda_temp_68) = 0);
#line 299 "StatisticsModule.cs"
                        break;
                    }
#line 301 "StatisticsModule.cs"
                    double* left_distances = scratch;
#line 302 "StatisticsModule.cs"
                    double* right_distances = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(count, count));
#line 303 "StatisticsModule.cs"
                    double* row_means = csharp2cuda_pointer_add(right_distances, csharp2cuda_i32_mul(count, count));
#line 304 "StatisticsModule.cs"
                    mathblocks_statistics_center_distance(a, count, left_distances, row_means);
#line 305 "StatisticsModule.cs"
                    mathblocks_statistics_center_distance(b, count, right_distances, row_means);
#line 306 "StatisticsModule.cs"
                    double covariance_square = 0.0;
#line 307 "StatisticsModule.cs"
                    double left_variance_square = 0.0;
#line 308 "StatisticsModule.cs"
                    double right_variance_square = 0.0;
#line 309 "StatisticsModule.cs"
                    {
#line 309 "StatisticsModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(count, count)))))
                                break;
#line 310 "StatisticsModule.cs"
                            {
#line 311 "StatisticsModule.cs"
#line 311 "StatisticsModule.cs"
                                double* csharp2cuda_temp_70 = &(covariance_square);
#line 311 "StatisticsModule.cs"
                                double csharp2cuda_temp_71 = *(csharp2cuda_temp_70);
#line 311 "StatisticsModule.cs"
                                double csharp2cuda_temp_72 = (left_distances)[index];
#line 311 "StatisticsModule.cs"
                                double csharp2cuda_temp_73 = (right_distances)[index];
                                (*(csharp2cuda_temp_70) = __dadd_rn(csharp2cuda_temp_71, __dmul_rn(csharp2cuda_temp_72, csharp2cuda_temp_73)));
#line 312 "StatisticsModule.cs"
#line 312 "StatisticsModule.cs"
                                double* csharp2cuda_temp_74 = &(left_variance_square);
#line 312 "StatisticsModule.cs"
                                double csharp2cuda_temp_75 = *(csharp2cuda_temp_74);
#line 312 "StatisticsModule.cs"
                                double csharp2cuda_temp_76 = (left_distances)[index];
#line 312 "StatisticsModule.cs"
                                double csharp2cuda_temp_77 = (left_distances)[index];
                                (*(csharp2cuda_temp_74) = __dadd_rn(csharp2cuda_temp_75, __dmul_rn(csharp2cuda_temp_76, csharp2cuda_temp_77)));
#line 313 "StatisticsModule.cs"
#line 313 "StatisticsModule.cs"
                                double* csharp2cuda_temp_78 = &(right_variance_square);
#line 313 "StatisticsModule.cs"
                                double csharp2cuda_temp_79 = *(csharp2cuda_temp_78);
#line 313 "StatisticsModule.cs"
                                double csharp2cuda_temp_80 = (right_distances)[index];
#line 313 "StatisticsModule.cs"
                                double csharp2cuda_temp_81 = (right_distances)[index];
                                (*(csharp2cuda_temp_78) = __dadd_rn(csharp2cuda_temp_79, __dmul_rn(csharp2cuda_temp_80, csharp2cuda_temp_81)));
                            }
#line 309 "StatisticsModule.cs"
                            int* csharp2cuda_temp_69 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_69));
                        }
                    }
#line 315 "StatisticsModule.cs"
#line 315 "StatisticsModule.cs"
                    double* csharp2cuda_temp_82 = &(covariance_square);
#line 315 "StatisticsModule.cs"
                    double csharp2cuda_temp_83 = *(csharp2cuda_temp_82);
                    (*(csharp2cuda_temp_82) = __ddiv_rn(csharp2cuda_temp_83, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 316 "StatisticsModule.cs"
#line 316 "StatisticsModule.cs"
                    double* csharp2cuda_temp_84 = &(left_variance_square);
#line 316 "StatisticsModule.cs"
                    double csharp2cuda_temp_85 = *(csharp2cuda_temp_84);
                    (*(csharp2cuda_temp_84) = __ddiv_rn(csharp2cuda_temp_85, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 317 "StatisticsModule.cs"
#line 317 "StatisticsModule.cs"
                    double* csharp2cuda_temp_86 = &(right_variance_square);
#line 317 "StatisticsModule.cs"
                    double csharp2cuda_temp_87 = *(csharp2cuda_temp_86);
                    (*(csharp2cuda_temp_86) = __ddiv_rn(csharp2cuda_temp_87, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 318 "StatisticsModule.cs"
#line 318 "StatisticsModule.cs"
                    double* csharp2cuda_temp_88 = &((output)->scalar_value);
#line 319 "StatisticsModule.cs"
                    double csharp2cuda_temp_89 = __ddiv_rn(covariance_square, mathblocks_square_root(__dmul_rn(left_variance_square, right_variance_square)));
                    (*(csharp2cuda_temp_88) = mathblocks_square_root(csharp2cuda_temp_89));
#line 321 "StatisticsModule.cs"
                    break;
                }
#line 323 "StatisticsModule.cs"
            case 4:
#line 324 "StatisticsModule.cs"
                {
#line 325 "StatisticsModule.cs"
#line 325 "StatisticsModule.cs"
                    int csharp2cuda_temp_90 = (second)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_90, 1));
#line 326 "StatisticsModule.cs"
                    {
#line 326 "StatisticsModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 326 "StatisticsModule.cs"
                            int csharp2cuda_temp_92 = (second)->count;
                            if (!(((index) < (csharp2cuda_temp_92))))
                                break;
#line 327 "StatisticsModule.cs"
                            {
#line 328 "StatisticsModule.cs"
#line 328 "StatisticsModule.cs"
                                double csharp2cuda_temp_93 = (b)[index];
#line 328 "StatisticsModule.cs"
                                double csharp2cuda_temp_94 = (b)[csharp2cuda_i32_sub(index, 1)];
                                if (((csharp2cuda_temp_93) <= (csharp2cuda_temp_94)))
#line 329 "StatisticsModule.cs"
                                {
#line 330 "StatisticsModule.cs"
#line 330 "StatisticsModule.cs"
                                    int* csharp2cuda_temp_95 = &((output)->valid);
                                    (*(csharp2cuda_temp_95) = 0);
#line 331 "StatisticsModule.cs"
                                    break;
                                }
                            }
#line 326 "StatisticsModule.cs"
                            int* csharp2cuda_temp_91 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_91));
                        }
                    }
#line 334 "StatisticsModule.cs"
                    {
#line 334 "StatisticsModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 334 "StatisticsModule.cs"
                            bool csharp2cuda_temp_97 = (output)->valid;
#line 334 "StatisticsModule.cs"
                            bool csharp2cuda_temp_98;
#line 334 "StatisticsModule.cs"
                            if (csharp2cuda_temp_97)
                            {
#line 334 "StatisticsModule.cs"
                                int csharp2cuda_temp_99 = (output)->count;
#line 334 "StatisticsModule.cs"
                                csharp2cuda_temp_98 = ((index) < (csharp2cuda_temp_99));
                            }
                            else
                            {
#line 334 "StatisticsModule.cs"
                                csharp2cuda_temp_98 = false;
                            }
                            if (!(csharp2cuda_temp_98))
                                break;
#line 335 "StatisticsModule.cs"
#line 335 "StatisticsModule.cs"
                            double* csharp2cuda_temp_100 = &((result)[index]);
                            (*(csharp2cuda_temp_100) = 0.0);
#line 334 "StatisticsModule.cs"
                            int* csharp2cuda_temp_96 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_96));
                        }
                    }
#line 336 "StatisticsModule.cs"
                    {
#line 336 "StatisticsModule.cs"
                        int value_index = 0;
                        while (true)
                        {
#line 336 "StatisticsModule.cs"
                            bool csharp2cuda_temp_102 = (output)->valid;
#line 336 "StatisticsModule.cs"
                            bool csharp2cuda_temp_103;
#line 336 "StatisticsModule.cs"
                            if (csharp2cuda_temp_102)
                            {
#line 336 "StatisticsModule.cs"
                                int csharp2cuda_temp_104 = (first)->count;
#line 336 "StatisticsModule.cs"
                                csharp2cuda_temp_103 = ((value_index) < (csharp2cuda_temp_104));
                            }
                            else
                            {
#line 336 "StatisticsModule.cs"
                                csharp2cuda_temp_103 = false;
                            }
                            if (!(csharp2cuda_temp_103))
                                break;
#line 337 "StatisticsModule.cs"
                            {
#line 338 "StatisticsModule.cs"
                                int lower = 0;
#line 339 "StatisticsModule.cs"
                                int upper = (second)->count;
#line 340 "StatisticsModule.cs"
                                while (true)
                                {
                                    if (!(((lower) < (upper))))
                                        break;
#line 341 "StatisticsModule.cs"
                                    {
#line 342 "StatisticsModule.cs"
                                        int csharp2cuda_temp_105 = csharp2cuda_i32_div(csharp2cuda_i32_sub(upper, lower), 2);
#line 342 "StatisticsModule.cs"
                                        int middle = csharp2cuda_i32_add(lower, csharp2cuda_temp_105);
#line 343 "StatisticsModule.cs"
#line 343 "StatisticsModule.cs"
                                        double csharp2cuda_temp_106 = (a)[value_index];
#line 343 "StatisticsModule.cs"
                                        double csharp2cuda_temp_107 = (b)[middle];
                                        if (((csharp2cuda_temp_106) <= (csharp2cuda_temp_107)))
                                        {
#line 344 "StatisticsModule.cs"
#line 344 "StatisticsModule.cs"
                                            int* csharp2cuda_temp_108 = &(upper);
                                            (*(csharp2cuda_temp_108) = middle);
                                        }
                                        else
                                        {
#line 346 "StatisticsModule.cs"
#line 346 "StatisticsModule.cs"
                                            int* csharp2cuda_temp_109 = &(lower);
                                            (*(csharp2cuda_temp_109) = csharp2cuda_i32_add(middle, 1));
                                        }
                                    }
                                }
#line 348 "StatisticsModule.cs"
#line 348 "StatisticsModule.cs"
                                double* csharp2cuda_temp_110 = &((result)[lower]);
#line 348 "StatisticsModule.cs"
                                double csharp2cuda_temp_111 = *(csharp2cuda_temp_110);
                                (*(csharp2cuda_temp_110) = __dadd_rn(csharp2cuda_temp_111, 1.0));
                            }
#line 336 "StatisticsModule.cs"
                            int* csharp2cuda_temp_101 = &(value_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_101));
                        }
                    }
#line 350 "StatisticsModule.cs"
                    break;
                }
#line 352 "StatisticsModule.cs"
            case 5:
#line 353 "StatisticsModule.cs"
                {
#line 354 "StatisticsModule.cs"
#line 354 "StatisticsModule.cs"
                    int csharp2cuda_temp_112 = (first)->count;
#line 354 "StatisticsModule.cs"
                    bool csharp2cuda_temp_113;
#line 354 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_112) <= (0))))
                    {
#line 354 "StatisticsModule.cs"
                        csharp2cuda_temp_113 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 354 "StatisticsModule.cs"
                        csharp2cuda_temp_113 = true;
                    }
                    if (csharp2cuda_temp_113)
#line 355 "StatisticsModule.cs"
                    {
#line 356 "StatisticsModule.cs"
#line 356 "StatisticsModule.cs"
                        int* csharp2cuda_temp_114 = &((output)->valid);
                        (*(csharp2cuda_temp_114) = 0);
#line 357 "StatisticsModule.cs"
                        break;
                    }
#line 359 "StatisticsModule.cs"
#line 359 "StatisticsModule.cs"
                    int csharp2cuda_temp_115 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_115, scratch);
#line 360 "StatisticsModule.cs"
#line 360 "StatisticsModule.cs"
                    double* csharp2cuda_temp_116 = &((output)->scalar_value);
#line 361 "StatisticsModule.cs"
                    int csharp2cuda_temp_117 = (first)->count;
#line 361 "StatisticsModule.cs"
                    double csharp2cuda_temp_118 = mathblocks_statistics_sorted_quantile(scratch, csharp2cuda_temp_117, 0.75);
#line 362 "StatisticsModule.cs"
                    int csharp2cuda_temp_119 = (first)->count;
#line 362 "StatisticsModule.cs"
                    double csharp2cuda_temp_120 = mathblocks_statistics_sorted_quantile(scratch, csharp2cuda_temp_119, 0.25);
                    (*(csharp2cuda_temp_116) = __dsub_rn(csharp2cuda_temp_118, csharp2cuda_temp_120));
#line 363 "StatisticsModule.cs"
                    break;
                }
#line 365 "StatisticsModule.cs"
            case 6:
#line 366 "StatisticsModule.cs"
                {
#line 367 "StatisticsModule.cs"
#line 367 "StatisticsModule.cs"
                    int csharp2cuda_temp_121 = (first)->count;
#line 367 "StatisticsModule.cs"
                    int csharp2cuda_temp_122 = (second)->count;
                    if (((csharp2cuda_temp_121) != (csharp2cuda_temp_122)))
#line 368 "StatisticsModule.cs"
                    {
#line 369 "StatisticsModule.cs"
#line 369 "StatisticsModule.cs"
                        int* csharp2cuda_temp_123 = &((output)->valid);
                        (*(csharp2cuda_temp_123) = 0);
#line 370 "StatisticsModule.cs"
                        break;
                    }
#line 372 "StatisticsModule.cs"
                    long long concordant = ((long long)(0));
#line 373 "StatisticsModule.cs"
                    long long discordant = ((long long)(0));
#line 374 "StatisticsModule.cs"
                    long long left_ties = ((long long)(0));
#line 375 "StatisticsModule.cs"
                    long long right_ties = ((long long)(0));
#line 376 "StatisticsModule.cs"
                    {
#line 376 "StatisticsModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 376 "StatisticsModule.cs"
                            int csharp2cuda_temp_125 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_125))))
                                break;
#line 377 "StatisticsModule.cs"
                            {
#line 378 "StatisticsModule.cs"
                                {
#line 378 "StatisticsModule.cs"
                                    int right = csharp2cuda_i32_add(left, 1);
                                    while (true)
                                    {
#line 378 "StatisticsModule.cs"
                                        int csharp2cuda_temp_127 = (first)->count;
                                        if (!(((right) < (csharp2cuda_temp_127))))
                                            break;
#line 379 "StatisticsModule.cs"
                                        {
#line 380 "StatisticsModule.cs"
                                            double csharp2cuda_temp_128 = (a)[left];
#line 380 "StatisticsModule.cs"
                                            double csharp2cuda_temp_129 = (a)[right];
#line 380 "StatisticsModule.cs"
                                            double left_difference = __dsub_rn(csharp2cuda_temp_128, csharp2cuda_temp_129);
#line 381 "StatisticsModule.cs"
                                            double csharp2cuda_temp_130 = (b)[left];
#line 381 "StatisticsModule.cs"
                                            double csharp2cuda_temp_131 = (b)[right];
#line 381 "StatisticsModule.cs"
                                            double right_difference = __dsub_rn(csharp2cuda_temp_130, csharp2cuda_temp_131);
#line 382 "StatisticsModule.cs"
                                            int csharp2cuda_temp_132;
#line 382 "StatisticsModule.cs"
                                            if (((left_difference) > (0.0)))
                                            {
#line 382 "StatisticsModule.cs"
                                                csharp2cuda_temp_132 = 1;
                                            }
                                            else
                                            {
#line 382 "StatisticsModule.cs"
                                                int csharp2cuda_temp_133;
#line 382 "StatisticsModule.cs"
                                                if (((left_difference) < (0.0)))
                                                {
#line 382 "StatisticsModule.cs"
                                                    csharp2cuda_temp_133 = csharp2cuda_i32_neg(1);
                                                }
                                                else
                                                {
#line 382 "StatisticsModule.cs"
                                                    csharp2cuda_temp_133 = 0;
                                                }
#line 382 "StatisticsModule.cs"
                                                csharp2cuda_temp_132 = csharp2cuda_temp_133;
                                            }
#line 382 "StatisticsModule.cs"
                                            int left_sign = csharp2cuda_temp_132;
#line 383 "StatisticsModule.cs"
                                            int csharp2cuda_temp_134;
#line 383 "StatisticsModule.cs"
                                            if (((right_difference) > (0.0)))
                                            {
#line 383 "StatisticsModule.cs"
                                                csharp2cuda_temp_134 = 1;
                                            }
                                            else
                                            {
#line 383 "StatisticsModule.cs"
                                                int csharp2cuda_temp_135;
#line 383 "StatisticsModule.cs"
                                                if (((right_difference) < (0.0)))
                                                {
#line 383 "StatisticsModule.cs"
                                                    csharp2cuda_temp_135 = csharp2cuda_i32_neg(1);
                                                }
                                                else
                                                {
#line 383 "StatisticsModule.cs"
                                                    csharp2cuda_temp_135 = 0;
                                                }
#line 383 "StatisticsModule.cs"
                                                csharp2cuda_temp_134 = csharp2cuda_temp_135;
                                            }
#line 383 "StatisticsModule.cs"
                                            int right_sign = csharp2cuda_temp_134;
#line 384 "StatisticsModule.cs"
#line 384 "StatisticsModule.cs"
                                            bool csharp2cuda_temp_136;
#line 384 "StatisticsModule.cs"
                                            if (((left_sign) == (0)))
                                            {
#line 384 "StatisticsModule.cs"
                                                csharp2cuda_temp_136 = ((right_sign) == (0));
                                            }
                                            else
                                            {
#line 384 "StatisticsModule.cs"
                                                csharp2cuda_temp_136 = false;
                                            }
                                            if (csharp2cuda_temp_136)
                                            {
#line 385 "StatisticsModule.cs"
                                                goto csharp2cuda_for_continue_10;
                                            }
#line 386 "StatisticsModule.cs"
                                            if (((left_sign) == (0)))
                                            {
#line 387 "StatisticsModule.cs"
#line 387 "StatisticsModule.cs"
                                                long long* csharp2cuda_temp_137 = &(left_ties);
                                                csharp2cuda_i64_post_increment(*(csharp2cuda_temp_137));
                                            }
                                            else
                                            {
#line 388 "StatisticsModule.cs"
                                                if (((right_sign) == (0)))
                                                {
#line 389 "StatisticsModule.cs"
#line 389 "StatisticsModule.cs"
                                                    long long* csharp2cuda_temp_138 = &(right_ties);
                                                    csharp2cuda_i64_post_increment(*(csharp2cuda_temp_138));
                                                }
                                                else
                                                {
#line 390 "StatisticsModule.cs"
                                                    if (((left_sign) == (right_sign)))
                                                    {
#line 391 "StatisticsModule.cs"
#line 391 "StatisticsModule.cs"
                                                        long long* csharp2cuda_temp_139 = &(concordant);
                                                        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_139));
                                                    }
                                                    else
                                                    {
#line 393 "StatisticsModule.cs"
#line 393 "StatisticsModule.cs"
                                                        long long* csharp2cuda_temp_140 = &(discordant);
                                                        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_140));
                                                    }
                                                }
                                            }
                                        }
                                        csharp2cuda_for_continue_10:
#line 378 "StatisticsModule.cs"
                                        int* csharp2cuda_temp_126 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_126));
                                    }
                                }
                            }
#line 376 "StatisticsModule.cs"
                            int* csharp2cuda_temp_124 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_124));
                        }
                    }
#line 396 "StatisticsModule.cs"
#line 396 "StatisticsModule.cs"
                    double* csharp2cuda_temp_141 = &((output)->scalar_value);
#line 396 "StatisticsModule.cs"
                    double csharp2cuda_temp_142 = __ddiv_rn(((double)(csharp2cuda_i64_sub(concordant, discordant))), mathblocks_square_root(__dmul_rn(((double)(csharp2cuda_i64_add(csharp2cuda_i64_add(concordant, discordant), left_ties))), ((double)(csharp2cuda_i64_add(csharp2cuda_i64_add(concordant, discordant), right_ties))))));
                    (*(csharp2cuda_temp_141) = csharp2cuda_temp_142);
#line 400 "StatisticsModule.cs"
                    break;
                }
#line 402 "StatisticsModule.cs"
            case 7:
            case 8:
            case 9:
            case 11:
            case 12:
            case 20:
#line 408 "StatisticsModule.cs"
                {
#line 409 "StatisticsModule.cs"
#line 409 "StatisticsModule.cs"
                    int csharp2cuda_temp_143 = (first)->count;
#line 409 "StatisticsModule.cs"
                    bool csharp2cuda_temp_144;
#line 409 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_143) <= (0))))
                    {
#line 409 "StatisticsModule.cs"
                        int csharp2cuda_temp_145 = (first)->count;
#line 409 "StatisticsModule.cs"
                        int csharp2cuda_temp_146 = (second)->count;
#line 409 "StatisticsModule.cs"
                        csharp2cuda_temp_144 = ((csharp2cuda_temp_145) != (csharp2cuda_temp_146));
                    }
                    else
                    {
#line 409 "StatisticsModule.cs"
                        csharp2cuda_temp_144 = true;
                    }
                    if (csharp2cuda_temp_144)
#line 410 "StatisticsModule.cs"
                    {
#line 411 "StatisticsModule.cs"
#line 411 "StatisticsModule.cs"
                        int* csharp2cuda_temp_147 = &((output)->valid);
                        (*(csharp2cuda_temp_147) = 0);
#line 412 "StatisticsModule.cs"
                        break;
                    }
#line 414 "StatisticsModule.cs"
                    int csharp2cuda_temp_148 = (first)->count;
#line 414 "StatisticsModule.cs"
                    double covariance = mathblocks_statistics_population_covariance(a, b, csharp2cuda_temp_148);
#line 415 "StatisticsModule.cs"
#line 415 "StatisticsModule.cs"
                    bool csharp2cuda_temp_149;
#line 415 "StatisticsModule.cs"
                    if (!(((opcode) == (12))))
                    {
#line 415 "StatisticsModule.cs"
                        csharp2cuda_temp_149 = ((opcode) == (20));
                    }
                    else
                    {
#line 415 "StatisticsModule.cs"
                        csharp2cuda_temp_149 = true;
                    }
                    if (csharp2cuda_temp_149)
#line 416 "StatisticsModule.cs"
                    {
#line 417 "StatisticsModule.cs"
#line 417 "StatisticsModule.cs"
                        double* csharp2cuda_temp_150 = &((output)->scalar_value);
#line 417 "StatisticsModule.cs"
                        double csharp2cuda_temp_151;
#line 417 "StatisticsModule.cs"
                        if (((opcode) == (12)))
                        {
#line 417 "StatisticsModule.cs"
                            csharp2cuda_temp_151 = covariance;
                        }
                        else
                        {
#line 419 "StatisticsModule.cs"
                            int csharp2cuda_temp_152 = (first)->count;
#line 419 "StatisticsModule.cs"
                            int csharp2cuda_temp_153 = (first)->count;
#line 417 "StatisticsModule.cs"
                            csharp2cuda_temp_151 = __ddiv_rn(__dmul_rn(covariance, ((double)(csharp2cuda_temp_152))), __dsub_rn(((double)(csharp2cuda_temp_153)), 1.0));
                        }
                        (*(csharp2cuda_temp_150) = csharp2cuda_temp_151);
                    }
                    else
                    {
#line 421 "StatisticsModule.cs"
                        if (((opcode) == (9)))
#line 422 "StatisticsModule.cs"
                        {
#line 423 "StatisticsModule.cs"
#line 423 "StatisticsModule.cs"
                            double* csharp2cuda_temp_154 = &((output)->scalar_value);
#line 424 "StatisticsModule.cs"
                            int csharp2cuda_temp_155 = (first)->count;
#line 424 "StatisticsModule.cs"
                            double csharp2cuda_temp_156 = mathblocks_statistics_population_variance(a, csharp2cuda_temp_155);
#line 423 "StatisticsModule.cs"
                            double csharp2cuda_temp_157 = __ddiv_rn(covariance, csharp2cuda_temp_156);
                            (*(csharp2cuda_temp_154) = csharp2cuda_temp_157);
                        }
                        else
                        {
#line 426 "StatisticsModule.cs"
                            if (((opcode) == (7)))
#line 427 "StatisticsModule.cs"
                            {
#line 429 "StatisticsModule.cs"
                                int csharp2cuda_temp_158 = (first)->count;
#line 429 "StatisticsModule.cs"
                                double csharp2cuda_temp_159 = mathblocks_statistics_population_variance(a, csharp2cuda_temp_158);
#line 428 "StatisticsModule.cs"
                                double slope = __ddiv_rn(covariance, csharp2cuda_temp_159);
#line 430 "StatisticsModule.cs"
#line 430 "StatisticsModule.cs"
                                double* csharp2cuda_temp_160 = &((output)->scalar_value);
#line 430 "StatisticsModule.cs"
                                int csharp2cuda_temp_161 = (first)->count;
#line 430 "StatisticsModule.cs"
                                double csharp2cuda_temp_162 = mathblocks_statistics_mean(b, csharp2cuda_temp_161);
#line 431 "StatisticsModule.cs"
                                int csharp2cuda_temp_163 = (first)->count;
#line 431 "StatisticsModule.cs"
                                double csharp2cuda_temp_164 = mathblocks_statistics_mean(a, csharp2cuda_temp_163);
                                (*(csharp2cuda_temp_160) = __dsub_rn(csharp2cuda_temp_162, __dmul_rn(slope, csharp2cuda_temp_164)));
                            }
                            else
#line 434 "StatisticsModule.cs"
                            {
#line 436 "StatisticsModule.cs"
                                int csharp2cuda_temp_165 = (first)->count;
#line 436 "StatisticsModule.cs"
                                double csharp2cuda_temp_166 = mathblocks_statistics_population_variance(a, csharp2cuda_temp_165);
#line 437 "StatisticsModule.cs"
                                int csharp2cuda_temp_167 = (first)->count;
#line 437 "StatisticsModule.cs"
                                double csharp2cuda_temp_168 = mathblocks_statistics_population_variance(b, csharp2cuda_temp_167);
#line 435 "StatisticsModule.cs"
                                double correlation = __ddiv_rn(covariance, __dmul_rn(mathblocks_square_root(csharp2cuda_temp_166), mathblocks_square_root(csharp2cuda_temp_168)));
#line 438 "StatisticsModule.cs"
#line 438 "StatisticsModule.cs"
                                double* csharp2cuda_temp_169 = &((output)->scalar_value);
#line 438 "StatisticsModule.cs"
                                double csharp2cuda_temp_170;
#line 438 "StatisticsModule.cs"
                                if (((opcode) == (8)))
                                {
#line 438 "StatisticsModule.cs"
                                    csharp2cuda_temp_170 = __dmul_rn(correlation, correlation);
                                }
                                else
                                {
#line 438 "StatisticsModule.cs"
                                    csharp2cuda_temp_170 = correlation;
                                }
                                (*(csharp2cuda_temp_169) = csharp2cuda_temp_170);
                            }
                        }
                    }
#line 440 "StatisticsModule.cs"
                    break;
                }
#line 442 "StatisticsModule.cs"
            case 10:
#line 443 "StatisticsModule.cs"
                {
#line 444 "StatisticsModule.cs"
#line 444 "StatisticsModule.cs"
                    int csharp2cuda_temp_171 = (first)->count;
#line 444 "StatisticsModule.cs"
                    bool csharp2cuda_temp_172;
#line 444 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_171) <= (0))))
                    {
#line 444 "StatisticsModule.cs"
                        csharp2cuda_temp_172 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 444 "StatisticsModule.cs"
                        csharp2cuda_temp_172 = true;
                    }
                    if (csharp2cuda_temp_172)
#line 445 "StatisticsModule.cs"
                    {
#line 446 "StatisticsModule.cs"
#line 446 "StatisticsModule.cs"
                        int* csharp2cuda_temp_173 = &((output)->valid);
                        (*(csharp2cuda_temp_173) = 0);
#line 447 "StatisticsModule.cs"
                        break;
                    }
#line 449 "StatisticsModule.cs"
                    double* sorted = scratch;
#line 450 "StatisticsModule.cs"
                    int csharp2cuda_temp_174 = (first)->count;
#line 450 "StatisticsModule.cs"
                    double* deviations = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_174);
#line 451 "StatisticsModule.cs"
#line 451 "StatisticsModule.cs"
                    int csharp2cuda_temp_175 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_175, sorted);
#line 452 "StatisticsModule.cs"
                    int csharp2cuda_temp_176 = (first)->count;
#line 452 "StatisticsModule.cs"
                    double median = mathblocks_statistics_sorted_quantile(sorted, csharp2cuda_temp_176, 0.5);
#line 453 "StatisticsModule.cs"
                    {
#line 453 "StatisticsModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 453 "StatisticsModule.cs"
                            int csharp2cuda_temp_178 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_178))))
                                break;
#line 454 "StatisticsModule.cs"
#line 454 "StatisticsModule.cs"
                            double* csharp2cuda_temp_179 = &((deviations)[index]);
#line 454 "StatisticsModule.cs"
                            double csharp2cuda_temp_180 = (a)[index];
                            (*(csharp2cuda_temp_179) = fabs(__dsub_rn(csharp2cuda_temp_180, median)));
#line 453 "StatisticsModule.cs"
                            int* csharp2cuda_temp_177 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_177));
                        }
                    }
#line 455 "StatisticsModule.cs"
#line 455 "StatisticsModule.cs"
                    int csharp2cuda_temp_181 = (first)->count;
                    mathblocks_statistics_sort_copy(deviations, csharp2cuda_temp_181, sorted);
#line 456 "StatisticsModule.cs"
#line 456 "StatisticsModule.cs"
                    double* csharp2cuda_temp_182 = &((output)->scalar_value);
#line 456 "StatisticsModule.cs"
                    int csharp2cuda_temp_183 = (first)->count;
#line 456 "StatisticsModule.cs"
                    double csharp2cuda_temp_184 = mathblocks_statistics_sorted_quantile(sorted, csharp2cuda_temp_183, 0.5);
                    (*(csharp2cuda_temp_182) = csharp2cuda_temp_184);
#line 457 "StatisticsModule.cs"
                    break;
                }
#line 459 "StatisticsModule.cs"
            case 13:
            case 14:
#line 461 "StatisticsModule.cs"
                {
#line 462 "StatisticsModule.cs"
#line 462 "StatisticsModule.cs"
                    int csharp2cuda_temp_185 = (first)->count;
                    if (((csharp2cuda_temp_185) <= (0)))
#line 463 "StatisticsModule.cs"
                    {
#line 464 "StatisticsModule.cs"
#line 464 "StatisticsModule.cs"
                        int* csharp2cuda_temp_186 = &((output)->valid);
                        (*(csharp2cuda_temp_186) = 0);
#line 465 "StatisticsModule.cs"
                        break;
                    }
#line 467 "StatisticsModule.cs"
                    int csharp2cuda_temp_187 = (first)->count;
#line 467 "StatisticsModule.cs"
                    double mean = mathblocks_statistics_mean(a, csharp2cuda_temp_187);
#line 468 "StatisticsModule.cs"
                    double second_moment = 0.0;
#line 469 "StatisticsModule.cs"
                    double higher_moment = 0.0;
#line 470 "StatisticsModule.cs"
                    {
#line 470 "StatisticsModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 470 "StatisticsModule.cs"
                            int csharp2cuda_temp_189 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_189))))
                                break;
#line 471 "StatisticsModule.cs"
                            {
#line 472 "StatisticsModule.cs"
                                double csharp2cuda_temp_190 = (a)[index];
#line 472 "StatisticsModule.cs"
                                double difference = __dsub_rn(csharp2cuda_temp_190, mean);
#line 473 "StatisticsModule.cs"
                                double square = __dmul_rn(difference, difference);
#line 474 "StatisticsModule.cs"
#line 474 "StatisticsModule.cs"
                                double* csharp2cuda_temp_191 = &(second_moment);
#line 474 "StatisticsModule.cs"
                                double csharp2cuda_temp_192 = *(csharp2cuda_temp_191);
                                (*(csharp2cuda_temp_191) = __dadd_rn(csharp2cuda_temp_192, square));
#line 475 "StatisticsModule.cs"
#line 475 "StatisticsModule.cs"
                                double* csharp2cuda_temp_193 = &(higher_moment);
#line 475 "StatisticsModule.cs"
                                double csharp2cuda_temp_194 = *(csharp2cuda_temp_193);
#line 475 "StatisticsModule.cs"
                                double csharp2cuda_temp_195;
#line 475 "StatisticsModule.cs"
                                if (((opcode) == (13)))
                                {
#line 475 "StatisticsModule.cs"
                                    csharp2cuda_temp_195 = __dmul_rn(square, square);
                                }
                                else
                                {
#line 475 "StatisticsModule.cs"
                                    csharp2cuda_temp_195 = __dmul_rn(square, difference);
                                }
                                (*(csharp2cuda_temp_193) = __dadd_rn(csharp2cuda_temp_194, csharp2cuda_temp_195));
                            }
#line 470 "StatisticsModule.cs"
                            int* csharp2cuda_temp_188 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_188));
                        }
                    }
#line 477 "StatisticsModule.cs"
#line 477 "StatisticsModule.cs"
                    double* csharp2cuda_temp_196 = &(second_moment);
#line 477 "StatisticsModule.cs"
                    double csharp2cuda_temp_197 = *(csharp2cuda_temp_196);
#line 477 "StatisticsModule.cs"
                    int csharp2cuda_temp_198 = (first)->count;
                    (*(csharp2cuda_temp_196) = __ddiv_rn(csharp2cuda_temp_197, ((double)(csharp2cuda_temp_198))));
#line 478 "StatisticsModule.cs"
#line 478 "StatisticsModule.cs"
                    double* csharp2cuda_temp_199 = &(higher_moment);
#line 478 "StatisticsModule.cs"
                    double csharp2cuda_temp_200 = *(csharp2cuda_temp_199);
#line 478 "StatisticsModule.cs"
                    int csharp2cuda_temp_201 = (first)->count;
                    (*(csharp2cuda_temp_199) = __ddiv_rn(csharp2cuda_temp_200, ((double)(csharp2cuda_temp_201))));
#line 479 "StatisticsModule.cs"
#line 479 "StatisticsModule.cs"
                    double* csharp2cuda_temp_202 = &((output)->scalar_value);
#line 479 "StatisticsModule.cs"
                    double csharp2cuda_temp_203;
#line 479 "StatisticsModule.cs"
                    if (((opcode) == (13)))
                    {
#line 480 "StatisticsModule.cs"
                        double csharp2cuda_temp_204 = __ddiv_rn(higher_moment, __dmul_rn(second_moment, second_moment));
#line 479 "StatisticsModule.cs"
                        csharp2cuda_temp_203 = __dsub_rn(csharp2cuda_temp_204, 3.0);
                    }
                    else
                    {
#line 479 "StatisticsModule.cs"
                        csharp2cuda_temp_203 = __ddiv_rn(higher_moment, mathblocks_power(second_moment, 1.5));
                    }
                    (*(csharp2cuda_temp_202) = csharp2cuda_temp_203);
#line 482 "StatisticsModule.cs"
                    break;
                }
#line 484 "StatisticsModule.cs"
            case 15:
            case 16:
            case 21:
            case 22:
#line 488 "StatisticsModule.cs"
                {
#line 489 "StatisticsModule.cs"
#line 489 "StatisticsModule.cs"
                    int csharp2cuda_temp_205 = (first)->count;
                    if (((csharp2cuda_temp_205) <= (0)))
#line 490 "StatisticsModule.cs"
                    {
#line 491 "StatisticsModule.cs"
#line 491 "StatisticsModule.cs"
                        int* csharp2cuda_temp_206 = &((output)->valid);
                        (*(csharp2cuda_temp_206) = 0);
#line 492 "StatisticsModule.cs"
                        break;
                    }
#line 494 "StatisticsModule.cs"
                    int csharp2cuda_temp_207 = (first)->count;
#line 494 "StatisticsModule.cs"
                    double variance = mathblocks_statistics_population_variance(a, csharp2cuda_temp_207);
#line 495 "StatisticsModule.cs"
#line 495 "StatisticsModule.cs"
                    bool csharp2cuda_temp_208;
#line 495 "StatisticsModule.cs"
                    if (!(((opcode) == (21))))
                    {
#line 495 "StatisticsModule.cs"
                        csharp2cuda_temp_208 = ((opcode) == (22));
                    }
                    else
                    {
#line 495 "StatisticsModule.cs"
                        csharp2cuda_temp_208 = true;
                    }
                    if (csharp2cuda_temp_208)
                    {
#line 496 "StatisticsModule.cs"
#line 496 "StatisticsModule.cs"
                        double* csharp2cuda_temp_209 = &(variance);
#line 496 "StatisticsModule.cs"
                        int csharp2cuda_temp_210 = (first)->count;
#line 496 "StatisticsModule.cs"
                        int csharp2cuda_temp_211 = (first)->count;
#line 496 "StatisticsModule.cs"
                        double csharp2cuda_temp_212 = __ddiv_rn(__dmul_rn(variance, ((double)(csharp2cuda_temp_210))), __dsub_rn(((double)(csharp2cuda_temp_211)), 1.0));
                        (*(csharp2cuda_temp_209) = csharp2cuda_temp_212);
                    }
#line 497 "StatisticsModule.cs"
#line 497 "StatisticsModule.cs"
                    double* csharp2cuda_temp_213 = &((output)->scalar_value);
#line 497 "StatisticsModule.cs"
                    bool csharp2cuda_temp_214;
#line 497 "StatisticsModule.cs"
                    if (!(((opcode) == (15))))
                    {
#line 497 "StatisticsModule.cs"
                        csharp2cuda_temp_214 = ((opcode) == (21));
                    }
                    else
                    {
#line 497 "StatisticsModule.cs"
                        csharp2cuda_temp_214 = true;
                    }
#line 497 "StatisticsModule.cs"
                    double csharp2cuda_temp_215;
#line 497 "StatisticsModule.cs"
                    if (csharp2cuda_temp_214)
                    {
#line 497 "StatisticsModule.cs"
                        csharp2cuda_temp_215 = mathblocks_square_root(variance);
                    }
                    else
                    {
#line 497 "StatisticsModule.cs"
                        csharp2cuda_temp_215 = variance;
                    }
                    (*(csharp2cuda_temp_213) = csharp2cuda_temp_215);
#line 500 "StatisticsModule.cs"
                    break;
                }
#line 502 "StatisticsModule.cs"
            case 17:
#line 503 "StatisticsModule.cs"
                {
#line 504 "StatisticsModule.cs"
#line 504 "StatisticsModule.cs"
                    int csharp2cuda_temp_216 = (first)->count;
#line 504 "StatisticsModule.cs"
                    bool csharp2cuda_temp_217;
#line 504 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_216) <= (0))))
                    {
#line 504 "StatisticsModule.cs"
                        csharp2cuda_temp_217 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 504 "StatisticsModule.cs"
                        csharp2cuda_temp_217 = true;
                    }
                    if (csharp2cuda_temp_217)
#line 505 "StatisticsModule.cs"
                    {
#line 506 "StatisticsModule.cs"
#line 506 "StatisticsModule.cs"
                        int* csharp2cuda_temp_218 = &((output)->valid);
                        (*(csharp2cuda_temp_218) = 0);
#line 507 "StatisticsModule.cs"
                        break;
                    }
#line 509 "StatisticsModule.cs"
                    int count = 0;
#line 510 "StatisticsModule.cs"
                    {
#line 510 "StatisticsModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 510 "StatisticsModule.cs"
                            int csharp2cuda_temp_220 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_220))))
                                break;
#line 511 "StatisticsModule.cs"
                            {
#line 511 "StatisticsModule.cs"
                                int right = left;
                                while (true)
                                {
#line 511 "StatisticsModule.cs"
                                    int csharp2cuda_temp_222 = (first)->count;
                                    if (!(((right) < (csharp2cuda_temp_222))))
                                        break;
#line 512 "StatisticsModule.cs"
#line 512 "StatisticsModule.cs"
                                    int* csharp2cuda_temp_223 = &(count);
#line 512 "StatisticsModule.cs"
                                    int csharp2cuda_temp_224 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_223));
#line 512 "StatisticsModule.cs"
                                    double* csharp2cuda_temp_225 = &((scratch)[csharp2cuda_temp_224]);
#line 512 "StatisticsModule.cs"
                                    double csharp2cuda_temp_226 = (a)[left];
#line 512 "StatisticsModule.cs"
                                    double csharp2cuda_temp_227 = (a)[right];
#line 512 "StatisticsModule.cs"
                                    double csharp2cuda_temp_228 = __ddiv_rn(__dadd_rn(csharp2cuda_temp_226, csharp2cuda_temp_227), 2.0);
                                    (*(csharp2cuda_temp_225) = csharp2cuda_temp_228);
#line 511 "StatisticsModule.cs"
                                    int* csharp2cuda_temp_221 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_221));
                                }
                            }
#line 510 "StatisticsModule.cs"
                            int* csharp2cuda_temp_219 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_219));
                        }
                    }
#line 513 "StatisticsModule.cs"
#line 513 "StatisticsModule.cs"
                    double* csharp2cuda_temp_229 = &((output)->scalar_value);
#line 513 "StatisticsModule.cs"
                    double csharp2cuda_temp_230 = mathblocks_statistics_median(scratch, count);
                    (*(csharp2cuda_temp_229) = csharp2cuda_temp_230);
#line 514 "StatisticsModule.cs"
                    break;
                }
#line 516 "StatisticsModule.cs"
            case 19:
#line 517 "StatisticsModule.cs"
#line 517 "StatisticsModule.cs"
                double* csharp2cuda_temp_231 = &((output)->scalar_value);
#line 518 "StatisticsModule.cs"
                int csharp2cuda_temp_232 = (first)->count;
#line 518 "StatisticsModule.cs"
                int csharp2cuda_temp_233 = (first)->count;
#line 518 "StatisticsModule.cs"
                double csharp2cuda_temp_234 = __ddiv_rn(mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_232), ((double)(csharp2cuda_temp_233)));
                (*(csharp2cuda_temp_231) = mathblocks_square_root(csharp2cuda_temp_234));
#line 519 "StatisticsModule.cs"
                break;
#line 520 "StatisticsModule.cs"
            case 23:
#line 521 "StatisticsModule.cs"
                {
#line 522 "StatisticsModule.cs"
#line 522 "StatisticsModule.cs"
                    int csharp2cuda_temp_235 = (first)->count;
#line 522 "StatisticsModule.cs"
                    bool csharp2cuda_temp_236;
#line 522 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_235) <= (0))))
                    {
#line 522 "StatisticsModule.cs"
                        int csharp2cuda_temp_237 = (first)->count;
#line 522 "StatisticsModule.cs"
                        int csharp2cuda_temp_238 = (second)->count;
#line 522 "StatisticsModule.cs"
                        csharp2cuda_temp_236 = ((csharp2cuda_temp_237) != (csharp2cuda_temp_238));
                    }
                    else
                    {
#line 522 "StatisticsModule.cs"
                        csharp2cuda_temp_236 = true;
                    }
#line 522 "StatisticsModule.cs"
                    bool csharp2cuda_temp_239;
#line 522 "StatisticsModule.cs"
                    if (!(csharp2cuda_temp_236))
                    {
#line 522 "StatisticsModule.cs"
                        csharp2cuda_temp_239 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 522 "StatisticsModule.cs"
                        csharp2cuda_temp_239 = true;
                    }
                    if (csharp2cuda_temp_239)
#line 523 "StatisticsModule.cs"
                    {
#line 524 "StatisticsModule.cs"
#line 524 "StatisticsModule.cs"
                        int* csharp2cuda_temp_240 = &((output)->valid);
                        (*(csharp2cuda_temp_240) = 0);
#line 525 "StatisticsModule.cs"
                        break;
                    }
#line 527 "StatisticsModule.cs"
                    double* left_ranks = scratch;
#line 528 "StatisticsModule.cs"
                    int csharp2cuda_temp_241 = (first)->count;
#line 528 "StatisticsModule.cs"
                    double* right_ranks = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_241);
#line 529 "StatisticsModule.cs"
#line 529 "StatisticsModule.cs"
                    int csharp2cuda_temp_242 = (first)->count;
                    mathblocks_statistics_rank(a, csharp2cuda_temp_242, left_ranks);
#line 530 "StatisticsModule.cs"
#line 530 "StatisticsModule.cs"
                    int csharp2cuda_temp_243 = (first)->count;
                    mathblocks_statistics_rank(b, csharp2cuda_temp_243, right_ranks);
#line 531 "StatisticsModule.cs"
#line 531 "StatisticsModule.cs"
                    double* csharp2cuda_temp_244 = &((output)->scalar_value);
#line 534 "StatisticsModule.cs"
                    int csharp2cuda_temp_245 = (first)->count;
#line 531 "StatisticsModule.cs"
                    double csharp2cuda_temp_246 = mathblocks_statistics_pearson(left_ranks, right_ranks, csharp2cuda_temp_245);
                    (*(csharp2cuda_temp_244) = csharp2cuda_temp_246);
#line 535 "StatisticsModule.cs"
                    break;
                }
#line 537 "StatisticsModule.cs"
            case 24:
#line 538 "StatisticsModule.cs"
                {
#line 539 "StatisticsModule.cs"
#line 539 "StatisticsModule.cs"
                    int csharp2cuda_temp_247 = (first)->count;
#line 539 "StatisticsModule.cs"
                    int csharp2cuda_temp_248 = (second)->count;
#line 539 "StatisticsModule.cs"
                    bool csharp2cuda_temp_249;
#line 539 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_247) != (csharp2cuda_temp_248))))
                    {
#line 539 "StatisticsModule.cs"
                        csharp2cuda_temp_249 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 539 "StatisticsModule.cs"
                        csharp2cuda_temp_249 = true;
                    }
                    if (csharp2cuda_temp_249)
#line 540 "StatisticsModule.cs"
                    {
#line 541 "StatisticsModule.cs"
#line 541 "StatisticsModule.cs"
                        int* csharp2cuda_temp_250 = &((output)->valid);
                        (*(csharp2cuda_temp_250) = 0);
#line 542 "StatisticsModule.cs"
                        break;
                    }
#line 544 "StatisticsModule.cs"
                    int count = 0;
#line 545 "StatisticsModule.cs"
                    {
#line 545 "StatisticsModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 545 "StatisticsModule.cs"
                            int csharp2cuda_temp_252 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_252))))
                                break;
#line 546 "StatisticsModule.cs"
                            {
#line 547 "StatisticsModule.cs"
                                {
#line 547 "StatisticsModule.cs"
                                    int right = csharp2cuda_i32_add(left, 1);
                                    while (true)
                                    {
#line 547 "StatisticsModule.cs"
                                        int csharp2cuda_temp_254 = (first)->count;
                                        if (!(((right) < (csharp2cuda_temp_254))))
                                            break;
#line 548 "StatisticsModule.cs"
                                        {
#line 549 "StatisticsModule.cs"
                                            double csharp2cuda_temp_255 = (a)[right];
#line 549 "StatisticsModule.cs"
                                            double csharp2cuda_temp_256 = (a)[left];
#line 549 "StatisticsModule.cs"
                                            double difference = __dsub_rn(csharp2cuda_temp_255, csharp2cuda_temp_256);
#line 550 "StatisticsModule.cs"
                                            if (((difference) != (0.0)))
                                            {
#line 551 "StatisticsModule.cs"
#line 551 "StatisticsModule.cs"
                                                int* csharp2cuda_temp_257 = &(count);
#line 551 "StatisticsModule.cs"
                                                int csharp2cuda_temp_258 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_257));
#line 551 "StatisticsModule.cs"
                                                double* csharp2cuda_temp_259 = &((scratch)[csharp2cuda_temp_258]);
#line 551 "StatisticsModule.cs"
                                                double csharp2cuda_temp_260 = (b)[right];
#line 551 "StatisticsModule.cs"
                                                double csharp2cuda_temp_261 = (b)[left];
#line 551 "StatisticsModule.cs"
                                                double csharp2cuda_temp_262 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_260, csharp2cuda_temp_261), difference);
                                                (*(csharp2cuda_temp_259) = csharp2cuda_temp_262);
                                            }
                                        }
#line 547 "StatisticsModule.cs"
                                        int* csharp2cuda_temp_253 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_253));
                                    }
                                }
                            }
#line 545 "StatisticsModule.cs"
                            int* csharp2cuda_temp_251 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_251));
                        }
                    }
#line 554 "StatisticsModule.cs"
                    if (((count) == (0)))
                    {
#line 555 "StatisticsModule.cs"
#line 555 "StatisticsModule.cs"
                        int* csharp2cuda_temp_263 = &((output)->valid);
                        (*(csharp2cuda_temp_263) = 0);
                    }
                    else
                    {
#line 557 "StatisticsModule.cs"
#line 557 "StatisticsModule.cs"
                        double* csharp2cuda_temp_264 = &((output)->scalar_value);
#line 557 "StatisticsModule.cs"
                        double csharp2cuda_temp_265 = mathblocks_statistics_median(scratch, count);
                        (*(csharp2cuda_temp_264) = csharp2cuda_temp_265);
                    }
#line 558 "StatisticsModule.cs"
                    break;
                }
#line 560 "StatisticsModule.cs"
            case 25:
            case 26:
#line 562 "StatisticsModule.cs"
                {
#line 563 "StatisticsModule.cs"
#line 563 "StatisticsModule.cs"
                    int csharp2cuda_temp_266 = (first)->count;
#line 563 "StatisticsModule.cs"
                    bool csharp2cuda_temp_267;
#line 563 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_266) <= (0))))
                    {
#line 563 "StatisticsModule.cs"
                        int csharp2cuda_temp_268 = (first)->count;
#line 563 "StatisticsModule.cs"
                        int csharp2cuda_temp_269 = (second)->count;
#line 563 "StatisticsModule.cs"
                        csharp2cuda_temp_267 = ((csharp2cuda_temp_268) != (csharp2cuda_temp_269));
                    }
                    else
                    {
#line 563 "StatisticsModule.cs"
                        csharp2cuda_temp_267 = true;
                    }
                    if (csharp2cuda_temp_267)
#line 564 "StatisticsModule.cs"
                    {
#line 565 "StatisticsModule.cs"
#line 565 "StatisticsModule.cs"
                        int* csharp2cuda_temp_270 = &((output)->valid);
                        (*(csharp2cuda_temp_270) = 0);
#line 566 "StatisticsModule.cs"
                        break;
                    }
#line 568 "StatisticsModule.cs"
                    int csharp2cuda_temp_271 = (first)->count;
#line 568 "StatisticsModule.cs"
                    double weight_sum = mathblocks_compensated_sum(b, csharp2cuda_temp_271);
#line 569 "StatisticsModule.cs"
                    int csharp2cuda_temp_272 = (first)->count;
#line 569 "StatisticsModule.cs"
                    double mean = __ddiv_rn(mathblocks_compensated_product_sum(a, b, csharp2cuda_temp_272), weight_sum);
#line 570 "StatisticsModule.cs"
                    if (((opcode) == (25)))
#line 571 "StatisticsModule.cs"
                    {
#line 572 "StatisticsModule.cs"
#line 572 "StatisticsModule.cs"
                        double* csharp2cuda_temp_273 = &((output)->scalar_value);
                        (*(csharp2cuda_temp_273) = mean);
                    }
                    else
#line 575 "StatisticsModule.cs"
                    {
#line 576 "StatisticsModule.cs"
                        double numerator = 0.0;
#line 577 "StatisticsModule.cs"
                        {
#line 577 "StatisticsModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 577 "StatisticsModule.cs"
                                int csharp2cuda_temp_275 = (first)->count;
                                if (!(((index) < (csharp2cuda_temp_275))))
                                    break;
#line 578 "StatisticsModule.cs"
                                {
#line 579 "StatisticsModule.cs"
                                    double csharp2cuda_temp_276 = (a)[index];
#line 579 "StatisticsModule.cs"
                                    double difference = __dsub_rn(csharp2cuda_temp_276, mean);
#line 580 "StatisticsModule.cs"
#line 580 "StatisticsModule.cs"
                                    double* csharp2cuda_temp_277 = &(numerator);
#line 580 "StatisticsModule.cs"
                                    double csharp2cuda_temp_278 = *(csharp2cuda_temp_277);
#line 580 "StatisticsModule.cs"
                                    double csharp2cuda_temp_279 = (b)[index];
                                    (*(csharp2cuda_temp_277) = __dadd_rn(csharp2cuda_temp_278, __dmul_rn(__dmul_rn(csharp2cuda_temp_279, difference), difference)));
                                }
#line 577 "StatisticsModule.cs"
                                int* csharp2cuda_temp_274 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_274));
                            }
                        }
#line 582 "StatisticsModule.cs"
#line 582 "StatisticsModule.cs"
                        double* csharp2cuda_temp_280 = &((output)->scalar_value);
#line 582 "StatisticsModule.cs"
                        double csharp2cuda_temp_281 = __ddiv_rn(numerator, weight_sum);
                        (*(csharp2cuda_temp_280) = csharp2cuda_temp_281);
                    }
#line 584 "StatisticsModule.cs"
                    break;
                }
        }
#line 587 "StatisticsModule.cs"
#line 587 "StatisticsModule.cs"
        bool csharp2cuda_temp_282 = (output)->valid;
#line 587 "StatisticsModule.cs"
        bool csharp2cuda_temp_283;
#line 587 "StatisticsModule.cs"
        if (csharp2cuda_temp_282)
        {
#line 587 "StatisticsModule.cs"
            csharp2cuda_temp_283 = ((opcode) != (2));
        }
        else
        {
#line 587 "StatisticsModule.cs"
            csharp2cuda_temp_283 = false;
        }
#line 587 "StatisticsModule.cs"
        bool csharp2cuda_temp_284;
#line 587 "StatisticsModule.cs"
        if (csharp2cuda_temp_283)
        {
#line 587 "StatisticsModule.cs"
            csharp2cuda_temp_284 = ((opcode) != (4));
        }
        else
        {
#line 587 "StatisticsModule.cs"
            csharp2cuda_temp_284 = false;
        }
#line 587 "StatisticsModule.cs"
        bool csharp2cuda_temp_285;
#line 587 "StatisticsModule.cs"
        if (csharp2cuda_temp_284)
        {
#line 587 "StatisticsModule.cs"
            double csharp2cuda_temp_286 = (output)->scalar_value;
#line 587 "StatisticsModule.cs"
            csharp2cuda_temp_285 = (!(isfinite(csharp2cuda_temp_286)));
        }
        else
        {
#line 587 "StatisticsModule.cs"
            csharp2cuda_temp_285 = false;
        }
        if (csharp2cuda_temp_285)
        {
#line 588 "StatisticsModule.cs"
#line 588 "StatisticsModule.cs"
            int* csharp2cuda_temp_287 = &((output)->valid);
            (*(csharp2cuda_temp_287) = 0);
        }
    }
}

#line 46 "StatisticsModule.cs"
__device__ double mathblocks_statistics_mean(const double* values, int count)
#line 48 "StatisticsModule.cs"
{
#line 49 "StatisticsModule.cs"
    return __ddiv_rn(mathblocks_compensated_sum(values, count), ((double)(count)));
}

#line 142 "StatisticsModule.cs"
__device__ double mathblocks_statistics_median(double* values, int count)
#line 144 "StatisticsModule.cs"
{
#line 145 "StatisticsModule.cs"
    mathblocks_statistics_sort_in_place(values, count);
#line 146 "StatisticsModule.cs"
    return mathblocks_statistics_sorted_quantile(values, count, 0.5);
}

#line 81 "StatisticsModule.cs"
__device__ double mathblocks_statistics_pearson(
    const double* left,
    const double* right,
    int count)
#line 86 "StatisticsModule.cs"
{
#line 87 "StatisticsModule.cs"
#line 87 "StatisticsModule.cs"
    double csharp2cuda_temp_0 = mathblocks_statistics_population_covariance(left, right, count);
#line 88 "StatisticsModule.cs"
    double csharp2cuda_temp_1 = mathblocks_statistics_population_variance(left, count);
#line 89 "StatisticsModule.cs"
    double csharp2cuda_temp_2 = mathblocks_statistics_population_variance(right, count);
    return __ddiv_rn(csharp2cuda_temp_0, __dmul_rn(mathblocks_square_root(csharp2cuda_temp_1), mathblocks_square_root(csharp2cuda_temp_2)));
}

#line 67 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_covariance(
    const double* left,
    const double* right,
    int count)
#line 72 "StatisticsModule.cs"
{
#line 73 "StatisticsModule.cs"
    double left_mean = mathblocks_statistics_mean(left, count);
#line 74 "StatisticsModule.cs"
    double right_mean = mathblocks_statistics_mean(right, count);
#line 75 "StatisticsModule.cs"
    double sum = 0.0;
#line 76 "StatisticsModule.cs"
    {
#line 76 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 77 "StatisticsModule.cs"
#line 77 "StatisticsModule.cs"
            double* csharp2cuda_temp_1 = &(sum);
#line 77 "StatisticsModule.cs"
            double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
#line 77 "StatisticsModule.cs"
            double csharp2cuda_temp_3 = (left)[index];
#line 77 "StatisticsModule.cs"
            double csharp2cuda_temp_4 = (right)[index];
            (*(csharp2cuda_temp_1) = __dadd_rn(csharp2cuda_temp_2, __dmul_rn(__dsub_rn(csharp2cuda_temp_3, left_mean), __dsub_rn(csharp2cuda_temp_4, right_mean))));
#line 76 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 78 "StatisticsModule.cs"
    return __ddiv_rn(sum, ((double)(count)));
}

#line 52 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_variance(
    const double* values,
    int count)
#line 56 "StatisticsModule.cs"
{
#line 57 "StatisticsModule.cs"
    double mean = mathblocks_statistics_mean(values, count);
#line 58 "StatisticsModule.cs"
    double sum = 0.0;
#line 59 "StatisticsModule.cs"
    {
#line 59 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 60 "StatisticsModule.cs"
            {
#line 61 "StatisticsModule.cs"
                double csharp2cuda_temp_1 = (values)[index];
#line 61 "StatisticsModule.cs"
                double difference = __dsub_rn(csharp2cuda_temp_1, mean);
#line 62 "StatisticsModule.cs"
#line 62 "StatisticsModule.cs"
                double* csharp2cuda_temp_2 = &(sum);
#line 62 "StatisticsModule.cs"
                double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, __dmul_rn(difference, difference)));
            }
#line 59 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 64 "StatisticsModule.cs"
    return __ddiv_rn(sum, ((double)(count)));
}

#line 149 "StatisticsModule.cs"
__device__ void mathblocks_statistics_rank(
    const double* values,
    int count,
    double* result)
#line 154 "StatisticsModule.cs"
{
#line 155 "StatisticsModule.cs"
    {
#line 155 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 156 "StatisticsModule.cs"
            {
#line 157 "StatisticsModule.cs"
                int lower = 0;
#line 158 "StatisticsModule.cs"
                int equal = 0;
#line 159 "StatisticsModule.cs"
                {
#line 159 "StatisticsModule.cs"
                    int candidate = 0;
                    while (true)
                    {
                        if (!(((candidate) < (count))))
                            break;
#line 160 "StatisticsModule.cs"
                        {
#line 161 "StatisticsModule.cs"
#line 161 "StatisticsModule.cs"
                            double csharp2cuda_temp_2 = (values)[candidate];
#line 161 "StatisticsModule.cs"
                            double csharp2cuda_temp_3 = (values)[index];
                            if (((csharp2cuda_temp_2) < (csharp2cuda_temp_3)))
                            {
#line 162 "StatisticsModule.cs"
#line 162 "StatisticsModule.cs"
                                int* csharp2cuda_temp_4 = &(lower);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
                            }
                            else
                            {
#line 163 "StatisticsModule.cs"
#line 163 "StatisticsModule.cs"
                                double csharp2cuda_temp_5 = (values)[candidate];
#line 163 "StatisticsModule.cs"
                                double csharp2cuda_temp_6 = (values)[index];
                                if (((csharp2cuda_temp_5) == (csharp2cuda_temp_6)))
                                {
#line 164 "StatisticsModule.cs"
#line 164 "StatisticsModule.cs"
                                    int* csharp2cuda_temp_7 = &(equal);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_7));
                                }
                            }
                        }
#line 159 "StatisticsModule.cs"
                        int* csharp2cuda_temp_1 = &(candidate);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 166 "StatisticsModule.cs"
#line 166 "StatisticsModule.cs"
                double* csharp2cuda_temp_8 = &((result)[index]);
#line 166 "StatisticsModule.cs"
                double csharp2cuda_temp_9 = __ddiv_rn(__dadd_rn(((double)(equal)), 1.0), 2.0);
                (*(csharp2cuda_temp_8) = __dadd_rn(((double)(lower)), csharp2cuda_temp_9));
            }
#line 155 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 92 "StatisticsModule.cs"
__device__ void mathblocks_statistics_sort_copy(
    const double* values,
    int count,
    double* result)
#line 97 "StatisticsModule.cs"
{
#line 98 "StatisticsModule.cs"
    {
#line 98 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 99 "StatisticsModule.cs"
            {
#line 100 "StatisticsModule.cs"
                double value = (values)[index];
#line 101 "StatisticsModule.cs"
                int position = index;
#line 102 "StatisticsModule.cs"
                while (true)
                {
#line 102 "StatisticsModule.cs"
                    bool csharp2cuda_temp_1;
#line 102 "StatisticsModule.cs"
                    if (((position) > (0)))
                    {
#line 102 "StatisticsModule.cs"
                        double csharp2cuda_temp_2 = (result)[csharp2cuda_i32_sub(position, 1)];
#line 102 "StatisticsModule.cs"
                        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) > (value));
                    }
                    else
                    {
#line 102 "StatisticsModule.cs"
                        csharp2cuda_temp_1 = false;
                    }
                    if (!(csharp2cuda_temp_1))
                        break;
#line 103 "StatisticsModule.cs"
                    {
#line 104 "StatisticsModule.cs"
#line 104 "StatisticsModule.cs"
                        double* csharp2cuda_temp_3 = &((result)[position]);
#line 104 "StatisticsModule.cs"
                        double csharp2cuda_temp_4 = (result)[csharp2cuda_i32_sub(position, 1)];
                        (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 105 "StatisticsModule.cs"
#line 105 "StatisticsModule.cs"
                        int* csharp2cuda_temp_5 = &(position);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_5));
                    }
                }
#line 107 "StatisticsModule.cs"
#line 107 "StatisticsModule.cs"
                double* csharp2cuda_temp_6 = &((result)[position]);
                (*(csharp2cuda_temp_6) = value);
            }
#line 98 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 111 "StatisticsModule.cs"
__device__ void mathblocks_statistics_sort_in_place(double* values, int count)
#line 113 "StatisticsModule.cs"
{
#line 114 "StatisticsModule.cs"
    {
#line 114 "StatisticsModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 115 "StatisticsModule.cs"
            {
#line 116 "StatisticsModule.cs"
                double value = (values)[index];
#line 117 "StatisticsModule.cs"
                int position = index;
#line 118 "StatisticsModule.cs"
                while (true)
                {
#line 118 "StatisticsModule.cs"
                    bool csharp2cuda_temp_1;
#line 118 "StatisticsModule.cs"
                    if (((position) > (0)))
                    {
#line 118 "StatisticsModule.cs"
                        double csharp2cuda_temp_2 = (values)[csharp2cuda_i32_sub(position, 1)];
#line 118 "StatisticsModule.cs"
                        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) > (value));
                    }
                    else
                    {
#line 118 "StatisticsModule.cs"
                        csharp2cuda_temp_1 = false;
                    }
                    if (!(csharp2cuda_temp_1))
                        break;
#line 119 "StatisticsModule.cs"
                    {
#line 120 "StatisticsModule.cs"
#line 120 "StatisticsModule.cs"
                        double* csharp2cuda_temp_3 = &((values)[position]);
#line 120 "StatisticsModule.cs"
                        double csharp2cuda_temp_4 = (values)[csharp2cuda_i32_sub(position, 1)];
                        (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 121 "StatisticsModule.cs"
#line 121 "StatisticsModule.cs"
                        int* csharp2cuda_temp_5 = &(position);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_5));
                    }
                }
#line 123 "StatisticsModule.cs"
#line 123 "StatisticsModule.cs"
                double* csharp2cuda_temp_6 = &((values)[position]);
                (*(csharp2cuda_temp_6) = value);
            }
#line 114 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 127 "StatisticsModule.cs"
__device__ double mathblocks_statistics_sorted_quantile(
    const double* sorted,
    int count,
    double probability)
#line 132 "StatisticsModule.cs"
{
#line 133 "StatisticsModule.cs"
    if (((count) == (1)))
    {
#line 134 "StatisticsModule.cs"
        return (sorted)[0];
    }
#line 135 "StatisticsModule.cs"
    double position = __dmul_rn(probability, ((double)(csharp2cuda_i32_sub(count, 1))));
#line 136 "StatisticsModule.cs"
    int lower = csharp2cuda_f64_to_i32(floor(position));
#line 137 "StatisticsModule.cs"
    int upper = csharp2cuda_f64_to_i32(ceil(position));
#line 138 "StatisticsModule.cs"
    double weight = __dsub_rn(position, ((double)(lower)));
#line 139 "StatisticsModule.cs"
#line 139 "StatisticsModule.cs"
    double csharp2cuda_temp_0 = (sorted)[lower];
#line 139 "StatisticsModule.cs"
    double csharp2cuda_temp_1 = (sorted)[upper];
    return __dadd_rn(__dmul_rn(csharp2cuda_temp_0, __dsub_rn(1.0, weight)), __dmul_rn(csharp2cuda_temp_1, weight));
}