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

struct MathBlockDeviceType;

#line 30 "TypeRuleUnit.cs"
struct MathBlockDeviceType
{
    int kind;
    int rows;
    int columns;
    int unit_numerator0;
    int unit_numerator1;
    int unit_numerator2;
    int unit_numerator3;
    int unit_denominator0;
    int unit_denominator1;
    int unit_denominator2;
    int unit_denominator3;
};

#line 243 "TypeRuleUnit.cs"
__device__ int mathblocks_type_check_operands(
    const int* row,
    int start,
    const MathBlockDeviceType* inputs,
    int count,
    int mode,
    int seriesMask);

#line 145 "TypeRuleUnit.cs"
__device__ void mathblocks_type_clear(MathBlockDeviceType* value, int kind);

#line 188 "TypeRuleUnit.cs"
__device__ int mathblocks_type_combine_unit(
    const MathBlockDeviceType* left,
    const MathBlockDeviceType* right,
    int rightSign,
    int exponentNumerator,
    int exponentDenominator,
    MathBlockDeviceType* target);

#line 328 "TypeRuleUnit.cs"
__device__ int mathblocks_type_composed(
    const int* row,
    int start,
    const MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output,
    int mode,
    int seriesMask);

#line 155 "TypeRuleUnit.cs"
__device__ void mathblocks_type_copy_unit(const MathBlockDeviceType* source, MathBlockDeviceType* target);

#line 426 "TypeRuleUnit.cs"
__device__ int mathblocks_type_core(
    const int* row,
    int start,
    const MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output,
    int mode,
    int seriesMask);

#line 473 "TypeRuleUnit.cs"
__device__ int mathblocks_type_elementwise_form(
    const int* row,
    const MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output);

#line 54 "TypeRuleUnit.cs"
__device__ long long mathblocks_type_gcd(long long left, long long right);

#line 220 "TypeRuleUnit.cs"
__device__ MathBlockDeviceType mathblocks_type_input(
    const MathBlockDeviceType* inputs,
    int index,
    int mode,
    int seriesMask);

#line 445 "TypeRuleUnit.cs"
__device__ int mathblocks_type_lift_result(
    const MathBlockDeviceType* inputs,
    const MathBlockDeviceType* sourceResult,
    int validity,
    int fillIndex,
    int rows,
    MathBlockDeviceType* output);

#line 281 "TypeRuleUnit.cs"
__device__ int mathblocks_type_merge_shape(
    const MathBlockDeviceType* inputs,
    int checkMask,
    int outputMask,
    int mode,
    int seriesMask,
    int count,
    MathBlockDeviceType* output);

#line 126 "TypeRuleUnit.cs"
__device__ int mathblocks_type_normalize(MathBlockDeviceType* value, int dimension, long long numerator, long long denominator);

#line 590 "TypeRuleUnit.cs"
__device__ void mathblocks_type_resolve(
    const int* signature_row,
    const MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output);

#line 570 "TypeRuleUnit.cs"
__device__ int mathblocks_type_resolve_status(
    const int* signature_row,
    const MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output);

#line 100 "TypeRuleUnit.cs"
__device__ void mathblocks_type_set_unit(MathBlockDeviceType* value, int dimension, int numerator, int denominator);

#line 88 "TypeRuleUnit.cs"
__device__ int mathblocks_type_unit_denominator(const MathBlockDeviceType* value, int dimension);

#line 162 "TypeRuleUnit.cs"
__device__ bool mathblocks_type_unit_equal(const MathBlockDeviceType* left, const MathBlockDeviceType* right);

#line 174 "TypeRuleUnit.cs"
__device__ bool mathblocks_type_unit_is_dimensionless(const MathBlockDeviceType* value);

#line 76 "TypeRuleUnit.cs"
__device__ int mathblocks_type_unit_numerator(const MathBlockDeviceType* value, int dimension);

#line 517 "TypeRuleUnit.cs"
__device__ int mathblocks_type_window_form(
    const int* row,
    const MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output);

#line 243 "TypeRuleUnit.cs"
__device__ int mathblocks_type_check_operands(
    const int* row,
    int start,
    const MathBlockDeviceType* inputs,
    int count,
    int mode,
    int seriesMask)
#line 251 "TypeRuleUnit.cs"
{
#line 252 "TypeRuleUnit.cs"
    int csharp2cuda_temp_0 = (row)[csharp2cuda_i32_add(start, 1)];
#line 252 "TypeRuleUnit.cs"
    int operandStart = csharp2cuda_i32_add(csharp2cuda_i32_add(start, 2), csharp2cuda_temp_0);
#line 253 "TypeRuleUnit.cs"
#line 253 "TypeRuleUnit.cs"
    int csharp2cuda_temp_1 = (row)[operandStart];
    if (((csharp2cuda_temp_1) != (count)))
    {
#line 254 "TypeRuleUnit.cs"
        return 1;
    }
#line 255 "TypeRuleUnit.cs"
    {
#line 255 "TypeRuleUnit.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 256 "TypeRuleUnit.cs"
            {
#line 257 "TypeRuleUnit.cs"
                MathBlockDeviceType input = mathblocks_type_input(inputs, index, mode, seriesMask);
#line 258 "TypeRuleUnit.cs"
                int kind = (input).kind;
#line 259 "TypeRuleUnit.cs"
                int mask = (row)[csharp2cuda_i32_add(csharp2cuda_i32_add(operandStart, 1), csharp2cuda_i32_mul(index, 3))];
#line 260 "TypeRuleUnit.cs"
                int constraint = (row)[csharp2cuda_i32_add(csharp2cuda_i32_add(operandStart, 2), csharp2cuda_i32_mul(index, 3))];
#line 261 "TypeRuleUnit.cs"
#line 261 "TypeRuleUnit.cs"
                bool csharp2cuda_temp_3;
#line 261 "TypeRuleUnit.cs"
                if (!(((kind) < (1))))
                {
#line 261 "TypeRuleUnit.cs"
                    csharp2cuda_temp_3 = ((kind) > (31));
                }
                else
                {
#line 261 "TypeRuleUnit.cs"
                    csharp2cuda_temp_3 = true;
                }
#line 261 "TypeRuleUnit.cs"
                bool csharp2cuda_temp_4;
#line 261 "TypeRuleUnit.cs"
                if (!(csharp2cuda_temp_3))
                {
#line 261 "TypeRuleUnit.cs"
                    csharp2cuda_temp_4 = ((csharp2cuda_i32_and(csharp2cuda_i32_shr(mask, kind), 1)) == (0));
                }
                else
                {
#line 261 "TypeRuleUnit.cs"
                    csharp2cuda_temp_4 = true;
                }
                if (csharp2cuda_temp_4)
                {
#line 262 "TypeRuleUnit.cs"
                    return 2;
                }
#line 263 "TypeRuleUnit.cs"
                if (((constraint) == (csharp2cuda_i32_neg(2))))
#line 264 "TypeRuleUnit.cs"
                {
#line 265 "TypeRuleUnit.cs"
#line 265 "TypeRuleUnit.cs"
                    MathBlockDeviceType* csharp2cuda_temp_5 = &(input);
#line 265 "TypeRuleUnit.cs"
                    bool csharp2cuda_temp_6 = mathblocks_type_unit_is_dimensionless(csharp2cuda_temp_5);
                    if ((!(csharp2cuda_temp_6)))
                    {
#line 266 "TypeRuleUnit.cs"
                        return 3;
                    }
                }
                else
                {
#line 268 "TypeRuleUnit.cs"
                    if (((constraint) >= (0)))
#line 269 "TypeRuleUnit.cs"
                    {
#line 270 "TypeRuleUnit.cs"
                        MathBlockDeviceType other = mathblocks_type_input(inputs, constraint, mode, seriesMask);
#line 271 "TypeRuleUnit.cs"
#line 271 "TypeRuleUnit.cs"
                        MathBlockDeviceType* csharp2cuda_temp_7 = &(input);
#line 271 "TypeRuleUnit.cs"
                        MathBlockDeviceType* csharp2cuda_temp_8 = &(other);
#line 271 "TypeRuleUnit.cs"
                        bool csharp2cuda_temp_9 = mathblocks_type_unit_equal(csharp2cuda_temp_7, csharp2cuda_temp_8);
                        if ((!(csharp2cuda_temp_9)))
                        {
#line 272 "TypeRuleUnit.cs"
                            return 4;
                        }
                    }
                }
            }
#line 255 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_2 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 275 "TypeRuleUnit.cs"
    return 0;
}

#line 145 "TypeRuleUnit.cs"
__device__ void mathblocks_type_clear(MathBlockDeviceType* value, int kind)
#line 147 "TypeRuleUnit.cs"
{
#line 148 "TypeRuleUnit.cs"
#line 148 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_0 = &((value)->kind);
    (*(csharp2cuda_temp_0) = kind);
#line 149 "TypeRuleUnit.cs"
#line 149 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_1 = &((value)->rows);
    (*(csharp2cuda_temp_1) = 0);
#line 150 "TypeRuleUnit.cs"
#line 150 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_2 = &((value)->columns);
    (*(csharp2cuda_temp_2) = 0);
#line 151 "TypeRuleUnit.cs"
    {
#line 151 "TypeRuleUnit.cs"
        int dimension = 0;
        while (true)
        {
            if (!(((dimension) < (4))))
                break;
#line 152 "TypeRuleUnit.cs"
            mathblocks_type_set_unit(value, dimension, 0, 1);
#line 151 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_3 = &(dimension);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
        }
    }
}

#line 188 "TypeRuleUnit.cs"
__device__ int mathblocks_type_combine_unit(
    const MathBlockDeviceType* left,
    const MathBlockDeviceType* right,
    int rightSign,
    int exponentNumerator,
    int exponentDenominator,
    MathBlockDeviceType* target)
#line 196 "TypeRuleUnit.cs"
{
#line 197 "TypeRuleUnit.cs"
    {
#line 197 "TypeRuleUnit.cs"
        int dimension = 0;
        while (true)
        {
            if (!(((dimension) < (4))))
                break;
#line 198 "TypeRuleUnit.cs"
            {
#line 199 "TypeRuleUnit.cs"
                int csharp2cuda_temp_1 = mathblocks_type_unit_numerator(left, dimension);
#line 199 "TypeRuleUnit.cs"
                long long numerator = ((long long)(csharp2cuda_temp_1));
#line 200 "TypeRuleUnit.cs"
                int csharp2cuda_temp_2 = mathblocks_type_unit_denominator(left, dimension);
#line 200 "TypeRuleUnit.cs"
                long long denominator = ((long long)(csharp2cuda_temp_2));
#line 201 "TypeRuleUnit.cs"
                if (((((void*)(right))) != (((void*)(nullptr)))))
#line 202 "TypeRuleUnit.cs"
                {
#line 203 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_3 = mathblocks_type_unit_numerator(right, dimension);
#line 203 "TypeRuleUnit.cs"
                    long long rightNumerator = ((long long)(csharp2cuda_temp_3));
#line 204 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_4 = mathblocks_type_unit_denominator(right, dimension);
#line 204 "TypeRuleUnit.cs"
                    long long rightDenominator = ((long long)(csharp2cuda_temp_4));
#line 205 "TypeRuleUnit.cs"
                    long long sum = csharp2cuda_i64_add(csharp2cuda_i64_mul(numerator, rightDenominator), csharp2cuda_i64_mul(csharp2cuda_i64_mul(((long long)(rightSign)), rightNumerator), denominator));
#line 206 "TypeRuleUnit.cs"
                    long long product = csharp2cuda_i64_mul(denominator, rightDenominator);
#line 207 "TypeRuleUnit.cs"
#line 207 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_5 = mathblocks_type_normalize(target, dimension, sum, product);
                    if (((csharp2cuda_temp_5) == (0)))
                    {
#line 208 "TypeRuleUnit.cs"
                        return 0;
                    }
#line 209 "TypeRuleUnit.cs"
#line 209 "TypeRuleUnit.cs"
                    long long* csharp2cuda_temp_6 = &(numerator);
#line 209 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_7 = mathblocks_type_unit_numerator(target, dimension);
                    (*(csharp2cuda_temp_6) = ((long long)(csharp2cuda_temp_7)));
#line 210 "TypeRuleUnit.cs"
#line 210 "TypeRuleUnit.cs"
                    long long* csharp2cuda_temp_8 = &(denominator);
#line 210 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_9 = mathblocks_type_unit_denominator(target, dimension);
                    (*(csharp2cuda_temp_8) = ((long long)(csharp2cuda_temp_9)));
                }
#line 212 "TypeRuleUnit.cs"
#line 212 "TypeRuleUnit.cs"
                int csharp2cuda_temp_10 = mathblocks_type_normalize(target, dimension, csharp2cuda_i64_mul(numerator, ((long long)(exponentNumerator))), csharp2cuda_i64_mul(denominator, ((long long)(exponentDenominator))));
                if (((csharp2cuda_temp_10) == (0)))
                {
#line 213 "TypeRuleUnit.cs"
                    return 0;
                }
            }
#line 197 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_0 = &(dimension);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 215 "TypeRuleUnit.cs"
    return 1;
}

#line 328 "TypeRuleUnit.cs"
__device__ int mathblocks_type_composed(
    const int* row,
    int start,
    const MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output,
    int mode,
    int seriesMask)
#line 337 "TypeRuleUnit.cs"
{
#line 338 "TypeRuleUnit.cs"
    int p = csharp2cuda_i32_add(start, 2);
#line 339 "TypeRuleUnit.cs"
    int outputKind = (row)[csharp2cuda_i32_add(p, 0)];
#line 340 "TypeRuleUnit.cs"
    if (((outputKind) <= (0)))
    {
#line 341 "TypeRuleUnit.cs"
#line 341 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_0 = &(outputKind);
#line 341 "TypeRuleUnit.cs"
        MathBlockDeviceType csharp2cuda_temp_1 = mathblocks_type_input(inputs, csharp2cuda_i32_neg(outputKind), mode, seriesMask);
#line 341 "TypeRuleUnit.cs"
        int csharp2cuda_temp_2 = (csharp2cuda_temp_1).kind;
        (*(csharp2cuda_temp_0) = csharp2cuda_temp_2);
    }
#line 342 "TypeRuleUnit.cs"
    mathblocks_type_clear(output, outputKind);
#line 344 "TypeRuleUnit.cs"
    int shapeMode = (row)[csharp2cuda_i32_add(p, 1)];
#line 345 "TypeRuleUnit.cs"
#line 345 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_3;
#line 345 "TypeRuleUnit.cs"
    if (!(((shapeMode) == (2))))
    {
#line 345 "TypeRuleUnit.cs"
        csharp2cuda_temp_3 = ((shapeMode) == (4));
    }
    else
    {
#line 345 "TypeRuleUnit.cs"
        csharp2cuda_temp_3 = true;
    }
#line 345 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_4;
#line 345 "TypeRuleUnit.cs"
    if (!(csharp2cuda_temp_3))
    {
#line 345 "TypeRuleUnit.cs"
        csharp2cuda_temp_4 = ((shapeMode) == (7));
    }
    else
    {
#line 345 "TypeRuleUnit.cs"
        csharp2cuda_temp_4 = true;
    }
    if (csharp2cuda_temp_4)
#line 346 "TypeRuleUnit.cs"
    {
#line 347 "TypeRuleUnit.cs"
        int csharp2cuda_temp_5 = (row)[csharp2cuda_i32_add(p, 2)];
#line 347 "TypeRuleUnit.cs"
        int csharp2cuda_temp_6 = (row)[csharp2cuda_i32_add(p, 3)];
#line 347 "TypeRuleUnit.cs"
        int merged = mathblocks_type_merge_shape(inputs, csharp2cuda_temp_5, csharp2cuda_temp_6, mode, seriesMask, count, output);
#line 348 "TypeRuleUnit.cs"
        if (((merged) != (0)))
        {
#line 349 "TypeRuleUnit.cs"
            return merged;
        }
#line 350 "TypeRuleUnit.cs"
        if (((shapeMode) == (4)))
        {
#line 351 "TypeRuleUnit.cs"
#line 351 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_7 = &((output)->columns);
            (*(csharp2cuda_temp_7) = 0);
        }
        else
        {
#line 352 "TypeRuleUnit.cs"
            if (((shapeMode) == (7)))
            {
#line 353 "TypeRuleUnit.cs"
#line 353 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_8 = &((output)->rows);
                (*(csharp2cuda_temp_8) = 0);
            }
        }
#line 354 "TypeRuleUnit.cs"
        if (((shapeMode) == (7)))
        {
#line 355 "TypeRuleUnit.cs"
#line 355 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_9 = &((output)->columns);
            (*(csharp2cuda_temp_9) = 0);
        }
    }
    else
    {
#line 357 "TypeRuleUnit.cs"
        if (((shapeMode) >= (1)))
#line 358 "TypeRuleUnit.cs"
        {
#line 359 "TypeRuleUnit.cs"
            int csharp2cuda_temp_10 = (row)[csharp2cuda_i32_add(p, 2)];
#line 359 "TypeRuleUnit.cs"
            MathBlockDeviceType shapeA = mathblocks_type_input(inputs, csharp2cuda_temp_10, mode, seriesMask);
#line 360 "TypeRuleUnit.cs"
            if (((shapeMode) == (1)))
#line 361 "TypeRuleUnit.cs"
            {
#line 362 "TypeRuleUnit.cs"
#line 362 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_11 = &((output)->rows);
#line 362 "TypeRuleUnit.cs"
                int csharp2cuda_temp_12 = (shapeA).rows;
                (*(csharp2cuda_temp_11) = csharp2cuda_temp_12);
#line 363 "TypeRuleUnit.cs"
#line 363 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_13 = &((output)->columns);
#line 363 "TypeRuleUnit.cs"
                int csharp2cuda_temp_14 = (shapeA).columns;
                (*(csharp2cuda_temp_13) = csharp2cuda_temp_14);
            }
            else
            {
#line 365 "TypeRuleUnit.cs"
                if (((shapeMode) == (3)))
#line 366 "TypeRuleUnit.cs"
                {
#line 367 "TypeRuleUnit.cs"
#line 367 "TypeRuleUnit.cs"
                    int* csharp2cuda_temp_15 = &((output)->rows);
#line 367 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_16 = (shapeA).rows;
                    (*(csharp2cuda_temp_15) = csharp2cuda_temp_16);
                }
                else
                {
#line 369 "TypeRuleUnit.cs"
                    if (((shapeMode) == (5)))
#line 370 "TypeRuleUnit.cs"
                    {
#line 371 "TypeRuleUnit.cs"
                        int csharp2cuda_temp_17 = (row)[csharp2cuda_i32_add(p, 3)];
#line 371 "TypeRuleUnit.cs"
                        MathBlockDeviceType shapeB = mathblocks_type_input(inputs, csharp2cuda_temp_17, mode, seriesMask);
#line 372 "TypeRuleUnit.cs"
#line 372 "TypeRuleUnit.cs"
                        int csharp2cuda_temp_18 = (shapeA).rows;
#line 372 "TypeRuleUnit.cs"
                        bool csharp2cuda_temp_19;
#line 372 "TypeRuleUnit.cs"
                        if (((csharp2cuda_temp_18) > (0)))
                        {
#line 372 "TypeRuleUnit.cs"
                            int csharp2cuda_temp_20 = (shapeB).rows;
#line 372 "TypeRuleUnit.cs"
                            csharp2cuda_temp_19 = ((csharp2cuda_temp_20) > (0));
                        }
                        else
                        {
#line 372 "TypeRuleUnit.cs"
                            csharp2cuda_temp_19 = false;
                        }
                        if (csharp2cuda_temp_19)
#line 373 "TypeRuleUnit.cs"
                        {
#line 374 "TypeRuleUnit.cs"
                            int csharp2cuda_temp_21 = (shapeA).rows;
#line 374 "TypeRuleUnit.cs"
                            int csharp2cuda_temp_22 = (shapeB).rows;
#line 374 "TypeRuleUnit.cs"
                            long long total = csharp2cuda_i64_add(((long long)(csharp2cuda_temp_21)), ((long long)(csharp2cuda_temp_22)));
#line 375 "TypeRuleUnit.cs"
                            if (((total) > (2147483647LL)))
                            {
#line 376 "TypeRuleUnit.cs"
                                return 6;
                            }
#line 377 "TypeRuleUnit.cs"
#line 377 "TypeRuleUnit.cs"
                            int* csharp2cuda_temp_23 = &((output)->rows);
                            (*(csharp2cuda_temp_23) = csharp2cuda_i32_from_bits(total));
                        }
                    }
                    else
                    {
#line 380 "TypeRuleUnit.cs"
                        if (((shapeMode) == (6)))
#line 381 "TypeRuleUnit.cs"
                        {
#line 382 "TypeRuleUnit.cs"
#line 382 "TypeRuleUnit.cs"
                            int csharp2cuda_temp_24 = (shapeA).rows;
                            if (((csharp2cuda_temp_24) > (0)))
#line 383 "TypeRuleUnit.cs"
                            {
#line 384 "TypeRuleUnit.cs"
                                int csharp2cuda_temp_25 = (shapeA).rows;
#line 384 "TypeRuleUnit.cs"
                                int csharp2cuda_temp_26 = (row)[csharp2cuda_i32_add(p, 3)];
#line 384 "TypeRuleUnit.cs"
                                long long total = csharp2cuda_i64_add(((long long)(csharp2cuda_temp_25)), ((long long)(csharp2cuda_temp_26)));
#line 385 "TypeRuleUnit.cs"
                                if (((total) > (2147483647LL)))
                                {
#line 386 "TypeRuleUnit.cs"
                                    return 6;
                                }
#line 387 "TypeRuleUnit.cs"
#line 387 "TypeRuleUnit.cs"
                                int* csharp2cuda_temp_27 = &((output)->rows);
                                (*(csharp2cuda_temp_27) = csharp2cuda_i32_from_bits(total));
                            }
                        }
                        else
                        {
#line 390 "TypeRuleUnit.cs"
                            if (((shapeMode) == (9)))
#line 391 "TypeRuleUnit.cs"
                            {
#line 392 "TypeRuleUnit.cs"
#line 392 "TypeRuleUnit.cs"
                                int csharp2cuda_temp_28 = (shapeA).rows;
                                if (((csharp2cuda_temp_28) > (0)))
                                {
#line 393 "TypeRuleUnit.cs"
#line 393 "TypeRuleUnit.cs"
                                    int* csharp2cuda_temp_29 = &((output)->rows);
#line 393 "TypeRuleUnit.cs"
                                    int csharp2cuda_temp_30 = (shapeA).rows;
#line 393 "TypeRuleUnit.cs"
                                    int csharp2cuda_temp_31 = (row)[csharp2cuda_i32_add(p, 3)];
                                    (*(csharp2cuda_temp_29) = csharp2cuda_i32_from_bits(csharp2cuda_i64_add(((long long)(csharp2cuda_temp_30)), ((long long)(csharp2cuda_temp_31)))));
                                }
                            }
                            else
                            {
#line 395 "TypeRuleUnit.cs"
                                if (((shapeMode) == (8)))
#line 396 "TypeRuleUnit.cs"
                                {
#line 397 "TypeRuleUnit.cs"
#line 397 "TypeRuleUnit.cs"
                                    int* csharp2cuda_temp_32 = &((output)->rows);
                                    (*(csharp2cuda_temp_32) = 1);
#line 398 "TypeRuleUnit.cs"
#line 398 "TypeRuleUnit.cs"
                                    int csharp2cuda_temp_33 = (shapeA).rows;
                                    if (((csharp2cuda_temp_33) > (1)))
                                    {
#line 399 "TypeRuleUnit.cs"
#line 399 "TypeRuleUnit.cs"
                                        int* csharp2cuda_temp_34 = &((output)->rows);
#line 399 "TypeRuleUnit.cs"
                                        int csharp2cuda_temp_35 = (shapeA).rows;
                                        (*(csharp2cuda_temp_34) = csharp2cuda_i32_sub(csharp2cuda_temp_35, 1));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
#line 403 "TypeRuleUnit.cs"
    int unitMode = (row)[csharp2cuda_i32_add(p, 4)];
#line 404 "TypeRuleUnit.cs"
    if (((unitMode) == (0)))
    {
#line 405 "TypeRuleUnit.cs"
        return 0;
    }
#line 406 "TypeRuleUnit.cs"
    int csharp2cuda_temp_36 = (row)[csharp2cuda_i32_add(p, 5)];
#line 406 "TypeRuleUnit.cs"
    MathBlockDeviceType unitA = mathblocks_type_input(inputs, csharp2cuda_temp_36, mode, seriesMask);
#line 407 "TypeRuleUnit.cs"
    MathBlockDeviceType unitB;
#line 408 "TypeRuleUnit.cs"
#line 408 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_37 = &(unitB);
    mathblocks_type_clear(csharp2cuda_temp_37, 0);
#line 409 "TypeRuleUnit.cs"
    if (((unitMode) >= (3)))
    {
#line 410 "TypeRuleUnit.cs"
#line 410 "TypeRuleUnit.cs"
        MathBlockDeviceType* csharp2cuda_temp_38 = &(unitB);
#line 410 "TypeRuleUnit.cs"
        int csharp2cuda_temp_39 = (row)[csharp2cuda_i32_add(p, 6)];
#line 410 "TypeRuleUnit.cs"
        MathBlockDeviceType csharp2cuda_temp_40 = mathblocks_type_input(inputs, csharp2cuda_temp_39, mode, seriesMask);
        (*(csharp2cuda_temp_38) = csharp2cuda_temp_40);
    }
#line 411 "TypeRuleUnit.cs"
    int combined = 1;
#line 412 "TypeRuleUnit.cs"
    if (((unitMode) == (1)))
    {
#line 413 "TypeRuleUnit.cs"
#line 413 "TypeRuleUnit.cs"
        MathBlockDeviceType* csharp2cuda_temp_41 = &(unitA);
        mathblocks_type_copy_unit(csharp2cuda_temp_41, output);
    }
    else
    {
#line 414 "TypeRuleUnit.cs"
        if (((unitMode) == (2)))
        {
#line 415 "TypeRuleUnit.cs"
#line 415 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_42 = &(combined);
#line 415 "TypeRuleUnit.cs"
            MathBlockDeviceType* csharp2cuda_temp_43 = &(unitA);
#line 415 "TypeRuleUnit.cs"
            int csharp2cuda_temp_44 = (row)[csharp2cuda_i32_add(p, 7)];
#line 415 "TypeRuleUnit.cs"
            int csharp2cuda_temp_45 = (row)[csharp2cuda_i32_add(p, 8)];
#line 415 "TypeRuleUnit.cs"
            int csharp2cuda_temp_46 = mathblocks_type_combine_unit(csharp2cuda_temp_43, ((MathBlockDeviceType*)(nullptr)), 1, csharp2cuda_temp_44, csharp2cuda_temp_45, output);
            (*(csharp2cuda_temp_42) = csharp2cuda_temp_46);
        }
        else
        {
#line 416 "TypeRuleUnit.cs"
            if (((unitMode) == (3)))
            {
#line 417 "TypeRuleUnit.cs"
#line 417 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_47 = &(combined);
#line 417 "TypeRuleUnit.cs"
                MathBlockDeviceType* csharp2cuda_temp_48 = &(unitA);
#line 417 "TypeRuleUnit.cs"
                MathBlockDeviceType* csharp2cuda_temp_49 = &(unitB);
#line 417 "TypeRuleUnit.cs"
                int csharp2cuda_temp_50 = mathblocks_type_combine_unit(csharp2cuda_temp_48, csharp2cuda_temp_49, 1, 1, 1, output);
                (*(csharp2cuda_temp_47) = csharp2cuda_temp_50);
            }
            else
            {
#line 418 "TypeRuleUnit.cs"
                if (((unitMode) == (4)))
                {
#line 419 "TypeRuleUnit.cs"
#line 419 "TypeRuleUnit.cs"
                    int* csharp2cuda_temp_51 = &(combined);
#line 419 "TypeRuleUnit.cs"
                    MathBlockDeviceType* csharp2cuda_temp_52 = &(unitA);
#line 419 "TypeRuleUnit.cs"
                    MathBlockDeviceType* csharp2cuda_temp_53 = &(unitB);
#line 419 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_54 = mathblocks_type_combine_unit(csharp2cuda_temp_52, csharp2cuda_temp_53, csharp2cuda_i32_neg(1), 1, 1, output);
                    (*(csharp2cuda_temp_51) = csharp2cuda_temp_54);
                }
            }
        }
    }
#line 420 "TypeRuleUnit.cs"
    if (((combined) == (0)))
    {
#line 421 "TypeRuleUnit.cs"
        return 6;
    }
#line 422 "TypeRuleUnit.cs"
    return 0;
}

#line 155 "TypeRuleUnit.cs"
__device__ void mathblocks_type_copy_unit(const MathBlockDeviceType* source, MathBlockDeviceType* target)
#line 157 "TypeRuleUnit.cs"
{
#line 158 "TypeRuleUnit.cs"
    {
#line 158 "TypeRuleUnit.cs"
        int dimension = 0;
        while (true)
        {
            if (!(((dimension) < (4))))
                break;
#line 159 "TypeRuleUnit.cs"
#line 159 "TypeRuleUnit.cs"
            int csharp2cuda_temp_1 = mathblocks_type_unit_numerator(source, dimension);
#line 159 "TypeRuleUnit.cs"
            int csharp2cuda_temp_2 = mathblocks_type_unit_denominator(source, dimension);
            mathblocks_type_set_unit(target, dimension, csharp2cuda_temp_1, csharp2cuda_temp_2);
#line 158 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_0 = &(dimension);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 426 "TypeRuleUnit.cs"
__device__ int mathblocks_type_core(
    const int* row,
    int start,
    const MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output,
    int mode,
    int seriesMask)
#line 435 "TypeRuleUnit.cs"
{
#line 436 "TypeRuleUnit.cs"
    int checkedOperands = mathblocks_type_check_operands(row, start, inputs, count, mode, seriesMask);
#line 437 "TypeRuleUnit.cs"
    if (((checkedOperands) != (0)))
    {
#line 438 "TypeRuleUnit.cs"
        return checkedOperands;
    }
#line 439 "TypeRuleUnit.cs"
#line 439 "TypeRuleUnit.cs"
    int csharp2cuda_temp_0 = (row)[start];
    if (((csharp2cuda_temp_0) == (1)))
    {
#line 440 "TypeRuleUnit.cs"
        return mathblocks_type_composed(row, start, inputs, count, output, mode, seriesMask);
    }
#line 441 "TypeRuleUnit.cs"
    return 7;
}

#line 473 "TypeRuleUnit.cs"
__device__ int mathblocks_type_elementwise_form(
    const int* row,
    const MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output)
#line 479 "TypeRuleUnit.cs"
{
#line 480 "TypeRuleUnit.cs"
    int validity = (row)[2];
#line 481 "TypeRuleUnit.cs"
    int source = 3;
#line 482 "TypeRuleUnit.cs"
    int csharp2cuda_temp_0 = (row)[csharp2cuda_i32_add(source, 1)];
#line 482 "TypeRuleUnit.cs"
    int sourceArity = (row)[csharp2cuda_i32_add(csharp2cuda_i32_add(source, 2), csharp2cuda_temp_0)];
#line 483 "TypeRuleUnit.cs"
    if (((count) != (csharp2cuda_i32_sub(csharp2cuda_i32_add(sourceArity, 1), validity))))
    {
#line 484 "TypeRuleUnit.cs"
        return 1;
    }
#line 485 "TypeRuleUnit.cs"
    int rows = 0;
#line 486 "TypeRuleUnit.cs"
    int vectors = 0;
#line 487 "TypeRuleUnit.cs"
    int consistent = 1;
#line 488 "TypeRuleUnit.cs"
    {
#line 488 "TypeRuleUnit.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (sourceArity))))
                break;
#line 489 "TypeRuleUnit.cs"
            {
#line 490 "TypeRuleUnit.cs"
#line 490 "TypeRuleUnit.cs"
                int csharp2cuda_temp_2 = ((inputs)[index]).kind;
                if (((csharp2cuda_temp_2) != (4)))
                {
#line 491 "TypeRuleUnit.cs"
                    goto csharp2cuda_for_continue_0;
                }
#line 492 "TypeRuleUnit.cs"
#line 492 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_3 = &(vectors);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
#line 493 "TypeRuleUnit.cs"
                int length = ((inputs)[index]).rows;
#line 494 "TypeRuleUnit.cs"
                if (((length) > (0)))
#line 495 "TypeRuleUnit.cs"
                {
#line 496 "TypeRuleUnit.cs"
                    if (((rows) == (0)))
                    {
#line 497 "TypeRuleUnit.cs"
#line 497 "TypeRuleUnit.cs"
                        int* csharp2cuda_temp_4 = &(rows);
                        (*(csharp2cuda_temp_4) = length);
                    }
                    else
                    {
#line 498 "TypeRuleUnit.cs"
                        if (((rows) != (length)))
                        {
#line 499 "TypeRuleUnit.cs"
#line 499 "TypeRuleUnit.cs"
                            int* csharp2cuda_temp_5 = &(consistent);
                            (*(csharp2cuda_temp_5) = 0);
                        }
                    }
                }
            }
            csharp2cuda_for_continue_0:
#line 488 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_1 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 502 "TypeRuleUnit.cs"
    if (((vectors) == (0)))
    {
#line 503 "TypeRuleUnit.cs"
        return 7;
    }
#line 504 "TypeRuleUnit.cs"
    if (((consistent) == (0)))
    {
#line 505 "TypeRuleUnit.cs"
#line 505 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_6 = &(rows);
        (*(csharp2cuda_temp_6) = 0);
    }
#line 506 "TypeRuleUnit.cs"
    MathBlockDeviceType result;
#line 507 "TypeRuleUnit.cs"
#line 507 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_7 = &(result);
    mathblocks_type_clear(csharp2cuda_temp_7, 0);
#line 508 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_8 = &(result);
#line 508 "TypeRuleUnit.cs"
    int status = mathblocks_type_core(row, source, inputs, sourceArity, csharp2cuda_temp_8, 1, 0);
#line 509 "TypeRuleUnit.cs"
    if (((status) != (0)))
    {
#line 510 "TypeRuleUnit.cs"
        return status;
    }
#line 511 "TypeRuleUnit.cs"
#line 511 "TypeRuleUnit.cs"
    int csharp2cuda_temp_9 = (result).kind;
    if (((csharp2cuda_temp_9) != (1)))
    {
#line 512 "TypeRuleUnit.cs"
        return 2;
    }
#line 513 "TypeRuleUnit.cs"
#line 513 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_10 = &(result);
    return mathblocks_type_lift_result(inputs, csharp2cuda_temp_10, validity, sourceArity, rows, output);
}

#line 54 "TypeRuleUnit.cs"
__device__ long long mathblocks_type_gcd(long long left, long long right)
#line 56 "TypeRuleUnit.cs"
{
#line 57 "TypeRuleUnit.cs"
    if (((left) < (((long long)(0)))))
    {
#line 58 "TypeRuleUnit.cs"
#line 58 "TypeRuleUnit.cs"
        long long* csharp2cuda_temp_0 = &(left);
        (*(csharp2cuda_temp_0) = csharp2cuda_i64_neg(left));
    }
#line 59 "TypeRuleUnit.cs"
    if (((right) < (((long long)(0)))))
    {
#line 60 "TypeRuleUnit.cs"
#line 60 "TypeRuleUnit.cs"
        long long* csharp2cuda_temp_1 = &(right);
        (*(csharp2cuda_temp_1) = csharp2cuda_i64_neg(right));
    }
#line 61 "TypeRuleUnit.cs"
    if (((left) == (((long long)(0)))))
#line 62 "TypeRuleUnit.cs"
    {
#line 63 "TypeRuleUnit.cs"
        if (((right) == (((long long)(0)))))
        {
#line 64 "TypeRuleUnit.cs"
            return ((long long)(1));
        }
#line 65 "TypeRuleUnit.cs"
        return right;
    }
#line 67 "TypeRuleUnit.cs"
    while (true)
    {
        if (!(((right) != (((long long)(0))))))
            break;
#line 68 "TypeRuleUnit.cs"
        {
#line 69 "TypeRuleUnit.cs"
            long long next = csharp2cuda_i64_rem(left, right);
#line 70 "TypeRuleUnit.cs"
#line 70 "TypeRuleUnit.cs"
            long long* csharp2cuda_temp_2 = &(left);
            (*(csharp2cuda_temp_2) = right);
#line 71 "TypeRuleUnit.cs"
#line 71 "TypeRuleUnit.cs"
            long long* csharp2cuda_temp_3 = &(right);
            (*(csharp2cuda_temp_3) = next);
        }
    }
#line 73 "TypeRuleUnit.cs"
    return left;
}

#line 220 "TypeRuleUnit.cs"
__device__ MathBlockDeviceType mathblocks_type_input(
    const MathBlockDeviceType* inputs,
    int index,
    int mode,
    int seriesMask)
#line 226 "TypeRuleUnit.cs"
{
#line 227 "TypeRuleUnit.cs"
    MathBlockDeviceType value = (inputs)[index];
#line 228 "TypeRuleUnit.cs"
#line 228 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_0;
#line 228 "TypeRuleUnit.cs"
    if (((mode) == (1)))
    {
#line 228 "TypeRuleUnit.cs"
        int csharp2cuda_temp_1 = (value).kind;
#line 228 "TypeRuleUnit.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_temp_1) == (4));
    }
    else
    {
#line 228 "TypeRuleUnit.cs"
        csharp2cuda_temp_0 = false;
    }
    if (csharp2cuda_temp_0)
#line 229 "TypeRuleUnit.cs"
    {
#line 230 "TypeRuleUnit.cs"
#line 230 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_2 = &((value).kind);
        (*(csharp2cuda_temp_2) = 1);
#line 231 "TypeRuleUnit.cs"
#line 231 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_3 = &((value).rows);
        (*(csharp2cuda_temp_3) = 0);
#line 232 "TypeRuleUnit.cs"
#line 232 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_4 = &((value).columns);
        (*(csharp2cuda_temp_4) = 0);
    }
    else
    {
#line 234 "TypeRuleUnit.cs"
#line 234 "TypeRuleUnit.cs"
        bool csharp2cuda_temp_5;
#line 234 "TypeRuleUnit.cs"
        if (((mode) == (2)))
        {
#line 234 "TypeRuleUnit.cs"
            csharp2cuda_temp_5 = ((csharp2cuda_i32_and(csharp2cuda_i32_shr(seriesMask, index), 1)) != (0));
        }
        else
        {
#line 234 "TypeRuleUnit.cs"
            csharp2cuda_temp_5 = false;
        }
        if (csharp2cuda_temp_5)
#line 235 "TypeRuleUnit.cs"
        {
#line 236 "TypeRuleUnit.cs"
#line 236 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_6 = &((value).rows);
            (*(csharp2cuda_temp_6) = 0);
#line 237 "TypeRuleUnit.cs"
#line 237 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_7 = &((value).columns);
            (*(csharp2cuda_temp_7) = 0);
        }
    }
#line 239 "TypeRuleUnit.cs"
    return value;
}

#line 445 "TypeRuleUnit.cs"
__device__ int mathblocks_type_lift_result(
    const MathBlockDeviceType* inputs,
    const MathBlockDeviceType* sourceResult,
    int validity,
    int fillIndex,
    int rows,
    MathBlockDeviceType* output)
#line 453 "TypeRuleUnit.cs"
{
#line 454 "TypeRuleUnit.cs"
    if (((validity) != (0)))
#line 455 "TypeRuleUnit.cs"
    {
#line 456 "TypeRuleUnit.cs"
        mathblocks_type_clear(output, 11);
#line 457 "TypeRuleUnit.cs"
#line 457 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_0 = &((output)->rows);
        (*(csharp2cuda_temp_0) = rows);
#line 458 "TypeRuleUnit.cs"
        return 0;
    }
#line 460 "TypeRuleUnit.cs"
    MathBlockDeviceType fill = (inputs)[fillIndex];
#line 461 "TypeRuleUnit.cs"
#line 461 "TypeRuleUnit.cs"
    int csharp2cuda_temp_1 = (fill).kind;
    if (((csharp2cuda_temp_1) != (1)))
    {
#line 462 "TypeRuleUnit.cs"
        return 2;
    }
#line 463 "TypeRuleUnit.cs"
#line 463 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_2 = &(fill);
#line 463 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_3 = mathblocks_type_unit_equal(csharp2cuda_temp_2, sourceResult);
    if ((!(csharp2cuda_temp_3)))
    {
#line 464 "TypeRuleUnit.cs"
        return 4;
    }
#line 465 "TypeRuleUnit.cs"
    mathblocks_type_copy_unit(sourceResult, output);
#line 466 "TypeRuleUnit.cs"
#line 466 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_4 = &((output)->kind);
    (*(csharp2cuda_temp_4) = 4);
#line 467 "TypeRuleUnit.cs"
#line 467 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_5 = &((output)->rows);
    (*(csharp2cuda_temp_5) = rows);
#line 468 "TypeRuleUnit.cs"
#line 468 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_6 = &((output)->columns);
    (*(csharp2cuda_temp_6) = 0);
#line 469 "TypeRuleUnit.cs"
    return 0;
}

#line 281 "TypeRuleUnit.cs"
__device__ int mathblocks_type_merge_shape(
    const MathBlockDeviceType* inputs,
    int checkMask,
    int outputMask,
    int mode,
    int seriesMask,
    int count,
    MathBlockDeviceType* output)
#line 290 "TypeRuleUnit.cs"
{
#line 291 "TypeRuleUnit.cs"
    if (((outputMask) == (0)))
    {
#line 292 "TypeRuleUnit.cs"
#line 292 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_0 = &(outputMask);
        (*(csharp2cuda_temp_0) = checkMask);
    }
#line 293 "TypeRuleUnit.cs"
    int rows = 0;
#line 294 "TypeRuleUnit.cs"
    int columns = 0;
#line 295 "TypeRuleUnit.cs"
    int outputRows = 0;
#line 296 "TypeRuleUnit.cs"
    int outputColumns = 0;
#line 297 "TypeRuleUnit.cs"
    {
#line 297 "TypeRuleUnit.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 298 "TypeRuleUnit.cs"
            {
#line 299 "TypeRuleUnit.cs"
                if (((csharp2cuda_i32_and(csharp2cuda_i32_shr(checkMask, index), 1)) == (0)))
                {
#line 300 "TypeRuleUnit.cs"
                    goto csharp2cuda_for_continue_0;
                }
#line 301 "TypeRuleUnit.cs"
                MathBlockDeviceType input = mathblocks_type_input(inputs, index, mode, seriesMask);
#line 302 "TypeRuleUnit.cs"
#line 302 "TypeRuleUnit.cs"
                int csharp2cuda_temp_2 = (input).rows;
                if (((csharp2cuda_temp_2) != (0)))
#line 303 "TypeRuleUnit.cs"
                {
#line 304 "TypeRuleUnit.cs"
#line 304 "TypeRuleUnit.cs"
                    bool csharp2cuda_temp_3;
#line 304 "TypeRuleUnit.cs"
                    if (((rows) != (0)))
                    {
#line 304 "TypeRuleUnit.cs"
                        int csharp2cuda_temp_4 = (input).rows;
#line 304 "TypeRuleUnit.cs"
                        csharp2cuda_temp_3 = ((rows) != (csharp2cuda_temp_4));
                    }
                    else
                    {
#line 304 "TypeRuleUnit.cs"
                        csharp2cuda_temp_3 = false;
                    }
                    if (csharp2cuda_temp_3)
                    {
#line 305 "TypeRuleUnit.cs"
                        return 5;
                    }
#line 306 "TypeRuleUnit.cs"
#line 306 "TypeRuleUnit.cs"
                    int* csharp2cuda_temp_5 = &(rows);
#line 306 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_6 = (input).rows;
                    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
                }
#line 308 "TypeRuleUnit.cs"
#line 308 "TypeRuleUnit.cs"
                int csharp2cuda_temp_7 = (input).columns;
                if (((csharp2cuda_temp_7) != (0)))
#line 309 "TypeRuleUnit.cs"
                {
#line 310 "TypeRuleUnit.cs"
#line 310 "TypeRuleUnit.cs"
                    bool csharp2cuda_temp_8;
#line 310 "TypeRuleUnit.cs"
                    if (((columns) != (0)))
                    {
#line 310 "TypeRuleUnit.cs"
                        int csharp2cuda_temp_9 = (input).columns;
#line 310 "TypeRuleUnit.cs"
                        csharp2cuda_temp_8 = ((columns) != (csharp2cuda_temp_9));
                    }
                    else
                    {
#line 310 "TypeRuleUnit.cs"
                        csharp2cuda_temp_8 = false;
                    }
                    if (csharp2cuda_temp_8)
                    {
#line 311 "TypeRuleUnit.cs"
                        return 5;
                    }
#line 312 "TypeRuleUnit.cs"
#line 312 "TypeRuleUnit.cs"
                    int* csharp2cuda_temp_10 = &(columns);
#line 312 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_11 = (input).columns;
                    (*(csharp2cuda_temp_10) = csharp2cuda_temp_11);
                }
#line 314 "TypeRuleUnit.cs"
                if (((csharp2cuda_i32_and(csharp2cuda_i32_shr(outputMask, index), 1)) != (0)))
#line 315 "TypeRuleUnit.cs"
                {
#line 316 "TypeRuleUnit.cs"
                    if (((outputRows) == (0)))
                    {
#line 317 "TypeRuleUnit.cs"
#line 317 "TypeRuleUnit.cs"
                        int* csharp2cuda_temp_12 = &(outputRows);
#line 317 "TypeRuleUnit.cs"
                        int csharp2cuda_temp_13 = (input).rows;
                        (*(csharp2cuda_temp_12) = csharp2cuda_temp_13);
                    }
#line 318 "TypeRuleUnit.cs"
                    if (((outputColumns) == (0)))
                    {
#line 319 "TypeRuleUnit.cs"
#line 319 "TypeRuleUnit.cs"
                        int* csharp2cuda_temp_14 = &(outputColumns);
#line 319 "TypeRuleUnit.cs"
                        int csharp2cuda_temp_15 = (input).columns;
                        (*(csharp2cuda_temp_14) = csharp2cuda_temp_15);
                    }
                }
            }
            csharp2cuda_for_continue_0:
#line 297 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_1 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 322 "TypeRuleUnit.cs"
#line 322 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_16 = &((output)->rows);
    (*(csharp2cuda_temp_16) = outputRows);
#line 323 "TypeRuleUnit.cs"
#line 323 "TypeRuleUnit.cs"
    int* csharp2cuda_temp_17 = &((output)->columns);
    (*(csharp2cuda_temp_17) = outputColumns);
#line 324 "TypeRuleUnit.cs"
    return 0;
}

#line 126 "TypeRuleUnit.cs"
__device__ int mathblocks_type_normalize(MathBlockDeviceType* value, int dimension, long long numerator, long long denominator)
#line 128 "TypeRuleUnit.cs"
{
#line 129 "TypeRuleUnit.cs"
    long long divisor = mathblocks_type_gcd(numerator, denominator);
#line 130 "TypeRuleUnit.cs"
#line 130 "TypeRuleUnit.cs"
    long long* csharp2cuda_temp_0 = &(numerator);
#line 130 "TypeRuleUnit.cs"
    long long csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
    (*(csharp2cuda_temp_0) = csharp2cuda_i64_div(csharp2cuda_temp_1, divisor));
#line 131 "TypeRuleUnit.cs"
#line 131 "TypeRuleUnit.cs"
    long long* csharp2cuda_temp_2 = &(denominator);
#line 131 "TypeRuleUnit.cs"
    long long csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
    (*(csharp2cuda_temp_2) = csharp2cuda_i64_div(csharp2cuda_temp_3, divisor));
#line 132 "TypeRuleUnit.cs"
    if (((denominator) < (((long long)(0)))))
#line 133 "TypeRuleUnit.cs"
    {
#line 134 "TypeRuleUnit.cs"
#line 134 "TypeRuleUnit.cs"
        long long* csharp2cuda_temp_4 = &(numerator);
        (*(csharp2cuda_temp_4) = csharp2cuda_i64_neg(numerator));
#line 135 "TypeRuleUnit.cs"
#line 135 "TypeRuleUnit.cs"
        long long* csharp2cuda_temp_5 = &(denominator);
        (*(csharp2cuda_temp_5) = csharp2cuda_i64_neg(denominator));
    }
#line 137 "TypeRuleUnit.cs"
#line 137 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_6;
#line 137 "TypeRuleUnit.cs"
    if (!(((numerator) < (csharp2cuda_i64_neg(2147483648LL)))))
    {
#line 137 "TypeRuleUnit.cs"
        csharp2cuda_temp_6 = ((numerator) > (2147483647LL));
    }
    else
    {
#line 137 "TypeRuleUnit.cs"
        csharp2cuda_temp_6 = true;
    }
#line 137 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_7;
#line 137 "TypeRuleUnit.cs"
    if (!(csharp2cuda_temp_6))
    {
#line 137 "TypeRuleUnit.cs"
        csharp2cuda_temp_7 = ((denominator) < (((long long)(1))));
    }
    else
    {
#line 137 "TypeRuleUnit.cs"
        csharp2cuda_temp_7 = true;
    }
#line 137 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_8;
#line 137 "TypeRuleUnit.cs"
    if (!(csharp2cuda_temp_7))
    {
#line 137 "TypeRuleUnit.cs"
        csharp2cuda_temp_8 = ((denominator) > (2147483647LL));
    }
    else
    {
#line 137 "TypeRuleUnit.cs"
        csharp2cuda_temp_8 = true;
    }
    if (csharp2cuda_temp_8)
    {
#line 138 "TypeRuleUnit.cs"
        return 0;
    }
#line 139 "TypeRuleUnit.cs"
    if (((numerator) == (((long long)(0)))))
    {
#line 140 "TypeRuleUnit.cs"
#line 140 "TypeRuleUnit.cs"
        long long* csharp2cuda_temp_9 = &(denominator);
        (*(csharp2cuda_temp_9) = ((long long)(1)));
    }
#line 141 "TypeRuleUnit.cs"
    mathblocks_type_set_unit(value, dimension, csharp2cuda_i32_from_bits(numerator), csharp2cuda_i32_from_bits(denominator));
#line 142 "TypeRuleUnit.cs"
    return 1;
}

#line 590 "TypeRuleUnit.cs"
__device__ void mathblocks_type_resolve(
    const int* signature_row,
    const MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output)
#line 596 "TypeRuleUnit.cs"
{
#line 597 "TypeRuleUnit.cs"
    mathblocks_type_resolve_status(signature_row, inputs, count, output);
}

#line 570 "TypeRuleUnit.cs"
__device__ int mathblocks_type_resolve_status(
    const int* signature_row,
    const MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output)
#line 576 "TypeRuleUnit.cs"
{
#line 577 "TypeRuleUnit.cs"
    int rule = (signature_row)[0];
#line 578 "TypeRuleUnit.cs"
    int status = 7;
#line 579 "TypeRuleUnit.cs"
    if (((rule) == (2)))
    {
#line 580 "TypeRuleUnit.cs"
#line 580 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_0 = &(status);
#line 580 "TypeRuleUnit.cs"
        int csharp2cuda_temp_1 = mathblocks_type_elementwise_form(signature_row, inputs, count, output);
        (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
    }
    else
    {
#line 581 "TypeRuleUnit.cs"
        if (((rule) == (3)))
        {
#line 582 "TypeRuleUnit.cs"
#line 582 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_2 = &(status);
#line 582 "TypeRuleUnit.cs"
            int csharp2cuda_temp_3 = mathblocks_type_window_form(signature_row, inputs, count, output);
            (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
        }
        else
        {
#line 584 "TypeRuleUnit.cs"
#line 584 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_4 = &(status);
#line 584 "TypeRuleUnit.cs"
            int csharp2cuda_temp_5 = mathblocks_type_core(signature_row, 0, inputs, count, output, 0, 0);
            (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
        }
    }
#line 585 "TypeRuleUnit.cs"
    if (((status) != (0)))
    {
#line 586 "TypeRuleUnit.cs"
        mathblocks_type_clear(output, csharp2cuda_i32_neg(1));
    }
#line 587 "TypeRuleUnit.cs"
    return status;
}

#line 100 "TypeRuleUnit.cs"
__device__ void mathblocks_type_set_unit(MathBlockDeviceType* value, int dimension, int numerator, int denominator)
#line 102 "TypeRuleUnit.cs"
{
#line 103 "TypeRuleUnit.cs"
    if (((dimension) == (0)))
#line 104 "TypeRuleUnit.cs"
    {
#line 105 "TypeRuleUnit.cs"
#line 105 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_0 = &((value)->unit_numerator0);
        (*(csharp2cuda_temp_0) = numerator);
#line 106 "TypeRuleUnit.cs"
#line 106 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_1 = &((value)->unit_denominator0);
        (*(csharp2cuda_temp_1) = denominator);
    }
    else
    {
#line 108 "TypeRuleUnit.cs"
        if (((dimension) == (1)))
#line 109 "TypeRuleUnit.cs"
        {
#line 110 "TypeRuleUnit.cs"
#line 110 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_2 = &((value)->unit_numerator1);
            (*(csharp2cuda_temp_2) = numerator);
#line 111 "TypeRuleUnit.cs"
#line 111 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_3 = &((value)->unit_denominator1);
            (*(csharp2cuda_temp_3) = denominator);
        }
        else
        {
#line 113 "TypeRuleUnit.cs"
            if (((dimension) == (2)))
#line 114 "TypeRuleUnit.cs"
            {
#line 115 "TypeRuleUnit.cs"
#line 115 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_4 = &((value)->unit_numerator2);
                (*(csharp2cuda_temp_4) = numerator);
#line 116 "TypeRuleUnit.cs"
#line 116 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_5 = &((value)->unit_denominator2);
                (*(csharp2cuda_temp_5) = denominator);
            }
            else
#line 119 "TypeRuleUnit.cs"
            {
#line 120 "TypeRuleUnit.cs"
#line 120 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_6 = &((value)->unit_numerator3);
                (*(csharp2cuda_temp_6) = numerator);
#line 121 "TypeRuleUnit.cs"
#line 121 "TypeRuleUnit.cs"
                int* csharp2cuda_temp_7 = &((value)->unit_denominator3);
                (*(csharp2cuda_temp_7) = denominator);
            }
        }
    }
}

#line 88 "TypeRuleUnit.cs"
__device__ int mathblocks_type_unit_denominator(const MathBlockDeviceType* value, int dimension)
#line 90 "TypeRuleUnit.cs"
{
#line 91 "TypeRuleUnit.cs"
    if (((dimension) == (0)))
    {
#line 92 "TypeRuleUnit.cs"
        return (value)->unit_denominator0;
    }
#line 93 "TypeRuleUnit.cs"
    if (((dimension) == (1)))
    {
#line 94 "TypeRuleUnit.cs"
        return (value)->unit_denominator1;
    }
#line 95 "TypeRuleUnit.cs"
    if (((dimension) == (2)))
    {
#line 96 "TypeRuleUnit.cs"
        return (value)->unit_denominator2;
    }
#line 97 "TypeRuleUnit.cs"
    return (value)->unit_denominator3;
}

#line 162 "TypeRuleUnit.cs"
__device__ bool mathblocks_type_unit_equal(const MathBlockDeviceType* left, const MathBlockDeviceType* right)
#line 164 "TypeRuleUnit.cs"
{
#line 165 "TypeRuleUnit.cs"
    {
#line 165 "TypeRuleUnit.cs"
        int dimension = 0;
        while (true)
        {
            if (!(((dimension) < (4))))
                break;
#line 166 "TypeRuleUnit.cs"
            {
#line 167 "TypeRuleUnit.cs"
#line 167 "TypeRuleUnit.cs"
                int csharp2cuda_temp_1 = mathblocks_type_unit_numerator(left, dimension);
#line 167 "TypeRuleUnit.cs"
                int csharp2cuda_temp_2 = mathblocks_type_unit_numerator(right, dimension);
#line 167 "TypeRuleUnit.cs"
                bool csharp2cuda_temp_3;
#line 167 "TypeRuleUnit.cs"
                if (!(((csharp2cuda_temp_1) != (csharp2cuda_temp_2))))
                {
#line 168 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_4 = mathblocks_type_unit_denominator(left, dimension);
#line 168 "TypeRuleUnit.cs"
                    int csharp2cuda_temp_5 = mathblocks_type_unit_denominator(right, dimension);
#line 167 "TypeRuleUnit.cs"
                    csharp2cuda_temp_3 = ((csharp2cuda_temp_4) != (csharp2cuda_temp_5));
                }
                else
                {
#line 167 "TypeRuleUnit.cs"
                    csharp2cuda_temp_3 = true;
                }
                if (csharp2cuda_temp_3)
                {
#line 169 "TypeRuleUnit.cs"
                    return false;
                }
            }
#line 165 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_0 = &(dimension);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 171 "TypeRuleUnit.cs"
    return true;
}

#line 174 "TypeRuleUnit.cs"
__device__ bool mathblocks_type_unit_is_dimensionless(const MathBlockDeviceType* value)
#line 176 "TypeRuleUnit.cs"
{
#line 177 "TypeRuleUnit.cs"
    {
#line 177 "TypeRuleUnit.cs"
        int dimension = 0;
        while (true)
        {
            if (!(((dimension) < (4))))
                break;
#line 178 "TypeRuleUnit.cs"
            {
#line 179 "TypeRuleUnit.cs"
#line 179 "TypeRuleUnit.cs"
                int csharp2cuda_temp_1 = mathblocks_type_unit_numerator(value, dimension);
                if (((csharp2cuda_temp_1) != (0)))
                {
#line 180 "TypeRuleUnit.cs"
                    return false;
                }
            }
#line 177 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_0 = &(dimension);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 182 "TypeRuleUnit.cs"
    return true;
}

#line 76 "TypeRuleUnit.cs"
__device__ int mathblocks_type_unit_numerator(const MathBlockDeviceType* value, int dimension)
#line 78 "TypeRuleUnit.cs"
{
#line 79 "TypeRuleUnit.cs"
    if (((dimension) == (0)))
    {
#line 80 "TypeRuleUnit.cs"
        return (value)->unit_numerator0;
    }
#line 81 "TypeRuleUnit.cs"
    if (((dimension) == (1)))
    {
#line 82 "TypeRuleUnit.cs"
        return (value)->unit_numerator1;
    }
#line 83 "TypeRuleUnit.cs"
    if (((dimension) == (2)))
    {
#line 84 "TypeRuleUnit.cs"
        return (value)->unit_numerator2;
    }
#line 85 "TypeRuleUnit.cs"
    return (value)->unit_numerator3;
}

#line 517 "TypeRuleUnit.cs"
__device__ int mathblocks_type_window_form(
    const int* row,
    const MathBlockDeviceType* inputs,
    int count,
    MathBlockDeviceType* output)
#line 523 "TypeRuleUnit.cs"
{
#line 524 "TypeRuleUnit.cs"
    int validity = (row)[2];
#line 525 "TypeRuleUnit.cs"
    int lastRow = (row)[3];
#line 526 "TypeRuleUnit.cs"
    int seriesMask = (row)[4];
#line 527 "TypeRuleUnit.cs"
    int source = 5;
#line 528 "TypeRuleUnit.cs"
    int csharp2cuda_temp_0 = (row)[csharp2cuda_i32_add(source, 1)];
#line 528 "TypeRuleUnit.cs"
    int sourceArity = (row)[csharp2cuda_i32_add(csharp2cuda_i32_add(source, 2), csharp2cuda_temp_0)];
#line 529 "TypeRuleUnit.cs"
    if (((count) != (csharp2cuda_i32_sub(csharp2cuda_i32_add(sourceArity, 2), validity))))
    {
#line 530 "TypeRuleUnit.cs"
        return 1;
    }
#line 531 "TypeRuleUnit.cs"
    int rows = 0;
#line 532 "TypeRuleUnit.cs"
    int consistent = 1;
#line 533 "TypeRuleUnit.cs"
    {
#line 533 "TypeRuleUnit.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (sourceArity))))
                break;
#line 534 "TypeRuleUnit.cs"
            {
#line 535 "TypeRuleUnit.cs"
                if (((csharp2cuda_i32_and(csharp2cuda_i32_shr(seriesMask, index), 1)) == (0)))
                {
#line 536 "TypeRuleUnit.cs"
                    goto csharp2cuda_for_continue_0;
                }
#line 537 "TypeRuleUnit.cs"
                int kind = ((inputs)[index]).kind;
#line 538 "TypeRuleUnit.cs"
#line 538 "TypeRuleUnit.cs"
                bool csharp2cuda_temp_2;
#line 538 "TypeRuleUnit.cs"
                if (((kind) != (4)))
                {
#line 538 "TypeRuleUnit.cs"
                    csharp2cuda_temp_2 = ((kind) != (11));
                }
                else
                {
#line 538 "TypeRuleUnit.cs"
                    csharp2cuda_temp_2 = false;
                }
                if (csharp2cuda_temp_2)
                {
#line 539 "TypeRuleUnit.cs"
                    return 2;
                }
#line 540 "TypeRuleUnit.cs"
                int length = ((inputs)[index]).rows;
#line 541 "TypeRuleUnit.cs"
                if (((length) > (0)))
#line 542 "TypeRuleUnit.cs"
                {
#line 543 "TypeRuleUnit.cs"
                    if (((rows) == (0)))
                    {
#line 544 "TypeRuleUnit.cs"
#line 544 "TypeRuleUnit.cs"
                        int* csharp2cuda_temp_3 = &(rows);
                        (*(csharp2cuda_temp_3) = length);
                    }
                    else
                    {
#line 545 "TypeRuleUnit.cs"
                        if (((rows) != (length)))
                        {
#line 546 "TypeRuleUnit.cs"
#line 546 "TypeRuleUnit.cs"
                            int* csharp2cuda_temp_4 = &(consistent);
                            (*(csharp2cuda_temp_4) = 0);
                        }
                    }
                }
            }
            csharp2cuda_for_continue_0:
#line 533 "TypeRuleUnit.cs"
            int* csharp2cuda_temp_1 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 549 "TypeRuleUnit.cs"
    if (((consistent) == (0)))
    {
#line 550 "TypeRuleUnit.cs"
#line 550 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_5 = &(rows);
        (*(csharp2cuda_temp_5) = 0);
    }
#line 551 "TypeRuleUnit.cs"
    MathBlockDeviceType result;
#line 552 "TypeRuleUnit.cs"
#line 552 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_6 = &(result);
    mathblocks_type_clear(csharp2cuda_temp_6, 0);
#line 553 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_7 = &(result);
#line 553 "TypeRuleUnit.cs"
    int status = mathblocks_type_core(row, source, inputs, sourceArity, csharp2cuda_temp_7, 2, seriesMask);
#line 554 "TypeRuleUnit.cs"
    if (((status) != (0)))
    {
#line 555 "TypeRuleUnit.cs"
        return status;
    }
#line 556 "TypeRuleUnit.cs"
    int expectedKind = 1;
#line 557 "TypeRuleUnit.cs"
    if (((lastRow) != (0)))
    {
#line 558 "TypeRuleUnit.cs"
#line 558 "TypeRuleUnit.cs"
        int* csharp2cuda_temp_8 = &(expectedKind);
        (*(csharp2cuda_temp_8) = 4);
    }
#line 559 "TypeRuleUnit.cs"
#line 559 "TypeRuleUnit.cs"
    int csharp2cuda_temp_9 = (result).kind;
    if (((csharp2cuda_temp_9) != (expectedKind)))
    {
#line 560 "TypeRuleUnit.cs"
        return 2;
    }
#line 561 "TypeRuleUnit.cs"
    MathBlockDeviceType width = (inputs)[sourceArity];
#line 562 "TypeRuleUnit.cs"
#line 562 "TypeRuleUnit.cs"
    int csharp2cuda_temp_10 = (width).kind;
    if (((csharp2cuda_temp_10) != (1)))
    {
#line 563 "TypeRuleUnit.cs"
        return 2;
    }
#line 564 "TypeRuleUnit.cs"
#line 564 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_11 = &(width);
#line 564 "TypeRuleUnit.cs"
    bool csharp2cuda_temp_12 = mathblocks_type_unit_is_dimensionless(csharp2cuda_temp_11);
    if ((!(csharp2cuda_temp_12)))
    {
#line 565 "TypeRuleUnit.cs"
        return 3;
    }
#line 566 "TypeRuleUnit.cs"
#line 566 "TypeRuleUnit.cs"
    MathBlockDeviceType* csharp2cuda_temp_13 = &(result);
    return mathblocks_type_lift_result(inputs, csharp2cuda_temp_13, validity, csharp2cuda_i32_add(sourceArity, 1), rows, output);
}