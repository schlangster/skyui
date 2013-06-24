
using System;
using fomm.Scripting;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using System.Windows.Forms;
using System.Globalization;
using System.Collections.Generic;

class Script : SkyrimBaseScript {

	static Version SKSE_MIN_VERSION = new Version("0.1.6.16");

	// Main dialog
	static Form mainInstallForm;
	static TextBox textArea;
	static Button refreshButton;
	static Button installButton;
	static Button cancelButton;

	static string[] checkedLooseFiles = {
		"Scripts/SKI_ActiveEffectsWidget.pex",
		"Scripts/SKI_ConfigBase.pex",
		"Scripts/SKI_ConfigManager.pex",
		"Scripts/SKI_Main.pex",
		"Scripts/SKI_MeterWidget.pex",
		"Scripts/SKI_PlayerLoadGameAlias.pex",
		"Scripts/SKI_QuestBase.pex",
		"Scripts/SKI_StatusWidget.pex",
		"Scripts/SKI_WidgetBase.pex",
		"Scripts/SKI_WidgetManager.pex",
		"Interface/skyui_cfg.txt",
		"Interface/skyui_translate.txt",
		"Interface/bartermenu.swf",
		"Interface/containermenu.swf",
		"Interface/inventorymenu.swf",
		"Interface/magicmenu.swf",
		"Interface/skyui/inventorylists.swf",
		"Interface/skyui/tabbedinventorylists.swf",
		"Interface/skyui/skyui_icons_cat.swf",
		"Interface/skyui/skyui_icons_inv.swf",
		"Interface/skyui/skyui_icons_magic.swf"
	};

	static bool install = false;

	static int problemCount = 0;

	static List<string> foundLooseFiles = new List<string>();

	static bool noSKSE = false;
	static bool noSKSEScripts = false;
	static Version skseVersion;
	
	public static bool OnActivate()
	{
		DetectProblems();

		// Detected problems? Show report. Otherwise just install
		if (problemCount > 0) {
			InitializeComponents();
			mainInstallForm.ShowDialog(); 
		} else {
			install = true;
		}
				
		if (install)
			PerformBasicInstall();
		
		return install;
	}

	static void DetectProblems()
	{
		// Clean up previous data
		problemCount = 0;
		foundLooseFiles.Clear();
		noSKSE = false;
		noSKSEScripts = false;
		skseVersion = new Version();


		// 1. Check Loose files
 		foreach (string file in checkedLooseFiles)
 			if (GetExistingDataFile(file) != null)
 				foundLooseFiles.Add(file);

 		if (foundLooseFiles.Count > 0)
 			problemCount++;

 		// 2. Check if skse is present
 		noSKSE = !ScriptExtenderPresent();
 		if (noSKSE)
 			problemCount++;

		// 3. Check SKSE version
 		skseVersion = GetSkseVersion();
 		if (skseVersion == null || skseVersion < SKSE_MIN_VERSION)
 			problemCount++;

		// 4. Check missing SKSE.pex
		if (GetExistingDataFile("Scripts/SKSE.pex") == null) {
 			noSKSEScripts = true;
 			problemCount++;
 		}
	}

	static void GenerateReport()
	{
		int c = 0;
		textArea.Clear();

		if (problemCount == 0) {
			PrintReport("All problems have been resolved.");
			return;
		}

		PrintReport("This report informs you about potential problems with your SkyUI installation.");
		PrintReport("");
		PrintReport("Fix these problems , then press 'Refresh' to confirm that they're gone.");
		PrintReport("After all problems have been resolved, you can continue with the installation.");
		PrintReport("");

		if (foundLooseFiles.Count > 0) {
			c++;
			PrintReport("-----------");
			PrintReport("Problem #" + c + ":");
			PrintReport("-----------");
			PrintReport("There are files in your 'Data/' folder, which override newer versions from the SkyUI.bsa archive.");
			PrintReport("");
			PrintReport("These files are:");
 			foreach (string file in foundLooseFiles)
	 			PrintReport("\tData/" + file);
			PrintReport("");
	 		PrintReport("Potential causes:");
	 		PrintReport("* An old SkyUI version was not uninstalled before installing the new one.");
	 		PrintReport("");
	 		PrintReport("Solution:");
	 		PrintReport("1. If you have an old SkyUI version installed in NMM, uninstall it, then try again.");
	 		PrintReport("2. If there are still problematic files reported, delete them manually.");
	 		PrintReport("");
		}

		if (noSKSE) {
			c++;
			PrintReport("-----------");
			PrintReport("Problem #" + c + ":");
			PrintReport("-----------");
			PrintReport("The Skyrim Script Extender (SKSE) is not installed.");
	 		PrintReport("");
	 		PrintReport("Solution:");
			PrintReport("1. Get the latest SKSE version from 'http://skse.silverlock.org/' and install it.");
			PrintReport("   If you have problems installing it, have a look at this video:");
			PrintReport("   http://www.youtube.com/watch?v=xTGnQIiNVqA");

		} else if (skseVersion == null || skseVersion < SKSE_MIN_VERSION) {
			c++;
			PrintReport("-----------");
			PrintReport("Problem #" + c + ":");
			PrintReport("-----------");
			PrintReport("Your SKSE version is too old.");
			PrintReport("");
			PrintReport("Detected version: " + skseVersion);
			PrintReport("Required version: " + SKSE_MIN_VERSION + " (or newer)");
	 		PrintReport("");
	 		PrintReport("Solution:");
			PrintReport("1. Get the latest SKSE version from 'http://skse.silverlock.org/' and install it.");
			PrintReport("   If you have problems installing it, have a look at this video:");
			PrintReport("   http://www.youtube.com/watch?v=xTGnQIiNVqA");

		} else if (noSKSEScripts) {
			c++;
			PrintReport("-----------");
			PrintReport("Problem #" + c + ":");
			PrintReport("-----------");
			PrintReport("The SKSE scripts are missing.");
			PrintReport("");
			PrintReport("Potential causes:");
	 		PrintReport("* You didn't install the scripts with the rest of SKSE.");
	 		PrintReport("");
	 		PrintReport("Solution:");
			PrintReport("1. Re-install SKSE. Make sure you extract the 'Data/' folder from the downloaded archive to your Skyrim installation directory.");
		}
		

	}

	static void PrintReport(string line)
	{
		textArea.AppendText(line + "\n");
	}
	
	static void InitializeComponents()
	{
        textArea = new System.Windows.Forms.TextBox();
        refreshButton = new System.Windows.Forms.Button();
        installButton = new System.Windows.Forms.Button();
        cancelButton = new System.Windows.Forms.Button();

        // 
        // textArea
        // 
        textArea.BackColor = System.Drawing.SystemColors.ControlLightLight;
        textArea.Location = new System.Drawing.Point(12, 12);
        textArea.Font = new System.Drawing.Font("Courier New", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        textArea.Multiline = true;
        textArea.Name = "textArea";
        textArea.ReadOnly = true;
        textArea.ScrollBars = System.Windows.Forms.ScrollBars.Both;
		textArea.Size = new System.Drawing.Size(610, 439);
        textArea.TabIndex = 0;
        // 
        // refreshButton
        // 
		refreshButton.Location = new System.Drawing.Point(280, 457);
        refreshButton.Name = "refreshButton";
        refreshButton.Size = new System.Drawing.Size(75, 23);
        refreshButton.TabIndex = 1;
        refreshButton.Text = "Refresh";
        refreshButton.UseVisualStyleBackColor = true;
        refreshButton.Click += new System.EventHandler(refreshButton_Click);
        // 
        // installButton
        // 
		installButton.Location = new System.Drawing.Point(547, 457);
        installButton.Name = "installButton";
        installButton.Size = new System.Drawing.Size(75, 23);
        installButton.TabIndex = 2;
        installButton.Text = "Install";
        installButton.UseVisualStyleBackColor = true;
        installButton.Click += new System.EventHandler(installButton_Click);
        // 
        // cancelButton
        // 
		cancelButton.Location = new System.Drawing.Point(12, 457);
        cancelButton.Name = "cancelButton";
        cancelButton.Size = new System.Drawing.Size(75, 23);
        cancelButton.TabIndex = 3;
        cancelButton.Text = "Cancel";
        cancelButton.UseVisualStyleBackColor = true;
        cancelButton.Click += new System.EventHandler(cancelButton_Click);
        // 
        // mainInstallForm
        // 
		mainInstallForm = CreateCustomForm();
        mainInstallForm.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
        mainInstallForm.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
		mainInstallForm.ClientSize = new System.Drawing.Size(634, 492);
        mainInstallForm.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
        mainInstallForm.MaximizeBox = false;
		mainInstallForm.MinimizeBox = false;
        mainInstallForm.Controls.Add(installButton);
        mainInstallForm.Controls.Add(refreshButton);
        mainInstallForm.Controls.Add(cancelButton);
        mainInstallForm.Controls.Add(textArea);
        mainInstallForm.Name = "mainInstallForm";
        mainInstallForm.Text = "SkyUI Problem Report";
        mainInstallForm.Load += new System.EventHandler(mainInstallForm_Load);
	}
	
	static void installButton_Click(object sender, EventArgs e)
	{
		install = true;
		mainInstallForm.Close();
	}

	static void refreshButton_Click(object sender, EventArgs e)
	{
		DetectProblems();
		GenerateReport();
	}

	static void cancelButton_Click(object sender, EventArgs e)
	{
		install = false;
		mainInstallForm.Close();
	}

	static void mainInstallForm_Load(object sender, EventArgs e)
	{
		GenerateReport();
	}
	
	static bool IsPluginActive(String pluginName)
	{  	
		string[] loadOrder = GetActivePlugins();  
		for (int i = 0; i < loadOrder.Length; ++i) {  
			if (loadOrder[i].Equals(pluginName, StringComparison.InvariantCultureIgnoreCase)) {
				 return true;  
			}
		}  
	
		return false;  
	}
}
