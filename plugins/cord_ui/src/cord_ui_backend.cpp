#include "cord_ui_backend.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QVariant>

#include "logos_sdk.h"   // generated: modules().zone_sequencer (Qt-typed)

// Unwrap a Qt LogosResult into the JSON string the QML parses (callModuleParse):
// success → the value (string as-is, else compact JSON); failure → {"error": ...}.
static QString resultToJson(const LogosResult& r)
{
    if (!r.success) {
        QJsonObject o;
        o["error"] = r.getError();
        return QString::fromUtf8(QJsonDocument(o).toJson(QJsonDocument::Compact));
    }
    QVariant v = r.value;
    if (v.typeId() == QMetaType::QString)
        return v.toString();
    QJsonDocument doc = QJsonDocument::fromVariant(v);
    return doc.isNull() ? r.getString()
                        : QString::fromUtf8(doc.toJson(QJsonDocument::Compact));
}

QString CordUiBackend::setNodeUrl(QString url)
{
    if (!isContextReady()) return "{\"error\":\"context not ready\"}";
    return resultToJson(modules().zone_sequencer.set_node_url(url));
}

QString CordUiBackend::queryChannelPaged(QString channelId, QString cursorJson, int limit)
{
    if (!isContextReady()) return "{\"error\":\"context not ready\"}";
    return resultToJson(
        modules().zone_sequencer.query_channel_paged(channelId, cursorJson, limit));
}
