import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid

RowLayout {
	id: configSpinBox

	property string configKey: ''
	property alias maximumValue: spinBox.to
	property alias minimumValue: spinBox.from
	property alias stepSize: spinBox.stepSize
	property alias value: spinBox.value
	property string prefix: ''
	property string suffix: ''

	property alias before: labelBefore.text
	property alias after: labelAfter.text

	Label {
		id: labelBefore
		text: ""
		visible: text
	}

	SpinBox {
		id: spinBox
		editable: true
		from: 0
		to: 2147483647
		value: Plasmoid.configuration[configKey]
		textFromValue: (value, locale) => configSpinBox.prefix + value + configSpinBox.suffix
		valueFromText: (text, locale) => parseInt(text.replace(/[^\d-]/g, '')) || 0
		onValueModified: serializeTimer.start()
	}

	Label {
		id: labelAfter
		text: ""
		visible: text
	}

	Timer {
		id: serializeTimer
		interval: 300
		onTriggered: Plasmoid.configuration[configKey] = spinBox.value
	}
}
