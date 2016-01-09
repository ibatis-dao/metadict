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

import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author serg
 */
public class BeanProperties implements IBean<Object,Object> {

    /**
	 * 
	 */
	private static final long serialVersionUID = -7810013525182389945L;
	protected static final Logger log = LoggerFactory.getLogger(BeanProperties.class);
    protected final Class<?> beanClass;
    protected final PropertyDescriptor[] pds;
    protected Map<Object,IDataProperty<Object,Object>> beanProperties;

    public BeanProperties(Class<?> beanClass) throws IntrospectionException {
        log.trace(">>> constructor");
    	if (beanClass == null) {
            throw new IllegalArgumentException("Wrong parameter beanClass (= null)");
        }
        this.beanClass = beanClass;
        pds = getBeanPropertyDescriptors(beanClass);
    }
    
	@Override
    public Class<?> getBeanClass() {
    	return beanClass;
    }
    
	public Map<Object, IDataProperty<Object, Object>> getBeanProperties() {
		if (beanProperties == null) {
			beanProperties = new HashMap<Object,IDataProperty<Object,Object>>((int)(pds.length/0.75), (float) 0.75);
			addAllBeanProperties(pds);
		}
		return beanProperties;
	}

    protected PropertyDescriptor[] getBeanPropertyDescriptors(Class<?> beanClass) throws IntrospectionException {
        if (beanClass == null) {
            throw new IllegalArgumentException("Wrong parameter beanClass (= null)");
        }
        //заполняем свойства на основе сведений о классе 
        BeanInfo beanInfo = Introspector.getBeanInfo(beanClass);
        return beanInfo.getPropertyDescriptors();
    }
    
    protected void addAllBeanProperties(PropertyDescriptor[] pds) {
        //заполняем свойства на основе сведений о классе 
        for (int i = 0; i < pds.length; i++) {
        	getBeanProperties().put(i, new BeanProperty(pds[i]));
            log.debug(pds[i].getName());
        }
    }
    
    @Override
    public boolean addDataProperty(Object id, IDataProperty<Object,Object> property) {
    	getBeanProperties().put(id, property);
        return true;
    }

    @Override
    public IDataProperty<Object,Object> getDataProperty(Object id) {
        return getBeanProperties().get(id);
    }

    @Override
    public Collection<Object> getDataPropertyIds() {
        return getBeanProperties().keySet(); //values();
    }

    @Override
    public boolean removeDataProperty(Object id) {
        return (getBeanProperties().remove(id) != null);
    }

}
