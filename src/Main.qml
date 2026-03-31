import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 800
    height: 600
    visible: true
    title: "Hyperion - Hello World!"

    background: Rectangle {
        color: "#212121"
    }

    Label {
        text: "Hyperion System Ready"
        anchors.centerIn: parent
        color: "cyan"
        font.pixelSize: 24
    }
}
