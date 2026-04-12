import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#0a1628"

    ListView {
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
        width: parent.width // TODO: Change dimensions as inpector panel enters

        model: MacroListModel {}

        delegate: Rectangle {
            width: parent.width
            height: 50

            Text {
                text: actionLabel
            }
        }
    }

    MacroToolbar {
        id: toolBar
    }
}
