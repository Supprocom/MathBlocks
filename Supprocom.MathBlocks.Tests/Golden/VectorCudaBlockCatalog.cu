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

#line 105 "VectorModule.cs"
__device__ double mathblocks_compensated_absolute_sum(const double* values, int count);

#line 85 "VectorModule.cs"
__device__ double mathblocks_compensated_product_sum(
    const double* first,
    const double* second,
    int count);

#line 68 "VectorModule.cs"
__device__ double mathblocks_compensated_sum(const double* values, int count);

#line 155 "VectorModule.cs"
__device__ void mathblocks_copy_and_sort(
    const MathBlockSlot* input,
    MathBlockSlot* output);

#line 47 "VectorModule.cs"
__device__ double mathblocks_maximum(double first, double second);

#line 35 "VectorModule.cs"
__device__ double mathblocks_minimum(double first, double second);

#line 59 "VectorModule.cs"
__device__ bool mathblocks_nonnegative_integer(double value, int* result);

#line 185 "VectorModule.cs"
__device__ double mathblocks_quantile(
    const MathBlockSlot* input,
    MathBlockSlot* output,
    double probability);

#line 168 "VectorModule.cs"
__device__ double mathblocks_quantile_values(
    const double* values,
    int count,
    double* sorted,
    double probability);

#line 122 "VectorModule.cs"
__device__ void mathblocks_set_vector_shape(MathBlockSlot* output, int count);

#line 136 "VectorModule.cs"
__device__ void mathblocks_sort_copy_values(
    const double* source,
    int count,
    double* sorted);

#line 221 "VectorModule.cs"
__device__ bool mathblocks_vector_arg_extreme_value(
    const double* values,
    int count,
    bool maximum,
    double* value);

#line 273 "VectorModule.cs"
__device__ void mathblocks_vector_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 198 "VectorModule.cs"
__device__ bool mathblocks_vector_geometric_mean_value(
    const double* values,
    int count,
    double* logarithms,
    double* value);

#line 238 "VectorModule.cs"
__device__ double mathblocks_vector_rank_at(
    const double* values,
    int count,
    int position);

#line 254 "VectorModule.cs"
__device__ void mathblocks_vector_standardize_moments(
    const double* values,
    int count,
    double* mean,
    double* deviation);

#line 105 "VectorModule.cs"
__device__ double mathblocks_compensated_absolute_sum(const double* values, int count)
#line 107 "VectorModule.cs"
{
#line 108 "VectorModule.cs"
    double sum = 0.0;
#line 109 "VectorModule.cs"
    double correction = 0.0;
#line 110 "VectorModule.cs"
    {
#line 110 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 111 "VectorModule.cs"
            {
#line 112 "VectorModule.cs"
                double csharp2cuda_temp_1 = (values)[index];
#line 112 "VectorModule.cs"
                double value = fabs(csharp2cuda_temp_1);
#line 113 "VectorModule.cs"
                double next = __dadd_rn(sum, value);
#line 114 "VectorModule.cs"
#line 114 "VectorModule.cs"
                double* csharp2cuda_temp_2 = &(correction);
#line 114 "VectorModule.cs"
                double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 114 "VectorModule.cs"
                double csharp2cuda_temp_4;
#line 114 "VectorModule.cs"
                if (((fabs(sum)) >= (fabs(value))))
                {
#line 114 "VectorModule.cs"
                    csharp2cuda_temp_4 = __dadd_rn(__dsub_rn(sum, next), value);
                }
                else
                {
#line 114 "VectorModule.cs"
                    csharp2cuda_temp_4 = __dadd_rn(__dsub_rn(value, next), sum);
                }
                (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, csharp2cuda_temp_4));
#line 117 "VectorModule.cs"
#line 117 "VectorModule.cs"
                double* csharp2cuda_temp_5 = &(sum);
                (*(csharp2cuda_temp_5) = next);
            }
#line 110 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 119 "VectorModule.cs"
    return __dadd_rn(sum, correction);
}

#line 85 "VectorModule.cs"
__device__ double mathblocks_compensated_product_sum(
    const double* first,
    const double* second,
    int count)
#line 90 "VectorModule.cs"
{
#line 91 "VectorModule.cs"
    double sum = 0.0;
#line 92 "VectorModule.cs"
    double correction = 0.0;
#line 93 "VectorModule.cs"
    {
#line 93 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 94 "VectorModule.cs"
            {
#line 95 "VectorModule.cs"
                double csharp2cuda_temp_1 = (first)[index];
#line 95 "VectorModule.cs"
                double csharp2cuda_temp_2 = (second)[index];
#line 95 "VectorModule.cs"
                double value = __dmul_rn(csharp2cuda_temp_1, csharp2cuda_temp_2);
#line 96 "VectorModule.cs"
                double next = __dadd_rn(sum, value);
#line 97 "VectorModule.cs"
#line 97 "VectorModule.cs"
                double* csharp2cuda_temp_3 = &(correction);
#line 97 "VectorModule.cs"
                double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 97 "VectorModule.cs"
                double csharp2cuda_temp_5;
#line 97 "VectorModule.cs"
                if (((fabs(sum)) >= (fabs(value))))
                {
#line 97 "VectorModule.cs"
                    csharp2cuda_temp_5 = __dadd_rn(__dsub_rn(sum, next), value);
                }
                else
                {
#line 97 "VectorModule.cs"
                    csharp2cuda_temp_5 = __dadd_rn(__dsub_rn(value, next), sum);
                }
                (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, csharp2cuda_temp_5));
#line 100 "VectorModule.cs"
#line 100 "VectorModule.cs"
                double* csharp2cuda_temp_6 = &(sum);
                (*(csharp2cuda_temp_6) = next);
            }
#line 93 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 102 "VectorModule.cs"
    return __dadd_rn(sum, correction);
}

#line 68 "VectorModule.cs"
__device__ double mathblocks_compensated_sum(const double* values, int count)
#line 70 "VectorModule.cs"
{
#line 71 "VectorModule.cs"
    double sum = 0.0;
#line 72 "VectorModule.cs"
    double correction = 0.0;
#line 73 "VectorModule.cs"
    {
#line 73 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 74 "VectorModule.cs"
            {
#line 75 "VectorModule.cs"
                double value = (values)[index];
#line 76 "VectorModule.cs"
                double next = __dadd_rn(sum, value);
#line 77 "VectorModule.cs"
#line 77 "VectorModule.cs"
                double* csharp2cuda_temp_1 = &(correction);
#line 77 "VectorModule.cs"
                double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
#line 77 "VectorModule.cs"
                double csharp2cuda_temp_3;
#line 77 "VectorModule.cs"
                if (((fabs(sum)) >= (fabs(value))))
                {
#line 77 "VectorModule.cs"
                    csharp2cuda_temp_3 = __dadd_rn(__dsub_rn(sum, next), value);
                }
                else
                {
#line 77 "VectorModule.cs"
                    csharp2cuda_temp_3 = __dadd_rn(__dsub_rn(value, next), sum);
                }
                (*(csharp2cuda_temp_1) = __dadd_rn(csharp2cuda_temp_2, csharp2cuda_temp_3));
#line 80 "VectorModule.cs"
#line 80 "VectorModule.cs"
                double* csharp2cuda_temp_4 = &(sum);
                (*(csharp2cuda_temp_4) = next);
            }
#line 73 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 82 "VectorModule.cs"
    return __dadd_rn(sum, correction);
}

#line 155 "VectorModule.cs"
__device__ void mathblocks_copy_and_sort(
    const MathBlockSlot* input,
    MathBlockSlot* output)
#line 159 "VectorModule.cs"
{
#line 160 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_0 = (output)->data_pointer;
#line 160 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_1;
#line 160 "VectorModule.cs"
    if (((csharp2cuda_temp_0) != (((unsigned long long)(0)))))
    {
#line 160 "VectorModule.cs"
        csharp2cuda_temp_1 = (output)->data_pointer;
    }
    else
    {
#line 160 "VectorModule.cs"
        csharp2cuda_temp_1 = (output)->scratch_pointer;
    }
#line 160 "VectorModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_1));
#line 163 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_2 = (input)->data_pointer;
#line 163 "VectorModule.cs"
    const double* source = ((double*)(csharp2cuda_temp_2));
#line 164 "VectorModule.cs"
#line 164 "VectorModule.cs"
    int csharp2cuda_temp_3 = (input)->count;
    mathblocks_sort_copy_values(source, csharp2cuda_temp_3, scratch);
}

#line 47 "VectorModule.cs"
__device__ double mathblocks_maximum(double first, double second)
#line 49 "VectorModule.cs"
{
#line 50 "VectorModule.cs"
    if (((first) > (second)))
    {
#line 51 "VectorModule.cs"
        return first;
    }
#line 52 "VectorModule.cs"
    if (((second) > (first)))
    {
#line 53 "VectorModule.cs"
        return second;
    }
#line 54 "VectorModule.cs"
    if (((first) == (0.0)))
    {
#line 55 "VectorModule.cs"
#line 55 "VectorModule.cs"
        double csharp2cuda_temp_0;
#line 55 "VectorModule.cs"
        if (signbit(first))
        {
#line 55 "VectorModule.cs"
            csharp2cuda_temp_0 = second;
        }
        else
        {
#line 55 "VectorModule.cs"
            csharp2cuda_temp_0 = first;
        }
        return csharp2cuda_temp_0;
    }
#line 56 "VectorModule.cs"
    return first;
}

#line 35 "VectorModule.cs"
__device__ double mathblocks_minimum(double first, double second)
#line 37 "VectorModule.cs"
{
#line 38 "VectorModule.cs"
    if (((first) < (second)))
    {
#line 39 "VectorModule.cs"
        return first;
    }
#line 40 "VectorModule.cs"
    if (((second) < (first)))
    {
#line 41 "VectorModule.cs"
        return second;
    }
#line 42 "VectorModule.cs"
    if (((first) == (0.0)))
    {
#line 43 "VectorModule.cs"
#line 43 "VectorModule.cs"
        double csharp2cuda_temp_0;
#line 43 "VectorModule.cs"
        if (signbit(first))
        {
#line 43 "VectorModule.cs"
            csharp2cuda_temp_0 = first;
        }
        else
        {
#line 43 "VectorModule.cs"
            csharp2cuda_temp_0 = second;
        }
        return csharp2cuda_temp_0;
    }
#line 44 "VectorModule.cs"
    return first;
}

#line 59 "VectorModule.cs"
__device__ bool mathblocks_nonnegative_integer(double value, int* result)
#line 61 "VectorModule.cs"
{
#line 62 "VectorModule.cs"
#line 62 "VectorModule.cs"
    bool csharp2cuda_temp_0;
#line 62 "VectorModule.cs"
    if (!(((value) < (0.0))))
    {
#line 62 "VectorModule.cs"
        csharp2cuda_temp_0 = ((value) > (2147483647.0));
    }
    else
    {
#line 62 "VectorModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 62 "VectorModule.cs"
    bool csharp2cuda_temp_1;
#line 62 "VectorModule.cs"
    if (!(csharp2cuda_temp_0))
    {
#line 62 "VectorModule.cs"
        csharp2cuda_temp_1 = ((value) != (trunc(value)));
    }
    else
    {
#line 62 "VectorModule.cs"
        csharp2cuda_temp_1 = true;
    }
    if (csharp2cuda_temp_1)
    {
#line 63 "VectorModule.cs"
        return false;
    }
#line 64 "VectorModule.cs"
#line 64 "VectorModule.cs"
    int* csharp2cuda_temp_2 = result;
    (*(csharp2cuda_temp_2) = csharp2cuda_f64_to_i32(value));
#line 65 "VectorModule.cs"
    return true;
}

#line 185 "VectorModule.cs"
__device__ double mathblocks_quantile(
    const MathBlockSlot* input,
    MathBlockSlot* output,
    double probability)
#line 190 "VectorModule.cs"
{
#line 191 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_0 = (output)->data_pointer;
#line 191 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_1;
#line 191 "VectorModule.cs"
    if (((csharp2cuda_temp_0) != (((unsigned long long)(0)))))
    {
#line 191 "VectorModule.cs"
        csharp2cuda_temp_1 = (output)->data_pointer;
    }
    else
    {
#line 191 "VectorModule.cs"
        csharp2cuda_temp_1 = (output)->scratch_pointer;
    }
#line 191 "VectorModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_1));
#line 194 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_2 = (input)->data_pointer;
#line 194 "VectorModule.cs"
    const double* source = ((double*)(csharp2cuda_temp_2));
#line 195 "VectorModule.cs"
#line 195 "VectorModule.cs"
    int csharp2cuda_temp_3 = (input)->count;
    return mathblocks_quantile_values(source, csharp2cuda_temp_3, scratch, probability);
}

#line 168 "VectorModule.cs"
__device__ double mathblocks_quantile_values(
    const double* values,
    int count,
    double* sorted,
    double probability)
#line 174 "VectorModule.cs"
{
#line 175 "VectorModule.cs"
    mathblocks_sort_copy_values(values, count, sorted);
#line 176 "VectorModule.cs"
    if (((count) == (1)))
    {
#line 177 "VectorModule.cs"
        return (sorted)[0];
    }
#line 178 "VectorModule.cs"
    double position = __dmul_rn(probability, ((double)(csharp2cuda_i32_sub(count, 1))));
#line 179 "VectorModule.cs"
    int lower = csharp2cuda_f64_to_i32(floor(position));
#line 180 "VectorModule.cs"
    int upper = csharp2cuda_f64_to_i32(ceil(position));
#line 181 "VectorModule.cs"
    double weight = __dsub_rn(position, ((double)(lower)));
#line 182 "VectorModule.cs"
#line 182 "VectorModule.cs"
    double csharp2cuda_temp_0 = (sorted)[lower];
#line 182 "VectorModule.cs"
    double csharp2cuda_temp_1 = (sorted)[upper];
    return __dadd_rn(__dmul_rn(csharp2cuda_temp_0, __dsub_rn(1.0, weight)), __dmul_rn(csharp2cuda_temp_1, weight));
}

#line 122 "VectorModule.cs"
__device__ void mathblocks_set_vector_shape(MathBlockSlot* output, int count)
#line 124 "VectorModule.cs"
{
#line 125 "VectorModule.cs"
#line 125 "VectorModule.cs"
    int* csharp2cuda_temp_0 = &((output)->rows);
    (*(csharp2cuda_temp_0) = count);
#line 126 "VectorModule.cs"
#line 126 "VectorModule.cs"
    int* csharp2cuda_temp_1 = &((output)->columns);
    (*(csharp2cuda_temp_1) = 0);
#line 127 "VectorModule.cs"
#line 127 "VectorModule.cs"
    int* csharp2cuda_temp_2 = &((output)->count);
    (*(csharp2cuda_temp_2) = count);
#line 128 "VectorModule.cs"
#line 128 "VectorModule.cs"
    bool csharp2cuda_temp_3;
#line 128 "VectorModule.cs"
    if (!(((count) < (0))))
    {
#line 128 "VectorModule.cs"
        int csharp2cuda_temp_4 = (output)->capacity;
#line 128 "VectorModule.cs"
        csharp2cuda_temp_3 = ((count) > (csharp2cuda_temp_4));
    }
    else
    {
#line 128 "VectorModule.cs"
        csharp2cuda_temp_3 = true;
    }
    if (csharp2cuda_temp_3)
#line 129 "VectorModule.cs"
    {
#line 130 "VectorModule.cs"
#line 130 "VectorModule.cs"
        int* csharp2cuda_temp_5 = &((output)->valid);
        (*(csharp2cuda_temp_5) = 0);
#line 131 "VectorModule.cs"
        return;
    }
}

#line 136 "VectorModule.cs"
__device__ void mathblocks_sort_copy_values(
    const double* source,
    int count,
    double* sorted)
#line 141 "VectorModule.cs"
{
#line 142 "VectorModule.cs"
    {
#line 142 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 143 "VectorModule.cs"
            {
#line 144 "VectorModule.cs"
                double value = (source)[index];
#line 145 "VectorModule.cs"
                int position = index;
#line 146 "VectorModule.cs"
                while (true)
                {
#line 146 "VectorModule.cs"
                    bool csharp2cuda_temp_1;
#line 146 "VectorModule.cs"
                    if (((position) > (0)))
                    {
#line 146 "VectorModule.cs"
                        double csharp2cuda_temp_2 = (sorted)[csharp2cuda_i32_sub(position, 1)];
#line 146 "VectorModule.cs"
                        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) > (value));
                    }
                    else
                    {
#line 146 "VectorModule.cs"
                        csharp2cuda_temp_1 = false;
                    }
                    if (!(csharp2cuda_temp_1))
                        break;
#line 147 "VectorModule.cs"
                    {
#line 148 "VectorModule.cs"
#line 148 "VectorModule.cs"
                        double* csharp2cuda_temp_3 = &((sorted)[position]);
#line 148 "VectorModule.cs"
                        double csharp2cuda_temp_4 = (sorted)[csharp2cuda_i32_sub(position, 1)];
                        (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 149 "VectorModule.cs"
#line 149 "VectorModule.cs"
                        int* csharp2cuda_temp_5 = &(position);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_5));
                    }
                }
#line 151 "VectorModule.cs"
#line 151 "VectorModule.cs"
                double* csharp2cuda_temp_6 = &((sorted)[position]);
                (*(csharp2cuda_temp_6) = value);
            }
#line 142 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 221 "VectorModule.cs"
__device__ bool mathblocks_vector_arg_extreme_value(
    const double* values,
    int count,
    bool maximum,
    double* value)
#line 227 "VectorModule.cs"
{
#line 228 "VectorModule.cs"
    if (((count) <= (0)))
    {
#line 229 "VectorModule.cs"
        return false;
    }
#line 230 "VectorModule.cs"
    int selected = 0;
#line 231 "VectorModule.cs"
    {
#line 231 "VectorModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 232 "VectorModule.cs"
#line 232 "VectorModule.cs"
            bool csharp2cuda_temp_1;
#line 232 "VectorModule.cs"
            if (maximum)
            {
#line 232 "VectorModule.cs"
                double csharp2cuda_temp_2 = (values)[index];
#line 232 "VectorModule.cs"
                double csharp2cuda_temp_3 = (values)[selected];
#line 232 "VectorModule.cs"
                csharp2cuda_temp_1 = ((csharp2cuda_temp_2) > (csharp2cuda_temp_3));
            }
            else
            {
#line 232 "VectorModule.cs"
                double csharp2cuda_temp_4 = (values)[index];
#line 232 "VectorModule.cs"
                double csharp2cuda_temp_5 = (values)[selected];
#line 232 "VectorModule.cs"
                csharp2cuda_temp_1 = ((csharp2cuda_temp_4) < (csharp2cuda_temp_5));
            }
            if (csharp2cuda_temp_1)
            {
#line 232 "VectorModule.cs"
#line 232 "VectorModule.cs"
                int* csharp2cuda_temp_6 = &(selected);
                (*(csharp2cuda_temp_6) = index);
            }
#line 231 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 233 "VectorModule.cs"
#line 233 "VectorModule.cs"
    double* csharp2cuda_temp_7 = value;
    (*(csharp2cuda_temp_7) = ((double)(selected)));
#line 234 "VectorModule.cs"
    return true;
}

#line 273 "VectorModule.cs"
__device__ void mathblocks_vector_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 279 "VectorModule.cs"
{
#line 280 "VectorModule.cs"
    int thread = threadIdx.x;
#line 281 "VectorModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 281 "VectorModule.cs"
    if (((input_count) > (0)))
    {
#line 281 "VectorModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 281 "VectorModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 281 "VectorModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 282 "VectorModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 282 "VectorModule.cs"
    if (((input_count) > (1)))
    {
#line 282 "VectorModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 282 "VectorModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 282 "VectorModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 283 "VectorModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 283 "VectorModule.cs"
    if (((input_count) > (2)))
    {
#line 283 "VectorModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 283 "VectorModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 283 "VectorModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 285 "VectorModule.cs"
    if (((thread) == (0)))
#line 286 "VectorModule.cs"
    {
#line 287 "VectorModule.cs"
#line 287 "VectorModule.cs"
        double* csharp2cuda_temp_3 = &((output)->scalar_value);
        (*(csharp2cuda_temp_3) = 0.0);
#line 288 "VectorModule.cs"
#line 288 "VectorModule.cs"
        int* csharp2cuda_temp_4 = &((output)->boolean_value);
        (*(csharp2cuda_temp_4) = 0);
#line 289 "VectorModule.cs"
#line 289 "VectorModule.cs"
        int* csharp2cuda_temp_5 = &((output)->rows);
        (*(csharp2cuda_temp_5) = 0);
#line 290 "VectorModule.cs"
#line 290 "VectorModule.cs"
        int* csharp2cuda_temp_6 = &((output)->columns);
        (*(csharp2cuda_temp_6) = 0);
#line 291 "VectorModule.cs"
#line 291 "VectorModule.cs"
        int* csharp2cuda_temp_7 = &((output)->count);
        (*(csharp2cuda_temp_7) = 0);
#line 292 "VectorModule.cs"
#line 292 "VectorModule.cs"
        int* csharp2cuda_temp_8 = &((output)->valid);
#line 292 "VectorModule.cs"
        bool csharp2cuda_temp_9;
#line 292 "VectorModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 292 "VectorModule.cs"
            csharp2cuda_temp_9 = (first)->valid;
        }
        else
        {
#line 292 "VectorModule.cs"
            csharp2cuda_temp_9 = true;
        }
        (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
#line 293 "VectorModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 294 "VectorModule.cs"
#line 294 "VectorModule.cs"
            int* csharp2cuda_temp_10 = &((output)->valid);
#line 294 "VectorModule.cs"
            bool csharp2cuda_temp_11 = (output)->valid;
#line 294 "VectorModule.cs"
            bool csharp2cuda_temp_12;
#line 294 "VectorModule.cs"
            if (csharp2cuda_temp_11)
            {
#line 294 "VectorModule.cs"
                csharp2cuda_temp_12 = (second)->valid;
            }
            else
            {
#line 294 "VectorModule.cs"
                csharp2cuda_temp_12 = false;
            }
            (*(csharp2cuda_temp_10) = csharp2cuda_temp_12);
        }
#line 295 "VectorModule.cs"
        if (((((void*)(third))) != (((void*)(nullptr)))))
        {
#line 296 "VectorModule.cs"
#line 296 "VectorModule.cs"
            int* csharp2cuda_temp_13 = &((output)->valid);
#line 296 "VectorModule.cs"
            bool csharp2cuda_temp_14 = (output)->valid;
#line 296 "VectorModule.cs"
            bool csharp2cuda_temp_15;
#line 296 "VectorModule.cs"
            if (csharp2cuda_temp_14)
            {
#line 296 "VectorModule.cs"
                csharp2cuda_temp_15 = (third)->valid;
            }
            else
            {
#line 296 "VectorModule.cs"
                csharp2cuda_temp_15 = false;
            }
            (*(csharp2cuda_temp_13) = csharp2cuda_temp_15);
        }
    }
#line 298 "VectorModule.cs"
    __syncthreads();
#line 299 "VectorModule.cs"
#line 299 "VectorModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 300 "VectorModule.cs"
        return;
    }
#line 302 "VectorModule.cs"
    double* csharp2cuda_temp_17;
#line 302 "VectorModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 302 "VectorModule.cs"
        csharp2cuda_temp_17 = ((double*)(nullptr));
    }
    else
    {
#line 302 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 302 "VectorModule.cs"
        csharp2cuda_temp_17 = ((double*)(csharp2cuda_temp_18));
    }
#line 302 "VectorModule.cs"
    const double* a = csharp2cuda_temp_17;
#line 303 "VectorModule.cs"
    double* csharp2cuda_temp_19;
#line 303 "VectorModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 303 "VectorModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 303 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 303 "VectorModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 303 "VectorModule.cs"
    const double* b = csharp2cuda_temp_19;
#line 304 "VectorModule.cs"
    double* csharp2cuda_temp_21;
#line 304 "VectorModule.cs"
    if (((((void*)(third))) == (((void*)(nullptr)))))
    {
#line 304 "VectorModule.cs"
        csharp2cuda_temp_21 = ((double*)(nullptr));
    }
    else
    {
#line 304 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_22 = (third)->data_pointer;
#line 304 "VectorModule.cs"
        csharp2cuda_temp_21 = ((double*)(csharp2cuda_temp_22));
    }
#line 304 "VectorModule.cs"
    const double* c = csharp2cuda_temp_21;
#line 305 "VectorModule.cs"
    int* csharp2cuda_temp_23;
#line 305 "VectorModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 305 "VectorModule.cs"
        csharp2cuda_temp_23 = ((int*)(nullptr));
    }
    else
    {
#line 305 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_24 = (first)->data_pointer;
#line 305 "VectorModule.cs"
        csharp2cuda_temp_23 = ((int*)(csharp2cuda_temp_24));
    }
#line 305 "VectorModule.cs"
    const int* boolean_a = csharp2cuda_temp_23;
#line 306 "VectorModule.cs"
    int* csharp2cuda_temp_25;
#line 306 "VectorModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 306 "VectorModule.cs"
        csharp2cuda_temp_25 = ((int*)(nullptr));
    }
    else
    {
#line 306 "VectorModule.cs"
        unsigned long long csharp2cuda_temp_26 = (second)->data_pointer;
#line 306 "VectorModule.cs"
        csharp2cuda_temp_25 = ((int*)(csharp2cuda_temp_26));
    }
#line 306 "VectorModule.cs"
    const int* boolean_b = csharp2cuda_temp_25;
#line 307 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_27 = (output)->data_pointer;
#line 307 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_28;
#line 307 "VectorModule.cs"
    if (((csharp2cuda_temp_27) != (((unsigned long long)(0)))))
    {
#line 307 "VectorModule.cs"
        csharp2cuda_temp_28 = (output)->data_pointer;
    }
    else
    {
#line 307 "VectorModule.cs"
        csharp2cuda_temp_28 = (output)->scratch_pointer;
    }
#line 307 "VectorModule.cs"
    double* result = ((double*)(csharp2cuda_temp_28));
#line 310 "VectorModule.cs"
    unsigned long long csharp2cuda_temp_29 = (output)->data_pointer;
#line 310 "VectorModule.cs"
    int* boolean_result = ((int*)(csharp2cuda_temp_29));
#line 312 "VectorModule.cs"
    switch (opcode)
    {
#line 314 "VectorModule.cs"
        case 0:
#line 315 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 315 "VectorModule.cs"
#line 315 "VectorModule.cs"
                int csharp2cuda_temp_30 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_30);
            }
#line 316 "VectorModule.cs"
            __syncthreads();
#line 317 "VectorModule.cs"
            {
#line 317 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 317 "VectorModule.cs"
                    bool csharp2cuda_temp_33 = (output)->valid;
#line 317 "VectorModule.cs"
                    bool csharp2cuda_temp_34;
#line 317 "VectorModule.cs"
                    if (csharp2cuda_temp_33)
                    {
#line 317 "VectorModule.cs"
                        int csharp2cuda_temp_35 = (first)->count;
#line 317 "VectorModule.cs"
                        csharp2cuda_temp_34 = ((index) < (csharp2cuda_temp_35));
                    }
                    else
                    {
#line 317 "VectorModule.cs"
                        csharp2cuda_temp_34 = false;
                    }
                    if (!(csharp2cuda_temp_34))
                        break;
#line 318 "VectorModule.cs"
#line 318 "VectorModule.cs"
                    double* csharp2cuda_temp_36 = &((result)[index]);
#line 318 "VectorModule.cs"
                    double csharp2cuda_temp_37 = (a)[index];
                    (*(csharp2cuda_temp_36) = fabs(csharp2cuda_temp_37));
#line 317 "VectorModule.cs"
                    int* csharp2cuda_temp_31 = &(index);
#line 317 "VectorModule.cs"
                    int csharp2cuda_temp_32 = *(csharp2cuda_temp_31);
                    (*(csharp2cuda_temp_31) = csharp2cuda_i32_add(csharp2cuda_temp_32, blockDim.x));
                }
            }
#line 319 "VectorModule.cs"
            break;
#line 320 "VectorModule.cs"
        case 1:
#line 321 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 321 "VectorModule.cs"
#line 321 "VectorModule.cs"
                int csharp2cuda_temp_38 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_38);
            }
#line 322 "VectorModule.cs"
            __syncthreads();
#line 323 "VectorModule.cs"
            {
#line 323 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 323 "VectorModule.cs"
                    bool csharp2cuda_temp_41 = (output)->valid;
#line 323 "VectorModule.cs"
                    bool csharp2cuda_temp_42;
#line 323 "VectorModule.cs"
                    if (csharp2cuda_temp_41)
                    {
#line 323 "VectorModule.cs"
                        int csharp2cuda_temp_43 = (first)->count;
#line 323 "VectorModule.cs"
                        csharp2cuda_temp_42 = ((index) < (csharp2cuda_temp_43));
                    }
                    else
                    {
#line 323 "VectorModule.cs"
                        csharp2cuda_temp_42 = false;
                    }
                    if (!(csharp2cuda_temp_42))
                        break;
#line 324 "VectorModule.cs"
                    {
#line 325 "VectorModule.cs"
#line 325 "VectorModule.cs"
                        double* csharp2cuda_temp_44 = &((result)[index]);
#line 325 "VectorModule.cs"
                        double csharp2cuda_temp_45 = (a)[index];
#line 325 "VectorModule.cs"
                        double csharp2cuda_temp_46 = (second)->scalar_value;
                        (*(csharp2cuda_temp_44) = __dadd_rn(csharp2cuda_temp_45, csharp2cuda_temp_46));
#line 326 "VectorModule.cs"
#line 326 "VectorModule.cs"
                        double csharp2cuda_temp_47 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_47))))
                        {
#line 326 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 323 "VectorModule.cs"
                    int* csharp2cuda_temp_39 = &(index);
#line 323 "VectorModule.cs"
                    int csharp2cuda_temp_40 = *(csharp2cuda_temp_39);
                    (*(csharp2cuda_temp_39) = csharp2cuda_i32_add(csharp2cuda_temp_40, blockDim.x));
                }
            }
#line 328 "VectorModule.cs"
            break;
#line 329 "VectorModule.cs"
        case 2:
        case 9:
        case 26:
        case 47:
#line 333 "VectorModule.cs"
            if (((thread) == (0)))
#line 334 "VectorModule.cs"
            {
#line 335 "VectorModule.cs"
#line 335 "VectorModule.cs"
                int csharp2cuda_temp_48 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_48);
#line 336 "VectorModule.cs"
#line 336 "VectorModule.cs"
                int csharp2cuda_temp_49 = (first)->count;
#line 336 "VectorModule.cs"
                int csharp2cuda_temp_50 = (second)->count;
                if (((csharp2cuda_temp_49) != (csharp2cuda_temp_50)))
                {
#line 336 "VectorModule.cs"
#line 336 "VectorModule.cs"
                    int* csharp2cuda_temp_51 = &((output)->valid);
                    (*(csharp2cuda_temp_51) = 0);
                }
            }
#line 338 "VectorModule.cs"
            __syncthreads();
#line 339 "VectorModule.cs"
            {
#line 339 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 339 "VectorModule.cs"
                    bool csharp2cuda_temp_54 = (output)->valid;
#line 339 "VectorModule.cs"
                    bool csharp2cuda_temp_55;
#line 339 "VectorModule.cs"
                    if (csharp2cuda_temp_54)
                    {
#line 339 "VectorModule.cs"
                        int csharp2cuda_temp_56 = (first)->count;
#line 339 "VectorModule.cs"
                        csharp2cuda_temp_55 = ((index) < (csharp2cuda_temp_56));
                    }
                    else
                    {
#line 339 "VectorModule.cs"
                        csharp2cuda_temp_55 = false;
                    }
                    if (!(csharp2cuda_temp_55))
                        break;
#line 340 "VectorModule.cs"
                    {
#line 341 "VectorModule.cs"
                        double csharp2cuda_temp_57;
#line 341 "VectorModule.cs"
                        if (((opcode) == (2)))
                        {
#line 341 "VectorModule.cs"
                            double csharp2cuda_temp_58 = (a)[index];
#line 341 "VectorModule.cs"
                            double csharp2cuda_temp_59 = (b)[index];
#line 341 "VectorModule.cs"
                            csharp2cuda_temp_57 = __dadd_rn(csharp2cuda_temp_58, csharp2cuda_temp_59);
                        }
                        else
                        {
#line 342 "VectorModule.cs"
                            double csharp2cuda_temp_60;
#line 342 "VectorModule.cs"
                            if (((opcode) == (9)))
                            {
#line 342 "VectorModule.cs"
                                double csharp2cuda_temp_61 = (a)[index];
#line 342 "VectorModule.cs"
                                double csharp2cuda_temp_62 = (b)[index];
#line 342 "VectorModule.cs"
                                csharp2cuda_temp_60 = __ddiv_rn(csharp2cuda_temp_61, csharp2cuda_temp_62);
                            }
                            else
                            {
#line 343 "VectorModule.cs"
                                double csharp2cuda_temp_63;
#line 343 "VectorModule.cs"
                                if (((opcode) == (26)))
                                {
#line 343 "VectorModule.cs"
                                    double csharp2cuda_temp_64 = (a)[index];
#line 343 "VectorModule.cs"
                                    double csharp2cuda_temp_65 = (b)[index];
#line 343 "VectorModule.cs"
                                    csharp2cuda_temp_63 = __dmul_rn(csharp2cuda_temp_64, csharp2cuda_temp_65);
                                }
                                else
                                {
#line 344 "VectorModule.cs"
                                    double csharp2cuda_temp_66 = (a)[index];
#line 344 "VectorModule.cs"
                                    double csharp2cuda_temp_67 = (b)[index];
#line 343 "VectorModule.cs"
                                    csharp2cuda_temp_63 = __dsub_rn(csharp2cuda_temp_66, csharp2cuda_temp_67);
                                }
#line 342 "VectorModule.cs"
                                csharp2cuda_temp_60 = csharp2cuda_temp_63;
                            }
#line 341 "VectorModule.cs"
                            csharp2cuda_temp_57 = csharp2cuda_temp_60;
                        }
#line 341 "VectorModule.cs"
                        double value = csharp2cuda_temp_57;
#line 345 "VectorModule.cs"
#line 345 "VectorModule.cs"
                        double* csharp2cuda_temp_68 = &((result)[index]);
                        (*(csharp2cuda_temp_68) = value);
#line 346 "VectorModule.cs"
                        if ((!(isfinite(value))))
                        {
#line 346 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 339 "VectorModule.cs"
                    int* csharp2cuda_temp_52 = &(index);
#line 339 "VectorModule.cs"
                    int csharp2cuda_temp_53 = *(csharp2cuda_temp_52);
                    (*(csharp2cuda_temp_52) = csharp2cuda_i32_add(csharp2cuda_temp_53, blockDim.x));
                }
            }
#line 348 "VectorModule.cs"
            break;
#line 349 "VectorModule.cs"
        case 3:
#line 350 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 350 "VectorModule.cs"
#line 350 "VectorModule.cs"
                int csharp2cuda_temp_69 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_69, 1));
            }
#line 351 "VectorModule.cs"
            __syncthreads();
#line 352 "VectorModule.cs"
            {
#line 352 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 352 "VectorModule.cs"
                    bool csharp2cuda_temp_72 = (output)->valid;
#line 352 "VectorModule.cs"
                    bool csharp2cuda_temp_73;
#line 352 "VectorModule.cs"
                    if (csharp2cuda_temp_72)
                    {
#line 352 "VectorModule.cs"
                        int csharp2cuda_temp_74 = (first)->count;
#line 352 "VectorModule.cs"
                        csharp2cuda_temp_73 = ((index) < (csharp2cuda_temp_74));
                    }
                    else
                    {
#line 352 "VectorModule.cs"
                        csharp2cuda_temp_73 = false;
                    }
                    if (!(csharp2cuda_temp_73))
                        break;
#line 353 "VectorModule.cs"
#line 353 "VectorModule.cs"
                    double* csharp2cuda_temp_75 = &((result)[index]);
#line 353 "VectorModule.cs"
                    double csharp2cuda_temp_76 = (a)[index];
                    (*(csharp2cuda_temp_75) = csharp2cuda_temp_76);
#line 352 "VectorModule.cs"
                    int* csharp2cuda_temp_70 = &(index);
#line 352 "VectorModule.cs"
                    int csharp2cuda_temp_71 = *(csharp2cuda_temp_70);
                    (*(csharp2cuda_temp_70) = csharp2cuda_i32_add(csharp2cuda_temp_71, blockDim.x));
                }
            }
#line 354 "VectorModule.cs"
#line 354 "VectorModule.cs"
            bool csharp2cuda_temp_77;
#line 354 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 354 "VectorModule.cs"
                csharp2cuda_temp_77 = (output)->valid;
            }
            else
            {
#line 354 "VectorModule.cs"
                csharp2cuda_temp_77 = false;
            }
            if (csharp2cuda_temp_77)
            {
#line 354 "VectorModule.cs"
#line 354 "VectorModule.cs"
                int csharp2cuda_temp_78 = (first)->count;
#line 354 "VectorModule.cs"
                double* csharp2cuda_temp_79 = &((result)[csharp2cuda_temp_78]);
#line 354 "VectorModule.cs"
                double csharp2cuda_temp_80 = (second)->scalar_value;
                (*(csharp2cuda_temp_79) = csharp2cuda_temp_80);
            }
#line 355 "VectorModule.cs"
            break;
#line 356 "VectorModule.cs"
        case 4:
        case 5:
#line 358 "VectorModule.cs"
#line 358 "VectorModule.cs"
            bool csharp2cuda_temp_81;
#line 358 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 359 "VectorModule.cs"
                int csharp2cuda_temp_82 = (first)->count;
#line 359 "VectorModule.cs"
                double* csharp2cuda_temp_83 = &((output)->scalar_value);
#line 359 "VectorModule.cs"
                bool csharp2cuda_temp_84 = mathblocks_vector_arg_extreme_value(a, csharp2cuda_temp_82, ((opcode) == (4)), csharp2cuda_temp_83);
#line 358 "VectorModule.cs"
                csharp2cuda_temp_81 = (!(csharp2cuda_temp_84));
            }
            else
            {
#line 358 "VectorModule.cs"
                csharp2cuda_temp_81 = false;
            }
            if (csharp2cuda_temp_81)
            {
#line 360 "VectorModule.cs"
#line 360 "VectorModule.cs"
                int* csharp2cuda_temp_85 = &((output)->valid);
                (*(csharp2cuda_temp_85) = 0);
            }
#line 361 "VectorModule.cs"
            break;
#line 362 "VectorModule.cs"
        case 6:
#line 363 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 363 "VectorModule.cs"
#line 363 "VectorModule.cs"
                int csharp2cuda_temp_86 = (first)->count;
#line 363 "VectorModule.cs"
                int csharp2cuda_temp_87 = (second)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_86, csharp2cuda_temp_87));
            }
#line 364 "VectorModule.cs"
            __syncthreads();
#line 365 "VectorModule.cs"
            {
#line 365 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 365 "VectorModule.cs"
                    bool csharp2cuda_temp_90 = (output)->valid;
#line 365 "VectorModule.cs"
                    bool csharp2cuda_temp_91;
#line 365 "VectorModule.cs"
                    if (csharp2cuda_temp_90)
                    {
#line 365 "VectorModule.cs"
                        int csharp2cuda_temp_92 = (first)->count;
#line 365 "VectorModule.cs"
                        csharp2cuda_temp_91 = ((index) < (csharp2cuda_temp_92));
                    }
                    else
                    {
#line 365 "VectorModule.cs"
                        csharp2cuda_temp_91 = false;
                    }
                    if (!(csharp2cuda_temp_91))
                        break;
#line 366 "VectorModule.cs"
#line 366 "VectorModule.cs"
                    double* csharp2cuda_temp_93 = &((result)[index]);
#line 366 "VectorModule.cs"
                    double csharp2cuda_temp_94 = (a)[index];
                    (*(csharp2cuda_temp_93) = csharp2cuda_temp_94);
#line 365 "VectorModule.cs"
                    int* csharp2cuda_temp_88 = &(index);
#line 365 "VectorModule.cs"
                    int csharp2cuda_temp_89 = *(csharp2cuda_temp_88);
                    (*(csharp2cuda_temp_88) = csharp2cuda_i32_add(csharp2cuda_temp_89, blockDim.x));
                }
            }
#line 367 "VectorModule.cs"
            {
#line 367 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 367 "VectorModule.cs"
                    bool csharp2cuda_temp_97 = (output)->valid;
#line 367 "VectorModule.cs"
                    bool csharp2cuda_temp_98;
#line 367 "VectorModule.cs"
                    if (csharp2cuda_temp_97)
                    {
#line 367 "VectorModule.cs"
                        int csharp2cuda_temp_99 = (second)->count;
#line 367 "VectorModule.cs"
                        csharp2cuda_temp_98 = ((index) < (csharp2cuda_temp_99));
                    }
                    else
                    {
#line 367 "VectorModule.cs"
                        csharp2cuda_temp_98 = false;
                    }
                    if (!(csharp2cuda_temp_98))
                        break;
#line 368 "VectorModule.cs"
#line 368 "VectorModule.cs"
                    int csharp2cuda_temp_100 = (first)->count;
#line 368 "VectorModule.cs"
                    double* csharp2cuda_temp_101 = &((result)[csharp2cuda_i32_add(csharp2cuda_temp_100, index)]);
#line 368 "VectorModule.cs"
                    double csharp2cuda_temp_102 = (b)[index];
                    (*(csharp2cuda_temp_101) = csharp2cuda_temp_102);
#line 367 "VectorModule.cs"
                    int* csharp2cuda_temp_95 = &(index);
#line 367 "VectorModule.cs"
                    int csharp2cuda_temp_96 = *(csharp2cuda_temp_95);
                    (*(csharp2cuda_temp_95) = csharp2cuda_i32_add(csharp2cuda_temp_96, blockDim.x));
                }
            }
#line 369 "VectorModule.cs"
            break;
#line 370 "VectorModule.cs"
        case 7:
#line 371 "VectorModule.cs"
            if (((thread) == (0)))
#line 372 "VectorModule.cs"
            {
#line 373 "VectorModule.cs"
#line 373 "VectorModule.cs"
                int csharp2cuda_temp_103 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_103);
#line 374 "VectorModule.cs"
                double product = 1.0;
#line 375 "VectorModule.cs"
                {
#line 375 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 375 "VectorModule.cs"
                        bool csharp2cuda_temp_105 = (output)->valid;
#line 375 "VectorModule.cs"
                        bool csharp2cuda_temp_106;
#line 375 "VectorModule.cs"
                        if (csharp2cuda_temp_105)
                        {
#line 375 "VectorModule.cs"
                            int csharp2cuda_temp_107 = (first)->count;
#line 375 "VectorModule.cs"
                            csharp2cuda_temp_106 = ((index) < (csharp2cuda_temp_107));
                        }
                        else
                        {
#line 375 "VectorModule.cs"
                            csharp2cuda_temp_106 = false;
                        }
                        if (!(csharp2cuda_temp_106))
                            break;
#line 376 "VectorModule.cs"
                        {
#line 377 "VectorModule.cs"
#line 377 "VectorModule.cs"
                            double* csharp2cuda_temp_108 = &(product);
#line 377 "VectorModule.cs"
                            double csharp2cuda_temp_109 = *(csharp2cuda_temp_108);
#line 377 "VectorModule.cs"
                            double csharp2cuda_temp_110 = (a)[index];
                            (*(csharp2cuda_temp_108) = __dmul_rn(csharp2cuda_temp_109, csharp2cuda_temp_110));
#line 378 "VectorModule.cs"
#line 378 "VectorModule.cs"
                            double* csharp2cuda_temp_111 = &((result)[index]);
                            (*(csharp2cuda_temp_111) = product);
#line 379 "VectorModule.cs"
                            if ((!(isfinite(product))))
                            {
#line 379 "VectorModule.cs"
#line 379 "VectorModule.cs"
                                int* csharp2cuda_temp_112 = &((output)->valid);
                                (*(csharp2cuda_temp_112) = 0);
                            }
                        }
#line 375 "VectorModule.cs"
                        int* csharp2cuda_temp_104 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_104));
                    }
                }
            }
#line 382 "VectorModule.cs"
            break;
#line 383 "VectorModule.cs"
        case 8:
#line 384 "VectorModule.cs"
            if (((thread) == (0)))
#line 385 "VectorModule.cs"
            {
#line 386 "VectorModule.cs"
#line 386 "VectorModule.cs"
                int csharp2cuda_temp_113 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_113);
#line 387 "VectorModule.cs"
                double sum = 0.0;
#line 388 "VectorModule.cs"
                {
#line 388 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 388 "VectorModule.cs"
                        bool csharp2cuda_temp_115 = (output)->valid;
#line 388 "VectorModule.cs"
                        bool csharp2cuda_temp_116;
#line 388 "VectorModule.cs"
                        if (csharp2cuda_temp_115)
                        {
#line 388 "VectorModule.cs"
                            int csharp2cuda_temp_117 = (first)->count;
#line 388 "VectorModule.cs"
                            csharp2cuda_temp_116 = ((index) < (csharp2cuda_temp_117));
                        }
                        else
                        {
#line 388 "VectorModule.cs"
                            csharp2cuda_temp_116 = false;
                        }
                        if (!(csharp2cuda_temp_116))
                            break;
#line 389 "VectorModule.cs"
                        {
#line 390 "VectorModule.cs"
#line 390 "VectorModule.cs"
                            double* csharp2cuda_temp_118 = &(sum);
#line 390 "VectorModule.cs"
                            double csharp2cuda_temp_119 = *(csharp2cuda_temp_118);
#line 390 "VectorModule.cs"
                            double csharp2cuda_temp_120 = (a)[index];
                            (*(csharp2cuda_temp_118) = __dadd_rn(csharp2cuda_temp_119, csharp2cuda_temp_120));
#line 391 "VectorModule.cs"
#line 391 "VectorModule.cs"
                            double* csharp2cuda_temp_121 = &((result)[index]);
                            (*(csharp2cuda_temp_121) = sum);
#line 392 "VectorModule.cs"
                            if ((!(isfinite(sum))))
                            {
#line 392 "VectorModule.cs"
#line 392 "VectorModule.cs"
                                int* csharp2cuda_temp_122 = &((output)->valid);
                                (*(csharp2cuda_temp_122) = 0);
                            }
                        }
#line 388 "VectorModule.cs"
                        int* csharp2cuda_temp_114 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_114));
                    }
                }
            }
#line 395 "VectorModule.cs"
            break;
#line 396 "VectorModule.cs"
        case 10:
#line 397 "VectorModule.cs"
            if (((thread) == (0)))
#line 398 "VectorModule.cs"
            {
#line 399 "VectorModule.cs"
#line 399 "VectorModule.cs"
                int csharp2cuda_temp_123 = (first)->count;
#line 399 "VectorModule.cs"
                int csharp2cuda_temp_124 = (second)->count;
                if (((csharp2cuda_temp_123) != (csharp2cuda_temp_124)))
                {
#line 399 "VectorModule.cs"
#line 399 "VectorModule.cs"
                    int* csharp2cuda_temp_125 = &((output)->valid);
                    (*(csharp2cuda_temp_125) = 0);
                }
                else
#line 401 "VectorModule.cs"
                {
#line 402 "VectorModule.cs"
#line 402 "VectorModule.cs"
                    double* csharp2cuda_temp_126 = &((output)->scalar_value);
#line 402 "VectorModule.cs"
                    int csharp2cuda_temp_127 = (first)->count;
#line 402 "VectorModule.cs"
                    double csharp2cuda_temp_128 = mathblocks_compensated_product_sum(a, b, csharp2cuda_temp_127);
                    (*(csharp2cuda_temp_126) = csharp2cuda_temp_128);
#line 403 "VectorModule.cs"
#line 403 "VectorModule.cs"
                    double csharp2cuda_temp_129 = (output)->scalar_value;
                    if ((!(isfinite(csharp2cuda_temp_129))))
                    {
#line 403 "VectorModule.cs"
#line 403 "VectorModule.cs"
                        int* csharp2cuda_temp_130 = &((output)->valid);
                        (*(csharp2cuda_temp_130) = 0);
                    }
                }
            }
#line 406 "VectorModule.cs"
            break;
#line 407 "VectorModule.cs"
        case 11:
        case 15:
        case 20:
#line 410 "VectorModule.cs"
            if (((thread) == (0)))
#line 411 "VectorModule.cs"
            {
#line 412 "VectorModule.cs"
#line 412 "VectorModule.cs"
                int csharp2cuda_temp_131 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_131);
#line 413 "VectorModule.cs"
#line 413 "VectorModule.cs"
                int csharp2cuda_temp_132 = (first)->count;
#line 413 "VectorModule.cs"
                int csharp2cuda_temp_133 = (second)->count;
                if (((csharp2cuda_temp_132) != (csharp2cuda_temp_133)))
                {
#line 413 "VectorModule.cs"
#line 413 "VectorModule.cs"
                    int* csharp2cuda_temp_134 = &((output)->valid);
                    (*(csharp2cuda_temp_134) = 0);
                }
            }
#line 415 "VectorModule.cs"
            __syncthreads();
#line 416 "VectorModule.cs"
            {
#line 416 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 416 "VectorModule.cs"
                    bool csharp2cuda_temp_137 = (output)->valid;
#line 416 "VectorModule.cs"
                    bool csharp2cuda_temp_138;
#line 416 "VectorModule.cs"
                    if (csharp2cuda_temp_137)
                    {
#line 416 "VectorModule.cs"
                        int csharp2cuda_temp_139 = (first)->count;
#line 416 "VectorModule.cs"
                        csharp2cuda_temp_138 = ((index) < (csharp2cuda_temp_139));
                    }
                    else
                    {
#line 416 "VectorModule.cs"
                        csharp2cuda_temp_138 = false;
                    }
                    if (!(csharp2cuda_temp_138))
                        break;
#line 417 "VectorModule.cs"
#line 417 "VectorModule.cs"
                    int* csharp2cuda_temp_140 = &((boolean_result)[index]);
#line 417 "VectorModule.cs"
                    bool csharp2cuda_temp_141;
#line 417 "VectorModule.cs"
                    if (((opcode) == (11)))
                    {
#line 417 "VectorModule.cs"
                        double csharp2cuda_temp_142 = (a)[index];
#line 417 "VectorModule.cs"
                        double csharp2cuda_temp_143 = (b)[index];
#line 417 "VectorModule.cs"
                        csharp2cuda_temp_141 = ((csharp2cuda_temp_142) == (csharp2cuda_temp_143));
                    }
                    else
                    {
#line 418 "VectorModule.cs"
                        bool csharp2cuda_temp_144;
#line 418 "VectorModule.cs"
                        if (((opcode) == (15)))
                        {
#line 418 "VectorModule.cs"
                            double csharp2cuda_temp_145 = (a)[index];
#line 418 "VectorModule.cs"
                            double csharp2cuda_temp_146 = (b)[index];
#line 418 "VectorModule.cs"
                            csharp2cuda_temp_144 = ((csharp2cuda_temp_145) > (csharp2cuda_temp_146));
                        }
                        else
                        {
#line 419 "VectorModule.cs"
                            double csharp2cuda_temp_147 = (a)[index];
#line 419 "VectorModule.cs"
                            double csharp2cuda_temp_148 = (b)[index];
#line 418 "VectorModule.cs"
                            csharp2cuda_temp_144 = ((csharp2cuda_temp_147) < (csharp2cuda_temp_148));
                        }
#line 417 "VectorModule.cs"
                        csharp2cuda_temp_141 = csharp2cuda_temp_144;
                    }
                    (*(csharp2cuda_temp_140) = csharp2cuda_temp_141);
#line 416 "VectorModule.cs"
                    int* csharp2cuda_temp_135 = &(index);
#line 416 "VectorModule.cs"
                    int csharp2cuda_temp_136 = *(csharp2cuda_temp_135);
                    (*(csharp2cuda_temp_135) = csharp2cuda_i32_add(csharp2cuda_temp_136, blockDim.x));
                }
            }
#line 420 "VectorModule.cs"
            break;
#line 421 "VectorModule.cs"
        case 12:
        case 27:
        case 44:
#line 424 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 424 "VectorModule.cs"
#line 424 "VectorModule.cs"
                int csharp2cuda_temp_149 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_149);
            }
#line 425 "VectorModule.cs"
            __syncthreads();
#line 426 "VectorModule.cs"
            {
#line 426 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 426 "VectorModule.cs"
                    bool csharp2cuda_temp_152 = (output)->valid;
#line 426 "VectorModule.cs"
                    bool csharp2cuda_temp_153;
#line 426 "VectorModule.cs"
                    if (csharp2cuda_temp_152)
                    {
#line 426 "VectorModule.cs"
                        int csharp2cuda_temp_154 = (first)->count;
#line 426 "VectorModule.cs"
                        csharp2cuda_temp_153 = ((index) < (csharp2cuda_temp_154));
                    }
                    else
                    {
#line 426 "VectorModule.cs"
                        csharp2cuda_temp_153 = false;
                    }
                    if (!(csharp2cuda_temp_153))
                        break;
#line 427 "VectorModule.cs"
                    {
#line 428 "VectorModule.cs"
                        double csharp2cuda_temp_155;
#line 428 "VectorModule.cs"
                        if (((opcode) == (12)))
                        {
#line 428 "VectorModule.cs"
                            double csharp2cuda_temp_156 = (a)[index];
#line 428 "VectorModule.cs"
                            csharp2cuda_temp_155 = mathblocks_exponential(csharp2cuda_temp_156);
                        }
                        else
                        {
#line 429 "VectorModule.cs"
                            double csharp2cuda_temp_157;
#line 429 "VectorModule.cs"
                            if (((opcode) == (27)))
                            {
#line 429 "VectorModule.cs"
                                double csharp2cuda_temp_158 = (a)[index];
#line 429 "VectorModule.cs"
                                csharp2cuda_temp_157 = mathblocks_natural_logarithm(csharp2cuda_temp_158);
                            }
                            else
                            {
#line 430 "VectorModule.cs"
                                double csharp2cuda_temp_159 = (a)[index];
#line 429 "VectorModule.cs"
                                csharp2cuda_temp_157 = mathblocks_square_root(csharp2cuda_temp_159);
                            }
#line 428 "VectorModule.cs"
                            csharp2cuda_temp_155 = csharp2cuda_temp_157;
                        }
#line 428 "VectorModule.cs"
                        double value = csharp2cuda_temp_155;
#line 431 "VectorModule.cs"
#line 431 "VectorModule.cs"
                        double* csharp2cuda_temp_160 = &((result)[index]);
                        (*(csharp2cuda_temp_160) = value);
#line 432 "VectorModule.cs"
                        if ((!(isfinite(value))))
                        {
#line 432 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 426 "VectorModule.cs"
                    int* csharp2cuda_temp_150 = &(index);
#line 426 "VectorModule.cs"
                    int csharp2cuda_temp_151 = *(csharp2cuda_temp_150);
                    (*(csharp2cuda_temp_150) = csharp2cuda_i32_add(csharp2cuda_temp_151, blockDim.x));
                }
            }
#line 434 "VectorModule.cs"
            break;
#line 435 "VectorModule.cs"
        case 13:
#line 436 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 436 "VectorModule.cs"
#line 436 "VectorModule.cs"
                int csharp2cuda_temp_161 = (second)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_161);
            }
#line 437 "VectorModule.cs"
            __syncthreads();
#line 438 "VectorModule.cs"
            {
#line 438 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 438 "VectorModule.cs"
                    bool csharp2cuda_temp_164 = (output)->valid;
#line 438 "VectorModule.cs"
                    bool csharp2cuda_temp_165;
#line 438 "VectorModule.cs"
                    if (csharp2cuda_temp_164)
                    {
#line 438 "VectorModule.cs"
                        int csharp2cuda_temp_166 = (second)->count;
#line 438 "VectorModule.cs"
                        csharp2cuda_temp_165 = ((index) < (csharp2cuda_temp_166));
                    }
                    else
                    {
#line 438 "VectorModule.cs"
                        csharp2cuda_temp_165 = false;
                    }
                    if (!(csharp2cuda_temp_165))
                        break;
#line 439 "VectorModule.cs"
                    {
#line 440 "VectorModule.cs"
                        int source_index = 0;
#line 441 "VectorModule.cs"
#line 441 "VectorModule.cs"
                        double csharp2cuda_temp_167 = (b)[index];
#line 441 "VectorModule.cs"
                        int* csharp2cuda_temp_168 = &(source_index);
#line 441 "VectorModule.cs"
                        bool csharp2cuda_temp_169 = mathblocks_nonnegative_integer(csharp2cuda_temp_167, csharp2cuda_temp_168);
#line 441 "VectorModule.cs"
                        bool csharp2cuda_temp_170;
#line 441 "VectorModule.cs"
                        if (!((!(csharp2cuda_temp_169))))
                        {
#line 441 "VectorModule.cs"
                            int csharp2cuda_temp_171 = (first)->count;
#line 441 "VectorModule.cs"
                            csharp2cuda_temp_170 = ((source_index) >= (csharp2cuda_temp_171));
                        }
                        else
                        {
#line 441 "VectorModule.cs"
                            csharp2cuda_temp_170 = true;
                        }
                        if (csharp2cuda_temp_170)
                        {
#line 442 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                        else
                        {
#line 444 "VectorModule.cs"
#line 444 "VectorModule.cs"
                            double* csharp2cuda_temp_172 = &((result)[index]);
#line 444 "VectorModule.cs"
                            double csharp2cuda_temp_173 = (a)[source_index];
                            (*(csharp2cuda_temp_172) = csharp2cuda_temp_173);
                        }
                    }
#line 438 "VectorModule.cs"
                    int* csharp2cuda_temp_162 = &(index);
#line 438 "VectorModule.cs"
                    int csharp2cuda_temp_163 = *(csharp2cuda_temp_162);
                    (*(csharp2cuda_temp_162) = csharp2cuda_i32_add(csharp2cuda_temp_163, blockDim.x));
                }
            }
#line 446 "VectorModule.cs"
            break;
#line 447 "VectorModule.cs"
        case 14:
#line 448 "VectorModule.cs"
#line 448 "VectorModule.cs"
            bool csharp2cuda_temp_174;
#line 448 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 449 "VectorModule.cs"
                unsigned long long csharp2cuda_temp_175 = (output)->scratch_pointer;
#line 449 "VectorModule.cs"
                bool csharp2cuda_temp_176;
#line 449 "VectorModule.cs"
                if (!(((csharp2cuda_temp_175) == (((unsigned long long)(0))))))
                {
#line 450 "VectorModule.cs"
                    int csharp2cuda_temp_177 = (first)->count;
#line 450 "VectorModule.cs"
                    double* csharp2cuda_temp_178 = &((output)->scalar_value);
#line 450 "VectorModule.cs"
                    bool csharp2cuda_temp_179 = mathblocks_vector_geometric_mean_value(a, csharp2cuda_temp_177, result, csharp2cuda_temp_178);
#line 449 "VectorModule.cs"
                    csharp2cuda_temp_176 = (!(csharp2cuda_temp_179));
                }
                else
                {
#line 449 "VectorModule.cs"
                    csharp2cuda_temp_176 = true;
                }
#line 448 "VectorModule.cs"
                csharp2cuda_temp_174 = csharp2cuda_temp_176;
            }
            else
            {
#line 448 "VectorModule.cs"
                csharp2cuda_temp_174 = false;
            }
            if (csharp2cuda_temp_174)
            {
#line 451 "VectorModule.cs"
#line 451 "VectorModule.cs"
                int* csharp2cuda_temp_180 = &((output)->valid);
                (*(csharp2cuda_temp_180) = 0);
            }
#line 452 "VectorModule.cs"
            break;
#line 453 "VectorModule.cs"
        case 16:
#line 454 "VectorModule.cs"
            if (((thread) == (0)))
#line 455 "VectorModule.cs"
            {
#line 456 "VectorModule.cs"
                int index = 0;
#line 457 "VectorModule.cs"
#line 457 "VectorModule.cs"
                double csharp2cuda_temp_181 = (second)->scalar_value;
#line 457 "VectorModule.cs"
                int* csharp2cuda_temp_182 = &(index);
#line 457 "VectorModule.cs"
                bool csharp2cuda_temp_183 = mathblocks_nonnegative_integer(csharp2cuda_temp_181, csharp2cuda_temp_182);
#line 457 "VectorModule.cs"
                bool csharp2cuda_temp_184;
#line 457 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_183))))
                {
#line 457 "VectorModule.cs"
                    int csharp2cuda_temp_185 = (first)->count;
#line 457 "VectorModule.cs"
                    csharp2cuda_temp_184 = ((index) >= (csharp2cuda_temp_185));
                }
                else
                {
#line 457 "VectorModule.cs"
                    csharp2cuda_temp_184 = true;
                }
                if (csharp2cuda_temp_184)
                {
#line 458 "VectorModule.cs"
#line 458 "VectorModule.cs"
                    int* csharp2cuda_temp_186 = &((output)->valid);
                    (*(csharp2cuda_temp_186) = 0);
                }
                else
                {
#line 460 "VectorModule.cs"
#line 460 "VectorModule.cs"
                    double* csharp2cuda_temp_187 = &((output)->scalar_value);
#line 460 "VectorModule.cs"
                    double csharp2cuda_temp_188 = (a)[index];
                    (*(csharp2cuda_temp_187) = csharp2cuda_temp_188);
                }
            }
#line 462 "VectorModule.cs"
            break;
#line 463 "VectorModule.cs"
        case 17:
        case 18:
#line 465 "VectorModule.cs"
            if (((thread) == (0)))
#line 466 "VectorModule.cs"
            {
#line 467 "VectorModule.cs"
                double csharp2cuda_temp_189;
#line 467 "VectorModule.cs"
                if (((opcode) == (17)))
                {
#line 468 "VectorModule.cs"
                    int csharp2cuda_temp_190 = (first)->count;
#line 467 "VectorModule.cs"
                    csharp2cuda_temp_189 = mathblocks_compensated_absolute_sum(a, csharp2cuda_temp_190);
                }
                else
                {
#line 469 "VectorModule.cs"
                    int csharp2cuda_temp_191 = (first)->count;
#line 469 "VectorModule.cs"
                    double csharp2cuda_temp_192 = mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_191);
#line 467 "VectorModule.cs"
                    csharp2cuda_temp_189 = mathblocks_square_root(csharp2cuda_temp_192);
                }
#line 467 "VectorModule.cs"
                double norm = csharp2cuda_temp_189;
#line 470 "VectorModule.cs"
#line 470 "VectorModule.cs"
                double* csharp2cuda_temp_193 = &((output)->scalar_value);
                (*(csharp2cuda_temp_193) = norm);
#line 471 "VectorModule.cs"
                if ((!(isfinite(norm))))
                {
#line 471 "VectorModule.cs"
#line 471 "VectorModule.cs"
                    int* csharp2cuda_temp_194 = &((output)->valid);
                    (*(csharp2cuda_temp_194) = 0);
                }
            }
#line 473 "VectorModule.cs"
            break;
#line 474 "VectorModule.cs"
        case 19:
#line 475 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 475 "VectorModule.cs"
#line 475 "VectorModule.cs"
                double* csharp2cuda_temp_195 = &((output)->scalar_value);
#line 475 "VectorModule.cs"
                int csharp2cuda_temp_196 = (first)->count;
                (*(csharp2cuda_temp_195) = ((double)(csharp2cuda_temp_196)));
            }
#line 476 "VectorModule.cs"
            break;
#line 477 "VectorModule.cs"
        case 21:
#line 478 "VectorModule.cs"
            if (((thread) == (0)))
#line 479 "VectorModule.cs"
            {
#line 480 "VectorModule.cs"
                int count = 0;
#line 481 "VectorModule.cs"
#line 481 "VectorModule.cs"
                double csharp2cuda_temp_197 = (third)->scalar_value;
#line 481 "VectorModule.cs"
                int* csharp2cuda_temp_198 = &(count);
#line 481 "VectorModule.cs"
                bool csharp2cuda_temp_199 = mathblocks_nonnegative_integer(csharp2cuda_temp_197, csharp2cuda_temp_198);
#line 481 "VectorModule.cs"
                bool csharp2cuda_temp_200;
#line 481 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_199))))
                {
#line 481 "VectorModule.cs"
                    csharp2cuda_temp_200 = ((count) <= (0));
                }
                else
                {
#line 481 "VectorModule.cs"
                    csharp2cuda_temp_200 = true;
                }
#line 481 "VectorModule.cs"
                bool csharp2cuda_temp_201;
#line 481 "VectorModule.cs"
                if (!(csharp2cuda_temp_200))
                {
#line 481 "VectorModule.cs"
                    csharp2cuda_temp_201 = ((count) > (1000000));
                }
                else
                {
#line 481 "VectorModule.cs"
                    csharp2cuda_temp_201 = true;
                }
                if (csharp2cuda_temp_201)
                {
#line 482 "VectorModule.cs"
#line 482 "VectorModule.cs"
                    int* csharp2cuda_temp_202 = &((output)->valid);
                    (*(csharp2cuda_temp_202) = 0);
                }
                else
                {
#line 484 "VectorModule.cs"
                    mathblocks_set_vector_shape(output, count);
                }
            }
#line 486 "VectorModule.cs"
            __syncthreads();
#line 487 "VectorModule.cs"
            if ((output)->valid)
#line 488 "VectorModule.cs"
            {
#line 489 "VectorModule.cs"
                double start = (first)->scalar_value;
#line 490 "VectorModule.cs"
                double end = (second)->scalar_value;
#line 491 "VectorModule.cs"
                int csharp2cuda_temp_203 = (output)->count;
#line 491 "VectorModule.cs"
                double csharp2cuda_temp_204;
#line 491 "VectorModule.cs"
                if (((csharp2cuda_temp_203) == (1)))
                {
#line 491 "VectorModule.cs"
                    csharp2cuda_temp_204 = 0.0;
                }
                else
                {
#line 491 "VectorModule.cs"
                    int csharp2cuda_temp_205 = (output)->count;
#line 491 "VectorModule.cs"
                    csharp2cuda_temp_204 = __ddiv_rn(__dsub_rn(end, start), ((double)(csharp2cuda_i32_sub(csharp2cuda_temp_205, 1))));
                }
#line 491 "VectorModule.cs"
                double step = csharp2cuda_temp_204;
#line 492 "VectorModule.cs"
                {
#line 492 "VectorModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 492 "VectorModule.cs"
                        int csharp2cuda_temp_208 = (output)->count;
                        if (!(((index) < (csharp2cuda_temp_208))))
                            break;
#line 493 "VectorModule.cs"
#line 493 "VectorModule.cs"
                        double* csharp2cuda_temp_209 = &((result)[index]);
#line 493 "VectorModule.cs"
                        int csharp2cuda_temp_210 = (output)->count;
#line 493 "VectorModule.cs"
                        double csharp2cuda_temp_211;
#line 493 "VectorModule.cs"
                        if (((index) == (csharp2cuda_i32_sub(csharp2cuda_temp_210, 1))))
                        {
#line 493 "VectorModule.cs"
                            csharp2cuda_temp_211 = end;
                        }
                        else
                        {
#line 493 "VectorModule.cs"
                            csharp2cuda_temp_211 = __dadd_rn(start, __dmul_rn(step, ((double)(index))));
                        }
                        (*(csharp2cuda_temp_209) = csharp2cuda_temp_211);
#line 492 "VectorModule.cs"
                        int* csharp2cuda_temp_206 = &(index);
#line 492 "VectorModule.cs"
                        int csharp2cuda_temp_207 = *(csharp2cuda_temp_206);
                        (*(csharp2cuda_temp_206) = csharp2cuda_i32_add(csharp2cuda_temp_207, blockDim.x));
                    }
                }
            }
#line 495 "VectorModule.cs"
            break;
#line 496 "VectorModule.cs"
        case 22:
        case 25:
#line 498 "VectorModule.cs"
            if (((thread) == (0)))
#line 499 "VectorModule.cs"
            {
#line 500 "VectorModule.cs"
#line 500 "VectorModule.cs"
                int csharp2cuda_temp_212 = (first)->count;
                if (((csharp2cuda_temp_212) <= (0)))
#line 501 "VectorModule.cs"
                {
#line 502 "VectorModule.cs"
#line 502 "VectorModule.cs"
                    int* csharp2cuda_temp_213 = &((output)->valid);
                    (*(csharp2cuda_temp_213) = 0);
#line 503 "VectorModule.cs"
                    break;
                }
#line 505 "VectorModule.cs"
                double selected = (a)[0];
#line 506 "VectorModule.cs"
                {
#line 506 "VectorModule.cs"
                    int index = 1;
                    while (true)
                    {
#line 506 "VectorModule.cs"
                        int csharp2cuda_temp_215 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_215))))
                            break;
#line 507 "VectorModule.cs"
#line 507 "VectorModule.cs"
                        double* csharp2cuda_temp_216 = &(selected);
#line 507 "VectorModule.cs"
                        double csharp2cuda_temp_217;
#line 507 "VectorModule.cs"
                        if (((opcode) == (22)))
                        {
#line 508 "VectorModule.cs"
                            double csharp2cuda_temp_218 = (a)[index];
#line 507 "VectorModule.cs"
                            csharp2cuda_temp_217 = mathblocks_maximum(selected, csharp2cuda_temp_218);
                        }
                        else
                        {
#line 509 "VectorModule.cs"
                            double csharp2cuda_temp_219 = (a)[index];
#line 507 "VectorModule.cs"
                            csharp2cuda_temp_217 = mathblocks_minimum(selected, csharp2cuda_temp_219);
                        }
                        (*(csharp2cuda_temp_216) = csharp2cuda_temp_217);
#line 506 "VectorModule.cs"
                        int* csharp2cuda_temp_214 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_214));
                    }
                }
#line 510 "VectorModule.cs"
#line 510 "VectorModule.cs"
                double* csharp2cuda_temp_220 = &((output)->scalar_value);
                (*(csharp2cuda_temp_220) = selected);
            }
#line 512 "VectorModule.cs"
            break;
#line 513 "VectorModule.cs"
        case 23:
        case 48:
#line 515 "VectorModule.cs"
            if (((thread) == (0)))
#line 516 "VectorModule.cs"
            {
#line 517 "VectorModule.cs"
                int csharp2cuda_temp_221 = (first)->count;
#line 517 "VectorModule.cs"
                double sum = mathblocks_compensated_sum(a, csharp2cuda_temp_221);
#line 518 "VectorModule.cs"
#line 518 "VectorModule.cs"
                double* csharp2cuda_temp_222 = &((output)->scalar_value);
#line 518 "VectorModule.cs"
                double csharp2cuda_temp_223;
#line 518 "VectorModule.cs"
                if (((opcode) == (23)))
                {
#line 518 "VectorModule.cs"
                    int csharp2cuda_temp_224 = (first)->count;
#line 518 "VectorModule.cs"
                    csharp2cuda_temp_223 = __ddiv_rn(sum, ((double)(csharp2cuda_temp_224)));
                }
                else
                {
#line 518 "VectorModule.cs"
                    csharp2cuda_temp_223 = sum;
                }
                (*(csharp2cuda_temp_222) = csharp2cuda_temp_223);
#line 519 "VectorModule.cs"
#line 519 "VectorModule.cs"
                double csharp2cuda_temp_225 = (output)->scalar_value;
                if ((!(isfinite(csharp2cuda_temp_225))))
                {
#line 519 "VectorModule.cs"
#line 519 "VectorModule.cs"
                    int* csharp2cuda_temp_226 = &((output)->valid);
                    (*(csharp2cuda_temp_226) = 0);
                }
            }
#line 521 "VectorModule.cs"
            break;
#line 522 "VectorModule.cs"
        case 24:
        case 35:
#line 524 "VectorModule.cs"
            if (((thread) == (0)))
#line 525 "VectorModule.cs"
            {
#line 526 "VectorModule.cs"
                double csharp2cuda_temp_227;
#line 526 "VectorModule.cs"
                if (((opcode) == (24)))
                {
#line 526 "VectorModule.cs"
                    csharp2cuda_temp_227 = 0.5;
                }
                else
                {
#line 526 "VectorModule.cs"
                    csharp2cuda_temp_227 = (second)->scalar_value;
                }
#line 526 "VectorModule.cs"
                double probability = csharp2cuda_temp_227;
#line 527 "VectorModule.cs"
#line 527 "VectorModule.cs"
                int csharp2cuda_temp_228 = (first)->count;
#line 527 "VectorModule.cs"
                bool csharp2cuda_temp_229;
#line 527 "VectorModule.cs"
                if (!(((csharp2cuda_temp_228) <= (0))))
                {
#line 527 "VectorModule.cs"
                    unsigned long long csharp2cuda_temp_230 = (output)->scratch_pointer;
#line 527 "VectorModule.cs"
                    csharp2cuda_temp_229 = ((csharp2cuda_temp_230) == (((unsigned long long)(0))));
                }
                else
                {
#line 527 "VectorModule.cs"
                    csharp2cuda_temp_229 = true;
                }
#line 527 "VectorModule.cs"
                bool csharp2cuda_temp_231;
#line 527 "VectorModule.cs"
                if (!(csharp2cuda_temp_229))
                {
#line 527 "VectorModule.cs"
                    csharp2cuda_temp_231 = ((probability) < (0.0));
                }
                else
                {
#line 527 "VectorModule.cs"
                    csharp2cuda_temp_231 = true;
                }
#line 527 "VectorModule.cs"
                bool csharp2cuda_temp_232;
#line 527 "VectorModule.cs"
                if (!(csharp2cuda_temp_231))
                {
#line 527 "VectorModule.cs"
                    csharp2cuda_temp_232 = ((probability) > (1.0));
                }
                else
                {
#line 527 "VectorModule.cs"
                    csharp2cuda_temp_232 = true;
                }
                if (csharp2cuda_temp_232)
                {
#line 529 "VectorModule.cs"
#line 529 "VectorModule.cs"
                    int* csharp2cuda_temp_233 = &((output)->valid);
                    (*(csharp2cuda_temp_233) = 0);
                }
                else
#line 531 "VectorModule.cs"
                {
#line 532 "VectorModule.cs"
#line 532 "VectorModule.cs"
                    double* csharp2cuda_temp_234 = &((output)->scalar_value);
#line 532 "VectorModule.cs"
                    double csharp2cuda_temp_235 = mathblocks_quantile(first, output, probability);
                    (*(csharp2cuda_temp_234) = csharp2cuda_temp_235);
#line 533 "VectorModule.cs"
#line 533 "VectorModule.cs"
                    double csharp2cuda_temp_236 = (output)->scalar_value;
                    if ((!(isfinite(csharp2cuda_temp_236))))
                    {
#line 533 "VectorModule.cs"
#line 533 "VectorModule.cs"
                        int* csharp2cuda_temp_237 = &((output)->valid);
                        (*(csharp2cuda_temp_237) = 0);
                    }
                }
            }
#line 536 "VectorModule.cs"
            break;
#line 537 "VectorModule.cs"
        case 28:
        case 29:
#line 539 "VectorModule.cs"
            if (((thread) == (0)))
#line 540 "VectorModule.cs"
            {
#line 541 "VectorModule.cs"
#line 541 "VectorModule.cs"
                int csharp2cuda_temp_238 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_238);
#line 542 "VectorModule.cs"
#line 542 "VectorModule.cs"
                double* csharp2cuda_temp_239 = &((output)->scalar_value);
#line 542 "VectorModule.cs"
                double csharp2cuda_temp_240;
#line 542 "VectorModule.cs"
                if (((opcode) == (28)))
                {
#line 543 "VectorModule.cs"
                    int csharp2cuda_temp_241 = (first)->count;
#line 542 "VectorModule.cs"
                    csharp2cuda_temp_240 = mathblocks_compensated_absolute_sum(a, csharp2cuda_temp_241);
                }
                else
                {
#line 544 "VectorModule.cs"
                    int csharp2cuda_temp_242 = (first)->count;
#line 544 "VectorModule.cs"
                    double csharp2cuda_temp_243 = mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_242);
#line 542 "VectorModule.cs"
                    csharp2cuda_temp_240 = mathblocks_square_root(csharp2cuda_temp_243);
                }
                (*(csharp2cuda_temp_239) = csharp2cuda_temp_240);
#line 545 "VectorModule.cs"
#line 545 "VectorModule.cs"
                double csharp2cuda_temp_244 = (output)->scalar_value;
#line 545 "VectorModule.cs"
                bool csharp2cuda_temp_245;
#line 545 "VectorModule.cs"
                if (!((!(isfinite(csharp2cuda_temp_244)))))
                {
#line 545 "VectorModule.cs"
                    double csharp2cuda_temp_246 = (output)->scalar_value;
#line 545 "VectorModule.cs"
                    csharp2cuda_temp_245 = ((csharp2cuda_temp_246) == (0.0));
                }
                else
                {
#line 545 "VectorModule.cs"
                    csharp2cuda_temp_245 = true;
                }
                if (csharp2cuda_temp_245)
                {
#line 545 "VectorModule.cs"
#line 545 "VectorModule.cs"
                    int* csharp2cuda_temp_247 = &((output)->valid);
                    (*(csharp2cuda_temp_247) = 0);
                }
            }
#line 547 "VectorModule.cs"
            __syncthreads();
#line 548 "VectorModule.cs"
            {
#line 548 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 548 "VectorModule.cs"
                    bool csharp2cuda_temp_250 = (output)->valid;
#line 548 "VectorModule.cs"
                    bool csharp2cuda_temp_251;
#line 548 "VectorModule.cs"
                    if (csharp2cuda_temp_250)
                    {
#line 548 "VectorModule.cs"
                        int csharp2cuda_temp_252 = (first)->count;
#line 548 "VectorModule.cs"
                        csharp2cuda_temp_251 = ((index) < (csharp2cuda_temp_252));
                    }
                    else
                    {
#line 548 "VectorModule.cs"
                        csharp2cuda_temp_251 = false;
                    }
                    if (!(csharp2cuda_temp_251))
                        break;
#line 549 "VectorModule.cs"
                    {
#line 550 "VectorModule.cs"
#line 550 "VectorModule.cs"
                        double* csharp2cuda_temp_253 = &((result)[index]);
#line 550 "VectorModule.cs"
                        double csharp2cuda_temp_254 = (a)[index];
#line 550 "VectorModule.cs"
                        double csharp2cuda_temp_255 = (output)->scalar_value;
#line 550 "VectorModule.cs"
                        double csharp2cuda_temp_256 = __ddiv_rn(1.0, csharp2cuda_temp_255);
                        (*(csharp2cuda_temp_253) = __dmul_rn(csharp2cuda_temp_254, csharp2cuda_temp_256));
#line 551 "VectorModule.cs"
#line 551 "VectorModule.cs"
                        double csharp2cuda_temp_257 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_257))))
                        {
#line 551 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 548 "VectorModule.cs"
                    int* csharp2cuda_temp_248 = &(index);
#line 548 "VectorModule.cs"
                    int csharp2cuda_temp_249 = *(csharp2cuda_temp_248);
                    (*(csharp2cuda_temp_248) = csharp2cuda_i32_add(csharp2cuda_temp_249, blockDim.x));
                }
            }
#line 553 "VectorModule.cs"
            break;
#line 554 "VectorModule.cs"
        case 30:
#line 555 "VectorModule.cs"
            if (((thread) == (0)))
#line 556 "VectorModule.cs"
            {
#line 557 "VectorModule.cs"
                mathblocks_set_vector_shape(output, 2);
#line 558 "VectorModule.cs"
                if ((output)->valid)
#line 559 "VectorModule.cs"
                {
#line 560 "VectorModule.cs"
#line 560 "VectorModule.cs"
                    double* csharp2cuda_temp_258 = &((result)[0]);
#line 560 "VectorModule.cs"
                    double csharp2cuda_temp_259 = (first)->scalar_value;
                    (*(csharp2cuda_temp_258) = csharp2cuda_temp_259);
#line 561 "VectorModule.cs"
#line 561 "VectorModule.cs"
                    double* csharp2cuda_temp_260 = &((result)[1]);
#line 561 "VectorModule.cs"
                    double csharp2cuda_temp_261 = (second)->scalar_value;
                    (*(csharp2cuda_temp_260) = csharp2cuda_temp_261);
                }
            }
#line 564 "VectorModule.cs"
            break;
#line 565 "VectorModule.cs"
        case 31:
        case 41:
        case 45:
#line 568 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 568 "VectorModule.cs"
#line 568 "VectorModule.cs"
                int csharp2cuda_temp_262 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_262);
            }
#line 569 "VectorModule.cs"
            __syncthreads();
#line 570 "VectorModule.cs"
            {
#line 570 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 570 "VectorModule.cs"
                    bool csharp2cuda_temp_265 = (output)->valid;
#line 570 "VectorModule.cs"
                    bool csharp2cuda_temp_266;
#line 570 "VectorModule.cs"
                    if (csharp2cuda_temp_265)
                    {
#line 570 "VectorModule.cs"
                        int csharp2cuda_temp_267 = (first)->count;
#line 570 "VectorModule.cs"
                        csharp2cuda_temp_266 = ((index) < (csharp2cuda_temp_267));
                    }
                    else
                    {
#line 570 "VectorModule.cs"
                        csharp2cuda_temp_266 = false;
                    }
                    if (!(csharp2cuda_temp_266))
                        break;
#line 571 "VectorModule.cs"
                    {
#line 572 "VectorModule.cs"
                        double csharp2cuda_temp_268;
#line 572 "VectorModule.cs"
                        if (((opcode) == (31)))
                        {
#line 572 "VectorModule.cs"
                            double csharp2cuda_temp_269 = (a)[index];
#line 572 "VectorModule.cs"
                            csharp2cuda_temp_268 = mathblocks_maximum(csharp2cuda_temp_269, 0.0);
                        }
                        else
                        {
#line 573 "VectorModule.cs"
                            double csharp2cuda_temp_270;
#line 573 "VectorModule.cs"
                            if (((opcode) == (41)))
                            {
#line 573 "VectorModule.cs"
                                double csharp2cuda_temp_271 = (a)[index];
#line 573 "VectorModule.cs"
                                double csharp2cuda_temp_272 = (a)[index];
#line 573 "VectorModule.cs"
                                csharp2cuda_temp_270 = ((double)(csharp2cuda_i32_sub(((((csharp2cuda_temp_271) > (0.0))) ? 1 : 0), ((((csharp2cuda_temp_272) < (0.0))) ? 1 : 0))));
                            }
                            else
                            {
#line 574 "VectorModule.cs"
                                double csharp2cuda_temp_273 = (a)[index];
#line 574 "VectorModule.cs"
                                double csharp2cuda_temp_274 = (a)[index];
#line 573 "VectorModule.cs"
                                csharp2cuda_temp_270 = __dmul_rn(csharp2cuda_temp_273, csharp2cuda_temp_274);
                            }
#line 572 "VectorModule.cs"
                            csharp2cuda_temp_268 = csharp2cuda_temp_270;
                        }
#line 572 "VectorModule.cs"
                        double value = csharp2cuda_temp_268;
#line 575 "VectorModule.cs"
#line 575 "VectorModule.cs"
                        double* csharp2cuda_temp_275 = &((result)[index]);
                        (*(csharp2cuda_temp_275) = value);
#line 576 "VectorModule.cs"
                        if ((!(isfinite(value))))
                        {
#line 576 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 570 "VectorModule.cs"
                    int* csharp2cuda_temp_263 = &(index);
#line 570 "VectorModule.cs"
                    int csharp2cuda_temp_264 = *(csharp2cuda_temp_263);
                    (*(csharp2cuda_temp_263) = csharp2cuda_i32_add(csharp2cuda_temp_264, blockDim.x));
                }
            }
#line 578 "VectorModule.cs"
            break;
#line 579 "VectorModule.cs"
        case 32:
#line 580 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 580 "VectorModule.cs"
#line 580 "VectorModule.cs"
                int csharp2cuda_temp_276 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_276);
            }
#line 581 "VectorModule.cs"
            __syncthreads();
#line 582 "VectorModule.cs"
            {
#line 582 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 582 "VectorModule.cs"
                    bool csharp2cuda_temp_279 = (output)->valid;
#line 582 "VectorModule.cs"
                    bool csharp2cuda_temp_280;
#line 582 "VectorModule.cs"
                    if (csharp2cuda_temp_279)
                    {
#line 582 "VectorModule.cs"
                        int csharp2cuda_temp_281 = (first)->count;
#line 582 "VectorModule.cs"
                        csharp2cuda_temp_280 = ((index) < (csharp2cuda_temp_281));
                    }
                    else
                    {
#line 582 "VectorModule.cs"
                        csharp2cuda_temp_280 = false;
                    }
                    if (!(csharp2cuda_temp_280))
                        break;
#line 583 "VectorModule.cs"
                    {
#line 584 "VectorModule.cs"
#line 584 "VectorModule.cs"
                        double* csharp2cuda_temp_282 = &((result)[index]);
#line 584 "VectorModule.cs"
                        double csharp2cuda_temp_283 = (a)[index];
#line 584 "VectorModule.cs"
                        double csharp2cuda_temp_284 = (second)->scalar_value;
                        (*(csharp2cuda_temp_282) = mathblocks_power(csharp2cuda_temp_283, csharp2cuda_temp_284));
#line 585 "VectorModule.cs"
#line 585 "VectorModule.cs"
                        double csharp2cuda_temp_285 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_285))))
                        {
#line 585 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 582 "VectorModule.cs"
                    int* csharp2cuda_temp_277 = &(index);
#line 582 "VectorModule.cs"
                    int csharp2cuda_temp_278 = *(csharp2cuda_temp_277);
                    (*(csharp2cuda_temp_277) = csharp2cuda_i32_add(csharp2cuda_temp_278, blockDim.x));
                }
            }
#line 587 "VectorModule.cs"
            break;
#line 588 "VectorModule.cs"
        case 33:
#line 589 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 589 "VectorModule.cs"
#line 589 "VectorModule.cs"
                int csharp2cuda_temp_286 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_286, 1));
            }
#line 590 "VectorModule.cs"
            __syncthreads();
#line 591 "VectorModule.cs"
#line 591 "VectorModule.cs"
            bool csharp2cuda_temp_287;
#line 591 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 591 "VectorModule.cs"
                csharp2cuda_temp_287 = (output)->valid;
            }
            else
            {
#line 591 "VectorModule.cs"
                csharp2cuda_temp_287 = false;
            }
            if (csharp2cuda_temp_287)
            {
#line 591 "VectorModule.cs"
#line 591 "VectorModule.cs"
                double* csharp2cuda_temp_288 = &((result)[0]);
#line 591 "VectorModule.cs"
                double csharp2cuda_temp_289 = (second)->scalar_value;
                (*(csharp2cuda_temp_288) = csharp2cuda_temp_289);
            }
#line 592 "VectorModule.cs"
            {
#line 592 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 592 "VectorModule.cs"
                    bool csharp2cuda_temp_292 = (output)->valid;
#line 592 "VectorModule.cs"
                    bool csharp2cuda_temp_293;
#line 592 "VectorModule.cs"
                    if (csharp2cuda_temp_292)
                    {
#line 592 "VectorModule.cs"
                        int csharp2cuda_temp_294 = (first)->count;
#line 592 "VectorModule.cs"
                        csharp2cuda_temp_293 = ((index) < (csharp2cuda_temp_294));
                    }
                    else
                    {
#line 592 "VectorModule.cs"
                        csharp2cuda_temp_293 = false;
                    }
                    if (!(csharp2cuda_temp_293))
                        break;
#line 593 "VectorModule.cs"
#line 593 "VectorModule.cs"
                    double* csharp2cuda_temp_295 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 593 "VectorModule.cs"
                    double csharp2cuda_temp_296 = (a)[index];
                    (*(csharp2cuda_temp_295) = csharp2cuda_temp_296);
#line 592 "VectorModule.cs"
                    int* csharp2cuda_temp_290 = &(index);
#line 592 "VectorModule.cs"
                    int csharp2cuda_temp_291 = *(csharp2cuda_temp_290);
                    (*(csharp2cuda_temp_290) = csharp2cuda_i32_add(csharp2cuda_temp_291, blockDim.x));
                }
            }
#line 594 "VectorModule.cs"
            break;
#line 595 "VectorModule.cs"
        case 34:
#line 596 "VectorModule.cs"
            if (((thread) == (0)))
#line 597 "VectorModule.cs"
            {
#line 598 "VectorModule.cs"
                double product = 1.0;
#line 599 "VectorModule.cs"
                {
#line 599 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 599 "VectorModule.cs"
                        int csharp2cuda_temp_298 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_298))))
                            break;
#line 599 "VectorModule.cs"
#line 599 "VectorModule.cs"
                        double* csharp2cuda_temp_299 = &(product);
#line 599 "VectorModule.cs"
                        double csharp2cuda_temp_300 = *(csharp2cuda_temp_299);
#line 599 "VectorModule.cs"
                        double csharp2cuda_temp_301 = (a)[index];
                        (*(csharp2cuda_temp_299) = __dmul_rn(csharp2cuda_temp_300, csharp2cuda_temp_301));
#line 599 "VectorModule.cs"
                        int* csharp2cuda_temp_297 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_297));
                    }
                }
#line 600 "VectorModule.cs"
#line 600 "VectorModule.cs"
                double* csharp2cuda_temp_302 = &((output)->scalar_value);
                (*(csharp2cuda_temp_302) = product);
#line 601 "VectorModule.cs"
                if ((!(isfinite(product))))
                {
#line 601 "VectorModule.cs"
#line 601 "VectorModule.cs"
                    int* csharp2cuda_temp_303 = &((output)->valid);
                    (*(csharp2cuda_temp_303) = 0);
                }
            }
#line 603 "VectorModule.cs"
            break;
#line 604 "VectorModule.cs"
        case 36:
#line 605 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 605 "VectorModule.cs"
#line 605 "VectorModule.cs"
                int csharp2cuda_temp_304 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_304);
            }
#line 606 "VectorModule.cs"
            __syncthreads();
#line 607 "VectorModule.cs"
            {
#line 607 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 607 "VectorModule.cs"
                    bool csharp2cuda_temp_307 = (output)->valid;
#line 607 "VectorModule.cs"
                    bool csharp2cuda_temp_308;
#line 607 "VectorModule.cs"
                    if (csharp2cuda_temp_307)
                    {
#line 607 "VectorModule.cs"
                        int csharp2cuda_temp_309 = (first)->count;
#line 607 "VectorModule.cs"
                        csharp2cuda_temp_308 = ((index) < (csharp2cuda_temp_309));
                    }
                    else
                    {
#line 607 "VectorModule.cs"
                        csharp2cuda_temp_308 = false;
                    }
                    if (!(csharp2cuda_temp_308))
                        break;
#line 608 "VectorModule.cs"
#line 608 "VectorModule.cs"
                    double* csharp2cuda_temp_310 = &((result)[index]);
#line 608 "VectorModule.cs"
                    int csharp2cuda_temp_311 = (first)->count;
#line 608 "VectorModule.cs"
                    double csharp2cuda_temp_312 = mathblocks_vector_rank_at(a, csharp2cuda_temp_311, index);
                    (*(csharp2cuda_temp_310) = csharp2cuda_temp_312);
#line 607 "VectorModule.cs"
                    int* csharp2cuda_temp_305 = &(index);
#line 607 "VectorModule.cs"
                    int csharp2cuda_temp_306 = *(csharp2cuda_temp_305);
                    (*(csharp2cuda_temp_305) = csharp2cuda_i32_add(csharp2cuda_temp_306, blockDim.x));
                }
            }
#line 609 "VectorModule.cs"
            break;
#line 610 "VectorModule.cs"
        case 37:
#line 611 "VectorModule.cs"
            if (((thread) == (0)))
#line 612 "VectorModule.cs"
            {
#line 613 "VectorModule.cs"
                int count = 0;
#line 614 "VectorModule.cs"
#line 614 "VectorModule.cs"
                double csharp2cuda_temp_313 = (second)->scalar_value;
#line 614 "VectorModule.cs"
                int* csharp2cuda_temp_314 = &(count);
#line 614 "VectorModule.cs"
                bool csharp2cuda_temp_315 = mathblocks_nonnegative_integer(csharp2cuda_temp_313, csharp2cuda_temp_314);
#line 614 "VectorModule.cs"
                bool csharp2cuda_temp_316;
#line 614 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_315))))
                {
#line 614 "VectorModule.cs"
                    csharp2cuda_temp_316 = ((count) > (1000000));
                }
                else
                {
#line 614 "VectorModule.cs"
                    csharp2cuda_temp_316 = true;
                }
                if (csharp2cuda_temp_316)
                {
#line 615 "VectorModule.cs"
#line 615 "VectorModule.cs"
                    int* csharp2cuda_temp_317 = &((output)->valid);
                    (*(csharp2cuda_temp_317) = 0);
                }
                else
                {
#line 617 "VectorModule.cs"
                    mathblocks_set_vector_shape(output, count);
                }
            }
#line 619 "VectorModule.cs"
            __syncthreads();
#line 620 "VectorModule.cs"
            {
#line 620 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 620 "VectorModule.cs"
                    bool csharp2cuda_temp_320 = (output)->valid;
#line 620 "VectorModule.cs"
                    bool csharp2cuda_temp_321;
#line 620 "VectorModule.cs"
                    if (csharp2cuda_temp_320)
                    {
#line 620 "VectorModule.cs"
                        int csharp2cuda_temp_322 = (output)->count;
#line 620 "VectorModule.cs"
                        csharp2cuda_temp_321 = ((index) < (csharp2cuda_temp_322));
                    }
                    else
                    {
#line 620 "VectorModule.cs"
                        csharp2cuda_temp_321 = false;
                    }
                    if (!(csharp2cuda_temp_321))
                        break;
#line 621 "VectorModule.cs"
#line 621 "VectorModule.cs"
                    double* csharp2cuda_temp_323 = &((result)[index]);
#line 621 "VectorModule.cs"
                    double csharp2cuda_temp_324 = (first)->scalar_value;
                    (*(csharp2cuda_temp_323) = csharp2cuda_temp_324);
#line 620 "VectorModule.cs"
                    int* csharp2cuda_temp_318 = &(index);
#line 620 "VectorModule.cs"
                    int csharp2cuda_temp_319 = *(csharp2cuda_temp_318);
                    (*(csharp2cuda_temp_318) = csharp2cuda_i32_add(csharp2cuda_temp_319, blockDim.x));
                }
            }
#line 622 "VectorModule.cs"
            break;
#line 623 "VectorModule.cs"
        case 38:
#line 624 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 624 "VectorModule.cs"
#line 624 "VectorModule.cs"
                int csharp2cuda_temp_325 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_325);
            }
#line 625 "VectorModule.cs"
            __syncthreads();
#line 626 "VectorModule.cs"
            {
#line 626 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 626 "VectorModule.cs"
                    bool csharp2cuda_temp_328 = (output)->valid;
#line 626 "VectorModule.cs"
                    bool csharp2cuda_temp_329;
#line 626 "VectorModule.cs"
                    if (csharp2cuda_temp_328)
                    {
#line 626 "VectorModule.cs"
                        int csharp2cuda_temp_330 = (first)->count;
#line 626 "VectorModule.cs"
                        csharp2cuda_temp_329 = ((index) < (csharp2cuda_temp_330));
                    }
                    else
                    {
#line 626 "VectorModule.cs"
                        csharp2cuda_temp_329 = false;
                    }
                    if (!(csharp2cuda_temp_329))
                        break;
#line 627 "VectorModule.cs"
#line 627 "VectorModule.cs"
                    double* csharp2cuda_temp_331 = &((result)[index]);
#line 627 "VectorModule.cs"
                    int csharp2cuda_temp_332 = (first)->count;
#line 627 "VectorModule.cs"
                    double csharp2cuda_temp_333 = (a)[csharp2cuda_i32_sub(csharp2cuda_i32_sub(csharp2cuda_temp_332, index), 1)];
                    (*(csharp2cuda_temp_331) = csharp2cuda_temp_333);
#line 626 "VectorModule.cs"
                    int* csharp2cuda_temp_326 = &(index);
#line 626 "VectorModule.cs"
                    int csharp2cuda_temp_327 = *(csharp2cuda_temp_326);
                    (*(csharp2cuda_temp_326) = csharp2cuda_i32_add(csharp2cuda_temp_327, blockDim.x));
                }
            }
#line 628 "VectorModule.cs"
            break;
#line 629 "VectorModule.cs"
        case 39:
#line 630 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 630 "VectorModule.cs"
#line 630 "VectorModule.cs"
                int csharp2cuda_temp_334 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_334);
            }
#line 631 "VectorModule.cs"
            __syncthreads();
#line 632 "VectorModule.cs"
            {
#line 632 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 632 "VectorModule.cs"
                    bool csharp2cuda_temp_337 = (output)->valid;
#line 632 "VectorModule.cs"
                    bool csharp2cuda_temp_338;
#line 632 "VectorModule.cs"
                    if (csharp2cuda_temp_337)
                    {
#line 632 "VectorModule.cs"
                        int csharp2cuda_temp_339 = (first)->count;
#line 632 "VectorModule.cs"
                        csharp2cuda_temp_338 = ((index) < (csharp2cuda_temp_339));
                    }
                    else
                    {
#line 632 "VectorModule.cs"
                        csharp2cuda_temp_338 = false;
                    }
                    if (!(csharp2cuda_temp_338))
                        break;
#line 633 "VectorModule.cs"
                    {
#line 634 "VectorModule.cs"
#line 634 "VectorModule.cs"
                        double* csharp2cuda_temp_340 = &((result)[index]);
#line 634 "VectorModule.cs"
                        double csharp2cuda_temp_341 = (a)[index];
#line 634 "VectorModule.cs"
                        double csharp2cuda_temp_342 = (second)->scalar_value;
                        (*(csharp2cuda_temp_340) = __dmul_rn(csharp2cuda_temp_341, csharp2cuda_temp_342));
#line 635 "VectorModule.cs"
#line 635 "VectorModule.cs"
                        double csharp2cuda_temp_343 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_343))))
                        {
#line 635 "VectorModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 632 "VectorModule.cs"
                    int* csharp2cuda_temp_335 = &(index);
#line 632 "VectorModule.cs"
                    int csharp2cuda_temp_336 = *(csharp2cuda_temp_335);
                    (*(csharp2cuda_temp_335) = csharp2cuda_i32_add(csharp2cuda_temp_336, blockDim.x));
                }
            }
#line 637 "VectorModule.cs"
            break;
#line 638 "VectorModule.cs"
        case 40:
#line 639 "VectorModule.cs"
            if (((thread) == (0)))
#line 640 "VectorModule.cs"
            {
#line 641 "VectorModule.cs"
#line 641 "VectorModule.cs"
                int csharp2cuda_temp_344 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_344);
#line 642 "VectorModule.cs"
#line 642 "VectorModule.cs"
                int csharp2cuda_temp_345 = (first)->count;
#line 642 "VectorModule.cs"
                int csharp2cuda_temp_346 = (second)->count;
#line 642 "VectorModule.cs"
                bool csharp2cuda_temp_347;
#line 642 "VectorModule.cs"
                if (!(((csharp2cuda_temp_345) != (csharp2cuda_temp_346))))
                {
#line 642 "VectorModule.cs"
                    int csharp2cuda_temp_348 = (first)->count;
#line 642 "VectorModule.cs"
                    int csharp2cuda_temp_349 = (third)->count;
#line 642 "VectorModule.cs"
                    csharp2cuda_temp_347 = ((csharp2cuda_temp_348) != (csharp2cuda_temp_349));
                }
                else
                {
#line 642 "VectorModule.cs"
                    csharp2cuda_temp_347 = true;
                }
                if (csharp2cuda_temp_347)
                {
#line 642 "VectorModule.cs"
#line 642 "VectorModule.cs"
                    int* csharp2cuda_temp_350 = &((output)->valid);
                    (*(csharp2cuda_temp_350) = 0);
                }
            }
#line 644 "VectorModule.cs"
            __syncthreads();
#line 645 "VectorModule.cs"
            {
#line 645 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 645 "VectorModule.cs"
                    bool csharp2cuda_temp_353 = (output)->valid;
#line 645 "VectorModule.cs"
                    bool csharp2cuda_temp_354;
#line 645 "VectorModule.cs"
                    if (csharp2cuda_temp_353)
                    {
#line 645 "VectorModule.cs"
                        int csharp2cuda_temp_355 = (first)->count;
#line 645 "VectorModule.cs"
                        csharp2cuda_temp_354 = ((index) < (csharp2cuda_temp_355));
                    }
                    else
                    {
#line 645 "VectorModule.cs"
                        csharp2cuda_temp_354 = false;
                    }
                    if (!(csharp2cuda_temp_354))
                        break;
#line 646 "VectorModule.cs"
#line 646 "VectorModule.cs"
                    double* csharp2cuda_temp_356 = &((result)[index]);
#line 646 "VectorModule.cs"
                    bool csharp2cuda_temp_357 = (boolean_a)[index];
#line 646 "VectorModule.cs"
                    double csharp2cuda_temp_358;
#line 646 "VectorModule.cs"
                    if (csharp2cuda_temp_357)
                    {
#line 646 "VectorModule.cs"
                        csharp2cuda_temp_358 = (b)[index];
                    }
                    else
                    {
#line 646 "VectorModule.cs"
                        csharp2cuda_temp_358 = (c)[index];
                    }
                    (*(csharp2cuda_temp_356) = csharp2cuda_temp_358);
#line 645 "VectorModule.cs"
                    int* csharp2cuda_temp_351 = &(index);
#line 645 "VectorModule.cs"
                    int csharp2cuda_temp_352 = *(csharp2cuda_temp_351);
                    (*(csharp2cuda_temp_351) = csharp2cuda_i32_add(csharp2cuda_temp_352, blockDim.x));
                }
            }
#line 647 "VectorModule.cs"
            break;
#line 648 "VectorModule.cs"
        case 42:
#line 649 "VectorModule.cs"
            if (((thread) == (0)))
#line 650 "VectorModule.cs"
            {
#line 651 "VectorModule.cs"
                int start = 0;
#line 652 "VectorModule.cs"
                int length = 0;
#line 653 "VectorModule.cs"
#line 653 "VectorModule.cs"
                double csharp2cuda_temp_359 = (second)->scalar_value;
#line 653 "VectorModule.cs"
                int* csharp2cuda_temp_360 = &(start);
#line 653 "VectorModule.cs"
                bool csharp2cuda_temp_361 = mathblocks_nonnegative_integer(csharp2cuda_temp_359, csharp2cuda_temp_360);
#line 653 "VectorModule.cs"
                bool csharp2cuda_temp_362;
#line 653 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_361))))
                {
#line 654 "VectorModule.cs"
                    double csharp2cuda_temp_363 = (third)->scalar_value;
#line 654 "VectorModule.cs"
                    int* csharp2cuda_temp_364 = &(length);
#line 654 "VectorModule.cs"
                    bool csharp2cuda_temp_365 = mathblocks_nonnegative_integer(csharp2cuda_temp_363, csharp2cuda_temp_364);
#line 653 "VectorModule.cs"
                    csharp2cuda_temp_362 = (!(csharp2cuda_temp_365));
                }
                else
                {
#line 653 "VectorModule.cs"
                    csharp2cuda_temp_362 = true;
                }
#line 653 "VectorModule.cs"
                bool csharp2cuda_temp_366;
#line 653 "VectorModule.cs"
                if (!(csharp2cuda_temp_362))
                {
#line 655 "VectorModule.cs"
                    int csharp2cuda_temp_367 = (first)->count;
#line 653 "VectorModule.cs"
                    csharp2cuda_temp_366 = ((start) > (csharp2cuda_temp_367));
                }
                else
                {
#line 653 "VectorModule.cs"
                    csharp2cuda_temp_366 = true;
                }
#line 653 "VectorModule.cs"
                bool csharp2cuda_temp_368;
#line 653 "VectorModule.cs"
                if (!(csharp2cuda_temp_366))
                {
#line 655 "VectorModule.cs"
                    int csharp2cuda_temp_369 = (first)->count;
#line 653 "VectorModule.cs"
                    csharp2cuda_temp_368 = ((length) > (csharp2cuda_i32_sub(csharp2cuda_temp_369, start)));
                }
                else
                {
#line 653 "VectorModule.cs"
                    csharp2cuda_temp_368 = true;
                }
                if (csharp2cuda_temp_368)
                {
#line 656 "VectorModule.cs"
#line 656 "VectorModule.cs"
                    int* csharp2cuda_temp_370 = &((output)->valid);
                    (*(csharp2cuda_temp_370) = 0);
                }
                else
                {
#line 658 "VectorModule.cs"
                    mathblocks_set_vector_shape(output, length);
                }
            }
#line 660 "VectorModule.cs"
            __syncthreads();
#line 661 "VectorModule.cs"
            if ((output)->valid)
#line 662 "VectorModule.cs"
            {
#line 663 "VectorModule.cs"
                double csharp2cuda_temp_371 = (second)->scalar_value;
#line 663 "VectorModule.cs"
                int start = csharp2cuda_f64_to_i32(csharp2cuda_temp_371);
#line 664 "VectorModule.cs"
                {
#line 664 "VectorModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 664 "VectorModule.cs"
                        int csharp2cuda_temp_374 = (output)->count;
                        if (!(((index) < (csharp2cuda_temp_374))))
                            break;
#line 665 "VectorModule.cs"
#line 665 "VectorModule.cs"
                        double* csharp2cuda_temp_375 = &((result)[index]);
#line 665 "VectorModule.cs"
                        double csharp2cuda_temp_376 = (a)[csharp2cuda_i32_add(start, index)];
                        (*(csharp2cuda_temp_375) = csharp2cuda_temp_376);
#line 664 "VectorModule.cs"
                        int* csharp2cuda_temp_372 = &(index);
#line 664 "VectorModule.cs"
                        int csharp2cuda_temp_373 = *(csharp2cuda_temp_372);
                        (*(csharp2cuda_temp_372) = csharp2cuda_i32_add(csharp2cuda_temp_373, blockDim.x));
                    }
                }
            }
#line 667 "VectorModule.cs"
            break;
#line 668 "VectorModule.cs"
        case 43:
#line 669 "VectorModule.cs"
            if (((thread) == (0)))
#line 670 "VectorModule.cs"
            {
#line 671 "VectorModule.cs"
#line 671 "VectorModule.cs"
                int csharp2cuda_temp_377 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_377);
#line 672 "VectorModule.cs"
                if ((output)->valid)
                {
#line 672 "VectorModule.cs"
                    mathblocks_copy_and_sort(first, output);
                }
            }
#line 674 "VectorModule.cs"
            break;
#line 675 "VectorModule.cs"
        case 46:
#line 676 "VectorModule.cs"
            if (((thread) == (0)))
#line 677 "VectorModule.cs"
            {
#line 678 "VectorModule.cs"
#line 678 "VectorModule.cs"
                int csharp2cuda_temp_378 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_378);
#line 679 "VectorModule.cs"
#line 679 "VectorModule.cs"
                bool csharp2cuda_temp_379 = (output)->valid;
#line 679 "VectorModule.cs"
                bool csharp2cuda_temp_380;
#line 679 "VectorModule.cs"
                if (!((!(csharp2cuda_temp_379))))
                {
#line 679 "VectorModule.cs"
                    int csharp2cuda_temp_381 = (first)->count;
#line 679 "VectorModule.cs"
                    csharp2cuda_temp_380 = ((csharp2cuda_temp_381) <= (0));
                }
                else
                {
#line 679 "VectorModule.cs"
                    csharp2cuda_temp_380 = true;
                }
                if (csharp2cuda_temp_380)
#line 680 "VectorModule.cs"
                {
#line 681 "VectorModule.cs"
#line 681 "VectorModule.cs"
                    int* csharp2cuda_temp_382 = &((output)->valid);
                    (*(csharp2cuda_temp_382) = 0);
#line 682 "VectorModule.cs"
                    break;
                }
#line 684 "VectorModule.cs"
                double mean = 0.0;
#line 685 "VectorModule.cs"
                double deviation = 0.0;
#line 686 "VectorModule.cs"
#line 686 "VectorModule.cs"
                int csharp2cuda_temp_383 = (first)->count;
#line 686 "VectorModule.cs"
                double* csharp2cuda_temp_384 = &(mean);
#line 686 "VectorModule.cs"
                double* csharp2cuda_temp_385 = &(deviation);
                mathblocks_vector_standardize_moments(a, csharp2cuda_temp_383, csharp2cuda_temp_384, csharp2cuda_temp_385);
#line 687 "VectorModule.cs"
                {
#line 687 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 687 "VectorModule.cs"
                        int csharp2cuda_temp_387 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_387))))
                            break;
#line 688 "VectorModule.cs"
                        {
#line 689 "VectorModule.cs"
#line 689 "VectorModule.cs"
                            double* csharp2cuda_temp_388 = &((result)[index]);
#line 689 "VectorModule.cs"
                            double csharp2cuda_temp_389 = (a)[index];
#line 689 "VectorModule.cs"
                            double csharp2cuda_temp_390 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_389, mean), deviation);
                            (*(csharp2cuda_temp_388) = csharp2cuda_temp_390);
#line 690 "VectorModule.cs"
#line 690 "VectorModule.cs"
                            double csharp2cuda_temp_391 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_391))))
                            {
#line 690 "VectorModule.cs"
#line 690 "VectorModule.cs"
                                int* csharp2cuda_temp_392 = &((output)->valid);
                                (*(csharp2cuda_temp_392) = 0);
                            }
                        }
#line 687 "VectorModule.cs"
                        int* csharp2cuda_temp_386 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_386));
                    }
                }
            }
#line 693 "VectorModule.cs"
            break;
#line 694 "VectorModule.cs"
        case 49:
#line 695 "VectorModule.cs"
            if (((thread) == (0)))
#line 696 "VectorModule.cs"
            {
#line 697 "VectorModule.cs"
                int count = 0;
#line 698 "VectorModule.cs"
                {
#line 698 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 698 "VectorModule.cs"
                        int csharp2cuda_temp_394 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_394))))
                            break;
#line 699 "VectorModule.cs"
                        {
#line 700 "VectorModule.cs"
                            bool found = false;
#line 701 "VectorModule.cs"
                            {
#line 701 "VectorModule.cs"
                                int prior = 0;
                                while (true)
                                {
                                    if (!(((prior) < (count))))
                                        break;
#line 702 "VectorModule.cs"
#line 702 "VectorModule.cs"
                                    double csharp2cuda_temp_396 = (result)[prior];
#line 702 "VectorModule.cs"
                                    double csharp2cuda_temp_397 = (a)[index];
                                    if (((csharp2cuda_temp_396) == (csharp2cuda_temp_397)))
#line 702 "VectorModule.cs"
                                    {
#line 702 "VectorModule.cs"
#line 702 "VectorModule.cs"
                                        bool* csharp2cuda_temp_398 = &(found);
                                        (*(csharp2cuda_temp_398) = true);
#line 702 "VectorModule.cs"
                                        break;
                                    }
#line 701 "VectorModule.cs"
                                    int* csharp2cuda_temp_395 = &(prior);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_395));
                                }
                            }
#line 703 "VectorModule.cs"
                            if ((!(found)))
                            {
#line 703 "VectorModule.cs"
#line 703 "VectorModule.cs"
                                int* csharp2cuda_temp_399 = &(count);
#line 703 "VectorModule.cs"
                                int csharp2cuda_temp_400 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_399));
#line 703 "VectorModule.cs"
                                double* csharp2cuda_temp_401 = &((result)[csharp2cuda_temp_400]);
#line 703 "VectorModule.cs"
                                double csharp2cuda_temp_402 = (a)[index];
                                (*(csharp2cuda_temp_401) = csharp2cuda_temp_402);
                            }
                        }
#line 698 "VectorModule.cs"
                        int* csharp2cuda_temp_393 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_393));
                    }
                }
#line 705 "VectorModule.cs"
                mathblocks_set_vector_shape(output, count);
            }
#line 707 "VectorModule.cs"
            break;
#line 708 "VectorModule.cs"
        case 50:
        case 52:
        case 55:
#line 711 "VectorModule.cs"
            {
#line 712 "VectorModule.cs"
                if (((thread) == (0)))
#line 713 "VectorModule.cs"
                {
#line 714 "VectorModule.cs"
#line 714 "VectorModule.cs"
                    int* csharp2cuda_temp_403 = &((output)->boolean_value);
#line 714 "VectorModule.cs"
                    int csharp2cuda_temp_404;
#line 714 "VectorModule.cs"
                    if (((opcode) == (50)))
                    {
#line 714 "VectorModule.cs"
                        csharp2cuda_temp_404 = 1;
                    }
                    else
                    {
#line 714 "VectorModule.cs"
                        csharp2cuda_temp_404 = 0;
                    }
                    (*(csharp2cuda_temp_403) = csharp2cuda_temp_404);
#line 715 "VectorModule.cs"
#line 715 "VectorModule.cs"
                    double* csharp2cuda_temp_405 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_405) = 0.0);
                }
#line 717 "VectorModule.cs"
                __syncthreads();
#line 718 "VectorModule.cs"
                int local_count = 0;
#line 719 "VectorModule.cs"
                bool local_all = true;
#line 720 "VectorModule.cs"
                bool local_any = false;
#line 721 "VectorModule.cs"
                {
#line 721 "VectorModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 721 "VectorModule.cs"
                        int csharp2cuda_temp_408 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_408))))
                            break;
#line 722 "VectorModule.cs"
                        {
#line 723 "VectorModule.cs"
                            int csharp2cuda_temp_409 = (boolean_a)[index];
#line 723 "VectorModule.cs"
                            bool value = ((csharp2cuda_temp_409) != (0));
#line 724 "VectorModule.cs"
                            if (value)
                            {
#line 724 "VectorModule.cs"
#line 724 "VectorModule.cs"
                                int* csharp2cuda_temp_410 = &(local_count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_410));
                            }
#line 725 "VectorModule.cs"
#line 725 "VectorModule.cs"
                            bool* csharp2cuda_temp_411 = &(local_all);
#line 725 "VectorModule.cs"
                            bool csharp2cuda_temp_412;
#line 725 "VectorModule.cs"
                            if (local_all)
                            {
#line 725 "VectorModule.cs"
                                csharp2cuda_temp_412 = value;
                            }
                            else
                            {
#line 725 "VectorModule.cs"
                                csharp2cuda_temp_412 = false;
                            }
                            (*(csharp2cuda_temp_411) = csharp2cuda_temp_412);
#line 726 "VectorModule.cs"
#line 726 "VectorModule.cs"
                            bool* csharp2cuda_temp_413 = &(local_any);
#line 726 "VectorModule.cs"
                            bool csharp2cuda_temp_414;
#line 726 "VectorModule.cs"
                            if (!(local_any))
                            {
#line 726 "VectorModule.cs"
                                csharp2cuda_temp_414 = value;
                            }
                            else
                            {
#line 726 "VectorModule.cs"
                                csharp2cuda_temp_414 = true;
                            }
                            (*(csharp2cuda_temp_413) = csharp2cuda_temp_414);
                        }
#line 721 "VectorModule.cs"
                        int* csharp2cuda_temp_406 = &(index);
#line 721 "VectorModule.cs"
                        int csharp2cuda_temp_407 = *(csharp2cuda_temp_406);
                        (*(csharp2cuda_temp_406) = csharp2cuda_i32_add(csharp2cuda_temp_407, blockDim.x));
                    }
                }
#line 728 "VectorModule.cs"
#line 728 "VectorModule.cs"
                bool csharp2cuda_temp_415;
#line 728 "VectorModule.cs"
                if (((opcode) == (55)))
                {
#line 728 "VectorModule.cs"
                    csharp2cuda_temp_415 = ((local_count) != (0));
                }
                else
                {
#line 728 "VectorModule.cs"
                    csharp2cuda_temp_415 = false;
                }
                if (csharp2cuda_temp_415)
                {
#line 729 "VectorModule.cs"
                    atomicAdd(&((output)->boolean_value), local_count);
                }
                else
                {
#line 730 "VectorModule.cs"
#line 730 "VectorModule.cs"
                    bool csharp2cuda_temp_416;
#line 730 "VectorModule.cs"
                    if (((opcode) == (50)))
                    {
#line 730 "VectorModule.cs"
                        csharp2cuda_temp_416 = (!(local_all));
                    }
                    else
                    {
#line 730 "VectorModule.cs"
                        csharp2cuda_temp_416 = false;
                    }
                    if (csharp2cuda_temp_416)
                    {
#line 731 "VectorModule.cs"
                        atomicExch(&((output)->boolean_value), 0);
                    }
                    else
                    {
#line 732 "VectorModule.cs"
#line 732 "VectorModule.cs"
                        bool csharp2cuda_temp_417;
#line 732 "VectorModule.cs"
                        if (((opcode) == (52)))
                        {
#line 732 "VectorModule.cs"
                            csharp2cuda_temp_417 = local_any;
                        }
                        else
                        {
#line 732 "VectorModule.cs"
                            csharp2cuda_temp_417 = false;
                        }
                        if (csharp2cuda_temp_417)
                        {
#line 733 "VectorModule.cs"
                            atomicExch(&((output)->boolean_value), 1);
                        }
                    }
                }
#line 734 "VectorModule.cs"
                __syncthreads();
#line 735 "VectorModule.cs"
#line 735 "VectorModule.cs"
                bool csharp2cuda_temp_418;
#line 735 "VectorModule.cs"
                if (((thread) == (0)))
                {
#line 735 "VectorModule.cs"
                    csharp2cuda_temp_418 = ((opcode) == (55));
                }
                else
                {
#line 735 "VectorModule.cs"
                    csharp2cuda_temp_418 = false;
                }
                if (csharp2cuda_temp_418)
#line 736 "VectorModule.cs"
                {
#line 737 "VectorModule.cs"
#line 737 "VectorModule.cs"
                    double* csharp2cuda_temp_419 = &((output)->scalar_value);
#line 737 "VectorModule.cs"
                    int csharp2cuda_temp_420 = (output)->boolean_value;
                    (*(csharp2cuda_temp_419) = ((double)(csharp2cuda_temp_420)));
#line 738 "VectorModule.cs"
#line 738 "VectorModule.cs"
                    int* csharp2cuda_temp_421 = &((output)->boolean_value);
                    (*(csharp2cuda_temp_421) = 0);
                }
#line 740 "VectorModule.cs"
                break;
            }
#line 742 "VectorModule.cs"
        case 51:
        case 54:
        case 57:
#line 745 "VectorModule.cs"
            if (((thread) == (0)))
#line 746 "VectorModule.cs"
            {
#line 747 "VectorModule.cs"
#line 747 "VectorModule.cs"
                int csharp2cuda_temp_422 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_422);
#line 748 "VectorModule.cs"
#line 748 "VectorModule.cs"
                int csharp2cuda_temp_423 = (first)->count;
#line 748 "VectorModule.cs"
                int csharp2cuda_temp_424 = (second)->count;
                if (((csharp2cuda_temp_423) != (csharp2cuda_temp_424)))
                {
#line 748 "VectorModule.cs"
#line 748 "VectorModule.cs"
                    int* csharp2cuda_temp_425 = &((output)->valid);
                    (*(csharp2cuda_temp_425) = 0);
                }
            }
#line 750 "VectorModule.cs"
            __syncthreads();
#line 751 "VectorModule.cs"
            {
#line 751 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 751 "VectorModule.cs"
                    bool csharp2cuda_temp_428 = (output)->valid;
#line 751 "VectorModule.cs"
                    bool csharp2cuda_temp_429;
#line 751 "VectorModule.cs"
                    if (csharp2cuda_temp_428)
                    {
#line 751 "VectorModule.cs"
                        int csharp2cuda_temp_430 = (first)->count;
#line 751 "VectorModule.cs"
                        csharp2cuda_temp_429 = ((index) < (csharp2cuda_temp_430));
                    }
                    else
                    {
#line 751 "VectorModule.cs"
                        csharp2cuda_temp_429 = false;
                    }
                    if (!(csharp2cuda_temp_429))
                        break;
#line 752 "VectorModule.cs"
#line 752 "VectorModule.cs"
                    int* csharp2cuda_temp_431 = &((boolean_result)[index]);
#line 752 "VectorModule.cs"
                    bool csharp2cuda_temp_432;
#line 752 "VectorModule.cs"
                    if (((opcode) == (51)))
                    {
#line 752 "VectorModule.cs"
                        bool csharp2cuda_temp_433 = (boolean_a)[index];
#line 752 "VectorModule.cs"
                        bool csharp2cuda_temp_434;
#line 752 "VectorModule.cs"
                        if (csharp2cuda_temp_433)
                        {
#line 752 "VectorModule.cs"
                            csharp2cuda_temp_434 = (boolean_b)[index];
                        }
                        else
                        {
#line 752 "VectorModule.cs"
                            csharp2cuda_temp_434 = false;
                        }
#line 752 "VectorModule.cs"
                        csharp2cuda_temp_432 = csharp2cuda_temp_434;
                    }
                    else
                    {
#line 753 "VectorModule.cs"
                        bool csharp2cuda_temp_435;
#line 753 "VectorModule.cs"
                        if (((opcode) == (54)))
                        {
#line 753 "VectorModule.cs"
                            bool csharp2cuda_temp_436 = (boolean_a)[index];
#line 753 "VectorModule.cs"
                            bool csharp2cuda_temp_437;
#line 753 "VectorModule.cs"
                            if (!(csharp2cuda_temp_436))
                            {
#line 753 "VectorModule.cs"
                                csharp2cuda_temp_437 = (boolean_b)[index];
                            }
                            else
                            {
#line 753 "VectorModule.cs"
                                csharp2cuda_temp_437 = true;
                            }
#line 753 "VectorModule.cs"
                            csharp2cuda_temp_435 = csharp2cuda_temp_437;
                        }
                        else
                        {
#line 754 "VectorModule.cs"
                            int csharp2cuda_temp_438 = (boolean_a)[index];
#line 754 "VectorModule.cs"
                            int csharp2cuda_temp_439 = (boolean_b)[index];
#line 753 "VectorModule.cs"
                            csharp2cuda_temp_435 = ((csharp2cuda_temp_438) != (csharp2cuda_temp_439));
                        }
#line 752 "VectorModule.cs"
                        csharp2cuda_temp_432 = csharp2cuda_temp_435;
                    }
                    (*(csharp2cuda_temp_431) = csharp2cuda_temp_432);
#line 751 "VectorModule.cs"
                    int* csharp2cuda_temp_426 = &(index);
#line 751 "VectorModule.cs"
                    int csharp2cuda_temp_427 = *(csharp2cuda_temp_426);
                    (*(csharp2cuda_temp_426) = csharp2cuda_i32_add(csharp2cuda_temp_427, blockDim.x));
                }
            }
#line 755 "VectorModule.cs"
            break;
#line 756 "VectorModule.cs"
        case 53:
#line 757 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 757 "VectorModule.cs"
#line 757 "VectorModule.cs"
                int csharp2cuda_temp_440 = (first)->count;
                mathblocks_set_vector_shape(output, csharp2cuda_temp_440);
            }
#line 758 "VectorModule.cs"
            __syncthreads();
#line 759 "VectorModule.cs"
            {
#line 759 "VectorModule.cs"
                int index = thread;
                while (true)
                {
#line 759 "VectorModule.cs"
                    bool csharp2cuda_temp_443 = (output)->valid;
#line 759 "VectorModule.cs"
                    bool csharp2cuda_temp_444;
#line 759 "VectorModule.cs"
                    if (csharp2cuda_temp_443)
                    {
#line 759 "VectorModule.cs"
                        int csharp2cuda_temp_445 = (first)->count;
#line 759 "VectorModule.cs"
                        csharp2cuda_temp_444 = ((index) < (csharp2cuda_temp_445));
                    }
                    else
                    {
#line 759 "VectorModule.cs"
                        csharp2cuda_temp_444 = false;
                    }
                    if (!(csharp2cuda_temp_444))
                        break;
#line 760 "VectorModule.cs"
#line 760 "VectorModule.cs"
                    int* csharp2cuda_temp_446 = &((boolean_result)[index]);
#line 760 "VectorModule.cs"
                    bool csharp2cuda_temp_447 = (boolean_a)[index];
                    (*(csharp2cuda_temp_446) = (!(csharp2cuda_temp_447)));
#line 759 "VectorModule.cs"
                    int* csharp2cuda_temp_441 = &(index);
#line 759 "VectorModule.cs"
                    int csharp2cuda_temp_442 = *(csharp2cuda_temp_441);
                    (*(csharp2cuda_temp_441) = csharp2cuda_i32_add(csharp2cuda_temp_442, blockDim.x));
                }
            }
#line 761 "VectorModule.cs"
            break;
#line 762 "VectorModule.cs"
        case 56:
#line 763 "VectorModule.cs"
            if (((thread) == (0)))
#line 764 "VectorModule.cs"
            {
#line 765 "VectorModule.cs"
                int count = 0;
#line 766 "VectorModule.cs"
                {
#line 766 "VectorModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 766 "VectorModule.cs"
                        int csharp2cuda_temp_449 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_449))))
                            break;
#line 767 "VectorModule.cs"
                        if ((boolean_a)[index])
                        {
#line 767 "VectorModule.cs"
#line 767 "VectorModule.cs"
                            int* csharp2cuda_temp_450 = &(count);
#line 767 "VectorModule.cs"
                            int csharp2cuda_temp_451 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_450));
#line 767 "VectorModule.cs"
                            double* csharp2cuda_temp_452 = &((result)[csharp2cuda_temp_451]);
                            (*(csharp2cuda_temp_452) = ((double)(index)));
                        }
#line 766 "VectorModule.cs"
                        int* csharp2cuda_temp_448 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_448));
                    }
                }
#line 768 "VectorModule.cs"
                mathblocks_set_vector_shape(output, count);
            }
#line 770 "VectorModule.cs"
            break;
#line 771 "VectorModule.cs"
        default:
#line 772 "VectorModule.cs"
            if (((thread) == (0)))
            {
#line 772 "VectorModule.cs"
#line 772 "VectorModule.cs"
                int* csharp2cuda_temp_453 = &((output)->valid);
                (*(csharp2cuda_temp_453) = 0);
            }
#line 773 "VectorModule.cs"
            break;
    }
}

#line 198 "VectorModule.cs"
__device__ bool mathblocks_vector_geometric_mean_value(
    const double* values,
    int count,
    double* logarithms,
    double* value)
#line 204 "VectorModule.cs"
{
#line 205 "VectorModule.cs"
    if (((count) <= (0)))
    {
#line 206 "VectorModule.cs"
        return false;
    }
#line 207 "VectorModule.cs"
    bool finite = true;
#line 208 "VectorModule.cs"
    {
#line 208 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 209 "VectorModule.cs"
            {
#line 210 "VectorModule.cs"
#line 210 "VectorModule.cs"
                double* csharp2cuda_temp_1 = &((logarithms)[index]);
#line 210 "VectorModule.cs"
                double csharp2cuda_temp_2 = (values)[index];
                (*(csharp2cuda_temp_1) = mathblocks_natural_logarithm(csharp2cuda_temp_2));
#line 211 "VectorModule.cs"
#line 211 "VectorModule.cs"
                double csharp2cuda_temp_3 = (logarithms)[index];
                if ((!(isfinite(csharp2cuda_temp_3))))
                {
#line 212 "VectorModule.cs"
#line 212 "VectorModule.cs"
                    bool* csharp2cuda_temp_4 = &(finite);
                    (*(csharp2cuda_temp_4) = false);
                }
            }
#line 208 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 214 "VectorModule.cs"
    if ((!(finite)))
    {
#line 215 "VectorModule.cs"
        return false;
    }
#line 216 "VectorModule.cs"
#line 216 "VectorModule.cs"
    double* csharp2cuda_temp_5 = value;
#line 216 "VectorModule.cs"
    double csharp2cuda_temp_6 = mathblocks_compensated_sum(logarithms, count);
#line 216 "VectorModule.cs"
    double csharp2cuda_temp_7 = __ddiv_rn(csharp2cuda_temp_6, ((double)(count)));
    (*(csharp2cuda_temp_5) = mathblocks_exponential(csharp2cuda_temp_7));
#line 217 "VectorModule.cs"
#line 217 "VectorModule.cs"
    double csharp2cuda_temp_8 = *(value);
    return isfinite(csharp2cuda_temp_8);
}

#line 238 "VectorModule.cs"
__device__ double mathblocks_vector_rank_at(
    const double* values,
    int count,
    int position)
#line 243 "VectorModule.cs"
{
#line 244 "VectorModule.cs"
    int less = 0;
#line 245 "VectorModule.cs"
    int equal = 0;
#line 246 "VectorModule.cs"
    {
#line 246 "VectorModule.cs"
        int other = 0;
        while (true)
        {
            if (!(((other) < (count))))
                break;
#line 247 "VectorModule.cs"
            {
#line 248 "VectorModule.cs"
#line 248 "VectorModule.cs"
                double csharp2cuda_temp_1 = (values)[other];
#line 248 "VectorModule.cs"
                double csharp2cuda_temp_2 = (values)[position];
                if (((csharp2cuda_temp_1) < (csharp2cuda_temp_2)))
                {
#line 248 "VectorModule.cs"
#line 248 "VectorModule.cs"
                    int* csharp2cuda_temp_3 = &(less);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
                }
                else
                {
#line 249 "VectorModule.cs"
#line 249 "VectorModule.cs"
                    double csharp2cuda_temp_4 = (values)[other];
#line 249 "VectorModule.cs"
                    double csharp2cuda_temp_5 = (values)[position];
                    if (((csharp2cuda_temp_4) == (csharp2cuda_temp_5)))
                    {
#line 249 "VectorModule.cs"
#line 249 "VectorModule.cs"
                        int* csharp2cuda_temp_6 = &(equal);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
                    }
                }
            }
#line 246 "VectorModule.cs"
            int* csharp2cuda_temp_0 = &(other);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 251 "VectorModule.cs"
#line 251 "VectorModule.cs"
    double csharp2cuda_temp_7 = __ddiv_rn(__dadd_rn(((double)(equal)), 1.0), 2.0);
    return __dadd_rn(((double)(less)), csharp2cuda_temp_7);
}

#line 254 "VectorModule.cs"
__device__ void mathblocks_vector_standardize_moments(
    const double* values,
    int count,
    double* mean,
    double* deviation)
#line 260 "VectorModule.cs"
{
#line 261 "VectorModule.cs"
    double csharp2cuda_temp_0 = mathblocks_compensated_sum(values, count);
#line 261 "VectorModule.cs"
    double average = __ddiv_rn(csharp2cuda_temp_0, ((double)(count)));
#line 262 "VectorModule.cs"
    double variance = 0.0;
#line 263 "VectorModule.cs"
    {
#line 263 "VectorModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 264 "VectorModule.cs"
            {
#line 265 "VectorModule.cs"
                double csharp2cuda_temp_2 = (values)[index];
#line 265 "VectorModule.cs"
                double difference = __dsub_rn(csharp2cuda_temp_2, average);
#line 266 "VectorModule.cs"
#line 266 "VectorModule.cs"
                double* csharp2cuda_temp_3 = &(variance);
#line 266 "VectorModule.cs"
                double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
                (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, __dmul_rn(difference, difference)));
            }
#line 263 "VectorModule.cs"
            int* csharp2cuda_temp_1 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 268 "VectorModule.cs"
#line 268 "VectorModule.cs"
    double* csharp2cuda_temp_5 = &(variance);
#line 268 "VectorModule.cs"
    double csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
    (*(csharp2cuda_temp_5) = __ddiv_rn(csharp2cuda_temp_6, ((double)(count))));
#line 269 "VectorModule.cs"
#line 269 "VectorModule.cs"
    double* csharp2cuda_temp_7 = mean;
    (*(csharp2cuda_temp_7) = average);
#line 270 "VectorModule.cs"
#line 270 "VectorModule.cs"
    double* csharp2cuda_temp_8 = deviation;
    (*(csharp2cuda_temp_8) = mathblocks_square_root(variance));
}