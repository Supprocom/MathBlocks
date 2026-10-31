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

#line 687 "WindowModule.cs"
__device__ void mathblocks_window_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 274 "WindowModule.cs"
__device__ bool mathblocks_window_distance_correlation(
    const double* left_values,
    const double* right_values,
    int count,
    double* row_means,
    double* value);

#line 249 "WindowModule.cs"
__device__ double mathblocks_window_distance_row_means(
    const double* values,
    int count,
    double* row_means);

#line 219 "WindowModule.cs"
__device__ double* mathblocks_window_merge_sort(double* values, double* buffer, int count);

#line 592 "WindowModule.cs"
__device__ void mathblocks_window_publish(MathBlockSlot* output, bool valid, int count, int thread);

#line 608 "WindowModule.cs"
__device__ void mathblocks_window_run(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output,
    int thread,
    int threads,
    int scratch_capacity);

#line 192 "WindowModule.cs"
__device__ long long mathblocks_window_scratch_count(int source, int width);

#line 314 "WindowModule.cs"
__device__ double mathblocks_window_scratch_median(double* scratch, int count);

#line 167 "WindowModule.cs"
__device__ int mathblocks_window_series_count(int source);

#line 134 "WindowModule.cs"
__device__ int mathblocks_window_source_arity(int source);

#line 323 "WindowModule.cs"
__device__ bool mathblocks_window_standardize_last(
    const double* values,
    int count,
    double* value);

#line 345 "WindowModule.cs"
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

#line 687 "WindowModule.cs"
__device__ void mathblocks_window_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 693 "WindowModule.cs"
{
#line 694 "WindowModule.cs"
    mathblocks_window_run(opcode, inputs, input_count, output, threadIdx.x, blockDim.x, csharp2cuda_i32_neg(1));
}

#line 274 "WindowModule.cs"
__device__ bool mathblocks_window_distance_correlation(
    const double* left_values,
    const double* right_values,
    int count,
    double* row_means,
    double* value)
#line 281 "WindowModule.cs"
{
#line 282 "WindowModule.cs"
    if (((count) <= (0)))
    {
#line 283 "WindowModule.cs"
        return false;
    }
#line 284 "WindowModule.cs"
    double* left_means = row_means;
#line 285 "WindowModule.cs"
    double* right_means = csharp2cuda_pointer_add(row_means, count);
#line 286 "WindowModule.cs"
    double left_total = mathblocks_window_distance_row_means(left_values, count, left_means);
#line 287 "WindowModule.cs"
    double right_total = mathblocks_window_distance_row_means(right_values, count, right_means);
#line 288 "WindowModule.cs"
    double covariance_square = 0.0;
#line 289 "WindowModule.cs"
    double left_variance_square = 0.0;
#line 290 "WindowModule.cs"
    double right_variance_square = 0.0;
#line 291 "WindowModule.cs"
    {
#line 291 "WindowModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 292 "WindowModule.cs"
            {
#line 293 "WindowModule.cs"
                {
#line 293 "WindowModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (count))))
                            break;
#line 294 "WindowModule.cs"
                        {
#line 295 "WindowModule.cs"
                            double csharp2cuda_temp_2 = (left_values)[row];
#line 295 "WindowModule.cs"
                            double csharp2cuda_temp_3 = (left_values)[column];
#line 296 "WindowModule.cs"
                            double csharp2cuda_temp_4 = (left_means)[row];
#line 296 "WindowModule.cs"
                            double csharp2cuda_temp_5 = (left_means)[column];
#line 295 "WindowModule.cs"
                            double left = __dsub_rn(fabs(__dsub_rn(csharp2cuda_temp_2, csharp2cuda_temp_3)), __dsub_rn(__dadd_rn(csharp2cuda_temp_4, csharp2cuda_temp_5), left_total));
#line 297 "WindowModule.cs"
                            double csharp2cuda_temp_6 = (right_values)[row];
#line 297 "WindowModule.cs"
                            double csharp2cuda_temp_7 = (right_values)[column];
#line 298 "WindowModule.cs"
                            double csharp2cuda_temp_8 = (right_means)[row];
#line 298 "WindowModule.cs"
                            double csharp2cuda_temp_9 = (right_means)[column];
#line 297 "WindowModule.cs"
                            double right = __dsub_rn(fabs(__dsub_rn(csharp2cuda_temp_6, csharp2cuda_temp_7)), __dsub_rn(__dadd_rn(csharp2cuda_temp_8, csharp2cuda_temp_9), right_total));
#line 299 "WindowModule.cs"
#line 299 "WindowModule.cs"
                            double* csharp2cuda_temp_10 = &(covariance_square);
#line 299 "WindowModule.cs"
                            double csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
                            (*(csharp2cuda_temp_10) = __dadd_rn(csharp2cuda_temp_11, __dmul_rn(left, right)));
#line 300 "WindowModule.cs"
#line 300 "WindowModule.cs"
                            double* csharp2cuda_temp_12 = &(left_variance_square);
#line 300 "WindowModule.cs"
                            double csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
                            (*(csharp2cuda_temp_12) = __dadd_rn(csharp2cuda_temp_13, __dmul_rn(left, left)));
#line 301 "WindowModule.cs"
#line 301 "WindowModule.cs"
                            double* csharp2cuda_temp_14 = &(right_variance_square);
#line 301 "WindowModule.cs"
                            double csharp2cuda_temp_15 = *(csharp2cuda_temp_14);
                            (*(csharp2cuda_temp_14) = __dadd_rn(csharp2cuda_temp_15, __dmul_rn(right, right)));
                        }
#line 293 "WindowModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
            }
#line 291 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 304 "WindowModule.cs"
#line 304 "WindowModule.cs"
    double* csharp2cuda_temp_16 = &(covariance_square);
#line 304 "WindowModule.cs"
    double csharp2cuda_temp_17 = *(csharp2cuda_temp_16);
    (*(csharp2cuda_temp_16) = __ddiv_rn(csharp2cuda_temp_17, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 305 "WindowModule.cs"
#line 305 "WindowModule.cs"
    double* csharp2cuda_temp_18 = &(left_variance_square);
#line 305 "WindowModule.cs"
    double csharp2cuda_temp_19 = *(csharp2cuda_temp_18);
    (*(csharp2cuda_temp_18) = __ddiv_rn(csharp2cuda_temp_19, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 306 "WindowModule.cs"
#line 306 "WindowModule.cs"
    double* csharp2cuda_temp_20 = &(right_variance_square);
#line 306 "WindowModule.cs"
    double csharp2cuda_temp_21 = *(csharp2cuda_temp_20);
    (*(csharp2cuda_temp_20) = __ddiv_rn(csharp2cuda_temp_21, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 307 "WindowModule.cs"
#line 307 "WindowModule.cs"
    double* csharp2cuda_temp_22 = value;
#line 308 "WindowModule.cs"
    double csharp2cuda_temp_23 = __ddiv_rn(covariance_square, mathblocks_square_root(__dmul_rn(left_variance_square, right_variance_square)));
    (*(csharp2cuda_temp_22) = mathblocks_square_root(csharp2cuda_temp_23));
#line 310 "WindowModule.cs"
#line 310 "WindowModule.cs"
    double csharp2cuda_temp_24 = *(value);
    return isfinite(csharp2cuda_temp_24);
}

#line 249 "WindowModule.cs"
__device__ double mathblocks_window_distance_row_means(
    const double* values,
    int count,
    double* row_means)
#line 254 "WindowModule.cs"
{
#line 255 "WindowModule.cs"
    double total_mean = 0.0;
#line 256 "WindowModule.cs"
    {
#line 256 "WindowModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 257 "WindowModule.cs"
            {
#line 258 "WindowModule.cs"
#line 258 "WindowModule.cs"
                double* csharp2cuda_temp_1 = &((row_means)[row]);
                (*(csharp2cuda_temp_1) = 0.0);
#line 259 "WindowModule.cs"
                {
#line 259 "WindowModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (count))))
                            break;
#line 260 "WindowModule.cs"
                        {
#line 261 "WindowModule.cs"
                            double csharp2cuda_temp_3 = (values)[row];
#line 261 "WindowModule.cs"
                            double csharp2cuda_temp_4 = (values)[column];
#line 261 "WindowModule.cs"
                            double distance = fabs(__dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4));
#line 262 "WindowModule.cs"
#line 262 "WindowModule.cs"
                            double* csharp2cuda_temp_5 = &((row_means)[row]);
#line 262 "WindowModule.cs"
                            double csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
                            (*(csharp2cuda_temp_5) = __dadd_rn(csharp2cuda_temp_6, distance));
#line 263 "WindowModule.cs"
#line 263 "WindowModule.cs"
                            double* csharp2cuda_temp_7 = &(total_mean);
#line 263 "WindowModule.cs"
                            double csharp2cuda_temp_8 = *(csharp2cuda_temp_7);
                            (*(csharp2cuda_temp_7) = __dadd_rn(csharp2cuda_temp_8, distance));
                        }
#line 259 "WindowModule.cs"
                        int* csharp2cuda_temp_2 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                    }
                }
#line 265 "WindowModule.cs"
#line 265 "WindowModule.cs"
                double* csharp2cuda_temp_9 = &((row_means)[row]);
#line 265 "WindowModule.cs"
                double csharp2cuda_temp_10 = *(csharp2cuda_temp_9);
                (*(csharp2cuda_temp_9) = __ddiv_rn(csharp2cuda_temp_10, ((double)(count))));
            }
#line 256 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 267 "WindowModule.cs"
#line 267 "WindowModule.cs"
    double* csharp2cuda_temp_11 = &(total_mean);
#line 267 "WindowModule.cs"
    double csharp2cuda_temp_12 = *(csharp2cuda_temp_11);
    (*(csharp2cuda_temp_11) = __ddiv_rn(csharp2cuda_temp_12, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 268 "WindowModule.cs"
    return total_mean;
}

#line 219 "WindowModule.cs"
__device__ double* mathblocks_window_merge_sort(double* values, double* buffer, int count)
#line 221 "WindowModule.cs"
{
#line 222 "WindowModule.cs"
    double* source = values;
#line 223 "WindowModule.cs"
    double* target = buffer;
#line 224 "WindowModule.cs"
    {
#line 224 "WindowModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 225 "WindowModule.cs"
            {
#line 226 "WindowModule.cs"
                {
#line 226 "WindowModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 227 "WindowModule.cs"
                        {
#line 228 "WindowModule.cs"
                            int csharp2cuda_temp_4;
#line 228 "WindowModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 228 "WindowModule.cs"
                                csharp2cuda_temp_4 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 228 "WindowModule.cs"
                                csharp2cuda_temp_4 = count;
                            }
#line 228 "WindowModule.cs"
                            int middle = csharp2cuda_temp_4;
#line 229 "WindowModule.cs"
                            int csharp2cuda_temp_5;
#line 229 "WindowModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 229 "WindowModule.cs"
                                csharp2cuda_temp_5 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 229 "WindowModule.cs"
                                csharp2cuda_temp_5 = count;
                            }
#line 229 "WindowModule.cs"
                            int end = csharp2cuda_temp_5;
#line 230 "WindowModule.cs"
                            int left = start;
#line 231 "WindowModule.cs"
                            int right = middle;
#line 232 "WindowModule.cs"
                            int position = start;
#line 233 "WindowModule.cs"
                            while (true)
                            {
#line 233 "WindowModule.cs"
                                bool csharp2cuda_temp_6;
#line 233 "WindowModule.cs"
                                if (((left) < (middle)))
                                {
#line 233 "WindowModule.cs"
                                    csharp2cuda_temp_6 = ((right) < (end));
                                }
                                else
                                {
#line 233 "WindowModule.cs"
                                    csharp2cuda_temp_6 = false;
                                }
                                if (!(csharp2cuda_temp_6))
                                    break;
#line 234 "WindowModule.cs"
#line 234 "WindowModule.cs"
                                int* csharp2cuda_temp_7 = &(position);
#line 234 "WindowModule.cs"
                                int csharp2cuda_temp_8 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_7));
#line 234 "WindowModule.cs"
                                double* csharp2cuda_temp_9 = &((target)[csharp2cuda_temp_8]);
#line 234 "WindowModule.cs"
                                double csharp2cuda_temp_10 = (source)[right];
#line 234 "WindowModule.cs"
                                double csharp2cuda_temp_11 = (source)[left];
#line 234 "WindowModule.cs"
                                double csharp2cuda_temp_12;
#line 234 "WindowModule.cs"
                                if (((csharp2cuda_temp_10) < (csharp2cuda_temp_11)))
                                {
#line 234 "WindowModule.cs"
                                    int* csharp2cuda_temp_13 = &(right);
#line 234 "WindowModule.cs"
                                    int csharp2cuda_temp_14 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
#line 234 "WindowModule.cs"
                                    csharp2cuda_temp_12 = (source)[csharp2cuda_temp_14];
                                }
                                else
                                {
#line 234 "WindowModule.cs"
                                    int* csharp2cuda_temp_15 = &(left);
#line 234 "WindowModule.cs"
                                    int csharp2cuda_temp_16 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
#line 234 "WindowModule.cs"
                                    csharp2cuda_temp_12 = (source)[csharp2cuda_temp_16];
                                }
                                (*(csharp2cuda_temp_9) = csharp2cuda_temp_12);
                            }
#line 235 "WindowModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 236 "WindowModule.cs"
#line 236 "WindowModule.cs"
                                int* csharp2cuda_temp_17 = &(position);
#line 236 "WindowModule.cs"
                                int csharp2cuda_temp_18 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_17));
#line 236 "WindowModule.cs"
                                double* csharp2cuda_temp_19 = &((target)[csharp2cuda_temp_18]);
#line 236 "WindowModule.cs"
                                int* csharp2cuda_temp_20 = &(left);
#line 236 "WindowModule.cs"
                                int csharp2cuda_temp_21 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_20));
#line 236 "WindowModule.cs"
                                double csharp2cuda_temp_22 = (source)[csharp2cuda_temp_21];
                                (*(csharp2cuda_temp_19) = csharp2cuda_temp_22);
                            }
#line 237 "WindowModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 238 "WindowModule.cs"
#line 238 "WindowModule.cs"
                                int* csharp2cuda_temp_23 = &(position);
#line 238 "WindowModule.cs"
                                int csharp2cuda_temp_24 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_23));
#line 238 "WindowModule.cs"
                                double* csharp2cuda_temp_25 = &((target)[csharp2cuda_temp_24]);
#line 238 "WindowModule.cs"
                                int* csharp2cuda_temp_26 = &(right);
#line 238 "WindowModule.cs"
                                int csharp2cuda_temp_27 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_26));
#line 238 "WindowModule.cs"
                                double csharp2cuda_temp_28 = (source)[csharp2cuda_temp_27];
                                (*(csharp2cuda_temp_25) = csharp2cuda_temp_28);
                            }
                        }
#line 226 "WindowModule.cs"
                        int* csharp2cuda_temp_2 = &(start);
#line 226 "WindowModule.cs"
                        int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                        (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 240 "WindowModule.cs"
                double* sorted = target;
#line 241 "WindowModule.cs"
#line 241 "WindowModule.cs"
                double** csharp2cuda_temp_29 = &(target);
                (*(csharp2cuda_temp_29) = source);
#line 242 "WindowModule.cs"
#line 242 "WindowModule.cs"
                double** csharp2cuda_temp_30 = &(source);
                (*(csharp2cuda_temp_30) = sorted);
            }
#line 224 "WindowModule.cs"
            int* csharp2cuda_temp_0 = &(width);
#line 224 "WindowModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, width));
        }
    }
#line 244 "WindowModule.cs"
    return source;
}

#line 592 "WindowModule.cs"
__device__ void mathblocks_window_publish(MathBlockSlot* output, bool valid, int count, int thread)
#line 594 "WindowModule.cs"
{
#line 595 "WindowModule.cs"
    if (((thread) != (0)))
    {
#line 596 "WindowModule.cs"
        return;
    }
#line 597 "WindowModule.cs"
#line 597 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &((output)->scalar_value);
    (*(csharp2cuda_temp_0) = 0.0);
#line 598 "WindowModule.cs"
#line 598 "WindowModule.cs"
    int* csharp2cuda_temp_1 = &((output)->boolean_value);
    (*(csharp2cuda_temp_1) = 0);
#line 599 "WindowModule.cs"
#line 599 "WindowModule.cs"
    int* csharp2cuda_temp_2 = &((output)->columns);
    (*(csharp2cuda_temp_2) = 0);
#line 600 "WindowModule.cs"
#line 600 "WindowModule.cs"
    int* csharp2cuda_temp_3 = &((output)->rows);
#line 600 "WindowModule.cs"
    int csharp2cuda_temp_4;
#line 600 "WindowModule.cs"
    if (valid)
    {
#line 600 "WindowModule.cs"
        csharp2cuda_temp_4 = count;
    }
    else
    {
#line 600 "WindowModule.cs"
        csharp2cuda_temp_4 = 0;
    }
    (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 601 "WindowModule.cs"
#line 601 "WindowModule.cs"
    int* csharp2cuda_temp_5 = &((output)->count);
#line 601 "WindowModule.cs"
    int csharp2cuda_temp_6;
#line 601 "WindowModule.cs"
    if (valid)
    {
#line 601 "WindowModule.cs"
        csharp2cuda_temp_6 = count;
    }
    else
    {
#line 601 "WindowModule.cs"
        csharp2cuda_temp_6 = 0;
    }
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 602 "WindowModule.cs"
#line 602 "WindowModule.cs"
    int* csharp2cuda_temp_7 = &((output)->valid);
    (*(csharp2cuda_temp_7) = valid);
}

#line 608 "WindowModule.cs"
__device__ void mathblocks_window_run(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output,
    int thread,
    int threads,
    int scratch_capacity)
#line 617 "WindowModule.cs"
{
#line 618 "WindowModule.cs"
    int source = csharp2cuda_i32_div(opcode, 2);
#line 619 "WindowModule.cs"
    int csharp2cuda_temp_0 = csharp2cuda_i32_rem(opcode, 2);
#line 619 "WindowModule.cs"
    bool sibling = ((csharp2cuda_temp_0) != (0));
#line 620 "WindowModule.cs"
    int arity = mathblocks_window_source_arity(source);
#line 621 "WindowModule.cs"
    int series = mathblocks_window_series_count(source);
#line 622 "WindowModule.cs"
    bool csharp2cuda_temp_1;
#line 622 "WindowModule.cs"
    if (((opcode) >= (0)))
    {
#line 622 "WindowModule.cs"
        csharp2cuda_temp_1 = ((source) < (53));
    }
    else
    {
#line 622 "WindowModule.cs"
        csharp2cuda_temp_1 = false;
    }
#line 622 "WindowModule.cs"
    bool csharp2cuda_temp_2;
#line 622 "WindowModule.cs"
    if (csharp2cuda_temp_1)
    {
#line 622 "WindowModule.cs"
        int csharp2cuda_temp_3;
#line 622 "WindowModule.cs"
        if (sibling)
        {
#line 622 "WindowModule.cs"
            csharp2cuda_temp_3 = 1;
        }
        else
        {
#line 622 "WindowModule.cs"
            csharp2cuda_temp_3 = 2;
        }
#line 622 "WindowModule.cs"
        csharp2cuda_temp_2 = ((input_count) == (csharp2cuda_i32_add(arity, csharp2cuda_temp_3)));
    }
    else
    {
#line 622 "WindowModule.cs"
        csharp2cuda_temp_2 = false;
    }
#line 622 "WindowModule.cs"
    bool valid = csharp2cuda_temp_2;
#line 623 "WindowModule.cs"
    {
#line 623 "WindowModule.cs"
        int index = 0;
        while (true)
        {
#line 623 "WindowModule.cs"
            bool csharp2cuda_temp_5;
#line 623 "WindowModule.cs"
            if (valid)
            {
#line 623 "WindowModule.cs"
                csharp2cuda_temp_5 = ((index) < (input_count));
            }
            else
            {
#line 623 "WindowModule.cs"
                csharp2cuda_temp_5 = false;
            }
            if (!(csharp2cuda_temp_5))
                break;
#line 624 "WindowModule.cs"
#line 624 "WindowModule.cs"
            MathBlockSlot* csharp2cuda_temp_6 = (inputs)[index];
#line 624 "WindowModule.cs"
            bool csharp2cuda_temp_7;
#line 624 "WindowModule.cs"
            if (!(((((void*)(csharp2cuda_temp_6))) == (((void*)(nullptr))))))
            {
#line 624 "WindowModule.cs"
                MathBlockSlot* csharp2cuda_temp_8 = (inputs)[index];
#line 624 "WindowModule.cs"
                bool csharp2cuda_temp_9 = (csharp2cuda_temp_8)->valid;
#line 624 "WindowModule.cs"
                csharp2cuda_temp_7 = (!(csharp2cuda_temp_9));
            }
            else
            {
#line 624 "WindowModule.cs"
                csharp2cuda_temp_7 = true;
            }
            if (csharp2cuda_temp_7)
            {
#line 625 "WindowModule.cs"
#line 625 "WindowModule.cs"
                bool* csharp2cuda_temp_10 = &(valid);
                (*(csharp2cuda_temp_10) = false);
            }
#line 623 "WindowModule.cs"
            int* csharp2cuda_temp_4 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
        }
    }
#line 626 "WindowModule.cs"
    if ((!(valid)))
#line 627 "WindowModule.cs"
    {
#line 628 "WindowModule.cs"
        mathblocks_window_publish(output, false, 0, thread);
#line 629 "WindowModule.cs"
        return;
    }
#line 632 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_11;
#line 632 "WindowModule.cs"
    if (((input_count) > (0)))
    {
#line 632 "WindowModule.cs"
        csharp2cuda_temp_11 = (inputs)[0];
    }
    else
    {
#line 632 "WindowModule.cs"
        csharp2cuda_temp_11 = ((MathBlockSlot*)(nullptr));
    }
#line 632 "WindowModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_11;
#line 633 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_12;
#line 633 "WindowModule.cs"
    if (((series) > (1)))
    {
#line 633 "WindowModule.cs"
        csharp2cuda_temp_12 = (inputs)[1];
    }
    else
    {
#line 633 "WindowModule.cs"
        csharp2cuda_temp_12 = ((MathBlockSlot*)(nullptr));
    }
#line 633 "WindowModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_12;
#line 634 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_13;
#line 634 "WindowModule.cs"
    if (((arity) > (series)))
    {
#line 634 "WindowModule.cs"
        csharp2cuda_temp_13 = (inputs)[series];
    }
    else
    {
#line 634 "WindowModule.cs"
        csharp2cuda_temp_13 = ((MathBlockSlot*)(nullptr));
    }
#line 634 "WindowModule.cs"
    const MathBlockSlot* first_parameter = csharp2cuda_temp_13;
#line 635 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_14;
#line 635 "WindowModule.cs"
    if (((arity) > (csharp2cuda_i32_add(series, 1))))
    {
#line 635 "WindowModule.cs"
        csharp2cuda_temp_14 = (inputs)[csharp2cuda_i32_add(series, 1)];
    }
    else
    {
#line 635 "WindowModule.cs"
        csharp2cuda_temp_14 = ((MathBlockSlot*)(nullptr));
    }
#line 635 "WindowModule.cs"
    const MathBlockSlot* second_parameter = csharp2cuda_temp_14;
#line 636 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_15 = (inputs)[arity];
#line 636 "WindowModule.cs"
    const MathBlockSlot* width_input = csharp2cuda_temp_15;
#line 637 "WindowModule.cs"
    MathBlockSlot* csharp2cuda_temp_16;
#line 637 "WindowModule.cs"
    if (sibling)
    {
#line 637 "WindowModule.cs"
        csharp2cuda_temp_16 = ((MathBlockSlot*)(nullptr));
    }
    else
    {
#line 637 "WindowModule.cs"
        csharp2cuda_temp_16 = (inputs)[csharp2cuda_i32_add(arity, 1)];
    }
#line 637 "WindowModule.cs"
    const MathBlockSlot* fill_input = csharp2cuda_temp_16;
#line 638 "WindowModule.cs"
    int count = (first)->count;
#line 639 "WindowModule.cs"
    int width = 0;
#line 640 "WindowModule.cs"
#line 640 "WindowModule.cs"
    bool csharp2cuda_temp_17;
#line 640 "WindowModule.cs"
    if (((((void*)(second))) != (((void*)(nullptr)))))
    {
#line 640 "WindowModule.cs"
        int csharp2cuda_temp_18 = (second)->count;
#line 640 "WindowModule.cs"
        csharp2cuda_temp_17 = ((csharp2cuda_temp_18) != (count));
    }
    else
    {
#line 640 "WindowModule.cs"
        csharp2cuda_temp_17 = false;
    }
    if (csharp2cuda_temp_17)
    {
#line 641 "WindowModule.cs"
#line 641 "WindowModule.cs"
        bool* csharp2cuda_temp_19 = &(valid);
        (*(csharp2cuda_temp_19) = false);
    }
#line 642 "WindowModule.cs"
#line 642 "WindowModule.cs"
    double csharp2cuda_temp_20 = (width_input)->scalar_value;
#line 642 "WindowModule.cs"
    int* csharp2cuda_temp_21 = &(width);
#line 642 "WindowModule.cs"
    bool csharp2cuda_temp_22 = mathblocks_sequence_positive_integer(csharp2cuda_temp_20, csharp2cuda_temp_21);
#line 642 "WindowModule.cs"
    bool csharp2cuda_temp_23;
#line 642 "WindowModule.cs"
    if (!((!(csharp2cuda_temp_22))))
    {
#line 642 "WindowModule.cs"
        csharp2cuda_temp_23 = ((width) > (count));
    }
    else
    {
#line 642 "WindowModule.cs"
        csharp2cuda_temp_23 = true;
    }
    if (csharp2cuda_temp_23)
    {
#line 643 "WindowModule.cs"
#line 643 "WindowModule.cs"
        bool* csharp2cuda_temp_24 = &(valid);
        (*(csharp2cuda_temp_24) = false);
    }
#line 644 "WindowModule.cs"
#line 644 "WindowModule.cs"
    int csharp2cuda_temp_25 = (output)->capacity;
    if (((count) > (csharp2cuda_temp_25)))
    {
#line 645 "WindowModule.cs"
#line 645 "WindowModule.cs"
        bool* csharp2cuda_temp_26 = &(valid);
        (*(csharp2cuda_temp_26) = false);
    }
#line 646 "WindowModule.cs"
    long long csharp2cuda_temp_27;
#line 646 "WindowModule.cs"
    if (valid)
    {
#line 646 "WindowModule.cs"
        csharp2cuda_temp_27 = mathblocks_window_scratch_count(source, width);
    }
    else
    {
#line 646 "WindowModule.cs"
        csharp2cuda_temp_27 = ((long long)(0));
    }
#line 646 "WindowModule.cs"
    long long required = csharp2cuda_temp_27;
#line 647 "WindowModule.cs"
    long long csharp2cuda_temp_28;
#line 647 "WindowModule.cs"
    if (((scratch_capacity) < (0)))
    {
#line 647 "WindowModule.cs"
        csharp2cuda_temp_28 = required;
    }
    else
    {
#line 647 "WindowModule.cs"
        csharp2cuda_temp_28 = ((long long)(scratch_capacity));
    }
#line 647 "WindowModule.cs"
    long long capacity = csharp2cuda_temp_28;
#line 648 "WindowModule.cs"
#line 648 "WindowModule.cs"
    bool csharp2cuda_temp_29;
#line 648 "WindowModule.cs"
    if (!(((required) > (capacity))))
    {
#line 648 "WindowModule.cs"
        bool csharp2cuda_temp_30;
#line 648 "WindowModule.cs"
        if (((required) > (((long long)(0)))))
        {
#line 648 "WindowModule.cs"
            unsigned long long csharp2cuda_temp_31 = (output)->scratch_pointer;
#line 648 "WindowModule.cs"
            csharp2cuda_temp_30 = ((csharp2cuda_temp_31) == (((unsigned long long)(0))));
        }
        else
        {
#line 648 "WindowModule.cs"
            csharp2cuda_temp_30 = false;
        }
#line 648 "WindowModule.cs"
        csharp2cuda_temp_29 = csharp2cuda_temp_30;
    }
    else
    {
#line 648 "WindowModule.cs"
        csharp2cuda_temp_29 = true;
    }
    if (csharp2cuda_temp_29)
    {
#line 649 "WindowModule.cs"
#line 649 "WindowModule.cs"
        bool* csharp2cuda_temp_32 = &(valid);
        (*(csharp2cuda_temp_32) = false);
    }
#line 650 "WindowModule.cs"
    mathblocks_window_publish(output, valid, count, thread);
#line 651 "WindowModule.cs"
    if ((!(valid)))
    {
#line 652 "WindowModule.cs"
        return;
    }
#line 654 "WindowModule.cs"
    double csharp2cuda_temp_33;
#line 654 "WindowModule.cs"
    if (sibling)
    {
#line 654 "WindowModule.cs"
        csharp2cuda_temp_33 = 0.0;
    }
    else
    {
#line 654 "WindowModule.cs"
        csharp2cuda_temp_33 = (fill_input)->scalar_value;
    }
#line 654 "WindowModule.cs"
    double fill = csharp2cuda_temp_33;
#line 655 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_34 = (first)->data_pointer;
#line 655 "WindowModule.cs"
    const double* a = ((double*)(csharp2cuda_temp_34));
#line 656 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_35 = (first)->data_pointer;
#line 656 "WindowModule.cs"
    const int* flags = ((int*)(csharp2cuda_temp_35));
#line 657 "WindowModule.cs"
    double* csharp2cuda_temp_36;
#line 657 "WindowModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 657 "WindowModule.cs"
        csharp2cuda_temp_36 = ((double*)(nullptr));
    }
    else
    {
#line 657 "WindowModule.cs"
        unsigned long long csharp2cuda_temp_37 = (second)->data_pointer;
#line 657 "WindowModule.cs"
        csharp2cuda_temp_36 = ((double*)(csharp2cuda_temp_37));
    }
#line 657 "WindowModule.cs"
    const double* b = csharp2cuda_temp_36;
#line 658 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_38 = (output)->data_pointer;
#line 658 "WindowModule.cs"
    double* result = ((double*)(csharp2cuda_temp_38));
#line 659 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_39 = (output)->data_pointer;
#line 659 "WindowModule.cs"
    int* boolean_result = ((int*)(csharp2cuda_temp_39));
#line 660 "WindowModule.cs"
    unsigned long long csharp2cuda_temp_40 = (output)->scratch_pointer;
#line 660 "WindowModule.cs"
    double* scratch = csharp2cuda_pointer_add(((double*)(csharp2cuda_temp_40)), csharp2cuda_i32_mul(thread, csharp2cuda_i32_from_bits(capacity)));
#line 661 "WindowModule.cs"
    {
#line 661 "WindowModule.cs"
        int end = thread;
        while (true)
        {
            if (!(((end) < (count))))
                break;
#line 662 "WindowModule.cs"
            {
#line 663 "WindowModule.cs"
                bool row_valid = false;
#line 664 "WindowModule.cs"
                double value = 0.0;
#line 665 "WindowModule.cs"
                if (((end) >= (csharp2cuda_i32_sub(width, 1))))
#line 666 "WindowModule.cs"
                {
#line 668 "WindowModule.cs"
                    int start = csharp2cuda_i32_add(csharp2cuda_i32_sub(end, width), 1);
#line 669 "WindowModule.cs"
#line 669 "WindowModule.cs"
                    bool* csharp2cuda_temp_43 = &(row_valid);
#line 678 "WindowModule.cs"
                    double* csharp2cuda_temp_44 = &(value);
#line 669 "WindowModule.cs"
                    bool csharp2cuda_temp_45 = mathblocks_window_value(source, csharp2cuda_pointer_add(a, start), csharp2cuda_pointer_add(b, start), csharp2cuda_pointer_add(flags, start), width, first_parameter, second_parameter, scratch, csharp2cuda_temp_44);
                    (*(csharp2cuda_temp_43) = csharp2cuda_temp_45);
                }
#line 680 "WindowModule.cs"
                if (sibling)
                {
#line 681 "WindowModule.cs"
#line 681 "WindowModule.cs"
                    int* csharp2cuda_temp_46 = &((boolean_result)[end]);
                    (*(csharp2cuda_temp_46) = row_valid);
                }
                else
                {
#line 683 "WindowModule.cs"
#line 683 "WindowModule.cs"
                    double* csharp2cuda_temp_47 = &((result)[end]);
#line 683 "WindowModule.cs"
                    double csharp2cuda_temp_48;
#line 683 "WindowModule.cs"
                    if (row_valid)
                    {
#line 683 "WindowModule.cs"
                        csharp2cuda_temp_48 = value;
                    }
                    else
                    {
#line 683 "WindowModule.cs"
                        csharp2cuda_temp_48 = fill;
                    }
                    (*(csharp2cuda_temp_47) = csharp2cuda_temp_48);
                }
            }
#line 661 "WindowModule.cs"
            int* csharp2cuda_temp_41 = &(end);
#line 661 "WindowModule.cs"
            int csharp2cuda_temp_42 = *(csharp2cuda_temp_41);
            (*(csharp2cuda_temp_41) = csharp2cuda_i32_add(csharp2cuda_temp_42, threads));
        }
    }
}

#line 192 "WindowModule.cs"
__device__ long long mathblocks_window_scratch_count(int source, int width)
#line 194 "WindowModule.cs"
{
#line 195 "WindowModule.cs"
    long long count = ((long long)(width));
#line 196 "WindowModule.cs"
    switch (source)
    {
#line 198 "WindowModule.cs"
        case 3:
        case 44:
        case 47:
        case 48:
#line 202 "WindowModule.cs"
            return count;
#line 203 "WindowModule.cs"
        case 2:
        case 8:
        case 21:
#line 206 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, ((long long)(2)));
#line 207 "WindowModule.cs"
        case 22:
#line 208 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, csharp2cuda_i64_sub(count, ((long long)(1))));
#line 209 "WindowModule.cs"
        case 15:
#line 210 "WindowModule.cs"
            return csharp2cuda_i64_mul(count, csharp2cuda_i64_add(count, ((long long)(1))));
#line 211 "WindowModule.cs"
        default:
#line 212 "WindowModule.cs"
            return ((long long)(0));
    }
}

#line 314 "WindowModule.cs"
__device__ double mathblocks_window_scratch_median(double* scratch, int count)
#line 316 "WindowModule.cs"
{
#line 317 "WindowModule.cs"
    double* sorted = mathblocks_window_merge_sort(scratch, csharp2cuda_pointer_add(scratch, count), count);
#line 318 "WindowModule.cs"
    return mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
}

#line 167 "WindowModule.cs"
__device__ int mathblocks_window_series_count(int source)
#line 169 "WindowModule.cs"
{
#line 170 "WindowModule.cs"
    switch (source)
    {
#line 172 "WindowModule.cs"
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
#line 184 "WindowModule.cs"
            return 2;
#line 185 "WindowModule.cs"
        default:
#line 186 "WindowModule.cs"
            return 1;
    }
}

#line 134 "WindowModule.cs"
__device__ int mathblocks_window_source_arity(int source)
#line 136 "WindowModule.cs"
{
#line 137 "WindowModule.cs"
    switch (source)
    {
#line 139 "WindowModule.cs"
        case 34:
#line 140 "WindowModule.cs"
            return 3;
#line 141 "WindowModule.cs"
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
#line 161 "WindowModule.cs"
            return 2;
#line 162 "WindowModule.cs"
        default:
#line 163 "WindowModule.cs"
            return 1;
    }
}

#line 323 "WindowModule.cs"
__device__ bool mathblocks_window_standardize_last(
    const double* values,
    int count,
    double* value)
#line 328 "WindowModule.cs"
{
#line 329 "WindowModule.cs"
    if (((count) <= (0)))
    {
#line 330 "WindowModule.cs"
        return false;
    }
#line 331 "WindowModule.cs"
    double mean = 0.0;
#line 332 "WindowModule.cs"
    double deviation = 0.0;
#line 333 "WindowModule.cs"
#line 333 "WindowModule.cs"
    double* csharp2cuda_temp_0 = &(mean);
#line 333 "WindowModule.cs"
    double* csharp2cuda_temp_1 = &(deviation);
    mathblocks_vector_standardize_moments(values, count, csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 334 "WindowModule.cs"
    {
#line 334 "WindowModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 335 "WindowModule.cs"
#line 335 "WindowModule.cs"
            double csharp2cuda_temp_3 = (values)[index];
#line 335 "WindowModule.cs"
            double csharp2cuda_temp_4 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_3, mean), deviation);
            if ((!(isfinite(csharp2cuda_temp_4))))
            {
#line 336 "WindowModule.cs"
                return false;
            }
#line 334 "WindowModule.cs"
            int* csharp2cuda_temp_2 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 337 "WindowModule.cs"
#line 337 "WindowModule.cs"
    double* csharp2cuda_temp_5 = value;
#line 337 "WindowModule.cs"
    double csharp2cuda_temp_6 = (values)[csharp2cuda_i32_sub(count, 1)];
#line 337 "WindowModule.cs"
    double csharp2cuda_temp_7 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_6, mean), deviation);
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_7);
#line 338 "WindowModule.cs"
    return true;
}

#line 345 "WindowModule.cs"
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
#line 356 "WindowModule.cs"
{
#line 357 "WindowModule.cs"
    switch (source)
    {
#line 359 "WindowModule.cs"
        case 0:
#line 360 "WindowModule.cs"
            {
#line 361 "WindowModule.cs"
                int lag = 0;
#line 362 "WindowModule.cs"
#line 362 "WindowModule.cs"
                double csharp2cuda_temp_0 = (first_parameter)->scalar_value;
#line 362 "WindowModule.cs"
                int* csharp2cuda_temp_1 = &(lag);
#line 362 "WindowModule.cs"
                bool csharp2cuda_temp_2 = mathblocks_sequence_positive_integer(csharp2cuda_temp_0, csharp2cuda_temp_1);
#line 362 "WindowModule.cs"
                bool csharp2cuda_temp_3;
#line 362 "WindowModule.cs"
                if (!((!(csharp2cuda_temp_2))))
                {
#line 362 "WindowModule.cs"
                    csharp2cuda_temp_3 = ((lag) >= (count));
                }
                else
                {
#line 362 "WindowModule.cs"
                    csharp2cuda_temp_3 = true;
                }
                if (csharp2cuda_temp_3)
                {
#line 363 "WindowModule.cs"
                    return false;
                }
#line 364 "WindowModule.cs"
#line 364 "WindowModule.cs"
                double* csharp2cuda_temp_4 = value;
                (*(csharp2cuda_temp_4) = mathblocks_statistics_pearson(a, csharp2cuda_pointer_add(a, lag), csharp2cuda_i32_sub(count, lag)));
#line 365 "WindowModule.cs"
                break;
            }
#line 367 "WindowModule.cs"
        case 1:
        case 16:
#line 369 "WindowModule.cs"
#line 369 "WindowModule.cs"
            double csharp2cuda_temp_5 = (first_parameter)->scalar_value;
            return mathblocks_statistics_moment_value(a, count, csharp2cuda_temp_5, ((source) == (1)), value);
#line 370 "WindowModule.cs"
        case 2:
#line 371 "WindowModule.cs"
            return mathblocks_window_distance_correlation(a, b, count, scratch, value);
#line 372 "WindowModule.cs"
        case 3:
#line 373 "WindowModule.cs"
#line 373 "WindowModule.cs"
            bool csharp2cuda_temp_6;
#line 373 "WindowModule.cs"
            if (!(((count) <= (0))))
            {
#line 373 "WindowModule.cs"
                csharp2cuda_temp_6 = ((((void*)(scratch))) == (((void*)(nullptr))));
            }
            else
            {
#line 373 "WindowModule.cs"
                csharp2cuda_temp_6 = true;
            }
            if (csharp2cuda_temp_6)
            {
#line 374 "WindowModule.cs"
                return false;
            }
#line 375 "WindowModule.cs"
            mathblocks_statistics_sort_copy(a, count, scratch);
#line 376 "WindowModule.cs"
#line 376 "WindowModule.cs"
            double* csharp2cuda_temp_7 = value;
            (*(csharp2cuda_temp_7) = __dsub_rn(mathblocks_statistics_sorted_quantile(scratch, count, 0.75), mathblocks_statistics_sorted_quantile(scratch, count, 0.25)));
#line 379 "WindowModule.cs"
            break;
#line 380 "WindowModule.cs"
        case 4:
#line 381 "WindowModule.cs"
            return mathblocks_statistics_kendall_value(a, b, count, value);
#line 382 "WindowModule.cs"
        case 5:
        case 6:
        case 7:
        case 9:
        case 10:
        case 18:
#line 388 "WindowModule.cs"
            {
#line 389 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 390 "WindowModule.cs"
                    return false;
                }
#line 391 "WindowModule.cs"
                double covariance = mathblocks_statistics_population_covariance(a, b, count);
#line 392 "WindowModule.cs"
#line 392 "WindowModule.cs"
                bool csharp2cuda_temp_8;
#line 392 "WindowModule.cs"
                if (!(((source) == (10))))
                {
#line 392 "WindowModule.cs"
                    csharp2cuda_temp_8 = ((source) == (18));
                }
                else
                {
#line 392 "WindowModule.cs"
                    csharp2cuda_temp_8 = true;
                }
                if (csharp2cuda_temp_8)
#line 393 "WindowModule.cs"
                {
#line 394 "WindowModule.cs"
#line 394 "WindowModule.cs"
                    double* csharp2cuda_temp_9 = value;
#line 394 "WindowModule.cs"
                    double csharp2cuda_temp_10;
#line 394 "WindowModule.cs"
                    if (((source) == (10)))
                    {
#line 394 "WindowModule.cs"
                        csharp2cuda_temp_10 = covariance;
                    }
                    else
                    {
#line 394 "WindowModule.cs"
                        csharp2cuda_temp_10 = __ddiv_rn(__dmul_rn(covariance, ((double)(count))), __dsub_rn(((double)(count)), 1.0));
                    }
                    (*(csharp2cuda_temp_9) = csharp2cuda_temp_10);
                }
                else
                {
#line 398 "WindowModule.cs"
                    if (((source) == (7)))
#line 399 "WindowModule.cs"
                    {
#line 400 "WindowModule.cs"
#line 400 "WindowModule.cs"
                        double* csharp2cuda_temp_11 = value;
#line 400 "WindowModule.cs"
                        double csharp2cuda_temp_12 = __ddiv_rn(covariance, mathblocks_statistics_population_variance(a, count));
                        (*(csharp2cuda_temp_11) = csharp2cuda_temp_12);
                    }
                    else
                    {
#line 403 "WindowModule.cs"
                        if (((source) == (5)))
#line 404 "WindowModule.cs"
                        {
#line 405 "WindowModule.cs"
                            double slope = __ddiv_rn(covariance, mathblocks_statistics_population_variance(a, count));
#line 407 "WindowModule.cs"
#line 407 "WindowModule.cs"
                            double* csharp2cuda_temp_13 = value;
                            (*(csharp2cuda_temp_13) = __dsub_rn(mathblocks_statistics_mean(b, count), __dmul_rn(slope, mathblocks_statistics_mean(a, count))));
                        }
                        else
#line 411 "WindowModule.cs"
                        {
#line 412 "WindowModule.cs"
                            double correlation = __ddiv_rn(covariance, __dmul_rn(mathblocks_square_root(mathblocks_statistics_population_variance(a, count)), mathblocks_square_root(mathblocks_statistics_population_variance(b, count))));
#line 415 "WindowModule.cs"
#line 415 "WindowModule.cs"
                            double* csharp2cuda_temp_14 = value;
#line 415 "WindowModule.cs"
                            double csharp2cuda_temp_15;
#line 415 "WindowModule.cs"
                            if (((source) == (6)))
                            {
#line 415 "WindowModule.cs"
                                csharp2cuda_temp_15 = __dmul_rn(correlation, correlation);
                            }
                            else
                            {
#line 415 "WindowModule.cs"
                                csharp2cuda_temp_15 = correlation;
                            }
                            (*(csharp2cuda_temp_14) = csharp2cuda_temp_15);
                        }
                    }
                }
#line 417 "WindowModule.cs"
                break;
            }
#line 419 "WindowModule.cs"
        case 8:
#line 420 "WindowModule.cs"
            {
#line 421 "WindowModule.cs"
#line 421 "WindowModule.cs"
                bool csharp2cuda_temp_16;
#line 421 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 421 "WindowModule.cs"
                    csharp2cuda_temp_16 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 421 "WindowModule.cs"
                    csharp2cuda_temp_16 = true;
                }
                if (csharp2cuda_temp_16)
                {
#line 422 "WindowModule.cs"
                    return false;
                }
#line 423 "WindowModule.cs"
                double* sorted = scratch;
#line 424 "WindowModule.cs"
                double* deviations = csharp2cuda_pointer_add(scratch, count);
#line 425 "WindowModule.cs"
                mathblocks_statistics_sort_copy(a, count, sorted);
#line 426 "WindowModule.cs"
                double median = mathblocks_statistics_sorted_quantile(sorted, count, 0.5);
#line 427 "WindowModule.cs"
                {
#line 427 "WindowModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (count))))
                            break;
#line 428 "WindowModule.cs"
#line 428 "WindowModule.cs"
                        double* csharp2cuda_temp_18 = &((deviations)[index]);
#line 428 "WindowModule.cs"
                        double csharp2cuda_temp_19 = (a)[index];
                        (*(csharp2cuda_temp_18) = fabs(__dsub_rn(csharp2cuda_temp_19, median)));
#line 427 "WindowModule.cs"
                        int* csharp2cuda_temp_17 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_17));
                    }
                }
#line 429 "WindowModule.cs"
                mathblocks_statistics_sort_copy(deviations, count, sorted);
#line 430 "WindowModule.cs"
#line 430 "WindowModule.cs"
                double* csharp2cuda_temp_20 = value;
                (*(csharp2cuda_temp_20) = mathblocks_statistics_sorted_quantile(sorted, count, 0.5));
#line 431 "WindowModule.cs"
                break;
            }
#line 433 "WindowModule.cs"
        case 11:
        case 12:
#line 435 "WindowModule.cs"
            return mathblocks_statistics_shape_moment_value(a, count, ((source) == (11)), value);
#line 436 "WindowModule.cs"
        case 13:
        case 14:
        case 19:
        case 20:
#line 440 "WindowModule.cs"
            {
#line 441 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 442 "WindowModule.cs"
                    return false;
                }
#line 443 "WindowModule.cs"
                double variance = mathblocks_statistics_population_variance(a, count);
#line 444 "WindowModule.cs"
#line 444 "WindowModule.cs"
                bool csharp2cuda_temp_21;
#line 444 "WindowModule.cs"
                if (!(((source) == (19))))
                {
#line 444 "WindowModule.cs"
                    csharp2cuda_temp_21 = ((source) == (20));
                }
                else
                {
#line 444 "WindowModule.cs"
                    csharp2cuda_temp_21 = true;
                }
                if (csharp2cuda_temp_21)
                {
#line 445 "WindowModule.cs"
#line 445 "WindowModule.cs"
                    double* csharp2cuda_temp_22 = &(variance);
#line 445 "WindowModule.cs"
                    double csharp2cuda_temp_23 = __ddiv_rn(__dmul_rn(variance, ((double)(count))), __dsub_rn(((double)(count)), 1.0));
                    (*(csharp2cuda_temp_22) = csharp2cuda_temp_23);
                }
#line 446 "WindowModule.cs"
#line 446 "WindowModule.cs"
                double* csharp2cuda_temp_24 = value;
#line 446 "WindowModule.cs"
                bool csharp2cuda_temp_25;
#line 446 "WindowModule.cs"
                if (!(((source) == (13))))
                {
#line 446 "WindowModule.cs"
                    csharp2cuda_temp_25 = ((source) == (19));
                }
                else
                {
#line 446 "WindowModule.cs"
                    csharp2cuda_temp_25 = true;
                }
#line 446 "WindowModule.cs"
                double csharp2cuda_temp_26;
#line 446 "WindowModule.cs"
                if (csharp2cuda_temp_25)
                {
#line 446 "WindowModule.cs"
                    csharp2cuda_temp_26 = mathblocks_square_root(variance);
                }
                else
                {
#line 446 "WindowModule.cs"
                    csharp2cuda_temp_26 = variance;
                }
                (*(csharp2cuda_temp_24) = csharp2cuda_temp_26);
#line 449 "WindowModule.cs"
                break;
            }
#line 451 "WindowModule.cs"
        case 15:
#line 452 "WindowModule.cs"
            {
#line 453 "WindowModule.cs"
#line 453 "WindowModule.cs"
                bool csharp2cuda_temp_27;
#line 453 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 453 "WindowModule.cs"
                    csharp2cuda_temp_27 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 453 "WindowModule.cs"
                    csharp2cuda_temp_27 = true;
                }
                if (csharp2cuda_temp_27)
                {
#line 454 "WindowModule.cs"
                    return false;
                }
#line 455 "WindowModule.cs"
                int average_count = mathblocks_statistics_pair_averages(a, count, scratch);
#line 456 "WindowModule.cs"
#line 456 "WindowModule.cs"
                double* csharp2cuda_temp_28 = value;
#line 456 "WindowModule.cs"
                double csharp2cuda_temp_29 = mathblocks_window_scratch_median(scratch, average_count);
                (*(csharp2cuda_temp_28) = csharp2cuda_temp_29);
#line 457 "WindowModule.cs"
                break;
            }
#line 459 "WindowModule.cs"
        case 17:
#line 460 "WindowModule.cs"
#line 460 "WindowModule.cs"
            double* csharp2cuda_temp_30 = value;
#line 461 "WindowModule.cs"
            double csharp2cuda_temp_31 = __ddiv_rn(mathblocks_compensated_product_sum(a, a, count), ((double)(count)));
            (*(csharp2cuda_temp_30) = mathblocks_square_root(csharp2cuda_temp_31));
#line 462 "WindowModule.cs"
            break;
#line 463 "WindowModule.cs"
        case 21:
#line 464 "WindowModule.cs"
            {
#line 465 "WindowModule.cs"
#line 465 "WindowModule.cs"
                bool csharp2cuda_temp_32;
#line 465 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 465 "WindowModule.cs"
                    csharp2cuda_temp_32 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 465 "WindowModule.cs"
                    csharp2cuda_temp_32 = true;
                }
                if (csharp2cuda_temp_32)
                {
#line 466 "WindowModule.cs"
                    return false;
                }
#line 467 "WindowModule.cs"
                double* left_ranks = scratch;
#line 468 "WindowModule.cs"
                double* right_ranks = csharp2cuda_pointer_add(scratch, count);
#line 469 "WindowModule.cs"
                mathblocks_statistics_rank(a, count, left_ranks);
#line 470 "WindowModule.cs"
                mathblocks_statistics_rank(b, count, right_ranks);
#line 471 "WindowModule.cs"
#line 471 "WindowModule.cs"
                double* csharp2cuda_temp_33 = value;
                (*(csharp2cuda_temp_33) = mathblocks_statistics_pearson(left_ranks, right_ranks, count));
#line 472 "WindowModule.cs"
                break;
            }
#line 474 "WindowModule.cs"
        case 22:
#line 475 "WindowModule.cs"
            {
#line 476 "WindowModule.cs"
                int slope_count = mathblocks_statistics_pair_slopes(a, b, count, scratch);
#line 477 "WindowModule.cs"
                if (((slope_count) == (0)))
                {
#line 478 "WindowModule.cs"
                    return false;
                }
#line 479 "WindowModule.cs"
#line 479 "WindowModule.cs"
                double* csharp2cuda_temp_34 = value;
#line 479 "WindowModule.cs"
                double csharp2cuda_temp_35 = mathblocks_window_scratch_median(scratch, slope_count);
                (*(csharp2cuda_temp_34) = csharp2cuda_temp_35);
#line 480 "WindowModule.cs"
                break;
            }
#line 482 "WindowModule.cs"
        case 23:
        case 24:
#line 484 "WindowModule.cs"
            return mathblocks_statistics_weighted_value(a, b, count, ((source) == (24)), value);
#line 485 "WindowModule.cs"
        case 25:
#line 486 "WindowModule.cs"
#line 486 "WindowModule.cs"
            double* csharp2cuda_temp_36 = value;
            (*(csharp2cuda_temp_36) = mathblocks_sequence_longest_run_value(flags, count));
#line 487 "WindowModule.cs"
            return true;
#line 488 "WindowModule.cs"
        case 26:
        case 27:
#line 490 "WindowModule.cs"
            return mathblocks_sequence_decline_value(a, count, ((source) == (27)), value);
#line 491 "WindowModule.cs"
        case 28:
#line 492 "WindowModule.cs"
#line 492 "WindowModule.cs"
            double csharp2cuda_temp_37 = (first_parameter)->scalar_value;
            return mathblocks_sequence_variation_value(a, count, csharp2cuda_temp_37, false, value);
#line 493 "WindowModule.cs"
        case 29:
#line 494 "WindowModule.cs"
            return mathblocks_sequence_variation_value(a, count, 2.0, false, value);
#line 495 "WindowModule.cs"
        case 30:
#line 496 "WindowModule.cs"
#line 496 "WindowModule.cs"
            double csharp2cuda_temp_38 = (first_parameter)->scalar_value;
            return mathblocks_sequence_recurrence_value(a, count, csharp2cuda_temp_38, value);
#line 497 "WindowModule.cs"
        case 31:
#line 498 "WindowModule.cs"
            return mathblocks_sequence_variation_value(a, count, 1.0, true, value);
#line 499 "WindowModule.cs"
        case 32:
        case 33:
#line 501 "WindowModule.cs"
#line 501 "WindowModule.cs"
            double* csharp2cuda_temp_39 = value;
            (*(csharp2cuda_temp_39) = mathblocks_sequence_sign_change_value(a, count, ((source) == (32))));
#line 502 "WindowModule.cs"
            return true;
#line 503 "WindowModule.cs"
        case 34:
#line 504 "WindowModule.cs"
#line 504 "WindowModule.cs"
            double* csharp2cuda_temp_40 = value;
#line 507 "WindowModule.cs"
            double csharp2cuda_temp_41 = (first_parameter)->scalar_value;
#line 508 "WindowModule.cs"
            int csharp2cuda_temp_42 = (second_parameter)->boolean_value;
            (*(csharp2cuda_temp_40) = mathblocks_sequence_first_passage_value(a, count, csharp2cuda_temp_41, ((csharp2cuda_temp_42) != (0))));
#line 509 "WindowModule.cs"
            return true;
#line 510 "WindowModule.cs"
        case 35:
        case 36:
        case 37:
        case 38:
        case 39:
#line 515 "WindowModule.cs"
            if ((!(mathblocks_probability_distribution(a, count))))
            {
#line 516 "WindowModule.cs"
                return false;
            }
#line 517 "WindowModule.cs"
            if (((source) == (35)))
#line 518 "WindowModule.cs"
            {
#line 519 "WindowModule.cs"
#line 519 "WindowModule.cs"
                double* csharp2cuda_temp_43 = value;
                (*(csharp2cuda_temp_43) = mathblocks_probability_entropy(a, count));
            }
            else
            {
#line 521 "WindowModule.cs"
                if (((source) == (39)))
#line 522 "WindowModule.cs"
                {
#line 523 "WindowModule.cs"
#line 523 "WindowModule.cs"
                    double* csharp2cuda_temp_44 = value;
#line 523 "WindowModule.cs"
                    double csharp2cuda_temp_45 = __ddiv_rn(mathblocks_probability_entropy(a, count), mathblocks_natural_logarithm(2.0));
                    (*(csharp2cuda_temp_44) = csharp2cuda_temp_45);
                }
                else
                {
#line 526 "WindowModule.cs"
                    if (((source) == (38)))
#line 527 "WindowModule.cs"
                    {
#line 528 "WindowModule.cs"
#line 528 "WindowModule.cs"
                        double* csharp2cuda_temp_46 = value;
                        (*(csharp2cuda_temp_46) = __dsub_rn(1.0, mathblocks_compensated_product_sum(a, a, count)));
                    }
                    else
                    {
#line 530 "WindowModule.cs"
#line 533 "WindowModule.cs"
                        double csharp2cuda_temp_47 = (first_parameter)->scalar_value;
#line 530 "WindowModule.cs"
                        bool csharp2cuda_temp_48 = mathblocks_probability_ordered_entropy_value(a, count, csharp2cuda_temp_47, ((source) == (36)), value);
                        if ((!(csharp2cuda_temp_48)))
#line 536 "WindowModule.cs"
                        {
#line 537 "WindowModule.cs"
                            return false;
                        }
                    }
                }
            }
#line 539 "WindowModule.cs"
            break;
#line 540 "WindowModule.cs"
        case 40:
        case 41:
#line 542 "WindowModule.cs"
            {
#line 543 "WindowModule.cs"
                double sum = mathblocks_compensated_sum(a, count);
#line 544 "WindowModule.cs"
#line 544 "WindowModule.cs"
                double* csharp2cuda_temp_49 = value;
#line 544 "WindowModule.cs"
                double csharp2cuda_temp_50;
#line 544 "WindowModule.cs"
                if (((source) == (41)))
                {
#line 544 "WindowModule.cs"
                    csharp2cuda_temp_50 = __ddiv_rn(sum, ((double)(count)));
                }
                else
                {
#line 544 "WindowModule.cs"
                    csharp2cuda_temp_50 = sum;
                }
                (*(csharp2cuda_temp_49) = csharp2cuda_temp_50);
#line 545 "WindowModule.cs"
                break;
            }
#line 547 "WindowModule.cs"
        case 42:
        case 43:
#line 549 "WindowModule.cs"
            {
#line 550 "WindowModule.cs"
                if (((count) <= (0)))
                {
#line 551 "WindowModule.cs"
                    return false;
                }
#line 552 "WindowModule.cs"
                double selected = (a)[0];
#line 553 "WindowModule.cs"
                {
#line 553 "WindowModule.cs"
                    int index = 1;
                    while (true)
                    {
                        if (!(((index) < (count))))
                            break;
#line 554 "WindowModule.cs"
#line 554 "WindowModule.cs"
                        double* csharp2cuda_temp_52 = &(selected);
#line 554 "WindowModule.cs"
                        double csharp2cuda_temp_53;
#line 554 "WindowModule.cs"
                        if (((source) == (43)))
                        {
#line 555 "WindowModule.cs"
                            double csharp2cuda_temp_54 = (a)[index];
#line 554 "WindowModule.cs"
                            csharp2cuda_temp_53 = mathblocks_maximum(selected, csharp2cuda_temp_54);
                        }
                        else
                        {
#line 556 "WindowModule.cs"
                            double csharp2cuda_temp_55 = (a)[index];
#line 554 "WindowModule.cs"
                            csharp2cuda_temp_53 = mathblocks_minimum(selected, csharp2cuda_temp_55);
                        }
                        (*(csharp2cuda_temp_52) = csharp2cuda_temp_53);
#line 553 "WindowModule.cs"
                        int* csharp2cuda_temp_51 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_51));
                    }
                }
#line 557 "WindowModule.cs"
#line 557 "WindowModule.cs"
                double* csharp2cuda_temp_56 = value;
                (*(csharp2cuda_temp_56) = selected);
#line 558 "WindowModule.cs"
                return true;
            }
#line 560 "WindowModule.cs"
        case 44:
#line 561 "WindowModule.cs"
            return mathblocks_vector_geometric_mean_value(a, count, scratch, value);
#line 562 "WindowModule.cs"
        case 45:
#line 563 "WindowModule.cs"
#line 563 "WindowModule.cs"
            double* csharp2cuda_temp_57 = value;
            (*(csharp2cuda_temp_57) = mathblocks_compensated_absolute_sum(a, count));
#line 564 "WindowModule.cs"
            break;
#line 565 "WindowModule.cs"
        case 46:
#line 566 "WindowModule.cs"
#line 566 "WindowModule.cs"
            double* csharp2cuda_temp_58 = value;
            (*(csharp2cuda_temp_58) = mathblocks_square_root(mathblocks_compensated_product_sum(a, a, count)));
#line 567 "WindowModule.cs"
            break;
#line 568 "WindowModule.cs"
        case 47:
        case 48:
#line 570 "WindowModule.cs"
            {
#line 571 "WindowModule.cs"
                double csharp2cuda_temp_59;
#line 571 "WindowModule.cs"
                if (((source) == (47)))
                {
#line 571 "WindowModule.cs"
                    csharp2cuda_temp_59 = 0.5;
                }
                else
                {
#line 571 "WindowModule.cs"
                    csharp2cuda_temp_59 = (first_parameter)->scalar_value;
                }
#line 571 "WindowModule.cs"
                double probability = csharp2cuda_temp_59;
#line 572 "WindowModule.cs"
#line 572 "WindowModule.cs"
                bool csharp2cuda_temp_60;
#line 572 "WindowModule.cs"
                if (!(((count) <= (0))))
                {
#line 572 "WindowModule.cs"
                    csharp2cuda_temp_60 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 572 "WindowModule.cs"
                    csharp2cuda_temp_60 = true;
                }
#line 572 "WindowModule.cs"
                bool csharp2cuda_temp_61;
#line 572 "WindowModule.cs"
                if (!(csharp2cuda_temp_60))
                {
#line 572 "WindowModule.cs"
                    csharp2cuda_temp_61 = ((probability) < (0.0));
                }
                else
                {
#line 572 "WindowModule.cs"
                    csharp2cuda_temp_61 = true;
                }
#line 572 "WindowModule.cs"
                bool csharp2cuda_temp_62;
#line 572 "WindowModule.cs"
                if (!(csharp2cuda_temp_61))
                {
#line 572 "WindowModule.cs"
                    csharp2cuda_temp_62 = ((probability) > (1.0));
                }
                else
                {
#line 572 "WindowModule.cs"
                    csharp2cuda_temp_62 = true;
                }
                if (csharp2cuda_temp_62)
                {
#line 573 "WindowModule.cs"
                    return false;
                }
#line 574 "WindowModule.cs"
#line 574 "WindowModule.cs"
                double* csharp2cuda_temp_63 = value;
#line 574 "WindowModule.cs"
                double csharp2cuda_temp_64 = mathblocks_quantile_values(a, count, scratch, probability);
                (*(csharp2cuda_temp_63) = csharp2cuda_temp_64);
#line 575 "WindowModule.cs"
                break;
            }
#line 577 "WindowModule.cs"
        case 49:
        case 50:
#line 579 "WindowModule.cs"
            return mathblocks_vector_arg_extreme_value(a, count, ((source) == (49)), value);
#line 580 "WindowModule.cs"
        case 51:
#line 581 "WindowModule.cs"
#line 581 "WindowModule.cs"
            double* csharp2cuda_temp_65 = value;
            (*(csharp2cuda_temp_65) = mathblocks_vector_rank_at(a, count, csharp2cuda_i32_sub(count, 1)));
#line 582 "WindowModule.cs"
            return true;
#line 583 "WindowModule.cs"
        case 52:
#line 584 "WindowModule.cs"
            return mathblocks_window_standardize_last(a, count, value);
#line 585 "WindowModule.cs"
        default:
#line 586 "WindowModule.cs"
            return false;
    }
#line 588 "WindowModule.cs"
#line 588 "WindowModule.cs"
    double csharp2cuda_temp_66 = *(value);
    return isfinite(csharp2cuda_temp_66);
}