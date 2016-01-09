package das.dao;

import java.io.IOException;
import java.util.List;
import java.util.Set;

import das.dao.props.IBean;
import das.dto.SQLParams;

/** 
 * @author serg
 * маркерный интерфейс доступа к данным
 **/
public interface IDataSet {

    /**
     * capabilities, supported by these datasource implementation
     */
	public enum Capabilities {
    	PagingLimits,
    	Sorting,
    	Filtering,
    	Writing,
    	Transactional
    }

    /**
     * интерфейс для получения описания источника данных 
     */
	public interface Description extends IDataSet {
        
        /**
         * retrieve properties description of bean, which is represents of data row 
         */
    	public IBean<?, ?> getBeanProperties();
        
        /**
         * retrieve set of capabilities, supported by these datasource implementation.
         * 
         * @return set of supported capabilities by these datasource implementation
         */
        public Set<Capabilities> getCapabilities();
    }
	
	/**
	 * интерфейс для получения кол-ва строк в наборе данных 
	 */
	public interface Range extends IDataSet {
		
		/**
		 * минимальный номер строки в наборе данных. зависит от конкретной реализации, 
		 * от технологии БД, от драйвера доступа к БД
		 * @return минимальный номер строки в наборе данных.
		 * @throws UnsupportedOperationException
		 */
		int getMinOffset() throws UnsupportedOperationException;

		/**
		 * количество строк в наборе данных при условиях, определенных в фильтре в составе параметра param
		 * @return количество строк в наборе данных.
		 * @throws IOException
		 */
		int getRowCount(SQLParams param) throws IOException;
		
	}
    
    /**
     * интерфейс для чтения данных из источника данных 
     */
    public interface Reader<DTOclass> extends IDataSet {
        /**
         * Executes a paged SQL query and returns the ResultSet. The query is
         * defined through implementations of this IDAO interface.
         * 
         * @param SQLParams param 
         * 	defines paging offset and limit, sorting and filtering parameters
         * @return a List of bean containing the rows of the page
         * @throws IOException
         *             if the database access fails.
         */
        public List<DTOclass> select(SQLParams param) throws IOException;

    }

    /**
     * интерфейс для записи данных из источника данных 
     */
    public interface Writer<DTOclass> extends IDataSet {
        
        /**
         * Add a new row in the database. 
         * 
         * @param row
         *    A bean class containing the values to be stored.
         * @return the number of affected rows in the database
         * @throws IOException
         */
        public int insertRow(DTOclass row) throws IOException;

        /**
         * Update an existing row in the database. 
         * 
         * @param row
         *    A bean class containing the values to be stored.
         * @return the number of affected rows in the database
         * @throws IOException
         */
        public int updateRow(DTOclass row) throws IOException;

        /**
         * Removes the given RowItem from the database.
         * 
         * @param row
         *    A bean class containing the values to be removed
         * @return the number of affected rows in the database
         * @throws IOException
         */
        public int deleteRow(DTOclass row) throws IOException;
        
    }

    /**
     * интерфейс для поддержки транзакций 
     */
    public interface Transactable extends IDataSet {

        /**
         * Starts a new database transaction. Used when storing multiple changes.
         * 
         * Note that if a transaction is already open, it will be rolled back when a
         * new transaction is started.
         * 
         * @throws IOException
         *             if the database access fails.
         */
        public void beginTransaction() throws IOException;

        /**
         * Commits a transaction. If a transaction is not open nothing should
         * happen.
         * 
         * @throws IOException
         *             if the database access fails.
         */
        public void commit() throws IOException;

        /**
         * Rolls a transaction back. If a transaction is not open nothing should
         * happen.
         * 
         * @throws IOException
         *             if the database access fails.
         */
        public void rollback() throws IOException;
    }
    
}
