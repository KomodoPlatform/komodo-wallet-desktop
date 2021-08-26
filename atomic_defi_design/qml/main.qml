//! Qt Imports
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0

//! 3rdParty Imports
import Qaterial 1.0 as Qaterial

//! Project Imports
import App 1.0
import "Screens"
import "Components"

DexWindow
{
    id: window

    property alias  application: app
    property int    previousX: 0
    property int    previousY: 0
    property int    real_visibility
    property bool   isOsx: Qt.platform.os == "osx"
    property bool   logged: false

    title: API.app_name
    visible: true

	minimumWidth: General.minimumWidth
	minimumHeight: General.minimumHeight
	
	Universal.theme: Style.dark_theme ? Universal.Dark : Universal.Light
	Universal.accent: Style.colorQtThemeAccent
	Universal.foreground: Style.colorQtThemeForeground
	Universal.background: Style.colorQtThemeBackground

    background: DexRectangle
    {
		anchors.fill: parent
		color: "transparent"
		border.color: DexTheme.dexBoxBackgroundColor
		border.width: 1
		radius: 0
	}

    onVisibilityChanged:
    {
        // 3 is minimized, ignore that
        if (visibility !== 3)
            real_visibility = visibility

        API.app.change_state(visibility)

    }
	
	DexWindowControl { visible: !isOsx }

	DexRectangle {
		radius: 0
		width: parent.width-2
		height: 30
		anchors.horizontalCenter: parent.horizontalCenter
		color:  DexTheme.surfaceColor
		visible: isOsx 
	}

	App {
		id: app
		anchors.fill: parent
		anchors.topMargin: 30
		anchors.margins: 2
	}
	
	DexPopup
	{
		id: userMenu

		spacing: 8 
		padding: 2
		backgroundColor:  DexTheme.dexBoxBackgroundColor

		contentItem: Item
		{
			implicitWidth: 130
			implicitHeight: 30
			Rectangle {
				width: parent.width-10
				height: parent.height-5
				anchors.centerIn: parent
				color: logout_area.containsMouse?  DexTheme.contentColorTopBold :  DexTheme.buttonColorHovered
				Row {
					anchors.centerIn: parent
					Qaterial.Icon {
						anchors.verticalCenter: parent.verticalCenter
						icon: Qaterial.Icons.logout
						color:  DexTheme.foregroundColor
						size: 11
					}
					spacing: 5
					DexLabel {
						anchors.verticalCenter: parent.verticalCenter
						color:  DexTheme.foregroundColor
						text: qsTr('Logout')
					}
				}
				DexMouseArea {
					id: logout_area
					hoverEnabled: true
					anchors.fill: parent
					onClicked:  {
						let dialog = app.showText({
                            "title": qsTr("Confirm Logout"),
                            text: qsTr("Are you sure you want to log out?") ,
                            standardButtons: Dialog.Yes | Dialog.Cancel,
                            warning: true,
                            width: 300,
                            iconSource: Qaterial.Icons.logout,
                            iconColor: DexTheme.accentColor,
                            yesButtonText: qsTr("Yes"),
                            cancelButtonText: qsTr("Cancel"),
                            onAccepted: function(text) {
                            	app.notifications_list = []
                                userMenu.close()
								app.currentWalletName = ""
								API.app.disconnect()
								app.onDisconnect()
                                dialog.close()
                                dialog.destroy()
                            },
                            onRejected: function() {
                            	userMenu.close()
                            }
                        })
					}
				}
			}
		}
	}

	DexMacControl { visible: isOsx }
	Row {
		height: 30
		leftPadding: 8
		anchors.right: isOsx? parent.right : undefined
		anchors.rightMargin: isOsx? 8 : 0
		layoutDirection: isOsx? Qt.RightToLeft : Qt.LeftToRight
		spacing: 5

		Image {
			source: "qrc:/atomic_defi_design/assets/images/dex-tray-icon.png"
			width: 15
			height: 15
			smooth: true
			antialiasing: true
			visible: !_label.visible
			anchors.verticalCenter: parent.verticalCenter
		}
		DexLabel {
			text: atomic_app_name
			font.family: 'Montserrat'
			font.weight: Font.Medium
			opacity: .5
			leftPadding: 5
			color:  DexTheme.foregroundColor
			visible: !_label.visible
			anchors.verticalCenter: parent.verticalCenter
		} 

	}
	Item {
		width: _row.width
		height: 30
		Behavior on x {
			NumberAnimation {
				duration: 200
			}
		}
		anchors.right: parent.right
		anchors.rightMargin: isOsx? 10 : 120

		Row {
			id: _row
			anchors.verticalCenter: parent.verticalCenter
			layoutDirection: Qt.RightToLeft 
			spacing: 6
			DexLabel {
				text: " | "
				opacity: .1
				font.family: 'Montserrat'
				font.weight: Font.Medium
				visible: _label.visible & !isOsx
				color:  DexTheme.foregroundColor
				anchors.verticalCenter: parent.verticalCenter
				leftPadding: 2
			}
			Rectangle {
				width: __row.width + 10
				height: __row.height + 5
				anchors.verticalCenter: parent.verticalCenter
				//visible: _label.visible
				radius: 3
				color: _area.containsMouse?  DexTheme.dexBoxBackgroundColor : "transparent"
				Row {
					id: __row
					anchors.centerIn: parent
					layoutDirection: isOsx? Qt.RightToLeft : Qt.LeftToRight
					spacing: 6
					Qaterial.ColorIcon {
						source: Qaterial.Icons.accountCircle
						iconSize: 18
						visible: _label.visible
						color:  DexTheme.foregroundColor
						anchors.verticalCenter: parent.verticalCenter
					}
					DexLabel {
						id: _label
						text: API.app.wallet_mgr.wallet_default_name?? ""
						font.family: 'Montserrat'
						font.weight: Font.Medium
						opacity: .7
						visible: window.logged
						color:  DexTheme.foregroundColor
						anchors.verticalCenter: parent.verticalCenter
					}
					Qaterial.ColorIcon {
						source: Qaterial.Icons.menuDown
						iconSize: 14
						visible: _label.visible
						color:  DexTheme.foregroundColor
						anchors.verticalCenter: parent.verticalCenter
					}
				}
				DexMouseArea {
					id: _area
					anchors.fill: parent
					onClicked: {
						if(userMenu.visible){
							userMenu.close()
						}else {
							userMenu.openAt(mapToItem(Overlay.overlay, width / 2, height), Item.Top)
						}
					}
				}
			}
			DexLabel {
				text: " | "
				opacity: .1
				font.family: 'Montserrat'
				font.weight: Font.Medium
				visible: _label.visible
				color:  DexTheme.foregroundColor
				anchors.verticalCenter: parent.verticalCenter
				leftPadding: 2
			}
			Row {
				anchors.verticalCenter: parent.verticalCenter
				spacing: 6
				
				DexLabel {
					leftPadding: 2
					text: qsTr("Balance")
					font.family: 'Montserrat'
					font.weight: Font.Medium
					opacity: .7
					visible: _label.visible
					color:  DexTheme.foregroundColor
					anchors.verticalCenter: parent.verticalCenter
				}
				DexLabel {
					text: ":"
					opacity: .7
					font.family: 'Montserrat'
					font.weight: Font.Medium
					visible: _label.visible
					color:  DexTheme.foregroundColor
					anchors.verticalCenter: parent.verticalCenter
				}
				DexLabel {
					text_value: General.formatFiat("", API.app.portfolio_pg.balance_fiat_all,API.app.settings_pg.current_currency)
					font.family: 'lato'
					font.weight: Font.Medium
					visible: _label.visible
					color: DexTheme.accentColor
					privacy: true
					anchors.verticalCenter: parent.verticalCenter
					DexMouseArea {
						anchors.fill: parent
						onClicked: {
							const current_fiat = API.app.settings_pg.current_currency
							const available_fiats = API.app.settings_pg.get_available_currencies()
							const current_index = available_fiats.indexOf(
													current_fiat)
							const next_index = (current_index + 1)
											 % available_fiats.length
							const next_fiat = available_fiats[next_index]
							API.app.settings_pg.current_currency = next_fiat
						}
					}
				}
			}

			DexLabel {
				text: " | "
				opacity: .1
				font.family: 'Montserrat'
				font.weight: Font.Medium
				visible: _label.visible
				color:  DexTheme.foregroundColor
				anchors.verticalCenter: parent.verticalCenter
				leftPadding: 2
			}
			DexIconButton {
				opacity: containsMouse? 1 : .8
				anchors.verticalCenter: parent.verticalCenter
                iconSize: 22
				icon: Qaterial.Icons.bellOutline
				visible: _label.visible
				active: app.notification_modal.opened
                AnimatedRectangle
                {
					z: 1
					anchors.right: parent.right
					anchors.rightMargin: -3
					y: -3
					radius: width/2
					width: count_text.height * 1.4
					height: width
					visible: app.notifications_list !== undefined? app.notifications_list.length > 0 : false
					color:  DexTheme.redColor

                    DefaultText
                    {
						id: count_text
						anchors.centerIn: parent
						text_value: _label.visible ? app.notifications_list.length ?? 0 : 0
						font.pixelSize: 8
						font.family: 'Lato'
						color:  DexTheme.foregroundColor 
					}
				}
                onClicked:
                {
                    if (app.notification_modal.visible)
                        app.notification_modal.close()
                    else
                        app.notification_modal.openAt(mapToItem(Overlay.overlay, -165, 18), Item.Top)
				}
			}

			Settings {
		        id: atomic_settings0
		        fileName: atomic_cfg_file
		    }

            DexIconButton {
				opacity: containsMouse ? 1 : .8
				anchors.verticalCenter: parent.verticalCenter
                iconSize: 22
                icon: DexTheme.theme !== "dark" ? Qaterial.Icons.moonWaxingCrescent : Qaterial.Icons.whiteBalanceSunny
                visible: false
				active: app.notification_modal.opened
				onClicked: {
					let themeList = API.qt_utilities.get_themes_list()
			        if(DexTheme.theme === "light") {
			        	app.themeManager.apply("Dark")
			        } else {
			        	app.themeManager.apply("Light")
			        }
				}
			}
		}
	}
}
