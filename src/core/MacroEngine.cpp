#include "MacroEngine.hpp"
#include "MacroAction.hpp"
#include <QThread>
#include <iostream>
#include <stdexcept>

MacroEngine::MacroEngine(QObject* parent)
    : QObject(parent) {}

void MacroEngine::execute(const Macro& macro) {
    m_abort = false;
    emit executionStarted(QString::fromStdString(macro.id));

    try {
        for (int i = 0; i < static_cast<int>(macro.actions.size()); ++i) {
            if (m_abort) break;

            emit actionStarted(i);
            runAction(macro.actions[i]);
            emit actionFinished(i);

            // yield so the thread's event loop can process abort() calls
            QThread::yieldCurrentThread();
        }
    } catch (const std::exception& e) {
        emit executionFailed(
            QString::fromStdString(macro.id),
            QString::fromLatin1(e.what())
        );
        return;
    }

    emit executionFinished(QString::fromStdString(macro.id));
}

void MacroEngine::abort() {
    m_abort = true;
}

void MacroEngine::runAction(const MacroAction& action) {
    std::visit([](auto&& a) {
        using T = std::decay_t<decltype(a)>;

        if constexpr (std::is_same_v<T, KeyAction>) {
            // TODO: platform key injection (e.g. CGEvent on macOS)
            std::cout << "Key action" << std::endl;
            QThread::msleep(a.holdMs > 0 ? a.holdMs : 1);
        }
        else if constexpr (std::is_same_v<T, MouseAction>) {
            // TODO: platform mouse injection
            std::cout << "Mouse action" << std::endl;
            QThread::msleep(a.holdMs > 0 ? a.holdMs : 1);
        }
        else if constexpr (std::is_same_v<T, DelayAction>) {
            QThread::msleep(a.fixedMs);
            std::cout << "Delay action" << std::endl;
            // TODO: add jitter. rand in [0, jitterMs]
        }
        else if constexpr (std::is_same_v<T, LoopBegin>) {
            std::cout << "Loop action" << std::endl;
            // loop control is handled at a higher level. no-op here for now
        }
    }, action);
}
