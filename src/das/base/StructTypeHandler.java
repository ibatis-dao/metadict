package das.base;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Struct;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class StructTypeHandler<B> extends BaseTypeHandler<B> {

    private final Logger log = LoggerFactory.getLogger(this.getClass());
    
	@Override
	public void setNonNullParameter(PreparedStatement ps, int parameterIndex, B parameter, JdbcType jdbcType) throws SQLException {
		log.debug("setNonNullParameter(paramIdx={}, parameter.class={}, jdbcType={})", parameterIndex, parameter==null?null:parameter.getClass().getName(), jdbcType);
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
