---
title: RockyDocs Script Method
author: Wale Soyinka
contributors: 
update: 11-Sep-2025
---

# Running a local copy of the docs.rockylinux.org website using the RockyDocs script

This document walks you through using the automated `rockydocs.sh` script to recreate and run a production-identical copy of the entire docs.rockylinux.org website on your local machine.

The RockyDocs script provides a modern, automated approach that eliminates the manual setup complexity found in other methods while delivering exact production behavior.

Running a local copy of the documentation website might be useful in the following scenarios:

- You are a documentation author and want to preview exactly how your content will appear on the live website
- You want to test your contributions across multiple Rocky Linux versions (8, 9, and 10) locally
- You are interested in learning about or contributing to the documentation infrastructure
- You need to verify that your content renders correctly with the version selector and navigation

## Prerequisites

The RockyDocs script automatically handles most dependencies, but you'll need:

- A Linux or macOS system (Windows with WSL2 should work)
- `git` installed on your system
- Either Python 3.8+ with `pip` OR Docker (the script supports both environments)
- About 2GB of free disk space for the full environment

The script will automatically check for and install other required tools like `mkdocs`, `mike`, and various plugins.

## Setup the content environment

1. Change to a directory where you want to work with Rocky Linux documentation. We'll refer to this as your workspace directory.

    ```bash
    mkdir -p ~/rocky-projects
    cd ~/rocky-projects
    ```

2. Clone the official Rocky Linux documentation repository:

    ```bash
    git clone https://github.com/rocky-linux/documentation.git
    cd documentation
    ```

    You now have the content repository with the automated `rockydocs.sh` script included.

## Quick start options with the RockyDocs script

The RockyDocs script provides multiple workflow options to match different contributor needs. Choose the option that best fits your writing and review workflow.

!!! note "Understanding the Three-Step Process"
    **Setup** (one-time): Creates a build environment with Python virtual environment and installs MkDocs tools. Also sets the language configuration (minimal or full) that will be used for all subsequent deployments. This creates a separate workspace directory for build files while keeping your content repository clean.
    
    **Deploy**: Builds all Rocky Linux versions (8, 9, 10) into a complete versioned website using Mike and the language configuration set during setup. This creates the multi-version structure you see on docs.rockylinux.org.
    
    **Serve**: Starts a local web server to preview your changes. Static mode serves pre-built files (production-identical), while live mode enables automatic reloading when you edit content.

## Customizing your workspace location

By default, the script creates a workspace in `../rockydocs-workspaces/` relative to your content repository. You can customize this location using the `--workspace` option:

```bash
# Use a custom workspace location
./rockydocs.sh --setup --venv --workspace ~/my-docs-workspace

# The script remembers your choice for future commands
./rockydocs.sh --deploy
./rockydocs.sh --serve --static
```

!!! tip "Workspace Benefits"
    - Keeps your content repository clean from build files
    - Allows multiple documentation projects to share the same build environment
    - Automatically saves your workspace preference for future commands
    - Intelligently reuses existing repositories to save disk space and clone time

The script automatically saves your workspace preference and reuses it for subsequent commands.

### Option 1: Production-Identical Preview (Recommended for Final Review)

This option provides the exact same experience as the live docs.rockylinux.org website, perfect for final content review and testing.

1. **Setup the environment** (one-time setup):

    ```bash
    # Basic setup (creates workspace in ../rockydocs-workspaces/)
    ./rockydocs.sh --setup --venv
    
    # Alternative: Custom workspace location
    ./rockydocs.sh --setup --venv --workspace ~/my-docs-workspace
    ```

2. **Build all documentation versions**:

    ```bash
    ./rockydocs.sh --deploy
    ```

3. **Start the production-identical website**:

    ```bash
    ./rockydocs.sh --serve --static
    ```

    !!! tip "Static Serving Mode"
        This serves pre-built static files exactly like production with no redirects. Perfect for verifying how your content will look on the live site. The root URL (`http://localhost:8000/`) serves the latest content directly, just like docs.rockylinux.org.
        
        **Note**: You must run `--deploy` again to see content changes, as this serves pre-built files.
    
    !!! note "Language Support"
        By default, the script builds English and Ukrainian language versions for faster setup and builds. For complete testing with all available languages, use the `--full` flag:
        
        ```bash
        # Full language support setup (config set once)
        ./rockydocs.sh --setup --venv --full
        # Deploy uses setup's language configuration automatically
        ./rockydocs.sh --deploy
        ```

### Option 2: Live Development Mode (Best for Active Writing)

This option automatically refreshes your browser when you edit content files, ideal for active writing sessions.

1. **Setup the environment** (one-time setup):

    ```bash
    # Basic setup
    ./rockydocs.sh --setup --venv
    
    # Alternative: Custom workspace location
    ./rockydocs.sh --setup --venv --workspace ~/my-docs-workspace
    ```

2. **Build all documentation versions**:

    ```bash
    ./rockydocs.sh --deploy
    ```

3. **Start the live development server**:

    ```bash
    ./rockydocs.sh --serve
    ```

    !!! tip "Live Development Mode"
        This provides live reloading - edit any markdown file in your `docs/` directory and see changes instantly in your browser. Perfect for active writing and editing content. Changes appear automatically without needing to run `--deploy` again.
        
        **Note**: May include redirects and behavior that differs slightly from production. Use static mode for final verification.

### Option 3: Dual Server Mode (Best of Both Worlds)

This option runs two servers simultaneously, giving you both full site navigation and live content editing capabilities.

1. **Setup the environment** (one-time setup):

    ```bash
    # Basic setup
    ./rockydocs.sh --setup --venv
    
    # Alternative: Custom workspace location
    ./rockydocs.sh --setup --venv --workspace ~/my-docs-workspace
    ```

2. **Build all documentation versions**:

    ```bash
    ./rockydocs.sh --deploy
    ```

3. **Start dual servers**:

    ```bash
    ./rockydocs.sh --serve-dual
    ```

    !!! tip "Dual Server Mode"
        This runs two servers simultaneously for the best of both worlds:
        
        - **Port 8000**: Mike serve with full version selector and site navigation
        - **Port 8001**: MkDocs live reload for instant content updates
        
        Switch between ports depending on whether you need live editing (8001) or full site testing (8000). This mode is ideal for contributors who want both immediate content feedback and complete site navigation testing.

### Option 4: Docker Environment

If you prefer containerized environments or don't want to install Python dependencies locally, you can use Docker versions of any serving mode.

!!! note "Docker Environment Benefits"
    - **Isolated Environment**: No impact on your local Python installation or system dependencies
    - **Consistent Builds**: Same container environment across different machines
    - **Easy Cleanup**: Simply remove containers and images when done
    - **All Serving Modes**: Supports static, live, and dual server modes in containers

1. **Setup the Docker environment**:

    ```bash
    # Basic Docker setup
    ./rockydocs.sh --setup --docker
    
    # Alternative: Custom workspace location
    ./rockydocs.sh --setup --docker --workspace ~/my-docs-workspace
    ```

2. **Build all versions in containers**:

    ```bash
    ./rockydocs.sh --deploy --docker
    ```

3. **Choose your Docker serving mode**:

    ```bash
    # Production-identical (static)
    ./rockydocs.sh --serve --docker --static

    # Live development with auto-reload
    ./rockydocs.sh --serve --docker

    # Dual servers (containerized)
    ./rockydocs.sh --serve-dual --docker
    ```

## View your local documentation website

With either method, you can now view your local copy of the website by opening your web browser to:

**<http://localhost:8000>**

You should see:
- The complete Rocky Linux documentation website
- Full navigation and search functionality
- Version selector in the top navigation
- All content exactly as it appears on the production site
- No redirect behavior - pages load directly

## Available script commands

The `rockydocs.sh` script provides several useful commands:

### Primary workflow commands

```bash
# Setup commands (run once)
./rockydocs.sh --setup --venv --minimal     # Python virtual environment setup
./rockydocs.sh --setup --docker --minimal   # Docker containerized setup

# Deployment commands (build the site)
./rockydocs.sh --deploy --minimal           # Build all versions (venv)
./rockydocs.sh --deploy --docker --minimal  # Build all versions (Docker)

# Serving commands (start the local website)
./rockydocs.sh --serve --static             # Production-identical static server (venv)
./rockydocs.sh --serve --docker --static    # Production-identical static server (Docker)
./rockydocs.sh --serve                      # Live development server with auto-reload (venv)
./rockydocs.sh --serve --docker             # Live development server with auto-reload (Docker)
./rockydocs.sh --serve-dual                 # Dual servers: mike serve + mkdocs live reload (venv)
./rockydocs.sh --serve-dual --docker        # Dual servers: containerized version (Docker)
```

### Maintenance and information commands

```bash
./rockydocs.sh --status                     # Show environment status and information
./rockydocs.sh --clean                      # Clean workspace and build artifacts
./rockydocs.sh --reset                      # Reset saved configuration
./rockydocs.sh --help                       # Show detailed help information
```


## Working with different Rocky Linux versions

The script automatically detects which version you're working on based on your git branch:

```bash
# Switch to different versions in your content repository
git checkout rocky-8    # Work on Rocky Linux 8 documentation
git checkout rocky-9    # Work on Rocky Linux 9 documentation
git checkout main       # Work on Rocky Linux 10 documentation

# Rebuild with your changes
./rockydocs.sh --deploy --minimal
```

Your changes will appear in the corresponding version when you view the local website.


## Understanding the folder structure

The RockyDocs script creates a clean separation between your content and the build environment:

```
~/rocky-projects/documentation/          # Your content repository (where you edit)
├── docs/                                # Your content files (guides, books, etc.)
├── rockydocs.sh                         # The script
└── .git/                               # Your content git repository

~/rockydocs-workspaces/                  # Build workspace (created by script)
├── docs.rockylinux.org/                # Main build environment
│   ├── venv/                           # Python virtual environment
│   ├── worktrees/                      # Cached copies of doc versions
│   │   ├── main/                       # Rocky Linux 10 content cache
│   │   ├── rocky-8/                    # Rocky Linux 8 content cache  
│   │   └── rocky-9/                    # Rocky Linux 9 content cache
│   ├── site-static/                    # Static site files (for --static mode)
│   ├── content -> worktrees/main/docs  # Symlink to your current version
│   ├── mkdocs.yml                      # Build configuration
│   └── .git/                          # Local build repository
└── app -> docs.rockylinux.org          # Compatibility symlink
```

**Key points:**
- Your content repository stays clean - no build files or dependencies
- The build workspace is completely separate and can be safely deleted
- The script automatically manages the `content` symlink based on your current git branch
- Cached worktrees avoid repeatedly downloading content for different Rocky versions
- The `--clean` command removes the entire build workspace if needed

## Updating your environment

To get the latest changes from the official repositories:

```bash
# This updates both the build environment and content
./rockydocs.sh --deploy --minimal
```

The script automatically fetches updates from all Rocky Linux documentation branches.

## Troubleshooting

If you encounter issues:

1. **Check system status**:
    ```bash
    ./rockydocs.sh --status
    ```

2. **Clean and rebuild**:
    ```bash
    ./rockydocs.sh --clean
    ./rockydocs.sh --setup --venv --minimal
    ./rockydocs.sh --deploy --minimal
    ```

3. **Get detailed help**:
    ```bash
    ./rockydocs.sh --help
    ./rockydocs.sh --setup --help
    ./rockydocs.sh --serve --help
    ```

## How Your Edits Flow to the Built Site

Understanding how the RockyDocs script connects your local editing to the deployed website helps explain why certain design decisions were made and how your changes appear in the built documentation.

### The Core Challenge

The script needs to accomplish three things simultaneously:
1. Let you edit in your familiar local repository
2. Build multiple Rocky Linux versions (8, 9, 10) with proper git context  
3. Reflect your live edits immediately in builds

### Directory Structure Overview

```
Your editing environment:
~/rocky-projects/documentation/          ← You edit here
├── docs/                               ← Your live content
├── .git/                              ← Your git repository  
└── rockydocs.sh

Build environment (separate):
../rockydocs-workspaces/docs.rockylinux.org/
├── content → (symlink target varies)   ← MkDocs reads from here
├── mkdocs.yml (docs_dir: "content")    ← Always points to symlink
├── worktrees/                          ← Cached content for other versions
│   ├── main/docs/      ← Rocky 10 cached content
│   ├── rocky-8/docs/   ← Rocky 8 cached content  
│   └── rocky-9/docs/   ← Rocky 9 cached content
└── venv/
```

### The Smart Symlink Strategy

The key innovation is a dynamic symlink called `content` in the build environment. This symlink changes its target based on what you're currently working on:

#### When You're Editing Rocky Linux 10 (main branch):
```bash
# Your context:
cd ~/rocky-projects/documentation
git branch  # Shows: * main

# When you run: ./rockydocs.sh --deploy
# Script creates: content → ~/rocky-projects/documentation/docs

# Result: Your live edits appear immediately in builds
```

#### When Building Other Versions:
```bash
# Script builds Rocky 8:
# content → ../worktrees/rocky-8/docs (cached Rocky 8 content)

# Script builds Rocky 9:  
# content → ../worktrees/rocky-9/docs (cached Rocky 9 content)
```

### Why This Design?

**Main Branch → Your Live Files:**
- You're actively editing Rocky Linux 10 content
- Live reload: save file, see changes immediately in browser
- Uses your repo's git history for accurate timestamps

**Other Branches → Cached Worktrees:**  
- You may not have rocky-8/rocky-9 branches locally
- Provides complete git context for each Rocky version
- Enables building all versions without affecting your workflow

### Complete Build Flow Example

```bash
# 1. You edit in your repo
cd ~/rocky-projects/documentation
echo "New troubleshooting tip" >> docs/guides/myguide.md

# 2. You deploy and serve
./rockydocs.sh --deploy
./rockydocs.sh --serve

# 3. Script creates symlink in build environment
# content → ~/rocky-projects/documentation/docs

# 4. MkDocs builds from your live files
# Your changes appear immediately in the local website
```

### Benefits of This Architecture

1. **Immediate Edit Reflection**: Your changes appear instantly without rebuilding
2. **Multi-Version Support**: Can build all Rocky versions with proper git context
3. **Clean Separation**: Your git workflow remains completely unaffected  
4. **Git History Preservation**: Each version has accurate timestamps and author information
5. **Flexible Development**: Switch branches, script adapts automatically

The symlink acts as a "smart pointer" that MkDocs follows to find content, while the script dynamically retargets it based on what you're currently working on. This explains why the script needs to clone repositories separately - it creates a clean build environment while keeping your editing environment pristine.

## Notes

- The RockyDocs script creates a workspace **outside** your content repository to keep your git workflow clean
- All environments are completely local - nothing is uploaded or published automatically
- The script automatically manages dependencies, port conflicts, and cleanup
- Both Python virtual environment and Docker methods provide identical functionality
- The local website includes the exact same theme, navigation, and features as the production site
- You can safely experiment with content changes - your local environment is completely isolated
- The script automatically preserves git history for accurate document timestamps