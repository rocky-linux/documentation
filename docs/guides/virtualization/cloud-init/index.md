---
title: Guide to cloud-init on Rocky Linux
---

# Mastering cloud-init on Rocky Linux

Welcome to the comprehensive guide to `cloud-init` on Rocky Linux. This series is designed to take you from the fundamental concepts of cloud instance initialization to advanced, real-world provisioning and troubleshooting techniques. Whether you are a new user setting up your first cloud server or an experienced administrator building custom images, this guide has something for you.

The chapters are designed to be read sequentially, building on the knowledge from the previous sections.

---

## Chapters in This Guide

**[1. Fundamentals](./01_fundamentals.md)**
> Learn what `cloud-init` is, why it's essential for cloud computing, and the stages of its execution lifecycle.

**[2. First Contact](./02_first_contact.md)**
> Your first hands-on exercise. Boot a cloud image and perform a simple customization using a basic `user-data` file.

**[3. The Configuration Engine](./03_configuration_engine.md)**
> Dive deep into the `cloud-init` module system. Learn to use the most important modules for managing users, packages, and files.

**[4. Advanced Provisioning](./04_advanced_provisioning.md)**
> Tackle complex scenarios, including how to define static network configurations and how to combine scripts and cloud-configs into a single payload.

**[5. The Image Builder's Perspective](./05_image_builders_perspective.md)**
> Shift your perspective to that of an image builder. Learn how to create "golden images" with baked-in defaults and how to properly generalize them for cloning.

**[6. Troubleshooting](./06_troubleshooting.md)**
> Learn the essential art of `cloud-init` forensics. Understand the logs, status commands, and common pitfalls to diagnose and solve problems effectively.

**[7. Contributing to cloud-init](./07_contributing.md)**
> Go beyond being a user. This chapter provides a map for understanding the `cloud-init` source code and making your first contribution to the open-source project.