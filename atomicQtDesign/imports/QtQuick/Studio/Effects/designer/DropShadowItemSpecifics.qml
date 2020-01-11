import QtQuick 2.0
import HelperWidgets 2.0
import QtQuick.Layouts 1.0


Column {
    anchors.left: parent.left
    anchors.right: parent.right

    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: qsTr("Shadow Color")

        ColorEditor {
            caption: qsTr("Shadow Color")
            backendValue: backendValues.color
            supportGradient: false
        }
    }

    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: "Shadow Details"

        SectionLayout {
            rows: 2
            Label {
                text: qsTr("radius")
                toolTip: qsTr("Radius defines the softness of the shadow. A larger radius causes the edges of the shadow to appear more blurry.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.radius
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: 0
                    maximumValue: 100
                    stepSize: 1
                }
                ExpandingSpacer {
                }
            }

            Label {
                text: qsTr("samples")
                toolTip: qsTr("This property defines how many samples are taken per pixel when edge softening blur calculation is done, ideally, this value should be twice as large as the highest required radius value plus one.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.samples
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: 0
                    maximumValue: 201
                    stepSize: 1
                }
                ExpandingSpacer {
                }
            }

            Label {
                text: qsTr("spread")
                toolTip: qsTr("This property defines how large part of the shadow color is strengthened near the source edges.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.spread
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
        caption: "Offsets"

        SectionLayout {
            rows: 2
            Label {
                text: qsTr("horizontal offset")
                toolTip: qsTr("HorizontalOffset defines the offset for the rendered shadow compared to the DropShadow items horizontal position.")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.horizontalOffset
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: 0
                    maximumValue: 100
                    stepSize: 1
                }
                ExpandingSpacer {
                }
            }

            Label {
                text: qsTr("vertical offset")
                toolTip: qsTr("VerticalOffset defines the offset for the rendered shadow compared to the DropShadow items vertical position. ")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.verticalOffset
                    Layout.preferredWidth: 80
                    decimals: 1
                    minimumValue: 0
                    maximumValue: 100
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
                    backendValue: backendValues.transparentBorder
                    text: backendValues.transparentBorder.valueToString
                }
            }
        }
    }
}
