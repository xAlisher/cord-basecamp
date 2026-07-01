#pragma once

#include "rep_cord_ui_source.h"       // generated from src/cord_ui.rep (repc)
#include "logos_ui_plugin_context.h"  // modules() + onContextReady()

/**
 * @brief cord_ui backend — bridges QML to the universal zone_sequencer (read-only).
 *
 * QML (logos.module("cord_ui") + logos.watch) → this backend → the Qt-free universal
 * zone_sequencer via modules().zone_sequencer.*. Cord only reads channels
 * (set_node_url + query_channel_paged, no signing), so this is the minimal
 * beacon-recipe migration. Replaces cord's legacy
 * logos.callModule("liblogos_zone_sequencer_module", ...) path, which returns "null"
 * for universal modules (cord#5). logos_cord stays on callModule (legacy Qt module).
 */
class CordUiBackend : public CordUiSimpleSource,
                      public LogosUiPluginContext
{
public:
    QString setNodeUrl(QString url) override;
    QString queryChannelPaged(QString channelId, QString cursorJson, int limit) override;

protected:
    void onContextReady() override { setZoneSeqReady(true); }
};
