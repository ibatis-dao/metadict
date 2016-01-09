package app.person;

import java.io.Serializable;
import java.util.Calendar;

public class PersonIndividual extends Person implements Serializable {

	private static final long serialVersionUID = -4286050109241192287L;

	private String lastName; // Фамилия
	private String middleName; // Отчество
	private String firstName; // Имя
	private Calendar birthdate; // Дата рождения

	public PersonIndividual() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @return the lastName
	 */
	public String getLastName() {
		return lastName;
	}

	/**
	 * @param lastName the lastName to set
	 */
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	/**
	 * @return the middleName
	 */
	public String getMiddleName() {
		return middleName;
	}

	/**
	 * @param middleName the middleName to set
	 */
	public void setMiddleName(String middleName) {
		this.middleName = middleName;
	}

	/**
	 * @return the firstName
	 */
	public String getFirstName() {
		return firstName;
	}

	/**
	 * @param firstName the firstName to set
	 */
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	/**
	 * @return the birthdate
	 */
	public Calendar getBirthdate() {
		return birthdate;
	}

	/**
	 * @param birthdate the birthdate to set
	 */
	public void setBirthdate(Calendar birthdate) {
		this.birthdate = birthdate;
	}

}
