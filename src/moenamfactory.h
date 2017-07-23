#ifndef MOENAMFACTORY_H
#define MOENAMFACTORY_H

#include <QObject>
#include <QQmlNetworkAccessManagerFactory>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>

class MoeNAMFactory : public QQmlNetworkAccessManagerFactory
{
public:
    virtual QNetworkAccessManager *create(QObject *parent);
};


class MoeNetworkAccessManager : public QNetworkAccessManager
{
    Q_OBJECT

public:
    MoeNetworkAccessManager(QObject *parent = 0);

protected:
    virtual QNetworkReply *createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData);

public slots:
    bool removeCache(const QString &url);
    void clearCache();

private:
    bool checkCacheRule(const QString &url);
};

#endif // MOENAMFACTORY_H
