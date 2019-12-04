
#include "mainwindow.h"
#include "./ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
        : QMainWindow(parent), m_ui(new Ui::MainWindow),
          m_status_bar_contents("loaded", new QProgressBar(statusBar())) {
    m_ui->setupUi(this);
    statusBar()->showMessage(m_status_bar_contents.default_msg);
    statusBar()->addPermanentWidget(m_status_bar_contents.m_progress_bar);
    m_status_bar_contents.m_progress_bar->setVisible(false);
}

MainWindow::~MainWindow() {
    delete m_ui;
}

