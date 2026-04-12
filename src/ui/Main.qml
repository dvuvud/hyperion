import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root
    width: 800
    height: 560
    visible: true
    title: "Hyperion"
    color: "#0a1628"

    StackView {
        id: stack
        anchors.top: parent.top
        anchors.bottom: statusBar.top
        anchors.left: parent.left
        anchors.right: parent.right

        initialItem: HomeScreen {}

        pushEnter: Transition {
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 120 }
            PropertyAnimation { property: "x"; from: 30; to: 0; duration: 120; easing.type: Easing.OutCubic }
        }
        pushExit: Transition {
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 120 }
        }
        popEnter: Transition {
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 120 }
        }
        popExit: Transition {
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 120 }
            PropertyAnimation { property: "x"; from: 0; to: 30; duration: 120; easing.type: Easing.InCubic }
        }
    }
    StatusBar {
        id: statusBar
    }
}
