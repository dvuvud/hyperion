import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#0a1628"

    ListView {
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
        width: parent.width

        model: MacroListModel {
            id: macroModel
        }

        delegate: MacroItem {
            width: ListView.view.width
            title: actionLabel
            type: actionType

            onClicked: {
                console.log("Clicked item:", index)
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
            console.log("run macro")
        }

        onTextEdited: (text) => {
            macroModel.macroName = text
        }
    }
}
