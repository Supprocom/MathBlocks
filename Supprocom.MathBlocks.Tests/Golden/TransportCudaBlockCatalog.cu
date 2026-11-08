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

#line 78 "TransportModule.cs"
__device__ void mathblocks_transport_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 64 "TransportModule.cs"
__device__ double mathblocks_transport_mean_pairwise(
    const double* left,
    int left_count,
    const double* right,
    int right_count);

#line 78 "TransportModule.cs"
__device__ void mathblocks_transport_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 84 "TransportModule.cs"
{
#line 85 "TransportModule.cs"
    int thread = threadIdx.x;
#line 86 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 86 "TransportModule.cs"
    if (((input_count) > (0)))
    {
#line 86 "TransportModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 86 "TransportModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 86 "TransportModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 87 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 87 "TransportModule.cs"
    if (((input_count) > (1)))
    {
#line 87 "TransportModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 87 "TransportModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 87 "TransportModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 88 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 88 "TransportModule.cs"
    if (((input_count) > (2)))
    {
#line 88 "TransportModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 88 "TransportModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 88 "TransportModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 89 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_3;
#line 89 "TransportModule.cs"
    if (((input_count) > (3)))
    {
#line 89 "TransportModule.cs"
        csharp2cuda_temp_3 = (inputs)[3];
    }
    else
    {
#line 89 "TransportModule.cs"
        csharp2cuda_temp_3 = ((MathBlockSlot*)(nullptr));
    }
#line 89 "TransportModule.cs"
    const MathBlockSlot* fourth = csharp2cuda_temp_3;
#line 90 "TransportModule.cs"
    MathBlockSlot* csharp2cuda_temp_4;
#line 90 "TransportModule.cs"
    if (((input_count) > (4)))
    {
#line 90 "TransportModule.cs"
        csharp2cuda_temp_4 = (inputs)[4];
    }
    else
    {
#line 90 "TransportModule.cs"
        csharp2cuda_temp_4 = ((MathBlockSlot*)(nullptr));
    }
#line 90 "TransportModule.cs"
    const MathBlockSlot* fifth = csharp2cuda_temp_4;
#line 91 "TransportModule.cs"
    if (((thread) == (0)))
#line 92 "TransportModule.cs"
    {
#line 93 "TransportModule.cs"
#line 93 "TransportModule.cs"
        double* csharp2cuda_temp_5 = &((output)->scalar_value);
        (*(csharp2cuda_temp_5) = 0.0);
#line 94 "TransportModule.cs"
#line 94 "TransportModule.cs"
        int* csharp2cuda_temp_6 = &((output)->boolean_value);
        (*(csharp2cuda_temp_6) = 0);
#line 95 "TransportModule.cs"
#line 95 "TransportModule.cs"
        int* csharp2cuda_temp_7 = &((output)->rows);
        (*(csharp2cuda_temp_7) = 0);
#line 96 "TransportModule.cs"
#line 96 "TransportModule.cs"
        int* csharp2cuda_temp_8 = &((output)->columns);
        (*(csharp2cuda_temp_8) = 0);
#line 97 "TransportModule.cs"
#line 97 "TransportModule.cs"
        int* csharp2cuda_temp_9 = &((output)->count);
        (*(csharp2cuda_temp_9) = 0);
#line 98 "TransportModule.cs"
#line 98 "TransportModule.cs"
        int* csharp2cuda_temp_10 = &((output)->valid);
        (*(csharp2cuda_temp_10) = 1);
#line 99 "TransportModule.cs"
        {
#line 99 "TransportModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 100 "TransportModule.cs"
#line 100 "TransportModule.cs"
                MathBlockSlot* csharp2cuda_temp_12 = (inputs)[index];
#line 100 "TransportModule.cs"
                bool csharp2cuda_temp_13;
#line 100 "TransportModule.cs"
                if (!(((((void*)(csharp2cuda_temp_12))) == (((void*)(nullptr))))))
                {
#line 100 "TransportModule.cs"
                    MathBlockSlot* csharp2cuda_temp_14 = (inputs)[index];
#line 100 "TransportModule.cs"
                    bool csharp2cuda_temp_15 = (csharp2cuda_temp_14)->valid;
#line 100 "TransportModule.cs"
                    csharp2cuda_temp_13 = (!(csharp2cuda_temp_15));
                }
                else
                {
#line 100 "TransportModule.cs"
                    csharp2cuda_temp_13 = true;
                }
                if (csharp2cuda_temp_13)
                {
#line 100 "TransportModule.cs"
#line 100 "TransportModule.cs"
                    int* csharp2cuda_temp_16 = &((output)->valid);
                    (*(csharp2cuda_temp_16) = 0);
                }
#line 99 "TransportModule.cs"
                int* csharp2cuda_temp_11 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_11));
            }
        }
    }
#line 102 "TransportModule.cs"
    __syncthreads();
#line 103 "TransportModule.cs"
#line 103 "TransportModule.cs"
    bool csharp2cuda_temp_17 = (output)->valid;
    if ((!(csharp2cuda_temp_17)))
    {
#line 104 "TransportModule.cs"
        return;
    }
#line 106 "TransportModule.cs"
    double* csharp2cuda_temp_18;
#line 106 "TransportModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 106 "TransportModule.cs"
        csharp2cuda_temp_18 = ((double*)(nullptr));
    }
    else
    {
#line 106 "TransportModule.cs"
        unsigned long long csharp2cuda_temp_19 = (first)->data_pointer;
#line 106 "TransportModule.cs"
        csharp2cuda_temp_18 = ((double*)(csharp2cuda_temp_19));
    }
#line 106 "TransportModule.cs"
    const double* a = csharp2cuda_temp_18;
#line 107 "TransportModule.cs"
    double* csharp2cuda_temp_20;
#line 107 "TransportModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 107 "TransportModule.cs"
        csharp2cuda_temp_20 = ((double*)(nullptr));
    }
    else
    {
#line 107 "TransportModule.cs"
        unsigned long long csharp2cuda_temp_21 = (second)->data_pointer;
#line 107 "TransportModule.cs"
        csharp2cuda_temp_20 = ((double*)(csharp2cuda_temp_21));
    }
#line 107 "TransportModule.cs"
    const double* b = csharp2cuda_temp_20;
#line 108 "TransportModule.cs"
    double* csharp2cuda_temp_22;
#line 108 "TransportModule.cs"
    if (((((void*)(third))) == (((void*)(nullptr)))))
    {
#line 108 "TransportModule.cs"
        csharp2cuda_temp_22 = ((double*)(nullptr));
    }
    else
    {
#line 108 "TransportModule.cs"
        unsigned long long csharp2cuda_temp_23 = (third)->data_pointer;
#line 108 "TransportModule.cs"
        csharp2cuda_temp_22 = ((double*)(csharp2cuda_temp_23));
    }
#line 108 "TransportModule.cs"
    const double* c = csharp2cuda_temp_22;
#line 109 "TransportModule.cs"
    double* csharp2cuda_temp_24;
#line 109 "TransportModule.cs"
    if (((((void*)(fourth))) == (((void*)(nullptr)))))
    {
#line 109 "TransportModule.cs"
        csharp2cuda_temp_24 = ((double*)(nullptr));
    }
    else
    {
#line 109 "TransportModule.cs"
        unsigned long long csharp2cuda_temp_25 = (fourth)->data_pointer;
#line 109 "TransportModule.cs"
        csharp2cuda_temp_24 = ((double*)(csharp2cuda_temp_25));
    }
#line 109 "TransportModule.cs"
    const double* d = csharp2cuda_temp_24;
#line 110 "TransportModule.cs"
    unsigned long long csharp2cuda_temp_26 = (output)->data_pointer;
#line 110 "TransportModule.cs"
    double* result = ((double*)(csharp2cuda_temp_26));
#line 111 "TransportModule.cs"
    unsigned long long csharp2cuda_temp_27 = (output)->scratch_pointer;
#line 111 "TransportModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_27));
#line 113 "TransportModule.cs"
    if (((thread) == (0)))
#line 114 "TransportModule.cs"
    {
#line 115 "TransportModule.cs"
        switch (opcode)
        {
#line 117 "TransportModule.cs"
            case 0:
#line 118 "TransportModule.cs"
#line 118 "TransportModule.cs"
                int csharp2cuda_temp_28 = (first)->rows;
#line 118 "TransportModule.cs"
                int csharp2cuda_temp_29 = (first)->columns;
#line 118 "TransportModule.cs"
                bool csharp2cuda_temp_30;
#line 118 "TransportModule.cs"
                if (!(((csharp2cuda_temp_28) != (csharp2cuda_temp_29))))
                {
#line 118 "TransportModule.cs"
                    int csharp2cuda_temp_31 = (second)->count;
#line 118 "TransportModule.cs"
                    int csharp2cuda_temp_32 = (first)->rows;
#line 118 "TransportModule.cs"
                    csharp2cuda_temp_30 = ((csharp2cuda_temp_31) != (csharp2cuda_temp_32));
                }
                else
                {
#line 118 "TransportModule.cs"
                    csharp2cuda_temp_30 = true;
                }
                if (csharp2cuda_temp_30)
#line 119 "TransportModule.cs"
                {
#line 120 "TransportModule.cs"
#line 120 "TransportModule.cs"
                    int* csharp2cuda_temp_33 = &((output)->valid);
                    (*(csharp2cuda_temp_33) = 0);
#line 121 "TransportModule.cs"
                    break;
                }
#line 123 "TransportModule.cs"
                {
#line 124 "TransportModule.cs"
                    double total = 0.0;
#line 125 "TransportModule.cs"
                    {
#line 125 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 125 "TransportModule.cs"
                            int csharp2cuda_temp_35 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_35))))
                                break;
#line 126 "TransportModule.cs"
                            {
#line 127 "TransportModule.cs"
                                int column = 0;
#line 128 "TransportModule.cs"
#line 128 "TransportModule.cs"
                                double csharp2cuda_temp_36 = (b)[row];
#line 128 "TransportModule.cs"
                                int* csharp2cuda_temp_37 = &(column);
#line 128 "TransportModule.cs"
                                bool csharp2cuda_temp_38 = mathblocks_nonnegative_integer(csharp2cuda_temp_36, csharp2cuda_temp_37);
#line 128 "TransportModule.cs"
                                bool csharp2cuda_temp_39;
#line 128 "TransportModule.cs"
                                if (!((!(csharp2cuda_temp_38))))
                                {
#line 128 "TransportModule.cs"
                                    int csharp2cuda_temp_40 = (first)->columns;
#line 128 "TransportModule.cs"
                                    csharp2cuda_temp_39 = ((column) >= (csharp2cuda_temp_40));
                                }
                                else
                                {
#line 128 "TransportModule.cs"
                                    csharp2cuda_temp_39 = true;
                                }
                                if (csharp2cuda_temp_39)
#line 129 "TransportModule.cs"
                                {
#line 130 "TransportModule.cs"
#line 130 "TransportModule.cs"
                                    int* csharp2cuda_temp_41 = &((output)->valid);
                                    (*(csharp2cuda_temp_41) = 0);
#line 131 "TransportModule.cs"
                                    break;
                                }
#line 133 "TransportModule.cs"
#line 133 "TransportModule.cs"
                                double* csharp2cuda_temp_42 = &(total);
#line 133 "TransportModule.cs"
                                double csharp2cuda_temp_43 = *(csharp2cuda_temp_42);
#line 133 "TransportModule.cs"
                                int csharp2cuda_temp_44 = (first)->columns;
#line 133 "TransportModule.cs"
                                double csharp2cuda_temp_45 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_44), column)];
                                (*(csharp2cuda_temp_42) = __dadd_rn(csharp2cuda_temp_43, csharp2cuda_temp_45));
                            }
#line 125 "TransportModule.cs"
                            int* csharp2cuda_temp_34 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_34));
                        }
                    }
#line 135 "TransportModule.cs"
#line 135 "TransportModule.cs"
                    double* csharp2cuda_temp_46 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_46) = total);
#line 136 "TransportModule.cs"
                    break;
                }
#line 138 "TransportModule.cs"
            case 1:
#line 139 "TransportModule.cs"
#line 139 "TransportModule.cs"
                int csharp2cuda_temp_47 = (first)->rows;
#line 139 "TransportModule.cs"
                int csharp2cuda_temp_48 = (second)->rows;
#line 139 "TransportModule.cs"
                bool csharp2cuda_temp_49;
#line 139 "TransportModule.cs"
                if (!(((csharp2cuda_temp_47) != (csharp2cuda_temp_48))))
                {
#line 139 "TransportModule.cs"
                    int csharp2cuda_temp_50 = (first)->columns;
#line 139 "TransportModule.cs"
                    int csharp2cuda_temp_51 = (second)->columns;
#line 139 "TransportModule.cs"
                    csharp2cuda_temp_49 = ((csharp2cuda_temp_50) != (csharp2cuda_temp_51));
                }
                else
                {
#line 139 "TransportModule.cs"
                    csharp2cuda_temp_49 = true;
                }
                if (csharp2cuda_temp_49)
#line 140 "TransportModule.cs"
                {
#line 141 "TransportModule.cs"
#line 141 "TransportModule.cs"
                    int* csharp2cuda_temp_52 = &((output)->valid);
                    (*(csharp2cuda_temp_52) = 0);
#line 142 "TransportModule.cs"
                    break;
                }
#line 144 "TransportModule.cs"
                {
#line 145 "TransportModule.cs"
                    double total = 0.0;
#line 146 "TransportModule.cs"
                    {
#line 146 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 146 "TransportModule.cs"
                            int csharp2cuda_temp_54 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_54))))
                                break;
#line 147 "TransportModule.cs"
                            {
#line 147 "TransportModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 147 "TransportModule.cs"
                                    int csharp2cuda_temp_56 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_56))))
                                        break;
#line 148 "TransportModule.cs"
#line 148 "TransportModule.cs"
                                    double* csharp2cuda_temp_57 = &(total);
#line 148 "TransportModule.cs"
                                    double csharp2cuda_temp_58 = *(csharp2cuda_temp_57);
#line 148 "TransportModule.cs"
                                    int csharp2cuda_temp_59 = (first)->columns;
#line 148 "TransportModule.cs"
                                    double csharp2cuda_temp_60 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_59), column)];
#line 149 "TransportModule.cs"
                                    int csharp2cuda_temp_61 = (first)->columns;
#line 149 "TransportModule.cs"
                                    double csharp2cuda_temp_62 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_61), column)];
                                    (*(csharp2cuda_temp_57) = __dadd_rn(csharp2cuda_temp_58, __dmul_rn(csharp2cuda_temp_60, csharp2cuda_temp_62)));
#line 147 "TransportModule.cs"
                                    int* csharp2cuda_temp_55 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_55));
                                }
                            }
#line 146 "TransportModule.cs"
                            int* csharp2cuda_temp_53 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_53));
                        }
                    }
#line 150 "TransportModule.cs"
#line 150 "TransportModule.cs"
                    double* csharp2cuda_temp_63 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_63) = total);
#line 151 "TransportModule.cs"
                    break;
                }
#line 153 "TransportModule.cs"
            case 2:
#line 154 "TransportModule.cs"
#line 154 "TransportModule.cs"
                int csharp2cuda_temp_64 = (first)->count;
#line 154 "TransportModule.cs"
                bool csharp2cuda_temp_65;
#line 154 "TransportModule.cs"
                if (!(((csharp2cuda_temp_64) <= (0))))
                {
#line 154 "TransportModule.cs"
                    int csharp2cuda_temp_66 = (second)->count;
#line 154 "TransportModule.cs"
                    csharp2cuda_temp_65 = ((csharp2cuda_temp_66) <= (0));
                }
                else
                {
#line 154 "TransportModule.cs"
                    csharp2cuda_temp_65 = true;
                }
                if (csharp2cuda_temp_65)
#line 155 "TransportModule.cs"
                {
#line 156 "TransportModule.cs"
#line 156 "TransportModule.cs"
                    int* csharp2cuda_temp_67 = &((output)->valid);
                    (*(csharp2cuda_temp_67) = 0);
#line 157 "TransportModule.cs"
                    break;
                }
#line 159 "TransportModule.cs"
                {
#line 161 "TransportModule.cs"
                    int csharp2cuda_temp_68 = (first)->count;
#line 161 "TransportModule.cs"
                    int csharp2cuda_temp_69 = (second)->count;
#line 160 "TransportModule.cs"
                    double cross = mathblocks_transport_mean_pairwise(a, csharp2cuda_temp_68, b, csharp2cuda_temp_69);
#line 163 "TransportModule.cs"
                    int csharp2cuda_temp_70 = (first)->count;
#line 163 "TransportModule.cs"
                    int csharp2cuda_temp_71 = (first)->count;
#line 162 "TransportModule.cs"
                    double left_within = mathblocks_transport_mean_pairwise(a, csharp2cuda_temp_70, a, csharp2cuda_temp_71);
#line 165 "TransportModule.cs"
                    int csharp2cuda_temp_72 = (second)->count;
#line 165 "TransportModule.cs"
                    int csharp2cuda_temp_73 = (second)->count;
#line 164 "TransportModule.cs"
                    double right_within = mathblocks_transport_mean_pairwise(b, csharp2cuda_temp_72, b, csharp2cuda_temp_73);
#line 166 "TransportModule.cs"
                    double squared = __dsub_rn(__dsub_rn(__dmul_rn(2.0, cross), left_within), right_within);
#line 168 "TransportModule.cs"
#line 168 "TransportModule.cs"
                    double* csharp2cuda_temp_74 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_74) = mathblocks_square_root(mathblocks_maximum(squared, 0.0)));
#line 169 "TransportModule.cs"
                    break;
                }
#line 171 "TransportModule.cs"
            case 3:
#line 172 "TransportModule.cs"
#line 172 "TransportModule.cs"
                int csharp2cuda_temp_75 = (first)->rows;
#line 172 "TransportModule.cs"
                int csharp2cuda_temp_76 = (first)->columns;
#line 172 "TransportModule.cs"
                bool csharp2cuda_temp_77;
#line 172 "TransportModule.cs"
                if (!(((csharp2cuda_temp_75) != (csharp2cuda_temp_76))))
                {
#line 172 "TransportModule.cs"
                    int csharp2cuda_temp_78 = (first)->rows;
#line 172 "TransportModule.cs"
                    csharp2cuda_temp_77 = ((csharp2cuda_temp_78) > (20));
                }
                else
                {
#line 172 "TransportModule.cs"
                    csharp2cuda_temp_77 = true;
                }
#line 172 "TransportModule.cs"
                bool csharp2cuda_temp_79;
#line 172 "TransportModule.cs"
                if (!(csharp2cuda_temp_77))
                {
#line 172 "TransportModule.cs"
                    csharp2cuda_temp_79 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 172 "TransportModule.cs"
                    csharp2cuda_temp_79 = true;
                }
                if (csharp2cuda_temp_79)
#line 173 "TransportModule.cs"
                {
#line 174 "TransportModule.cs"
#line 174 "TransportModule.cs"
                    int* csharp2cuda_temp_80 = &((output)->valid);
                    (*(csharp2cuda_temp_80) = 0);
#line 175 "TransportModule.cs"
                    break;
                }
#line 177 "TransportModule.cs"
                {
#line 178 "TransportModule.cs"
                    int size = (first)->rows;
#line 179 "TransportModule.cs"
                    int state_count = csharp2cuda_i32_shl(1, size);
#line 180 "TransportModule.cs"
                    mathblocks_sequence_set_vector_shape(output, size);
#line 181 "TransportModule.cs"
                    double* values = scratch;
#line 182 "TransportModule.cs"
                    int* previous_mask = ((int*)(csharp2cuda_pointer_add(values, state_count)));
#line 183 "TransportModule.cs"
                    int* chosen_column = csharp2cuda_pointer_add(previous_mask, state_count);
#line 184 "TransportModule.cs"
                    {
#line 184 "TransportModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (state_count))))
                                break;
#line 185 "TransportModule.cs"
                            {
#line 186 "TransportModule.cs"
#line 186 "TransportModule.cs"
                                double* csharp2cuda_temp_82 = &((values)[index]);
                                (*(csharp2cuda_temp_82) = mathblocks_positive_infinity());
#line 187 "TransportModule.cs"
#line 187 "TransportModule.cs"
                                int* csharp2cuda_temp_83 = &((previous_mask)[index]);
                                (*(csharp2cuda_temp_83) = 0);
#line 188 "TransportModule.cs"
#line 188 "TransportModule.cs"
                                int* csharp2cuda_temp_84 = &((chosen_column)[index]);
                                (*(csharp2cuda_temp_84) = 0);
                            }
#line 184 "TransportModule.cs"
                            int* csharp2cuda_temp_81 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_81));
                        }
                    }
#line 190 "TransportModule.cs"
#line 190 "TransportModule.cs"
                    double* csharp2cuda_temp_85 = &((values)[0]);
                    (*(csharp2cuda_temp_85) = 0.0);
#line 191 "TransportModule.cs"
                    {
#line 191 "TransportModule.cs"
                        int mask = 0;
                        while (true)
                        {
                            if (!(((mask) < (state_count))))
                                break;
#line 192 "TransportModule.cs"
                            {
#line 193 "TransportModule.cs"
                                int row = mathblocks_advanced_popcount(mask);
#line 194 "TransportModule.cs"
#line 194 "TransportModule.cs"
                                bool csharp2cuda_temp_87;
#line 194 "TransportModule.cs"
                                if (!(((row) >= (size))))
                                {
#line 194 "TransportModule.cs"
                                    double csharp2cuda_temp_88 = (values)[mask];
#line 194 "TransportModule.cs"
                                    csharp2cuda_temp_87 = (!(isfinite(csharp2cuda_temp_88)));
                                }
                                else
                                {
#line 194 "TransportModule.cs"
                                    csharp2cuda_temp_87 = true;
                                }
                                if (csharp2cuda_temp_87)
                                {
#line 195 "TransportModule.cs"
                                    goto csharp2cuda_for_continue_6;
                                }
#line 196 "TransportModule.cs"
                                {
#line 196 "TransportModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
                                        if (!(((column) < (size))))
                                            break;
#line 197 "TransportModule.cs"
                                        {
#line 198 "TransportModule.cs"
                                            if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, column))) != (0)))
                                            {
#line 199 "TransportModule.cs"
                                                goto csharp2cuda_for_continue_5;
                                            }
#line 200 "TransportModule.cs"
                                            int next = csharp2cuda_i32_or(mask, csharp2cuda_i32_shl(1, column));
#line 201 "TransportModule.cs"
                                            double csharp2cuda_temp_90 = (values)[mask];
#line 201 "TransportModule.cs"
                                            double csharp2cuda_temp_91 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
#line 201 "TransportModule.cs"
                                            double candidate = __dadd_rn(csharp2cuda_temp_90, csharp2cuda_temp_91);
#line 202 "TransportModule.cs"
#line 202 "TransportModule.cs"
                                            double csharp2cuda_temp_92 = (values)[next];
                                            if (((candidate) >= (csharp2cuda_temp_92)))
                                            {
#line 203 "TransportModule.cs"
                                                goto csharp2cuda_for_continue_5;
                                            }
#line 204 "TransportModule.cs"
#line 204 "TransportModule.cs"
                                            double* csharp2cuda_temp_93 = &((values)[next]);
                                            (*(csharp2cuda_temp_93) = candidate);
#line 205 "TransportModule.cs"
#line 205 "TransportModule.cs"
                                            int* csharp2cuda_temp_94 = &((previous_mask)[next]);
                                            (*(csharp2cuda_temp_94) = mask);
#line 206 "TransportModule.cs"
#line 206 "TransportModule.cs"
                                            int* csharp2cuda_temp_95 = &((chosen_column)[next]);
                                            (*(csharp2cuda_temp_95) = column);
                                        }
                                        csharp2cuda_for_continue_5:
#line 196 "TransportModule.cs"
                                        int* csharp2cuda_temp_89 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_89));
                                    }
                                }
                            }
                            csharp2cuda_for_continue_6:
#line 191 "TransportModule.cs"
                            int* csharp2cuda_temp_86 = &(mask);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_86));
                        }
                    }
#line 209 "TransportModule.cs"
                    int current = csharp2cuda_i32_sub(state_count, 1);
#line 210 "TransportModule.cs"
                    {
#line 210 "TransportModule.cs"
                        int row = csharp2cuda_i32_sub(size, 1);
                        while (true)
                        {
                            if (!(((row) >= (0))))
                                break;
#line 211 "TransportModule.cs"
                            {
#line 212 "TransportModule.cs"
#line 212 "TransportModule.cs"
                                double* csharp2cuda_temp_97 = &((result)[row]);
#line 212 "TransportModule.cs"
                                int csharp2cuda_temp_98 = (chosen_column)[current];
                                (*(csharp2cuda_temp_97) = ((double)(csharp2cuda_temp_98)));
#line 213 "TransportModule.cs"
#line 213 "TransportModule.cs"
                                int* csharp2cuda_temp_99 = &(current);
#line 213 "TransportModule.cs"
                                int csharp2cuda_temp_100 = (previous_mask)[current];
                                (*(csharp2cuda_temp_99) = csharp2cuda_temp_100);
                            }
#line 210 "TransportModule.cs"
                            int* csharp2cuda_temp_96 = &(row);
                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_96));
                        }
                    }
#line 215 "TransportModule.cs"
                    break;
                }
#line 217 "TransportModule.cs"
            case 4:
#line 218 "TransportModule.cs"
#line 218 "TransportModule.cs"
                int csharp2cuda_temp_101 = (first)->count;
#line 218 "TransportModule.cs"
                int csharp2cuda_temp_102 = (second)->count;
                mathblocks_sequence_set_matrix_shape(output, csharp2cuda_temp_101, csharp2cuda_temp_102);
#line 219 "TransportModule.cs"
#line 219 "TransportModule.cs"
                int csharp2cuda_temp_103 = (first)->count;
#line 219 "TransportModule.cs"
                bool csharp2cuda_temp_104;
#line 219 "TransportModule.cs"
                if (!((!(mathblocks_advanced_distribution(a, csharp2cuda_temp_103)))))
                {
#line 220 "TransportModule.cs"
                    int csharp2cuda_temp_105 = (second)->count;
#line 219 "TransportModule.cs"
                    csharp2cuda_temp_104 = (!(mathblocks_advanced_distribution(b, csharp2cuda_temp_105)));
                }
                else
                {
#line 219 "TransportModule.cs"
                    csharp2cuda_temp_104 = true;
                }
                if (csharp2cuda_temp_104)
#line 221 "TransportModule.cs"
                {
#line 222 "TransportModule.cs"
#line 222 "TransportModule.cs"
                    int* csharp2cuda_temp_106 = &((output)->valid);
                    (*(csharp2cuda_temp_106) = 0);
#line 223 "TransportModule.cs"
                    break;
                }
#line 225 "TransportModule.cs"
                {
#line 225 "TransportModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 225 "TransportModule.cs"
                        int csharp2cuda_temp_108 = (output)->count;
                        if (!(((index) < (csharp2cuda_temp_108))))
                            break;
#line 226 "TransportModule.cs"
#line 226 "TransportModule.cs"
                        double* csharp2cuda_temp_109 = &((result)[index]);
                        (*(csharp2cuda_temp_109) = 0.0);
#line 225 "TransportModule.cs"
                        int* csharp2cuda_temp_107 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_107));
                    }
                }
#line 227 "TransportModule.cs"
                {
#line 228 "TransportModule.cs"
                    int left_index = 0;
#line 229 "TransportModule.cs"
                    int right_index = 0;
#line 230 "TransportModule.cs"
                    double left_remaining = (a)[0];
#line 231 "TransportModule.cs"
                    double right_remaining = (b)[0];
#line 232 "TransportModule.cs"
                    while (true)
                    {
#line 232 "TransportModule.cs"
                        int csharp2cuda_temp_110 = (first)->count;
#line 232 "TransportModule.cs"
                        bool csharp2cuda_temp_111;
#line 232 "TransportModule.cs"
                        if (((left_index) < (csharp2cuda_temp_110)))
                        {
#line 232 "TransportModule.cs"
                            int csharp2cuda_temp_112 = (second)->count;
#line 232 "TransportModule.cs"
                            csharp2cuda_temp_111 = ((right_index) < (csharp2cuda_temp_112));
                        }
                        else
                        {
#line 232 "TransportModule.cs"
                            csharp2cuda_temp_111 = false;
                        }
                        if (!(csharp2cuda_temp_111))
                            break;
#line 233 "TransportModule.cs"
                        {
#line 234 "TransportModule.cs"
                            double csharp2cuda_temp_113;
#line 234 "TransportModule.cs"
                            if (((left_remaining) < (right_remaining)))
                            {
#line 234 "TransportModule.cs"
                                csharp2cuda_temp_113 = left_remaining;
                            }
                            else
                            {
#line 234 "TransportModule.cs"
                                csharp2cuda_temp_113 = right_remaining;
                            }
#line 234 "TransportModule.cs"
                            double amount = csharp2cuda_temp_113;
#line 237 "TransportModule.cs"
#line 237 "TransportModule.cs"
                            int csharp2cuda_temp_114 = (second)->count;
#line 237 "TransportModule.cs"
                            double* csharp2cuda_temp_115 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left_index, csharp2cuda_temp_114), right_index)]);
#line 237 "TransportModule.cs"
                            double csharp2cuda_temp_116 = *(csharp2cuda_temp_115);
                            (*(csharp2cuda_temp_115) = __dadd_rn(csharp2cuda_temp_116, amount));
#line 238 "TransportModule.cs"
#line 238 "TransportModule.cs"
                            double* csharp2cuda_temp_117 = &(left_remaining);
#line 238 "TransportModule.cs"
                            double csharp2cuda_temp_118 = *(csharp2cuda_temp_117);
                            (*(csharp2cuda_temp_117) = __dsub_rn(csharp2cuda_temp_118, amount));
#line 239 "TransportModule.cs"
#line 239 "TransportModule.cs"
                            double* csharp2cuda_temp_119 = &(right_remaining);
#line 239 "TransportModule.cs"
                            double csharp2cuda_temp_120 = *(csharp2cuda_temp_119);
                            (*(csharp2cuda_temp_119) = __dsub_rn(csharp2cuda_temp_120, amount));
#line 240 "TransportModule.cs"
#line 240 "TransportModule.cs"
                            bool csharp2cuda_temp_121;
#line 240 "TransportModule.cs"
                            if (((left_remaining) == (0.0)))
                            {
#line 240 "TransportModule.cs"
                                int* csharp2cuda_temp_122 = &(left_index);
#line 240 "TransportModule.cs"
                                int csharp2cuda_temp_123 = csharp2cuda_i32_pre_increment(*(csharp2cuda_temp_122));
#line 240 "TransportModule.cs"
                                int csharp2cuda_temp_124 = (first)->count;
#line 240 "TransportModule.cs"
                                csharp2cuda_temp_121 = ((csharp2cuda_temp_123) < (csharp2cuda_temp_124));
                            }
                            else
                            {
#line 240 "TransportModule.cs"
                                csharp2cuda_temp_121 = false;
                            }
                            if (csharp2cuda_temp_121)
                            {
#line 241 "TransportModule.cs"
#line 241 "TransportModule.cs"
                                double* csharp2cuda_temp_125 = &(left_remaining);
#line 241 "TransportModule.cs"
                                double csharp2cuda_temp_126 = (a)[left_index];
                                (*(csharp2cuda_temp_125) = csharp2cuda_temp_126);
                            }
#line 242 "TransportModule.cs"
#line 242 "TransportModule.cs"
                            bool csharp2cuda_temp_127;
#line 242 "TransportModule.cs"
                            if (((right_remaining) == (0.0)))
                            {
#line 242 "TransportModule.cs"
                                int* csharp2cuda_temp_128 = &(right_index);
#line 242 "TransportModule.cs"
                                int csharp2cuda_temp_129 = csharp2cuda_i32_pre_increment(*(csharp2cuda_temp_128));
#line 242 "TransportModule.cs"
                                int csharp2cuda_temp_130 = (second)->count;
#line 242 "TransportModule.cs"
                                csharp2cuda_temp_127 = ((csharp2cuda_temp_129) < (csharp2cuda_temp_130));
                            }
                            else
                            {
#line 242 "TransportModule.cs"
                                csharp2cuda_temp_127 = false;
                            }
                            if (csharp2cuda_temp_127)
                            {
#line 243 "TransportModule.cs"
#line 243 "TransportModule.cs"
                                double* csharp2cuda_temp_131 = &(right_remaining);
#line 243 "TransportModule.cs"
                                double csharp2cuda_temp_132 = (b)[right_index];
                                (*(csharp2cuda_temp_131) = csharp2cuda_temp_132);
                            }
                        }
                    }
#line 245 "TransportModule.cs"
                    break;
                }
#line 247 "TransportModule.cs"
            case 5:
#line 248 "TransportModule.cs"
#line 248 "TransportModule.cs"
                int csharp2cuda_temp_133 = (first)->count;
#line 248 "TransportModule.cs"
                int csharp2cuda_temp_134 = (second)->count;
#line 248 "TransportModule.cs"
                bool csharp2cuda_temp_135;
#line 248 "TransportModule.cs"
                if (!(((csharp2cuda_temp_133) != (csharp2cuda_temp_134))))
                {
#line 249 "TransportModule.cs"
                    int csharp2cuda_temp_136 = (first)->count;
#line 248 "TransportModule.cs"
                    csharp2cuda_temp_135 = (!(mathblocks_advanced_distribution(a, csharp2cuda_temp_136)));
                }
                else
                {
#line 248 "TransportModule.cs"
                    csharp2cuda_temp_135 = true;
                }
#line 248 "TransportModule.cs"
                bool csharp2cuda_temp_137;
#line 248 "TransportModule.cs"
                if (!(csharp2cuda_temp_135))
                {
#line 250 "TransportModule.cs"
                    int csharp2cuda_temp_138 = (second)->count;
#line 248 "TransportModule.cs"
                    csharp2cuda_temp_137 = (!(mathblocks_advanced_distribution(b, csharp2cuda_temp_138)));
                }
                else
                {
#line 248 "TransportModule.cs"
                    csharp2cuda_temp_137 = true;
                }
                if (csharp2cuda_temp_137)
#line 251 "TransportModule.cs"
                {
#line 252 "TransportModule.cs"
#line 252 "TransportModule.cs"
                    int* csharp2cuda_temp_139 = &((output)->valid);
                    (*(csharp2cuda_temp_139) = 0);
#line 253 "TransportModule.cs"
                    break;
                }
#line 255 "TransportModule.cs"
                {
#line 256 "TransportModule.cs"
                    double cumulative = 0.0;
#line 257 "TransportModule.cs"
                    double total = 0.0;
#line 258 "TransportModule.cs"
                    {
#line 258 "TransportModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 258 "TransportModule.cs"
                            int csharp2cuda_temp_141 = (first)->count;
                            if (!(((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_141, 1)))))
                                break;
#line 259 "TransportModule.cs"
                            {
#line 260 "TransportModule.cs"
#line 260 "TransportModule.cs"
                                double* csharp2cuda_temp_142 = &(cumulative);
#line 260 "TransportModule.cs"
                                double csharp2cuda_temp_143 = *(csharp2cuda_temp_142);
#line 260 "TransportModule.cs"
                                double csharp2cuda_temp_144 = (a)[index];
#line 260 "TransportModule.cs"
                                double csharp2cuda_temp_145 = (b)[index];
                                (*(csharp2cuda_temp_142) = __dadd_rn(csharp2cuda_temp_143, __dsub_rn(csharp2cuda_temp_144, csharp2cuda_temp_145)));
#line 261 "TransportModule.cs"
#line 261 "TransportModule.cs"
                                double* csharp2cuda_temp_146 = &(total);
#line 261 "TransportModule.cs"
                                double csharp2cuda_temp_147 = *(csharp2cuda_temp_146);
                                (*(csharp2cuda_temp_146) = __dadd_rn(csharp2cuda_temp_147, fabs(cumulative)));
                            }
#line 258 "TransportModule.cs"
                            int* csharp2cuda_temp_140 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_140));
                        }
                    }
#line 263 "TransportModule.cs"
#line 263 "TransportModule.cs"
                    double* csharp2cuda_temp_148 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_148) = total);
#line 264 "TransportModule.cs"
                    break;
                }
#line 266 "TransportModule.cs"
            case 6:
#line 267 "TransportModule.cs"
#line 267 "TransportModule.cs"
                int csharp2cuda_temp_149 = (first)->rows;
#line 267 "TransportModule.cs"
                int csharp2cuda_temp_150 = (first)->columns;
                mathblocks_sequence_set_matrix_shape(output, csharp2cuda_temp_149, csharp2cuda_temp_150);
#line 268 "TransportModule.cs"
#line 268 "TransportModule.cs"
                int csharp2cuda_temp_151 = (first)->rows;
#line 268 "TransportModule.cs"
                int csharp2cuda_temp_152 = (second)->count;
#line 268 "TransportModule.cs"
                bool csharp2cuda_temp_153;
#line 268 "TransportModule.cs"
                if (!(((csharp2cuda_temp_151) != (csharp2cuda_temp_152))))
                {
#line 268 "TransportModule.cs"
                    int csharp2cuda_temp_154 = (first)->columns;
#line 268 "TransportModule.cs"
                    int csharp2cuda_temp_155 = (third)->count;
#line 268 "TransportModule.cs"
                    csharp2cuda_temp_153 = ((csharp2cuda_temp_154) != (csharp2cuda_temp_155));
                }
                else
                {
#line 268 "TransportModule.cs"
                    csharp2cuda_temp_153 = true;
                }
#line 268 "TransportModule.cs"
                bool csharp2cuda_temp_156;
#line 268 "TransportModule.cs"
                if (!(csharp2cuda_temp_153))
                {
#line 269 "TransportModule.cs"
                    int csharp2cuda_temp_157 = (second)->count;
#line 268 "TransportModule.cs"
                    csharp2cuda_temp_156 = (!(mathblocks_advanced_distribution(b, csharp2cuda_temp_157)));
                }
                else
                {
#line 268 "TransportModule.cs"
                    csharp2cuda_temp_156 = true;
                }
#line 268 "TransportModule.cs"
                bool csharp2cuda_temp_158;
#line 268 "TransportModule.cs"
                if (!(csharp2cuda_temp_156))
                {
#line 270 "TransportModule.cs"
                    int csharp2cuda_temp_159 = (third)->count;
#line 268 "TransportModule.cs"
                    csharp2cuda_temp_158 = (!(mathblocks_advanced_distribution(c, csharp2cuda_temp_159)));
                }
                else
                {
#line 268 "TransportModule.cs"
                    csharp2cuda_temp_158 = true;
                }
#line 268 "TransportModule.cs"
                bool csharp2cuda_temp_160;
#line 268 "TransportModule.cs"
                if (!(csharp2cuda_temp_158))
                {
#line 271 "TransportModule.cs"
                    double csharp2cuda_temp_161 = (fourth)->scalar_value;
#line 268 "TransportModule.cs"
                    csharp2cuda_temp_160 = ((csharp2cuda_temp_161) <= (0.0));
                }
                else
                {
#line 268 "TransportModule.cs"
                    csharp2cuda_temp_160 = true;
                }
#line 268 "TransportModule.cs"
                bool csharp2cuda_temp_162;
#line 268 "TransportModule.cs"
                if (!(csharp2cuda_temp_160))
                {
#line 268 "TransportModule.cs"
                    csharp2cuda_temp_162 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 268 "TransportModule.cs"
                    csharp2cuda_temp_162 = true;
                }
                if (csharp2cuda_temp_162)
#line 272 "TransportModule.cs"
                {
#line 273 "TransportModule.cs"
#line 273 "TransportModule.cs"
                    int* csharp2cuda_temp_163 = &((output)->valid);
                    (*(csharp2cuda_temp_163) = 0);
#line 274 "TransportModule.cs"
                    break;
                }
#line 276 "TransportModule.cs"
                {
#line 277 "TransportModule.cs"
                    int iterations = 0;
#line 278 "TransportModule.cs"
#line 278 "TransportModule.cs"
                    double csharp2cuda_temp_164 = (fifth)->scalar_value;
#line 278 "TransportModule.cs"
                    int* csharp2cuda_temp_165 = &(iterations);
#line 278 "TransportModule.cs"
                    bool csharp2cuda_temp_166 = mathblocks_sequence_positive_integer(csharp2cuda_temp_164, csharp2cuda_temp_165);
#line 278 "TransportModule.cs"
                    bool csharp2cuda_temp_167;
#line 278 "TransportModule.cs"
                    if (!((!(csharp2cuda_temp_166))))
                    {
#line 278 "TransportModule.cs"
                        csharp2cuda_temp_167 = ((iterations) > (10000));
                    }
                    else
                    {
#line 278 "TransportModule.cs"
                        csharp2cuda_temp_167 = true;
                    }
                    if (csharp2cuda_temp_167)
#line 279 "TransportModule.cs"
                    {
#line 280 "TransportModule.cs"
#line 280 "TransportModule.cs"
                        int* csharp2cuda_temp_168 = &((output)->valid);
                        (*(csharp2cuda_temp_168) = 0);
#line 281 "TransportModule.cs"
                        break;
                    }
#line 283 "TransportModule.cs"
                    double* kernel = scratch;
#line 284 "TransportModule.cs"
                    int csharp2cuda_temp_169 = (first)->count;
#line 284 "TransportModule.cs"
                    double* left_scale = csharp2cuda_pointer_add(kernel, csharp2cuda_temp_169);
#line 285 "TransportModule.cs"
                    int csharp2cuda_temp_170 = (first)->rows;
#line 285 "TransportModule.cs"
                    double* right_scale = csharp2cuda_pointer_add(left_scale, csharp2cuda_temp_170);
#line 286 "TransportModule.cs"
                    {
#line 286 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 286 "TransportModule.cs"
                            int csharp2cuda_temp_172 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_172))))
                                break;
#line 287 "TransportModule.cs"
                            {
#line 287 "TransportModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 287 "TransportModule.cs"
                                    int csharp2cuda_temp_174 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_174))))
                                        break;
#line 288 "TransportModule.cs"
#line 288 "TransportModule.cs"
                                    int csharp2cuda_temp_175 = (first)->columns;
#line 288 "TransportModule.cs"
                                    double* csharp2cuda_temp_176 = &((kernel)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_175), column)]);
#line 289 "TransportModule.cs"
                                    int csharp2cuda_temp_177 = (first)->columns;
#line 289 "TransportModule.cs"
                                    double csharp2cuda_temp_178 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_177), column)];
#line 290 "TransportModule.cs"
                                    double csharp2cuda_temp_179 = (fourth)->scalar_value;
#line 289 "TransportModule.cs"
                                    double csharp2cuda_temp_180 = __ddiv_rn((-(csharp2cuda_temp_178)), csharp2cuda_temp_179);
                                    (*(csharp2cuda_temp_176) = mathblocks_exponential(csharp2cuda_temp_180));
#line 287 "TransportModule.cs"
                                    int* csharp2cuda_temp_173 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_173));
                                }
                            }
#line 286 "TransportModule.cs"
                            int* csharp2cuda_temp_171 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_171));
                        }
                    }
#line 291 "TransportModule.cs"
                    {
#line 291 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 291 "TransportModule.cs"
                            int csharp2cuda_temp_182 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_182))))
                                break;
#line 292 "TransportModule.cs"
#line 292 "TransportModule.cs"
                            double* csharp2cuda_temp_183 = &((left_scale)[row]);
                            (*(csharp2cuda_temp_183) = 1.0);
#line 291 "TransportModule.cs"
                            int* csharp2cuda_temp_181 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_181));
                        }
                    }
#line 293 "TransportModule.cs"
                    {
#line 293 "TransportModule.cs"
                        int column = 0;
                        while (true)
                        {
#line 293 "TransportModule.cs"
                            int csharp2cuda_temp_185 = (first)->columns;
                            if (!(((column) < (csharp2cuda_temp_185))))
                                break;
#line 294 "TransportModule.cs"
#line 294 "TransportModule.cs"
                            double* csharp2cuda_temp_186 = &((right_scale)[column]);
                            (*(csharp2cuda_temp_186) = 1.0);
#line 293 "TransportModule.cs"
                            int* csharp2cuda_temp_184 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_184));
                        }
                    }
#line 295 "TransportModule.cs"
                    {
#line 295 "TransportModule.cs"
                        int iteration = 0;
                        while (true)
                        {
                            if (!(((iteration) < (iterations))))
                                break;
#line 296 "TransportModule.cs"
                            {
#line 297 "TransportModule.cs"
                                {
#line 297 "TransportModule.cs"
                                    int row = 0;
                                    while (true)
                                    {
#line 297 "TransportModule.cs"
                                        int csharp2cuda_temp_189 = (first)->rows;
                                        if (!(((row) < (csharp2cuda_temp_189))))
                                            break;
#line 298 "TransportModule.cs"
                                        {
#line 299 "TransportModule.cs"
                                            double sum = 0.0;
#line 300 "TransportModule.cs"
                                            {
#line 300 "TransportModule.cs"
                                                int column = 0;
                                                while (true)
                                                {
#line 300 "TransportModule.cs"
                                                    int csharp2cuda_temp_191 = (first)->columns;
                                                    if (!(((column) < (csharp2cuda_temp_191))))
                                                        break;
#line 301 "TransportModule.cs"
#line 301 "TransportModule.cs"
                                                    double* csharp2cuda_temp_192 = &(sum);
#line 301 "TransportModule.cs"
                                                    double csharp2cuda_temp_193 = *(csharp2cuda_temp_192);
#line 301 "TransportModule.cs"
                                                    int csharp2cuda_temp_194 = (first)->columns;
#line 301 "TransportModule.cs"
                                                    double csharp2cuda_temp_195 = (kernel)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_194), column)];
#line 301 "TransportModule.cs"
                                                    double csharp2cuda_temp_196 = (right_scale)[column];
                                                    (*(csharp2cuda_temp_192) = __dadd_rn(csharp2cuda_temp_193, __dmul_rn(csharp2cuda_temp_195, csharp2cuda_temp_196)));
#line 300 "TransportModule.cs"
                                                    int* csharp2cuda_temp_190 = &(column);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_190));
                                                }
                                            }
#line 302 "TransportModule.cs"
#line 302 "TransportModule.cs"
                                            double* csharp2cuda_temp_197 = &((left_scale)[row]);
#line 302 "TransportModule.cs"
                                            double csharp2cuda_temp_198 = (b)[row];
#line 302 "TransportModule.cs"
                                            double csharp2cuda_temp_199 = __ddiv_rn(csharp2cuda_temp_198, sum);
                                            (*(csharp2cuda_temp_197) = csharp2cuda_temp_199);
                                        }
#line 297 "TransportModule.cs"
                                        int* csharp2cuda_temp_188 = &(row);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_188));
                                    }
                                }
#line 304 "TransportModule.cs"
                                {
#line 304 "TransportModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
#line 304 "TransportModule.cs"
                                        int csharp2cuda_temp_201 = (first)->columns;
                                        if (!(((column) < (csharp2cuda_temp_201))))
                                            break;
#line 305 "TransportModule.cs"
                                        {
#line 306 "TransportModule.cs"
                                            double sum = 0.0;
#line 307 "TransportModule.cs"
                                            {
#line 307 "TransportModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
#line 307 "TransportModule.cs"
                                                    int csharp2cuda_temp_203 = (first)->rows;
                                                    if (!(((row) < (csharp2cuda_temp_203))))
                                                        break;
#line 308 "TransportModule.cs"
#line 308 "TransportModule.cs"
                                                    double* csharp2cuda_temp_204 = &(sum);
#line 308 "TransportModule.cs"
                                                    double csharp2cuda_temp_205 = *(csharp2cuda_temp_204);
#line 308 "TransportModule.cs"
                                                    int csharp2cuda_temp_206 = (first)->columns;
#line 308 "TransportModule.cs"
                                                    double csharp2cuda_temp_207 = (kernel)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_206), column)];
#line 308 "TransportModule.cs"
                                                    double csharp2cuda_temp_208 = (left_scale)[row];
                                                    (*(csharp2cuda_temp_204) = __dadd_rn(csharp2cuda_temp_205, __dmul_rn(csharp2cuda_temp_207, csharp2cuda_temp_208)));
#line 307 "TransportModule.cs"
                                                    int* csharp2cuda_temp_202 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_202));
                                                }
                                            }
#line 309 "TransportModule.cs"
#line 309 "TransportModule.cs"
                                            double* csharp2cuda_temp_209 = &((right_scale)[column]);
#line 309 "TransportModule.cs"
                                            double csharp2cuda_temp_210 = (c)[column];
#line 309 "TransportModule.cs"
                                            double csharp2cuda_temp_211 = __ddiv_rn(csharp2cuda_temp_210, sum);
                                            (*(csharp2cuda_temp_209) = csharp2cuda_temp_211);
                                        }
#line 304 "TransportModule.cs"
                                        int* csharp2cuda_temp_200 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_200));
                                    }
                                }
                            }
#line 295 "TransportModule.cs"
                            int* csharp2cuda_temp_187 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_187));
                        }
                    }
#line 312 "TransportModule.cs"
                    {
#line 312 "TransportModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 312 "TransportModule.cs"
                            int csharp2cuda_temp_213 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_213))))
                                break;
#line 313 "TransportModule.cs"
                            {
#line 313 "TransportModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 313 "TransportModule.cs"
                                    int csharp2cuda_temp_215 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_215))))
                                        break;
#line 314 "TransportModule.cs"
#line 314 "TransportModule.cs"
                                    int csharp2cuda_temp_216 = (first)->columns;
#line 314 "TransportModule.cs"
                                    double* csharp2cuda_temp_217 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_216), column)]);
#line 315 "TransportModule.cs"
                                    double csharp2cuda_temp_218 = (left_scale)[row];
#line 315 "TransportModule.cs"
                                    int csharp2cuda_temp_219 = (first)->columns;
#line 315 "TransportModule.cs"
                                    double csharp2cuda_temp_220 = (kernel)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_219), column)];
#line 316 "TransportModule.cs"
                                    double csharp2cuda_temp_221 = (right_scale)[column];
                                    (*(csharp2cuda_temp_217) = __dmul_rn(__dmul_rn(csharp2cuda_temp_218, csharp2cuda_temp_220), csharp2cuda_temp_221));
#line 313 "TransportModule.cs"
                                    int* csharp2cuda_temp_214 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_214));
                                }
                            }
#line 312 "TransportModule.cs"
                            int* csharp2cuda_temp_212 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_212));
                        }
                    }
#line 317 "TransportModule.cs"
                    break;
                }
#line 319 "TransportModule.cs"
            case 7:
#line 320 "TransportModule.cs"
#line 320 "TransportModule.cs"
                int csharp2cuda_temp_222 = (first)->count;
#line 320 "TransportModule.cs"
                bool csharp2cuda_temp_223;
#line 320 "TransportModule.cs"
                if (!(((csharp2cuda_temp_222) <= (0))))
                {
#line 320 "TransportModule.cs"
                    int csharp2cuda_temp_224 = (first)->count;
#line 320 "TransportModule.cs"
                    int csharp2cuda_temp_225 = (second)->count;
#line 320 "TransportModule.cs"
                    csharp2cuda_temp_223 = ((csharp2cuda_temp_224) != (csharp2cuda_temp_225));
                }
                else
                {
#line 320 "TransportModule.cs"
                    csharp2cuda_temp_223 = true;
                }
#line 320 "TransportModule.cs"
                bool csharp2cuda_temp_226;
#line 320 "TransportModule.cs"
                if (!(csharp2cuda_temp_223))
                {
#line 321 "TransportModule.cs"
                    double csharp2cuda_temp_227 = (third)->scalar_value;
#line 320 "TransportModule.cs"
                    csharp2cuda_temp_226 = ((csharp2cuda_temp_227) < (1.0));
                }
                else
                {
#line 320 "TransportModule.cs"
                    csharp2cuda_temp_226 = true;
                }
#line 320 "TransportModule.cs"
                bool csharp2cuda_temp_228;
#line 320 "TransportModule.cs"
                if (!(csharp2cuda_temp_226))
                {
#line 320 "TransportModule.cs"
                    csharp2cuda_temp_228 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 320 "TransportModule.cs"
                    csharp2cuda_temp_228 = true;
                }
                if (csharp2cuda_temp_228)
#line 322 "TransportModule.cs"
                {
#line 323 "TransportModule.cs"
#line 323 "TransportModule.cs"
                    int* csharp2cuda_temp_229 = &((output)->valid);
                    (*(csharp2cuda_temp_229) = 0);
#line 324 "TransportModule.cs"
                    break;
                }
#line 326 "TransportModule.cs"
                {
#line 327 "TransportModule.cs"
                    double* left_sorted = scratch;
#line 328 "TransportModule.cs"
                    int csharp2cuda_temp_230 = (first)->count;
#line 328 "TransportModule.cs"
                    double* right_sorted = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_230);
#line 329 "TransportModule.cs"
#line 329 "TransportModule.cs"
                    int csharp2cuda_temp_231 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_231, left_sorted, false);
#line 330 "TransportModule.cs"
#line 330 "TransportModule.cs"
                    int csharp2cuda_temp_232 = (second)->count;
                    mathblocks_statistics_sort_copy(b, csharp2cuda_temp_232, right_sorted, false);
#line 331 "TransportModule.cs"
                    double sum = 0.0;
#line 332 "TransportModule.cs"
                    {
#line 332 "TransportModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 332 "TransportModule.cs"
                            int csharp2cuda_temp_234 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_234))))
                                break;
#line 333 "TransportModule.cs"
#line 333 "TransportModule.cs"
                            double* csharp2cuda_temp_235 = &(sum);
#line 333 "TransportModule.cs"
                            double csharp2cuda_temp_236 = *(csharp2cuda_temp_235);
#line 334 "TransportModule.cs"
                            double csharp2cuda_temp_237 = (left_sorted)[index];
#line 334 "TransportModule.cs"
                            double csharp2cuda_temp_238 = (right_sorted)[index];
#line 335 "TransportModule.cs"
                            double csharp2cuda_temp_239 = (third)->scalar_value;
                            (*(csharp2cuda_temp_235) = __dadd_rn(csharp2cuda_temp_236, mathblocks_power(fabs(__dsub_rn(csharp2cuda_temp_237, csharp2cuda_temp_238)), csharp2cuda_temp_239)));
#line 332 "TransportModule.cs"
                            int* csharp2cuda_temp_233 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_233));
                        }
                    }
#line 336 "TransportModule.cs"
#line 336 "TransportModule.cs"
                    double* csharp2cuda_temp_240 = &((output)->scalar_value);
#line 337 "TransportModule.cs"
                    int csharp2cuda_temp_241 = (first)->count;
#line 337 "TransportModule.cs"
                    double csharp2cuda_temp_242 = __ddiv_rn(sum, ((double)(csharp2cuda_temp_241)));
#line 338 "TransportModule.cs"
                    double csharp2cuda_temp_243 = (third)->scalar_value;
#line 338 "TransportModule.cs"
                    double csharp2cuda_temp_244 = __ddiv_rn(1.0, csharp2cuda_temp_243);
                    (*(csharp2cuda_temp_240) = mathblocks_power(csharp2cuda_temp_242, csharp2cuda_temp_244));
#line 339 "TransportModule.cs"
                    break;
                }
#line 341 "TransportModule.cs"
            case 8:
#line 342 "TransportModule.cs"
#line 342 "TransportModule.cs"
                int csharp2cuda_temp_245 = (first)->count;
#line 342 "TransportModule.cs"
                bool csharp2cuda_temp_246;
#line 342 "TransportModule.cs"
                if (!(((csharp2cuda_temp_245) <= (0))))
                {
#line 342 "TransportModule.cs"
                    int csharp2cuda_temp_247 = (first)->count;
#line 342 "TransportModule.cs"
                    int csharp2cuda_temp_248 = (second)->count;
#line 342 "TransportModule.cs"
                    csharp2cuda_temp_246 = ((csharp2cuda_temp_247) != (csharp2cuda_temp_248));
                }
                else
                {
#line 342 "TransportModule.cs"
                    csharp2cuda_temp_246 = true;
                }
#line 342 "TransportModule.cs"
                bool csharp2cuda_temp_249;
#line 342 "TransportModule.cs"
                if (!(csharp2cuda_temp_246))
                {
#line 343 "TransportModule.cs"
                    int csharp2cuda_temp_250 = (third)->count;
#line 342 "TransportModule.cs"
                    csharp2cuda_temp_249 = ((csharp2cuda_temp_250) <= (0));
                }
                else
                {
#line 342 "TransportModule.cs"
                    csharp2cuda_temp_249 = true;
                }
#line 342 "TransportModule.cs"
                bool csharp2cuda_temp_251;
#line 342 "TransportModule.cs"
                if (!(csharp2cuda_temp_249))
                {
#line 343 "TransportModule.cs"
                    int csharp2cuda_temp_252 = (third)->count;
#line 343 "TransportModule.cs"
                    int csharp2cuda_temp_253 = (fourth)->count;
#line 342 "TransportModule.cs"
                    csharp2cuda_temp_251 = ((csharp2cuda_temp_252) != (csharp2cuda_temp_253));
                }
                else
                {
#line 342 "TransportModule.cs"
                    csharp2cuda_temp_251 = true;
                }
#line 342 "TransportModule.cs"
                bool csharp2cuda_temp_254;
#line 342 "TransportModule.cs"
                if (!(csharp2cuda_temp_251))
                {
#line 342 "TransportModule.cs"
                    csharp2cuda_temp_254 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 342 "TransportModule.cs"
                    csharp2cuda_temp_254 = true;
                }
#line 342 "TransportModule.cs"
                bool csharp2cuda_temp_255;
#line 342 "TransportModule.cs"
                if (!(csharp2cuda_temp_254))
                {
#line 344 "TransportModule.cs"
                    int csharp2cuda_temp_256 = (second)->count;
#line 342 "TransportModule.cs"
                    csharp2cuda_temp_255 = (!(mathblocks_advanced_distribution(b, csharp2cuda_temp_256)));
                }
                else
                {
#line 342 "TransportModule.cs"
                    csharp2cuda_temp_255 = true;
                }
#line 342 "TransportModule.cs"
                bool csharp2cuda_temp_257;
#line 342 "TransportModule.cs"
                if (!(csharp2cuda_temp_255))
                {
#line 345 "TransportModule.cs"
                    int csharp2cuda_temp_258 = (fourth)->count;
#line 342 "TransportModule.cs"
                    csharp2cuda_temp_257 = (!(mathblocks_advanced_distribution(d, csharp2cuda_temp_258)));
                }
                else
                {
#line 342 "TransportModule.cs"
                    csharp2cuda_temp_257 = true;
                }
                if (csharp2cuda_temp_257)
#line 346 "TransportModule.cs"
                {
#line 347 "TransportModule.cs"
#line 347 "TransportModule.cs"
                    int* csharp2cuda_temp_259 = &((output)->valid);
                    (*(csharp2cuda_temp_259) = 0);
#line 348 "TransportModule.cs"
                    break;
                }
#line 350 "TransportModule.cs"
                {
#line 351 "TransportModule.cs"
                    int* left_order = ((int*)(scratch));
#line 352 "TransportModule.cs"
                    int csharp2cuda_temp_260 = (first)->count;
#line 352 "TransportModule.cs"
                    int* right_order = csharp2cuda_pointer_add(left_order, csharp2cuda_temp_260);
#line 353 "TransportModule.cs"
                    int csharp2cuda_temp_261 = (third)->count;
#line 353 "TransportModule.cs"
                    int* left_buffer = csharp2cuda_pointer_add(right_order, csharp2cuda_temp_261);
#line 354 "TransportModule.cs"
                    int csharp2cuda_temp_262 = (first)->count;
#line 354 "TransportModule.cs"
                    int* right_buffer = csharp2cuda_pointer_add(left_buffer, csharp2cuda_temp_262);
#line 355 "TransportModule.cs"
#line 355 "TransportModule.cs"
                    int csharp2cuda_temp_263 = (first)->count;
                    mathblocks_stable_index_order(a, csharp2cuda_temp_263, left_order, left_buffer);
#line 356 "TransportModule.cs"
#line 356 "TransportModule.cs"
                    int csharp2cuda_temp_264 = (third)->count;
                    mathblocks_stable_index_order(c, csharp2cuda_temp_264, right_order, right_buffer);
#line 357 "TransportModule.cs"
                    int left_index = 0;
#line 358 "TransportModule.cs"
                    int right_index = 0;
#line 359 "TransportModule.cs"
                    int csharp2cuda_temp_265 = (left_order)[0];
#line 359 "TransportModule.cs"
                    double left_remaining = (b)[csharp2cuda_temp_265];
#line 360 "TransportModule.cs"
                    int csharp2cuda_temp_266 = (right_order)[0];
#line 360 "TransportModule.cs"
                    double right_remaining = (d)[csharp2cuda_temp_266];
#line 361 "TransportModule.cs"
                    double total = 0.0;
#line 362 "TransportModule.cs"
                    while (true)
                    {
#line 362 "TransportModule.cs"
                        int csharp2cuda_temp_267 = (first)->count;
#line 362 "TransportModule.cs"
                        bool csharp2cuda_temp_268;
#line 362 "TransportModule.cs"
                        if (((left_index) < (csharp2cuda_temp_267)))
                        {
#line 362 "TransportModule.cs"
                            int csharp2cuda_temp_269 = (third)->count;
#line 362 "TransportModule.cs"
                            csharp2cuda_temp_268 = ((right_index) < (csharp2cuda_temp_269));
                        }
                        else
                        {
#line 362 "TransportModule.cs"
                            csharp2cuda_temp_268 = false;
                        }
                        if (!(csharp2cuda_temp_268))
                            break;
#line 363 "TransportModule.cs"
                        {
#line 364 "TransportModule.cs"
                            double csharp2cuda_temp_270;
#line 364 "TransportModule.cs"
                            if (((left_remaining) < (right_remaining)))
                            {
#line 364 "TransportModule.cs"
                                csharp2cuda_temp_270 = left_remaining;
                            }
                            else
                            {
#line 364 "TransportModule.cs"
                                csharp2cuda_temp_270 = right_remaining;
                            }
#line 364 "TransportModule.cs"
                            double amount = csharp2cuda_temp_270;
#line 367 "TransportModule.cs"
#line 367 "TransportModule.cs"
                            double* csharp2cuda_temp_271 = &(total);
#line 367 "TransportModule.cs"
                            double csharp2cuda_temp_272 = *(csharp2cuda_temp_271);
#line 368 "TransportModule.cs"
                            int csharp2cuda_temp_273 = (left_order)[left_index];
#line 368 "TransportModule.cs"
                            double csharp2cuda_temp_274 = (a)[csharp2cuda_temp_273];
#line 368 "TransportModule.cs"
                            int csharp2cuda_temp_275 = (right_order)[right_index];
#line 368 "TransportModule.cs"
                            double csharp2cuda_temp_276 = (c)[csharp2cuda_temp_275];
                            (*(csharp2cuda_temp_271) = __dadd_rn(csharp2cuda_temp_272, __dmul_rn(amount, fabs(__dsub_rn(csharp2cuda_temp_274, csharp2cuda_temp_276)))));
#line 369 "TransportModule.cs"
#line 369 "TransportModule.cs"
                            double* csharp2cuda_temp_277 = &(left_remaining);
#line 369 "TransportModule.cs"
                            double csharp2cuda_temp_278 = *(csharp2cuda_temp_277);
                            (*(csharp2cuda_temp_277) = __dsub_rn(csharp2cuda_temp_278, amount));
#line 370 "TransportModule.cs"
#line 370 "TransportModule.cs"
                            double* csharp2cuda_temp_279 = &(right_remaining);
#line 370 "TransportModule.cs"
                            double csharp2cuda_temp_280 = *(csharp2cuda_temp_279);
                            (*(csharp2cuda_temp_279) = __dsub_rn(csharp2cuda_temp_280, amount));
#line 371 "TransportModule.cs"
#line 371 "TransportModule.cs"
                            bool csharp2cuda_temp_281;
#line 371 "TransportModule.cs"
                            if (((left_remaining) == (0.0)))
                            {
#line 371 "TransportModule.cs"
                                int* csharp2cuda_temp_282 = &(left_index);
#line 371 "TransportModule.cs"
                                int csharp2cuda_temp_283 = csharp2cuda_i32_pre_increment(*(csharp2cuda_temp_282));
#line 371 "TransportModule.cs"
                                int csharp2cuda_temp_284 = (first)->count;
#line 371 "TransportModule.cs"
                                csharp2cuda_temp_281 = ((csharp2cuda_temp_283) < (csharp2cuda_temp_284));
                            }
                            else
                            {
#line 371 "TransportModule.cs"
                                csharp2cuda_temp_281 = false;
                            }
                            if (csharp2cuda_temp_281)
                            {
#line 372 "TransportModule.cs"
#line 372 "TransportModule.cs"
                                double* csharp2cuda_temp_285 = &(left_remaining);
#line 372 "TransportModule.cs"
                                int csharp2cuda_temp_286 = (left_order)[left_index];
#line 372 "TransportModule.cs"
                                double csharp2cuda_temp_287 = (b)[csharp2cuda_temp_286];
                                (*(csharp2cuda_temp_285) = csharp2cuda_temp_287);
                            }
#line 373 "TransportModule.cs"
#line 373 "TransportModule.cs"
                            bool csharp2cuda_temp_288;
#line 373 "TransportModule.cs"
                            if (((right_remaining) == (0.0)))
                            {
#line 373 "TransportModule.cs"
                                int* csharp2cuda_temp_289 = &(right_index);
#line 373 "TransportModule.cs"
                                int csharp2cuda_temp_290 = csharp2cuda_i32_pre_increment(*(csharp2cuda_temp_289));
#line 373 "TransportModule.cs"
                                int csharp2cuda_temp_291 = (third)->count;
#line 373 "TransportModule.cs"
                                csharp2cuda_temp_288 = ((csharp2cuda_temp_290) < (csharp2cuda_temp_291));
                            }
                            else
                            {
#line 373 "TransportModule.cs"
                                csharp2cuda_temp_288 = false;
                            }
                            if (csharp2cuda_temp_288)
                            {
#line 374 "TransportModule.cs"
#line 374 "TransportModule.cs"
                                double* csharp2cuda_temp_292 = &(right_remaining);
#line 374 "TransportModule.cs"
                                int csharp2cuda_temp_293 = (right_order)[right_index];
#line 374 "TransportModule.cs"
                                double csharp2cuda_temp_294 = (d)[csharp2cuda_temp_293];
                                (*(csharp2cuda_temp_292) = csharp2cuda_temp_294);
                            }
                        }
                    }
#line 376 "TransportModule.cs"
#line 376 "TransportModule.cs"
                    double* csharp2cuda_temp_295 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_295) = total);
#line 377 "TransportModule.cs"
                    break;
                }
#line 379 "TransportModule.cs"
            case 9:
            case 10:
#line 381 "TransportModule.cs"
#line 381 "TransportModule.cs"
                int csharp2cuda_temp_296 = (first)->rows;
#line 381 "TransportModule.cs"
                int csharp2cuda_temp_297 = (second)->columns;
                mathblocks_sequence_set_matrix_shape(output, csharp2cuda_temp_296, csharp2cuda_temp_297);
#line 382 "TransportModule.cs"
#line 382 "TransportModule.cs"
                int csharp2cuda_temp_298 = (first)->columns;
#line 382 "TransportModule.cs"
                int csharp2cuda_temp_299 = (second)->rows;
                if (((csharp2cuda_temp_298) != (csharp2cuda_temp_299)))
#line 383 "TransportModule.cs"
                {
#line 384 "TransportModule.cs"
#line 384 "TransportModule.cs"
                    int* csharp2cuda_temp_300 = &((output)->valid);
                    (*(csharp2cuda_temp_300) = 0);
#line 385 "TransportModule.cs"
                    break;
                }
#line 387 "TransportModule.cs"
                {
#line 387 "TransportModule.cs"
                    int row = 0;
                    while (true)
                    {
#line 387 "TransportModule.cs"
                        int csharp2cuda_temp_302 = (first)->rows;
                        if (!(((row) < (csharp2cuda_temp_302))))
                            break;
#line 388 "TransportModule.cs"
                        {
#line 388 "TransportModule.cs"
                            int column = 0;
                            while (true)
                            {
#line 388 "TransportModule.cs"
                                int csharp2cuda_temp_304 = (second)->columns;
                                if (!(((column) < (csharp2cuda_temp_304))))
                                    break;
#line 389 "TransportModule.cs"
                                {
#line 390 "TransportModule.cs"
                                    double csharp2cuda_temp_305;
#line 390 "TransportModule.cs"
                                    if (((opcode) == (9)))
                                    {
#line 390 "TransportModule.cs"
                                        csharp2cuda_temp_305 = (-(mathblocks_positive_infinity()));
                                    }
                                    else
                                    {
#line 390 "TransportModule.cs"
                                        csharp2cuda_temp_305 = mathblocks_positive_infinity();
                                    }
#line 390 "TransportModule.cs"
                                    double selected = csharp2cuda_temp_305;
#line 393 "TransportModule.cs"
                                    {
#line 393 "TransportModule.cs"
                                        int inner = 0;
                                        while (true)
                                        {
#line 393 "TransportModule.cs"
                                            int csharp2cuda_temp_307 = (first)->columns;
                                            if (!(((inner) < (csharp2cuda_temp_307))))
                                                break;
#line 394 "TransportModule.cs"
                                            {
#line 395 "TransportModule.cs"
                                                int csharp2cuda_temp_308 = (first)->columns;
#line 395 "TransportModule.cs"
                                                double csharp2cuda_temp_309 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_308), inner)];
#line 396 "TransportModule.cs"
                                                int csharp2cuda_temp_310 = (second)->columns;
#line 396 "TransportModule.cs"
                                                double csharp2cuda_temp_311 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_310), column)];
#line 395 "TransportModule.cs"
                                                double candidate = __dadd_rn(csharp2cuda_temp_309, csharp2cuda_temp_311);
#line 398 "TransportModule.cs"
#line 398 "TransportModule.cs"
                                                double* csharp2cuda_temp_312 = &(selected);
#line 398 "TransportModule.cs"
                                                double csharp2cuda_temp_313;
#line 398 "TransportModule.cs"
                                                if (((opcode) == (9)))
                                                {
#line 398 "TransportModule.cs"
                                                    csharp2cuda_temp_313 = mathblocks_maximum(selected, candidate);
                                                }
                                                else
                                                {
#line 398 "TransportModule.cs"
                                                    csharp2cuda_temp_313 = mathblocks_minimum(selected, candidate);
                                                }
                                                (*(csharp2cuda_temp_312) = csharp2cuda_temp_313);
                                            }
#line 393 "TransportModule.cs"
                                            int* csharp2cuda_temp_306 = &(inner);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_306));
                                        }
                                    }
#line 402 "TransportModule.cs"
#line 402 "TransportModule.cs"
                                    int csharp2cuda_temp_314 = (second)->columns;
#line 402 "TransportModule.cs"
                                    double* csharp2cuda_temp_315 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_314), column)]);
                                    (*(csharp2cuda_temp_315) = selected);
                                }
#line 388 "TransportModule.cs"
                                int* csharp2cuda_temp_303 = &(column);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_303));
                            }
                        }
#line 387 "TransportModule.cs"
                        int* csharp2cuda_temp_301 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_301));
                    }
                }
#line 404 "TransportModule.cs"
                break;
        }
#line 407 "TransportModule.cs"
#line 407 "TransportModule.cs"
        bool csharp2cuda_temp_316 = (output)->valid;
#line 407 "TransportModule.cs"
        bool csharp2cuda_temp_317;
#line 407 "TransportModule.cs"
        if (csharp2cuda_temp_316)
        {
#line 407 "TransportModule.cs"
            csharp2cuda_temp_317 = ((opcode) != (3));
        }
        else
        {
#line 407 "TransportModule.cs"
            csharp2cuda_temp_317 = false;
        }
#line 407 "TransportModule.cs"
        bool csharp2cuda_temp_318;
#line 407 "TransportModule.cs"
        if (csharp2cuda_temp_317)
        {
#line 407 "TransportModule.cs"
            csharp2cuda_temp_318 = ((opcode) != (4));
        }
        else
        {
#line 407 "TransportModule.cs"
            csharp2cuda_temp_318 = false;
        }
#line 407 "TransportModule.cs"
        bool csharp2cuda_temp_319;
#line 407 "TransportModule.cs"
        if (csharp2cuda_temp_318)
        {
#line 407 "TransportModule.cs"
            csharp2cuda_temp_319 = ((opcode) != (6));
        }
        else
        {
#line 407 "TransportModule.cs"
            csharp2cuda_temp_319 = false;
        }
#line 407 "TransportModule.cs"
        bool csharp2cuda_temp_320;
#line 407 "TransportModule.cs"
        if (csharp2cuda_temp_319)
        {
#line 407 "TransportModule.cs"
            csharp2cuda_temp_320 = ((opcode) != (9));
        }
        else
        {
#line 407 "TransportModule.cs"
            csharp2cuda_temp_320 = false;
        }
#line 407 "TransportModule.cs"
        bool csharp2cuda_temp_321;
#line 407 "TransportModule.cs"
        if (csharp2cuda_temp_320)
        {
#line 407 "TransportModule.cs"
            csharp2cuda_temp_321 = ((opcode) != (10));
        }
        else
        {
#line 407 "TransportModule.cs"
            csharp2cuda_temp_321 = false;
        }
#line 407 "TransportModule.cs"
        bool csharp2cuda_temp_322;
#line 407 "TransportModule.cs"
        if (csharp2cuda_temp_321)
        {
#line 409 "TransportModule.cs"
            double csharp2cuda_temp_323 = (output)->scalar_value;
#line 407 "TransportModule.cs"
            csharp2cuda_temp_322 = (!(isfinite(csharp2cuda_temp_323)));
        }
        else
        {
#line 407 "TransportModule.cs"
            csharp2cuda_temp_322 = false;
        }
        if (csharp2cuda_temp_322)
#line 410 "TransportModule.cs"
        {
#line 411 "TransportModule.cs"
#line 411 "TransportModule.cs"
            int* csharp2cuda_temp_324 = &((output)->valid);
            (*(csharp2cuda_temp_324) = 0);
        }
#line 413 "TransportModule.cs"
#line 413 "TransportModule.cs"
        bool csharp2cuda_temp_325 = (output)->valid;
#line 413 "TransportModule.cs"
        bool csharp2cuda_temp_326;
#line 413 "TransportModule.cs"
        if (csharp2cuda_temp_325)
        {
#line 413 "TransportModule.cs"
            bool csharp2cuda_temp_327;
#line 413 "TransportModule.cs"
            if (!(((opcode) == (3))))
            {
#line 413 "TransportModule.cs"
                csharp2cuda_temp_327 = ((opcode) == (4));
            }
            else
            {
#line 413 "TransportModule.cs"
                csharp2cuda_temp_327 = true;
            }
#line 413 "TransportModule.cs"
            bool csharp2cuda_temp_328;
#line 413 "TransportModule.cs"
            if (!(csharp2cuda_temp_327))
            {
#line 413 "TransportModule.cs"
                csharp2cuda_temp_328 = ((opcode) == (6));
            }
            else
            {
#line 413 "TransportModule.cs"
                csharp2cuda_temp_328 = true;
            }
#line 413 "TransportModule.cs"
            bool csharp2cuda_temp_329;
#line 413 "TransportModule.cs"
            if (!(csharp2cuda_temp_328))
            {
#line 413 "TransportModule.cs"
                csharp2cuda_temp_329 = ((opcode) == (9));
            }
            else
            {
#line 413 "TransportModule.cs"
                csharp2cuda_temp_329 = true;
            }
#line 413 "TransportModule.cs"
            bool csharp2cuda_temp_330;
#line 413 "TransportModule.cs"
            if (!(csharp2cuda_temp_329))
            {
#line 413 "TransportModule.cs"
                csharp2cuda_temp_330 = ((opcode) == (10));
            }
            else
            {
#line 413 "TransportModule.cs"
                csharp2cuda_temp_330 = true;
            }
#line 413 "TransportModule.cs"
            csharp2cuda_temp_326 = csharp2cuda_temp_330;
        }
        else
        {
#line 413 "TransportModule.cs"
            csharp2cuda_temp_326 = false;
        }
        if (csharp2cuda_temp_326)
        {
#line 414 "TransportModule.cs"
            {
#line 414 "TransportModule.cs"
                int index = 0;
                while (true)
                {
#line 414 "TransportModule.cs"
                    int csharp2cuda_temp_332 = (output)->count;
                    if (!(((index) < (csharp2cuda_temp_332))))
                        break;
#line 415 "TransportModule.cs"
#line 415 "TransportModule.cs"
                    double csharp2cuda_temp_333 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_333))))
                    {
#line 415 "TransportModule.cs"
#line 415 "TransportModule.cs"
                        int* csharp2cuda_temp_334 = &((output)->valid);
                        (*(csharp2cuda_temp_334) = 0);
                    }
#line 414 "TransportModule.cs"
                    int* csharp2cuda_temp_331 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_331));
                }
            }
        }
    }
}

#line 64 "TransportModule.cs"
__device__ double mathblocks_transport_mean_pairwise(
    const double* left,
    int left_count,
    const double* right,
    int right_count)
#line 70 "TransportModule.cs"
{
#line 71 "TransportModule.cs"
    double sum = 0.0;
#line 72 "TransportModule.cs"
    {
#line 72 "TransportModule.cs"
        int left_index = 0;
        while (true)
        {
            if (!(((left_index) < (left_count))))
                break;
#line 73 "TransportModule.cs"
            {
#line 73 "TransportModule.cs"
                int right_index = 0;
                while (true)
                {
                    if (!(((right_index) < (right_count))))
                        break;
#line 74 "TransportModule.cs"
#line 74 "TransportModule.cs"
                    double* csharp2cuda_temp_2 = &(sum);
#line 74 "TransportModule.cs"
                    double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 74 "TransportModule.cs"
                    double csharp2cuda_temp_4 = (left)[left_index];
#line 74 "TransportModule.cs"
                    double csharp2cuda_temp_5 = (right)[right_index];
                    (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, fabs(__dsub_rn(csharp2cuda_temp_4, csharp2cuda_temp_5))));
#line 73 "TransportModule.cs"
                    int* csharp2cuda_temp_1 = &(right_index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                }
            }
#line 72 "TransportModule.cs"
            int* csharp2cuda_temp_0 = &(left_index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 75 "TransportModule.cs"
    return __ddiv_rn(sum, ((double)(csharp2cuda_i32_mul(left_count, right_count))));
}