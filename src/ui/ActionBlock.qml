import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string actionType:  ""
    property string actionLabel: ""
    property bool   isSelected:  false
    property int    blockIndex:  0

    signal selectRequested
    signal deleteRequested
    signal moveRequested(int from, int to)

    height: 48
    radius: 10
    color: isSelected ? "#112f5c" : (hovered ? "#0f2040" : "#0d1c36")
    border.color: isSelected ? "#2d6bc4" : "#1a2d4a"
    border.width: 1

    property bool hovered: false

    Behavior on color        { ColorAnimation { duration: 100 } }
    Behavior on border.color { ColorAnimation { duration: 100 } }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered:  root.hovered = true
        onExited:   root.hovered = false
        onClicked:  root.selectRequested()
        cursorShape: Qt.PointingHandCursor
    }

    // type badge
    Rectangle {
        id: badge
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: 32; height: 32; radius: 8

        color: {
            switch (root.actionType) {
                case "key":       return "#1e4d8c"
                case "mouse":     return "#1a5c42"
                case "delay":     return "#7a4a10"
                case "loopBegin": return "#4a1a7a"
                default:          return "#1a2d4a"
            }
        }

        // canvas icon. one per action type
        Canvas {
            id: iconCanvas
            anchors.centerIn: parent
            width: 20; height: 20
            onPaint: {
                var ctx = getContext("2d")
                
                function drawRoundRect(x, y, w, h, r) {
                    ctx.beginPath();
                    ctx.moveTo(x + r, y);
                    ctx.lineTo(x + w - r, y);
                    ctx.arcTo(x + w, y, x + w, y + r, r);
                    ctx.lineTo(x + w, y + h - r);
                    ctx.arcTo(x + w, y + h, x + w - r, y + h, r);
                    ctx.lineTo(x + r, y + h);
                    ctx.arcTo(x, y + h, x, y + h - r, r);
                    ctx.lineTo(x, y + r);
                    ctx.arcTo(x, y, x + r, y, r);
                    ctx.closePath();
                    ctx.fill();
                }

                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = "#a8ccf0"
                ctx.fillStyle   = "#a8ccf0"
                ctx.lineWidth   = 1.5
                ctx.lineCap     = "round"
                ctx.lineJoin    = "round"

                switch (root.actionType) {

                // keyboard: draw a small 3-row keyboard grid
                case "key":
                    // top row: 4 small keys
                    var keyW = 3, keyH = 2.5, gap = 1
                    var rowY = [3, 7, 11]
                    var counts = [4, 4, 3]
                    var offsets = [1, 1, 2.5]
                    for (var r = 0; r < 3; r++) {
                        for (var k = 0; k < counts[r]; k++) {
                            var kx = offsets[r] + k * (keyW + gap)
                            drawRoundRect(kx, rowY[r], keyW, keyH, 0.5)
                        }
                    }
                    // space bar
                    drawRoundRect(3, 15, 14, 2.5, 0.5)
                    break

                // mouse: outline of a mouse body
                case "mouse":
                    // body outline
                    ctx.beginPath()
                    ctx.moveTo(10, 18)
                    ctx.bezierCurveTo(4, 18, 2, 13, 2, 9)
                    ctx.bezierCurveTo(2, 4,  5,  2, 10, 2)
                    ctx.bezierCurveTo(15, 2, 18, 4, 18, 9)
                    ctx.bezierCurveTo(18, 13, 16, 18, 10, 18)
                    ctx.stroke()
                    // centre dividing line
                    ctx.beginPath()
                    ctx.moveTo(10, 2); ctx.lineTo(10, 9)
                    ctx.stroke()
                    // scroll wheel
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    ctx.moveTo(10, 7); ctx.lineTo(10, 11)
                    ctx.stroke()
                    ctx.lineWidth = 1.5
                    break

                // ── delay: clock face ─────────────────────────
                case "delay":
                    // circle
                    ctx.beginPath()
                    ctx.arc(10, 10, 8, 0, Math.PI * 2)
                    ctx.stroke()
                    // hour hand pointing to ~12
                    ctx.beginPath()
                    ctx.moveTo(10, 10); ctx.lineTo(10, 4)
                    ctx.stroke()
                    // minute hand pointing to ~3
                    ctx.beginPath()
                    ctx.moveTo(10, 10); ctx.lineTo(15, 10)
                    ctx.stroke()
                    // centre dot
                    ctx.beginPath()
                    ctx.arc(10, 10, 1.2, 0, Math.PI * 2)
                    ctx.fill()
                    break

                // loop begin: circular arrow
                case "loopBegin":
                    // arc (~300 degrees)
                    ctx.beginPath()
                    ctx.arc(10, 10, 7, 0.5, Math.PI * 2 - 0.1)
                    ctx.stroke()
                    // arrowhead at end of arc
                    ctx.beginPath()
                    ctx.moveTo(17, 9)
                    ctx.lineTo(17.5, 12.5)
                    ctx.lineTo(14.5, 11)
                    ctx.closePath()
                    ctx.fill()
                    // count indicator. small "n" label inside
                    ctx.font = "bold 6px sans-serif"
                    ctx.textAlign = "center"
                    ctx.textBaseline = "middle"
                    ctx.fillText("n", 10, 10)
                    break

                default:
                    // generic gear
                    ctx.beginPath()
                    ctx.arc(10, 10, 4, 0, Math.PI * 2)
                    ctx.stroke()
                    break
                }
            }

            // repaint whenever the action type changes
            Connections {
                target: root
                function onActionTypeChanged() { iconCanvas.requestPaint() }
            }
        }
    }

    // label
    Text {
        anchors.left: badge.right
        anchors.leftMargin: 10
        anchors.right: deleteBtn.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.actionLabel
        color: "#c8ddf5"
        font.pixelSize: 13
        elide: Text.ElideRight
    }

    // delete button
    Text {
        id: deleteBtn
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: "✕"
        color: deleteHover.containsMouse ? "#e05a5a" : "#2d5a9e"
        font.pixelSize: 11
        opacity: root.hovered ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 100 } }
        Behavior on color   { ColorAnimation  { duration: 100 } }

        MouseArea {
            id: deleteHover
            anchors.fill: parent
            anchors.margins: -6
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => {
                mouse.accepted = true
                root.deleteRequested()
            }
        }
    }
}
