import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#f0f4f9"

    property int sessionIndex: session.index
    property bool authenticating: false

    TextConstants { id: textConstants }

    function doLogin() {
        authenticating = true
        errorMessage.text = " "
        errorCode.visible = false
        sddm.login(name.text, password.text, sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginSucceeded() {
            root.authenticating = false
            errorMessage.color = "#188038"
            errorMessage.text = textConstants.loginSucceeded
        }
        function onLoginFailed() {
            root.authenticating = false
            password.text = ""
            password.focus = true
            errorMessage.color = "#d93025"
            errorMessage.text = "Couldn't sign you in. Check your password and try again."
            errorCode.visible = true
            shakeAnim.restart()
        }
        function onInformationMessage(message) {
            root.authenticating = false
            errorMessage.color = "#d93025"
            errorMessage.text = message
        }
    }

    Background {
        anchors.fill: parent
        source: Qt.resolvedUrl(config.background)
        fillMode: Image.PreserveAspectCrop
    }



    // ---- Clock, top right ----
    Column {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 36
        anchors.rightMargin: 48
        spacing: 4

        Text {
            id: timeText
            anchors.right: parent.right
            color: "white"
            style: Text.Outline
            styleColor: "#80000000"
            font.pixelSize: 44
            font.weight: Font.Light
        }
        Text {
            id: dateText
            anchors.right: parent.right
            color: "white"
            style: Text.Outline
            styleColor: "#80000000"
            font.pixelSize: 16
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var d = new Date()
            timeText.text = Qt.formatTime(d, "hh:mm")
            dateText.text = Qt.formatDate(d, "dddd, MMMM d")
        }
    }

    // ---- Sign-in card ----
    Rectangle {
        id: card
        width: 460
        height: mainColumn.implicitHeight + 88
        radius: 28
        color: "white"
        border.color: "#dadce0"
        border.width: 1
        anchors.centerIn: parent

        transform: Translate { id: cardShake; x: 0 }

        SequentialAnimation {
            id: shakeAnim
            NumberAnimation { target: cardShake; property: "x"; to: -14; duration: 50 }
            NumberAnimation { target: cardShake; property: "x"; to: 12; duration: 50 }
            NumberAnimation { target: cardShake; property: "x"; to: -8; duration: 50 }
            NumberAnimation { target: cardShake; property: "x"; to: 6; duration: 50 }
            NumberAnimation { target: cardShake; property: "x"; to: 0; duration: 50 }
        }

        // entrance animation
        opacity: 0
        Component.onCompleted: entranceAnim.start()
        ParallelAnimation {
            id: entranceAnim
            NumberAnimation { target: card; property: "opacity"; from: 0; to: 1; duration: 350; easing.type: Easing.OutCubic }
            NumberAnimation { target: card; property: "anchors.verticalCenterOffset"; from: 24; to: 0; duration: 350; easing.type: Easing.OutCubic }
        }

        Column {
            id: mainColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 44
            anchors.rightMargin: 44
            spacing: 8

            // Chrome logo
            Canvas {
                id: chromeLogo
                width: 48
                height: 48
                anchors.horizontalCenter: parent.horizontalCenter
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var cx = width / 2, cy = height / 2
                    var R = width / 2
                    var d = Math.PI / 180
                    function slice(a0, a1, col) {
                        ctx.beginPath()
                        ctx.moveTo(cx, cy)
                        ctx.arc(cx, cy, R, a0 * d, a1 * d, false)
                        ctx.closePath()
                        ctx.fillStyle = col
                        ctx.fill()
                    }
                    slice(210, 330, "#ea4335")
                    slice(330, 450, "#34a853")
                    slice(90, 210, "#fbbc04")
                    ctx.beginPath()
                    ctx.arc(cx, cy, R * 0.46, 0, 2 * Math.PI)
                    ctx.fillStyle = "white"
                    ctx.fill()
                    ctx.beginPath()
                    ctx.arc(cx, cy, R * 0.36, 0, 2 * Math.PI)
                    ctx.fillStyle = "#4285f4"
                    ctx.fill()
                }
            }

            Item { width: 1; height: 6 }

            Text {
                width: parent.width
                text: "Sign in"
                color: "#1f1f1f"
                font.pixelSize: 28
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                width: parent.width
                text: "to continue to your test desktop"
                color: "#444746"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
            }

            Item { width: 1; height: 10 }

            // Google account chip with avatar initial
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: chipRow.implicitWidth + 28
                height: 36
                radius: 18
                color: "white"
                border.color: "#747775"
                border.width: 1

                Row {
                    id: chipRow
                    anchors.centerIn: parent
                    spacing: 8

                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        anchors.verticalCenter: parent.verticalCenter
                        color: ["#4285f4", "#ea4335", "#fbbc04", "#34a853"][
                            name.text.length > 0 ? name.text.charCodeAt(0) % 4 : 0]
                        Text {
                            anchors.centerIn: parent
                            text: name.text.length > 0 ? name.text.charAt(0).toUpperCase() : "?"
                            color: "white"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: name.text.length > 0 ? name.text : "no user"
                        color: "#1f1f1f"
                        font.pixelSize: 13
                    }
                }
            }

            Item { width: 1; height: 12 }

            Text { text: "Username"; color: "#444746"; font.pixelSize: 12; font.bold: true }
            TextBox {
                id: name
                width: parent.width
                height: 48
                text: userModel.lastUser
                font.pixelSize: 16
                radius: 8
                color: "#ffffff"
                borderColor: "#747775"
                focusColor: "#0b57d0"
                hoverColor: "#0b57d0"
                textColor: "#1f1f1f"
                KeyNavigation.backtab: loginButton
                KeyNavigation.tab: session
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        password.focus = true
                        event.accepted = true
                    }
                }
            }

            Item { width: 1; height: 6 }

            Text { text: "Session / Desktop"; color: "#0b57d0"; font.pixelSize: 12; font.bold: true }
            ComboBox {
                id: session
                width: parent.width
                height: 48
                z: 999
                font.pixelSize: 15
                arrowIcon: Qt.resolvedUrl("angle-down.png")
                model: sessionModel
                index: sessionModel.lastIndex
                color: "#ffffff"
                borderColor: "#747775"
                focusColor: "#0b57d0"
                hoverColor: "#0b57d0"
                textColor: "#1f1f1f"
                KeyNavigation.backtab: name
                KeyNavigation.tab: password
            }

            Text { z: 1; text: "Password"; color: "#444746"; font.pixelSize: 12; font.bold: true }
            PasswordBox {
                id: password
                z: 1
                width: parent.width
                height: 48
                font.pixelSize: 16
                radius: 8
                color: "#ffffff"
                borderColor: "#747775"
                focusColor: "#0b57d0"
                hoverColor: "#0b57d0"
                textColor: "#1f1f1f"
                KeyNavigation.backtab: session
                KeyNavigation.tab: loginButton
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.doLogin()
                        event.accepted = true
                    }
                }
            }

            // Caps lock warning
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
                visible: keyboard.capsLock
                Text { text: "\u26a0"; color: "#ea8600"; font.pixelSize: 12 }
                Text {
                    text: "Caps Lock is on"
                    color: "#ea8600"
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            Text {
                id: errorMessage
                width: parent.width
                text: " "
                color: "#d93025"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            // Chrome net-error style code
            Text {
                id: errorCode
                width: parent.width
                visible: false
                text: "ERR_AUTH_FAILED"
                color: "#747775"
                font.pixelSize: 11
                font.family: "monospace"
                horizontalAlignment: Text.AlignHCenter
            }

            Item { width: 1; height: 4 }

            // Google-style action row: pill button right-aligned
            Item {
                width: parent.width
                height: 44

                Rectangle {
                    id: loginButton
                    width: 110
                    height: 40
                    radius: 20
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.authenticating ? "#0b57d0"
                         : loginMouse.pressed ? "#0842a0"
                         : (loginMouse.containsMouse || loginButton.activeFocus) ? "#1b6ef3"
                         : "#0b57d0"
                    activeFocusOnTab: true
                    KeyNavigation.backtab: password
                    KeyNavigation.tab: name
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                                || event.key === Qt.Key_Space) {
                            root.doLogin()
                            event.accepted = true
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !root.authenticating
                        text: "Sign in"
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    // Google-colored loading dots while authenticating
                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        visible: root.authenticating

                        Repeater {
                            model: [ "#ffffff", "#fbbc04", "#34a853", "#ea4335" ]
                            Rectangle {
                                id: dot
                                width: 8
                                height: 8
                                radius: 4
                                color: modelData
                                anchors.verticalCenter: parent.verticalCenter

                                SequentialAnimation on anchors.verticalCenterOffset {
                                    running: root.authenticating
                                    loops: Animation.Infinite
                                    PauseAnimation { duration: index * 120 }
                                    NumberAnimation { to: -5; duration: 220; easing.type: Easing.OutQuad }
                                    NumberAnimation { to: 0; duration: 220; easing.type: Easing.InQuad }
                                    PauseAnimation { duration: (3 - index) * 120 }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: loginMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: !root.authenticating
                        onClicked: root.doLogin()
                    }
                }
            }
        }
    }

    // ---- Footer text ----
    Column {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 48
        anchors.bottomMargin: 18
        spacing: 2
        Text {
            text: "Chromium Touch Test"
            color: "white"
            style: Text.Outline
            styleColor: "#80000000"
            font.pixelSize: 13
        }
        Text {
            text: "No internet required to sign in"
            color: "white"
            style: Text.Outline
            styleColor: "#80000000"
            font.pixelSize: 11
        }
    }

    // ---- Dino runner (game demo) across the bottom ----
    Item {
        id: dinoGame
        anchors.left: parent.left
        anchors.leftMargin: 48
        anchors.right: parent.right
        anchors.rightMargin: 48
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 64
        height: 54

        property bool jumping: dinoJump.running
        property var cacti: [ width * 0.30, width * 0.55, width * 0.80 ]

        Rectangle {
            id: ground
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 2
            color: "#e8eaed"
        }

        Repeater {
            model: dinoGame.cacti
            Item {
                width: 12
                height: 24
                x: modelData
                anchors.bottom: ground.top
                Rectangle { color: "#e8eaed"; width: 4; height: 24; anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter }
                Rectangle { color: "#e8eaed"; width: 3; height: 9; anchors.bottom: parent.bottom; anchors.bottomMargin: 8; x: 1 }
                Rectangle { color: "#e8eaed"; width: 3; height: 9; anchors.bottom: parent.bottom; anchors.bottomMargin: 5; x: 8 }
            }
        }

        Canvas {
            id: dino
            width: 44
            height: 48
            x: 0
            anchors.bottom: ground.top
            anchors.bottomMargin: 0
            transformOrigin: Item.Bottom
            scale: 1.18

            property int frame: 0
            property var body: [
                "..........###########",
                ".........############",
                ".........##.#########",
                ".........############",
                ".........############",
                ".........############",
                ".........######......",
                ".........#########...",
                "#.......######.......",
                "#......#######.......",
                "##....##########.....",
                "###..#########.#.....",
                "##############.......",
                "##############.......",
                ".#############.......",
                "..###########........",
                "...##########........",
                "....########........."
            ]
            property var legs: [
                [ ".....###.###.........",
                  ".....##...##.........",
                  ".....##....#.........",
                  "....##.....#........." ],
                [ ".....###.###.........",
                  ".....##...##.........",
                  ".....#....##.........",
                  ".....#.....##........" ],
                [ ".....###.###.........",
                  ".....##...##.........",
                  ".....#.....#.........",
                  ".....#.....#........." ]
            ]

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.fillStyle = "#f1f3f4"
                var px = 2
                var rows = body.concat(legs[frame])
                for (var y = 0; y < rows.length; y++) {
                    var row = rows[y]
                    for (var x = 0; x < row.length; x++) {
                        if (row.charAt(x) === "#")
                            ctx.fillRect(x * px, y * px + 4, px, px)
                    }
                }
            }
            onFrameChanged: requestPaint()

            Timer {
                interval: 110
                running: true
                repeat: true
                onTriggered: {
                    if (!dinoGame.jumping)
                        dino.frame = dino.frame === 0 ? 1 : 0
                }
            }

            onXChanged: {
                if (dinoJump.running)
                    return
                var front = x + 28
                for (var i = 0; i < dinoGame.cacti.length; i++) {
                    var d = dinoGame.cacti[i] - front
                    if (d > 2 && d < 20) {
                        dinoJump.restart()
                        break
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: dinoJump.restart()
            }

            SequentialAnimation {
                id: dinoJump
                ScriptAction { script: dino.frame = 2 }
                NumberAnimation { target: dino; property: "anchors.bottomMargin"; to: 40; duration: 240; easing.type: Easing.OutQuad }
                NumberAnimation { target: dino; property: "anchors.bottomMargin"; to: 0; duration: 260; easing.type: Easing.InQuad }
            }

            NumberAnimation on x {
                from: 0
                to: dinoGame.width - 44
                duration: 11000
                loops: Animation.Infinite
                running: true
            }
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 48
        anchors.bottomMargin: 20
        spacing: 8

        Rectangle {
            width: restartText.implicitWidth + 32
            height: 36
            radius: 18
            color: restartMouse.pressed ? "#40ffffff"
                 : restartMouse.containsMouse ? "#26ffffff" : "transparent"
            Text {
                id: restartText
                anchors.centerIn: parent
                text: textConstants.reboot
                color: "white"
                style: Text.Outline
                styleColor: "#80000000"
                font.pixelSize: 14
                font.bold: true
            }
            MouseArea {
                id: restartMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.reboot()
            }
        }

        Rectangle {
            width: shutdownText.implicitWidth + 32
            height: 36
            radius: 18
            color: shutdownMouse.pressed ? "#40ffffff"
                 : shutdownMouse.containsMouse ? "#26ffffff" : "transparent"
            Text {
                id: shutdownText
                anchors.centerIn: parent
                text: textConstants.shutdown
                color: "white"
                style: Text.Outline
                styleColor: "#80000000"
                font.pixelSize: 14
                font.bold: true
            }
            MouseArea {
                id: shutdownMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.powerOff()
            }
        }
    }

    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
    }
}
