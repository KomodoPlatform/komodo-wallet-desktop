import "../../../Components"
import "../../../Constants"

MultipageModal
{
    id: root
    width: 1000
    MultipageModalContent
    {
        titleText: qsTr("Selected Order Removed")

        DefaultText
        {
            text: qsTr("The selected order does not exist anymore, it might have been matched or canceled, and no order with a better price is available.\nPlease select a new order.")
        }

        footer:
        [
            DefaultButton
            {
                text: qsTr("OK")
                onClicked: close()
            }
        ]
    }

}
