// Copyright (c) 2026 Nickel Browser Project
// Use of this source code is governed by a BSD-3-Clause license.
//
// Embedded EasyList/EasyPrivacy rules for Nickel's adblock engine.
// Security: embedded list avoids runtime network fetches (Least Privilege).

#ifndef SRC_COMPONENTS_NICKEL_ADBLOCK_ADBLOCK_FILTER_LIST_H_
#define SRC_COMPONENTS_NICKEL_ADBLOCK_ADBLOCK_FILTER_LIST_H_

namespace nickel::adblock {

inline constexpr char kNickelAdblockFilterList[] = R"(
! Nickel Browser minimal EasyList/EasyPrivacy bundle
! Network blocking
||ads.example.com^
||tracking.example.net^$script,third-party
||analytics.example.org^$image,third-party
@@||ads.example.com/allow^$script

! Cosmetic filtering
example.com##.ad-banner
##.sponsored
#@#example.com##.sponsored
)";

}  // namespace nickel::adblock

#endif  // SRC_COMPONENTS_NICKEL_ADBLOCK_ADBLOCK_FILTER_LIST_H_
