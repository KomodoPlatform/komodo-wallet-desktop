import QtQuick 2.0
import HelperWidgets 2.0
import QtQuick.Layouts 1.0

ComboBox {
    model: ["FlatCap", "SquareCap", "RoundCap"]
    backendValue: backendValues.capStyle
    Layout.fillWidth: true
    useInteger: true

    manualMapping: true

    property bool block: false

    onValueFromBackendChanged: {
        if (!__isCompleted)
            return

        block = true

        if (backendValues.capStyle.value === 0)
            currentIndex = 0
        if (backendValues.capStyle.value === 16)
            currentIndex = 1
        if (backendValues.capStyle.value === 32)
            currentIndex = 2

        block = false
    }

    onCurrentTextChanged: {
        if (!__isCompleted)
            return

        if (block)
            return

        if (currentText === "FlatCap")
            backendValues.capStyle.value = 0

        if (currentText === "SquareCap")
            backendValues.capStyle.value = 16

        if (currentText === "RoundCap")
            backendValues.capStyle.value = 32
    }
}
