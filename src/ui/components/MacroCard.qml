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

        // Icon
        Rectangle {
            width: 44; height: 44
            radius: 10
            color: iconType === "create" ? "#1a3d7a" : "#163254"
            Layout.bottomMargin: 14

            Canvas {
                anchors.centerIn: parent
                width: 22; height: 22
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.strokeStyle = iconType === "create" ? "#4a8be0" : "#4a7ab5"
                    ctx.lineWidth = 1.5
                    ctx.lineCap = "round"
                    if (iconType === "create") {
                        // rounded rect outline
                        ctx.beginPath()
                        ctx.moveTo(7, 3); ctx.lineTo(15, 3)
                        ctx.arcTo(19, 3, 19, 7, 4)
                        ctx.lineTo(19, 15)
                        ctx.arcTo(19, 19, 15, 19, 4)
                        ctx.lineTo(7, 19)
                        ctx.arcTo(3, 19, 3, 15, 4)
                        ctx.lineTo(3, 7)
                        ctx.arcTo(3, 3, 7, 3, 4)
                        ctx.closePath()
                        ctx.stroke()
                        // plus
                        ctx.beginPath()
                        ctx.moveTo(11, 7); ctx.lineTo(11, 15)
                        ctx.moveTo(7,  11); ctx.lineTo(15, 11)
                        ctx.stroke()
                    } else {
                        // three bars
                        ctx.fillStyle = "#4a7ab5"
                        ctx.beginPath()
                        ctx.rect(3, 4,  16, 3); ctx.fill()
                        ctx.beginPath()
                        ctx.rect(3, 9,  16, 3); ctx.fill()
                        ctx.beginPath()
                        ctx.rect(3, 14, 10, 3); ctx.fill()
                    }
                }
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
