# Release Process

1. **Version Bump**: Update `NICKEL_VERSION` in the production workflow.
2. **Tagging**: Create a new git tag (e.g., `v1.0.0`).
3. **Build**: The production workflow triggers automatically.
4. **Signing**: Ensure macOS and Windows binaries are correctly signed in the CI.
5. **Publish**: Verify release assets and publish the draft release on GitHub.
