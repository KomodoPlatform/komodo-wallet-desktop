import QtQuick 2.0
import HelperWidgets 2.0
import QtQuick.Layouts 1.0


Column {
    anchors.left: parent.left
    anchors.right: parent.right

    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: "Directional Blur Details"

        SectionLayout {
            rows: 2
            Label {
                text: qsTr("blur angle")
                toolTip: qsTr("This property defines the direction for the blur. Blur is applied to both sides of each pixel, therefore setting the direction to 0 and 180 produces the same result.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.directionalBlurAngle
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: -180
                    maximumValue: 180
                    stepSize: 1
                }
                ExpandingSpacer {
                }
            }

            Label {
                text: qsTr("blur samples")
                toolTip: qsTr("This property defines how many samples are taken per pixel when blur calculation is done. Larger value produces better quality, but is slower to render.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.directionalBlurSamples
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: 0
                    maximumValue: 1000
                    stepSize: 1
                }
                ExpandingSpacer {
                }
            }

            Label {
                text: qsTr("blur length")
                toolTip: qsTr("This property defines the perceived amount of movement for each pixel. The movement is divided evenly to both sides of each pixel.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.directionalBlurLength
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: 0
                    maximumValue: 1000
                    stepSize: 1
                }
                ExpandingSpacer {
                }
            }
        }
    }


    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: "Caching and Border"

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
                ExpandingSpacer {
                }
            }
            Label {
                text: qsTr("transparent border")
                toolTip: qsTr("When set to true, the exterior of the item is padded with a transparent edge, making sampling outside the source texture use transparency instead of the edge pixels.")
            }
            SecondColumnLayout {
                CheckBox {
                    Layout.fillWidth: true
                    backendValue: backendValues.directionalBlurBorder
                    text: backendValues.directionalBlurBorder.valueToString
                }
            }
        }
    }
}
