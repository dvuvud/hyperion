import QtQuick

Rectangle {
    property string label: ""
    property string icon: ""
    signal clicked

    width: labelText.width + 32
    height: 28
    radius: 7
    color: hover.containsMouse ? "#1a3d7a" : "#0f2040"
    border.color: hover.containsMouse ? "#2d6bc4" : "#1a2d4a"
    border.width: 1
    Behavior on color        { ColorAnimation { duration: 100 } }
    Behavior on border.color { ColorAnimation { duration: 100 } }

    Row {
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: parent.parent.icon
            color: "#7aa4d4"
            font.pixelSize: 13
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: labelText
            text: parent.parent.label
            color: "#c8ddf5"
            font.pixelSize: 12
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.clicked()
    }
}
