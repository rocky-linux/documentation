# Rocky Linux Documentation Script Changelog

All notable changes to the `rockydocs.sh` script will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to NEVRA versioning (Name-Version-Release).

## [1.0.0-13.el10] - 2025-09-12

### Added
- NEVRA-based versioning system following RPM conventions
- Enhanced --version output showing full NEVRA format
- Author information in script header and --version output  
- Enhanced --status command with git remote information display
- External changelog management system

### Changed
- **BREAKING**: Script renamed from `rockydocs-dev-12.sh` to `rockydocs.sh`
- Version format changed from `1.0.0-dev12` to NEVRA `rockydocs-1.0.0-13.el10`
- Script header updated to production-ready format
- --version output now displays full NEVRA format with author and description

### Technical Details
- Transitioned from development versioning to production NEVRA format
- Maintains full backward compatibility for all functionality
- Commit-based change tracking using git log filtering
- External changelog prevents script bloat

### Migration Notes
- All existing functionality preserved
- No changes to command-line interface except enhanced --version
- Workspace and configuration management unchanged
- All serving modes (--serve, --serve --static, --serve-dual) unchanged

---

## Development History (Pre-1.0.0)

### [dev12] - 2025-09-11
- Performance-optimized refactor with consolidated git operations
- Consolidated git fetch operations for improved performance
- Optimized web root override with local-only modifications
- Streamlined static serving mode
- Enhanced dependency checking
- Modular architecture with tools/rockydocs-functions.sh

### [dev11 and earlier]
- See git commit history for detailed development progression
- Major features: Mike versioning, Docker support, workspace management
- Foundation: Multi-version deployment, static serving, dual server modes