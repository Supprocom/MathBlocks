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

#line 685 "WindowModule.cs"
__device__ void mathblocks_window_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 273 "WindowModule.cs"
__device__ bool mathblocks_window_distance_correlation(
    const double* left_values,
    const double* right_values,
    int count,
    double* row_means,
    double* value);

#line 248 "WindowModule.cs"
__device__ double mathblocks_window_distance_row_means(
    const double* values,
    int count,
    double* row_means);

#line 218 "WindowModule.cs"
__device__ double* mathblocks_window_merge_sort(double* values, double* buffer, int count);

#line 591 "WindowModule.cs"
__device__ void mathblocks_window_publish(MathBlockSlot* output, bool valid, int count);

#line 606 "WindowModule.cs"
__device__ void mathblocks_window_run(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output,
    int scratch_capacity);

#line 191 "WindowModule.cs"
__device__ long long mathblocks_window_scratch_count(int source, int width);

#line 313 "WindowModule.cs"
__device__ double mathblocks_window_scratch_median(double* scratch, int count);

#line 166 "WindowModule.cs"
__device__ int mathblocks_window_series_count(int source);

#line 133 "WindowModule.cs"
__device__ int mathblocks_window_source_arity(int source);

#line 322 "WindowModule.cs"
__device__ bool mathblocks_window_standardize_last(
    const double* values,
    int count,
    double* value);

#line 344 "WindowModule.cs"
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

#line 685 "WindowModule.cs"
__device__ void mathblocks_window_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 691 "WindowModule.cs"
{
#line 692 "WindowModule.cs"
    mathblocks_window_run(opcode, inputs, input_count, output, csharp2cuda_i32_neg(1));
}

#line 273 "WindowModule.cs"
__device__ bool mathblocks_window_distance_correlation(
    const double* left_values,
    const double* right_values,
    int count,
    double* row_means,
    double* value)
#line 280 "WindowModule.cs"
{
#line 281 "WindowModule.cs"
    if (((count) <= (0)))
    {
#line 282 "WindowModule.cs"
        return false;
    }
#line 283 "WindowModule.cs"
    double* left_means = row_means;
#line 284 "WindowModule.cs"
    double* right_means = csharp2cuda_pointer_add(row_means, count);
#line 285 "WindowModule.cs"
    double left_total = mathblocks_window_distance_row_means(left_values, count, left_means);
#line 286 "WindowModule.cs"
    double right_total = mathblocks_window_distance_row_means(right_values, count, right_means);
#line 287 "WindowModule.cs"
    double covariance_square = 0.0;
#line 288 "WindowModule.cs"
    double left_variance_square = 0.0;
#line 289 "WindowModule.cs"
    double right_variance_square = 0.0;
#line 290 "WindowModule.cs"
    {
#line 290 "WindowModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 291 "WindowModule.cs"
            {
#line 292 "WindowModule.cs"
                {
#line 292 "WindowModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (count))))
                            break;
#line 293 "WindowModule.cs"
                        {
#line 294 "WindowModule.cs"
                            double csharp2cuda_temp_2 = (left_values)[row];
#line 294 "WindowModule.cs"
                            double csharp2cuda_temp_3 = (left_values)[column];
#line 295 "WindowModule.cs"
                            double csharp2cuda_temp_4 = (left_means)[row];
#line 295 "WindowModule.cs"
                            double csharp2cuda_temp_5 = (left_means)[column];
#line 294 "WindowModule.cs"
                            double left = __dsub_rn(fabs(__dsub_rn(csharp2cuda_temp_2, csharp2cuda_temp_3)), __dsub_rn(__dadd_rn(csharp2cuda_temp_4, csharp2cuda_temp_5), left_total));
#line 296 "WindowModule.cs"
                            double csharp2cuda_temp_6 = (right_values)[row];
#line 296 "WindowModule.cs"
                            double csharp2cuda_temp_7 = (right_values)[column];
#line 297 "WindowModule.cs"
                            double csharp2cuda_temp_8 = (right_means)[row];
#line 297 "WindowModule.cs"
                            double csharp2cuda_temp_9 = (right_means)[column];
#line 296 "WindowModule.cs"
                            double right = __dsub_rn(fabs(__dsub_rn(csharp2cuda_temp_6, csharp2cuda_temp_7)), __dsub_rn(__dadd_rn(csharp2cuda_temp_8, csharp2cuda_temp_9), right_total));
#line 298 "WindowModule.cs"
#line 298 "WindowModule.cs"
                            double* csharp2cuda_temp_10 = &(covariance_square);
#line 298 "WindowModule.cs"
                            double csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
                            (*(csharp2cuda_temp_10) = __dadd_rn(csharp2cuda_temp_11, __dmul_rn(left, right)));
#line 299 "WindowModule.cs"
#line 299 "WindowModule.cs"
                            double* csharp2cuda_temp_12 = &(left_variance_square);
#line 299 "WindowModule.cs"
                            double csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
                            (*(csharp2cuda_temp_12) = __dadd_rn(csharp2cuda_temp_13, __dmul_rn(left, left)));
#line 300 "WindowModule.cs"
#line 300 "WindowModule.cs"
                            double* csharp2cuda_temp_14 = &(right_variance_square);
#line 300 "WindowModule.cs"
                            double csharp2cuda_temp_15 = *(csharp2cuda_temp_14);
                            (*(csharp2cuda_temp_14) = __dadd_rn(csharp2cuda_temp_15, __dmul_rn(right, right)));
                        }
#line 292 "WindowModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
            }
#line 290 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 303 "WindowModule.cs"
#line 303 "WindowModule.cs"
    double* csharp2cuda_temp_16 = &(covariance_square);
#line 303 "WindowModule.cs"
    double csharp2cuda_temp_17 = *(csharp2cuda_temp_16);
    (*(csharp2cuda_temp_16) = __ddiv_rn(csharp2cuda_temp_17, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 304 "WindowModule.cs"
#line 304 "WindowModule.cs"
    double* csharp2cuda_temp_18 = &(left_variance_square);
#line 304 "WindowModule.cs"
    double csharp2cuda_temp_19 = *(csharp2cuda_temp_18);
    (*(csharp2cuda_temp_18) = __ddiv_rn(csharp2cuda_temp_19, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 305 "WindowModule.cs"
#line 305 "WindowModule.cs"
    double* csharp2cuda_temp_20 = &(right_variance_square);
#line 305 "WindowModule.cs"
    double csharp2cuda_temp_21 = *(csharp2cuda_temp_20);
    (*(csharp2cuda_temp_20) = __ddiv_rn(csharp2cuda_temp_21, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 306 "WindowModule.cs"
#line 306 "WindowModule.cs"
    double* csharp2cuda_temp_22 = value;
#line 307 "WindowModule.cs"
    double csharp2cuda_temp_23 = __ddiv_rn(covariance_square, mathblocks_square_root(__dmul_rn(left_variance_square, right_variance_square)));
    (*(csharp2cuda_temp_22) = mathblocks_square_root(csharp2cuda_temp_23));
#line 309 "WindowModule.cs"
#line 309 "WindowModule.cs"
    double csharp2cuda_temp_24 = *(value);
    return isfinite(csharp2cuda_temp_24);
}

#line 248 "WindowModule.cs"
__device__ double mathblocks_window_distance_row_means(
    const double* values,
    int count,
    double* row_means)
#line 253 "WindowModule.cs"
{
#line 254 "WindowModule.cs"
    double total_mean = 0.0;
#line 255 "WindowModule.cs"
    {
#line 255 "WindowModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 256 "WindowModule.cs"
            {
#line 257 "WindowModule.cs"
#line 257 "WindowModule.cs"
                double* csharp2cuda_temp_1 = &((row_means)[row]);
                (*(csharp2cuda_temp_1) = 0.0);
#line 258 "WindowModule.cs"
                {
#line 258 "WindowModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (count))))
                            break;
#line 259 "WindowModule.cs"
                        {
#line 260 "WindowModule.cs"
                            double csharp2cuda_temp_3 = (values)[row];
#line 260 "WindowModule.cs"
                            double csharp2cuda_temp_4 = (values)[column];
#line 260 "WindowModule.cs"
                            double distance = fabs(__dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4));
#line 261 "WindowModule.cs"
#line 261 "WindowModule.cs"
                            double* csharp2cuda_temp_5 = &((row_means)[row]);
#line 261 "WindowModule.cs"
                            double csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
                            (*(csharp2cuda_temp_5) = __dadd_rn(csharp2cuda_temp_6, distance));
#line 262 "WindowModule.cs"
#line 262 "WindowModule.cs"
                            double* csharp2cuda_temp_7 = &(total_mean);
#line 262 "WindowModule.cs"
                            double csharp2cuda_temp_8 = *(csharp2cuda_temp_7);
                            (*(csharp2cuda_temp_7) = __dadd_rn(csharp2cuda_temp_8, distance));
                        }
#line 258 "WindowModule.cs"
                        int* csharp2cuda_temp_2 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                    }
                }
#line 264 "WindowModule.cs"
#line 264 "WindowModule.cs"
                double* csharp2cuda_temp_9 = &((row_means)[row]);
#line 264 "WindowModule.cs"
                double csharp2cuda_temp_10 = *(csharp2cuda_temp_9);
                (*(csharp2cuda_temp_9) = __ddiv_rn(csharp2cuda_temp_10, ((double)(count))));
            }
#line 255 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 266 "WindowModule.cs"
#line 266 "WindowModule.cs"
    double* csharp2cuda_temp_11 = &(total_mean);
#line 266 "WindowModule.cs"
    double csharp2cuda_temp_12 = *(csharp2cuda_temp_11);
    (*(csharp2cuda_temp_11) = __ddiv_rn(csharp2cuda_temp_12, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 267 "WindowModule.cs"
    return total_mean;
}

#line 218 "WindowModule.cs"
__device__ double* mathblocks_window_merge_sort(double* values, double* buffer, int count)
#line 220 "WindowModule.cs"
{
#line 221 "WindowModule.cs"
    double* source = values;
#line 222 "WindowModule.cs"
    double* target = buffer;
#line 223 "WindowModule.cs"
    {
#line 223 "WindowModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 224 "WindowModule.cs"
            {
#line 225 "WindowModule.cs"
                {
#line 225 "WindowModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 226 "WindowModule.cs"
                        {
#line 227 "WindowModule.cs"
                            int csharp2cuda_temp_4;
#line 227 "WindowModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 227 "WindowModule.cs"
                                csharp2cuda_temp_4 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 227 "WindowModule.cs"
                                csharp2cuda_temp_4 = count;
                            }
#line 227 "WindowModule.cs"
                            int middle = csharp2cuda_temp_4;
#line 228 "WindowModule.cs"
                            int csharp2cuda_temp_5;
#line 228 "WindowModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 228 "WindowModule.cs"
                                csharp2cuda_temp_5 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 228 "WindowModule.cs"
                                csharp2cuda_temp_5 = count;
                            }
#line 228 "WindowModule.cs"
                            int end = csharp2cuda_temp_5;
#line 229 "WindowModule.cs"
                            int left = start;
#line 230 "WindowModule.cs"
                            int right = middle;
#line 231 "WindowModule.cs"
                            int position = start;
#line 232 "WindowModule.cs"
                            while (true)
                            {
#line 232 "WindowModule.cs"
                                bool csharp2cuda_temp_6;
#line 232 "WindowModule.cs"
                                if (((left) < (middle)))
                                {
#line 232 "WindowModule.cs"
                                    csharp2cuda_temp_6 = ((right) < (end));
                                }
                                else
                                {
#line 232 "WindowModule.cs"
                                    csharp2cuda_temp_6 = false;
                                }
                                if (!(csharp2cuda_temp_6))
                                    break;
#line 233 "WindowModule.cs"
#line 233 "WindowModule.cs"
                                int* csharp2cuda_temp_7 = &(position);
#line 233 "WindowModule.cs"
                                int csharp2cuda_temp_8 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_7));
#line 233 "WindowModule.cs"
                                double* csharp2cuda_temp_9 = &((target)[csharp2cuda_temp_8]);
#line 233 "WindowModule.cs"
                                double csharp2cuda_temp_10 = (source)[right];
#line 233 "WindowModule.cs"
                                double csharp2cuda_temp_11 = (source)[left];
#line 233 "WindowModule.cs"
                                double csharp2cuda_temp_12;
#line 233 "WindowModule.cs"
                                if (((csharp2cuda_temp_10) < (csharp2cuda_temp_11)))
                                {
#line 233 "WindowModule.cs"
                                    int* csharp2cuda_temp_13 = &(right);
#line 233 "WindowModule.cs"
                                    int csharp2cuda_temp_14 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
#line 233 "WindowModule.cs"
                                    csharp2cuda_temp_12 = (source)[csharp2cuda_temp_14];
                                }
                                else
                                {
#line 233 "WindowModule.cs"
                                    int* csharp2cuda_temp_15 = &(left);
#line 233 "WindowModule.cs"
                                    int csharp2cuda_temp_16 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
#line 233 "WindowModule.cs"
                                    csharp2cuda_temp_12 = (source)[csharp2cuda_temp_16];
                                }
                                (*(csharp2cuda_temp_9) = csharp2cuda_temp_12);
                            }
#line 234 "WindowModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 235 "WindowModule.cs"
#line 235 "WindowModule.cs"
                                int* csharp2cuda_temp_17 = &(position);
#line 235 "WindowModule.cs"
                                int csharp2cuda_temp_18 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_17));
#line 235 "WindowModule.cs"
                                double* csharp2cuda_temp_19 = &((target)[csharp2cuda_temp_18]);
#line 235 "WindowModule.cs"
                                int* csharp2cuda_temp_20 = &(left);
#line 235 "WindowModule.cs"
                                int csharp2cuda_temp_21 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_20));
#line 235 "WindowModule.cs"
                                double csharp2cuda_temp_22 = (source)[csharp2cuda_temp_21];
                                (*(csharp2cuda_temp_19) = csharp2cuda_temp_22);
                            }
#line 236 "WindowModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 237 "WindowModule.cs"
#line 237 "WindowModule.cs"
                                int* csharp2cuda_temp_23 = &(position);
#line 237 "WindowModule.cs"
                                int csharp2cuda_temp_24 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_23));
#line 237 "WindowModule.cs"
                                double* csharp2cuda_temp_25 = &((target)[csharp2cuda_temp_24]);
#line 237 "WindowModule.cs"
                                int* csharp2cuda_temp_26 = &(right);
#line 237 "WindowModule.cs"
                                int csharp2cuda_temp_27 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_26));
#line 237 "WindowModule.cs"
                                double csharp2cuda_temp_28 = (source)[csharp2cuda_temp_27];
                                (*(csharp2cuda_temp_25) = csharp2cuda_temp_28);
                            }
                        }
#line 225 "WindowModule.cs"
                        int* csharp2cuda_temp_2 = &(start);
#line 225 "WindowModule.cs"
                        int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                        (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 239 "WindowModule.cs"
                double* sorted = target;
#line 240 "WindowModule.cs"
#line 240 "WindowModule.cs"
                double** csharp2cuda_temp_29 = &(target);
                (*(csharp2cuda_temp_29) = source);
#line 241 "WindowModule.cs"
#line 241 "WindowModule.cs"
                double** csharp2cuda_temp_30 = &(source);
                (*(csharp2cuda_temp_30) = sorted);
            }
#line 223 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(width);
#line 223 "WindowModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, width));
        }
    }
#line 243 "WindowModule.cs"
    return source;
}

#line 591 "WindowModule.cs"
__device__ void mathblocks_window_publish(MathBlockSlot* output, bool valid, int count)
#line 593 "WindowModule.cs"
{
#line 594 "WindowModule.cs"
#line 594 "WindowModule.cs"
    bool csharp2cuda_temp_0;
#line 594 "WindowModule.cs"
    if (!(((blockIdx.x) != (0))))
    {
#line 594 "WindowModule.cs"
        csharp2cuda_temp_0 = ((threadIdx.x) != (0));
    }
    else
    {
#line 594 "WindowModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 595 "WindowModule.cs"
        return;
    }
#line 596 "WindowModule.cs"
#line 596 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &((output)->scalar_value);
    (*(csharp2cuda_temp_1) = 0.0);
#line 597 "WindowModule.cs"
#line 597 "WindowModule.cs"
    int* csharp2cuda_temp_2 = &((output)->boolean_value);
    (*(csharp2cuda_temp_2) = 0);
#line 598 "WindowModule.cs"
#line 598 "WindowModule.cs"
    int* csharp2cuda_temp_3 = &((output)->columns);
    (*(csharp2cuda_temp_3) = 0);
#line 599 "WindowModule.cs"
#line 599 "WindowModule.cs"
    int* csharp2cuda_temp_4 = &((output)->rows);
#line 599 "WindowModule.cs"
    int csharp2cuda_temp_5;
#line 599 "WindowModule.cs"
    if (valid)
    {
#line 599 "WindowModule.cs"
        csharp2cuda_temp_5 = count;
    }
    else
    {
#line 599 "WindowModule.cs"
        csharp2cuda_temp_5 = 0;
    }
    (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
#line 600 "WindowModule.cs"
#line 600 "WindowModule.cs"
    int* csharp2cuda_temp_6 = &((output)->count);
#line 600 "WindowModule.cs"
    int csharp2cuda_temp_7;
#line 600 "WindowModule.cs"
    if (valid)
    {
#line 600 "WindowModule.cs"
        csharp2cuda_temp_7 = count;
    }
    else
    {
#line 600 "WindowModule.cs"
        csharp2cuda_temp_7 = 0;
    }
    (*(csharp2cuda_temp_6) = csharp2cuda_temp_7);
#line 601 "WindowModule.cs"
#line 601 "WindowModule.cs"
    int* csharp2cuda_temp_8 = &((output)->valid);
    (*(csharp2cuda_temp_8) = valid);
}

#line 606 "WindowModule.cs"
__device__ void mathblocks_window_run(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output,
    int scratch_capacity)
#line 613 "WindowModule.cs"
{
#line 614 "WindowModule.cs"
    int source = csharp2cuda_i32_div(opcode, 2);
#line 615 "WindowModule.cs"
    int csharp2cuda_temp_0 = csharp2cuda_i32_rem(opcode, 2);
#line 615 "WindowModule.cs"
    bool sibling = ((csharp2cuda_temp_0) != (0));
#line 616 "WindowModule.cs"
    int arity = mathblocks_window_source_arity(source);
#line 617 "WindowModule.cs"
    int series = mathblocks_window_series_count(source);
#line 618 "WindowModule.cs"
    bool csharp2cuda_temp_1;
#line 618 "WindowModule.cs"
    if (((opcode) >= (0)))
    {
#line 618 "WindowModule.cs"
        csharp2cuda_temp_1 = ((source) < (53));
    }
    else
    {
#line 618 "WindowModule.cs"
        csharp2cuda_temp_1 = false;
    }
#line 618 "WindowModule.cs"
    bool csharp2cuda_temp_2;
#line 618 "WindowModule.cs"
    if (csharp2cuda_temp_1)
    {
#line 618 "WindowModule.cs"
        int csharp2cuda_temp_3;
#line 618 "WindowModule.cs"
        if (sibling)
        {
#line 618 "WindowModule.cs"
            csharp2cuda_temp_3 = 1;
        }
        else
        {
#line 618 "WindowModule.cs"
            csharp2cuda_temp_3 = 2;
        }
#line 618 "WindowModule.cs"
        csharp2cuda_temp_2 = ((input_count) == (csharp2cuda_i32_add(arity, csharp2cuda_temp_3)));
    }
    else
    {
#line 618 "WindowModule.cs"
        csharp2cuda_temp_2 = false;
    }
#line 618 "WindowModule.cs"
    bool valid = csharp2cuda_temp_2;
#line 619 "WindowModule.cs"
    {
#line 619 "WindowModule.cs"
        int index = 0;
        while (true)
        {
#line 619 "WindowModule.cs"
            bool csharp2cuda_temp_5;
#line 619 "WindowModule.cs"
            if (valid)
            {
#line 619 "WindowModule.cs"
                csharp2cuda_temp_5 = ((index) < (input_count));
            }
            else
            {
#line 619 "WindowModule.cs"
                csharp2cuda_temp_5 = false;
            }
            if (!(csharp2cuda_temp_5))
                break;
#line 620 "WindowModule.cs"
#line 620 "WindowModule.cs"
            MathBlockSlot* csharp2cuda_temp_6 = (inputs)[index];
#line 620 "WindowModule.cs"
            bool csharp2cuda_temp_7;
#line 620 "WindowModule.cs"
            if (!(((((void*)(csharp2cuda_temp_6))) == (((void*)(nullptr))))))
            {
#line 620 "WindowModule.cs"
                MathBlockSlot* csharp2cuda_temp_8 = (inputs)[index];
#line 620 "WindowModule.cs"
                bool csharp2cuda_temp_9 = (csharp2cuda_temp_8)->valid;
#line 620 "WindowModule.cs"
                csharp2cuda_temp_7 = (!(csharp2cuda_temp_9));
            }
            else
            {
#line 620 "WindowModule.cs"
                csharp2cuda_temp_7 = true;
            }
            if (csharp2cuda_temp_7)
            {
#line 621 "WindowModule.cs"
#line 621 "WindowModule.cs"
                bool* csharp2cuda_temp_10 = &(valid);
                (*(csharp2cuda_temp_10) = false);
            }
#line 619 "WindowModule.cs"
            int* csharp2cuda_temp_4 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
        }
    }
#line 622 "WindowModule.cs"
    if ((!(valid)))
#line 623 "WindowModule.cs"
    {
#line 624 "WindowModule.cs"
        mathblocks_window_publish(output, false, 0);
#line 625 "WindowModule.cs"
        return;
    }
#line 628 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_11;
#line 628 "WindowModule.cs"
    if (((input_count) > (0)))
    {
#line 628 "WindowModule.cs"
        csharp2cuda_temp_11 = (inputs)[0];
    }
    else
    {
#line 628 "WindowModule.cs"
        csharp2cuda_temp_11 = ((MathBlockSlot*)(nullptr));
    }
#line 628 "WindowModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_11;
#line 629 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_12;
#line 629 "WindowModule.cs"
    if (((series) > (1)))
    {
#line 629 "WindowModule.cs"
        csharp2cuda_temp_12 = (inputs)[1];
    }
    else
    {
#line 629 "WindowModule.cs"
        csharp2cuda_temp_12 = ((MathBlockSlot*)(nullptr));
    }
#line 629 "WindowModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_12;
#line 630 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_13;
#line 630 "WindowModule.cs"
    if (((arity) > (series)))
    {
#line 630 "WindowModule.cs"
        csharp2cuda_temp_13 = (inputs)[series];
    }
    else
    {
#line 630 "WindowModule.cs"
        csharp2cuda_temp_13 = ((MathBlockSlot*)(nullptr));
    }
#line 630 "WindowModule.cs"
    const MathBlockSlot* first_parameter = csharp2cuda_temp_13;
#line 631 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_14;
#line 631 "WindowModule.cs"
    if (((arity) > (csharp2cuda_i32_add(series, 1))))
    {
#line 631 "WindowModule.cs"
        csharp2cuda_temp_14 = (inputs)[csharp2cuda_i32_add(series, 1)];
    }
    else
    {
#line 631 "WindowModule.cs"
        csharp2cuda_temp_14 = ((MathBlockSlot*)(nullptr));
    }
#line 631 "WindowModule.cs"
    const MathBlockSlot* second_parameter = csharp2cuda_temp_14;
#line 632 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_15 = (inputs)[arity];
#line 632 "WindowModule.cs"
    const MathBlockSlot* width_input = csharp2cuda_temp_15;
#line 633 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_16;
#line 633 "WindowModule.cs"
    if (sibling)
    {
#line 633 "WindowModule.cs"
        csharp2cuda_temp_16 = ((MathBlockSlot*)(nullptr));
    }
    else
    {
#line 633 "WindowModule.cs"
        csharp2cuda_temp_16 = (inputs)[csharp2cuda_i32_add(arity, 1)];
    }
#line 633 "WindowModule.cs"
    const MathBlockSlot* fill_input = csharp2cuda_temp_16;
#line 634 "WindowModule.cs"
    int count = (first)->count;
#line 635 "WindowModule.cs"
    int width = 0;
#line 636 "WindowModule.cs"
#line 636 "WindowModule.cs"
    bool csharp2cuda_temp_17;
#line 636 "WindowModule.cs"
    if (((((void*)(second))) != (((void*)(nullptr)))))
    {
#line 636 "WindowModule.cs"
        int csharp2cuda_temp_18 = (second)->count;
#line 636 "WindowModule.cs"
        csharp2cuda_temp_17 = ((csharp2cuda_temp_18) != (count));
    }
    else
    {
#line 636 "WindowModule.cs"
        csharp2cuda_temp_17 = false;
    }
    if (csharp2cuda_temp_17)
    {
#line 637 "WindowModule.cs"
#line 637 "WindowModule.cs"
        bool* csharp2cuda_temp_19 = &(valid);
        (*(csharp2cuda_temp_19) = false);
    }
#line 638 "WindowModule.cs"
#line 638 "WindowModule.cs"
    double csharp2cuda_temp_20 = (width_input)->scalar_value;
#line 638 "WindowModule.cs"
    int* csharp2cuda_temp_21 = &(width);
#line 638 "WindowModule.cs"
    bool csharp2cuda_temp_22 = mathblocks_sequence_positive_integer(csharp2cuda_temp_20, csharp2cuda_temp_21);
#line 638 "WindowModule.cs"
    bool csharp2cuda_temp_23;
#line 638 "WindowModule.cs"
    if (!((!(csharp2cuda_temp_22))))
    {
#line 638 "WindowModule.cs"
        csharp2cuda_temp_23 = ((width) > (count));
    }
    else
    {
#line 638 "WindowModule.cs"
        csharp2cuda_temp_23 = true;
    }
    if (csharp2cuda_temp_23)
    {
#line 639 "WindowModule.cs"
#line 639 "WindowModule.cs"
        bool* csharp2cuda_temp_24 = &(valid);
        (*(csharp2cuda_temp_24) = false);
    }
#line 640 "WindowModule.cs"
#line 640 "WindowModule.cs"
    int csharp2cuda_temp_25 = (output)->capacity;
    if (((count) > (csharp2cuda_temp_25)))
    {
#line 641 "WindowModule.cs"
#line 641 "WindowModule.cs"
        bool* csharp2cuda_temp_26 = &(valid);
        (*(csharp2cuda_temp_26) = false);
    }
#line 642 "WindowModule.cs"
    long long csharp2cuda_temp_27;
#line 642 "WindowModule.cs"
    if (valid)
    {
#line 642 "WindowModule.cs"
        csharp2cuda_temp_27 = mathblocks_window_scratch_count(source, width);
    }
    else
    {
#line 642 "WindowModule.cs"
        csharp2cuda_temp_27 = ((long long)(0));
    }
#line 642 "WindowModule.cs"
    long long required = csharp2cuda_temp_27;
#line 643 "WindowModule.cs"
    long long csharp2cuda_temp_28;
#line 643 "WindowModule.cs"
    if (((scratch_capacity) < (0)))
    {
#line 643 "WindowModule.cs"
        csharp2cuda_temp_28 = required;
    }
    else
    {
#line 643 "WindowModule.cs"
        csharp2cuda_temp_28 = ((long long)(scratch_capacity));
    }
#line 643 "WindowModule.cs"
    long long capacity = csharp2cuda_temp_28;
#line 644 "WindowModule.cs"
#line 644 "WindowModule.cs"
    bool csharp2cuda_temp_29;
#line 644 "WindowModule.cs"
    if (!(((required) > (capacity))))
    {
#line 644 "WindowModule.cs"
        bool csharp2cuda_temp_30;
#line 644 "WindowModule.cs"
        if (((required) > (((long long)(0)))))
        {
#line 644 "WindowModule.cs"
            unsigned long long csharp2cuda_temp_31 = (output)->scratch_pointer;
#line 644 "WindowModule.cs"
            csharp2cuda_temp_30 = ((csharp2cuda_temp_31) == (((unsigned long long)(0))));
        }
        else
        {
#line 644 "WindowModule.cs"
            csharp2cuda_temp_30 = false;
        }
#line 644 "WindowModule.cs"
        csharp2cuda_temp_29 = csharp2cuda_temp_30;
    }
    else
    {
#line 644 "WindowModule.cs"
        csharp2cuda_temp_29 = true;
    }
    if (csharp2cuda_temp_29)
    {
#line 645 "WindowModule.cs"
#line 645 "WindowModule.cs"
        bool* csharp2cuda_temp_32 = &(valid);
        (*(csharp2cuda_temp_32) = false);
    }
#line 646 "WindowModule.cs"
    mathblocks_window_publish(output, valid, count);
#line 647 "WindowModule.cs"
    if ((!(valid)))
    {
#line 648 "WindowModule.cs"
        return;
    }
#line 650 "WindowModule.cs"
    double csharp2cuda_temp_33;
#line 650 "WindowModule.cs"
    if (sibling)
    {
#line 650 "WindowModule.cs"
        csharp2cuda_temp_33 = 0.0;
    }
    else
    {
#line 650 "WindowModule.cs"
        csharp2cuda_temp_33 = (fill_input)->scalar_value;
    }
#line 650 "WindowModule.cs"
    double fill = csharp2cuda_temp_33;
#line 651 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_34 = (first)->data_pointer;
#line 651 "WindowModule.cs"
    const double* a = ((double*)(csharp2cuda_temp_34));
#line 652 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_35 = (first)->data_pointer;
#line 652 "WindowModule.cs"
    const int* flags = ((int*)(csharp2cuda_temp_35));
#line 653 "WindowModule.cs"
    double* csharp2cuda_temp_36;
#line 653 "WindowModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 653 "WindowModule.cs"
        csharp2cuda_temp_36 = ((double*)(nullptr));
    }
    else
    {
#line 653 "WindowModule.cs"
        unsigned long long csharp2cuda_temp_37 = (second)->data_pointer;
#line 653 "WindowModule.cs"
        csharp2cuda_temp_36 = ((double*)(csharp2cuda_temp_37));
    }
#line 653 "WindowModule.cs"
    const double* b = csharp2cuda_temp_36;
#line 654 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_38 = (output)->data_pointer;
#line 654 "WindowModule.cs"
    double* result = ((double*)(csharp2cuda_temp_38));
#line 655 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_39 = (output)->data_pointer;
#line 655 "WindowModule.cs"
    int* boolean_result = ((int*)(csharp2cuda_temp_39));
#line 656 "WindowModule.cs"
    int thread = csharp2cuda_i32_add(csharp2cuda_i32_mul(blockIdx.x, blockDim.x), threadIdx.x);
#line 657 "WindowModule.cs"
    int threads = csharp2cuda_i32_mul(gridDim.x, blockDim.x);
#line 658 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_40 = (output)->scratch_pointer;
#line 658 "WindowModule.cs"
    double* scratch = csharp2cuda_pointer_add(((double*)(csharp2cuda_temp_40)), csharp2cuda_i32_mul(thread, csharp2cuda_i32_from_bits(capacity)));
#line 659 "WindowModule.cs"
    {
#line 659 "WindowModule.cs"
        int end = thread;
        while (true)
        {
            if (!(((end) < (count))))
                break;
#line 660 "WindowModule.cs"
            {
#line 661 "WindowModule.cs"
                bool row_valid = false;
#line 662 "WindowModule.cs"
                double value = 0.0;
#line 663 "WindowModule.cs"
                if (((end) >= (csharp2cuda_i32_sub(width, 1))))
#line 664 "WindowModule.cs"
                {
#line 666 "WindowModule.cs"
                    int start = csharp2cuda_i32_add(csharp2cuda_i32_sub(end, width), 1);
#line 667 "WindowModule.cs"
#line 667 "WindowModule.cs"
                    bool* csharp2cuda_temp_43 = &(row_valid);
#line 676 "WindowModule.cs"
                    double* csharp2cuda_temp_44 = &(value);
#line 667 "WindowModule.cs"
                    bool csharp2cuda_temp_45 = mathblocks_window_value(source, csharp2cuda_pointer_add(a, start), csharp2cuda_pointer_add(b, start), csharp2cuda_pointer_add(flags, start), width, first_parameter, second_parameter, scratch, csharp2cuda_temp_44);
                    (*(csharp2cuda_temp_43) = csharp2cuda_temp_45);
                }
#line 678 "WindowModule.cs"
                if (sibling)
                {
#line 679 "WindowModule.cs"
#line 679 "WindowModule.cs"
                    int* csharp2cuda_temp_46 = &((boolean_result)[end]);
                    (*(csharp2cuda_temp_46) = row_valid);
                }
                else
                {
#line 681 "WindowModule.cs"
#line 681 "WindowModule.cs"
                    double* csharp2cuda_temp_47 = &((result)[end]);
#line 681 "WindowModule.cs"
                    double csharp2cuda_temp_48;
#line 681 "WindowModule.cs"
                    if (row_valid)
                    {
#line 681 "WindowModule.cs"
                        csharp2cuda_temp_48 = value;
                    }
                    else
                    {
#line 681 "WindowModule.cs"
                        csharp2cuda_temp_48 = fill;
                    }
                    (*(csharp2cuda_temp_47) = csharp2cuda_temp_48);
                }
            }
#line 659 "WindowModule.cs"
            int* csharp2cuda_temp_41 = &(end);
#line 659 "WindowModule.cs"
            int csharp2cuda_temp_42 = *(csharp2cuda_temp_41);
            (*(csharp2cuda_temp_41) = csharp2cuda_i32_add(csharp2cuda_temp_42, threads));
        }
    }
}

#line 191 "WindowModule.cs"
__device__ long long mathblocks_window_scratch_count(int source, int width)
#line 193 "WindowModule.cs"
{
#line 194 "WindowModule.cs"
    long long count = ((long long)(width));
#line 195 "WindowModule.cs"
    switch (source)
    {
#line 197 "WindowModule.cs"
        case 3:
        case 44:
        case 47:
        case 48:
#line 201 "WindowModule.cs"
            return count;
#line 202 "WindowModule.cs"
        case 2:
        case 8:
        case 21:
#line 205 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, ((long long)(2)));
#line 206 "WindowModule.cs"
        case 22:
#line 207 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, csharp2cuda_i64_sub(count, ((long long)(1))));
#line 208 "WindowModule.cs"
        case 15:
#line 209 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, csharp2cuda_i64_add(count, ((long long)(1))));
#line 210 "WindowModule.cs"
        default:
#line 211 "WindowModule.cs"
            return ((long long)(0));
    }
}

#line 313 "WindowModule.cs"
__device__ double mathblocks_window_scratch_median(double* scratch, int count)
#line 315 "WindowModule.cs"
{
#line 316 "WindowModule.cs"
    double* sorted = mathblocks_window_merge_sort(scratch, csharp2cuda_pointer_add(scratch, count), count);
#line 317 "WindowModule.cs"
    return mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
}

#line 166 "WindowModule.cs"
__device__ int mathblocks_window_series_count(int source)
#line 168 "WindowModule.cs"
{
#line 169 "WindowModule.cs"
    switch (source)
    {
#line 171 "WindowModule.cs"
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
#line 183 "WindowModule.cs"
            return 2;
#line 184 "WindowModule.cs"
        default:
#line 185 "WindowModule.cs"
            return 1;
    }
}

#line 133 "WindowModule.cs"
__device__ int mathblocks_window_source_arity(int source)
#line 135 "WindowModule.cs"
{
#line 136 "WindowModule.cs"
    switch (source)
    {
#line 138 "WindowModule.cs"
        case 34:
#line 139 "WindowModule.cs"
            return 3;
#line 140 "WindowModule.cs"
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
#line 160 "WindowModule.cs"
            return 2;
#line 161 "WindowModule.cs"
        default:
#line 162 "WindowModule.cs"
            return 1;
    }
}

#line 322 "WindowModule.cs"
__device__ bool mathblocks_window_standardize_last(
    const double* values,
    int count,
    double* value)
#line 327 "WindowModule.cs"
{
#line 328 "WindowModule.cs"
    if (((count) <= (0)))
    {
#line 329 "WindowModule.cs"
        return false;
    }
#line 330 "WindowModule.cs"
    double mean = 0.0;
#line 331 "WindowModule.cs"
    double deviation = 0.0;
#line 332 "WindowModule.cs"
#line 332 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &(mean);
#line 332 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(deviation);
    mathblocks_vector_standardize_moments(values, count, csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 333 "WindowModule.cs"
    {
#line 333 "WindowModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 334 "WindowModule.cs"
#line 334 "WindowModule.cs"
            double csharp2cuda_temp_3 = (values)[index];
#line 334 "WindowModule.cs"
            double csharp2cuda_temp_4 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_3, mean), deviation);
            if ((!(isfinite(csharp2cuda_temp_4))))
            {
#line 335 "WindowModule.cs"
                return false;
            }
#line 333 "WindowModule.cs"
            int* csharp2cuda_temp_2 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 336 "WindowModule.cs"
#line 336 "WindowModule.cs"
    double* csharp2cuda_temp_5 = value;
#line 336 "WindowModule.cs"
    double csharp2cuda_temp_6 = (values)[csharp2cuda_i32_sub(count, 1)];
#line 336 "WindowModule.cs"
    double csharp2cuda_temp_7 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_6, mean), deviation);
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_7);
#line 337 "WindowModule.cs"
    return true;
}

#line 344 "WindowModule.cs"
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
#line 355 "WindowModule.cs"
{
#line 356 "WindowModule.cs"
    switch (source)
    {
#line 358 "WindowModule.cs"
        case 0:
#line 359 "WindowModule.cs"
            {
#line 360 "WindowModule.cs"
                int lag = 0;
#line 361 "WindowModule.cs"
#line 361 "WindowModule.cs"
                double csharp2cuda_temp_0 = (first_parameter)->scalar_value;
#line 361 "WindowModule.cs"
                int* csharp2cuda_temp_1 = &(lag);
#line 361 "WindowModule.cs"
                bool csharp2cuda_temp_2 = mathblocks_sequence_positive_integer(csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 361 "WindowModule.cs"
                bool csharp2cuda_temp_3;
#line 361 "WindowModule.cs"
                if (!((!(csharp2cuda_temp_2))))
                {
#line 361 "WindowModule.cs"
                    csharp2cuda_temp_3 = ((lag) >= (count));
                }
                else
                {
#line 361 "WindowModule.cs"
                    csharp2cuda_temp_3 = true;
                }
                if (csharp2cuda_temp_3)
                {
#line 362 "WindowModule.cs"
                    return false;
                }
#line 363 "WindowModule.cs"
#line 363 "WindowModule.cs"
                double* csharp2cuda_temp_4 = value;
                (*(csharp2cuda_temp_4) = mathblocks_statistics_pearson(a, csharp2cuda_pointer_add(a, lag), csharp2cuda_i32_sub(count, lag)));
#line 364 "WindowModule.cs"
                break;
            }
#line 366 "WindowModule.cs"
        case 1:
        case 16:
#line 368 "WindowModule.cs"
#line 368 "WindowModule.cs"
            double csharp2cuda_temp_5 = (first_parameter)->scalar_value;
            return mathblocks_statistics_moment_value(a, count, csharp2cuda_temp_5, ((source) == (1)), value);
#line 369 "WindowModule.cs"
        case 2:
#line 370 "WindowModule.cs"
            return mathblocks_window_distance_correlation(a, b, count, scratch, value);
#line 371 "WindowModule.cs"
        case 3:
#line 372 "WindowModule.cs"
#line 372 "WindowModule.cs"
            bool csharp2cuda_temp_6;
#line 372 "WindowModule.cs"
            if (!(((count) <= (0))))
            {
#line 372 "WindowModule.cs"
                csharp2cuda_temp_6 = ((((void*)(scratch))) == (((void*)(nullptr))));
            }
            else
            {
#line 372 "WindowModule.cs"
                csharp2cuda_temp_6 = true;
            }
            if (csharp2cuda_temp_6)
            {
#line 373 "WindowModule.cs"
                return false;
            }
#line 374 "WindowModule.cs"
            mathblocks_statistics_sort_copy(a, count, scratch);
#line 375 "WindowModule.cs"
#line 375 "WindowModule.cs"
            double* csharp2cuda_temp_7 = value;
            (*(csharp2cuda_temp_7) = __dsub_rn(mathblocks_statistics_sorted_quantile(scratch, count, 0.75), mathblocks_statistics_sorted_quantile(scratch, count, 0.25)));
#line 378 "WindowModule.cs"
            break;
#line 379 "WindowModule.cs"
        case 4:
#line 380 "WindowModule.cs"
            return mathblocks_statistics_kendall_value(a, b, count, value);
#line 381 "WindowModule.cs"
        case 5:
        case 6:
        case 7:
        case 9:
        case 10:
        case 18:
#line 387 "WindowModule.cs"
            {
#line 388 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 389 "WindowModule.cs"
                    return false;
                }
#line 390 "WindowModule.cs"
                double covariance = mathblocks_statistics_population_covariance(a, b, count);
#line 391 "WindowModule.cs"
#line 391 "WindowModule.cs"
                bool csharp2cuda_temp_8;
#line 391 "WindowModule.cs"
                if (!(((source) == (10))))
                {
#line 391 "WindowModule.cs"
                    csharp2cuda_temp_8 = ((source) == (18));
                }
                else
                {
#line 391 "WindowModule.cs"
                    csharp2cuda_temp_8 = true;
                }
                if (csharp2cuda_temp_8)
#line 392 "WindowModule.cs"
                {
#line 393 "WindowModule.cs"
#line 393 "WindowModule.cs"
                    double* csharp2cuda_temp_9 = value;
#line 393 "WindowModule.cs"
                    double csharp2cuda_temp_10;
#line 393 "WindowModule.cs"
                    if (((source) == (10)))
                    {
#line 393 "WindowModule.cs"
                        csharp2cuda_temp_10 = covariance;
                    }
                    else
                    {
#line 393 "WindowModule.cs"
                        csharp2cuda_temp_10 = __ddiv_rn(__dmul_rn(covariance, ((double)(count))), __dsub_rn(((double)(count)), 1.0));
                    }
                    (*(csharp2cuda_temp_9) = csharp2cuda_temp_10);
                }
                else
                {
#line 397 "WindowModule.cs"
                    if (((source) == (7)))
#line 398 "WindowModule.cs"
                    {
#line 399 "WindowModule.cs"
#line 399 "WindowModule.cs"
                        double* csharp2cuda_temp_11 = value;
#line 399 "WindowModule.cs"
                        double csharp2cuda_temp_12 = __ddiv_rn(covariance, mathblocks_statistics_population_variance(a, count));
                        (*(csharp2cuda_temp_11) = csharp2cuda_temp_12);
                    }
                    else
                    {
#line 402 "WindowModule.cs"
                        if (((source) == (5)))
#line 403 "WindowModule.cs"
                        {
#line 404 "WindowModule.cs"
                            double slope = __ddiv_rn(covariance, mathblocks_statistics_population_variance(a, count));
#line 406 "WindowModule.cs"
#line 406 "WindowModule.cs"
                            double* csharp2cuda_temp_13 = value;
                            (*(csharp2cuda_temp_13) = __dsub_rn(mathblocks_statistics_mean(b, count), __dmul_rn(slope, mathblocks_statistics_mean(a, count))));
                        }
                        else
#line 410 "WindowModule.cs"
                        {
#line 411 "WindowModule.cs"
                            double correlation = __ddiv_rn(covariance, __dmul_rn(mathblocks_square_root(mathblocks_statistics_population_variance(a, count)), mathblocks_square_root(mathblocks_statistics_population_variance(b, count))));
#line 414 "WindowModule.cs"
#line 414 "WindowModule.cs"
                            double* csharp2cuda_temp_14 = value;
#line 414 "WindowModule.cs"
                            double csharp2cuda_temp_15;
#line 414 "WindowModule.cs"
                            if (((source) == (6)))
                            {
#line 414 "WindowModule.cs"
                                csharp2cuda_temp_15 = __dmul_rn(correlation, correlation);
                            }
                            else
                            {
#line 414 "WindowModule.cs"
                                csharp2cuda_temp_15 = correlation;
                            }
                            (*(csharp2cuda_temp_14) = csharp2cuda_temp_15);
                        }
                    }
                }
#line 416 "WindowModule.cs"
                break;
            }
#line 418 "WindowModule.cs"
        case 8:
#line 419 "WindowModule.cs"
            {
#line 420 "WindowModule.cs"
#line 420 "WindowModule.cs"
                bool csharp2cuda_temp_16;
#line 420 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 420 "WindowModule.cs"
                    csharp2cuda_temp_16 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 420 "WindowModule.cs"
                    csharp2cuda_temp_16 = true;
                }
                if (csharp2cuda_temp_16)
                {
#line 421 "WindowModule.cs"
                    return false;
                }
#line 422 "WindowModule.cs"
                double* sorted = scratch;
#line 423 "WindowModule.cs"
                double* deviations = csharp2cuda_pointer_add(scratch, count);
#line 424 "WindowModule.cs"
                mathblocks_statistics_sort_copy(a, count, sorted);
#line 425 "WindowModule.cs"
                double median = mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
#line 426 "WindowModule.cs"
                {
#line 426 "WindowModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (count))))
                            break;
#line 427 "WindowModule.cs"
#line 427 "WindowModule.cs"
                        double* csharp2cuda_temp_18 = &((deviations)[index]);
#line 427 "WindowModule.cs"
                        double csharp2cuda_temp_19 = (a)[index];
                        (*(csharp2cuda_temp_18) = fabs(__dsub_rn(csharp2cuda_temp_19, median)));
#line 426 "WindowModule.cs"
                        int* csharp2cuda_temp_17 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_17));
                    }
                }
#line 428 "WindowModule.cs"
                mathblocks_statistics_sort_copy(deviations, count, sorted);
#line 429 "WindowModule.cs"
#line 429 "WindowModule.cs"
                double* csharp2cuda_temp_20 = value;
                (*(csharp2cuda_temp_20) = mathblocks_statistics_sorted_quantile(sorted, count, 0.5));
#line 430 "WindowModule.cs"
                break;
            }
#line 432 "WindowModule.cs"
        case 11:
        case 12:
#line 434 "WindowModule.cs"
            return mathblocks_statistics_shape_moment_value(a, count, ((source) == (11)), value);
#line 435 "WindowModule.cs"
        case 13:
        case 14:
        case 19:
        case 20:
#line 439 "WindowModule.cs"
            {
#line 440 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 441 "WindowModule.cs"
                    return false;
                }
#line 442 "WindowModule.cs"
                double variance = mathblocks_statistics_population_variance(a, count);
#line 443 "WindowModule.cs"
#line 443 "WindowModule.cs"
                bool csharp2cuda_temp_21;
#line 443 "WindowModule.cs"
                if (!(((source) == (19))))
                {
#line 443 "WindowModule.cs"
                    csharp2cuda_temp_21 = ((source) == (20));
                }
                else
                {
#line 443 "WindowModule.cs"
                    csharp2cuda_temp_21 = true;
                }
                if (csharp2cuda_temp_21)
                {
#line 444 "WindowModule.cs"
#line 444 "WindowModule.cs"
                    double* csharp2cuda_temp_22 = &(variance);
#line 444 "WindowModule.cs"
                    double csharp2cuda_temp_23 = __ddiv_rn(__dmul_rn(variance, ((double)(count))), __dsub_rn(((double)(count)), 1.0));
                    (*(csharp2cuda_temp_22) = csharp2cuda_temp_23);
                }
#line 445 "WindowModule.cs"
#line 445 "WindowModule.cs"
                double* csharp2cuda_temp_24 = value;
#line 445 "WindowModule.cs"
                bool csharp2cuda_temp_25;
#line 445 "WindowModule.cs"
                if (!(((source) == (13))))
                {
#line 445 "WindowModule.cs"
                    csharp2cuda_temp_25 = ((source) == (19));
                }
                else
                {
#line 445 "WindowModule.cs"
                    csharp2cuda_temp_25 = true;
                }
#line 445 "WindowModule.cs"
                double csharp2cuda_temp_26;
#line 445 "WindowModule.cs"
                if (csharp2cuda_temp_25)
                {
#line 445 "WindowModule.cs"
                    csharp2cuda_temp_26 = mathblocks_square_root(variance);
                }
                else
                {
#line 445 "WindowModule.cs"
                    csharp2cuda_temp_26 = variance;
                }
                (*(csharp2cuda_temp_24) = csharp2cuda_temp_26);
#line 448 "WindowModule.cs"
                break;
            }
#line 450 "WindowModule.cs"
        case 15:
#line 451 "WindowModule.cs"
            {
#line 452 "WindowModule.cs"
#line 452 "WindowModule.cs"
                bool csharp2cuda_temp_27;
#line 452 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 452 "WindowModule.cs"
                    csharp2cuda_temp_27 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 452 "WindowModule.cs"
                    csharp2cuda_temp_27 = true;
                }
                if (csharp2cuda_temp_27)
                {
#line 453 "WindowModule.cs"
                    return false;
                }
#line 454 "WindowModule.cs"
                int average_count = mathblocks_statistics_pair_averages(a, count, scratch);
#line 455 "WindowModule.cs"
#line 455 "WindowModule.cs"
                double* csharp2cuda_temp_28 = value;
#line 455 "WindowModule.cs"
                double csharp2cuda_temp_29 = mathblocks_window_scratch_median(scratch, average_count);
                (*(csharp2cuda_temp_28) = csharp2cuda_temp_29);
#line 456 "WindowModule.cs"
                break;
            }
#line 458 "WindowModule.cs"
        case 17:
#line 459 "WindowModule.cs"
#line 459 "WindowModule.cs"
            double* csharp2cuda_temp_30 = value;
#line 460 "WindowModule.cs"
            double csharp2cuda_temp_31 = __ddiv_rn(mathblocks_compensated_product_sum(a, a, count), ((double)(count)));
            (*(csharp2cuda_temp_30) = mathblocks_square_root(csharp2cuda_temp_31));
#line 461 "WindowModule.cs"
            break;
#line 462 "WindowModule.cs"
        case 21:
#line 463 "WindowModule.cs"
            {
#line 464 "WindowModule.cs"
#line 464 "WindowModule.cs"
                bool csharp2cuda_temp_32;
#line 464 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 464 "WindowModule.cs"
                    csharp2cuda_temp_32 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 464 "WindowModule.cs"
                    csharp2cuda_temp_32 = true;
                }
                if (csharp2cuda_temp_32)
                {
#line 465 "WindowModule.cs"
                    return false;
                }
#line 466 "WindowModule.cs"
                double* left_ranks = scratch;
#line 467 "WindowModule.cs"
                double* right_ranks = csharp2cuda_pointer_add(scratch, count);
#line 468 "WindowModule.cs"
                mathblocks_statistics_rank(a, count, left_ranks);
#line 469 "WindowModule.cs"
                mathblocks_statistics_rank(b, count, right_ranks);
#line 470 "WindowModule.cs"
#line 470 "WindowModule.cs"
                double* csharp2cuda_temp_33 = value;
                (*(csharp2cuda_temp_33) = mathblocks_statistics_pearson(left_ranks, right_ranks, count));
#line 471 "WindowModule.cs"
                break;
            }
#line 473 "WindowModule.cs"
        case 22:
#line 474 "WindowModule.cs"
            {
#line 475 "WindowModule.cs"
                int slope_count = mathblocks_statistics_pair_slopes(a, b, count, scratch);
#line 476 "WindowModule.cs"
                if (((slope_count) == (0)))
                {
#line 477 "WindowModule.cs"
                    return false;
                }
#line 478 "WindowModule.cs"
#line 478 "WindowModule.cs"
                double* csharp2cuda_temp_34 = value;
#line 478 "WindowModule.cs"
                double csharp2cuda_temp_35 = mathblocks_window_scratch_median(scratch, slope_count);
                (*(csharp2cuda_temp_34) = csharp2cuda_temp_35);
#line 479 "WindowModule.cs"
                break;
            }
#line 481 "WindowModule.cs"
        case 23:
        case 24:
#line 483 "WindowModule.cs"
            return mathblocks_statistics_weighted_value(a, b, count, ((source) == (24)), value);
#line 484 "WindowModule.cs"
        case 25:
#line 485 "WindowModule.cs"
#line 485 "WindowModule.cs"
            double* csharp2cuda_temp_36 = value;
            (*(csharp2cuda_temp_36) = mathblocks_sequence_longest_run_value(flags, count));
#line 486 "WindowModule.cs"
            return true;
#line 487 "WindowModule.cs"
        case 26:
        case 27:
#line 489 "WindowModule.cs"
            return mathblocks_sequence_decline_value(a, count, ((source) == (27)), value);
#line 490 "WindowModule.cs"
        case 28:
#line 491 "WindowModule.cs"
#line 491 "WindowModule.cs"
            double csharp2cuda_temp_37 = (first_parameter)->scalar_value;
            return mathblocks_sequence_variation_value(a, count, csharp2cuda_temp_37, false, value);
#line 492 "WindowModule.cs"
        case 29:
#line 493 "WindowModule.cs"
            return mathblocks_sequence_variation_value(a, count, 2.0, false, value);
#line 494 "WindowModule.cs"
        case 30:
#line 495 "WindowModule.cs"
#line 495 "WindowModule.cs"
            double csharp2cuda_temp_38 = (first_parameter)->scalar_value;
            return mathblocks_sequence_recurrence_value(a, count, csharp2cuda_temp_38, value);
#line 496 "WindowModule.cs"
        case 31:
#line 497 "WindowModule.cs"
            return mathblocks_sequence_variation_value(a, count, 1.0, true, value);
#line 498 "WindowModule.cs"
        case 32:
        case 33:
#line 500 "WindowModule.cs"
#line 500 "WindowModule.cs"
            double* csharp2cuda_temp_39 = value;
            (*(csharp2cuda_temp_39) = mathblocks_sequence_sign_change_value(a, count, ((source) == (32))));
#line 501 "WindowModule.cs"
            return true;
#line 502 "WindowModule.cs"
        case 34:
#line 503 "WindowModule.cs"
#line 503 "WindowModule.cs"
            double* csharp2cuda_temp_40 = value;
#line 506 "WindowModule.cs"
            double csharp2cuda_temp_41 = (first_parameter)->scalar_value;
#line 507 "WindowModule.cs"
            int csharp2cuda_temp_42 = (second_parameter)->boolean_value;
            (*(csharp2cuda_temp_40) = mathblocks_sequence_first_passage_value(a, count, csharp2cuda_temp_41, ((csharp2cuda_temp_42) != (0))));
#line 508 "WindowModule.cs"
            return true;
#line 509 "WindowModule.cs"
        case 35:
        case 36:
        case 37:
        case 38:
        case 39:
#line 514 "WindowModule.cs"
            if ((!(mathblocks_probability_distribution(a, count))))
            {
#line 515 "WindowModule.cs"
                return false;
            }
#line 516 "WindowModule.cs"
            if (((source) == (35)))
#line 517 "WindowModule.cs"
            {
#line 518 "WindowModule.cs"
#line 518 "WindowModule.cs"
                double* csharp2cuda_temp_43 = value;
                (*(csharp2cuda_temp_43) = mathblocks_probability_entropy(a, count));
            }
            else
            {
#line 520 "WindowModule.cs"
                if (((source) == (39)))
#line 521 "WindowModule.cs"
                {
#line 522 "WindowModule.cs"
#line 522 "WindowModule.cs"
                    double* csharp2cuda_temp_44 = value;
#line 522 "WindowModule.cs"
                    double csharp2cuda_temp_45 = __ddiv_rn(mathblocks_probability_entropy(a, count), mathblocks_natural_logarithm(2.0));
                    (*(csharp2cuda_temp_44) = csharp2cuda_temp_45);
                }
                else
                {
#line 525 "WindowModule.cs"
                    if (((source) == (38)))
#line 526 "WindowModule.cs"
                    {
#line 527 "WindowModule.cs"
#line 527 "WindowModule.cs"
                        double* csharp2cuda_temp_46 = value;
                        (*(csharp2cuda_temp_46) = __dsub_rn(1.0, mathblocks_compensated_product_sum(a, a, count)));
                    }
                    else
                    {
#line 529 "WindowModule.cs"
#line 532 "WindowModule.cs"
                        double csharp2cuda_temp_47 = (first_parameter)->scalar_value;
#line 529 "WindowModule.cs"
                        bool csharp2cuda_temp_48 = mathblocks_probability_ordered_entropy_value(a, count, csharp2cuda_temp_47, ((source) == (36)), value);
                        if ((!(csharp2cuda_temp_48)))
#line 535 "WindowModule.cs"
                        {
#line 536 "WindowModule.cs"
                            return false;
                        }
                    }
                }
            }
#line 538 "WindowModule.cs"
            break;
#line 539 "WindowModule.cs"
        case 40:
        case 41:
#line 541 "WindowModule.cs"
            {
#line 542 "WindowModule.cs"
                double sum = mathblocks_compensated_sum(a, count);
#line 543 "WindowModule.cs"
#line 543 "WindowModule.cs"
                double* csharp2cuda_temp_49 = value;
#line 543 "WindowModule.cs"
                double csharp2cuda_temp_50;
#line 543 "WindowModule.cs"
                if (((source) == (41)))
                {
#line 543 "WindowModule.cs"
                    csharp2cuda_temp_50 = __ddiv_rn(sum, ((double)(count)));
                }
                else
                {
#line 543 "WindowModule.cs"
                    csharp2cuda_temp_50 = sum;
                }
                (*(csharp2cuda_temp_49) = csharp2cuda_temp_50);
#line 544 "WindowModule.cs"
                break;
            }
#line 546 "WindowModule.cs"
        case 42:
        case 43:
#line 548 "WindowModule.cs"
            {
#line 549 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 550 "WindowModule.cs"
                    return false;
                }
#line 551 "WindowModule.cs"
                double selected = (a)[0];
#line 552 "WindowModule.cs"
                {
#line 552 "WindowModule.cs"
                    int index = 1;
                    while (true)
                    {
                        if (!(((index) < (count))))
                            break;
#line 553 "WindowModule.cs"
#line 553 "WindowModule.cs"
                        double* csharp2cuda_temp_52 = &(selected);
#line 553 "WindowModule.cs"
                        double csharp2cuda_temp_53;
#line 553 "WindowModule.cs"
                        if (((source) == (43)))
                        {
#line 554 "WindowModule.cs"
                            double csharp2cuda_temp_54 = (a)[index];
#line 553 "WindowModule.cs"
                            csharp2cuda_temp_53 = mathblocks_maximum(selected, csharp2cuda_temp_54);
                        }
                        else
                        {
#line 555 "WindowModule.cs"
                            double csharp2cuda_temp_55 = (a)[index];
#line 553 "WindowModule.cs"
                            csharp2cuda_temp_53 = mathblocks_minimum(selected, csharp2cuda_temp_55);
                        }
                        (*(csharp2cuda_temp_52) = csharp2cuda_temp_53);
#line 552 "WindowModule.cs"
                        int* csharp2cuda_temp_51 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_51));
                    }
                }
#line 556 "WindowModule.cs"
#line 556 "WindowModule.cs"
                double* csharp2cuda_temp_56 = value;
                (*(csharp2cuda_temp_56) = selected);
#line 557 "WindowModule.cs"
                return true;
            }
#line 559 "WindowModule.cs"
        case 44:
#line 560 "WindowModule.cs"
            return mathblocks_vector_geometric_mean_value(a, count, scratch, value);
#line 561 "WindowModule.cs"
        case 45:
#line 562 "WindowModule.cs"
#line 562 "WindowModule.cs"
            double* csharp2cuda_temp_57 = value;
            (*(csharp2cuda_temp_57) = mathblocks_compensated_absolute_sum(a, count));
#line 563 "WindowModule.cs"
            break;
#line 564 "WindowModule.cs"
        case 46:
#line 565 "WindowModule.cs"
#line 565 "WindowModule.cs"
            double* csharp2cuda_temp_58 = value;
            (*(csharp2cuda_temp_58) = mathblocks_square_root(mathblocks_compensated_product_sum(a, a, count)));
#line 566 "WindowModule.cs"
            break;
#line 567 "WindowModule.cs"
        case 47:
        case 48:
#line 569 "WindowModule.cs"
            {
#line 570 "WindowModule.cs"
                double csharp2cuda_temp_59;
#line 570 "WindowModule.cs"
                if (((source) == (47)))
                {
#line 570 "WindowModule.cs"
                    csharp2cuda_temp_59 = 0.5;
                }
                else
                {
#line 570 "WindowModule.cs"
                    csharp2cuda_temp_59 = (first_parameter)->scalar_value;
                }
#line 570 "WindowModule.cs"
                double probability = csharp2cuda_temp_59;
#line 571 "WindowModule.cs"
#line 571 "WindowModule.cs"
                bool csharp2cuda_temp_60;
#line 571 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 571 "WindowModule.cs"
                    csharp2cuda_temp_60 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 571 "WindowModule.cs"
                    csharp2cuda_temp_60 = true;
                }
#line 571 "WindowModule.cs"
                bool csharp2cuda_temp_61;
#line 571 "WindowModule.cs"
                if (!(csharp2cuda_temp_60))
                {
#line 571 "WindowModule.cs"
                    csharp2cuda_temp_61 = ((probability) < (0.0));
                }
                else
                {
#line 571 "WindowModule.cs"
                    csharp2cuda_temp_61 = true;
                }
#line 571 "WindowModule.cs"
                bool csharp2cuda_temp_62;
#line 571 "WindowModule.cs"
                if (!(csharp2cuda_temp_61))
                {
#line 571 "WindowModule.cs"
                    csharp2cuda_temp_62 = ((probability) > (1.0));
                }
                else
                {
#line 571 "WindowModule.cs"
                    csharp2cuda_temp_62 = true;
                }
                if (csharp2cuda_temp_62)
                {
#line 572 "WindowModule.cs"
                    return false;
                }
#line 573 "WindowModule.cs"
#line 573 "WindowModule.cs"
                double* csharp2cuda_temp_63 = value;
#line 573 "WindowModule.cs"
                double csharp2cuda_temp_64 = mathblocks_quantile_values(a, count, scratch, probability);
                (*(csharp2cuda_temp_63) = csharp2cuda_temp_64);
#line 574 "WindowModule.cs"
                break;
            }
#line 576 "WindowModule.cs"
        case 49:
        case 50:
#line 578 "WindowModule.cs"
            return mathblocks_vector_arg_extreme_value(a, count, ((source) == (49)), value);
#line 579 "WindowModule.cs"
        case 51:
#line 580 "WindowModule.cs"
#line 580 "WindowModule.cs"
            double* csharp2cuda_temp_65 = value;
            (*(csharp2cuda_temp_65) = mathblocks_vector_rank_at(a, count, csharp2cuda_i32_sub(count, 1)));
#line 581 "WindowModule.cs"
            return true;
#line 582 "WindowModule.cs"
        case 52:
#line 583 "WindowModule.cs"
            return mathblocks_window_standardize_last(a, count, value);
#line 584 "WindowModule.cs"
        default:
#line 585 "WindowModule.cs"
            return false;
    }
#line 587 "WindowModule.cs"
#line 587 "WindowModule.cs"
    double csharp2cuda_temp_66 = *(value);
    return isfinite(csharp2cuda_temp_66);
}