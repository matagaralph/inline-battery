import QtQuick
import org.kde.kirigami as Kirigami

Item {
	id: batteryIcon
	property bool charging: false
	property int charge: 0
	property color normalColor: Kirigami.Theme.textColor
	property color chargingColor: "#1e1"
	property color lowBatteryColor: "#e33"
	property int lowBatteryPercent: 20

	Rectangle {
		id: container
		anchors.fill: parent
		anchors.rightMargin: 2
		color: "transparent"
		border.color: normalColor
		radius: 4.5

		Item {
			anchors.fill: parent
			anchors.margins: 2.6

			Rectangle {
				radius: 2.4
				anchors.left: parent.left
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				color: {
					if (charging) {
						return chargingColor
					} else if (charge < lowBatteryPercent) {
						return lowBatteryColor
					} else {
						return normalColor
					}
				}
				width: parent.width * Math.max(0, Math.min(charge, 100)) / 100
			}
		}
	}

	Rectangle {
		anchors.left: container.right
		anchors.leftMargin: 1
		anchors.verticalCenter: parent.verticalCenter
		radius: 4
		height: parent.height / 4
		width: 1.3
		color: normalColor
	}
}
