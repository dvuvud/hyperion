#pragma once

#include "Macro.hpp"
#include <QObject>
#include <QtQmlIntegration/qqmlintegration.h>
#include <atomic>

class MacroEngine : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Use the singleton via MacroEngineHost")

public:
    explicit MacroEngine(QObject* parent = nullptr);

public slots:
    void execute(const Macro& macro);
    void abort();

signals:
    void executionStarted(const QString& macroId);
    void actionStarted(int index);
    void actionFinished(int index);
    void executionFinished(const QString& macroId);
    void executionFailed(const QString& macroId, const QString& reason);

private:
    void runAction(const MacroAction& action);

    std::atomic<bool> m_abort { false };
};
