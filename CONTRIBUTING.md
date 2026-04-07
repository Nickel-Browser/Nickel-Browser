# Contributing to Nickel Browser

Thank you for your interest in contributing to Nickel Browser! 🪙🐅 We welcome contributors of ALL skill levels and backgrounds. Whether you're fixing a typo, adding a translation, writing documentation, submitting a core patch, or designing a logo — every contribution makes Nickel better.

## 🤝 How to Contribute

### Reporting Bugs

1. Check if the issue already exists in [Issues](https://github.com/Nickel-Browser/Nickel-Browser/issues).
2. If not, create a new issue using our [Bug Report Template](https://github.com/Nickel-Browser/Nickel-Browser/issues/new?template=bug_report.yml) with:
   - Clear title and description.
   - Steps to reproduce.
   - Expected vs actual behavior.
   - Your OS and Nickel version.
   - Screenshots if applicable.

### Suggesting Features

1. Open a [Feature Request](https://github.com/Nickel-Browser/Nickel-Browser/issues/new?template=feature_request.yml).
2. Describe the feature and why it aligns with Nickel's privacy-first, community-driven philosophy.
3. Reference community demand (e.g., Reddit threads, forum posts) if available.

### Code Contributions

#### Development Environment Setup Checklist

- [ ] **Fork** the repository on GitHub.
- [ ] **Clone** your fork: `git clone https://github.com/YOUR_USERNAME/Nickel-Browser.git`
- [ ] **Add upstream remote**: `git remote add upstream https://github.com/Nickel-Browser/Nickel-Browser.git`
- [ ] **Install prerequisites**: (See [BUILD.md](docs/BUILD.md) for details).
- [ ] **Create a feature branch**: `git checkout -b feat/amazing-feature`
- [ ] **Verify you can build** the project using **Method A (Binary Repagging)**.

#### Development Workflow

1. **Sync with Upstream:**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```
2. **Make Changes:** Edit files, add features, or fix bugs.
3. **Test Your Changes:** (See Testing Requirements below).
4. **Commit:** Follow the Conventional Commits format.
5. **Push:** `git push origin feat/amazing-feature`
6. **Pull Request:** Open a PR on the main repository.

#### Commit Message Format

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: A new feature.
- `fix`: A bug fix.
- `docs`: Documentation only changes.
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc).
- `refactor`: A code change that neither fixes a bug nor adds a feature.
- `perf`: A code change that improves performance.
- `test`: Adding missing tests or correcting existing tests.
- `chore`: Changes to the build process or auxiliary tools and libraries such as documentation generation.

**Examples:**
```
feat(adblock): add support for regional filter lists
```
```
fix(fingerprint): correct noise generation in canvas spoofing
```
```
docs(readme): update build requirements for macOS
```

### Patch Contributions

For Chromium source-level modifications:
1. Place patches in the `patches/` directory following the naming convention `00XX-description.patch`.
2. Document what the patch does and its origin in the commit message.
3. Verify the patch applies cleanly using `docs/legacy/apply_patches.sh` (for source builds).

### Documentation

Help improve our documentation:
- Fix typos or clarify instructions.
- Add translations for the browser UI or documentation.
- Create tutorials or troubleshooting guides.

## 🧪 Testing Requirements

Before submitting a Pull Request, please ensure:

1. **Build Success**: Your changes must not break the build. Run a binary build to verify.
2. **Functionality**: Manually verify the feature or fix works as expected in the browser.
3. **No Regressions**: Check that existing features still work correctly.
4. **Clean Code**: Remove any debug logs or commented-out code before committing.

## 🏷️ Labels

We use labels to organize our work and help contributors find tasks:

| Label | Meaning |
|-------|---------|
| [`good first issue`](https://github.com/Nickel-Browser/Nickel-Browser/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22) | Beginner-friendly tasks with clear instructions. |
| [`help wanted`](https://github.com/Nickel-Browser/Nickel-Browser/issues?q=is%3Aopen+is%3Aissue+label%3A%22help+wanted%22) | Tasks where we specifically need community assistance. |
| `privacy` | Features or fixes related to privacy and fingerprinting. |
| `adblock` | Features or fixes related to the built-in ad blocker. |
| `bug` | Confirmed bugs that need fixing. |
| `feature` | New feature requests being tracked. |

## 🎯 Priority Areas

We are currently prioritizing:
1. **Performance optimizations** for low-end hardware.
2. **Additional fingerprinting protections** and noise generation.
3. **Filter list curation** for privacy-invasive sites.
4. **UI/UX polish** and theme consistency.
5. **Documentation** improvements and translations.

## 🙏 Recognition

Contributors will be listed in `CONTRIBUTORS.md` and mentioned in our release notes. Every contribution, no matter how small, is appreciated!

## ⚖️ Code of Conduct

We are committed to providing a welcoming and inspiring community for all. Please see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for our full Code of Conduct.

## 📝 License

By contributing, you agree that your contributions will be licensed under the project's dual-license model: **BSD-3-Clause** for Chromium/ungoogled-chromium components and **GPLv3-or-later** for Nickel-specific code.

---

Thank you for helping make Nickel Browser the best privacy-first browser for everyone! 🐅