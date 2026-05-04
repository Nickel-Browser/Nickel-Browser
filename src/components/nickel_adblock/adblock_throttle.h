// Copyright (c) 2026 Nickel Browser Project
// Use of this source code is governed by a BSD-3-Clause license.
//
// nickel_adblock_throttle.h
// URLLoaderThrottle for Nickel's ad-blocking engine.

#ifndef SRC_COMPONENTS_NICKEL_ADBLOCK_ADBLOCK_THROTTLE_H_
#define SRC_COMPONENTS_NICKEL_ADBLOCK_ADBLOCK_THROTTLE_H_

#include <memory>

#include "content/public/browser/url_loader_throttle.h"
#include "net/redirect_info.h"
#include "src/components/nickel_adblock/adblock_engine.h"

namespace nickel::adblock {

class NickelAdblockThrottle : public content::URLLoaderThrottle {
 public:
  NickelAdblockThrottle();
  ~NickelAdblockThrottle() override;

  NickelAdblockThrottle(const NickelAdblockThrottle&) = delete;
  NickelAdblockThrottle& operator=(const NickelAdblockThrottle&) = delete;

  void WillStartRequest(network::ResourceRequest* request,
                        bool* defer) override;
  void WillRedirectRequest(network::ResourceRequest* request,
                           const net::RedirectInfo& redirect_info,
                           const network::mojom::URLResponseHead& response_head,
                           bool* defer) override;

 private:
  void EvaluateRequest(const network::ResourceRequest& request);

  NickelAdblockEngine* engine_ = nullptr;
};

}  // namespace nickel::adblock

#endif  // SRC_COMPONENTS_NICKEL_ADBLOCK_ADBLOCK_THROTTLE_H_
