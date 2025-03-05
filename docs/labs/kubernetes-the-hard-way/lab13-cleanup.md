---
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - kubernetes
  - k8s
  - lab exercise
---

# Lab 13: Cleaning Up

> This is a fork of the original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) originally written by Kelsey Hightower (GitHub: kelseyhightower). Unlike the original that bases itself on Debian like distributions for the ARM64 architecture, this fork targets Enterprise Linux distributions such as Rocky Linux running on x86_64 architecture.

In this lab you will delete the compute resources created during this tutorial.

## Compute Instances

Previous versions of this guide made use of GCP resources for various aspects of compute and networking. The current version is agnostic, and you perform all configurations on the `jumpbox`, `server`, or nodes.

Clean up is as simple as deleting all virtual machines you created for this exercise.

Next: [Start Over](lab0-README.md)
