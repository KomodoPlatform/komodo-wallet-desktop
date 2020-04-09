import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"
import ".."

DefaultModal {
    id: root

    width: 900

    onClosed: {
        accept_eula.checked = false
        accept_tac.checked = false
    }

    property var onConfirm: () => {}
    property bool close_only: false

    // Inside modal
    ColumnLayout {
        id: modal_layout

        width: parent.width

        ModalHeader {
            title: API.get().empty_string + (qsTr("Disclaimer and ToS"))
        }


        Rectangle {
            id: eula_rect
            color: Style.colorTheme7
            radius: Style.rectangleCornerRadius
            height: 400
            Layout.fillWidth: true
            Flickable {
                ScrollBar.vertical: ScrollBar { }

                anchors.fill: parent
                anchors.margins: 20

                clip: true
                contentWidth: eula_text.width
                contentHeight: eula_text.height

                DefaultText {
                    id: eula_text
                    text: API.get().empty_string + (getEula())

                    width: eula_rect.width - 40
                }
            }
        }

        // Checkboxes
        CheckBox {
            id: accept_eula
            visible: !close_only
            text: API.get().empty_string + (qsTr("Accept EULA"))
        }

        CheckBox {
            id: accept_tac
            visible: !close_only
            text: API.get().empty_string + (qsTr("Accept Terms and Conditions"))
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().empty_string + (close_only ? qsTr("Close") : qsTr("Cancel"))
                Layout.fillWidth: true
                onClicked: root.close()
            }

            PrimaryButton {
                visible: !close_only
                text: API.get().empty_string + (qsTr("Confirm"))
                Layout.fillWidth: true
                enabled: accept_eula.checked && accept_tac.checked
                onClicked: {
                    onConfirm()
                    root.close()
                }
            }
        }
    }

    function getEula() {
        return qsTr(
"<h2>Lorem ipsum dolor sit amet</h2>

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Sagittis eu volutpat odio facilisis mauris sit amet massa vitae. Neque ornare aenean euismod elementum nisi quis eleifend. Sed risus ultricies tristique nulla aliquet. Viverra maecenas accumsan lacus vel facilisis volutpat est. Ultrices sagittis orci a scelerisque purus semper eget. Tortor id aliquet lectus proin. Elit scelerisque mauris pellentesque pulvinar pellentesque habitant morbi tristique. Vestibulum rhoncus est pellentesque elit ullamcorper. Scelerisque fermentum dui faucibus in. Facilisi nullam vehicula ipsum a arcu. Elementum facilisis leo vel fringilla est. Porttitor eget dolor morbi non arcu risus quis. Scelerisque fermentum dui faucibus in ornare quam.

Aliquam sem fringilla ut morbi tincidunt augue. Elit sed vulputate mi sit. In cursus turpis massa tincidunt dui ut ornare. Elit sed vulputate mi sit. Duis convallis convallis tellus id interdum velit. Massa id neque aliquam vestibulum morbi blandit. Varius morbi enim nunc faucibus a pellentesque sit. Id eu nisl nunc mi ipsum faucibus vitae. Id eu nisl nunc mi ipsum faucibus. Tempus iaculis urna id volutpat lacus laoreet. Eget duis at tellus at urna condimentum mattis pellentesque. Curabitur gravida arcu ac tortor dignissim convallis aenean et tortor. Sed lectus vestibulum mattis ullamcorper velit sed. In nisl nisi scelerisque eu ultrices vitae auctor eu. Lobortis feugiat vivamus at augue eget. Eleifend donec pretium vulputate sapien nec sagittis aliquam malesuada bibendum.

Imperdiet sed euismod nisi porta lorem mollis aliquam ut porttitor. Egestas diam in arcu cursus. Eros in cursus turpis massa tincidunt dui ut ornare lectus. Maecenas accumsan lacus vel facilisis volutpat est velit. Vestibulum lectus mauris ultrices eros in cursus. Cursus eget nunc scelerisque viverra. Quis vel eros donec ac odio tempor orci dapibus. Nibh ipsum consequat nisl vel pretium lectus quam id. Arcu risus quis varius quam quisque id diam vel. Odio ut sem nulla pharetra. Consectetur adipiscing elit duis tristique sollicitudin nibh sit amet commodo. Elementum pulvinar etiam non quam lacus suspendisse faucibus interdum. Cras fermentum odio eu feugiat pretium. Diam in arcu cursus euismod quis viverra. Commodo elit at imperdiet dui accumsan sit amet nulla. Lobortis feugiat vivamus at augue eget arcu dictum varius. Lorem donec massa sapien faucibus et molestie ac feugiat sed. Vitae proin sagittis nisl rhoncus mattis rhoncus urna neque viverra. Ut morbi tincidunt augue interdum velit euismod in pellentesque.

Nisl tincidunt eget nullam non nisi. Facilisis volutpat est velit egestas. Volutpat odio facilisis mauris sit. Urna et pharetra pharetra massa. Nisi quis eleifend quam adipiscing vitae. Eget arcu dictum varius duis. Justo nec ultrices dui sapien eget. Tortor at risus viverra adipiscing at. Nibh sit amet commodo nulla. Elit at imperdiet dui accumsan sit amet nulla facilisi morbi. Senectus et netus et malesuada fames ac turpis egestas. Auctor neque vitae tempus quam pellentesque nec nam aliquam. A diam maecenas sed enim ut sem viverra. Rhoncus est pellentesque elit ullamcorper dignissim cras tincidunt lobortis feugiat. Non diam phasellus vestibulum lorem sed risus. Nulla pellentesque dignissim enim sit amet venenatis urna.

Condimentum vitae sapien pellentesque habitant. Vitae elementum curabitur vitae nunc sed velit dignissim. Donec ultrices tincidunt arcu non. Nisi scelerisque eu ultrices vitae auctor eu augue. Ipsum faucibus vitae aliquet nec. Purus viverra accumsan in nisl nisi scelerisque. Nisl nisi scelerisque eu ultrices. At imperdiet dui accumsan sit. Et netus et malesuada fames ac turpis egestas. Vel facilisis volutpat est velit egestas dui id ornare. Ultrices vitae auctor eu augue. Id neque aliquam vestibulum morbi blandit cursus risus at. Odio facilisis mauris sit amet massa vitae. Nec ullamcorper sit amet risus nullam eget felis. A iaculis at erat pellentesque adipiscing commodo. Arcu odio ut sem nulla pharetra diam. Fames ac turpis egestas sed tempus urna et pharetra. A cras semper auctor neque vitae. Et tortor consequat id porta nibh venenatis cras sed. Lorem ipsum dolor sit amet.

Diam volutpat commodo sed egestas. Ut etiam sit amet nisl. Elementum nisi quis eleifend quam adipiscing. Neque aliquam vestibulum morbi blandit cursus risus. A diam sollicitudin tempor id eu nisl. Ultrices tincidunt arcu non sodales neque sodales ut. Proin libero nunc consequat interdum. Suspendisse potenti nullam ac tortor vitae purus. Et tortor consequat id porta nibh venenatis cras sed felis. Pellentesque habitant morbi tristique senectus et netus. Suscipit adipiscing bibendum est ultricies. Viverra vitae congue eu consequat ac felis donec et.

Egestas erat imperdiet sed euismod nisi porta. Vestibulum sed arcu non odio euismod lacinia at. Odio tempor orci dapibus ultrices in. Ullamcorper sit amet risus nullam eget felis eget nunc lobortis. Amet consectetur adipiscing elit duis tristique. Egestas dui id ornare arcu odio ut sem nulla pharetra. Elementum nisi quis eleifend quam. Mi in nulla posuere sollicitudin aliquam. In fermentum et sollicitudin ac. Adipiscing diam donec adipiscing tristique risus nec. Senectus et netus et malesuada fames ac turpis egestas. Duis at consectetur lorem donec massa sapien faucibus et. Est lorem ipsum dolor sit amet. Mi sit amet mauris commodo quis imperdiet massa tincidunt. Nunc sed augue lacus viverra vitae congue eu consequat. Interdum velit euismod in pellentesque massa placerat duis. Hendrerit gravida rutrum quisque non. Sed nisi lacus sed viverra tellus. Gravida quis blandit turpis cursus.

Mattis rhoncus urna neque viverra justo nec ultrices dui sapien. Et netus et malesuada fames ac. Proin libero nunc consequat interdum varius sit amet mattis vulputate. Curabitur vitae nunc sed velit dignissim sodales ut. Aliquam ultrices sagittis orci a scelerisque purus semper. Tempus quam pellentesque nec nam aliquam sem et tortor. Quisque sagittis purus sit amet volutpat consequat. Dolor morbi non arcu risus quis varius quam quisque. At ultrices mi tempus imperdiet nulla malesuada pellentesque elit. Vitae elementum curabitur vitae nunc. Dui nunc mattis enim ut tellus. Mauris vitae ultricies leo integer. Ut aliquam purus sit amet. Sit amet mattis vulputate enim nulla aliquet. Facilisis sed odio morbi quis commodo. Eu scelerisque felis imperdiet proin fermentum leo vel orci porta. Egestas quis ipsum suspendisse ultrices gravida dictum fusce ut placerat. Quisque id diam vel quam elementum pulvinar. Cras sed felis eget velit aliquet sagittis. Risus nec feugiat in fermentum posuere urna nec tincidunt.

Odio eu feugiat pretium nibh ipsum consequat nisl. Netus et malesuada fames ac turpis egestas integer eget aliquet. Pellentesque id nibh tortor id aliquet lectus proin nibh nisl. Maecenas ultricies mi eget mauris pharetra et ultrices neque. Amet aliquam id diam maecenas ultricies. Tortor posuere ac ut consequat. Id interdum velit laoreet id donec ultrices tincidunt. Lectus mauris ultrices eros in cursus. Maecenas volutpat blandit aliquam etiam erat velit scelerisque. Duis tristique sollicitudin nibh sit amet commodo nulla facilisi. Gravida cum sociis natoque penatibus et magnis. Egestas sed sed risus pretium quam vulputate. Donec ac odio tempor orci dapibus ultrices in. In hendrerit gravida rutrum quisque. Placerat orci nulla pellentesque dignissim enim sit amet. Risus quis varius quam quisque id diam. Faucibus et molestie ac feugiat sed. Ultricies tristique nulla aliquet enim. Mi bibendum neque egestas congue quisque egestas diam in.

Quis hendrerit dolor magna eget est lorem. Quis risus sed vulputate odio. Massa id neque aliquam vestibulum morbi blandit cursus risus. Id ornare arcu odio ut. Elit scelerisque mauris pellentesque pulvinar pellentesque. Pharetra magna ac placerat vestibulum lectus. Turpis massa tincidunt dui ut ornare. Scelerisque eleifend donec pretium vulputate sapien. Vitae et leo duis ut diam quam nulla. Lobortis mattis aliquam faucibus purus in massa tempor. Blandit aliquam etiam erat velit scelerisque in dictum non. Nullam ac tortor vitae purus. Proin nibh nisl condimentum id venenatis a condimentum vitae sapien. Volutpat lacus laoreet non curabitur gravida arcu ac tortor. Ut sem viverra aliquet eget. Et egestas quis ipsum suspendisse ultrices. Lectus magna fringilla urna porttitor rhoncus dolor purus non enim. Enim tortor at auctor urna nunc id. Sagittis vitae et leo duis ut diam quam nulla."
)
    }
}
