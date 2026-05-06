// Copyright (c) 2026 Nickel Browser Project
// Use of this source code is governed by a BSD-3-Clause license.
//
// nickel_adblock_engine.h
// Core ad-blocking filter engine for Nickel Browser.

#ifndef SRC_COMPONENTS_NICKEL_ADBLOCK_ADBLOCK_ENGINE_H_
#define SRC_COMPONENTS_NICKEL_ADBLOCK_ADBLOCK_ENGINE_H_

#include <cstddef>
#include <cstdint>
#include <optional>
#include <string>
#include <vector>

#include "base/synchronization/lock.h"
#include "url/gurl.h"

namespace nickel::adblock {

// Type of network request (mirrors Chromium's ResourceType).
enum class RequestType : uint8_t {
  kScript = 0,
  kImage = 1,
  kStylesheet = 2,
  kXHR = 3,
  kFont = 4,
  kMedia = 5,
  kWebsocket = 6,
  kOther = 7,
};

// Result of a filter engine evaluation.
struct FilterResult {
  bool blocked = false;
  bool important = false;  // matched an !important rule (cannot be overridden)
  std::string matched_rule;
};

struct CosmeticResult {
  bool hidden = false;
  bool exception = false;
  std::string matched_rule;
};

// NickelAdblockEngine evaluates filter lists against network requests.
// Thread-safe after rules are loaded.
class NickelAdblockEngine {
 public:
  NickelAdblockEngine();
  ~NickelAdblockEngine();

  NickelAdblockEngine(const NickelAdblockEngine&) = delete;
  NickelAdblockEngine& operator=(const NickelAdblockEngine&) = delete;

  // Load filter rules from a raw EasyList/Adblock Plus format string.
  // Returns the number of rules successfully parsed.
  size_t LoadRules(const std::string& filter_list_text);

  // Returns the number of loaded filter rules.
  size_t RuleCount() const;

  // Clear all loaded rules.
  void Clear();

  // Evaluate whether |request_url| (requested from |document_url|) should
  // be blocked.
  FilterResult ShouldBlockRequest(const GURL& request_url,
                                  const GURL& document_url,
                                  RequestType type) const;

  // Evaluate cosmetic rules for a given selector on |document_url|.
  CosmeticResult ShouldHideElement(const GURL& document_url,
                                   const std::string& selector) const;

 private:
  struct NetworkRule;
  struct CosmeticRule;

  std::vector<NetworkRule> network_rules_;
  std::vector<CosmeticRule> cosmetic_rules_;

  mutable base::Lock lock_;
};

}  // namespace nickel::adblock

#endif  // SRC_COMPONENTS_NICKEL_ADBLOCK_ADBLOCK_ENGINE_H_
