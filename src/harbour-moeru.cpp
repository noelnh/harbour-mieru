#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>

#include "utils.h"


int main(int argc, char *argv[])
{
    Utils utils;
    view->rootContext()->setContextProperty("utils", &utils);

    return SailfishApp::main(argc, argv);
}
