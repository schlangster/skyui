scriptname UILIB_TextInputMenu

; Note: Not thread-safe
function Open(Form client) global
	client.RegisterForModEvent("UILIB_textInputOpen", "OnTextInputOpen")
	client.RegisterForModEvent("UILIB_textInputClose", "OnTextInputClose")

	UI.OpenCustomMenu("textinputmenu")
endFunction

function SetData(string title, string initialText) global
	UI.InvokeNumber("CustomMenu", "_root.textInputDialog.setPlatform", 0)

	String[] data = new string[2]
	data[0] = title
	data[1] = initialText
	UI.InvokeStringA("CustomMenu", "_root.textInputDialog.initData", data)
endFunction

function Release(Form client) global
	client.UnregisterForModEvent("UILIB_textInputOpen")
	client.UnregisterForModEvent("UILIB_textInputClose")
endFunction