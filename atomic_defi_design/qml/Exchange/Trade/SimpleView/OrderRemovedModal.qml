import "../../../Components"
import "../../../Constants"

BasicModal
{
    id: root
    width: 800
    ModalContent
    {
        title: qsTr("Selected Order Removed")

        DefaultText
        {
            text: qsTr("The selected order does not exist anymore. It might have been matched or canceled. Please select a new order.")
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
    onClosed: API.app.trading_pg.clear_forms()
}
