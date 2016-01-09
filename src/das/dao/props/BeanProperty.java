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

import java.beans.PropertyDescriptor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author serg
 */
public class BeanProperty implements IDataProperty<Object,Object> {
    
    /**
	 * 
	 */
	private static final long serialVersionUID = 2480470991038910376L;
	private static final Logger log = LoggerFactory.getLogger(BeanProperty.class);
    private final PropertyDescriptor pd;
    
    public BeanProperty(PropertyDescriptor pd) {
    	log.trace(">>> BeanProperty.construtor");
    	if (pd == null) {
            throw new IllegalArgumentException("Wrong parameter pd (= null)");
        }
        this.pd = pd;
    }

    @Override
    public Class<?> getType() {
        return pd.getPropertyType();
    }

    @Override
    public Object getValue(Object bean) throws InvocationTargetException, IllegalAccessException, IllegalArgumentException {
        Method m = pd.getReadMethod();
        if (m != null) {
            Object[] params = null;
            return m.invoke(bean, params);
        } else {
            throw new IllegalAccessException("No getter method for property "+pd.getName());
        }
    }

    @Override
    public void setValue(Object bean, Object newValue) throws InvocationTargetException, IllegalAccessException, IllegalArgumentException {
        Method m = pd.getWriteMethod();
        if (m != null) {
            m.invoke(bean, newValue);
        } else {
            throw new IllegalAccessException("No setter method for property "+pd.getName());
        }
    }

}
