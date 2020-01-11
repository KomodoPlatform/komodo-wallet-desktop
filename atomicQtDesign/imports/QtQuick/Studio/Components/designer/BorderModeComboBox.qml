import QtQuick 2.0
import HelperWidgets 2.0
import QtQuick.Layouts 1.0

ComboBox {
    model: ["Inside", "Middle", "Outside"]
    backendValue: backendValues.borderMode
    Layout.fillWidth: true
    useInteger: true

    manualMapping: true

    property bool block: false

    onValueFromBackendChanged: {
        if (!__isCompleted)
            return

        block = true

        if (backendValues.borderMode.value === 0)
            currentIndex = 0
        if (backendValues.borderMode.value === 1)
            currentIndex = 1
        if (backendValues.borderMode.value === 2)
            currentIndex = 2

        block = false
    }

    onCurrentTextChanged: {
        if (!__isCompleted)
            return

        if (block)
            return

        if (currentText === "Inside")
            backendValues.borderMode.value = 0

        if (currentText === "Middle")
            backendValues.borderMode.value = 1

        if (currentText === "Outside")
            backendValues.borderMode.value = 2
    }
}
