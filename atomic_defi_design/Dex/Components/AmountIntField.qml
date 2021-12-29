import QtQuick 2.15

DefaultTextField
{
    validator: RegExpValidator
    {
        regExp: /[0-9]+/
    }
}
