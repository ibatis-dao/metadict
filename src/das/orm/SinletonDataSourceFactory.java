package das.orm;

import org.apache.ibatis.datasource.unpooled.UnpooledDataSourceFactory;

public class SinletonDataSourceFactory extends UnpooledDataSourceFactory {
	
	public SinletonDataSourceFactory() {
		this.dataSource = new SinletonDataSource();
	}

}
