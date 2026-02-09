# Contributing to Rocky Linux Documentation

Thank you for your interest in contributing to Rocky Linux documentation. This guide walks you through everything you need to create, edit, and submit documentation that meets our standards.

## Quick Start

1. Fork the [Rocky Linux Documentation repository](https://github.com/rocky-linux/documentation)
2. Clone your fork locally
3. Set up pre-commit hooks (required)
4. Create or edit documentation
5. Run validation checks
6. Submit a pull request

## Prerequisites

Before contributing, you need:

- A [GitHub account](https://github.com/signup)
- [Git](https://git-scm.com/downloads) installed on your machine
- [Python 3.8+](https://www.python.org/downloads/) for spell checking
- [Node.js](https://nodejs.org/) for markdown linting
- A text editor (see [Local Editors](#local-editors) below)

## Fork and Clone the Repository

1. Navigate to the [Rocky Linux documentation repository](https://github.com/rocky-linux/documentation)
2. Click the **Fork** button in the upper right corner
3. Clone your fork to your local machine:

```bash
git clone https://github.com/YOUR_USERNAME/documentation.git
cd documentation
```

4. Add the upstream repository as a remote:

```bash
git remote add upstream https://github.com/rocky-linux/documentation.git
```

## Setting Up Your Environment

### Alternative Tooling

The setup instructions in this section describe one approach to documentation validation using pre-commit hooks and command-line tools. There are other methods available to check your markdown documents, before submitting them as a PR.

If you already use a terminal-based editor (Neovim, Emacs, Helix, etc.) with integrated linting tools, you can continue using your existing workflow. Tools like:

- [markdownlint](https://github.com/DavidAnson/markdownlint) or [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) - Available as editor plugins for real-time markdown linting
- [vale](https://github.com/errata-ai/vale) - Prose linter that can enforce style guide rules
- [harper-ls](https://github.com/Automattic/harper) - Grammar checker with LSP support
- [ltex-ls](https://github.com/valentjn/ltex-ls) - LanguageTool-based grammar and spell checking via LSP

These tools provide the same validation capabilities and can be configured to match the Rocky Linux documentation standards. The key requirement is that your contributions pass the automated CI checks when you submit a pull request, regardless of which tools you use locally.

### Rocky Linux 10 Setup

If you are running Rocky Linux 10, follow these steps to set up a complete documentation validation environment. This installs all required tools and enables you to run the same checks that the Documentation Team uses to validate pull requests.

#### Step 1: Install System Dependencies

```bash
# Note: npm is bundled with nodejs in Rocky Linux 10
sudo dnf install -y git python3-pip hunspell hunspell-en-US nodejs
```

#### Step 2: Install Python Packages

```bash
pip install pre-commit pyspelling
```

#### Step 3: Install Node.js Packages

```bash
sudo npm install -g markdownlint-cli
```

#### Step 4: Install Lychee Link Checker

Lychee is not available in the Rocky Linux repositories, so install the binary directly:

```bash
cd /tmp
curl -sLO https://github.com/lycheeverse/lychee/releases/latest/download/lychee-x86_64-unknown-linux-gnu.tar.gz
tar xzf lychee-x86_64-unknown-linux-gnu.tar.gz
sudo mv lychee /usr/local/bin/
sudo chmod +x /usr/local/bin/lychee
rm -f lychee-x86_64-unknown-linux-gnu.tar.gz
```

Verify the installation:

```bash
lychee --version
```

#### Step 5: Clone your Forked Repository and Configure it

```bash
git clone https://github.com/YOUR_USERNAME/documentation.git
cd documentation
```

If you have already cloned the repository, ensure it is up to date:

```bash
cd documentation
git pull origin main
```

#### Step 6: Configure Pyspelling for Hunspell

Rocky Linux 10 uses Hunspell instead of Aspell. Create a `.pyspelling.yml` file in the repository root if one does not exist or if you need to override the default:

```bash
cat > .pyspelling.yml << 'EOF'
spellchecker: hunspell
matrix:
  - name: Markdown
    sources:
      # Process English files only - exclude translations
      - 'docs/**/*.md|!docs/**/*.{af,de,en,es,fr,hi,id,it,ja,ko,pl,pt,pt-BR,sv,tr,uk,zh}.md'
    expect_match: false
    hunspell:
      d: en_US
    dictionary:
      wordlists:
        - .wordlist.txt
      output: build/spelling-wordlist.dic
    pipeline:
      - pyspelling.filters.markdown:
      - pyspelling.filters.html:
          comments: true
          ignores:
            - code
            - pre
            - kbd
      - pyspelling.filters.context:
          context_visible_first: true
          escapes: '\\[\\`]'
          delimiters:
            # Ignore front matter
            - open: '(?s)^---'
              close: '^---'
            # Ignore code blocks
            - open: '(?s)^(?P<open>`{3,}).*$'
              close: '^(?P=open)$'
            # Ignore inline code
            - open: '`'
              close: '`'
            # Ignore URLs
            - open: '\('
              content: 'https?://[^\)]*'
              close: '\)'
            # Ignore email addresses
            - open: '<'
              content: '[^>]+@[^>]+'
              close: '>'
      - pyspelling.filters.url:
EOF
```

#### Step 7: Install Pre-commit Hooks

```bash
pre-commit install
```

#### Step 8: Verify Your Setup

Run all validation checks to confirm everything is working:

```bash
pre-commit run --all-files
```

#### Expected Behavior on First Run

When running `pre-commit run --all-files` for the first time, you may see errors from existing repository files. This is expected behavior:

| Hook | Expected Result | Notes |
|------|-----------------|-------|
| trailing-whitespace | May auto-fix files | Changes are staged automatically |
| end-of-file-fixer | May auto-fix files | Changes are staged automatically |
| check-yaml | Pass | MkDocs config files are excluded |
| check-added-large-files | Pass | |
| markdownlint | May show errors | |
| pyspelling | Pass (with Hunspell config) | Requires Step 6 configuration |
| lychee | Pass | Some timeouts are normal |

**Important**: The markdownlint errors you see are in existing repository documentation files, not files you created. When contributing, you only need to ensure your own files pass validation.

#### Step 9: Validate Your Document

Before submitting your documentation, validate your specific file to ensure it passes all checks:

```bash
# Spell check
pyspelling -S "docs/guides/your-document.md"

# Markdown lint
markdownlint "docs/guides/your-document.md"

# Link check
lychee "docs/guides/your-document.md" --no-progress
```

Example output:

```text
markdownlint docs/guides/automation/kickstart-rocky-broken.md
docs/guides/automation/kickstart-rocky-broken.md:1 error MD041/first-line-heading/first-line-h1 First line in a file should be a top-level heading [Context: "---"]
docs/guides/automation/kickstart-rocky-broken.md:162 error MD001/heading-increment Heading levels should only increment by one level at a time [Expected: h2; Actual: h3]
```

#### Troubleshooting your Rocky Linux 10 Setup

**pre-commit error: ".pre-commit-config.yaml is not a file"**

This error means the `.pre-commit-config.yaml` file is missing from your local repository. Pull the latest changes from your fork:

```bash
git pull origin main
```

If your fork is behind the upstream repository, sync it first:

```bash
git fetch upstream
git merge upstream/main
git push origin main
```

**pyspelling error: "option 'attributes' must be a float type"**

This error occurs when the `.pyspelling.yml` configuration has an incorrectly formatted `attributes` option. The `attributes` option in the HTML filter must be either omitted or a list of strings. An empty `attributes:` key causes this error.

Solution: Use the complete Hunspell configuration provided in Step 6, which has the correct format.

**YAML check failures on MkDocs config files**

The `check-yaml` hook may fail on files like `mkdocs.yml` or `tools/mkdocs-docker.yml` because they use Python-specific YAML tags (`!ENV`, `tag:yaml.org,2002:python/name:...`). These files are excluded from YAML validation in the pre-commit configuration.

If you see YAML errors on these files, verify that your `.pre-commit-config.yaml` includes the exclusions:

```yaml
- id: check-yaml
  exclude: |
    (?x)^(
      tools/mkdocs-docker\.yml|
      tools/docker-compose\.yml|
      build_pdf/build_base\.yml|
      mkdocs\.yml
    )$
```

**lychee error: "unexpected argument '--exclude-mail'"**

The `--exclude-mail` flag was deprecated in lychee v0.15.x and removed in v0.19.x. Email addresses are now excluded by default. If you encounter this error, verify that your `.pre-commit-config.yaml` uses `--exclude 'mailto:'` instead of `--exclude-mail`.

### Rocky Linux 9 Setup

If you are running Rocky Linux 9, follow these steps to set up a complete documentation validation environment. Rocky Linux 9 uses Hunspell for spell checking (aspell is not available in EPEL for Rocky Linux 9).

#### Step 1: Install System Dependencies

```bash
sudo dnf install -y git python3-pip hunspell hunspell-en-US nodejs npm
```

#### Step 2: Install Python Packages

```bash
pip install --user pre-commit pyspelling
```

#### Step 3: Install Node.js Packages

```bash
sudo npm install -g markdownlint-cli
```

#### Step 4: Install Lychee Link Checker

Lychee is not available in the Rocky Linux repositories, so install the binary directly:

```bash
cd /tmp
curl -sLO https://github.com/lycheeverse/lychee/releases/latest/download/lychee-x86_64-unknown-linux-gnu.tar.gz
tar xzf lychee-x86_64-unknown-linux-gnu.tar.gz
sudo mv lychee /usr/local/bin/
sudo chmod +x /usr/local/bin/lychee
rm -f lychee-x86_64-unknown-linux-gnu.tar.gz
```

Verify the installation:

```bash
lychee --version
```

#### Step 5: Clone your Forked Repository and Configure it

```bash
git clone https://github.com/YOUR_USERNAME/documentation.git
cd documentation
```

#### Step 6: Configure Pyspelling for Hunspell

Rocky Linux 9 uses Hunspell instead of Aspell. Create a `.pyspelling.yml` file in the repository root:

```bash
cat > .pyspelling.yml << 'EOF'
spellchecker: hunspell
matrix:
  - name: Markdown
    sources:
      # Process English files only - exclude translations
      - 'docs/**/*.md|!docs/**/*.{af,de,en,es,fr,hi,id,it,ja,ko,pl,pt,pt-BR,sv,tr,uk,zh}.md'
    expect_match: false
    hunspell:
      d: en_US
    dictionary:
      wordlists:
        - .wordlist.txt
      output: build/spelling-wordlist.dic
    pipeline:
      - pyspelling.filters.markdown:
      - pyspelling.filters.html:
          comments: true
          ignores:
            - code
            - pre
            - kbd
      - pyspelling.filters.context:
          context_visible_first: true
          escapes: '\\[\\`]'
          delimiters:
            # Ignore front matter
            - open: '(?s)^---'
              close: '^---'
            # Ignore code blocks
            - open: '(?s)^(?P<open>`{3,}).*$'
              close: '^(?P=open)$'
            # Ignore inline code
            - open: '`'
              close: '`'
            # Ignore URLs
            - open: '\('
              content: 'https?://[^\)]*'
              close: '\)'
            # Ignore email addresses
            - open: '<'
              content: '[^>]+@[^>]+'
              close: '>'
      - pyspelling.filters.url:
EOF
```

#### Step 7: Install Pre-commit Hooks

```bash
~/.local/bin/pre-commit install
```

**Note**: When using `pip install --user`, the `pre-commit` binary is installed to `~/.local/bin/`. You can either use the full path or add `~/.local/bin` to your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### Step 8: Verify Your Setup

Run all validation checks to confirm everything is working:

```bash
~/.local/bin/pre-commit run --all-files
```

#### Step 9: Validate Your Document

Before submitting your documentation, validate your specific file to ensure it passes all checks:

```bash
# Spell check
pyspelling -S "docs/guides/your-document.md"

# Markdown lint
markdownlint "docs/guides/your-document.md"

# Link check
lychee "docs/guides/your-document.md" --no-progress
```

#### Troubleshooting Rocky Linux 9 Setup

**aspell not available**

Unlike Rocky Linux 8, aspell is not available in EPEL for Rocky Linux 9. Use Hunspell instead:

```bash
# Verify Hunspell is installed
rpm -q hunspell hunspell-en-US

# If not installed
sudo dnf install -y hunspell hunspell-en-US
```

**pre-commit command not found**

When using `pip install --user`, the binary is in `~/.local/bin/`:

```bash
# Use full path
~/.local/bin/pre-commit install

# Or add to PATH
export PATH="$HOME/.local/bin:$PATH"
```

### Rocky Linux 8 Setup

If you are running Rocky Linux 8, follow these steps to set up a complete documentation validation environment. Rocky Linux 8 uses Aspell for spell checking (available from base repositories).

#### Step 1: Install System Dependencies

Rocky Linux 8 uses Python 3.9 and Node.js module streams:

```bash
# Install Python 3.9 and other dependencies
sudo dnf install -y git python39-pip python39 aspell aspell-en

# Enable Node.js 18 module stream
sudo dnf module enable -y nodejs:18

# Install Node.js
sudo dnf install -y nodejs
```

#### Step 2: Install Python Packages

Use Python 3.9's pip:

```bash
pip3.9 install --user pre-commit pyspelling
```

#### Step 3: Install Node.js Packages

```bash
sudo npm install -g markdownlint-cli
```

#### Step 4: Install Lychee Link Checker

Lychee is not available in the Rocky Linux repositories, so install the binary directly:

```bash
cd /tmp
curl -sLO https://github.com/lycheeverse/lychee/releases/latest/download/lychee-x86_64-unknown-linux-gnu.tar.gz
tar xzf lychee-x86_64-unknown-linux-gnu.tar.gz
sudo mv lychee /usr/local/bin/
sudo chmod +x /usr/local/bin/lychee
rm -f lychee-x86_64-unknown-linux-gnu.tar.gz
```

Verify the installation:

```bash
lychee --version
```

#### Step 5: Clone your Forked Repository and Configure it

```bash
git clone https://github.com/YOUR_USERNAME/documentation.git
cd documentation
```

#### Step 6: Configure Pyspelling for Aspell

Rocky Linux 8 uses Aspell from the base repositories. Create a `.pyspelling.yml` file in the repository root:

```bash
cat > .pyspelling.yml << 'EOF'
spellchecker: aspell
matrix:
  - name: Markdown
    sources:
      # Process English files only - exclude translations
      - 'docs/**/*.md|!docs/**/*.{af,de,en,es,fr,hi,id,it,ja,ko,pl,pt,pt-BR,sv,tr,uk,zh}.md'
    expect_match: false
    aspell:
      lang: en
      d: en_US
    dictionary:
      wordlists:
        - .wordlist.txt
      output: build/spelling-wordlist.dic
    pipeline:
      - pyspelling.filters.markdown:
      - pyspelling.filters.html:
          comments: true
          ignores:
            - code
            - pre
            - kbd
      - pyspelling.filters.context:
          context_visible_first: true
          escapes: '\\[\\`]'
          delimiters:
            # Ignore front matter
            - open: '(?s)^---'
              close: '^---'
            # Ignore code blocks
            - open: '(?s)^(?P<open>`{3,}).*$'
              close: '^(?P=open)$'
            # Ignore inline code
            - open: '`'
              close: '`'
            # Ignore URLs
            - open: '\('
              content: 'https?://[^\)]*'
              close: '\)'
            # Ignore email addresses
            - open: '<'
              content: '[^>]+@[^>]+'
              close: '>'
      - pyspelling.filters.url:
EOF
```

#### Step 7: Install Pre-commit Hooks

```bash
~/.local/bin/pre-commit install
```

**Note**: When using `pip install --user`, the `pre-commit` binary is installed to `~/.local/bin/`. You can either use the full path or add `~/.local/bin` to your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### Step 8: Verify Your Setup

Run all validation checks to confirm everything is working:

```bash
~/.local/bin/pre-commit run --all-files
```

#### Step 9: Validate Your Document

Before submitting your documentation, validate your specific file to ensure it passes all checks:

```bash
# Spell check
pyspelling -S "docs/guides/your-document.md"

# Markdown lint
markdownlint "docs/guides/your-document.md"

# Link check
lychee "docs/guides/your-document.md" --no-progress
```

#### Troubleshooting Rocky Linux 8 Setup

**Python 3.6 vs Python 3.9**

Rocky Linux 8 ships with Python 3.6 by default, but newer packages like pre-commit require Python 3.9+:

```bash
# Install Python 3.9
sudo dnf install -y python39 python39-pip

# Use Python 3.9 pip explicitly
pip3.9 install --user pre-commit pyspelling
```

**Node.js version too old**

Rocky Linux 8 defaults to Node.js 10, which is too old. Enable the Node.js 18 module stream:

```bash
# Enable Node.js 18 module stream
sudo dnf module enable -y nodejs:18

# Install or upgrade Node.js
sudo dnf install -y nodejs
```

**pre-commit command not found**

When using `pip install --user`, the binary is in `~/.local/bin/`:

```bash
# Use full path
~/.local/bin/pre-commit install

# Or add to PATH
export PATH="$HOME/.local/bin:$PATH"
```

### macOS Sequoia Setup

If you are running macOS Sequoia (macOS 15), follow these steps to set up a complete documentation validation environment. These instructions have been tested on both Apple Silicon (M1/M2/M3/M4) and Intel Macs.

#### Step 1: Install Xcode Command Line Tools

Before installing Homebrew, you must install the Xcode Command Line Tools:

```bash
xcode-select --install
```

A dialog box will appear asking you to install the tools. Click **Install** and wait for the installation to complete.

#### Step 2: Install Homebrew (if not already installed)

If you do not have [Homebrew](https://brew.sh/) installed, run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Important for Apple Silicon Macs (M1/M2/M3/M4)**: Homebrew installs to `/opt/homebrew` on Apple Silicon, which is not in the default PATH. After installation, run these commands to configure your shell:

```bash
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Verify Homebrew is working:

```bash
brew doctor
```

**Note for Intel Macs**: Homebrew installs to `/usr/local` on Intel Macs, which is already in the default PATH. No additional configuration is needed.

#### Step 3: Install System Dependencies

```bash
brew install git python node aspell lychee
```

#### Step 4: Install Python Packages

The recommended approach is to use a virtual environment:

```bash
python3 -m venv ~/rocky-docs-env
source ~/rocky-docs-env/bin/activate
pip install pre-commit pyspelling
```

Add an alias to your shell configuration for easy activation:

```bash
echo "alias rocky-docs-env='source ~/rocky-docs-env/bin/activate'" >> ~/.zshrc
source ~/.zshrc
```

#### Step 5: Install Node.js Packages

If you encounter permission errors with npm global installs, configure npm to use a user directory:

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Then install markdownlint:

```bash
npm install -g markdownlint-cli
```

#### Step 6: Clone your Forked Repository and Configure it

```bash
git clone https://github.com/YOUR_USERNAME/documentation.git
cd documentation
```

Add the upstream remote:

```bash
git remote add upstream https://github.com/rocky-linux/documentation.git
```

#### Step 7: Configure Pyspelling for macOS

macOS uses Aspell (installed via Homebrew). Create a `.pyspelling.yml` file in the repository root configured for Aspell:

```bash
cat > .pyspelling.yml << 'EOF'
spellchecker: aspell
matrix:
  - name: Markdown
    sources:
      - 'docs/**/*.md'
    expect_match: false
    aspell:
      lang: en
      d: en_US
    dictionary:
      wordlists:
        - .wordlist.txt
      output: build/spelling-wordlist.dic
    pipeline:
      - pyspelling.filters.markdown
      - pyspelling.filters.html:
          ignores:
            - code
            - pre
            - kbd
      - pyspelling.filters.context:
          context_visible_first: true
          escapes: '\\[\\`]'
          delimiters:
            - open: '(?s)^---'
              close: '^---'
            - open: '(?s)^(?P<open>`{3,}).*$'
              close: '^(?P=open)$'
            - open: '`'
              close: '`'
            - open: '\('
              content: 'https?://[^\)]*'
              close: '\)'
            - open: '<'
              content: '[^>]+@[^>]+'
              close: '>'
      - pyspelling.filters.url
EOF
```

#### Step 8: Install Pre-commit Hooks

```bash
pre-commit install
```

#### Step 9: Verify Your Setup

Run the validation checks:

```bash
pre-commit run --all-files
```

**Note**: The pyspelling (spell check) and lychee (link check) hooks are configured as manual hooks to avoid long run times on the full repository. When running `pre-commit run --all-files`, you may see markdownlint errors from existing repository files. These are pre-existing issues and are not your responsibility to fix.

#### Validating Your Own Documents

When contributing, validate your specific document using these commands:

```bash
# Activate the virtual environment first
rocky-docs-env

# Markdown lint check
markdownlint docs/guides/your-document.md

# Spell check
pyspelling -S docs/guides/your-document.md

# Link check
lychee docs/guides/your-document.md --no-progress
```

#### Troubleshooting macOS Sequoia Setup

**pip3 command not found**

If `pip3` is not found after installing Python via Homebrew:

```bash
# Verify Python installation
python3 --version

# Use python3 -m pip instead
python3 -m pip install pre-commit pyspelling
```

**Permission denied when installing Python packages**

macOS Sequoia enforces stricter security. Use a virtual environment (recommended):

```bash
python3 -m venv ~/rocky-docs-env
source ~/rocky-docs-env/bin/activate
pip install pre-commit pyspelling
```

**aspell dictionary not found**

The Homebrew aspell package includes common language dictionaries. Verify installation:

```bash
brew install aspell
aspell dump dicts | grep en
```

**npm global install permission errors**

Configure npm to use a user-writable directory:

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
npm install -g markdownlint-cli
```

**pre-commit hook failures on Apple Silicon (M1/M2/M3/M4)**

If you encounter architecture-related errors:

```bash
# Ensure Homebrew is correctly configured for Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# Reinstall tools if needed
brew reinstall python node aspell lychee
```

**"Too many open files" error with lychee**

macOS has a low default file descriptor limit. Increase it before running lychee on many files:

```bash
ulimit -n 4096
lychee docs/
```

**Certificate verification errors with lychee**

If you encounter SSL errors:

```bash
# Update certificates
brew install ca-certificates

# Or use lychee with certificate verification disabled for testing (not recommended for final validation)
lychee --insecure docs/your-document.md
```

### Windows 11 Setup

If you are running Windows 11, follow these steps to set up a complete documentation validation environment.

#### Step 1: Install Chocolatey Package Manager

Open **PowerShell as Administrator** (right-click Start → Terminal (Admin)) and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
iwr https://community.chocolatey.org/install.ps1 -UseBasicParsing | iex
```

Close and reopen PowerShell as Administrator after installation.

#### Step 2: Install Git, Python, and Node.js

```powershell
choco install -y git python nodejs-lts
```

Close and reopen PowerShell as Administrator to refresh the PATH.

#### Step 3: Install Python Packages

```powershell
pip install pre-commit pyspelling
```

#### Step 4: Install Node.js Packages

```powershell
npm install -g markdownlint-cli
```

#### Step 5: Install Hunspell (Spell Checker)

```powershell
choco install -y hunspell.portable
```

#### Step 6: Install Lychee (Link Checker)

```powershell
choco install -y lychee
```

#### Step 7: Clone your Forked Repository and Configure it

```powershell
cd ~\Documents
git clone https://github.com/YOUR_USERNAME/documentation.git
cd documentation
```

#### Step 8: Create Pre-commit Configuration

Create a `.pre-commit-config.yaml` file in the repository root:

```powershell
@"
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
        args: [--markdown-linebreak-ext=md]
      - id: end-of-file-fixer
      - id: check-yaml
        exclude: |
          (?x)^(
            tools/mkdocs-docker\.yml|
            tools/docker-compose\.yml|
            build_pdf/build_base\.yml|
            mkdocs\.yml
          )$
      - id: check-added-large-files
        args: ['--maxkb=1024']

  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.38.0
    hooks:
      - id: markdownlint
        args:
          - --config
          - .markdownlint.yml
          - --fix
        files: \.md$
        exclude: |
          (?x)^(
            LICENSE\.md|
            build_pdf/.*
          )$
"@ | Out-File -FilePath .pre-commit-config.yaml -Encoding UTF8
```

#### Step 9: Install Pre-commit Hooks

```powershell
pre-commit install
```

#### Step 10: Verify Your Setup

Run validation checks to confirm everything is working:

```powershell
pre-commit run --files docs/guides/automation/kickstart-rocky.md
```

#### Troubleshooting Windows 11 Setup

**Chocolatey installation fails**

If the Chocolatey installation command fails due to line break issues when pasting, run the two commands separately:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

Then:

```powershell
iwr https://community.chocolatey.org/install.ps1 -UseBasicParsing | iex
```

**Commands not found after installation**

Close and reopen PowerShell after installing packages to refresh the PATH environment variable.

**aspell not available**

Aspell is not available in Chocolatey. Use Hunspell instead:

```powershell
choco install -y hunspell.portable
```

**Permission errors with pip or npm**

Run PowerShell as Administrator for all installation commands.

**pre-commit config file not found**

Ensure you created the `.pre-commit-config.yaml` file in the repository root directory (the `documentation` folder, not a subdirectory).

**Alternative: Use winget instead of Chocolatey**

Windows 11 includes winget by default. You can use it as an alternative:

```powershell
winget install Git.Git Python.Python.3.12 OpenJS.NodeJS.LTS
```

Note: You will still need Chocolatey for hunspell and lychee, or download them manually.

### Install Pre-commit Hooks (Required)

Pre-commit hooks run automatically before each commit to check spelling, markdown formatting, and links. You must set these up before contributing.

**Platform-specific setup guides** - Follow the appropriate section instead of the general instructions below:

- [Rocky Linux 10 Setup](#rocky-linux-10-setup) - Uses Hunspell, npm bundled with nodejs
- [Rocky Linux 9 Setup](#rocky-linux-9-setup) - Uses Hunspell (aspell not available in EPEL)
- [Rocky Linux 8 Setup](#rocky-linux-8-setup) - Uses Aspell, requires Python 3.9 and Node.js 18 module
- [macOS Sequoia Setup](#macos-sequoia-setup) - Uses Homebrew and Aspell
- [Windows 11 Setup](#windows-11-setup) - Uses Chocolatey, Hunspell, and PowerShell

1. Install pre-commit:

```bash
pip install pre-commit
```

2. Install the required tools:

```bash
# Install pyspelling for spell checking
pip install pyspelling

# Install aspell dictionaries (varies by OS)
# On Rocky Linux / RHEL / Fedora:
sudo dnf install aspell aspell-en

# On Debian / Ubuntu:
sudo apt-get install aspell aspell-en

# On macOS:
brew install aspell

# Install markdownlint-cli for markdown linting
npm install -g markdownlint-cli

# Install lychee for link checking
# On Rocky Linux 10 (binary installation - lychee is not in repos):
cd /tmp && curl -sLO https://github.com/lycheeverse/lychee/releases/latest/download/lychee-x86_64-unknown-linux-gnu.tar.gz
tar xzf lychee-x86_64-unknown-linux-gnu.tar.gz && sudo mv lychee /usr/local/bin/
sudo chmod +x /usr/local/bin/lychee && rm -f lychee-x86_64-unknown-linux-gnu.tar.gz

# On Fedora (may be available in repos):
sudo dnf install lychee

# On Debian / Ubuntu (via cargo):
cargo install lychee

# On macOS:
brew install lychee
```

3. Install the pre-commit hooks:

```bash
pre-commit install
```

4. Verify the installation by running hooks manually:

```bash
pre-commit run --all-files
```

## Creating New Documentation

### Document Naming

Use lowercase filenames with underscores or hyphens. Keep names short and descriptive:

- `kickstart_rocky.md` - Good
- `HowToInstallRockyLinuxUsingKickstart.md` - Too long
- `ks.md` - Too vague

For translated documents, append the language code before `.md`:

- `kickstart_rocky.md` - English (default)
- `kickstart_rocky.de.md` - German
- `kickstart_rocky.es.md` - Spanish

### Document Location

Place your document in the appropriate directory under `docs/guides/`:

| Topic | Directory |
|-------|-----------|
| Automation tasks | `docs/guides/automation/` |
| Backup solutions | `docs/guides/backup/` |
| Cloud deployments | `docs/guides/cloud/` |
| Content management | `docs/guides/cms/` |
| Communication tools | `docs/guides/communications/` |
| Container technologies | `docs/guides/containers/` |
| Contributing guides | `docs/guides/contribute/` |
| Database systems | `docs/guides/database/` |
| Desktop environments | `docs/guides/desktop/` |
| DNS configuration | `docs/guides/dns/` |
| Text editors | `docs/guides/editors/` |
| Email servers | `docs/guides/email/` |
| File sharing | `docs/guides/file_sharing/` |
| Hardware guides | `docs/guides/hardware/` |
| Interoperability | `docs/guides/interoperability/` |
| Kernel topics | `docs/guides/kernel/` |
| Mirror management | `docs/guides/mirror_management/` |
| Networking | `docs/guides/network/` |
| Package management | `docs/guides/package_management/` |
| Proxy servers | `docs/guides/proxies/` |
| Repositories | `docs/guides/repositories/` |
| Security | `docs/guides/security/` |
| Troubleshooting | `docs/guides/troubleshooting/` |
| Virtualization | `docs/guides/virtualization/` |
| Web servers | `docs/guides/web/` |

If your guide does not fit any existing category, place it in the most relevant directory or ask the documentation team in the [Mattermost Documentation channel](https://chat.rockylinux.org/rocky-linux/channels/documentation).

### Document Structure

Every document must include front matter metadata at the top:

```yaml
---
title: Your Document Title
author: Your Name
contributors: Comma, Separated, Names
tested_with: 8.10, 9.7, 10.1
tags:
  - relevant
  - tags
  - here
---
```

After the front matter, structure your document with:

1. A brief introduction explaining what the guide covers
2. Prerequisites or requirements
3. Step-by-step instructions
4. Conclusion or summary

### Example Guides

Feel free to take a look at some example gudes to understand the formatting and styling:

- [Kickstart Files and Rocky Linux](https://docs.rockylinux.org/guides/automation/kickstart-rocky/)
- [Setting Up libvirt on Rocky Linux](https://docs.rockylinux.org/guides/virtualization/libvirt-rocky/)
- [Automatic template creation with Packer and deployment with Ansible in a VMware vSphere environment](https://docs.rockylinux.org/guides/automation/templates-automation-packer-vsphere/)

### AI Usage

The Rocky Linux Documentation Team permits AI and LLM tools in the contribution process, following the [Fedora AI Policy](https://docs.fedoraproject.org/en-US/docs/ai-policy/) as a baseline. If you use AI for any part of your documentation (drafting, research, grammar, code generation), you must include a disclosure at the beginning of your document stating that AI was used and that you take full responsibility for correctness. You must test every procedure and verify all technical content yourself, as AI frequently produces errors. Do not pass other contributors' existing work through AI tools and resubmit it as a contribution, as this erases the original author's voice and creates unnecessary churn. Minor corrections such as typos and broken links do not require disclosure.

## Formatting Guidelines

### Style Guide

Follow the [Rocky Linux Style Guide](https://docs.rockylinux.org/guides/contribute/style_guide/) for:

- Grammar and punctuation standards
- Voice and tone guidelines
- Accessibility requirements

Key points:

- Use US English spelling
- Use active voice
- Avoid contractions (aids translation)
- Use sentence-style capitalization for headings
- Use serial commas ("apples, oranges, and bananas")

### Markdown Formatting

Follow the [Document Formatting Guide](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting/) for:

- Admonitions (note, warning, tip boxes)
- Code blocks
- Tables
- Lists

Key rules enforced by our linter:

- Use dashes (`-`) for unordered lists, not asterisks
- Include blank lines around headings
- Use fenced code blocks with language identifiers
- Avoid trailing whitespace
- End files with a single newline

### Code Blocks

Always specify the language for syntax highlighting:

````markdown
```bash
dnf install httpd
systemctl enable --now httpd
```
````

For commands where output is shown, use `text` as the language:

````markdown
```text
$ hostname
rocky.example.com
```
````

## Validation Checks

Before committing, the pre-commit hooks automatically run:

1. **Spell check** (pyspelling) - Checks for US English spelling errors
2. **Markdown lint** (markdownlint) - Validates markdown formatting
3. **Link check** (lychee) - Verifies all links are valid

If any check fails, the commit is blocked. Fix the issues and try again.

### Running Checks Manually

Run all checks:

```bash
pre-commit run --all-files
```

Run individual checks:

```bash
# Spell check only
pyspelling

# Markdown lint only
markdownlint docs/

# Link check only
lychee docs/
```

### Rocky Docs Contribution Guidelines Validation

Beyond the standard checks, your document must comply with the [Rocky Linux Documentation Contribution Guidelines](https://docs.rockylinux.org/guides/contribute/) and [Formatting Standards](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting/). Use the following checks to validate your document before submitting a pull request.

#### Validate a Single Document

Replace `path/to/your-document.md` with your document path in all commands below.

**Run standard checks on your document:**

```bash
# Spell check
pyspelling -S "path/to/your-document.md"

# Markdown lint
markdownlint "path/to/your-document.md"

# Link check
lychee "path/to/your-document.md" --no-progress
```

#### Metadata Validation

Every document requires front matter metadata. Check that your document includes:

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Document title |
| `author` | Yes | Your name |
| `contributors` | Recommended | Comma-separated list of contributors |
| `tested_with` | Yes | Rocky Linux versions tested (e.g., `8.10, 9.7, 10.1`) |
| `tags` | Yes | Searchable one-word terms |

**Check for required metadata:**

```bash
# Check for title
grep -q '^title:' path/to/your-document.md && echo "✓ Title found" || echo "✗ Missing title"

# Check for author
grep -q '^author:' path/to/your-document.md && echo "✓ Author found" || echo "✗ Missing author"

# Check for contributors (recommended)
grep -q '^contributors:' path/to/your-document.md && echo "✓ Contributors found" || echo "⚠ Contributors recommended"

# Check for tested with
grep -qE '^tested.*(with|_with|on)?:' path/to/your-document.md && echo "✓ Tested with found" || echo "✗ Missing tested with"

# Check for tags
grep -q '^tags:' path/to/your-document.md && echo "✓ Tags found" || echo "✗ Missing tags"
```

#### Heading Structure Validation

Documents should have at most one Level 1 heading (`#`). If your document has `title:` metadata, the title is auto-generated, so you may not need a Level 1 heading at all.

```bash
# Count Level 1 headings (should be 0 or 1)
h1_count=$(grep -c '^# ' path/to/your-document.md || echo 0)
if [ "$h1_count" -le 1 ]; then
    echo "✓ Heading structure OK ($h1_count H1 headings)"
else
    echo "✗ Too many H1 headings: $h1_count (maximum 1 allowed)"
fi
```

#### Admonition Formatting

Admonitions use the `!!!` syntax with proper types and 4-space indentation for content:

```markdown
!!! warning "Optional Custom Title"

    This content must be indented with 4 spaces.
```

Valid admonition types: `note`, `abstract`, `info`, `tip`, `success`, `question`, `warning`, `failure`, `danger`, `bug`, `example`, `quote`

```bash
# Check admonition syntax
if grep -qE '^!!!\s+(note|abstract|info|tip|success|question|warning|failure|danger|bug|example|quote)' path/to/your-document.md; then
    echo "✓ Admonitions use valid types"
else
    if grep -q '^!!!' path/to/your-document.md; then
        echo "⚠ Admonitions found but may have invalid types"
    else
        echo "ℹ No admonitions found"
    fi
fi
```

#### Code Block Validation

Code blocks must specify a language identifier for syntax highlighting:

````markdown
```bash
dnf install httpd
```
````

```bash
# Check for code blocks without language identifiers
blocks_without_lang=$(grep -c '^```$' path/to/your-document.md 2>/dev/null || echo 0)
blocks_with_lang=$(grep -c '^```[a-zA-Z]' path/to/your-document.md 2>/dev/null || echo 0)

if [ "$blocks_without_lang" -eq 0 ]; then
    echo "✓ All code blocks have language identifiers ($blocks_with_lang blocks)"
else
    echo "✗ $blocks_without_lang code blocks missing language identifiers"
fi
```

#### Link Format Validation

Links should use proper markdown format `[text](url)`. Avoid bare URLs.

```bash
# Count properly formatted links
proper_links=$(grep -oE '\[[^]]+\]\([^)]+\)' path/to/your-document.md 2>/dev/null | wc -l)
echo "ℹ Found $proper_links properly formatted links"
```

#### Lab Domain Validation

When using example URLs in documentation, use approved domains to pass link validation:

- `example.com`, `example.org`, `example.net`
- `home.arpa`
- `localhost` or `127.0.0.1`

#### Internal Anchors Warning

Avoid internal document anchors like `[link](#section-name)` as they may break during translation.

```bash
# Check for internal anchors
anchors=$(grep -cE '\[.+\]\(#[^)]+\)' path/to/your-document.md 2>/dev/null || echo 0)
if [ "$anchors" -eq 0 ]; then
    echo "✓ No internal anchors found"
else
    echo "⚠ Found $anchors internal anchors (may break during translation)"
fi
```

#### Raw HTML Warning

Avoid using raw HTML elements. Markdown linters flag them and they may not render correctly. The following HTML elements are allowed in `.markdownlint.yml` and will not trigger linting errors:

- `<sub>` and `<sup>` - For subscript and superscript text
- `<details>` and `<summary>` - For collapsible/expandable content sections

```bash
# Check for HTML tags (excluding allowed elements: sub, sup, details, summary)
html_tags=$(grep -cE '<(?!sub|sup|details|summary|/sub|/sup|/details|/summary)[a-zA-Z][^>]*>' path/to/your-document.md 2>/dev/null || echo 0)
if [ "$html_tags" -eq 0 ]; then
    echo "✓ No disallowed raw HTML found"
else
    echo "⚠ Found $html_tags HTML tags (use markdown instead, or allowed elements: sub, sup, details, summary)"
fi
```

#### Complete Validation Script

Save this script as `validate-doc.sh` and run it against your document:

```bash
#!/bin/bash
# Rocky Linux Documentation Validator
# Usage: ./validate-doc.sh path/to/your-document.md

if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-markdown-file>"
    exit 1
fi

DOC="$1"

if [ ! -f "$DOC" ]; then
    echo "Error: File not found: $DOC"
    exit 1
fi

echo "============================================"
echo "ROCKY LINUX DOCUMENTATION VALIDATOR"
echo "============================================"
echo "Document: $DOC"
echo "--------------------------------------------"
echo ""
echo "METADATA CHECKS:"
echo "--------------------------------------------"
grep -q '^title:' "$DOC" && echo "  Title:        ✓ PASS" || echo "  Title:        ✗ FAIL - Required"
grep -q '^author:' "$DOC" && echo "  Author:       ✓ PASS" || echo "  Author:       ✗ FAIL - Required"
grep -q '^contributors:' "$DOC" && echo "  Contributors: ✓ PASS" || echo "  Contributors: ⚠ WARN - Recommended"
grep -qE '^tested.*(with|_with|on)?:' "$DOC" && echo "  Tested With:  ✓ PASS" || echo "  Tested With:  ✗ FAIL - Required"
grep -q '^tags:' "$DOC" && echo "  Tags:         ✓ PASS" || echo "  Tags:         ✗ FAIL - Required"
echo ""
echo "STRUCTURE CHECKS:"
echo "--------------------------------------------"
h1_count=$(grep -c '^# ' "$DOC" 2>/dev/null || echo 0)
if [ "$h1_count" -le 1 ]; then
    echo "  Single H1:    ✓ PASS ($h1_count heading)"
else
    echo "  Single H1:    ✗ FAIL - Found $h1_count (max 1)"
fi
echo ""
echo "FORMATTING CHECKS:"
echo "--------------------------------------------"
blocks_without_lang=$(grep -c '^```$' "$DOC" 2>/dev/null || echo 0)
if [ "$blocks_without_lang" -eq 0 ]; then
    echo "  Code Blocks:  ✓ PASS"
else
    echo "  Code Blocks:  ✗ FAIL - $blocks_without_lang missing language"
fi

anchors=$(grep -cE '\[.+\]\(#[^)]+\)' "$DOC" 2>/dev/null || echo 0)
if [ "$anchors" -eq 0 ]; then
    echo "  No Anchors:   ✓ PASS"
else
    echo "  No Anchors:   ⚠ WARN - $anchors found (translation risk)"
fi

html_tags=$(grep -cE '<(?!sub|sup|details|summary|/sub|/sup|/details|/summary)[a-zA-Z][^>]*>' "$DOC" 2>/dev/null || echo 0)
if [ "$html_tags" -eq 0 ]; then
    echo "  No Raw HTML:  ✓ PASS (sub, sup, details, summary are allowed)"
else
    echo "  No Raw HTML:  ⚠ WARN - $html_tags disallowed tags found"
fi
echo ""
echo "TOOL CHECKS:"
echo "--------------------------------------------"
echo "Running pyspelling..."
if pyspelling -S "$DOC" > /dev/null 2>&1; then
    echo "  Spell Check:  ✓ PASS"
else
    echo "  Spell Check:  ✗ FAIL - Run: pyspelling -S \"$DOC\""
fi

echo "Running markdownlint..."
if markdownlint "$DOC" > /dev/null 2>&1; then
    echo "  Markdown:     ✓ PASS"
else
    echo "  Markdown:     ✗ FAIL - Run: markdownlint \"$DOC\""
fi

echo "Running lychee..."
if lychee "$DOC" --no-progress > /dev/null 2>&1; then
    echo "  Links:        ✓ PASS"
else
    echo "  Links:        ✗ FAIL - Run: lychee \"$DOC\" --no-progress"
fi
echo ""
echo "============================================"
```

Make the script executable and run it:

```bash
chmod +x validate-doc.sh
./validate-doc.sh docs/guides/automation/kickstart-rocky.md
```

Example output:

```text
============================================
ROCKY LINUX DOCUMENTATION VALIDATOR
============================================
Document: docs/guides/automation/kickstart-rocky.md
--------------------------------------------

METADATA CHECKS:
--------------------------------------------
  Title:        ✓ PASS
  Author:       ✓ PASS
  Contributors: ✓ PASS
  Tested With:  ✓ PASS
  Tags:         ✓ PASS

STRUCTURE CHECKS:
--------------------------------------------
  Single H1:    ✓ PASS (1 heading)

FORMATTING CHECKS:
--------------------------------------------
  Code Blocks:  ✓ PASS
  No Anchors:   ✓ PASS
  No Raw HTML:  ✓ PASS

TOOL CHECKS:
--------------------------------------------
Running pyspelling...
  Spell Check:  ✓ PASS
Running markdownlint...
  Markdown:     ✓ PASS
Running lychee...
  Links:        ✓ PASS

============================================
```

### Adding Words to the Dictionary

If the spell checker flags a valid technical term, add it to `.wordlist.txt` in alphabetical order. Common additions include:

- Rocky Linux specific terms
- Package names
- Technical acronyms
- Command names

## Editing Existing Documentation

1. Sync your fork with upstream:

```bash
git fetch upstream
git checkout main
git merge upstream/main
```

2. Create a branch for your changes:

```bash
git checkout -b fix-typo-in-installation-guide
```

3. Make your edits and commit:

```bash
git add docs/guides/installation.md
git commit -m "Fix typo in installation guide"
```

4. Push and create a pull request:

```bash
git push origin fix-typo-in-installation-guide
```

## Submitting a Pull Request

1. Push your branch to your fork
2. Navigate to the [upstream repository](https://github.com/rocky-linux/documentation)
3. Click **New Pull Request**
4. Select your fork and branch
5. Fill in the pull request template:
   - Describe what you changed
   - Explain why you made the change
   - Reference any related issues

After submission, GitHub Actions runs the same validation checks. The documentation team reviews your pull request and may request changes.

## Local Editors

Choose a markdown editor that suits your workflow:

### Graphical Editors

- [ReText](https://github.com/retext-project/retext) - Free, cross-platform, open source
- [Zettlr](https://www.zettlr.com/) - Free, cross-platform, open source
- [MarkText](https://github.com/marktext/marktext) - Free, cross-platform, open source
- [Remarkable](https://remarkableapp.github.io/) - Linux and Windows, open source
- [VS Code](https://code.visualstudio.com/) - Partially open source, by Microsoft. Recommended extensions: Git Graph, Markdown All in One, Markdown Preview Enhanced, markdownlint

### Terminal Editors

- [NvChad](https://nvchad.com/) - For Neovim users. See our [NvChad setup guide](https://docs.rockylinux.org/books/nvchad/)
- [Doom Emacs](https://github.com/doomemacs/doomemacs) - For Emacs users. Enable the `markdown` module in your config

Terminal editors can integrate the same validation tools used by the pre-commit hooks directly into your editing workflow:

- [markdownlint](https://github.com/DavidAnson/markdownlint)
- [vale](https://github.com/errata-ai/vale)
- [harper-ls](https://github.com/Automattic/harper)
- [ltex-ls](https://github.com/valentjn/ltex-ls)

## Troubleshooting

### Pre-commit Hook Failures

**pyspelling not found**:

```bash
# Install pyspelling
pip install pyspelling

# Verify installation
pyspelling --version
```

**aspell or hunspell dictionary not found**:

```bash
# Rocky Linux 10 and Rocky Linux 9 (uses Hunspell)
sudo dnf install hunspell hunspell-en-US

# Rocky Linux 8, RHEL, Fedora (Aspell)
sudo dnf install aspell aspell-en

# Debian / Ubuntu
sudo apt-get install aspell aspell-en

# macOS
brew install aspell
```

**Note for Rocky Linux 9 and 10 users**: Rocky Linux 9 and 10 use Hunspell instead of Aspell. The `aspell` package is not available in Rocky Linux 9 EPEL or Rocky Linux 10 base repositories. If you encounter spell check errors, ensure your `.pyspelling.yml` is configured for Hunspell (see [Rocky Linux 10 Setup](#rocky-linux-10-setup) or [Rocky Linux 9 Setup](#rocky-linux-9-setup)).

To verify which spell checker is installed:

```bash
# Check for Hunspell (Rocky Linux 9 and 10)
rpm -q hunspell hunspell-en-US

# Check for Aspell (Rocky Linux 8)
rpm -q aspell aspell-en
```

**markdownlint not found**:

```bash
# Install Node.js first, then:
npm install -g markdownlint-cli

# Verify installation
markdownlint --version
```

**lychee not found**:

```bash
# Rocky Linux 10 (install binary directly)
cd /tmp
curl -sLO https://github.com/lycheeverse/lychee/releases/latest/download/lychee-x86_64-unknown-linux-gnu.tar.gz
tar xzf lychee-x86_64-unknown-linux-gnu.tar.gz
sudo mv lychee /usr/local/bin/
sudo chmod +x /usr/local/bin/lychee
rm -f lychee-x86_64-unknown-linux-gnu.tar.gz

# Using cargo (Rust package manager)
cargo install lychee

# macOS
brew install lychee
```

**lychee error: "unexpected argument '--exclude-mail'"**:

This error occurs with lychee v0.19.0 and later. The `--exclude-mail` flag was deprecated and then removed because email addresses are excluded from checking by default.

If you see this error, update your `.pre-commit-config.yaml` to replace:

```yaml
# Old (deprecated)
- --exclude-mail
```

With:

```yaml
# New (pattern-based exclusion)
- --exclude
- 'mailto:'
```

Or simply remove the flag entirely since email checking is disabled by default.

### Spell Check False Positives

If the spell checker flags a valid technical term:

1. Verify the term is spelled correctly
2. Add the term to `.wordlist.txt` in alphabetical order
3. Commit the updated wordlist with your changes

### Link Check Timeouts

Some websites block automated requests. If you get false failures:

1. Verify the link works in a browser
2. Check if the URL is already in the exclude list
3. If legitimate, the documentation team may add it to the exclusions

## Getting Help

- **Mattermost**: Join the [Documentation channel](https://chat.rockylinux.org/rocky-linux/channels/documentation) for real-time help
- **GitHub Issues**: Report documentation bugs or suggest improvements
- **Forums**: Visit the [Rocky Linux Forums](https://forums.rockylinux.org) for general questions

## Additional Resources

- [Style Guide](https://docs.rockylinux.org/guides/contribute/style_guide/) - Writing standards
- [Document Formatting](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting/) - Markdown syntax and admonitions
- [Beginner Contributors Guide](https://docs.rockylinux.org/guides/contribute/beginners/) - Detailed walkthrough for new contributors
- [Creating New Documents](https://docs.rockylinux.org/guides/contribute/createnew/) - GitHub-specific instructions
- [Navigation and Structure](https://docs.rockylinux.org/guides/contribute/navigation/) - How the documentation site is organized

## License

Documents contributed to Rocky Linux documentation are published under the [Creative Commons BY-SA 4.0 license](https://creativecommons.org/licenses/by-sa/4.0/). By contributing, you agree to license your work under these terms.
