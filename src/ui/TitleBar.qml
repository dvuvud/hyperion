import QtQuick
import QtQuick.Layouts

Rectangle {
    id: titleBar
    anchors.top:   parent.top
    anchors.left:  parent.left
    anchors.right: parent.right
    height: 40
    color: "#07101e"

    // title text
    Text {
        id: titleText
        anchors.centerIn: parent
        text: "HYPERION"
        color: "#7aa4d4"
        font.pixelSize: 13
        font.weight: Font.DemiBold
        font.letterSpacing: 1.4
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
