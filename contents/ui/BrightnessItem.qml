import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

RowLayout {
	id: root

	property alias icon: brightnessIcon.source
	property alias label: brightnessLabel.text
	property real value
	property alias maximumValue: brightnessSlider.to

	signal moved(real value)

	spacing: Kirigami.Units.gridUnit

	Kirigami.Icon {
		id: brightnessIcon
		Layout.alignment: Qt.AlignTop
		Layout.preferredWidth: Kirigami.Units.iconSizes.medium
		Layout.preferredHeight: Kirigami.Units.iconSizes.medium
	}

	Column {
		id: brightnessColumn
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignTop
		spacing: 0

		PlasmaComponents.Label {
			id: brightnessLabel
			width: parent.width
		}

		PlasmaComponents.Slider {
			id: brightnessSlider
			width: parent.width
			from: to > 100 ? 1 : 0
			stepSize: 1
			value: root.value
			onPressedChanged: value = pressed ? value : Qt.binding(() => root.value)
			onMoved: root.moved(value)
		}
	}
}
