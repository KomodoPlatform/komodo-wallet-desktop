import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtWebEngine 1.8
import "../Exchange/Trade/"
import "../Constants/" as Constants

Item {
    anchors.margins: 5
    readonly property string left_ticker: "KMD"
    readonly property string right_ticker: "BTC"
//    component ItemBox: ItemBox {
//        id: _control
//    }
    SplitView {
        anchors.fill: parent
        ItemBox {
            title: "Third Box"
            defaultWidth: 300
            maximumWidth: 400
            closable: false
            expandedHort: true
            color: 'transparent'
            SplitView {
                anchors.fill: parent
                anchors.topMargin: 45
                orientation: Qt.Vertical
                handle: Item {
                    implicitWidth: 10
                    implicitHeight: 10
                    InnerBackground {
                        implicitWidth: 16
                        implicitHeight: 6
                        anchors.centerIn: parent
                        opacity: .4
                    }
                }
                ItemBox {
                    title: "WebView Box"
                    defaultHeight: 200
                    expandedVert: true
                    contentItem: Component {
                        WebEngineView {
                            url: "https://fr.tradingview.com/chart/?symbol=KMD/BTC&theme=dark"
                        }
                    }
                }
                ItemBox {
                    title: "Orderbook Box"
                    defaultHeight: 200
                    DefaultRangeSlider {
                        id: control
                        x: 10
                        y: 60
                    }

                }
                ItemBox {
                    title: "Orders & History Box"
                    defaultHeight: 200
                }
            }
        }
        ItemBox {
            title: "OrderBook Box"
            defaultHeight: 350
            minimumWidth: 350




        }
        ItemBox {
            title: "Form Box"
            defaultHeight: 250
        }
        handle: Item {
            implicitWidth: 10
            implicitHeight: 10
            InnerBackground {
                implicitWidth: 6
                implicitHeight: 16
                anchors.centerIn: parent
                opacity: .4
            }
        }

    }


}
