import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    property string type: ""
    property bool hovered: false

    signal clicked

    width: parent ? parent.width : 200
    height: 56
    radius: 10

    color: hovered ? "#16243a" : "#0f1b2a"
    border.color: hovered ? "#3b82f6" : "#1f2a3a"
    border.width: 1

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: root.clicked()

        cursorShape: Qt.PointingHandCursor
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // small type badge
        Rectangle {
            width: 34
            height: 34
            radius: 6
            color: "#1f2a3a"
            border.color: "#2a3b52"

            Text {
                anchors.centerIn: parent
                text: root.type
                color: "#7aa2f7"
                font.pixelSize: 10
            }
        }

        // main label
        Text {
            text: root.title
            color: "#d6e4ff"
            font.pixelSize: 13
            font.weight: Font.Medium
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }
}
