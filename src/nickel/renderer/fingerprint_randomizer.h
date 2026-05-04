#ifndef SRC_NICKEL_RENDERER_FINGERPRINT_RANDOMIZER_H_
#define SRC_NICKEL_RENDERER_FINGERPRINT_RANDOMIZER_H_

#include "content/public/renderer/render_frame_observer.h"
#include "v8/include/v8.h"

namespace blink {
class WebLocalFrame;
}

namespace nickel {

class FingerprintRandomizer : public content::RenderFrameObserver {
 public:
  FingerprintRandomizer(content::RenderFrame* render_frame, uint64_t seed);
  ~FingerprintRandomizer() override;

  // RenderFrameObserver:
  void DidCreateScriptContext(v8::Local<v8::Context> context, int32_t world_id) override;
  void OnDestruct() override;

 private:
  void InjectFingerprintShims(v8::Local<v8::Context> context);

  uint64_t seed_;
};

} // namespace nickel

#endif // SRC_NICKEL_RENDERER_FINGERPRINT_RANDOMIZER_H_
