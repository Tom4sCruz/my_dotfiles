import QtQuick

// One password character: flickers through random glyphs when typed,
// then keeps re-rolling now and then so the line shimmers.
Text {
    id: glyph
    readonly property string pool: "ｦｧｨｩｪｫｬｭｮｯｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789Z:.=*+-<>¦"
    property int flicker: 7

    function roll() { text = pool[Math.floor(Math.random() * pool.length)]; }

    color: Theme.lime
    font.family: Theme.font
    font.pixelSize: 26
    font.weight: Font.Bold
    Component.onCompleted: roll()

    // fresh character: bright, fast flicker
    Timer {
        running: glyph.flicker > 0
        repeat: true
        interval: 45
        onTriggered: { glyph.roll(); glyph.flicker--; }
    }
    opacity: flicker > 0 ? 1 : 0.85

    // settled: occasional re-roll
    Timer {
        running: glyph.flicker === 0
        repeat: true
        interval: 400 + Math.random() * 1600
        onTriggered: { glyph.roll(); interval = 400 + Math.random() * 1600; }
    }
}
