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
    // Run a single action and return false if aborted
    bool runAction(const MacroAction& action);

    // Sleep for `ms` milliseconds, checking m_abort every `granularityMs`.
    // Returns false if aborted before the full duration elapsed.
    bool interruptibleSleep(uint32_t ms, uint32_t granularityMs = 20);

    // Loop frame pushed onto m_loopStack when we enter a LoopBegin.
    struct LoopFrame {
        int      startIndex;    // index of the LoopBegin action
        uint32_t remaining;     // iterations left (0 = infinite)
        bool     infinite;
    };

    std::atomic<bool> m_abort { false };
    std::vector<LoopFrame> m_loopStack;
};
