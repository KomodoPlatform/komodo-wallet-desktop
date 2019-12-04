#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QProgressBar>
#include <utility>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

struct StatusBarContents {
    StatusBarContents(QString str, QProgressBar *in_progress_bar) noexcept : default_msg(std::move(str)),
                                                                             m_progress_bar(in_progress_bar) {

    }

    QString default_msg{""};
    QProgressBar *m_progress_bar{nullptr};
};

class MainWindow : public QMainWindow {
Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);

    ~MainWindow();

private:
    Ui::MainWindow *m_ui;
    StatusBarContents m_status_bar_contents;

    void initStatusBar() const noexcept;
};

#endif // MAINWINDOW_H
