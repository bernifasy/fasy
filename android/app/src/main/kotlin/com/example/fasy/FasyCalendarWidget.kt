package com.example.fasy

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class FasyCalendarWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) {
            val views = RemoteViews(context.packageName, R.layout.widget_calendar)
            HomeWidgetPlugin.getData(context).getString("calendar_image", null)?.let {
                views.setImageViewBitmap(R.id.calendar_image, BitmapFactory.decodeFile(it))
            }
            views.setOnClickPendingIntent(
                R.id.calendar_image,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            )
            manager.updateAppWidget(id, views)
        }
    }
}