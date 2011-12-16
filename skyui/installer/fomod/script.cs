
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

class Script : FalloutNewVegasBaseScript {
	const string title = "SkyUI";

	static ASCIIEncoding encoding;

	static Form mainInstallForm;
	static PictureBox logoPicture;
	static PictureBox exitButton;
	static PictureBox installButton;
	static PictureBox iconsButton;

	static Form iconsForm;
	static PictureBox icons1PreviewBox;
	static PictureBox icons2PreviewBox;
	static PictureBox icons3PreviewBox;
	static PictureBox iconsButton1;
	static PictureBox iconsButton2;
	static PictureBox iconsButton3;	
	
	
	static PictureBox iconsBackButton;
	
	static Image imageChecked;
	static Image imageUnchecked;
	
	static Image imageLogo;
	static Image imageInstall;
	static Image imageInstallHi;
	static Image imageExit;
	static Image imageExitHi;
	static Image imageIcons;
	static Image imageIconsHi;

	static Image imageBack;
	static Image imageBackHi;
	static Image imageIcons1Preview;
	static Image imageIcons2Preview;
	static Image imageIcons3Preview;
	
	static System.Media.SoundPlayer hoverPlayer;
	static System.Media.SoundPlayer acceptPlayer;
	static System.Media.SoundPlayer denyPlayer;
	
	static bool install;
	
	static int categoryIconSelected;
	
	static int DEFAULT_CATEGORY_ICON = 1;
	
	static String FONT_CONFIG_FILE = "Interface/fontconfig.txt";

	public static bool OnActivate() {
		encoding = new ASCIIEncoding();	
		
		setDefaults();
		
		InitializeComponents();
		
		mainInstallForm.ShowDialog(); 
				
		if (install) {
			installFiles();
		}
		
		return install;
	}
	
	static void setDefaults() {
		categoryIconSelected = DEFAULT_CATEGORY_ICON;
	}
	
	static void installFiles() {
		installMainFiles();
		installIconFiles();
		installFontConfig();
		installSKSEPlugin();
	}	

	static void installSKSEPlugin() {
		InstallFileFromFomod("SKSE/Plugins/gibbed_interface_extensions.dll");
	}
	
	static void installMainFiles() {
		InstallFileFromFomod("Interface/inventorymenu.swf");
		InstallFileFromFomod("Interface/skyui_icons_inv.swf");
		InstallFileFromFomod("Interface/skyui.cfg");
		
		InstallFileFromFomod("Interface/skyui/inventorylists.swf");
	}
	
	static void installIconFiles() {
		if (categoryIconSelected == 1) {
			CopyDataFile("SkyUI Extras/Category Icon Themes/Straight, by T3T/skyui_icons_cat.swf", "Interface/skyui_icons_cat.swf");
		} else if (categoryIconSelected == 2) {
			CopyDataFile("SkyUI Extras/Category Icon Themes/Curved, by T3T/skyui_icons_cat.swf", "Interface/skyui_icons_cat.swf");
		} else {
			CopyDataFile("SkyUI Extras/Category Icon Themes/Celtic, by GreatClone/skyui_icons_cat.swf", "Interface/skyui_icons_cat.swf");
		}
	}
	
	static bool installFontConfig() {		
		if (! DataFileExists(FONT_CONFIG_FILE)) {
			return InstallFileFromFomod(FONT_CONFIG_FILE);
		} else {

			bool editSuccess = UpdateFontConfig();
		
			if (! editSuccess) {
				MessageBox("Failed to access " + FONT_CONFIG_FILE + ". Reinstall the mod with all other applications closed, or try a manual installation (see readme).", title);
			}
			
			return editSuccess;
		}
	}

	
	static bool UpdateFontConfig()
	{
		byte[] data = GetExistingDataFile(FONT_CONFIG_FILE);
		
		if (data == null)
			return false;
		
		string tmp = encoding.GetString(data);
		
		// Include is already there?
		if (Regex.Match(tmp, "map \"" + Regex.Escape("$") + "ListFont\" = ", RegexOptions.Singleline).Success == true)
			return true;
		
		tmp += "\r\n\r\n"
			+ "map \"$ListFont\" = \"Futura Condensed\" Normal";
		
		data = encoding.GetBytes(tmp);
			
		GenerateDataFile(FONT_CONFIG_FILE, data);
		
		return true;
	}
	
	static void InitializeComponents()
	{
		InitializeAudio();		
		InitializeImages();
		
		InitializeMainForm();
		InitializeIconsForm();
	}
	
	static void InitializeMainForm() {
		InitializeLogo();
		InitializeInstallButton(); 
		InitializeIconsButton();	
		InitializeExitButton();
		
		SetupMainForm();
	}

	static void SetupMainForm() {		
		mainInstallForm = CreateCustomForm();
		
		mainInstallForm.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
		mainInstallForm.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
		mainInstallForm.BackColor = System.Drawing.Color.Black;
		mainInstallForm.ClientSize = new System.Drawing.Size(684, 562);
		mainInstallForm.Controls.Add(iconsButton);
		mainInstallForm.Controls.Add(installButton);
		mainInstallForm.Controls.Add(exitButton);
		mainInstallForm.Controls.Add(logoPicture);
		mainInstallForm.Name = "MainForm";
		mainInstallForm.Text = "SkyUI";
	}
	
	static void InitializeLogo() {
		logoPicture = new System.Windows.Forms.PictureBox();	   
		logoPicture.BackColor = System.Drawing.Color.Transparent;
		logoPicture.Image = imageLogo;
		logoPicture.Location = new System.Drawing.Point(12, 12);
		logoPicture.Name = "logoBox";
		logoPicture.Size = new System.Drawing.Size(330, 538);
		logoPicture.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		logoPicture.TabIndex = 0;
		logoPicture.TabStop = false;		
	}

	static void InitializeInstallButton() {
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
	}

	static void InitializeIconsButton() {
	 	iconsButton = new System.Windows.Forms.PictureBox();
		iconsButton.Image = imageIcons;
		iconsButton.Location = new System.Drawing.Point(526, 324);
		iconsButton.Name = "iconsButton";
		iconsButton.Size = new System.Drawing.Size(146, 28);
		iconsButton.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
		iconsButton.TabIndex = 6;
		iconsButton.TabStop = false;
		iconsButton.Click += new System.EventHandler(iconsButton_Click);
		iconsButton.MouseEnter += new System.EventHandler(iconsButton_MouseEnter);
		iconsButton.MouseLeave += new System.EventHandler(iconsButton_MouseLeave);		 
	}
	
	static void InitializeExitButton() {
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
	}
	
	static void InitializeIconsForm() {
		InitializeIconsOption1();
		InitializeIconsOption2();
		InitializeIconsOption3();
		InitializeIconsBackButton();
		
		SetupIconsForm();
	}

	static void InitializeIconsOption1() {  
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
	}

	static void InitializeIconsOption2() {
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
	}
	
	static void InitializeIconsOption3() {
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
	}

	static void InitializeIconsBackButton() {
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
	}
	
	static void SetupIconsForm() {		
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

	static void InitializeImages()
	{	
		InitializeCommonImages();
		InitializeMainImages();
		InitializeIconOptionsImages();
	}

	static void InitializeCommonImages()
	{	
		imageChecked = GetImageFromFomod("InstallerChecked.png");
		imageUnchecked = GetImageFromFomod("InstallerUnchecked.png");
	}

	static void InitializeMainImages()
	{	
		imageLogo = GetImageFromFomod("fomod/logo600.png");
	
		imageInstall = GetImageFromFomod("fomod/Install.png");
		imageInstallHi = GetImageFromFomod("fomod/InstallHi.png");
		imageIcons = GetImageFromFomod("fomod/Icons.png");
		imageIconsHi = GetImageFromFomod("fomod/IconsHi.png");
		imageExit = GetImageFromFomod("fomod/Exit.png");
		imageExitHi = GetImageFromFomod("fomod/ExitHi.png");
	}
	
	static void InitializeIconOptionsImages()
	{	
		imageBack = GetImageFromFomod("fomod/Back.png");
		imageBackHi = GetImageFromFomod("fomod/BackHi.png");		

		imageIcons1Preview = GetImageFromFomod("fomod/t3t_alt_1.png");
		imageIcons2Preview = GetImageFromFomod("fomod/t3t_alt_2.png");
		imageIcons3Preview = GetImageFromFomod("fomod/celtic.png");
	}

	static void InitializeAudio()
	{
		hoverPlayer = new System.Media.SoundPlayer();
		acceptPlayer = new System.Media.SoundPlayer();
		denyPlayer = new System.Media.SoundPlayer();
	
		hoverPlayer.Stream = GetStreamFromFomod("fomod/mouse_over4.wav");
		acceptPlayer.Stream = GetStreamFromFomod("fomod/blip11.wav");
		denyPlayer.Stream = GetStreamFromFomod("fomod/electric_alert1.wav");
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
		acceptPlayer.Play();
		mainInstallForm.Close();
	}
	
	static void iconsButton1_Click(object sender, EventArgs e)
	{
		acceptPlayer.Play();

		iconsButton1.Image = imageChecked;
		iconsButton2.Image = imageUnchecked;
		iconsButton3.Image = imageUnchecked;
		
		categoryIconSelected = 1;
	}

	static void iconsButton2_Click(object sender, EventArgs e)
	{
		acceptPlayer.Play();

		iconsButton1.Image = imageUnchecked;
		iconsButton2.Image = imageChecked;
		iconsButton3.Image = imageUnchecked;
		
		categoryIconSelected = 2;
	}

	static void iconsButton3_Click(object sender, EventArgs e)
	{
		acceptPlayer.Play();

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
		acceptPlayer.Play();
		iconsForm.Close();
	}
	
	static bool IsPluginActive(String pluginName) {  	
		string[] loadOrder = GetActivePlugins();  
		for (int i = 0; i < loadOrder.Length; ++i) {  
			if (loadOrder[i].Equals(pluginName, StringComparison.InvariantCultureIgnoreCase)) {
				 return true;  
			}
		}  
	
		return false;  
	}   
	
	static Image GetImageFromFomod(string filename) {  
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
