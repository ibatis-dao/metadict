package das.base;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Struct;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

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
		log.debug("setNonNullParameter(paramIdx={}, parameter.class={}, jdbcType={})", parameterIndex, parameter==null?null:parameter.getClass().getName(), jdbcType);
		//setNonNullParameter(paramIdx=1, parameter.class=app.dict.country.Country, jdbcType=STRUCT)
		Connection conn = ps.getConnection();
		log.debug("configuration={}", configuration); 
		String jdbcTypeName = getJDBCTypeName(conn, parameter);
		log.debug("jdbcTypeName={}", jdbcTypeName);
		//conn.createStruct(jdbcTypeName, attributes)
		// Create descriptors for each Oracle record type required
		//Struct structDesc = StructDescriptor.createDescriptor("LISA.T_USR_CONTRAGENT_BLACKLIST_ROW", conn);
		//STRUCT s = new STRUCT(structDesc, conn, parameter);

		//Connection conn = ps.getConnection();
		//conn.createStruct(typeName, attributes);
		/*
		Struct location = (Struct)ps.getObject("LOCATION");
        Object[] locAttrs = location.getAttributes();
        */
		ps.setObject(parameterIndex, parameter);
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
