package app.dict.country;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.HashMap;
import java.util.Map;

import org.apache.ibatis.exceptions.PersistenceException;

import das.base.CRUDSingleDAO;
import das.base.CRUDSingleMapper;
import das.orm.ORMFacade;

public class CountryDAO extends CRUDSingleDAO<Country, CountryDAO.CountryMapper> {

	/**
	 * интерфейс, декларирующий методы объекта доступа к данным.
	 * на основе описания этого интерфейса MyBATIS отображает объявленные методы в операторы sql
	 * @author serg
	 *
	 */
	public interface CountryMapper extends CRUDSingleMapper<Country>{
		public Country findByN3c(String number3code) throws IOException;
	}
	
	/**
	 * поддержка преобразования составного (объектного) типа БД в класс java средствами драйвера jdbc 
	 * @author serg
	 *
	 */
	public class CountrySQLData implements SQLData {
		
		private String sqlTypeName;
		private Country country;
		
		public CountrySQLData(Country country, String sqlTypeName) {
			log.trace("CountrySQLData(country={}, sqlTypeName={})", country!=null?country:null, sqlTypeName);
			this.country = country;
			this.sqlTypeName = sqlTypeName;
		}
		
		@Override
		public String getSQLTypeName() throws SQLException {
			log.trace("getSQLTypeName()={}", sqlTypeName);
			return sqlTypeName;
		}

		@Override
		public void readSQL(SQLInput stream, String sqlTypeName) throws SQLException {
			log.trace("readSQL(sqlTypeName={})", sqlTypeName);
			country.setId(stream.readString()); // идентификатор
			country.setName(stream.readString());  // наименование
			country.setNumber3code(stream.readString()); // ISO 3166 Number3 code
			country.setAlpha2code(stream.readString()); // ISO 3166 Alpha2 code
			country.setAlpha3code(stream.readString()); // ISO 3166 Alpha3 code
		}

		@Override
		public void writeSQL(SQLOutput stream) throws SQLException {
			log.trace("writeSQL()");
			stream.writeString(country.getId());
			stream.writeString(country.getName());
			stream.writeString(country.getNumber3code());
			stream.writeString(country.getAlpha2code());
			stream.writeString(country.getAlpha3code());
		}
		
	}

	/**
	 * поддержка методов объекта доступа к данным. реализация интерфейса CRUDSingleMapper
	 * @throws IOException, SQLException 
	 */
	public CountryDAO() throws IOException, IOException, SQLException {
        super(CountryDAO.CountryMapper.class);
		log.trace(">>> constructor >>>");
		ORMFacade orm;
		orm = new ORMFacade();
		Connection conn = orm.getDBConnection();
		
		Map<String,Class<?>> map = conn.getTypeMap();
		if (map == null) {
			map = new HashMap<String,Class<?>>();
		}
		//log.debug("map={}", map);
		map.put("public.i18_country", CountrySQLData.class);
		conn.setTypeMap(map);

	}
	
	public Country findByN3c(String number3code) throws IOException {
        log.trace(">>> getAll");
        ORMFacade orm = new ORMFacade();
        try {
        	CountryDAO.CountryMapper mapper = orm.getMapper(CountryDAO.CountryMapper.class);
        	Country res = mapper.findByN3c(number3code);
            log.trace("<<< getAll");
            return res;
        } catch (IOException e) {
            log.error(null, e);
            throw e;
        } finally {
            orm.closeDBSession();
        }
	}

}
