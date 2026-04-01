import QtQuick

// generic pill button for the title bar (Save, etc.)
Rectangle {
    id: root

    property string label: ""
    property color  baseColor:  "#1e4d8c"
    property color  hoverColor: "#2d6bc4"

    signal clicked()

    width: 64; height: 26; radius: 6
    color: hov.containsMouse ? hoverColor : baseColor
    Behavior on color { ColorAnimation { duration: 100 } }

    Text {
        anchors.centerIn: parent
        text: root.label
        color: "#e8f0fb"
        font.pixelSize: 12
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: hov
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
