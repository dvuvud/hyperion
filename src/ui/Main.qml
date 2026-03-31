import QtQuick
import QtQuick.Controls
import Hyperion

ApplicationWindow {
    width: 800; height: 600
    visible: true

    MacroListModel {
        id: macroModel
    }

    Component.onCompleted: {
        macroModel.appendAction("key")
        macroModel.appendAction("delay")
        macroModel.appendAction("loopBegin")
        console.log("Row count:", macroModel.rowCount())
    }

    ListView {
        anchors.fill: parent
        model: macroModel
        delegate: Text {
            text: actionLabel
            color: "white"
        }
    }
}
