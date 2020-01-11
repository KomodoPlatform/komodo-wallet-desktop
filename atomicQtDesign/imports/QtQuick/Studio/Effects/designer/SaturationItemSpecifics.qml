import QtQuick 2.0
import HelperWidgets 2.0
import QtQuick.Layouts 1.0


Column {
    anchors.left: parent.left
    anchors.right: parent.right

    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: "Desaturation"

        SectionLayout {
            rows: 2
            Label {
                text: qsTr("desaturation")
                toolTip: qsTr("This property defines how much the source colors are desaturated.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.desaturation
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
