package das.dao.props;

public interface IDataPropertyORMMapped<B, V> extends IDataProperty<B, V> {
    /*
    * Gets the name (usually short "programmatic", non localizable) of the Property.
    */
    String getName();
    /*
    * Sets the name (usually short "programmatic", non localizable) of the Property.
    */
    void setName(String name);
    /*
    * Gets the data base column name, related to the Property.
    */
    String getColumnName();

    /*
     * Return - either column is part of primary key or not  
     */
    boolean isPrimaryKey();
}
