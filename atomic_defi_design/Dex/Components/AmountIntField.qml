import QtQuick 2.15

DexTextField
{
    property bool allowFloat: false
    validator: RegExpValidator
    {
        regExp: allowFloat ? /([0-9]*[.])?[0-9]+/ : /[0-9]+/
    }
}
