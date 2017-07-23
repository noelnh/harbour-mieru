#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QScopedPointer>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>

#include <sailfishapp.h>

#include "utils.h"
#include "moenamfactory.h"


int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    MoeNAMFactory mnamf;
    view->engine()->setNetworkAccessManagerFactory(&mnamf);
    view->rootContext()->setContextProperty("networkMgr", view->engine()->networkAccessManager());

    Utils utils;
    view->rootContext()->setContextProperty("utils", &utils);

    view->setSource(SailfishApp::pathTo("qml/harbour-mieru.qml"));
    view->show();

    return app->exec();
}
