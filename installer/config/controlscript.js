var silentMode = false;
var appAlreadyInstalled = false;
var appInstalledUninstallerPath;
var appInstalledLocation;

function officialAppName()
{
	return installer.value("Name");
}

function appName() 
{
	return installer.value("RunProgram").replace(/^.*[\\\/]/, '');
}

function killProcessByName()
{
	var cmd;
	var cmdArgs;
	if (installer.value("os") === "win") {
		cmd = "taskkill";
		cmdArgs = ["/F", "/IM", appName()]
	} else {
		cmd = "killall";
		cmdArgs = [appName()];
	}
	var result = installer.execute(cmd, cmdArgs);	
	
	console.log("Operation (kill process by name finished with code: " + result);
}

function killAppIfRunning()
{
	if (appIsRunning()) {
		killProcessByName();
	}
}

function appIsRunning()
{
    return installer.isProcessRunning(appName());
}

function readRegistryItem(key, array)
{
	var result = installer.execute("reg", array)[0];
	return result.trim().split("\n");
}

function checkRegistry(key)
{
	var keys = readRegistryItem(key, new Array("QUERY", key));
	if (keys.length == 0) {
		return false;
	}
	
	keys.forEach(function(entry) {
		var queryString = entry.trim();
		var resultKeys = readRegistryItem(key, new Array("QUERY", queryString, "/v", "DisplayName"));
		
		if ((resultKeys.length > 1) && (resultKeys[1].includes(officialAppName()))) {
			appAlreadyInstalled = true;
			
			resultKeys = readRegistryItem(key, new Array("QUERY", queryString, "/v", "UninstallString"));
			if (resultKeys.length > 1) {
				appInstalledUninstallerPath = resultKeys[1].replace("UninstallString","").replace("REG_SZ","").trim();
				console.log("appInstalledUninstallerPath: " + appInstalledUninstallerPath);
			}
			
			resultKeys = readRegistryItem(key, new Array("QUERY", queryString, "/v", "InstallLocation"));
			if (resultKeys.length > 1) {
				appInstalledLocation = resultKeys[1].replace("InstallLocation","").replace("REG_SZ","").trim();
				console.log("appInstalledLocation: " + appInstalledLocation);
				return true;
			}
		}
	});
	
	return false;
}

function appInstalled()
{
	if (!checkRegistry("HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall")) {
		checkRegistry("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall");
	}
	return appAlreadyInstalled;
}

function sleep(miliseconds) {
	var currentTime = new Date().getTime();
	while (currentTime + miliseconds >= new Date().getTime()) {}
}

function Controller()
{
	console.log("Component initialization - General script");
	
	console.log("App installed: " + appInstalled());
	
	if (((installer.value("silentInstall") === "true") &&  installer.isInstaller()) || 
		(((installer.value("silentUninstall") === "true") && installer.isUninstaller()))) {
		silentMode = true;
		installer.setDefaultPageVisible(QInstaller.LicenseCheck, false);
	}

	if (installer.isInstaller() && appAlreadyInstalled) {
		if (silentMode) {
			console.log("Execute uninstaller in silent mode");
			
			installer.setMessageBoxAutomaticAnswer("OverwriteTargetDirectory", QMessageBox.Yes);
			var resultArray = installer.execute(appInstalledUninstallerPath, "silentUninstall=true");

			for (var i = 0; i < 10; i++) {
				sleep(3000);
				if (!installer.fileExists(appInstalledUninstallerPath)) {
					break;
				}
            }

		} else {
			if (QMessageBox.Ok === QMessageBox.information("os.information", officialAppName(),
                    qsTr("The application is already installed.") + " " +
					qsTr("We need to remove the old installation first. Do you wish to proceed?"),
					QMessageBox.Ok | QMessageBox.Cancel)) {

				var resultArray = installer.execute(appInstalledUninstallerPath);
				
				console.log("Uninstaller finished with code: " + resultArray[1])
				
				if (Number(resultArray[1]) !== 0) {
					console.log("Uninstallation aborted by user");
					installer.setCancelled();
					return;
				}
			} else {
				console.log("Request to quit from user");
				installer.setCancelled();
				return;	
			}
		}
	}
	
	gui.setSilent(silentMode); 
}

Controller.prototype.IntroductionPageCallback = function ()
{
    console.log("IntroductionPageCallback started");
	
    if (installer.isUninstaller() || silentMode) {
		gui.clickButton(buttons.NextButton);
    }
}

Controller.prototype.TargetDirectoryPageCallback = function ()
{
	console.log("TargetDirectoryPageCallback started");
	
	if (installer.isInstaller() && silentMode) {
		gui.clickButton(buttons.NextButton);
	}
}

Controller.prototype.StartMenuDirectoryPageCallback = function ()
{
	console.log("StartMenuDirectoryPageCallback started");
	
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.FinishedPageCallback = function ()
{
    console.log("FinishedPageCallback started");
	
	if (installer.isUninstaller() && !silentMode) {
		return;
	}
	
    gui.clickButton(buttons.FinishButton);
}

Controller.prototype.ReadyForInstallationPageCallback = function()
{
    console.log("ReadyForInstallationPageCallback started");
	
    if ((installer.isUninstaller() && silentMode) || (installer.isInstaller() && silentMode)) {
        gui.clickButton(buttons.CommitButton);
    }
}

Controller.prototype.PerformInstallationPageCallback = function()
{
    console.log("PerformInstallationPageCallback started");
	
	// Kill process before uninstall
	if (installer.isUninstaller()) {
		killAppIfRunning();
	}
	
    if ((installer.isUninstaller() && silentMode) || (installer.isInstaller() && silentMode)) {
        gui.clickButton(buttons.NextButton);
        gui.clickButton(buttons.CommitButton);
    }
}

Controller.prototype.RestartPageCallback = function ()
{
    console.log("RestartPageCallback");
}

Controller.prototype.ComponentSelectionPageCallback = function()
{
    console.log("ComponentSelectionPageCallback");
	
    if (installer.isInstaller()) {
        gui.clickButton(buttons.NextButton);
    }
}


