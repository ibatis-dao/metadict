package app.dict.language;

import java.io.Serializable;

public class Language implements Serializable {

	private static final long serialVersionUID = 7406008793623617521L;

	private String id; // идентификатор
	private String name;  // Наименование языка
	private String number3code; // ISO 3166 Number3 code
	private String alpha2code; // ISO 639-1 alpha 2 code
	private String alpha3code; // ISO 639-3 alpha 3 code
	private String scope; //Scope of denotation for language identifiers...

	public Language() {
	}

	public Language(String id, String name, String number3code, String alpha2code, String alpha3code, String scope) {
		this.id = id;
		this.name = name;
		this.number3code = number3code;
		this.alpha2code = alpha2code;
		this.alpha3code = alpha3code;
		this.scope = scope;
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

	/**
	 * @return the number3code
	 */
	public String getNumber3code() {
		return number3code;
	}

	/**
	 * @param number3code the number3code to set
	 */
	public void setNumber3code(String number3code) {
		this.number3code = number3code;
	}

	/**
	 * @return the alpha2code
	 */
	public String getAlpha2code() {
		return alpha2code;
	}

	/**
	 * @param alpha2code the alpha2code to set
	 */
	public void setAlpha2code(String alpha2code) {
		this.alpha2code = alpha2code;
	}

	/**
	 * @return the alpha3code
	 */
	public String getAlpha3code() {
		return alpha3code;
	}

	/**
	 * @param alpha3code the alpha3code to set
	 */
	public void setAlpha3code(String alpha3code) {
		this.alpha3code = alpha3code;
	}

	/**
	 * @return the scope
	 */
	public String getScope() {
		return scope;
	}

	/**
	 * @param scope the scope to set
	 */
	public void setScope(String scope) {
		this.scope = scope;
	}

}
