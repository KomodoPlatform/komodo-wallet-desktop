import QtQuick 2.15

DexTextField
{
    validator: RegExpValidator
    {
        regExp: /(0|([1-9][0-9]*))(\.[0-9]{1,8})?/
    }
}
