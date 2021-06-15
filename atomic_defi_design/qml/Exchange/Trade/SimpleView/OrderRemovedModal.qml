import "../../../Components"
import "../../../Constants"

BasicModal
{
    id: root
    width: 1000
    ModalContent
    {
        title: qsTr("Selected Order Removed")

        DefaultText
        {
            text: qsTr("The selected order does not exist anymore, it might have been matched or canceled, and no order with a better price is available. Please select a new order.")
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
