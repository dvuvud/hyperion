import QtQuick

Rectangle {
    id: root

    property string barTitle:    ""
    property bool   showBack:    false
    property bool   showRecord:  false
    property bool   showSave:    false

    property alias macroName: titleInput.text

    signal backClicked()
    signal saveClicked()

    function releaseFocus() {
        titleInput.releaseFocus()
    }

    height: 40
    color: "#07101e"

    // bottom border
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height: 1
        color: "#1a2d4a"
    }

    // back button
    Text {
        id: backBtn
        visible: root.showBack
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 16
        text: "‹ Back"
        color: backHov.containsMouse ? "#7ab8f5" : "#4a8be0"
        font.pixelSize: 13
        font.weight: Font.DemiBold
        Behavior on color { ColorAnimation { duration: 100 } }

        MouseArea {
            id: backHov
            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.backClicked()
        }
    }

    // record button
    Rectangle {
        id: recordBtn
        visible: root.showRecord
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: backBtn.visible ? backBtn.right : parent.left
        anchors.leftMargin: 16
        width: 82; height: 26; radius: 6

        property bool recording: false

        color: recording ? (rHov.containsMouse ? "#6a1f1f" : "#5c1a1a")
                         : (rHov.containsMouse ? "#2a1515" : "#1a0f0f")
        border.color: recording ? "#e05a5a" : "#3a2020"
        border.width: 1
        Behavior on color { ColorAnimation { duration: 120 } }

        Row {
            anchors.centerIn: parent
            spacing: 6

            Rectangle {
                width: 7; height: 7; radius: 4
                color: recordBtn.recording ? "#e05a5a" : "#7a3a3a"
                anchors.verticalCenter: parent.verticalCenter
                SequentialAnimation on opacity {
                    running: recordBtn.recording
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.2; duration: 500 }
                    NumberAnimation { to: 1.0; duration: 500 }
                }
            }

            Text {
                text: recordBtn.recording ? "Stop" : "Record"
                color: recordBtn.recording ? "#e05a5a" : "#7a4a4a"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: rHov
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: recordBtn.recording = !recordBtn.recording
        }
    }

    // centre: static label or editable input
    Text {
        visible: root.barTitle !== ""
        anchors.centerIn: parent
        text: root.barTitle
        color: "#7aa4d4"
        font.pixelSize: 13
        font.weight: Font.DemiBold
        font.letterSpacing: 1.4
    }

    TitleTextInput {
        id: titleInput
        visible: root.barTitle === ""
        anchors.centerIn: parent
    }

    // Save button
    TitleBarButton {
        visible: root.showSave
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 16
        label: "Save"
        onClicked: root.saveClicked()
    }
}
