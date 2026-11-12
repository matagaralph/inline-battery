import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Column {
	id: root

	signal toggled(bool checked)

	spacing: 0

	RowLayout {
		width: parent.width
		spacing: Kirigami.Units.gridUnit

		MouseArea {
			Layout.fillWidth: true
			Layout.preferredHeight: childrenRect.height
			onClicked: {
				pmCheckBox.forceActiveFocus()
				pmCheckBox.click()
			}

			PlasmaCore.ToolTipArea {
				anchors.fill: parent
				subText: i18n("Disabling power management will prevent your screen and computer from turning off automatically.\n\nMost applications will automatically suppress power management when they don't want to have you interrupted.")
			}

			RowLayout {
				width: parent.width
				spacing: Kirigami.Units.gridUnit

				Item {
					Layout.preferredWidth: Kirigami.Units.iconSizes.medium
					Layout.preferredHeight: Kirigami.Units.iconSizes.medium

					PlasmaComponents.CheckBox {
						id: pmCheckBox
						anchors.centerIn: parent
						checked: !batterywidget.powermanagementDisabled
						opacity: batterywidget.inhibitions.length > 0 ? 0.5 : 1
						Behavior on opacity {
							NumberAnimation { duration: Kirigami.Units.longDuration }
						}
						onToggled: root.toggled(checked)

						Connections {
							target: batterywidget
							function onPowermanagementDisabledChanged() {
								pmCheckBox.checked = !batterywidget.powermanagementDisabled
							}
						}
					}
				}

				PlasmaComponents.Label {
					Layout.fillWidth: true
					text: i18n("Enable Power Management")
				}
			}
		}

		PlasmaComponents.ToolButton {
			icon.name: "configure"
			onClicked: batterywidget.action_powerdevilkcm()
			PlasmaComponents.ToolTip.text: i18n("Configure Power Saving...")
			PlasmaComponents.ToolTip.visible: hovered
			visible: batterywidget.kcmsAuthorized
		}
	}

	Column {
		anchors {
			left: parent.left
			leftMargin: Kirigami.Units.iconSizes.medium + Kirigami.Units.gridUnit
			right: parent.right
		}
		spacing: Kirigami.Units.smallSpacing

		InhibitionHint {
			width: parent.width
			visible: inhibitionControl.isLidPresent && !inhibitionControl.triggersLidAction
			iconSource: "computer-laptop"
			text: i18n("Your notebook is configured not to suspend when closing the lid while an external monitor is connected.")
		}

		InhibitionHint {
			width: parent.width
			visible: batterywidget.inhibitions.length > 0
			iconSource: batterywidget.inhibitions.length > 0 ? batterywidget.inhibitions[0].icon || "" : ""
			text: {
				const inhibitions = batterywidget.inhibitions
				if (inhibitions.length > 1) {
					return i18ncp("Some Application and n others are currently suppressing PM",
						"%2 and %1 other application are currently suppressing power management.",
						"%2 and %1 other applications are currently suppressing power management.",
						inhibitions.length - 1, inhibitions[0].prettyName)
				} else if (inhibitions.length === 1) {
					if (!inhibitions[0].reason) {
						return i18nc("Some Application is suppressing PM",
							"%1 is currently suppressing power management.", inhibitions[0].prettyName)
					}
					return i18nc("Some Application is suppressing PM: Reason provided by the app",
						"%1 is currently suppressing power management: %2", inhibitions[0].prettyName, inhibitions[0].reason)
				}
				return ""
			}
		}
	}
}
