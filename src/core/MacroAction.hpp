#pragma once

#include <variant>
#include <string>
#include <cstdint>

struct KeyAction {
    uint32_t key;
    bool press;
    uint32_t modifiers;
    uint32_t holdMs;
};

struct MouseAction {
    enum class Button { Left, Right, Middle };
    enum class Kind   { Click, Press, Release, Move, Scroll };

    Button button;
    Kind   kind;
    int    x, y;
    uint32_t holdMs;
};

struct DelayAction {
    uint32_t fixedMs;
    uint32_t jitterMs;
};

struct LoopBegin {
    uint32_t count;
    bool     infinite;
};

using MacroAction = std::variant<
KeyAction,
    MouseAction,
    DelayAction,
    LoopBegin
    >;
