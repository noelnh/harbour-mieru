#include <QNetworkDiskCache>
#include <QStandardPaths>
#include <QDir>

#include "moenamfactory.h"

QNetworkAccessManager *MoeNAMFactory::create(QObject *parent)
{
    QNetworkAccessManager *nam = new MoeNetworkAccessManager(parent);

    QNetworkDiskCache* diskCache = new QNetworkDiskCache(parent);
    QString dataPath = QStandardPaths::standardLocations(QStandardPaths::CacheLocation).at(0);
    QDir dir(dataPath);
    if (!dir.exists()) dir.mkpath(dir.absolutePath());

    diskCache->setCacheDirectory(dataPath);
    diskCache->setMaximumCacheSize(300*1024*1024);
    nam->setCache(diskCache);

    return nam;
}


MoeNetworkAccessManager::MoeNetworkAccessManager(QObject *parent) : QNetworkAccessManager(parent)
{
}

QNetworkReply *MoeNetworkAccessManager::createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData)
{

    QNetworkRequest rqst(request);
    QString url = rqst.url().toString();

    if (checkCacheRule(url))
    {
        rqst.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
    } else {
        rqst.setAttribute(QNetworkRequest::CacheSaveControlAttribute, false);
    }

    QNetworkReply *reply = QNetworkAccessManager::createRequest(op, rqst, outgoingData);

    return reply;
}

bool MoeNetworkAccessManager::removeCache(const QString &url)
{
    return this->cache()->remove(url);
}

void MoeNetworkAccessManager::clearCache()
{
    this->cache()->clear();
}

bool MoeNetworkAccessManager::checkCacheRule(const QString &url) {
    return url.endsWith(".ico") || url.endsWith(".gif") ||
                    url.endsWith(".png") || url.endsWith(".jpg") ||
                    url.contains("/tag.json?limit=1&");
}
