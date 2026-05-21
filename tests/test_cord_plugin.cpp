#include <QtTest/QtTest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDir>
#include <QFile>
#include <QTemporaryDir>

#include "plugin/CordPlugin.h"

// ── Helpers ───────────────────────────────────────────────────────────────────
static QJsonObject parseObj(const QString& s)
{
    return QJsonDocument::fromJson(s.toUtf8()).object();
}

static QJsonArray parseArr(const QString& s)
{
    return QJsonDocument::fromJson(s.toUtf8()).array();
}

// Valid-looking 64-char hex channel ID for testing
static const QString kChanA = "aabbccdd11223344aabbccdd11223344aabbccdd11223344aabbccdd11223344";
static const QString kChanB = "1122334455667788112233445566778811223344556677881122334455667788";

// ── Test class ────────────────────────────────────────────────────────────────
class TestCordPlugin : public QObject
{
    Q_OBJECT

private:
    CordPlugin* makePlugin(const QString& persistencePath)
    {
        auto* p = new CordPlugin();
        p->setProperty("instancePersistencePath", persistencePath);
        p->initLogos(nullptr);
        return p;
    }

private slots:
    // ── addChannel ────────────────────────────────────────────────────────────

    void testAddChannelSuccess()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());
        CordPlugin p;
        p.setProperty("instancePersistencePath", tmp.path());
        p.initLogos(nullptr);

        auto r = parseObj(p.addChannel(kChanA, "Alice"));
        QVERIFY(r["ok"].toBool());

        auto wl = parseArr(p.getWatchlist());
        QCOMPARE(wl.size(), 1);
        QCOMPARE(wl[0].toObject()["channelId"].toString(), kChanA);
        QCOMPARE(wl[0].toObject()["label"].toString(), QString("Alice"));
    }

    void testAddChannelDuplicate()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());
        CordPlugin p;
        p.setProperty("instancePersistencePath", tmp.path());
        p.initLogos(nullptr);

        p.addChannel(kChanA, "Alice");
        auto r = parseObj(p.addChannel(kChanA, "Alice again"));
        QCOMPARE(r["error"].toString(), QString("duplicate"));

        // Still only 1 entry
        auto wl = parseArr(p.getWatchlist());
        QCOMPARE(wl.size(), 1);
    }

    void testAddChannelInvalidId()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());
        CordPlugin p;
        p.setProperty("instancePersistencePath", tmp.path());
        p.initLogos(nullptr);

        auto r1 = parseObj(p.addChannel("", "test"));
        QVERIFY(r1.contains("error"));

        auto r2 = parseObj(p.addChannel("not-hex!!!", "test"));
        QVERIFY(r2.contains("error"));
    }

    void testAddChannelDefaultLabel()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());
        CordPlugin p;
        p.setProperty("instancePersistencePath", tmp.path());
        p.initLogos(nullptr);

        // Empty label falls back to channelId
        p.addChannel(kChanA, "");
        auto wl = parseArr(p.getWatchlist());
        QCOMPARE(wl[0].toObject()["label"].toString(), kChanA);
    }

    // ── removeChannel ─────────────────────────────────────────────────────────

    void testRemoveChannel()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());
        CordPlugin p;
        p.setProperty("instancePersistencePath", tmp.path());
        p.initLogos(nullptr);

        p.addChannel(kChanA, "Alice");
        p.addChannel(kChanB, "Bob");
        QCOMPARE(parseArr(p.getWatchlist()).size(), 2);

        auto r = parseObj(p.removeChannel(kChanA));
        QVERIFY(r["ok"].toBool());

        auto wl = parseArr(p.getWatchlist());
        QCOMPARE(wl.size(), 1);
        QCOMPARE(wl[0].toObject()["channelId"].toString(), kChanB);
    }

    void testRemoveChannelNotFound()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());
        CordPlugin p;
        p.setProperty("instancePersistencePath", tmp.path());
        p.initLogos(nullptr);

        auto r = parseObj(p.removeChannel(kChanA));
        QVERIFY(r.contains("error"));
    }

    // ── updateCursor ──────────────────────────────────────────────────────────

    void testUpdateCursor()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());
        CordPlugin p;
        p.setProperty("instancePersistencePath", tmp.path());
        p.initLogos(nullptr);

        p.addChannel(kChanA, "Alice");
        auto r = parseObj(p.updateCursor(kChanA, "{\"slot\":42}"));
        QVERIFY(r["ok"].toBool());

        auto wl = parseArr(p.getWatchlist());
        QCOMPARE(wl[0].toObject()["cursorJson"].toString(), QString("{\"slot\":42}"));
        QVERIFY(wl[0].toObject()["lastSeen"].toInt() > 0);
    }

    void testUpdateCursorChannelNotFound()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());
        CordPlugin p;
        p.setProperty("instancePersistencePath", tmp.path());
        p.initLogos(nullptr);

        auto r = parseObj(p.updateCursor(kChanA, "{}"));
        QVERIFY(r.contains("error"));
    }

    // ── recordDispatch / getDispatchLog ───────────────────────────────────────

    void testRecordDispatch()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());
        CordPlugin p;
        p.setProperty("instancePersistencePath", tmp.path());
        p.initLogos(nullptr);

        p.addChannel(kChanA, "Alice");
        auto r = parseObj(p.recordDispatch(kChanA, "msgid001", "cid_pin",
                                            "QmTestCid1111", "", "received"));
        QVERIFY(r["ok"].toBool());
        QVERIFY(r.contains("logIndex"));
        QCOMPARE(r["logIndex"].toInt(), 0);

        auto log = parseArr(p.getDispatchLog());
        QCOMPARE(log.size(), 1);
        QCOMPARE(log[0].toObject()["cid"].toString(), QString("QmTestCid1111"));
        QCOMPARE(log[0].toObject()["type"].toString(), QString("cid_pin"));
        QCOMPARE(log[0].toObject()["result"].toString(), QString("received"));
        QCOMPARE(log[0].toObject()["label"].toString(), QString("Alice"));
    }

    void testDispatchLogCappedAt200()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());
        CordPlugin p;
        p.setProperty("instancePersistencePath", tmp.path());
        p.initLogos(nullptr);

        p.addChannel(kChanA, "Alice");

        for (int i = 0; i < 210; i++) {
            p.recordDispatch(kChanA, QString("msg%1").arg(i),
                             "cid_pin", QString("Qm%1").arg(i), "", "received");
        }

        auto log = parseArr(p.getDispatchLog());
        QVERIFY(log.size() <= 200);
    }

    // ── Persistence ───────────────────────────────────────────────────────────

    void testWatchlistPersists()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());

        {
            CordPlugin p;
            p.setProperty("instancePersistencePath", tmp.path());
            p.initLogos(nullptr);
            p.addChannel(kChanA, "Alice");
            p.addChannel(kChanB, "Bob");
        }

        CordPlugin p2;
        p2.setProperty("instancePersistencePath", tmp.path());
        p2.initLogos(nullptr);

        auto wl = parseArr(p2.getWatchlist());
        QCOMPARE(wl.size(), 2);
        QCOMPARE(wl[0].toObject()["label"].toString(), QString("Alice"));
        QCOMPARE(wl[1].toObject()["label"].toString(), QString("Bob"));
    }

    void testDispatchLogPersists()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());

        {
            CordPlugin p;
            p.setProperty("instancePersistencePath", tmp.path());
            p.initLogos(nullptr);
            p.addChannel(kChanA, "Alice");
            p.recordDispatch(kChanA, "msg001", "cid_pin", "QmTestCid", "", "received");
        }

        CordPlugin p2;
        p2.setProperty("instancePersistencePath", tmp.path());
        p2.initLogos(nullptr);

        auto log = parseArr(p2.getDispatchLog());
        QCOMPARE(log.size(), 1);
        QCOMPARE(log[0].toObject()["cid"].toString(), QString("QmTestCid"));
    }

    // ── Config ────────────────────────────────────────────────────────────────

    void testGetCordConfigDefaults()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());

        QSettings s;
        s.remove("cord");

        CordPlugin p;
        p.setProperty("instancePersistencePath", tmp.path());
        p.initLogos(nullptr);

        auto cfg = parseObj(p.getCordConfig());
        QCOMPARE(cfg["nodeUrl"].toString(), QString("http://127.0.0.1:8080"));
        QCOMPARE(cfg["pollInterval"].toInt(), 30);
    }

    void testSetNodeUrl()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());

        QSettings s;
        s.remove("cord");

        CordPlugin p;
        p.setProperty("instancePersistencePath", tmp.path());
        p.initLogos(nullptr);

        auto r = parseObj(p.setNodeUrl("http://node.test:9000"));
        QVERIFY(r["ok"].toBool());
        QCOMPARE(parseObj(p.getCordConfig())["nodeUrl"].toString(),
                 QString("http://node.test:9000"));
    }

    void testSetNodeUrlEmpty()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());
        CordPlugin p;
        p.setProperty("instancePersistencePath", tmp.path());
        p.initLogos(nullptr);

        auto r = parseObj(p.setNodeUrl(""));
        QVERIFY(r.contains("error"));
    }

    void testSetPollIntervalClamped()
    {
        QTemporaryDir tmp;
        QVERIFY(tmp.isValid());

        QSettings s;
        s.remove("cord");

        CordPlugin p;
        p.setProperty("instancePersistencePath", tmp.path());
        p.initLogos(nullptr);

        // Below minimum → clamped to 15
        p.setPollInterval(5);
        QCOMPARE(parseObj(p.getCordConfig())["pollInterval"].toInt(), 15);

        // Above maximum → clamped to 300
        p.setPollInterval(9999);
        QCOMPARE(parseObj(p.getCordConfig())["pollInterval"].toInt(), 300);

        // In range
        p.setPollInterval(60);
        QCOMPARE(parseObj(p.getCordConfig())["pollInterval"].toInt(), 60);
    }
};

QTEST_MAIN(TestCordPlugin)
#include "test_cord_plugin.moc"
