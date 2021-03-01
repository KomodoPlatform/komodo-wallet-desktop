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
                    RangeSlider {
                        y: 60
                        x: 10
                        id: control
                        //value: 0.5
//                        from: 0
//                        to: 100
                        opacity: enabled? 1 : .5
                        first.value: 0.25
                        second.value: .75

                        background: Rectangle {
                            x: control.leftPadding
                            y: control.topPadding + control.availableHeight / 2 - height / 2
                            implicitWidth: 200
                            implicitHeight: 4
                            width: control.availableWidth
                            height: implicitHeight
                            radius: 2
                            color: "#bdbebf"

                            Rectangle {
                                x: control.first.visualPosition * parent.width
                                width: control.second.visualPosition * parent.width - x
                                height: parent.height
                                color: Style.colorGreen
                                radius: 2
                            }
                        }

                        first.handle: FloatingBackground {
                            x: control.leftPadding + control.first.visualPosition * (control.availableWidth - width)
                           y: control.topPadding + control.availableHeight / 2 - height / 2
                           implicitWidth: 26
                           implicitHeight: 26
                           radius: 13
                            Rectangle {
                                anchors.centerIn: parent
                                width: 10
                                height: 10
                                radius: 10
                                color: Style.colorGreen
                            }

                            //border.color: "#bdbebf"
                        }
                        second.handle: FloatingBackground {
                            x: control.leftPadding + control.second.visualPosition * (control.availableWidth - width)
                           y: control.topPadding + control.availableHeight / 2 - height / 2
                           implicitWidth: 26
                           implicitHeight: 26
                           radius: 13
                            Rectangle {
                                anchors.centerIn: parent
                                width: 10
                                height: 10
                                radius: 10
                                color: Style.colorGreen
                            }

                            //border.color: "#bdbebf"
                        }
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
