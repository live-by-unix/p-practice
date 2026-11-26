#pragma once

// Pure gameplay-state checks for the P mod. Kept free of any Geode/game
// dependencies so the decision logic can be unit tested on its own.
namespace p {

struct GameplayState {
    // PlayLayer::get() returned a non-null pointer
    bool hasPlayLayer = false;
    // PlayLayer::m_player1 is valid (level objects finished setting up)
    bool playerExists = false;
    // PlayLayer::isGameplayActive() - level is running, not completed, player alive
    bool gameplayActive = false;
    // PlayLayer::m_isPracticeMode - already in Practice Mode
    bool isPracticeMode = false;
    // PlayLayer::m_isPaused - pause menu (or another blocking layer) is open
    bool isPaused = false;
};

// Returns true only when pressing the keybind should switch the current run
// into Practice Mode.
inline bool shouldEnablePractice(GameplayState const& state) {
    return state.hasPlayLayer
        && state.playerExists
        && state.gameplayActive
        && !state.isPracticeMode
        && !state.isPaused;
}

} // namespace p
