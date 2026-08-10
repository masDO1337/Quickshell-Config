pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Polkit

Singleton {
    id: root

    PolkitAgent {
        id: agent

        onIsActiveChanged: {
            if (root.manualMode) root.manualMode = false
        }
    }

    property bool manualMode: false
    property bool visible: manualMode || agent.isActive

    property AuthFlow flow: agent.flow

    component Input: QtObject {
        property string prompt: "Input "
        property string value: ""
        property bool isPassword: false
        property bool focus: true
    }

    property Input flowInput: Input {
        prompt: root.flow?.inputPrompt ?? "Input "
        isPassword: !root.flow?.responseVisible ?? true
    }

    component Message: QtObject {
        property string title: "Title"
        property string message: "Message"
        property bool supplementaryIsError: false
        property string supplementaryMessage: ""
        property list<Input> inputs: []
        property bool responseRequired: true

        property var responseCallback: null

        function clear() {
            supplementaryIsError = false
            supplementaryMessage = ""
            responseRequired = true
        }

        function submit() {
            responseRequired = false
            if (responseCallback) responseCallback({ accepted: true, data: inputs.map(i => i.value) })
        }
        
        function cancel() {
            responseRequired = false
            if (responseCallback) responseCallback({ accepted: false, data: [] })
        }

        function setSupplementaryMessage(text, isError) {
            supplementaryMessage = text
            supplementaryIsError = isError
        }
    }

    property Message manual: Message {}
    
    readonly property string iconName:             manualMode ? Quickshell.shellPath("Icons/aperture.svg") : Quickshell.iconPath(flow?.iconName ?? "", true)
    readonly property string title:                manualMode ? manual.title                               : "Authentication Required"
    readonly property string message:              manualMode ? manual.message                             : flow?.message ?? "Authentication is required"
    readonly property bool   supplementaryIsError: manualMode ? manual.supplementaryIsError                : flow?.supplementaryIsError ?? false
    readonly property string supplementaryMessage: manualMode ? manual.supplementaryMessage                : flow?.supplementaryMessage ?? ""
    readonly property list<Input> inputs:          manualMode ? manual.inputs                              : [flowInput]
    readonly property bool   failed:               manualMode ? false                                      : flow?.failed ?? false
    readonly property bool   responseRequired:     manualMode ? manual.responseRequired                    : flow?.isResponseRequired ?? false
    readonly property string acceptText:           manualMode ? "Accept"                                   : "Authenticate"

    function request(message: Message) {
        manual = message
        manualMode = true
    }

    function submit(value: string) {
        if (manualMode) {
            manual.submit()
        } else if (flow) {
            if (value === "") value = inputs[0].value
            flow.submit(value)
            flowInput.value = ""
        }
    }

    function cancel() {
        if (manualMode) {
            manual.cancel()
            manualMode = false
        } else if (flow) flow.cancelAuthenticationRequest()
    }

    function accept(text: string) {
        if (manualMode) {
            manual.setSupplementaryMessage(text, false)
            timer.running = true
        }
    }

    function error(text: string) {
        if (manualMode) {
            manual.responseRequired = true
            manual.setSupplementaryMessage(text, true)
        }
    }

    property Timer timer: Timer {
        running: false
        interval: 2000
        onTriggered: {
            root.manualMode = false
        }
    }

    //Component.onCompleted: request(manual)
}