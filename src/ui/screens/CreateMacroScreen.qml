import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#0a1628"

    property int selectedIndex: -1
    property var selectedData: ({})
    property string selectedType: ""

    // list + inspector panel
    Item {
        anchors { top: toolBar.bottom; bottom: parent.bottom; }
        width: parent.width

        ListView {
            anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: inspectorPanel.left }

            model: MacroListModel {
                id: macroModel
            }

            delegate: MacroItem {
                width: ListView.view.width
                title: actionLabel
                type: actionType

                onClicked: {
                    if (root.selectedIndex === index) {
                        root.selectedType = ""
                        root.selectedData = ({})
                        root.selectedIndex = -1
                    } else {
                        root.selectedType = "" // briefly unload for safety
                        root.selectedData = actionData
                        root.selectedType = actionType
                        root.selectedIndex = index
                    }
                    console.log("Clicked item:", index)
                }
            }
        }

        Rectangle {
            id: inspectorPanel
            width: 280
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
            anchors.rightMargin: selectedIndex >= 0 ? 0 : -width
            Behavior on anchors.rightMargin { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            color: "#07101e"
            border.color: "#1f2a3a"
            border.width: 1
            radius: 10

            Loader {
                id: inspectorLoader
                anchors.fill: parent

                sourceComponent: {
                    switch(root.selectedType) {
                        case "key":       return keyEditorComponent
                        case "mouse":     return mouseEditorComponent
                        case "delay":     return delayEditorComponent
                        case "loopBegin": return loopEditorComponent
                        default:          return null
                    }
                }
            }

            Component {
                id: keyEditorComponent
                Column {
                    spacing: 8
                    padding: 12

                    property int currentModifiers: root.selectedData.modifiers ?? 0

                    Text { text: "Key"; color: "#ffffff"; font.pixelSize: 12 }
                    TextField {
                        width: parent.width - 24
                        maximumLength: 1
                        text: root.selectedData.key ? String.fromCharCode(root.selectedData.key) : ""
                        onEditingFinished: {
                            if (text.length > 0)
                            macroModel.updateAction(root.selectedIndex, { key: text.charCodeAt(0) })
                        }
                    }

                    Text { text: "Direction"; color: "#ffffff"; font.pixelSize: 12 }
                    ComboBox {
                        width: parent.width - 24
                        model: ["Press (↓)", "Release (↑)"]
                        currentIndex: root.selectedData.press ? 0 : 1
                        onActivated: (idx) => macroModel.updateAction(
                            root.selectedIndex, { press: idx === 0 })
                        }

                        Text { text: "Modifiers"; color: "#ffffff"; font.pixelSize: 12 }

                        // one row per modifier — checkbox + label
                        Repeater {
                            model: [
                                { label: "Shift",        bit: 1 },
                                { label: "Control",      bit: 2 },
                                { label: "Alt / Option", bit: 4 },
                                { label: "Meta / Cmd",   bit: 8 },
                            ]

                            delegate: Row {
                                spacing: 8
                                width: parent.width - 24

                                CheckBox {
                                    checked: (parent.parent.currentModifiers & modelData.bit) !== 0
                                    onToggled: {
                                        var col = parent.parent   // the Column
                                        col.currentModifiers = checked
                                        ? col.currentModifiers | modelData.bit
                                        : col.currentModifiers & ~modelData.bit
                                        macroModel.updateAction(
                                            root.selectedIndex,
                                            { modifiers: col.currentModifiers })
                                        }
                                    }
                                    Text {
                                        text: modelData.label
                                        color: "#c0d4ee"
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            Text { text: "Hold (ms)"; color: "#ffffff"; font.pixelSize: 12 }
                            TextField {
                                width: parent.width - 24
                                text: root.selectedData.holdMs ?? 0
                                inputMethodHints: Qt.ImhDigitsOnly
                                onEditingFinished: macroModel.updateAction(
                                    root.selectedIndex, { holdMs: parseInt(text) })
                                }
                            }
                        }

            Component {
                id: mouseEditorComponent
                Column {
                    spacing: 8
                    padding: 12

                    property int currentKind:   root.selectedData.kind   ?? 0
                    property int currentButton: root.selectedData.button ?? 0

                    Text { text: "Kind"; color: "#ffffff"; font.pixelSize: 12 }
                    ComboBox {
                        width: parent.width - 24
                        model: ["Click", "Press", "Release", "Move", "Scroll"]
                        currentIndex: parent.currentKind
                        onActivated: (idx) => {
                            parent.currentKind = idx
                            macroModel.updateAction(root.selectedIndex, { kind: idx })
                        }
                    }

                    Text {
                        text: "Button"; color: "#ffffff"; font.pixelSize: 12
                        visible: parent.currentKind < 3
                    }
                    ComboBox {
                        width: parent.width - 24
                        visible: parent.currentKind < 3
                        model: ["Left", "Right", "Middle"]
                        currentIndex: parent.currentButton
                        onActivated: (idx) => {
                            parent.currentButton = idx
                            macroModel.updateAction(root.selectedIndex, { button: idx })
                        }
                    }

                    Text {
                        text: "X"; color: "#ffffff"; font.pixelSize: 12
                        visible: parent.currentKind !== 4
                    }
                    TextField {
                        width: parent.width - 24
                        visible: parent.currentKind !== 4
                        text: root.selectedData.x ?? 0
                        inputMethodHints: Qt.ImhDigitsOnly
                        onEditingFinished: macroModel.updateAction(root.selectedIndex, { x: parseInt(text) })
                    }

                    Text {
                        text: "Y"; color: "#ffffff"; font.pixelSize: 12
                        visible: parent.currentKind !== 4
                    }
                    TextField {
                        width: parent.width - 24
                        visible: parent.currentKind !== 4
                        text: root.selectedData.y ?? 0
                        inputMethodHints: Qt.ImhDigitsOnly
                        onEditingFinished: macroModel.updateAction(root.selectedIndex, { y: parseInt(text) })
                    }

                    Text {
                        text: "Scroll delta"; color: "#ffffff"; font.pixelSize: 12
                        visible: parent.currentKind === 4
                    }
                    TextField {
                        width: parent.width - 24
                        visible: parent.currentKind === 4
                        text: root.selectedData.scrollDelta ?? 0
                        inputMethodHints: Qt.ImhDigitsOnly
                        placeholderText: "+ up  / − down"
                        onEditingFinished: macroModel.updateAction(root.selectedIndex, { scrollDelta: parseInt(text) })
                    }

                    Text {
                        text: "Hold (ms)"; color: "#ffffff"; font.pixelSize: 12
                        visible: parent.currentKind < 3
                    }
                    TextField {
                        width: parent.width - 24
                        visible: parent.currentKind < 3
                        text: root.selectedData.holdMs ?? 0
                        inputMethodHints: Qt.ImhDigitsOnly
                        onEditingFinished: macroModel.updateAction(root.selectedIndex, { holdMs: parseInt(text) })
                    }
                }
            }

            Component {
                id: delayEditorComponent
                Column {
                    spacing: 8
                    padding: 12

                    Text { text: "Fixed (ms)"; color: "#ffffff" }
                    TextField {
                        text: root.selectedData.fixedMs
                        onTextChanged: macroModel.updateAction(root.selectedIndex, { fixedMs: parseInt(text) })
                    }

                    Text { text: "Jitter (ms)"; color: "#ffffff" }
                    TextField {
                        text: root.selectedData.jitterMs
                        onTextChanged: macroModel.updateAction(root.selectedIndex, { jitterMs: parseInt(text) })
                    }
                }
            }

            Component {
                id: loopEditorComponent
                Column {
                    spacing: 8
                    padding: 12

                    Text { text: "Count"; color: "#ffffff" }
                    TextField {
                        enabled: !root.selectedData.infinite
                        text: root.selectedData.count
                        onTextChanged: macroModel.updateAction(root.selectedIndex, { count: parseInt(text) })
                    }

                    Text { text: "Infinite"; color: "#ffffff" }
                    Switch {
                        checked: root.selectedData.infinite
                        onCheckedChanged: macroModel.updateAction(root.selectedIndex, { infinite: checked })
                    }
                }
            }
        }
    }

    MacroToolbar {
        id: toolBar

        onAddAction: (type) => {
            macroModel.appendAction(type)
        }

        onSaveRequested: {
            var ok = macroModel.saveToFile("data/" + macroModel.macroName + ".json")
            console.log("Saved to data/" + macroModel.macroName + ".json: ", ok)
        }

        onRunRequested: {
            MacroEngineHost.executeFromModel(macroModel);
            console.log("run macro")
        }

        onTextEdited: (text) => {
            macroModel.macroName = text
        }
    }
}
