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

#line 956 "WindowModule.cs"
__device__ void mathblocks_window_accurate_rows(
    int source,
    const double* x,
    int width,
    int first_row,
    int last_row,
    double fill,
    bool sibling,
    double* result,
    int* boolean_result,
    long long* scratch);

#line 1259 "WindowModule.cs"
__device__ void mathblocks_window_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 256 "WindowModule.cs"
__device__ bool mathblocks_window_distance_correlation(
    const double* left_values,
    const double* right_values,
    int count,
    double* row_means,
    double* value);

#line 231 "WindowModule.cs"
__device__ double mathblocks_window_distance_row_means(
    const double* values,
    int count,
    double* row_means);

#line 912 "WindowModule.cs"
__device__ void mathblocks_window_divide_by_integer(double h, double l, int width, double* qh, double* ql);

#line 659 "WindowModule.cs"
__device__ void mathblocks_window_exact_add(long long* accumulator, double value, int shift, bool subtract);

#line 702 "WindowModule.cs"
__device__ void mathblocks_window_exact_add_square(long long* accumulator, double value, bool subtract);

#line 596 "WindowModule.cs"
__device__ int mathblocks_window_exact_add_to(long long* target, double value, int shift, bool subtract);

#line 763 "WindowModule.cs"
__device__ bool mathblocks_window_exact_any_below(const long long* value, int lowest, int position);

#line 749 "WindowModule.cs"
__device__ long long mathblocks_window_exact_bits(const long long* value, int position, int count);

#line 638 "WindowModule.cs"
__device__ long long mathblocks_window_exact_carry(long long* target, int first, int last);

#line 585 "WindowModule.cs"
__device__ void mathblocks_window_exact_clear(long long* accumulator);

#line 729 "WindowModule.cs"
__device__ int mathblocks_window_exact_load(long long* accumulator, bool* negative);

#line 652 "WindowModule.cs"
__device__ void mathblocks_window_exact_negate(long long* target, int first, int last);

#line 815 "WindowModule.cs"
__device__ void mathblocks_window_exact_read_pair(long long* accumulator, double* high, double* low, bool* zero);

#line 856 "WindowModule.cs"
__device__ double mathblocks_window_exact_read_quotient(long long* accumulator, int divisor);

#line 779 "WindowModule.cs"
__device__ double mathblocks_window_exact_round(const long long* value, int lowest, int top, bool sticky);

#line 893 "WindowModule.cs"
__device__ void mathblocks_window_fast_two_sum(double a, double b, double* s, double* e);

#line 946 "WindowModule.cs"
__device__ bool mathblocks_window_in_range(double value, double largest);

#line 579 "WindowModule.cs"
__device__ double mathblocks_window_power_of_two(int exponent);

#line 1126 "WindowModule.cs"
__device__ void mathblocks_window_publish(MathBlockSlot* output, bool valid, int count, int thread);

#line 1142 "WindowModule.cs"
__device__ void mathblocks_window_run(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output,
    int thread,
    int threads,
    int scratch_capacity);

#line 197 "WindowModule.cs"
__device__ long long mathblocks_window_scratch_count(int source, int width);

#line 296 "WindowModule.cs"
__device__ double mathblocks_window_scratch_median(double* scratch, int count);

#line 172 "WindowModule.cs"
__device__ int mathblocks_window_series_count(int source);

#line 1065 "WindowModule.cs"
__device__ void mathblocks_window_sorted_rows(
    const double* x,
    int width,
    double probability,
    int first_row,
    int last_row,
    double fill,
    bool sibling,
    double* result,
    int* boolean_result,
    double* sorted);

#line 139 "WindowModule.cs"
__device__ int mathblocks_window_source_arity(int source);

#line 678 "WindowModule.cs"
__device__ void mathblocks_window_split(double a, double* high, double* low);

#line 901 "WindowModule.cs"
__device__ void mathblocks_window_square(double h, double l, double* sh, double* sl);

#line 305 "WindowModule.cs"
__device__ bool mathblocks_window_standardize_last(
    const double* values,
    int count,
    double* value);

#line 925 "WindowModule.cs"
__device__ double mathblocks_window_subtract_rounded(double ah, double al, double bh, double bl);

#line 687 "WindowModule.cs"
__device__ void mathblocks_window_two_product(double a, double b, double* p, double* e);

#line 884 "WindowModule.cs"
__device__ void mathblocks_window_two_sum(double a, double b, double* s, double* e);

#line 327 "WindowModule.cs"
__device__ bool mathblocks_window_value(
    int source,
    const double* a,
    const double* b,
    const int* flags,
    int count,
    const MathBlockSlot* first_parameter,
    const MathBlockSlot* second_parameter,
    double* scratch,
    double* value);

#line 956 "WindowModule.cs"
__device__ void mathblocks_window_accurate_rows(
    int source,
    const double* x,
    int width,
    int first_row,
    int last_row,
    double fill,
    bool sibling,
    double* result,
    int* boolean_result,
    long long* scratch)
#line 968 "WindowModule.cs"
{
#line 969 "WindowModule.cs"
    bool variance = ((source) >= (55));
#line 970 "WindowModule.cs"
    bool csharp2cuda_temp_0;
#line 970 "WindowModule.cs"
    if (!(((source) == (56))))
    {
#line 970 "WindowModule.cs"
        csharp2cuda_temp_0 = ((source) == (58));
    }
    else
    {
#line 970 "WindowModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 970 "WindowModule.cs"
    bool sample = csharp2cuda_temp_0;
#line 971 "WindowModule.cs"
    bool deviation = ((source) >= (57));
#line 972 "WindowModule.cs"
    long long* first = scratch;
#line 973 "WindowModule.cs"
    long long* second = csharp2cuda_pointer_add(scratch, 285);
#line 974 "WindowModule.cs"
    mathblocks_window_exact_clear(first);
#line 975 "WindowModule.cs"
    if (variance)
    {
#line 976 "WindowModule.cs"
        mathblocks_window_exact_clear(second);
    }
#line 977 "WindowModule.cs"
    double csharp2cuda_temp_1;
#line 977 "WindowModule.cs"
    if (sample)
    {
#line 977 "WindowModule.cs"
        csharp2cuda_temp_1 = __dsub_rn(((double)(width)), 1.0);
    }
    else
    {
#line 977 "WindowModule.cs"
        csharp2cuda_temp_1 = ((double)(width));
    }
#line 977 "WindowModule.cs"
    double divisor = csharp2cuda_temp_1;
#line 978 "WindowModule.cs"
    int csharp2cuda_temp_2;
#line 978 "WindowModule.cs"
    if (((csharp2cuda_i32_add(csharp2cuda_i32_sub(first_row, width), 1)) < (0)))
    {
#line 978 "WindowModule.cs"
        csharp2cuda_temp_2 = 0;
    }
    else
    {
#line 978 "WindowModule.cs"
        csharp2cuda_temp_2 = csharp2cuda_i32_add(csharp2cuda_i32_sub(first_row, width), 1);
    }
#line 978 "WindowModule.cs"
    int begin = csharp2cuda_temp_2;
#line 979 "WindowModule.cs"
    int changes = 0;
#line 980 "WindowModule.cs"
    {
#line 980 "WindowModule.cs"
        int row = begin;
        while (true)
        {
            if (!(((row) < (last_row))))
                break;
#line 981 "WindowModule.cs"
            {
#line 982 "WindowModule.cs"
#line 982 "WindowModule.cs"
                double csharp2cuda_temp_4 = (x)[row];
                mathblocks_window_exact_add(first, csharp2cuda_temp_4, 0, false);
#line 983 "WindowModule.cs"
                if (variance)
#line 984 "WindowModule.cs"
                {
#line 985 "WindowModule.cs"
#line 985 "WindowModule.cs"
                    double csharp2cuda_temp_5 = (x)[row];
                    mathblocks_window_exact_add_square(second, csharp2cuda_temp_5, false);
#line 986 "WindowModule.cs"
#line 986 "WindowModule.cs"
                    bool csharp2cuda_temp_6;
#line 986 "WindowModule.cs"
                    if (((row) > (begin)))
                    {
#line 986 "WindowModule.cs"
                        double csharp2cuda_temp_7 = (x)[row];
#line 986 "WindowModule.cs"
                        double csharp2cuda_temp_8 = (x)[csharp2cuda_i32_sub(row, 1)];
#line 986 "WindowModule.cs"
                        csharp2cuda_temp_6 = ((csharp2cuda_temp_7) != (csharp2cuda_temp_8));
                    }
                    else
                    {
#line 986 "WindowModule.cs"
                        csharp2cuda_temp_6 = false;
                    }
                    if (csharp2cuda_temp_6)
                    {
#line 987 "WindowModule.cs"
#line 987 "WindowModule.cs"
                        int* csharp2cuda_temp_9 = &(changes);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
                    }
                }
#line 989 "WindowModule.cs"
                if (((csharp2cuda_i32_sub(row, width)) >= (begin)))
#line 990 "WindowModule.cs"
                {
#line 991 "WindowModule.cs"
#line 991 "WindowModule.cs"
                    double csharp2cuda_temp_10 = (x)[csharp2cuda_i32_sub(row, width)];
                    mathblocks_window_exact_add(first, csharp2cuda_temp_10, 0, true);
#line 992 "WindowModule.cs"
                    if (variance)
#line 993 "WindowModule.cs"
                    {
#line 994 "WindowModule.cs"
#line 994 "WindowModule.cs"
                        double csharp2cuda_temp_11 = (x)[csharp2cuda_i32_sub(row, width)];
                        mathblocks_window_exact_add_square(second, csharp2cuda_temp_11, true);
#line 995 "WindowModule.cs"
#line 995 "WindowModule.cs"
                        double csharp2cuda_temp_12 = (x)[csharp2cuda_i32_add(csharp2cuda_i32_sub(row, width), 1)];
#line 995 "WindowModule.cs"
                        double csharp2cuda_temp_13 = (x)[csharp2cuda_i32_sub(row, width)];
                        if (((csharp2cuda_temp_12) != (csharp2cuda_temp_13)))
                        {
#line 996 "WindowModule.cs"
#line 996 "WindowModule.cs"
                            int* csharp2cuda_temp_14 = &(changes);
                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_14));
                        }
                    }
                }
#line 999 "WindowModule.cs"
                if (((row) < (first_row)))
                {
#line 1000 "WindowModule.cs"
                    goto csharp2cuda_for_continue_0;
                }
#line 1001 "WindowModule.cs"
                bool computed = false;
#line 1002 "WindowModule.cs"
                double value = 0.0;
#line 1003 "WindowModule.cs"
                if (((row) >= (csharp2cuda_i32_sub(width, 1))))
#line 1004 "WindowModule.cs"
                {
#line 1005 "WindowModule.cs"
                    if ((!(variance)))
#line 1006 "WindowModule.cs"
                    {
#line 1007 "WindowModule.cs"
                        double low = 0.0;
#line 1008 "WindowModule.cs"
                        bool zero = true;
#line 1009 "WindowModule.cs"
                        if (((source) == (54)))
                        {
#line 1010 "WindowModule.cs"
#line 1010 "WindowModule.cs"
                            double* csharp2cuda_temp_15 = &(value);
#line 1010 "WindowModule.cs"
                            double csharp2cuda_temp_16 = mathblocks_window_exact_read_quotient(first, width);
                            (*(csharp2cuda_temp_15) = csharp2cuda_temp_16);
                        }
                        else
                        {
#line 1012 "WindowModule.cs"
#line 1012 "WindowModule.cs"
                            double* csharp2cuda_temp_17 = &(value);
#line 1012 "WindowModule.cs"
                            double* csharp2cuda_temp_18 = &(low);
#line 1012 "WindowModule.cs"
                            bool* csharp2cuda_temp_19 = &(zero);
                            mathblocks_window_exact_read_pair(first, csharp2cuda_temp_17, csharp2cuda_temp_18, csharp2cuda_temp_19);
                        }
#line 1013 "WindowModule.cs"
#line 1013 "WindowModule.cs"
                        bool* csharp2cuda_temp_20 = &(computed);
                        (*(csharp2cuda_temp_20) = isfinite(value));
                    }
                    else
#line 1016 "WindowModule.cs"
                    {
#line 1017 "WindowModule.cs"
                        double moment = 0.0;
#line 1018 "WindowModule.cs"
                        bool in_range = true;
#line 1019 "WindowModule.cs"
                        if (((changes) != (0)))
#line 1020 "WindowModule.cs"
                        {
#line 1021 "WindowModule.cs"
                            double s1h = 0.0;
#line 1022 "WindowModule.cs"
                            double s1l = 0.0;
#line 1023 "WindowModule.cs"
                            double s2h = 0.0;
#line 1024 "WindowModule.cs"
                            double s2l = 0.0;
#line 1025 "WindowModule.cs"
                            double qh = 0.0;
#line 1026 "WindowModule.cs"
                            double ql = 0.0;
#line 1027 "WindowModule.cs"
                            double rh = 0.0;
#line 1028 "WindowModule.cs"
                            double rl = 0.0;
#line 1029 "WindowModule.cs"
                            bool s1_zero = true;
#line 1030 "WindowModule.cs"
                            bool s2_zero = true;
#line 1031 "WindowModule.cs"
#line 1031 "WindowModule.cs"
                            double* csharp2cuda_temp_21 = &(s1h);
#line 1031 "WindowModule.cs"
                            double* csharp2cuda_temp_22 = &(s1l);
#line 1031 "WindowModule.cs"
                            bool* csharp2cuda_temp_23 = &(s1_zero);
                            mathblocks_window_exact_read_pair(first, csharp2cuda_temp_21, csharp2cuda_temp_22, csharp2cuda_temp_23);
#line 1032 "WindowModule.cs"
#line 1032 "WindowModule.cs"
                            double* csharp2cuda_temp_24 = &(s2h);
#line 1032 "WindowModule.cs"
                            double* csharp2cuda_temp_25 = &(s2l);
#line 1032 "WindowModule.cs"
                            bool* csharp2cuda_temp_26 = &(s2_zero);
                            mathblocks_window_exact_read_pair(second, csharp2cuda_temp_24, csharp2cuda_temp_25, csharp2cuda_temp_26);
#line 1033 "WindowModule.cs"
#line 1033 "WindowModule.cs"
                            double* csharp2cuda_temp_27 = &(qh);
#line 1033 "WindowModule.cs"
                            double* csharp2cuda_temp_28 = &(ql);
                            mathblocks_window_square(s1h, s1l, csharp2cuda_temp_27, csharp2cuda_temp_28);
#line 1034 "WindowModule.cs"
#line 1034 "WindowModule.cs"
                            double* csharp2cuda_temp_29 = &(rh);
#line 1034 "WindowModule.cs"
                            double* csharp2cuda_temp_30 = &(rl);
                            mathblocks_window_divide_by_integer(qh, ql, width, csharp2cuda_temp_29, csharp2cuda_temp_30);
#line 1035 "WindowModule.cs"
#line 1035 "WindowModule.cs"
                            double* csharp2cuda_temp_31 = &(moment);
#line 1035 "WindowModule.cs"
                            double csharp2cuda_temp_32 = mathblocks_window_subtract_rounded(s2h, s2l, rh, rl);
                            (*(csharp2cuda_temp_31) = csharp2cuda_temp_32);
#line 1036 "WindowModule.cs"
                            double largest = __longlong_as_double(9218868437227405311LL);
#line 1037 "WindowModule.cs"
#line 1037 "WindowModule.cs"
                            bool csharp2cuda_temp_33;
#line 1037 "WindowModule.cs"
                            if (!((!(mathblocks_window_in_range(s2h, largest)))))
                            {
#line 1037 "WindowModule.cs"
                                csharp2cuda_temp_33 = (!(mathblocks_window_in_range(qh, largest)));
                            }
                            else
                            {
#line 1037 "WindowModule.cs"
                                csharp2cuda_temp_33 = true;
                            }
#line 1037 "WindowModule.cs"
                            bool csharp2cuda_temp_34;
#line 1037 "WindowModule.cs"
                            if (!(csharp2cuda_temp_33))
                            {
#line 1037 "WindowModule.cs"
                                csharp2cuda_temp_34 = (!(mathblocks_window_in_range(rh, mathblocks_window_power_of_two(996))));
                            }
                            else
                            {
#line 1037 "WindowModule.cs"
                                csharp2cuda_temp_34 = true;
                            }
#line 1037 "WindowModule.cs"
                            bool csharp2cuda_temp_35;
#line 1037 "WindowModule.cs"
                            if (!(csharp2cuda_temp_34))
                            {
#line 1040 "WindowModule.cs"
                                bool csharp2cuda_temp_36;
#line 1040 "WindowModule.cs"
                                if (((s2h) == (0.0)))
                                {
#line 1040 "WindowModule.cs"
                                    csharp2cuda_temp_36 = (!(s2_zero));
                                }
                                else
                                {
#line 1040 "WindowModule.cs"
                                    csharp2cuda_temp_36 = false;
                                }
#line 1037 "WindowModule.cs"
                                csharp2cuda_temp_35 = csharp2cuda_temp_36;
                            }
                            else
                            {
#line 1037 "WindowModule.cs"
                                csharp2cuda_temp_35 = true;
                            }
#line 1037 "WindowModule.cs"
                            bool csharp2cuda_temp_37;
#line 1037 "WindowModule.cs"
                            if (!(csharp2cuda_temp_35))
                            {
#line 1040 "WindowModule.cs"
                                bool csharp2cuda_temp_38;
#line 1040 "WindowModule.cs"
                                if (((qh) == (0.0)))
                                {
#line 1040 "WindowModule.cs"
                                    csharp2cuda_temp_38 = ((s1h) != (0.0));
                                }
                                else
                                {
#line 1040 "WindowModule.cs"
                                    csharp2cuda_temp_38 = false;
                                }
#line 1037 "WindowModule.cs"
                                csharp2cuda_temp_37 = csharp2cuda_temp_38;
                            }
                            else
                            {
#line 1037 "WindowModule.cs"
                                csharp2cuda_temp_37 = true;
                            }
#line 1037 "WindowModule.cs"
                            bool csharp2cuda_temp_39;
#line 1037 "WindowModule.cs"
                            if (!(csharp2cuda_temp_37))
                            {
#line 1041 "WindowModule.cs"
                                bool csharp2cuda_temp_40;
#line 1041 "WindowModule.cs"
                                if (((moment) > (0.0)))
                                {
#line 1041 "WindowModule.cs"
                                    csharp2cuda_temp_40 = ((moment) < (mathblocks_window_power_of_two(csharp2cuda_i32_neg(968))));
                                }
                                else
                                {
#line 1041 "WindowModule.cs"
                                    csharp2cuda_temp_40 = false;
                                }
#line 1037 "WindowModule.cs"
                                csharp2cuda_temp_39 = csharp2cuda_temp_40;
                            }
                            else
                            {
#line 1037 "WindowModule.cs"
                                csharp2cuda_temp_39 = true;
                            }
                            if (csharp2cuda_temp_39)
                            {
#line 1042 "WindowModule.cs"
#line 1042 "WindowModule.cs"
                                bool* csharp2cuda_temp_41 = &(in_range);
                                (*(csharp2cuda_temp_41) = false);
                            }
                            else
                            {
#line 1043 "WindowModule.cs"
                                if (((moment) <= (0.0)))
                                {
#line 1044 "WindowModule.cs"
#line 1044 "WindowModule.cs"
                                    double* csharp2cuda_temp_42 = &(moment);
                                    (*(csharp2cuda_temp_42) = 0.0);
                                }
                            }
                        }
#line 1046 "WindowModule.cs"
#line 1046 "WindowModule.cs"
                        double* csharp2cuda_temp_43 = &(value);
#line 1046 "WindowModule.cs"
                        double csharp2cuda_temp_44 = __ddiv_rn(moment, divisor);
                        (*(csharp2cuda_temp_43) = csharp2cuda_temp_44);
#line 1047 "WindowModule.cs"
                        if (deviation)
                        {
#line 1048 "WindowModule.cs"
#line 1048 "WindowModule.cs"
                            double* csharp2cuda_temp_45 = &(value);
                            (*(csharp2cuda_temp_45) = mathblocks_square_root(value));
                        }
#line 1049 "WindowModule.cs"
#line 1049 "WindowModule.cs"
                        bool* csharp2cuda_temp_46 = &(computed);
#line 1049 "WindowModule.cs"
                        bool csharp2cuda_temp_47;
#line 1049 "WindowModule.cs"
                        if (in_range)
                        {
#line 1049 "WindowModule.cs"
                            csharp2cuda_temp_47 = isfinite(value);
                        }
                        else
                        {
#line 1049 "WindowModule.cs"
                            csharp2cuda_temp_47 = false;
                        }
                        (*(csharp2cuda_temp_46) = csharp2cuda_temp_47);
                    }
                }
#line 1052 "WindowModule.cs"
                if (sibling)
                {
#line 1053 "WindowModule.cs"
#line 1053 "WindowModule.cs"
                    int* csharp2cuda_temp_48 = &((boolean_result)[row]);
                    (*(csharp2cuda_temp_48) = computed);
                }
                else
                {
#line 1055 "WindowModule.cs"
#line 1055 "WindowModule.cs"
                    double* csharp2cuda_temp_49 = &((result)[row]);
#line 1055 "WindowModule.cs"
                    double csharp2cuda_temp_50;
#line 1055 "WindowModule.cs"
                    if (computed)
                    {
#line 1055 "WindowModule.cs"
                        csharp2cuda_temp_50 = value;
                    }
                    else
                    {
#line 1055 "WindowModule.cs"
                        csharp2cuda_temp_50 = fill;
                    }
                    (*(csharp2cuda_temp_49) = csharp2cuda_temp_50);
                }
            }
            csharp2cuda_for_continue_0:
#line 980 "WindowModule.cs"
            int* csharp2cuda_temp_3 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
        }
    }
}

#line 1259 "WindowModule.cs"
__device__ void mathblocks_window_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 1265 "WindowModule.cs"
{
#line 1266 "WindowModule.cs"
    mathblocks_window_run(opcode, inputs, input_count, output, threadIdx.x, blockDim.x, csharp2cuda_i32_neg(1));
}

#line 256 "WindowModule.cs"
__device__ bool mathblocks_window_distance_correlation(
    const double* left_values,
    const double* right_values,
    int count,
    double* row_means,
    double* value)
#line 263 "WindowModule.cs"
{
#line 264 "WindowModule.cs"
    if (((count) <= (0)))
    {
#line 265 "WindowModule.cs"
        return false;
    }
#line 266 "WindowModule.cs"
    double* left_means = row_means;
#line 267 "WindowModule.cs"
    double* right_means = csharp2cuda_pointer_add(row_means, count);
#line 268 "WindowModule.cs"
    double left_total = mathblocks_window_distance_row_means(left_values, count, left_means);
#line 269 "WindowModule.cs"
    double right_total = mathblocks_window_distance_row_means(right_values, count, right_means);
#line 270 "WindowModule.cs"
    double covariance_square = 0.0;
#line 271 "WindowModule.cs"
    double left_variance_square = 0.0;
#line 272 "WindowModule.cs"
    double right_variance_square = 0.0;
#line 273 "WindowModule.cs"
    {
#line 273 "WindowModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 274 "WindowModule.cs"
            {
#line 275 "WindowModule.cs"
                {
#line 275 "WindowModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (count))))
                            break;
#line 276 "WindowModule.cs"
                        {
#line 277 "WindowModule.cs"
                            double csharp2cuda_temp_2 = (left_values)[row];
#line 277 "WindowModule.cs"
                            double csharp2cuda_temp_3 = (left_values)[column];
#line 278 "WindowModule.cs"
                            double csharp2cuda_temp_4 = (left_means)[row];
#line 278 "WindowModule.cs"
                            double csharp2cuda_temp_5 = (left_means)[column];
#line 277 "WindowModule.cs"
                            double left = __dsub_rn(fabs(__dsub_rn(csharp2cuda_temp_2, csharp2cuda_temp_3)), __dsub_rn(__dadd_rn(csharp2cuda_temp_4, csharp2cuda_temp_5), left_total));
#line 279 "WindowModule.cs"
                            double csharp2cuda_temp_6 = (right_values)[row];
#line 279 "WindowModule.cs"
                            double csharp2cuda_temp_7 = (right_values)[column];
#line 280 "WindowModule.cs"
                            double csharp2cuda_temp_8 = (right_means)[row];
#line 280 "WindowModule.cs"
                            double csharp2cuda_temp_9 = (right_means)[column];
#line 279 "WindowModule.cs"
                            double right = __dsub_rn(fabs(__dsub_rn(csharp2cuda_temp_6, csharp2cuda_temp_7)), __dsub_rn(__dadd_rn(csharp2cuda_temp_8, csharp2cuda_temp_9), right_total));
#line 281 "WindowModule.cs"
#line 281 "WindowModule.cs"
                            double* csharp2cuda_temp_10 = &(covariance_square);
#line 281 "WindowModule.cs"
                            double csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
                            (*(csharp2cuda_temp_10) = __dadd_rn(csharp2cuda_temp_11, __dmul_rn(left, right)));
#line 282 "WindowModule.cs"
#line 282 "WindowModule.cs"
                            double* csharp2cuda_temp_12 = &(left_variance_square);
#line 282 "WindowModule.cs"
                            double csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
                            (*(csharp2cuda_temp_12) = __dadd_rn(csharp2cuda_temp_13, __dmul_rn(left, left)));
#line 283 "WindowModule.cs"
#line 283 "WindowModule.cs"
                            double* csharp2cuda_temp_14 = &(right_variance_square);
#line 283 "WindowModule.cs"
                            double csharp2cuda_temp_15 = *(csharp2cuda_temp_14);
                            (*(csharp2cuda_temp_14) = __dadd_rn(csharp2cuda_temp_15, __dmul_rn(right, right)));
                        }
#line 275 "WindowModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
            }
#line 273 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 286 "WindowModule.cs"
#line 286 "WindowModule.cs"
    double* csharp2cuda_temp_16 = &(covariance_square);
#line 286 "WindowModule.cs"
    double csharp2cuda_temp_17 = *(csharp2cuda_temp_16);
    (*(csharp2cuda_temp_16) = __ddiv_rn(csharp2cuda_temp_17, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 287 "WindowModule.cs"
#line 287 "WindowModule.cs"
    double* csharp2cuda_temp_18 = &(left_variance_square);
#line 287 "WindowModule.cs"
    double csharp2cuda_temp_19 = *(csharp2cuda_temp_18);
    (*(csharp2cuda_temp_18) = __ddiv_rn(csharp2cuda_temp_19, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 288 "WindowModule.cs"
#line 288 "WindowModule.cs"
    double* csharp2cuda_temp_20 = &(right_variance_square);
#line 288 "WindowModule.cs"
    double csharp2cuda_temp_21 = *(csharp2cuda_temp_20);
    (*(csharp2cuda_temp_20) = __ddiv_rn(csharp2cuda_temp_21, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 289 "WindowModule.cs"
#line 289 "WindowModule.cs"
    double* csharp2cuda_temp_22 = value;
#line 290 "WindowModule.cs"
    double csharp2cuda_temp_23 = __ddiv_rn(covariance_square, mathblocks_square_root(__dmul_rn(left_variance_square, right_variance_square)));
    (*(csharp2cuda_temp_22) = mathblocks_square_root(csharp2cuda_temp_23));
#line 292 "WindowModule.cs"
#line 292 "WindowModule.cs"
    double csharp2cuda_temp_24 = *(value);
    return isfinite(csharp2cuda_temp_24);
}

#line 231 "WindowModule.cs"
__device__ double mathblocks_window_distance_row_means(
    const double* values,
    int count,
    double* row_means)
#line 236 "WindowModule.cs"
{
#line 237 "WindowModule.cs"
    double total_mean = 0.0;
#line 238 "WindowModule.cs"
    {
#line 238 "WindowModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 239 "WindowModule.cs"
            {
#line 240 "WindowModule.cs"
#line 240 "WindowModule.cs"
                double* csharp2cuda_temp_1 = &((row_means)[row]);
                (*(csharp2cuda_temp_1) = 0.0);
#line 241 "WindowModule.cs"
                {
#line 241 "WindowModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (count))))
                            break;
#line 242 "WindowModule.cs"
                        {
#line 243 "WindowModule.cs"
                            double csharp2cuda_temp_3 = (values)[row];
#line 243 "WindowModule.cs"
                            double csharp2cuda_temp_4 = (values)[column];
#line 243 "WindowModule.cs"
                            double distance = fabs(__dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4));
#line 244 "WindowModule.cs"
#line 244 "WindowModule.cs"
                            double* csharp2cuda_temp_5 = &((row_means)[row]);
#line 244 "WindowModule.cs"
                            double csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
                            (*(csharp2cuda_temp_5) = __dadd_rn(csharp2cuda_temp_6, distance));
#line 245 "WindowModule.cs"
#line 245 "WindowModule.cs"
                            double* csharp2cuda_temp_7 = &(total_mean);
#line 245 "WindowModule.cs"
                            double csharp2cuda_temp_8 = *(csharp2cuda_temp_7);
                            (*(csharp2cuda_temp_7) = __dadd_rn(csharp2cuda_temp_8, distance));
                        }
#line 241 "WindowModule.cs"
                        int* csharp2cuda_temp_2 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                    }
                }
#line 247 "WindowModule.cs"
#line 247 "WindowModule.cs"
                double* csharp2cuda_temp_9 = &((row_means)[row]);
#line 247 "WindowModule.cs"
                double csharp2cuda_temp_10 = *(csharp2cuda_temp_9);
                (*(csharp2cuda_temp_9) = __ddiv_rn(csharp2cuda_temp_10, ((double)(count))));
            }
#line 238 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 249 "WindowModule.cs"
#line 249 "WindowModule.cs"
    double* csharp2cuda_temp_11 = &(total_mean);
#line 249 "WindowModule.cs"
    double csharp2cuda_temp_12 = *(csharp2cuda_temp_11);
    (*(csharp2cuda_temp_11) = __ddiv_rn(csharp2cuda_temp_12, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 250 "WindowModule.cs"
    return total_mean;
}

#line 912 "WindowModule.cs"
__device__ void mathblocks_window_divide_by_integer(double h, double l, int width, double* qh, double* ql)
#line 914 "WindowModule.cs"
{
#line 915 "WindowModule.cs"
    double divisor = ((double)(width));
#line 916 "WindowModule.cs"
    double high = __ddiv_rn(h, divisor);
#line 917 "WindowModule.cs"
    double p = 0.0;
#line 918 "WindowModule.cs"
    double e = 0.0;
#line 919 "WindowModule.cs"
#line 919 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &(p);
#line 919 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(e);
    mathblocks_window_two_product(high, divisor, csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 920 "WindowModule.cs"
    double low = __ddiv_rn(__dadd_rn(__dsub_rn(__dsub_rn(h, p), e), l), divisor);
#line 921 "WindowModule.cs"
    mathblocks_window_fast_two_sum(high, low, qh, ql);
}

#line 659 "WindowModule.cs"
__device__ void mathblocks_window_exact_add(long long* accumulator, double value, int shift, bool subtract)
#line 661 "WindowModule.cs"
{
#line 662 "WindowModule.cs"
    if (((value) == (0.0)))
    {
#line 663 "WindowModule.cs"
        return;
    }
#line 664 "WindowModule.cs"
    int index = mathblocks_window_exact_add_to(accumulator, value, shift, subtract);
#line 665 "WindowModule.cs"
#line 665 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (accumulator)[282];
    if (((((long long)(index))) < (csharp2cuda_temp_0)))
    {
#line 666 "WindowModule.cs"
#line 666 "WindowModule.cs"
        long long* csharp2cuda_temp_1 = &((accumulator)[282]);
        (*(csharp2cuda_temp_1) = ((long long)(index)));
    }
#line 667 "WindowModule.cs"
#line 667 "WindowModule.cs"
    long long csharp2cuda_temp_2 = (accumulator)[283];
    if (((((long long)(csharp2cuda_i32_add(index, 2)))) > (csharp2cuda_temp_2)))
    {
#line 668 "WindowModule.cs"
#line 668 "WindowModule.cs"
        long long* csharp2cuda_temp_3 = &((accumulator)[283]);
        (*(csharp2cuda_temp_3) = ((long long)(csharp2cuda_i32_add(index, 2))));
    }
#line 669 "WindowModule.cs"
#line 669 "WindowModule.cs"
    long long* csharp2cuda_temp_4 = &((accumulator)[284]);
#line 669 "WindowModule.cs"
    long long csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
    (*(csharp2cuda_temp_4) = csharp2cuda_i64_add(csharp2cuda_temp_5, 1LL));
#line 670 "WindowModule.cs"
#line 670 "WindowModule.cs"
    long long csharp2cuda_temp_6 = (accumulator)[284];
    if (((csharp2cuda_temp_6) == (134217728LL)))
#line 671 "WindowModule.cs"
    {
#line 672 "WindowModule.cs"
#line 672 "WindowModule.cs"
        long long csharp2cuda_temp_7 = (accumulator)[282];
#line 672 "WindowModule.cs"
        long long csharp2cuda_temp_8 = (accumulator)[283];
        mathblocks_window_exact_carry(accumulator, csharp2cuda_i32_from_bits(csharp2cuda_temp_7), csharp2cuda_i32_from_bits(csharp2cuda_temp_8));
#line 673 "WindowModule.cs"
#line 673 "WindowModule.cs"
        long long* csharp2cuda_temp_9 = &((accumulator)[283]);
#line 673 "WindowModule.cs"
        long long csharp2cuda_temp_10 = *(csharp2cuda_temp_9);
        (*(csharp2cuda_temp_9) = csharp2cuda_i64_add(csharp2cuda_temp_10, 1LL));
#line 674 "WindowModule.cs"
#line 674 "WindowModule.cs"
        long long* csharp2cuda_temp_11 = &((accumulator)[284]);
        (*(csharp2cuda_temp_11) = 0LL);
    }
}

#line 702 "WindowModule.cs"
__device__ void mathblocks_window_exact_add_square(long long* accumulator, double value, bool subtract)
#line 704 "WindowModule.cs"
{
#line 705 "WindowModule.cs"
    if (((value) == (0.0)))
    {
#line 706 "WindowModule.cs"
        return;
    }
#line 707 "WindowModule.cs"
    double magnitude = fabs(value);
#line 708 "WindowModule.cs"
    double scaled = value;
#line 709 "WindowModule.cs"
    int shift = 0;
#line 710 "WindowModule.cs"
    if (((magnitude) < (mathblocks_window_power_of_two(csharp2cuda_i32_neg(400)))))
#line 711 "WindowModule.cs"
    {
#line 712 "WindowModule.cs"
#line 712 "WindowModule.cs"
        double* csharp2cuda_temp_0 = &(scaled);
        (*(csharp2cuda_temp_0) = __dmul_rn(value, mathblocks_window_power_of_two(600)));
#line 713 "WindowModule.cs"
#line 713 "WindowModule.cs"
        int* csharp2cuda_temp_1 = &(shift);
        (*(csharp2cuda_temp_1) = csharp2cuda_i32_neg(1200));
    }
    else
    {
#line 715 "WindowModule.cs"
        if (((magnitude) > (mathblocks_window_power_of_two(400))))
#line 716 "WindowModule.cs"
        {
#line 717 "WindowModule.cs"
#line 717 "WindowModule.cs"
            double* csharp2cuda_temp_2 = &(scaled);
            (*(csharp2cuda_temp_2) = __dmul_rn(value, mathblocks_window_power_of_two(csharp2cuda_i32_neg(600))));
#line 718 "WindowModule.cs"
#line 718 "WindowModule.cs"
            int* csharp2cuda_temp_3 = &(shift);
            (*(csharp2cuda_temp_3) = 1200);
        }
    }
#line 720 "WindowModule.cs"
    double product = 0.0;
#line 721 "WindowModule.cs"
    double error = 0.0;
#line 722 "WindowModule.cs"
#line 722 "WindowModule.cs"
    double* csharp2cuda_temp_4 = &(product);
#line 722 "WindowModule.cs"
    double* csharp2cuda_temp_5 = &(error);
    mathblocks_window_two_product(scaled, scaled, csharp2cuda_temp_4, csharp2cuda_temp_5);
#line 723 "WindowModule.cs"
    mathblocks_window_exact_add(accumulator, product, shift, subtract);
#line 724 "WindowModule.cs"
    mathblocks_window_exact_add(accumulator, error, shift, subtract);
}

#line 596 "WindowModule.cs"
__device__ int mathblocks_window_exact_add_to(long long* target, double value, int shift, bool subtract)
#line 598 "WindowModule.cs"
{
#line 599 "WindowModule.cs"
    long long bits = __double_as_longlong(value);
#line 600 "WindowModule.cs"
    bool negative = ((((bits) < (0LL))) != (subtract));
#line 601 "WindowModule.cs"
    int biased = csharp2cuda_i32_from_bits(csharp2cuda_i64_and(csharp2cuda_i64_shr(bits, 52), 2047LL));
#line 602 "WindowModule.cs"
    long long significand = csharp2cuda_i64_and(bits, 4503599627370495LL);
#line 603 "WindowModule.cs"
    int exponent;
#line 604 "WindowModule.cs"
    if (((biased) == (0)))
#line 605 "WindowModule.cs"
    {
#line 606 "WindowModule.cs"
#line 606 "WindowModule.cs"
        int* csharp2cuda_temp_0 = &(exponent);
        (*(csharp2cuda_temp_0) = csharp2cuda_i32_neg(1074));
    }
    else
#line 609 "WindowModule.cs"
    {
#line 610 "WindowModule.cs"
#line 610 "WindowModule.cs"
        long long* csharp2cuda_temp_1 = &(significand);
#line 610 "WindowModule.cs"
        long long csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
        (*(csharp2cuda_temp_1) = csharp2cuda_i64_or(csharp2cuda_temp_2, csharp2cuda_i64_shl(1LL, 52)));
#line 611 "WindowModule.cs"
#line 611 "WindowModule.cs"
        int* csharp2cuda_temp_3 = &(exponent);
        (*(csharp2cuda_temp_3) = csharp2cuda_i32_sub(biased, 1075));
    }
#line 613 "WindowModule.cs"
    int position = csharp2cuda_i32_add(csharp2cuda_i32_add(exponent, shift), 2208);
#line 614 "WindowModule.cs"
    int index = csharp2cuda_i32_shr(position, 5);
#line 615 "WindowModule.cs"
    int offset = csharp2cuda_i32_and(position, 31);
#line 616 "WindowModule.cs"
    long long low_part = csharp2cuda_i64_shl(csharp2cuda_i64_and(significand, 4294967295LL), offset);
#line 617 "WindowModule.cs"
    long long high_part = csharp2cuda_i64_shl(csharp2cuda_i64_shr(significand, 32), offset);
#line 618 "WindowModule.cs"
    long long first = csharp2cuda_i64_and(low_part, 4294967295LL);
#line 619 "WindowModule.cs"
    long long second = csharp2cuda_i64_add(csharp2cuda_i64_shr(low_part, 32), csharp2cuda_i64_and(high_part, 4294967295LL));
#line 620 "WindowModule.cs"
    long long third = csharp2cuda_i64_shr(high_part, 32);
#line 621 "WindowModule.cs"
    if (negative)
#line 622 "WindowModule.cs"
    {
#line 623 "WindowModule.cs"
#line 623 "WindowModule.cs"
        long long* csharp2cuda_temp_4 = &((target)[index]);
#line 623 "WindowModule.cs"
        long long csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
        (*(csharp2cuda_temp_4) = csharp2cuda_i64_sub(csharp2cuda_temp_5, first));
#line 624 "WindowModule.cs"
#line 624 "WindowModule.cs"
        long long* csharp2cuda_temp_6 = &((target)[csharp2cuda_i32_add(index, 1)]);
#line 624 "WindowModule.cs"
        long long csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
        (*(csharp2cuda_temp_6) = csharp2cuda_i64_sub(csharp2cuda_temp_7, second));
#line 625 "WindowModule.cs"
#line 625 "WindowModule.cs"
        long long* csharp2cuda_temp_8 = &((target)[csharp2cuda_i32_add(index, 2)]);
#line 625 "WindowModule.cs"
        long long csharp2cuda_temp_9 = *(csharp2cuda_temp_8);
        (*(csharp2cuda_temp_8) = csharp2cuda_i64_sub(csharp2cuda_temp_9, third));
    }
    else
#line 628 "WindowModule.cs"
    {
#line 629 "WindowModule.cs"
#line 629 "WindowModule.cs"
        long long* csharp2cuda_temp_10 = &((target)[index]);
#line 629 "WindowModule.cs"
        long long csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
        (*(csharp2cuda_temp_10) = csharp2cuda_i64_add(csharp2cuda_temp_11, first));
#line 630 "WindowModule.cs"
#line 630 "WindowModule.cs"
        long long* csharp2cuda_temp_12 = &((target)[csharp2cuda_i32_add(index, 1)]);
#line 630 "WindowModule.cs"
        long long csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
        (*(csharp2cuda_temp_12) = csharp2cuda_i64_add(csharp2cuda_temp_13, second));
#line 631 "WindowModule.cs"
#line 631 "WindowModule.cs"
        long long* csharp2cuda_temp_14 = &((target)[csharp2cuda_i32_add(index, 2)]);
#line 631 "WindowModule.cs"
        long long csharp2cuda_temp_15 = *(csharp2cuda_temp_14);
        (*(csharp2cuda_temp_14) = csharp2cuda_i64_add(csharp2cuda_temp_15, third));
    }
#line 633 "WindowModule.cs"
    return index;
}

#line 763 "WindowModule.cs"
__device__ bool mathblocks_window_exact_any_below(const long long* value, int lowest, int position)
#line 765 "WindowModule.cs"
{
#line 766 "WindowModule.cs"
    int relative = csharp2cuda_i32_add(position, 2208);
#line 767 "WindowModule.cs"
    int index = csharp2cuda_i32_shr(relative, 5);
#line 768 "WindowModule.cs"
    int offset = csharp2cuda_i32_and(relative, 31);
#line 769 "WindowModule.cs"
#line 769 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (value)[index];
    if (((csharp2cuda_i64_and(csharp2cuda_temp_0, csharp2cuda_i64_sub(csharp2cuda_i64_shl(1LL, offset), 1LL))) != (0LL)))
    {
#line 770 "WindowModule.cs"
        return true;
    }
#line 771 "WindowModule.cs"
    {
#line 771 "WindowModule.cs"
        int chunk = lowest;
        while (true)
        {
            if (!(((chunk) < (index))))
                break;
#line 772 "WindowModule.cs"
#line 772 "WindowModule.cs"
            long long csharp2cuda_temp_2 = (value)[chunk];
            if (((csharp2cuda_temp_2) != (0LL)))
            {
#line 773 "WindowModule.cs"
                return true;
            }
#line 771 "WindowModule.cs"
            int* csharp2cuda_temp_1 = &(chunk);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 774 "WindowModule.cs"
    return false;
}

#line 749 "WindowModule.cs"
__device__ long long mathblocks_window_exact_bits(const long long* value, int position, int count)
#line 751 "WindowModule.cs"
{
#line 752 "WindowModule.cs"
    int relative = csharp2cuda_i32_add(position, 2208);
#line 753 "WindowModule.cs"
    int index = csharp2cuda_i32_shr(relative, 5);
#line 754 "WindowModule.cs"
    int offset = csharp2cuda_i32_and(relative, 31);
#line 755 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (value)[index];
#line 755 "WindowModule.cs"
    long long csharp2cuda_temp_1 = (value)[csharp2cuda_i32_add(index, 1)];
#line 755 "WindowModule.cs"
    unsigned long long word = ((((unsigned long long)(csharp2cuda_temp_0))) | (csharp2cuda_u64_shl(((unsigned long long)(csharp2cuda_temp_1)), 32)));
#line 756 "WindowModule.cs"
    unsigned long long result = csharp2cuda_u64_shr(word, offset);
#line 757 "WindowModule.cs"
    if (((offset) != (0)))
    {
#line 758 "WindowModule.cs"
#line 758 "WindowModule.cs"
        unsigned long long* csharp2cuda_temp_2 = &(result);
#line 758 "WindowModule.cs"
        unsigned long long csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 758 "WindowModule.cs"
        long long csharp2cuda_temp_4 = (value)[csharp2cuda_i32_add(index, 2)];
        (*(csharp2cuda_temp_2) = ((csharp2cuda_temp_3) | (csharp2cuda_u64_shl(((unsigned long long)(csharp2cuda_temp_4)), csharp2cuda_i32_sub(64, offset)))));
    }
#line 759 "WindowModule.cs"
    return csharp2cuda_i64_from_bits(((result) & (((csharp2cuda_u64_shl(1ull, count)) - (1ull)))));
}

#line 638 "WindowModule.cs"
__device__ long long mathblocks_window_exact_carry(long long* target, int first, int last)
#line 640 "WindowModule.cs"
{
#line 641 "WindowModule.cs"
    long long carry = 0LL;
#line 642 "WindowModule.cs"
    {
#line 642 "WindowModule.cs"
        int index = first;
        while (true)
        {
            if (!(((index) <= (last))))
                break;
#line 643 "WindowModule.cs"
            {
#line 644 "WindowModule.cs"
                long long csharp2cuda_temp_1 = (target)[index];
#line 644 "WindowModule.cs"
                long long current = csharp2cuda_i64_add(csharp2cuda_temp_1, carry);
#line 645 "WindowModule.cs"
#line 645 "WindowModule.cs"
                long long* csharp2cuda_temp_2 = &(carry);
                (*(csharp2cuda_temp_2) = csharp2cuda_i64_shr(current, 32));
#line 646 "WindowModule.cs"
#line 646 "WindowModule.cs"
                long long* csharp2cuda_temp_3 = &((target)[index]);
                (*(csharp2cuda_temp_3) = csharp2cuda_i64_and(current, 4294967295LL));
            }
#line 642 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 648 "WindowModule.cs"
#line 648 "WindowModule.cs"
    long long* csharp2cuda_temp_4 = &((target)[csharp2cuda_i32_add(last, 1)]);
#line 648 "WindowModule.cs"
    long long csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
    (*(csharp2cuda_temp_4) = csharp2cuda_i64_add(csharp2cuda_temp_5, carry));
#line 649 "WindowModule.cs"
    return (target)[csharp2cuda_i32_add(last, 1)];
}

#line 585 "WindowModule.cs"
__device__ void mathblocks_window_exact_clear(long long* accumulator)
#line 587 "WindowModule.cs"
{
#line 588 "WindowModule.cs"
    {
#line 588 "WindowModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (282))))
                break;
#line 589 "WindowModule.cs"
#line 589 "WindowModule.cs"
            long long* csharp2cuda_temp_1 = &((accumulator)[index]);
            (*(csharp2cuda_temp_1) = 0LL);
#line 588 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 590 "WindowModule.cs"
#line 590 "WindowModule.cs"
    long long* csharp2cuda_temp_2 = &((accumulator)[282]);
    (*(csharp2cuda_temp_2) = 141LL);
#line 591 "WindowModule.cs"
#line 591 "WindowModule.cs"
    long long* csharp2cuda_temp_3 = &((accumulator)[283]);
    (*(csharp2cuda_temp_3) = csharp2cuda_i64_neg(1LL));
#line 592 "WindowModule.cs"
#line 592 "WindowModule.cs"
    long long* csharp2cuda_temp_4 = &((accumulator)[284]);
    (*(csharp2cuda_temp_4) = 0LL);
}

#line 729 "WindowModule.cs"
__device__ int mathblocks_window_exact_load(long long* accumulator, bool* negative)
#line 731 "WindowModule.cs"
{
#line 732 "WindowModule.cs"
    long long* scratch = csharp2cuda_pointer_add(accumulator, 141);
#line 733 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (accumulator)[282];
#line 733 "WindowModule.cs"
    int lowest = csharp2cuda_i32_from_bits(csharp2cuda_temp_0);
#line 734 "WindowModule.cs"
    long long csharp2cuda_temp_1 = (accumulator)[283];
#line 734 "WindowModule.cs"
    int highest = csharp2cuda_i32_from_bits(csharp2cuda_temp_1);
#line 735 "WindowModule.cs"
    {
#line 735 "WindowModule.cs"
        int index = lowest;
        while (true)
        {
            if (!(((index) <= (highest))))
                break;
#line 736 "WindowModule.cs"
#line 736 "WindowModule.cs"
            long long* csharp2cuda_temp_3 = &((scratch)[index]);
#line 736 "WindowModule.cs"
            long long csharp2cuda_temp_4 = (accumulator)[index];
            (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 735 "WindowModule.cs"
            int* csharp2cuda_temp_2 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 737 "WindowModule.cs"
    {
#line 737 "WindowModule.cs"
        int index = csharp2cuda_i32_add(highest, 1);
        while (true)
        {
            if (!(((index) <= (csharp2cuda_i32_add(highest, 4)))))
                break;
#line 738 "WindowModule.cs"
#line 738 "WindowModule.cs"
            long long* csharp2cuda_temp_6 = &((scratch)[index]);
            (*(csharp2cuda_temp_6) = 0LL);
#line 737 "WindowModule.cs"
            int* csharp2cuda_temp_5 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
        }
    }
#line 739 "WindowModule.cs"
#line 739 "WindowModule.cs"
    bool* csharp2cuda_temp_7 = negative;
#line 739 "WindowModule.cs"
    long long csharp2cuda_temp_8 = mathblocks_window_exact_carry(scratch, lowest, highest);
    (*(csharp2cuda_temp_7) = ((csharp2cuda_temp_8) < (0LL)));
#line 740 "WindowModule.cs"
    if (*(negative))
#line 741 "WindowModule.cs"
    {
#line 742 "WindowModule.cs"
        mathblocks_window_exact_negate(scratch, lowest, csharp2cuda_i32_add(highest, 1));
#line 743 "WindowModule.cs"
        mathblocks_window_exact_carry(scratch, lowest, csharp2cuda_i32_add(highest, 1));
    }
#line 745 "WindowModule.cs"
    return csharp2cuda_i32_add(highest, 1);
}

#line 652 "WindowModule.cs"
__device__ void mathblocks_window_exact_negate(long long* target, int first, int last)
#line 654 "WindowModule.cs"
{
#line 655 "WindowModule.cs"
    {
#line 655 "WindowModule.cs"
        int index = first;
        while (true)
        {
            if (!(((index) <= (last))))
                break;
#line 656 "WindowModule.cs"
#line 656 "WindowModule.cs"
            long long* csharp2cuda_temp_1 = &((target)[index]);
#line 656 "WindowModule.cs"
            long long csharp2cuda_temp_2 = (target)[index];
            (*(csharp2cuda_temp_1) = csharp2cuda_i64_neg(csharp2cuda_temp_2));
#line 655 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 815 "WindowModule.cs"
__device__ void mathblocks_window_exact_read_pair(long long* accumulator, double* high, double* low, bool* zero)
#line 817 "WindowModule.cs"
{
#line 818 "WindowModule.cs"
#line 818 "WindowModule.cs"
    double* csharp2cuda_temp_0 = high;
    (*(csharp2cuda_temp_0) = 0.0);
#line 819 "WindowModule.cs"
#line 819 "WindowModule.cs"
    double* csharp2cuda_temp_1 = low;
    (*(csharp2cuda_temp_1) = 0.0);
#line 820 "WindowModule.cs"
#line 820 "WindowModule.cs"
    bool* csharp2cuda_temp_2 = zero;
    (*(csharp2cuda_temp_2) = true);
#line 821 "WindowModule.cs"
#line 821 "WindowModule.cs"
    long long csharp2cuda_temp_3 = (accumulator)[283];
    if (((csharp2cuda_temp_3) < (0LL)))
    {
#line 822 "WindowModule.cs"
        return;
    }
#line 823 "WindowModule.cs"
    long long* scratch = csharp2cuda_pointer_add(accumulator, 141);
#line 824 "WindowModule.cs"
    long long csharp2cuda_temp_4 = (accumulator)[282];
#line 824 "WindowModule.cs"
    int lowest = csharp2cuda_i32_from_bits(csharp2cuda_temp_4);
#line 825 "WindowModule.cs"
    bool negative = false;
#line 826 "WindowModule.cs"
    bool* csharp2cuda_temp_5 = &(negative);
#line 826 "WindowModule.cs"
    int top = mathblocks_window_exact_load(accumulator, csharp2cuda_temp_5);
#line 827 "WindowModule.cs"
    {
#line 827 "WindowModule.cs"
        int index = lowest;
        while (true)
        {
            if (!(((index) <= (top))))
                break;
#line 828 "WindowModule.cs"
#line 828 "WindowModule.cs"
            long long csharp2cuda_temp_7 = (scratch)[index];
            if (((csharp2cuda_temp_7) != (0LL)))
            {
#line 829 "WindowModule.cs"
#line 829 "WindowModule.cs"
                bool* csharp2cuda_temp_8 = zero;
                (*(csharp2cuda_temp_8) = false);
            }
#line 827 "WindowModule.cs"
            int* csharp2cuda_temp_6 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
        }
    }
#line 830 "WindowModule.cs"
#line 830 "WindowModule.cs"
    double* csharp2cuda_temp_9 = high;
#line 830 "WindowModule.cs"
    double csharp2cuda_temp_10 = mathblocks_window_exact_round(scratch, lowest, top, false);
    (*(csharp2cuda_temp_9) = csharp2cuda_temp_10);
#line 831 "WindowModule.cs"
#line 831 "WindowModule.cs"
    double csharp2cuda_temp_11 = *(high);
    if ((!(isfinite(csharp2cuda_temp_11))))
#line 832 "WindowModule.cs"
    {
#line 833 "WindowModule.cs"
#line 833 "WindowModule.cs"
        double* csharp2cuda_temp_12 = high;
#line 833 "WindowModule.cs"
        double csharp2cuda_temp_13;
#line 833 "WindowModule.cs"
        if (negative)
        {
#line 833 "WindowModule.cs"
            double csharp2cuda_temp_14 = *(high);
#line 833 "WindowModule.cs"
            csharp2cuda_temp_13 = (-(csharp2cuda_temp_14));
        }
        else
        {
#line 833 "WindowModule.cs"
            csharp2cuda_temp_13 = *(high);
        }
        (*(csharp2cuda_temp_12) = csharp2cuda_temp_13);
#line 834 "WindowModule.cs"
        return;
    }
#line 836 "WindowModule.cs"
#line 836 "WindowModule.cs"
    double csharp2cuda_temp_15 = *(high);
    mathblocks_window_exact_add_to(scratch, csharp2cuda_temp_15, 0, true);
#line 837 "WindowModule.cs"
    long long csharp2cuda_temp_16 = mathblocks_window_exact_carry(scratch, lowest, top);
#line 837 "WindowModule.cs"
    bool rest_negative = ((csharp2cuda_temp_16) < (0LL));
#line 838 "WindowModule.cs"
    if (rest_negative)
#line 839 "WindowModule.cs"
    {
#line 840 "WindowModule.cs"
        mathblocks_window_exact_negate(scratch, lowest, csharp2cuda_i32_add(top, 1));
#line 841 "WindowModule.cs"
        mathblocks_window_exact_carry(scratch, lowest, csharp2cuda_i32_add(top, 1));
    }
#line 843 "WindowModule.cs"
#line 843 "WindowModule.cs"
    double* csharp2cuda_temp_17 = low;
#line 843 "WindowModule.cs"
    double csharp2cuda_temp_18 = mathblocks_window_exact_round(scratch, lowest, csharp2cuda_i32_add(top, 1), false);
    (*(csharp2cuda_temp_17) = csharp2cuda_temp_18);
#line 844 "WindowModule.cs"
    if (rest_negative)
    {
#line 845 "WindowModule.cs"
#line 845 "WindowModule.cs"
        double* csharp2cuda_temp_19 = low;
#line 845 "WindowModule.cs"
        double csharp2cuda_temp_20 = *(low);
        (*(csharp2cuda_temp_19) = (-(csharp2cuda_temp_20)));
    }
#line 846 "WindowModule.cs"
    if (negative)
#line 847 "WindowModule.cs"
    {
#line 848 "WindowModule.cs"
#line 848 "WindowModule.cs"
        double* csharp2cuda_temp_21 = high;
#line 848 "WindowModule.cs"
        double csharp2cuda_temp_22 = *(high);
        (*(csharp2cuda_temp_21) = (-(csharp2cuda_temp_22)));
#line 849 "WindowModule.cs"
#line 849 "WindowModule.cs"
        double* csharp2cuda_temp_23 = low;
#line 849 "WindowModule.cs"
        double csharp2cuda_temp_24 = *(low);
        (*(csharp2cuda_temp_23) = (-(csharp2cuda_temp_24)));
    }
}

#line 856 "WindowModule.cs"
__device__ double mathblocks_window_exact_read_quotient(long long* accumulator, int divisor)
#line 858 "WindowModule.cs"
{
#line 859 "WindowModule.cs"
#line 859 "WindowModule.cs"
    long long csharp2cuda_temp_0 = (accumulator)[283];
    if (((csharp2cuda_temp_0) < (0LL)))
    {
#line 860 "WindowModule.cs"
        return 0.0;
    }
#line 861 "WindowModule.cs"
    long long* scratch = csharp2cuda_pointer_add(accumulator, 141);
#line 862 "WindowModule.cs"
    long long csharp2cuda_temp_1 = (accumulator)[282];
#line 862 "WindowModule.cs"
    int lowest = csharp2cuda_i32_from_bits(csharp2cuda_temp_1);
#line 863 "WindowModule.cs"
    bool negative = false;
#line 864 "WindowModule.cs"
    bool* csharp2cuda_temp_2 = &(negative);
#line 864 "WindowModule.cs"
    int top = mathblocks_window_exact_load(accumulator, csharp2cuda_temp_2);
#line 865 "WindowModule.cs"
    int leading = top;
#line 866 "WindowModule.cs"
    while (true)
    {
#line 866 "WindowModule.cs"
        bool csharp2cuda_temp_3;
#line 866 "WindowModule.cs"
        if (((leading) > (lowest)))
        {
#line 866 "WindowModule.cs"
            long long csharp2cuda_temp_4 = (scratch)[leading];
#line 866 "WindowModule.cs"
            csharp2cuda_temp_3 = ((csharp2cuda_temp_4) == (0LL));
        }
        else
        {
#line 866 "WindowModule.cs"
            csharp2cuda_temp_3 = false;
        }
        if (!(csharp2cuda_temp_3))
            break;
#line 867 "WindowModule.cs"
#line 867 "WindowModule.cs"
        int* csharp2cuda_temp_5 = &(leading);
        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_5));
    }
#line 868 "WindowModule.cs"
    int csharp2cuda_temp_6;
#line 868 "WindowModule.cs"
    if (((csharp2cuda_i32_sub(leading, 4)) < (lowest)))
    {
#line 868 "WindowModule.cs"
        csharp2cuda_temp_6 = csharp2cuda_i32_sub(leading, 4);
    }
    else
    {
#line 868 "WindowModule.cs"
        csharp2cuda_temp_6 = lowest;
    }
#line 868 "WindowModule.cs"
    int start = csharp2cuda_temp_6;
#line 869 "WindowModule.cs"
    if (((start) < (0)))
    {
#line 870 "WindowModule.cs"
#line 870 "WindowModule.cs"
        int* csharp2cuda_temp_7 = &(start);
        (*(csharp2cuda_temp_7) = 0);
    }
#line 871 "WindowModule.cs"
    long long remainder = 0LL;
#line 872 "WindowModule.cs"
    {
#line 872 "WindowModule.cs"
        int index = csharp2cuda_i32_add(top, 1);
        while (true)
        {
            if (!(((index) >= (start))))
                break;
#line 873 "WindowModule.cs"
            {
#line 874 "WindowModule.cs"
                long long csharp2cuda_temp_9 = (scratch)[index];
#line 874 "WindowModule.cs"
                long long current = csharp2cuda_i64_or(csharp2cuda_i64_shl(remainder, 32), csharp2cuda_temp_9);
#line 875 "WindowModule.cs"
#line 875 "WindowModule.cs"
                long long* csharp2cuda_temp_10 = &((scratch)[index]);
#line 875 "WindowModule.cs"
                long long csharp2cuda_temp_11 = csharp2cuda_i64_div(current, ((long long)(divisor)));
                (*(csharp2cuda_temp_10) = csharp2cuda_temp_11);
#line 876 "WindowModule.cs"
#line 876 "WindowModule.cs"
                long long* csharp2cuda_temp_12 = &(remainder);
#line 876 "WindowModule.cs"
                long long csharp2cuda_temp_13 = csharp2cuda_i64_rem(current, ((long long)(divisor)));
                (*(csharp2cuda_temp_12) = csharp2cuda_temp_13);
            }
#line 872 "WindowModule.cs"
            int* csharp2cuda_temp_8 = &(index);
            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_8));
        }
    }
#line 878 "WindowModule.cs"
    double result = mathblocks_window_exact_round(scratch, start, csharp2cuda_i32_add(top, 1), ((remainder) != (0LL)));
#line 879 "WindowModule.cs"
    {
#line 879 "WindowModule.cs"
        int index = start;
        while (true)
        {
            if (!(((index) < (lowest))))
                break;
#line 880 "WindowModule.cs"
#line 880 "WindowModule.cs"
            long long* csharp2cuda_temp_15 = &((scratch)[index]);
            (*(csharp2cuda_temp_15) = 0LL);
#line 879 "WindowModule.cs"
            int* csharp2cuda_temp_14 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_14));
        }
    }
#line 881 "WindowModule.cs"
#line 881 "WindowModule.cs"
    double csharp2cuda_temp_16;
#line 881 "WindowModule.cs"
    if (negative)
    {
#line 881 "WindowModule.cs"
        csharp2cuda_temp_16 = (-(result));
    }
    else
    {
#line 881 "WindowModule.cs"
        csharp2cuda_temp_16 = result;
    }
    return csharp2cuda_temp_16;
}

#line 779 "WindowModule.cs"
__device__ double mathblocks_window_exact_round(const long long* value, int lowest, int top, bool sticky)
#line 781 "WindowModule.cs"
{
#line 782 "WindowModule.cs"
    int chunk = top;
#line 783 "WindowModule.cs"
    while (true)
    {
#line 783 "WindowModule.cs"
        bool csharp2cuda_temp_0;
#line 783 "WindowModule.cs"
        if (((chunk) >= (lowest)))
        {
#line 783 "WindowModule.cs"
            long long csharp2cuda_temp_1 = (value)[chunk];
#line 783 "WindowModule.cs"
            csharp2cuda_temp_0 = ((csharp2cuda_temp_1) == (0LL));
        }
        else
        {
#line 783 "WindowModule.cs"
            csharp2cuda_temp_0 = false;
        }
        if (!(csharp2cuda_temp_0))
            break;
#line 784 "WindowModule.cs"
#line 784 "WindowModule.cs"
        int* csharp2cuda_temp_2 = &(chunk);
        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_2));
    }
#line 785 "WindowModule.cs"
    if (((chunk) < (lowest)))
    {
#line 786 "WindowModule.cs"
        return 0.0;
    }
#line 787 "WindowModule.cs"
    int bit = 31;
#line 788 "WindowModule.cs"
    while (true)
    {
#line 788 "WindowModule.cs"
        long long csharp2cuda_temp_3 = (value)[chunk];
        if (!(((csharp2cuda_i64_and(csharp2cuda_i64_shr(csharp2cuda_temp_3, bit), 1LL)) == (0LL))))
            break;
#line 789 "WindowModule.cs"
#line 789 "WindowModule.cs"
        int* csharp2cuda_temp_4 = &(bit);
        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_4));
    }
#line 790 "WindowModule.cs"
    int most = csharp2cuda_i32_add(csharp2cuda_i32_add(csharp2cuda_i32_neg(2208), csharp2cuda_i32_mul(32, chunk)), bit);
#line 791 "WindowModule.cs"
    int csharp2cuda_temp_5;
#line 791 "WindowModule.cs"
    if (((csharp2cuda_i32_sub(most, 52)) < (csharp2cuda_i32_neg(1074))))
    {
#line 791 "WindowModule.cs"
        csharp2cuda_temp_5 = csharp2cuda_i32_neg(1074);
    }
    else
    {
#line 791 "WindowModule.cs"
        csharp2cuda_temp_5 = csharp2cuda_i32_sub(most, 52);
    }
#line 791 "WindowModule.cs"
    int least = csharp2cuda_temp_5;
#line 792 "WindowModule.cs"
    int count = csharp2cuda_i32_add(csharp2cuda_i32_sub(most, least), 1);
#line 793 "WindowModule.cs"
    long long csharp2cuda_temp_6;
#line 793 "WindowModule.cs"
    if (((count) > (0)))
    {
#line 793 "WindowModule.cs"
        csharp2cuda_temp_6 = mathblocks_window_exact_bits(value, least, count);
    }
    else
    {
#line 793 "WindowModule.cs"
        csharp2cuda_temp_6 = 0LL;
    }
#line 793 "WindowModule.cs"
    long long significand = csharp2cuda_temp_6;
#line 794 "WindowModule.cs"
    long long csharp2cuda_temp_7 = mathblocks_window_exact_bits(value, csharp2cuda_i32_sub(least, 1), 1);
#line 794 "WindowModule.cs"
    bool round = ((csharp2cuda_temp_7) != (0LL));
#line 795 "WindowModule.cs"
    bool csharp2cuda_temp_8;
#line 795 "WindowModule.cs"
    if (!(sticky))
    {
#line 795 "WindowModule.cs"
        csharp2cuda_temp_8 = mathblocks_window_exact_any_below(value, lowest, csharp2cuda_i32_sub(least, 1));
    }
    else
    {
#line 795 "WindowModule.cs"
        csharp2cuda_temp_8 = true;
    }
#line 795 "WindowModule.cs"
    bool below = csharp2cuda_temp_8;
#line 796 "WindowModule.cs"
#line 796 "WindowModule.cs"
    bool csharp2cuda_temp_9;
#line 796 "WindowModule.cs"
    if (round)
    {
#line 796 "WindowModule.cs"
        bool csharp2cuda_temp_10;
#line 796 "WindowModule.cs"
        if (!(below))
        {
#line 796 "WindowModule.cs"
            csharp2cuda_temp_10 = ((csharp2cuda_i64_and(significand, 1LL)) != (0LL));
        }
        else
        {
#line 796 "WindowModule.cs"
            csharp2cuda_temp_10 = true;
        }
#line 796 "WindowModule.cs"
        csharp2cuda_temp_9 = csharp2cuda_temp_10;
    }
    else
    {
#line 796 "WindowModule.cs"
        csharp2cuda_temp_9 = false;
    }
    if (csharp2cuda_temp_9)
    {
#line 797 "WindowModule.cs"
#line 797 "WindowModule.cs"
        long long* csharp2cuda_temp_11 = &(significand);
        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_11));
    }
#line 798 "WindowModule.cs"
    if (((significand) == (csharp2cuda_i64_shl(1LL, 53))))
#line 799 "WindowModule.cs"
    {
#line 800 "WindowModule.cs"
#line 800 "WindowModule.cs"
        long long* csharp2cuda_temp_12 = &(significand);
        (*(csharp2cuda_temp_12) = csharp2cuda_i64_shl(1LL, 52));
#line 801 "WindowModule.cs"
#line 801 "WindowModule.cs"
        int* csharp2cuda_temp_13 = &(least);
        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
    }
#line 803 "WindowModule.cs"
    if (((significand) >= (csharp2cuda_i64_shl(1LL, 52))))
#line 804 "WindowModule.cs"
    {
#line 805 "WindowModule.cs"
        int biased = csharp2cuda_i32_add(least, 1075);
#line 806 "WindowModule.cs"
        if (((biased) >= (2047)))
        {
#line 807 "WindowModule.cs"
            return __longlong_as_double(9218868437227405312LL);
        }
#line 808 "WindowModule.cs"
        return __longlong_as_double(csharp2cuda_i64_or(csharp2cuda_i64_shl(((long long)(biased)), 52), csharp2cuda_i64_sub(significand, csharp2cuda_i64_shl(1LL, 52))));
    }
#line 810 "WindowModule.cs"
    return __longlong_as_double(significand);
}

#line 893 "WindowModule.cs"
__device__ void mathblocks_window_fast_two_sum(double a, double b, double* s, double* e)
#line 895 "WindowModule.cs"
{
#line 896 "WindowModule.cs"
#line 896 "WindowModule.cs"
    double* csharp2cuda_temp_0 = s;
    (*(csharp2cuda_temp_0) = __dadd_rn(a, b));
#line 897 "WindowModule.cs"
#line 897 "WindowModule.cs"
    double* csharp2cuda_temp_1 = e;
#line 897 "WindowModule.cs"
    double csharp2cuda_temp_2 = *(s);
    (*(csharp2cuda_temp_1) = __dsub_rn(b, __dsub_rn(csharp2cuda_temp_2, a)));
}

#line 946 "WindowModule.cs"
__device__ bool mathblocks_window_in_range(double value, double largest)
#line 948 "WindowModule.cs"
{
#line 949 "WindowModule.cs"
#line 949 "WindowModule.cs"
    bool csharp2cuda_temp_0;
#line 949 "WindowModule.cs"
    if (!(((value) == (0.0))))
    {
#line 950 "WindowModule.cs"
        bool csharp2cuda_temp_1;
#line 950 "WindowModule.cs"
        if (((fabs(value)) >= (mathblocks_window_power_of_two(csharp2cuda_i32_neg(968)))))
        {
#line 950 "WindowModule.cs"
            csharp2cuda_temp_1 = ((fabs(value)) <= (largest));
        }
        else
        {
#line 950 "WindowModule.cs"
            csharp2cuda_temp_1 = false;
        }
#line 949 "WindowModule.cs"
        csharp2cuda_temp_0 = csharp2cuda_temp_1;
    }
    else
    {
#line 949 "WindowModule.cs"
        csharp2cuda_temp_0 = true;
    }
    return csharp2cuda_temp_0;
}

#line 579 "WindowModule.cs"
__device__ double mathblocks_window_power_of_two(int exponent)
#line 581 "WindowModule.cs"
{
#line 582 "WindowModule.cs"
    return __longlong_as_double(csharp2cuda_i64_shl(((long long)(csharp2cuda_i32_add(exponent, 1023))), 52));
}

#line 1126 "WindowModule.cs"
__device__ void mathblocks_window_publish(MathBlockSlot* output, bool valid, int count, int thread)
#line 1128 "WindowModule.cs"
{
#line 1129 "WindowModule.cs"
    if (((thread) != (0)))
    {
#line 1130 "WindowModule.cs"
        return;
    }
#line 1131 "WindowModule.cs"
#line 1131 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &((output)->scalar_value);
    (*(csharp2cuda_temp_0) = 0.0);
#line 1132 "WindowModule.cs"
#line 1132 "WindowModule.cs"
    int* csharp2cuda_temp_1 = &((output)->boolean_value);
    (*(csharp2cuda_temp_1) = 0);
#line 1133 "WindowModule.cs"
#line 1133 "WindowModule.cs"
    int* csharp2cuda_temp_2 = &((output)->columns);
    (*(csharp2cuda_temp_2) = 0);
#line 1134 "WindowModule.cs"
#line 1134 "WindowModule.cs"
    int* csharp2cuda_temp_3 = &((output)->rows);
#line 1134 "WindowModule.cs"
    int csharp2cuda_temp_4;
#line 1134 "WindowModule.cs"
    if (valid)
    {
#line 1134 "WindowModule.cs"
        csharp2cuda_temp_4 = count;
    }
    else
    {
#line 1134 "WindowModule.cs"
        csharp2cuda_temp_4 = 0;
    }
    (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 1135 "WindowModule.cs"
#line 1135 "WindowModule.cs"
    int* csharp2cuda_temp_5 = &((output)->count);
#line 1135 "WindowModule.cs"
    int csharp2cuda_temp_6;
#line 1135 "WindowModule.cs"
    if (valid)
    {
#line 1135 "WindowModule.cs"
        csharp2cuda_temp_6 = count;
    }
    else
    {
#line 1135 "WindowModule.cs"
        csharp2cuda_temp_6 = 0;
    }
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 1136 "WindowModule.cs"
#line 1136 "WindowModule.cs"
    int* csharp2cuda_temp_7 = &((output)->valid);
    (*(csharp2cuda_temp_7) = valid);
}

#line 1142 "WindowModule.cs"
__device__ void mathblocks_window_run(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output,
    int thread,
    int threads,
    int scratch_capacity)
#line 1151 "WindowModule.cs"
{
#line 1152 "WindowModule.cs"
    int source = csharp2cuda_i32_div(opcode, 2);
#line 1153 "WindowModule.cs"
    int csharp2cuda_temp_0 = csharp2cuda_i32_rem(opcode, 2);
#line 1153 "WindowModule.cs"
    bool sibling = ((csharp2cuda_temp_0) != (0));
#line 1154 "WindowModule.cs"
    int arity = mathblocks_window_source_arity(source);
#line 1155 "WindowModule.cs"
    int series = mathblocks_window_series_count(source);
#line 1156 "WindowModule.cs"
    bool csharp2cuda_temp_1;
#line 1156 "WindowModule.cs"
    if (((opcode) >= (0)))
    {
#line 1156 "WindowModule.cs"
        csharp2cuda_temp_1 = ((source) < (59));
    }
    else
    {
#line 1156 "WindowModule.cs"
        csharp2cuda_temp_1 = false;
    }
#line 1156 "WindowModule.cs"
    bool csharp2cuda_temp_2;
#line 1156 "WindowModule.cs"
    if (csharp2cuda_temp_1)
    {
#line 1156 "WindowModule.cs"
        int csharp2cuda_temp_3;
#line 1156 "WindowModule.cs"
        if (sibling)
        {
#line 1156 "WindowModule.cs"
            csharp2cuda_temp_3 = 1;
        }
        else
        {
#line 1156 "WindowModule.cs"
            csharp2cuda_temp_3 = 2;
        }
#line 1156 "WindowModule.cs"
        csharp2cuda_temp_2 = ((input_count) == (csharp2cuda_i32_add(arity, csharp2cuda_temp_3)));
    }
    else
    {
#line 1156 "WindowModule.cs"
        csharp2cuda_temp_2 = false;
    }
#line 1156 "WindowModule.cs"
    bool valid = csharp2cuda_temp_2;
#line 1157 "WindowModule.cs"
    {
#line 1157 "WindowModule.cs"
        int index = 0;
        while (true)
        {
#line 1157 "WindowModule.cs"
            bool csharp2cuda_temp_5;
#line 1157 "WindowModule.cs"
            if (valid)
            {
#line 1157 "WindowModule.cs"
                csharp2cuda_temp_5 = ((index) < (input_count));
            }
            else
            {
#line 1157 "WindowModule.cs"
                csharp2cuda_temp_5 = false;
            }
            if (!(csharp2cuda_temp_5))
                break;
#line 1158 "WindowModule.cs"
#line 1158 "WindowModule.cs"
            MathBlockSlot* csharp2cuda_temp_6 = (inputs)[index];
#line 1158 "WindowModule.cs"
            bool csharp2cuda_temp_7;
#line 1158 "WindowModule.cs"
            if (!(((((void*)(csharp2cuda_temp_6))) == (((void*)(nullptr))))))
            {
#line 1158 "WindowModule.cs"
                MathBlockSlot* csharp2cuda_temp_8 = (inputs)[index];
#line 1158 "WindowModule.cs"
                bool csharp2cuda_temp_9 = (csharp2cuda_temp_8)->valid;
#line 1158 "WindowModule.cs"
                csharp2cuda_temp_7 = (!(csharp2cuda_temp_9));
            }
            else
            {
#line 1158 "WindowModule.cs"
                csharp2cuda_temp_7 = true;
            }
            if (csharp2cuda_temp_7)
            {
#line 1159 "WindowModule.cs"
#line 1159 "WindowModule.cs"
                bool* csharp2cuda_temp_10 = &(valid);
                (*(csharp2cuda_temp_10) = false);
            }
#line 1157 "WindowModule.cs"
            int* csharp2cuda_temp_4 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
        }
    }
#line 1160 "WindowModule.cs"
    if ((!(valid)))
#line 1161 "WindowModule.cs"
    {
#line 1162 "WindowModule.cs"
        mathblocks_window_publish(output, false, 0, thread);
#line 1163 "WindowModule.cs"
        return;
    }
#line 1166 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_11;
#line 1166 "WindowModule.cs"
    if (((input_count) > (0)))
    {
#line 1166 "WindowModule.cs"
        csharp2cuda_temp_11 = (inputs)[0];
    }
    else
    {
#line 1166 "WindowModule.cs"
        csharp2cuda_temp_11 = ((MathBlockSlot*)(nullptr));
    }
#line 1166 "WindowModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_11;
#line 1167 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_12;
#line 1167 "WindowModule.cs"
    if (((series) > (1)))
    {
#line 1167 "WindowModule.cs"
        csharp2cuda_temp_12 = (inputs)[1];
    }
    else
    {
#line 1167 "WindowModule.cs"
        csharp2cuda_temp_12 = ((MathBlockSlot*)(nullptr));
    }
#line 1167 "WindowModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_12;
#line 1168 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_13;
#line 1168 "WindowModule.cs"
    if (((arity) > (series)))
    {
#line 1168 "WindowModule.cs"
        csharp2cuda_temp_13 = (inputs)[series];
    }
    else
    {
#line 1168 "WindowModule.cs"
        csharp2cuda_temp_13 = ((MathBlockSlot*)(nullptr));
    }
#line 1168 "WindowModule.cs"
    const MathBlockSlot* first_parameter = csharp2cuda_temp_13;
#line 1169 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_14;
#line 1169 "WindowModule.cs"
    if (((arity) > (csharp2cuda_i32_add(series, 1))))
    {
#line 1169 "WindowModule.cs"
        csharp2cuda_temp_14 = (inputs)[csharp2cuda_i32_add(series, 1)];
    }
    else
    {
#line 1169 "WindowModule.cs"
        csharp2cuda_temp_14 = ((MathBlockSlot*)(nullptr));
    }
#line 1169 "WindowModule.cs"
    const MathBlockSlot* second_parameter = csharp2cuda_temp_14;
#line 1170 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_15 = (inputs)[arity];
#line 1170 "WindowModule.cs"
    const MathBlockSlot* width_input = csharp2cuda_temp_15;
#line 1171 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_16;
#line 1171 "WindowModule.cs"
    if (sibling)
    {
#line 1171 "WindowModule.cs"
        csharp2cuda_temp_16 = ((MathBlockSlot*)(nullptr));
    }
    else
    {
#line 1171 "WindowModule.cs"
        csharp2cuda_temp_16 = (inputs)[csharp2cuda_i32_add(arity, 1)];
    }
#line 1171 "WindowModule.cs"
    const MathBlockSlot* fill_input = csharp2cuda_temp_16;
#line 1172 "WindowModule.cs"
    int count = (first)->count;
#line 1173 "WindowModule.cs"
    int width = 0;
#line 1174 "WindowModule.cs"
#line 1174 "WindowModule.cs"
    bool csharp2cuda_temp_17;
#line 1174 "WindowModule.cs"
    if (((((void*)(second))) != (((void*)(nullptr)))))
    {
#line 1174 "WindowModule.cs"
        int csharp2cuda_temp_18 = (second)->count;
#line 1174 "WindowModule.cs"
        csharp2cuda_temp_17 = ((csharp2cuda_temp_18) != (count));
    }
    else
    {
#line 1174 "WindowModule.cs"
        csharp2cuda_temp_17 = false;
    }
    if (csharp2cuda_temp_17)
    {
#line 1175 "WindowModule.cs"
#line 1175 "WindowModule.cs"
        bool* csharp2cuda_temp_19 = &(valid);
        (*(csharp2cuda_temp_19) = false);
    }
#line 1176 "WindowModule.cs"
#line 1176 "WindowModule.cs"
    double csharp2cuda_temp_20 = (width_input)->scalar_value;
#line 1176 "WindowModule.cs"
    int* csharp2cuda_temp_21 = &(width);
#line 1176 "WindowModule.cs"
    bool csharp2cuda_temp_22 = mathblocks_sequence_positive_integer(csharp2cuda_temp_20, csharp2cuda_temp_21);
#line 1176 "WindowModule.cs"
    bool csharp2cuda_temp_23;
#line 1176 "WindowModule.cs"
    if (!((!(csharp2cuda_temp_22))))
    {
#line 1176 "WindowModule.cs"
        csharp2cuda_temp_23 = ((width) > (count));
    }
    else
    {
#line 1176 "WindowModule.cs"
        csharp2cuda_temp_23 = true;
    }
    if (csharp2cuda_temp_23)
    {
#line 1177 "WindowModule.cs"
#line 1177 "WindowModule.cs"
        bool* csharp2cuda_temp_24 = &(valid);
        (*(csharp2cuda_temp_24) = false);
    }
#line 1178 "WindowModule.cs"
#line 1178 "WindowModule.cs"
    int csharp2cuda_temp_25 = (output)->capacity;
    if (((count) > (csharp2cuda_temp_25)))
    {
#line 1179 "WindowModule.cs"
#line 1179 "WindowModule.cs"
        bool* csharp2cuda_temp_26 = &(valid);
        (*(csharp2cuda_temp_26) = false);
    }
#line 1180 "WindowModule.cs"
    long long csharp2cuda_temp_27;
#line 1180 "WindowModule.cs"
    if (valid)
    {
#line 1180 "WindowModule.cs"
        csharp2cuda_temp_27 = mathblocks_window_scratch_count(source, width);
    }
    else
    {
#line 1180 "WindowModule.cs"
        csharp2cuda_temp_27 = ((long long)(0));
    }
#line 1180 "WindowModule.cs"
    long long required = csharp2cuda_temp_27;
#line 1181 "WindowModule.cs"
    long long csharp2cuda_temp_28;
#line 1181 "WindowModule.cs"
    if (((scratch_capacity) < (0)))
    {
#line 1181 "WindowModule.cs"
        csharp2cuda_temp_28 = required;
    }
    else
    {
#line 1181 "WindowModule.cs"
        csharp2cuda_temp_28 = ((long long)(scratch_capacity));
    }
#line 1181 "WindowModule.cs"
    long long capacity = csharp2cuda_temp_28;
#line 1182 "WindowModule.cs"
#line 1182 "WindowModule.cs"
    bool csharp2cuda_temp_29;
#line 1182 "WindowModule.cs"
    if (!(((required) > (capacity))))
    {
#line 1182 "WindowModule.cs"
        bool csharp2cuda_temp_30;
#line 1182 "WindowModule.cs"
        if (((required) > (((long long)(0)))))
        {
#line 1182 "WindowModule.cs"
            unsigned long long csharp2cuda_temp_31 = (output)->scratch_pointer;
#line 1182 "WindowModule.cs"
            csharp2cuda_temp_30 = ((csharp2cuda_temp_31) == (((unsigned long long)(0))));
        }
        else
        {
#line 1182 "WindowModule.cs"
            csharp2cuda_temp_30 = false;
        }
#line 1182 "WindowModule.cs"
        csharp2cuda_temp_29 = csharp2cuda_temp_30;
    }
    else
    {
#line 1182 "WindowModule.cs"
        csharp2cuda_temp_29 = true;
    }
    if (csharp2cuda_temp_29)
    {
#line 1183 "WindowModule.cs"
#line 1183 "WindowModule.cs"
        bool* csharp2cuda_temp_32 = &(valid);
        (*(csharp2cuda_temp_32) = false);
    }
#line 1184 "WindowModule.cs"
    mathblocks_window_publish(output, valid, count, thread);
#line 1185 "WindowModule.cs"
    if ((!(valid)))
    {
#line 1186 "WindowModule.cs"
        return;
    }
#line 1188 "WindowModule.cs"
    double csharp2cuda_temp_33;
#line 1188 "WindowModule.cs"
    if (sibling)
    {
#line 1188 "WindowModule.cs"
        csharp2cuda_temp_33 = 0.0;
    }
    else
    {
#line 1188 "WindowModule.cs"
        csharp2cuda_temp_33 = (fill_input)->scalar_value;
    }
#line 1188 "WindowModule.cs"
    double fill = csharp2cuda_temp_33;
#line 1189 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_34 = (first)->data_pointer;
#line 1189 "WindowModule.cs"
    const double* a = ((double*)(csharp2cuda_temp_34));
#line 1190 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_35 = (first)->data_pointer;
#line 1190 "WindowModule.cs"
    const int* flags = ((int*)(csharp2cuda_temp_35));
#line 1191 "WindowModule.cs"
    double* csharp2cuda_temp_36;
#line 1191 "WindowModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 1191 "WindowModule.cs"
        csharp2cuda_temp_36 = ((double*)(nullptr));
    }
    else
    {
#line 1191 "WindowModule.cs"
        unsigned long long csharp2cuda_temp_37 = (second)->data_pointer;
#line 1191 "WindowModule.cs"
        csharp2cuda_temp_36 = ((double*)(csharp2cuda_temp_37));
    }
#line 1191 "WindowModule.cs"
    const double* b = csharp2cuda_temp_36;
#line 1192 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_38 = (output)->data_pointer;
#line 1192 "WindowModule.cs"
    double* result = ((double*)(csharp2cuda_temp_38));
#line 1193 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_39 = (output)->data_pointer;
#line 1193 "WindowModule.cs"
    int* boolean_result = ((int*)(csharp2cuda_temp_39));
#line 1194 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_40 = (output)->scratch_pointer;
#line 1194 "WindowModule.cs"
    double* scratch = csharp2cuda_pointer_add(((double*)(csharp2cuda_temp_40)), csharp2cuda_i32_mul(thread, csharp2cuda_i32_from_bits(capacity)));
#line 1195 "WindowModule.cs"
#line 1195 "WindowModule.cs"
    bool csharp2cuda_temp_41;
#line 1195 "WindowModule.cs"
    if (!(((source) == (47))))
    {
#line 1195 "WindowModule.cs"
        csharp2cuda_temp_41 = ((source) == (48));
    }
    else
    {
#line 1195 "WindowModule.cs"
        csharp2cuda_temp_41 = true;
    }
#line 1195 "WindowModule.cs"
    bool csharp2cuda_temp_42;
#line 1195 "WindowModule.cs"
    if (!(csharp2cuda_temp_41))
    {
#line 1195 "WindowModule.cs"
        csharp2cuda_temp_42 = ((source) >= (53));
    }
    else
    {
#line 1195 "WindowModule.cs"
        csharp2cuda_temp_42 = true;
    }
    if (csharp2cuda_temp_42)
#line 1196 "WindowModule.cs"
    {
#line 1198 "WindowModule.cs"
        long long rows_per_thread = csharp2cuda_i64_div(csharp2cuda_i64_sub(csharp2cuda_i64_add(((long long)(count)), ((long long)(threads))), ((long long)(1))), ((long long)(threads)));
#line 1199 "WindowModule.cs"
        long long first_row = csharp2cuda_i64_mul(((long long)(thread)), rows_per_thread);
#line 1200 "WindowModule.cs"
        if (((first_row) >= (((long long)(count)))))
        {
#line 1201 "WindowModule.cs"
            return;
        }
#line 1202 "WindowModule.cs"
        long long csharp2cuda_temp_43;
#line 1202 "WindowModule.cs"
        if (((csharp2cuda_i64_sub(((long long)(count)), first_row)) < (rows_per_thread)))
        {
#line 1202 "WindowModule.cs"
            csharp2cuda_temp_43 = ((long long)(count));
        }
        else
        {
#line 1202 "WindowModule.cs"
            csharp2cuda_temp_43 = csharp2cuda_i64_add(first_row, rows_per_thread);
        }
#line 1202 "WindowModule.cs"
        long long last_row = csharp2cuda_temp_43;
#line 1203 "WindowModule.cs"
        if (((source) >= (53)))
#line 1204 "WindowModule.cs"
        {
#line 1205 "WindowModule.cs"
            mathblocks_window_accurate_rows(source, a, width, csharp2cuda_i32_from_bits(first_row), csharp2cuda_i32_from_bits(last_row), fill, sibling, result, boolean_result, ((long long*)(scratch)));
        }
        else
#line 1218 "WindowModule.cs"
        {
#line 1219 "WindowModule.cs"
#line 1222 "WindowModule.cs"
            double csharp2cuda_temp_44;
#line 1222 "WindowModule.cs"
            if (((source) == (47)))
            {
#line 1222 "WindowModule.cs"
                csharp2cuda_temp_44 = 0.5;
            }
            else
            {
#line 1222 "WindowModule.cs"
                csharp2cuda_temp_44 = (first_parameter)->scalar_value;
            }
            mathblocks_window_sorted_rows(a, width, csharp2cuda_temp_44, csharp2cuda_i32_from_bits(first_row), csharp2cuda_i32_from_bits(last_row), fill, sibling, result, boolean_result, scratch);
        }
#line 1231 "WindowModule.cs"
        return;
    }
#line 1233 "WindowModule.cs"
    {
#line 1233 "WindowModule.cs"
        int end = thread;
        while (true)
        {
            if (!(((end) < (count))))
                break;
#line 1234 "WindowModule.cs"
            {
#line 1235 "WindowModule.cs"
                bool row_valid = false;
#line 1236 "WindowModule.cs"
                double value = 0.0;
#line 1237 "WindowModule.cs"
                if (((end) >= (csharp2cuda_i32_sub(width, 1))))
#line 1238 "WindowModule.cs"
                {
#line 1240 "WindowModule.cs"
                    int start = csharp2cuda_i32_add(csharp2cuda_i32_sub(end, width), 1);
#line 1241 "WindowModule.cs"
#line 1241 "WindowModule.cs"
                    bool* csharp2cuda_temp_47 = &(row_valid);
#line 1250 "WindowModule.cs"
                    double* csharp2cuda_temp_48 = &(value);
#line 1241 "WindowModule.cs"
                    bool csharp2cuda_temp_49 = mathblocks_window_value(source, csharp2cuda_pointer_add(a, start), csharp2cuda_pointer_add(b, start), csharp2cuda_pointer_add(flags, start), width, first_parameter, second_parameter, scratch, csharp2cuda_temp_48);
                    (*(csharp2cuda_temp_47) = csharp2cuda_temp_49);
                }
#line 1252 "WindowModule.cs"
                if (sibling)
                {
#line 1253 "WindowModule.cs"
#line 1253 "WindowModule.cs"
                    int* csharp2cuda_temp_50 = &((boolean_result)[end]);
                    (*(csharp2cuda_temp_50) = row_valid);
                }
                else
                {
#line 1255 "WindowModule.cs"
#line 1255 "WindowModule.cs"
                    double* csharp2cuda_temp_51 = &((result)[end]);
#line 1255 "WindowModule.cs"
                    double csharp2cuda_temp_52;
#line 1255 "WindowModule.cs"
                    if (row_valid)
                    {
#line 1255 "WindowModule.cs"
                        csharp2cuda_temp_52 = value;
                    }
                    else
                    {
#line 1255 "WindowModule.cs"
                        csharp2cuda_temp_52 = fill;
                    }
                    (*(csharp2cuda_temp_51) = csharp2cuda_temp_52);
                }
            }
#line 1233 "WindowModule.cs"
            int* csharp2cuda_temp_45 = &(end);
#line 1233 "WindowModule.cs"
            int csharp2cuda_temp_46 = *(csharp2cuda_temp_45);
            (*(csharp2cuda_temp_45) = csharp2cuda_i32_add(csharp2cuda_temp_46, threads));
        }
    }
}

#line 197 "WindowModule.cs"
__device__ long long mathblocks_window_scratch_count(int source, int width)
#line 199 "WindowModule.cs"
{
#line 200 "WindowModule.cs"
    long long count = ((long long)(width));
#line 201 "WindowModule.cs"
    switch (source)
    {
#line 203 "WindowModule.cs"
        case 44:
        case 47:
        case 48:
#line 206 "WindowModule.cs"
            return count;
#line 207 "WindowModule.cs"
        case 2:
        case 3:
        case 8:
        case 21:
#line 211 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, ((long long)(2)));
#line 212 "WindowModule.cs"
        case 22:
#line 213 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, csharp2cuda_i64_sub(count, ((long long)(1))));
#line 214 "WindowModule.cs"
        case 15:
#line 215 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, csharp2cuda_i64_add(count, ((long long)(1))));
#line 216 "WindowModule.cs"
        case 53:
        case 54:
#line 218 "WindowModule.cs"
            return ((long long)(285));
#line 219 "WindowModule.cs"
        case 55:
        case 56:
        case 57:
        case 58:
#line 223 "WindowModule.cs"
            return ((long long)(570));
#line 224 "WindowModule.cs"
        default:
#line 225 "WindowModule.cs"
            return ((long long)(0));
    }
}

#line 296 "WindowModule.cs"
__device__ double mathblocks_window_scratch_median(double* scratch, int count)
#line 298 "WindowModule.cs"
{
#line 299 "WindowModule.cs"
    double* sorted = mathblocks_stable_merge_sort(scratch, csharp2cuda_pointer_add(scratch, count), count, false);
#line 300 "WindowModule.cs"
    return mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
}

#line 172 "WindowModule.cs"
__device__ int mathblocks_window_series_count(int source)
#line 174 "WindowModule.cs"
{
#line 175 "WindowModule.cs"
    switch (source)
    {
#line 177 "WindowModule.cs"
        case 2:
        case 4:
        case 5:
        case 6:
        case 7:
        case 9:
        case 10:
        case 18:
        case 21:
        case 22:
        case 23:
        case 24:
#line 189 "WindowModule.cs"
            return 2;
#line 190 "WindowModule.cs"
        default:
#line 191 "WindowModule.cs"
            return 1;
    }
}

#line 1065 "WindowModule.cs"
__device__ void mathblocks_window_sorted_rows(
    const double* x,
    int width,
    double probability,
    int first_row,
    int last_row,
    double fill,
    bool sibling,
    double* result,
    int* boolean_result,
    double* sorted)
#line 1077 "WindowModule.cs"
{
#line 1078 "WindowModule.cs"
    bool csharp2cuda_temp_0;
#line 1078 "WindowModule.cs"
    if (!(((probability) < (0.0))))
    {
#line 1078 "WindowModule.cs"
        csharp2cuda_temp_0 = ((probability) > (1.0));
    }
    else
    {
#line 1078 "WindowModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 1078 "WindowModule.cs"
    bool probability_valid = (!(csharp2cuda_temp_0));
#line 1079 "WindowModule.cs"
    int csharp2cuda_temp_1;
#line 1079 "WindowModule.cs"
    if (((csharp2cuda_i32_add(csharp2cuda_i32_sub(first_row, width), 1)) < (0)))
    {
#line 1079 "WindowModule.cs"
        csharp2cuda_temp_1 = 0;
    }
    else
    {
#line 1079 "WindowModule.cs"
        csharp2cuda_temp_1 = csharp2cuda_i32_add(csharp2cuda_i32_sub(first_row, width), 1);
    }
#line 1079 "WindowModule.cs"
    int begin = csharp2cuda_temp_1;
#line 1080 "WindowModule.cs"
    int size = 0;
#line 1081 "WindowModule.cs"
    {
#line 1081 "WindowModule.cs"
        int row = begin;
        while (true)
        {
            if (!(((row) < (last_row))))
                break;
#line 1082 "WindowModule.cs"
            {
#line 1083 "WindowModule.cs"
                if (((csharp2cuda_i32_sub(row, width)) >= (begin)))
#line 1084 "WindowModule.cs"
                {
#line 1085 "WindowModule.cs"
                    double leaving = (x)[csharp2cuda_i32_sub(row, width)];
#line 1086 "WindowModule.cs"
                    int low = 0;
#line 1087 "WindowModule.cs"
                    int high = size;
#line 1088 "WindowModule.cs"
                    while (true)
                    {
                        if (!(((low) < (high))))
                            break;
#line 1089 "WindowModule.cs"
                        {
#line 1090 "WindowModule.cs"
                            int middle = csharp2cuda_i32_div(csharp2cuda_i32_add(low, high), 2);
#line 1091 "WindowModule.cs"
#line 1091 "WindowModule.cs"
                            double csharp2cuda_temp_3 = (sorted)[middle];
                            if (((csharp2cuda_temp_3) < (leaving)))
                            {
#line 1092 "WindowModule.cs"
#line 1092 "WindowModule.cs"
                                int* csharp2cuda_temp_4 = &(low);
                                (*(csharp2cuda_temp_4) = csharp2cuda_i32_add(middle, 1));
                            }
                            else
                            {
#line 1094 "WindowModule.cs"
#line 1094 "WindowModule.cs"
                                int* csharp2cuda_temp_5 = &(high);
                                (*(csharp2cuda_temp_5) = middle);
                            }
                        }
                    }
#line 1096 "WindowModule.cs"
                    {
#line 1096 "WindowModule.cs"
                        int index = low;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_sub(size, 1)))))
                                break;
#line 1097 "WindowModule.cs"
#line 1097 "WindowModule.cs"
                            double* csharp2cuda_temp_7 = &((sorted)[index]);
#line 1097 "WindowModule.cs"
                            double csharp2cuda_temp_8 = (sorted)[csharp2cuda_i32_add(index, 1)];
                            (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 1096 "WindowModule.cs"
                            int* csharp2cuda_temp_6 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
                        }
                    }
#line 1098 "WindowModule.cs"
#line 1098 "WindowModule.cs"
                    int* csharp2cuda_temp_9 = &(size);
                    csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_9));
                }
#line 1100 "WindowModule.cs"
                double entering = (x)[row];
#line 1101 "WindowModule.cs"
                int position = size;
#line 1102 "WindowModule.cs"
                while (true)
                {
#line 1102 "WindowModule.cs"
                    bool csharp2cuda_temp_10;
#line 1102 "WindowModule.cs"
                    if (((position) > (0)))
                    {
#line 1102 "WindowModule.cs"
                        double csharp2cuda_temp_11 = (sorted)[csharp2cuda_i32_sub(position, 1)];
#line 1102 "WindowModule.cs"
                        csharp2cuda_temp_10 = ((csharp2cuda_temp_11) > (entering));
                    }
                    else
                    {
#line 1102 "WindowModule.cs"
                        csharp2cuda_temp_10 = false;
                    }
                    if (!(csharp2cuda_temp_10))
                        break;
#line 1103 "WindowModule.cs"
                    {
#line 1104 "WindowModule.cs"
#line 1104 "WindowModule.cs"
                        double* csharp2cuda_temp_12 = &((sorted)[position]);
#line 1104 "WindowModule.cs"
                        double csharp2cuda_temp_13 = (sorted)[csharp2cuda_i32_sub(position, 1)];
                        (*(csharp2cuda_temp_12) = csharp2cuda_temp_13);
#line 1105 "WindowModule.cs"
#line 1105 "WindowModule.cs"
                        int* csharp2cuda_temp_14 = &(position);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_14));
                    }
                }
#line 1107 "WindowModule.cs"
#line 1107 "WindowModule.cs"
                double* csharp2cuda_temp_15 = &((sorted)[position]);
                (*(csharp2cuda_temp_15) = entering);
#line 1108 "WindowModule.cs"
#line 1108 "WindowModule.cs"
                int* csharp2cuda_temp_16 = &(size);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
#line 1109 "WindowModule.cs"
                if (((row) < (first_row)))
                {
#line 1110 "WindowModule.cs"
                    goto csharp2cuda_for_continue_1;
                }
#line 1111 "WindowModule.cs"
                bool computed = false;
#line 1112 "WindowModule.cs"
                double value = 0.0;
#line 1113 "WindowModule.cs"
#line 1113 "WindowModule.cs"
                bool csharp2cuda_temp_17;
#line 1113 "WindowModule.cs"
                if (((row) >= (csharp2cuda_i32_sub(width, 1))))
                {
#line 1113 "WindowModule.cs"
                    csharp2cuda_temp_17 = probability_valid;
                }
                else
                {
#line 1113 "WindowModule.cs"
                    csharp2cuda_temp_17 = false;
                }
                if (csharp2cuda_temp_17)
#line 1114 "WindowModule.cs"
                {
#line 1115 "WindowModule.cs"
#line 1115 "WindowModule.cs"
                    double* csharp2cuda_temp_18 = &(value);
                    (*(csharp2cuda_temp_18) = mathblocks_statistics_sorted_quantile(sorted, width, probability));
#line 1116 "WindowModule.cs"
#line 1116 "WindowModule.cs"
                    bool* csharp2cuda_temp_19 = &(computed);
                    (*(csharp2cuda_temp_19) = isfinite(value));
                }
#line 1118 "WindowModule.cs"
                if (sibling)
                {
#line 1119 "WindowModule.cs"
#line 1119 "WindowModule.cs"
                    int* csharp2cuda_temp_20 = &((boolean_result)[row]);
                    (*(csharp2cuda_temp_20) = computed);
                }
                else
                {
#line 1121 "WindowModule.cs"
#line 1121 "WindowModule.cs"
                    double* csharp2cuda_temp_21 = &((result)[row]);
#line 1121 "WindowModule.cs"
                    double csharp2cuda_temp_22;
#line 1121 "WindowModule.cs"
                    if (computed)
                    {
#line 1121 "WindowModule.cs"
                        csharp2cuda_temp_22 = value;
                    }
                    else
                    {
#line 1121 "WindowModule.cs"
                        csharp2cuda_temp_22 = fill;
                    }
                    (*(csharp2cuda_temp_21) = csharp2cuda_temp_22);
                }
            }
            csharp2cuda_for_continue_1:
#line 1081 "WindowModule.cs"
            int* csharp2cuda_temp_2 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
}

#line 139 "WindowModule.cs"
__device__ int mathblocks_window_source_arity(int source)
#line 141 "WindowModule.cs"
{
#line 142 "WindowModule.cs"
    switch (source)
    {
#line 144 "WindowModule.cs"
        case 34:
#line 145 "WindowModule.cs"
            return 3;
#line 146 "WindowModule.cs"
        case 0:
        case 1:
        case 2:
        case 4:
        case 5:
        case 6:
        case 7:
        case 9:
        case 10:
        case 16:
        case 18:
        case 21:
        case 22:
        case 23:
        case 24:
        case 28:
        case 30:
        case 36:
        case 37:
        case 48:
#line 166 "WindowModule.cs"
            return 2;
#line 167 "WindowModule.cs"
        default:
#line 168 "WindowModule.cs"
            return 1;
    }
}

#line 678 "WindowModule.cs"
__device__ void mathblocks_window_split(double a, double* high, double* low)
#line 680 "WindowModule.cs"
{
#line 681 "WindowModule.cs"
    double c = __dmul_rn(134217729.0, a);
#line 682 "WindowModule.cs"
#line 682 "WindowModule.cs"
    double* csharp2cuda_temp_0 = high;
    (*(csharp2cuda_temp_0) = __dsub_rn(c, __dsub_rn(c, a)));
#line 683 "WindowModule.cs"
#line 683 "WindowModule.cs"
    double* csharp2cuda_temp_1 = low;
#line 683 "WindowModule.cs"
    double csharp2cuda_temp_2 = *(high);
    (*(csharp2cuda_temp_1) = __dsub_rn(a, csharp2cuda_temp_2));
}

#line 901 "WindowModule.cs"
__device__ void mathblocks_window_square(double h, double l, double* sh, double* sl)
#line 903 "WindowModule.cs"
{
#line 904 "WindowModule.cs"
    double p = 0.0;
#line 905 "WindowModule.cs"
    double e = 0.0;
#line 906 "WindowModule.cs"
#line 906 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &(p);
#line 906 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(e);
    mathblocks_window_two_product(h, h, csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 907 "WindowModule.cs"
    double low = __dadd_rn(e, __dmul_rn(__dadd_rn(h, h), l));
#line 908 "WindowModule.cs"
    mathblocks_window_fast_two_sum(p, low, sh, sl);
}

#line 305 "WindowModule.cs"
__device__ bool mathblocks_window_standardize_last(
    const double* values,
    int count,
    double* value)
#line 310 "WindowModule.cs"
{
#line 311 "WindowModule.cs"
    if (((count) <= (0)))
    {
#line 312 "WindowModule.cs"
        return false;
    }
#line 313 "WindowModule.cs"
    double mean = 0.0;
#line 314 "WindowModule.cs"
    double deviation = 0.0;
#line 315 "WindowModule.cs"
#line 315 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &(mean);
#line 315 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(deviation);
    mathblocks_vector_standardize_moments(values, count, csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 316 "WindowModule.cs"
    {
#line 316 "WindowModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 317 "WindowModule.cs"
#line 317 "WindowModule.cs"
            double csharp2cuda_temp_3 = (values)[index];
#line 317 "WindowModule.cs"
            double csharp2cuda_temp_4 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_3, mean), deviation);
            if ((!(isfinite(csharp2cuda_temp_4))))
            {
#line 318 "WindowModule.cs"
                return false;
            }
#line 316 "WindowModule.cs"
            int* csharp2cuda_temp_2 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 319 "WindowModule.cs"
#line 319 "WindowModule.cs"
    double* csharp2cuda_temp_5 = value;
#line 319 "WindowModule.cs"
    double csharp2cuda_temp_6 = (values)[csharp2cuda_i32_sub(count, 1)];
#line 319 "WindowModule.cs"
    double csharp2cuda_temp_7 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_6, mean), deviation);
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_7);
#line 320 "WindowModule.cs"
    return true;
}

#line 925 "WindowModule.cs"
__device__ double mathblocks_window_subtract_rounded(double ah, double al, double bh, double bl)
#line 927 "WindowModule.cs"
{
#line 928 "WindowModule.cs"
    double sh = 0.0;
#line 929 "WindowModule.cs"
    double sl = 0.0;
#line 930 "WindowModule.cs"
    double th = 0.0;
#line 931 "WindowModule.cs"
    double tl = 0.0;
#line 932 "WindowModule.cs"
#line 932 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &(sh);
#line 932 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(sl);
    mathblocks_window_two_sum(ah, (-(bh)), csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 933 "WindowModule.cs"
#line 933 "WindowModule.cs"
    double* csharp2cuda_temp_2 = &(th);
#line 933 "WindowModule.cs"
    double* csharp2cuda_temp_3 = &(tl);
    mathblocks_window_two_sum(al, (-(bl)), csharp2cuda_temp_2, csharp2cuda_temp_3);
#line 934 "WindowModule.cs"
    double c = __dadd_rn(sl, th);
#line 935 "WindowModule.cs"
    double vh = 0.0;
#line 936 "WindowModule.cs"
    double vl = 0.0;
#line 937 "WindowModule.cs"
#line 937 "WindowModule.cs"
    double* csharp2cuda_temp_4 = &(vh);
#line 937 "WindowModule.cs"
    double* csharp2cuda_temp_5 = &(vl);
    mathblocks_window_fast_two_sum(sh, c, csharp2cuda_temp_4, csharp2cuda_temp_5);
#line 938 "WindowModule.cs"
    double w = __dadd_rn(tl, vl);
#line 939 "WindowModule.cs"
    double zh = 0.0;
#line 940 "WindowModule.cs"
    double zl = 0.0;
#line 941 "WindowModule.cs"
#line 941 "WindowModule.cs"
    double* csharp2cuda_temp_6 = &(zh);
#line 941 "WindowModule.cs"
    double* csharp2cuda_temp_7 = &(zl);
    mathblocks_window_fast_two_sum(vh, w, csharp2cuda_temp_6, csharp2cuda_temp_7);
#line 942 "WindowModule.cs"
    return zh;
}

#line 687 "WindowModule.cs"
__device__ void mathblocks_window_two_product(double a, double b, double* p, double* e)
#line 689 "WindowModule.cs"
{
#line 690 "WindowModule.cs"
#line 690 "WindowModule.cs"
    double* csharp2cuda_temp_0 = p;
    (*(csharp2cuda_temp_0) = __dmul_rn(a, b));
#line 691 "WindowModule.cs"
    double ah = 0.0;
#line 692 "WindowModule.cs"
    double al = 0.0;
#line 693 "WindowModule.cs"
    double bh = 0.0;
#line 694 "WindowModule.cs"
    double bl = 0.0;
#line 695 "WindowModule.cs"
#line 695 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(ah);
#line 695 "WindowModule.cs"
    double* csharp2cuda_temp_2 = &(al);
    mathblocks_window_split(a, csharp2cuda_temp_1, csharp2cuda_temp_2);
#line 696 "WindowModule.cs"
#line 696 "WindowModule.cs"
    double* csharp2cuda_temp_3 = &(bh);
#line 696 "WindowModule.cs"
    double* csharp2cuda_temp_4 = &(bl);
    mathblocks_window_split(b, csharp2cuda_temp_3, csharp2cuda_temp_4);
#line 697 "WindowModule.cs"
#line 697 "WindowModule.cs"
    double* csharp2cuda_temp_5 = e;
#line 697 "WindowModule.cs"
    double csharp2cuda_temp_6 = *(p);
    (*(csharp2cuda_temp_5) = __dadd_rn(__dadd_rn(__dadd_rn(__dsub_rn(__dmul_rn(ah, bh), csharp2cuda_temp_6), __dmul_rn(ah, bl)), __dmul_rn(al, bh)), __dmul_rn(al, bl)));
}

#line 884 "WindowModule.cs"
__device__ void mathblocks_window_two_sum(double a, double b, double* s, double* e)
#line 886 "WindowModule.cs"
{
#line 887 "WindowModule.cs"
#line 887 "WindowModule.cs"
    double* csharp2cuda_temp_0 = s;
    (*(csharp2cuda_temp_0) = __dadd_rn(a, b));
#line 888 "WindowModule.cs"
    double csharp2cuda_temp_1 = *(s);
#line 888 "WindowModule.cs"
    double b_virtual = __dsub_rn(csharp2cuda_temp_1, a);
#line 889 "WindowModule.cs"
    double csharp2cuda_temp_2 = *(s);
#line 889 "WindowModule.cs"
    double a_virtual = __dsub_rn(csharp2cuda_temp_2, b_virtual);
#line 890 "WindowModule.cs"
#line 890 "WindowModule.cs"
    double* csharp2cuda_temp_3 = e;
    (*(csharp2cuda_temp_3) = __dadd_rn(__dsub_rn(a, a_virtual), __dsub_rn(b, b_virtual)));
}

#line 327 "WindowModule.cs"
__device__ bool mathblocks_window_value(
    int source,
    const double* a,
    const double* b,
    const int* flags,
    int count,
    const MathBlockSlot* first_parameter,
    const MathBlockSlot* second_parameter,
    double* scratch,
    double* value)
#line 338 "WindowModule.cs"
{
#line 339 "WindowModule.cs"
    switch (source)
    {
#line 341 "WindowModule.cs"
        case 0:
#line 342 "WindowModule.cs"
            {
#line 343 "WindowModule.cs"
                int lag = 0;
#line 344 "WindowModule.cs"
#line 344 "WindowModule.cs"
                double csharp2cuda_temp_0 = (first_parameter)->scalar_value;
#line 344 "WindowModule.cs"
                int* csharp2cuda_temp_1 = &(lag);
#line 344 "WindowModule.cs"
                bool csharp2cuda_temp_2 = mathblocks_sequence_positive_integer(csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 344 "WindowModule.cs"
                bool csharp2cuda_temp_3;
#line 344 "WindowModule.cs"
                if (!((!(csharp2cuda_temp_2))))
                {
#line 344 "WindowModule.cs"
                    csharp2cuda_temp_3 = ((lag) >= (count));
                }
                else
                {
#line 344 "WindowModule.cs"
                    csharp2cuda_temp_3 = true;
                }
                if (csharp2cuda_temp_3)
                {
#line 345 "WindowModule.cs"
                    return false;
                }
#line 346 "WindowModule.cs"
#line 346 "WindowModule.cs"
                double* csharp2cuda_temp_4 = value;
                (*(csharp2cuda_temp_4) = mathblocks_statistics_pearson(a, csharp2cuda_pointer_add(a, lag), csharp2cuda_i32_sub(count, lag)));
#line 347 "WindowModule.cs"
                break;
            }
#line 349 "WindowModule.cs"
        case 1:
        case 16:
#line 351 "WindowModule.cs"
#line 351 "WindowModule.cs"
            double csharp2cuda_temp_5 = (first_parameter)->scalar_value;
            return mathblocks_statistics_moment_value(a, count, csharp2cuda_temp_5, ((source) == (1)), value);
#line 352 "WindowModule.cs"
        case 2:
#line 353 "WindowModule.cs"
            return mathblocks_window_distance_correlation(a, b, count, scratch, value);
#line 354 "WindowModule.cs"
        case 3:
#line 355 "WindowModule.cs"
#line 355 "WindowModule.cs"
            bool csharp2cuda_temp_6;
#line 355 "WindowModule.cs"
            if (!(((count) <= (0))))
            {
#line 355 "WindowModule.cs"
                csharp2cuda_temp_6 = ((((void*)(scratch))) == (((void*)(nullptr))));
            }
            else
            {
#line 355 "WindowModule.cs"
                csharp2cuda_temp_6 = true;
            }
            if (csharp2cuda_temp_6)
            {
#line 356 "WindowModule.cs"
                return false;
            }
#line 357 "WindowModule.cs"
            mathblocks_statistics_sort_copy(a, count, scratch, false);
#line 358 "WindowModule.cs"
#line 358 "WindowModule.cs"
            double* csharp2cuda_temp_7 = value;
            (*(csharp2cuda_temp_7) = __dsub_rn(mathblocks_statistics_sorted_quantile(scratch, count, 0.75), mathblocks_statistics_sorted_quantile(scratch, count, 0.25)));
#line 361 "WindowModule.cs"
            break;
#line 362 "WindowModule.cs"
        case 4:
#line 363 "WindowModule.cs"
            return mathblocks_statistics_kendall_value(a, b, count, value);
#line 364 "WindowModule.cs"
        case 5:
        case 6:
        case 7:
        case 9:
        case 10:
        case 18:
#line 370 "WindowModule.cs"
            {
#line 371 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 372 "WindowModule.cs"
                    return false;
                }
#line 373 "WindowModule.cs"
                double covariance = mathblocks_statistics_population_covariance(a, b, count);
#line 374 "WindowModule.cs"
#line 374 "WindowModule.cs"
                bool csharp2cuda_temp_8;
#line 374 "WindowModule.cs"
                if (!(((source) == (10))))
                {
#line 374 "WindowModule.cs"
                    csharp2cuda_temp_8 = ((source) == (18));
                }
                else
                {
#line 374 "WindowModule.cs"
                    csharp2cuda_temp_8 = true;
                }
                if (csharp2cuda_temp_8)
#line 375 "WindowModule.cs"
                {
#line 376 "WindowModule.cs"
#line 376 "WindowModule.cs"
                    double* csharp2cuda_temp_9 = value;
#line 376 "WindowModule.cs"
                    double csharp2cuda_temp_10;
#line 376 "WindowModule.cs"
                    if (((source) == (10)))
                    {
#line 376 "WindowModule.cs"
                        csharp2cuda_temp_10 = covariance;
                    }
                    else
                    {
#line 376 "WindowModule.cs"
                        csharp2cuda_temp_10 = __ddiv_rn(__dmul_rn(covariance, ((double)(count))), __dsub_rn(((double)(count)), 1.0));
                    }
                    (*(csharp2cuda_temp_9) = csharp2cuda_temp_10);
                }
                else
                {
#line 380 "WindowModule.cs"
                    if (((source) == (7)))
#line 381 "WindowModule.cs"
                    {
#line 382 "WindowModule.cs"
#line 382 "WindowModule.cs"
                        double* csharp2cuda_temp_11 = value;
#line 382 "WindowModule.cs"
                        double csharp2cuda_temp_12 = __ddiv_rn(covariance, mathblocks_statistics_population_variance(a, count));
                        (*(csharp2cuda_temp_11) = csharp2cuda_temp_12);
                    }
                    else
                    {
#line 385 "WindowModule.cs"
                        if (((source) == (5)))
#line 386 "WindowModule.cs"
                        {
#line 387 "WindowModule.cs"
                            double slope = __ddiv_rn(covariance, mathblocks_statistics_population_variance(a, count));
#line 389 "WindowModule.cs"
#line 389 "WindowModule.cs"
                            double* csharp2cuda_temp_13 = value;
                            (*(csharp2cuda_temp_13) = __dsub_rn(mathblocks_statistics_mean(b, count), __dmul_rn(slope, mathblocks_statistics_mean(a, count))));
                        }
                        else
#line 393 "WindowModule.cs"
                        {
#line 394 "WindowModule.cs"
                            double correlation = __ddiv_rn(covariance, __dmul_rn(mathblocks_square_root(mathblocks_statistics_population_variance(a, count)), mathblocks_square_root(mathblocks_statistics_population_variance(b, count))));
#line 397 "WindowModule.cs"
#line 397 "WindowModule.cs"
                            double* csharp2cuda_temp_14 = value;
#line 397 "WindowModule.cs"
                            double csharp2cuda_temp_15;
#line 397 "WindowModule.cs"
                            if (((source) == (6)))
                            {
#line 397 "WindowModule.cs"
                                csharp2cuda_temp_15 = __dmul_rn(correlation, correlation);
                            }
                            else
                            {
#line 397 "WindowModule.cs"
                                csharp2cuda_temp_15 = correlation;
                            }
                            (*(csharp2cuda_temp_14) = csharp2cuda_temp_15);
                        }
                    }
                }
#line 399 "WindowModule.cs"
                break;
            }
#line 401 "WindowModule.cs"
        case 8:
#line 402 "WindowModule.cs"
            {
#line 403 "WindowModule.cs"
#line 403 "WindowModule.cs"
                bool csharp2cuda_temp_16;
#line 403 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 403 "WindowModule.cs"
                    csharp2cuda_temp_16 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 403 "WindowModule.cs"
                    csharp2cuda_temp_16 = true;
                }
                if (csharp2cuda_temp_16)
                {
#line 404 "WindowModule.cs"
                    return false;
                }
#line 405 "WindowModule.cs"
                double* sorted = scratch;
#line 406 "WindowModule.cs"
                double* deviations = csharp2cuda_pointer_add(scratch, count);
#line 407 "WindowModule.cs"
                mathblocks_statistics_sort_copy(a, count, sorted, false);
#line 408 "WindowModule.cs"
                double median = mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
#line 409 "WindowModule.cs"
                {
#line 409 "WindowModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (count))))
                            break;
#line 410 "WindowModule.cs"
#line 410 "WindowModule.cs"
                        double* csharp2cuda_temp_18 = &((deviations)[index]);
#line 410 "WindowModule.cs"
                        double csharp2cuda_temp_19 = (a)[index];
                        (*(csharp2cuda_temp_18) = fabs(__dsub_rn(csharp2cuda_temp_19, median)));
#line 409 "WindowModule.cs"
                        int* csharp2cuda_temp_17 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_17));
                    }
                }
#line 411 "WindowModule.cs"
                mathblocks_statistics_sort_copy(deviations, count, sorted, false);
#line 412 "WindowModule.cs"
#line 412 "WindowModule.cs"
                double* csharp2cuda_temp_20 = value;
                (*(csharp2cuda_temp_20) = mathblocks_statistics_sorted_quantile(sorted, count, 0.5));
#line 413 "WindowModule.cs"
                break;
            }
#line 415 "WindowModule.cs"
        case 11:
        case 12:
#line 417 "WindowModule.cs"
            return mathblocks_statistics_shape_moment_value(a, count, ((source) == (11)), value);
#line 418 "WindowModule.cs"
        case 13:
        case 14:
        case 19:
        case 20:
#line 422 "WindowModule.cs"
            {
#line 423 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 424 "WindowModule.cs"
                    return false;
                }
#line 425 "WindowModule.cs"
                double variance = mathblocks_statistics_population_variance(a, count);
#line 426 "WindowModule.cs"
#line 426 "WindowModule.cs"
                bool csharp2cuda_temp_21;
#line 426 "WindowModule.cs"
                if (!(((source) == (19))))
                {
#line 426 "WindowModule.cs"
                    csharp2cuda_temp_21 = ((source) == (20));
                }
                else
                {
#line 426 "WindowModule.cs"
                    csharp2cuda_temp_21 = true;
                }
                if (csharp2cuda_temp_21)
                {
#line 427 "WindowModule.cs"
#line 427 "WindowModule.cs"
                    double* csharp2cuda_temp_22 = &(variance);
#line 427 "WindowModule.cs"
                    double csharp2cuda_temp_23 = __ddiv_rn(__dmul_rn(variance, ((double)(count))), __dsub_rn(((double)(count)), 1.0));
                    (*(csharp2cuda_temp_22) = csharp2cuda_temp_23);
                }
#line 428 "WindowModule.cs"
#line 428 "WindowModule.cs"
                double* csharp2cuda_temp_24 = value;
#line 428 "WindowModule.cs"
                bool csharp2cuda_temp_25;
#line 428 "WindowModule.cs"
                if (!(((source) == (13))))
                {
#line 428 "WindowModule.cs"
                    csharp2cuda_temp_25 = ((source) == (19));
                }
                else
                {
#line 428 "WindowModule.cs"
                    csharp2cuda_temp_25 = true;
                }
#line 428 "WindowModule.cs"
                double csharp2cuda_temp_26;
#line 428 "WindowModule.cs"
                if (csharp2cuda_temp_25)
                {
#line 428 "WindowModule.cs"
                    csharp2cuda_temp_26 = mathblocks_square_root(variance);
                }
                else
                {
#line 428 "WindowModule.cs"
                    csharp2cuda_temp_26 = variance;
                }
                (*(csharp2cuda_temp_24) = csharp2cuda_temp_26);
#line 431 "WindowModule.cs"
                break;
            }
#line 433 "WindowModule.cs"
        case 15:
#line 434 "WindowModule.cs"
            {
#line 435 "WindowModule.cs"
#line 435 "WindowModule.cs"
                bool csharp2cuda_temp_27;
#line 435 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 435 "WindowModule.cs"
                    csharp2cuda_temp_27 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 435 "WindowModule.cs"
                    csharp2cuda_temp_27 = true;
                }
                if (csharp2cuda_temp_27)
                {
#line 436 "WindowModule.cs"
                    return false;
                }
#line 437 "WindowModule.cs"
                int average_count = mathblocks_statistics_pair_averages(a, count, scratch);
#line 438 "WindowModule.cs"
#line 438 "WindowModule.cs"
                double* csharp2cuda_temp_28 = value;
#line 438 "WindowModule.cs"
                double csharp2cuda_temp_29 = mathblocks_window_scratch_median(scratch, average_count);
                (*(csharp2cuda_temp_28) = csharp2cuda_temp_29);
#line 439 "WindowModule.cs"
                break;
            }
#line 441 "WindowModule.cs"
        case 17:
#line 442 "WindowModule.cs"
#line 442 "WindowModule.cs"
            double* csharp2cuda_temp_30 = value;
#line 443 "WindowModule.cs"
            double csharp2cuda_temp_31 = __ddiv_rn(mathblocks_compensated_product_sum(a, a, count), ((double)(count)));
            (*(csharp2cuda_temp_30) = mathblocks_square_root(csharp2cuda_temp_31));
#line 444 "WindowModule.cs"
            break;
#line 445 "WindowModule.cs"
        case 21:
#line 446 "WindowModule.cs"
            {
#line 447 "WindowModule.cs"
#line 447 "WindowModule.cs"
                bool csharp2cuda_temp_32;
#line 447 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 447 "WindowModule.cs"
                    csharp2cuda_temp_32 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 447 "WindowModule.cs"
                    csharp2cuda_temp_32 = true;
                }
                if (csharp2cuda_temp_32)
                {
#line 448 "WindowModule.cs"
                    return false;
                }
#line 449 "WindowModule.cs"
                double* left_ranks = scratch;
#line 450 "WindowModule.cs"
                double* right_ranks = csharp2cuda_pointer_add(scratch, count);
#line 451 "WindowModule.cs"
                mathblocks_statistics_rank(a, count, left_ranks);
#line 452 "WindowModule.cs"
                mathblocks_statistics_rank(b, count, right_ranks);
#line 453 "WindowModule.cs"
#line 453 "WindowModule.cs"
                double* csharp2cuda_temp_33 = value;
                (*(csharp2cuda_temp_33) = mathblocks_statistics_pearson(left_ranks, right_ranks, count));
#line 454 "WindowModule.cs"
                break;
            }
#line 456 "WindowModule.cs"
        case 22:
#line 457 "WindowModule.cs"
            {
#line 458 "WindowModule.cs"
                int slope_count = mathblocks_statistics_pair_slopes(a, b, count, scratch);
#line 459 "WindowModule.cs"
                if (((slope_count) == (0)))
                {
#line 460 "WindowModule.cs"
                    return false;
                }
#line 461 "WindowModule.cs"
#line 461 "WindowModule.cs"
                double* csharp2cuda_temp_34 = value;
#line 461 "WindowModule.cs"
                double csharp2cuda_temp_35 = mathblocks_window_scratch_median(scratch, slope_count);
                (*(csharp2cuda_temp_34) = csharp2cuda_temp_35);
#line 462 "WindowModule.cs"
                break;
            }
#line 464 "WindowModule.cs"
        case 23:
        case 24:
#line 466 "WindowModule.cs"
            return mathblocks_statistics_weighted_value(a, b, count, ((source) == (24)), value);
#line 467 "WindowModule.cs"
        case 25:
#line 468 "WindowModule.cs"
#line 468 "WindowModule.cs"
            double* csharp2cuda_temp_36 = value;
            (*(csharp2cuda_temp_36) = mathblocks_sequence_longest_run_value(flags, count));
#line 469 "WindowModule.cs"
            return true;
#line 470 "WindowModule.cs"
        case 26:
        case 27:
#line 472 "WindowModule.cs"
            return mathblocks_sequence_decline_value(a, count, ((source) == (27)), value);
#line 473 "WindowModule.cs"
        case 28:
#line 474 "WindowModule.cs"
#line 474 "WindowModule.cs"
            double csharp2cuda_temp_37 = (first_parameter)->scalar_value;
            return mathblocks_sequence_variation_value(a, count, csharp2cuda_temp_37, false, value);
#line 475 "WindowModule.cs"
        case 29:
#line 476 "WindowModule.cs"
            return mathblocks_sequence_variation_value(a, count, 2.0, false, value);
#line 477 "WindowModule.cs"
        case 30:
#line 478 "WindowModule.cs"
#line 478 "WindowModule.cs"
            double csharp2cuda_temp_38 = (first_parameter)->scalar_value;
            return mathblocks_sequence_recurrence_value(a, count, csharp2cuda_temp_38, value);
#line 479 "WindowModule.cs"
        case 31:
#line 480 "WindowModule.cs"
            return mathblocks_sequence_variation_value(a, count, 1.0, true, value);
#line 481 "WindowModule.cs"
        case 32:
        case 33:
#line 483 "WindowModule.cs"
#line 483 "WindowModule.cs"
            double* csharp2cuda_temp_39 = value;
            (*(csharp2cuda_temp_39) = mathblocks_sequence_sign_change_value(a, count, ((source) == (32))));
#line 484 "WindowModule.cs"
            return true;
#line 485 "WindowModule.cs"
        case 34:
#line 486 "WindowModule.cs"
#line 486 "WindowModule.cs"
            double* csharp2cuda_temp_40 = value;
#line 489 "WindowModule.cs"
            double csharp2cuda_temp_41 = (first_parameter)->scalar_value;
#line 490 "WindowModule.cs"
            int csharp2cuda_temp_42 = (second_parameter)->boolean_value;
            (*(csharp2cuda_temp_40) = mathblocks_sequence_first_passage_value(a, count, csharp2cuda_temp_41, ((csharp2cuda_temp_42) != (0))));
#line 491 "WindowModule.cs"
            return true;
#line 492 "WindowModule.cs"
        case 35:
        case 36:
        case 37:
        case 38:
        case 39:
#line 497 "WindowModule.cs"
            if ((!(mathblocks_probability_distribution(a, count))))
            {
#line 498 "WindowModule.cs"
                return false;
            }
#line 499 "WindowModule.cs"
            if (((source) == (35)))
#line 500 "WindowModule.cs"
            {
#line 501 "WindowModule.cs"
#line 501 "WindowModule.cs"
                double* csharp2cuda_temp_43 = value;
                (*(csharp2cuda_temp_43) = mathblocks_probability_entropy(a, count));
            }
            else
            {
#line 503 "WindowModule.cs"
                if (((source) == (39)))
#line 504 "WindowModule.cs"
                {
#line 505 "WindowModule.cs"
#line 505 "WindowModule.cs"
                    double* csharp2cuda_temp_44 = value;
#line 505 "WindowModule.cs"
                    double csharp2cuda_temp_45 = __ddiv_rn(mathblocks_probability_entropy(a, count), mathblocks_natural_logarithm(2.0));
                    (*(csharp2cuda_temp_44) = csharp2cuda_temp_45);
                }
                else
                {
#line 508 "WindowModule.cs"
                    if (((source) == (38)))
#line 509 "WindowModule.cs"
                    {
#line 510 "WindowModule.cs"
#line 510 "WindowModule.cs"
                        double* csharp2cuda_temp_46 = value;
                        (*(csharp2cuda_temp_46) = __dsub_rn(1.0, mathblocks_compensated_product_sum(a, a, count)));
                    }
                    else
                    {
#line 512 "WindowModule.cs"
#line 515 "WindowModule.cs"
                        double csharp2cuda_temp_47 = (first_parameter)->scalar_value;
#line 512 "WindowModule.cs"
                        bool csharp2cuda_temp_48 = mathblocks_probability_ordered_entropy_value(a, count, csharp2cuda_temp_47, ((source) == (36)), value);
                        if ((!(csharp2cuda_temp_48)))
#line 518 "WindowModule.cs"
                        {
#line 519 "WindowModule.cs"
                            return false;
                        }
                    }
                }
            }
#line 521 "WindowModule.cs"
            break;
#line 522 "WindowModule.cs"
        case 40:
        case 41:
#line 524 "WindowModule.cs"
            {
#line 525 "WindowModule.cs"
                double sum = mathblocks_compensated_sum(a, count);
#line 526 "WindowModule.cs"
#line 526 "WindowModule.cs"
                double* csharp2cuda_temp_49 = value;
#line 526 "WindowModule.cs"
                double csharp2cuda_temp_50;
#line 526 "WindowModule.cs"
                if (((source) == (41)))
                {
#line 526 "WindowModule.cs"
                    csharp2cuda_temp_50 = __ddiv_rn(sum, ((double)(count)));
                }
                else
                {
#line 526 "WindowModule.cs"
                    csharp2cuda_temp_50 = sum;
                }
                (*(csharp2cuda_temp_49) = csharp2cuda_temp_50);
#line 527 "WindowModule.cs"
                break;
            }
#line 529 "WindowModule.cs"
        case 42:
        case 43:
#line 531 "WindowModule.cs"
            {
#line 532 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 533 "WindowModule.cs"
                    return false;
                }
#line 534 "WindowModule.cs"
                double selected = (a)[0];
#line 535 "WindowModule.cs"
                {
#line 535 "WindowModule.cs"
                    int index = 1;
                    while (true)
                    {
                        if (!(((index) < (count))))
                            break;
#line 536 "WindowModule.cs"
#line 536 "WindowModule.cs"
                        double* csharp2cuda_temp_52 = &(selected);
#line 536 "WindowModule.cs"
                        double csharp2cuda_temp_53;
#line 536 "WindowModule.cs"
                        if (((source) == (43)))
                        {
#line 537 "WindowModule.cs"
                            double csharp2cuda_temp_54 = (a)[index];
#line 536 "WindowModule.cs"
                            csharp2cuda_temp_53 = mathblocks_maximum(selected, csharp2cuda_temp_54);
                        }
                        else
                        {
#line 538 "WindowModule.cs"
                            double csharp2cuda_temp_55 = (a)[index];
#line 536 "WindowModule.cs"
                            csharp2cuda_temp_53 = mathblocks_minimum(selected, csharp2cuda_temp_55);
                        }
                        (*(csharp2cuda_temp_52) = csharp2cuda_temp_53);
#line 535 "WindowModule.cs"
                        int* csharp2cuda_temp_51 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_51));
                    }
                }
#line 539 "WindowModule.cs"
#line 539 "WindowModule.cs"
                double* csharp2cuda_temp_56 = value;
                (*(csharp2cuda_temp_56) = selected);
#line 540 "WindowModule.cs"
                return true;
            }
#line 542 "WindowModule.cs"
        case 44:
#line 543 "WindowModule.cs"
            return mathblocks_vector_geometric_mean_value(a, count, scratch, value);
#line 544 "WindowModule.cs"
        case 45:
#line 545 "WindowModule.cs"
#line 545 "WindowModule.cs"
            double* csharp2cuda_temp_57 = value;
            (*(csharp2cuda_temp_57) = mathblocks_compensated_absolute_sum(a, count));
#line 546 "WindowModule.cs"
            break;
#line 547 "WindowModule.cs"
        case 46:
#line 548 "WindowModule.cs"
#line 548 "WindowModule.cs"
            double* csharp2cuda_temp_58 = value;
            (*(csharp2cuda_temp_58) = mathblocks_square_root(mathblocks_compensated_product_sum(a, a, count)));
#line 549 "WindowModule.cs"
            break;
#line 550 "WindowModule.cs"
        case 47:
        case 48:
#line 552 "WindowModule.cs"
            {
#line 553 "WindowModule.cs"
                double csharp2cuda_temp_59;
#line 553 "WindowModule.cs"
                if (((source) == (47)))
                {
#line 553 "WindowModule.cs"
                    csharp2cuda_temp_59 = 0.5;
                }
                else
                {
#line 553 "WindowModule.cs"
                    csharp2cuda_temp_59 = (first_parameter)->scalar_value;
                }
#line 553 "WindowModule.cs"
                double probability = csharp2cuda_temp_59;
#line 554 "WindowModule.cs"
#line 554 "WindowModule.cs"
                bool csharp2cuda_temp_60;
#line 554 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 554 "WindowModule.cs"
                    csharp2cuda_temp_60 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 554 "WindowModule.cs"
                    csharp2cuda_temp_60 = true;
                }
#line 554 "WindowModule.cs"
                bool csharp2cuda_temp_61;
#line 554 "WindowModule.cs"
                if (!(csharp2cuda_temp_60))
                {
#line 554 "WindowModule.cs"
                    csharp2cuda_temp_61 = ((probability) < (0.0));
                }
                else
                {
#line 554 "WindowModule.cs"
                    csharp2cuda_temp_61 = true;
                }
#line 554 "WindowModule.cs"
                bool csharp2cuda_temp_62;
#line 554 "WindowModule.cs"
                if (!(csharp2cuda_temp_61))
                {
#line 554 "WindowModule.cs"
                    csharp2cuda_temp_62 = ((probability) > (1.0));
                }
                else
                {
#line 554 "WindowModule.cs"
                    csharp2cuda_temp_62 = true;
                }
                if (csharp2cuda_temp_62)
                {
#line 555 "WindowModule.cs"
                    return false;
                }
#line 556 "WindowModule.cs"
#line 556 "WindowModule.cs"
                double* csharp2cuda_temp_63 = value;
#line 556 "WindowModule.cs"
                double csharp2cuda_temp_64 = mathblocks_quantile_values(a, count, scratch, probability);
                (*(csharp2cuda_temp_63) = csharp2cuda_temp_64);
#line 557 "WindowModule.cs"
                break;
            }
#line 559 "WindowModule.cs"
        case 49:
        case 50:
#line 561 "WindowModule.cs"
            return mathblocks_vector_arg_extreme_value(a, count, ((source) == (49)), value);
#line 562 "WindowModule.cs"
        case 51:
#line 563 "WindowModule.cs"
#line 563 "WindowModule.cs"
            double* csharp2cuda_temp_65 = value;
            (*(csharp2cuda_temp_65) = mathblocks_vector_rank_at(a, count, csharp2cuda_i32_sub(count, 1)));
#line 564 "WindowModule.cs"
            return true;
#line 565 "WindowModule.cs"
        case 52:
#line 566 "WindowModule.cs"
            return mathblocks_window_standardize_last(a, count, value);
#line 567 "WindowModule.cs"
        default:
#line 568 "WindowModule.cs"
            return false;
    }
#line 570 "WindowModule.cs"
#line 570 "WindowModule.cs"
    double csharp2cuda_temp_66 = *(value);
    return isfinite(csharp2cuda_temp_66);
}