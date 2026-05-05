// Copyright (c) 2026 Nickel Browser Project
// Use of this source code is governed by a BSD-3-Clause license.
//
// nickel_adblock_throttle.cc

#include "src/components/nickel_adblock/adblock_throttle.h"

#include <mutex>

#include "base/no_destructor.h"
#include "net/base/net_errors.h"
#include "services/network/public/cpp/resource_request.h"
#include "src/components/nickel_adblock/adblock_filter_list.h"

namespace nickel::adblock {

namespace {

RequestType ToRequestType(network::mojom::RequestDestination destination) {
  switch (destination) {
    case network::mojom::RequestDestination::kScript:
      return RequestType::kScript;
    case network::mojom::RequestDestination::kImage:
      return RequestType::kImage;
    case network::mojom::RequestDestination::kStyle:
      return RequestType::kStylesheet;
    case network::mojom::RequestDestination::kFont:
      return RequestType::kFont;
    case network::mojom::RequestDestination::kAudio:
    case network::mojom::RequestDestination::kVideo:
      return RequestType::kMedia;
    case network::mojom::RequestDestination::kDocument:
    case network::mojom::RequestDestination::kSharedWorker:
    case network::mojom::RequestDestination::kWorker:
    case network::mojom::RequestDestination::kServiceWorker:
      return RequestType::kOther;
    case network::mojom::RequestDestination::kEmpty:
    default:
      return RequestType::kOther;
  }
}

NickelAdblockEngine* GetGlobalEngine() {
  static base::NoDestructor<NickelAdblockEngine> engine;
  static std::once_flag once;
  std::call_once(once, [] { engine->LoadRules(kNickelAdblockFilterList); });
  return engine.get();
}

}  // namespace

NickelAdblockThrottle::NickelAdblockThrottle() : engine_(GetGlobalEngine()) {}

NickelAdblockThrottle::~NickelAdblockThrottle() = default;

void NickelAdblockThrottle::WillStartRequest(network::ResourceRequest* request,
                                             bool* defer) {
  EvaluateRequest(*request);
}

void NickelAdblockThrottle::WillRedirectRequest(
    network::ResourceRequest* request,
    const net::RedirectInfo& redirect_info,
    const network::mojom::URLResponseHead& response_head,
    bool* defer) {
  EvaluateRequest(*request);
}

void NickelAdblockThrottle::EvaluateRequest(
    const network::ResourceRequest& request) {
  if (!engine_ || !request.url.SchemeIsHTTPOrHTTPS()) {
    return;
  }

  GURL document_url;
  if (request.request_initiator.has_value()) {
    document_url = request.request_initiator->GetURL();
  }

  FilterResult result = engine_->ShouldBlockRequest(
      request.url, document_url, ToRequestType(request.destination));
  if (result.blocked) {
    CancelWithError(net::ERR_BLOCKED_BY_CLIENT);
  }
}

}  // namespace nickel::adblock
