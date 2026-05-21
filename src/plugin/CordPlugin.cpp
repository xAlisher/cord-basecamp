#include "CordPlugin.h"

#include <QSettings>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDateTime>
#include <QFile>
#include <QDir>
#include <QRegularExpression>

// ── QSettings key prefix ──────────────────────────────────────────────────────
static constexpr const char* kNodeUrlKey      = "cord/nodeUrl";
static constexpr const char* kPollIntervalKey = "cord/pollInterval";

static constexpr int kMaxDispatchLog = 200;

// ── Helpers ───────────────────────────────────────────────────────────────────
QString CordPlugin::errorJson(const QString& msg)
{
    QJsonObject o;
    o[QStringLiteral("error")] = msg;
    return QJsonDocument(o).toJson(QJsonDocument::Compact);
}

QString CordPlugin::okJson()
{
    QJsonObject o;
    o[QStringLiteral("ok")] = true;
    return QJsonDocument(o).toJson(QJsonDocument::Compact);
}

// ── Constructor ───────────────────────────────────────────────────────────────
CordPlugin::CordPlugin(QObject* parent)
    : QObject(parent)
{}

// ── initLogos ─────────────────────────────────────────────────────────────────
void CordPlugin::initLogos(LogosAPI* api)
{
    logosAPI = api;

    QVariant prop = property("instancePersistencePath");
    if (prop.isValid() && !prop.toString().isEmpty()) {
        m_persistencePath = prop.toString();
    } else {
        m_persistencePath = QDir::homePath() +
            QStringLiteral("/.local/share/Logos/LogosBasecamp/module_data/logos_cord");
    }

    QDir().mkpath(m_persistencePath);

    loadWatchlist();
    loadDispatchLog();
}

// ── loadWatchlist / saveWatchlist ─────────────────────────────────────────────
void CordPlugin::loadWatchlist()
{
    if (m_persistencePath.isEmpty())
        return;

    QFile f(m_persistencePath + QStringLiteral("/watchlist.json"));
    if (!f.open(QIODevice::ReadOnly))
        return;

    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    if (doc.isArray())
        m_watchlist = doc.array();
}

void CordPlugin::saveWatchlist()
{
    if (m_persistencePath.isEmpty())
        return;

    QFile f(m_persistencePath + QStringLiteral("/watchlist.json"));
    if (f.open(QIODevice::WriteOnly | QIODevice::Truncate))
        f.write(QJsonDocument(m_watchlist).toJson(QJsonDocument::Compact));
}

// ── loadDispatchLog / saveDispatchLog ─────────────────────────────────────────
void CordPlugin::loadDispatchLog()
{
    if (m_persistencePath.isEmpty())
        return;

    QFile f(m_persistencePath + QStringLiteral("/dispatch-log.json"));
    if (!f.open(QIODevice::ReadOnly))
        return;

    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    if (doc.isArray())
        m_dispatchLog = doc.array();
}

void CordPlugin::saveDispatchLog()
{
    if (m_persistencePath.isEmpty())
        return;

    QFile f(m_persistencePath + QStringLiteral("/dispatch-log.json"));
    if (f.open(QIODevice::WriteOnly | QIODevice::Truncate))
        f.write(QJsonDocument(m_dispatchLog).toJson(QJsonDocument::Compact));
}

// ── watchlistIndexOf ──────────────────────────────────────────────────────────
int CordPlugin::watchlistIndexOf(const QString& channelId) const
{
    for (int i = 0; i < m_watchlist.size(); ++i) {
        if (m_watchlist[i].toObject()[QStringLiteral("channelId")].toString() == channelId)
            return i;
    }
    return -1;
}

QString CordPlugin::labelForChannel(const QString& channelId) const
{
    int idx = watchlistIndexOf(channelId);
    if (idx < 0)
        return channelId;
    return m_watchlist[idx].toObject()[QStringLiteral("label")].toString();
}

// ── addChannel ────────────────────────────────────────────────────────────────
QString CordPlugin::addChannel(const QString& channelId, const QString& label)
{
    QString id = channelId.trimmed().toLower();

    if (id.isEmpty())
        return errorJson(QStringLiteral("invalid channel id"));

    // Basic hex validation: must be non-empty and all hex chars
    static const QRegularExpression hexRe(QStringLiteral("^[0-9a-f]+$"));
    if (!hexRe.match(id).hasMatch())
        return errorJson(QStringLiteral("invalid channel id"));

    if (watchlistIndexOf(id) >= 0) {
        QJsonObject o;
        o[QStringLiteral("error")] = QStringLiteral("duplicate");
        return QJsonDocument(o).toJson(QJsonDocument::Compact);
    }

    QJsonObject entry;
    entry[QStringLiteral("channelId")]   = id;
    entry[QStringLiteral("label")]       = label.trimmed().isEmpty() ? id : label.trimmed();
    entry[QStringLiteral("lastSeen")]    = 0;
    entry[QStringLiteral("cursorJson")] = QStringLiteral("{}");
    entry[QStringLiteral("pendingCount")] = 0;

    m_watchlist.append(entry);
    saveWatchlist();

    return okJson();
}

// ── removeChannel ─────────────────────────────────────────────────────────────
QString CordPlugin::removeChannel(const QString& channelId)
{
    int idx = watchlistIndexOf(channelId.trimmed().toLower());
    if (idx < 0)
        return errorJson(QStringLiteral("not found"));

    // Rebuild without that entry
    QJsonArray updated;
    for (int i = 0; i < m_watchlist.size(); ++i) {
        if (i != idx)
            updated.append(m_watchlist[i]);
    }
    m_watchlist = updated;
    saveWatchlist();

    return okJson();
}

// ── getWatchlist ──────────────────────────────────────────────────────────────
QString CordPlugin::getWatchlist() const
{
    return QJsonDocument(m_watchlist).toJson(QJsonDocument::Compact);
}

// ── updateCursor ──────────────────────────────────────────────────────────────
QString CordPlugin::updateCursor(const QString& channelId, const QString& cursorJson)
{
    int idx = watchlistIndexOf(channelId.trimmed().toLower());
    if (idx < 0)
        return errorJson(QStringLiteral("channel not found"));

    QJsonObject entry = m_watchlist[idx].toObject();
    entry[QStringLiteral("cursorJson")] = cursorJson;
    entry[QStringLiteral("lastSeen")]   = QDateTime::currentSecsSinceEpoch();
    m_watchlist[idx] = entry;
    saveWatchlist();

    return okJson();
}

// ── getDispatchLog ────────────────────────────────────────────────────────────
QString CordPlugin::getDispatchLog() const
{
    if (m_dispatchLog.size() <= kMaxDispatchLog)
        return QJsonDocument(m_dispatchLog).toJson(QJsonDocument::Compact);

    QJsonArray tail;
    int start = m_dispatchLog.size() - kMaxDispatchLog;
    for (int i = start; i < m_dispatchLog.size(); ++i)
        tail.append(m_dispatchLog[i]);
    return QJsonDocument(tail).toJson(QJsonDocument::Compact);
}

// ── recordDispatch ────────────────────────────────────────────────────────────
QString CordPlugin::recordDispatch(const QString& channelId,
                                    const QString& messageId,
                                    const QString& type,
                                    const QString& cid,
                                    const QString& source,
                                    const QString& result)
{
    QString id = channelId.trimmed().toLower();

    QJsonObject entry;
    entry[QStringLiteral("channelId")]   = id;
    entry[QStringLiteral("label")]       = labelForChannel(id);
    entry[QStringLiteral("messageId")]   = messageId;
    entry[QStringLiteral("cid")]         = cid;
    entry[QStringLiteral("source")]      = source;
    entry[QStringLiteral("type")]        = type;
    entry[QStringLiteral("ts")]          = QDateTime::currentSecsSinceEpoch();
    entry[QStringLiteral("result")]      = result;
    entry[QStringLiteral("dispatchedTs")] = QDateTime::currentSecsSinceEpoch();

    // Trim to last kMaxDispatchLog entries
    if (m_dispatchLog.size() >= kMaxDispatchLog) {
        QJsonArray trimmed;
        int start = m_dispatchLog.size() - kMaxDispatchLog + 1;
        for (int i = start; i < m_dispatchLog.size(); ++i)
            trimmed.append(m_dispatchLog[i]);
        m_dispatchLog = trimmed;
    }

    int logIndex = m_dispatchLog.size();
    m_dispatchLog.append(entry);
    saveDispatchLog();

    QJsonObject o;
    o[QStringLiteral("ok")]       = true;
    o[QStringLiteral("logIndex")] = logIndex;
    return QJsonDocument(o).toJson(QJsonDocument::Compact);
}

// ── getCordConfig ─────────────────────────────────────────────────────────────
QString CordPlugin::getCordConfig() const
{
    QSettings s;
    QJsonObject o;
    o[QStringLiteral("nodeUrl")]      = s.value(QLatin1String(kNodeUrlKey),
                                                 QStringLiteral("http://127.0.0.1:8080")).toString();
    o[QStringLiteral("pollInterval")] = s.value(QLatin1String(kPollIntervalKey), 30).toInt();
    return QJsonDocument(o).toJson(QJsonDocument::Compact);
}

// ── setNodeUrl ────────────────────────────────────────────────────────────────
QString CordPlugin::setNodeUrl(const QString& url)
{
    if (url.trimmed().isEmpty())
        return errorJson(QStringLiteral("url must not be empty"));
    QSettings s;
    s.setValue(QLatin1String(kNodeUrlKey), url.trimmed());
    return okJson();
}

// ── setPollInterval ───────────────────────────────────────────────────────────
QString CordPlugin::setPollInterval(int seconds)
{
    int clamped = qBound(15, seconds, 300);
    QSettings s;
    s.setValue(QLatin1String(kPollIntervalKey), clamped);
    return okJson();
}
