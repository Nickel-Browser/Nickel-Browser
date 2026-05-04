#ifndef SRC_NICKEL_COMPONENTS_NICKEL_ADBLOCK_ADBLOCK_SERVICE_H_
#define SRC_NICKEL_COMPONENTS_NICKEL_ADBLOCK_ADBLOCK_SERVICE_H_

#include "base/files/file_path.h"
#include "base/no_destructor.h"
#include "url/gurl.h"

namespace nickel {

enum class BlockDecision {
  kAllow,
  kBlock,
  kRedirect
};

struct AdBlockResult {
  BlockDecision decision;
  std::string redirect_url;
};

class AdBlockService {
 public:
  static AdBlockService* GetInstance();

  void Initialize(const base::FilePath& filter_list_path);

  AdBlockResult ShouldBlock(const GURL& url,
                            const GURL& first_party_url,
                            const std::string& resource_type);

  bool IsInitialized() const { return is_initialized_; }

 private:
  friend class base::NoDestructor<AdBlockService>;
  AdBlockService();
  ~AdBlockService();

  bool is_initialized_ = false;
};

} // namespace nickel

#endif // SRC_NICKEL_COMPONENTS_NICKEL_ADBLOCK_ADBLOCK_SERVICE_H_
