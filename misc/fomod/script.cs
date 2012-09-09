
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

class Script : FalloutNewVegasBaseScript {
	const string title = "SkyUI";

	// Main dialog
	static Form mainInstallForm;
	static PictureBox logoPicture;
	static PictureBox exitButton;
	static PictureBox optionsButton;
	static PictureBox installButton;
	static PictureBox iconsButton;

	// Icons dialog
	static Form iconsForm;
	static PictureBox icons1PreviewBox;
	static PictureBox icons2PreviewBox;
	static PictureBox icons3PreviewBox;
	static PictureBox iconsButton1;
	static PictureBox iconsButton2;
	static PictureBox iconsButton3;	
	static PictureBox iconsBackButton;
	
	// Options dialog
	static Form optionsForm;
	static PictureBox optionsLabelImage;
	static Label optionsLabel2;
	static Label optionsLabel3;
	static Label optionsLabel4;
	static PictureBox optionsSelector2Left;
	static PictureBox optionsSelector3Left;
	static PictureBox optionsSelector4Left;
	static PictureBox optionsSelector2Right;
	static PictureBox optionsSelector3Right;
	static PictureBox optionsSelector4Right;
	static PictureBox optionsBackButton;
	
	// Images
	static Image imageChecked;
	static Image imageUnchecked;
	
	static Image imageLogo;
	static Image imageInstall;
	static Image imageInstallHi;
	static Image imageExit;
	static Image imageExitHi;
	static Image imageIcons;
	static Image imageIconsHi;
	static Image imageOptions;
	static Image imageOptionsHi;

	static Image imageBack;
	static Image imageBackHi;
	static Image imageIcons1Preview;
	static Image imageIcons2Preview;
	static Image imageIcons3Preview;
	
	static Image imageSelectorLeft;
	static Image imageSelectorLeftHi;
	static Image imageSelectorRight;
	static Image imageSelectorRightHi;
	static Image imageOptionLabels;
	
	// Sounds
	static System.Media.SoundPlayer hoverPlayer;
	static System.Media.SoundPlayer acceptPlayer;
	static System.Media.SoundPlayer denyPlayer;
	static System.Media.SoundPlayer selectPlayer;
	
	static bool install;
	
	// Icon state
	static int categoryIconSelected = 1;
	
	// Options state
	static string[] optionsFontSize = {"Small", "Normal", "Large"};
	static int selectedFontSize = 1;
	
	static string[] optionsRatio = {"Standard", "48:9", "48:18"};
	static int selectedRatio = 0;
	
	static bool showVWColumn = false;
	
	
	public static bool OnActivate()
	{
		InitializeComponents();
		
		mainInstallForm.ShowDialog(); 
				
		if (install) {
			installFiles();
		}
		
		return install;
	}
	
	static void installFiles()
	{
		string[] excludes = new string[] {
			"skyui_cfg.txt",
			"Interface/skyui/skyui_icons_cat.swf",
			"Interface/skyui/skyui_icons_inv.swf"
		};
		
		installMainFiles(excludes);
		installConfig();
		installIconFiles();
	}
	
	static void installMainFiles(string[] excludes)
	{
		foreach (string file in GetFomodFileList()) {
		
			// Ignore fomod/ folder
			if (file.StartsWith("fomod", true, null))
				continue;
				
			if (file.StartsWith("SkyUI Extras", true, null))
				continue;
				
			foreach (string exclude in excludes) {
				if (file.EndsWith(exclude, true, null) || file.StartsWith(exclude, true, null)) {
					continue;
				}
			}

			InstallFileFromFomod(file);
		}
	}
	
	static void installConfig()
	{
		// Install default config if generation failed
		if (! generateConfig()) {
			InstallFileFromFomod("Interface/skyui_cfg.txt");
		}
	}
	
	static bool generateConfig()
	{
		byte[] data = GetFileFromFomod("fomod/template_cfg.txt");
                
		if (data == null)            
			return false;
                
		string s = Encoding.ASCII.GetString(data);
		
		// Might be slightly ineffecient doing it like that ...
		
		// Font size
		if (selectedFontSize == 0) {
			// Small
			s = s.Replace("%T_FONTSIZE%", "13");
			s = s.Replace("%T_LABELFONTSIZE%", "12");
			s = s.Replace("%T_ICONSIZE%", "16");
			s = s.Replace("%T_EQUIPINDENT%", "-25");
			s = s.Replace("%T_EQUIPBORDER%", "<0, 10, 2, 2> ");
			s = s.Replace("%T_ICONBORDER%", "<0, 3, 2, 2>");
			s = s.Replace("%T_TEXTBORDER%", "<0, 0, 0.3, 0>");
			
		} else if (selectedFontSize == 1) {
			// Normal
			s = s.Replace("%T_FONTSIZE%", "14");
			s = s.Replace("%T_LABELFONTSIZE%", "12");
			s = s.Replace("%T_ICONSIZE%", "18");
			s = s.Replace("%T_EQUIPINDENT%", "-28");
			s = s.Replace("%T_EQUIPBORDER%", "<0, 10, 3, 3>");
			s = s.Replace("%T_ICONBORDER%", "<0, 3, 3, 3>");
			s = s.Replace("%T_TEXTBORDER%", "<0, 0, 1.1, 0>");
			
		} else {
			// Large
			s = s.Replace("%T_FONTSIZE%", "18");
			s = s.Replace("%T_LABELFONTSIZE%", "14");
			s = s.Replace("%T_ICONSIZE%", "20");
			s = s.Replace("%T_EQUIPINDENT%", "-30");
			s = s.Replace("%T_EQUIPBORDER%", "<0, 10, 3.2, 3.2>");
			s = s.Replace("%T_ICONBORDER%", "<0, 4, 3.2, 3.2>");
			s = s.Replace("%T_TEXTBORDER%", "<0, 0, 0.4, 0>");
		}
		
		// Ratio
		if (selectedRatio == 0) {
			s = s.Replace("%T_ICALIGN%", "center");
			s = s.Replace("%T_ICXOFFSET%", "0");
			s = s.Replace("%T_IIXOFFSET%", "0");
			s = s.Replace("%T_IIYOFFSET%", "0");
			s = s.Replace("%T_IIYSCALE%", "1.5");
		} else if (selectedRatio == 1) {
			s = s.Replace("%T_ICALIGN%", "right");
			s = s.Replace("%T_ICXOFFSET%", "-60");
			s = s.Replace("%T_IIXOFFSET%", "50");
			s = s.Replace("%T_IIYOFFSET%", "-12");
			s = s.Replace("%T_IIYSCALE%", "0.8");
		} else {
			s = s.Replace("%T_ICALIGN%", "right");
			s = s.Replace("%T_ICXOFFSET%", "-22");
			s = s.Replace("%T_IIXOFFSET%", "42");
			s = s.Replace("%T_IIYOFFSET%", "-12");
			s = s.Replace("%T_IIYSCALE%", "1.5");
		}
		
		// V/W Column
		if (showVWColumn) {
			s = s.Replace("%T_VALUECOLWEIGHT%", "0.2");
			s = s.Replace("%T_VALUESTATES%", "2");
			s = s.Replace("%T_VALUECOLS%", "valueColumn, valueWeightColumn");
			
		} else {
			s = s.Replace("%T_VALUECOLWEIGHT%", "0.1");
			s = s.Replace("%T_VALUESTATES%", "4");
			s = s.Replace("%T_VALUECOLS%", "valueColumn");
		}
		
		Byte[] newData = Encoding.ASCII.GetBytes(s);
		GenerateDataFile("Interface/skyui_cfg.txt", newData);
		
		return true;
	}
	
	static void installIconFiles()
	{
		if (categoryIconSelected == 1) {
			CopyDataFile("SkyUI Extras/Icon Themes/Straight, by T3T/skyui_icons_cat.swf", "Interface/skyui/skyui_icons_cat.swf");
			CopyDataFile("SkyUI Extras/Icon Themes/Straight, by T3T/skyui_icons_inv.swf", "Interface/skyui/skyui_icons_inv.swf");
		} else if (categoryIconSelected == 2) {
			CopyDataFile("SkyUI Extras/Icon Themes/Curved, by T3T/skyui_icons_cat.swf", "Interface/skyui/skyui_icons_cat.swf");
			CopyDataFile("SkyUI Extras/Icon Themes/Curved, by T3T/skyui_icons_inv.swf", "Interface/skyui/skyui_icons_inv.swf");
		} else {
			CopyDataFile("SkyUI Extras/Icon Themes/Celtic, by GreatClone/skyui_icons_cat.swf", "Interface/skyui/skyui_icons_cat.swf");
			CopyDataFile("SkyUI Extras/Icon Themes/Celtic, by GreatClone/skyui_icons_inv.swf", "Interface/skyui/skyui_icons_inv.swf");
		}
	}
	
	static void InitializeComponents()
	{
		InitializeAudio();		
		InitializeImages();
		
		InitializeMainForm();
		InitializeIconsForm();
		InitializeOptionsForm();
	}
	
	static void InitializeMainForm()
	{
		// Logo
		logoPicture = new System.Windows.Forms.PictureBox();	   
		logoPicture.BackColor = System.Drawing.Color.Transparent;
		logoPicture.Image = imageLogo;
		logoPicture.Location = new System.Drawing.Point(12, 12);
		logoPicture.Name = "logoBox";
		logoPicture.Size = new System.Drawing.Size(330, 538);
		logoPicture.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		logoPicture.TabIndex = 0;
		logoPicture.TabStop = false;
		
		// Install button
		installButton = new System.Windows.Forms.PictureBox();
		installButton.Anchor = System.Windows.Forms.AnchorStyles.None;
		installButton.Image = imageInstall;
		installButton.Location = new System.Drawing.Point(438, 251);
		installButton.Name = "installButton";
		installButton.Size = new System.Drawing.Size(234, 40);
		installButton.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		installButton.TabIndex = 3;
		installButton.TabStop = false;
		installButton.Click += new System.EventHandler(installButton_Click);
		installButton.MouseEnter += new System.EventHandler(installButton_MouseEnter);
		installButton.MouseLeave += new System.EventHandler(installButton_MouseLeave);

		// Options button
	 	optionsButton = new System.Windows.Forms.PictureBox();
		optionsButton.Image = imageOptions;
		optionsButton.Location = new System.Drawing.Point(480, 324);
		optionsButton.Name = "optionsButton";
		optionsButton.Size = new System.Drawing.Size(192, 28);
		optionsButton.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		optionsButton.TabIndex = 6;
		optionsButton.TabStop = false;
		optionsButton.Click += new System.EventHandler(optionsButton_Click);
		optionsButton.MouseEnter += new System.EventHandler(optionsButton_MouseEnter);
		optionsButton.MouseLeave += new System.EventHandler(optionsButton_MouseLeave);
		
		// Icons button
	 	iconsButton = new System.Windows.Forms.PictureBox();
		iconsButton.Image = imageIcons;
		iconsButton.Location = new System.Drawing.Point(526, 370);
		iconsButton.Name = "iconsButton";
		iconsButton.Size = new System.Drawing.Size(146, 28);
		iconsButton.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		iconsButton.TabIndex = 6;
		iconsButton.TabStop = false;
		iconsButton.Click += new System.EventHandler(iconsButton_Click);
		iconsButton.MouseEnter += new System.EventHandler(iconsButton_MouseEnter);
		iconsButton.MouseLeave += new System.EventHandler(iconsButton_MouseLeave);		
	
		// Exit button
		exitButton = new System.Windows.Forms.PictureBox();
		exitButton.Image = imageExit;
		exitButton.Location = new System.Drawing.Point(563, 522);
		exitButton.Name = "exitButton";
		exitButton.Size = new System.Drawing.Size(109, 28);
		exitButton.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		exitButton.TabIndex = 2;
		exitButton.TabStop = false;
		exitButton.Click += new System.EventHandler(exitButton_Click);
		exitButton.MouseEnter += new System.EventHandler(exitButton_MouseEnter);
		exitButton.MouseLeave += new System.EventHandler(exitButton_MouseLeave);	
		
		SetupMainForm();
	}

	static void SetupMainForm()
	{		
		mainInstallForm = CreateCustomForm();
		
		mainInstallForm.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
		mainInstallForm.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
		mainInstallForm.BackColor = System.Drawing.Color.Black;
		mainInstallForm.ClientSize = new System.Drawing.Size(684, 562);
		
        mainInstallForm.MaximizeBox = false;
		mainInstallForm.MinimizeBox = false;
        mainInstallForm.MaximumSize = new System.Drawing.Size(700, 600);
        mainInstallForm.MinimumSize = new System.Drawing.Size(700, 600);
		
		mainInstallForm.Controls.Add(optionsButton);
		mainInstallForm.Controls.Add(iconsButton);
		mainInstallForm.Controls.Add(installButton);
		mainInstallForm.Controls.Add(exitButton);
		mainInstallForm.Controls.Add(logoPicture);
		mainInstallForm.Name = "MainForm";
		mainInstallForm.Text = "SkyUI";
	}
	
	static void InitializeIconsForm()
	{
		// Option 1
		iconsButton1 = new System.Windows.Forms.PictureBox();
		iconsButton1.Image = imageIcons1Preview;
		if (categoryIconSelected == 1) {
			iconsButton1.Image = imageChecked;
		} else {
			iconsButton1.Image = imageUnchecked;
		}
		iconsButton1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		iconsButton1.Location = new System.Drawing.Point(12, 25);
		iconsButton1.Name = "iconsButton1";
		iconsButton1.Size = new System.Drawing.Size(64, 64);
		iconsButton1.TabIndex = 7;
		iconsButton1.TabStop = false;
		iconsButton1.Click += new System.EventHandler(iconsButton1_Click);	
		
		icons1PreviewBox = new System.Windows.Forms.PictureBox();
		icons1PreviewBox.Anchor = System.Windows.Forms.AnchorStyles.None;
	   	icons1PreviewBox.Image = imageIcons1Preview;
		icons1PreviewBox.Location = new System.Drawing.Point(82, 14);
		icons1PreviewBox.Name = "icons1PreviewBox";
		icons1PreviewBox.Size = new System.Drawing.Size(550, 75);
		icons1PreviewBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		icons1PreviewBox.TabIndex = 8;
		icons1PreviewBox.TabStop = false; 
		
		// Option 2
		iconsButton2 = new System.Windows.Forms.PictureBox();
		if (categoryIconSelected == 2) {
			iconsButton2.Image = imageChecked;
		} else {
			iconsButton2.Image = imageUnchecked;
		}
		iconsButton2.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		iconsButton2.Location = new System.Drawing.Point(12, 106);
		iconsButton2.Name = "iconsButton2";
		iconsButton2.Size = new System.Drawing.Size(64, 64);
		iconsButton2.TabIndex = 9;
		iconsButton2.TabStop = false;
		iconsButton2.Click += new System.EventHandler(iconsButton2_Click);		
	
		icons2PreviewBox = new System.Windows.Forms.PictureBox();
		icons2PreviewBox.Anchor = System.Windows.Forms.AnchorStyles.None;
		icons2PreviewBox.Image = imageIcons2Preview;
		icons2PreviewBox.Location = new System.Drawing.Point(82, 95);
		icons2PreviewBox.Name = "icons2PreviewBox";
		icons2PreviewBox.Size = new System.Drawing.Size(550, 75);
		icons2PreviewBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		icons2PreviewBox.TabIndex = 10;
		icons2PreviewBox.TabStop = false;
		
		// Option 3
		iconsButton3 = new System.Windows.Forms.PictureBox();
		if (categoryIconSelected == 3) {
			iconsButton3.Image = imageChecked;
		} else {
			iconsButton3.Image = imageUnchecked;
		}
		iconsButton3.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		iconsButton3.Location = new System.Drawing.Point(12, 187);
		iconsButton3.Name = "iconsButton3";
		iconsButton3.Size = new System.Drawing.Size(64, 64);
		iconsButton3.TabIndex = 11;
		iconsButton3.TabStop = false;
		iconsButton3.Click += new System.EventHandler(iconsButton3_Click);	
	
		icons3PreviewBox = new System.Windows.Forms.PictureBox();
		icons3PreviewBox.Anchor = System.Windows.Forms.AnchorStyles.None;
		icons3PreviewBox.Image = imageIcons3Preview;
		icons3PreviewBox.Location = new System.Drawing.Point(82, 176);
		icons3PreviewBox.Name = "icons3PreviewBox";
		icons3PreviewBox.Size = new System.Drawing.Size(550, 75);
		icons3PreviewBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		icons3PreviewBox.TabIndex = 12;
		icons3PreviewBox.TabStop = false;
		
		// Back button
		iconsBackButton = new System.Windows.Forms.PictureBox(); 
		iconsBackButton.Image = imageBack;
		iconsBackButton.Location = new System.Drawing.Point(263, 288);
		iconsBackButton.Name = "iconsBackButton";
		iconsBackButton.Size = new System.Drawing.Size(119, 22);
		iconsBackButton.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		iconsBackButton.TabIndex = 13;
		iconsBackButton.TabStop = false;
		iconsBackButton.Click += new System.EventHandler(closeIconsFormButton_Click);
		iconsBackButton.MouseEnter += new System.EventHandler(closeIconsFormButton_MouseEnter);
		iconsBackButton.MouseLeave += new System.EventHandler(closeIconsFormButton_MouseLeave);	
		
		SetupIconsForm();
	}
	
	static void SetupIconsForm()
	{		
		iconsForm = CreateCustomForm();

		iconsForm.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
		iconsForm.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
		iconsForm.BackColor = System.Drawing.Color.Black;
		iconsForm.ClientSize = new System.Drawing.Size(644, 322);
		iconsForm.Controls.Add(iconsBackButton);
		iconsForm.Controls.Add(icons1PreviewBox);
		iconsForm.Controls.Add(iconsButton1);
		iconsForm.Controls.Add(icons2PreviewBox);
		iconsForm.Controls.Add(iconsButton2);
		iconsForm.Controls.Add(icons3PreviewBox);
		iconsForm.Controls.Add(iconsButton3);
		iconsForm.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
		iconsForm.Name = "IconsForm";
		iconsForm.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
		iconsForm.Text = "Icons";
	}
	
	static void InitializeOptionsForm()
	{
		// Left side label image
		optionsLabelImage = new System.Windows.Forms.PictureBox();
		optionsLabelImage.Image = imageOptionLabels;
		optionsLabelImage.Location = new System.Drawing.Point(12, 12);
		optionsLabelImage.Name = "optionsLabelImage";
		optionsLabelImage.Size = new System.Drawing.Size(300, 150);
		optionsLabelImage.TabIndex = 29;
		optionsLabelImage.TabStop = false;	
		
		// Font Size Option
		optionsLabel2 = new System.Windows.Forms.Label();
		optionsLabel2.Font = new System.Drawing.Font("Arial", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
		optionsLabel2.ForeColor = System.Drawing.SystemColors.ControlLightLight;
		optionsLabel2.Location = new System.Drawing.Point(409, 19);
		optionsLabel2.Name = "optionsLabel2";
		optionsLabel2.Size = new System.Drawing.Size(150, 27);
		optionsLabel2.TabIndex = 16;
		optionsLabel2.Text = optionsFontSize[selectedFontSize];
		optionsLabel2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
		optionsLabel2.Click += new System.EventHandler(optionsFontSizeNext_Click);
		
		optionsSelector2Left = new System.Windows.Forms.PictureBox();
		optionsSelector2Left.Image = imageSelectorLeft;
		optionsSelector2Left.Location = new System.Drawing.Point(355, 12);
		optionsSelector2Left.Name = "optionsSelector2Left";
		optionsSelector2Left.Size = new System.Drawing.Size(33, 41);
		optionsSelector2Left.TabIndex = 14;
		optionsSelector2Left.Click += new System.EventHandler(optionsFontSizePrev_Click);
		optionsSelector2Left.MouseEnter += new System.EventHandler(leftSelector_MouseEnter);
		optionsSelector2Left.MouseLeave += new System.EventHandler(leftSelector_MouseLeave);	
		
		optionsSelector2Right = new System.Windows.Forms.PictureBox();
		optionsSelector2Right.Image = imageSelectorRight;
		optionsSelector2Right.Location = new System.Drawing.Point(565, 12);
		optionsSelector2Right.Name = "optionsSelector2Right";
		optionsSelector2Right.Size = new System.Drawing.Size(48, 39);
		optionsSelector2Right.TabIndex = 15;
		optionsSelector2Right.Click += new System.EventHandler(optionsFontSizeNext_Click);
		optionsSelector2Right.MouseEnter += new System.EventHandler(rightSelector_MouseEnter);
		optionsSelector2Right.MouseLeave += new System.EventHandler(rightSelector_MouseLeave);
		
		// Ratio Option
		optionsLabel3 = new System.Windows.Forms.Label();
		optionsLabel3.Font = new System.Drawing.Font("Arial", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
		optionsLabel3.ForeColor = System.Drawing.SystemColors.ControlLightLight;
		optionsLabel3.Location = new System.Drawing.Point(409, 69);
		optionsLabel3.Name = "optionsLabel3";
		optionsLabel3.Size = new System.Drawing.Size(150, 27);
		optionsLabel3.TabIndex = 16;
		optionsLabel3.Text = optionsRatio[selectedRatio];
		optionsLabel3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
		optionsLabel3.Click += new System.EventHandler(optionsRatioNext_Click);
		
		optionsSelector3Left = new System.Windows.Forms.PictureBox();
		optionsSelector3Left.Image = imageSelectorLeft;
		optionsSelector3Left.Location = new System.Drawing.Point(355, 62);
		optionsSelector3Left.Name = "optionsSelector3Left";
		optionsSelector3Left.Size = new System.Drawing.Size(33, 41);
		optionsSelector3Left.TabIndex = 14;
		optionsSelector3Left.Click += new System.EventHandler(optionsRatioPrev_Click);
		optionsSelector3Left.MouseEnter += new System.EventHandler(leftSelector_MouseEnter);
		optionsSelector3Left.MouseLeave += new System.EventHandler(leftSelector_MouseLeave);	
		
		optionsSelector3Right = new System.Windows.Forms.PictureBox();
		optionsSelector3Right.Image = imageSelectorRight;
		optionsSelector3Right.Location = new System.Drawing.Point(565, 62);
		optionsSelector3Right.Name = "optionsSelector3Right";
		optionsSelector3Right.Size = new System.Drawing.Size(48, 39);
		optionsSelector3Right.TabIndex = 15;
		optionsSelector3Right.Click += new System.EventHandler(optionsRatioNext_Click);
		optionsSelector3Right.MouseEnter += new System.EventHandler(rightSelector_MouseEnter);
		optionsSelector3Right.MouseLeave += new System.EventHandler(rightSelector_MouseLeave);	
		
		// VW Column Option
		optionsLabel4 = new System.Windows.Forms.Label();
		optionsLabel4.Font = new System.Drawing.Font("Arial", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
		optionsLabel4.ForeColor = System.Drawing.SystemColors.ControlLightLight;
		optionsLabel4.Location = new System.Drawing.Point(409, 119);
		optionsLabel4.Name = "optionsLabel4";
		optionsLabel4.Size = new System.Drawing.Size(150, 27);
		optionsLabel4.TabIndex = 16;
		optionsLabel4.Text = showVWColumn? "Yes" : "No";
		optionsLabel4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
		optionsLabel4.Click += new System.EventHandler(optionsVWColumn_Click);
		
		optionsSelector4Left = new System.Windows.Forms.PictureBox();
		optionsSelector4Left.Image = imageSelectorLeft;
		optionsSelector4Left.Location = new System.Drawing.Point(355, 112);
		optionsSelector4Left.Name = "optionsSelector3Left";
		optionsSelector4Left.Size = new System.Drawing.Size(33, 41);
		optionsSelector4Left.TabIndex = 14;
		optionsSelector4Left.Click += new System.EventHandler(optionsVWColumn_Click);
		optionsSelector4Left.MouseEnter += new System.EventHandler(leftSelector_MouseEnter);
		optionsSelector4Left.MouseLeave += new System.EventHandler(leftSelector_MouseLeave);	
		
		optionsSelector4Right = new System.Windows.Forms.PictureBox();
		optionsSelector4Right.Image = imageSelectorRight;
		optionsSelector4Right.Location = new System.Drawing.Point(565, 112);
		optionsSelector4Right.Name = "optionsSelector3Right";
		optionsSelector4Right.Size = new System.Drawing.Size(48, 39);
		optionsSelector4Right.TabIndex = 15;
		optionsSelector4Right.Click += new System.EventHandler(optionsVWColumn_Click);
		optionsSelector4Right.MouseEnter += new System.EventHandler(rightSelector_MouseEnter);
		optionsSelector4Right.MouseLeave += new System.EventHandler(rightSelector_MouseLeave);
		
		// Back button
		optionsBackButton = new System.Windows.Forms.PictureBox();
		optionsBackButton.Image = imageBack;
		optionsBackButton.Location = new System.Drawing.Point(253, 194);
		optionsBackButton.Name = "optionsBackButton";
		optionsBackButton.Size = new System.Drawing.Size(119, 22);
		optionsBackButton.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		optionsBackButton.TabIndex = 13;
		optionsBackButton.TabStop = false;
		optionsBackButton.Click += new System.EventHandler(optionsBackButton_Click);
		optionsBackButton.MouseEnter += new System.EventHandler(optionsBackButton_MouseEnter);
		optionsBackButton.MouseLeave += new System.EventHandler(optionsBackButton_MouseLeave);	
		
		SetupOptionsForm();
	}	
	
	static void SetupOptionsForm()
	{		
		optionsForm = CreateCustomForm();

		optionsForm.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
		optionsForm.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
		optionsForm.BackColor = System.Drawing.Color.Black;
		optionsForm.ClientSize = new System.Drawing.Size(625, 228);
		optionsForm.Controls.Add(optionsLabelImage);
		optionsForm.Controls.Add(optionsLabel2);
		optionsForm.Controls.Add(optionsSelector2Left);
		optionsForm.Controls.Add(optionsSelector2Right);
		optionsForm.Controls.Add(optionsLabel3);
		optionsForm.Controls.Add(optionsSelector3Left);
		optionsForm.Controls.Add(optionsSelector3Right);
		optionsForm.Controls.Add(optionsLabel4);
		optionsForm.Controls.Add(optionsSelector4Left);
		optionsForm.Controls.Add(optionsSelector4Right);
		optionsForm.Controls.Add(optionsBackButton);
		optionsForm.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
		optionsForm.Name = "OptionsForm";
		optionsForm.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
		optionsForm.Text = "Options";
	}

	static void InitializeImages()
	{	
		// Common
		imageChecked = GetImageFromFomod("fomod/InstallerChecked.png");
		imageUnchecked = GetImageFromFomod("fomod/InstallerUnchecked.png");
		
		imageSelectorLeft = GetImageFromFomod("fomod/SelectorLeft.png");
		imageSelectorLeftHi = GetImageFromFomod("fomod/SelectorLeftHi.png");
		imageSelectorRight = GetImageFromFomod("fomod/SelectorRight.png");
		imageSelectorRightHi = GetImageFromFomod("fomod/SelectorRightHi.png");
		
		imageBack = GetImageFromFomod("fomod/Back.png");
		imageBackHi = GetImageFromFomod("fomod/BackHi.png");		
		
		// Main
		imageLogo = GetImageFromFomod("fomod/logo600.png");
		imageInstall = GetImageFromFomod("fomod/Install.png");
		imageInstallHi = GetImageFromFomod("fomod/InstallHi.png");
		imageIcons = GetImageFromFomod("fomod/Icons.png");
		imageIconsHi = GetImageFromFomod("fomod/IconsHi.png");
		imageOptions = GetImageFromFomod("fomod/Options.png");
		imageOptionsHi = GetImageFromFomod("fomod/OptionsHi.png");
		imageExit = GetImageFromFomod("fomod/Exit.png");
		imageExitHi = GetImageFromFomod("fomod/ExitHi.png");
		
		
		// Icons
		imageIcons1Preview = GetImageFromFomod("fomod/t3t_alt_1.png");
		imageIcons2Preview = GetImageFromFomod("fomod/t3t_alt_2.png");
		imageIcons3Preview = GetImageFromFomod("fomod/celtic.png");
		
		// Options
		imageOptionLabels = GetImageFromFomod("fomod/OptionLabels.png");
	}

	static void InitializeAudio()
	{
		hoverPlayer = new System.Media.SoundPlayer();
		acceptPlayer = new System.Media.SoundPlayer();
		denyPlayer = new System.Media.SoundPlayer();
		selectPlayer = new System.Media.SoundPlayer();
	
		hoverPlayer.Stream = GetStreamFromFomod("fomod/ui_menu_focus.wav");
		acceptPlayer.Stream = GetStreamFromFomod("fomod/ui_menu_ok.wav");
		denyPlayer.Stream = GetStreamFromFomod("fomod/ui_menu_cancel.wav");
		selectPlayer.Stream = GetStreamFromFomod("fomod/ui_menu_prevnext.wav");
	}
	
	static void installButton_MouseEnter(object sender, EventArgs e)
	{
		installButton.Image = imageInstallHi;
		hoverPlayer.Play();
	}
	
	static void installButton_MouseLeave(object sender, EventArgs e)
	{
		installButton.Image = imageInstall;
	}
	
	static void installButton_Click(object sender, EventArgs e)
	{
		acceptPlayer.Play();
		install = true;
		mainInstallForm.Close();
	}
	
	static void optionsButton_MouseEnter(object sender, EventArgs e)
	{
		optionsButton.Image = imageOptionsHi;
		hoverPlayer.Play();
	}
	
	static void optionsButton_MouseLeave(object sender, EventArgs e)
	{
		optionsButton.Image = imageOptions;
	}
	
	static void optionsButton_Click(object sender, EventArgs e)
	{
		acceptPlayer.Play();
		optionsForm.ShowDialog();
	}

	static void iconsButton_MouseEnter(object sender, EventArgs e)
	{
		iconsButton.Image = imageIconsHi;
		hoverPlayer.Play();
	}

	static void iconsButton_MouseLeave(object sender, EventArgs e)
	{
		iconsButton.Image = imageIcons;
	}

	static void iconsButton_Click(object sender, EventArgs e)
	{
		acceptPlayer.Play();
		iconsForm.ShowDialog();
	}

	static void exitButton_MouseEnter(object sender, EventArgs e)
	{
		exitButton.Image = imageExitHi;
		hoverPlayer.Play();
	}

	static void exitButton_MouseLeave(object sender, EventArgs e)
	{
		exitButton.Image = imageExit;
	}

	static void exitButton_Click(object sender, EventArgs e)
	{
		denyPlayer.Play();
		mainInstallForm.Close();
	}
	
	static void optionsBackButton_MouseEnter(object sender, EventArgs e)
	{
		optionsBackButton.Image = imageBackHi;
		hoverPlayer.Play();
	}

	static void optionsBackButton_MouseLeave(object sender, EventArgs e)
	{
		optionsBackButton.Image = imageBack;
	}

	static void optionsBackButton_Click(object sender, EventArgs e)
	{
		denyPlayer.Play();
		optionsForm.Close();
	}
	
	static void leftSelector_MouseEnter(object sender, EventArgs e)
	{
		((PictureBox)sender).Image = imageSelectorLeftHi;
		hoverPlayer.Play();
	}

	static void leftSelector_MouseLeave(object sender, EventArgs e)
	{
		((PictureBox)sender).Image = imageSelectorLeft;
	}
	
	static void rightSelector_MouseEnter(object sender, EventArgs e)
	{
		((PictureBox)sender).Image = imageSelectorRightHi;
		hoverPlayer.Play();
	}

	static void rightSelector_MouseLeave(object sender, EventArgs e)
	{
		((PictureBox)sender).Image = imageSelectorRight;
	}
	
	static void optionsFontSizePrev_Click(object sender, EventArgs e)
	{
		selectPlayer.Play();

		if (selectedFontSize > 0)
			selectedFontSize--;
		else
			selectedFontSize = optionsFontSize.Length-1;
		
		optionsLabel2.Text = optionsFontSize[selectedFontSize];
	}
	
	static void optionsFontSizeNext_Click(object sender, EventArgs e)
	{
		selectPlayer.Play();

		if (selectedFontSize < optionsFontSize.Length-1)
			selectedFontSize++;
		else
			selectedFontSize = 0;
		
		optionsLabel2.Text = optionsFontSize[selectedFontSize];
	}
	
	static void optionsRatioPrev_Click(object sender, EventArgs e)
	{
		selectPlayer.Play();

		if (selectedRatio > 0)
			selectedRatio--;
		else
			selectedRatio = optionsRatio.Length-1;
		
		optionsLabel3.Text = optionsRatio[selectedRatio];
	}
	
	static void optionsRatioNext_Click(object sender, EventArgs e)
	{
		selectPlayer.Play();

		if (selectedRatio < optionsRatio.Length-1)
			selectedRatio++;
		else
			selectedRatio = 0;
		
		optionsLabel3.Text = optionsRatio[selectedRatio];
	}
	
	static void optionsVWColumn_Click(object sender, EventArgs e)
	{
		selectPlayer.Play();

		showVWColumn = !showVWColumn;
		optionsLabel4.Text = showVWColumn? "Yes" : "No";
	}
	
	static void iconsButton1_Click(object sender, EventArgs e)
	{
		selectPlayer.Play();

		iconsButton1.Image = imageChecked;
		iconsButton2.Image = imageUnchecked;
		iconsButton3.Image = imageUnchecked;
		
		categoryIconSelected = 1;
	}

	static void iconsButton2_Click(object sender, EventArgs e)
	{
		selectPlayer.Play();

		iconsButton1.Image = imageUnchecked;
		iconsButton2.Image = imageChecked;
		iconsButton3.Image = imageUnchecked;
		
		categoryIconSelected = 2;
	}

	static void iconsButton3_Click(object sender, EventArgs e)
	{
		selectPlayer.Play();

		iconsButton1.Image = imageUnchecked;
		iconsButton2.Image = imageUnchecked;
		iconsButton3.Image = imageChecked;
		
		categoryIconSelected = 3;
	}

	static void closeIconsFormButton_MouseEnter(object sender, EventArgs e)
	{
		iconsBackButton.Image = imageBackHi;
		hoverPlayer.Play();
	}

	static void closeIconsFormButton_MouseLeave(object sender, EventArgs e)
	{
		iconsBackButton.Image = imageBack;
	}

	static void closeIconsFormButton_Click(object sender, EventArgs e)
	{
		denyPlayer.Play();
		iconsForm.Close();
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
	
	static Image GetImageFromFomod(string filename)
	{  
		byte[] data = GetFileFromFomod(filename);  
		MemoryStream s = new MemoryStream(data);  
		Image img = Image.FromStream(s);  
		s.Close();  
		
		return img;  
	} 
	
	static Stream GetStreamFromFomod(string filename)
	{  
		byte[] data = GetFileFromFomod(filename);
		
		if (data == null)
			return null;
			
		return new MemoryStream(data);
	}
}
