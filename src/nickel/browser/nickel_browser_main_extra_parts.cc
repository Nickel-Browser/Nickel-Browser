#include "src/nickel/browser/nickel_browser_main_extra_parts.h"

namespace nickel {

NickelBrowserMainExtraParts::NickelBrowserMainExtraParts() = default;
NickelBrowserMainExtraParts::~NickelBrowserMainExtraParts() = default;

void NickelBrowserMainExtraParts::PreMainMessageLoopRun() {
  // Initialize Nickel components here
}

} // namespace nickel
