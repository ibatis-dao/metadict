package das.orm;

import java.sql.Connection;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.DriverPropertyInfo;
import java.sql.SQLException;
import java.util.Enumeration;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Logger;

import org.apache.ibatis.datasource.unpooled.UnpooledDataSource;
import org.apache.ibatis.io.Resources;

public class SinletonDataSource extends UnpooledDataSource {

	private static Map<String, Driver> registeredDrivers = new ConcurrentHashMap<String, Driver>();
	private Connection connection;
	
	static {
		Enumeration<Driver> drivers = DriverManager.getDrivers();
		while (drivers.hasMoreElements()) {
			Driver driver = drivers.nextElement();
			registeredDrivers.put(driver.getClass().getName(), driver);
		}
	}
	
	public Connection getConnection() throws SQLException {
		return doGetConnection(getUsername(), getPassword());
	}

	public Connection getConnection(String username, String password) throws SQLException {
		return doGetConnection(username, password);
	}
	
	private Connection doGetConnection(String username, String password) throws SQLException {
		if ((connection != null) &&
			(
				((username != null) && (username.equals(getUsername()))) ||
				((username == null) && (getUsername() == null))
			) &&
			(
				((password != null) && (password.equals(getPassword()))) ||
				((password == null) && (getPassword() == null))
			)
		){
			return connection;
		}
		Properties props = new Properties();
		if (getDriverProperties() != null) {
			props.putAll(getDriverProperties());
		}
		if (username != null) {
			props.setProperty("user", username);
		}
		if (password != null) {
			props.setProperty("password", password);
		}
		initializeDriver();
	    connection = DriverManager.getConnection(getUrl(), props);
	    configureConnection(connection);
		return connection;
	}

	private synchronized void initializeDriver() throws SQLException {
		if (!registeredDrivers.containsKey(getDriver())) {
			Class<?> driverType;
			try {
				if (getDriverClassLoader() != null) {
					driverType = Class.forName(getDriver(), true, getDriverClassLoader());
				} else {
					driverType = Resources.classForName(getDriver());
				}
				// DriverManager requires the driver to be loaded via the system ClassLoader.
				// http://www.kfu.com/~nsayer/Java/dyn-jdbc.html
				Driver driverInstance = (Driver)driverType.newInstance();
				DriverManager.registerDriver(new DriverProxy(driverInstance));
				registeredDrivers.put(getDriver(), driverInstance);
			} catch (Exception e) {
				throw new SQLException("Error setting driver on SinletonDataSource. Cause: " + e);
			}
		}
	}

	private void configureConnection(Connection conn) throws SQLException {
		if (isAutoCommit() != null && isAutoCommit() != conn.getAutoCommit()) {
			conn.setAutoCommit(isAutoCommit());
		}
		if (getDefaultTransactionIsolationLevel() != null) {
			conn.setTransactionIsolation(getDefaultTransactionIsolationLevel());
		}
	}

	private static class DriverProxy implements Driver {
		private Driver driver;

		DriverProxy(Driver d) {
			this.driver = d;
		}

		public boolean acceptsURL(String u) throws SQLException {
			return this.driver.acceptsURL(u);
		}

		public Connection connect(String u, Properties p) throws SQLException {
			return this.driver.connect(u, p);
		}

		public int getMajorVersion() {
			return this.driver.getMajorVersion();
		}

		public int getMinorVersion() {
			return this.driver.getMinorVersion();
		}

		public DriverPropertyInfo[] getPropertyInfo(String u, Properties p) throws SQLException {
			return this.driver.getPropertyInfo(u, p);
		}

		public boolean jdbcCompliant() {
			return this.driver.jdbcCompliant();
		}

		public Logger getParentLogger() {
			return Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
		}
	}

}
