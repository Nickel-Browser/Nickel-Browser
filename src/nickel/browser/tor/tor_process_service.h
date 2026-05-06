#ifndef SRC_NICKEL_BROWSER_TOR_TOR_PROCESS_SERVICE_H_
#define SRC_NICKEL_BROWSER_TOR_TOR_PROCESS_SERVICE_H_

#include "base/files/file_path.h"

namespace nickel {

class TorProcessService {
 public:
  TorProcessService();
  ~TorProcessService();

  void LaunchTor();

 private:
  bool VerifyBinaryIntegrity(const base::FilePath& path);
  base::FilePath GetTorBinaryPath() { return base::FilePath(); }
};

} // namespace nickel

#endif // SRC_NICKEL_BROWSER_TOR_TOR_PROCESS_SERVICE_H_
