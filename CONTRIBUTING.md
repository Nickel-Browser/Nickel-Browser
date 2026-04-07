# Contributing to Nickel Browser

Thank you for your interest in contributing to Nickel Browser! 🪙🐅 We welcome contributors of all skill levels and backgrounds.

## 🤝 How to Contribute

### Reporting Bugs

1. Check if the issue already exists in [Issues](https://github.com/Nickel-Browser/Nickel-Browser/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Your OS and Nickel version
   - Screenshots if applicable

### Suggesting Features

1. Open a [Feature Request](https://github.com/Nickel-Browser/Nickel-Browser/issues/new?template=feature_request.yml)
2. Describe the feature and why it aligns with Nickel's privacy-first philosophy
3. Reference community demand (Reddit threads, forum posts, etc.)

### Code Contributions

#### Development Environment Setup Checklist

- [ ] Fork the repository on GitHub
- [ ] Clone your fork: `git clone https://github.com/YOUR_USERNAME/Nickel-Browser.git`
- [ ] Add upstream remote: `git remote add upstream https://github.com/Nickel-Browser/Nickel-Browser.git`
- [ ] Install prerequisites (see [BUILD.md](docs/BUILD.md))
- [ ] Create a feature branch: `git checkout -b feat/amazing-feature`
- [ ] Verify you can build the project using Method A (Binary Repagging)

#### Development Workflow

1. **Sync with Upstream:**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```
2. **Make Changes:** Edit files, add features, or fix bugs.
3. **Test Your Changes:** (See Testing Requirements below)
4. **Commit:** Follow the Conventional Commits format.
5. **Push:** `git push origin feat/amazing-feature`
6. **Pull Request:** Open a PR on the main repository.

#### Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style (formatting, no logic change)
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `test`: Tests
- `chore`: Build process, dependencies

**Examples:**
```
feat(adblock): add new filter list updater
```
```
fix(fingerprint): correct canvas noise algorithm
```
```
docs(readme): update build instructions
```

### Patch Contributions

For Chromium patches:
1. Place patches in `patches/`
2. Document what the patch does in the commit message.
3. Verify application using `docs/legacy/apply_patches.sh` (for source builds).

### Documentation

Help improve docs:
- Fix typos
- Clarify instructions
- Add translations
- Create tutorials

## 🧪 Testing Requirements

Before submitting a Pull Request, please ensure:

1. **Build Success:** Your changes must not break the build. Run a binary build to verify.
2. **Linting:** (If applicable) Ensure your code follows the project's style.
3. **Functionality:** Manually verify the feature or fix works as expected in the browser.
4. **No Regressions:** Check that existing features still work.

## 🏷️ Labels

We use these labels to organize our work:

| Label | Meaning |
|-------|---------|
| `good first issue` | Beginner-friendly tasks |
| `help wanted` | Community assistance needed |
| `privacy` | Privacy-related feature |
| `adblock` | Ad-blocking related |
| `bug` | Confirmed bug |
| `feature` | Feature request |

## 🎯 Priority Areas

We especially need help with:
1. **Performance optimizations** for low-end hardware.
2. **Additional fingerprinting protections**.
3. **Filter list curation** for piracy sites and regional trackers.
4. **UI/UX improvements** and theme consistency.
5. **Documentation** and translations.

## 🙏 Recognition

Contributors will be listed in `CONTRIBUTORS.md` (coming soon) and mentioned in release notes.

## ⚖️ Code of Conduct

We are committed to providing a welcoming and inspiring community for all. Please see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for details.

## 📝 License

By contributing, you agree that your contributions will be licensed under the project's dual-license (BSD-3-Clause and GPLv3).

---

Thank you for making Nickel better! 🐅