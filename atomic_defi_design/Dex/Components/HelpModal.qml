import QtQuick 2.12

MultipageModal
{
    property string helpSentence
    property alias  title: _content.titleText

    width: 500

    MultipageModalContent { id: _content; DexLabel { text: helpSentence } }
}
