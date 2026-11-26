// Unit tests for the gameplay-state decision logic in src/GameplayCheck.hpp.
// These tests cover the state checks only; in-game behavior is verified
// manually (see README.md -> Testing).

#include "GameplayCheck.hpp"

#include <cstdio>
#include <cstdlib>

namespace {

int failures = 0;

void check(bool condition, char const* name) {
    if (!condition) {
        std::fprintf(stderr, "FAIL: %s\n", name);
        ++failures;
    } else {
        std::printf("PASS: %s\n", name);
    }
}

p::GameplayState activeNormalRun() {
    return {
        /*hasPlayLayer=*/true,
        /*playerExists=*/true,
        /*gameplayActive=*/true,
        /*isPracticeMode=*/false,
        /*isPaused=*/false,
    };
}

} // namespace

int main() {
    // Normal Mode + P -> activate
    check(p::shouldEnablePractice(activeNormalRun()), "active normal run activates");

    // Practice Mode + P -> no change
    {
        auto state = activeNormalRun();
        state.isPracticeMode = true;
        check(!p::shouldEnablePractice(state), "already in practice mode does nothing");
    }

    // Outside gameplay (menus, level select, editor) -> no action
    {
        auto state = p::GameplayState{};
        check(!p::shouldEnablePractice(state), "no PlayLayer does nothing");
    }

    // Pause menu -> no action
    {
        auto state = activeNormalRun();
        state.isPaused = true;
        check(!p::shouldEnablePractice(state), "paused does nothing");
    }

    // Gameplay not active (level complete, transition, player dead) -> no action
    {
        auto state = activeNormalRun();
        state.gameplayActive = false;
        check(!p::shouldEnablePractice(state), "inactive gameplay does nothing");
    }

    // PlayLayer exists but player object not yet created -> no action
    {
        auto state = activeNormalRun();
        state.playerExists = false;
        check(!p::shouldEnablePractice(state), "missing player object does nothing");
    }

    // Repeated presses: state stays consistent, function is pure -> still activates
    // only while conditions hold; once practice is enabled the flag blocks it.
    {
        auto state = activeNormalRun();
        check(p::shouldEnablePractice(state), "first press activates");
        state.isPracticeMode = true; // game flipped the flag after first call
        check(!p::shouldEnablePractice(state), "second press after activation does nothing");
    }

    // Destroyed/invalid PlayLayer is represented by hasPlayLayer == false.
    {
        auto state = p::GameplayState{};
        state.hasPlayLayer = false;
        state.gameplayActive = true;
        state.playerExists = true;
        check(!p::shouldEnablePractice(state), "destroyed PlayLayer does nothing");
    }

    if (failures != 0) {
        std::fprintf(stderr, "%d test(s) failed\n", failures);
        return EXIT_FAILURE;
    }
    std::printf("All tests passed\n");
    return EXIT_SUCCESS;
}
