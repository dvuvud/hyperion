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

    signal addAction(string type)
    signal saveRequested()
    signal runRequested()

    RowLayout {
        anchors.left:    parent.left
        anchors.top:     parent.top
        anchors.bottom:  parent.bottom
        anchors.leftMargin: 8
        spacing: 2

        // back button
        ToolButton {
            icon.source: "../icons/back.svg"

            background: Rectangle {
                color: parent.hovered ? "#1a2d4a" : "transparent"
                radius: 4
            }

            onClicked: stack.pop()
        }

        // save button
        ToolButton {
            icon.source: "../icons/save.svg"

            background: Rectangle {
                color: parent.hovered ? "#1a2d4a" : "transparent"
                radius: 4
            }

            onClicked: macroBar.saveRequested()
        }

        // key action button
        ToolButton {
            icon.source: "../icons/keyboard.svg"

            background: Rectangle {
                color: parent.hovered ? "#1a2d4a" : "transparent"
                radius: 4
            }

            onClicked: macroBar.addAction("key")
        }

        // mouse action button
        ToolButton {
            icon.source: "../icons/mouse.svg"

            background: Rectangle {
                color: parent.hovered ? "#1a2d4a" : "transparent"
                radius: 4
            }

            onClicked: macroBar.addAction("mouse")
        }

        // delay action button
        ToolButton {
            icon.source: "../icons/delay.svg"

            background: Rectangle {
                color: parent.hovered ? "#1a2d4a" : "transparent"
                radius: 4
            }

            onClicked: macroBar.addAction("delay")
        }

        // loop action button
        ToolButton {
            icon.source: "../icons/loop.svg"

            background: Rectangle {
                color: parent.hovered ? "#1a2d4a" : "transparent"
                radius: 4
            }

            onClicked: macroBar.addAction("loopBegin")
        }

        // run button
        ToolButton {
            icon.source: "../icons/run.svg"

            background: Rectangle {
                color: parent.hovered ? "#1a2d4a" : "transparent"
                radius: 4
            }

            onClicked: macroBar.runRequested()
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
