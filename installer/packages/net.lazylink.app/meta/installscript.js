function Component()
{
    console.log("Component initialization - Install script");
}

Component.prototype.createOperations = function()
{
    component.createOperations();
    if (installer.value("os") === "win") {
        component.addOperation("CreateShortcut",
                               "@TargetDir@\\lazylink.exe",
                               "@DesktopDir@" + "\\LazyLink.lnk",
                               "workingDirectory=@TargetDir",
                               "iconPath=@TargetDir@\\lazylink.exe",
                               "iconId=0");
        component.addOperation("CreateShortcut",
                               "@TargetDir@\\lazylink.exe",
                               "@StartMenuDir@" + "\\LazyLink.lnk",
                               "workingDirectory=@TargetDir@",
                               "iconPath=@TargetDir@\\lazylink.exe",
                               "iconId=0");

        console.log("Start menu dir: " + installer.value("StartMenuDir"));

        var vc2017x64RegQuery = [
                    "QUERY",
                    "HKEY_LOCAL_MACHINE\\SOFTWARE\\WOW6432Node\\Microsoft\\VisualStudio\\14.0\\VC\\Runtimes\\x64",
                    "/v",
                    "Installed"];
        var isVC2017x64Installed = installer.execute("reg", vc2017x64RegQuery);
        if (!isVC2017x64Installed) {
            console.log("Installing Microsoft Visual C++ 2017 Redistributable for x64.");
            component.addElevatedOperation("Execute",
                                           "@TargetDir@\\vcredist_x64.exe",
                                           "/install",
                                           "/quiet",
                                           "/norestart");
        } else {
            console.log("Microsoft Visual C++ 2017 Redistributable for x64 is already installed");
            component.addOperation("Delete", "@TargetDir@\\vcredist_x64.exe");
        }
    }
}
