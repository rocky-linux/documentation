---
title: Package Signing & Testing
---

# Package signing and testing'

RPMs produced by us should be cryptographically signed with a Rocky Linux key, which guarantees to users that the package was
indeed built by the Rocky Linux project.

The package will also need to be put through some testing - preferably automated. The nature of the testing is yet to be determined,
but we’ll want to do some sanity checks at the bare minimum before unleashing it on the world. (Is this package installable? Did we accidentally miss any files? Does it cause dnf/yum dependency conflicts? etc.)
