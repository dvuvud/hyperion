#pragma once

#include "MacroAction.hpp"

namespace InputInjector {

/// Send a single key event.
void sendKey(uint32_t key, bool press, uint32_t modifiers);

/// Send a single mouse event.
void sendMouse(const MouseAction& action);

// Modifier bitmask (platform-independent names stored in the macro file).
enum MacroModifiers : uint32_t {
    Mod_None    = 0,
    Mod_Shift   = 1 << 0,
    Mod_Control = 1 << 1,
    Mod_Alt     = 1 << 2,   // Option on macOS
    Mod_Meta    = 1 << 3,   // Command on macOS, Win key on Windows
};

}
