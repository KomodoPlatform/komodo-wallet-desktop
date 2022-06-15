// Helps QML engine to reduce instantiation overhead.
// https://doc.qt.io/qt-6/qtqml-javascript-resources.html#shared-javascript-resources-libraries
.pragma library

// Gets a ARGB string from a RGBA string.
//
// Returns `rgbaString` if it's a RGB string (it needs no change).
// Returns a ARGB string otherwise.
//
// WARNING: The behavior is undefined if the input string is not a valid RGB/A string.
//
// Valid RGBA string:       "#RRGGBBAA"
// Returned ARGB string:    "#AARRGGBB"
function argbStrFromRgbaStr(rgbaString)
{
    let tempRgbaString = rgbaString
    if (tempRgbaString.length === 7)
    {
        console.warn("Dex.Graphics.Color.argbStrFromRgbaStr: %1 is not an RGBA color"
                        .arg(tempRgbaString));
        return tempRgbaString;
    }

    //   #                 A                       RGB
    return "#" + tempRgbaString.substr(7, 2) + tempRgbaString.substr(1, 6);
}
