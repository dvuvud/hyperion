import QtQuick
import QtQuick.Layouts

Rectangle {
    id: logo
    Layout.alignment: Qt.AlignHCenter
    width: 52; height: 52
    radius: 14
    color: "#1a3a6b"
    border.color: "#2d5a9e"
    border.width: 1

    Canvas {
        anchors.centerIn: parent
        width: 28; height: 28
        onPaint: {
            var ctx = getContext("2d")
            ctx.strokeStyle = "#4a8be0"
            ctx.lineWidth = 1.5
            ctx.lineCap = "round"
            ctx.beginPath()
            ctx.arc(14, 14, 6, 0, Math.PI * 2)
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(14, 4);  ctx.lineTo(14, 8)
            ctx.moveTo(14, 20); ctx.lineTo(14, 24)
            ctx.moveTo(4,  14); ctx.lineTo(8,  14)
            ctx.moveTo(20, 14); ctx.lineTo(24, 14)
            ctx.stroke()
            ctx.fillStyle = "#4a8be0"
            ctx.beginPath()
            ctx.arc(14, 14, 2, 0, Math.PI * 2)
            ctx.fill()
        }
    }
}
