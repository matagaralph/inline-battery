import QtQuick
import QtQuick.Controls
import org.kde.plasma.plasmoid

CheckBox {
	id: configCheckBox

	property string configKey: ''
	checked: configKey ? Plasmoid.configuration[configKey] : false
	onClicked: Plasmoid.configuration[configKey] = !Plasmoid.configuration[configKey]
}
