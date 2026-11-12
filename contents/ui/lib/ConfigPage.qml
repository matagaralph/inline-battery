import QtQuick
import QtQuick.Layouts

ColumnLayout {
	id: page
	Layout.fillWidth: true
	default property alias _contentChildren: content.data

	ColumnLayout {
		id: content
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignTop
	}

	property alias showAppletVersion: appletVersionLoader.active
	Loader {
		id: appletVersionLoader
		active: false
		visible: active
		source: "AppletVersion.qml"
		anchors.right: parent.right
		anchors.bottom: parent.top
	}
}
