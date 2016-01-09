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

import java.util.List;
import java.util.Set;

import org.apache.ibatis.mapping.ResultFlag;

/**
 *
 * @author serg
 */
public class BeanPropertyMapping {
    
// properties got from org.apache.ibatis.mapping.ResultMapping
    
    private String property;
    private String column;
    private Class<?> javaType;
    private List<ResultFlag> flags;
    private Set<String> notNullColumns;
    
    
    public BeanPropertyMapping(String property, String column) {
        this(property, column, null, null, null);
    }
    
	public BeanPropertyMapping(String property, String column, Class<?> javaType) {
        this(property, column, javaType, null, null);
    }
    
    public BeanPropertyMapping(String property, String column, Class<?> javaType, List<ResultFlag> flags, Set<String> notNullColumns) {
        this.property = property;
        this.column = column;
        this.javaType = javaType;
        this.flags = flags;
        this.notNullColumns = notNullColumns; 
    }
    
    public String getProperty() {
        return property;
    }

    public String getColumn() {
        return column;
    }

    public Class<?> getJavaType() {
        return javaType;
    }

    public List<ResultFlag> getFlags() {
		return flags;
	}

	public Set<String> getNotNullColumns() {
		return notNullColumns;
	}

}
