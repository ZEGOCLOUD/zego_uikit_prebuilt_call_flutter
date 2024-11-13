package com.zegocloud.uikit.call_plugin.notification;

import android.content.Context;

import java.util.regex.Pattern;

public class AudioUtils {
    public static String cleanMediaPath(String mediaPath) {
        if (mediaPath != null) {
            Pattern pattern = Pattern.compile("^https?:\\/\\/", Pattern.CASE_INSENSITIVE);
            Pattern pattern2 = Pattern.compile("^(asset:\\/\\/)(.*)", Pattern.CASE_INSENSITIVE);
            Pattern pattern3 = Pattern.compile("^(file:\\/\\/)(.*)", Pattern.CASE_INSENSITIVE);
            Pattern pattern4 = Pattern.compile("^(resource:\\/\\/)(.*)", Pattern.CASE_INSENSITIVE);

            if(pattern.matcher(mediaPath).find()){
                return mediaPath;
            }

            if(pattern2.matcher(mediaPath).find()){
                return pattern2.matcher(mediaPath).replaceAll("$2");
            }

            if(pattern3.matcher(mediaPath).find()){
                return pattern3.matcher(mediaPath).replaceAll("/$2");
            }

            if(pattern4.matcher(mediaPath).find()){
                return pattern4.matcher(mediaPath).replaceAll("$2");
            }
        }
        return null;
    }

    public static int getAudioResourceId(Context context, String audioReference){
        audioReference = AudioUtils.cleanMediaPath(audioReference);
        String[] reference = audioReference.split("\\/");

        try {
            int resId = 0;

            String type = reference[0];
            String label = reference[1];

            // Resources protected from obfuscation
            // https://developer.android.com/studio/build/shrink-code#strict-reference-checks
            String name = String.format("res_%1s", label);
            resId = context.getResources().getIdentifier(name, type, context.getPackageName());

            if(resId == 0){
                resId = context.getResources().getIdentifier(label, type, context.getPackageName());
            }

            return resId;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }
}
