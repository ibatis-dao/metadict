/*
 * Copyright 2015 serg.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package das.dao.props;

import java.util.Enumeration;

/**
 *
 * @author serg
 * @param <B>
 * @param <V>
 */
public interface IDataPropertyDescribed<B, V> extends IDataProperty<B, V> {
    /*
    * Gets the name (usually short "programmatic", non localizable) of the Property.
    */
    String getName();
    /*
    * Sets the name (usually short "programmatic", non localizable) of the Property.
    */
    void setName(String name);
    /*
    * Gets the descriptive name (usually not so short, "user-friendly", localizable) of the Property.
    */
    String getDisplayName();
    /*
    * Sets the descriptivename (usually not so short, "user-friendly", localizable) of the Property.
    */
    void setDisplayName(String displayName);
    /*
    * Gets the writeability status of the Property.
    */
    boolean getReadOnly();
    /*
    * Sets the writeability status of the Property.
    */
    void setReadOnly(boolean ro);
    
    /*
    * Gets the visibility status of the Property.
    */
    boolean getVisible();
    /*
    * Sets the visibility status of the Property.
    */
    void setVisible(boolean v);

    /*
    * Gets the Property ability to store NULL value.
    */
    boolean getNullable();
    /*
    * Sets the Property ability to store NULL value.
    */
    void setNullable(boolean v);

    /**
     * Gets an enumeration of the locale-independent names of this
     * feature.
     *
     * @return  An enumeration of the locale-independent names of any
     *    attributes that have been registered with setValue.
     */
    Enumeration<String> getAttributeNames();
    
    /**
     * Associate a named attribute with this feature.
     *
     * @param attributeName  The locale-independent name of the attribute
     * @param value  The value.
     */
    public void setAttributeValue(String attributeName, Object value);

    /**
     * Retrieve a named attribute with this feature.
     *
     * @param attributeName  The locale-independent name of the attribute
     * @return  The value of the attribute.  May be null if
     *     the attribute is unknown.
     */
    public Object getAttributeValue(String attributeName);
}
