scriptname UILIB_ListMenu

; Note: Not thread-safe
function Open(Form client) global
	client.RegisterForModEvent("UILIB_listMenuOpen", "OnListMenuOpen")
	client.RegisterForModEvent("UILIB_listMenuClose", "OnListMenuClose")

	UI.OpenCustomMenu("listmenu")
endFunction

function SetData(string title, string[] options, int startIndex, int defaultIndex) global
	UI.InvokeNumber("CustomMenu", "_root.listDialog.setPlatform", 0)

	UI.InvokeStringA("CustomMenu", "_root.listDialog.initListData", options)

	int handle = UICallback.Create("CustomMenu", "_root.listDialog.initListParams")
	if (handle)
		UICallback.PushString(handle, title)
		UICallback.PushInt(handle, startIndex)
		UICallback.PushInt(handle, defaultIndex)
		UICallback.Send(handle)
	endIf
endFunction

function Release(Form client) global
	client.UnregisterForModEvent("UILIB_listMenuOpen")
	client.UnregisterForModEvent("UILIB_listMenuClose")
endFunction