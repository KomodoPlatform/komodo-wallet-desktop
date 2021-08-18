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

		if(!("contentColorTop" in data)) {
            console.log('[THEME] contentColorTop type not defined')
            DexTheme.contentColorTop = DexTheme.backgroundColor
            DexTheme.contentColorTopBold = DexTheme.backgroundColor
        }

        if(!("portfolioPieGradient" in data)) {
            console.log('[THEME] portfolioPieGradient type not defined')
            DexTheme.portfolioPieGradient = false
        }

        if(!("sideBarRightBorderColor" in data)) {
            console.log('[THEME] portfolioPieGradient type not defined')
            DexTheme.sideBarRightBorderColor = "transparent"
        }

        if(!("hoverColor" in data)) {
            console.log('[THEME] hoverColor type not defined')
            DexTheme.hoverColor = DexTheme.accentLightColor1
        }

        if(!("modalStepColor" in data)) {
            console.log('[THEME] modalStepColor type not defined')
            DexTheme.modalStepColor = DexTheme.accentColor
        }
	}

	function rgba255to1(n) {
		return (parseInt(n)*1) / 255
	}

}