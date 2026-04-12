#pragma once

#include <QAbstractListModel>
#include "core/Macro.hpp"
#include <QtQmlIntegration/qqmlintegration.h>

class MacroListModel : public QAbstractListModel {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString macroName READ macroName WRITE setMacroName NOTIFY macroNameChanged)
    Q_PROPERTY(QString macroId   READ macroId   CONSTANT)

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

    QString macroName() const { return QString::fromStdString(m_macro.name); }
    QString macroId()   const { return QString::fromStdString(m_macro.id);   }

    void setMacroName(const QString& name) {
        if (m_macro.name == name.toStdString()) return;
        m_macro.name = name.toStdString();
        emit macroNameChanged();
    }

    // returns a const ref so MacroEngineHost can execute it directly
    const Macro& macro() const { return m_macro; }

    Q_INVOKABLE void appendAction(const QString& type);
    Q_INVOKABLE void removeAction(int index);
    Q_INVOKABLE void moveAction(int from, int to);
    Q_INVOKABLE void updateAction(int index, const QVariantMap& data);

    Q_INVOKABLE bool saveToFile(const QString& path);
    Q_INVOKABLE bool loadFromFile(const QString& path);

signals:
    void macroNameChanged();

private:
    Macro m_macro;

    static QString labelFor(const MacroAction& action);
    static QString typeFor(const MacroAction& action);
};
