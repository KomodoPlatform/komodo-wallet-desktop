import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

Item {
    id: exchange_trade

    height: 500

    function convertToFullName(coins) {
        return coins.map(c => c.name + " (" + c.ticker + ")")
    }

    function baseCoins() {
        return API.get().enabled_coins
    }

    function relCoins() {
        return API.get().enabled_coins.filter(c => c.ticker !== base)
    }

    property string base
    property string rel

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter

        width: 1000
        height: parent.height
        spacing: 20

        // Select coins row
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height

            color: Style.colorTheme7
            radius: Style.rectangleCornerRadius

            RowLayout {
                // Base
                ComboBox {
                    id: combo_base
                    Layout.preferredWidth: 250
                    Layout.leftMargin: 15
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10

                    model: convertToFullName(baseCoins())
                    onCurrentTextChanged: base = baseCoins()[currentIndex].ticker
                }

                Image {
                    source: General.image_path + "exchange-exchange.svg"
                }

                // Rel Base
                ComboBox {
                    id: combo_rel
                    Layout.preferredWidth: 250
                    Layout.rightMargin: 15

                    model: convertToFullName(relCoins())
                    onCurrentTextChanged: rel = relCoins()[currentIndex].ticker
                }
            }
        }

        // Bottom part
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Left side
            Rectangle {
                color: Style.colorTheme7
                radius: Style.rectangleCornerRadius
                Layout.preferredWidth: 300
                Layout.fillHeight: true

                DefaultText {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Rel: " + rel
                }
            }

            // Right side
            Rectangle {
                color: Style.colorTheme7
                radius: Style.rectangleCornerRadius
                Layout.fillWidth: true
                Layout.fillHeight: true

                DefaultText {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Base: " + base
                }
            }
        }
    }
}









