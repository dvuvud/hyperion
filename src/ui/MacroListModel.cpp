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
        case DataRole:  return QVariant();
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
            if constexpr (std::is_same_v<T, LoopEnd>)      return "loopEnd";
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
            if constexpr (std::is_same_v<T, LoopEnd>)
            return "End loop";
            return "Unknown";
            }, action);
}

void MacroListModel::appendAction(const QString& type) {
    beginInsertRows({}, rowCount(), rowCount());

    if      (type == "key")       m_actions.push_back(KeyAction{});
    else if (type == "mouse")     m_actions.push_back(MouseAction{});
    else if (type == "delay")     m_actions.push_back(DelayAction{ 500, 0 });
    else if (type == "loopBegin") m_actions.push_back(LoopBegin{ "count", 3 });
    else if (type == "loopEnd")   m_actions.push_back(LoopEnd{});

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
