import QtQuick 2.15
import Qaterial 1.0 as Qaterial
import App 1.0

QtObject {
	function apply(name) {
		let data = API.qt_utilities.load_theme(name)
        
		checkThemeType(data)

        for (let i in data) {
        	console.log("[THEME] set(<font color='pink'>%1</font>) to <b>%2</b>".arg(data[i]).arg(i))
            if (typeof(data[i]) === "boolean") {
                eval("DexTheme." + i.toString() + " = " + data[i].toString())
            }
            else if(typeof(data[i]) === "number") {
                eval("DexTheme." + i.toString() + " = " + data[i])
            } else {
            	if(data[i].toString().startsWith('rgba')){
					let color = data[i].toString().replace("rgba(","").replace(")","").split(",")
					color = Qt.rgba(rgba255to1(color[0]),
								  rgba255to1(color[1]),
								  rgba255to1(color[2]),
								  parseFloat(color[3]))
					eval("DexTheme." + i.toString() + " = color")
				} else {
					eval("DexTheme." + i.toString() + " = '" + data[i] + "'")
				}
                
            }
        }
		
		checkExtraProperty(data)


        Qaterial.Style.accentColor = DexTheme.accentColor
        
        console.log("[THEME] %1 Applied successfully".arg(name))
	}

	function checkThemeType(data) {
		if(!("theme" in data)) {
            console.log('[THEME] theme type not defined')
            DexTheme.theme = "undefined"
        } else {
            console.log("[THEME] theme type defined")
        }
	}

	function checkExtraProperty(data) {

        if(!("portfolioPieGradient" in data)) {
            console.log('[THEME] portfolioPieGradient type not defined')
            DexTheme.portfolioPieGradient = false
        }

        if(!("sideBarRightBorderColor" in data)) {
            console.log('[THEME] portfolioPieGradient type not defined')
            DexTheme.sideBarRightBorderColor = "transparent"
        }

        if(!("proviewItemBoxBorderColor" in data)) {
            console.log('[THEME] proviewItemBoxBorderColor type not defined')
            DexTheme.proviewItemBoxBorderColor = "transparent"
        }

        propertyChecker("tabBarBackgroudColor","buttonColorEnabled", data)
        propertyChecker("contentColorTop", "backgroundColor", data)
        propertyChecker("contentColorTopBold", "backgroundColor", data)
        propertyChecker("modalStepColor", "accentColor", data)
        propertyChecker("modelStepBorderColor", "hightlightColor", data)
        propertyChecker("hoverColor", "buttonColorHovered", data)
        propertyChecker("buttonGradientEnabled1", "buttonColorEnabled", data)
        propertyChecker("buttonGradientEnabled2", "buttonColorEnabled", data)
        propertyChecker("arrowUpColor", "greenColor", data)
        propertyChecker("arrowDownColor", "redColor", data)
        propertyChecker("tradeFieldBoxBackgroundColor", "backgroundColor", data)
        propertyChecker("iconButtonColor","buttonColorEnabled", data)
        propertyChecker("iconButtonForegroundColor","buttonColorTextEnabled", data)
        propertyChecker("proviewItemBoxBackgroundColor","dexBoxBackgroundColor", data)
        propertyChecker("comboBoxBorderColor","rectangleBorderColor",data)
        propertyChecker("comboBoxBackgroundColor","dexBoxBackgroundColor",data)
	}

	function propertyChecker(name, value, data) {
		if(!(name in data)) {
			console.log('[THEME] %1 type not defined'.arg(name))
			eval('DexTheme.'+name+' = DexTheme.'+value)
		}
	}

	function rgba255to1(n) {
		return (parseInt(n)*1) / 255
	}

}