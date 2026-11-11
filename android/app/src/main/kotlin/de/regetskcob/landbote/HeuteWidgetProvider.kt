package de.regetskcob.landbote

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

/**
 * The Heute widget: the unread count large in Mono, below it the three
 * newest headlines with their source. Data comes from Flutter through
 * home_widget (lib/services/home_widget.dart); the widget only reads.
 */
class HeuteWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val unread = widgetData.getInt("unread", 0)
        val top = try {
            JSONArray(widgetData.getString("top", "[]"))
        } catch (e: Exception) {
            JSONArray()
        }
        val titles = intArrayOf(R.id.title1, R.id.title2, R.id.title3)
        val sources = intArrayOf(R.id.source1, R.id.source2, R.id.source3)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.heute_widget)
            views.setTextViewText(R.id.count, unread.toString())
            views.setTextViewText(
                R.id.kennung,
                if (unread == 0) "HEUTE · ALLES GELESEN" else "HEUTE · NEU",
            )
            for (i in 0 until 3) {
                if (i < top.length()) {
                    val item = top.getJSONObject(i)
                    views.setTextViewText(titles[i], item.optString("title"))
                    views.setTextViewText(sources[i], item.optString("source").uppercase())
                    views.setViewVisibility(titles[i], View.VISIBLE)
                    views.setViewVisibility(sources[i], View.VISIBLE)
                } else {
                    views.setViewVisibility(titles[i], View.GONE)
                    views.setViewVisibility(sources[i], View.GONE)
                }
            }
            val open = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.root, open)
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
