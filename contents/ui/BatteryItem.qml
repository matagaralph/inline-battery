import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.workspace.components as WorkspaceComponents
import org.kde.coreaddons as KCoreAddons
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.battery

Item {
	id: batteryItem
	height: childrenRect.height

	required property var model

	readonly property bool isPresent: model.PluggedIn
	readonly property bool isBroken: model.Capacity > 0 && model.Capacity < 50
	readonly property bool isCharging: model.ChargeState === BatteryControlModel.Charging
	readonly property bool isDischarging: model.ChargeState === BatteryControlModel.Discharging

	readonly property string stateText: {
		if (!isPresent) {
			return i18nc("Battery is currently not present in the bay", "Not present")
		}
		switch (model.ChargeState) {
		case BatteryControlModel.Discharging: return i18n("Discharging")
		case BatteryControlModel.FullyCharged: return i18n("Fully Charged")
		case BatteryControlModel.Charging: return i18n("Charging")
		default: return i18n("Not Charging")
		}
	}

	readonly property var details: {
		const data = []
		const remainingTime = batterywidget.remainingTime

		if (remainingTime > 0 && model.IsPowerSupply && (isDischarging || isCharging)) {
			data.push({ label: isCharging ? i18n("Time To Full:") : i18n("Time To Empty:") })
			data.push({ value: KCoreAddons.Format.formatDuration(remainingTime, KCoreAddons.FormatTypes.HideSeconds) })
		}

		if (model.IsPowerSupply && model.Capacity > 0) {
			data.push({ label: i18n("Capacity:") })
			data.push({ value: i18nc("Placeholder is battery capacity", "%1%", model.Capacity) })
		}

		return data
	}

	property Component batteryDetails: GridLayout {
		id: detailsLayout

		readonly property bool inListView: !!parent.inListView
		readonly property font detailsFont: inListView ? Kirigami.Theme.smallFont : Kirigami.Theme.defaultFont

		width: Kirigami.Units.gridUnit * 11
		columns: 2
		columnSpacing: Kirigami.Units.smallSpacing
		rowSpacing: 0

		PlasmaComponents.Label {
			Layout.fillWidth: true
			Layout.columnSpan: 2
			wrapMode: Text.WordWrap
			text: batteryItem.isBroken ? i18n("The capacity of this battery is %1%. This means it is broken and needs a replacement. Please contact your hardware vendor for more details.", batteryItem.model.Capacity) : ""
			font: detailsLayout.detailsFont
			visible: batteryItem.isBroken
		}

		Repeater {
			model: batteryItem.details

			PlasmaComponents.Label {
				required property var modelData
				required property int index

				Layout.fillWidth: true
				horizontalAlignment: detailsLayout.inListView && index % 2 === 1 ? Text.AlignRight : Text.AlignLeft
				font: detailsLayout.detailsFont
				text: modelData.value ? modelData.value : modelData.label
			}
		}
	}

	Column {
		width: parent.width
		spacing: 0

		PlasmaCore.ToolTipArea {
			width: parent.width
			height: infoRow.height
			active: !detailsLoader.active
			z: 2

			mainItem: Row {
				id: batteryItemToolTip

				property int _s: Kirigami.Units.largeSpacing / 2

				width: implicitWidth + batteryItemToolTip._s
				height: implicitHeight + batteryItemToolTip._s * 2
				spacing: batteryItemToolTip._s * 2

				WorkspaceComponents.BatteryIcon {
					x: batteryItemToolTip._s * 2
					y: batteryItemToolTip._s
					width: Kirigami.Units.iconSizes.medium
					height: width
					batteryType: batteryIcon.batteryType
					percent: batteryIcon.percent
					hasBattery: batteryIcon.hasBattery
					pluggedIn: batteryIcon.pluggedIn
					visible: !batteryItem.isBroken
				}

				Column {
					id: mainColumn
					x: batteryItemToolTip._s
					y: batteryItemToolTip._s

					PlasmaExtras.Heading {
						level: 3
						text: batteryNameLabel.text
					}
					Loader {
						sourceComponent: batteryItem.batteryDetails
						opacity: 0.5
					}
				}
			}

			RowLayout {
				id: infoRow
				width: parent.width
				spacing: Kirigami.Units.gridUnit

				WorkspaceComponents.BatteryIcon {
					id: batteryIcon
					Layout.alignment: Qt.AlignTop
					Layout.preferredWidth: Kirigami.Units.iconSizes.medium
					Layout.preferredHeight: Kirigami.Units.iconSizes.medium
					batteryType: batteryItem.model.Type
					percent: Math.max(0, batteryItem.model.Percent)
					hasBattery: batteryItem.isPresent
					pluggedIn: batteryItem.isCharging && batteryItem.model.IsPowerSupply
				}

				Column {
					Layout.fillWidth: true
					Layout.alignment: batteryItem.isPresent ? Qt.AlignTop : Qt.AlignVCenter

					RowLayout {
						width: parent.width
						spacing: Kirigami.Units.smallSpacing

						PlasmaComponents.Label {
							id: batteryNameLabel
							Layout.fillWidth: true
							elide: Text.ElideRight
							text: batteryItem.model.PrettyName
						}

						PlasmaComponents.Label {
							text: batteryItem.stateText
							visible: batteryItem.model.IsPowerSupply
							opacity: 0.6
						}

						PlasmaComponents.Label {
							id: batteryPercent
							horizontalAlignment: Text.AlignRight
							visible: batteryItem.isPresent
							text: i18nc("Placeholder is battery percentage", "%1%", batteryItem.model.Percent)
						}
					}

					PlasmaComponents.ProgressBar {
						width: parent.width
						from: 0
						to: 100
						visible: batteryItem.isPresent
						value: Number(batteryItem.model.Percent)
					}
				}
			}
		}

		Loader {
			id: detailsLoader
			property bool inListView: true
			anchors {
				left: parent.left
				leftMargin: batteryIcon.width + Kirigami.Units.gridUnit
				right: parent.right
			}
			visible: !!item
			opacity: 0.5
			sourceComponent: batteryItem.batteryDetails
			active: batteryItem.ListView.view.count < 2
		}
	}
}
