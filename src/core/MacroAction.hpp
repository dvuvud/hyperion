#include <variant>
#include <string>
#include <cstdint>

struct KeyAction {
    uint32_t    key;            // Qt::Key value
    bool        press;          // true = press, false = release
    uint32_t    modifiers;      // Qt::KeyboardModifiers bitmask
    uint32_t    holdMs;         // how long to hold (0 = instant)
};

struct MouseAction {
    enum class Button { Left, Right, Middle };
    enum class Kind   { Click, Press, Release, Move, Scroll };
    Button      button;
    Kind        kind;
    int         x, y;           // screen coords
    uint32_t    holdMs;
};

struct DelayAction {
    uint32_t    fixedMs;        
    uint32_t    jitterMs;       // ± random amount for human-like timing
};

struct LoopBegin {
    std::string variableName;   // e.g. "count"
    uint32_t    defaultCount;   // used if variable not set at runtime
};

struct LoopEnd {
    // paired with a LoopBegin by index at runtime
};

using MacroAction = std::variant
KeyAction,
    MouseAction,
    DelayAction,
    LoopBegin,
    LoopEnd
    >;
