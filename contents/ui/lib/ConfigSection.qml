import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
	id: control
	Layout.fillWidth: true
	default property alias _contentChildren: content.data
	property string label: ""

	color: "#0c000000"
	border.width: 2
	border.color: "#10000000"
	property int padding: 8
	implicitHeight: childrenRect.height + padding + padding
	property alias spacing: content.spacing

	Label {
		id: title
		visible: control.label
		text: control.label
		font.bold: true
		font.pointSize: 13
		anchors.leftMargin: padding
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.right: parent.right
		height: visible ? implicitHeight : padding
	}

	ColumnLayout {
		id: content
		anchors.top: title.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.margins: padding
	}
}
