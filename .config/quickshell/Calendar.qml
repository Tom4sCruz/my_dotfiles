import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: cal
    spacing: 10

    readonly property date today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth()

    readonly property var monthNames: ["January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"]
    readonly property var dayNames: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    function shift(delta) {
        const d = new Date(viewYear, viewMonth + delta, 1);
        viewYear = d.getFullYear();
        viewMonth = d.getMonth();
    }

    // 6 weeks x 7 days, Monday first
    function cells() {
        const first = new Date(viewYear, viewMonth, 1);
        const offset = (first.getDay() + 6) % 7;
        const out = [];
        for (let i = 0; i < 42; i++) {
            const d = new Date(viewYear, viewMonth, 1 - offset + i);
            out.push({
                day: d.getDate(),
                inMonth: d.getMonth() === viewMonth,
                isToday: d.getFullYear() === today.getFullYear()
                    && d.getMonth() === today.getMonth()
                    && d.getDate() === today.getDate()
            });
        }
        return out;
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 2

        StyledText {
            text: cal.monthNames[cal.viewMonth] + " " + cal.viewYear
            font.pixelSize: 15
            font.weight: Font.Bold
            Layout.fillWidth: true
            Layout.leftMargin: 4
        }
        IconButton { text: ""; glyphSize: 12; onClicked: cal.shift(-1) }  // chevron-left
        IconButton { text: ""; glyphSize: 12; onClicked: cal.shift(1) }   // chevron-right
    }

    Rectangle {
        color: Theme.bgAlt
        border.color: Theme.border
        border.width: 1
        implicitWidth: grid.implicitWidth + 20
        implicitHeight: grid.implicitHeight + 20

        GridLayout {
            id: grid
            anchors.centerIn: parent
            columns: 7
            rowSpacing: 4
            columnSpacing: 4

            Repeater {
                model: cal.dayNames
                StyledText {
                    required property string modelData
                    text: modelData
                    color: Theme.dim
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 30
                }
            }

            Repeater {
                model: cal.cells()
                Rectangle {
                    required property var modelData
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 26
                    color: modelData.isToday ? Theme.fg : "transparent"   // today: white square

                    StyledText {
                        anchors.centerIn: parent
                        text: parent.modelData.day
                        color: parent.modelData.isToday ? Theme.bg : parent.modelData.inMonth ? Theme.fg : Theme.dim
                        opacity: parent.modelData.inMonth ? 1 : 0.5
                        font.weight: parent.modelData.isToday ? Font.Black : Font.DemiBold
                    }
                }
            }
        }
    }
}
