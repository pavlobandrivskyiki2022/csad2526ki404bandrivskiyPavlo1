// Prompt: Write GoogleTest-based unit tests for add(int,int) from math_operations.h. Include gtest headers and create at least one test case that checks add(2,3)==5 and a few edge cases. Use gtest_main or provide main() as needed.

#include <gtest/gtest.h>
#include "math_operations.h"

using math_operations::add;

TEST(MathOperationsTest, AddPositiveNumbers) {
    EXPECT_EQ(add(2, 3), 5);
}

TEST(MathOperationsTest, AddNegativeNumbers) {
    EXPECT_EQ(add(-2, -3), -5);
}

TEST(MathOperationsTest, AddMixedSignNumbers) {
    EXPECT_EQ(add(-2, 3), 1);
    EXPECT_EQ(add(2, -3), -1);
}

TEST(MathOperationsTest, AddZero) {
    EXPECT_EQ(add(0, 0), 0);
    EXPECT_EQ(add(0, 5), 5);
    EXPECT_EQ(add(5, 0), 5);
}
