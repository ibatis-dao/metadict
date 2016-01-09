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

import java.io.Serializable;
import java.lang.reflect.InvocationTargetException;

/**
 * @author serg
 * @param <B> bean type
 * @param <V> property value type
 */
public interface IDataProperty<B, V> extends Serializable {

    /*
    * Returns the type of the Property.
    */
    Class<? extends V> getType();

    /**
     * Gets the value stored in the Property.
     * @param bean is a data object, which has property
     * @return property value
     * @throws InvocationTargetException
     * @throws java.lang.IllegalAccessException
     */
    
    V getValue(B bean) throws InvocationTargetException, IllegalAccessException, IllegalArgumentException;

    /**
     * Sets the value of the Property.
     * @param bean
     * @param newValue
     * @throws InvocationTargetException
     * @throws IllegalAccessException
     * @throws IllegalArgumentException
     */
    
    void setValue(B bean, V newValue) throws InvocationTargetException, IllegalAccessException, IllegalArgumentException;

}
