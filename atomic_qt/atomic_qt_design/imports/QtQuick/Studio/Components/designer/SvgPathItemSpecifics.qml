import QtQuick 2.0
import HelperWidgets 2.0
import QtQuick.Layouts 1.0


Column {
    anchors.left: parent.left
    anchors.right: parent.right

    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: qsTr("Fill Color")

        ColorEditor {
            caption: qsTr("Fill Color")
            backendValue: backendValues.fillColor
            supportGradient: true
            shapeGradients: true
        }


    }

    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: qsTr("Stroke Color")

        ColorEditor {
            caption: qsTr("Stroke Color")
            backendValue: backendValues.strokeColor
            supportGradient: false
        }
    }


    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: "Stroke Details"

        SectionLayout {
            rows: 2
            Label {
                text: qsTr("Stroke Width")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.strokeWidth
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: 0
                    maximumValue: 10000
                    stepSize: 1
                }
                ExpandingSpacer {

                }
            }


            Label {
                text: qsTr("Stroke Style")
            }

            SecondColumnLayout {
                ComboBox {
                    model: ["None", "Solid", "Dash", "Dot", "Dash Dot", "Dash Dot Dot"]
                    backendValue: backendValues.strokeStyle
                    Layout.fillWidth: true
                    useInteger: true
                }

            }

            Label {
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                text: qsTr("Dash Pattern")
            }

            DashPatternEditor {
                enableEditors: strokeStyle.currentIndex === 2
            }

            Label {
                text: qsTr("Joint Style")
            }

            SecondColumnLayout {
                ComboBox {
                    model: ["Miter Join", "Bevel Join", "Round Join"]
                    backendValue: backendValues.joinStyle
                    Layout.fillWidth: true
                    useInteger: true
                }

            }

            Label {
                text: qsTr("Cap Style")
            }

            SecondColumnLayout {
                CapComboBox {
                }
            }

            Label {
                text: qsTr("Anti Aliasing")
            }
            SecondColumnLayout {
                CheckBox {
                    backendValue: backendValues.antialiasing
                    text: qsTr("Anti Aliasing")
                }
                ExpandingSpacer {

                }
            }

        }
    }

    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: qsTr("Path Info")

        SectionLayout {
            rows: 1

            Label {
                text: qsTr("Path Data")
            }
            SecondColumnLayout{

                LineEdit {
                    Layout.fillWidth: true
                    backendValue: backendValues.path
                }
            }
        }
    }
}
