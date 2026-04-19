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

                    Text { text: "Key"; color: "#ffffff" }
                    TextField {
                        maximumLength: 1
                        text: root.selectedData.key ? String.fromCharCode(root.selectedData.key) : ""
                        onTextChanged: {
                            if (text.length > 0)
                                macroModel.updateAction(root.selectedIndex, { key: text.charCodeAt(0) })
                        }
                    }

                    Text { text: "Press"; color: "#ffffff" }
                    Switch {
                        checked: root.selectedData.press
                        onCheckedChanged: macroModel.updateAction(root.selectedIndex, { press: checked })
                    }

                    Text { text: "Modifiers"; color: "#ffffff" }
                    TextField {
                        text: root.selectedData.modifiers
                        onTextChanged: macroModel.updateAction(root.selectedIndex, { modifiers: parseInt(text) })
                    }

                    Text { text: "Hold (ms)"; color: "#ffffff" }
                    TextField {
                        text: root.selectedData.holdMs
                        onTextChanged: macroModel.updateAction(root.selectedIndex, { holdMs: parseInt(text) })
                    }
                }
            }

            Component {
                id: mouseEditorComponent
                Column {
                    spacing: 8
                    padding: 12

                    Text { text: "X"; color: "#ffffff" }
                    TextField {
                        text: root.selectedData.x
                        onTextChanged: macroModel.updateAction(root.selectedIndex, { x: parseInt(text) })
                    }

                    Text { text: "Y"; color: "#ffffff" }
                    TextField {
                        text: root.selectedData.y
                        onTextChanged: macroModel.updateAction(root.selectedIndex, { y: parseInt(text) })
                    }

                    Text { text: "Hold (ms)"; color: "#ffffff" }
                    TextField {
                        text: root.selectedData.holdMs
                        onTextChanged: macroModel.updateAction(root.selectedIndex, { holdMs: parseInt(text) })
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
