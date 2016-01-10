package app.dict.country;

import java.io.IOException;

import das.base.CRUDSingleDAO;
import das.base.CRUDSingleMapper;
import das.orm.ORMFacade;

public class CountryDAO extends CRUDSingleDAO<Country, CountryDAO.CountryMapper> {

	public interface CountryMapper extends CRUDSingleMapper<Country>{
		public Country findByN3c(String number3code) throws IOException;
	}

	public CountryDAO() {
        super(CountryDAO.CountryMapper.class);
		log.trace(">>> constructor >>>");
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
