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

import java.beans.IntrospectionException;
import java.beans.PropertyDescriptor;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author serg
 */
public class BeanPropertiesDescribed extends BeanProperties {

	private static final Logger log = LoggerFactory.getLogger(BeanPropertiesDescribed.class);
    /**
	 * 
	 */
	private static final long serialVersionUID = 6650106557980236807L;

	public BeanPropertiesDescribed(Class<?> beanClass) throws IntrospectionException {
		super(beanClass);
		log.trace(">>> BeanPropertiesDescribed.construtor");
    }
    
    @Override
    protected void addAllBeanProperties(PropertyDescriptor[] pds) {
        //заполняем свойства на основе сведений о классе 
        for (int i = 0; i < pds.length; i++) {
            beanProperties.put(i, new BeanPropertyDescribed(pds[i]));
            log.debug(pds[i].getName());
        }
    }
    
}
