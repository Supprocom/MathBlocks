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

#line 72 "TransportModule.cs"
__device__ void mathblocks_transport_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 58 "TransportModule.cs"
__device__ double mathblocks_transport_mean_pairwise(
    const double* left,
    int left_count,
    const double* right,
    int right_count);

#line 72 "TransportModule.cs"
__device__ void mathblocks_transport_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 78 "TransportModule.cs"
{
#line 79 "TransportModule.cs"
    int thread = threadIdx.x;
#line 80 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 80 "TransportModule.cs"
    if (((input_count) > (0)))
    {
#line 80 "TransportModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 80 "TransportModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 80 "TransportModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 81 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 81 "TransportModule.cs"
    if (((input_count) > (1)))
    {
#line 81 "TransportModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 81 "TransportModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 81 "TransportModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 82 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 82 "TransportModule.cs"
    if (((input_count) > (2)))
    {
#line 82 "TransportModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 82 "TransportModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 82 "TransportModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 83 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_3;
#line 83 "TransportModule.cs"
    if (((input_count) > (3)))
    {
#line 83 "TransportModule.cs"
        csharp2cuda_temp_3 = (inputs)[3];
    }
    else
    {
#line 83 "TransportModule.cs"
        csharp2cuda_temp_3 = ((MathBlockSlot*)(nullptr));
    }
#line 83 "TransportModule.cs"
    const MathBlockSlot* fourth = csharp2cuda_temp_3;
#line 84 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_4;
#line 84 "TransportModule.cs"
    if (((input_count) > (4)))
    {
#line 84 "TransportModule.cs"
        csharp2cuda_temp_4 = (inputs)[4];
    }
    else
    {
#line 84 "TransportModule.cs"
        csharp2cuda_temp_4 = ((MathBlockSlot*)(nullptr));
    }
#line 84 "TransportModule.cs"
    const MathBlockSlot* fifth = csharp2cuda_temp_4;
#line 85 "TransportModule.cs"
    if (((thread) == (0)))
#line 86 "TransportModule.cs"
    {
#line 87 "TransportModule.cs"
#line 87 "TransportModule.cs"
        double* csharp2cuda_temp_5 = &((output)->scalar_value);
        (*(csharp2cuda_temp_5) = 0.0);
#line 88 "TransportModule.cs"
#line 88 "TransportModule.cs"
        int* csharp2cuda_temp_6 = &((output)->boolean_value);
        (*(csharp2cuda_temp_6) = 0);
#line 89 "TransportModule.cs"
#line 89 "TransportModule.cs"
        int* csharp2cuda_temp_7 = &((output)->rows);
        (*(csharp2cuda_temp_7) = 0);
#line 90 "TransportModule.cs"
#line 90 "TransportModule.cs"
        int* csharp2cuda_temp_8 = &((output)->columns);
        (*(csharp2cuda_temp_8) = 0);
#line 91 "TransportModule.cs"
#line 91 "TransportModule.cs"
        int* csharp2cuda_temp_9 = &((output)->count);
        (*(csharp2cuda_temp_9) = 0);
#line 92 "TransportModule.cs"
#line 92 "TransportModule.cs"
        int* csharp2cuda_temp_10 = &((output)->valid);
        (*(csharp2cuda_temp_10) = 1);
#line 93 "TransportModule.cs"
        {
#line 93 "TransportModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 94 "TransportModule.cs"
#line 94 "TransportModule.cs"
                MathBlockSlot* csharp2cuda_temp_12 = (inputs)[index];
#line 94 "TransportModule.cs"
                bool csharp2cuda_temp_13;
#line 94 "TransportModule.cs"
                if (!(((((void*)(csharp2cuda_temp_12))) == (((void*)(nullptr))))))
                {
#line 94 "TransportModule.cs"
                    MathBlockSlot* csharp2cuda_temp_14 = (inputs)[index];
#line 94 "TransportModule.cs"
                    bool csharp2cuda_temp_15 = (csharp2cuda_temp_14)->valid;
#line 94 "TransportModule.cs"
                    csharp2cuda_temp_13 = (!(csharp2cuda_temp_15));
                }
                else
                {
#line 94 "TransportModule.cs"
                    csharp2cuda_temp_13 = true;
                }
                if (csharp2cuda_temp_13)
                {
#line 94 "TransportModule.cs"
#line 94 "TransportModule.cs"
                    int* csharp2cuda_temp_16 = &((output)->valid);
                    (*(csharp2cuda_temp_16) = 0);
                }
#line 93 "TransportModule.cs"
                int* csharp2cuda_temp_11 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_11));
            }
        }
    }
#line 96 "TransportModule.cs"
    __syncthreads();
#line 97 "TransportModule.cs"
#line 97 "TransportModule.cs"
    bool csharp2cuda_temp_17 = (output)->valid;
    if ((!(csharp2cuda_temp_17)))
    {
#line 98 "TransportModule.cs"
        return;
    }
#line 100 "TransportModule.cs"
    double* csharp2cuda_temp_18;
#line 100 "TransportModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 100 "TransportModule.cs"
        csharp2cuda_temp_18 = ((double*)(nullptr));
    }
    else
    {
#line 100 "TransportModule.cs"
        unsigned long long csharp2cuda_temp_19 = (first)->data_pointer;
#line 100 "TransportModule.cs"
        csharp2cuda_temp_18 = ((double*)(csharp2cuda_temp_19));
    }
#line 100 "TransportModule.cs"
    const double* a = csharp2cuda_temp_18;
#line 101 "TransportModule.cs"
    double* csharp2cuda_temp_20;
#line 101 "TransportModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 101 "TransportModule.cs"
        csharp2cuda_temp_20 = ((double*)(nullptr));
    }
    else
    {
#line 101 "TransportModule.cs"
        unsigned long long csharp2cuda_temp_21 = (second)->data_pointer;
#line 101 "TransportModule.cs"
        csharp2cuda_temp_20 = ((double*)(csharp2cuda_temp_21));
    }
#line 101 "TransportModule.cs"
    const double* b = csharp2cuda_temp_20;
#line 102 "TransportModule.cs"
    double* csharp2cuda_temp_22;
#line 102 "TransportModule.cs"
    if (((((void*)(third))) == (((void*)(nullptr)))))
    {
#line 102 "TransportModule.cs"
        csharp2cuda_temp_22 = ((double*)(nullptr));
    }
    else
    {
#line 102 "TransportModule.cs"
        unsigned long long csharp2cuda_temp_23 = (third)->data_pointer;
#line 102 "TransportModule.cs"
        csharp2cuda_temp_22 = ((double*)(csharp2cuda_temp_23));
    }
#line 102 "TransportModule.cs"
    const double* c = csharp2cuda_temp_22;
#line 103 "TransportModule.cs"
    double* csharp2cuda_temp_24;
#line 103 "TransportModule.cs"
    if (((((void*)(fourth))) == (((void*)(nullptr)))))
    {
#line 103 "TransportModule.cs"
        csharp2cuda_temp_24 = ((double*)(nullptr));
    }
    else
    {
#line 103 "TransportModule.cs"
        unsigned long long csharp2cuda_temp_25 = (fourth)->data_pointer;
#line 103 "TransportModule.cs"
        csharp2cuda_temp_24 = ((double*)(csharp2cuda_temp_25));
    }
#line 103 "TransportModule.cs"
    const double* d = csharp2cuda_temp_24;
#line 104 "TransportModule.cs"
    unsigned long long csharp2cuda_temp_26 = (output)->data_pointer;
#line 104 "TransportModule.cs"
    double* result = ((double*)(csharp2cuda_temp_26));
#line 105 "TransportModule.cs"
    unsigned long long csharp2cuda_temp_27 = (output)->scratch_pointer;
#line 105 "TransportModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_27));
#line 107 "TransportModule.cs"
    if (((thread) == (0)))
#line 108 "TransportModule.cs"
    {
#line 109 "TransportModule.cs"
        switch (opcode)
        {
#line 111 "TransportModule.cs"
            case 0:
#line 112 "TransportModule.cs"
#line 112 "TransportModule.cs"
                int csharp2cuda_temp_28 = (first)->rows;
#line 112 "TransportModule.cs"
                int csharp2cuda_temp_29 = (first)->columns;
#line 112 "TransportModule.cs"
                bool csharp2cuda_temp_30;
#line 112 "TransportModule.cs"
                if (!(((csharp2cuda_temp_28) != (csharp2cuda_temp_29))))
                {
#line 112 "TransportModule.cs"
                    int csharp2cuda_temp_31 = (second)->count;
#line 112 "TransportModule.cs"
                    int csharp2cuda_temp_32 = (first)->rows;
#line 112 "TransportModule.cs"
                    csharp2cuda_temp_30 = ((csharp2cuda_temp_31) != (csharp2cuda_temp_32));
                }
                else
                {
#line 112 "TransportModule.cs"
                    csharp2cuda_temp_30 = true;
                }
                if (csharp2cuda_temp_30)
#line 113 "TransportModule.cs"
                {
#line 114 "TransportModule.cs"
#line 114 "TransportModule.cs"
                    int* csharp2cuda_temp_33 = &((output)->valid);
                    (*(csharp2cuda_temp_33) = 0);
#line 115 "TransportModule.cs"
                    break;
                }
#line 117 "TransportModule.cs"
                {
#line 118 "TransportModule.cs"
                    double total = 0.0;
#line 119 "TransportModule.cs"
                    {
#line 119 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 119 "TransportModule.cs"
                            int csharp2cuda_temp_35 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_35))))
                                break;
#line 120 "TransportModule.cs"
                            {
#line 121 "TransportModule.cs"
                                int column = 0;
#line 122 "TransportModule.cs"
#line 122 "TransportModule.cs"
                                double csharp2cuda_temp_36 = (b)[row];
#line 122 "TransportModule.cs"
                                int* csharp2cuda_temp_37 = &(column);
#line 122 "TransportModule.cs"
                                bool csharp2cuda_temp_38 = mathblocks_nonnegative_integer(csharp2cuda_temp_36, csharp2cuda_temp_37);
#line 122 "TransportModule.cs"
                                bool csharp2cuda_temp_39;
#line 122 "TransportModule.cs"
                                if (!((!(csharp2cuda_temp_38))))
                                {
#line 122 "TransportModule.cs"
                                    int csharp2cuda_temp_40 = (first)->columns;
#line 122 "TransportModule.cs"
                                    csharp2cuda_temp_39 = ((column) >= (csharp2cuda_temp_40));
                                }
                                else
                                {
#line 122 "TransportModule.cs"
                                    csharp2cuda_temp_39 = true;
                                }
                                if (csharp2cuda_temp_39)
#line 123 "TransportModule.cs"
                                {
#line 124 "TransportModule.cs"
#line 124 "TransportModule.cs"
                                    int* csharp2cuda_temp_41 = &((output)->valid);
                                    (*(csharp2cuda_temp_41) = 0);
#line 125 "TransportModule.cs"
                                    break;
                                }
#line 127 "TransportModule.cs"
#line 127 "TransportModule.cs"
                                double* csharp2cuda_temp_42 = &(total);
#line 127 "TransportModule.cs"
                                double csharp2cuda_temp_43 = *(csharp2cuda_temp_42);
#line 127 "TransportModule.cs"
                                int csharp2cuda_temp_44 = (first)->columns;
#line 127 "TransportModule.cs"
                                double csharp2cuda_temp_45 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_44), column)];
                                (*(csharp2cuda_temp_42) = __dadd_rn(csharp2cuda_temp_43, csharp2cuda_temp_45));
                            }
#line 119 "TransportModule.cs"
                            int* csharp2cuda_temp_34 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_34));
                        }
                    }
#line 129 "TransportModule.cs"
#line 129 "TransportModule.cs"
                    double* csharp2cuda_temp_46 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_46) = total);
#line 130 "TransportModule.cs"
                    break;
                }
#line 132 "TransportModule.cs"
            case 1:
#line 133 "TransportModule.cs"
#line 133 "TransportModule.cs"
                int csharp2cuda_temp_47 = (first)->rows;
#line 133 "TransportModule.cs"
                int csharp2cuda_temp_48 = (second)->rows;
#line 133 "TransportModule.cs"
                bool csharp2cuda_temp_49;
#line 133 "TransportModule.cs"
                if (!(((csharp2cuda_temp_47) != (csharp2cuda_temp_48))))
                {
#line 133 "TransportModule.cs"
                    int csharp2cuda_temp_50 = (first)->columns;
#line 133 "TransportModule.cs"
                    int csharp2cuda_temp_51 = (second)->columns;
#line 133 "TransportModule.cs"
                    csharp2cuda_temp_49 = ((csharp2cuda_temp_50) != (csharp2cuda_temp_51));
                }
                else
                {
#line 133 "TransportModule.cs"
                    csharp2cuda_temp_49 = true;
                }
                if (csharp2cuda_temp_49)
#line 134 "TransportModule.cs"
                {
#line 135 "TransportModule.cs"
#line 135 "TransportModule.cs"
                    int* csharp2cuda_temp_52 = &((output)->valid);
                    (*(csharp2cuda_temp_52) = 0);
#line 136 "TransportModule.cs"
                    break;
                }
#line 138 "TransportModule.cs"
                {
#line 139 "TransportModule.cs"
                    double total = 0.0;
#line 140 "TransportModule.cs"
                    {
#line 140 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 140 "TransportModule.cs"
                            int csharp2cuda_temp_54 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_54))))
                                break;
#line 141 "TransportModule.cs"
                            {
#line 141 "TransportModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 141 "TransportModule.cs"
                                    int csharp2cuda_temp_56 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_56))))
                                        break;
#line 142 "TransportModule.cs"
#line 142 "TransportModule.cs"
                                    double* csharp2cuda_temp_57 = &(total);
#line 142 "TransportModule.cs"
                                    double csharp2cuda_temp_58 = *(csharp2cuda_temp_57);
#line 142 "TransportModule.cs"
                                    int csharp2cuda_temp_59 = (first)->columns;
#line 142 "TransportModule.cs"
                                    double csharp2cuda_temp_60 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_59), column)];
#line 143 "TransportModule.cs"
                                    int csharp2cuda_temp_61 = (first)->columns;
#line 143 "TransportModule.cs"
                                    double csharp2cuda_temp_62 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_61), column)];
                                    (*(csharp2cuda_temp_57) = __dadd_rn(csharp2cuda_temp_58, __dmul_rn(csharp2cuda_temp_60, csharp2cuda_temp_62)));
#line 141 "TransportModule.cs"
                                    int* csharp2cuda_temp_55 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_55));
                                }
                            }
#line 140 "TransportModule.cs"
                            int* csharp2cuda_temp_53 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_53));
                        }
                    }
#line 144 "TransportModule.cs"
#line 144 "TransportModule.cs"
                    double* csharp2cuda_temp_63 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_63) = total);
#line 145 "TransportModule.cs"
                    break;
                }
#line 147 "TransportModule.cs"
            case 2:
#line 148 "TransportModule.cs"
#line 148 "TransportModule.cs"
                int csharp2cuda_temp_64 = (first)->count;
#line 148 "TransportModule.cs"
                bool csharp2cuda_temp_65;
#line 148 "TransportModule.cs"
                if (!(((csharp2cuda_temp_64) <= (0))))
                {
#line 148 "TransportModule.cs"
                    int csharp2cuda_temp_66 = (second)->count;
#line 148 "TransportModule.cs"
                    csharp2cuda_temp_65 = ((csharp2cuda_temp_66) <= (0));
                }
                else
                {
#line 148 "TransportModule.cs"
                    csharp2cuda_temp_65 = true;
                }
                if (csharp2cuda_temp_65)
#line 149 "TransportModule.cs"
                {
#line 150 "TransportModule.cs"
#line 150 "TransportModule.cs"
                    int* csharp2cuda_temp_67 = &((output)->valid);
                    (*(csharp2cuda_temp_67) = 0);
#line 151 "TransportModule.cs"
                    break;
                }
#line 153 "TransportModule.cs"
                {
#line 155 "TransportModule.cs"
                    int csharp2cuda_temp_68 = (first)->count;
#line 155 "TransportModule.cs"
                    int csharp2cuda_temp_69 = (second)->count;
#line 154 "TransportModule.cs"
                    double cross = mathblocks_transport_mean_pairwise(a, csharp2cuda_temp_68, b, csharp2cuda_temp_69);
#line 157 "TransportModule.cs"
                    int csharp2cuda_temp_70 = (first)->count;
#line 157 "TransportModule.cs"
                    int csharp2cuda_temp_71 = (first)->count;
#line 156 "TransportModule.cs"
                    double left_within = mathblocks_transport_mean_pairwise(a, csharp2cuda_temp_70, a, csharp2cuda_temp_71);
#line 159 "TransportModule.cs"
                    int csharp2cuda_temp_72 = (second)->count;
#line 159 "TransportModule.cs"
                    int csharp2cuda_temp_73 = (second)->count;
#line 158 "TransportModule.cs"
                    double right_within = mathblocks_transport_mean_pairwise(b, csharp2cuda_temp_72, b, csharp2cuda_temp_73);
#line 160 "TransportModule.cs"
                    double squared = __dsub_rn(__dsub_rn(__dmul_rn(2.0, cross), left_within), right_within);
#line 161 "TransportModule.cs"
#line 161 "TransportModule.cs"
                    double* csharp2cuda_temp_74 = &((output)->scalar_value);
#line 161 "TransportModule.cs"
                    double csharp2cuda_temp_75;
#line 161 "TransportModule.cs"
                    if (((squared) > (0.0)))
                    {
#line 161 "TransportModule.cs"
                        csharp2cuda_temp_75 = squared;
                    }
                    else
                    {
#line 161 "TransportModule.cs"
                        csharp2cuda_temp_75 = 0.0;
                    }
                    (*(csharp2cuda_temp_74) = mathblocks_square_root(csharp2cuda_temp_75));
#line 162 "TransportModule.cs"
                    break;
                }
#line 164 "TransportModule.cs"
            case 3:
#line 165 "TransportModule.cs"
#line 165 "TransportModule.cs"
                int csharp2cuda_temp_76 = (first)->rows;
#line 165 "TransportModule.cs"
                int csharp2cuda_temp_77 = (first)->columns;
#line 165 "TransportModule.cs"
                bool csharp2cuda_temp_78;
#line 165 "TransportModule.cs"
                if (!(((csharp2cuda_temp_76) != (csharp2cuda_temp_77))))
                {
#line 165 "TransportModule.cs"
                    int csharp2cuda_temp_79 = (first)->rows;
#line 165 "TransportModule.cs"
                    csharp2cuda_temp_78 = ((csharp2cuda_temp_79) > (20));
                }
                else
                {
#line 165 "TransportModule.cs"
                    csharp2cuda_temp_78 = true;
                }
#line 165 "TransportModule.cs"
                bool csharp2cuda_temp_80;
#line 165 "TransportModule.cs"
                if (!(csharp2cuda_temp_78))
                {
#line 165 "TransportModule.cs"
                    csharp2cuda_temp_80 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 165 "TransportModule.cs"
                    csharp2cuda_temp_80 = true;
                }
                if (csharp2cuda_temp_80)
#line 166 "TransportModule.cs"
                {
#line 167 "TransportModule.cs"
#line 167 "TransportModule.cs"
                    int* csharp2cuda_temp_81 = &((output)->valid);
                    (*(csharp2cuda_temp_81) = 0);
#line 168 "TransportModule.cs"
                    break;
                }
#line 170 "TransportModule.cs"
                {
#line 171 "TransportModule.cs"
                    int size = (first)->rows;
#line 172 "TransportModule.cs"
                    int state_count = csharp2cuda_i32_shl(1, size);
#line 173 "TransportModule.cs"
                    mathblocks_sequence_set_vector_shape(output, size);
#line 174 "TransportModule.cs"
                    double* values = scratch;
#line 175 "TransportModule.cs"
                    int* previous_mask = ((int*)(csharp2cuda_pointer_add(values, state_count)));
#line 176 "TransportModule.cs"
                    int* chosen_column = csharp2cuda_pointer_add(previous_mask, state_count);
#line 177 "TransportModule.cs"
                    {
#line 177 "TransportModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (state_count))))
                                break;
#line 178 "TransportModule.cs"
                            {
#line 179 "TransportModule.cs"
#line 179 "TransportModule.cs"
                                double* csharp2cuda_temp_83 = &((values)[index]);
                                (*(csharp2cuda_temp_83) = mathblocks_positive_infinity());
#line 180 "TransportModule.cs"
#line 180 "TransportModule.cs"
                                int* csharp2cuda_temp_84 = &((previous_mask)[index]);
                                (*(csharp2cuda_temp_84) = 0);
#line 181 "TransportModule.cs"
#line 181 "TransportModule.cs"
                                int* csharp2cuda_temp_85 = &((chosen_column)[index]);
                                (*(csharp2cuda_temp_85) = 0);
                            }
#line 177 "TransportModule.cs"
                            int* csharp2cuda_temp_82 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_82));
                        }
                    }
#line 183 "TransportModule.cs"
#line 183 "TransportModule.cs"
                    double* csharp2cuda_temp_86 = &((values)[0]);
                    (*(csharp2cuda_temp_86) = 0.0);
#line 184 "TransportModule.cs"
                    {
#line 184 "TransportModule.cs"
                        int mask = 0;
                        while (true)
                        {
                            if (!(((mask) < (state_count))))
                                break;
#line 185 "TransportModule.cs"
                            {
#line 186 "TransportModule.cs"
                                int row = mathblocks_advanced_popcount(mask);
#line 187 "TransportModule.cs"
#line 187 "TransportModule.cs"
                                bool csharp2cuda_temp_88;
#line 187 "TransportModule.cs"
                                if (!(((row) >= (size))))
                                {
#line 187 "TransportModule.cs"
                                    double csharp2cuda_temp_89 = (values)[mask];
#line 187 "TransportModule.cs"
                                    csharp2cuda_temp_88 = (!(isfinite(csharp2cuda_temp_89)));
                                }
                                else
                                {
#line 187 "TransportModule.cs"
                                    csharp2cuda_temp_88 = true;
                                }
                                if (csharp2cuda_temp_88)
                                {
#line 188 "TransportModule.cs"
                                    goto csharp2cuda_for_continue_6;
                                }
#line 189 "TransportModule.cs"
                                {
#line 189 "TransportModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
                                        if (!(((column) < (size))))
                                            break;
#line 190 "TransportModule.cs"
                                        {
#line 191 "TransportModule.cs"
                                            if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, column))) != (0)))
                                            {
#line 192 "TransportModule.cs"
                                                goto csharp2cuda_for_continue_5;
                                            }
#line 193 "TransportModule.cs"
                                            int next = csharp2cuda_i32_or(mask, csharp2cuda_i32_shl(1, column));
#line 194 "TransportModule.cs"
                                            double csharp2cuda_temp_91 = (values)[mask];
#line 194 "TransportModule.cs"
                                            double csharp2cuda_temp_92 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
#line 194 "TransportModule.cs"
                                            double candidate = __dadd_rn(csharp2cuda_temp_91, csharp2cuda_temp_92);
#line 195 "TransportModule.cs"
#line 195 "TransportModule.cs"
                                            double csharp2cuda_temp_93 = (values)[next];
                                            if (((candidate) >= (csharp2cuda_temp_93)))
                                            {
#line 196 "TransportModule.cs"
                                                goto csharp2cuda_for_continue_5;
                                            }
#line 197 "TransportModule.cs"
#line 197 "TransportModule.cs"
                                            double* csharp2cuda_temp_94 = &((values)[next]);
                                            (*(csharp2cuda_temp_94) = candidate);
#line 198 "TransportModule.cs"
#line 198 "TransportModule.cs"
                                            int* csharp2cuda_temp_95 = &((previous_mask)[next]);
                                            (*(csharp2cuda_temp_95) = mask);
#line 199 "TransportModule.cs"
#line 199 "TransportModule.cs"
                                            int* csharp2cuda_temp_96 = &((chosen_column)[next]);
                                            (*(csharp2cuda_temp_96) = column);
                                        }
                                        csharp2cuda_for_continue_5:
#line 189 "TransportModule.cs"
                                        int* csharp2cuda_temp_90 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_90));
                                    }
                                }
                            }
                            csharp2cuda_for_continue_6:
#line 184 "TransportModule.cs"
                            int* csharp2cuda_temp_87 = &(mask);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_87));
                        }
                    }
#line 202 "TransportModule.cs"
                    int current = csharp2cuda_i32_sub(state_count, 1);
#line 203 "TransportModule.cs"
                    {
#line 203 "TransportModule.cs"
                        int row = csharp2cuda_i32_sub(size, 1);
                        while (true)
                        {
                            if (!(((row) >= (0))))
                                break;
#line 204 "TransportModule.cs"
                            {
#line 205 "TransportModule.cs"
#line 205 "TransportModule.cs"
                                double* csharp2cuda_temp_98 = &((result)[row]);
#line 205 "TransportModule.cs"
                                int csharp2cuda_temp_99 = (chosen_column)[current];
                                (*(csharp2cuda_temp_98) = ((double)(csharp2cuda_temp_99)));
#line 206 "TransportModule.cs"
#line 206 "TransportModule.cs"
                                int* csharp2cuda_temp_100 = &(current);
#line 206 "TransportModule.cs"
                                int csharp2cuda_temp_101 = (previous_mask)[current];
                                (*(csharp2cuda_temp_100) = csharp2cuda_temp_101);
                            }
#line 203 "TransportModule.cs"
                            int* csharp2cuda_temp_97 = &(row);
                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_97));
                        }
                    }
#line 208 "TransportModule.cs"
                    break;
                }
#line 210 "TransportModule.cs"
            case 4:
#line 211 "TransportModule.cs"
#line 211 "TransportModule.cs"
                int csharp2cuda_temp_102 = (first)->count;
#line 211 "TransportModule.cs"
                int csharp2cuda_temp_103 = (second)->count;
                mathblocks_sequence_set_matrix_shape(output, csharp2cuda_temp_102, csharp2cuda_temp_103);
#line 212 "TransportModule.cs"
#line 212 "TransportModule.cs"
                int csharp2cuda_temp_104 = (first)->count;
#line 212 "TransportModule.cs"
                bool csharp2cuda_temp_105;
#line 212 "TransportModule.cs"
                if (!((!(mathblocks_advanced_distribution(a, csharp2cuda_temp_104)))))
                {
#line 213 "TransportModule.cs"
                    int csharp2cuda_temp_106 = (second)->count;
#line 212 "TransportModule.cs"
                    csharp2cuda_temp_105 = (!(mathblocks_advanced_distribution(b, csharp2cuda_temp_106)));
                }
                else
                {
#line 212 "TransportModule.cs"
                    csharp2cuda_temp_105 = true;
                }
                if (csharp2cuda_temp_105)
#line 214 "TransportModule.cs"
                {
#line 215 "TransportModule.cs"
#line 215 "TransportModule.cs"
                    int* csharp2cuda_temp_107 = &((output)->valid);
                    (*(csharp2cuda_temp_107) = 0);
#line 216 "TransportModule.cs"
                    break;
                }
#line 218 "TransportModule.cs"
                {
#line 218 "TransportModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 218 "TransportModule.cs"
                        int csharp2cuda_temp_109 = (output)->count;
                        if (!(((index) < (csharp2cuda_temp_109))))
                            break;
#line 219 "TransportModule.cs"
#line 219 "TransportModule.cs"
                        double* csharp2cuda_temp_110 = &((result)[index]);
                        (*(csharp2cuda_temp_110) = 0.0);
#line 218 "TransportModule.cs"
                        int* csharp2cuda_temp_108 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_108));
                    }
                }
#line 220 "TransportModule.cs"
                {
#line 221 "TransportModule.cs"
                    int left_index = 0;
#line 222 "TransportModule.cs"
                    int right_index = 0;
#line 223 "TransportModule.cs"
                    double left_remaining = (a)[0];
#line 224 "TransportModule.cs"
                    double right_remaining = (b)[0];
#line 225 "TransportModule.cs"
                    while (true)
                    {
#line 225 "TransportModule.cs"
                        int csharp2cuda_temp_111 = (first)->count;
#line 225 "TransportModule.cs"
                        bool csharp2cuda_temp_112;
#line 225 "TransportModule.cs"
                        if (((left_index) < (csharp2cuda_temp_111)))
                        {
#line 225 "TransportModule.cs"
                            int csharp2cuda_temp_113 = (second)->count;
#line 225 "TransportModule.cs"
                            csharp2cuda_temp_112 = ((right_index) < (csharp2cuda_temp_113));
                        }
                        else
                        {
#line 225 "TransportModule.cs"
                            csharp2cuda_temp_112 = false;
                        }
                        if (!(csharp2cuda_temp_112))
                            break;
#line 226 "TransportModule.cs"
                        {
#line 227 "TransportModule.cs"
                            double csharp2cuda_temp_114;
#line 227 "TransportModule.cs"
                            if (((left_remaining) < (right_remaining)))
                            {
#line 227 "TransportModule.cs"
                                csharp2cuda_temp_114 = left_remaining;
                            }
                            else
                            {
#line 227 "TransportModule.cs"
                                csharp2cuda_temp_114 = right_remaining;
                            }
#line 227 "TransportModule.cs"
                            double amount = csharp2cuda_temp_114;
#line 230 "TransportModule.cs"
#line 230 "TransportModule.cs"
                            int csharp2cuda_temp_115 = (second)->count;
#line 230 "TransportModule.cs"
                            double* csharp2cuda_temp_116 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left_index, csharp2cuda_temp_115), right_index)]);
#line 230 "TransportModule.cs"
                            double csharp2cuda_temp_117 = *(csharp2cuda_temp_116);
                            (*(csharp2cuda_temp_116) = __dadd_rn(csharp2cuda_temp_117, amount));
#line 231 "TransportModule.cs"
#line 231 "TransportModule.cs"
                            double* csharp2cuda_temp_118 = &(left_remaining);
#line 231 "TransportModule.cs"
                            double csharp2cuda_temp_119 = *(csharp2cuda_temp_118);
                            (*(csharp2cuda_temp_118) = __dsub_rn(csharp2cuda_temp_119, amount));
#line 232 "TransportModule.cs"
#line 232 "TransportModule.cs"
                            double* csharp2cuda_temp_120 = &(right_remaining);
#line 232 "TransportModule.cs"
                            double csharp2cuda_temp_121 = *(csharp2cuda_temp_120);
                            (*(csharp2cuda_temp_120) = __dsub_rn(csharp2cuda_temp_121, amount));
#line 233 "TransportModule.cs"
#line 233 "TransportModule.cs"
                            bool csharp2cuda_temp_122;
#line 233 "TransportModule.cs"
                            if (((left_remaining) == (0.0)))
                            {
#line 233 "TransportModule.cs"
                                int* csharp2cuda_temp_123 = &(left_index);
#line 233 "TransportModule.cs"
                                int csharp2cuda_temp_124 = csharp2cuda_i32_pre_increment(*(csharp2cuda_temp_123));
#line 233 "TransportModule.cs"
                                int csharp2cuda_temp_125 = (first)->count;
#line 233 "TransportModule.cs"
                                csharp2cuda_temp_122 = ((csharp2cuda_temp_124) < (csharp2cuda_temp_125));
                            }
                            else
                            {
#line 233 "TransportModule.cs"
                                csharp2cuda_temp_122 = false;
                            }
                            if (csharp2cuda_temp_122)
                            {
#line 234 "TransportModule.cs"
#line 234 "TransportModule.cs"
                                double* csharp2cuda_temp_126 = &(left_remaining);
#line 234 "TransportModule.cs"
                                double csharp2cuda_temp_127 = (a)[left_index];
                                (*(csharp2cuda_temp_126) = csharp2cuda_temp_127);
                            }
#line 235 "TransportModule.cs"
#line 235 "TransportModule.cs"
                            bool csharp2cuda_temp_128;
#line 235 "TransportModule.cs"
                            if (((right_remaining) == (0.0)))
                            {
#line 235 "TransportModule.cs"
                                int* csharp2cuda_temp_129 = &(right_index);
#line 235 "TransportModule.cs"
                                int csharp2cuda_temp_130 = csharp2cuda_i32_pre_increment(*(csharp2cuda_temp_129));
#line 235 "TransportModule.cs"
                                int csharp2cuda_temp_131 = (second)->count;
#line 235 "TransportModule.cs"
                                csharp2cuda_temp_128 = ((csharp2cuda_temp_130) < (csharp2cuda_temp_131));
                            }
                            else
                            {
#line 235 "TransportModule.cs"
                                csharp2cuda_temp_128 = false;
                            }
                            if (csharp2cuda_temp_128)
                            {
#line 236 "TransportModule.cs"
#line 236 "TransportModule.cs"
                                double* csharp2cuda_temp_132 = &(right_remaining);
#line 236 "TransportModule.cs"
                                double csharp2cuda_temp_133 = (b)[right_index];
                                (*(csharp2cuda_temp_132) = csharp2cuda_temp_133);
                            }
                        }
                    }
#line 238 "TransportModule.cs"
                    break;
                }
#line 240 "TransportModule.cs"
            case 5:
#line 241 "TransportModule.cs"
#line 241 "TransportModule.cs"
                int csharp2cuda_temp_134 = (first)->count;
#line 241 "TransportModule.cs"
                int csharp2cuda_temp_135 = (second)->count;
#line 241 "TransportModule.cs"
                bool csharp2cuda_temp_136;
#line 241 "TransportModule.cs"
                if (!(((csharp2cuda_temp_134) != (csharp2cuda_temp_135))))
                {
#line 242 "TransportModule.cs"
                    int csharp2cuda_temp_137 = (first)->count;
#line 241 "TransportModule.cs"
                    csharp2cuda_temp_136 = (!(mathblocks_advanced_distribution(a, csharp2cuda_temp_137)));
                }
                else
                {
#line 241 "TransportModule.cs"
                    csharp2cuda_temp_136 = true;
                }
#line 241 "TransportModule.cs"
                bool csharp2cuda_temp_138;
#line 241 "TransportModule.cs"
                if (!(csharp2cuda_temp_136))
                {
#line 243 "TransportModule.cs"
                    int csharp2cuda_temp_139 = (second)->count;
#line 241 "TransportModule.cs"
                    csharp2cuda_temp_138 = (!(mathblocks_advanced_distribution(b, csharp2cuda_temp_139)));
                }
                else
                {
#line 241 "TransportModule.cs"
                    csharp2cuda_temp_138 = true;
                }
                if (csharp2cuda_temp_138)
#line 244 "TransportModule.cs"
                {
#line 245 "TransportModule.cs"
#line 245 "TransportModule.cs"
                    int* csharp2cuda_temp_140 = &((output)->valid);
                    (*(csharp2cuda_temp_140) = 0);
#line 246 "TransportModule.cs"
                    break;
                }
#line 248 "TransportModule.cs"
                {
#line 249 "TransportModule.cs"
                    double cumulative = 0.0;
#line 250 "TransportModule.cs"
                    double total = 0.0;
#line 251 "TransportModule.cs"
                    {
#line 251 "TransportModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 251 "TransportModule.cs"
                            int csharp2cuda_temp_142 = (first)->count;
                            if (!(((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_142, 1)))))
                                break;
#line 252 "TransportModule.cs"
                            {
#line 253 "TransportModule.cs"
#line 253 "TransportModule.cs"
                                double* csharp2cuda_temp_143 = &(cumulative);
#line 253 "TransportModule.cs"
                                double csharp2cuda_temp_144 = *(csharp2cuda_temp_143);
#line 253 "TransportModule.cs"
                                double csharp2cuda_temp_145 = (a)[index];
#line 253 "TransportModule.cs"
                                double csharp2cuda_temp_146 = (b)[index];
                                (*(csharp2cuda_temp_143) = __dadd_rn(csharp2cuda_temp_144, __dsub_rn(csharp2cuda_temp_145, csharp2cuda_temp_146)));
#line 254 "TransportModule.cs"
#line 254 "TransportModule.cs"
                                double* csharp2cuda_temp_147 = &(total);
#line 254 "TransportModule.cs"
                                double csharp2cuda_temp_148 = *(csharp2cuda_temp_147);
                                (*(csharp2cuda_temp_147) = __dadd_rn(csharp2cuda_temp_148, fabs(cumulative)));
                            }
#line 251 "TransportModule.cs"
                            int* csharp2cuda_temp_141 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_141));
                        }
                    }
#line 256 "TransportModule.cs"
#line 256 "TransportModule.cs"
                    double* csharp2cuda_temp_149 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_149) = total);
#line 257 "TransportModule.cs"
                    break;
                }
#line 259 "TransportModule.cs"
            case 6:
#line 260 "TransportModule.cs"
#line 260 "TransportModule.cs"
                int csharp2cuda_temp_150 = (first)->rows;
#line 260 "TransportModule.cs"
                int csharp2cuda_temp_151 = (first)->columns;
                mathblocks_sequence_set_matrix_shape(output, csharp2cuda_temp_150, csharp2cuda_temp_151);
#line 261 "TransportModule.cs"
#line 261 "TransportModule.cs"
                int csharp2cuda_temp_152 = (first)->rows;
#line 261 "TransportModule.cs"
                int csharp2cuda_temp_153 = (second)->count;
#line 261 "TransportModule.cs"
                bool csharp2cuda_temp_154;
#line 261 "TransportModule.cs"
                if (!(((csharp2cuda_temp_152) != (csharp2cuda_temp_153))))
                {
#line 261 "TransportModule.cs"
                    int csharp2cuda_temp_155 = (first)->columns;
#line 261 "TransportModule.cs"
                    int csharp2cuda_temp_156 = (third)->count;
#line 261 "TransportModule.cs"
                    csharp2cuda_temp_154 = ((csharp2cuda_temp_155) != (csharp2cuda_temp_156));
                }
                else
                {
#line 261 "TransportModule.cs"
                    csharp2cuda_temp_154 = true;
                }
#line 261 "TransportModule.cs"
                bool csharp2cuda_temp_157;
#line 261 "TransportModule.cs"
                if (!(csharp2cuda_temp_154))
                {
#line 262 "TransportModule.cs"
                    int csharp2cuda_temp_158 = (second)->count;
#line 261 "TransportModule.cs"
                    csharp2cuda_temp_157 = (!(mathblocks_advanced_distribution(b, csharp2cuda_temp_158)));
                }
                else
                {
#line 261 "TransportModule.cs"
                    csharp2cuda_temp_157 = true;
                }
#line 261 "TransportModule.cs"
                bool csharp2cuda_temp_159;
#line 261 "TransportModule.cs"
                if (!(csharp2cuda_temp_157))
                {
#line 263 "TransportModule.cs"
                    int csharp2cuda_temp_160 = (third)->count;
#line 261 "TransportModule.cs"
                    csharp2cuda_temp_159 = (!(mathblocks_advanced_distribution(c, csharp2cuda_temp_160)));
                }
                else
                {
#line 261 "TransportModule.cs"
                    csharp2cuda_temp_159 = true;
                }
#line 261 "TransportModule.cs"
                bool csharp2cuda_temp_161;
#line 261 "TransportModule.cs"
                if (!(csharp2cuda_temp_159))
                {
#line 264 "TransportModule.cs"
                    double csharp2cuda_temp_162 = (fourth)->scalar_value;
#line 261 "TransportModule.cs"
                    csharp2cuda_temp_161 = ((csharp2cuda_temp_162) <= (0.0));
                }
                else
                {
#line 261 "TransportModule.cs"
                    csharp2cuda_temp_161 = true;
                }
#line 261 "TransportModule.cs"
                bool csharp2cuda_temp_163;
#line 261 "TransportModule.cs"
                if (!(csharp2cuda_temp_161))
                {
#line 261 "TransportModule.cs"
                    csharp2cuda_temp_163 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 261 "TransportModule.cs"
                    csharp2cuda_temp_163 = true;
                }
                if (csharp2cuda_temp_163)
#line 265 "TransportModule.cs"
                {
#line 266 "TransportModule.cs"
#line 266 "TransportModule.cs"
                    int* csharp2cuda_temp_164 = &((output)->valid);
                    (*(csharp2cuda_temp_164) = 0);
#line 267 "TransportModule.cs"
                    break;
                }
#line 269 "TransportModule.cs"
                {
#line 270 "TransportModule.cs"
                    int iterations = 0;
#line 271 "TransportModule.cs"
#line 271 "TransportModule.cs"
                    double csharp2cuda_temp_165 = (fifth)->scalar_value;
#line 271 "TransportModule.cs"
                    int* csharp2cuda_temp_166 = &(iterations);
#line 271 "TransportModule.cs"
                    bool csharp2cuda_temp_167 = mathblocks_sequence_positive_integer(csharp2cuda_temp_165, csharp2cuda_temp_166);
#line 271 "TransportModule.cs"
                    bool csharp2cuda_temp_168;
#line 271 "TransportModule.cs"
                    if (!((!(csharp2cuda_temp_167))))
                    {
#line 271 "TransportModule.cs"
                        csharp2cuda_temp_168 = ((iterations) > (10000));
                    }
                    else
                    {
#line 271 "TransportModule.cs"
                        csharp2cuda_temp_168 = true;
                    }
                    if (csharp2cuda_temp_168)
#line 272 "TransportModule.cs"
                    {
#line 273 "TransportModule.cs"
#line 273 "TransportModule.cs"
                        int* csharp2cuda_temp_169 = &((output)->valid);
                        (*(csharp2cuda_temp_169) = 0);
#line 274 "TransportModule.cs"
                        break;
                    }
#line 276 "TransportModule.cs"
                    double* kernel = scratch;
#line 277 "TransportModule.cs"
                    int csharp2cuda_temp_170 = (first)->count;
#line 277 "TransportModule.cs"
                    double* left_scale = csharp2cuda_pointer_add(kernel, csharp2cuda_temp_170);
#line 278 "TransportModule.cs"
                    int csharp2cuda_temp_171 = (first)->rows;
#line 278 "TransportModule.cs"
                    double* right_scale = csharp2cuda_pointer_add(left_scale, csharp2cuda_temp_171);
#line 279 "TransportModule.cs"
                    {
#line 279 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 279 "TransportModule.cs"
                            int csharp2cuda_temp_173 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_173))))
                                break;
#line 280 "TransportModule.cs"
                            {
#line 280 "TransportModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 280 "TransportModule.cs"
                                    int csharp2cuda_temp_175 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_175))))
                                        break;
#line 281 "TransportModule.cs"
#line 281 "TransportModule.cs"
                                    int csharp2cuda_temp_176 = (first)->columns;
#line 281 "TransportModule.cs"
                                    double* csharp2cuda_temp_177 = &((kernel)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_176), column)]);
#line 282 "TransportModule.cs"
                                    int csharp2cuda_temp_178 = (first)->columns;
#line 282 "TransportModule.cs"
                                    double csharp2cuda_temp_179 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_178), column)];
#line 283 "TransportModule.cs"
                                    double csharp2cuda_temp_180 = (fourth)->scalar_value;
#line 282 "TransportModule.cs"
                                    double csharp2cuda_temp_181 = __ddiv_rn((-(csharp2cuda_temp_179)), csharp2cuda_temp_180);
                                    (*(csharp2cuda_temp_177) = mathblocks_exponential(csharp2cuda_temp_181));
#line 280 "TransportModule.cs"
                                    int* csharp2cuda_temp_174 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_174));
                                }
                            }
#line 279 "TransportModule.cs"
                            int* csharp2cuda_temp_172 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_172));
                        }
                    }
#line 284 "TransportModule.cs"
                    {
#line 284 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 284 "TransportModule.cs"
                            int csharp2cuda_temp_183 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_183))))
                                break;
#line 285 "TransportModule.cs"
#line 285 "TransportModule.cs"
                            double* csharp2cuda_temp_184 = &((left_scale)[row]);
                            (*(csharp2cuda_temp_184) = 1.0);
#line 284 "TransportModule.cs"
                            int* csharp2cuda_temp_182 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_182));
                        }
                    }
#line 286 "TransportModule.cs"
                    {
#line 286 "TransportModule.cs"
                        int column = 0;
                        while (true)
                        {
#line 286 "TransportModule.cs"
                            int csharp2cuda_temp_186 = (first)->columns;
                            if (!(((column) < (csharp2cuda_temp_186))))
                                break;
#line 287 "TransportModule.cs"
#line 287 "TransportModule.cs"
                            double* csharp2cuda_temp_187 = &((right_scale)[column]);
                            (*(csharp2cuda_temp_187) = 1.0);
#line 286 "TransportModule.cs"
                            int* csharp2cuda_temp_185 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_185));
                        }
                    }
#line 288 "TransportModule.cs"
                    {
#line 288 "TransportModule.cs"
                        int iteration = 0;
                        while (true)
                        {
                            if (!(((iteration) < (iterations))))
                                break;
#line 289 "TransportModule.cs"
                            {
#line 290 "TransportModule.cs"
                                {
#line 290 "TransportModule.cs"
                                    int row = 0;
                                    while (true)
                                    {
#line 290 "TransportModule.cs"
                                        int csharp2cuda_temp_190 = (first)->rows;
                                        if (!(((row) < (csharp2cuda_temp_190))))
                                            break;
#line 291 "TransportModule.cs"
                                        {
#line 292 "TransportModule.cs"
                                            double sum = 0.0;
#line 293 "TransportModule.cs"
                                            {
#line 293 "TransportModule.cs"
                                                int column = 0;
                                                while (true)
                                                {
#line 293 "TransportModule.cs"
                                                    int csharp2cuda_temp_192 = (first)->columns;
                                                    if (!(((column) < (csharp2cuda_temp_192))))
                                                        break;
#line 294 "TransportModule.cs"
#line 294 "TransportModule.cs"
                                                    double* csharp2cuda_temp_193 = &(sum);
#line 294 "TransportModule.cs"
                                                    double csharp2cuda_temp_194 = *(csharp2cuda_temp_193);
#line 294 "TransportModule.cs"
                                                    int csharp2cuda_temp_195 = (first)->columns;
#line 294 "TransportModule.cs"
                                                    double csharp2cuda_temp_196 = (kernel)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_195), column)];
#line 294 "TransportModule.cs"
                                                    double csharp2cuda_temp_197 = (right_scale)[column];
                                                    (*(csharp2cuda_temp_193) = __dadd_rn(csharp2cuda_temp_194, __dmul_rn(csharp2cuda_temp_196, csharp2cuda_temp_197)));
#line 293 "TransportModule.cs"
                                                    int* csharp2cuda_temp_191 = &(column);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_191));
                                                }
                                            }
#line 295 "TransportModule.cs"
#line 295 "TransportModule.cs"
                                            double* csharp2cuda_temp_198 = &((left_scale)[row]);
#line 295 "TransportModule.cs"
                                            double csharp2cuda_temp_199 = (b)[row];
#line 295 "TransportModule.cs"
                                            double csharp2cuda_temp_200 = __ddiv_rn(csharp2cuda_temp_199, sum);
                                            (*(csharp2cuda_temp_198) = csharp2cuda_temp_200);
                                        }
#line 290 "TransportModule.cs"
                                        int* csharp2cuda_temp_189 = &(row);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_189));
                                    }
                                }
#line 297 "TransportModule.cs"
                                {
#line 297 "TransportModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
#line 297 "TransportModule.cs"
                                        int csharp2cuda_temp_202 = (first)->columns;
                                        if (!(((column) < (csharp2cuda_temp_202))))
                                            break;
#line 298 "TransportModule.cs"
                                        {
#line 299 "TransportModule.cs"
                                            double sum = 0.0;
#line 300 "TransportModule.cs"
                                            {
#line 300 "TransportModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
#line 300 "TransportModule.cs"
                                                    int csharp2cuda_temp_204 = (first)->rows;
                                                    if (!(((row) < (csharp2cuda_temp_204))))
                                                        break;
#line 301 "TransportModule.cs"
#line 301 "TransportModule.cs"
                                                    double* csharp2cuda_temp_205 = &(sum);
#line 301 "TransportModule.cs"
                                                    double csharp2cuda_temp_206 = *(csharp2cuda_temp_205);
#line 301 "TransportModule.cs"
                                                    int csharp2cuda_temp_207 = (first)->columns;
#line 301 "TransportModule.cs"
                                                    double csharp2cuda_temp_208 = (kernel)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_207), column)];
#line 301 "TransportModule.cs"
                                                    double csharp2cuda_temp_209 = (left_scale)[row];
                                                    (*(csharp2cuda_temp_205) = __dadd_rn(csharp2cuda_temp_206, __dmul_rn(csharp2cuda_temp_208, csharp2cuda_temp_209)));
#line 300 "TransportModule.cs"
                                                    int* csharp2cuda_temp_203 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_203));
                                                }
                                            }
#line 302 "TransportModule.cs"
#line 302 "TransportModule.cs"
                                            double* csharp2cuda_temp_210 = &((right_scale)[column]);
#line 302 "TransportModule.cs"
                                            double csharp2cuda_temp_211 = (c)[column];
#line 302 "TransportModule.cs"
                                            double csharp2cuda_temp_212 = __ddiv_rn(csharp2cuda_temp_211, sum);
                                            (*(csharp2cuda_temp_210) = csharp2cuda_temp_212);
                                        }
#line 297 "TransportModule.cs"
                                        int* csharp2cuda_temp_201 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_201));
                                    }
                                }
                            }
#line 288 "TransportModule.cs"
                            int* csharp2cuda_temp_188 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_188));
                        }
                    }
#line 305 "TransportModule.cs"
                    {
#line 305 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 305 "TransportModule.cs"
                            int csharp2cuda_temp_214 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_214))))
                                break;
#line 306 "TransportModule.cs"
                            {
#line 306 "TransportModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 306 "TransportModule.cs"
                                    int csharp2cuda_temp_216 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_216))))
                                        break;
#line 307 "TransportModule.cs"
#line 307 "TransportModule.cs"
                                    int csharp2cuda_temp_217 = (first)->columns;
#line 307 "TransportModule.cs"
                                    double* csharp2cuda_temp_218 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_217), column)]);
#line 308 "TransportModule.cs"
                                    double csharp2cuda_temp_219 = (left_scale)[row];
#line 308 "TransportModule.cs"
                                    int csharp2cuda_temp_220 = (first)->columns;
#line 308 "TransportModule.cs"
                                    double csharp2cuda_temp_221 = (kernel)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_220), column)];
#line 309 "TransportModule.cs"
                                    double csharp2cuda_temp_222 = (right_scale)[column];
                                    (*(csharp2cuda_temp_218) = __dmul_rn(__dmul_rn(csharp2cuda_temp_219, csharp2cuda_temp_221), csharp2cuda_temp_222));
#line 306 "TransportModule.cs"
                                    int* csharp2cuda_temp_215 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_215));
                                }
                            }
#line 305 "TransportModule.cs"
                            int* csharp2cuda_temp_213 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_213));
                        }
                    }
#line 310 "TransportModule.cs"
                    break;
                }
#line 312 "TransportModule.cs"
            case 7:
#line 313 "TransportModule.cs"
#line 313 "TransportModule.cs"
                int csharp2cuda_temp_223 = (first)->count;
#line 313 "TransportModule.cs"
                bool csharp2cuda_temp_224;
#line 313 "TransportModule.cs"
                if (!(((csharp2cuda_temp_223) <= (0))))
                {
#line 313 "TransportModule.cs"
                    int csharp2cuda_temp_225 = (first)->count;
#line 313 "TransportModule.cs"
                    int csharp2cuda_temp_226 = (second)->count;
#line 313 "TransportModule.cs"
                    csharp2cuda_temp_224 = ((csharp2cuda_temp_225) != (csharp2cuda_temp_226));
                }
                else
                {
#line 313 "TransportModule.cs"
                    csharp2cuda_temp_224 = true;
                }
#line 313 "TransportModule.cs"
                bool csharp2cuda_temp_227;
#line 313 "TransportModule.cs"
                if (!(csharp2cuda_temp_224))
                {
#line 314 "TransportModule.cs"
                    double csharp2cuda_temp_228 = (third)->scalar_value;
#line 313 "TransportModule.cs"
                    csharp2cuda_temp_227 = ((csharp2cuda_temp_228) < (1.0));
                }
                else
                {
#line 313 "TransportModule.cs"
                    csharp2cuda_temp_227 = true;
                }
#line 313 "TransportModule.cs"
                bool csharp2cuda_temp_229;
#line 313 "TransportModule.cs"
                if (!(csharp2cuda_temp_227))
                {
#line 313 "TransportModule.cs"
                    csharp2cuda_temp_229 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 313 "TransportModule.cs"
                    csharp2cuda_temp_229 = true;
                }
                if (csharp2cuda_temp_229)
#line 315 "TransportModule.cs"
                {
#line 316 "TransportModule.cs"
#line 316 "TransportModule.cs"
                    int* csharp2cuda_temp_230 = &((output)->valid);
                    (*(csharp2cuda_temp_230) = 0);
#line 317 "TransportModule.cs"
                    break;
                }
#line 319 "TransportModule.cs"
                {
#line 320 "TransportModule.cs"
                    double* left_sorted = scratch;
#line 321 "TransportModule.cs"
                    int csharp2cuda_temp_231 = (first)->count;
#line 321 "TransportModule.cs"
                    double* right_sorted = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_231);
#line 322 "TransportModule.cs"
#line 322 "TransportModule.cs"
                    int csharp2cuda_temp_232 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_232, left_sorted, false);
#line 323 "TransportModule.cs"
#line 323 "TransportModule.cs"
                    int csharp2cuda_temp_233 = (second)->count;
                    mathblocks_statistics_sort_copy(b, csharp2cuda_temp_233, right_sorted, false);
#line 324 "TransportModule.cs"
                    double sum = 0.0;
#line 325 "TransportModule.cs"
                    {
#line 325 "TransportModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 325 "TransportModule.cs"
                            int csharp2cuda_temp_235 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_235))))
                                break;
#line 326 "TransportModule.cs"
#line 326 "TransportModule.cs"
                            double* csharp2cuda_temp_236 = &(sum);
#line 326 "TransportModule.cs"
                            double csharp2cuda_temp_237 = *(csharp2cuda_temp_236);
#line 327 "TransportModule.cs"
                            double csharp2cuda_temp_238 = (left_sorted)[index];
#line 327 "TransportModule.cs"
                            double csharp2cuda_temp_239 = (right_sorted)[index];
#line 328 "TransportModule.cs"
                            double csharp2cuda_temp_240 = (third)->scalar_value;
                            (*(csharp2cuda_temp_236) = __dadd_rn(csharp2cuda_temp_237, mathblocks_power(fabs(__dsub_rn(csharp2cuda_temp_238, csharp2cuda_temp_239)), csharp2cuda_temp_240)));
#line 325 "TransportModule.cs"
                            int* csharp2cuda_temp_234 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_234));
                        }
                    }
#line 329 "TransportModule.cs"
#line 329 "TransportModule.cs"
                    double* csharp2cuda_temp_241 = &((output)->scalar_value);
#line 330 "TransportModule.cs"
                    int csharp2cuda_temp_242 = (first)->count;
#line 330 "TransportModule.cs"
                    double csharp2cuda_temp_243 = __ddiv_rn(sum, ((double)(csharp2cuda_temp_242)));
#line 331 "TransportModule.cs"
                    double csharp2cuda_temp_244 = (third)->scalar_value;
#line 331 "TransportModule.cs"
                    double csharp2cuda_temp_245 = __ddiv_rn(1.0, csharp2cuda_temp_244);
                    (*(csharp2cuda_temp_241) = mathblocks_power(csharp2cuda_temp_243, csharp2cuda_temp_245));
#line 332 "TransportModule.cs"
                    break;
                }
#line 334 "TransportModule.cs"
            case 8:
#line 335 "TransportModule.cs"
#line 335 "TransportModule.cs"
                int csharp2cuda_temp_246 = (first)->count;
#line 335 "TransportModule.cs"
                bool csharp2cuda_temp_247;
#line 335 "TransportModule.cs"
                if (!(((csharp2cuda_temp_246) <= (0))))
                {
#line 335 "TransportModule.cs"
                    int csharp2cuda_temp_248 = (first)->count;
#line 335 "TransportModule.cs"
                    int csharp2cuda_temp_249 = (second)->count;
#line 335 "TransportModule.cs"
                    csharp2cuda_temp_247 = ((csharp2cuda_temp_248) != (csharp2cuda_temp_249));
                }
                else
                {
#line 335 "TransportModule.cs"
                    csharp2cuda_temp_247 = true;
                }
#line 335 "TransportModule.cs"
                bool csharp2cuda_temp_250;
#line 335 "TransportModule.cs"
                if (!(csharp2cuda_temp_247))
                {
#line 336 "TransportModule.cs"
                    int csharp2cuda_temp_251 = (third)->count;
#line 335 "TransportModule.cs"
                    csharp2cuda_temp_250 = ((csharp2cuda_temp_251) <= (0));
                }
                else
                {
#line 335 "TransportModule.cs"
                    csharp2cuda_temp_250 = true;
                }
#line 335 "TransportModule.cs"
                bool csharp2cuda_temp_252;
#line 335 "TransportModule.cs"
                if (!(csharp2cuda_temp_250))
                {
#line 336 "TransportModule.cs"
                    int csharp2cuda_temp_253 = (third)->count;
#line 336 "TransportModule.cs"
                    int csharp2cuda_temp_254 = (fourth)->count;
#line 335 "TransportModule.cs"
                    csharp2cuda_temp_252 = ((csharp2cuda_temp_253) != (csharp2cuda_temp_254));
                }
                else
                {
#line 335 "TransportModule.cs"
                    csharp2cuda_temp_252 = true;
                }
#line 335 "TransportModule.cs"
                bool csharp2cuda_temp_255;
#line 335 "TransportModule.cs"
                if (!(csharp2cuda_temp_252))
                {
#line 335 "TransportModule.cs"
                    csharp2cuda_temp_255 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 335 "TransportModule.cs"
                    csharp2cuda_temp_255 = true;
                }
#line 335 "TransportModule.cs"
                bool csharp2cuda_temp_256;
#line 335 "TransportModule.cs"
                if (!(csharp2cuda_temp_255))
                {
#line 337 "TransportModule.cs"
                    int csharp2cuda_temp_257 = (second)->count;
#line 335 "TransportModule.cs"
                    csharp2cuda_temp_256 = (!(mathblocks_advanced_distribution(b, csharp2cuda_temp_257)));
                }
                else
                {
#line 335 "TransportModule.cs"
                    csharp2cuda_temp_256 = true;
                }
#line 335 "TransportModule.cs"
                bool csharp2cuda_temp_258;
#line 335 "TransportModule.cs"
                if (!(csharp2cuda_temp_256))
                {
#line 338 "TransportModule.cs"
                    int csharp2cuda_temp_259 = (fourth)->count;
#line 335 "TransportModule.cs"
                    csharp2cuda_temp_258 = (!(mathblocks_advanced_distribution(d, csharp2cuda_temp_259)));
                }
                else
                {
#line 335 "TransportModule.cs"
                    csharp2cuda_temp_258 = true;
                }
                if (csharp2cuda_temp_258)
#line 339 "TransportModule.cs"
                {
#line 340 "TransportModule.cs"
#line 340 "TransportModule.cs"
                    int* csharp2cuda_temp_260 = &((output)->valid);
                    (*(csharp2cuda_temp_260) = 0);
#line 341 "TransportModule.cs"
                    break;
                }
#line 343 "TransportModule.cs"
                {
#line 344 "TransportModule.cs"
                    int* left_order = ((int*)(scratch));
#line 345 "TransportModule.cs"
                    int csharp2cuda_temp_261 = (first)->count;
#line 345 "TransportModule.cs"
                    int* right_order = csharp2cuda_pointer_add(left_order, csharp2cuda_temp_261);
#line 346 "TransportModule.cs"
                    int csharp2cuda_temp_262 = (third)->count;
#line 346 "TransportModule.cs"
                    int* left_buffer = csharp2cuda_pointer_add(right_order, csharp2cuda_temp_262);
#line 347 "TransportModule.cs"
                    int csharp2cuda_temp_263 = (first)->count;
#line 347 "TransportModule.cs"
                    int* right_buffer = csharp2cuda_pointer_add(left_buffer, csharp2cuda_temp_263);
#line 348 "TransportModule.cs"
#line 348 "TransportModule.cs"
                    int csharp2cuda_temp_264 = (first)->count;
                    mathblocks_stable_index_order(a, csharp2cuda_temp_264, left_order, left_buffer);
#line 349 "TransportModule.cs"
#line 349 "TransportModule.cs"
                    int csharp2cuda_temp_265 = (third)->count;
                    mathblocks_stable_index_order(c, csharp2cuda_temp_265, right_order, right_buffer);
#line 350 "TransportModule.cs"
                    int left_index = 0;
#line 351 "TransportModule.cs"
                    int right_index = 0;
#line 352 "TransportModule.cs"
                    int csharp2cuda_temp_266 = (left_order)[0];
#line 352 "TransportModule.cs"
                    double left_remaining = (b)[csharp2cuda_temp_266];
#line 353 "TransportModule.cs"
                    int csharp2cuda_temp_267 = (right_order)[0];
#line 353 "TransportModule.cs"
                    double right_remaining = (d)[csharp2cuda_temp_267];
#line 354 "TransportModule.cs"
                    double total = 0.0;
#line 355 "TransportModule.cs"
                    while (true)
                    {
#line 355 "TransportModule.cs"
                        int csharp2cuda_temp_268 = (first)->count;
#line 355 "TransportModule.cs"
                        bool csharp2cuda_temp_269;
#line 355 "TransportModule.cs"
                        if (((left_index) < (csharp2cuda_temp_268)))
                        {
#line 355 "TransportModule.cs"
                            int csharp2cuda_temp_270 = (third)->count;
#line 355 "TransportModule.cs"
                            csharp2cuda_temp_269 = ((right_index) < (csharp2cuda_temp_270));
                        }
                        else
                        {
#line 355 "TransportModule.cs"
                            csharp2cuda_temp_269 = false;
                        }
                        if (!(csharp2cuda_temp_269))
                            break;
#line 356 "TransportModule.cs"
                        {
#line 357 "TransportModule.cs"
                            double csharp2cuda_temp_271;
#line 357 "TransportModule.cs"
                            if (((left_remaining) < (right_remaining)))
                            {
#line 357 "TransportModule.cs"
                                csharp2cuda_temp_271 = left_remaining;
                            }
                            else
                            {
#line 357 "TransportModule.cs"
                                csharp2cuda_temp_271 = right_remaining;
                            }
#line 357 "TransportModule.cs"
                            double amount = csharp2cuda_temp_271;
#line 360 "TransportModule.cs"
#line 360 "TransportModule.cs"
                            double* csharp2cuda_temp_272 = &(total);
#line 360 "TransportModule.cs"
                            double csharp2cuda_temp_273 = *(csharp2cuda_temp_272);
#line 361 "TransportModule.cs"
                            int csharp2cuda_temp_274 = (left_order)[left_index];
#line 361 "TransportModule.cs"
                            double csharp2cuda_temp_275 = (a)[csharp2cuda_temp_274];
#line 361 "TransportModule.cs"
                            int csharp2cuda_temp_276 = (right_order)[right_index];
#line 361 "TransportModule.cs"
                            double csharp2cuda_temp_277 = (c)[csharp2cuda_temp_276];
                            (*(csharp2cuda_temp_272) = __dadd_rn(csharp2cuda_temp_273, __dmul_rn(amount, fabs(__dsub_rn(csharp2cuda_temp_275, csharp2cuda_temp_277)))));
#line 362 "TransportModule.cs"
#line 362 "TransportModule.cs"
                            double* csharp2cuda_temp_278 = &(left_remaining);
#line 362 "TransportModule.cs"
                            double csharp2cuda_temp_279 = *(csharp2cuda_temp_278);
                            (*(csharp2cuda_temp_278) = __dsub_rn(csharp2cuda_temp_279, amount));
#line 363 "TransportModule.cs"
#line 363 "TransportModule.cs"
                            double* csharp2cuda_temp_280 = &(right_remaining);
#line 363 "TransportModule.cs"
                            double csharp2cuda_temp_281 = *(csharp2cuda_temp_280);
                            (*(csharp2cuda_temp_280) = __dsub_rn(csharp2cuda_temp_281, amount));
#line 364 "TransportModule.cs"
#line 364 "TransportModule.cs"
                            bool csharp2cuda_temp_282;
#line 364 "TransportModule.cs"
                            if (((left_remaining) == (0.0)))
                            {
#line 364 "TransportModule.cs"
                                int* csharp2cuda_temp_283 = &(left_index);
#line 364 "TransportModule.cs"
                                int csharp2cuda_temp_284 = csharp2cuda_i32_pre_increment(*(csharp2cuda_temp_283));
#line 364 "TransportModule.cs"
                                int csharp2cuda_temp_285 = (first)->count;
#line 364 "TransportModule.cs"
                                csharp2cuda_temp_282 = ((csharp2cuda_temp_284) < (csharp2cuda_temp_285));
                            }
                            else
                            {
#line 364 "TransportModule.cs"
                                csharp2cuda_temp_282 = false;
                            }
                            if (csharp2cuda_temp_282)
                            {
#line 365 "TransportModule.cs"
#line 365 "TransportModule.cs"
                                double* csharp2cuda_temp_286 = &(left_remaining);
#line 365 "TransportModule.cs"
                                int csharp2cuda_temp_287 = (left_order)[left_index];
#line 365 "TransportModule.cs"
                                double csharp2cuda_temp_288 = (b)[csharp2cuda_temp_287];
                                (*(csharp2cuda_temp_286) = csharp2cuda_temp_288);
                            }
#line 366 "TransportModule.cs"
#line 366 "TransportModule.cs"
                            bool csharp2cuda_temp_289;
#line 366 "TransportModule.cs"
                            if (((right_remaining) == (0.0)))
                            {
#line 366 "TransportModule.cs"
                                int* csharp2cuda_temp_290 = &(right_index);
#line 366 "TransportModule.cs"
                                int csharp2cuda_temp_291 = csharp2cuda_i32_pre_increment(*(csharp2cuda_temp_290));
#line 366 "TransportModule.cs"
                                int csharp2cuda_temp_292 = (third)->count;
#line 366 "TransportModule.cs"
                                csharp2cuda_temp_289 = ((csharp2cuda_temp_291) < (csharp2cuda_temp_292));
                            }
                            else
                            {
#line 366 "TransportModule.cs"
                                csharp2cuda_temp_289 = false;
                            }
                            if (csharp2cuda_temp_289)
                            {
#line 367 "TransportModule.cs"
#line 367 "TransportModule.cs"
                                double* csharp2cuda_temp_293 = &(right_remaining);
#line 367 "TransportModule.cs"
                                int csharp2cuda_temp_294 = (right_order)[right_index];
#line 367 "TransportModule.cs"
                                double csharp2cuda_temp_295 = (d)[csharp2cuda_temp_294];
                                (*(csharp2cuda_temp_293) = csharp2cuda_temp_295);
                            }
                        }
                    }
#line 369 "TransportModule.cs"
#line 369 "TransportModule.cs"
                    double* csharp2cuda_temp_296 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_296) = total);
#line 370 "TransportModule.cs"
                    break;
                }
#line 372 "TransportModule.cs"
            case 9:
            case 10:
#line 374 "TransportModule.cs"
#line 374 "TransportModule.cs"
                int csharp2cuda_temp_297 = (first)->rows;
#line 374 "TransportModule.cs"
                int csharp2cuda_temp_298 = (second)->columns;
                mathblocks_sequence_set_matrix_shape(output, csharp2cuda_temp_297, csharp2cuda_temp_298);
#line 375 "TransportModule.cs"
#line 375 "TransportModule.cs"
                int csharp2cuda_temp_299 = (first)->columns;
#line 375 "TransportModule.cs"
                int csharp2cuda_temp_300 = (second)->rows;
                if (((csharp2cuda_temp_299) != (csharp2cuda_temp_300)))
#line 376 "TransportModule.cs"
                {
#line 377 "TransportModule.cs"
#line 377 "TransportModule.cs"
                    int* csharp2cuda_temp_301 = &((output)->valid);
                    (*(csharp2cuda_temp_301) = 0);
#line 378 "TransportModule.cs"
                    break;
                }
#line 380 "TransportModule.cs"
                {
#line 380 "TransportModule.cs"
                    int row = 0;
                    while (true)
                    {
#line 380 "TransportModule.cs"
                        int csharp2cuda_temp_303 = (first)->rows;
                        if (!(((row) < (csharp2cuda_temp_303))))
                            break;
#line 381 "TransportModule.cs"
                        {
#line 381 "TransportModule.cs"
                            int column = 0;
                            while (true)
                            {
#line 381 "TransportModule.cs"
                                int csharp2cuda_temp_305 = (second)->columns;
                                if (!(((column) < (csharp2cuda_temp_305))))
                                    break;
#line 382 "TransportModule.cs"
                                {
#line 383 "TransportModule.cs"
                                    double csharp2cuda_temp_306;
#line 383 "TransportModule.cs"
                                    if (((opcode) == (9)))
                                    {
#line 383 "TransportModule.cs"
                                        csharp2cuda_temp_306 = (-(mathblocks_positive_infinity()));
                                    }
                                    else
                                    {
#line 383 "TransportModule.cs"
                                        csharp2cuda_temp_306 = mathblocks_positive_infinity();
                                    }
#line 383 "TransportModule.cs"
                                    double selected = csharp2cuda_temp_306;
#line 386 "TransportModule.cs"
                                    {
#line 386 "TransportModule.cs"
                                        int inner = 0;
                                        while (true)
                                        {
#line 386 "TransportModule.cs"
                                            int csharp2cuda_temp_308 = (first)->columns;
                                            if (!(((inner) < (csharp2cuda_temp_308))))
                                                break;
#line 387 "TransportModule.cs"
                                            {
#line 388 "TransportModule.cs"
                                                int csharp2cuda_temp_309 = (first)->columns;
#line 388 "TransportModule.cs"
                                                double csharp2cuda_temp_310 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_309), inner)];
#line 389 "TransportModule.cs"
                                                int csharp2cuda_temp_311 = (second)->columns;
#line 389 "TransportModule.cs"
                                                double csharp2cuda_temp_312 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_311), column)];
#line 388 "TransportModule.cs"
                                                double candidate = __dadd_rn(csharp2cuda_temp_310, csharp2cuda_temp_312);
#line 390 "TransportModule.cs"
#line 390 "TransportModule.cs"
                                                double* csharp2cuda_temp_313 = &(selected);
#line 390 "TransportModule.cs"
                                                double csharp2cuda_temp_314;
#line 390 "TransportModule.cs"
                                                if (((opcode) == (9)))
                                                {
#line 391 "TransportModule.cs"
                                                    double csharp2cuda_temp_315;
#line 391 "TransportModule.cs"
                                                    if (((selected) > (candidate)))
                                                    {
#line 391 "TransportModule.cs"
                                                        csharp2cuda_temp_315 = selected;
                                                    }
                                                    else
                                                    {
#line 391 "TransportModule.cs"
                                                        csharp2cuda_temp_315 = candidate;
                                                    }
#line 390 "TransportModule.cs"
                                                    csharp2cuda_temp_314 = csharp2cuda_temp_315;
                                                }
                                                else
                                                {
#line 392 "TransportModule.cs"
                                                    double csharp2cuda_temp_316;
#line 392 "TransportModule.cs"
                                                    if (((selected) < (candidate)))
                                                    {
#line 392 "TransportModule.cs"
                                                        csharp2cuda_temp_316 = selected;
                                                    }
                                                    else
                                                    {
#line 392 "TransportModule.cs"
                                                        csharp2cuda_temp_316 = candidate;
                                                    }
#line 390 "TransportModule.cs"
                                                    csharp2cuda_temp_314 = csharp2cuda_temp_316;
                                                }
                                                (*(csharp2cuda_temp_313) = csharp2cuda_temp_314);
                                            }
#line 386 "TransportModule.cs"
                                            int* csharp2cuda_temp_307 = &(inner);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_307));
                                        }
                                    }
#line 394 "TransportModule.cs"
#line 394 "TransportModule.cs"
                                    int csharp2cuda_temp_317 = (second)->columns;
#line 394 "TransportModule.cs"
                                    double* csharp2cuda_temp_318 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_317), column)]);
                                    (*(csharp2cuda_temp_318) = selected);
                                }
#line 381 "TransportModule.cs"
                                int* csharp2cuda_temp_304 = &(column);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_304));
                            }
                        }
#line 380 "TransportModule.cs"
                        int* csharp2cuda_temp_302 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_302));
                    }
                }
#line 396 "TransportModule.cs"
                break;
        }
#line 399 "TransportModule.cs"
#line 399 "TransportModule.cs"
        bool csharp2cuda_temp_319 = (output)->valid;
#line 399 "TransportModule.cs"
        bool csharp2cuda_temp_320;
#line 399 "TransportModule.cs"
        if (csharp2cuda_temp_319)
        {
#line 399 "TransportModule.cs"
            csharp2cuda_temp_320 = ((opcode) != (3));
        }
        else
        {
#line 399 "TransportModule.cs"
            csharp2cuda_temp_320 = false;
        }
#line 399 "TransportModule.cs"
        bool csharp2cuda_temp_321;
#line 399 "TransportModule.cs"
        if (csharp2cuda_temp_320)
        {
#line 399 "TransportModule.cs"
            csharp2cuda_temp_321 = ((opcode) != (4));
        }
        else
        {
#line 399 "TransportModule.cs"
            csharp2cuda_temp_321 = false;
        }
#line 399 "TransportModule.cs"
        bool csharp2cuda_temp_322;
#line 399 "TransportModule.cs"
        if (csharp2cuda_temp_321)
        {
#line 399 "TransportModule.cs"
            csharp2cuda_temp_322 = ((opcode) != (6));
        }
        else
        {
#line 399 "TransportModule.cs"
            csharp2cuda_temp_322 = false;
        }
#line 399 "TransportModule.cs"
        bool csharp2cuda_temp_323;
#line 399 "TransportModule.cs"
        if (csharp2cuda_temp_322)
        {
#line 399 "TransportModule.cs"
            csharp2cuda_temp_323 = ((opcode) != (9));
        }
        else
        {
#line 399 "TransportModule.cs"
            csharp2cuda_temp_323 = false;
        }
#line 399 "TransportModule.cs"
        bool csharp2cuda_temp_324;
#line 399 "TransportModule.cs"
        if (csharp2cuda_temp_323)
        {
#line 399 "TransportModule.cs"
            csharp2cuda_temp_324 = ((opcode) != (10));
        }
        else
        {
#line 399 "TransportModule.cs"
            csharp2cuda_temp_324 = false;
        }
#line 399 "TransportModule.cs"
        bool csharp2cuda_temp_325;
#line 399 "TransportModule.cs"
        if (csharp2cuda_temp_324)
        {
#line 401 "TransportModule.cs"
            double csharp2cuda_temp_326 = (output)->scalar_value;
#line 399 "TransportModule.cs"
            csharp2cuda_temp_325 = (!(isfinite(csharp2cuda_temp_326)));
        }
        else
        {
#line 399 "TransportModule.cs"
            csharp2cuda_temp_325 = false;
        }
        if (csharp2cuda_temp_325)
#line 402 "TransportModule.cs"
        {
#line 403 "TransportModule.cs"
#line 403 "TransportModule.cs"
            int* csharp2cuda_temp_327 = &((output)->valid);
            (*(csharp2cuda_temp_327) = 0);
        }
#line 405 "TransportModule.cs"
#line 405 "TransportModule.cs"
        bool csharp2cuda_temp_328 = (output)->valid;
#line 405 "TransportModule.cs"
        bool csharp2cuda_temp_329;
#line 405 "TransportModule.cs"
        if (csharp2cuda_temp_328)
        {
#line 405 "TransportModule.cs"
            bool csharp2cuda_temp_330;
#line 405 "TransportModule.cs"
            if (!(((opcode) == (3))))
            {
#line 405 "TransportModule.cs"
                csharp2cuda_temp_330 = ((opcode) == (4));
            }
            else
            {
#line 405 "TransportModule.cs"
                csharp2cuda_temp_330 = true;
            }
#line 405 "TransportModule.cs"
            bool csharp2cuda_temp_331;
#line 405 "TransportModule.cs"
            if (!(csharp2cuda_temp_330))
            {
#line 405 "TransportModule.cs"
                csharp2cuda_temp_331 = ((opcode) == (6));
            }
            else
            {
#line 405 "TransportModule.cs"
                csharp2cuda_temp_331 = true;
            }
#line 405 "TransportModule.cs"
            bool csharp2cuda_temp_332;
#line 405 "TransportModule.cs"
            if (!(csharp2cuda_temp_331))
            {
#line 405 "TransportModule.cs"
                csharp2cuda_temp_332 = ((opcode) == (9));
            }
            else
            {
#line 405 "TransportModule.cs"
                csharp2cuda_temp_332 = true;
            }
#line 405 "TransportModule.cs"
            bool csharp2cuda_temp_333;
#line 405 "TransportModule.cs"
            if (!(csharp2cuda_temp_332))
            {
#line 405 "TransportModule.cs"
                csharp2cuda_temp_333 = ((opcode) == (10));
            }
            else
            {
#line 405 "TransportModule.cs"
                csharp2cuda_temp_333 = true;
            }
#line 405 "TransportModule.cs"
            csharp2cuda_temp_329 = csharp2cuda_temp_333;
        }
        else
        {
#line 405 "TransportModule.cs"
            csharp2cuda_temp_329 = false;
        }
        if (csharp2cuda_temp_329)
        {
#line 406 "TransportModule.cs"
            {
#line 406 "TransportModule.cs"
                int index = 0;
                while (true)
                {
#line 406 "TransportModule.cs"
                    int csharp2cuda_temp_335 = (output)->count;
                    if (!(((index) < (csharp2cuda_temp_335))))
                        break;
#line 407 "TransportModule.cs"
#line 407 "TransportModule.cs"
                    double csharp2cuda_temp_336 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_336))))
                    {
#line 407 "TransportModule.cs"
#line 407 "TransportModule.cs"
                        int* csharp2cuda_temp_337 = &((output)->valid);
                        (*(csharp2cuda_temp_337) = 0);
                    }
#line 406 "TransportModule.cs"
                    int* csharp2cuda_temp_334 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_334));
                }
            }
        }
    }
}

#line 58 "TransportModule.cs"
__device__ double mathblocks_transport_mean_pairwise(
    const double* left,
    int left_count,
    const double* right,
    int right_count)
#line 64 "TransportModule.cs"
{
#line 65 "TransportModule.cs"
    double sum = 0.0;
#line 66 "TransportModule.cs"
    {
#line 66 "TransportModule.cs"
        int left_index = 0;
        while (true)
        {
            if (!(((left_index) < (left_count))))
                break;
#line 67 "TransportModule.cs"
            {
#line 67 "TransportModule.cs"
                int right_index = 0;
                while (true)
                {
                    if (!(((right_index) < (right_count))))
                        break;
#line 68 "TransportModule.cs"
#line 68 "TransportModule.cs"
                    double* csharp2cuda_temp_2 = &(sum);
#line 68 "TransportModule.cs"
                    double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 68 "TransportModule.cs"
                    double csharp2cuda_temp_4 = (left)[left_index];
#line 68 "TransportModule.cs"
                    double csharp2cuda_temp_5 = (right)[right_index];
                    (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, fabs(__dsub_rn(csharp2cuda_temp_4, csharp2cuda_temp_5))));
#line 67 "TransportModule.cs"
                    int* csharp2cuda_temp_1 = &(right_index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                }
            }
#line 66 "TransportModule.cs"
            int* csharp2cuda_temp_0 = &(left_index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 69 "TransportModule.cs"
    return __ddiv_rn(sum, ((double)(csharp2cuda_i32_mul(left_count, right_count))));
}