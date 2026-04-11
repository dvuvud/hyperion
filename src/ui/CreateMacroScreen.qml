import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models
import Hyperion

FocusScope {
    id: root
    property int selectedIndex: -1

    Rectangle {
        anchors.fill: parent
        color: "#0a1628"
        MouseArea {
            anchors.fill: parent
            onClicked: titleBar.releaseFocus()
        }
    }

    MacroListModel { id: macroModel }

    // bind the TitleBar's editable field bidirectionally
    Binding {
        target:   titleBar
        property: "macroName"
        value:    macroModel.macroName
    }

    // write changes back to the model
    Connections {
        target: titleBar
        function onMacroNameChanged() {
            macroModel.macroName = titleBar.macroName
        }
    }

    TitleBar {
        id: titleBar
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right
        z: 10
        showBack: true; showRecord: true; showSave: true
        onBackClicked: stack.pop()
        onSaveClicked: {
            MacroEngineHost.executeFromModel(macroModel)
            stack.pop()
        }
    }

    // body
    Item {
        id: body
        anchors.top:    titleBar.bottom
        anchors.bottom: toolbar.top
        anchors.left:   parent.left
        anchors.right:  parent.right

        // empty state
        Column {
            anchors.centerIn: parent
            spacing: 10
            visible: macroModel.count === 0
            opacity: 0.35
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "No actions yet"
                color: "#7aa4d4"; font.pixelSize: 15; font.weight: Font.DemiBold
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Use the toolbar below to add your first action"
                color: "#4a7ab5"; font.pixelSize: 12
            }
        }

        // list
        ListView {
            id: listView
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            anchors.left:   parent.left
            anchors.right:  parent.right
            topMargin:   12
            leftMargin:  16
            rightMargin: 16
            spacing: 6
            clip: true
            model: macroModel

            displaced: Transition {
                NumberAnimation { properties: "y"; duration: 180; easing.type: Easing.OutCubic }
            }

            delegate: Item {
                id: delegateRoot
                required property int    index
                required property string actionType
                required property string actionLabel

                width:  listView.width - listView.leftMargin - listView.rightMargin
                height: 48

                ActionBlock {
                    anchors.left:   parent.left
                    anchors.right:  reorderBtns.left
                    anchors.rightMargin: 6
                    height: parent.height
                    actionType:   delegateRoot.actionType
                    actionLabel:  delegateRoot.actionLabel
                    isSelected:   root.selectedIndex === delegateRoot.index
                    blockIndex:   delegateRoot.index
                    onSelectRequested: root.selectedIndex = delegateRoot.index
                    onDeleteRequested: {
                        if (root.selectedIndex === delegateRoot.index)
                            root.selectedIndex = -1
                        macroModel.removeAction(delegateRoot.index)
                    }
                }

                // up / down buttons
                Column {
                    id: reorderBtns
                    anchors.right:          parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Repeater {
                        model: [
                            { arrow: "▲", delta: -1 },
                            { arrow: "▼", delta:  1 },
                        ]
                        delegate: Rectangle {
                            required property var  modelData
                            property bool isUp:       modelData.delta < 0
                            property bool isDisabled: isUp
                                ? delegateRoot.index === 0
                                : delegateRoot.index === macroModel.count - 1

                            width: 24; height: 21; radius: 5
                            color: btnHov.containsMouse && !isDisabled
                                   ? "#1a3a6b" : "transparent"
                            Behavior on color { ColorAnimation { duration: 80 } }

                            Text {
                                anchors.centerIn: parent
                                text:  modelData.arrow
                                color: parent.isDisabled ? "#2a3a55" : "#4a8be0"
                                font.pixelSize: 10
                                Behavior on color { ColorAnimation { duration: 80 } }
                            }

                            MouseArea {
                                id: btnHov
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  parent.isDisabled
                                              ? Qt.ArrowCursor
                                              : Qt.PointingHandCursor
                                enabled: !parent.isDisabled
                                onClicked: {
                                    const from = delegateRoot.index
                                    const to   = from + modelData.delta
                                    macroModel.moveAction(from, to)
                                    if (root.selectedIndex === from)
                                        root.selectedIndex = to
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // toolbar
    Rectangle {
        id: toolbar
        anchors.bottom: parent.bottom
        anchors.left: parent.left; anchors.right: parent.right
        height: 48; color: "#07101e"

        Rectangle {
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            height: 1; color: "#1a2d4a"
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left; anchors.leftMargin: 16
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Add:"; color: "#2d5a9e"
                font.pixelSize: 11; font.weight: Font.DemiBold
                font.letterSpacing: 0.8; rightPadding: 4
            }

            Repeater {
                model: [
                    { label: "Key",   type: "key",       icon: "⌨" },
                    { label: "Mouse", type: "mouse",     icon: "🖱" },
                    { label: "Delay", type: "delay",     icon: "⏱" },
                    { label: "Loop",  type: "loopBegin", icon: "↺" },
                ]
                delegate: ToolbarButton {
                    required property var modelData
                    label: modelData.label
                    icon:  modelData.icon
                    onClicked: macroModel.appendAction(modelData.type)
                }
            }
        }
    }
}
