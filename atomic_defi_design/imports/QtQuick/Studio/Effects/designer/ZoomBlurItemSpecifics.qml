import QtQuick 2.0
import HelperWidgets 2.0
import QtQuick.Layouts 1.0


Column {
    anchors.left: parent.left
    anchors.right: parent.right


    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: "Blur Details"

        SectionLayout {
            rows: 2
            Label {
                text: qsTr("length")
                toolTip: qsTr("This property defines the maximum perceived amount of movement for each pixel. The amount is smaller near the center and reaches the specified value at the edges.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.zoomBlurLength
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: -1000
                    maximumValue: 1000
                    stepSize: 1
                }
                ExpandingSpacer {
                }
            }

            Label {
                text: qsTr("samples")
                toolTip: qsTr("This property defines how many samples are taken per pixel when blur calculation is done. Larger value produces better quality, but is slower to render.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.zoomBlurSamples
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: 0
                    maximumValue: 200
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
        caption: "Offsets"

        SectionLayout {
            rows: 2
            Label {
                text: qsTr("horizontal offset")
                toolTip: qsTr("These properties define the offset in pixels for the perceived center point of the rotation.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.zoomBlurHoffset
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: -1000
                    maximumValue: 1000
                    stepSize: 1
                }
                ExpandingSpacer {
                }
            }

            Label {
                text: qsTr("vertical offset")
                toolTip: qsTr("These properties define an offset in pixels for the blur direction center point.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.zoomBlurVoffset
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: -1000
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
                toolTip: qsTr("This property defines the blur behavior near the edges of the item, where the pixel blurring is affected by the pixels outside the source edges. If the property is set to true, the pixels outside the source are interpreted to be transparent, which is similar to OpenGL clamp-to-border extension. The blur is expanded slightly outside the effect item area.")
            }
            SecondColumnLayout {
                CheckBox {
                    Layout.fillWidth: true
                    backendValue: backendValues.transparentBorder
                    text: backendValues.transparentBorder.valueToString
                }
            }
        }
    }
}
