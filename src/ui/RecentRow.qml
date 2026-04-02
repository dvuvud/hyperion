import QtQuick

Rectangle {
    id: root

    property string macroName: ""
    property string metaText:  ""
    property bool   isActive:  false

    signal clicked

    height: 36
    radius: 8
    color: hovered ? "#0f2040" : "transparent"
    property bool hovered: false

    Behavior on color { ColorAnimation { duration: 100 } }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited:  root.hovered = false
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Rectangle {
            width: 8; height: 8; radius: 4
            anchors.verticalCenter: parent.verticalCenter
            color: isActive ? "#2d6bc4" : "#1e3d6e"
        }

        Text {
            text: root.macroName
            color: "#7aa4d4"
            font.pixelSize: 13
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 120
        }

        Text {
            text: root.metaText
            color: "#2d5a9e"
            font.pixelSize: 11
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "›"
            color: "#2d5a9e"
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
