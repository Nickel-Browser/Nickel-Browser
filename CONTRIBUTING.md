# Contributing to Nickel Browser

Thank you for your interest in contributing to Nickel Browser! 🪙🐅

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

1. Open a [Feature Request](https://github.com/Nickel-Browser/Nickel-Browser/issues/new?template=feature_request.md)
2. Describe the feature and why it aligns with Nickel's privacy-first philosophy
3. Reference community demand (Reddit threads, forum posts, etc.)

### Code Contributions

#### Setting Up Development Environment

```bash
# 1. Fork the repo on GitHub
# 2. Clone your fork
git clone https://github.com/GITHUB_USERNAME/YOUR_REPO.git
cd YOUR_REPO

# 3. Add upstream remote
git remote add upstream https://github.com/Nickel-Browser/Nickel-Browser.git

# 4. Create a branch
git checkout -b feature/your-feature-name
```

#### Development Workflow

```bash
# Sync with upstream
git fetch upstream
git rebase upstream/main

# Make your changes
# ... edit files ...

# Commit with clear message
git commit -m "feat: add vertical tabs sidebar"

# Push to your fork
git push origin feature/your-feature-name

# Create Pull Request on GitHub
```

#### Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style (formatting, no logic change)
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `test`: Tests
- `chore`: Build process, dependencies

Examples:
```
feat(adblock): add new filter list updater
fix(fingerprint): correct canvas noise algorithm
docs(readme): update build instructions
```

### Patch Contributions

For Chromium patches:

1. Place patches in `patches/extra/`
2. Add patch to `patches/series` file
3. Test with `./scripts/apply-patches.sh`
4. Document what the patch does in commit message

### Filter Lists

To add default filter lists:

1. Edit `src/nickel/adblock/filter-lists.json`
2. Ensure list is compatible with uBlock Origin format
3. Verify license allows redistribution

### Documentation

Help improve docs:
- Fix typos
- Clarify instructions
- Add translations
- Create tutorials

## 🏷️ Labels

We use these labels:

| Label | Meaning |
|-------|---------|
| `good first issue` | Beginner-friendly |
| `help wanted` | Community assistance needed |
| `privacy` | Privacy-related feature |
| `adblock` | Ad-blocking related |
| `bug` | Confirmed bug |
| `feature` | Feature request |
| `linux` | Linux-specific |
| `windows` | Windows-specific |
| `macos` | macOS-specific |

## 🧪 Testing

Before submitting PR:

```bash
# Run patch validation
./scripts/validate-patches.sh

# Test build (if you have resources)
./scripts/build.sh

# Check code style
./scripts/lint.sh
```

## 📋 Code Standards

### C++ Patches

- Follow Chromium style guide
- Use 2-space indentation
- Max 80 characters per line
- Comment complex logic

### JavaScript

- ES6+ syntax
- 2-space indentation
- JSDoc comments for functions
- No `var`, use `let`/`const`

### Python

- PEP 8 compliant
- Python 3.9+ compatible
- Type hints where applicable

## 🎯 Priority Areas

We especially need help with:

1. **Performance optimizations** for low-end hardware
2. **Additional fingerprinting protections**
3. **Filter list curation** for piracy sites
4. **UI/UX improvements**
5. **Documentation** and tutorials
6. **Translations**
7. **Testing** on various platforms

## 🙏 Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in about page (with permission)

## 💬 Communication

- **Discord**: Real-time chat
- **Matrix**: Privacy-focused alternative
- **GitHub Issues**: Bug reports and features
- **GitHub Discussions**: General questions

## ⚖️ Code of Conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## 📝 License

By contributing, you agree that your contributions will be licensed under the same license as the project (BSD-3-Clause for Chromium parts, GPLv3 for Nickel additions).

---

Thank you for making Nickel better!🐅
