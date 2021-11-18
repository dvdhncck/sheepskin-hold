package com.quackomatic.sheepskin;

import android.media.ExifInterface;
import android.os.Build;

import androidx.annotation.RequiresApi;

import java.io.File;
import java.io.IOException;

public class TileCache {

    @RequiresApi(api = Build.VERSION_CODES.Q)
    public float[] doSomething(String filePath) throws IOException {

        ExifInterface exifInterface = new ExifInterface(new File(filePath));

        float[] result = new float[2];
        exifInterface.getLatLong(result);
        return result;
    }
}
