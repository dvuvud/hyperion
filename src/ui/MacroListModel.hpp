#pragma once

#include <QAbstractListModel>
#include "core/Macro.hpp"
#include <QtQmlIntegration/qqmlintegration.h>

class MacroListModel : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT

    public:
        enum Role {
            TypeRole = Qt::UserRole + 1,
            LabelRole,      
            DataRole,                      
        };

        explicit MacroListModel(QObject* parent = nullptr);

        int      rowCount(const QModelIndex& parent = {}) const override;
        QVariant data(const QModelIndex& index, int role) const override;
        QHash<int, QByteArray> roleNames() const override;

        Q_INVOKABLE void appendAction(const QString& type);
        Q_INVOKABLE void removeAction(int index);
        Q_INVOKABLE void moveAction(int from, int to);
        Q_INVOKABLE void updateAction(int index, const QVariantMap& data);

    private:
        std::vector<MacroAction> m_actions;

        static QString labelFor(const MacroAction& action);
        static QString typeFor(const MacroAction& action);
};
