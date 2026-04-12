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
            console.log("save macro")
        }

        onRunRequested: {
            console.log("run macro")
        }
    }
}
