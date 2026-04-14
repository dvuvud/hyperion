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
                    if (root.selectedIndex === index)
                        root.selectedIndex = -1
                    else
                        root.selectedIndex = index

                    root.selectedData = actionData
                    root.selectedType = actionType
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
            console.log("run macro")
        }

        onTextEdited: (text) => {
            macroModel.macroName = text
        }
    }
}
