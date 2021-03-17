#pragma once

//! Boost
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
#include <boost/multiprecision/cpp_dec_float.hpp>
#include <boost/multiprecision/cpp_int.hpp>
using t_float_50 = boost::multiprecision::cpp_dec_float_50;
using t_rational = boost::multiprecision::cpp_rational;
#pragma clang diagnostic pop

t_float_50 safe_float(const std::string& from) noexcept;