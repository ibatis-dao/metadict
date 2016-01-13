/**
 * 
 */
package app.dict;

import static org.junit.Assert.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import app.MainView;
import app.dict.country.Country;
import app.dict.country.CountryDAO;

/**
 * @author serg
 *
 */
public class CountryDAOtst {

	private static final transient Logger log = LoggerFactory.getLogger(CountryDAOtst.class);

	/**
	 * Test method for {@link app.dict.country.CountryDAO#CountryDAO()}.
	 * @throws SQLException 
	 * @throws IOException 
	 */
	//@Test
	public void testCountryDAO() throws IOException, SQLException {
		CountryDAO c = new CountryDAO();
		assertNotNull(c);
	}

	/**
	 * Test method for {@link das.base.CRUDSingleDAO#getAll()}.
	 * @throws IOException 
	 * @throws SQLException 
	 */
	//@Test
	public void testGetAll() throws IOException, SQLException {
		CountryDAO c = new CountryDAO();
		assertNotNull(c);
		List<Country> l = c.getAll();
		assertNotNull(l);
	}

	/**
	 * Test method for {@link das.base.CRUDSingleDAO#insert(), #update(), #delete(), #findByN3c()}.
	 * @throws IOException 
	 * @throws SQLException 
	 */
	@Test
	public void testCUD() throws IOException, SQLException {
		CountryDAO c = new CountryDAO();
		assertNotNull(c);
		Country item = new Country(null, "name01", "1", "00", "000");
		assertNotNull(item);
		int cnt = c.insert(item);
		assertTrue(cnt > 0);
		item = c.findByN3c("1");
		assertNotNull(item);
		log.debug("item.ID="+item.getId());
		assertTrue("1".equals(item.getNumber3code()));
		cnt = c.update(item);
		assertTrue(cnt > 0);
		cnt = c.delete(item);
		assertTrue(cnt > 0);
	}

	/**
	 * Test method for {@link das.base.CRUDSingleDAO#update(java.lang.Object)}.
	 */
	//@Test
	public void testUpdate() {
		fail("Not yet implemented");
	}

	/**
	 * Test method for {@link das.base.CRUDSingleDAO#delete(java.lang.Object)}.
	 */
	//@Test
	public void testDelete() {
		fail("Not yet implemented");
	}

}
