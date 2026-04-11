import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    property string description: ""
    property string cta: ""
    property bool   isPrimary: false
    property string iconType: "create"

    signal clicked

    radius: 14
    color: isPrimary
        ? (hovered ? "#112f5c" : "#0f2a52")
        : (hovered ? "#132848" : "#0f2040")
    border.color: hovered
        ? (isPrimary ? "#4a8be0" : "#2d6bc4")
        : (isPrimary ? "#2d6bc4" : "#1e3d6e")
    border.width: 1

    property bool hovered: false

    Behavior on color        { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited:  root.hovered = false
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 0

        // icon
        Rectangle {
            width: 44; height: 44
            radius: 10
            color: iconType === "create" ? "#1a3d7a" : "#163254"
            Layout.bottomMargin: 14

            Image {
                anchors.centerIn: parent
                width: 22
                height: 22

                source: iconType === "create"
                ? "../icons/macro-create.svg"
                : "../icons/macro-browse.svg"
            }
        }

        // title
        Text {
            text: root.title
            color: "#d0e4f8"
            font.pixelSize: 15
            font.weight: Font.DemiBold
            Layout.fillWidth: true
            Layout.bottomMargin: 6
        }

        // description
        Text {
            text: root.description
            color: "#4a7ab5"
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            lineHeight: 1.5
            Layout.fillWidth: true
        }

        // spacer. pushes CTA to bottom
        Item { Layout.fillHeight: true }

        // CTA
        Text {
            text: root.cta + " ›"
            color: "#4a8be0"
            font.pixelSize: 12
            font.weight: Font.DemiBold
            Layout.topMargin: 10
        }
    }
}
