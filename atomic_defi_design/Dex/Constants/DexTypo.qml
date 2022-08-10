pragma Singleton

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import App 1.0 as App 

QtObject {
    id: _font

    property real fontDensity: 1.0

    property real languageDensity: {
        switch (App.API.app.settings_pg.lang) {
            case "en":
                return 0.99999
            case "fr":
                return 0.99999
            case "tr":
                return 0.99999
            case "ru":
                return 0.99999
            default:
                return 0.99999
        }
    }
    property string fontFamily: "Ubuntu"

    property font head1: Qt.font({
        pixelSize: 96 * fontDensity,
        letterSpacing: -1.5,
        family: fontFamily,
        weight: Font.Light
    })
    property font head2: Qt.font({
        pixelSize: 60 * fontDensity,
        letterSpacing: -0.5,
        family: fontFamily,
        weight: Font.Light
    })
    property font head3: Qt.font({
        pixelSize: 48 * fontDensity,
        letterSpacing: 0,
        family: fontFamily,
        weight: Font.Normal
    })
    property font head4: Qt.font({
        pixelSize: 34 * fontDensity,
        letterSpacing: 0.25,
        family: fontFamily,
        weight: Font.Normal
    })
    property font head5: Qt.font({
        pixelSize: 24 * fontDensity,
        letterSpacing: 0,
        family: fontFamily,
        weight: Font.Normal
    })
    property font head6: Qt.font({
        pixelSize: 20 * fontDensity,
        letterSpacing: 0.15,
        family: fontFamily,
        weight: Font.Medium
    })
    property font head7: Qt.font({
        pixelSize: 18 * fontDensity,
        letterSpacing: 0.15,
        family: fontFamily,
        weight: Font.Medium
    })
    property font head8: Qt.font({
        pixelSize: 16 * fontDensity,
        letterSpacing: 0.15,
        family: fontFamily,
        weight: Font.Medium
    })
    property font subtitle1: Qt.font({
        pixelSize: 16 * fontDensity,
        letterSpacing: 0.15,
        family: fontFamily,
        weight: Font.Normal
    })
    property font subtitle2: Qt.font({
        pixelSize: 14 * fontDensity,
        letterSpacing: 0.1,
        family: fontFamily,
        weight: Font.Medium
    })
    property font body1: Qt.font({
        pixelSize: 16 * fontDensity,
        letterSpacing: 0.5,
        family: fontFamily,
        weight: Font.Normal
    })
    property font body2: Qt.font({
        pixelSize: 14 * fontDensity,
        letterSpacing: 0.25,
        family: fontFamily,
        weight: Font.Normal
    })
    property font button: Qt.font({
        pixelSize: 16 * fontDensity,
        letterSpacing: 1.25,
        family: fontFamily,
        weight: Font.Medium
    })
    property font caption: Qt.font({
        pixelSize: 12 * fontDensity,
        letterSpacing: 0.4,
        family: fontFamily,
        weight: Font.Normal
    })
    property font overLine: Qt.font({
        pixelSize: 10 * fontDensity,
        letterSpacing: 1.25,
        capitalization: Font.AllUppercase,
        family: fontFamily,
        weight: Font.Normal
    })
    property font subtitle3: Qt.font({
        pixelSize: 16 * fontDensity,
        letterSpacing: 0.1,
        family: fontFamily,
        weight: 500
    })
    property font monoSpace: Qt.font({
        pixelSize: 14 * fontDensity,
        letterSpacing: 0,
        family: "Courier",
        weight: Font.Normal
    })
    property font monoSmall: Qt.font({
        pixelSize: 14 * fontDensity,
        letterSpacing: 0.4,
        family: "Courier",
        weight: Font.Normal
    })
}
