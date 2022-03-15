package com.example.geocarsclient;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

class StartGeocars:BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (Intent.ACTION_BOOT_COMPLETED == intent!!.action) {
            var i = Intent(context, MainActivity::class.java);
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context!!.startActivity(i); 
        }
    }
}

