import QtQuick 2.0
import HelperWidgets 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0 as Controls
import QtQuickDesignerTheme 1.0

GridLayout {
    id: root
    Layout.fillWidth: true
    rowSpacing: 2
    columnSpacing: 6
    rows: 2
    columns: 5
    property bool enableEditors: true

    property variant backendValue: backendValues.dashPattern

    property string expression: backendValue.expression

    onExpressionChanged: root.parseExpression()

    property bool __block: false

    function createArray() {
        if (root.__block)
            return

        var array = []

        array.push(dash01.value)
        array.push(gap01.value)
        array.push(dash02.value)
        array.push(gap02.value)
        root.__block = true
        root.backendValue.expression = '[' + array.toString() + ']'
        root.__block = false
    }

    function parseExpression() {
        if (root.__block)
            return

        dash01.value = 0
        gap01.value = 0
        dash02.value = 0
        gap02.value = 0
        var array = backendValue.expression.toString()
        array = array.replace("[", "")
        array = array.replace("]", "")
        array = array.split(',')

        root.__block = true
        try {
            dash01.value = array[0]
            gap01.value = array[1]
            dash02.value = array[2]
            gap02.value = array[3]
        } catch (err) {

        }

        root.__block = false
    }

    Connections {
        target: modelNodeBackend
        onSelectionChanged: parseExpression()
    }

    Item {
        width: 32
        ExtendedFunctionButton {
            x: 4
            anchors.verticalCenter: parent.verticalCenter
            backendValue: root.backendValue
        }
    }

    Controls.Label {
        text: qsTr("Dash")
        color: Theme.color(Theme.PanelTextColorLight)
        elide: Text.ElideRight
    }

    DoubleSpinBox {
        id: dash01

        enabled: root.enableEditors
        property color textColor: colorLogic.textColor
        ColorLogic {
            id: colorLogic
            backendValue: backendValues.dashPattern
        }
        onValueChanged: root.createArray()
        maximumValue: 1000
    }

    Controls.Label {
        text: qsTr("Gap")
        color: Theme.color(Theme.PanelTextColorLight)
        elide: Text.ElideRight
    }

    DoubleSpinBox {
        id: gap01

        enabled: root.enableEditors
        property color textColor: colorLogic.textColor

        onValueChanged: root.createArray()
        maximumValue: 1000
    }

    Item {
        width: 32
    }

    Controls.Label {
        text: qsTr("Dash")
        color: Theme.color(Theme.PanelTextColorLight)
        elide: Text.ElideRight
    }

    DoubleSpinBox {
        id: dash02

        enabled: root.enableEditors
        property color textColor: colorLogic.textColor

        onValueChanged: root.createArray()
        maximumValue: 1000
    }

    Controls.Label {
        text: qsTr("Gap")
        color: Theme.color(Theme.PanelTextColorLight)
        elide: Text.ElideRight
    }

    DoubleSpinBox {
        id: gap02

        enabled: root.enableEditors
        property color textColor: colorLogic.textColor

        onValueChanged: root.createArray()
        maximumValue: 1000
    }
}
