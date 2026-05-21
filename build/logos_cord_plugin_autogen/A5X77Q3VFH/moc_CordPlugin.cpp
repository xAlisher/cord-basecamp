/****************************************************************************
** Meta object code from reading C++ file 'CordPlugin.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.9.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/plugin/CordPlugin.h"
#include <QtCore/qmetatype.h>
#include <QtCore/qplugin.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'CordPlugin.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.9.3. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN10CordPluginE_t {};
} // unnamed namespace

template <> constexpr inline auto CordPlugin::qt_create_metaobjectdata<qt_meta_tag_ZN10CordPluginE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "CordPlugin",
        "eventResponse",
        "",
        "eventName",
        "QVariantList",
        "data",
        "initLogos",
        "LogosAPI*",
        "api",
        "addChannel",
        "channelId",
        "label",
        "removeChannel",
        "getWatchlist",
        "updateCursor",
        "cursorJson",
        "getDispatchLog",
        "recordDispatch",
        "messageId",
        "type",
        "cid",
        "source",
        "result",
        "getCordConfig",
        "setNodeUrl",
        "url",
        "setPollInterval",
        "seconds"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'eventResponse'
        QtMocHelpers::SignalData<void(const QString &, const QVariantList &)>(1, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 3 }, { 0x80000000 | 4, 5 },
        }}),
        // Method 'initLogos'
        QtMocHelpers::MethodData<void(LogosAPI *)>(6, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 7, 8 },
        }}),
        // Method 'addChannel'
        QtMocHelpers::MethodData<QString(const QString &, const QString &)>(9, 2, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 10 }, { QMetaType::QString, 11 },
        }}),
        // Method 'removeChannel'
        QtMocHelpers::MethodData<QString(const QString &)>(12, 2, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 10 },
        }}),
        // Method 'getWatchlist'
        QtMocHelpers::MethodData<QString() const>(13, 2, QMC::AccessPublic, QMetaType::QString),
        // Method 'updateCursor'
        QtMocHelpers::MethodData<QString(const QString &, const QString &)>(14, 2, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 10 }, { QMetaType::QString, 15 },
        }}),
        // Method 'getDispatchLog'
        QtMocHelpers::MethodData<QString() const>(16, 2, QMC::AccessPublic, QMetaType::QString),
        // Method 'recordDispatch'
        QtMocHelpers::MethodData<QString(const QString &, const QString &, const QString &, const QString &, const QString &, const QString &)>(17, 2, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 10 }, { QMetaType::QString, 18 }, { QMetaType::QString, 19 }, { QMetaType::QString, 20 },
            { QMetaType::QString, 21 }, { QMetaType::QString, 22 },
        }}),
        // Method 'getCordConfig'
        QtMocHelpers::MethodData<QString() const>(23, 2, QMC::AccessPublic, QMetaType::QString),
        // Method 'setNodeUrl'
        QtMocHelpers::MethodData<QString(const QString &)>(24, 2, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 25 },
        }}),
        // Method 'setPollInterval'
        QtMocHelpers::MethodData<QString(int)>(26, 2, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 27 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<CordPlugin, qt_meta_tag_ZN10CordPluginE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject CordPlugin::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10CordPluginE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10CordPluginE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN10CordPluginE_t>.metaTypes,
    nullptr
} };

void CordPlugin::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<CordPlugin *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->eventResponse((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QVariantList>>(_a[2]))); break;
        case 1: _t->initLogos((*reinterpret_cast< std::add_pointer_t<LogosAPI*>>(_a[1]))); break;
        case 2: { QString _r = _t->addChannel((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 3: { QString _r = _t->removeChannel((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 4: { QString _r = _t->getWatchlist();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 5: { QString _r = _t->updateCursor((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 6: { QString _r = _t->getDispatchLog();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 7: { QString _r = _t->recordDispatch((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[5])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[6])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 8: { QString _r = _t->getCordConfig();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 9: { QString _r = _t->setNodeUrl((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 10: { QString _r = _t->setPollInterval((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
        case 1:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
            case 0:
                *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType::fromType< LogosAPI* >(); break;
            }
            break;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (CordPlugin::*)(const QString & , const QVariantList & )>(_a, &CordPlugin::eventResponse, 0))
            return;
    }
}

const QMetaObject *CordPlugin::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *CordPlugin::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10CordPluginE_t>.strings))
        return static_cast<void*>(this);
    if (!strcmp(_clname, "PluginInterface"))
        return static_cast< PluginInterface*>(this);
    if (!strcmp(_clname, "com.example.PluginInterface"))
        return static_cast< PluginInterface*>(this);
    return QObject::qt_metacast(_clname);
}

int CordPlugin::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 11)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 11;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 11)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 11;
    }
    return _id;
}

// SIGNAL 0
void CordPlugin::eventResponse(const QString & _t1, const QVariantList & _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 0, nullptr, _t1, _t2);
}

#ifdef QT_MOC_EXPORT_PLUGIN_V2
static constexpr unsigned char qt_pluginMetaDataV2_CordPlugin[] = {
    0xbf, 
    // "IID"
    0x02,  0x78,  0x1d,  'o',  'r',  'g',  '.',  'l', 
    'o',  'g',  'o',  's',  '.',  'C',  'o',  'r', 
    'd',  'M',  'o',  'd',  'u',  'l',  'e',  'I', 
    'n',  't',  'e',  'r',  'f',  'a',  'c',  'e', 
    // "className"
    0x03,  0x6a,  'C',  'o',  'r',  'd',  'P',  'l', 
    'u',  'g',  'i',  'n', 
    // "MetaData"
    0x04,  0xa8,  0x66,  'a',  'u',  't',  'h',  'o', 
    'r',  0x64,  'C',  'o',  'r',  'd',  0x68,  'c', 
    'a',  't',  'e',  'g',  'o',  'r',  'y',  0x66, 
    's',  'o',  'c',  'i',  'a',  'l',  0x6c,  'd', 
    'e',  'p',  'e',  'n',  'd',  'e',  'n',  'c', 
    'i',  'e',  's',  0x80,  0x6b,  'd',  'e',  's', 
    'c',  'r',  'i',  'p',  't',  'i',  'o',  'n', 
    0x78,  0x33,  'C',  'o',  'r',  'd',  ' ',  uchar('\xe2'),
    uchar('\x80'), uchar('\x94'), ' ',  's',  'o',  'c',  'i',  'a', 
    'l',  ' ',  'l',  'a',  'y',  'e',  'r',  ':', 
    ' ',  's',  'u',  'b',  's',  'c',  'r',  'i', 
    'b',  'e',  ' ',  't',  'o',  ' ',  'B',  'e', 
    'a',  'c',  'o',  'n',  ' ',  'c',  'h',  'a', 
    'n',  'n',  'e',  'l',  's',  0x64,  'm',  'a', 
    'i',  'n',  0x6b,  'c',  'o',  'r',  'd',  '_', 
    'p',  'l',  'u',  'g',  'i',  'n',  0x64,  'n', 
    'a',  'm',  'e',  0x6a,  'l',  'o',  'g',  'o', 
    's',  '_',  'c',  'o',  'r',  'd',  0x64,  't', 
    'y',  'p',  'e',  0x64,  'c',  'o',  'r',  'e', 
    0x67,  'v',  'e',  'r',  's',  'i',  'o',  'n', 
    0x65,  '1',  '.',  '0',  '.',  '0', 
    0xff, 
};
QT_MOC_EXPORT_PLUGIN_V2(CordPlugin, CordPlugin, qt_pluginMetaDataV2_CordPlugin)
#else
QT_PLUGIN_METADATA_SECTION
Q_CONSTINIT static constexpr unsigned char qt_pluginMetaData_CordPlugin[] = {
    'Q', 'T', 'M', 'E', 'T', 'A', 'D', 'A', 'T', 'A', ' ', '!',
    // metadata version, Qt version, architectural requirements
    0, QT_VERSION_MAJOR, QT_VERSION_MINOR, qPluginArchRequirements(),
    0xbf, 
    // "IID"
    0x02,  0x78,  0x1d,  'o',  'r',  'g',  '.',  'l', 
    'o',  'g',  'o',  's',  '.',  'C',  'o',  'r', 
    'd',  'M',  'o',  'd',  'u',  'l',  'e',  'I', 
    'n',  't',  'e',  'r',  'f',  'a',  'c',  'e', 
    // "className"
    0x03,  0x6a,  'C',  'o',  'r',  'd',  'P',  'l', 
    'u',  'g',  'i',  'n', 
    // "MetaData"
    0x04,  0xa8,  0x66,  'a',  'u',  't',  'h',  'o', 
    'r',  0x64,  'C',  'o',  'r',  'd',  0x68,  'c', 
    'a',  't',  'e',  'g',  'o',  'r',  'y',  0x66, 
    's',  'o',  'c',  'i',  'a',  'l',  0x6c,  'd', 
    'e',  'p',  'e',  'n',  'd',  'e',  'n',  'c', 
    'i',  'e',  's',  0x80,  0x6b,  'd',  'e',  's', 
    'c',  'r',  'i',  'p',  't',  'i',  'o',  'n', 
    0x78,  0x33,  'C',  'o',  'r',  'd',  ' ',  uchar('\xe2'),
    uchar('\x80'), uchar('\x94'), ' ',  's',  'o',  'c',  'i',  'a', 
    'l',  ' ',  'l',  'a',  'y',  'e',  'r',  ':', 
    ' ',  's',  'u',  'b',  's',  'c',  'r',  'i', 
    'b',  'e',  ' ',  't',  'o',  ' ',  'B',  'e', 
    'a',  'c',  'o',  'n',  ' ',  'c',  'h',  'a', 
    'n',  'n',  'e',  'l',  's',  0x64,  'm',  'a', 
    'i',  'n',  0x6b,  'c',  'o',  'r',  'd',  '_', 
    'p',  'l',  'u',  'g',  'i',  'n',  0x64,  'n', 
    'a',  'm',  'e',  0x6a,  'l',  'o',  'g',  'o', 
    's',  '_',  'c',  'o',  'r',  'd',  0x64,  't', 
    'y',  'p',  'e',  0x64,  'c',  'o',  'r',  'e', 
    0x67,  'v',  'e',  'r',  's',  'i',  'o',  'n', 
    0x65,  '1',  '.',  '0',  '.',  '0', 
    0xff, 
};
QT_MOC_EXPORT_PLUGIN(CordPlugin, CordPlugin)
#endif  // QT_MOC_EXPORT_PLUGIN_V2

QT_WARNING_POP
