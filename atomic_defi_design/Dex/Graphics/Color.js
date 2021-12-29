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
    if (rgbaString.length === 7)
    {
        console.warn("Dex.Graphics.Color.argbStrFromRgbaStr: %1 is not an RGBA color"
                        .arg(rgbaString));
        return rgbaString;
    }

    //   #                 A                       RGB
    return "#" + rgbaString.substr(7, 2) + rgbaString.substr(1, 6);
}
