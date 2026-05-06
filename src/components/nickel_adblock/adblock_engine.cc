// Copyright (c) 2026 Nickel Browser Project
// Use of this source code is governed by a BSD-3-Clause license.
//
// nickel_adblock_engine.cc
// Ad-blocking filter engine implementation.

#include "src/components/nickel_adblock/adblock_engine.h"

#include <algorithm>
#include <cctype>
#include <cstring>
#include <unordered_set>

#include "base/strings/string_split.h"
#include "base/strings/string_util.h"
#include "base/synchronization/lock.h"
#include "net/base/registry_controlled_domains/registry_controlled_domain.h"

namespace nickel::adblock {

namespace {

struct RuleOptions {
  std::optional<bool> third_party;
  bool important = false;
  std::unordered_set<RequestType> types;
  std::vector<std::string> include_domains;
  std::vector<std::string> exclude_domains;
};

struct ParsedRule {
  std::string pattern;
  bool is_exception = false;
  bool domain_anchor = false;
  bool left_anchor = false;
  bool right_anchor = false;
  bool is_comment = false;
  bool is_element_hide = false;
  bool is_element_exception = false;
  std::string element_domain;
  std::string element_selector;
  RuleOptions options;
};

bool IsSeparator(char c) {
  return c == '/' || c == ':' || c == '?' || c == '&' || c == '=' || c == '#';
}

std::string NormalizeURL(const GURL& url) {
  GURL::Replacements reps;
  reps.ClearRef();
  return base::ToLowerASCII(url.ReplaceComponents(reps).spec());
}

std::string GetRegistrableDomain(const GURL& url) {
  return net::registry_controlled_domains::GetDomainAndRegistry(
      url, net::registry_controlled_domains::EXCLUDE_PRIVATE_REGISTRIES);
}

bool IsThirdParty(const GURL& request_url, const GURL& document_url) {
  if (!document_url.is_valid()) {
    return true;
  }
  return !net::registry_controlled_domains::SameDomainOrHost(
      request_url, document_url,
      net::registry_controlled_domains::EXCLUDE_PRIVATE_REGISTRIES);
}

bool MatchWildcardPattern(const std::string& pattern, const std::string& text) {
  size_t p = 0;
  size_t t = 0;
  size_t star = std::string::npos;
  size_t match = 0;

  while (t < text.size()) {
    if (p < pattern.size() && pattern[p] == '*') {
      star = p++;
      match = t;
      continue;
    }
    if (p < pattern.size() && pattern[p] == '^') {
      if (!IsSeparator(text[t])) {
        if (star != std::string::npos) {
          p = star + 1;
          t = ++match;
          continue;
        }
        return false;
      }
      ++p;
      ++t;
      continue;
    }
    if (p < pattern.size() && pattern[p] == text[t]) {
      ++p;
      ++t;
      continue;
    }
    if (star != std::string::npos) {
      p = star + 1;
      t = ++match;
      continue;
    }
    return false;
  }

  while (p < pattern.size() && pattern[p] == '*') {
    ++p;
  }
  if (p < pattern.size() && pattern[p] == '^') {
    return p + 1 == pattern.size();
  }
  return p == pattern.size();
}

bool MatchAnchoredPattern(const std::string& pattern,
                          const std::string& text,
                          bool left_anchor,
                          bool right_anchor) {
  if (left_anchor) {
    if (right_anchor) {
      return MatchWildcardPattern(pattern, text);
    }
    return MatchWildcardPattern(pattern + "*", text);
  }

  if (right_anchor) {
    return MatchWildcardPattern("*" + pattern, text);
  }

  for (size_t start = 0; start <= text.size(); ++start) {
    if (MatchWildcardPattern(pattern, text.substr(start))) {
      return true;
    }
  }
  return false;
}

RuleOptions ParseOptions(const std::string& options_text) {
  RuleOptions options;
  if (options_text.empty()) {
    return options;
  }

  std::vector<std::string> entries = base::SplitString(
      options_text, ",", base::TRIM_WHITESPACE, base::SPLIT_WANT_NONEMPTY);
  for (const auto& entry : entries) {
    std::string option = base::ToLowerASCII(entry);
    if (option == "third-party") {
      options.third_party = true;
    } else if (option == "~third-party") {
      options.third_party = false;
    } else if (option == "important") {
      options.important = true;
    } else if (option.rfind("domain=", 0) == 0) {
      std::string domains = option.substr(strlen("domain="));
      auto domain_entries = base::SplitString(
          domains, "|", base::TRIM_WHITESPACE, base::SPLIT_WANT_NONEMPTY);
      for (const auto& domain : domain_entries) {
        if (domain.rfind("~", 0) == 0) {
          options.exclude_domains.push_back(domain.substr(1));
        } else {
          options.include_domains.push_back(domain);
        }
      }
    } else if (option == "script") {
      options.types.insert(RequestType::kScript);
    } else if (option == "image") {
      options.types.insert(RequestType::kImage);
    } else if (option == "stylesheet") {
      options.types.insert(RequestType::kStylesheet);
    } else if (option == "xmlhttprequest" || option == "xhr") {
      options.types.insert(RequestType::kXHR);
    } else if (option == "font") {
      options.types.insert(RequestType::kFont);
    } else if (option == "media") {
      options.types.insert(RequestType::kMedia);
    } else if (option == "websocket") {
      options.types.insert(RequestType::kWebsocket);
    }
  }

  return options;
}

ParsedRule ParseRule(const std::string& raw) {
  ParsedRule parsed;
  std::string rule = base::TrimWhitespaceASCII(raw, base::TRIM_ALL);

  if (rule.empty() || rule[0] == '!') {
    parsed.is_comment = true;
    return parsed;
  }

  const size_t hide_pos = rule.find("##");
  const size_t exception_pos = rule.find("#@#");
  if (hide_pos != std::string::npos || exception_pos != std::string::npos) {
    parsed.is_element_hide = true;
    parsed.is_element_exception = exception_pos != std::string::npos;
    const size_t split_pos = parsed.is_element_exception ? exception_pos : hide_pos;
    parsed.element_domain = base::ToLowerASCII(rule.substr(0, split_pos));
    parsed.element_selector = rule.substr(split_pos + (parsed.is_element_exception ? 3 : 2));
    return parsed;
  }

  if (base::StartsWith(rule, "@@")) {
    parsed.is_exception = true;
    rule = rule.substr(2);
  }

  const size_t options_pos = rule.find('$');
  if (options_pos != std::string::npos) {
    parsed.options = ParseOptions(rule.substr(options_pos + 1));
    rule = rule.substr(0, options_pos);
  }

  if (base::StartsWith(rule, "||")) {
    parsed.domain_anchor = true;
    rule = rule.substr(2);
  }

  if (base::StartsWith(rule, "|")) {
    parsed.left_anchor = true;
    rule = rule.substr(1);
  }
  if (base::EndsWith(rule, "|")) {
    parsed.right_anchor = true;
    rule = rule.substr(0, rule.size() - 1);
  }

  parsed.pattern = base::ToLowerASCII(rule);
  return parsed;
}

bool DomainMatches(const std::string& domain, const std::string& host) {
  if (domain.empty()) {
    return true;
  }
  if (host == domain) {
    return true;
  }
  return base::EndsWith(host, "." + domain, base::CompareCase::INSENSITIVE_ASCII);
}

bool RuleAppliesToDomain(const RuleOptions& options, const GURL& document_url) {
  if (options.include_domains.empty() && options.exclude_domains.empty()) {
    return true;
  }
  const std::string doc_domain = GetRegistrableDomain(document_url);
  bool included = options.include_domains.empty();
  for (const auto& domain : options.include_domains) {
    if (DomainMatches(domain, doc_domain)) {
      included = true;
      break;
    }
  }
  if (!included) {
    return false;
  }
  for (const auto& domain : options.exclude_domains) {
    if (DomainMatches(domain, doc_domain)) {
      return false;
    }
  }
  return true;
}

bool RuleAppliesToType(const RuleOptions& options, RequestType type) {
  if (options.types.empty()) {
    return true;
  }
  return options.types.count(type) > 0;
}

}  // namespace

struct NickelAdblockEngine::NetworkRule {
  std::string pattern;
  bool is_exception = false;
  bool domain_anchor = false;
  bool left_anchor = false;
  bool right_anchor = false;
  RuleOptions options;
};

struct NickelAdblockEngine::CosmeticRule {
  std::string domain;
  std::string selector;
  bool is_exception = false;
};

NickelAdblockEngine::NickelAdblockEngine() = default;

NickelAdblockEngine::~NickelAdblockEngine() = default;

size_t NickelAdblockEngine::LoadRules(const std::string& filter_list_text) {
  base::AutoLock auto_lock(lock_);
  network_rules_.clear();
  cosmetic_rules_.clear();

  const auto lines = base::SplitString(filter_list_text, "\n",
                                       base::TRIM_WHITESPACE, base::SPLIT_WANT_ALL);
  for (const auto& line : lines) {
    ParsedRule parsed = ParseRule(line);
    if (parsed.is_comment || parsed.pattern.empty()) {
      if (parsed.is_element_hide && !parsed.element_selector.empty()) {
        CosmeticRule rule;
        rule.domain = parsed.element_domain;
        rule.selector = parsed.element_selector;
        rule.is_exception = parsed.is_element_exception;
        cosmetic_rules_.push_back(std::move(rule));
      }
      continue;
    }

    NetworkRule rule;
    rule.pattern = parsed.pattern;
    rule.is_exception = parsed.is_exception;
    rule.domain_anchor = parsed.domain_anchor;
    rule.left_anchor = parsed.left_anchor;
    rule.right_anchor = parsed.right_anchor;
    rule.options = parsed.options;
    network_rules_.push_back(std::move(rule));
  }

  return network_rules_.size();
}

size_t NickelAdblockEngine::RuleCount() const {
  base::AutoLock auto_lock(lock_);
  return network_rules_.size() + cosmetic_rules_.size();
}

void NickelAdblockEngine::Clear() {
  base::AutoLock auto_lock(lock_);
  network_rules_.clear();
  cosmetic_rules_.clear();
}

FilterResult NickelAdblockEngine::ShouldBlockRequest(const GURL& request_url,
                                                     const GURL& document_url,
                                                     RequestType type) const {
  base::AutoLock auto_lock(lock_);
  FilterResult result;
  if (!request_url.is_valid()) {
    return result;
  }

  const std::string normalized_url = NormalizeURL(request_url);
  const std::string host = base::ToLowerASCII(request_url.host());

  for (const auto& rule : network_rules_) {
    if (!RuleAppliesToType(rule.options, type)) {
      continue;
    }
    if (!RuleAppliesToDomain(rule.options, document_url)) {
      continue;
    }
    if (rule.options.third_party.has_value() &&
        IsThirdParty(request_url, document_url) != rule.options.third_party.value()) {
      continue;
    }

    bool matches = false;
    if (rule.domain_anchor) {
      const size_t host_end = rule.pattern.find_first_of("^/");
      const std::string rule_host =
          host_end == std::string::npos ? rule.pattern : rule.pattern.substr(0, host_end);
      if (!DomainMatches(rule_host, host)) {
        continue;
      }
      matches = MatchAnchoredPattern(rule.pattern, host + request_url.PathForRequest(),
                                     true, false);
    } else {
      matches = MatchAnchoredPattern(rule.pattern, normalized_url, rule.left_anchor,
                                     rule.right_anchor);
    }

    if (!matches) {
      continue;
    }

    if (rule.is_exception) {
      if (!result.important) {
        return FilterResult{false, false, rule.pattern};
      }
      continue;
    }

    result.blocked = true;
    result.important = rule.options.important;
    result.matched_rule = rule.pattern;
    if (result.important) {
      return result;
    }
  }

  return result;
}

CosmeticResult NickelAdblockEngine::ShouldHideElement(
    const GURL& document_url,
    const std::string& selector) const {
  base::AutoLock auto_lock(lock_);
  CosmeticResult result;

  const std::string doc_domain = base::ToLowerASCII(GetRegistrableDomain(document_url));
  for (const auto& rule : cosmetic_rules_) {
    if (!rule.domain.empty() && !DomainMatches(rule.domain, doc_domain)) {
      continue;
    }
    if (rule.selector != selector) {
      continue;
    }

    if (rule.is_exception) {
      return CosmeticResult{false, true, rule.selector};
    }
    result.hidden = true;
    result.matched_rule = rule.selector;
  }

  return result;
}

}  // namespace nickel::adblock
