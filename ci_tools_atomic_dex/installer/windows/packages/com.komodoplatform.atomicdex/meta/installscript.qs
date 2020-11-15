function Component()
{
    // Install to @RootDir@ instead of @HomeDir@ on Windows
    if (installer.value("os") === "win") {
        var homeDir = installer.value("HomeDir");
        var targetDir = installer.value("TargetDir").replace(homeDir, "@RootDir@");
        installer.setValue("TargetDir", targetDir);
    }
}