#include <Geode/Geode.hpp>
#include <Geode/binding/PlayLayer.hpp>

#include "GameplayCheck.hpp"

using namespace geode::prelude;

namespace {

// Reads the current gameplay state straight from the live PlayLayer.
// PlayLayer::get() queries GameManager::m_playLayer on every call, so no
// stale pointers are ever retained.
p::GameplayState currentGameplayState() {
    auto* playLayer = PlayLayer::get();
    if (!playLayer) {
        return {};
    }
    return {
        /*hasPlayLayer=*/true,
        /*playerExists=*/playLayer->m_player1 != nullptr,
        /*gameplayActive=*/playLayer->isGameplayActive(),
        /*isPracticeMode=*/playLayer->m_isPracticeMode,
        /*isPaused=*/playLayer->m_isPaused,
    };
}

} // namespace

$on_mod(Loaded) {
    listenForKeybindSettingPresses("practice-mode", [](Keybind const&, bool down, bool repeat, double) {
        // Ignore key releases and OS key-repeat events.
        if (!down || repeat) {
            return ListenerResult::Propagate;
        }

        if (!p::shouldEnablePractice(currentGameplayState())) {
            return ListenerResult::Propagate;
        }

        // togglePracticeMode is the same native entry point the pause menu's
        // Practice Mode button uses (PauseLayer::onPracticeMode). Passing true
        // performs the full transition: it sets the practice flag, swaps the
        // music to the practice track, enables the checkpoint UI and places
        // the initial practice checkpoint - without restarting the level.
        PlayLayer::get()->togglePracticeMode(true);
        return ListenerResult::Stop;
    });
}
