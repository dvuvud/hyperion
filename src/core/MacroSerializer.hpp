#pragma once

#include "Macro.hpp"
#include <QString>
#include <optional>

namespace MacroSerializer {

    bool saveToFile(const Macro& macro, const QString& path);
    std::optional<Macro> loadFromFile(const QString& path);

}
