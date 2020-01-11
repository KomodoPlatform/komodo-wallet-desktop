import QtQuick 2.0
import HelperWidgets 2.0
import QtQuick.Layouts 1.0


Column {
    anchors.left: parent.left
    anchors.right: parent.right

    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: qsTr("Flipped Status")

        SectionLayout {
            rows: 2
            Label {
                text: qsTr("Flip Angle")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.flipAngle
                    Layout.preferredWidth: 80
                    minimumValue: -360
                    maximumValue: 360
                    stepSize: 10
                }
                ExpandingSpacer {

                }
            }
        }
    }

    Section {
        anchors.left: parent.left
        anchors.right: parent.right
        caption: "Opacity"

        SectionLayout {
            rows: 2
            Label {
                text: qsTr("Opacity Front")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.opacityFront
                    Layout.preferredWidth: 80
                    decimals: 2
                    minimumValue: 0
                    maximumValue: 1
                    stepSize: 0.1
                }
                ExpandingSpacer {
                }
            }
            Label {
                text: qsTr("Opacity Back")
            }
            SecondColumnLayout {
                SpinBox {
                    backendValue: backendValues.opacityBack
                    Layout.preferredWidth: 80
                    decimals: 2
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
        caption: "Rotational Axis"

        SectionLayout {
            rows: 2
            Label {
                text: qsTr("X Rotational Axis")
            }

            SecondColumnLayout {
                ComboBox {
                    model: ["X Axis", "Y Axis"]
                    backendValue: backendValues.xAxis
                    Layout.fillWidth: true
                    useInteger: true
                }
            }

            Label {
                text: qsTr("Y Rotational Axis")
            }

            SecondColumnLayout {
                ComboBox {
                    model: ["X Axis", "Y Axis"]
                    backendValue: backendValues.yAxis
                    Layout.fillWidth: true
                    useInteger: true
                }
            }
        }
    }
}
