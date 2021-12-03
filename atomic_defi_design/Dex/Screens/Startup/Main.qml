import QtQuick 2.15

Item
{
    id: root

    enum StartupPage
    {
        WalletsView,
        NewWallet,
        ImportWallet,
        Login,
        Logging
    }

    property var    currentPage

    property var    _availablePages: [ _walletsView, _newWallet, _importWallet, _login, _logging ]
    property string _selectedWalletName

    signal logged(string walletName)

    Component.onCompleted: _selectedWalletName.length > 0 ? currentPage = Main.StartupPage.Login : currentPage = Main.StartupPage.WalletsView

    Loader
    {
        id: _pageLoader
        anchors.fill: parent
        sourceComponent: _availablePages[currentPage]
    }

    Component
    {
        id: _walletsView
        WalletsView
        {
            onNewWalletClicked: currentPage = Main.StartupPage.NewWallet
            onImportWalletClicked: currentPage = Main.StartupPage.ImportWallet
            onWalletSelected:
            {
                _selectedWalletName = walletName;
                currentPage = Main.StartupPage.Login;
            }
        }
    }

    Component
    {
        id: _newWallet
        NewWallet
        {
            onWalletCreated:
            {
                _selectedWalletName = walletName;
                currentPage = Main.StartupPage.Login;
            }
            onBackClicked: currentPage = Main.StartupPage.WalletsView
        }
    }

    Component
    {
        id: _importWallet
        ImportWallet
        {
            onBackClicked: currentPage = Main.StartupPage.WalletsView
            onPostConfirmSuccess:
            {
                _selectedWalletName = walletName;
                currentPage = Main.StartupPage.Login;
            }
        }
    }

    Component
    {
        id: _login
        Login
        {
            onBackClicked: currentPage = Main.StartupPage.WalletsView
            onLoginSucceeded: currentPage = Main.StartupPage.Logging
            walletName: _selectedWalletName
        }
    }

    Component
    {
        id: _logging
        Logging
        {
            onLogged: root.logged(_selectedWalletName)
        }
    }
}
