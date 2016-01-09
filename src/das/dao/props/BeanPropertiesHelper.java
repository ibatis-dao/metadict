package das.dao.props;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public class BeanPropertiesHelper {
	
	public static List<String> getColumnNames(IBean<?, ?> beanProperties) {
		List<String> columnNames = null;
		if (beanProperties != null) {
			columnNames = new ArrayList<String>();
        	Collection<?> propIDs = beanProperties.getDataPropertyIds();
        	if (propIDs != null) {
            	for (Object propID : propIDs) {
            		IDataProperty<?,?> prop = beanProperties.getDataProperty(propID);
            		if (prop != null) {
            			if (prop instanceof IDataPropertyORMMapped) {
            				columnNames.add(((IDataPropertyORMMapped<?,?>)prop).getColumnName());
            			}
            			
            		}
            	}
        	}
    	}
		return columnNames;
	}
	
	public static List<String> getPrimaryKeyColumns(IBean<?, ?> beanProperties) {
		List<String> columnNames = null;
		if (beanProperties != null) {
			columnNames = new ArrayList<String>();
        	Collection<?> propIDs = beanProperties.getDataPropertyIds();
        	if (propIDs != null) {
            	for (Object propID : propIDs) {
            		IDataProperty<?,?> prop = beanProperties.getDataProperty(propID);
            		if (prop != null) {
            			if (prop instanceof IDataPropertyORMMapped) {
            				IDataPropertyORMMapped<?, ?> pom = (IDataPropertyORMMapped<?,?>)prop;
            				if (pom.isPrimaryKey()) {
            					columnNames.add(pom.getColumnName());
            				}
            			}
            			
            		}
            	}
        	}
    	}
		return columnNames;
	}
	
    /*
     * Returns object, represents primary key for given row
     * @return object, represents primary key for given row
     */
    @SuppressWarnings({ "rawtypes", "unchecked" })
	public static Object[] getPrimaryKey(IBean<?,?> beanProperties, Object row) throws InvocationTargetException, IllegalAccessException, IllegalArgumentException {
    	List<Object> pk = new ArrayList<Object>();
    	if (beanProperties != null) {
    		Collection<?> propIDs = beanProperties.getDataPropertyIds();
        	if (propIDs != null) {
            	for (Object propID : propIDs) {
            		IDataProperty<?,?> prop = beanProperties.getDataProperty(propID);
            		if (prop != null) {
            			if (prop instanceof IDataPropertyORMMapped) {
            				IDataPropertyORMMapped<Object, Object> pom = (IDataPropertyORMMapped)prop;
            				if (pom.isPrimaryKey()) {
            					pk.add(pom.getValue(row));
            				}
            			}
            			
            		}
            	}
        	}
    	}
    	return pk.toArray();
    }


}
