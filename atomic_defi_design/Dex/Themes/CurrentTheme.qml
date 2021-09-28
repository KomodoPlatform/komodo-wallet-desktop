pragma Singleton

import Dex.Graphics 1.0 as Dex

ThemeData
{
    function loadFromFilesystem(fileName)
    {
        console.info("Dex.Themes.CurrentTheme.loadFromFilesystem: loading %1..."
                        .arg(fileName))

        let themeData = atomic_qt_utilities.load_theme(fileName);

        accentColor                         = Dex.Color.argbStrFromRgbaStr(themeData.accentColor);
        foregroundColor                     = Dex.Color.argbStrFromRgbaStr(themeData.foregroundColor);
        backgroundColor                     = Dex.Color.argbStrFromRgbaStr(themeData.backgroundColor);
        backgroundColorDeep                 = Dex.Color.argbStrFromRgbaStr(themeData.backgroundColorDeep);

        buttonColorDisabled                 = Dex.Color.argbStrFromRgbaStr(themeData.buttonColorDisabled);
        buttonColorEnabled                  = Dex.Color.argbStrFromRgbaStr(themeData.buttonColorEnabled);
        buttonColorHovered                  = Dex.Color.argbStrFromRgbaStr(themeData.buttonColorHovered);
        buttonColorPressed                  = Dex.Color.argbStrFromRgbaStr(themeData.buttonColorPressed);

        buttonTextDisabledColor             = Dex.Color.argbStrFromRgbaStr(themeData.buttonTextDisabledColor);
        buttonTextEnabledColor              = Dex.Color.argbStrFromRgbaStr(themeData.buttonTextEnabledColor);
        buttonTextHoveredColor              = Dex.Color.argbStrFromRgbaStr(themeData.buttonTextHoveredColor);
        buttonTextPressedColor              = Dex.Color.argbStrFromRgbaStr(themeData.buttonTextPressedColor);

        gradientButtonStartColor            = Dex.Color.argbStrFromRgbaStr(themeData.gradientButtonStartColor);
        gradientButtonEndColor              = Dex.Color.argbStrFromRgbaStr(themeData.gradientButtonEndColor);

        textSelectionColor                  = Dex.Color.argbStrFromRgbaStr(themeData.textSelectionColor);
        textPlaceholderColor                = Dex.Color.argbStrFromRgbaStr(themeData.textPlaceholderColor);
        textSelectedColor                   = Dex.Color.argbStrFromRgbaStr(themeData.textSelectedColor);

        chartTradingLineBackgroundColor     = Dex.Color.argbStrFromRgbaStr(themeData.chartTradingLineBackgroundColor);
        chartTradingLineColor               = Dex.Color.argbStrFromRgbaStr(themeData.chartTradingLineColor);

        colorInnerShadowBottom              = Dex.Color.argbStrFromRgbaStr(themeData.colorInnerShadowBottom);
        colorInnerShadowTop                 = Dex.Color.argbStrFromRgbaStr(themeData.colorInnerShadowTop);

        colorLineGradient1                  = Dex.Color.argbStrFromRgbaStr(themeData.colorLineGradient1);
        colorLineGradient2                  = Dex.Color.argbStrFromRgbaStr(themeData.colorLineGradient2);
        colorLineGradient3                  = Dex.Color.argbStrFromRgbaStr(themeData.colorLineGradient3);
        colorLineGradient4                  = Dex.Color.argbStrFromRgbaStr(themeData.colorLineGradient4);

        floatingBackgroundColor             = Dex.Color.argbStrFromRgbaStr(themeData.floatingBackgroundColor);
        floatingBackgroundShadowColor1      = Dex.Color.argbStrFromRgbaStr(themeData.floatingBackgroundShadowColor1);
        floatingBackgroundShadowColor2      = Dex.Color.argbStrFromRgbaStr(themeData.floatingBackgroundShadowColor2);
        floatingBackgroundShadowDarkColor   = Dex.Color.argbStrFromRgbaStr(themeData.floatingBackgroundShadowDarkColor);

        sidebarDropShadowColor              = Dex.Color.argbStrFromRgbaStr(themeData.sidebarDropShadowColor);
        sidebarBgStartColor                 = Dex.Color.argbStrFromRgbaStr(themeData.sidebarBgStartColor);
        sidebarBgEndColor                   = Dex.Color.argbStrFromRgbaStr(themeData.sidebarBgEndColor);
        navigationSideBarButtonGradient1    = Dex.Color.argbStrFromRgbaStr(themeData.navigationSideBarButtonGradient1);
        navigationSideBarButtonGradient2    = Dex.Color.argbStrFromRgbaStr(themeData.navigationSideBarButtonGradient2);
        navigationSideBarButtonGradient3    = Dex.Color.argbStrFromRgbaStr(themeData.navigationSideBarButtonGradient3);
        navigationSideBarButtonGradient4    = Dex.Color.argbStrFromRgbaStr(themeData.navigationSideBarButtonGradient4);

        okColor                             = Dex.Color.argbStrFromRgbaStr(themeData.okColor);
        noColor                             = Dex.Color.argbStrFromRgbaStr(themeData.noColor);

        printCurrentValues();

        console.info("Dex.Themes.CurrentTheme.loadFromFilesystem: %1 is loaded"
                        .arg(fileName));
    }

    // Prints current loaded theme values.
    function printCurrentValues()
    {
        console.info("Dex.Themes.CurrentTheme.printValues.accentColor : %1".arg(accentColor));
        console.info("Dex.Themes.CurrentTheme.printValues.foregroundColor : %1".arg(foregroundColor));
        console.info("Dex.Themes.CurrentTheme.printValues.backgroundColor : %1".arg(backgroundColor));
        console.info("Dex.Themes.CurrentTheme.printValues.backgroundColorDeep : %1".arg(backgroundColorDeep));

        console.info("Dex.Themes.CurrentTheme.printValues.buttonColorDisabled : %1".arg(buttonColorDisabled));
        console.info("Dex.Themes.CurrentTheme.printValues.buttonColorEnabled : %1".arg(buttonColorEnabled));
        console.info("Dex.Themes.CurrentTheme.printValues.buttonColorHovered : %1".arg(buttonColorHovered));
        console.info("Dex.Themes.CurrentTheme.printValues.buttonColorPressed : %1".arg(buttonColorPressed));

        console.info("Dex.Themes.CurrentTheme.printValues.buttonTextDisabledColor : %1".arg(buttonTextDisabledColor));
        console.info("Dex.Themes.CurrentTheme.printValues.buttonTextEnabledColor : %1".arg(buttonTextEnabledColor));
        console.info("Dex.Themes.CurrentTheme.printValues.buttonTextHoveredColor : %1".arg(buttonTextHoveredColor));
        console.info("Dex.Themes.CurrentTheme.printValues.buttonTextPressedColor : %1".arg(buttonTextPressedColor));

        console.info("Dex.Themes.CurrentTheme.printValues.gradientButtonStartColor : %1".arg(gradientButtonStartColor));
        console.info("Dex.Themes.CurrentTheme.printValues.gradientButtonEndColor : %1".arg(gradientButtonEndColor));

        console.info("Dex.Themes.CurrentTheme.printValues.textSelectionColor : %1".arg(textSelectionColor));
        console.info("Dex.Themes.CurrentTheme.printValues.textPlaceholderColor : %1".arg(textPlaceholderColor));
        console.info("Dex.Themes.CurrentTheme.printValues.textSelectedColor : %1".arg(textSelectedColor));

        console.info("Dex.Themes.CurrentTheme.printValues.chartTradingLineBackgroundColor : %1".arg(chartTradingLineBackgroundColor));
        console.info("Dex.Themes.CurrentTheme.printValues.chartTradingLineColor : %1".arg(chartTradingLineColor));

        console.info("Dex.Themes.CurrentTheme.printValues.colorInnerShadowBottom : %1".arg(colorInnerShadowBottom));
        console.info("Dex.Themes.CurrentTheme.printValues.colorInnerShadowTop : %1".arg(colorInnerShadowTop));

        console.info("Dex.Themes.CurrentTheme.printValues.colorLineGradient1 : %1".arg(colorLineGradient1));
        console.info("Dex.Themes.CurrentTheme.printValues.colorLineGradient2 : %1".arg(colorLineGradient2));
        console.info("Dex.Themes.CurrentTheme.printValues.colorLineGradient3 : %1".arg(colorLineGradient3));
        console.info("Dex.Themes.CurrentTheme.printValues.colorLineGradient4 : %1".arg(colorLineGradient4));

        console.info("Dex.Themes.CurrentTheme.printValues.floatingBackgroundColor : %1".arg(floatingBackgroundColor));
        console.info("Dex.Themes.CurrentTheme.printValues.floatingBackgroundShadowColor1 : %1".arg(floatingBackgroundShadowColor1));
        console.info("Dex.Themes.CurrentTheme.printValues.floatingBackgroundShadowColor2 : %1".arg(floatingBackgroundShadowColor2));
        console.info("Dex.Themes.CurrentTheme.printValues.floatingBackgroundShadowDarkColor : %1".arg(floatingBackgroundShadowDarkColor));

        console.info("Dex.Themes.CurrentTheme.printValues.sidebarDropShadowColor : %1".arg(sidebarDropShadowColor));
        console.info("Dex.Themes.CurrentTheme.printValues.sidebarBgStartColor : %1".arg(sidebarBgStartColor));
        console.info("Dex.Themes.CurrentTheme.printValues.sidebarBgEndColor : %1".arg(sidebarBgEndColor));
        console.info("Dex.Themes.CurrentTheme.printValues.navigationSideBarButtonGradient1 : %1".arg(navigationSideBarButtonGradient1));
        console.info("Dex.Themes.CurrentTheme.printValues.navigationSideBarButtonGradient2 : %1".arg(navigationSideBarButtonGradient2));
        console.info("Dex.Themes.CurrentTheme.printValues.navigationSideBarButtonGradient3 : %1".arg(navigationSideBarButtonGradient3));
        console.info("Dex.Themes.CurrentTheme.printValues.navigationSideBarButtonGradient4 : %1".arg(navigationSideBarButtonGradient4));

        console.info("Dex.Themes.CurrentTheme.printValues.okColor : %1".arg(okColor));
        console.info("Dex.Themes.CurrentTheme.printValues.noColor : %1".arg(noColor));
    }
}
