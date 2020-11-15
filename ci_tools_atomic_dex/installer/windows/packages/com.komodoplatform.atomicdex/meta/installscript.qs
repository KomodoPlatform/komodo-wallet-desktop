function Component()
{
    // Install to @RootDir@ instead of @HomeDir@ on Windows
    if (installer.value("os") === "win") {
		// Start Menu Shortcut
        component.addOperation("CreateShortcut", 
                               "@TargetDir@/atomicdex-desktop.exe", 
                               "@StartMenuDir@/AtomicDEX Desktop.lnk",
                               "workingDirectory=@TargetDir@", 
                               "iconPath=@TargetDir@/atomicdex-desktop.ico", "iconId=0",
                               "description=Start AtomicDEX Desktop");
        
        // Desktop Shortcut
        component.addOperation("CreateShortcut", 
                            "@TargetDir@/atomicdex-desktop.exe",
                            "@DesktopDir@/AtomicDEX Desktop.lnk",
                            "workingDirectory=@TargetDir@",
                            "iconPath=@TargetDir@/atomicdex-desktop.ico", "iconId=0",
                            "description=Start AtomicDEX Desktop");
    }
}