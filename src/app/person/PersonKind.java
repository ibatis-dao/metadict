package app.person;

import java.io.Serializable;

public class PersonKind implements Serializable {

	private static final long serialVersionUID = 2086963171601566119L;

	private String id;   // идентификатор
	private String name; // наименование

	public PersonKind() {
	}

	public PersonKind(String id, String name) {
		this.id = id;
		this.name = name;
	}

	/**
	 * @return the id
	 */
	public String getId() {
		return id;
	}

	/**
	 * @param id the id to set
	 */
	public void setId(String id) {
		this.id = id;
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

}
