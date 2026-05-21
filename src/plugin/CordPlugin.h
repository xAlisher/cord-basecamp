#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QJsonArray>

#include "interface.h"

class CordPlugin : public QObject, public PluginInterface
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.logos.CordModuleInterface" FILE "plugin_metadata.json")
    Q_INTERFACES(PluginInterface)

public:
    explicit CordPlugin(QObject* parent = nullptr);

    QString name()    const override { return QStringLiteral("logos_cord"); }
    QString version() const override { return QStringLiteral("1.0.0"); }

    Q_INVOKABLE void initLogos(LogosAPI* api);

    // ── WatchList ────────────────────────────────────────────────────────────
    // Returns {"ok":true} | {"error":"duplicate"} | {"error":"invalid channel id"}
    Q_INVOKABLE QString addChannel(const QString& channelId, const QString& label);

    // Returns {"ok":true} | {"error":"not found"}
    Q_INVOKABLE QString removeChannel(const QString& channelId);

    // Returns [{"channelId","label","lastSeen":unix,"cursorJson":"{}","pendingCount":N}]
    Q_INVOKABLE QString getWatchlist() const;

    // ── Cursor management ────────────────────────────────────────────────────
    // Called by QML after each successful poll. Returns {"ok":true}
    Q_INVOKABLE QString updateCursor(const QString& channelId, const QString& cursorJson);

    // ── Dispatch log ─────────────────────────────────────────────────────────
    // Returns last 200: [{"channelId","label","messageId","cid","type","ts","result","dispatchedTs"}]
    Q_INVOKABLE QString getDispatchLog() const;

    // Appends an entry to the dispatch log. Returns {"ok":true,"logIndex":N}
    Q_INVOKABLE QString recordDispatch(const QString& channelId,
                                       const QString& messageId,
                                       const QString& type,
                                       const QString& cid,
                                       const QString& source,
                                       const QString& result);

    // ── Config ───────────────────────────────────────────────────────────────
    // Returns {"nodeUrl":"...","pollInterval":30}
    Q_INVOKABLE QString getCordConfig() const;

    // Returns {"ok":true} | {"error":"..."}
    Q_INVOKABLE QString setNodeUrl(const QString& url);

    // seconds clamped to [15, 300]. Returns {"ok":true}
    Q_INVOKABLE QString setPollInterval(int seconds);

signals:
    void eventResponse(const QString& eventName, const QVariantList& data);

private:
    void loadWatchlist();
    void saveWatchlist();
    void loadDispatchLog();
    void saveDispatchLog();

    int watchlistIndexOf(const QString& channelId) const;
    QString labelForChannel(const QString& channelId) const;

    static QString errorJson(const QString& msg);
    static QString okJson();

    QString    m_persistencePath;
    QJsonArray m_watchlist;     // [{channelId, label, lastSeen, cursorJson, pendingCount}]
    QJsonArray m_dispatchLog;   // last 200 entries
};
