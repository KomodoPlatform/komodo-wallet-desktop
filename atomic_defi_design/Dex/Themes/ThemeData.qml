import QtQuick 2.12

QtObject
{
    property color  accentColor
    property color  foregroundColor
    property color  foregroundColor2
    property color  foregroundColor3
    property color  backgroundColor
    property color  backgroundColorDeep

    property color  busyIndicatorColor

    property color  buttonColorDisabled
    property color  buttonColorEnabled
    property color  buttonColorHovered
    property color  buttonColorPressed
    property color  buttonTextDisabledColor
    property color  buttonTextEnabledColor
    property color  buttonTextHoveredColor
    property color  buttonTextPressedColor

    property color  gradientButtonStartColor
    property color  gradientButtonEndColor
    property color  gradientButtonDisabledStartColor
    property color  gradientButtonDisabledEndColor
    property color  gradientButtonHoveredStartColor
    property color  gradientButtonHoveredEndColor
    property color  gradientButtonPressedStartColor
    property color  gradientButtonPressedEndColor
    property color  gradientButtonTextEnabledColor
    property color  gradientButtonTextDisabledColor
    property color  gradientButtonTextHoveredColor
    property color  gradientButtonTextPressedColor

    property color  checkBoxGradientStartColor
    property color  checkBoxGradientEndColor

    property color  switchGradientStartColor
    property color  switchGradientEndColor
    property color  switchGradientStartColor2
    property color  switchGradientEndColor2

    property color  comboBoxBackgroundColor
    property color  comboBoxArrowsColor
    property color  comboBoxDropdownItemHighlightedColor

    property color  modalPageCounterGradientStartColor
    property color  modalPageCounterGradientEndColor

    property color  notifPopupBackgroundColor
    property color  notifPopupTextColor
    property color  notifPopupTimerColor
    property color  notifPopupTimerBackgroundColor
    property color  notifPopupIconStartColor
    property color  notifPopupIconEndColor

    property color  scrollBarIndicatorColor
    property color  scrollBarBackgroundColor

    property color  tabSelectedColor

    property color  textDisabledColor
    property color  textSelectionColor
    property color  textPlaceholderColor
    property color  textSelectedColor

    property color  textFieldBackgroundColor
    property color  textFieldActiveBackgroundColor
    property color  textFieldPrefixColor
    property color  textFieldSuffixColor

    property color  chartTradingLineBackgroundColor
    property color  chartTradingLineColor

    property color  innerBackgroundColor

    property color  floatingBackgroundColor

    property color  rangeSliderBackgroundColor
    property color  rangeSliderDistanceColor
    property color  rangeSliderIndicatorBackgroundStartColor
    property color  rangeSliderIndicatorBackgroundEndColor

    // Login page related
    property color  userIconColorStart
    property color  userIconColorEnd     // Property not yet used.

    // Sidebar related
    property color  sidebarBgColor
    property color  sidebarVersionTextColor
    property color  sidebarCursorStartColor
    property color  sidebarCursorEndColor
    property color  sidebarLineTextHovered
    property color  sidebarLineTextSelected

    // Trading page related
    property color  tradeBuyModeSelectorBackgroundColorStart
    property color  tradeBuyModeSelectorBackgroundColorEnd
    property color  tradeSellModeSelectorBackgroundColorStart
    property color  tradeSellModeSelectorBackgroundColorEnd
    property color  tradeMarketModeSelectorNotSelectedBackgroundColor

    // Address book page related
    property var    addressBookTagColors

    // Colors used to tell when something is good or wrong.
    property color  okColor
    property color  noColor

    property color  senderColorStart
    property color  receiverColorStart

    property color  lineSeparatorColor

    // Logos
    property string logoPath
    property string bigLogoPath
}
