import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: macroBar
    anchors.top:   parent.top
    anchors.left:  parent.left
    anchors.right: parent.right
    height: 40
    color: "#07101e"

    RowLayout {
        anchors.left:    parent.left
        anchors.top:     parent.top
        anchors.bottom:  parent.bottom
        anchors.leftMargin: 8
        spacing: 2

        // back button
        ToolButton {
            text: "‹"
            font.pixelSize: 18
            contentItem: Text {
                text: parent.text
                color: "#7aa4d4"
                font: parent.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: parent.hovered ? "#1a2d4a" : "transparent"
                radius: 4
            }
            onClicked: stack.pop()
        }

        // save button
        ToolButton {
            text: "💾"
            background: Rectangle {
                color: parent.hovered ? "#1a2d4a" : "transparent"
                radius: 4
            }
            // TODO: setup onClicked:
        }

        // run button
        ToolButton {
            text: "▶"
            contentItem: Text {
                text: parent.text
                color: "#7aa4d4"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: parent.hovered ? "#1a2d4a" : "transparent"
                radius: 4
            }
            // TODO: setup onClicked:
        }
    }

    // editable title, centered
    TextInput {
        id: macroTitle
        Keys.onReturnPressed: macroTitle.focus = false
        anchors.centerIn: parent
        text: "New Macro"
        color: "#7aa4d4"
        font.pixelSize: 13
        font.weight: Font.DemiBold
        font.letterSpacing: 1.4
        horizontalAlignment: Text.AlignHCenter
        selectionColor: "#1a2d4a"
        selectedTextColor: "#b8d4f0"
    }

    // bottom border
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height: 1
        color: "#1a2d4a"
    }
}
