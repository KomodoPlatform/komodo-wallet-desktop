import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

// Price
DefaultText {
    Layout.alignment: Qt.AlignHCenter
    text: API.get().empty_string + (!hasValidPrice() ? '' : (preffered_price === empty_price ? qsTr("Price") + ": " + General.formatDouble(getCalculatedPrice()) :
                                            qsTr("Selected Price") + ": " + General.formatDouble(preffered_price)) + " " + getTicker(false))
}
