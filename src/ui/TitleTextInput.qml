import QtQuick

// editable title field. focus is released on return, escape, or when
// releaseFocus() is called externally (e.g. from a background click).
Item {
    id: root

    property alias text: input.text
    property bool  editing: input.activeFocus

    function releaseFocus() {
        input.focus = false
    }

    implicitWidth:  220
    implicitHeight: input.implicitHeight + 4

    TextInput {
        id: input
        anchors.centerIn: parent
        width: parent.width

        text: "New Macro"
        color: "#e8f0fb"
        font.pixelSize: 13
        font.weight: Font.DemiBold
        horizontalAlignment: TextInput.AlignHCenter
        selectByMouse: true

        Keys.onReturnPressed: input.focus = false
        Keys.onEscapePressed: input.focus = false
    }

    // animated underline
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height: 1
        color: input.activeFocus ? "#4a8be0" : "#1a2d4a"
        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
