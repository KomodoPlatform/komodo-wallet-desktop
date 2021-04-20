import "../Components"

// Modal to display when update file checksum does not match
FatalErrorModal
{
    id: root
    message: qsTr("The downloaded update archive is corrupted !")
}
