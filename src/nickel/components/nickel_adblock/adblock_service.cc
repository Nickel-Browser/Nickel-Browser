#include "src/nickel/components/nickel_adblock/adblock_service.h"

namespace nickel {

// static
AdBlockService* AdBlockService::GetInstance() {
  static base::NoDestructor<AdBlockService> instance;
  return instance.get();
}

AdBlockService::AdBlockService() = default;
AdBlockService::~AdBlockService() = default;

void AdBlockService::Initialize(const base::FilePath& filter_list_path) {
  // Real implementation would load the Rust engine here
  is_initialized_ = true;
}

AdBlockResult AdBlockService::ShouldBlock(const GURL& url,
                                          const GURL& first_party_url,
                                          const std::string& resource_type) {
  AdBlockResult result;
  result.decision = BlockDecision::kAllow;
  // Rust engine call here
  return result;
}

} // namespace nickel
