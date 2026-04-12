import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#0a1628"

    TitleBar {
        ToolButton {
            icon.source: "../icons/back.svg"

            anchors.left:    parent.left
            anchors.top:     parent.top
            anchors.bottom:  parent.bottom
            anchors.leftMargin: 8

            background: Rectangle {
                color: parent.hovered ? "#1a2d4a" : "transparent"
                radius: 4
            }
            onClicked: stack.pop()
        }
    }
}
