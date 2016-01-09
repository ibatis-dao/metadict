package app.person;

import java.io.Serializable;

public class PersonLegal extends Person implements Serializable {

	private static final long serialVersionUID = -8362767749626694584L;
	
	private String nameShort; // Краткое наименование
	private String nameLong;  // Полное наименование

	public PersonLegal() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the nameShort
	 */
	public String getNameShort() {
		return nameShort;
	}

	/**
	 * @param nameShort the nameShort to set
	 */
	public void setNameShort(String nameShort) {
		this.nameShort = nameShort;
	}

	/**
	 * @return the nameLong
	 */
	public String getNameLong() {
		return nameLong;
	}

	/**
	 * @param nameLong the nameLong to set
	 */
	public void setNameLong(String nameLong) {
		this.nameLong = nameLong;
	}

}
