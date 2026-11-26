# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.3] - 2026-11-26

### Fixed
- Mod logo padded to required 1:1 aspect ratio for Geode Index submission.

## [v1.0.2] - 2026-11-26

### Changed
- Shrunk mod logo image size (1.2 MB → 40 KB).

## [v1.0.1] - 2026-11-26

### Fixed
- Mod icon/logo packaging.

## [v1.0.0] - 2026-11-25

### Added
- Press a customizable keybind (default: `P`) during active gameplay to switch the current run into Practice Mode via the game's native `PlayLayer::togglePracticeMode`.
- Geode keybind setting (`practice-mode`, category: gameplay) configurable from the mod's settings page.
- Gameplay-state gating: the shortcut only fires while a level is actively running (not in menus, the editor, the pause menu, or while already in Practice Mode).
