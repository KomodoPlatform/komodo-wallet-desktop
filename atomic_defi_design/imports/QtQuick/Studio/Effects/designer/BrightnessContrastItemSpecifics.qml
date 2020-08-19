import QtQuick 2.0
import HelperWidgets 2.0
import QtQuick.Layouts 1.0


Column {
    anchors.left: parent.left
    anchors.right: parent.right

    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: "Brightness and Contrast"

        SectionLayout {
            rows: 2
            Label {
                text: qsTr("brightness")
                toolTip: qsTr("This property defines how much the source brightness is increased or decreased.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.brightness
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: -1
                    maximumValue: 1
                    stepSize: 0.1
                }
                ExpandingSpacer {
                }
            }

            Label {
                text: qsTr("contrast")
                toolTip: qsTr("This property defines how much the source contrast is increased or decreased. The decrease of the contrast is linear, but the increase is applied with a non-linear curve to allow very high contrast adjustment at the high end of the value range.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.contrast
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: -1
                    maximumValue: 1
                    stepSize: 0.1
                }
                ExpandingSpacer {
                }
            }
        }
    }

    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: "Caching"

        SectionLayout {
            rows: 2
            Label {
                text: qsTr("cached")
                toolTip: qsTr("This property allows the effect output pixels to be cached in order to improve the rendering performance.")
            }
            SecondColumnLayout {
                CheckBox {
                    Layout.fillWidth: true
                    backendValue: backendValues.cached
                    text: backendValues.cached.valueToString
                }
            }
        }
    }
}
