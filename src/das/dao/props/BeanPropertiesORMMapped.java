package das.dao.props;

import java.beans.IntrospectionException;
import java.beans.PropertyDescriptor;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class BeanPropertiesORMMapped extends BeanProperties {

	/**
	 * 
	 */
	private static final long serialVersionUID = -4203214421210581941L;
	private static final Logger log = LoggerFactory.getLogger(BeanPropertiesORMMapped.class);
	private List<BeanPropertyMapping> bpm;
	
    /**
	 * 
	 */
	public BeanPropertiesORMMapped(Class<?> beanClass, List<BeanPropertyMapping> bpm) throws IntrospectionException {
		super(beanClass);
		log.trace(">>> constructor");
		if (bpm == null) {
			throw new IllegalArgumentException("Wrong parameter bpm (= null)");
		}
		this.bpm = bpm;
		log.debug("bpm="+bpm+", this.bpm="+this.bpm);
    }
    
    @Override
    protected void addAllBeanProperties(PropertyDescriptor[] pds) {
    	log.trace("addAllBeanProperties");
    	//заполняем свойства на основе сведений о классе 
        for (int i = 0; i < pds.length; i++) {
            log.debug("Name="+pds[i].getName()+", bpm="+bpm);
            for (BeanPropertyMapping m : bpm) {
            	log.debug("Property="+m.getProperty());
            	if (pds[i].getName().equals(m.getProperty())) {
            		beanProperties.put(pds[i].getName(), new BeanPropertyORMMapped(pds[i], m));
            	}
            }
        }
    }
}
