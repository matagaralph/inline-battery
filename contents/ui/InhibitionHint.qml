import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

RowLayout {
	property alias iconSource: iconItem.source
	property alias text: label.text

	spacing: Kirigami.Units.smallSpacing

	Kirigami.Icon {
		id: iconItem
		Layout.preferredWidth: Kirigami.Units.iconSizes.medium
		Layout.preferredHeight: Kirigami.Units.iconSizes.medium
		visible: valid
	}

	PlasmaComponents.Label {
		id: label
		Layout.fillWidth: true
		font: Kirigami.Theme.smallFont
		wrapMode: Text.WordWrap
		elide: Text.ElideRight
		maximumLineCount: 3
	}
}
