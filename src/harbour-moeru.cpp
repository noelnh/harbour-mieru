#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QScopedPointer>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>

#include <sailfishapp.h>

#include "utils.h"


int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    Utils utils;
    view->rootContext()->setContextProperty("utils", &utils);

    view->setSource(SailfishApp::pathTo("qml/harbour-moeru.qml"));
    view->show();

    return app->exec();
}
