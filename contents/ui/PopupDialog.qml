import QtQuick
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.brightnesscontrolplugin

FocusScope {
	id: dialog
	focus: true


	property alias model: batteryList.model
	required property ScreenBrightnessControl screenBrightnessControl
	required property KeyboardBrightnessControl keyboardBrightnessControl

	signal powermanagementChanged(bool checked)

	Column {
		id: settingsColumn
		anchors.horizontalCenter: parent.horizontalCenter
		width: parent.width - Kirigami.Units.gridUnit
		spacing: Math.round(Kirigami.Units.gridUnit / 2)

		PowerManagementItem {
			id: pmSwitch
			width: parent.width
			onToggled: checked => dialog.powermanagementChanged(checked)
		}

		Repeater {
			id: screenBrightnessRepeater
			model: dialog.screenBrightnessControl.displays

			BrightnessItem {
				required property var model

				width: settingsColumn.width
				icon: "video-display-brightness"
				label: screenBrightnessRepeater.count > 1 ? model.label : i18n("Display Brightness")
				value: model.brightness
				maximumValue: model.maxBrightness
				onMoved: value => dialog.screenBrightnessControl.setBrightness(model.displayName, value)
			}
		}

		BrightnessItem {
			id: keyboardBrightnessSlider
			width: parent.width
			icon: "input-keyboard-brightness"
			label: i18n("Keyboard Brightness")
			visible: dialog.keyboardBrightnessControl.isBrightnessAvailable
			value: dialog.keyboardBrightnessControl.brightness
			maximumValue: dialog.keyboardBrightnessControl.brightnessMax
			onMoved: value => dialog.keyboardBrightnessControl.brightness = value
		}
	}

	PlasmaComponents.ScrollView {
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: settingsColumn.bottom
			topMargin: Kirigami.Units.gridUnit
			bottom: dialog.bottom
		}
		width: parent.width - Kirigami.Units.gridUnit

		ListView {
			id: batteryList
			boundsBehavior: Flickable.StopAtBounds
			spacing: Math.round(Kirigami.Units.gridUnit / 2)

			delegate: BatteryItem {
				width: ListView.view.width
			}
		}
	}
}
