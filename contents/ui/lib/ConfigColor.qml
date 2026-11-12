import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

RowLayout {
	id: configColor
	spacing: 2
	Layout.maximumWidth: 300

	property alias label: label.text
	property alias horizontalAlignment: label.horizontalAlignment

	property string configKey: ''
	property string configValue: configKey ? Plasmoid.configuration[configKey] : ""
	property string defaultColor: ''
	readonly property color value: configValue || defaultColor
	onConfigValueChanged: {
		if (!textField.activeFocus) {
			textField.text = configColor.configValue
		}
		if (configKey) {
			Plasmoid.configuration[configKey] = configValue
		}
	}

	Label {
		id: label
		text: "Label"
		Layout.fillWidth: horizontalAlignment == Text.AlignRight
		horizontalAlignment: Text.AlignLeft
	}

	MouseArea {
		Layout.preferredWidth: textField.height
		Layout.preferredHeight: textField.height
		hoverEnabled: true

		onClicked: dialog.open()

		Rectangle {
			anchors.fill: parent
			color: configColor.value
			border.width: 2
			border.color: parent.containsMouse ? Kirigami.Theme.highlightColor : "#BB000000"
		}
	}

	TextField {
		id: textField
		placeholderText: "#AARRGGBB"
		text: configColor.configValue
		Layout.fillWidth: label.horizontalAlignment == Text.AlignLeft
		onTextChanged: {
			if (text.length === 0
				|| (text.indexOf('#') === 0 && (text.length == 4 || text.length == 7 || text.length == 9))
			) {
				configColor.configValue = text
			}
		}
	}

	ColorDialog {
		id: dialog
		visible: false
		modality: Qt.WindowModal
		title: configColor.label
		options: ColorDialog.ShowAlphaChannel
		selectedColor: configColor.value
		onSelectedColorChanged: {
			if (visible) {
				configColor.configValue = selectedColor
			}
		}
	}
}
