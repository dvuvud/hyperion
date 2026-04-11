#pragma once

#include "MacroAction.hpp"
#include <vector>
#include <string>
#include <QUuid>

struct Macro {
    std::string              id;
    std::string              name;
    std::vector<MacroAction> actions;

    static Macro create(const std::string& name = "New Macro") {
        return {
            QUuid::createUuid().toString(QUuid::WithoutBraces).toStdString(),
            name,
            {}
        };
    }
};
