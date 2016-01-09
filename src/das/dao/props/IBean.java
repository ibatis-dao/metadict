package das.dao.props;

public interface IBean<B,V> extends IHasDataProperty<B,V>{
	
	public Class<?> getBeanClass();

}
