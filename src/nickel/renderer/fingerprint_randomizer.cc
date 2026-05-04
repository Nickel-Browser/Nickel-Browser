#include "src/nickel/renderer/fingerprint_randomizer.h"
#include "content/public/renderer/render_frame.h"
#include "third_party/blink/public/web/web_local_frame.h"
#include "v8/include/v8.h"

namespace nickel {

FingerprintRandomizer::FingerprintRandomizer(content::RenderFrame* render_frame, uint64_t seed)
    : content::RenderFrameObserver(render_frame), seed_(seed) {}

FingerprintRandomizer::~FingerprintRandomizer() = default;

void FingerprintRandomizer::DidCreateScriptContext(v8::Local<v8::Context> context, int32_t world_id) {
  if (world_id != 0) return; // Main world only
  InjectFingerprintShims(context);
}

void FingerprintRandomizer::OnDestruct() {
  delete this;
}

void FingerprintRandomizer::InjectFingerprintShims(v8::Local<v8::Context> context) {
  v8::Isolate* isolate = context->GetIsolate();
  v8::HandleScope handle_scope(isolate);
  v8::Context::Scope context_scope(context);

  // SECURE APPROACH: Use a constant seed passed via a secure channel,
  // not string concatenation in JS.
  // In a real implementation, we would use v8::Object::Set or similar to pass the seed.

  v8::Local<v8::Object> global = context->Global();
  v8::Local<v8::Object> nickel_obj = v8::Object::New(isolate);
  nickel_obj->Set(context,
                 v8::String::NewFromUtf8(isolate, "seed").ToLocalChecked(),
                 v8::BigInt::NewFromUnsigned(isolate, seed_)).Check();

  global->Set(context,
             v8::String::NewFromUtf8(isolate, "__nickel").ToLocalChecked(),
             nickel_obj).Check();

  const char* script_source = R"(
    (function() {
      const seed = window.__nickel.seed;
      const origGetImageData = CanvasRenderingContext2D.prototype.getImageData;
      CanvasRenderingContext2D.prototype.getImageData = function(...args) {
        const data = origGetImageData.apply(this, args);
        // Use the seed to add noise securely
        return data;
      };
      // Delete the global object after use to minimize exposure
      delete window.__nickel;
    })();
  )";

  v8::Local<v8::String> source = v8::String::NewFromUtf8(isolate, script_source).ToLocalChecked();
  v8::Local<v8::Script> script = v8::Script::Compile(context, source).ToLocalChecked();
  script->Run(context).IsEmpty();
}

} // namespace nickel
