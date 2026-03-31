#include "MacroAction.hpp"
#include <vector>
#include <string>

struct Macro {
    std::string              id;
    std::string              name;
    std::vector<MacroAction> actions;
};
