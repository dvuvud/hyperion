#include "MacroSerializer.hpp"

#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QtCore>

namespace {

    QJsonObject actionToJson(const MacroAction& action) {
        return std::visit([](auto&& a) -> QJsonObject {
                using T = std::decay_t<decltype(a)>;

                QJsonObject obj;

                if constexpr (std::is_same_v<T, KeyAction>) {
                    obj["type"] = "key";
                    obj["key"] = (int)a.key;
                    obj["press"] = a.press;
                    obj["modifiers"] = (int)a.modifiers;
                    obj["holdMs"] = (int)a.holdMs;
                } else if constexpr (std::is_same_v<T, MouseAction>) {
                    obj["type"] = "mouse";
                    obj["x"] = a.x;
                    obj["y"] = a.y;
                    obj["holdMs"] = (int)a.holdMs;
                } else if constexpr (std::is_same_v<T, DelayAction>) {
                    obj["type"] = "delay";
                    obj["fixedMs"] = (int)a.fixedMs;
                    obj["jitterMs"] = (int)a.jitterMs;
                } else if constexpr (std::is_same_v<T, LoopBegin>) {
                    obj["type"] = "loopBegin";
                    obj["count"] = (int)a.count;
                    obj["infinite"] = a.infinite;
                }

                return obj;
        }, action);
    }

    std::optional<MacroAction> actionFromJson(const QJsonObject& obj) {
        QString type = obj["type"].toString();

        if (type == "key") {
            return KeyAction{
                (uint)obj["key"].toInt(),
                      obj["press"].toBool(),
                (uint)obj["modifiers"].toInt(),
                (uint)obj["holdMs"].toInt()
            };
        }

        if (type == "mouse") {
            return MouseAction{
                static_cast<MouseAction::Button>(obj["button"].toInt()),
                static_cast<MouseAction::Kind>(obj["kind"].toInt()),
                obj["holdMs"].toInt()
            };
        }

        if (type == "delay") {
            return DelayAction{
                (uint)obj["fixedMs"].toInt(),
                (uint)obj["jitterMs"].toInt()
            };
        }

        if (type == "loopBegin") {
            return LoopBegin{
                (uint)obj["count"].toInt(),
                      obj["infinite"].toBool()
            };
        }

        return std::nullopt;
    }

}

namespace MacroSerializer {

    bool saveToFile(const Macro& macro, const QString& path) {
        QFile file(QDir(PROJECT_ROOT).filePath(path));

        if (!file.open(QIODevice::WriteOnly)) {
            qWarning() << "Error:" << file.errorString();
            return false;
        }

        QJsonObject root;
        root["name"] = QString::fromStdString(macro.name);
        root["id"]   = QString::fromStdString(macro.id);

        QJsonArray actions;
        for (const auto& a : macro.actions) {
            actions.append(actionToJson(a));
        }

        root["actions"] = actions;

        QJsonDocument doc(root);
        file.write(doc.toJson(QJsonDocument::Indented));

        return true;
    }

    std::optional<Macro> loadFromFile(const QString& path) {
        QFile file(QDir(PROJECT_ROOT).filePath(path));

        if (!file.open(QIODevice::ReadOnly)) {
            qWarning() << "Error:" << file.errorString();
            return std::nullopt;
        }

        QByteArray data = file.readAll();
        QJsonDocument doc = QJsonDocument::fromJson(data);

        if (!doc.isObject())
            return std::nullopt;

        QJsonObject obj = doc.object();

        Macro macro;
        macro.name = obj["name"].toString().toStdString();
        macro.id   = obj["id"].toString().toStdString();

        QJsonArray actions = obj["actions"].toArray();
        for (const auto& val : actions) {
            auto action = actionFromJson(val.toObject());
            if (action)
                macro.actions.push_back(*action);
        }

        return macro;
    }

}
