package com.example.fasy

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

private fun updateButton(
    context: Context, manager: AppWidgetManager, id: Int,
    dataKey: String, link: String
) {
    val views = RemoteViews(context.packageName, R.layout.widget_button)
    HomeWidgetPlugin.getData(context).getString(dataKey, null)?.let {
        views.setImageViewBitmap(R.id.btn_image, BitmapFactory.decodeFile(it))
    }
    views.setOnClickPendingIntent(
        R.id.btn_image,
        HomeWidgetLaunchIntent.getActivity(
            context, MainActivity::class.java, Uri.parse(link)
        )
    )
    manager.updateAppWidget(id, views)
}

class FasyButtonG1Widget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) updateButton(context, manager, id, "btn_g1_image", "fasy://g1")
    }
}

class FasyButtonG2Widget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) updateButton(context, manager, id, "btn_g2_image", "fasy://g2")
    }
}

class FasyButtonQuickWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) updateButton(context, manager, id, "btn_quick_image", "fasy://quick")
    }
}