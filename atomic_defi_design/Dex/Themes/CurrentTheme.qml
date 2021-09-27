pragma Singleton

ThemeData
{
    function loadFromFilesystem(fileName)
    {
        console.info("Dex.Themes.CurrentTheme.loadFromFilesystem: l˜SJDKoading %1..."
                        .arg(fileName))

        let themeData = atomic_qt_utilities.load_theme(fileName);

        accentColor                         = themeData.accentColor;
        foregroundColor                     = themeData.foregroundColor;
        backgroundColor                     = themeData.backgroundColor;
        backgroundColorDeep                 = themeData.backgroundColorDeep;

        buttonColorDisabled                 = themeData.buttonColorDisabled;
        buttonColorEnabled                  = themeData.buttonColorEnabled;
        buttonColorHovered                  = themeData.buttonColorHovered;
        buttonColorPressed                  = themeData.buttonColorPressed;

        buttonTextDisabledColor             = themeData.buttonTextDisabledColor;
        buttonTextEnabledColor              = themeData.buttonTextEnabledColor;
        buttonTextHoveredColor              = themeData.buttonTextHoveredColor;
        buttonTextPressedColor              = themeData.buttonTextPressedColor;

        gradientButtonStartColor            = themeData.gradientButtonStartColor;
        gradientButtonEndColor              = themeData.gradientButtonEndColor;

        textSelectionColor                  = themeData.textSelectionColor;
        textPlaceholderColor                = themeData.textPlaceholderColor;
        textSelectedColor                   = themeData.textSelectedColor;

        chartTradingLineBackgroundColor     = themeData.chartTradingLineBackgroundColor;
        chartTradingLineColor               = themeData.chartTradingLineColor;

        colorInnerShadowBottom              = themeData.colorInnerShadowBottom;
        colorInnerShadowTop                 = themeData.colorInnerShadowTop;

        colorLineGradient1                  = themeData.colorLineGradient1;
        colorLineGradient2                  = themeData.colorLineGradient2;
        colorLineGradient3                  = themeData.colorLineGradient3;
        colorLineGradient4                  = themeData.colorLineGradient4;

        floatingBackgroundColor             = themeData.floatingBackgroundColor;
        floatingBackgroundShadowColor1      = themeData.floatingBackgroundShadowColor1;
        floatingBackgroundShadowColor2      = themeData.floatingBackgroundShadowColor2;
        floatingBackgroundShadowDarkColor   = themeData.floatingBackgroundShadowDarkColor;

        sidebarDropShadowColor              = themeData.sidebarDropShadowColor;
        sidebarBgStartColor                 = themeData.sidebarBgStartColor;
        sidebarBgEndColor                   = themeData.sidebarBgEndColor;
        navigationSideBarButtonGradient1    = themeData.navigationSideBarButtonGradient1;
        navigationSideBarButtonGradient2    = themeData.navigationSideBarButtonGradient2;
        navigationSideBarButtonGradient3    = themeData.navigationSideBarButtonGradient3;
        navigationSideBarButtonGradient4    = themeData.navigationSideBarButtonGradient4;

        okColor                             = themeData.okColor;
        noColor                             = themeData.noColor;

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
