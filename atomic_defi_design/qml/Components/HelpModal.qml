import QtQuick 2.12

BasicModal
{
    property string helpSentence
    property alias  title: _content.title

    width: 500

    ModalContent { id: _content; DexLabel { text: helpSentence } }
}
