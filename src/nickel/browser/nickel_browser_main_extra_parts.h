#ifndef SRC_NICKEL_BROWSER_NICKEL_BROWSER_MAIN_EXTRA_PARTS_H_
#define SRC_NICKEL_BROWSER_NICKEL_BROWSER_MAIN_EXTRA_PARTS_H_

#include "chrome/browser/chrome_browser_main_extra_parts.h"

namespace nickel {

class NickelBrowserMainExtraParts : public ChromeBrowserMainExtraParts {
 public:
  NickelBrowserMainExtraParts();
  ~NickelBrowserMainExtraParts() override;

  // ChromeBrowserMainExtraParts:
  void PreMainMessageLoopRun() override;
};

} // namespace nickel

#endif // SRC_NICKEL_BROWSER_NICKEL_BROWSER_MAIN_EXTRA_PARTS_H_
