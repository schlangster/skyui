import gfx.events.EventDispatcher;

import mx.utils.Delegate;
import TextField.StyleSheet;

class skyui.util.MarkupParser
{
	private static var _eventDummy: Object;

	private static var _markup: Object;

	public static var styleSheet: StyleSheet;

	/* INITIALIATZION */

	private static var _initialized: Boolean = initialize();

	public static function initialize(): Boolean
	{
		_markup = {};

		_eventDummy = {};
		EventDispatcher.initialize(_eventDummy);

		styleSheet = new StyleSheet();
		styleSheet.setStyle("p", {color: "#FFFFFF", fontSize: "17px"});
		styleSheet.setStyle(".list", {color: "#FFFFFF", fontSize: "17px", textIndent: "10px"});
		styleSheet.setStyle("bullet", {color: "#FFFFFF", fontSize: "20px"});
		styleSheet.setStyle("strong", {color: "#DDDDDD", fontWeight: "bold", fontFamily: "$EverywhereBoldFont"});
		styleSheet.setStyle("em", {fontStyle: "italic", fontFamily: "$EverywhereFont"});
		styleSheet.setStyle("underline", {textDecoration: "underline"});
		styleSheet.setStyle("a:link", {color: "#FFFFFF", textDecoration: "none"});
		styleSheet.setStyle("a:hover", {color: "#FFFFFF", textDecoration: "underline"});
		styleSheet.setStyle("a:active", {color: "#FFFFFF", textDecoration: "underline"});
		styleSheet.setStyle("h1", {color: "#FFFFFF", fontSize: "28px"});
		styleSheet.setStyle("h2", {color: "#FFFFFF", fontSize: "24px"});
		styleSheet.setStyle("h3", {color: "#FFFFFF", fontSize: "18px"});
		styleSheet.setStyle("h4", {color: "#CCCCCC", fontSize: "16px"});
		styleSheet.setStyle("h5", {color: "#CCCCCC", fontSize: "14px"});
		styleSheet.setStyle("h6", {color: "#BBBBBB", fontSize: "14px"});

		return true;
	}

  /* PUBLIC FUNCTIONS */

	public static function registerParseCallback(a_scope: Object, a_callBack: String): Void
	{
		_eventDummy.addEventListener("dataParsed", a_scope, a_callBack);
	}

	public static function load(a_path: String): Boolean
	{
		var lv = new LoadVars();
		lv.onData = Delegate.create(MarkupParser, parseData);
		return lv.load(a_path);
	}

  /* PRIVATE FUNCTIONS */
	
	private static function parseData(a_data: String): Void
	{
		var lines: Array = a_data.split("\r\n");
		if (lines.length == 1)
			lines = a_data.split("\n");

		var sectionName: String;
		var section: Object;

		var line: String;
		var parsedLine: String;
		var blankLine: Boolean
		var inParagraph: Boolean = false;

		var emptyLine: Boolean = true;

		var lastLineIdx = lines.length - 1;
		for (var i = 0; i <= lastLineIdx; i++) {

			line = lines[i];

			// Comment
			if (line.charAt(0) == ";")
				continue;

			// Section start
			if (line.charAt(0) == "[" && line.charAt(1) != "[" && line.length > 2) {

				sectionName = line.slice(1, line.lastIndexOf("]")).toLowerCase();
				
				if (_markup[sectionName] == undefined)
					_markup[sectionName] = {lines: [], htmlText: ""};

				continue;
			}

			if (sectionName == undefined && line.length < 3)
				continue;

			if (sectionName == undefined) {
				sectionName = "main";
				_markup[sectionName] = {lines: [], htmlText: ""};
			}


			line = htmlEscapeAndClean(line);

			// Empty line?
			emptyLine = (line.length == 0);

			// Header?
			if (!emptyLine && line.charAt(0) == "#") {
				var h: Number = 1;
				for (var j: Number = h; j < 6 && line.charAt(j) == "#"; j++)
					h++;

				if (line.charAt(h) == " ") {
					if (inParagraph) {
						_markup[sectionName].htmlText += "</p>";
						inParagraph = false;
					}
					_markup[sectionName].htmlText += "<p><h" + h + ">" + parseLine(line.slice(h + 1)) + "</h" + h + "></p>";
					continue;
				}
			}

			// List?
			if (!emptyLine && line.charAt(0) == "*" && line.charAt(1) == " ") {
				if (inParagraph) {
					_markup[sectionName].htmlText += "</p>";
					inParagraph = false;
				}
				_markup[sectionName].htmlText += "<p class='list'><bullet>&#183;&nbsp;</bullet>" + parseLine(line.slice(2)) + "<hack></p>";
				continue;
			}

			if (!inParagraph) {
				if (!emptyLine) {
					_markup[sectionName].htmlText += "<p>";
					_markup[sectionName].htmlText += parseLine(line);
					inParagraph = true;

					if (i == lastLineIdx) {
						_markup[sectionName].htmlText += "</p>";
						inParagraph = false;
					}
				}
			} else {
				if (!emptyLine) {
					_markup[sectionName].htmlText += "<br>";
					_markup[sectionName].htmlText += parseLine(line);
				} else {
					_markup[sectionName].htmlText += "</p>";
					inParagraph = false;
				}
			}
		}

		_eventDummy.dispatchEvent({type: "dataParsed", markup: _markup});
	}

	private static function parseLine(a_data: String): String
	{
		var parsedString = parseStyles(a_data);
		parsedString = parseAnchors(parsedString)

		return parsedString;
	}

	private static function parseStyles(a_data: String): String
	{
		var parsingString: String = "";
		var parsedString: String = "";

		// Bold and Italic

		// ***TEXT***   **Text2*****
		// i j    k l   ij     k   l

		var i: Number = -1;
		var j: Number = -1;

		var k: Number = -1;
		var l: Number = -1;

		var tokenWidth: Number = 0;

		while(l < a_data.length - 1) {
			j = i = a_data.indexOf("*", l+1);

			if (i == -1) { // No further tokens found
				parsingString += a_data.substring(l+1);
				break;
			}

			// Always append text before first token
			parsingString += a_data.substring(l+1, i);
	
			while (a_data.charAt(j+1) == "*")
				j++;

			l = k = a_data.indexOf("*", j+1);

			if (k == -1) { // No trailing token found, append remaining text and break
				parsingString += a_data.substring(i)
				break;
			}

			while (a_data.charAt(l+1) == "*")
				l++;

			tokenWidth = (j-i)+1;
			switch(tokenWidth) {
				case 1:
					parsingString += "<em>" + a_data.substring(j+1, k) + "</em>";
					break;
				case 2:
					parsingString += "<strong>" + a_data.substring(j+1, k) + "</strong>";
					break;
				case 3:
					parsingString += "<strong><em>" + a_data.substring(j+1, k) + "</em></strong>";
					break;
				default:
					parsingString += a_data.substring(i, l+1)
			}
		}

		// Underline

		// _TEXT_   __Text2_____
		// i    j    i     j

		var m: Number = -1;
		var n: Number = -1;

		while(n < parsingString.length - 1) {
			m = parsingString.indexOf("_", n+1);
			
			if (m == -1) { // No further tokens found
				parsedString += parsingString.substring(n+1);
				break;
			}

			while (parsingString.charAt(m+1) == "_")
				m++;

			parsedString += parsingString.substring(n+1, m);

			n = parsingString.indexOf("_", m+1);

			if (n == -1) {
				parsedString += parsingString.substring(m);
				break;
			}

			parsedString += "<underline>" + parsingString.substring(m+1, n) + "</underline>";
		}

		return parsedString;
	}

	private static function parseAnchors(a_data: String): String
	{
		// [[Section]]    [[Section|Name]]
        // i        k     i        j    k

		var parsedString: String = "";
		var anchorData: Array;

		var i: Number = -1;
		var j: Number = -2;

		while(j < a_data.length - 1) {
			i = a_data.indexOf("[[", j+2);

			if (i == -1) { // No further tokens found
				parsedString += a_data.substring(j+2);
				break;
			}

			// Always append text before first token
			parsedString += a_data.substring(j+2, i);

			j = a_data.indexOf("]]", i+2);

			if (j == -1) {
				parsedString += a_data.substring(i);
				break;
			}

			//if (j != -1)
			anchorData = a_data.substring(i+2, j).split("|", 2);

			if (anchorData.length == 2)
				parsedString += "<a href=\"asfunction:anchorPress,changeSection," + anchorData[0] + "\">" + anchorData[1] + "</a>";
			else
				parsedString += "<a href=\"asfunction:anchorPress,changeSection," + anchorData[0] + "\">" + anchorData[0] + "</a>";



		}

		return parsedString;
	}

	private static function htmlEscapeAndClean(a_str: String): String
	{
		// Trim leading and trailing whitespaces
		var i: Number = 0;
		while (a_str.charAt(i) == " " || a_str.charAt(i) == "\t")
			i++;

		var j: Number = a_str.length - 1;
		while (a_str.charAt(j) == " " || a_str.charAt(j) == "\t")
			j--;

		a_str = a_str.slice(i,j + 1);

		// Replace characters
		a_str = a_str.split("&").join("&amp;");
		a_str = a_str.split("'").join("&apos;");
		a_str = a_str.split("\"").join("&quot;");
		a_str = a_str.split("<").join("&lt;");
		a_str = a_str.split(">").join("&gt;");
		a_str = a_str.split("&amp;nbsp;").join("&nbsp;"); //hack... :)
		

		return a_str;
	}
}