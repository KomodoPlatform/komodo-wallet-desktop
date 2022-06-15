// Project Imports
import Dex.Themes 1.0 as Dex //> CurrentTheme

Arrow
{
    id: root

    property alias amISender: root.up

    color: !amISender ? Dex.CurrentTheme.senderColorStart : Dex.CurrentTheme.receiverColorStart
}
