#include "MacroEngineHost.hpp"

MacroEngineHost::MacroEngineHost(QObject* parent)
    : QObject(parent)
    , m_engine(new MacroEngine)
{
    m_engine->moveToThread(&m_thread);

    // engine -> host (cross-thread, queued automatically)
    connect(m_engine, &MacroEngine::executionStarted, this, [this] {
        m_running = true;
        emit runningChanged();
    });
    connect(m_engine, &MacroEngine::executionFinished, this, [this] {
        m_running = false;
        emit runningChanged();
    });
    connect(m_engine, &MacroEngine::executionFailed, this, [this](auto& id, auto& reason) {
        m_running = false;
        emit runningChanged();
        emit executionFailed(id, reason);
    });
    connect(m_engine, &MacroEngine::actionStarted,  this, &MacroEngineHost::actionStarted);
    connect(m_engine, &MacroEngine::actionFinished, this, &MacroEngineHost::actionFinished);

    // host -> engine (queued. safe across threads)
    connect(this, &MacroEngineHost::_execute, m_engine, &MacroEngine::execute);
    connect(this, &MacroEngineHost::_abort,   m_engine, &MacroEngine::abort);

    connect(&m_thread, &QThread::finished, m_engine, &QObject::deleteLater);
    m_thread.start();
}

MacroEngineHost::~MacroEngineHost() {
    m_thread.quit();
    m_thread.wait();
}

void MacroEngineHost::execute(const Macro& macro) {
    if (m_running) return;
    emit _execute(macro);
}

void MacroEngineHost::executeFromModel(MacroListModel* model) {
    if (!model) return;
    execute(model->macro());
}

void MacroEngineHost::abort() {
    emit _abort();
}
