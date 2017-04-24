#include "utils.h"

#include <QCryptographicHash>

Utils::Utils()
{
}

QString Utils::sha1(QString &data) {
    return QString(QCryptographicHash::hash((data),QCryptographicHash::Md5).toHex());
}
