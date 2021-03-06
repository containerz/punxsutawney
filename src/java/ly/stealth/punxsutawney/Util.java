/**
 * Licensed to the Apache Software Foundation (ASF) under one or more contributor license agreements. See the NOTICE
 * file distributed with this work for additional information regarding copyright ownership. The ASF licenses this file
 * to You under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */

package ly.stealth.punxsutawney;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class Util {
    @SuppressWarnings("UnusedDeclaration")
    static void copyAndClose(InputStream in, OutputStream out) throws IOException {
        byte[] buffer = new byte[16 * 1024];
        int actuallyRead = 0;

        try(InputStream _in = in; OutputStream _out = out) {
            while (actuallyRead != -1) {
                actuallyRead = in.read(buffer);
                if (actuallyRead != -1) out.write(buffer, 0, actuallyRead);
            }
        }
    }

    public static String join(Iterable<?> objects, String separator) {
        String result = "";

        for (Object object : objects)
            result += object + separator;

        if ( result.length() > 0 )
            result = result.substring(0, result.length() - separator.length());

        return result;
    }

    public static String uncapitalize(String s) {
        if (s == null || s.isEmpty()) return s;
        char[] chars = s.toCharArray();
        chars[0] = Character.toLowerCase(chars[0]);
        return new String(chars);
    }
}