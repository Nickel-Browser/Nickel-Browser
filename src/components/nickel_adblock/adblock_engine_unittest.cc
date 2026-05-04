// Copyright (c) 2026 Nickel Browser Project
// Use of this source code is governed by a BSD-3-Clause license.

#include "src/components/nickel_adblock/adblock_engine.h"

#include "testing/gtest/include/gtest/gtest.h"
#include "url/gurl.h"

namespace nickel::adblock {

namespace {

constexpr char kTestList[] = R"(
! Network rules
||ads.test^$script,third-party
@@||ads.test/allow^$script
||tracking.test^$image

! Cosmetic rules
example.com##.ad-slot
##.sponsored
#@#example.com##.sponsored
)";

}  // namespace

TEST(NickelAdblockEngineTest, BlocksNetworkRequests) {
  NickelAdblockEngine engine;
  engine.LoadRules(kTestList);

  FilterResult blocked = engine.ShouldBlockRequest(
      GURL("https://ads.test/banner.js"), GURL("https://news.example.com"),
      RequestType::kScript);
  EXPECT_TRUE(blocked.blocked);

  FilterResult allowed = engine.ShouldBlockRequest(
      GURL("https://ads.test/allow/script.js"), GURL("https://news.example.com"),
      RequestType::kScript);
  EXPECT_FALSE(allowed.blocked);

  FilterResult image_blocked = engine.ShouldBlockRequest(
      GURL("https://tracking.test/pixel.png"), GURL("https://example.com"),
      RequestType::kImage);
  EXPECT_TRUE(image_blocked.blocked);
}

TEST(NickelAdblockEngineTest, AppliesCosmeticRules) {
  NickelAdblockEngine engine;
  engine.LoadRules(kTestList);

  CosmeticResult hide = engine.ShouldHideElement(GURL("https://example.com"),
                                                 ".ad-slot");
  EXPECT_TRUE(hide.hidden);

  CosmeticResult generic_hide =
      engine.ShouldHideElement(GURL("https://foo.example"), ".sponsored");
  EXPECT_TRUE(generic_hide.hidden);

  CosmeticResult exception =
      engine.ShouldHideElement(GURL("https://example.com"), ".sponsored");
  EXPECT_TRUE(exception.exception);
  EXPECT_FALSE(exception.hidden);
}

}  // namespace nickel::adblock
