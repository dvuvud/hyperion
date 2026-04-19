#include "MacroListModel.hpp"
#include "MacroSerializer.hpp"
#include <QVariantMap>

MacroListModel::MacroListModel(QObject* parent)
    : QAbstractListModel(parent)
    , m_macro(Macro::create()) {}

int MacroListModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return static_cast<int>(m_macro.actions.size());
}

QHash<int, QByteArray> MacroListModel::roleNames() const {
    return {
        { TypeRole,  "actionType"  },
        { LabelRole, "actionLabel" },
        { DataRole,  "actionData"  },
    };
}

QVariant MacroListModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= rowCount()) return {};
    const auto& action = m_macro.actions[index.row()];

    switch (role) {
        case TypeRole:  return typeFor(action);
        case LabelRole: return labelFor(action);
        case DataRole: {
            return std::visit([](auto&& a) -> QVariant {
                using T = std::decay_t<decltype(a)>;
                QVariantMap m;
                if constexpr (std::is_same_v<T, KeyAction>) {
                    m["key"]       = a.key;
                    m["press"]     = a.press;
                    m["modifiers"] = a.modifiers;
                    m["holdMs"]    = a.holdMs;
                } else if constexpr (std::is_same_v<T, MouseAction>) {
                    m["button"]      = static_cast<int>(a.button);
                    m["kind"]        = static_cast<int>(a.kind);
                    m["x"]           = a.x;
                    m["y"]           = a.y;
                    m["scrollDelta"] = a.scrollDelta;
                    m["holdMs"]      = a.holdMs;
                } else if constexpr (std::is_same_v<T, DelayAction>) {
                    m["fixedMs"]  = a.fixedMs;
                    m["jitterMs"] = a.jitterMs;
                } else if constexpr (std::is_same_v<T, LoopBegin>) {
                    m["count"]    = a.count;
                    m["infinite"] = a.infinite;
                } else if constexpr (std::is_same_v<T, LoopEnd>) {
                    // No fields
                }
                return m;
            }, action);
        }
        default: return {};
    }
}

void MacroListModel::appendAction(const QString& type) {
    beginInsertRows({}, rowCount(), rowCount());

    if      (type == "key")       m_macro.actions.push_back(KeyAction{});
    else if (type == "mouse")     m_macro.actions.push_back(MouseAction{});
    else if (type == "delay")     m_macro.actions.push_back(DelayAction{ 500, 0 });
    else if (type == "loopBegin") m_macro.actions.push_back(LoopBegin{ 3, false });
    else if (type == "loopEnd") m_macro.actions.push_back(LoopEnd{ });

    endInsertRows();
}

void MacroListModel::removeAction(int index) {
    if (index < 0 || index >= rowCount()) return;
    beginRemoveRows({}, index, index);
    m_macro.actions.erase(m_macro.actions.begin() + index);
    endRemoveRows();
}

void MacroListModel::moveAction(int from, int to) {
    if (from == to) return;
    beginMoveRows({}, from, from, {}, to > from ? to + 1 : to);
    auto action = m_macro.actions[from];
    m_macro.actions.erase(m_macro.actions.begin() + from);
    m_macro.actions.insert(m_macro.actions.begin() + to, action);
    endMoveRows();
}

void MacroListModel::updateAction(int index, const QVariantMap& data) {
    if (index < 0 || index >= rowCount()) return;

    auto& action = m_macro.actions[index];
    const QString type = typeFor(action);

    if (type == "key") {
        auto& a = std::get<KeyAction>(action);
        if (data.contains("key"))       a.key       = data["key"].toUInt();
        if (data.contains("press"))     a.press     = data["press"].toBool();
        if (data.contains("modifiers")) a.modifiers = data["modifiers"].toUInt();
        if (data.contains("holdMs"))    a.holdMs    = data["holdMs"].toUInt();
    } else if (type == "mouse") {
        auto& a = std::get<MouseAction>(action);
        if (data.contains("button"))      a.button      = static_cast<MouseAction::Button>(data["button"].toInt());
        if (data.contains("kind"))        a.kind        = static_cast<MouseAction::Kind>(data["kind"].toInt());
        if (data.contains("x"))           a.x           = data["x"].toInt();
        if (data.contains("y"))           a.y           = data["y"].toInt();
        if (data.contains("scrollDelta")) a.scrollDelta = data["scrollDelta"].toInt();
        if (data.contains("holdMs"))      a.holdMs      = data["holdMs"].toUInt();
    } else if (type == "delay") {
        auto& a = std::get<DelayAction>(action);
        if (data.contains("fixedMs"))  a.fixedMs  = data["fixedMs"].toUInt();
        if (data.contains("jitterMs")) a.jitterMs = data["jitterMs"].toUInt();
    } else if (type == "loopBegin") {
        auto& a = std::get<LoopBegin>(action);
        if (data.contains("count"))    a.count    = data["count"].toUInt();
        if (data.contains("infinite")) a.infinite = data["infinite"].toBool();
    }

    emit dataChanged(createIndex(index, 0), createIndex(index, 0));
}

QString MacroListModel::typeFor(const MacroAction& action) {
    return std::visit([](auto&& a) -> QString {
        using T = std::decay_t<decltype(a)>;
        if constexpr (std::is_same_v<T, KeyAction>)    return "key";
        if constexpr (std::is_same_v<T, MouseAction>)  return "mouse";
        if constexpr (std::is_same_v<T, DelayAction>)  return "delay";
        if constexpr (std::is_same_v<T, LoopBegin>)    return "loopBegin";
        if constexpr (std::is_same_v<T, LoopEnd>)      return "loopEnd";
        return "unknown";
    }, action);
}

QString MacroListModel::labelFor(const MacroAction& action) {
    return std::visit([](auto&& a) -> QString {
        using T = std::decay_t<decltype(a)>;
        if constexpr (std::is_same_v<T, KeyAction>)
            return QString("Key 0x%1%2")
                .arg(a.key, 0, 16)
                .arg(a.press ? " ↓" : " ↑");
        if constexpr (std::is_same_v<T, MouseAction>) {
            using Kind = MouseAction::Kind;
            switch (a.kind) {
                case Kind::Move:    return QString("Move → (%1, %2)").arg(a.x).arg(a.y);
                case Kind::Scroll:  return QString("Scroll %1").arg(a.scrollDelta > 0 ? "↑" : "↓");
                case Kind::Click:   return QString("Click (%1, %2)").arg(a.x).arg(a.y);
                case Kind::Press:   return QString("Mouse ↓ (%1, %2)").arg(a.x).arg(a.y);
                case Kind::Release: return QString("Mouse ↑ (%1, %2)").arg(a.x).arg(a.y);
            }
        }
        if constexpr (std::is_same_v<T, DelayAction>)
            return QString("Wait %1ms").arg(a.fixedMs);
        if constexpr (std::is_same_v<T, LoopBegin>)
            return a.infinite ? QString("Loop ∞") : QString("Loop × %1").arg(a.count);
        if constexpr (std::is_same_v<T, LoopEnd>) {
            return QString("End loop");
        }
        return "Unknown";
    }, action);
}

bool MacroListModel::saveToFile(const QString& path) {
    return MacroSerializer::saveToFile(m_macro, path);
}

bool MacroListModel::loadFromFile(const QString& path) {
    auto loaded = MacroSerializer::loadFromFile(path);
    if (!loaded)
        return false;

    beginResetModel();
    m_macro = *loaded;
    endResetModel();

    emit macroNameChanged();
    return true;
}
