pragma Singleton
import QtQuick 2.12
import "simulation.js" as JS

QtObject {
    id: values

    property string helloText: "Hello!"

    property Timer update: Timer {
        running: true
        repeat: true
        onTriggered: JS.setHelloText()
        interval: 10
    }
}
