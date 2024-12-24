import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtWebEngine 1.8

import QtGraphicalEffects 1.0

import "../Exchange/Trade/"
import "../Constants/" as Constants

Item {
    anchors.margins: 5
    readonly property string left_ticker: atomic_app_primary_coin
    readonly property string right_ticker: atomic_app_secondary_coin

    DefaultSplitView {
        anchors.fill: parent
        ItemBox {
            id: box1
            title: "Third Box"
            defaultWidth: 300
            closable: false

            expandedHort: true
            color: 'transparent'

            DefaultSplitView {
                visible: parent.contentVisible
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
                    id: bBox1
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
                    id: bBox2
                    title: "Orderbook Box"
                    defaultHeight: 200
                    DefaultRangeSlider {
                        visible: parent.contentVisible
                        id: control
                        x: 10
                        y: 60
                        smooth: true
                    }
                    FastBlur {
                        anchors.fill: bBox2
                        source: bBox2
                        radius: 32
                        DexLabel {
                            anchors.centerIn: parent
                            text: "Jemm"
                        }
                    }

                }
                ItemBox {
                    id: bBox3
                    title: "Orders & History Box"
                    defaultHeight: 200
                }
            }
        }
        ItemBox {
            id: box2
            title: "OrderBook Box"
            defaultHeight: 350
            defaultWidth: 400
            minimumWidth: 350
        }

        ItemBox {
            id: box3
            title: "Form Box"
            defaultHeight: 250
            maximumHeight: 250
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
