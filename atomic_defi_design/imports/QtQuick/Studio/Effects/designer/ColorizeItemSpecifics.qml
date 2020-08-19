import QtQuick 2.0
import HelperWidgets 2.0
import QtQuick.Layouts 1.0


Column {
    anchors.left: parent.left
    anchors.right: parent.right

    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: "Colorize"

        SectionLayout {
            rows: 2
            Label {
                text: qsTr("hue")
                toolTip: qsTr("This property defines the hue value which is used to colorize the source.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.colorizeHue
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: 0
                    maximumValue: 1
                    stepSize: 0.1
                }
                ExpandingSpacer {
                }
            }

            Label {
                text: qsTr("lightness")
                toolTip: qsTr("This property defines how much the source lightness value is increased or decreased. Unlike hue and saturation properties, lightness does not set the used value, but it shifts the existing source pixel lightness value.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.colorizeLightness
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
                text: qsTr("saturation")
                toolTip: qsTr("This property defines the saturation value which is used to colorize the source.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.colorizeSaturation
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: 0
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
