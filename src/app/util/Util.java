package app.util;

import java.text.DecimalFormat;

public class Util {

	public Util() {
	}
	
    public static String readableFileSize1024(final long size) {
        if(size <= 0L) return "0";
        final String[] units = new String[] { "B", "kB", "MB", "GB", "TB", "PB", "EB" };
        int digitGroups = (int) (Math.log10(size)/Math.log10(1024));
        return new DecimalFormat("#,##0.#").format(size/Math.pow(1024, digitGroups)) + " " + units[digitGroups];
    }
    
    public static String readableFileSize1000(final long size) {
        if(size <= 0L) return "0";
        final String[] units = new String[] { "Bi", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB" };
        int digitGroups = (int) (Math.log10(size)/Math.log10(1000));
        return new DecimalFormat("#,##0.#").format(size/Math.pow(1000, digitGroups)) + " " + units[digitGroups];
    }
    
}
