package app.dict.country;

import java.io.Serializable;
import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import app.dict.CountryDAOtst;

public class Country implements Serializable /*, SQLData*/  {

	private static final long serialVersionUID = -2009341264796693438L;
	private static final transient Logger log = LoggerFactory.getLogger(Country.class);

	private Integer id; // идентификатор
	private String name;  // наименование
	private Integer number3code; // ISO 3166 Number3 code
	private String alpha2code; // ISO 3166 Alpha2 code
	private String alpha3code; // ISO 3166 Alpha3 code

	public Country() {
  	}

	public Country(Integer id, String name, Integer number3code, String alpha2code, String alpha3code) {
		this.id = id;
		this.name = name;
		this.number3code = number3code;
		this.alpha2code = alpha2code;
		this.alpha3code = alpha3code;
  	}

	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return "Country [id=" + id + ", name=" + name + ", number3code="
				+ number3code + ", alpha2code=" + alpha2code + ", alpha3code="
				+ alpha3code + "]";
	}

	/**
	 * @return the id
	 */
	public Integer getId() {
		return id;
	}

	/**
	 * @param id the id to set
	 */
	public void setId(Integer id) {
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
	public Integer getNumber3code() {
		return number3code;
	}

	/**
	 * @param number3code the number3code to set
	 */
	public void setNumber3code(Integer number3code) {
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

	/************************************
	 * interface SQLData implementation *
	 ************************************/
	/*
	private String sqlTypeName;

	@Override
	public String getSQLTypeName() throws SQLException {
		log.trace("getSQLTypeName()={}", sqlTypeName);
		return sqlTypeName;
	}

	@Override
	public void readSQL(SQLInput stream, String sqlTypeName) throws SQLException {
		log.trace("readSQL(sqlTypeName={})", sqlTypeName);
		setId(stream.readString()); // идентификатор
		setName(stream.readString());  // наименование
		setNumber3code(stream.readString()); // ISO 3166 Number3 code
		setAlpha2code(stream.readString()); // ISO 3166 Alpha2 code
		setAlpha3code(stream.readString()); // ISO 3166 Alpha3 code
	}

	@Override
	public void writeSQL(SQLOutput stream) throws SQLException {
		log.trace("writeSQL()");
		stream.writeString(getId());
		stream.writeString(getName());
		stream.writeString(getNumber3code());
		stream.writeString(getAlpha2code());
		stream.writeString(getAlpha3code());
	}
	*/
}
