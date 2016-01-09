package shiro.dao;

import java.io.Serializable;
import java.math.BigInteger;

import das.dao.IHasID;

public class AppUserRole implements Serializable, IHasID<BigInteger> {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1437257393269219116L;
	
	private BigInteger id;
    private String name;

    public AppUserRole() {
    	this(null, null);
    }
    
    public AppUserRole(BigInteger id, String name) {
		this.id = id;
		this.name = name;
	}

	@Override
	public BigInteger getId() {
		// TODO Auto-generated method stub
		return id;
	}

	/**
	 * @return the name
	 */
	public String getName() {
		return name;
	}

	/**
	 * @param name the name to set
	 */
	public void setName(String name) {
		this.name = name;
	}

	/**
	 * @param id the id to set
	 */
	public void setId(BigInteger id) {
		this.id = id;
	}

}
