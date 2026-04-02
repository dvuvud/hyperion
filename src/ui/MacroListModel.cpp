#include "MacroListModel.hpp"
#include <QVariantMap>

MacroListModel::MacroListModel(QObject* parent)
    : QAbstractListModel(parent) {}

    int MacroListModel::rowCount(const QModelIndex& parent) const {
        if (parent.isValid()) return 0;
        return static_cast<int>(m_actions.size());
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
    const auto& action = m_actions[index.row()];

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
                    m["x"]      = a.x;
                    m["y"]      = a.y;
                    m["holdMs"] = a.holdMs;
                } else if constexpr (std::is_same_v<T, DelayAction>) {
                    m["fixedMs"]  = a.fixedMs;
                    m["jitterMs"] = a.jitterMs;
                } else if constexpr (std::is_same_v<T, LoopBegin>) {
                    m["variableName"] = QString::fromStdString(a.variableName);
                    m["defaultCount"] = a.defaultCount;
                }
                    return m;
                }, action);
        }
        default:        return {};
    }
}

QString MacroListModel::typeFor(const MacroAction& action) {
    return std::visit([](auto&& a) -> QString {
            using T = std::decay_t<decltype(a)>;
            if constexpr (std::is_same_v<T, KeyAction>)    return "key";
            if constexpr (std::is_same_v<T, MouseAction>)  return "mouse";
            if constexpr (std::is_same_v<T, DelayAction>)  return "delay";
            if constexpr (std::is_same_v<T, LoopBegin>)    return "loopBegin";
            return "unknown";
            }, action);
}

QString MacroListModel::labelFor(const MacroAction& action) {
    return std::visit([](auto&& a) -> QString {
            using T = std::decay_t<decltype(a)>;
            if constexpr (std::is_same_v<T, KeyAction>)
            return QString("Key %1").arg(a.key);
            if constexpr (std::is_same_v<T, MouseAction>)
            return QString("Mouse click (%1, %2)").arg(a.x).arg(a.y);
            if constexpr (std::is_same_v<T, DelayAction>)
            return QString("Wait %1ms").arg(a.fixedMs);
            if constexpr (std::is_same_v<T, LoopBegin>)
            return QString("Loop × %1").arg(a.defaultCount);
            return "Unknown";
            }, action);
}

void MacroListModel::appendAction(const QString& type) {
    beginInsertRows({}, rowCount(), rowCount());

    if      (type == "key")       m_actions.push_back(KeyAction{});
    else if (type == "mouse")     m_actions.push_back(MouseAction{});
    else if (type == "delay")     m_actions.push_back(DelayAction{ 500, 0 });
    else if (type == "loopBegin") m_actions.push_back(LoopBegin{ "count", 3 });

    endInsertRows();
}

void MacroListModel::removeAction(int index) {
    if (index < 0 || index >= rowCount()) return;
    beginRemoveRows({}, index, index);
    m_actions.erase(m_actions.begin() + index);
    endRemoveRows();
}

void MacroListModel::moveAction(int from, int to) {
    if (from == to) return;
    beginMoveRows({}, from, from, {}, to > from ? to + 1 : to);
    auto action = m_actions[from];
    m_actions.erase(m_actions.begin() + from);
    m_actions.insert(m_actions.begin() + to, action);
    endMoveRows();
}

void MacroListModel::updateAction(int index, const QVariantMap& data) {
    if (index < 0 || index >= rowCount()) return;

    auto& action = m_actions[index];
    const QString type = typeFor(action);

    if (type == "key") {
        auto& a = std::get<KeyAction>(action);
        if (data.contains("key"))       a.key       = data["key"].toUInt();
        if (data.contains("press"))     a.press     = data["press"].toBool();
        if (data.contains("modifiers")) a.modifiers = data["modifiers"].toUInt();
        if (data.contains("holdMs"))    a.holdMs    = data["holdMs"].toUInt();
    } else if (type == "mouse") {
        auto& a = std::get<MouseAction>(action);
        if (data.contains("x"))      a.x      = data["x"].toInt();
        if (data.contains("y"))      a.y      = data["y"].toInt();
        if (data.contains("holdMs")) a.holdMs = data["holdMs"].toUInt();
    } else if (type == "delay") {
        auto& a = std::get<DelayAction>(action);
        if (data.contains("fixedMs"))  a.fixedMs  = data["fixedMs"].toUInt();
        if (data.contains("jitterMs")) a.jitterMs = data["jitterMs"].toUInt();
    } else if (type == "loopBegin") {
        auto& a = std::get<LoopBegin>(action);
        if (data.contains("variableName"))  a.variableName  = data["variableName"].toString().toStdString();
        if (data.contains("defaultCount"))  a.defaultCount  = data["defaultCount"].toUInt();
    }

    emit dataChanged(createIndex(index, 0), createIndex(index, 0));
}
