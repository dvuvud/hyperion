#include "MacroEngine.hpp"
#include "MacroAction.hpp"
#include <QThread>
#include <iostream>

#include <cstdlib>
#include <ctime>
#include <stdexcept>

MacroEngine::MacroEngine(QObject* parent)
    : QObject(parent)
{
    std::srand(static_cast<unsigned>(std::time(nullptr)));
}

void MacroEngine::execute(const Macro& macro) {
    m_abort = false;
    m_loopStack.clear();

    emit executionStarted(QString::fromStdString(macro.id));

    try {
        const auto& actions = macro.actions;
        const int   count   = static_cast<int>(actions.size());

        for (int i = 0; i < count;) {
            if (m_abort) break;

            emit actionStarted(i);
            bool ok = runAction(actions[i]);
            emit actionFinished(i);

            if (!ok) break;

            if (std::holds_alternative<LoopBegin>(actions[i])) {
                const auto& lb = std::get<LoopBegin>(actions[i]);
                m_loopStack.push_back({ i, lb.infinite ? 0 : lb.count, lb.infinite });
                ++i;
                continue;
            }

            if (std::holds_alternative<LoopEnd>(actions[i])) {
                if (!m_loopStack.empty()) {
                    auto& frame = m_loopStack.back();
 
                    if (frame.infinite) {
                        i = frame.startIndex + 1;
                        continue;
                    }
 
                    --frame.remaining;
                    if (frame.remaining > 0) {
                        i = frame.startIndex + 1; // jump past the LoopBegin
                        continue;
                    } else {
                        m_loopStack.pop_back();
                    }
                }
            }

            ++i;

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

// private helpers

bool MacroEngine::interruptibleSleep(uint32_t ms, uint32_t granularityMs) {
    // Break the total sleep into small chunks so that m_abort is checked
    // frequently to make abort() feel instantaneous to the user.
    uint32_t elapsed = 0;
    while (elapsed < ms) {
        if (m_abort) return false;
        uint32_t slice = std::min(granularityMs, ms - elapsed);
        QThread::msleep(slice);
        elapsed += slice;
    }
    return !m_abort;
}


bool MacroEngine::runAction(const MacroAction& action) {
    return std::visit([this](auto&& a) -> bool {
        using T = std::decay_t<decltype(a)>;

        if constexpr (std::is_same_v<T, KeyAction>) {
            // TODO: platform key injection (e.g. CGEvent on macOS)
            std::cout << "Key action" << std::endl;
            if (a.holdMs > 0) {
                if (!interruptibleSleep(a.holdMs)) return false;
            }
            return true;
        }
        else if constexpr (std::is_same_v<T, MouseAction>) {
            // TODO: platform mouse injection
            std::cout << "Mouse action" << std::endl;
            if (a.holdMs > 0) {
                if (!interruptibleSleep(a.holdMs)) return false;
            }
            return true;
        }
        else if constexpr (std::is_same_v<T, DelayAction>) {
            std::cout << "Delay action" << std::endl;
            uint32_t jitter = 0;
            if (a.jitterMs > 0) {
                // Uniform random in [0, jitterMs]
                jitter = static_cast<uint32_t>(std::rand()) % (a.jitterMs + 1);
            }
            return interruptibleSleep(a.fixedMs + jitter);
        }
        else if constexpr (std::is_same_v<T, LoopBegin>) {
            std::cout << "Loop begin" << std::endl;
            return true;
            // loop control is handled at a higher level. no-op here for now
        }
        else if constexpr (std::is_same_v<T, LoopEnd>) {
            std::cout << "Loop end" << std::endl;
            return true;
        }
    }, action);
}
