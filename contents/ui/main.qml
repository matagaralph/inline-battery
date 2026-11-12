import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.coreaddons as KCoreAddons
import org.kde.kcmutils as KCMUtils
import org.kde.config as KConfig
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.battery
import org.kde.plasma.private.batterymonitor
import org.kde.plasma.private.brightnesscontrolplugin

PlasmoidItem {
	id: batterywidget

	AppletConfig { id: config }

	BatteryControlModel { id: batteries }

	InhibitionControl {
		id: inhibitionControl
		isSilent: batterywidget.expanded
	}

	ScreenBrightnessControl {
		id: screenBrightnessControl
		isSilent: batterywidget.expanded
	}

	KeyboardBrightnessControl {
		id: keyboardBrightnessControl
		isSilent: batterywidget.expanded
	}

	readonly property bool powermanagementDisabled: inhibitionControl.isManuallyInhibited
	readonly property var inhibitions: inhibitionControl.requestedInhibitions.filter(inhibition => inhibition.active)
	readonly property int remainingTime: batteries.smoothedRemainingMsec
	readonly property bool kcmsAuthorized: KConfig.KAuthorized.authorizeControlModule("kcm_powerdevilprofilesconfig")

	readonly property bool currentBatteryCharging: batteries.state === BatteryControlModel.Charging
	readonly property int currentBatteryPercent: batteries.hasCumulative ? batteries.percent : 100
	readonly property bool currentBatteryLowPower: currentBatteryPercent <= config.lowBatteryPercent
	readonly property color currentTextColor: currentBatteryLowPower ? config.lowBatteryColor : config.normalColor
	readonly property string percentText: currentBatteryPercent > 0 ? currentBatteryPercent + '%' : '100%'

	Plasmoid.status: {
		if (powermanagementDisabled) {
			return PlasmaCore.Types.ActiveStatus
		}

		if (batteries.hasCumulative) {
			if (batteries.state !== BatteryControlModel.Charging && batteries.percent <= 5) {
				return PlasmaCore.Types.NeedsAttentionStatus
			} else if (batteries.state !== BatteryControlModel.FullyCharged) {
				return PlasmaCore.Types.ActiveStatus
			}
		}

		return PlasmaCore.Types.PassiveStatus
	}

	toolTipMainText: {
		if (!batteries.hasBatteries) {
			return i18n("No Batteries Available")
		} else if (!batteries.hasCumulative) {
			return i18n("Battery and Brightness")
		} else if (batteries.state === BatteryControlModel.FullyCharged) {
			return i18n("Fully Charged")
		}

		const percent = batteries.percent
		if (batteries.pluggedIn) {
			if (batteries.state === BatteryControlModel.Charging) {
				return i18n("%1%. Charging", percent)
			} else if (batteries.state === BatteryControlModel.NoCharge) {
				return i18n("%1%. Plugged in, not Charging", percent)
			}
			return i18n("%1%. Plugged in", percent)
		}

		if (remainingTime > 0) {
			return i18nc("%1 is remaining time, %2 is percentage", "%1 Remaining (%2%)",
				KCoreAddons.Format.formatDuration(remainingTime, KCoreAddons.FormatTypes.HideSeconds), percent)
		}
		return i18n("%1% Battery Remaining", percent)
	}

	toolTipSubText: powermanagementDisabled ? i18n("Power management is disabled") : ""

	function action_powerdevilkcm() {
		KCMUtils.KCMLauncher.openSystemSettings("kcm_powerdevilprofilesconfig")
	}

	function setPowerManagement(enabled) {
		if (enabled) {
			inhibitionControl.uninhibit()
		} else {
			inhibitionControl.inhibit(i18n("The battery applet has enabled system-wide inhibition"))
		}
	}

	Plasmoid.contextualActions: [
		PlasmaCore.Action {
			text: i18n("&Configure Power Saving...")
			icon.name: "preferences-system-power-management"
			visible: batterywidget.kcmsAuthorized
			onTriggered: batterywidget.action_powerdevilkcm()
		}
	]

	compactRepresentation: Item {
		id: panelItem

		Layout.minimumWidth: rowLayout.implicitWidth
		Layout.preferredWidth: rowLayout.implicitWidth
		Layout.minimumHeight: rowLayout.implicitHeight
		Layout.preferredHeight: rowLayout.implicitHeight

		function hideExpandedFrame() {
			let item = panelItem
			while (item.parent) {
				item = item.parent
				for (const child of item.children) {
					if (child.imagePath === "widgets/tabbar") {
						child.visible = false
						child.opacity = 0
						return
					}
				}
			}
		}

		Component.onCompleted: hideExpandedFrame()
		onParentChanged: hideExpandedFrame()

		Connections {
			target: batterywidget
			function onExpandedChanged() { panelItem.hideExpandedFrame() }
		}

		MouseArea {
			anchors.fill: parent
			onClicked: batterywidget.expanded = !batterywidget.expanded
		}

		RowLayout {
			id: rowLayout
			anchors.fill: parent
			spacing: 0

			PlasmaComponents.Label {
				id: percentTextLeft
				visible: Plasmoid.configuration.showPercentage && Plasmoid.configuration.alignLeft
				Layout.rightMargin: batteryIconContainer.visible ? config.padding : 0
				text: batterywidget.percentText
				font.pixelSize: config.fontSize
				fontSizeMode: Text.Fit
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				color: batterywidget.currentTextColor
			}

			Item {
				id: batteryIconContainer
				visible: Plasmoid.configuration.showBatteryIcon
				Layout.preferredWidth: config.iconWidth
				Layout.preferredHeight: config.iconHeight
				Layout.alignment: Qt.AlignVCenter

				MacBatteryIcon {
					id: batteryIcon
					anchors.fill: parent
					charging: batterywidget.currentBatteryCharging
					charge: batterywidget.currentBatteryPercent
					normalColor: config.normalColor
					chargingColor: config.chargingColor
					lowBatteryColor: config.lowBatteryColor
					lowBatteryPercent: config.lowBatteryPercent
				}
			}

			PlasmaComponents.Label {
				id: percentTextRight
				visible: Plasmoid.configuration.showPercentage && !Plasmoid.configuration.alignLeft
				Layout.leftMargin: batteryIconContainer.visible ? config.padding : 0
				text: batterywidget.percentText
				font.pixelSize: config.fontSize
				fontSizeMode: Text.Fit
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				color: batterywidget.currentTextColor
			}
		}
	}

	fullRepresentation: PopupDialog {
		id: dialogItem
		Layout.minimumWidth: Kirigami.Units.iconSizes.medium * 9
		Layout.preferredWidth: implicitWidth
		Layout.minimumHeight: Kirigami.Units.gridUnit * 15
		Layout.preferredHeight: Kirigami.Units.gridUnit * 15
		focus: true

		model: batterywidget.expanded ? batteries : null
		screenBrightness: screenBrightnessControl
		keyboardBrightness: keyboardBrightnessControl

		onPowermanagementChanged: checked => batterywidget.setPowerManagement(checked)
	}
}
