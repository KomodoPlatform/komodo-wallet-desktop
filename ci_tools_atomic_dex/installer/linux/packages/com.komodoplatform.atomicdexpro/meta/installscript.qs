function Component() { }

Component.prototype.createOperations = function() {
    // Call default implementation to actually install the application
    component.createOperations();

    if (systemInfo.productType === "windows") {
        // Start Menu Shortcut
        component.addOperation("CreateShortcut", 
                               "@TargetDir@/atomic_qt.exe", 
                               "@StartMenuDir@/AtomicDEX Pro.lnk",
                               "workingDirectory=@TargetDir@", 
                               "iconPath=@TargetDir@/app_icon.ico", "iconId=0",
                               "description=Open README file");
        
        // Desktop Shortcut
        component.addOperation("CreateShortcut", 
                            "@TargetDir@/atomic_qt.exe",
                            "@DesktopDir@/AtomicDEX Pro.lnk",
                            "workingDirectory=@TargetDir@",
                            "iconPath=@TargetDir@/app_icon.ico", "iconId=0",
                            "description=Start AtomicDEX Pro");
    }
}