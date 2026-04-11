import QtQuick
import QtQuick.Layouts

Rectangle {
    id: statusBar
    anchors.bottom: parent.bottom
    anchors.left:   parent.left
    anchors.right:  parent.right
    height: 26
    color: "#07101e"

    Rectangle {
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right
        height: 1
        color: "#1a2d4a"
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 14
        spacing: 16

        Row {
            spacing: 5
            Rectangle {
                width: 6; height: 6; radius: 3
                color: "#2d6bc4"
                anchors.verticalCenter: parent.verticalCenter
            }
            Text { text: "Ready"; color: "#2d5a9e"; font.pixelSize: 11 }
        }
        Text { text: "Qt 6"; color: "#2d5a9e"; font.pixelSize: 11 }
    }
}
