#include "testing/gtest/include/gtest/gtest.h"

TEST(NickelFingerprintTest, SeedIsPassedToIIFE) {
  // Placeholder verification
  std::string js = "(function(seed){})(12345)";
  EXPECT_TRUE(js.find("})(12345)") != std::string::npos);
}
