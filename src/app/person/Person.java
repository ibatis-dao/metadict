package app.person;

import java.io.Serializable;

public class Person implements Serializable {

	private static final long serialVersionUID = 1346992454951924908L;
	private String id;                   // идентификатор
	private String citizenshipCountryId; // гражданство, национальная принадлежность, подданство
	private String languageId;           // родной (основной) язык для общения
	private PersonKind personKind;       // тип персоны

	public Person() {
	}

	public Person(String id, String citizenshipCountryId, String languageId, String personKindId, String personKindName) {
		this.id = id;
		this.citizenshipCountryId = citizenshipCountryId;
		this.languageId = languageId;
		this.setPersonKind(new PersonKind(personKindId, personKindName));
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
	 * @return the citizenship_country_id
	 */
	public String getCitizenshipCountryId() {
		return citizenshipCountryId;
	}

	/**
	 * @param citizenship_country_id the citizenship_country_id to set
	 */
	public void setCitizenshipCountryId(String citizenshipCountryId) {
		this.citizenshipCountryId = citizenshipCountryId;
	}

	/**
	 * @return the language_id
	 */
	public String getLanguageId() {
		return languageId;
	}

	/**
	 * @param language_id the language_id to set
	 */
	public void setLanguageId(String languageId) {
		this.languageId = languageId;
	}

	/**
	 * @return the person_kind_id
	 */
	public String getPersonKindId() {
		if (personKind != null) {
		  return personKind.getId();
		} else {
			return null;
		}
	}

	/**
	 * @return the personKind
	 */
	public PersonKind getPersonKind() {
		return personKind;
	}

	/**
	 * @param personKind the personKind to set
	 */
	public void setPersonKind(PersonKind personKind) {
		this.personKind = personKind;
	}

}
