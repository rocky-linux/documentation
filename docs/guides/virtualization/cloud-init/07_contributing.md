---
title: 7. Contributing
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - cloud-init
  - open source
  - development
  - python
---

## Contributing to the cloud-init project

Congratulations! You have journeyed from the fundamental concepts of `cloud-init` to advanced provisioning and troubleshooting techniques. You are now a `cloud-init` power user. This final chapter opens the door to the next step in your journey: moving from a consumer of `cloud-init` to a potential contributor.

`cloud-init` is a critical open source project that thrives on community contributions. Whether it is fixing a typo in the documentation, reporting a bug, or writing a brand-new module, every contribution helps. This chapter provides a high-level map for understanding the source code, building a custom module, and engaging with the upstream community. It is not an exhaustive developer guide, but rather a friendly introduction to getting involved.

## 1. The `cloud-init` source code landscape

Before you can contribute, please familiarize yourself with the project. Let us explore the source code and set up a basic development environment.

### The language and repository

Written almost entirely in **Python**, Canonical hosts the `cloud-init`source code repository on **Launchpad**, but for easier collaboration and a more familiar interface, most contributors interact with its official mirror on **GitHub**.

* **Canonical repository (Launchpad):** [https://git.launchpad.net/cloud-init](https://git.launchpad.net/cloud-init)

* **GitHub mirror:** [https://github.com/canonical/cloud-init](https://github.com/canonical/cloud-init)

To get the source code, you can clone the GitHub repository:

```bash
# Clone the source code to your local machine
git clone https://github.com/canonical/cloud-init.git
cd cloud-init
```

### Setting up a development environment

To work on code without affecting your system's Python packages, always use a virtual environment.

```bash
# Create a Python virtual environment
python3 -m venv .venv

# Activate the virtual environment
source .venv/bin/activate

# Install the required development dependencies
pip install -r requirements-dev.txt
```

### A high-level tour of the source code

Navigating a new codebase can be daunting. Here are the most important directories:

* `cloudinit/`: This is the leading Python source directory.
* `cloudinit/sources/`: This directory contains the code for **Datasources** (e.g., `DataSourceNoCloud.py`). This is how `cloud-init` detects and reads configuration from different cloud platforms.
* `cloudinit/config/`: This is where the **Modules** live (e.g., `cc_packages.py`, `cc_users_groups.py`). The `cc_` prefix is a convention for the modules enabled by `#cloud-config`. This is the most common place for new feature contributions.
* `doc/`: The project's official documentation. Improving documentation is one of the best ways to make your first contribution.
* `tests/`: The comprehensive test suite for the project.

## 2. Writing a basic custom module

While `runcmd` is useful, writing a proper module is the best way to create reusable, portable, and idempotent configurations.

Let us create the simplest possible module: one that reads a configuration key from `user-data` and writes a message to the `cloud-init` log.

1. **Create the module file:** Create a new file named `cloudinit/config/cc_hello_world.py`.

    ```python
    # Filename: cloudinit/config/cc_hello_world.py

    # A list of frequency and stage for this module to run
    frequency = "once-per-instance"
    distros = ["all"]

    def handle(name, cfg, cloud, log, args):
        # Get a 'message' key from the user-data config.
        # If it doesn't exist, use a default value.
        message = cfg.get("message", "Hello from a custom module!")

        # Write the message to the main cloud-init log.
        log.info(f"Hello World Module says: {message}")
    ```

2. **Enable the module:** Creating the file is not enough. You must tell `cloud-init` to run it. Create a file at `/etc/cloud/cloud.cfg.d/99-my-modules.cfg` and add your module to one of the module lists:

    ```yaml
    # Add our custom module to the list of modules that run during the config stage
    cloud_config_modules:
      - hello_world
    ```

3. **Use the module:** Now, you can use the module in your `user-data`. The top-level key (`hello_world`) should match the module name without the `cc_` prefix.

    ```yaml
    #cloud-config
    hello_world:
      message: "My first custom module is working!"
    ```

After booting a VM with this configuration, check `/var/log/cloud-init.log` to find your custom message, confirming your module worked.

## 3. The contribution workflow

Contributing to an open source project follows a standard workflow. Here is a simplified overview:

1. **Find something to work on:** The best place to start is the project's issue tracker on Launchpad. Please be sure to look for bugs or feature requests. Newcomers are encouraged to start with documentation fixes or issues tagged as "low-hanging-fruit" or "good first issue".

2. **Fork and branch:** Create your own copy (a "fork") of the `cloud-init` repository on GitHub. Then, create a new branch for your changes.

    ```bash
    git checkout -b my-documentation-fix
    ```

3. **Make your changes and commit:** Make your code or documentation changes. When you commit, write a clear message describing what you did. The `-s` flag adds a `Signed-off-by` line, which certifies that you wrote the patch or have the right to contribute it.

    ```bash
    git commit -s -m "Doc: Fix typo in the users module documentation"
    ```

4. **Include tests:** All significant contributions, especially new features, must include tests. Explore the `tests/` directory to see how existing modules are tested.

5. **Submit a pull request (PR):** Push your branch to your fork on GitHub and open a Pull Request to the `main` branch of the `canonical/cloud-init` repository. This is your formal request to have your work included in the project.

6. **Engage in code review:** Project maintainers will review your PR. They might ask questions or request changes. This is a collaborative process. Engaging with feedback is a key part of contributing to open source.

### Community engagement

To learn more, ask questions, and interact with the community, you can join the `#cloud-init` channel on the OFTC IRC network or the official mailing list.

## A final word

Congratulations on completing this guide. You have progressed from a novice user to a `cloud-init` power user, and now you have a map to guide you into the world of open source contribution. The `cloud-init` community is welcoming and values your contributions, no matter how small. Happy building!
