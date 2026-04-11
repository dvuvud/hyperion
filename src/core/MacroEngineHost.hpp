#pragma once

#include "MacroEngine.hpp"
#include <QObject>
#include <QThread>
#include <QtQmlIntegration/qqmlintegration.h>

// instantiate this from QML or main.cpp.
// it owns the worker thread and exposes the engine's signals.
class MacroEngineHost : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool running READ running NOTIFY runningChanged)

public:
    explicit MacroEngineHost(QObject* parent = nullptr);
    ~MacroEngineHost() override;

    bool running() const { return m_running; }

    Q_INVOKABLE void execute(const Macro& macro);
    Q_INVOKABLE void abort();

signals:
    void runningChanged();
    void actionStarted(int index);
    void actionFinished(int index);
    void executionFailed(const QString& macroId, const QString& reason);

    // internal. crosses the thread boundary
    void _execute(const Macro& macro);
    void _abort();

private:
    QThread      m_thread;
    MacroEngine* m_engine = nullptr;
    bool         m_running = false;
};
