package shiro.dao;

import java.io.Serializable;

public class AppUserPermission implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -3186151918194489753L;
	
	private String id;
    private String objectName;
    private String methodName;

    public AppUserPermission() {
    	this(null, null, null);
	}
	
	public AppUserPermission(String id, String objectName, String methodName) {
		this.id = id;
		this.objectName = objectName;
		this.methodName = methodName;
	}
	
	public String getId() {
		return id;
	}
	
	/**
	 * @param id the id to set
	 */
	public void setId(String id) {
		this.id = id;
	}

	public String getObjectName() {
		return objectName;
	}

	public void setObjectName(String objectName) {
		this.objectName = objectName;
	}

	public String getMethodName() {
		return methodName;
	}

	public void setMethodName(String methodName) {
		this.methodName = methodName;
	}
	
}
