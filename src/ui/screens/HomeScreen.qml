import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#0a1628"

    // titlebar
    TitleBar {
        id: titleBar
    }

    ColumnLayout {
        id: mainColumn
        anchors.centerIn: parent
        width: Math.min(520, parent.width - 48)
        spacing: 36

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Logo {}

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
                onClicked: console.log("create - coming soon")
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
    }

    // status bar
    StatusBar {}
}
