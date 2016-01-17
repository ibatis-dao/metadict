package das.base;

import java.beans.IntrospectionException;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Type;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Struct;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.apache.ibatis.exceptions.PersistenceException;
import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import app.dict.country.Country;
import das.dao.props.BeanPropertiesORMMapped;
import das.dao.props.BeanPropertyMapping;
import das.dao.props.IDataProperty;
import das.excpt.ENullArgument;
import das.orm.ORMFacade;

public class StructTypeHandler<B> extends BaseTypeHandler<B> {

    private final Logger log = LoggerFactory.getLogger(this.getClass());
    
    private String getJDBCTypeName(Connection conn, B javaObject) throws SQLException {
    	String res = null;
    	Map<String, Class<?>> map = conn.getTypeMap();
    	log.debug("map == {}, javaObject == {}", map==null?"null":"non-null", javaObject==null?"null":"non-null");
    	if ((map != null) && (javaObject != null)) {
			log.debug("(map != null) && (parameter != null)");
			Class<?> cl = javaObject.getClass();
			if (map.containsValue(cl)) {
				log.debug("map.containsValue({})=true", cl.getName());
				Set<Entry<String, Class<?>>> set = map.entrySet();
				Iterator<Entry<String, Class<?>>> itr = set.iterator(); 
				Entry<String, Class<?>> entry;
				entry = itr.next();
				while (entry != null) {
					if (entry.getValue() == cl) {
						res = entry.getKey();
						log.debug("res={}", res);
						break;
					}
					entry = itr.next();
				}
			} else {
				log.debug("map.containsValue({})=false", cl.getName());
			}
		} else {
			log.debug("((map != null) && (javaObject != null)) = false");
		}
		return res;
    }
    
	@Override
	public void setNonNullParameter(PreparedStatement ps, int parameterIndex, B parameter, JdbcType jdbcType) throws SQLException {
		if (parameter == null) {
			throw new ENullArgument("setNonNullParameter", "parameter");
		}
		Class<?> beanClass = parameter.getClass();
		log.debug("setNonNullParameter(paramIdx={}, parameter.class={}, jdbcType={})", parameterIndex, beanClass.getName(), jdbcType);
		Connection conn = ps.getConnection();
		//setNonNullParameter(paramIdx=1, parameter.class=app.dict.country.Country, jdbcType=STRUCT)
		/*
		log.debug("configuration={}", configuration==null?"null":"non-null");
		Type type = getRawType();
		log.debug("type={}", type);
		*/
		ORMFacade orm;
		try {
			orm = new ORMFacade(conn);
			//orm.getParameterMapNames();
			String sqlTypeName = orm.getSqlTypeForClass(beanClass);
			log.debug("sqlTypeName={}", sqlTypeName);
			if (sqlTypeName == null) {
				ps.setObject(parameterIndex, parameter);
			} else {
				BeanPropertiesORMMapped bpom;
				try {
					log.debug("before new BeanPropertiesORMMapped(");
					bpom = new BeanPropertiesORMMapped(beanClass, orm.getBeanPropertiesMapping(beanClass));
					Collection<Object> ids = bpom.getDataPropertyIds();
					Object[] attributes = new Object[ids.size()];
					int idx = 0;
					for (Object pid : ids) {
						IDataProperty<Object,Object> dp = bpom.getDataProperty(pid);
						Object val = dp.getValue(parameter);
						log.debug("DataProperty.Id={}, Value={}", pid, val);
						attributes[idx] = val;
						idx++;
					}
					log.debug("before createStruct()");
					/* в драйвере postgresql метод работы с композитными типами не реализован
					java.sql.SQLFeatureNotSupportedException: 
					Method org.postgresql.jdbc4.Jdbc4Connection.createStruct(String, Object[]) is not yet implemented.
					*/
					Struct struct = conn.createStruct(sqlTypeName, attributes); 
					log.debug("before setObject()");
					ps.setObject(parameterIndex, struct);
				} catch (IntrospectionException e) {
					log.error("", e);
				} catch (InvocationTargetException e) {
					log.error("", e);
				} catch (IllegalAccessException e) {
					log.error("", e);
				} catch (IllegalArgumentException e) {
					log.error("", e);
				}
			}
		} catch (PersistenceException e) {
			log.error("", e);
		} catch (IOException e) {
			log.error("", e);
		}
		/*Connection conn = ps.getConnection();
		log.debug("configuration={}", configuration); 
		String jdbcTypeName = getJDBCTypeName(conn, parameter);
		log.debug("jdbcTypeName={}", jdbcTypeName);*/
		//
		// Create descriptors for each Oracle record type required
		//Struct structDesc = StructDescriptor.createDescriptor("LISA.T_USR_CONTRAGENT_BLACKLIST_ROW", conn);
		//STRUCT s = new STRUCT(structDesc, conn, parameter);
		//
		//conn.createStruct(typeName, attributes);
		/*
		Struct location = (Struct)ps.getObject("LOCATION");
        Object[] locAttrs = location.getAttributes();
        */
	}

	@Override
	public B getNullableResult(ResultSet rs, String columnName) throws SQLException {
		log.debug("getNullableResult(ResultSet, columnName={})", columnName);
		return (B) rs.getObject(columnName);
	}
	
	@Override
	public B getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
		log.debug("getNullableResult(ResultSet, columnIndex={})", columnIndex);
		return (B) rs.getObject(columnIndex);
	}
	
	@Override
	public B getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
		log.debug("getNullableResult(CallableStatement, columnIndex={})", columnIndex);
		return (B) cs.getObject(columnIndex);
	}

}
