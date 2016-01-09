package das.dao.props;

import java.beans.PropertyDescriptor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.List;

import org.apache.ibatis.mapping.ResultFlag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class BeanPropertyORMMapped implements IDataPropertyORMMapped<Object,Object> {

    /**
	 * 
	 */
	private static final long serialVersionUID = 7646636874602408641L;
	private static final Logger log = LoggerFactory.getLogger(BeanProperty.class);
    private final PropertyDescriptor pd;
    private final BeanPropertyMapping bpm;

    public BeanPropertyORMMapped(PropertyDescriptor pd, BeanPropertyMapping bpm) {
    	log.trace(">>> constructor");
        if (pd == null) {
            throw new IllegalArgumentException("Wrong parameter pd (= null)");
        }
        if (bpm == null) {
            throw new IllegalArgumentException("Wrong parameter bpm (= null)");
        }
        this.pd = pd;
        this.bpm = bpm;
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

	@Override
	public String getName() {
		return pd.getName();
	}

	@Override
	public void setName(String name) {
		pd.setName(name);
	}

	@Override
	public String getColumnName() {
		return bpm.getColumn();
	}
	
	/*
     * Return - either column is part of primary key or not  
     */
	@Override
    public boolean isPrimaryKey() {
		List<ResultFlag> f = bpm.getFlags();
		return f.contains(ResultFlag.ID);
	}

}
