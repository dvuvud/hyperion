import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#0a1628"

    TitleBar {
        id: titleBar
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right
        barTitle: "HYPERION"
    }

    ScrollView {
        anchors.top:    titleBar.bottom
        anchors.bottom: statusBar.top
        anchors.left:   parent.left
        anchors.right:  parent.right
        contentWidth: availableWidth
        clip: true

        Item {
            width: parent.width
            implicitHeight: mainColumn.implicitHeight + 80

            ColumnLayout {
                id: mainColumn
                anchors.centerIn: parent
                width: Math.min(520, parent.width - 48)
                spacing: 36

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10

                    Rectangle {
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

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Hyperion"
                        color: "#e8f0fb"
                        font.pixelSize: 26
                        font.weight: Font.Bold
                        font.letterSpacing: -0.5
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Macro automation — precise, human-like, fast"
                        color: "#4a7ab5"
                        font.pixelSize: 14
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    MacroCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        title: "Create macro"
                        description: "Record your actions or build step by step using the block editor."
                        cta: "Get started"
                        isPrimary: true
                        iconType: "create"
                        onClicked: stack.push(Qt.resolvedUrl("CreateMacroScreen.qml"))
                    }

                    MacroCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        title: "My library"
                        description: "Browse, edit and run macros you've already built."
                        cta: "Open library"
                        isPrimary: false
                        iconType: "library"
                        onClicked: console.log("library — coming soon")
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "RECENT"
                        color: "#2d5a9e"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.8
                        bottomPadding: 8
                    }

                    Repeater {
                        model: [
                            { name: "Login flow",      meta: "2 actions · edited today", active: true  },
                            { name: "Form filler",     meta: "8 actions · yesterday",    active: false },
                            { name: "Screenshot loop", meta: "3 actions · 3 days ago",   active: false },
                        ]
                        delegate: RecentRow {
                            required property var modelData
                            Layout.fillWidth: true
                            macroName: modelData.name
                            metaText:  modelData.meta
                            isActive:  modelData.active
                        }
                    }
                }
            }
        }
    }

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
            Text { text: "Qt 6";          color: "#2d5a9e"; font.pixelSize: 11 }
            Text { text: "macOS · arm64"; color: "#2d5a9e"; font.pixelSize: 11 }
        }
    }
}
