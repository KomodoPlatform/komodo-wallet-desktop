import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"

// Price
RowLayout {
    readonly property double price: !orderIsSelected() ? getCalculatedPrice() : preffered_order.price
    readonly property double expedient : 100 * (1 - parseFloat(price) / parseFloat(cex_price))

    readonly property int fontSize: Style.textSizeSmall2
    readonly property int fontSizeBigger: Style.textSizeSmall4
    readonly property int line_scale: 10

    readonly property bool price_entered: hasValidPrice()

    function limitDigits(value) {
        return parseFloat(value.toFixed(2))
    }

    spacing: 100

    ColumnLayout {
        visible: price_entered

        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + (qsTr("Exchange rate") + (orderIsSelected() ? (" (" + qsTr("Selected") + ")") : ""))
            font.pixelSize: fontSize
        }

        // Price
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + ("1 " + getTicker(true) + " = " + General.formatCrypto("", price, getTicker(false)))
            font.pixelSize: fontSizeBigger
            font.bold: true
        }

        // Price reversed
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + ("1 " + getTicker(false) + " = " + General.formatCrypto("", General.formatDouble(1 / parseFloat(price)), getTicker(true)))
            font.pixelSize: fontSize
        }
    }


    // Expedient
    ColumnLayout {
        visible: price_entered

        DefaultText {
            id: expedient_text
            Layout.topMargin: 10
            Layout.bottomMargin: Layout.topMargin
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + (qsTr("Expedient") + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + qsTr("%1 compared to CEX", "EXPEDIENT").arg("<b>" + General.formatPercent(limitDigits(expedient)) + "</b>"))
            font.pixelSize: fontSize
        }

        RowLayout {
            DefaultText {
                text_value: API.get().empty_string + (General.formatPercent(limitDigits(Math.min(-line_scale, expedient))))
                font.pixelSize: fontSize
            }

            Rectangle {
                id: expedient_line
                width: 200
                height: 6

                DefaultGradient {
                    anchors.fill: parent
                    anchors.margins: 0
                    start_color: Style.colorGreen
                    end_color: Style.colorBlue
                }

                Rectangle {
                    id: vertical_line
                    width: 4
                    height: expedient_line.height * 2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 0.5 * expedient_line.width * Math.min(Math.max(expedient / line_scale, -1), 1)
                }
            }

            DefaultText {
                text_value: API.get().empty_string + (General.formatPercent(limitDigits(Math.max(line_scale, expedient))))
                font.pixelSize: fontSize
            }
        }
    }





    // CEXchange
    ColumnLayout {
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + (General.cex_icon + " " + qsTr("CEXchange rate"))
            font.pixelSize: fontSize

            CexInfoTrigger {}
        }

        // Price
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + ("1 " + getTicker(true) + " = " + General.formatCrypto("", cex_price, getTicker(false)))
            font.pixelSize: fontSizeBigger
            font.bold: true
        }

        // Price reversed
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + ("1 " + getTicker(false) + " = " + General.formatCrypto("", General.formatDouble(1 / parseFloat(cex_price)), getTicker(true)))
            font.pixelSize: fontSize
        }
    }
}
