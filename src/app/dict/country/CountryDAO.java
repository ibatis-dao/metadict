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
		log.debug("map={}", map);
		map.put("i18_country", Country.class);
		conn.setTypeMap(map);

	}
	
	@Override
	public int insert(Country item) throws IOException {
		Connection conn = new ORMFacade().getDBConnection();
		Map<String, Class<?>> map;
		try {
			map = conn.getTypeMap();
			if (map != null) {
				Class<?> c = map.get("i18_country");
				log.debug("map(i18_country)={}", c);
			} else {
				log.debug("map=null");
			}
		} catch (SQLException e) {
			log.error("", e);
		}
		
        return super.insert(item);
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
